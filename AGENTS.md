# AGENTS.md

## Repository purpose

`garethpaul/docs-002` is a JavaScript web application or frontend sample. The checked-in files describe a JavaScript web application or frontend sample with the structure summarized below.

## Project structure

- `Makefile` - repository verification targets
- `scripts` - baseline checks and helper scripts
- `docs` - plans, notes, and generated README assets
- `package.json` - Node package metadata and scripts
- `components` - repository source or sample assets
- `pages` - repository source or sample assets
- `public` - repository source or sample assets

## Development commands

- Install dependencies: `npm ci`
- Full baseline: `make check`
- Combined verification: `make verify`
- Lint/static checks: `make lint`
- Tests: `make test`
- Build: `make build`
- package script `dev`: `npm run dev`
- package script `start`: `npm start`
- package script `build`: `npm run build`
- package script `lint`: `npm run lint`
- package script `type-check`: `npm run type-check`
- package script `test`: `npm test`
- package script `check`: `npm run check`
- package script `audit`: `npm run audit`
- If a command above skips because a platform toolchain is missing, verify on a machine with that SDK before claiming platform behavior is tested.

## Coding conventions

- Language mix noted in the README: React TSX (4), TypeScript (1).
- Use Node >=20.19.0 for package scripts.
- Keep React components controlled and covered by component tests when props or rendering behavior changes.
- Next.js routes, pages, and API handlers should stay aligned with the existing app structure.

## Testing guidance

- Test-related files detected: `scripts/test-execute-parser.ts`
- Start with the narrowest relevant test or Make target, then run `make check` before handing off if the change is not documentation-only.
- Keep README verification notes in sync when commands, fixtures, or supported toolchains change.

## PR / change guidance

- Keep diffs focused on the requested repository and avoid unrelated modernization or formatting churn.
- Preserve public APIs, sample behavior, file formats, and documented environment variables unless the task explicitly changes them.
- Update tests, README notes, or docs/plans when behavior, security posture, or validation commands change.
- Call out skipped platform validation, legacy toolchain assumptions, and any risky files touched in the final summary.

## Safety and gotchas

- Detected references to OpenAI. Keep API keys, OAuth credentials, tokens, and account-specific values in local configuration only.
- `OPENAI_API_KEY` must be provided through the environment. Do not commit OpenAI keys or sample outputs containing private prompt data.
- `OPENAI_ALLOWED_MODELS` can only narrow the checked-in `gpt-4o-mini` maximum; unsupported or legacy values must not expand the proxy.
- Submitted chat messages are normalized to `role` and `content` only; message metadata fields are rejected instead of silently dropped.
- Execute API request bodies are limited to the `code` field; extra fields such as credentials or metadata are rejected before code parsing.
- Extracted parameter and message objects preserve prototype-pollution keys as own fields so the allow-lists reject them.

## Agent workflow

1. Inspect the README, Makefile, manifests, and the files directly related to the request.
2. Make the smallest source or docs change that satisfies the task; avoid generated, vendored, or local-environment files unless required.
3. Run the narrowest useful validation first, then `make check` or the documented package/platform gate when available.
4. If a required SDK, service credential, or external runtime is unavailable, record the skipped command and why.
5. Summarize changed files, commands run, and remaining risks or follow-up validation.
