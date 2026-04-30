# Homebrew (Apple Silicon: /opt/homebrew, Intel: /usr/local)
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# PATH
export PATH="$HOME/.local/bin:/usr/local/sbin:$PATH"

# Postgres.app CLI tools (psql, pg_dump, etc.)
export PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="agnoster"

# Hide "user@hostname" in prompt
DEFAULT_USER="$USER"

# Plugins
plugins=(git)

[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# fnm (Node version manager) — auto-switches on cd via .nvmrc
command -v fnm &>/dev/null && eval "$(fnm env --use-on-cd)"

# rbenv
command -v rbenv &>/dev/null && eval "$(rbenv init - zsh)"

# fzf (key bindings + completion)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Inshellisense (IDE-style shell autocomplete — must be last before machine-local)
command -v is &>/dev/null && eval "$(is init zsh)"

# Machine-local overrides (not tracked in dotfiles repo).
# Put host-specific PATH entries, work tokens, experimental tweaks in ~/.zshrc.local.
# install.sh creates an empty stub on a fresh machine.
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
