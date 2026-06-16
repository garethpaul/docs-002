# Execute Message Unicode Integrity

## Status: In Progress

## Context

The execute route validates message type, nonblank content, per-message length,
and aggregate length, but it accepts strings containing lone UTF-16
surrogates. Those code units do not represent valid Unicode scalar text and
can reach the OpenAI request boundary. Valid supplementary-plane characters
use paired surrogates and must remain accepted.

## Objectives

- Reject lone high and low surrogates in every execute chat message.
- Preserve valid surrogate pairs, ordinary Unicode, and accepted message
  spacing without rewriting content.
- Keep rejection before execute capacity consumption and provider setup.
- Add mutation-sensitive parser, handler-ordering, guidance, and completed-plan
  contracts.

## Scope

- Update `pages/api/execute/code.ts` and `scripts/test-execute-parser.ts`.
- Extend `scripts/check-baseline.sh` with source, regression, ordering,
  documentation, and plan-evidence contracts.
- Document the message Unicode boundary in `README.md`, `SECURITY.md`,
  `VISION.md`, and `CHANGES.md`.

## Verification

- Focused parser and baseline tests
- Repository-root and external-directory `make check`
- Isolated mutations removing the Unicode predicate, high/low surrogate
  fixtures, valid-pair preservation, guidance, or completed-plan evidence
- `git diff --check`
- Exact-path, generated-artifact, sensitive-value, conflict-marker, and
  file-mode audits

## Risks

- The check must reject unpaired code units without rejecting valid emoji or
  other supplementary-plane characters.
- Accepted message text must remain byte-for-byte unchanged after validation.
- No live OpenAI request or deployed execute route will be exercised.
- This PR is stacked on PR #14 and must retain base-first merge ordering.

## Out Of Scope

- Stop-string Unicode policy, model selection, authentication, shared
  distributed rate limiting, provider retry policy, UI changes, and dependency
  upgrades.
