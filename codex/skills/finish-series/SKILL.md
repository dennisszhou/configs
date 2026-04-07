---
name: finish-series
description: Close out the current approved execution series by updating the active docs/execution artifact to reflect what actually completed, what remains deferred, and what state is next. Use after implementation and review of a series are complete.
---

# Finish Series

Record truthful closeout for the current execution series.

This skill updates the active `docs/execution/...` artifact after implementation
and review are done. It does not redesign the plan or silently change the scope
of later series.

## When to use this
Use this skill when:
- the current approved execution series has been implemented
- verification for that series is complete
- any requested review of the implemented diff is complete
- the execution doc should now reflect what actually landed

Do not use this skill when:
- implementation of the current series is still in progress
- the series plan needs to be redesigned before closeout
- the user wants to plan commits rather than close out a completed series

## Goal
Update the active `docs/execution/...` doc so it truthfully records:
- the current series is finished
- the top-level execution state has advanced
- the completion state is accurate
- any deferred follow-up is explicit when one exists

## Process

1. Read the active execution doc
- Identify the current series, current top-level state, and completion block.

2. Read the implemented history
- Confirm the current series actually reached its planned checkpoint.
- Confirm whether any planned follow-up was deferred.

3. Update the execution doc truthfully
- Mark the current series `Approval: finished`.
- Update top-level `Status` when needed.
- Update top-level `Approval.current state` to reflect the new position.
- Update `Completion` when the full effort is done.
- Add or update `optional follow-up` only when there is a real deferred or
  completed follow-up to record.

4. Do not redesign
- Do not change later series boundaries unless the user explicitly asks for a
  re-plan.
- If later assumptions are now wrong, stop and ask for an execution-doc update
  rather than silently fixing them here.

## Output format

Closeout target
- ...

Completed series
- ...

Execution doc updates
- ...

Deferred follow-up
- Include this only when a real deferred follow-up exists.

Next state
- ...

## What this skill does not do
- It does not implement code.
- It does not review diffs.
- It does not replace `review-execution` when the execution plan itself changed.
- It does not silently redesign later work.
