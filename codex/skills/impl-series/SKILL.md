---
name: impl-series
description: Execute an approved plan-series stack by implementing, verifying, and committing each planned step in order. Use when the user says to execute the series plan, start implementing, resume the stack, or continue an already approved staged implementation.
---

# Impl Series

Execute an approved current execution series one commit at a time. The git
history is the audit trail. Keep going until you hit a real question, a
failure, the current series is complete, or the full plan is complete.

During execution, preserve truthful working history. Do not try to polish the
series while the work is still moving. History cleanup belongs later, if
needed, to `$polish-series`.

## When to use this
Use this skill when:
- the user has already approved a series plan
- the user explicitly asks to execute that plan
- the user asks to continue or resume an in-progress commit stack

If there is no approved plan, stop and ask the user to run or approve
`$plan-series` first.

Do not use this skill while native plan mode is active. Execution begins after
design work and `$review-plan` are finished.

## Approval model
Invocation of this skill counts as authorization to execute the approved
current execution series sequentially.

Do not treat approval of a large execution artifact as permission to execute all
later series blindly when they depend on later checkpoints, review, or revised
conditions.

Do not stop between commits to ask “should I continue?” Stop only when:
- verification fails and the fix would go out of scope
- the plan no longer matches reality
- a meaningful design decision is required
- the worktree is unexpectedly dirty
- the current approved series is complete
- the full approved plan is complete

If the approved plan contains selective review gates such as `code`, `perf`, or
`migration`, honor them at the planned points instead of treating every commit
as a mandatory review stop.

If there is an approved active `docs/plans/...` design doc for the task and it
is not yet committed on the execution branch, that docs/plans commit becomes
Commit 1 before any implementation commit.

## Core rules

1. Commit after each step
- Every planned commit gets implemented, verified, and committed before moving
  to the next.
- Do not leave completed planned work uncommitted.

2. Never bundle commits
- Each planned commit becomes a separate git commit.
- Do not combine adjacent commits because they seem small.
- Do not split a planned commit into multiple commits unless the plan is amended.

Initial docs/plans anchoring is the one allowed extra commit outside the
numbered implementation plan when needed. It establishes the approved plan as
the starting point for execution history.

3. Respect the contract
- Stay within the planned file list unless a minor obvious expansion is needed
  for correctness, such as a missing import or small test fixture update.
- Respect the “Not included” list.
- Do not smuggle future work into the current commit.
- Do not casually reopen architecture once design and `$review-plan` are
  approved. Stop only if the approved model no longer fits reality.

4. Keep progress recoverable
- Use git history as the source of truth.
- Resume from the first unimplemented commit when continuing later.

5. Separate truthful history from polished history
- During execution, prefer truthful commits over tidy ones.
- Later docs/plans or docs/series update commits are acceptable when the plan
  changes.
- Do not prematurely rewrite or squash history during active execution.
- Final cleanup belongs to `$polish-series`, not this skill.

## Inputs
This skill expects:
- an approved series plan from `$plan-series`
- or an equivalent numbered series plan supplied by the user
- and optionally:
  - an active approved `docs/plans/...` design doc for the task
  - a `docs/series/...` execution doc when durable execution planning is needed

When a `docs/series/...` execution doc exists, treat it as the execution source
of truth. Do not fall back to chat output for execution state unless the plan
was intentionally response-only.

Each commit entry should include:
- subject line
- type
- invariant focus
- test level
- review gate
- files
- preconditions
- postconditions
- verify commands
- not-included list

The user may optionally specify where to start:
- start from the first unimplemented commit
- start from commit N
- start from series N

## Series-boundary rules
If the approved execution plan contains multiple series:
- implement only the current approved series
- stop when that series reaches its stable checkpoint unless later continuation
  is already explicitly approved
- re-check the next series against the approved design and execution artifact
  before continuing
- update the execution artifact before continuing if earlier implementation
  changes later assumptions

If a durable execution artifact is required by the workflow and does not exist,
stop and ask for the series plan to be recorded before implementation begins.

## Plan amendment rules
Treat deviations from the approved plan in three buckets:

1. Minor execution details
- Small mechanically required edits that do not change scope, sequencing, or
  intent may proceed without plan amendment.
- Note them briefly in progress reporting when useful.

2. Local plan amendments
- If an extra file must change, a verify command must change, or one planned
  commit should be split for correctness or reviewability, stop and propose a
  local plan amendment before continuing.
- Update the active design doc or execution artifact as needed, then continue
  after approval if the workflow calls for it.

3. Structural mismatches
- If dependency order, API shape, migration strategy, or overall sequencing is
  wrong, stop and re-plan before continuing.
- Return to design or `$review-plan` when needed. Do not improvise around
  a stale design.

The approved plan remains the source of truth unless explicitly amended.

When a design plan doc exists for the task:
- treat the current active design doc as the only design plan doc eligible for
  updates
- do not modify other plan docs
- do not rewrite historical plan docs during execution
- before implementation starts, the active design doc may still be amended
  freely
- if only the initial docs/plans commit exists and no implementation commit has
  landed yet, that initial docs/plans commit may be amended in place
- once implementation commits exist, do not silently amend the original
  docs/plans commit underneath them; record meaningful plan changes as a new
  docs/plans update commit instead

When a `docs/series/...` execution artifact exists for the task:
- treat the current active execution doc as the only execution artifact eligible
  for updates
- do not modify unrelated execution docs
- before implementation starts, the active execution doc may still be amended
  freely
- if only the initial docs/series commit exists and no implementation commit has
  landed yet, that initial docs/series commit may be amended in place
- once implementation commits exist, do not silently amend the original
  docs/series commit underneath them; record meaningful execution-plan changes
  as a new docs/series update commit instead

## Process

### 1. Determine starting point
Run:
- `git log --oneline --reverse`
- `git status --short`

First determine whether there is an approved active `docs/plans/...` design doc
for the task:
- if yes and no docs/plans anchoring commit exists on this execution branch yet,
  create that docs-only commit first
- if yes and the docs/plans anchoring commit exists but no implementation commit
  exists yet, it may still be amended in place

Then determine whether there is an approved active `docs/series/...` execution
doc for the task:
- if yes and no docs/series anchoring commit exists on this execution branch
  yet, create that docs-only commit before implementation commits that depend on
  it
- if yes and the docs/series anchoring commit exists but no implementation
  commit exists yet, it may still be amended in place
- if implementation commits already exist, treat the branch history as active
  execution history

Then compare the planned subject lines against git history.
The first implementation plan entry in the current approved series that does not
appear in history is the starting point.

If the worktree is dirty, stop and explain. Do not proceed on top of unexpected
uncommitted state.

Print progress in this shape:

Series plan progress:
  ✅ docs/plans: ...
  ✅ 1/6: ...
  ✅ 2/6: ...
  ➡️ 3/6: ...   ← starting here
  ⬜ 4/6: ...
  ⬜ 5/6: ...
  ⬜ 6/6: ...

When a `docs/series/...` execution artifact exists, also show the series
boundary, for example:

Series plan progress:
  ✅ docs/plans: ...
  ✅ docs/series: ...
  Series 1: approved current series
    ✅ 1/3: ...
    ➡️ 2/3: ...
    ⬜ 3/3: ...
  Series 2: waiting for approval
    ⬜ 1/4: ...
    ⬜ 2/4: ...
    ⬜ 3/4: ...
    ⬜ 4/4: ...

### 1a. Anchor approved docs when needed
If an approved active `docs/plans/...` file exists and is not yet committed on
the branch:
- stage only the active `docs/plans/...` file
- make a docs-only commit before any implementation commit
- use a specific subject line such as:
  - `docs/plans: add <topic> design`
  - `docs/plans: revise <topic> design`
  - `docs/plans: clarify <topic> invariants`
- do not include code or unrelated files in this commit

If an approved active `docs/series/...` file exists and is not yet committed on
the branch:
- stage only the active `docs/series/...` file
- make a docs-only commit before any implementation commit that depends on it
- use a specific subject line such as:
  - `docs/series: add <topic> execution plan`
  - `docs/series: revise <topic> execution plan`
  - `docs/series: update <topic> series checkpoints`
- do not include code or unrelated files in this commit

### 2. Restate the current contract
Before implementing each commit, restate:
- subject line
- invariant focus
- test level
- review gate
- files
- preconditions
- postconditions
- verify commands
- not-included list

If a design-doc or series-doc update commit is required before the next
implementation commit, restate that docs update as a separate step first.

### 3. Check preconditions
Verify that the plan’s preconditions are satisfied.
If preconditions are not met because a prior commit is missing or wrong, stop and
explain. Do not silently patch around broken earlier steps.

### 4. Check whether the planned step is still the smallest useful step
- If the current planned commit is too large, mixes concerns, or cannot be made
  independently correct, stop and propose a plan amendment.
- If the current planned commit no longer reflects reality cleanly, do not
  improvise around it.

If reality changed materially after implementation has begun:
- update the active design doc or execution doc first
- commit that docs update as its own docs commit
- then continue from the updated approved plan

### 5. Implement
Write the minimum code needed to satisfy the postconditions.
Guidelines:
- follow local code style
- keep the diff focused
- introduce tests in the commit if the plan says they belong there
- if a real ambiguity appears, stop and ask

### 6. Verify
Run the plan’s verify commands.
If verification fails:
- fix it if the fix is in-scope
- re-run verification
- if the fix is out-of-scope, stop and explain

Never commit code that fails its own verification.

Before committing, also run the repo's relevant formatter and linter, or their
check modes, when they apply to the touched files.

If a formatter changes files:
- review the formatter-produced diff
- re-stage the intended files
- make sure the commit still matches the planned scope before continuing

Treat the planned test level as guidance about proof:
- `regression`, `functional`, and `integration` are often better evidence than
  unit tests for behavior changes
- `unit` is mainly for small, stable, logic-dense primitives
- do not pad the commit with low-signal tests that merely mirror implementation

### 7. Review the staged result
Stage only the intended files.
Show:
- `git diff --cached --stat`
- and, when helpful, a staged diff summary

If unexpected files changed:
- proceed only if the extra changes are mechanically required to satisfy the
  planned postconditions and do not materially expand scope
- otherwise stop and ask, or propose a plan amendment

If the current commit has a non-`none` review gate:
- `code`: perform a skeptical code review pass before committing
- `perf`: check that performance or reliability claims are backed by concrete
  evidence
- `migration`: check compatibility and rollout details before committing
- `structures`: stop and revisit the structure contract only if the commit
  exposed a real mismatch that the approved review missed

### 8. Commit
Create the commit using the planned subject line and a body that explains:
- why this change exists
- key implementation decisions
- what is intentionally deferred

Use kernel-style commit formatting:
- subject line first
- blank line
- explanatory body
- wrap body lines cleanly at about 72 columns
- keep the subject concise and normally within 72 characters

When amending an existing commit in place, preserve this same format rather than
dropping back to a subject-only message.

Do not use `--no-verify`.
Do not add assistant attribution trailers unless explicitly requested.

For docs commits:
- keep the commit docs-only
- use specific subjects such as:
  - `docs/plans: add <topic> design`
  - `docs/plans: revise <topic> design`
  - `docs/plans: clarify <topic> invariants`
  - `docs/series: add <topic> execution plan`
  - `docs/series: revise <topic> execution plan`
  - `docs/series: update <topic> series checkpoints`
- avoid vague subjects like `update docs` or `fix plan`
- include a wrapped body that explains why the docs changed and what remains
  intentionally deferred when that is not obvious from the subject

### 9. Report progress
After each successful commit, print a short summary:

✅ N/Total: <subject>
   Invariant: ...
   Test level: ...
   Review gate: ...
   Files: ...
   Verified: ...
   Matched plan: yes|no
   Notes: <brief deviation note if any>

Then immediately continue to the next planned commit.

If that commit completes the current approved series and later series remain,
stop and report:
- the stable checkpoint reached
- the main verification performed for that series
- whether the next series still appears to match reality
- whether a docs update is needed before planning or approving the next series

## Handling problems

### Verification fails
Fix and retry if the fix is in scope.
If fixing it requires changing the plan materially or touching unrelated areas,
stop and ask.

### Plan does not match reality
If a dependency was missed, a file list is wrong, or a postcondition is
unrealistic, stop and propose a plan amendment.
If a design doc or execution doc exists, update only the current active
artifact for that layer. Do not modify unrelated docs.
Wait for approval before continuing.

If implementation has already begun, preserve truthful history:
- make a new docs/plans or docs/series update commit for meaningful plan changes
- do not silently rewrite the original approved docs commit underneath code
  commits

### Scope creep temptation
If you spot a real issue that is outside the current commit:
- note it briefly
- leave it for the appropriate later commit or a follow-up
- do not expand scope silently

### Low-signal testing temptation
If a commit can be verified with one good regression, functional, or integration
check, do not add several brittle unit tests just to look thorough.

### Ambiguous implementation choice
If there are multiple valid approaches and the plan does not choose between them,
stop and present the options with tradeoffs.

### Need to modify a prior commit
Do not rewrite prior commits during execution unless the user explicitly asks.
If a prior issue blocks progress, stop and explain.

## Resuming after a stop
When the user says “continue”, “resume”, or invokes this skill again:
1. inspect git history
2. find the first unimplemented commit in the current approved series
3. resume there
4. if the prior stop happened mid-commit because of a question, incorporate the
   user’s answer and finish that commit first

If the current series is complete but later series remain, do not continue into
the next series until the execution artifact and approvals say that series is
ready to start.

## What this skill does not do
- It does not create or redesign the series plan.
- It does not silently skip commits.
- It does not combine commits.
- It does not push.
- It does not amend prior commits unless explicitly asked.
- It does not stop at every commit boundary for permission.
- It does not reopen settled architecture unless the approved model is actually
  failing in practice.
- It does not polish history during active execution.

## Completion
After the final commit, print a concise summary of the completed stack and the
main verification that was performed.
