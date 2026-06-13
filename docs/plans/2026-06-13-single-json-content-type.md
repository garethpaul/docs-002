---
title: Single JSON Content Type
type: security
date: 2026-06-13
status: planned
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
