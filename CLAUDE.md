# CLAUDE.md

Guidance for Claude when editing this repo.

## Purpose & invariants

- This repo bootstraps a fresh Mac into the dev environment I actually use.
- **Brewfile = desired state for a fresh machine, not a snapshot of the current host.** If something is installed locally but not in the Brewfile, that's deliberate. Don't reflexively add drift.
- Host PHP is never installed. PHP runs inside ddev or Local by WP Engine.
- No global linters/formatters (biome, prettier, eslint, typescript). They live as project devDependencies.
- `install.sh` must remain idempotent — safe to re-run on an already-bootstrapped machine.

## Editing conventions

- After editing any shell script, run `./lint.sh`. Use `FIX=1 ./lint.sh` to auto-format.
- New CLI tools belong in `Brewfile`, not as ad-hoc `brew install` calls inside `install.sh`.
- New macOS preference tweaks belong in `defaults.sh`, not `install.sh`.
- New global npm packages belong in `npm-globals.sh`.
- New dotfiles belong in `config/` and get symlinked into `$HOME` by `install.sh`.

## File map

- `Brewfile` — brew packages
- `config/` — dotfiles symlinked into `$HOME`
- `install.sh` — bootstrap entry point (idempotent)
- `defaults.sh` — macOS system preferences
- `npm-globals.sh` — global npm packages
- `lint.sh` — shellcheck + shfmt
- `audit.sh` — host vs. repo sanity check
- `claude-audit.sh` — lists project-local Claude settings

## Don't

- Don't add explanatory prose or rationale to README — keep it terse and list-shaped.
- Don't mirror current host state into Brewfile without being asked.
- Don't add machine-specific config to the tracked `.zshrc` — that goes in `~/.zshrc.local` (untracked).
- Don't introduce global tool installs to replace the per-project pattern (corepack, project devDependencies).
