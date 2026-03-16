# Global Preferences

## Environment
- Primary machine: macOS on Apple Silicon (arm64)
- Editor: Neovim
- Prefer cross-platform tools and approaches that work on both macOS and Linux (e.g., `uv` for Python projects, POSIX-compatible shell where possible)
- Some work happens inside Docker/Linux containers — don't assume macOS-only, but don't assume Linux-only either
- Confirm before running unfamiliar or destructive shell commands

## Workflow
- **Plan first.** Present a plan before any non-trivial code change and wait for approval. For obvious one-liners (typos, string changes), just do it.
- For non-trivial work, show data model / key structures before implementation.
- If something breaks mid-task: stop, re-plan, check in. Don't push forward.
- If the task is ambiguous, ask — don't guess.
- Read existing code and any project-level CLAUDE.md before touching anything.
- Match repo style — when unsure about a pattern, inspect the codebase, don't invent.
- Keep changes scoped to what was asked. No drive-by refactors.
- Never use `--no-verify` when committing.
- Commit messages: kernel style. Subject line is `subsystem: short description`, body explains *why* the change was made, not what. Wrap at 72 columns.
- Before committing: show the staged diff and proposed commit message for review. Don't commit until approved.

## Code Philosophy
- Minimal diffs: change only what's needed.
- Data structures first — model the problem, then write the functions.
- Build what's needed now, but design so it's easy to extend later. Don't implement speculative features, but don't paint yourself into a corner either.
- Prefer explicit over implicit; established over custom; extensible over clever.

## Error Handling
- Raise errors explicitly with full context (params, status, response body).
- Use specific error types — no catch-all handlers, no empty catch blocks.
- Fix root causes. No silent fallbacks unless explicitly asked.

## Testing
- If the project has test/lint commands, run them before marking done.
- Don't mark a task complete without verifying it works.
- Flag untested edge cases rather than ignoring them.

## Documentation
- Inline docstrings for functions and classes. Explain *why*, not *what*.
- Large concepts that span multiple modules get their own doc file (e.g., `docs/architecture.md`).
- One authoritative place per concept — no duplication. Update docs when you change behavior.

## Terminal
- Non-interactive commands: flags over prompts.
- `git --no-pager diff` or `git diff | cat` — never interactive pager.
- `rg` over `grep`.

## Self-Improvement
- After a correction that reflects a recurring pattern or category mistake: suggest a CLAUDE.md addition so it doesn't repeat.
- In an unfamiliar repo: check for a project CLAUDE.md first.
