# Changes

## 2026-06-26 14:36 PDT - P1 - Make verification invocation authoritative

### Summary

Closed a false-green boundary where a later Makefile or unsafe GNU Make mode
could report a passing `check` without executing npm or checkout-workflow
verification.

### Work completed

- Converted public verification targets to guarded double-colon rules.
- Rejected startup/later Makefiles, caller invocation variables, and ten unsafe
  Make modes.
- Fixed shell, npm, and repository-root ownership in the reviewed graph.
- Added 24 causal authority cases, external-root coverage, and hostile checkout
  path coverage.

### Threads

- None; the focused Make, shell-test, baseline, and documentation work was
  completed directly.

### Files changed

- `Makefile` — authoritative invocation and guarded repository recipes.
- `scripts/test-makefile-authority.sh` — causal replacement, mode, override,
  external-root, and hostile-path regressions.
- `scripts/check-baseline.sh` — structural authority and plan contracts.
- `README.md`, `VISION.md`, `AGENTS.md`,
  `docs/plans/2026-06-26-make-invocation-authority.md` — public boundary and
  verification evidence.

### Validation

- `/bin/sh scripts/test-makefile-authority.sh` — 24 authority cases passed.
- Node 20.20.2, 22.16.0, and 24.17.0 `make check` — passed with
  lint, TypeScript, parser tests, Next production builds, source baseline,
  zero-vulnerability audits, and checkout-workflow fixtures.
- Absolute external-directory Make verification — passed on Node 20.20.2.
- Hosted verification — pending.

### Bugs / findings

- P1 fixed: a later single-colon Makefile replaced every verification leaf and
  exited zero; `make -n check` also exited zero without running the graph.

### Blockers

- The host login environment lacks Ruby; local workflow validation used the
  official Ruby 3.3 container while npm/Next ran on installed Node toolchains.

### Next action

- Open the PR and require all hosted Node and CodeQL checks on the exact head.

## 2026-06-26 - P2 - Retire the legacy default chat model

- Narrowed the execute proxy's maximum model allow-list to `gpt-4o-mini`.
- Rejected `gpt-3.5-turbo` even when `OPENAI_ALLOWED_MODELS` attempts to restore
  it; deployment configuration can still only narrow the checked-in maximum.
- Updated the visible prototype copy and security guidance to distinguish the
  preserved Chat Completions sample from OpenAI's Responses recommendation for
  new projects.
- Added a failing-first parser assertion and static contracts for the narrowed
  provider-eligibility boundary.

## 2026-06-19

- Required a configured `EXECUTE_API_TOKEN` and exact bearer credential before
  enabled execute requests can reach content parsing, rate limits, or OpenAI.
- Added an in-memory editor token field and regression guards that prevent the
  browser playground from silently bypassing or persisting the credential.
- Restored structural checkout-workflow validation and hostile YAML fixtures
  that downstream stacked branches had accidentally omitted.

## 2026-06-18

- Refreshed six compatible direct dependencies while preserving Node 20,
  TypeScript 5.9, the patched esbuild resolution, and the complete production
  verification gate.

## 2026-06-16

- Execute JSON Content-Type parameters accept only one UTF-8 charset declaration; malformed, duplicate, unsupported, and unrelated parameters are rejected before body validation.

## 2026-06-15

- Lone UTF-16 surrogates in execute message content are rejected before provider eligibility; valid surrogate pairs remain accepted unchanged.
- Lone UTF-16 surrogates in execute stop sequences are rejected; valid surrogate pairs and whitespace sequences remain accepted unchanged.
- Rejected whitespace-only execute message content before provider capacity
  consumption while preserving accepted content unchanged.
- Made explicitly empty model allowlists fail closed instead of restoring
  built-in defaults.
- Rejected whitespace-only OpenAI API keys before execute capacity consumption.

## 2026-06-14

- Added an exact-head execute integration verification matrix that separates
  portable package checks from sanitized browser, deployment, and provider
  evidence.

## 2026-06-13

- Moved execute capacity consumption after local validation and API-key checks
  so invalid requests cannot exhaust provider-eligible request slots.
- Rejected ambiguous multi-value Content-Type headers before execute request
  body normalization while preserving single JSON values with parameters.
- Added a process-local fixed-window execute budget that rejects excess
  provider-eligible attempts with `429` and `Retry-After` before provider setup.
- Added a tested `Cache-Control: no-store` policy to every execute API response
  so code, model output, and route errors are not intentionally cached.

## 2026-06-12

- Stopped checkout credential persistence and updated the transitive `esbuild`
  lockfile resolution from vulnerable 0.28.0 to patched 0.28.1.
- Bounded enabled OpenAI execute requests to 30 seconds and disabled automatic
  SDK retries so one interactive request has a predictable provider window.
- Added an immutable, executable request-options contract and baseline guard.

## 2026-06-10

- Added an explicit, default-off `DOCS_EXECUTE_ENABLED=true` deployment gate
  before the spend-capable OpenAI proxy can run.
- Rooted Make targets to the repository and pinned CI to Ubuntu 24.04.
- Added a GitHub Actions workflow that runs `npm ci` and `make check` on Node
  20, 22, and 24.
- Updated Next.js to 16.2.9, OpenAI to 6.42.0, React to 19.2.7, React types to
  19.x, and the CodeMirror lint package to 6.9.7.
- Pinned workflow actions, limited repository access to read-only, and raised
  dependency auditing from high to moderate severity.
- Extended the source baseline and docs to require the hosted CI verification
  path.

## 2026-06-09

- Required own execute request, parameter, and message fields before normalized
  values are read.
- Rejected non-finite numeric execute parameters before proxying OpenAI chat
  completion requests.
- Preserved extracted prototype keys as own fields so execute API parameter and
  message allow-lists reject them.
- Restricted execute API request bodies to the `code` field before parsing
  submitted examples.
- Restricted execute API chat message objects to `role` and `content` fields.
- Required JSON content types on execute API requests before validating or
  proxying submitted code.
- Constrained `OPENAI_ALLOWED_MODELS` so deployment configuration can only
  narrow the checked-in execute API model allow-list.

## 2026-06-08

- Added a root `make check` wrapper for the existing npm verification gate.
- Hardened the execute API proxy with AST-only extraction, literal parameter
  validation, model allow-listing, bounded message content, runtime key checks,
  and generic provider failure responses.
- Fixed the editor request path to submit the current code string directly,
  render API errors, and avoid logging submitted prompts or responses.
- Pinned the Next/Babel/OpenAI tooling baseline and added `npm test`,
  `npm run check`, and `npm run audit` verification gates.
- Added a zero-warning ESLint gate for TypeScript and TSX source and included
  it in `npm test`.
