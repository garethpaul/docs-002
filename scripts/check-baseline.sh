#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PACKAGE_JSON="$ROOT_DIR/package.json"
API="$ROOT_DIR/pages/api/execute/code.ts"
EDITOR="$ROOT_DIR/components/Editor.tsx"
PARSER_TEST="$ROOT_DIR/scripts/test-execute-parser.ts"
README="$ROOT_DIR/README.md"
PLAN="$ROOT_DIR/docs/plans/2026-06-08-docs-execute-api-baseline.md"
LINT_PLAN="$ROOT_DIR/docs/plans/2026-06-08-docs-lint-gate.md"
CHECK_PLAN="$ROOT_DIR/docs/plans/2026-06-08-docs-check-wrapper.md"
MODEL_PLAN="$ROOT_DIR/docs/plans/2026-06-09-model-allowlist-narrowing.md"
CONTENT_TYPE_PLAN="$ROOT_DIR/docs/plans/2026-06-09-json-content-type-guard.md"
MESSAGE_FIELD_PLAN="$ROOT_DIR/docs/plans/2026-06-09-message-field-allowlist.md"
BODY_FIELD_PLAN="$ROOT_DIR/docs/plans/2026-06-09-execute-body-field-allowlist.md"
PROTOTYPE_KEY_PLAN="$ROOT_DIR/docs/plans/2026-06-09-prototype-key-rejection.md"
FINITE_NUMERIC_PLAN="$ROOT_DIR/docs/plans/2026-06-09-finite-numeric-parameter-validation.md"
OWN_FIELD_PLAN="$ROOT_DIR/docs/plans/2026-06-09-own-field-validation.md"
CI_PLAN="$ROOT_DIR/docs/plans/2026-06-10-ci-baseline.md"
EXECUTE_ENABLE_PLAN="$ROOT_DIR/docs/plans/2026-06-10-execute-api-enable-gate.md"
REQUEST_TIMEOUT_PLAN="$ROOT_DIR/docs/plans/2026-06-12-openai-request-timeout.md"
CHECKOUT_CREDENTIAL_PLAN="$ROOT_DIR/docs/plans/2026-06-12-checkout-credential-and-esbuild-boundary.md"
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"
MAKEFILE="$ROOT_DIR/Makefile"

require_file() {
  path=$1
  if [ ! -f "$ROOT_DIR/$path" ]; then
    printf '%s\n' "Required file is missing: $path" >&2
    exit 1
  fi
}

for path in \
  "README.md" \
  ".github/workflows/check.yml" \
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
  "docs/plans/2026-06-09-prototype-key-rejection.md" \
  "docs/plans/2026-06-09-finite-numeric-parameter-validation.md" \
  "docs/plans/2026-06-09-own-field-validation.md" \
  "docs/plans/2026-06-10-ci-baseline.md" \
  "docs/plans/2026-06-10-execute-api-enable-gate.md" \
  "docs/plans/2026-06-12-openai-request-timeout.md" \
  "docs/plans/2026-06-12-checkout-credential-and-esbuild-boundary.md" \
  "scripts/test-execute-parser.ts" \
  "scripts/check-baseline.sh"; do
  require_file "$path"
done

if ! grep -Fq "actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10" "$CI_WORKFLOW" ||
  ! grep -Fq "actions/setup-node@48b55a011bda9f5d6aeb4c2d9c7362e8dae4041e" "$CI_WORKFLOW" ||
  ! grep -Fq "node-version: [20, 22, 24]" "$CI_WORKFLOW" ||
  ! grep -Fq "run: npm ci" "$CI_WORKFLOW" ||
  ! grep -Fq "run: make check" "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions workflow must pin actions and run make check across supported Node releases." >&2
  exit 1
fi

if ! grep -Fq "permissions:" "$CI_WORKFLOW" || ! grep -Fq "contents: read" "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions workflow must keep repository access read-only." >&2
  exit 1
fi

if [ "$(grep -Fc "uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10" "$CI_WORKFLOW")" -ne 1 ] ||
  [ "$(grep -Fc "persist-credentials: false" "$CI_WORKFLOW")" -ne 1 ]; then
  printf '%s\n' "GitHub Actions must use one pinned checkout without persisting credentials." >&2
  exit 1
fi

if ! awk '
  /uses: actions\/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10/ { checkout = 1; next }
  checkout && /^[[:space:]]+with:[[:space:]]*$/ { options = 1; next }
  checkout && options && /^[[:space:]]+persist-credentials: false[[:space:]]*$/ { protected = 1; next }
  checkout && /^[[:space:]]+- / { exit }
  END { exit protected ? 0 : 1 }
' "$CI_WORKFLOW"; then
  printf '%s\n' "Checkout credential persistence must be disabled on the pinned checkout step." >&2
  exit 1
fi

if ! node -e '
  const lock = require(process.argv[1]);
  const entry = lock.packages && lock.packages["node_modules/esbuild"];
  if (!entry || entry.version !== "0.28.1" ||
      entry.resolved !== "https://registry.npmjs.org/esbuild/-/esbuild-0.28.1.tgz" ||
      typeof entry.integrity !== "string" || !entry.integrity.startsWith("sha512-")) process.exit(1);
' "$ROOT_DIR/package-lock.json"; then
  printf '%s\n' "The lockfile must retain the reviewed esbuild 0.28.1 resolution and integrity." >&2
  exit 1
fi

if ! grep -Fq "workflow_dispatch:" "$CI_WORKFLOW" || ! grep -Fq "timeout-minutes: 15" "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions workflow must support bounded manual verification." >&2
  exit 1
fi

if ! grep -Fq "runs-on: ubuntu-24.04" "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions must use the stable Ubuntu 24.04 runner." >&2
  exit 1
fi

if ! grep -Fq 'ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' "$MAKEFILE" ||
  [ "$(grep -c '\$(NPM) --prefix \$(ROOT)' "$MAKEFILE")" -ne 4 ]; then
  printf '%s\n' "Make targets must run npm from the repository root." >&2
  exit 1
fi

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
for (const [name, version] of Object.entries({
  next: "16.2.9",
  openai: "6.42.0",
  react: "19.2.7",
  "react-dom": "19.2.7",
  "@codemirror/lint": "6.9.7",
})) {
  if (pkg.dependencies?.[name] !== version) {
    throw new Error(`package.json must pin ${name} ${version}`);
  }
}
if (pkg.scripts.audit !== "npm audit --audit-level=moderate") {
  throw new Error("package.json must keep the moderate-severity audit gate");
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
  "isExecuteApiEnabled" \
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

if ! grep -Fq "OPENAI_REQUEST_OPTIONS = Object.freeze({ timeout: 30_000, maxRetries: 0 })" "$API" ||
  ! grep -Fq "OPENAI_REQUEST_OPTIONS," "$API" ||
  ! grep -Fq "assert.deepEqual(OPENAI_REQUEST_OPTIONS, { timeout: 30_000, maxRetries: 0 })" "$PARSER_TEST" ||
  ! grep -Fq "Object.isFrozen(OPENAI_REQUEST_OPTIONS)" "$PARSER_TEST"; then
  printf '%s\n' "OpenAI execute requests must keep the tested 30-second zero-retry boundary." >&2
  exit 1
fi

if ! grep -Fq 'value.trim().toLowerCase() === "true"' "$API" ||
  ! grep -Fq 'return res.status(503).json({ error: "Execute API is disabled" })' "$API"; then
  printf '%s\n' "Execute API must stay disabled unless explicitly enabled." >&2
  exit 1
fi

if ! grep -Fq "defaultAllowedModels.has(model)" "$API"; then
  printf '%s\n' "OPENAI_ALLOWED_MODELS must only narrow the default model allow-list." >&2
  exit 1
fi

if ! grep -Fq "Number.isFinite(value)" "$API"; then
  printf '%s\n' "Execute numeric parameters must reject non-finite values." >&2
  exit 1
fi

if ! grep -Fq "Object.create(null) as JsonObject" "$API"; then
  printf '%s\n' "execute API must preserve prototype keys as own fields during extraction." >&2
  exit 1
fi

if ! grep -Fq "function hasOwnJsonField" "$API" ||
  ! grep -Fq 'hasOwnJsonField(payload, "code")' "$API" ||
  ! grep -Fq 'hasOwnJsonField(params, "model")' "$API" ||
  ! grep -Fq 'hasOwnJsonField(params, "messages")' "$API" ||
  ! grep -Fq 'hasOwnJsonField(message, "role")' "$API" ||
  ! grep -Fq 'hasOwnJsonField(message, "content")' "$API"; then
  printf '%s\n' "execute API must require own fields before reading normalized request data." >&2
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

if ! grep -Fq 'isExecuteApiEnabled("1")' "$ROOT_DIR/scripts/test-execute-parser.ts" ||
  ! grep -Fq 'isExecuteApiEnabled(" TRUE ")' "$ROOT_DIR/scripts/test-execute-parser.ts"; then
  printf '%s\n' "Execute parser tests must cover explicit API enablement normalization." >&2
  exit 1
fi

if ! grep -Fq 'apiKey: "secret"' "$ROOT_DIR/scripts/test-execute-parser.ts"; then
  printf '%s\n' "Execute parser tests must reject extra execute request body fields." >&2
  exit 1
fi

if ! grep -Fq "Object.create({ code:" "$ROOT_DIR/scripts/test-execute-parser.ts" ||
  ! grep -Fq "Inherited params" "$ROOT_DIR/scripts/test-execute-parser.ts" ||
  ! grep -Fq "Inherited message" "$ROOT_DIR/scripts/test-execute-parser.ts"; then
  printf '%s\n' "Execute parser tests must reject inherited request, parameter, and message fields." >&2
  exit 1
fi

if ! grep -Fq 'name: "sample-user"' "$ROOT_DIR/scripts/test-execute-parser.ts"; then
  printf '%s\n' "Execute parser tests must reject extra chat message fields." >&2
  exit 1
fi

if [ "$(grep -Fc '"__proto__": { polluted: true }' "$ROOT_DIR/scripts/test-execute-parser.ts")" -lt 2 ]; then
  printf '%s\n' "Execute parser tests must reject prototype-pollution keys in params and messages." >&2
  exit 1
fi

if ! grep -Fq "temperature: 1e309" "$ROOT_DIR/scripts/test-execute-parser.ts"; then
  printf '%s\n' "Execute parser tests must reject non-finite numeric parameters." >&2
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

if ! grep -Fq "Status: Completed" "$PROTOTYPE_KEY_PLAN"; then
  printf '%s\n' "Prototype key rejection plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$PROTOTYPE_KEY_PLAN"; then
  printf '%s\n' "Prototype key rejection plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$FINITE_NUMERIC_PLAN"; then
  printf '%s\n' "Finite numeric parameter validation plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$FINITE_NUMERIC_PLAN"; then
  printf '%s\n' "Finite numeric parameter validation plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$OWN_FIELD_PLAN"; then
  printf '%s\n' "Own field validation plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$OWN_FIELD_PLAN"; then
  printf '%s\n' "Own field validation plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$CI_PLAN" ||
  ! grep -Fq "make check" "$CI_PLAN"; then
  printf '%s\n' "CI baseline plan must be completed and record make check verification." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$EXECUTE_ENABLE_PLAN" ||
  ! grep -Fq "make check" "$EXECUTE_ENABLE_PLAN"; then
  printf '%s\n' "Execute API enable gate plan must be completed and record verification." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$REQUEST_TIMEOUT_PLAN" ||
  ! grep -Fq "npm test" "$REQUEST_TIMEOUT_PLAN"; then
  printf '%s\n' "OpenAI request timeout plan must remain completed and verified." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$CHECKOUT_CREDENTIAL_PLAN" ||
  ! grep -Fq 'Node 20 `npm test` passed' "$CHECKOUT_CREDENTIAL_PLAN" ||
  ! grep -Fq "external working directory" "$CHECKOUT_CREDENTIAL_PLAN" ||
  ! grep -Fq "hostile mutations were rejected" "$CHECKOUT_CREDENTIAL_PLAN" ||
  ! grep -Fq "zero vulnerabilities" "$CHECKOUT_CREDENTIAL_PLAN"; then
  printf '%s\n' "Checkout and esbuild plan must record completed verification." >&2
  exit 1
fi

if ! grep -Fq "does not persist checkout credentials" "$README" ||
  ! grep -Fq "esbuild 0.28.1" "$README" ||
  ! grep -Fq "does not persist checkout credentials" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "credential-free checkout" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "Stopped checkout credential persistence" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Project guidance must document the checkout and esbuild boundaries." >&2
  exit 1
fi

if ! grep -Fq "OPENAI_API_KEY" "$README" ||
  ! grep -Fq "OPENAI_ALLOWED_MODELS" "$README" ||
  ! grep -Fq "DOCS_EXECUTE_ENABLED" "$README" ||
  ! grep -Fq "Content-Type: application/json" "$README" ||
  ! grep -Fq "npm test" "$README" ||
  ! grep -Fq "make check" "$README" ||
  ! grep -Fq "GitHub Actions" "$README" ||
  ! grep -Fq "docs/plans/2026-06-10-ci-baseline.md" "$README"; then
  printf '%s\n' "README must document API key, model allow-list, JSON content type, npm test, and make check." >&2
  exit 1
fi

if ! grep -Fq "GitHub Actions" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "GitHub Actions" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "GitHub Actions" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Project docs must record the GitHub Actions CI baseline." >&2
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

if ! grep -Fq "prototype-pollution keys" "$README"; then
  printf '%s\n' "README must document prototype key rejection." >&2
  exit 1
fi

if ! grep -Fq "finite numeric execute parameters" "$README"; then
  printf '%s\n' "README must document finite numeric execute parameter validation." >&2
  exit 1
fi

if ! grep -Fq "own request, parameter, and message fields" "$README"; then
  printf '%s\n' "README must document own field validation." >&2
  exit 1
fi

if ! grep -Fq "check: verify" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose make check as the repository verification wrapper." >&2
  exit 1
fi

npm --prefix "$ROOT_DIR" run test:parser

printf '%s\n' "docs-002 execute API baseline checks passed."
