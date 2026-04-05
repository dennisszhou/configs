---
name: correctness-reviewer
description: Review an implemented series for semantic drift, invariant violations, hidden behavior changes, and contract mismatches. Use as a focused reviewer lens under series-reviewer.
---

# Correctness Reviewer

Review the implemented series for correctness against the approved design and
series contract.

This is a narrow reviewer lens, not a standalone workflow. It is best used
under `series-reviewer`.

## Focus
Check these directly:
- does the implementation still match the approved contract
- are invariants preserved
- has source-of-truth state shifted silently
- are there hidden semantic changes or scope creep
- do the chosen tests actually prove the changed contract

## Output format

Findings
- Ordered by severity. Use `none` if there are no findings.

Contract mismatches
- ...

Invariant risks
- ...

Residual risks
- ...
