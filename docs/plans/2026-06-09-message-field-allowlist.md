---
title: Message Field Allowlist
type: security
status: completed
date: 2026-06-09
---

# Message Field Allowlist

## Problem Frame

The execute API validated top-level chat completion parameters, but message
objects with extra fields were accepted and then normalized down to `role` and
`content`. Rejecting extra message fields makes the accepted request shape
explicit and prevents surprising silent drops.

## Scope Boundaries

- Preserve accepted `system`, `user`, and `assistant` messages.
- Preserve existing message count and content length limits.
- Do not add support for tool calls, names, multimodal content, or streaming.
- Keep the focused parser test as the executable contract.

## Implementation Units

### U1: Restrict Message Object Fields

Files:

- Modify `pages/api/execute/code.ts`

Approach:

- Add an allow-list for message object fields.
- Reject messages containing anything other than `role` and `content`.

### U2: Cover The Rejection

Files:

- Modify `scripts/test-execute-parser.ts`
- Modify `scripts/check-baseline.sh`

Approach:

- Add a parser regression with an extra `name` field.
- Require the message field allow-list and regression test in the baseline
  guard.

### U3: Document The Contract

Files:

- Modify `README.md`
- Modify `VISION.md`
- Modify `CHANGES.md`

Approach:

- Record that accepted chat messages are limited to `role` and `content`.
- Keep future expansions tied to explicit tests and docs.

## Verification

- `npm run test:parser`
- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
