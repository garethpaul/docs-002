---
title: Execute Body Field Allowlist
type: security
status: completed
date: 2026-06-09
---

# Execute Body Field Allowlist

## Problem Frame

The execute API required a `code` string, but extra request body fields were
accepted and ignored. Rejecting extra fields keeps credential-like values and
metadata out of the accepted request contract.

## Scope Boundaries

- Preserve JSON POST requests that include only a `code` string.
- Preserve the existing code size limit and AST-based OpenAI call extraction.
- Do not add new request fields or proxy configuration knobs.
- Keep the focused parser/helper test as the executable contract.

## Implementation Units

### U1: Restrict Request Body Fields

Files:

- Modify `pages/api/execute/code.ts`

Approach:

- Add a `code`-only body field allow-list.
- Reject arrays, non-objects, non-string `code` values, and extra fields before
  parsing submitted code.

### U2: Cover The Rejection

Files:

- Modify `scripts/test-execute-parser.ts`
- Modify `scripts/check-baseline.sh`

Approach:

- Add helper coverage for valid request bodies, extra fields, arrays, and
  non-string `code` values.
- Require the body field allow-list and regression in the baseline guard.

### U3: Document The Contract

Files:

- Modify `README.md`
- Modify `VISION.md`
- Modify `CHANGES.md`

Approach:

- Record that execute request bodies may only contain `code`.
- Keep future expansions tied to explicit tests and docs.

## Verification

- `npm run test:parser`
- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
