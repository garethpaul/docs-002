---
title: Execute Integration Verification Matrix
type: reliability
status: completed
date: 2026-06-14
---

# Execute Integration Verification Matrix

## Status: Completed

## Problem Frame

Portable checks cover execute-route parsing, validation, bounded provider
calls, response caching, and process-local request budgeting. The repository
does not define repeatable exact-head evidence for the editor-to-route flow,
deployment configuration, browser behavior, or provider responses.

## Scope Boundaries

- Do not change route, editor, parser, dependency, authentication, rate-limit,
  configuration, or deployment behavior.
- Do not add API keys, authorization values, submitted code, provider output,
  cookies, account identifiers, screenshots, or logs.
- Do not claim browser, deployed route, or live OpenAI execution from portable
  parser, build, static, or package checks.
- Do not merge or close stacked pull requests without explicit authorization.

## Requirements

- R1. Add an exact-commit matrix for deployment interlock, editor submission,
  route validation, no-store responses, request budgeting, provider success,
  provider failure, timeout handling, and browser refresh behavior.
- R2. Require isolated synthetic requests and sanitized evidence fields with
  explicit `pass`, `fail`, `blocked`, or `not run` status.
- R3. Keep portable package checks, local route tests, browser evidence,
  deployment evidence, and live provider evidence separate.
- R4. Add mutation-sensitive contracts for the matrix, project guidance, and
  completed plan evidence.

## Implementation

1. Add the integration verification matrix with all scenarios marked `not run`.
2. Link the matrix from project guidance and record the evidence boundary.
3. Extend the deterministic checker with scenario, status, and plan contracts.
4. Run focused, full, external-directory, audit, and hostile mutation gates.

## Verification

- `sh -n scripts/check-baseline.sh`
- `npm run check`
- `make check` from repository and external working directories
- Node.js 20 and 24 pinned package gates
- `npm audit --audit-level=moderate`
- Isolated hostile documentation mutations
- Exact diff, generated-artifact, and secret-pattern audits

## Work Completed

- Added a 14-scenario exact-head integration matrix covering deployment
  setup, route controls, editor submissions, provider outcomes, response
  caching, request budgeting, browser refresh behavior, and public edge
  controls.
- Required isolated synthetic deployments and requests, sanitized evidence,
  exact commit and pull-request attribution, and explicit `pass`, `fail`,
  `blocked`, or `not run` statuses.
- Kept portable package checks separate from local route, browser, deployment,
  and live provider evidence.
- Added mutation-sensitive static contracts without changing route, editor,
  parser, dependency, configuration, or deployment behavior.

## Verification Completed

- `sh -n scripts/check-baseline.sh` and the focused static gate passed.
- `make check` passed from the repository and an external working directory.
- The pinned package gate passed with Node.js 20.19.5 and Node.js 24.16.0,
  including lint, type-check, parser tests, production build, static checks,
  and dependency audit with zero vulnerabilities.
- Twelve isolated hostile documentation mutations were rejected.
- No browser, deployed execute route, deployment edge, or live OpenAI provider
  scenario was executed; all 14 integration scenarios remain truthfully
  marked `not run`.
