#!/usr/bin/env bash
# Bootstrap dev tooling from scratch
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

log() { printf "\n\033[1;34m==>\033[0m %s\n" "$*"; }
logk() { printf "\033[1;32m  ✓\033[0m %s\n" "$*"; }
logw() { printf "\033[1;33m  ⚠\033[0m %s\n" "$*"; }
loge() { printf "\033[1;31m  ✗\033[0m %s\n" "$*" >&2; }

CURRENT_STEP="starting up"
trap 'loge "Failed during: $CURRENT_STEP (line $LINENO)"' ERR

CURRENT_STEP="priming sudo"
log "Caching sudo credentials to minimize prompts"
sudo -v
# Refresh sudo timestamp in the background; exit when this script does
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

CURRENT_STEP="checking Xcode Command Line Tools"
log "Checking for Xcode Command Line Tools"
if ! xcode-select -p &>/dev/null; then
  logw "Not installed. Triggering installer (a GUI dialog will appear)..."
  xcode-select --install &>/dev/null || true
  logw "Waiting for install to finish..."
  until xcode-select -p &>/dev/null; do
    sleep 10
  done
  logk "Installed."
else
  logk "Already installed."
fi

CURRENT_STEP="installing Homebrew"
log "Installing Homebrew"
if ! command -v brew &>/dev/null; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  logk "Already installed."
fi

CURRENT_STEP="installing Homebrew packages"
log "Installing Homebrew packages"
brew bundle --file="$DOTFILES_DIR/Brewfile"

CURRENT_STEP="installing oh-my-zsh"
log "Installing oh-my-zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  logk "Already installed."
fi

CURRENT_STEP="setting up fzf shell integration"
log "Setting up fzf shell integration"
if command -v fzf &>/dev/null; then
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
fi

CURRENT_STEP="setting up Node via fnm"
log "Setting up Node via fnm"
if command -v fnm &>/dev/null; then
  eval "$(fnm env)"
  fnm install --lts
  fnm use --lts
  fnm default "$(fnm current)"
  corepack enable
  corepack install --global pnpm@latest
  bash "$DOTFILES_DIR/npm-globals.sh"
else
  logw "fnm not found — install node manually, then run npm-globals.sh"
fi

CURRENT_STEP="setting up Ruby via rbenv"
log "Setting up Ruby via rbenv"
if command -v rbenv &>/dev/null; then
  eval "$(rbenv init - bash)"
  LATEST_RUBY=$(rbenv install -l 2>/dev/null | grep -E '^[[:space:]]*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
  if [ -z "$LATEST_RUBY" ]; then
    logw "Could not detect latest Ruby; skipping rbenv install"
  else
    rbenv install -s "$LATEST_RUBY"
    rbenv global "$LATEST_RUBY"
    logk "Ruby $LATEST_RUBY set as global default"
  fi
else
  logw "rbenv not found — skipping Ruby install"
fi

CURRENT_STEP="setting up Python via uv"
log "Setting up Python via uv"
if command -v uv &>/dev/null; then
  uv python install
  logk "Latest stable CPython installed via uv"
else
  logw "uv not found — skipping Python install"
fi

CURRENT_STEP="installing Claude Code"
log "Installing Claude Code"
if ! command -v claude &>/dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash
else
  logk "Already installed."
fi

CURRENT_STEP="authenticating with GitHub"
log "Authenticating with GitHub"
if command -v gh &>/dev/null; then
  if gh auth status &>/dev/null; then
    logk "Already authenticated."
  else
    gh auth login --git-protocol ssh --hostname github.com --web
  fi
else
  logw "gh not found — skipping GitHub auth"
fi

CURRENT_STEP="symlinking dotfiles"
log "Symlinking dotfiles"
link_file() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    logw "Backing up existing $dst -> ${dst}.backup"
    mv "$dst" "${dst}.backup"
  fi
  ln -sf "$src" "$dst"
  logk "$dst -> $src"
}

link_file "$DOTFILES_DIR/config/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/config/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/config/.gitignore_global" "$HOME/.gitignore_global"
link_file "$DOTFILES_DIR/config/.npmrc" "$HOME/.npmrc"

CURRENT_STEP="creating .zshrc.local stub"
log "Creating ~/.zshrc.local stub if missing"
if [ ! -f "$HOME/.zshrc.local" ]; then
  cat >"$HOME/.zshrc.local" <<'EOF'
# Machine-local zsh config — not tracked in this repo.
# Put host-specific PATH entries, work tokens, experimental tweaks here.
EOF
  logk "Created ~/.zshrc.local"
else
  logk "Already exists."
fi

CURRENT_STEP="applying macOS defaults"
log "Applying macOS defaults"
"$DOTFILES_DIR/defaults.sh"

log "Done. Open a new shell to pick up changes."
