---
title: Checkout Credential And Esbuild Boundary
date: 2026-06-12
status: completed
execution: code
---

# Checkout Credential And Esbuild Boundary

## Summary

Stop GitHub Actions checkout credential persistence and restore a clean
dependency audit by selecting the patched `esbuild` release already allowed by
the pinned `tsx` dependency.

## Requirements

- Keep exactly one commit-pinned checkout step with `persist-credentials: false`.
- Preserve read-only permissions, Node 20/22/24 coverage, `npm ci`, and
  `make check`.
- Keep `package.json` unchanged and resolve `tsx` to integrity-pinned
  `esbuild@0.28.1` through `package-lock.json`.
- Reject checkout, lockfile, evidence, and guidance regressions locally.

## Verification

- Node 20 `npm test` passed, including lint, type checking, parser tests,
  production build, baseline contracts, and dependency audit.
- `npm ci` and `make check` passed from an external working directory.
- `npm audit --audit-level=moderate` reported zero vulnerabilities.
- Workflow, lockfile, and plan hostile mutations were rejected.
- `git diff --check` and shell syntax validation passed.
