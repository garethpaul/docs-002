---
title: docs-002 Check Wrapper
date: 2026-06-08
status: completed
execution: code
---

## Context

The project already exposes `npm test` as the complete local verification gate,
but repository automation expects a root `make check` entry point.

## Goals

- Add a root Makefile with `lint`, `test`, `build`, `audit`, `verify`, and
  `check` targets.
- Make `make check` run the same complete gate as `npm test`.
- Document the wrapper in README and CHANGES.
- Preserve the wrapper through the source baseline guard.

## Verification

- `make check`
- `npm test`
- `git diff --check`
