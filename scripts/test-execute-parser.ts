import assert from "node:assert/strict";
import type { NextApiRequest, NextApiResponse } from "next";
import executeHandler, {
  createFixedWindowRateLimiter,
  enforceExecuteRateLimit,
  EXECUTE_CACHE_CONTROL,
  EXECUTE_RATE_LIMIT_MAX_REQUESTS,
  EXECUTE_RATE_LIMIT_WINDOW_MS,
  extractParameters,
  hasValidExecuteAuthorization,
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

assert.equal(hasValidExecuteAuthorization("Bearer exact-token", "exact-token"), true);
assert.equal(hasValidExecuteAuthorization("Bearer wrong-token", "exact-token"), false);
assert.equal(hasValidExecuteAuthorization("Bearer token", "longer-token"), false);
assert.equal(hasValidExecuteAuthorization("Bearer påss-token", "påss-token"), true);
assert.equal(hasValidExecuteAuthorization("Bearer pass-token", "påss-token"), false);

const originalExecuteToken = process.env.EXECUTE_API_TOKEN;
const originalExecuteEnabledForAuth = process.env.DOCS_EXECUTE_ENABLED;
try {
  process.env.DOCS_EXECUTE_ENABLED = "true";
  for (const configuredToken of [undefined, "   "] as const) {
    if (configuredToken === undefined) {
      delete process.env.EXECUTE_API_TOKEN;
    } else {
      process.env.EXECUTE_API_TOKEN = configuredToken;
    }

    const missingTokenConfigurationResponse = createTestResponse();
    void executeHandler(
      {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: {},
      } as NextApiRequest,
      missingTokenConfigurationResponse as unknown as NextApiResponse,
    );
    assert.equal(missingTokenConfigurationResponse.statusCode, 503);
    assert.deepEqual(missingTokenConfigurationResponse.body, {
      error: "Execute API authentication is not configured",
    });
  }

  process.env.EXECUTE_API_TOKEN = "test-execute-token";
  for (const authorization of [
    undefined,
    "Basic test-execute-token",
    "Bearer wrong-token",
    "Bearer test-execute-token extra",
    ["Bearer test-execute-token"],
  ] as const) {
    const unauthorizedResponse = createTestResponse();
    void executeHandler(
      {
        method: "POST",
        headers: {
          "content-type": "application/json",
          ...(authorization === undefined ? {} : { authorization }),
        },
        body: {},
      } as NextApiRequest,
      unauthorizedResponse as unknown as NextApiResponse,
    );
    assert.equal(unauthorizedResponse.statusCode, 401);
    assert.equal(unauthorizedResponse.headers["WWW-Authenticate"], "Bearer");
    assert.deepEqual(unauthorizedResponse.body, { error: "Unauthorized" });
  }

  const authorizedResponse = createTestResponse();
  void executeHandler(
    {
      method: "POST",
      headers: {
        authorization: "bearer test-execute-token",
        "content-type": "application/json",
      },
      body: {},
    } as NextApiRequest,
    authorizedResponse as unknown as NextApiResponse,
  );
  assert.equal(authorizedResponse.statusCode, 400);
  assert.deepEqual(authorizedResponse.body, {
    error: "Request body must include only a code string",
  });
} finally {
  if (originalExecuteToken === undefined) {
    delete process.env.EXECUTE_API_TOKEN;
  } else {
    process.env.EXECUTE_API_TOKEN = originalExecuteToken;
  }
  if (originalExecuteEnabledForAuth === undefined) {
    delete process.env.DOCS_EXECUTE_ENABLED;
  } else {
    process.env.DOCS_EXECUTE_ENABLED = originalExecuteEnabledForAuth;
  }
}

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
  process.env.EXECUTE_API_TOKEN = "test-execute-token";
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
      headers: {
        authorization: "Bearer test-execute-token",
        "content-type": "text/plain",
      },
      body: { code: "const invalid = true;" },
    } as NextApiRequest,
    invalidContentTypeResponse as unknown as NextApiResponse,
  );
  assert.equal(invalidContentTypeResponse.statusCode, 415);
  assert.deepEqual(invalidContentTypeResponse.body, {
    error: "Request content type must be application/json",
  });

  const invalidParameterizedContentTypeResponse = createTestResponse();
  void executeHandler(
    {
      method: "POST",
      headers: {
        authorization: "Bearer test-execute-token",
        "content-type": "application/json; charset=latin1",
      },
      body: { code: "const invalid = true;" },
    } as NextApiRequest,
    invalidParameterizedContentTypeResponse as unknown as NextApiResponse,
  );
  assert.equal(invalidParameterizedContentTypeResponse.statusCode, 415);
  assert.deepEqual(invalidParameterizedContentTypeResponse.body, {
    error: "Request content type must be application/json",
  });

  process.env.OPENAI_API_KEY = "   ";
  const blankApiKeyResponse = createTestResponse();
  void executeHandler(
    {
      method: "POST",
      headers: {
        authorization: "Bearer test-execute-token",
        "content-type": "application/json",
      },
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

  process.env.OPENAI_API_KEY = "test-api-key";
  const malformedUnicodeResponse = createTestResponse();
  void executeHandler(
    {
      method: "POST",
      headers: {
        authorization: "Bearer test-execute-token",
        "content-type": "application/json",
      },
      body: {
        code: `await openai.chat.completions.create({
          model: "gpt-4o-mini",
          messages: [{ role: "user", content: "Broken \\ud800" }]
        });`,
      },
    } as NextApiRequest,
    malformedUnicodeResponse as unknown as NextApiResponse,
  );
  assert.equal(malformedUnicodeResponse.statusCode, 400);
  assert.deepEqual(malformedUnicodeResponse.body, {
    error: "Code must contain a literal, allowed openai.chat.completions.create request",
  });
} finally {
  if (originalExecuteEnabled === undefined) {
    delete process.env.DOCS_EXECUTE_ENABLED;
  } else {
    process.env.DOCS_EXECUTE_ENABLED = originalExecuteEnabled;
  }
  if (originalExecuteToken === undefined) {
    delete process.env.EXECUTE_API_TOKEN;
  } else {
    process.env.EXECUTE_API_TOKEN = originalExecuteToken;
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
assert.equal(hasJsonContentType(' application/json ; Charset = "UTF-8" '), true);
assert.equal(hasJsonContentType('application/json; charset="utf\\-8"'), true);
for (const invalidContentType of [
  "application/json;",
  "application/json; charset",
  "application/json; charset=",
  'application/json; charset="',
  'application/json; charset="utf-8',
  "application/json; charset=latin1",
  "application/json; charset=utf-8; charset=utf-8",
  "application/json; profile=test",
  'application/json; charset="utf\\\u0001-8"',
  "application/json, text/plain",
] as const) {
  assert.equal(hasJsonContentType(invalidContentType), false);
}
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

for (const blankContent of ["", "   ", "\t\n", "\u00a0", "\ufeff"] as const) {
  assert.equal(
    normalizeChatRequest({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: blankContent }],
    }),
    null,
  );
}

for (const malformedContent of [
  "Broken \ud800 text",
  "Broken \udfff text",
  "Broken \ud800",
] as const) {
  assert.equal(
    normalizeChatRequest({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: malformedContent }],
    }),
    null,
  );
}

assert.deepEqual(
  normalizeChatRequest({
    model: "gpt-4o-mini",
    messages: [{ role: "user", content: "Launch \ud83d\ude80" }],
  }),
  {
    model: "gpt-4o-mini",
    messages: [{ role: "user", content: "Launch \ud83d\ude80" }],
    max_tokens: 512,
  },
);

for (const malformedStop of ["\ud800", "Broken \udfff stop", "Broken \ud800"] as const) {
  assert.equal(
    normalizeChatRequest({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: "Hello" }],
      stop: malformedStop,
    }),
    null,
  );
}

assert.equal(
  normalizeChatRequest({
    model: "gpt-4o-mini",
    messages: [{ role: "user", content: "Hello" }],
    stop: ["END", "Broken \ud800 stop"],
  }),
  null,
);

assert.deepEqual(
  normalizeChatRequest({
    model: "gpt-4o-mini",
    messages: [{ role: "user", content: "Hello" }],
    stop: [" \t ", "Launch \ud83d\ude80"],
  }),
  {
    model: "gpt-4o-mini",
    messages: [{ role: "user", content: "Hello" }],
    max_tokens: 512,
    stop: [" \t ", "Launch \ud83d\ude80"],
  },
);

assert.equal(
  normalizeChatRequest({
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: "Be brief." },
      { role: "user", content: " \t " },
    ],
  }),
  null,
);

assert.deepEqual(
  normalizeChatRequest({
    model: "gpt-4o-mini",
    messages: [{ role: "user", content: "  Keep this spacing.  " }],
  }),
  {
    model: "gpt-4o-mini",
    messages: [{ role: "user", content: "  Keep this spacing.  " }],
    max_tokens: 512,
  },
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

  for (const emptyConfiguration of ["   ", " , , "]) {
    process.env.OPENAI_ALLOWED_MODELS = emptyConfiguration;
    assert.equal(
      parseAndNormalize(`
        await openai.chat.completions.create({
          model: "gpt-4o-mini",
          messages: [{ role: "user", content: "Hello" }]
        });
      `),
      null,
    );
  }

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
