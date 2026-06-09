---
title: JSON Content-Type Guard
date: 2026-06-09
status: completed
execution: code
---

## Context

The execute API already required POST requests and validated the parsed body
shape, but it did not explicitly require JSON request content types before
processing submitted code.

## Goals

- Reject non-JSON execute API requests with a clear client error.
- Accept standard JSON content types with optional parameters such as
  `charset=utf-8`.
- Cover the content-type helper with deterministic tests.
- Preserve the guard through the source baseline script and README notes.

## Verification

- `npm run test:parser`
- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
