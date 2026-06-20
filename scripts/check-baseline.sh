#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PACKAGE_JSON="$ROOT_DIR/package.json"
PACKAGE_LOCK="$ROOT_DIR/package-lock.json"
API="$ROOT_DIR/pages/api/execute/code.ts"
EDITOR="$ROOT_DIR/components/Editor.tsx"
PARSER_TEST="$ROOT_DIR/scripts/test-execute-parser.ts"
README="$ROOT_DIR/README.md"
VISION="$ROOT_DIR/VISION.md"
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
NO_STORE_PLAN="$ROOT_DIR/docs/plans/2026-06-13-execute-api-no-store.md"
EXECUTE_RATE_BUDGET_PLAN="$ROOT_DIR/docs/plans/2026-06-13-execute-fixed-window-budget.md"
SINGLE_CONTENT_TYPE_PLAN="$ROOT_DIR/docs/plans/2026-06-13-single-json-content-type.md"
PROVIDER_ELIGIBLE_BUDGET_PLAN="$ROOT_DIR/docs/plans/2026-06-13-provider-eligible-execute-budget.md"
MAKE_ROOT_PLAN="$ROOT_DIR/docs/plans/2026-06-14-make-root-override-protection.md"
INTEGRATION_VERIFICATION="$ROOT_DIR/INTEGRATION_VERIFICATION.md"
INTEGRATION_VERIFICATION_PLAN="$ROOT_DIR/docs/plans/2026-06-14-execute-integration-verification.md"
NONBLANK_API_KEY_PLAN="$ROOT_DIR/docs/plans/2026-06-15-001-nonblank-openai-api-key.md"
EMPTY_MODEL_ALLOWLIST_PLAN="$ROOT_DIR/docs/plans/2026-06-15-empty-model-allowlist.md"
NONBLANK_MESSAGE_PLAN="$ROOT_DIR/docs/plans/2026-06-15-nonblank-message-content.md"
MESSAGE_UNICODE_PLAN="$ROOT_DIR/docs/plans/2026-06-16-execute-message-unicode-integrity.md"
STOP_UNICODE_PLAN="$ROOT_DIR/docs/plans/2026-06-16-execute-stop-unicode-integrity.md"
CONTENT_TYPE_PARAMETER_PLAN="$ROOT_DIR/docs/plans/2026-06-16-execute-content-type-parameters.md"
DEPENDENCY_REFRESH_PLAN="$ROOT_DIR/docs/plans/2026-06-18-compatible-dependency-refresh.md"
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"
CHECKOUT_WORKFLOW_VALIDATOR="$ROOT_DIR/scripts/validate-checkout-workflows.rb"
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
  "INTEGRATION_VERIFICATION.md" \
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
  "docs/plans/2026-06-13-execute-api-no-store.md" \
  "docs/plans/2026-06-13-execute-fixed-window-budget.md" \
  "docs/plans/2026-06-13-single-json-content-type.md" \
  "docs/plans/2026-06-13-provider-eligible-execute-budget.md" \
  "docs/plans/2026-06-14-make-root-override-protection.md" \
  "docs/plans/2026-06-14-execute-integration-verification.md" \
  "docs/plans/2026-06-15-empty-model-allowlist.md" \
  "docs/plans/2026-06-15-nonblank-message-content.md" \
  "docs/plans/2026-06-16-execute-message-unicode-integrity.md" \
  "docs/plans/2026-06-16-execute-stop-unicode-integrity.md" \
  "docs/plans/2026-06-16-execute-content-type-parameters.md" \
  "docs/plans/2026-06-18-compatible-dependency-refresh.md" \
  "scripts/test-execute-parser.ts" \
  "scripts/check-baseline.sh" \
  "scripts/validate-checkout-workflows.rb"; do
  require_file "$path"
done

for integration_contract in \
  "Commit: pending implementation commit" \
  "Pull request: pending" \
  "Evidence status: not run" \
  "isolated synthetic deployment" \
  "Required sanitized evidence" \
  "Use only \`pass\`, \`fail\`, \`blocked\`, or \`not run\`" \
  "A parser test, source check, package build, or static contract cannot mark an" \
  "No browser, deployed execute route, deployment edge, or live OpenAI provider"; do
  if ! grep -Fq "$integration_contract" "$INTEGRATION_VERIFICATION"; then
    printf '%s\n' "Integration verification matrix contract is missing: $integration_contract" >&2
    exit 1
  fi
done

if [ "$(grep -Ec '^\| [0-9]+ \|' "$INTEGRATION_VERIFICATION")" -ne 14 ] ||
  [ "$(grep -Ec '^\| [0-9]+ \|.*\| not run \|$' "$INTEGRATION_VERIFICATION")" -ne 14 ]; then
  printf '%s\n' "Integration verification matrix must retain 14 explicitly not-run scenarios." >&2
  exit 1
fi

for integration_scenario in \
  "Isolated deployment setup" \
  "Disabled execute route" \
  "Missing provider configuration" \
  "Method restriction" \
  "JSON media-type validation" \
  "Valid editor submission" \
  "Invalid editor submission" \
  "Provider success" \
  "Provider failure" \
  "Provider timeout" \
  "Response cache boundary" \
  "Execute request budget" \
  "Browser refresh behavior" \
  "Public deployment controls"; do
  if [ "$(grep -Fc "| $integration_scenario |" "$INTEGRATION_VERIFICATION")" -ne 1 ]; then
    printf '%s\n' "Integration verification scenario is missing or duplicated: $integration_scenario" >&2
    exit 1
  fi
done

for integration_guidance in \
  "INTEGRATION_VERIFICATION.md" \
  "isolated synthetic requests" \
  "sanitized outcomes"; do
  if ! grep -Fq "$integration_guidance" "$README"; then
    printf '%s\n' "README integration verification guidance is missing: $integration_guidance" >&2
    exit 1
  fi
done

if ! grep -Fq "Keep exact-head browser, deployment, and provider evidence sanitized" "$VISION" ||
  ! grep -Fq "Browser, deployment, and provider claims require" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "Added an exact-head execute integration verification matrix" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Project guidance must retain the execute integration evidence boundary." >&2
  exit 1
fi

for integration_plan_contract in \
  "status: completed" \
  "## Status: Completed" \
  "## Work Completed" \
  "## Verification Completed" \
  "Node.js 20.19.5 and Node.js 24.16.0" \
  "Twelve isolated hostile documentation mutations were rejected" \
  "all 14 integration scenarios remain"; do
  if ! grep -Fq "$integration_plan_contract" "$INTEGRATION_VERIFICATION_PLAN"; then
    printf '%s\n' "Integration verification plan must record completed evidence: $integration_plan_contract" >&2
    exit 1
  fi
done

CONTENT_TYPE_HELPER=$(awk '
  /^export function hasJsonContentType\(/ { capture = 1 }
  capture && /^export function / && $0 !~ /^export function hasJsonContentType\(/ { exit }
  capture { print }
' "$API")

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

ruby "$CHECKOUT_WORKFLOW_VALIDATOR" "$ROOT_DIR/.github/workflows"

if ! node - "$PACKAGE_JSON" "$PACKAGE_LOCK" <<'NODE'
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
const lock = JSON.parse(fs.readFileSync(process.argv[3], "utf8"));
const reviewed = {
  "@codemirror/search": "6.7.1",
  "@radix-ui/react-menubar": "1.1.18",
  "@radix-ui/react-navigation-menu": "1.2.16",
  eslint: "10.5.0",
  openai: "6.44.0",
  "typescript-eslint": "8.61.1",
};
for (const [name, version] of Object.entries(reviewed)) {
  const declared = pkg.dependencies?.[name] ?? pkg.devDependencies?.[name];
  const resolved = lock.packages?.[`node_modules/${name}`]?.version;
  if (declared !== version || resolved !== version) {
    throw new Error(`${name} must be declared and resolved at ${version}`);
  }
}
const esbuild = lock.packages?.["node_modules/esbuild"];
if (!esbuild || esbuild.version !== "0.28.1" ||
    esbuild.resolved !== "https://registry.npmjs.org/esbuild/-/esbuild-0.28.1.tgz" ||
    typeof esbuild.integrity !== "string" || !esbuild.integrity.startsWith("sha512-")) {
  throw new Error("esbuild must retain the reviewed 0.28.1 resolution and integrity");
}
NODE
then
  printf '%s\n' "The manifest and lockfile must retain reviewed dependency and esbuild resolutions." >&2
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

if ! grep -Fxq 'override ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' "$MAKEFILE" ||
  [ "$(grep -c '\$(NPM) --prefix \$(ROOT)' "$MAKEFILE")" -ne 4 ]; then
  printf '%s\n' "Make targets must protect and use the repository root." >&2
  exit 1
fi

for make_root_plan_contract in \
  "status: completed" \
  "## Status: Completed" \
  "## Work Completed" \
  "## Verification Completed" \
  "zero vulnerabilities" \
  "Three isolated hostile assignment mutations were rejected"; do
  if ! grep -Fq "$make_root_plan_contract" "$MAKE_ROOT_PLAN"; then
    printf '%s\n' "Make-root plan must record completed evidence: $make_root_plan_contract" >&2
    exit 1
  fi
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
for (const [name, version] of Object.entries({
  next: "16.2.9",
  openai: "6.44.0",
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

for dependency_plan_contract in \
  "## Status: Completed" \
  "## Work Completed" \
  "## Verification Completed" \
  "\`@codemirror/search\` to 6.7.1" \
  "OpenAI to 6.44.0" \
  "TypeScript 6 and @types/node 25 remain intentionally deferred" \
  "Ten isolated dependency-contract mutations were rejected"; do
  if ! grep -Fq "$dependency_plan_contract" "$DEPENDENCY_REFRESH_PLAN"; then
    printf '%s\n' "Dependency refresh plan must record completed evidence: $dependency_plan_contract" >&2
    exit 1
  fi
done

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
  "EXECUTE_CACHE_CONTROL" \
  "extractParameters" \
  "hasJsonContentType" \
  "isExecuteApiEnabled" \
  "normalizeOpenAIApiKey" \
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

if ! grep -Fq 'EXECUTE_CACHE_CONTROL = "no-store"' "$API" ||
  ! grep -Fq 'res.setHeader("Cache-Control", EXECUTE_CACHE_CONTROL)' "$API" ||
  ! grep -Fq 'assert.equal(EXECUTE_CACHE_CONTROL, "no-store")' "$PARSER_TEST"; then
  printf '%s\n' "Execute API responses must keep the tested no-store cache policy." >&2
  exit 1
fi

if ! grep -Fq "OPENAI_REQUEST_OPTIONS = Object.freeze({ timeout: 30_000, maxRetries: 0 })" "$API" ||
  ! grep -Fq "OPENAI_REQUEST_OPTIONS," "$API" ||
  ! grep -Fq "assert.deepEqual(OPENAI_REQUEST_OPTIONS, { timeout: 30_000, maxRetries: 0 })" "$PARSER_TEST" ||
  ! grep -Fq "Object.isFrozen(OPENAI_REQUEST_OPTIONS)" "$PARSER_TEST"; then
  printf '%s\n' "OpenAI execute requests must keep the tested 30-second zero-retry boundary." >&2
  exit 1
fi

if ! grep -Fq "EXECUTE_RATE_LIMIT_MAX_REQUESTS = 10" "$API" ||
  ! grep -Fq "EXECUTE_RATE_LIMIT_WINDOW_MS = 60_000" "$API" ||
  ! grep -Fq "createFixedWindowRateLimiter" "$API" ||
  ! grep -Fq "enforceExecuteRateLimit" "$API" ||
  ! grep -Fq 'res.setHeader("Retry-After", String(rateLimit.retryAfterSeconds))' "$API" ||
  ! grep -Fq "res.status(429)" "$API"; then
  printf '%s\n' "Enabled execute POST attempts must keep the fixed-window request budget." >&2
  exit 1
fi

if ! grep -Fq "consumeCapacity(1_000)" "$PARSER_TEST" ||
  ! grep -Fq "consumeCapacity(60_000)" "$PARSER_TEST" ||
  ! grep -Fq "consumeCapacity(61_000)" "$PARSER_TEST" ||
  ! grep -Fq "consumeCapacity(500)" "$PARSER_TEST" ||
  ! grep -Fq "Number.POSITIVE_INFINITY" "$PARSER_TEST"; then
  printf '%s\n' "Execute tests must cover capacity, rejection, rollover, and clock recovery." >&2
  exit 1
fi

if ! awk '
  /if \(enforceExecuteRateLimit\(res\)\)/ { limiter = NR }
  /hasJsonContentType\(req.headers\["content-type"\]\)/ { content_type = NR }
  /normalizeExecuteBody\(req.body\)/ { body = NR }
  /normalizeChatRequest\(extractParameters\(body.code\)\)/ { params = NR }
  /const apiKey = normalizeOpenAIApiKey\(\)/ { api_key = NR }
  /new OpenAI/ { client = NR }
  END { exit !(content_type && body && params && api_key && limiter && client && content_type < body && body < params && params < api_key && api_key < limiter && limiter < client) }
' "$API" ||
  ! grep -Fq "enforceExecuteRateLimit(limitedResponse" "$PARSER_TEST" ||
  ! grep -Fq "assert.equal(limitedResponse.statusCode, 429)" "$PARSER_TEST" ||
  ! grep -Fq 'limitedResponse.headers["Retry-After"]' "$PARSER_TEST" ||
  ! grep -Fq "invalidContentTypeResponse.statusCode, 415" "$PARSER_TEST" ||
  ! grep -Fq "currentWindow = Date.now()" "$PARSER_TEST"; then
  printf '%s\n' "Execute capacity must apply after local validation and before provider setup." >&2
  exit 1
fi

if ! grep -Fq 'export function normalizeOpenAIApiKey(value: unknown = process.env.OPENAI_API_KEY)' "$API" || \
  ! grep -Fq 'return value.trim() || null' "$API" || \
  ! grep -Fq 'const openai = new OpenAI({ apiKey })' "$API" || \
  grep -Fq 'new OpenAI({ apiKey: process.env.OPENAI_API_KEY })' "$API" || \
  ! grep -Fq 'delete process.env.OPENAI_API_KEY' "$PARSER_TEST" || \
  ! grep -Fq 'normalizeOpenAIApiKey(), null' "$PARSER_TEST" || \
  ! grep -Fq 'normalizeOpenAIApiKey("   "), null' "$PARSER_TEST" || \
  ! grep -Fq 'normalizeOpenAIApiKey("  test-api-key  "), "test-api-key"' "$PARSER_TEST" || \
  ! grep -Fq 'blankApiKeyResponse.statusCode, 503' "$PARSER_TEST" || \
  ! grep -Fq 'error: "OPENAI_API_KEY is not configured"' "$PARSER_TEST"; then
  printf '%s\n' "OpenAI API key configuration must reject blank values before execute capacity or provider setup." >&2
  exit 1
fi

if [ ! -f "$NONBLANK_API_KEY_PLAN" ] || \
  ! grep -Fq 'status: completed' "$NONBLANK_API_KEY_PLAN" || \
  ! grep -Fq 'make check' "$NONBLANK_API_KEY_PLAN" || \
  ! grep -Fq 'hostile mutations' "$NONBLANK_API_KEY_PLAN"; then
  printf '%s\n' "Nonblank OpenAI API key plan must record completed verification." >&2
  exit 1
fi

if ! tr '\n' ' ' < "$README" | tr -s '[:space:]' ' ' | grep -Fq 'Whitespace-only OpenAI API keys are treated as missing before execute capacity is consumed' || \
  ! tr '\n' ' ' < "$ROOT_DIR/SECURITY.md" | tr -s '[:space:]' ' ' | grep -Fq 'Whitespace-only OpenAI API keys must be rejected before execute capacity or provider setup' || \
  ! grep -Fq 'Rejected whitespace-only OpenAI API keys before execute capacity consumption' "$ROOT_DIR/CHANGES.md" || \
  ! grep -Fq 'Reject blank OpenAI API keys before execute capacity consumption' "$VISION"; then
  printf '%s\n' "Nonblank OpenAI API key documentation is incomplete." >&2
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

if ! grep -Fq 'const configuredModelList = process.env.OPENAI_ALLOWED_MODELS;' "$API" || \
  ! grep -Fq 'if (configuredModelList === undefined)' "$API" || \
  ! grep -Fq 'return new Set(configuredModels.filter((model) => defaultAllowedModels.has(model)))' "$API" || \
  ! grep -Fq 'for (const emptyConfiguration of ["   ", " , , "])' "$PARSER_TEST"; then
  printf '%s\n' "Explicit empty model configuration must fail closed with parser coverage." >&2
  exit 1
fi

if [ ! -f "$EMPTY_MODEL_ALLOWLIST_PLAN" ] || \
  ! grep -Fq 'Status: Completed' "$EMPTY_MODEL_ALLOWLIST_PLAN" || \
  ! grep -Fq 'execute parser tests passed' "$EMPTY_MODEL_ALLOWLIST_PLAN" || \
  ! grep -Fq 'hostile mutations were rejected' "$EMPTY_MODEL_ALLOWLIST_PLAN" || \
  ! grep -Fq 'external working directory' "$EMPTY_MODEL_ALLOWLIST_PLAN"; then
  printf '%s\n' "Empty model allowlist plan must record completed verification." >&2
  exit 1
fi

if ! tr '\n' ' ' < "$README" | tr -s '[:space:]' ' ' | grep -Fq 'Explicitly blank or comma-only configuration allows no models' || \
  ! grep -Fq 'Explicitly empty model allowlists must fail closed' "$ROOT_DIR/SECURITY.md" || \
  ! grep -Fq 'Fail closed for explicitly empty model allowlists' "$VISION" || \
  ! grep -Fq 'Made explicitly empty model allowlists fail closed' "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Project guidance must document explicit empty model allowlist behavior." >&2
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

if [ "$(printf '%s\n' "$CONTENT_TYPE_HELPER" | grep -Fc 'if (typeof contentType !== "string") {')" -ne 1 ] ||
  ! grep -Fq 'hasJsonContentType(["text/plain", "application/json"]), false' "$PARSER_TEST" ||
  ! grep -Fq 'hasJsonContentType(["application/json", "application/json"]), false' "$PARSER_TEST" ||
  ! grep -Fq 'hasJsonContentType([]), false' "$PARSER_TEST"; then
  printf '%s\n' "Execute content-type validation must reject every multi-value header." >&2
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

if ! grep -Fq 'Authorization: `Bearer ${executeToken.trim()}`' "$EDITOR" ||
  ! grep -Fq 'type="password"' "$EDITOR" ||
  ! grep -Fq 'autoComplete="off"' "$EDITOR"; then
  printf '%s\n' "Editor must send a caller-supplied bearer token without persisting it." >&2
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

if ! grep -Fq "status: completed" "$NO_STORE_PLAN" ||
  ! grep -Fq "make check" "$NO_STORE_PLAN" ||
  ! grep -Fq "removing the response header failed" "$NO_STORE_PLAN" ||
  ! grep -Fq 'changing the policy to `no-cache` failed' "$NO_STORE_PLAN"; then
  printf '%s\n' "Execute API no-store plan must record completed verification." >&2
  exit 1
fi

if ! grep -Fq "Ten eligible" "$README" ||
  ! grep -Fq "process-local fixed-window budget" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "shared upstream enforcement" "$VISION" ||
  ! grep -Fq "Added a process-local fixed-window execute budget" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Project guidance must document the execute request budget and deployment boundary." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$EXECUTE_RATE_BUDGET_PLAN" ||
  ! grep -Fq "Node.js 20.19.5, 22.22.2, and 24.16.0" "$EXECUTE_RATE_BUDGET_PLAN" ||
  ! grep -Fq "hostile mutations were rejected" "$EXECUTE_RATE_BUDGET_PLAN" ||
  ! grep -Fq "no live OpenAI" "$EXECUTE_RATE_BUDGET_PLAN"; then
  printf '%s\n' "Execute fixed-window budget plan must record completed local verification." >&2
  exit 1
fi

if ! grep -Fq "Provider-eligible requests consume the process-local budget" "$README" ||
  ! grep -Fq "locally valid, configured requests consume capacity" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "Consume execute capacity only after local validation" "$VISION" ||
  ! grep -Fq "Moved execute capacity consumption after local validation" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Project guidance must document provider-eligible budget consumption." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$PROVIDER_ELIGIBLE_BUDGET_PLAN" ||
  ! grep -Fq "Node.js 20.19.5, 22.22.2, and 24.16.0" "$PROVIDER_ELIGIBLE_BUDGET_PLAN" ||
  ! grep -Fq "hostile mutations were rejected" "$PROVIDER_ELIGIBLE_BUDGET_PLAN" ||
  ! grep -Fq "No live OpenAI" "$PROVIDER_ELIGIBLE_BUDGET_PLAN"; then
  printf '%s\n' "Provider-eligible execute budget plan must record completed verification." >&2
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

if ! grep -Fq "no-store" "$README" ||
  ! grep -Fq "no-store" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "no-store" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "no-store" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Project guidance must document the execute API no-store boundary." >&2
  exit 1
fi

if ! grep -Fq "OPENAI_API_KEY" "$README" ||
  ! grep -Fq "OPENAI_ALLOWED_MODELS" "$README" ||
  ! grep -Fq "DOCS_EXECUTE_ENABLED" "$README" ||
  ! grep -Fq "EXECUTE_API_TOKEN" "$README" ||
  ! grep -Fq "Content-Type: application/json" "$README" ||
  ! grep -Fq "npm test" "$README" ||
  ! grep -Fq "make check" "$README" ||
  ! grep -Fq "GitHub Actions" "$README" ||
  ! grep -Fq "docs/plans/2026-06-10-ci-baseline.md" "$README"; then
  printf '%s\n' "README must document API key, execute token, model allow-list, JSON content type, npm test, and make check." >&2
  exit 1
fi

for auth_contract in \
  'normalizeExecuteApiToken' \
  'hasValidExecuteAuthorization' \
  'res.setHeader("WWW-Authenticate", "Bearer")' \
  'error: "Unauthorized"'; do
  if ! grep -Fq "$auth_contract" "$API"; then
    printf '%s\n' "Execute API must retain bearer authentication contract: $auth_contract" >&2
    exit 1
  fi
done

if grep -Eq 'create(Hash|Hmac)' "$API" ||
  grep -Eq 'provided(Token|Bytes|Digest)\.length.*expected(Token|Bytes|Digest)\.length' "$API" ||
  ! grep -Fq 'const MAX_EXECUTE_TOKEN_BYTES = 1024;' "$API" ||
  ! grep -Fq 'function hasWellFormedUnicode(value: string)' "$API" ||
  ! grep -Fq 'Buffer.alloc(MAX_EXECUTE_TOKEN_BYTES + 4)' "$API" ||
  ! grep -Fq 'timingSafeEqual(providedBuffer, expectedBuffer)' "$API"; then
  printf '%s\n' "Execute bearer authentication must compare bounded fixed-size buffers without hashing or a token-length short circuit." >&2
  exit 1
fi

for auth_test_contract in \
  'Execute API authentication is not configured' \
  'Bearer wrong-token' \
  'Bearer test-execute-token extra' \
  'unauthorizedResponse.statusCode, 401' \
  'authorizedResponse.statusCode, 400'; do
  if ! grep -Fq "$auth_test_contract" "$PARSER_TEST"; then
    printf '%s\n' "Execute parser tests must retain bearer authentication case: $auth_test_contract" >&2
    exit 1
  fi
done

for guidance_file in "$README" "$ROOT_DIR/SECURITY.md" "$VISION" "$ROOT_DIR/CHANGES.md"; do
  if ! grep -Fq 'EXECUTE_API_TOKEN' "$guidance_file"; then
    printf '%s\n' "Project guidance must document execute bearer authentication: $guidance_file" >&2
    exit 1
  fi
done

if ! grep -Fq "rejects multi-value Content-Type headers" "$README" ||
  ! grep -Fq "Ambiguous multi-value Content-Type headers" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "Reject ambiguous multi-value content types" "$VISION" ||
  ! grep -Fq "Rejected ambiguous multi-value Content-Type headers" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Project guidance must document the single content-type boundary." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$SINGLE_CONTENT_TYPE_PLAN" ||
  ! grep -Fq "make check" "$SINGLE_CONTENT_TYPE_PLAN" ||
  ! grep -Fq "hostile mutations were rejected" "$SINGLE_CONTENT_TYPE_PLAN" ||
  ! grep -Fq "no live OpenAI request" "$SINGLE_CONTENT_TYPE_PLAN"; then
  printf '%s\n' "Single JSON content-type plan must record completed verification." >&2
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

if ! grep -Fq 'content.trim().length === 0' "$API" ||
  ! grep -Fq 'for (const blankContent of ["", "   ", "\t\n", "\u00a0", "\ufeff"] as const)' "$PARSER_TEST" ||
  ! grep -Fq 'content: "  Keep this spacing.  "' "$PARSER_TEST"; then
  printf '%s\n' "Execute messages must reject whitespace-only content without rewriting accepted text." >&2
  exit 1
fi

if ! grep -Fq "Whitespace-only chat message content" "$README" ||
  ! grep -Fq "Whitespace-only execute message content" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "Reject whitespace-only chat message content" "$VISION" ||
  ! grep -Fq "Rejected whitespace-only execute message content" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Project guidance must document the nonblank message-content boundary." >&2
  exit 1
fi

for nonblank_message_contract in \
  "status: completed" \
  "## Status: Completed" \
  "## Verification Completed" \
  "hostile mutations were rejected"; do
  if ! grep -Fq "$nonblank_message_contract" "$NONBLANK_MESSAGE_PLAN"; then
    printf '%s\n' "Nonblank message-content plan must record completed evidence: $nonblank_message_contract" >&2
    exit 1
  fi
done

if ! grep -Fq 'function hasWellFormedUtf16(value: string)' "$API" ||
  ! grep -Fq 'value.charCodeAt(index)' "$API" ||
  ! grep -Fq 'index + 1 >= value.length' "$API" ||
  ! grep -Fq 'nextCodeUnit < 0xdc00 ||' "$API" ||
  ! grep -Fq 'nextCodeUnit > 0xdfff' "$API" ||
  ! grep -Fq '!hasWellFormedUtf16(content)' "$API"; then
  printf '%s\n' "Execute messages must reject lone UTF-16 surrogates." >&2
  exit 1
fi

if ! grep -Fq '"Broken \ud800 text"' "$PARSER_TEST" ||
  ! grep -Fq '"Broken \udfff text"' "$PARSER_TEST" ||
  ! grep -Fq '"Broken \ud800"' "$PARSER_TEST" ||
  ! grep -Fq 'content: "Launch \ud83d\ude80"' "$PARSER_TEST" ||
  ! grep -Fq 'const malformedUnicodeResponse = createTestResponse();' "$PARSER_TEST" ||
  ! grep -Fq 'assert.equal(malformedUnicodeResponse.statusCode, 400);' "$PARSER_TEST"; then
  printf '%s\n' "Execute parser tests must cover malformed and valid surrogate sequences before capacity." >&2
  exit 1
fi

unicode_guidance='Lone UTF-16 surrogates in execute message content are rejected before provider eligibility; valid surrogate pairs remain accepted unchanged.'
for guidance_file in "$README" "$ROOT_DIR/SECURITY.md" "$VISION" "$ROOT_DIR/CHANGES.md"; do
  if ! grep -Fq "$unicode_guidance" "$guidance_file"; then
    printf '%s\n' "Project guidance must document the execute message Unicode boundary." >&2
    exit 1
  fi
done

for message_unicode_contract in \
  "## Status: Completed" \
  "make check" \
  "isolated Unicode-integrity mutations were rejected" \
  "No live OpenAI request or deployed execute route"; do
  if ! grep -Fq "$message_unicode_contract" "$MESSAGE_UNICODE_PLAN"; then
    printf '%s\n' "Message Unicode-integrity plan must record completed evidence: $message_unicode_contract" >&2
    exit 1
  fi
done

if [ "$(grep -Fc 'hasWellFormedUtf16(value)' "$API")" -ne 1 ] ||
  [ "$(grep -Fc 'hasWellFormedUtf16(entry)' "$API")" -ne 1 ]; then
  printf '%s\n' "Scalar and array execute stop sequences must reject lone UTF-16 surrogates." >&2
  exit 1
fi

malformed_stop_fixture='for (const malformedStop of ["\ud800", "Broken \udfff stop", "Broken \ud800"] as const)'
if [ "$(grep -Fc "$malformed_stop_fixture" "$PARSER_TEST")" -ne 1 ] ||
  [ "$(grep -Fc 'stop: ["END", "Broken \ud800 stop"]' "$PARSER_TEST")" -ne 1 ] ||
  [ "$(grep -Fc 'stop: [" \t ", "Launch \ud83d\ude80"]' "$PARSER_TEST")" -ne 2 ]; then
  printf '%s\n' "Execute parser tests must cover malformed scalar/array stops and preserve valid stop Unicode unchanged." >&2
  exit 1
fi

stop_unicode_guidance='Lone UTF-16 surrogates in execute stop sequences are rejected; valid surrogate pairs and whitespace sequences remain accepted unchanged.'
for guidance_file in "$README" "$ROOT_DIR/SECURITY.md" "$VISION" "$ROOT_DIR/CHANGES.md"; do
  if ! grep -Fq "$stop_unicode_guidance" "$guidance_file"; then
    printf '%s\n' "Project guidance must document the execute stop Unicode boundary." >&2
    exit 1
  fi
done

for stop_unicode_contract in \
  "## Status: Completed" \
  "make check" \
  "isolated stop-Unicode mutations were rejected" \
  "No live OpenAI request or deployed execute route"; do
  if ! grep -Fq "$stop_unicode_contract" "$STOP_UNICODE_PLAN"; then
    printf '%s\n' "Stop Unicode-integrity plan must record completed evidence: $stop_unicode_contract" >&2
    exit 1
  fi
done

for content_type_parameter_source_contract in \
  'function readHttpToken(' \
  'function readHttpQuotedString(' \
  'let charsetSeen = false;' \
  'parameterName[0].toLowerCase() !== "charset"' \
  'parameterValue[0].toLowerCase() !== "utf-8"'; do
  if ! grep -Fq "$content_type_parameter_source_contract" "$API"; then
    printf '%s\n' "Execute Content-Type parameter parsing must keep contract: $content_type_parameter_source_contract" >&2
    exit 1
  fi
done

for content_type_parameter_test_contract in \
  'application/json ; Charset = "UTF-8"' \
  'application/json; charset=utf-8; charset=utf-8' \
  'application/json; charset=latin1' \
  'application/json; profile=test' \
  'invalidParameterizedContentTypeResponse.statusCode, 415'; do
  if ! grep -Fq "$content_type_parameter_test_contract" "$PARSER_TEST"; then
    printf '%s\n' "Execute parser tests must keep Content-Type parameter case: $content_type_parameter_test_contract" >&2
    exit 1
  fi
done

python3 - "$API" <<'PY'
from pathlib import Path
import sys

source = Path(sys.argv[1]).read_text(encoding="utf-8")
handler = source.split("export default async function handler(", 1)[1]
authentication = "if (!hasValidExecuteAuthorization(req.headers.authorization, executeApiToken)) {"
content_type = 'if (!hasJsonContentType(req.headers["content-type"])) {'
body = "const body = normalizeExecuteBody(req.body);"
capacity = "if (enforceExecuteRateLimit(res)) {"
if not all(token in handler for token in (authentication, content_type, body, capacity)):
    raise SystemExit("Execute handler must retain authentication, Content-Type, body, and capacity boundaries.")
if not handler.index(authentication) < handler.index(content_type) < handler.index(body) < handler.index(capacity):
    raise SystemExit("Execute authentication must pass before Content-Type, body, and capacity checks.")
PY

for guidance_file in "$README" "$ROOT_DIR/SECURITY.md" "$VISION" "$ROOT_DIR/CHANGES.md"; do
  if ! grep -Fq 'Execute JSON Content-Type parameters accept only one UTF-8 charset declaration' "$guidance_file" ||
    ! grep -Fq 'malformed, duplicate, unsupported, and unrelated parameters are rejected before' "$guidance_file"; then
    printf '%s\n' "Project guidance must document execute Content-Type parameter validation." >&2
    exit 1
  fi
done

for content_type_parameter_plan_contract in \
  "## Status: Completed" \
  "all focused parser tests" \
  "ESLint and TypeScript passed" \
  "reported zero vulnerabilities" \
  "Repository and external-directory \`make check\`" \
  "Eight isolated Content-Type mutations were rejected" \
  "b8de6991a8ee03d0fc3d57ed67eb8e910cb4b8c9" \
  'push run `27624231788`' \
  'pull-request run `27624249230`'; do
  if ! grep -Fq "$content_type_parameter_plan_contract" "$CONTENT_TYPE_PARAMETER_PLAN"; then
    printf '%s\n' "Content-Type parameter plan must record completed evidence: $content_type_parameter_plan_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "check: verify" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose make check as the repository verification wrapper." >&2
  exit 1
fi

npm --prefix "$ROOT_DIR" run test:parser

printf '%s\n' "docs-002 execute API baseline checks passed."
