# Execute Stop Unicode Integrity

## Status: Completed

## Context

Execute message content rejects lone UTF-16 surrogates, but `stop` strings and
stop-array entries still accept them. Those malformed code units can cross the
OpenAI request boundary even though valid supplementary-plane characters must
remain supported.

## Objectives

- Reject lone high and low surrogates in scalar and array stop sequences.
- Preserve valid surrogate pairs, whitespace stop sequences, and existing
  length and count limits without rewriting accepted values.
- Reuse the message well-formedness boundary instead of introducing a second
  Unicode validator.
- Add mutation-sensitive parser, source, guidance, and completed-plan
  contracts.

## Scope

- Update `pages/api/execute/code.ts` and `scripts/test-execute-parser.ts`.
- Extend `scripts/check-baseline.sh` with stop Unicode contracts.
- Update `README.md`, `SECURITY.md`, `VISION.md`, and `CHANGES.md`.

## Verification

- `sh -n scripts/check-baseline.sh`
- Focused parser and SDK-free baseline tests
- Repository-root and external-directory `make check`
- Isolated mutations removing scalar, array, valid-pair, guidance, or
  completed-plan coverage
- Exact diff, generated-artifact, secret-like addition, conflict-marker,
  whitespace, and file-mode audits

## Risks

- Valid emoji and other supplementary-plane stop sequences must remain valid.
- Existing whitespace stop sequences must not be treated as blank messages.
- No live OpenAI request or deployed execute route will be exercised.

## Out Of Scope

- Message validation, model selection, authentication, shared rate limiting,
  provider retry policy, UI changes, and dependency upgrades.

## Verification Completed

- `sh -n scripts/check-baseline.sh` and `npm run test:parser` passed under
  Node.js 20.19.5.
- Seven isolated stop-Unicode mutations were rejected: removing scalar or
  array validation, malformed scalar or array fixtures, valid-pair
  preservation, maintained guidance, or completed-plan status failed the
  baseline gate.
- Repository-root and external-directory `make check` passed lint, TypeScript,
  parser tests, Next.js production builds, static contracts, and
  `npm audit --audit-level=moderate` with zero vulnerabilities.
- No live OpenAI request or deployed execute route was exercised.
