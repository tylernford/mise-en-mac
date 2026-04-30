#!/usr/bin/env bash
# Global npm packages to install after nvm/node setup
set -euo pipefail

packages=(
  @microsoft/inshellisense
)

echo "Installing global npm packages..."
for pkg in "${packages[@]}"; do
  if npm ls -g --depth=0 "$pkg" &>/dev/null; then
    echo "  ✓ $pkg already installed"
  else
    echo "  -> $pkg"
    npm install -g "$pkg"
  fi
done

echo "Done."
