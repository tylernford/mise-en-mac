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

# Trigger inshellisense first-run so it writes ~/.inshellisense/init/zsh/init.zsh
# (the npm install alone doesn't create the shell init file)
command -v is &>/dev/null && is --version &>/dev/null || true

echo "Done."
