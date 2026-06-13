# Consume Execute Capacity Only for Provider-Eligible Requests

Status: In Progress

## Context

The execute route currently consumes its process-local fixed-window capacity
immediately after the method and enablement checks. Unsupported content types,
malformed bodies, oversized code, invalid parsed parameters, and missing API
configuration can therefore exhaust all provider request slots without any
request becoming eligible to call OpenAI.

## Requirements

- R1. Preserve the existing ten-request, sixty-second fixed-window behavior,
  `429` response, and `Retry-After` header for provider-eligible requests.
- R2. Reject invalid Content-Type, body, size, parameter, and missing-key cases
  before consuming execute capacity.
- R3. Keep capacity enforcement immediately before provider client creation so
  no OpenAI request can bypass it.
- R4. Preserve the disabled-route, no-store, generic-error, timeout, retry, and
  model/parameter allow-list boundaries.
- R5. Add runtime and helper-scoped static contracts that reject moving the
  budget ahead of local validation or behind provider construction.

## Scope Boundaries

- Do not change the budget size, window duration, global process-local scope,
  or public deployment warning.
- Do not add authentication, shared storage, a new dependency, or a live
  provider request.
- Do not change parser acceptance or response payloads.

## Implementation

- Move `enforceExecuteRateLimit` after all local validation and API-key checks.
- Add an offline handler regression that exhausts the budget and proves an
  invalid Content-Type still returns `415` instead of `429`.
- Extend the baseline checker and project guidance with ordered source,
  regression, documentation, and completed-plan contracts.

## Verification

- Run `make check` on Node.js 20, 22, and 24.
- Run the rooted check from an external working directory.
- Run isolated hostile mutations for ordering, bypass, regression, docs, and
  completed-plan evidence.
- Audit manifests, lockfiles, workflow, generated artifacts, whitespace, shell
  syntax, and credential-like additions.

## Risks

- The limiter remains process-local and unauthenticated, so public multi-instance
  deployments still require shared identity-aware rate limiting.
- Requests that pass local validation but fail at the provider still consume a
  slot, which intentionally bounds spend-capable attempts.
