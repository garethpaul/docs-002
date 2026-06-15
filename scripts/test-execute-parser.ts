import assert from "node:assert/strict";
import type { NextApiRequest, NextApiResponse } from "next";
import executeHandler, {
  createFixedWindowRateLimiter,
  enforceExecuteRateLimit,
  EXECUTE_CACHE_CONTROL,
  EXECUTE_RATE_LIMIT_MAX_REQUESTS,
  EXECUTE_RATE_LIMIT_WINDOW_MS,
  extractParameters,
  hasJsonContentType,
  isExecuteApiEnabled,
  normalizeOpenAIApiKey,
  normalizeExecuteBody,
  normalizeChatRequest,
  OPENAI_REQUEST_OPTIONS,
} from "../pages/api/execute/code";

type TestResponse = {
  body: unknown;
  headers: Record<string, string>;
  statusCode: number;
  setHeader(name: string, value: string): void;
  status(code: number): TestResponse;
  json(body: unknown): TestResponse;
};

function createTestResponse(): TestResponse {
  return {
    body: null,
    headers: {},
    statusCode: 200,
    setHeader(name, value) {
      this.headers[name] = value;
    },
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(body) {
      this.body = body;
      return this;
    },
  };
}

function parseAndNormalize(code: string) {
  return normalizeChatRequest(extractParameters(code));
}

assert.deepEqual(OPENAI_REQUEST_OPTIONS, { timeout: 30_000, maxRetries: 0 });
assert.equal(Object.isFrozen(OPENAI_REQUEST_OPTIONS), true);
assert.equal(EXECUTE_CACHE_CONTROL, "no-store");
assert.equal(EXECUTE_RATE_LIMIT_MAX_REQUESTS, 10);
assert.equal(EXECUTE_RATE_LIMIT_WINDOW_MS, 60_000);
const originalApiKey = process.env.OPENAI_API_KEY;
delete process.env.OPENAI_API_KEY;
assert.equal(normalizeOpenAIApiKey(), null);
if (originalApiKey !== undefined) {
  process.env.OPENAI_API_KEY = originalApiKey;
}
assert.equal(normalizeOpenAIApiKey(null), null);
assert.equal(normalizeOpenAIApiKey(""), null);
assert.equal(normalizeOpenAIApiKey("   "), null);
assert.equal(normalizeOpenAIApiKey("  test-api-key  "), "test-api-key");

const consumeCapacity = createFixedWindowRateLimiter(
  EXECUTE_RATE_LIMIT_MAX_REQUESTS,
  EXECUTE_RATE_LIMIT_WINDOW_MS,
);
for (let request = 0; request < EXECUTE_RATE_LIMIT_MAX_REQUESTS; request += 1) {
  assert.deepEqual(consumeCapacity(1_000), { allowed: true, retryAfterSeconds: 60 });
}
assert.deepEqual(consumeCapacity(1_000), { allowed: false, retryAfterSeconds: 60 });
assert.deepEqual(consumeCapacity(60_000), { allowed: false, retryAfterSeconds: 1 });
assert.deepEqual(consumeCapacity(61_000), { allowed: true, retryAfterSeconds: 60 });
assert.deepEqual(consumeCapacity(500), { allowed: true, retryAfterSeconds: 60 });
assert.throws(() => createFixedWindowRateLimiter(0, 60_000), TypeError);
assert.throws(() => createFixedWindowRateLimiter(10, Number.NaN), TypeError);
assert.throws(() => consumeCapacity(Number.POSITIVE_INFINITY), TypeError);

for (let request = 0; request < EXECUTE_RATE_LIMIT_MAX_REQUESTS; request += 1) {
  const response = createTestResponse();
  assert.equal(
    enforceExecuteRateLimit(response as unknown as NextApiResponse, 10_000),
    false,
  );
  assert.equal(response.statusCode, 200);
}

const limitedResponse = createTestResponse();
assert.equal(
  enforceExecuteRateLimit(limitedResponse as unknown as NextApiResponse, 10_000),
  true,
);
assert.equal(limitedResponse.statusCode, 429);
assert.match(limitedResponse.headers["Retry-After"], /^[1-9][0-9]*$/);
assert.deepEqual(limitedResponse.body, { error: "Execute API request limit exceeded" });

const originalExecuteEnabled = process.env.DOCS_EXECUTE_ENABLED;
try {
  process.env.DOCS_EXECUTE_ENABLED = "true";
  const currentWindow = Date.now();
  for (let request = 0; request < EXECUTE_RATE_LIMIT_MAX_REQUESTS; request += 1) {
    enforceExecuteRateLimit(
      createTestResponse() as unknown as NextApiResponse,
      currentWindow,
    );
  }

  const invalidContentTypeResponse = createTestResponse();
  void executeHandler(
    {
      method: "POST",
      headers: { "content-type": "text/plain" },
      body: { code: "const invalid = true;" },
    } as NextApiRequest,
    invalidContentTypeResponse as unknown as NextApiResponse,
  );
  assert.equal(invalidContentTypeResponse.statusCode, 415);
  assert.deepEqual(invalidContentTypeResponse.body, {
    error: "Request content type must be application/json",
  });

  process.env.OPENAI_API_KEY = "   ";
  const blankApiKeyResponse = createTestResponse();
  void executeHandler(
    {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: {
        code: `await openai.chat.completions.create({
          model: "gpt-4o-mini",
          messages: [{ role: "user", content: "Hello" }]
        });`,
      },
    } as NextApiRequest,
    blankApiKeyResponse as unknown as NextApiResponse,
  );
  assert.equal(blankApiKeyResponse.statusCode, 503);
  assert.deepEqual(blankApiKeyResponse.body, {
    error: "OPENAI_API_KEY is not configured",
  });
} finally {
  if (originalExecuteEnabled === undefined) {
    delete process.env.DOCS_EXECUTE_ENABLED;
  } else {
    process.env.DOCS_EXECUTE_ENABLED = originalExecuteEnabled;
  }
  if (originalApiKey === undefined) {
    delete process.env.OPENAI_API_KEY;
  } else {
    process.env.OPENAI_API_KEY = originalApiKey;
  }
}

const validRequest = parseAndNormalize(`
  import OpenAI from "openai";

  const openai = new OpenAI();
  async function main() {
    return openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: "Be brief." },
        { role: "user", content: "Say this is a test." }
      ],
      max_tokens: 128,
      temperature: 0.2,
      presence_penalty: -1,
      response_format: { type: "text" }
    });
  }
`);

assert.deepEqual(validRequest, {
  model: "gpt-4o-mini",
  messages: [
    { role: "system", content: "Be brief." },
    { role: "user", content: "Say this is a test." },
  ],
  max_tokens: 128,
  temperature: 0.2,
  presence_penalty: -1,
  response_format: { type: "text" },
});

assert.equal(parseAndNormalize("const value = 1;"), null);

assert.equal(hasJsonContentType("application/json"), true);
assert.equal(hasJsonContentType("Application/JSON; charset=utf-8"), true);
assert.equal(hasJsonContentType(["text/plain", "application/json"]), false);
assert.equal(hasJsonContentType(["application/json", "application/json"]), false);
assert.equal(hasJsonContentType([]), false);
assert.equal(hasJsonContentType("text/plain"), false);
assert.equal(hasJsonContentType(undefined), false);

assert.equal(isExecuteApiEnabled(undefined), false);
assert.equal(isExecuteApiEnabled("false"), false);
assert.equal(isExecuteApiEnabled("1"), false);
assert.equal(isExecuteApiEnabled(" yes "), false);
assert.equal(isExecuteApiEnabled(" TRUE "), true);

assert.deepEqual(normalizeExecuteBody({ code: "const value = 1;" }), {
  code: "const value = 1;",
});
assert.equal(normalizeExecuteBody({ code: "const value = 1;", apiKey: "secret" }), null);
assert.equal(normalizeExecuteBody(["const value = 1;"]), null);
assert.equal(normalizeExecuteBody({ code: 123 }), null);
assert.equal(normalizeExecuteBody(Object.create({ code: "const inherited = true;" })), null);

assert.equal(
  parseAndNormalize(`
    await openai.chat.completions.create({
      model: process.env.MODEL,
      messages: [{ role: "user", content: "Hello" }]
    });
  `),
  null,
);

assert.equal(
  normalizeChatRequest(Object.create({
    model: "gpt-4o-mini",
    messages: [{ role: "user", content: "Inherited params" }],
  })),
  null,
);

const inheritedMessage = Object.create({ role: "user", content: "Inherited message" });
assert.equal(
  normalizeChatRequest({
    model: "gpt-4o-mini",
    messages: [inheritedMessage],
    max_tokens: 128,
  } as any),
  null,
);

assert.equal(
  parseAndNormalize(`
    await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "tool", content: "Hello" }]
    });
  `),
  null,
);

assert.equal(
  parseAndNormalize(`
    await openai.chat.completions.create({
      model: "gpt-4o-mini",
      "__proto__": { polluted: true },
      messages: [{ role: "user", content: "Hello" }]
    });
  `),
  null,
);

assert.equal(
  parseAndNormalize(`
    await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: "Hello", "__proto__": { polluted: true } }]
    });
  `),
  null,
);

assert.equal(
  parseAndNormalize(`
    await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: "Hello", name: "sample-user" }]
    });
  `),
  null,
);

assert.equal(
  parseAndNormalize(`
    await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: ${JSON.stringify("x".repeat(8001))} }]
    });
  `),
  null,
);

assert.equal(
  parseAndNormalize(`
    await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: "One" }]
    });
    await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: "Two" }]
    });
  `),
  null,
);

assert.equal(
  parseAndNormalize(`
    await openai.chat.completions.create({
      model: "gpt-4o-mini",
      model: "gpt-3.5-turbo",
      messages: [{ role: "user", content: "Duplicate model" }]
    });
  `),
  null,
);

assert.equal(
  parseAndNormalize(`
    await openai.chat.completions.create({
      model: "not-allowed",
      messages: [{ role: "user", content: "Hello" }]
    });
  `),
  null,
);

const originalAllowedModels = process.env.OPENAI_ALLOWED_MODELS;
try {
  process.env.OPENAI_ALLOWED_MODELS = "gpt-4o-mini";
  assert.equal(
    parseAndNormalize(`
      await openai.chat.completions.create({
        model: "gpt-3.5-turbo",
        messages: [{ role: "user", content: "Hello" }]
      });
    `),
    null,
  );
  assert.deepEqual(
    parseAndNormalize(`
      await openai.chat.completions.create({
        model: "gpt-4o-mini",
        messages: [{ role: "user", content: "Hello" }]
      });
    `),
    {
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: "Hello" }],
      max_tokens: 512,
    },
  );

  process.env.OPENAI_ALLOWED_MODELS = "not-allowed";
  assert.equal(
    parseAndNormalize(`
      await openai.chat.completions.create({
        model: "not-allowed",
        messages: [{ role: "user", content: "Hello" }]
      });
    `),
    null,
  );
} finally {
  if (originalAllowedModels === undefined) {
    delete process.env.OPENAI_ALLOWED_MODELS;
  } else {
    process.env.OPENAI_ALLOWED_MODELS = originalAllowedModels;
  }
}

assert.equal(
  parseAndNormalize(`
    await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: "Hello" }],
      stream: true
    });
  `),
  null,
);

assert.equal(
  parseAndNormalize(`
    await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: "Hello" }],
      max_tokens: 4096
    });
  `),
  null,
);

assert.equal(
  parseAndNormalize(`
    await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: "Hello" }],
      temperature: 1e309
    });
  `),
  null,
);

console.log("execute parser tests passed.");
