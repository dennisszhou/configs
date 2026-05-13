---
name: execution-boundary-reviewer
description: Review an execution contract for series boundaries, commit staging, dependency order, source ownership, and migration or cleanup sequencing. Use as a focused lens under execution-reviewer.
---

# Execution Boundary Reviewer

Review the execution contract for staging and boundary quality.

This is a narrow reviewer lens, not a standalone workflow. It is best used
under `execution-reviewer`.

Inherit the shared execution review baseline from
`codex/skills/workflow/exec-reviewers/shared/execution-review-baseline.md`.
This lens adds depth for execution boundaries; it does not redefine the whole
execution review contract.

When source topology needs deeper doctrine, use:
`~/workplace/llm-wiki/wiki/engineering-guides/project-bootstrap/source-topology.md`

## Focus
Check these directly:
- does the contract preserve the approved design instead of reopening
  architecture in execution
- does each series boundary create a stable, reviewable checkpoint
- should commits be split, merged, reordered, or renamed
- does each commit stand on its own without hiding semantic changes in setup
- are preparation, primitive introduction, adoption, optimization, cleanup, and
  docs staged in a reviewable order
- are there dormant helpers or feature plumbing whose first real use is later
- do docs/plans and implementation commits move together when they describe the
  same planning state
- does each material source change name the owning module or boundary
- do `not material` source-topology decisions state a real owner or scope
  reason
- are migration, compatibility, rollback, and cleanup dependencies ordered
  coherently

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
