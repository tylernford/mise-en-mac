#!/usr/bin/env bash
# Show all .claude/settings.local.json files on this machine and their contents
set -euo pipefail

while IFS= read -r f; do
  echo "--- $f ---"
  cat "$f"
  echo ""
done < <(find "$HOME" -name "settings.local.json" -path "*/.claude/*" -not -path "*/node_modules/*" 2>/dev/null)
