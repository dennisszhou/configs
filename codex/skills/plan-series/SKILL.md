---
name: plan-series
description: Decompose an approved design, feature plan, or implementation idea into a sequence of small, reviewable, independently correct commits. Use when the user asks to break work into commits, plan the commit sequence, make the work atomic, or after a design/docs-plans doc is ready and implementation should be staged cleanly.
---

# Plan Series

Turn an implementation plan into either:
- a direct single-series execution plan
- a durable `docs/execution/...` execution artifact containing one or more
  execution series

## When to use this
Use this skill when:
- the user asks to break work into commits
- the user asks for a series plan or commit stack
- a design or `docs/plans/YYYY-MM-DD-topic.md` doc already exists and
  implementation is next
- design and, when needed, `$review-plan` have already been approved
- the work is large enough that reviewability, bisectability, and staged
  verification matter

Do not use this skill to write code or generate diffs. This skill produces the
commit plan for the current approved execution series.

Do not use this skill while native plan mode is still active. Series planning is
an execution-planning step, not a design-planning step.

## Goal
Each planned commit should be:
- Atomic: one logical change
- Independently correct: the tree builds, passes relevant tests, and is not left
  broken
- Reviewable: small enough for a human to reason about
- Ordered: preconditions are satisfied by prior commits
- Scoped: the commit says what it will not do
- Explicit about invariants, evidence level, and review gates

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
- do not rewrite older plan docs as part of series planning
- only propose updates to the active plan doc if the execution contract is wrong

If `$review-plan` concluded `needs design revision`, stop. Do not plan commits
on top of a rejected model.

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
- Choose the `docs/plans/...` commit shape intentionally:
  - if more than one implementation commit will follow, keep the approved plan
    doc in its own docs-only commit at the front of the series
  - if exactly one semantic implementation commit will follow, fold the
    approved `docs/plans/...` update into that lone implementation commit by
    default

4. Separate correctness from optimization
- Prefer this order:
  1. preparatory cleanup
  2. primitive / helper / API introduction
  3. tests for the primitive or contract when that is the right proof
  4. adoption / behavior change
  5. optimization
  6. docs / cleanup
- Do not apply `primitive / tests / adoption` mechanically when there is no
  real primitive boundary.
- For bugfixes and narrow semantic changes, merge regression evidence into the
  semantic commit by default instead of planning a trailing tests-only commit.

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

7. Choose the right test layer
- Unit tests are not the default proof of seriousness.
- Prefer regression, functional, or integration tests when the real contract
  lives at a subsystem boundary.
- Use unit tests mainly for small, stable, logic-dense primitives.
- Do not add abstractions mainly to make unit tests easier.
- Avoid mock-heavy plans that mostly restate implementation details.

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
- Include one invariant focus per commit so reviewers know what truth that step
  is meant to establish or preserve.
- Include one test level per commit from this fixed set:
  - none
  - regression
  - functional
  - integration
  - unit
- Include one review gate per commit from this fixed set:
  - none
  - structures
  - code
  - perf
  - migration
- The output of this skill is the commit series contract for `$impl-series`.
- Every commit must stand on its own:
  - the repo remains correct
  - relevant verification passes
  - the intermediate state is truthful and reviewable
- Ban:
  - adding a new feature helper with no live user in the commit where it lands
  - adding dormant feature logic, branches, or plumbing whose first real user is
    only a later commit
- Acceptable preparatory work is narrower:
  - extract helpers from already-used code
  - improve shared boundaries used by current code
  - restructure live code so a later semantic commit is smaller and clearer
- Anti-pattern:
  - a final `tests/coverage only` commit for narrow work where the tests merely
    prove the immediately preceding semantic change
  - a two-commit stack that is only:
    1. approved `docs/plans/...` docs-only commit
    2. one semantic implementation commit
    unless a real review or checkpoint reason justifies keeping them separate

## Large execution planning
Prefer a single execution series when the work can still be made reviewable,
independently correct, and realistically implementable as one stack.

Create or update a durable `docs/execution/...` execution doc when any hard
trigger applies:
- one execution effort spans multiple approved design docs
- execution requires multiple series
- implementation is likely to span multiple sessions
- the plan depends on explicit checkpoints or staged approvals between series

Response-only output is acceptable only when all of these are true:
- one approved design doc is in scope
- one execution series is sufficient
- the stack remains small enough to review coherently as one unit
- no durable checkpoint or staged approval boundary is needed

When this skill produces a `docs/execution/...` execution doc, that doc becomes
the execution source of truth for the effort. It should define the higher-level
execution contract:
- the goal
- roadmap context, when it matters
- the approved design inputs
- why execution is split when it is not one series
- the ordered series list and dependencies
- the stable checkpoint for each series
- the review focus and done-means for each series
- the per-series approval state
- the completion state for the effort

Execution docs should be strong enough to constrain implementation, but they do
not need to pre-plan every future commit. This skill is responsible for
decomposing the current approved execution series into the commit stack needed
to reach its checkpoint cleanly.

When creating or revising a `docs/execution/...` doc, use
`codex/skills/plan-series/EXECUTION_TEMPLATE.md` as the house-style starting
point:
- keep the required metadata and per-series contract fields
- adapt the doc shape when the execution effort is clearer with less ceremony
- do not treat the template as permission to bloat the execution doc with
  low-value boilerplate

Proof belongs to each series. The verification plan and stable checkpoint for a
series should provide that series's evidence rather than pushing proof into a
final catch-all series.

Place cleanup where it best reduces risk or clarifies later work. Use a
standalone cleanup series only when it is a real milestone with its own stable,
independently correct checkpoint.

Split series at real milestone boundaries, not arbitrary file counts.

Good boundaries include:
- foundational state/model changes
- preparatory cleanup that unlocks later work
- rebuild/runtime changes
- persistence/load/export cutover
- migration boundaries with explicit compatibility or cutover checkpoints

Bad boundaries include:
- random file grouping
- a generic final “proof/cleanup” series that should have been absorbed into
  earlier series checkpoints and verification
- splitting tightly coupled correctness changes across series with no stable
  checkpoint

## Output format

Produce either:
- a numbered single-series plan
- a `docs/execution/...` execution artifact with clearly labeled sections such
  as `Series 1`, `Series 2`, and `Series 3`

For a `docs/execution/...` execution artifact, begin with:

Title: <short descriptive title>
Date: YYYY-MM-DD
Status: `draft` | `approved` | `in_progress` | `finished` | `superseded`
Approval:
- overall doc approved: yes | no
- current state: human-readable current position in the effort, for example
  `planning`, `Series 1 approved`, `Series 1 finished`, `all series approved`,
  or `complete`
Completion:
- execution complete: yes | no
- include `optional follow-up:` only when there is a real deferred or completed
  follow-up to record

Then include:
- `## Goal`
- `## Roadmap Context` when it matters
- `## Design Inputs`
- `## Why Split` when relevant

Then, for each series, include:
- `Series N: <short label>`
- `Depends on: earlier series or none`
- `Roadmap milestone:` or `Roadmap slice:` when relevant
- `Design coverage: ...`
- `Stable checkpoint: ...`
- `Review focus: ...`
- `Done means: ...`
- `Approval: pending | approved | finished`
- `Verification plan: ...`
- `Not included: ...` when scope pressure or ambiguity makes it useful

Until the user explicitly approves a series, keep that series at
`Approval: pending`.

If the plan is recorded in a doc, name that doc explicitly in the response.
Wrap prose in `docs/` artifacts at `80` columns.

Within each series, each commit entry must look like this:

Commit N/Total: <subsystem: description>

  Type:          preparatory | semantic | optimization | docs | cleanup
  Required:      yes | no
  Summary:       1-2 sentence plain-English summary
  Invariant focus: specific truth this commit establishes or preserves
  Test level:    none | regression | functional | integration | unit
  Review gate:   none | structures | code | perf | migration
  Files:         explicit list of files created or modified
  Preconditions: what must already be true before this commit starts
  Postconditions: what is true after this commit lands
  Verify:        copy-pasteable command(s) proving the postconditions
  Risks:         brief note or "low"
  Not included:  what this commit explicitly does not do
  Depends on:    commit number(s) this depends on

When presenting one or more commit entries in chat, emit the commit block(s)
inside a fenced `text` code block so indentation is preserved exactly. Do not
present aligned commit entries as ordinary prose paragraphs.

For commit-entry formatting, `codex/skills/plan-series/scripts/format_commit_block.py`
is the source of truth for the required inline-indent layout. When a commit
entry includes any wrapped field or multi-line file list, you must generate the
final printed block from that script's layout rather than hand-formatting it.
Do not freehand wrapped commit blocks in the final response, and do not remove
the fenced `text` block wrapper around the final formatted output.

When printing or writing long field values such as `Summary`, `Files`,
`Preconditions`, `Postconditions`, and `Verify`, you must keep the value inline
after the label and align continuation lines under the start of the value. If
output does not follow this format, that is a formatting mistake and should be
corrected directly rather than explained away. For example:

  Summary:       first wrapped line
                 continuation line

For `Files`, you must list one path per line when there is more than one file
or when a single wrapped line would break path readability. Align each path
under the start of the value. For example:

  Files:         crates/igrepd/tests/config_compat.rs
                 crates/igrepd/tests/support/mod.rs
                 crates/igrepd/src/config.rs

Apply the same alignment rule to every wrapped long field, including
`Invariant focus`, `Preconditions`, `Postconditions`, `Risks`, and
`Not included`. This is the required shape:

  Summary:       first wrapped line
                 continuation line
  Invariant focus: first wrapped line
                   continuation line
  Files:         path/one
                 path/two
  Postconditions: first wrapped line
                  continuation line

If a wrapped line appears flush-left under the field label, or if a second file
path appears on an unindented line under `Files:`, the output is invalid and
must be regenerated before sending it to the user.

The required chat shape is:

```text
Commit 1/2: subsystem: short description

  Type:             semantic
  Required:         yes
  Summary:          first wrapped line
                    continuation line
```

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
If a commit is tests-only, say why it stands on its own instead of folding into
the semantic commit it proves.
If there is a standalone `docs/plans/...` commit and only one implementation
commit follows, say why that docs-only commit stands on its own instead of
folding into the implementation commit.

### Invariant focus
Name the contract or truth this commit is responsible for. This is the
centerpiece for review and verification.

### Test level
Pick the highest-leverage level that matches the contract being changed.

Guidance:
- `none` for pure docs, comments, or mechanical changes where another command is
  a better proof than a test
- `regression` for bugfix proof or narrow behavior restoration
- `functional` for behavior exercised through a public feature or workflow
- `integration` for subsystem or boundary interactions
- `unit` for small, stable, logic-dense primitives

Do not default to `unit` just to look rigorous.

### Review gate
Use this to mark commits that deserve extra scrutiny:
- `none` for low-risk preparatory or straightforward commits
- `structures` when the design boundary still needs a structure-focused check
- `code` for risky semantic changes
- `perf` for optimization or performance claims
- `migration` for cutovers, compatibility, or rollout hazards

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
If you keep a standalone test commit, use `Not included` or `Risks` to justify
why that separation improves reviewability or establishes a real boundary.

### Depends on
Usually this is the previous commit, but call out non-obvious dependencies and
independent branches when relevant.

## Interaction rules
- After producing the plan, stop and ask the user to review it before
  implementation starts.
- If a `docs/execution/...` execution doc is required and does not exist yet,
  create or update it as part of planning before asking for approval.
- Make clear whether approval covers only the current execution series or the
  whole execution artifact.
- Common adjustments:
  - split a commit
  - combine two commits
  - reorder independent commits
  - tighten or relax verification
  - move tests earlier
  - separate optimization from correctness more clearly
- Once the user approves the plan, treat it as the execution contract.
- If later execution reveals that the contract is wrong, update the current
  active execution artifact first. Do not modify unrelated plan docs.

## What good plans look like
Good plans:
- introduce primitives before using them
- keep each commit independently correct
- separate semantics from optimization
- expose scope boundaries explicitly
- give verification commands the implementer can actually run
- keep approved `docs/plans/...` in a front docs-only commit for real
  multi-commit series, but fold it into a lone semantic implementation commit
  when that yields a cleaner one-commit execution stack
- mark where extra review is warranted without requiring review theater for
  every commit
- fold regression tests into the semantic commit they prove when the work is a
  bugfix or narrow behavior change

Bad plans:
- end with a final `tests/coverage only` commit for a small bugfix or narrow
  semantic change when that commit does not establish an independently useful
  contract or failing-spec step

## What this skill does not do
- It does not implement the code.
- It does not generate diffs.
- It does not commit anything.
- It does not silently choose a large architectural direction when design is
  still unresolved.

## Final step
End by asking for approval or edits before implementation begins.
