# Changes

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
