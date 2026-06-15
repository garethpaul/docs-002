import type { NextApiRequest, NextApiResponse } from "next";
import OpenAI from "openai";
import { parse } from "@babel/parser";
import traverse from "@babel/traverse";
import type {
  ArrayExpression,
  Expression,
  MemberExpression,
  ObjectExpression,
  ObjectProperty,
} from "@babel/types";
import type { ChatCompletionCreateParamsNonStreaming } from "openai/resources/chat/completions";

type JsonValue = string | number | boolean | null | JsonValue[] | JsonObject;
type JsonObject = { [key: string]: JsonValue };
type ChatMessage = { role: "system" | "user" | "assistant"; content: string };
type HeaderValue = string | string[] | undefined;
type ExecuteBody = { code: string };
type RateLimitDecision = { allowed: boolean; retryAfterSeconds: number };
type ChatCompletionParams = {
  model: string;
  messages: ChatMessage[];
  max_tokens: number;
  temperature?: number;
  top_p?: number;
  presence_penalty?: number;
  frequency_penalty?: number;
  stop?: string | string[];
  response_format?: { type: "text" | "json_object" };
};
type ErrorResponse = { error: string };

const MAX_CODE_LENGTH = 12000;
const MAX_MESSAGES = 20;
const MAX_MESSAGE_CONTENT_LENGTH = 8000;
const MAX_COMPLETION_TOKENS = 2048;
const DEFAULT_COMPLETION_TOKENS = 512;
export const EXECUTE_RATE_LIMIT_MAX_REQUESTS = 10;
export const EXECUTE_RATE_LIMIT_WINDOW_MS = 60_000;
export const EXECUTE_CACHE_CONTROL = "no-store";
export const OPENAI_REQUEST_OPTIONS = Object.freeze({ timeout: 30_000, maxRetries: 0 });
const ALLOWED_MESSAGE_ROLES = new Set(["system", "user", "assistant"]);
const ALLOWED_BODY_FIELDS = new Set(["code"]);
const ALLOWED_MESSAGE_FIELDS = new Set(["role", "content"]);
const ALLOWED_PARAMETER_NAMES = new Set([
  "model",
  "messages",
  "temperature",
  "top_p",
  "max_tokens",
  "presence_penalty",
  "frequency_penalty",
  "stop",
  "response_format",
]);
const DEFAULT_ALLOWED_MODELS = ["gpt-3.5-turbo", "gpt-4o-mini"];

export const config = {
  api: {
    bodyParser: {
      sizeLimit: "16kb",
    },
  },
};

export function createFixedWindowRateLimiter(maxRequests: number, windowMs: number) {
  if (!Number.isInteger(maxRequests) || maxRequests <= 0) {
    throw new TypeError("maxRequests must be a positive integer");
  }
  if (!Number.isInteger(windowMs) || windowMs <= 0) {
    throw new TypeError("windowMs must be a positive integer");
  }

  let windowStartedAt: number | null = null;
  let requestCount = 0;

  return (now = Date.now()): RateLimitDecision => {
    if (!Number.isFinite(now)) {
      throw new TypeError("now must be finite");
    }

    if (
      windowStartedAt === null ||
      now < windowStartedAt ||
      now - windowStartedAt >= windowMs
    ) {
      windowStartedAt = now;
      requestCount = 0;
    }

    const remainingMs = Math.max(1, windowMs - (now - windowStartedAt));
    const retryAfterSeconds = Math.max(1, Math.ceil(remainingMs / 1000));
    if (requestCount >= maxRequests) {
      return { allowed: false, retryAfterSeconds };
    }

    requestCount += 1;
    return { allowed: true, retryAfterSeconds };
  };
}

const consumeExecuteCapacity = createFixedWindowRateLimiter(
  EXECUTE_RATE_LIMIT_MAX_REQUESTS,
  EXECUTE_RATE_LIMIT_WINDOW_MS,
);

export function enforceExecuteRateLimit(
  res: NextApiResponse<unknown | ErrorResponse>,
  now = Date.now(),
) {
  const rateLimit = consumeExecuteCapacity(now);
  if (rateLimit.allowed) {
    return false;
  }

  res.setHeader("Retry-After", String(rateLimit.retryAfterSeconds));
  res.status(429).json({ error: "Execute API request limit exceeded" });
  return true;
}

function isNamedMember(expression: unknown, propertyName: string): expression is MemberExpression {
  const member = expression as MemberExpression;
  return (
    member?.type === "MemberExpression" &&
    !member.computed &&
    member.property.type === "Identifier" &&
    member.property.name === propertyName
  );
}

function isOpenAIChatCompletionsCreate(callee: unknown) {
  if (!isNamedMember(callee, "create")) {
    return false;
  }

  const completions = callee.object;
  if (!isNamedMember(completions, "completions")) {
    return false;
  }

  const chat = completions.object;
  if (!isNamedMember(chat, "chat")) {
    return false;
  }

  return chat.object.type === "Identifier" && chat.object.name === "openai";
}

function propertyName(property: ObjectProperty) {
  if (property.computed) {
    return null;
  }
  if (property.key.type === "Identifier") {
    return property.key.name;
  }
  if (property.key.type === "StringLiteral") {
    return property.key.value;
  }
  return null;
}

function hasOwnJsonField(value: object, field: string): boolean {
  return Object.prototype.hasOwnProperty.call(value, field);
}

function literalValue(expression: Expression): JsonValue | undefined {
  switch (expression.type) {
    case "StringLiteral":
    case "NumericLiteral":
    case "BooleanLiteral":
      return expression.value;
    case "NullLiteral":
      return null;
    case "UnaryExpression":
      if (expression.operator === "-" && expression.argument.type === "NumericLiteral") {
        return -expression.argument.value;
      }
      return undefined;
    case "ArrayExpression":
      return arrayValue(expression);
    case "ObjectExpression":
      return objectValue(expression);
    default:
      return undefined;
  }
}

function arrayValue(expression: ArrayExpression): JsonValue[] | undefined {
  const values: JsonValue[] = [];

  for (const element of expression.elements) {
    if (!element || element.type === "SpreadElement") {
      return undefined;
    }

    const value = literalValue(element);
    if (value === undefined) {
      return undefined;
    }
    values.push(value);
  }

  return values;
}

function objectValue(expression: ObjectExpression): JsonObject | undefined {
  const value = Object.create(null) as JsonObject;

  for (const property of expression.properties) {
    if (property.type !== "ObjectProperty") {
      return undefined;
    }

    const name = propertyName(property);
    if (!name) {
      return undefined;
    }
    if (Object.prototype.hasOwnProperty.call(value, name)) {
      return undefined;
    }

    const propertyValue = literalValue(property.value as Expression);
    if (propertyValue === undefined) {
      return undefined;
    }

    value[name] = propertyValue;
  }

  return value;
}

export function extractParameters(code: string): JsonObject | null {
  try {
    const ast = parse(code, {
      sourceType: "module",
      plugins: ["typescript", "jsx"],
    });

    let params: JsonObject | null = null;
    let matchCount = 0;

    traverse(ast, {
      CallExpression(path) {
        if (!isOpenAIChatCompletionsCreate(path.node.callee)) {
          return;
        }

        const [argument] = path.node.arguments;
        if (!argument || argument.type !== "ObjectExpression") {
          params = null;
          path.stop();
          return;
        }

        matchCount += 1;
        params = objectValue(argument) ?? null;
      },
    });

    return matchCount === 1 ? params : null;
  } catch {
    return null;
  }
}

function allowedModels() {
  const defaultAllowedModels = new Set(DEFAULT_ALLOWED_MODELS);
  const configuredModelList = process.env.OPENAI_ALLOWED_MODELS;
  if (configuredModelList === undefined) {
    return defaultAllowedModels;
  }

  const configuredModels = configuredModelList
    .split(",")
    .map((model) => model.trim())
    .filter(Boolean);

  return new Set(configuredModels.filter((model) => defaultAllowedModels.has(model)));
}

export function hasJsonContentType(contentType: HeaderValue): boolean {
  if (typeof contentType !== "string") {
    return false;
  }

  return (
    contentType.split(";")[0].trim().toLowerCase() === "application/json"
  );
}

export function isExecuteApiEnabled(value = process.env.DOCS_EXECUTE_ENABLED): boolean {
  return typeof value === "string" && value.trim().toLowerCase() === "true";
}

export function normalizeOpenAIApiKey(value: unknown = process.env.OPENAI_API_KEY) {
  if (typeof value !== "string") {
    return null;
  }

  return value.trim() || null;
}

export function normalizeExecuteBody(body: unknown): ExecuteBody | null {
  if (!body || typeof body !== "object" || Array.isArray(body)) {
    return null;
  }

  const payload = body as Record<string, unknown>;
  if (Object.keys(payload).some((name) => !ALLOWED_BODY_FIELDS.has(name))) {
    return null;
  }

  if (!hasOwnJsonField(payload, "code") || typeof payload.code !== "string") {
    return null;
  }

  return { code: payload.code };
}

function numberInRange(
  value: JsonValue | undefined,
  min: number,
  max: number,
  integer = false,
) {
  if (typeof value !== "number" || !Number.isFinite(value) || value < min || value > max) {
    return null;
  }
  if (integer && !Number.isInteger(value)) {
    return null;
  }
  return value;
}

function normalizeMessages(value: JsonValue | undefined): ChatMessage[] | null {
  if (!Array.isArray(value) || value.length === 0 || value.length > MAX_MESSAGES) {
    return null;
  }

  let totalContentLength = 0;
  const messages: ChatMessage[] = [];

  for (const message of value) {
    if (!message || typeof message !== "object" || Array.isArray(message)) {
      return null;
    }

    if (Object.keys(message).some((name) => !ALLOWED_MESSAGE_FIELDS.has(name))) {
      return null;
    }

    if (!hasOwnJsonField(message, "role") || !hasOwnJsonField(message, "content")) {
      return null;
    }

    const role = message.role;
    const content = message.content;
    if (
      typeof role !== "string" ||
      !ALLOWED_MESSAGE_ROLES.has(role) ||
      typeof content !== "string" ||
      content.length === 0 ||
      content.trim().length === 0 ||
      content.length > MAX_MESSAGE_CONTENT_LENGTH
    ) {
      return null;
    }

    totalContentLength += content.length;
    if (totalContentLength > MAX_MESSAGE_CONTENT_LENGTH) {
      return null;
    }

    messages.push({ role: role as ChatMessage["role"], content });
  }

  return messages;
}

function normalizeStop(value: JsonValue | undefined) {
  if (value === undefined) {
    return undefined;
  }
  if (typeof value === "string" && value.length > 0 && value.length <= 100) {
    return value;
  }
  if (
    Array.isArray(value) &&
    value.length > 0 &&
    value.length <= 4 &&
    value.every((entry) => typeof entry === "string" && entry.length > 0 && entry.length <= 100)
  ) {
    return value as string[];
  }
  return null;
}

function normalizeResponseFormat(
  value: JsonValue | undefined,
): ChatCompletionParams["response_format"] | null | undefined {
  if (value === undefined) {
    return undefined;
  }
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return null;
  }
  const keys = Object.keys(value);
  if (keys.length !== 1 || keys[0] !== "type") {
    return null;
  }
  const responseType = value.type;
  if (responseType !== "text" && responseType !== "json_object") {
    return null;
  }
  return { type: responseType };
}

export function normalizeChatRequest(params: JsonObject | null): ChatCompletionParams | null {
  if (!params || Object.keys(params).some((name) => !ALLOWED_PARAMETER_NAMES.has(name))) {
    return null;
  }
  if (!hasOwnJsonField(params, "model") || !hasOwnJsonField(params, "messages")) {
    return null;
  }

  const model = params.model;
  if (typeof model !== "string" || model.trim() === "" || !allowedModels().has(model)) {
    return null;
  }

  const messages = normalizeMessages(params.messages);
  if (!messages) {
    return null;
  }

  const maxTokens =
    !hasOwnJsonField(params, "max_tokens")
      ? DEFAULT_COMPLETION_TOKENS
      : numberInRange(params.max_tokens, 1, MAX_COMPLETION_TOKENS, true);
  const normalized: ChatCompletionParams = { model, messages, max_tokens: maxTokens ?? 0 };
  if (!maxTokens) {
    return null;
  }

  const numericOptions = [
    ["temperature", 0, 2],
    ["top_p", 0, 1],
    ["presence_penalty", -2, 2],
    ["frequency_penalty", -2, 2],
  ] as const;

  for (const [name, min, max] of numericOptions) {
    if (!hasOwnJsonField(params, name)) {
      continue;
    }
    const value = numberInRange(params[name], min, max);
    if (value === null) {
      return null;
    }
    normalized[name] = value;
  }

  const stop = hasOwnJsonField(params, "stop") ? normalizeStop(params.stop) : undefined;
  if (stop === null) {
    return null;
  }
  if (stop !== undefined) {
    normalized.stop = stop;
  }

  const responseFormat = hasOwnJsonField(params, "response_format")
    ? normalizeResponseFormat(params.response_format)
    : undefined;
  if (responseFormat === null) {
    return null;
  }
  if (responseFormat !== undefined) {
    normalized.response_format = responseFormat;
  }

  return normalized;
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse<unknown | ErrorResponse>,
) {
  res.setHeader("Cache-Control", EXECUTE_CACHE_CONTROL);

  if (req.method !== "POST") {
    res.setHeader("Allow", "POST");
    return res.status(405).json({ error: "Method not allowed" });
  }

  if (!isExecuteApiEnabled()) {
    return res.status(503).json({ error: "Execute API is disabled" });
  }

  if (!hasJsonContentType(req.headers["content-type"])) {
    return res.status(415).json({ error: "Request content type must be application/json" });
  }

  const body = normalizeExecuteBody(req.body);
  if (!body) {
    return res.status(400).json({ error: "Request body must include only a code string" });
  }

  if (body.code.length > MAX_CODE_LENGTH) {
    return res.status(413).json({ error: "Code sample is too large" });
  }

  const params = normalizeChatRequest(extractParameters(body.code));
  if (!params) {
    return res.status(400).json({
      error: "Code must contain a literal, allowed openai.chat.completions.create request",
    });
  }

  const apiKey = normalizeOpenAIApiKey();
  if (!apiKey) {
    return res.status(503).json({ error: "OPENAI_API_KEY is not configured" });
  }

  if (enforceExecuteRateLimit(res)) {
    return;
  }

  try {
    const openai = new OpenAI({ apiKey });
    const completion = await openai.chat.completions.create(
      params as ChatCompletionCreateParamsNonStreaming,
      OPENAI_REQUEST_OPTIONS,
    );
    return res.status(200).json(completion.choices);
  } catch {
    return res.status(502).json({ error: "OpenAI request failed" });
  }
}
