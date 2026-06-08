# Changes

## 2026-06-08

- Hardened the execute API proxy with AST-only extraction, literal parameter
  validation, model allow-listing, bounded message content, runtime key checks,
  and generic provider failure responses.
- Fixed the editor request path to submit the current code string directly,
  render API errors, and avoid logging submitted prompts or responses.
- Pinned the Next/Babel/OpenAI tooling baseline and added `npm test`,
  `npm run check`, and `npm run audit` verification gates.
