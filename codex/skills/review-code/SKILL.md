---
name: review-code
description: Skeptically review an implementation diff against the approved design and commit contract. Use for semantic, optimization, migration, or other risky commits where an extra code-review gate is warranted.
---

# Review Code

Review the implemented diff as a skeptical reviewer, not as the author trying to
defend it.

This skill is for checking whether a risky or semantic change actually matches
the approved contract and whether its evidence is strong enough.

## When to use this
Use this skill when:
- a commit plan marks a step with `Review gate: code`
- a commit changes semantics, optimization behavior, reliability, or migration
  behavior
- the user explicitly requests skeptical code review

Do not use this skill for:
- routine preparatory commits with no meaningful semantic risk
- architecture design before implementation
- commit planning

## Review questions

Check these directly:
- Does the diff match the approved contract?
- Does it preserve the stated invariants?
- Is source-of-truth state still authoritative?
- Are tests high-signal and at the right layer?
- Are tests overfit to implementation details?
- Would one regression or integration test replace several brittle unit tests?
- Is there hidden semantic drift or scope creep?
- Are performance or reliability claims supported with real evidence?

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
- Identify the approved design or commit-plan promises relevant to this diff.

2. Check semantic alignment
- Compare the diff against the stated postconditions and invariant focus.

3. Check boundary discipline
- Look for hidden scope creep, unexpected API shifts, or quiet changes to source
  of truth.

4. Check evidence quality
- Decide whether the chosen tests or verification actually exercise the contract.
- Call out low-signal unit tests, mock-heavy tests, or missing regression proof.

5. Check claims
- Require concrete evidence for performance, reliability, or migration safety
  claims.

6. Return a verdict
- Findings, open questions, and residual risk.

## Output format

Findings
- Ordered by severity. Use `none` if there are no findings.

Open questions
- Use `none` if there are no material questions.

Residual risks
- ...

Verdict
- `acceptable`
- `acceptable with follow-up`
- `not ready`

## Review heuristics
- Prefer regression, functional, or integration proof when behavior is visible
  at a boundary.
- Prefer unit tests only for small, stable, logic-dense primitives.
- Flag abstractions introduced mainly to make unit testing easier.
- Flag heavy mocking when it hides the real failure mode.
- Flag large test volume when one or two better tests would prove more.

## What this skill does not do
- It does not redesign the feature from scratch.
- It does not produce a commit plan.
- It does not require review on every commit.
- It does not block on style nits when the real issue is correctness.
