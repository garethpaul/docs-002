# Retire GPT-3.5 Default

Status: Completed

## Goal

Remove the legacy GPT-3.5 Turbo model from the spend-capable execute proxy's
maximum provider allow-list without expanding API surface or model access.

## Work

- Narrowed `DEFAULT_ALLOWED_MODELS` to `gpt-4o-mini`.
- Added parser coverage proving `gpt-3.5-turbo` is rejected when environment
  configuration is absent.
- Preserved the existing environment narrowing behavior and empty-list
  fail-closed behavior.
- Updated setup, security, vision, agent guidance, visible copy, and CHANGES.
- Added static contracts that reject restoration of the legacy model.

## Verification

- Red-first parser test returned a normalized GPT-3.5 request before the
  maximum set was narrowed.
- Focused parser and build checks passed under Node 20.19; the host `make check`
  reached the documented Ruby prerequisite.
- Clean root and external-directory `make check` gates passed under Node
  20.20.2 and Ruby 3.1.2, including build, type-check, lint, audit,
  workflow-policy mutations, and generated-file checks.
- `npm audit` reported zero vulnerabilities.
- Shell syntax, whitespace, generated-artifact, and likely-secret audits
  passed.
- Hosted Node 20/22/24 checks and CodeQL results must pass on the exact pull
  request head before merge.

## Runtime Boundary

No live OpenAI request or browser interaction was executed. The route remains
disabled by default and still requires an API key plus exact bearer token when
explicitly enabled.
