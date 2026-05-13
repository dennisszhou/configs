---
name: review-series
description: Skeptically review an implementation diff against the approved design and series contract. Use automatically after impl-series implements the current series and before any finish-series closeout, and for semantic, optimization, migration, or other risky commits where an extra code-review gate is warranted.
---

# Review Series

Review the implemented diff as a skeptical reviewer, not as the author trying to
defend it.

This skill is the compact baseline implementation review path. It checks
whether a risky or semantic change actually matches the approved contract and
whether its evidence is strong enough.

Apply the shared implementation review baseline at
`codex/skills/workflow/impl-reviewers/shared/implementation-review-baseline.md`.
For larger or riskier series, escalate to `series-reviewer` so the same
baseline can be reviewed through focused lenses.

Apply the `AGENTS.md` house rules when checking proof placement and
documentation truth. Apply `$workflow-house-rules` when checking finish-series
eligibility and whether execution history stayed truthful.

## When to use this
Use this skill when:
- `impl-series` has implemented the current approved execution series and needs
  its mandatory review before any finish-series closeout decision
- a series plan marks a step with `Review: code`
- a commit changes semantics, optimization behavior, reliability, or migration
  behavior
- the user explicitly requests skeptical code review

Do not use this skill for:
- routine preparatory commits with no meaningful semantic risk
- architecture design before implementation
- series planning

## Review questions

Cover the shared baseline compactly:
- contract alignment
- invariants and source of truth
- source topology and ownership
- API and boundary drift
- evidence and proof quality
- documentation truth
- claims and measurements
- residual risk and verdict

## Review stance

Be skeptical and concrete:
- findings first
- highest-severity issues first
- point to the specific contract or invariant being violated
- prefer a small number of real issues over noisy style commentary

If there are no findings, say so explicitly and note any residual risk or
testing gap.

## Process

1. Restate the target contract
- Identify the approved design or series-plan promises relevant to this diff.

2. Check semantic alignment
- Compare the diff against the stated postconditions and invariant focus.

3. Check boundary discipline
- Look for hidden scope creep, unexpected API shifts, or quiet changes to source
  of truth.
- Run the source-topology checkpoint for non-trivial work: "Did this change
  leave a file or directory as the obvious dumping ground for the next unrelated
  feature?"
- Treat a vague `not material` topology answer as a finding when files or
  directories grew materially.

4. Check evidence quality
- Decide whether the chosen tests or verification actually exercise the contract.
- Call out low-signal unit tests, mock-heavy tests, or missing regression proof.

5. Check claims
- Require concrete evidence for performance, reliability, or migration safety
  claims.

6. Decide whether deep review is needed
- If the series spans multiple risk types, broad source areas, runtime
  behavior, performance claims, migration risk, or enough material that one
  pass is likely too coarse, say that it should use `series-reviewer`.
- Do not silently run subagents from this skill.

7. Return a verdict
- Findings, open questions, and residual risk.
- If `series-reviewer` is needed, return `not ready` or `acceptable with
  follow-up` as appropriate and name the missing deep-review path.

## Output format

Findings
- Ordered by severity. Use `none` if there are no findings.

Open questions
- Use `none` if there are no material questions.

Source topology checkpoint
- Answer: "Did this change leave a file or directory as the obvious dumping
  ground for the next unrelated feature?"

Residual risks
- ...

Verdict
- `acceptable`
- `acceptable with follow-up`
- `not ready`

## Review heuristics
- Load relevant llm-wiki pages named by the shared baseline when the diff
  touches those primitive areas.
- Prefer regression, functional, or integration proof when behavior is visible
  at a boundary.
- Prefer unit tests only for small, stable, logic-dense primitives.
- Flag abstractions introduced mainly to make unit testing easier.
- Flag heavy mocking when it hides the real failure mode.
- Flag large test volume when one or two better tests would prove more.

## What this skill does not do
- It does not redesign the feature from scratch.
- It does not produce a series plan.
- It does not require a separate manual review stop on every commit.
- It does not block on style nits when the real issue is correctness.
- It does not silently escalate into `series-reviewer`.
