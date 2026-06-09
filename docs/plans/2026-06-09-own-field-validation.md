# Own Field Validation

Status: Completed
Date: 2026-06-09

## Goal

Keep execute API normalization from reading inherited request, parameter, or
message values when helpers are exercised directly or future parsing paths
change.

## Changes

- Added an own-field helper for normalized JSON-like values.
- Required own `code`, `model`, `messages`, `role`, and `content` fields before
  reading those values.
- Switched optional parameter handling to read only own fields.
- Added parser tests for inherited execute body, parameter, and message fields.
- Extended the source baseline, README, changelog, and vision with the own-field
  validation contract.

## Verification

- `npm run test:parser`
- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
