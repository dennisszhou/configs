---
name: series-reviewer
description: Orchestrate a deeper implementation review by applying the shared review baseline through focused reviewer lenses, inline or with authorized parallel subagents. Use only when review-series is too coarse.
---

# Series Reviewer

Run a deeper implementation review when one `review-series` pass is likely too
coarse.

This skill is not the default review path. Use it after the implementation
review gate selects `deep-inline` or `parallel-deep`, or when `review-series`
finds that a single pass is too coarse for the implemented series.

Deep review is a review-depth choice, not a different standard. This skill must
satisfy the shared implementation review baseline at
`codex/skills/workflow/impl-reviewers/shared/implementation-review-baseline.md`.
Focused lenses may add depth, but they must not replace that baseline.

Apply `$workflow-house-rules`, especially `Parallel Review Is A Synthesis
Tool`, before using subagents.

## When to use this
Use this skill when:
- the implemented series spans multiple semantic areas or risk types
- the execution contract requests implementation review mode `deep-inline` or
  `parallel-deep`
- the change mixes correctness, structure, evidence, lifecycle, migration, or
  performance concerns
- one review pass would likely miss interactions between contracts and runtime
  behavior
- the user explicitly asks for subagents, parallel review, or reviewer lenses

Do not use this skill when:
- `review-series` is enough
- the change is small, local, or clearly low risk
- `parallel-deep` is requested but neither the user nor the approved execution
  contract authorizes subagents

## Goal
Produce one synthesized implementation review by applying the shared baseline
through the smallest useful set of focused lenses.

The default deep-review lens set is:
- `correctness-reviewer`
- `structure-reviewer`
- `evidence-reviewer`

Conditional lenses are:
- `runtime-reviewer` when lifecycle, background work, queueing, cancellation,
  shutdown, removal, concurrency, or public-status truth is in scope
- `performance-reviewer` when performance-sensitive behavior or claims are in
  scope

Use at most 2-4 lenses by default. Do not fan out just because the mechanism
exists.

## Review model

1. Identify review mode
- `deep-inline`: apply the selected lenses in the parent thread.
- `parallel-deep`: spawn read-only reviewer subagents for selected lenses.
- If no mode is supplied, use `deep-inline` unless the user explicitly asks for
  parallel review.

2. Start from the approved contract
- Restate the approved design, execution-series promises, per-commit review
  gates, and implementation diff scope.
- Load the shared implementation review baseline.

3. Select the narrowest useful lens set
- Always include `correctness-reviewer` for deep review.
- Include `structure-reviewer` when files, modules, imports, facades, adapters,
  or ownership boundaries changed materially.
- Include `evidence-reviewer` when tests, verification, docs truth, or claims
  need focused review.
- Include `runtime-reviewer` only when runtime/lifecycle risks are in scope.
- Include `performance-reviewer` only when hot paths, scale-sensitive behavior,
  or performance/reliability claims are in scope.

4. Prepare lens task packets
- Each lens task must state:
  - approved contract and diff scope
  - selected lens and focus
  - shared baseline path
  - relevant llm-wiki page, when known
  - output contract from `$workflow-house-rules`
- Reviewer subagents must be read-only unless the user explicitly assigns a
  worker implementation task, which this skill should not do.

5. Run inline or parallel review
- In `deep-inline`, apply each selected lens locally.
- In `parallel-deep`, spawn the selected reviewer lenses only when authorized by
  the user or approved execution contract.
- If a subagent report is vague, missing exact references, or conflicts with
  another report, inspect the relevant files in the parent thread before
  deciding the final verdict.

6. Check baseline coverage
- Map each baseline category to the parent review or selected lenses.
- If a baseline category is not covered, cover it in the parent thread before
  returning.

7. Synthesize, do not concatenate
- Deduplicate findings.
- Merge overlapping findings under the clearest statement of the risk.
- Preserve severity ordering.
- Decide one final verdict.

## Output format

Review mode
- `deep-inline` or `parallel-deep`

Findings
- Ordered by severity. Use `none` if there are no findings.

Lens summary
- correctness: summary
- structure: summary or `not selected`
- evidence: summary or `not selected`
- runtime: summary or `not selected`
- performance: summary or `not selected`

Baseline coverage
- contract alignment: covered by ...
- invariants/source of truth: covered by ...
- topology/ownership: covered by ...
- API/boundary drift: covered by ...
- proof quality: covered by ...
- docs truth: covered by ...
- claims and measurements: covered by ...
- residual risk/verdict: covered by parent

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
- Do not treat invocation of `series-reviewer` alone as authorization for
  subagents. Use subagents only for `parallel-deep` or an explicit user request
  for parallel review.
- Use the smallest reviewer set that matches the risk.
- Performance review is conditional, not default.
- This skill reviews the implemented series; it does not edit code or planning
  artifacts.

## What this skill does not do
- It does not replace `review-series` as the default.
- It does not redesign the feature.
- It does not produce a series plan.
- It does not justify reviewer fan-out for routine changes.
- It does not create project-scoped custom subagent configuration.
