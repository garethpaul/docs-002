#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
FIXTURES_DIR="$ROOT_DIR/scripts/fixtures/checkout-workflows"
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/docs-002-checkout-policy.XXXXXX")
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

run_fixture() {
  fixture=$1
  expected=$2
  case_dir="$TMP_DIR/$fixture"

  mkdir -p "$case_dir"
  tar -C "$ROOT_DIR" \
    --exclude=.git \
    --exclude=node_modules \
    --exclude=scripts/fixtures/checkout-workflows \
    -cf - . | tar -C "$case_dir" -xf -
  rm -rf "$case_dir/.github/workflows"
  mkdir -p "$case_dir/.github/workflows"
  cp "$FIXTURES_DIR/$fixture"/* "$case_dir/.github/workflows/"
  mkdir -p "$case_dir/test-bin"
  cat >"$case_dir/test-bin/npm" <<'EOF'
#!/usr/bin/env sh
exit 0
EOF
  chmod +x "$case_dir/test-bin/npm"

  if PATH="$case_dir/test-bin:$PATH" "$case_dir/scripts/check-baseline.sh" >"$case_dir/output.log" 2>&1; then
    actual=accept
  else
    actual=reject
  fi

  if [ "$actual" != "$expected" ]; then
    printf '%s\n' "checkout workflow fixture $fixture: expected $expected, got $actual" >&2
    cat "$case_dir/output.log" >&2
    return 1
  fi
}

run_fixture valid accept
for fixture in \
  true-decoy-env \
  true-decoy-comment \
  true-decoy-other-step \
  case-collision \
  duplicate-checkout \
  alias \
  tag \
  explicit-tag \
  alternate-workflow \
  false-safe-text \
  missing \
  quoted-false; do
  run_fixture "$fixture" reject
done

printf '%s\n' "checkout workflow policy fixtures passed."
