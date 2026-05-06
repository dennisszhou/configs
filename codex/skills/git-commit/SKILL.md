---
name: git-commit
description: Create, amend, reword, squash, or fixup git commits with staged changes using `.tmp` commit-message files and `git commit -F`. Use when Codex is about to make or rewrite a commit, prepare a commit message, enforce 50/72 commit formatting, or avoid unsafe `git commit -m` usage.
---

# Git Commit

## Overview

Use this skill any time Codex creates or rewrites a git commit. The goal is to
make commit-message mechanics boring and repeatable: stage the intended diff,
write a real message file under `.tmp/`, commit with `git commit -F`, and delete
the temporary file after the commit succeeds.

## Rules

- Never use `git commit -m`, including multiple `-m` flags.
- Never use `--no-verify`.
- Never add assistant attribution trailers unless the user explicitly asks.
- Use `.tmp/commit-message-<short-topic>.txt` for the message file.
- Use `git commit -F <message-file>` for new commits.
- Use `git commit --amend -F <message-file>` when amending.
- Use file-based message paths for reword, squash, and fixup rewrites whenever
  the rewrite command allows it.
- Delete the `.tmp` message file after the commit or rewrite succeeds.
- If the commit fails, keep the message file until the failure is understood or
  the user asks to discard it.

## Message Shape

Default to the ideal 50/72 rule unless the repository has a more specific
convention:

- subject line first, ideally no more than 50 characters
- blank line after the subject
- body lines wrapped at about 72 columns

The body must explain why the change exists, not only what changed. Write
cohesive prose instead of isolated one-sentence paragraphs. The first body
paragraph should explain the problem, motivation, or constraint that makes the
change necessary. Later paragraphs may group rationale, tradeoffs,
compatibility notes, risks, validation, or intentionally deferred work.

## Workflow

1. Check the intended staged diff:

   ```bash
   git diff --cached --stat
   git diff --cached
   ```

   If unexpected files are staged, stop and fix the staging before committing.

2. Create `.tmp` and write a message file:

   ```bash
   mkdir -p .tmp
   $EDITOR .tmp/commit-message-<short-topic>.txt
   ```

   If editing non-interactively, write the file with actual newlines, not
   escaped `\n` sequences.

3. Preview the message before committing:

   ```bash
   sed -n '1,80p' .tmp/commit-message-<short-topic>.txt
   awk '{ print length, $0 }' .tmp/commit-message-<short-topic>.txt
   ```

   Fix overlong subject or body lines before committing. The preview must show
   real wrapped lines and no literal `\n` sequences.

4. Commit from the file:

   ```bash
   git commit -F .tmp/commit-message-<short-topic>.txt
   ```

   For amend:

   ```bash
   git commit --amend -F .tmp/commit-message-<short-topic>.txt
   ```

5. Delete the message file after a successful commit:

   ```bash
   rm .tmp/commit-message-<short-topic>.txt
   ```

6. Verify the resulting commit when useful:

   ```bash
   git show --stat --format=fuller --no-ext-diff HEAD
   ```

## Shared History

Before amending, rewording, squashing, or fixup-folding commits, confirm the
history is local/private or the user has explicitly approved rewriting shared
history. Do not rewrite pushed or shared history by assumption.
