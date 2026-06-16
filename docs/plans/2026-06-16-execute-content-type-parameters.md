# Validate Execute Content-Type Parameters

## Status: Planned

## Problem

The execute endpoint currently checks only the text before the first semicolon
in `Content-Type`. Requests such as `application/json; charset=latin1`, a
duplicate charset declaration, a missing parameter value, or an unrelated
parameter are therefore treated as JSON before request-body and provider
eligibility checks.

RFC 9110 defines media-type parameters as semicolon-delimited name/value pairs
with token or quoted-string values. RFC 8259 requires networked JSON to use
UTF-8 and defines no registered `application/json` parameters. The endpoint
should retain the common interoperable UTF-8 charset spelling while rejecting
ambiguous or contradictory declarations.

Primary references:

- https://www.rfc-editor.org/rfc/rfc9110.html#section-8.3.1
- https://www.rfc-editor.org/rfc/rfc8259.html#section-8.1
- https://www.rfc-editor.org/rfc/rfc8259.html#section-11

## Priorities

1. P0: Reject malformed or contradictory JSON media-type parameters before
   request-body parsing and provider eligibility.
2. P1: Preserve bare `application/json` and one case-insensitive UTF-8 charset
   value in token or quoted-string form.
3. P1: Add mutation-sensitive parser, route-ordering, guidance, and completion
   contracts without changing provider request semantics.

## Scope

- Parse the complete request `Content-Type` value with HTTP whitespace,
  parameter-name, token-value, and quoted-value validation.
- Accept no parameters or exactly one `charset=utf-8` parameter.
- Reject duplicate charset parameters, unsupported charsets, unrelated
  parameters, empty values, unterminated quotes, trailing delimiters, escaped
  control characters, and array-valued headers.
- Keep the existing `415` response and stable public error body.
- Preserve execute enablement, body-size, body-shape, code parsing, model and
  message validation, rate limiting, OpenAI request options, and response
  behavior.

## Implementation Units

### U1: Parse the complete JSON media type

**File:** `pages/api/execute/code.ts`

Replace the prefix-only check with a small dependency-free parser for the
single supported media type and optional UTF-8 charset declaration. Keep the
function side-effect free and retain rejection of non-string header values.

### U2: Add request-boundary regressions

**File:** `scripts/test-execute-parser.ts`

Cover accepted bare, case-insensitive, whitespace, token, and quoted UTF-8
forms. Cover malformed syntax, duplicate or unsupported charset, unrelated
parameters, quoted control characters, arrays, and route rejection before
capacity is consumed.

### U3: Protect and document the contract

**Files:** `scripts/check-baseline.sh`, `README.md`, `SECURITY.md`, `VISION.md`,
`CHANGES.md`, and this plan.

Register the plan, source parser, sensitive tests, route ordering, maintained
guidance, and completed verification evidence in the dependency-free checker.

## Validation

- Run shell syntax, focused parser tests, TypeScript, ESLint, Prettier, the
  production build, npm audit, and repository/external `make check`.
- Reject isolated mutations that restore prefix-only acceptance, weaken
  duplicate/charset/syntax checks, remove the route-ordering assertion,
  remove guidance, or reopen plan status.
- Audit the exact diff, generated artifacts, untracked files, credentials,
  conflict markers, binaries, file modes, and whitespace before committing.

## Risks

- Clients sending nonstandard `application/json` parameters will receive the
  existing `415` response instead of reaching body parsing.
- This validates the declared media type; Next.js remains responsible for
  decoding the request body before the route executes.
- No live OpenAI request, deployed route, proxy normalization, or malformed raw
  HTTP transport is exercised.
- This change is stacked on PR #16, which must remain open and merge first.
