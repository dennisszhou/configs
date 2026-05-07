# Codex Workflow Index

This file is a human-facing index for the local Codex workflow. It is not
installed by `codex/install.sh`, and it is not a source of truth for workflow
policy.

Authoritative sources:
- `codex/AGENTS.md` defines the always-loaded baseline behavior.
- The house rules in `codex/AGENTS.md` define always-loaded docs, proof,
  commit-path, and source-ownership policy.
- `$workflow-house-rules` defines workflow-specific approval, series, planning
  artifact, finish, and history policy.
- `$product`, `$roadmap`, `$design`, and `$review-plan` own product and
  architecture planning.
- `$plan-series` and `$review-execution` own execution planning.
- `$impl-series`, `$review-series`, `$polish-series`, and `$finish-series` own
  implementation, review, local-history cleanup, and closeout.
- `$git-commit` owns commit-message mechanics.

When workflow behavior changes, update the owning skill first. Keep this file
as a short map so it does not become a second copy of the workflow rules.
