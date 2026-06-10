# CI Baseline

status: completed

## Context

The repository had a local npm-backed `make check` verification gate, but no
hosted workflow installed dependencies and ran it for pushes and pull requests.

## Objectives

- Verify the application and execute API across active Node release lines.
- Refresh current framework, OpenAI client, React, and editor dependencies.
- Pin third-party action code and keep repository access read-only.

## Changes

- Added a GitHub Actions workflow that runs `npm ci` and `make check` on Node
  20, 22, and 24 for pushes, pull requests, and manual dispatches.
- Updated Next.js, OpenAI, React, React types, and CodeMirror lint to current
  compatible releases.
- Pinned checkout and Node setup actions to reviewed commits, limited
  repository access to read-only, and bounded execution with timeout and
  concurrency cancellation.
- Extended the source baseline and docs so the hosted CI path stays covered.

## Verification

- `make check`
- Node 20, 22, and 24 hosted jobs
- `npm outdated --json`
- `git diff --check`
