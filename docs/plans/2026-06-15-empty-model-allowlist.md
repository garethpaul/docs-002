# Explicit Empty Model Allowlist

Status: In Progress

## Problem

`OPENAI_ALLOWED_MODELS` is documented as an optional narrowing control, with
the built-in allowlist used when the variable is unset. The current parser also
uses the built-in models when the variable is explicitly set to whitespace or
comma-only content, so a malformed deployment value silently reopens models
instead of failing closed.

## Requirements

1. Use the built-in allowlist only when `OPENAI_ALLOWED_MODELS` is absent.
2. Treat explicitly blank, whitespace-only, or comma-only configuration as an
   empty allowlist.
3. Continue intersecting configured names with the built-in allowlist.
4. Add mutation-sensitive parser, source, documentation, and completed-plan
   contracts.
5. Preserve request parsing, provider setup, rate limiting, and response
   behavior outside model eligibility.

## Scope Boundaries

- Do not add models or change the built-in model set.
- Do not normalize model names beyond existing comma splitting and trimming.
- Do not change deployment authentication, provider credentials, dependencies,
  request budgets, or user-visible errors.
- Do not merge or close stacked pull requests without explicit authorization.

## Implementation

1. Distinguish an undefined environment variable from a configured string in
   `allowedModels()`.
2. Return the built-in set only for the undefined case; otherwise return the
   configured intersection, including an empty set.
3. Add parser regressions for whitespace-only and comma-only configuration.
4. Extend the static baseline and repository guidance contracts.
5. Run focused tests, hostile mutations, Node 20 and Node 24 `make check`, an
   external-directory gate, and final artifact/secret/diff audits.

## Priority Follow-Ups

1. P0: fail closed for explicitly empty model configuration.
2. P1: execute the configured route against a synthetic deployment.
3. P2: revisit the maintained provider/model matrix before model expansion.

## Verification

- Pending implementation and bounded validation.
