#!/usr/bin/env bash
# Audit installed dev tooling against tracked state
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Brew leaves (top-level formulae) ==="
brew leaves
echo ""

echo "=== Leaves not in Brewfile ==="
comm -23 <(brew leaves | awk -F/ '{print $NF}' | sort) <(grep -E '^brew "' "$DOTFILES_DIR/Brewfile" | sed -E 's/^brew "([^"]+)".*/\1/' | awk -F/ '{print $NF}' | sort)
echo ""

echo "=== Brew casks ==="
brew list --cask
echo ""

echo "=== Casks not in Brewfile ==="
comm -23 <(brew list --cask | sort) <(grep -E '^cask "' "$DOTFILES_DIR/Brewfile" | sed -E 's/^cask "([^"]+)".*/\1/' | sort)
echo ""

echo "=== Untracked brew packages ==="
brew bundle cleanup --file="$DOTFILES_DIR/Brewfile" 2>/dev/null || true
echo ""

echo "=== Missing brew packages (in Brewfile but not installed) ==="
brew bundle check --file="$DOTFILES_DIR/Brewfile" --verbose 2>/dev/null || true
echo ""

echo "=== Installed Node versions (fnm) ==="
fnm list 2>/dev/null || true
echo ""

echo "=== Global npm packages ==="
npm ls -g --depth=0 2>/dev/null || true
echo ""

echo "=== Global pnpm packages ==="
pnpm ls -g --depth=0 2>/dev/null || true
echo ""

echo "=== uv tools ==="
uv tool list 2>/dev/null || true
echo ""

echo "=== Orphaned brew dependencies ==="
brew autoremove --dry-run 2>/dev/null || true
echo ""

echo "=== Brew cleanup (dry run) ==="
brew cleanup --dry-run 2>/dev/null | tail -5
echo "(run 'brew cleanup' to reclaim space)"
