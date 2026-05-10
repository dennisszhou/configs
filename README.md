# configs

# vimscript helpt
https://devhints.io/vimscript

## Codex

- `codex/install.sh` symlinks `codex/AGENTS.md` into `~/.codex/`
- User skills in `codex/skills/` are exposed under `~/.agents/skills/`
- Skills may be organized in nested repo directories, but `codex/install.sh`
  exposes each skill as a flat symlink at `~/.agents/skills/<skill-basename>`;
  skill directory basenames must be unique.
- Re-run `./configure.sh codex` after changing Codex instructions or user skills
- Preview direct installer changes with `sh codex/install.sh --dry-run`
- For tests, override target roots with `CODEX_HOME`, `AGENTS_HOME`, or
  `SKILLS_HOME` instead of writing to real home directories.
