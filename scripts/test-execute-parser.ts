import assert from "node:assert/strict";
import {
  extractParameters,
  hasJsonContentType,
  normalizeExecuteBody,
  normalizeChatRequest,
} from "../pages/api/execute/code";

function parseAndNormalize(code: string) {
  return normalizeChatRequest(extractParameters(code));
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
assert.equal(hasJsonContentType(["text/plain", "application/json"]), true);
assert.equal(hasJsonContentType("text/plain"), false);
assert.equal(hasJsonContentType(undefined), false);

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
