# docs-002

<!-- README-OVERVIEW-IMAGE -->
![Project overview](docs/readme-overview.svg)

## Overview

`garethpaul/docs-002` is a JavaScript web application or frontend sample. The checked-in files describe a JavaScript web application or frontend sample with the structure summarized below.

This README is based on the checked-in source, manifests, scripts, and repository metadata on the `main` branch. The project language mix found during review was: React TSX (4), TypeScript (1).

## Repository Contents

- `README.md` - project overview and local usage notes
- `package.json` - JavaScript dependency and script metadata
- `components` - source or example code
- `package-lock.json` - JavaScript dependency and script metadata
- `pages` - source or example code
- `SECURITY.md` - security reporting and disclosure guidance
- `Makefile` - repository-level verification wrapper
- `VISION.md` - project direction and maintenance guardrails

Additional scan context:

- Source directories: components, pages
- Dependency and build manifests: package-lock.json, package.json
- Entry points or build surfaces: package.json, Makefile
- Test-looking files: no obvious test files detected

## Getting Started

### Prerequisites

- Git
- Node.js 20.19 or newer and npm

### Setup

```bash
git clone https://github.com/garethpaul/docs-002.git
cd docs-002
npm ci
export OPENAI_API_KEY=sk-...
# Explicitly enable the spend-capable execute route for local testing.
export DOCS_EXECUTE_ENABLED=true
# Require callers to provide this generated secret in the editor or as a
# bearer credential. Do not commit it.
export EXECUTE_API_TOKEN=replace-with-a-generated-secret
# Optional: narrow the proxied chat model allow-list.
export OPENAI_ALLOWED_MODELS=gpt-4o-mini
```

The setup commands above are derived from repository files. Legacy mobile, Python, or JavaScript samples may require older SDKs or package versions than a modern workstation uses by default.

## Running or Using the Project

- Run `npm start` for the default development command.
- Run `npm run dev` for the development server.

Detected npm scripts:

- `npm run audit` - `npm audit --audit-level=moderate`
- `npm run build` - `node node_modules/next/dist/bin/next build`
- `npm run check` - `scripts/check-baseline.sh`
- `npm run dev` - `node node_modules/next/dist/bin/next dev`
- `npm run lint` - `eslint components pages scripts --ext ts,tsx --max-warnings=0`
- `npm run start` - `node node_modules/next/dist/bin/next start`
- `npm run test` - `npm run lint && npm run type-check && npm run test:parser && npm run build && npm run check && npm run audit`
- `npm run test:parser` - `node node_modules/tsx/dist/cli.mjs scripts/test-execute-parser.ts`
- `npm run type-check` - `node node_modules/typescript/bin/tsc --noEmit`

## Testing and Verification

Run the local verification gate before changing the editor or execute API:

```bash
make check
sh scripts/test-makefile-authority.sh
npm test
```

`make check` delegates to `npm test`, which runs the zero-warning
TypeScript/TSX lint gate, TypeScript checks, focused execute parser/validator
regression tests, the Next build, the source baseline guard, and
`npm audit --audit-level=moderate`. The execute API remains disabled unless
`DOCS_EXECUTE_ENABLED=true` and requires both `OPENAI_API_KEY` and a nonblank
`EXECUTE_API_TOKEN` at runtime. Callers enter the token for the current editor
session or send it as `Authorization: Bearer <token>`. The route accepts
`Content-Type: application/json` requests only, rejects multi-value Content-Type
headers, and validates submitted examples before calling the OpenAI SDK.
Execute JSON Content-Type parameters accept only one UTF-8 charset declaration;
malformed, duplicate, unsupported, and unrelated parameters are rejected before
body validation.
The Make entry point rejects startup and later Makefiles, caller-selected flags,
ten non-executing or error-ignoring modes, and shell/npm/root overrides before
the reviewed graph runs. Its causal suite also verifies absolute external
invocation and checkout paths containing spaces, quotes, brackets, and shell
metacharacters.
Request bodies may only contain a `code` string. Chat message objects may only
contain `role` and `content`.
Every execute API response sets `Cache-Control: no-store` so submitted code,
provider output, and route errors are not intentionally retained by shared or
browser caches.
Whitespace-only OpenAI API keys are treated as missing before execute capacity
is consumed or the provider client is constructed.
GitHub Actions installs dependencies with `npm ci` and runs `make check` on
Node 20, 22, and 24 on Ubuntu 24.04 for pushes, pull requests, and manual dispatches. The
workflow uses commit-pinned actions, read-only repository access, and a bounded
runtime. It does not persist checkout credentials after source retrieval. The
lockfile retains `esbuild 0.28.1` for the `tsx` test runner so the audit gate
rejects the vulnerable 0.28.0 resolution.

When the required SDK or runtime is unavailable, use static checks and source review first, then verify on a machine that has the matching platform toolchain.

## Configuration and Secrets

- Detected references to OpenAI. Keep API keys, OAuth credentials, tokens, and account-specific values in local configuration only.
- `OPENAI_API_KEY` must be provided through the environment. Do not commit
  OpenAI keys or sample outputs containing private prompt data. Leading and
  trailing whitespace is removed, and an empty result is rejected as missing.
- `DOCS_EXECUTE_ENABLED` must be exactly `true` after whitespace and case
  normalization before the spend-capable route is active.
- `EXECUTE_API_TOKEN` must be a nonblank server-side secret, and every enabled
  request must present the exact value as a bearer token before content parsing,
  request validation, rate-budget consumption, or provider setup. The editor
  keeps the caller-supplied value only in component memory and does not persist it.
  Tokens must be well-formed Unicode and no more than 1,024 UTF-8 bytes.
- `OPENAI_ALLOWED_MODELS` can narrow the comma-separated chat model allow-list.
  It can only narrow the checked-in default model allow-list; unsupported
  values are not allowed to expand the proxy. When unset, the execute API only
  accepts `gpt-4o-mini`. Explicitly blank or comma-only configuration
  allows no models instead of reopening those defaults.
- Submitted chat messages are normalized to `role` and `content` only; message
  metadata fields are rejected instead of silently dropped.
- Whitespace-only chat message content is rejected before provider eligibility;
  accepted nonblank content retains its original leading and trailing spacing.
- Lone UTF-16 surrogates in execute message content are rejected before provider eligibility; valid surrogate pairs remain accepted unchanged.
- Lone UTF-16 surrogates in execute stop sequences are rejected; valid surrogate pairs and whitespace sequences remain accepted unchanged.
- Execute API request bodies are limited to the `code` field; extra fields such
  as credentials or metadata are rejected before code parsing.
- Extracted parameter and message objects preserve prototype-pollution keys as
  own fields so the allow-lists reject them.
- Numeric execute parameters must be finite numbers within their checked range;
  non-finite values are rejected before proxying.
- Execute normalization requires own request, parameter, and message fields
  before reading `code`, `model`, `messages`, `role`, or `content`.
- Enabled provider calls use a fixed 30-second timeout with SDK retries disabled
  so one interactive request has a bounded OpenAI attempt.
- Provider-eligible requests consume the process-local budget only after
  Content-Type, body, code, parameter, and API-key validation. Ten eligible
  attempts per process per minute are admitted; exhausted windows return `429`
  with `Retry-After` before provider client construction. Multi-instance
  deployments still require an upstream shared limiter.
- Execute API responses use `Cache-Control: no-store` so code, model output,
  and errors are not intentionally cached.
- Execute content-type validation rejects multi-value Content-Type headers to
  avoid ambiguous request interpretation before body normalization.

## Security and Privacy Notes

- Review changes touching external API calls or credential-adjacent configuration; examples from the scan include components/Editor.tsx, package.json, pages/api/execute/code.ts, pages/index.tsx.
- Review changes touching network requests, sockets, or service endpoints; examples from the scan include components/Editor.tsx, components/Navigation.tsx.
- Review changes touching file, media, JSON, XML, CSV, OCR, or data parsing; examples from the scan include components/Editor.tsx, components/Navigation.module.css, pages/api/execute/code.ts.
- Review changes touching database, model, or persistence code; examples from the scan include components/Editor.tsx, pages/index.tsx.

## Maintenance Notes

- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `VISION.md` for project direction and contribution guardrails.
- See `docs/plans/2026-06-08-docs-execute-api-baseline.md` for the current
  execute API hardening baseline.
- See `docs/plans/2026-06-08-docs-lint-gate.md` for the TypeScript lint gate.
- See `docs/plans/2026-06-09-model-allowlist-narrowing.md` for model
  allow-list narrowing semantics.
- See `docs/plans/2026-06-09-json-content-type-guard.md` for the execute API
  JSON request boundary.
- See `docs/plans/2026-06-09-message-field-allowlist.md` for the execute API
  message field allow-list.
- See `docs/plans/2026-06-09-execute-body-field-allowlist.md` for the execute body field allow-list.
- See `docs/plans/2026-06-09-prototype-key-rejection.md` for prototype key
  rejection in extracted execute API objects.
- See `docs/plans/2026-06-09-finite-numeric-parameter-validation.md` for
  finite numeric execute parameters.
- See `docs/plans/2026-06-09-own-field-validation.md` for own request,
  parameter, and message field validation.
- See `docs/plans/2026-06-10-ci-baseline.md` for the hosted GitHub Actions
  baseline.
- See `docs/plans/2026-06-10-execute-api-enable-gate.md` for the explicit
  execute route deployment interlock.
- See `docs/plans/2026-06-12-openai-request-timeout.md` for the bounded OpenAI
  provider-call contract.
- See `docs/plans/2026-06-12-checkout-credential-and-esbuild-boundary.md` for
  checkout token isolation and the patched test-runner dependency resolution.
- See `docs/plans/2026-06-13-execute-api-no-store.md` for the execute response
  cache boundary.
- See `docs/plans/2026-06-13-execute-fixed-window-budget.md` for the process-local
  execute request budget.
- See `docs/plans/2026-06-13-provider-eligible-execute-budget.md` for local
  validation ordering before execute capacity consumption.
- Use [`INTEGRATION_VERIFICATION.md`](INTEGRATION_VERIFICATION.md) for
  exact-head browser, deployed route, deployment edge, and provider evidence.
  It requires isolated synthetic requests and sanitized outcomes.

## Contributing

Keep changes small and tied to the project that is already present in this repository. For code changes, document the toolchain used, avoid committing generated dependency directories or local configuration, and update this README when setup or verification steps change.
