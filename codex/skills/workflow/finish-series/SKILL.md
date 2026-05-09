---
name: finish-series
description: Close out the current approved execution series by updating existing related workflow docs when they need truthful closeout state. Use only after implementation and review of a series are complete and the user explicitly approves marking that series finished; never create a new workflow doc just to record closeout unless the user asks for one.
---

# Finish Series

Record truthful closeout for the current execution series.

This skill updates existing related workflow docs after implementation and
review are done, but only when the user explicitly approves marking the series
finished. That approval may be given before implementation, such as "implement
this and then finish the series", or after the implementation and review
summary. It is a closeout step for docs that already exist and would otherwise
be stale. It does not create new workflow docs, redesign the plan, or silently
change the scope of later series.

Related workflow docs include existing `docs/products/...`,
`docs/roadmaps/...`, `docs/plans/...`, and `docs/execution/...` artifacts for
the effort. If no related workflow doc exists, do not create one just to
describe what landed. Use the implementation commits, review summary, and
commit messages as the closeout record unless the user explicitly asks for a
new durable artifact.

Apply the `AGENTS.md` house rules for documentation truth and
`$workflow-house-rules`, especially `Finish Requires Finish Approval`.

## When to use this
Use this skill when:
- the current approved execution series has been implemented
- verification for that series is complete
- any requested review of the implemented diff is complete
- the user has explicitly approved closeout for the current series, either
  before implementation or after review
- an existing related workflow doc should now reflect what actually landed, what
  remains deferred, or what state comes next

Do not use this skill when:
- implementation of the current series is still in progress
- the series plan needs to be redesigned before closeout
- the user has not explicitly approved marking the current series finished
- the user wants to plan commits rather than close out a completed series
- no related workflow doc exists or needs a truthful closeout update, unless the
  user explicitly asks for a new durable closeout artifact

## Goal
Update only existing related workflow docs so they truthfully record closeout
state:
- if an existing product, roadmap, or design doc has current-state wording that
  would become false after closeout, update that wording narrowly
- if an active `docs/execution/...` artifact exists, mark the current series
  finished because the user approved closeout
- advance top-level execution state only in existing execution docs
- keep completion state accurate in existing execution docs
- make any deferred follow-up explicit when an existing doc already tracks that
  state
- leave product, roadmap, and design future-state or historical context alone
  unless closeout makes it false

## Process

1. Find existing related docs
- Identify existing `docs/products/...`, `docs/roadmaps/...`, and
  `docs/plans/...` artifacts for the effort whose current-state wording would
  become false after closeout.
- Identify any active `docs/execution/...` artifact for the effort.
- If no related workflow doc exists or needs a truth update, report that no docs
  closeout is needed. Do not create a new workflow doc.

2. Read the implemented history
- Confirm the current series actually reached its planned checkpoint.
- Confirm whether any planned follow-up was deferred.

3. Update existing docs truthfully
- If an active execution doc exists, mark the current series
  `Approval: finished`.
- Update top-level `Status`, `Approval.current state`, and `Completion` only in
  existing execution docs that already track those fields.
- Add or update `optional follow-up` only when an existing doc already tracks
  follow-up state and there is a real deferred or completed follow-up to record.
- Update existing product, roadmap, or design docs only when closeout would
  otherwise make their current-state wording false.
- Keep any resulting commit docs-only. Do not mix code changes into
  `$finish-series`.

4. Do not redesign
- Do not change later series boundaries unless the user explicitly asks for a
  re-plan.
- If later product, roadmap, design, or execution assumptions are now wrong,
  stop and ask for the appropriate workflow-doc update rather than silently
  fixing them here.
- Do not manufacture a new workflow doc for narrative closeout. The commit
  message, implementation summary, and review summary are the right place to
  describe what landed when no durable workflow artifact already exists.

## Output format

Closeout target
- ...

Completed series
- ...

Workflow doc updates
- List existing product, roadmap, design, and execution docs updated.
- Use `not applicable` when no existing workflow doc needed a closeout update.

Deferred follow-up
- Include this only when a real deferred follow-up exists.

Next state
- ...

## What this skill does not do
- It does not implement code.
- It does not review diffs.
- It does not replace `review-execution` when the execution plan itself changed.
- It does not silently redesign later work.
- It does not create new product, roadmap, design, or execution docs unless the
  user explicitly asks for one.
- It does not include code changes in the closeout commit.
