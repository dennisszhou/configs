# configs

Personal dotfiles and system configuration repo. Symlinks config files into `$HOME` rather than copying them.

## Structure

| Path | Purpose |
|---|---|
| `configure.sh` | Main install script — idempotent, symlinks files, installs packages & plugins |
| `setup.sh` | Bootstrap: runs `git submodule update --init` before anything else |
| `claude/` | All Claude Code config — CLAUDE.md, ECC manifest, install script |
| `claude/CLAUDE.md` | Global Claude Code instructions (symlinked to `~/.claude/CLAUDE.md`) |
| `claude/manifest.conf` | Which ECC agents/commands/skills/rules to enable |
| `claude/install.sh` | Symlinks Claude config + ECC items into `~/.claude/` |
| `codex/` | Generic Codex config — `~/.codex` files plus user skills, install script |
| `codex/AGENTS.md` | Global Codex instructions (symlinked to `~/.codex/AGENTS.md`) |
| `codex/install.sh` | Symlinks Codex config into `~/.codex/` and skills into `~/.agents/skills/` |
| `vendor/everything-claude-code/` | Git submodule → fork of `affaan-m/everything-claude-code` |
| `common/shrc` | Shared env vars (editor, history, FZF, PATH) sourced by all shells |
| `common/aliases` | Shell aliases shared across bash/zsh |
| `common/tmux` | tmux config (prefix `C-a`, vi keys, TPM plugins) |
| `common/gitconfig` | Git config (symlinked to `~/.gitconfig`) |
| `common/vimrc` | Vim config (symlinked to `~/.vimrc`) |
| `zsh/zshrc` | Zsh entry point — sources `os/mac` or `os/linux`, then `common/shrc`, aliases, functions |
| `zsh/zprofile` | Zsh login profile |
| `bash/bashrc` | Bash rc (Linux) |
| `bash/bash_profile` | Bash login profile (Linux) |
| `os/mac` | macOS-specific config (Homebrew PATH, LSCOLORS) |
| `os/linux` | Linux-specific config |
| `neovim/` | Git submodule → `dennisszhou/kickstart.nvim`, symlinked to `~/.config/nvim` |
| `iterm/` | iTerm2 color schemes |
| `kernel/` | Linux kernel `.config` files |
| `patches/` | One-off patches (e.g. neovim diff panel layout) |
| `templates/` | Templates for machine-local secrets (`~/.gitconfig.local`, `~/.shrc.local`) |
| `packages.list` | Package list with columns: `generic|mac(brew)|apt|dnf` |

## How `configure.sh` works

```
./configure.sh [all|packages|configs|plugins|claude|codex]
```

- **packages** — installs from `packages.list` using brew/apt/dnf
- **configs** — symlinks shell, vim, tmux, git, and neovim configs; copies local config templates if absent
- **plugins** — installs TPM (tmux), vim-plug, fzf shell integration
- **claude** — installs only Claude Code config into `~/.claude/`
- **codex** — installs only Codex config into `~/.codex/` and `~/.agents/skills/`
- **all** (default) — runs packages, base configs, local templates, and plugins

Pre-flight check: aborts if `neovim/` submodule is empty (run `./setup.sh` first).

## Local overrides (not committed)

- `~/.gitconfig.local` — git user identity and secrets (generated from template)
- `~/.shrc.local` — machine-specific env/PATH additions (sourced at end of `shrc`)

## tmux key bindings

- Prefix: `C-a`
- `E` — toggle pane synchronization
- `M`/`m` — mouse on/off
- `C-s` / `C-r` — save/restore session (tmux-resurrect, with confirmation prompt)
- Copy mode: vi keys, `v` begin-selection, `C-v` rectangle, `y` copy

## Neovim submodule

Fork of `kickstart.nvim`. Update with normal git submodule workflow; the hash is pinned in `.gitmodules`.
