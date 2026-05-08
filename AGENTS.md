# AGENTS.md

Repository-local instructions for coding agents working in this configs repo.
This file supplements broader global defaults. Follow the nearest applicable
`AGENTS.md` first.

## Repo purpose
- This is a personal dotfiles and system configuration repo.
- The main behavior is symlink-based installation into `$HOME`, not copying.
- Treat it as an install/bootstrap repo, not as an application or library.

## Local reference material
- `~/workplace/llm-wiki` contains LLM-managed wikis for prior work, project
  lessons, engineering guides, raw evidence, and preferences from work we have
  done together.
- Treat it as helpful prior context. It does not replace the current repository,
  nearest instructions, source code, tests, or official docs.
- Start at `~/workplace/llm-wiki/wiki/index.md` when you need the root map.
- Check the wiki when the task asks for planning, structure, project history,
  engineering judgment, or reusable guidance, or when a quick lookup is likely
  to prevent rediscovering prior work. Skip it for narrow mechanical edits where
  the current repo already provides enough context.
- Useful entrypoints:
  - `wiki/engineering-guides/index.md` for the guide map.
  - `wiki/engineering-guides/project-bootstrap/` for repo shape, project
    direction, and source topology.
  - `wiki/engineering-guides/systems-primitives/` for config, CLI,
    observability, concurrency, caching, errors, tests/proof, lifecycle, and
    storage.
  - `wiki/engineering-guides/agent-tooling/` for skills, plugins, MCP servers,
    and reusable agent capabilities.
  - `wiki/projects/` for prior project-specific lessons.
- Use wiki guidance as starting points and review prompts. If it conflicts with
  the current repo, nearest `AGENTS.md`, source, tests, or official docs, prefer
  the current repo or official source and mention the mismatch when it matters.
- When the wiki repeatedly helps or gets in the way for a task type, suggest an
  update to these instructions or to the wiki routing pages.
- Do not modify `llm-wiki` while working in this repo unless explicitly asked.
- If importing external material into `llm-wiki` later, preserve its model:
  durable evidence belongs in `raw/`, synthesis belongs in `wiki/`.

## Important entrypoints
- `setup.sh` initializes git submodules before any other setup.
- `configure.sh` is the main installer. It supports:
  - `all`
  - `packages`
  - `configs`
  - `plugins`
- `claude/install.sh` manages Claude Code symlinks into `~/.claude/`.
- `codex/install.sh` manages Codex symlinks into `~/.codex/` and user skills
  into `~/.agents/skills/`.
- `packages.list` is the package source of truth for macOS/Linux installs.

## Structure that matters
- `common/` contains shared shell, git, tmux, vim, and helper config.
- `zsh/`, `bash/`, and `os/` contain shell entrypoints and OS-specific logic.
- `templates/` contains machine-local templates that should remain safe to copy
  without containing secrets.
- `neovim/` is a git submodule and should be treated as an external pinned tree
  unless the task is explicitly to update or modify that submodule.
- `vendor/everything-claude-code/` is a git submodule used by `claude/install.sh`.
- `codex/` contains the generic `~/.codex` payload plus user skills; keep both
  symlink-based so local repo edits reflect immediately.
- `codex/skills/workflow/` contains the Codex planning, execution, and review
  workflow skills.
- `codex/skills/workflow/reviewers/` contains reviewer lenses used by that
  workflow.
- `codex/skills/tools/` contains reusable Codex tool skills.
- `kernel/`, `patches/`, and `iterm/` are supporting config assets, not general
  code modules.

## Editing rules
- Prefer minimal diffs. This repo is mostly stable config and bootstrap logic.
- Preserve idempotence in installer scripts. Re-running setup should remain safe.
- Keep macOS and Linux behavior aligned unless the file is explicitly
  platform-specific.
- Do not hardcode user-specific secrets, machine-local paths, or identities into
  committed files.
- Preserve the local override model:
  - `~/.gitconfig.local`
  - `~/.shrc.local`
- Do not casually rewrite install flows, package-manager behavior, or symlink
  migration logic without checking how the change affects existing machines.
- When touching shell scripts, prefer portable shell/Bash patterns that match
  the file’s current interpreter.

## Submodules and generated state
- Do not treat submodule contents as ordinary local files unless the task
  explicitly targets them.
- Do not replace a submodule with copied files.
- If a task requires changing submodule pointers, keep that change isolated and
  call it out clearly.

## Verification
- For shell script changes, run the lightest meaningful verification first:
  - syntax checks such as `bash -n` or `sh -n`
  - targeted dry-run style inspection where possible
- Do not run destructive install/setup commands against `$HOME` unless the user
  explicitly wants that.
- If verification is limited because running the full installer would mutate the
  local machine, say so explicitly.

## Documentation source of truth
- The top-level `CLAUDE.md` is the main repo guide for structure and workflow.
- `claude/CLAUDE.md` adds Claude-specific workflow preferences.
- Keep this file repo-specific. Do not duplicate broad personal coding guidance
  unless it directly affects safe work in this repository.
