---
name: execution-reviewer
description: Orchestrate a deeper execution-contract review by applying the shared execution review baseline inline or with authorized parallel subagents. Use only when review-execution is too coarse.
---

# Execution Reviewer

Run a deeper execution-contract review when one `review-execution` pass is
likely too coarse.

This skill is not the default execution-review path. Use it from
`review-execution` when a candidate contract has enough cross-commit,
multi-series, migration, evidence, topology, or review-gate risk that one
compact review is likely to miss interactions.

Deep review is a review-depth choice, not a different standard. This skill must
satisfy the shared execution review baseline at
`codex/skills/workflow/exec-reviewers/shared/execution-review-baseline.md`.
Focused lenses may add depth, but they must not replace that baseline.

Apply `$workflow-house-rules`, especially `Parallel Review Is A Synthesis
Tool`, before using subagents.

## When to use this
Use this skill when:
- the execution contract spans multiple series or a large current series
- commit boundaries, proof placement, verification, or review gates interact in
  non-obvious ways
- migration, compatibility, rollback, or cleanup order is part of the plan
- source-topology choices are material to the execution shape
- `review-execution` finds that a single pass is likely too coarse
- the user explicitly asks for deeper or parallel execution review

Do not use this skill when:
- ordinary `review-execution` is enough
- there is no candidate execution contract to review
- the issue is unresolved architecture, API shape, source of truth, or rollout
  semantics that should return to design review
- parallel review is requested but the user has not explicitly authorized
  subagents or parallel execution review

## Goal
Produce one synthesized execution-contract review by applying the shared
baseline through the smallest useful amount of extra depth.

The default deep-review lens set is:
- `execution-boundary-reviewer`
- `execution-evidence-reviewer`

Select one lens when the risk is clearly narrow. Use both when boundary,
ordering, proof, verification, and review-gate concerns interact. Do not add a
migration-specific lens until repeated use shows that boundary review is too
coarse.

This skill does not approve implementation by itself. Its verdict feeds back
into `review-execution`, which still returns `ready for implementation`,
`needs series revision`, `needs execution-doc revision`, or
`needs design revision`.

## Review model

1. Identify review mode
- `deep-inline`: apply the selected focus areas in the parent thread.
- `parallel-deep`: spawn read-only reviewer subagents for selected focus areas.
- If no mode is supplied, use `deep-inline` unless the user explicitly asks for
  parallel execution review.

2. Start from the candidate contract
- Restate the planning inputs, execution-doc state when present, current or
  next-series boundary, commit chain, verification, review gates, and stated
  `Not included` scope.
- Load the shared execution review baseline.

3. Select the narrowest useful focus set
- Cover every baseline category in the parent thread unless a focused lens is
  selected for that category.
- Select `execution-boundary-reviewer` for series boundaries, commit staging,
  source ownership, dependency ordering, migration, rollback, or cleanup risks.
- Select `execution-evidence-reviewer` for proof placement, verification,
  review-gate, documentation truth, or unsupported-claim risks.
- Do not fan out just because the mechanism exists.

4. Prepare focus task packets
- Each inline or parallel task must state:
  - candidate execution contract and planning inputs
  - selected focus and why it was selected
  - shared baseline path
  - relevant llm-wiki page, when known
  - output contract from `$workflow-house-rules`
- Reviewer subagents must be read-only. They may recommend amendments, but the
  parent review owns synthesis and the final verdict.

5. Run inline or parallel review
- In `deep-inline`, apply the selected focus areas locally.
- In `parallel-deep`, spawn selected reviewer subagents only when the user has
  explicitly authorized subagents or parallel execution review.
- If a subagent report is vague, missing exact references, or conflicts with
  another report, inspect the relevant artifact in the parent thread before
  deciding the final verdict.

6. Check baseline coverage
- Map each baseline category to the parent review or a selected focus area.
- If a baseline category is not covered, cover it in the parent thread before
  returning.

7. Synthesize, do not concatenate
- Deduplicate findings.
- Merge overlapping findings under the clearest statement of the risk.
- Preserve severity ordering.
- Decide one final verdict for `review-execution` to use.

## Output format

Review mode
- `deep-inline` or `parallel-deep`

Findings
- Ordered by severity. Use `none` if there are no findings.

Focus summary
- List selected focus areas and one-line outcomes.
- Use `none; baseline covered in parent review` when no focused lenses were
  selected.

Baseline coverage
- planning input and approval state: covered by ...
- design boundary preservation: covered by ...
- series boundaries and checkpoints: covered by ...
- commit atomicity and ordering: covered by ...
- proof placement and evidence shape: covered by ...
- verification and review gates: covered by ...
- source topology and ownership: covered by ...
- migration, rollback, and dependency ordering: covered by ...
- documentation truth: covered by ...
- residual risk and verdict: covered by parent

Open questions
- Use `none` if there are no material questions.

Residual risks
- ...

Verdict for review-execution
- `ready for implementation`
- `needs series revision`
- `needs execution-doc revision`
- `needs design revision`

## Constraints
- Keep one final review output.
- Do not produce competing reviewer conclusions.
- Do not treat invocation of `execution-reviewer` alone as authorization for
  subagents. Use subagents only after an explicit user request for subagents or
  parallel execution review.
- Use the smallest review depth that matches the risk.
- Do not redesign the feature or rewrite the execution contract.
- Do not approve implementation directly.

## What this skill does not do
- It does not replace `review-execution` as the required gate.
- It does not review implemented code; use `review-series` or `series-reviewer`
  for implementation diffs.
- It does not turn execution review into design review.
- It does not create project-scoped custom subagent configuration.
