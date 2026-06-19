# Refresh Compatible JavaScript Dependencies

## Status: Completed

## Problem

The exact PR #17 lockfile is audit-clean and production-green, but a bounded
registry comparison reports six newer releases within the repository's current
major-version boundaries. Leaving exact pins behind compatible upstream fixes
creates avoidable maintenance drift and makes later upgrades harder to review.

The available major upgrades for `@types/node` and TypeScript are separate
runtime and compiler compatibility decisions. They are intentionally excluded
from this narrow refresh.

## Priorities

1. P0: Preserve the zero-vulnerability, reproducible lockfile graph and the
   complete execute parser/build gate.
2. P1: Refresh the six compatible direct dependencies reported by the bounded
   registry check.
3. P1: Add a static contract that pins the reviewed versions and records the
   excluded major-version boundaries.

## Scope

- Update `@codemirror/search` from 6.7.0 to 6.7.1.
- Update `@radix-ui/react-menubar` from 1.1.17 to 1.1.18.
- Update `@radix-ui/react-navigation-menu` from 1.2.15 to 1.2.16.
- Update ESLint from 10.4.1 to 10.5.0.
- Update OpenAI from 6.42.0 to 6.44.0.
- Update `typescript-eslint` from 8.61.0 to 8.61.1.
- Regenerate only `package-lock.json` through npm's structured package
  resolver.
- Preserve Node 20 compatibility, TypeScript 5.9, all execute API behavior,
  workflow pins, and the existing stacked pull requests.

## Implementation Units

### U1: Refresh exact package pins

**Files:** `package.json`, `package-lock.json`

Install the six reviewed versions exactly and verify that transitive resolution
does not reintroduce the default-branch esbuild advisory.

### U2: Protect the dependency boundary

**Files:** `scripts/check-baseline.sh`, `CHANGES.md`, this plan

Add mutation-sensitive static checks for all six exact pins, the patched esbuild
resolution, maintained change history, and truthful completed verification
evidence.

## Validation

- Run shell syntax, parser tests, TypeScript, zero-warning ESLint, the Next.js
  production build, npm audit, and repository/external `make check`.
- Run the full gate on available Node 20, 22, and 24 runtimes.
- Reject isolated mutations to each direct package pin, one reviewed direct
  lockfile resolution, the esbuild lockfile resolution, plan status, and
  verification evidence.
- Audit the exact diff, generated artifacts, untracked files, credentials,
  conflict markers, binaries, file modes, and whitespace before committing.

## Risks

- Compatible releases can still contain behavioral changes; lint, type-check,
  parser, build, and audit gates must all pass on the reviewed graph.
- The OpenAI SDK is exercised through compile-time and route-level tests only;
  no live provider request is made.
- TypeScript 6 and `@types/node` 25 remain intentionally deferred because they
  cross compiler or supported-runtime boundaries.
- This change is stacked on PR #17, which must remain open and merge first.

## Work Completed

- Updated `@codemirror/search` to 6.7.1, both reviewed Radix components to their
  compatible releases, OpenAI to 6.44.0, ESLint to 10.5.0, and
  `typescript-eslint` to 8.61.1.
- Regenerated the npm lockfile through the structured resolver and retained the
  patched esbuild 0.28.1 resolution with an integrity digest.
- Added structured manifest/lockfile contracts for all six reviewed versions,
  synchronized the change history, and kept the existing audit gate.
- TypeScript 6 and @types/node 25 remain intentionally deferred because they
  cross compiler and supported-runtime boundaries.

## Verification Completed

- Node.js 20.19.5, 22.22.2, and 24.16.0 each passed zero-warning ESLint,
  TypeScript type-checking, execute parser tests, and the Next.js 16.2.9
  production build.
- Fresh lockfile installs and `npm audit --audit-level=moderate` reported zero
  vulnerabilities on all three available Node runtimes.
- Repository and external-directory `make check` passed the complete package
  gate with explicit timeouts.
- Ten isolated dependency-contract mutations were rejected: each of the six
  direct package pins, a reviewed direct lockfile resolution, the esbuild
  lockfile resolution, plan status, and verification evidence.
- Exact diff, generated-artifact, untracked-file, credential-shaped addition,
  conflict-marker, binary, file-mode, and whitespace audits passed before
  commit.
- No live OpenAI request, deployed route, proxy, or browser execution was
  performed.
