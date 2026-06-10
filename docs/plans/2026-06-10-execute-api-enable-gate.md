---
title: Execute API Enable Gate
type: security
status: completed
date: 2026-06-10
---

# Execute API Enable Gate

## Summary

Keep the spend-capable OpenAI execute route disabled after deployment unless an
operator explicitly enables it separately from configuring the provider key.

## Work Completed

- Added `isExecuteApiEnabled` with strict, whitespace-normalized `true`
  semantics.
- Rejects disabled requests with a generic 503 response before body parsing or
  provider client construction.
- Added parser-suite coverage for missing, false, numeric-style, yes-style, and
  normalized true values.
- Documented that the gate is a deployment interlock and does not replace
  authentication or rate limiting for public exposure.
- Rooted Make targets to the repository, pinned CI to Ubuntu 24.04, and extended
  the executable source baseline.

## Verification

- `npm ci`
- `npm run test:parser`
- `npm test`
- `make check`
- `make -f /absolute/path/to/Makefile check`
- Mutation checks for permissive enablement, removed enablement tests, floating
  runner, unrooted Make targets, and incomplete plan status
- `sh -n scripts/check-baseline.sh`
- `git diff --check`

No OpenAI request was sent and no application was deployed during this pass.
