# Execute API Bearer Authentication

## Status: Completed

## Problem

The default-off execute route could still proxy caller-controlled requests with
the deployment's OpenAI key whenever an operator enabled it. The stale auth PR
added a bearer check on an old base, but the browser editor did not send the
credential, so merging it would have broken the documented playground.

## Decision

Require a nonblank server-side `EXECUTE_API_TOKEN` and an exact caller-supplied
bearer credential before content-type parsing, body validation, rate-budget
consumption, or OpenAI client construction. Compare fixed-size SHA-256 digests
with `timingSafeEqual`. Keep the editor token only in React component memory,
submit it in the Authorization header, and never persist it.

A shared token is a deployment access gate, not identity-aware authorization.
Scaled public deployments still need shared rate limiting and may require a
real user/session authorization layer.

## Verification

- Focused parser and handler tests cover missing and blank configuration,
  missing/malformed/wrong credentials, duplicate header values, case-insensitive
  bearer scheme handling, and authorized progression to body validation.
- Static baseline checks enforce authentication before content-type, body, and
  capacity boundaries and require the editor's non-persistent password field.
- `npm run test:parser`, `npm run lint`, and `npm run type-check` passed locally.
- Full `make check`, clean-install matrix, hosted checks, and mutation validation
  are recorded in the landing PR before merge.
