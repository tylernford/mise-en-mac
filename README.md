# mise-en-mac

## Setup on a new machine

```bash
git clone <repo-url> ~/mise-en-mac
cd ~/mise-en-mac
./install.sh
# Open a new shell
```

`install.sh`:

- Ensures Xcode Command Line Tools are installed
- Installs Homebrew if missing
- Runs Brewfile
- Installs oh-my-zsh
- Sets up fzf shell integration
- Installs Node via fnm
- Enables corepack + global pnpm
- Runs `npm-globals.sh` to install global npm packages
- Installs the latest Ruby via rbenv
- Installs the latest CPython via uv
- Installs Claude Code
- Runs `gh auth login` to authenticate with GitHub
- Symlinks `.zshrc` / `.gitconfig` / `.gitignore_global` / `.npmrc` into `$HOME`
- Creates a `~/.zshrc.local` stub for machine-local overrides if missing
- Runs `defaults.sh` to apply opinionated macOS preferences

## Repo layout

- `Brewfile` — packages installed via `brew bundle`
- `config/` — dotfiles symlinked into `$HOME` by `install.sh`
- `install.sh` — bootstrap entry point
- `npm-globals.sh` — Node globals installed after fnm sets up Node
- `lint.sh` — runs shellcheck + shfmt on this repo's shell scripts
- `defaults.sh` — applies macOS system preferences via `defaults write` (Finder, Dock, screenshots, key repeat, etc.)
- `audit.sh` — sanity-checks the host vs. what's in this repo
- `claude-audit.sh` — finds and prints all `.claude/settings.local.json` files under `$HOME`

## How it works

- **Node**: managed by fnm; auto-switches per project via `.nvmrc`.
- **Package managers**: corepack ships pnpm/yarn/npm; pinned per project via `package.json`'s `packageManager` field. `pnpm@latest` installed globally for ad-hoc use.
- **Linters/formatters**: biome, prettier, eslint, typescript installed per project as devDependencies. Nothing global.
- **`.npmrc`** (symlinked from `config/.npmrc`):
  - `save-exact=true` — exact versions on install
  - `engine-strict=true` — fail install on Node version mismatch
  - `fund=false` — silence funding messages
- **Postgres**: Postgres.app provides the server and CLI tools; `.zshrc` adds them to `$PATH`.
- **PHP**: runs inside ddev or Local by WP Engine. No host PHP.
- **Shell linting**: `lint.sh` runs shellcheck + shfmt on this repo's scripts.
- **macOS defaults**: `defaults.sh` applies Finder, Dock, screenshot, key repeat, Safari, and input tweaks.
- **Machine-local shell config**: `.zshrc` sources `~/.zshrc.local` if present (untracked, for per-machine overrides).
- **Per-project Node version**: `.nvmrc` in project root; fnm auto-switches on `cd`.
- **Per-project package manager**: `corepack use pnpm@latest` writes the version into `package.json`.

## Common commands

```bash
./install.sh              # bootstrap or re-sync
./defaults.sh             # apply macOS system preferences
./lint.sh                 # check shell scripts
FIX=1 ./lint.sh           # auto-format shell scripts
./audit.sh                # compare host install state to this repo
./claude-audit.sh         # list all project-local Claude settings
brew bundle cleanup       # see what's installed but not in Brewfile
```
