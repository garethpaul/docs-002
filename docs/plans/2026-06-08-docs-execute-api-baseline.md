---
title: docs-002 execute API baseline
date: 2026-06-08
status: completed
execution: code
---

## Context

The app lets a browser editor submit OpenAI chat completion code to a Next.js API route. The current route extracts parameters with a regex/string rewrite, logs request-derived data, constructs the OpenAI client at module load, and returns raw error messages. The package baseline also depends on floating or vulnerable transitive versions.

## Goals

- Replace regex/string parsing with AST-only extraction for `openai.chat.completions.create({ ... })` calls.
- Accept only static, bounded chat completion parameters that are safe to forward.
- Validate HTTP method, request body shape, configured API key, model, messages, and message content before calling OpenAI.
- Stop logging submitted code, parsed parameters, API responses, or raw provider errors.
- Pin a repeatable dependency and verification baseline that passes type check, build, script checks, and high-severity audit.

## Scope Boundaries

- Keep the existing Pages Router and editor UI architecture.
- Do not add authentication, persistence, streaming, or a new prompt-building workflow.
- Do not open or edit GitHub Actions workflows in this pass.

## Implementation Units

### U1: Safe API parser

Files: `pages/api/execute/code.ts`

Approach: Parse submitted code with Babel, locate direct `openai.chat.completions.create(...)` member calls, extract a single static object literal, and reject unsupported dynamic expressions. Normalize and bound `model`, `messages`, `temperature`, `top_p`, `max_tokens`, `presence_penalty`, `frequency_penalty`, `stop`, and `response_format`.

Verification: Type-check, build, source guard checks, and direct parser/validator tests cover the shipped baseline.

### U2: Request handling guardrails

Files: `pages/api/execute/code.ts`, `components/Editor.tsx`

Approach: Validate POST JSON input and max submitted code size, defer OpenAI client construction until after API key validation, return generic server errors, and send the editor's raw code string without double JSON encoding. Remove request/response console logging from the client.

Verification: Type check and source guard checks confirm no regex extraction or sensitive logging remains.

### U3: Dependency and verification baseline

Files: `package.json`, `package-lock.json`, `scripts/check-baseline.sh`, parser test files

Approach: Pin supported framework/tooling versions, refresh the lockfile from a clean install, add a focused source guard and parser test script, and expose `npm test`/`npm run check` as repeatable gates.

Verification: `npm test`, `npm run build`, `npm audit --audit-level=high`, and `git diff --check` pass.
