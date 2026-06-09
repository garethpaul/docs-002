# Prototype Key Rejection

Status: Completed
Date: 2026-06-09

## Goal

Keep submitted `__proto__` keys from bypassing execute API parameter and message
field allow-lists during AST literal extraction.

## Changes

- Built extracted object literals with `Object.create(null)` so prototype keys
  remain enumerable own fields.
- Added parser regression coverage for `__proto__` keys on the chat completion
  parameter object and nested chat messages.
- Extended the source baseline to require null-prototype extraction, parser
  coverage, and documentation.
- Documented the prototype key rejection guard in README, CHANGES, VISION, and
  this completed plan.

## Verification

- `sh -n scripts/check-baseline.sh`
- `scripts/check-baseline.sh`
- `npm run lint`
- `npm run type-check`
- `npm run test:parser`
- `npm run build`
- `npm run audit`
- `npm test`
- `make lint`
- `make test`
- `make build`
- `make audit`
- `make check`
- `git diff --check`
