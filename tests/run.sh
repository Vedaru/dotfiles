#!/usr/bin/env bash
# Run the Neovim config test suite.
#
#   ./tests/run.sh              # all specs
#   ./tests/run.sh 02_session   # specs matching a substring
#
# Each spec runs in its own headless nvim with an isolated XDG_STATE_HOME, so
# tests never touch your real sessions or shada.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

NVIM="${NVIM:-nvim}"
FILTER="${1:-}"

if ! command -v "$NVIM" >/dev/null 2>&1; then
  echo "error: $NVIM not found" >&2
  exit 1
fi

specs=()
for spec in tests/spec/*_spec.lua; do
  [[ -f "$spec" ]] || continue
  if [[ -n "$FILTER" && "$spec" != *"$FILTER"* ]]; then
    continue
  fi
  specs+=("$spec")
done

if [[ ${#specs[@]} -eq 0 ]]; then
  echo "no specs matched '${FILTER}'" >&2
  exit 1
fi

total_pass=0
total_fail=0
failed=()

for spec in "${specs[@]}"; do
  echo
  echo "== $(basename "$spec")"
  state_dir="$(mktemp -d)"
  # shellcheck disable=SC2086
  output=$(XDG_STATE_HOME="$state_dir" "$NVIM" --headless \
    -c "luafile $spec" 2>&1)
  status=$?
  rm -rf "$state_dir"
  echo "$output"

  p=$(printf '%s\n' "$output" | sed -n 's/^-- \([0-9]\+\) passed.*/\1/p' | tail -1)
  f=$(printf '%s\n' "$output" | sed -n 's/^-- [0-9]\+ passed, \([0-9]\+\) failed.*/\1/p' | tail -1)
  total_pass=$((total_pass + ${p:-0}))
  total_fail=$((total_fail + ${f:-0}))

  if [[ $status -ne 0 ]]; then
    failed+=("$(basename "$spec")")
  fi
done

echo
echo "==============================================="
echo "  ${total_pass} passed, ${total_fail} failed"
if [[ ${#failed[@]} -gt 0 ]]; then
  echo "  failing specs: ${failed[*]}"
  exit 1
fi
echo "  all specs passed"
