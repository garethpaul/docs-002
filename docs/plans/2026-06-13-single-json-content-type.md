---
title: Single JSON Content Type
type: security
date: 2026-06-13
status: completed
---

# Single JSON Content Type

## Problem Frame

The execute route accepts `Content-Type` arrays when any element is
`application/json`. Conflicting duplicate values such as `text/plain` plus
`application/json` therefore pass the route boundary even though downstream
components can interpret ambiguous headers differently.

## Requirements

- R1. A single case-insensitive `application/json` value may include parameters
  and must remain accepted.
- R2. Missing, non-string, non-JSON, and every multi-value content type must be
  rejected before request-body normalization.
- R3. Method, enablement, rate budget, body, parser, provider, timeout, retry,
  and no-store behavior must remain unchanged.
- R4. Deterministic tests and static contracts must reject restoration of
  any-match array handling or removal of ambiguous-header regressions.

## Scope Boundaries

- Do not change route authentication, rate-limit placement, provider settings,
  dependencies, lockfiles, or hosted workflow configuration.
- Do not enable the execute route or make a live provider request.
- Do not broaden accepted JSON media types beyond `application/json`.

## Implementation

- Make `hasJsonContentType` reject arrays before normalizing a single string.
- Cover JSON parameters, conflicting arrays, duplicate JSON arrays, empty
  arrays, non-JSON strings, and missing values in the offline parser suite.
- Extend the baseline and project guidance with a mutation-sensitive
  single-value content-type contract.

## Verification

- Run `make check` on Node.js 20, 22, and 24.
- Run the rooted Make gate from an external working directory.
- Run isolated hostile mutations for array handling, accepted media types,
  regression coverage, docs, and completed plan evidence.
- Inspect the exact diff, lockfile/manifests, generated artifacts, and
  credential-like additions before committing.

## Work Completed

- Rejected every non-string content-type value before media-type
  normalization, including conflicting, duplicate, and empty header arrays.
- Preserved case-insensitive single `application/json` values with optional
  parameters.
- Added offline regressions and source contracts for conflicting arrays,
  duplicate JSON arrays, and empty arrays.
- Documented the single-value request interpretation boundary.

## Verification Completed

- Node.js 20.19.5, 22.22.2, and 24.16.0 `make check` passed lint, typecheck,
  offline parser tests, the Next.js production build, baseline contracts, and
  the moderate-severity audit with zero vulnerabilities.
- The rooted Make gate passed from an external working directory on Node.js
  20.19.5.
- Eight isolated hostile mutations were rejected across array handling,
  accepted media types, regression coverage, documentation, and completed
  plan evidence.
- Shell syntax, `git diff --check`, exact-path inspection, unchanged manifest
  and lockfile checks, generated-artifact inspection, and credential-like
  addition inspection passed.
- The execute route remained disabled; no OpenAI key was used and no live OpenAI request was made.
