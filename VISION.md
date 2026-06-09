## Docs 002 Vision

This document explains the current state and direction of the project.
Project overview and developer docs: [`README.md`](README.md)

Docs 002 is a Next.js "Try Now Docs" prototype. It provides a documentation
experience that can proxy API requests and speed up onboarding through an
embedded editor.

The repository is useful as a compact docs-product experiment with Next.js,
React, CodeMirror, Radix UI, and OpenAI API integration dependencies. Setup and
scripts live in [`README.md`](README.md).

The goal is to keep the prototype easy to run while making API proxying,
editor behavior, and documentation UX decisions explicit.

The current focus is:

Priority:

- Preserve the docs onboarding flow shown in the README screenshot
- Keep `npm run dev`, `npm run lint`, `npm run build`, `npm run type-check`,
  and `npm test` meaningful
- Avoid committing API keys or proxy secrets
- Keep editor and navigation components reviewable

Current baseline:

- The execute API accepts only static `openai.chat.completions.create({ ... })`
  examples with JSON request bodies and bounded literal parameters.
- Chat messages may only include `role` and `content` so metadata is not
  accepted and then silently dropped.
- Proxied requests require `OPENAI_API_KEY` and use `OPENAI_ALLOWED_MODELS`
  when maintainers need a narrower model allow-list. Environment configuration
  cannot expand beyond the checked-in default model set.
- The editor sends the current code string directly and avoids logging prompt
  content, parsed parameters, or provider responses.

Next priorities:

- Expand execute API tests when the accepted request shape grows.
- Keep framework dependency versions pinned or intentionally managed.
- Clarify which docs flows are prototype-only versus intended product behavior.

Contribution rules:

- One PR = one focused docs UX, editor, API proxy, or tooling change.
- Run `npm test` before pushing code changes.
- Keep secrets in environment configuration.
- Update screenshots or README notes when the visible docs flow changes.

## Security

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

API proxying can expose credentials and user prompts. Do not commit OpenAI keys,
session secrets, or upstream API tokens.

Proxy routes should validate inputs, constrain destinations, and avoid logging
sensitive request content.

## What We Will Not Merge (For Now)

- Committed API keys or proxy credentials
- Open proxy behavior without validation
- UI redesigns that break the documented onboarding flow
- Dependency updates that skip build and type-check verification

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
