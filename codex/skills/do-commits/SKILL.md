---
name: do-commits
description: Execute an approved plan-commits stack by implementing, verifying, and committing each planned step in order. Use when the user says to execute the commit plan, start implementing, resume the stack, or continue an already approved staged implementation.
---

# Do Commits

Execute an approved commit plan one commit at a time. The git history is the
audit trail. Keep going until you hit a real question, a failure, or the plan is
complete.

## When to use this
Use this skill when:
- the user has already approved a commit plan
- the user explicitly asks to execute that plan
- the user asks to continue or resume an in-progress commit stack

If there is no approved plan, stop and ask the user to run or approve
`$plan-commits` first.

## Approval model
Invocation of this skill counts as authorization to execute the approved commit
stack sequentially.

Do not stop between commits to ask “should I continue?” Stop only when:
- verification fails and the fix would go out of scope
- the plan no longer matches reality
- a meaningful design decision is required
- the worktree is unexpectedly dirty
- the stack is complete

## Core rules

1. Commit after each step
- Every planned commit gets implemented, verified, and committed before moving
  to the next.
- Do not leave completed planned work uncommitted.

2. Never bundle commits
- Each planned commit becomes a separate git commit.
- Do not combine adjacent commits because they seem small.
- Do not split a planned commit into multiple commits unless the plan is amended.

3. Respect the contract
- Stay within the planned file list unless a minor obvious expansion is needed
  for correctness, such as a missing import or small test fixture update.
- Respect the “Not included” list.
- Do not smuggle future work into the current commit.

4. Keep progress recoverable
- Use git history as the source of truth.
- Resume from the first unimplemented commit when continuing later.

## Inputs
This skill expects:
- an approved commit plan from `$plan-commits`
- or an equivalent numbered commit plan supplied by the user

The user may optionally specify where to start:
- start from the first unimplemented commit
- start from commit N

## Plan amendment rules
Treat deviations from the approved plan in three buckets:

1. Minor execution details
- Small mechanically required edits that do not change scope, sequencing, or
  intent may proceed without plan amendment.

2. Local plan amendments
- If an extra file must change, a verify command must change, or one planned
  commit should be split for correctness or reviewability, stop and propose a
  local plan amendment before continuing.

3. Structural mismatches
- If dependency order, API shape, migration strategy, or overall sequencing is
  wrong, stop and re-plan before continuing.

The approved plan remains the source of truth unless explicitly amended.

When a design plan doc exists for the task:
- treat the current active plan doc as the only plan doc eligible for updates
- do not modify other plan docs
- do not rewrite historical plan docs during execution

## Process

### 1. Determine starting point
Run:
- `git log --oneline --reverse`
- `git status --short`

Compare the planned subject lines against git history.
The first plan entry that does not appear in history is the starting point.

If the worktree is dirty, stop and explain. Do not proceed on top of unexpected
uncommitted state.

Print progress in this shape:

Commit plan progress:
  ✅ 1/6: ...
  ✅ 2/6: ...
  ➡️ 3/6: ...   ← starting here
  ⬜ 4/6: ...
  ⬜ 5/6: ...
  ⬜ 6/6: ...

### 2. Restate the current contract
Before implementing each commit, restate:
- subject line
- files
- preconditions
- postconditions
- verify commands
- not-included list

### 3. Check preconditions
Verify that the plan’s preconditions are satisfied.
If preconditions are not met because a prior commit is missing or wrong, stop and
explain. Do not silently patch around broken earlier steps.

### 4. Check whether the planned step is still the smallest useful step
- If the current planned commit is too large, mixes concerns, or cannot be made
  independently correct, stop and propose a plan amendment.
- If the current planned commit no longer reflects reality cleanly, do not
  improvise around it.

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

### 7. Review the staged result
Stage only the intended files.
Show:
- `git diff --cached --stat`
- and, when helpful, a staged diff summary

If unexpected files changed:
- proceed only if the extra changes are mechanically required to satisfy the
  planned postconditions and do not materially expand scope
- otherwise stop and ask, or propose a plan amendment

### 8. Commit
Create the commit using the planned subject line and a body that explains:
- why this change exists
- key implementation decisions
- what is intentionally deferred

Use a clean multi-line commit message.
Do not use `--no-verify`.
Do not add assistant attribution trailers unless explicitly requested.

### 9. Report progress
After each successful commit, print a short summary:

✅ N/Total: <subject>
   Files: ...
   Verified: ...
   Matched plan: yes|no
   Notes: <brief deviation note if any>

Then immediately continue to the next planned commit.

## Handling problems

### Verification fails
Fix and retry if the fix is in scope.
If fixing it requires changing the plan materially or touching unrelated areas,
stop and ask.

### Plan does not match reality
If a dependency was missed, a file list is wrong, or a postcondition is
unrealistic, stop and propose a plan amendment.
If a design plan doc exists, update only the current active plan doc.
Do not modify other plan docs.
Wait for approval before continuing.

### Scope creep temptation
If you spot a real issue that is outside the current commit:
- note it briefly
- leave it for the appropriate later commit or a follow-up
- do not expand scope silently

### Ambiguous implementation choice
If there are multiple valid approaches and the plan does not choose between them,
stop and present the options with tradeoffs.

### Need to modify a prior commit
Do not rewrite prior commits during execution unless the user explicitly asks.
If a prior issue blocks progress, stop and explain.

## Resuming after a stop
When the user says “continue”, “resume”, or invokes this skill again:
1. inspect git history
2. find the first unimplemented commit
3. resume there
4. if the prior stop happened mid-commit because of a question, incorporate the
   user’s answer and finish that commit first

## What this skill does not do
- It does not create or redesign the commit plan.
- It does not silently skip commits.
- It does not combine commits.
- It does not push.
- It does not amend prior commits unless explicitly asked.
- It does not stop at every commit boundary for permission.

## Completion
After the final commit, print a concise summary of the completed stack and the
main verification that was performed.
