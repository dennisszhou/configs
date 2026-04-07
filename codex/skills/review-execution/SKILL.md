---
name: review-execution
description: Skeptically review a docs/execution artifact to decide whether the whole execution plan or the current execution series is coherent enough for implementation. Use after the execution doc exists and before implementation starts or continues.
---

# Review Execution

Review whether the proposed execution doc is coherent enough to implement.

This skill is intentionally skeptical. Its job is not to invent a new plan from
scratch. Its job is to test whether the execution boundaries, checkpoints, and
approval state are clear enough to implement without hidden ambiguity.

## When to use this
Use this skill when:
- a `docs/execution/...` doc already exists
- the user wants to review the whole execution doc before approving it
- the execution doc changed materially after earlier implementation
- the next execution series has a risky boundary that deserves another
  structure-focused review

Do not use this skill when:
- there is no execution artifact to review
- the user wants design review before execution planning
- the user wants diff review of implemented code
- the next series is straightforward and the execution doc has not changed

## Goal
Answer one question:

Is the execution doc coherent enough to implement?

The outcome must be one of:
- `ready for implementation`
- `needs design revision`

## Review lens

Review the target artifact against these points:
- whether the roadmap and design inputs are explicit enough
- whether the series boundaries match the approved design truth
- whether dependencies and stable checkpoints are explicit
- whether review focus and done-means are concrete enough to constrain planning
- whether approval and completion state are coherent
- whether the execution doc is strong enough to guide `$plan-series` without
  moving important truth back into chat

This is a review, not a redesign session. If the model is weak, say so directly
and point to the smallest revision needed.

## Process

1. Restate the execution model
- Summarize the ordered series, checkpoint boundaries, and approval state.

2. Check planning inputs
- Confirm roadmap context, when relevant, and design inputs are explicit.
- Flag any place where the execution doc assumes context that only exists in
  chat.

3. Check series boundaries
- Are the series split at real milestone boundaries?
- Does each series have an explicit stable checkpoint and review focus?
- Do the boundaries preserve the approved design truth?

4. Check approval and completion state
- Is whole-doc approval distinct from per-series approval?
- Is the current state explicit enough to know what is authorized next?
- Is completion or deferred follow-up represented truthfully?

5. Check planning usefulness
- Is the execution doc strong enough that `$plan-series` can decompose the
  current series without inventing its scope?
- Are `Done means` and `Not included` explicit enough to prevent scope creep?

6. Decide readiness
- If the doc is coherent, say `ready for implementation`.
- Otherwise say `needs design revision` and list the blocking issues.

## Output format

Review target
- ...

Review mode
- `whole-doc execution review` | `next-series execution review`

Findings
- ...

Planning input check
- ...

Series boundary check
- ...

Approval and completion check
- ...

Execution usefulness check
- ...

Blocking issues
- Use `none` if there are no blockers.

Execution doc state
- `Status: ...`
- `overall doc approved: yes | no`
- `current state: ...`

Result
- `ready for implementation` | `needs design revision`

Recommended next step
- ...

## Exit criteria for “ready”
Only return `ready for implementation` when:
- roadmap context and design inputs are clear enough for the series being
  reviewed
- series boundaries and dependencies are explicit
- stable checkpoints, review focus, and done-means are concrete enough to guide
  `$plan-series`
- whole-doc approval is clearly distinguished from per-series approval
- the current execution state is explicit enough to know what is authorized next
- no series silently smuggles unresolved architecture into execution

## What this skill does not do
- It does not produce a commit stack.
- It does not write code.
- It does not review implemented diffs.
- It does not paper over structural ambiguity with “implementation details”.
