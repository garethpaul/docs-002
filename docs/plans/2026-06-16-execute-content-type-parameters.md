# Validate Execute Content-Type Parameters

## Status: Completed

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
   route-level body normalization and provider eligibility.
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

- Run shell syntax, focused parser tests, TypeScript, ESLint, the production
  build, npm audit, and repository/external `make check`.
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

## Work Completed

- Replaced prefix-only media-type matching with dependency-free HTTP token and
  quoted-string parsing for the execute request boundary.
- Preserved bare JSON and one UTF-8 charset declaration while rejecting
  malformed, duplicate, unsupported, and unrelated parameters.
- Added direct parser cases, a saturated-capacity route-ordering regression,
  static contracts, and synchronized maintenance guidance.

## Verification Completed

- The focused regression first reproduced the defect as a `400` body error for
  an unsupported charset, then all focused parser tests passed with the route
  returning the existing `415` response before body validation.
- ESLint and TypeScript passed, and the Next.js 16.2.9 production build
  completed successfully.
- `npm audit --audit-level=moderate` reported zero vulnerabilities in the
  exact installed lockfile graph.
- Repository and external-directory `make check` passed the complete package
  gate with explicit timeouts.
- Eight isolated Content-Type mutations were rejected: restoring prefix-only
  matching, weakening duplicate, charset, or parameter-name enforcement,
  removing quoted UTF-8 support, changing the route-ordering regression,
  deleting maintained guidance, and reopening plan status.
- Exact diff, generated-artifact, untracked-file, credential-shaped addition,
  conflict-marker, binary, file-mode, and whitespace audits passed.
- The implementation was committed as
  `b8de6991a8ee03d0fc3d57ed67eb8e910cb4b8c9`.
- Canonical hosted verification passed on that exact implementation head:
  push run `27624231788` and pull-request run `27624249230` each completed
  successfully across Node.js 20, 22, and 24. Both Vercel checks also passed,
  PR #17 remained open, clean, and mergeable, and the branch had no open
  code-scanning alerts.
