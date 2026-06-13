---
title: Execute Fixed Window Budget
type: security
date: 2026-06-13
status: completed
---

# Execute Fixed Window Budget

## Summary

Bound enabled execute-route traffic with a deterministic process-local fixed
window before request parsing or provider client construction, returning a
stable `429` response and `Retry-After` guidance when capacity is exhausted.

## Problem Frame

The execute API is disabled by default and constrains each individual OpenAI
request, but an enabled deployment accepts an unbounded number of POST attempts.
That leaves provider spend and application work exposed to bursts even though
each call has bounded input, timeout, retries, and response caching behavior.

## Prioritized Engineering Tasks

1. Add a process-local request budget that protects every enabled POST attempt
   before content parsing and provider setup.
2. Prove exact-window capacity, rejection, retry timing, and rollover behavior
   with deterministic no-network tests.
3. Enforce the implementation, tests, documentation, and completed evidence in
   the repository baseline.
4. Preserve upstream authentication and distributed rate limiting as the next
   deployment-level priority rather than claiming a process-local guard solves
   multi-instance enforcement.

## Requirements

- R1. An enabled process may accept at most ten execute POST attempts per
  60-second window.
- R2. The eleventh attempt in a window must return `429`, set a positive integer
  `Retry-After` header, and stop before parsing code or constructing OpenAI.
- R3. Capacity must reset after the full window elapses and recover safely when
  the observed clock moves backward.
- R4. Invalid limiter construction inputs must fail immediately instead of
  silently disabling the boundary.
- R5. Existing method, enable-gate, content-type, body, parser, provider,
  timeout, retry, and no-store behavior must remain unchanged.
- R6. Pure no-network tests must cover ten accepted attempts, the rejected
  eleventh attempt, bounded retry timing, window rollover, backward time, and
  invalid configuration.
- R7. `make check` must enforce source structure, regression names,
  documentation, and truthful completed-plan evidence.

## Key Technical Decisions

- **Process-global fixed window:** Use one module-scoped limiter so concurrent
  requests handled by the same application process share a strict budget.
- **Limit all enabled POST attempts:** Consume capacity before content-type and
  body validation so malformed traffic cannot bypass the application-work
  boundary.
- **Pure factory for verification:** Export a closure factory accepting explicit
  timestamps; the route uses `Date.now`, while tests stay deterministic.
- **Honest deployment boundary:** Document that serverless or horizontally
  scaled deployments still require an upstream shared limiter.

## Implementation Units

### U1. Add Fixed Window Limiter

- **Files:** `pages/api/execute/code.ts`
- **Goal:** Add validated limiter construction, bounded retry calculation,
  process-global capacity, and early `429` handling.
- **Covers:** R1, R2, R3, R4, R5

### U2. Add Deterministic Budget Regressions

- **Files:** `scripts/test-execute-parser.ts`
- **Goal:** Exercise capacity, rejection, rollover, backward-clock recovery,
  and invalid configuration without network or provider calls.
- **Covers:** R1, R2, R3, R4, R6

### U3. Enforce And Document The Boundary

- **Files:** `scripts/check-baseline.sh`, `README.md`, `SECURITY.md`, `VISION.md`,
  `CHANGES.md`
- **Goal:** Keep the fixed-window source, regressions, limitations, and completed
  verification evidence part of every full repository gate.
- **Covers:** R7

## Verification

- Node.js 20.19.5, 22.22.2, and 24.16.0 passed parser tests, zero-warning lint,
  TypeScript typechecking, the Next.js production build, and the
  moderate-severity dependency audit with zero vulnerabilities.
- `make check` passed on Node.js 20.19.5, 22.22.2, and 24.16.0, and the rooted
  external-working-directory wrapper passed from `/tmp` on Node.js 20.19.5.
- Ten hostile mutations were rejected for changed capacity or window, removed
  route enforcement or `Retry-After`, changed status, removed rollover,
  backward-clock, or route regressions, documentation drift, and incomplete
  plan status.
- Shell syntax, `git diff --check`, exact-path inspection, unchanged lockfile,
  secret-pattern inspection, and generated-artifact inspection passed.
- `agent-browser` was not installed, so the pipeline browser skill could not
  run. The change is API-only and has deterministic route-level coverage.
- Verification did not enable the deployed route or use an OpenAI key. It made
  no live OpenAI request and does not claim distributed multi-instance rate
  limiting.

## Risks

- Separate serverless instances maintain separate counters; a shared edge or
  datastore-backed limiter remains necessary for a public scaled deployment.
- A process restart resets capacity, which is acceptable for this local safety
  layer but not a billing-grade quota.
- The global budget intentionally lets malformed enabled POST attempts consume
  capacity so validation work cannot be spammed for free.
