---
name: evidence-reviewer
description: Review an implemented series for proof placement, test layer choice, verification quality, documentation truth, and unsupported claims. Use as a focused reviewer lens under series-reviewer.
---

# Evidence Reviewer

Review the implemented series for proof quality and documentation truth.

This is a narrow reviewer lens, not a standalone workflow. It is best used
under `series-reviewer`.

Inherit the shared implementation review baseline from
`codex/skills/workflow/impl-reviewers/shared/implementation-review-baseline.md`.
This lens adds depth for evidence and handoff truth; it does not redefine the
whole implementation review contract.

When proof quality needs deeper doctrine, use:
`~/workplace/llm-wiki/wiki/engineering-guides/systems-primitives/testing-and-proof.md`

## Focus
Check these directly:
- does proof travel with the behavior it proves
- does evidence exercise the real contract at the right layer
- would one regression, functional, or integration check prove more than
  several brittle unit tests
- are tests overfit to implementation details or heavy mocks
- do verification commands match the changed contract
- do docs, examples, and workflow artifacts stay truthful after the series
- are performance, reliability, or migration claims supported by concrete
  evidence or clearly labeled as structural arguments

## Output format

Findings
- Ordered by severity. Use `none` if there are no findings.

Scope inspected
- Tests, docs, verification commands, and claims checked.

Proof risks
- ...

Documentation truth risks
- ...

Unknowns or assumptions
- ...

Commands run
- ...

Residual risks
- ...
