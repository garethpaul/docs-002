---
title: Make Repository Root Override Protection
type: reliability
status: active
date: 2026-06-14
---

# Make Repository Root Override Protection

## Status: Active

## Problem Frame

The Makefile derives the checkout path in `ROOT`, but a command-line assignment
overrides that value. `make ROOT=/tmp check` consequently directs NPM to an
untracked `/tmp/package.json` instead of running the repository's pinned gate.

## Scope Boundaries

- Preserve `lint`, `test`, `build`, `audit`, `verify`, and `check` behavior.
- Preserve `NPM` as an intentional caller-selected executable override.
- Do not change API, parser, rate-budget, dependency, or deployment behavior.
- Keep every Make command independent of the caller's working directory.

## Requirements

- R1. Derive the repository root from the loaded Makefile itself.
- R2. Command-line and environment assignments must not redirect that root.
- R3. The deterministic checker must enforce the protected assignment form.
- R4. The pinned package gate must pass from repository and external paths.
- R5. Isolated mutations that restore caller control must fail verification.

## Implementation

1. Protect the Makefile repository-root assignment from caller overrides.
2. Register an exact assignment and completed-plan contract in the checker.
3. Run focused, full, external-directory, hostile-override, and mutation gates.

## Verification

- `sh -n scripts/check-baseline.sh`
- `make check`
- `npm test`
- External-working-directory `make -C <repository> check`
- Hostile command-line and environment `ROOT` assignments
- `npm audit --audit-level=moderate`
- `git diff --check`
- Isolated hostile assignment mutations
