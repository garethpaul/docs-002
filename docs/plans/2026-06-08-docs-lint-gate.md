---
title: docs-002 lint gate
date: 2026-06-08
status: completed
execution: code
---

## Context

The project had type-check, parser, build, source guard, and audit gates, but
no lint gate for the checked-in TypeScript and TSX source.

## Goals

- Add a flat ESLint config for the Next/TypeScript source tree.
- Align the documented Node baseline with the ESLint 10 toolchain.
- Make lint fail on warnings.
- Run lint before type-check, parser tests, build, source guard, and audit in
  `npm test`.
- Document the new gate and keep it covered by the source baseline.

## Verification

- `npm run lint`
- `npm test`
- `npm audit --audit-level=high`
- `git diff --check`
