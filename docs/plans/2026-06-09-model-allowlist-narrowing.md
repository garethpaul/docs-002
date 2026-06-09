---
title: Model Allow-List Narrowing
date: 2026-06-09
status: completed
execution: code
---

## Context

The execute API documents `OPENAI_ALLOWED_MODELS` as a way to narrow the
checked-in chat model allow-list, but the route treated the environment value
as a replacement list. A deployment typo or overly broad value could therefore
expand the proxy beyond the repository default.

## Goals

- Keep `DEFAULT_ALLOWED_MODELS` as the maximum model set.
- Let `OPENAI_ALLOWED_MODELS` narrow that set only to models already present in
  the default list.
- Reject unsupported environment model names instead of forwarding them.
- Add parser/normalizer regression coverage and source guard checks.

## Verification

- `npm run test:parser`
- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
