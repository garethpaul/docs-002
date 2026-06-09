# Changes

## 2026-06-09

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
