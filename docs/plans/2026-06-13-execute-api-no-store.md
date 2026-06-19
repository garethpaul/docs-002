---
title: Execute API No-Store Policy
type: security
status: completed
date: 2026-06-13
---

# Execute API No-Store Policy

## Summary

Set an explicit `Cache-Control: no-store` policy on every execute API response
so submitted code, provider output, and route errors are not intentionally
retained by browser or shared caches.

## Requirements

- R1. The cache policy must be applied before every execute handler branch.
- R2. The policy must cover successful, validation, disabled, method, and
  provider-error responses without changing their status codes or payloads.
- R3. The policy value must be an exported contract covered by an executable
  offline assertion and the static baseline.
- R4. Project security and maintenance guidance must record the boundary.

## Non-Goals

- Adding authentication, rate limiting, or provider request changes.
- Changing accepted request or response payloads.
- Relying on live OpenAI requests for verification.

## Work Completed

- Added the route-level response header before every handler branch.
- Added an exported policy constant with an offline executable assertion.
- Extended the static baseline and project documentation.

## Verification

- Node 20.19.5: `npm run test:parser`, `npm run type-check`, and `npm run lint`
  passed.
- Node 20.19.5: `npm test` passed, including the production build, static
  baseline, and zero-vulnerability moderate audit.
- Mutation: removing the response header failed `npm run check`.
- Mutation: changing the policy to `no-cache` failed `npm run test:parser`.
- `make check` passed after the completed plan and plan contract were added.
- `git diff --check` passed.
