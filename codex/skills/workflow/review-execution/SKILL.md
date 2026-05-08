---
name: review-execution
description: Skeptically review and lightly amend the execution contract produced by plan-series or an equivalent user-supplied execution plan, including response-only series plans, docs/execution artifacts, and current-series commit chains. Use after plan-series and before impl-series when execution review is required or requested, especially for durable, risky, multi-series, or boundary-sensitive work.
---

# Review Execution

Review the execution contract produced by `$plan-series`, or an equivalent
user-supplied execution plan, before implementation.

This skill is intentionally skeptical and constructive. Its job is not only to
ask whether the plan is coherent. It should also ask whether the execution
shape can be made more reviewable, safer, or better staged without changing the
approved product, roadmap, or design model.

When the review finds small non-structural improvements, apply them instead of
only reporting them. For durable `docs/execution/...` artifacts, edit the active
execution doc directly. For response-only plans, include the amended execution
contract in the review output. A ready review result still does not approve
implementation; it only makes the contract ready for the user to approve.

Apply the `AGENTS.md` house rules and `$workflow-house-rules` while reviewing
the execution contract. Prefer short references to rule names over repeating
shared policy text.

Do not turn this into design review. If the better execution shape requires a
different architecture, API shape, source of truth, migration strategy, or
rollout semantics, return `needs design revision` and send the work back to the
planning domain.

This review gate is not mandatory for every response-only plan. A small,
low-risk, one-series plan with clear verification may proceed by explicit user
approval without this skill. If `$plan-series` creates or materially revises a
`docs/execution/...` artifact, run this skill regardless of implementation
size. Durable execution docs, multi-series work, risky boundaries, unclear
verification, or material review gates should use this skill before
implementation.

## When to use this

Use this skill when:
- `$plan-series` has produced a response-only current-series plan
- `$plan-series` has created or revised a `docs/execution/...` artifact
- `$plan-series` has produced a current-series commit chain for a durable
  execution doc
- the execution contract is not clearly small and low-risk
- the user supplied an equivalent execution contract and wants to approve
  implementation
- the user wants to approve implementation after series planning
- the active execution doc changed materially after earlier implementation
- the next series boundary or commit chain needs review before continuing

Do not use this skill when:
- there is no candidate execution contract from `$plan-series` or an equivalent
  user-supplied execution plan
- the user wants design review before execution planning
- the user wants diff review of implemented code
- the user wants to change architecture rather than review execution staging

## Goal

Answer one question:

Is this execution contract the right implementation shape to start from?

The outcome must be one of:
- `ready for implementation`
- `needs series revision`
- `needs execution-doc revision`
- `needs design revision`

## Review Targets

For a response-only plan, review:
- the current-series commit chain
- commit boundaries, ordering, verification, review gates, and scope limits

For a durable `docs/execution/...` plan, review:
- the execution doc's series boundaries, checkpoints, approval state, and
  completion state
- the current-series commit chain produced by `$plan-series`
- whether the commit chain actually reaches the series checkpoint

For multi-series work, review whole-doc boundaries when the execution doc is
first created or materially changed. Later, review the current or next series
plus any doc state needed to know what is authorized.

## Review Lens

Check whether the contract can be improved before implementation:
- Should commits be split, merged, reordered, or renamed?
- Are docs/plans and implementation commits staged correctly?
- Are tests or proof in the commit that establishes the behavior?
- Does the plan satisfy the `AGENTS.md` house rules for docs and proof, and
  `$workflow-house-rules` for approval and finish boundaries?
- Does the commit chain preserve source/module ownership, or does it add
  substantial behavior to the nearest large file or crowded directory?
- Are `not material` source-topology decisions backed by a real owner/scope
  reason when source files or directories grow?
- Are review gates on the risky commits, not everywhere or nowhere?
- Are commit fields acting as decisions, or has the plan grown checklist-only
  metadata?
- Is cleanup placed where it reduces risk instead of being dumped at the end?
- Does each series boundary create a real stable checkpoint?
- Is a multi-series split justified, or is it arbitrary?
- Is a single series too large for review?
- Are there hidden dependency, migration, or rollback-ordering problems?
- Is `$plan-series` smuggling unresolved design back into execution?

This is a review, not a rewrite session. If the plan should change, describe the
smallest concrete revision that would make it ready. If the needed change is a
small non-structural amendment, make the amendment and report it.

## Minor Amendments

Make minor amendments during review when they are clearly beneficial and stay
inside the approved design and execution shape.

Allowed minor amendments include:
- tighten or literalize verification commands
- add or clarify `Not included`, precondition, postcondition, done-means, or
  checkpoint wording
- add an obvious missing review field to an already-risky commit
- add or clarify source-topology impact wording inside an existing commit
- clarify dependencies between existing commits or series
- rename a commit subject for accuracy without changing scope
- move proof wording into the commit that already establishes that behavior
- add a missing source-topology checkpoint or `Review: structures` field to a
  commit that materially grows source files or directories
- remove checklist-only fields when their information belongs in an existing
  decision field
- clarify approval or completion wording without changing approval state,
  current state, or finished state

Do not treat these as minor amendments:
- add, remove, split, fold, or reorder commits
- change the current series boundary or stable checkpoint
- change implementation scope, API shape, migration order, or design truth
- approve implementation or mark a series finished
- update unrelated plan or execution docs

When a needed improvement is not a minor amendment, return
`needs series revision`, `needs execution-doc revision`, or
`needs design revision` as appropriate.

## Process

1. Identify the review target
- State whether this is a response-only series review, execution-doc review,
  current-series review, or next-series review.

2. Restate the execution contract
- Summarize the goal, relevant planning inputs, execution-doc state when one
  exists, and current commit chain.

3. Check planning inputs
- Confirm the roadmap and design inputs are explicit enough for execution.
- Flag any place where execution assumes context that only exists in chat.

4. Check execution-doc state when present
- Is whole-doc approval distinct from per-series approval?
- Is the current state explicit enough to know what is authorized next?
- Are completion and deferred follow-up represented truthfully?

5. Check series boundaries
- Are series split at real milestone boundaries?
- Does each series have an explicit stable checkpoint and review focus?
- Do the boundaries preserve the approved design truth?
- Would a different split reduce risk or improve reviewability?

6. Check commit-chain boundaries
- Does each commit stand on its own?
- Are primitive, tests, adoption, optimization, docs, and cleanup staged in a
  reviewable order?
- Are narrow bugfixes keeping regression proof with the semantic fix?
- Are there dormant helpers or feature plumbing whose first real use is later?
- Are docs-only commits justified by a real multi-commit or checkpoint reason?
- Does each material source change name its owning module and avoid turning a
  broad file or crowded directory into the next dumping ground?
- Are `not material` topology decisions specific enough to review?
- Are `Evidence`, `Review`, and `Source topology` real decisions rather than
  labels copied into every commit?

7. Check verification and review gates
- Are verify commands literal and high-signal?
- Does the chosen proof target the real contract at the right layer?
- Are performance, migration, or reliability claims backed by evidence?
- Are `structures`, `code`, `perf`, and `migration` review gates placed where
  extra scrutiny is useful?

8. Decide the better execution shape
- If the current plan is already the best reasonable shape, say so.
- If it can be improved by minor amendment, apply the amendment and list what
  changed.
- If it needs a material change, list concrete changes such as split, merge,
  reorder, move proof, adjust gate, tighten verification, or revise execution
  doc.
- If the improvement would change the approved design, return
  `needs design revision` instead of patching over it in execution.

## Output Format

Review target
- ...

Review mode
- `response-only series review`
- `execution-doc + current-series review`
- `whole-doc execution review`
- `next-series execution review`

Findings
- Ordered by severity. Use `none` if there are no findings.

Better execution shape
- `none; current plan is good enough`
- or `minor amendments applied`
- or concrete changes:
  - split commit ...
  - fold commit ...
  - reorder commit ...
  - move proof ...
  - adjust review gate ...
  - revise execution doc ...

Planning input check
- ...

Execution doc check
- Use `not applicable` when there is no execution doc.

Series boundary check
- ...

Commit-chain check
- ...

Source topology check
- ...

Verification and review-gate check
- ...

Approval check
- State whether implementation approval can be recorded in chat only or whether
  a durable execution doc approval update is required before `$impl-series`.
- For durable execution docs, state the approval fields that must change before
  implementation starts.
- If approval fields are updated, leave them uncommitted until the first
  `$impl-series` commit. Do not create a standalone approval-only commit from
  this skill.

Minor amendments applied
- Use `none` if no amendments were applied.
- Otherwise list each file or response-only section changed and why.

Blocking issues
- Use `none` if there are no blockers.

Result
- `ready for implementation`
- `needs series revision`
- `needs execution-doc revision`
- `needs design revision`

Recommended next step
- ...

## Exit Criteria For Ready

Only return `ready for implementation` when:
- planning inputs are clear enough for the reviewed series
- any execution doc has coherent approval and completion state
- series boundaries and dependencies are explicit
- stable checkpoints, review focus, and done-means are concrete
- the current commit chain is atomic, ordered, independently correct, and
  reviewable
- source-topology impact is explicit for material source growth
- no material source growth relies on a vague or unsupported `not material`
  topology decision
- commit fields are limited to decisions that guide implementation, review, or
  verification
- verification proves the right contract at the right layer
- review gates match the real risk points
- no series silently smuggles unresolved architecture into execution
- no obvious split, merge, reorder, or proof-placement change would materially
  improve reviewability before implementation starts
- any small non-structural improvements found during review have already been
  applied or included in the amended response-only contract

## What This Skill Does Not Do

- It does not produce a commit stack.
- It does not write code.
- It does not review implemented diffs.
- It does not redesign the approved architecture.
- It does not approve implementation or mark a series finished.
- It does not paper over structural ambiguity with "implementation details".
