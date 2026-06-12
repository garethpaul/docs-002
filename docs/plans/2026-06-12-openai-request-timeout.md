---
title: OpenAI Request Timeout
type: reliability
status: completed
date: 2026-06-12
---

# OpenAI Request Timeout

## Summary

Bound each enabled execute API call to 30 seconds and disable SDK retries so a
single interactive request cannot occupy the server route through the OpenAI
Node SDK's much longer defaults.

## Problem Frame

The execute handler catches provider errors but currently relies on SDK network
defaults. The official OpenAI Node SDK documents a 10-minute default timeout
and two automatic retries for timeouts, connection failures, rate limits, and
server errors. Those defaults are too broad for an interactive documentation
endpoint and can outlive the hosting platform's useful request window.

## Requirements

- R1. Every OpenAI chat completion request from the execute handler must use a
  30-second timeout.
- R2. Automatic SDK retries must be disabled for this route so the timeout is a
  meaningful upper bound on one provider attempt.
- R3. The timeout and retry options must be exported as an immutable contract
  that parser tests can verify without a live API key or network request.
- R4. Existing generic `502` provider-error handling must remain unchanged and
  must not expose SDK exception details.
- R5. The static baseline, README, SECURITY, VISION, and CHANGES must preserve
  the bounded provider-call contract.

## Non-Goals

- Changing request models, prompts, parsing, or response payloads.
- Adding route-level retries, queues, streaming, or cancellation UI.
- Performing a live OpenAI API request.
- Making timeout duration user-configurable.

## Work Completed

- Added immutable per-request OpenAI SDK options with a 30-second timeout and
  zero retries.
- Passed the bounded options to every execute-route chat completion call.
- Added offline executable assertions for values and immutability.
- Extended the static baseline and project documentation with the provider-call
  work boundary.

## Verification

- Node 20.19.5, 22.22.2, and 24.16.0: clean `npm ci` followed by
  `make check` passed the full `npm test` gate: ESLint, TypeScript, parser
  tests, the Next.js production build, static baseline checks, and `npm audit`
  with zero vulnerabilities.
- Five isolated hostile mutations were rejected by the baseline: changing the
  timeout, restoring retries, removing `Object.freeze`, removing the parser
  value assertion, and changing this plan from completed to planned.
- `git diff --check` passed.

## Reference

- [OpenAI Node SDK retries and timeouts](https://github.com/openai/openai-node#retries)
