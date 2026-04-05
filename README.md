# configs

# vimscript helpt
https://devhints.io/vimscript

## Codex

- `codex/install.sh` symlinks `codex/AGENTS.md` into `~/.codex/`
- User skills in `codex/skills/` are exposed under `~/.agents/skills/`
- Re-run `./configure.sh codex` after changing Codex config or user skills
- Repo-managed Codex settings live in `codex/config.toml`
- `./configure.sh codex` reconciles the managed keys from `codex/config.toml` into `~/.codex/config.toml`
- The managed config currently includes `developer_instructions` and `[features].multi_agent = true`
- Sync is transactional: if an existing `~/.codex/config.toml` value conflicts with a managed key, the sync aborts without changing the file
