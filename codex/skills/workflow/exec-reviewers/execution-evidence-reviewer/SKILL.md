---
name: execution-evidence-reviewer
description: Review an execution contract for proof placement, verification quality, review gates, documentation truth, and unsupported claims. Use as a focused lens under execution-reviewer.
---

# Execution Evidence Reviewer

Review the execution contract for evidence and verification quality.

This is a narrow reviewer lens, not a standalone workflow. It is best used
under `execution-reviewer`.

Inherit the shared execution review baseline from
`codex/skills/workflow/exec-reviewers/shared/execution-review-baseline.md`.
This lens adds depth for proof, verification, and claims; it does not redefine
the whole execution review contract.

When proof quality needs deeper doctrine, use:
`~/workplace/llm-wiki/wiki/engineering-guides/systems-primitives/testing-and-proof.md`

## Focus
Check these directly:
- does proof travel with the behavior it proves
- does each commit's evidence target the real contract at the right layer
- are verification commands literal, available, and scoped to the risk
- are review gates placed on risky commits or series boundaries rather than
  copied everywhere as checklist metadata
- is the implementation review mode appropriate for the series risk
- are selected implementation-review lenses narrow enough for the stated risk
- does `parallel-deep` have explicit authorization for subagents
- are performance, reliability, migration, or concurrency claims backed by
  evidence or clearly marked as structural reasoning
- do durable docs, working artifacts, examples, and review instructions stay
  truthful at the commit where they become relevant
- are deferred follow-ups and untested edge cases represented in the owning
  artifact instead of only in chat

## Output format

Scope inspected
- ...

Blockers
- Use `none` if there are no blockers.

Non-blocking findings
- Ordered by risk. Use `none` if there are no findings.

Unknowns or assumptions
- Use `none` if there are no material unknowns.

Commands run
- List commands, or `none`.

Residual risk
- ...
