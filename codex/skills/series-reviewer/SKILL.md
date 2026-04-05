---
name: series-reviewer
description: Orchestrate a deeper review of an implemented series by synthesizing focused reviewer lenses such as correctness, runtime, and performance. Use only for larger or riskier series where a single review pass is likely too coarse.
---

# Series Reviewer

Run a deeper review of an implemented series when one review pass is likely too
coarse.

This skill is not the default review path. Start with `review-series`. Use this
skill when the work is broad enough that separate review lenses will materially
improve the result.

Invocation of this skill counts as authorization to use the reviewer subagents
that it needs.

## When to use this
Use this skill when:
- the implemented series spans multiple semantic areas or risk types
- the change mixes correctness, lifecycle, and operational concerns
- one review pass would likely miss interactions between contracts and runtime
  behavior
- the user explicitly asks for subagents, parallel review, or reviewer lenses

Do not use this skill when:
- `review-series` is enough
- the change is small, local, or clearly low risk
- the user has not authorized subagents in this environment

## Goal
Produce one synthesized review by combining a small number of focused reviewer
lenses.

The default lens set is:
- `correctness-reviewer`
- `runtime-reviewer`
- `performance-reviewer` when performance-sensitive behavior or claims are in
  scope

Use the smallest set that matches the risk. Do not fan out just because the
mechanism exists.

## Review model

1. Start from the approved contract
- Restate the design and series-plan promises that matter.

2. Decide whether parallel lenses are warranted
- If the series is straightforward, prefer `review-series` instead.
- If it is broad or risky, use focused reviewer lenses.

3. Spawn the narrowest useful lens set when authorized
- `correctness-reviewer` for semantic drift, invariants, and hidden behavior
  changes
- `runtime-reviewer` for lifecycle, queueing, background work, cancellation,
  status truthfulness, and shutdown/removal behavior
- `performance-reviewer` for static performance risks, hot-path anti-patterns,
  and unsupported performance claims

4. Synthesize, do not concatenate
- Deduplicate findings.
- Merge overlapping findings under the clearest statement of the risk.
- Preserve severity ordering.

## Output format

Findings
- Ordered by severity. Use `none` if there are no findings.

Lens summary
- correctness: summary
- runtime: summary
- performance: summary

Open questions
- Use `none` if there are no material questions.

Residual risks
- ...

Verdict
- `acceptable`
- `acceptable with follow-up`
- `not ready`

## Constraints
- Keep one final review output.
- Do not produce competing reviewer conclusions.
- Treat invocation of `series-reviewer` as explicit authorization for the
  reviewer subagents it needs.
- Use the smallest reviewer set that matches the risk.

## What this skill does not do
- It does not replace `review-series` as the default.
- It does not redesign the feature.
- It does not produce a series plan.
- It does not justify reviewer fan-out for routine changes.
