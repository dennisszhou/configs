---
name: plan-commits
description: Decompose an approved design, feature plan, or implementation idea into a sequence of small, reviewable, independently correct commits. Use when the user asks to break work into commits, plan the commit sequence, make the work atomic, or after a design/docs-plans doc is ready and implementation should be staged cleanly.
---

# Plan Commits

Turn an implementation plan into a sequence of small, independently correct
commits.

## When to use this
Use this skill when:
- the user asks to break work into commits
- the user asks for a commit plan or commit stack
- a design or `docs/plans/YYYY-MM-DD-topic.md` doc already exists and
  implementation is next
- the work is large enough that reviewability, bisectability, and staged
  verification matter

Do not use this skill to write code or generate diffs. This skill produces the
execution contract.

## Goal
Each planned commit should be:
- Atomic: one logical change
- Independently correct: the tree builds, passes relevant tests, and is not left
  broken
- Reviewable: small enough for a human to reason about
- Ordered: preconditions are satisfied by prior commits
- Scoped: the commit says what it will not do

## Inputs
This skill works best when it has an existing plan to decompose. That plan may
come from:
- a prior design discussion
- a `docs/plans/YYYY-MM-DD-topic.md` design doc
- a feature spec
- a bug write-up
- a conversational description of the intended end state

If no design exists and the task is non-trivial, first ask for or create a
short design/plan before producing the commit sequence. Do not simultaneously
invent the architecture and the commit stack unless the task is very small.

When an existing design plan is present:
- use that current plan doc as the source of truth for the work
- do not edit unrelated plan docs
- do not rewrite older plan docs as part of commit planning
- only propose updates to the active plan doc if the execution contract is wrong

## Process

1. Identify the end state
- What does done look like?
- What capabilities, behavior, or invariants will exist at the end?

2. Find the natural seams
Look for boundaries between:
- data structures and the code that uses them
- interface definitions and implementations
- build/config wiring and logic
- happy path and error handling
- correctness changes and performance optimizations
- primitive introduction and caller adoption
- core functionality and follow-up polish

3. Order by dependency, not by excitement
- Put foundations first.
- The first commit is what everything else depends on.
- Resist putting the most interesting code first if it depends on unlanded
  structure.

4. Separate correctness from optimization
- Prefer this order:
  1. preparatory cleanup
  2. primitive / helper / API introduction
  3. tests for the primitive or contract
  4. adoption / behavior change
  5. optimization
  6. docs / cleanup

5. Define the contract per commit
Every commit must say:
- what files it touches
- what must already be true
- what becomes true after it lands
- how to verify it
- what is intentionally deferred

6. Make verification concrete
- Verification commands must be literal, copy-pasteable commands.
- Use the lightest meaningful verification for the commit.
- Prefer the narrowest command that proves the postconditions.
- Avoid full test suites when a smaller targeted check is enough for that
  commit.
- If verification depends on the user’s environment, say so and adapt it.

## Additional planning rules
- Mark each commit as one of:
  - preparatory
  - semantic
  - optimization
  - docs
  - cleanup
- Mark whether each commit is required for the requested outcome or is an
  optional follow-up.
- Include a brief risk note for commits with non-obvious correctness, migration,
  or review hazards.
- The output of this skill is the execution contract for `$do-commits`.

## Output format

Produce a numbered commit plan. Each commit entry must look like this:

Commit N/Total: <subsystem: description>

  Type:          preparatory | semantic | optimization | docs | cleanup
  Required:      yes | no
  Summary:       1-2 sentence plain-English summary
  Files:         explicit list of files created or modified
  Preconditions: what must already be true before this commit starts
  Postconditions: what is true after this commit lands
  Verify:        copy-pasteable command(s) proving the postconditions
  Risks:         brief note or "low"
  Not included:  what this commit explicitly does not do
  Depends on:    commit number(s) this depends on

## Field guidance

### Commit title
Use the actual commit subject line that should eventually be used.
Format it as:
`subsystem: short description`

Examples:
- `auth: add token validation helper`
- `cache: introduce entry metadata struct`
- `api: switch callers to paginated response type`

### Summary
Brief plain English so someone skimming the plan can follow the arc.

### Files
List every file expected to change. Use `(new)` for new files. If uncertain, add
`(?)`.

### Preconditions
State what must already exist or be true before starting this commit. Reference
earlier commits by number where useful.

### Postconditions
This is the most important field. Make it testable and observable. Be specific
about what now works, what now builds, or what invariant now holds.

### Verify
Use literal commands. Do not write “run tests” or pseudocode. Include exact
commands when possible.

### Risks
Call out non-obvious correctness, migration, review, or blast-radius risk. Use
`low` when there is nothing notable.

### Not included
Explicitly state what tempting adjacent work is deferred. This is the main guard
against scope creep.

### Depends on
Usually this is the previous commit, but call out non-obvious dependencies and
independent branches when relevant.

## Interaction rules
- After producing the plan, stop and ask the user to review it before
  implementation starts.
- Common adjustments:
  - split a commit
  - combine two commits
  - reorder independent commits
  - tighten or relax verification
  - move tests earlier
  - separate optimization from correctness more clearly
- Once the user approves the plan, treat it as the execution contract.
- If later execution reveals that the contract is wrong, update the current
  active plan doc first. Do not modify other plan docs.

## What good plans look like
Good plans:
- introduce primitives before using them
- land tests with the primitive when practical
- keep each commit independently correct
- separate semantics from optimization
- expose scope boundaries explicitly
- give verification commands the implementer can actually run

## What this skill does not do
- It does not implement the code.
- It does not generate diffs.
- It does not commit anything.
- It does not silently choose a large architectural direction when design is
  still unresolved.

## Final step
End by asking for approval or edits before implementation begins.
