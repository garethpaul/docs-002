## Docs 002 Vision

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
- Keep `npm run dev`, `npm run build`, and `npm run type-check` meaningful
- Avoid committing API keys or proxy secrets
- Keep editor and navigation components reviewable

Next priorities:

- Document environment variables and proxy behavior
- Add tests or checks around editor parsing and request proxy boundaries
- Pin or intentionally manage framework dependency versions
- Clarify which docs flows are prototype-only versus intended product behavior

Contribution rules:

- One PR = one focused docs UX, editor, API proxy, or tooling change.
- Run `npm run type-check` and `npm run build` before pushing code changes.
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
