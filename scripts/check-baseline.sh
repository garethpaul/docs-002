#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PACKAGE_JSON="$ROOT_DIR/package.json"
API="$ROOT_DIR/pages/api/execute/code.ts"
EDITOR="$ROOT_DIR/components/Editor.tsx"
README="$ROOT_DIR/README.md"
PLAN="$ROOT_DIR/docs/plans/2026-06-08-docs-execute-api-baseline.md"
LINT_PLAN="$ROOT_DIR/docs/plans/2026-06-08-docs-lint-gate.md"
CHECK_PLAN="$ROOT_DIR/docs/plans/2026-06-08-docs-check-wrapper.md"
MODEL_PLAN="$ROOT_DIR/docs/plans/2026-06-09-model-allowlist-narrowing.md"
CONTENT_TYPE_PLAN="$ROOT_DIR/docs/plans/2026-06-09-json-content-type-guard.md"
MESSAGE_FIELD_PLAN="$ROOT_DIR/docs/plans/2026-06-09-message-field-allowlist.md"
BODY_FIELD_PLAN="$ROOT_DIR/docs/plans/2026-06-09-execute-body-field-allowlist.md"

require_file() {
  path=$1
  if [ ! -f "$ROOT_DIR/$path" ]; then
    printf '%s\n' "Required file is missing: $path" >&2
    exit 1
  fi
}

for path in \
  "README.md" \
  "Makefile" \
  "eslint.config.mjs" \
  "package.json" \
  "package-lock.json" \
  "pages/api/execute/code.ts" \
  "components/Editor.tsx" \
  "docs/plans/2026-06-08-docs-check-wrapper.md" \
  "docs/plans/2026-06-08-docs-execute-api-baseline.md" \
  "docs/plans/2026-06-08-docs-lint-gate.md" \
  "docs/plans/2026-06-09-json-content-type-guard.md" \
  "docs/plans/2026-06-09-execute-body-field-allowlist.md" \
  "docs/plans/2026-06-09-message-field-allowlist.md" \
  "docs/plans/2026-06-09-model-allowlist-narrowing.md" \
  "scripts/test-execute-parser.ts" \
  "scripts/check-baseline.sh"; do
  require_file "$path"
done

node - "$PACKAGE_JSON" <<'NODE'
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
if (pkg.dependencies.next === "latest") {
  throw new Error("next must be pinned; latest is not reproducible");
}
for (const script of ["check", "audit", "test", "test:parser", "type-check"]) {
  if (!pkg.scripts || !pkg.scripts[script]) {
    throw new Error(`package.json must define ${script}`);
  }
}
if (!pkg.scripts.lint || pkg.scripts.lint !== "eslint components pages scripts --ext ts,tsx --max-warnings=0") {
  throw new Error("package.json must define the zero-warning lint gate");
}
if (!pkg.scripts.test.includes("npm run lint")) {
  throw new Error("npm test must include the lint gate");
}
if (!pkg.scripts.test.includes("npm run test:parser")) {
  throw new Error("npm test must include the execute parser test gate");
}
if (!pkg.scripts.test.includes("npm run build")) {
  throw new Error("npm test must include the Next build gate");
}
if (!pkg.engines || pkg.engines.node !== ">=20.19.0") {
  throw new Error("package.json must declare the supported Node 20.19+ engine");
}
if (!pkg.overrides || pkg.overrides.postcss !== "8.5.10") {
  throw new Error("package.json must override postcss to the patched baseline");
}
if (!pkg.devDependencies || !pkg.devDependencies.eslint || !pkg.devDependencies["typescript-eslint"]) {
  throw new Error("package.json must include ESLint dependencies");
}
NODE

if grep -Fq "code.match(" "$API" || grep -Fq "JSON.parse(formattedStr)" "$API"; then
  printf '%s\n' "execute API must not parse OpenAI calls with regex/string JSON munging." >&2
  exit 1
fi

if grep -Fq "console.log" "$API" "$EDITOR" || grep -Fq "console.error" "$API" "$EDITOR"; then
  printf '%s\n' "execute API and editor must not log submitted code, parameters, or provider responses." >&2
  exit 1
fi

for required in \
  "MAX_CODE_LENGTH" \
  "MAX_MESSAGES" \
  "MAX_MESSAGE_CONTENT_LENGTH" \
  "MAX_COMPLETION_TOKENS" \
  "extractParameters" \
  "hasJsonContentType" \
  "normalizeChatRequest" \
  "OPENAI_API_KEY" \
  "OPENAI_ALLOWED_MODELS" \
  "ALLOWED_BODY_FIELDS" \
  "ALLOWED_MESSAGE_ROLES" \
  "ALLOWED_MESSAGE_FIELDS" \
  "ALLOWED_PARAMETER_NAMES" \
  "DEFAULT_ALLOWED_MODELS"; do
  if ! grep -Fq "$required" "$API"; then
    printf '%s\n' "execute API missing required guard: $required" >&2
    exit 1
  fi
done

if ! grep -Fq "defaultAllowedModels.has(model)" "$API"; then
  printf '%s\n' "OPENAI_ALLOWED_MODELS must only narrow the default model allow-list." >&2
  exit 1
fi

if ! grep -Fq "Request content type must be application/json" "$API"; then
  printf '%s\n' "execute API must reject non-JSON request content types." >&2
  exit 1
fi

if ! grep -Fq "normalizeExecuteBody" "$API" ||
  ! grep -Fq "Request body must include only a code string" "$API"; then
  printf '%s\n' "execute API must validate request body fields before parsing code." >&2
  exit 1
fi

if ! grep -Fq "process.env.OPENAI_ALLOWED_MODELS = \"gpt-4o-mini\"" "$ROOT_DIR/scripts/test-execute-parser.ts" ||
  ! grep -Fq "process.env.OPENAI_ALLOWED_MODELS = \"not-allowed\"" "$ROOT_DIR/scripts/test-execute-parser.ts"; then
  printf '%s\n' "Execute parser tests must cover model allow-list narrowing." >&2
  exit 1
fi

if ! grep -Fq "hasJsonContentType(\"Application/JSON; charset=utf-8\")" "$ROOT_DIR/scripts/test-execute-parser.ts" ||
  ! grep -Fq "hasJsonContentType(\"text/plain\")" "$ROOT_DIR/scripts/test-execute-parser.ts"; then
  printf '%s\n' "Execute parser tests must cover JSON content-type enforcement." >&2
  exit 1
fi

if ! grep -Fq 'apiKey: "secret"' "$ROOT_DIR/scripts/test-execute-parser.ts"; then
  printf '%s\n' "Execute parser tests must reject extra execute request body fields." >&2
  exit 1
fi

if ! grep -Fq 'name: "sample-user"' "$ROOT_DIR/scripts/test-execute-parser.ts"; then
  printf '%s\n' "Execute parser tests must reject extra chat message fields." >&2
  exit 1
fi

if grep -Fq "JSON.stringify(codeContent)" "$EDITOR"; then
  printf '%s\n' "Editor must send codeContent directly; do not double-encode it." >&2
  exit 1
fi

if ! grep -Fq "body: JSON.stringify({ code: codeContent })" "$EDITOR"; then
  printf '%s\n' "Editor must post the current code content to the execute API." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$PLAN"; then
  printf '%s\n' "Plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$LINT_PLAN"; then
  printf '%s\n' "Lint plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$CHECK_PLAN"; then
  printf '%s\n' "Check wrapper plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$MODEL_PLAN"; then
  printf '%s\n' "Model allow-list narrowing plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$CONTENT_TYPE_PLAN"; then
  printf '%s\n' "JSON content-type guard plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$MESSAGE_FIELD_PLAN"; then
  printf '%s\n' "Message field allow-list plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$BODY_FIELD_PLAN"; then
  printf '%s\n' "Execute body field allow-list plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$BODY_FIELD_PLAN"; then
  printf '%s\n' "Execute body field allow-list plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "make check" "$MESSAGE_FIELD_PLAN"; then
  printf '%s\n' "Message field allow-list plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "OPENAI_API_KEY" "$README" ||
  ! grep -Fq "OPENAI_ALLOWED_MODELS" "$README" ||
  ! grep -Fq "Content-Type: application/json" "$README" ||
  ! grep -Fq "npm test" "$README" ||
  ! grep -Fq "make check" "$README"; then
  printf '%s\n' "README must document API key, model allow-list, JSON content type, npm test, and make check." >&2
  exit 1
fi

if ! grep -Fq "can only narrow the checked-in default model allow-list" "$README"; then
  printf '%s\n' "README must document model allow-list narrowing semantics." >&2
  exit 1
fi

if ! grep -Fq "Chat message objects may only" "$README" ||
  ! grep -Fq "message field allow-list" "$README"; then
  printf '%s\n' "README must document the message field allow-list." >&2
  exit 1
fi

if ! grep -Fq "Request bodies may only contain" "$README" ||
  ! grep -Fq "execute body field allow-list" "$README"; then
  printf '%s\n' "README must document the execute body field allow-list." >&2
  exit 1
fi

if ! grep -Fq "check: verify" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose make check as the repository verification wrapper." >&2
  exit 1
fi

npm --prefix "$ROOT_DIR" run test:parser

printf '%s\n' "docs-002 execute API baseline checks passed."
