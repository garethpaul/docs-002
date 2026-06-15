---
title: Nonblank Execute Message Content
type: security
status: in_progress
date: 2026-06-15
execution: code
---

# Nonblank Execute Message Content

## Problem Frame

The execute parser rejects empty message strings but accepts content made only
of whitespace. Such a request passes the provider-eligibility boundary and can
consume the shared OpenAI budget without carrying a meaningful prompt.

## Prioritized Engineering Work

1. **P0 - Input integrity:** reject whitespace-only content for every message.
2. **P1 - Provider response verification:** add sanitized integration evidence
   for successful, malformed, and failed OpenAI responses.
3. **P2 - Distributed capacity controls:** replace the process-local budget
   when the route is deployed across multiple instances.

This change implements only P0. P1 remains in `INTEGRATION_VERIFICATION.md`,
and P2 requires deployment architecture outside this repository's current
sample boundary.

## Scope Boundaries

- Reject message content whose trimmed value is empty.
- Preserve the original content string for accepted messages; do not rewrite
  meaningful leading or trailing whitespace.
- Preserve role, field, count, per-message, aggregate-length, model, parameter,
  API-key, enable-gate, rate-limit, timeout, and response behavior.
- Do not call OpenAI or claim live integration evidence.

## Requirements

- R1. Empty and whitespace-only message content must be rejected.
- R2. Nonblank content with surrounding whitespace must remain accepted and
  retain its original bytes.
- R3. Every message in a multi-message request must independently satisfy the
  nonblank-content rule.
- R4. Static contracts must reject guard, regression-test, documentation, and
  completed-plan evidence removal.

## Implementation Units

### U1: Normalize Message Eligibility

Files:

- `pages/api/execute/code.ts`
- `scripts/test-execute-parser.ts`

Approach:

- Extend the existing message-content predicate with a trimmed nonblank check.
- Add direct parser regressions for whitespace-only, mixed multi-message, and
  preserved surrounding-whitespace cases.

### U2: Preserve The Boundary Contract

Files:

- `scripts/check-baseline.sh`
- `CHANGES.md`
- `README.md`
- `SECURITY.md`
- `VISION.md`
- `docs/plans/2026-06-15-nonblank-message-content.md`

Approach:

- Require the implementation predicate, focused tests, synchronized guidance,
  and truthful completed verification evidence.

## Verification

- Focused execute parser tests.
- Full repository and external-directory `make check`.
- Hostile mutations for predicate removal, focused-test removal,
  documentation drift, and incomplete plan evidence.
- Exact diff, generated artifact, conflict marker, and credential audits.

## Risks

- Unicode whitespace follows JavaScript `String.prototype.trim()` semantics;
  accepted nonblank content is returned unchanged.
- Live OpenAI behavior and distributed rate limiting remain outside this change.

## Assumptions

- A message containing only whitespace has no supported semantic use in this
  documentation execute sample.

## Status: In Progress
