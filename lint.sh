#!/usr/bin/env bash
# Lint and format-check shell scripts in this repo
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR"

SCRIPTS=()
while IFS= read -r f; do
  SCRIPTS+=("$f")
done < <(find . -type f -name '*.sh' -not -path './.git/*')

if [ ${#SCRIPTS[@]} -eq 0 ]; then
  echo "No shell scripts found."
  exit 0
fi

FIX=${FIX:-0}

echo "=== shellcheck ==="
shellcheck "${SCRIPTS[@]}"

echo ""
echo "=== shfmt ==="
SHFMT_FLAGS=(-i 2 -ci)
if [ "$FIX" = "1" ]; then
  shfmt "${SHFMT_FLAGS[@]}" -w "${SCRIPTS[@]}"
  echo "Formatted in place."
else
  shfmt "${SHFMT_FLAGS[@]}" -d "${SCRIPTS[@]}"
fi
