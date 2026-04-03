# configs

# vimscript helpt
https://devhints.io/vimscript

## Codex Superpowers

This repo can install a curated subset of your `superpowers` fork for Codex from the `vendor/superpowers` submodule.

- `codex/install.sh` symlinks only `codex/AGENTS.md` into `~/.codex/`
- Curated skills are listed in `codex/superpowers.manifest`
- Installed skills are exposed under `~/.agents/skills/superpowers/`
- Re-run `./configure.sh codex` after changing the manifest or updating the submodule
- Check for upstream drift with `sh codex/check-superpowers-manifest.sh`
- Repo-managed Codex settings live in `codex/config.toml`
- `./configure.sh codex` reconciles the managed keys from `codex/config.toml` into `~/.codex/config.toml`
- The managed config currently includes `developer_instructions` and `[features].multi_agent = true`
- Sync is transactional: if an existing `~/.codex/config.toml` value conflicts with a managed key, the sync aborts without changing the file
