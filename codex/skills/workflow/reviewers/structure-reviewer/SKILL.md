---
name: structure-reviewer
description: Review an implemented series for source topology, ownership boundaries, facade leakage, adapter containment, and dumping-ground risk. Use as a focused reviewer lens under series-reviewer.
---

# Structure Reviewer

Review the implemented series for source/module topology and ownership
discipline.

This is a narrow reviewer lens, not a standalone workflow. It is best used
under `series-reviewer`.

Inherit the shared implementation review baseline from
`codex/skills/workflow/reviewers/shared/implementation-review-baseline.md`.
This lens adds depth for structure and topology; it does not redefine the whole
implementation review contract.

When source topology needs deeper doctrine, use:
`~/workplace/llm-wiki/wiki/engineering-guides/project-bootstrap/source-topology.md`

## Focus
Check these directly:
- did substantial behavior land in the named owning module
- did any file or directory become the obvious dumping ground for the next
  unrelated feature
- are edge adapter types contained at boundaries
- do internal imports use owning modules rather than root facades
- are facade files preserving compatibility instead of becoming ownership
  centers
- do source-topology `not material` decisions remain specific and true after
  the diff

## Output format

Findings
- Ordered by severity. Use `none` if there are no findings.

Scope inspected
- Files, directories, and import surfaces checked.

Topology risks
- ...

Boundary leaks
- ...

Unknowns or assumptions
- ...

Commands run
- ...

Residual risks
- ...
