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

Do not use this skill to write implementation code or generate implementation
diffs. This skill produces a candidate execution contract: either a
response-only current-series plan or a durable execution doc plus the
current-series commit plan.

Do not use this skill while native plan mode is still active. Series planning is
an execution-planning step, not a design-planning step.

Apply the `$workflow-house-rules` documentation lifetime rule when choosing docs
commit boundaries. Durable reference docs must stay truthful as current-state
system guidance, while product, roadmap, design, `docs/plans/...`, and
`docs/execution/...` artifacts are working docs for the active phase or series.

Apply the `AGENTS.md` house rules for proof and documentation placement, and
`$workflow-house-rules` for approval handoff and planning-artifact commits. Do
not restate those rule bodies here; make the commit plan show how it satisfies
them when relevant.

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
- source/module owners and the files that currently happen to be nearby
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
    doc in a front docs-only planning-artifacts commit
  - if a durable `docs/execution/...` artifact is also part of that same
    planning state, include it in the same planning-artifacts commit rather than
    splitting `docs/plans` and `docs/execution` into separate commits
  - if exactly one semantic implementation commit will follow, fold the
    approved `docs/plans/...` update into that lone implementation commit by
    default

4. Separate correctness from optimization
- Prefer this dependency order, not one commit per line:
  1. preparatory cleanup
  2. primitive / helper / API introduction, with contract proof when useful
  3. adoption / behavior change, with regression or functional proof
  4. optimization behind an established and proven boundary
  5. cleanup or docs-only work that is independently true and reviewable
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
- source-topology impact, when a file or directory grows materially
- how the `AGENTS.md` house rules or `$workflow-house-rules` affect docs,
  proof, or approval state when relevant

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
- Keep commit entries decision-oriented. Do not add metadata fields whose values
  do not affect whether to start, stop, split, review, or verify the commit.
- Include one invariant focus per commit so reviewers know what truth that step
  is meant to establish or preserve.
- Use `Review: structures` when a commit names, creates, or materially changes
  source/module ownership boundaries.
- In `Evidence`, include one proof level from this fixed set plus why it is the
  right layer:
  - none
  - regression
  - functional
  - integration
  - unit
- In `Review`, include one review gate from this fixed set plus why that gate is
  enough:
  - none
  - structures
  - code
  - perf
  - migration
- Do not re-add checklist-only fields such as `Type`, `Required`, `Risks`, or
  `Depends on` unless the value changes a start/stop decision. Use
  `Preconditions`, `Not included`, `Evidence`, or `Review` for the concrete
  decision instead.
- The output of this skill is the candidate execution contract. It becomes the
  contract for `$impl-series` after `$review-execution` returns
  `ready for implementation` and the user approves implementation.
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
`codex/skills/workflow/plan-series/EXECUTION_TEMPLATE.md` as the house-style
starting point:
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

  Summary:       1-2 sentence plain-English summary
  Invariant focus: specific truth this commit establishes or preserves
  Files:         explicit list of files created or modified
  Source topology: owner/split/not material decision with reason
  Preconditions: what must already be true before this commit starts
  Postconditions: what is true after this commit lands
  Evidence:      none | regression | functional | integration | unit, with why
  Review:        none | structures | code | perf | migration, with why
  Verify:        copy-pasteable command(s) proving the postconditions
  Not included:  what this commit explicitly does not do

When presenting one or more commit entries in chat, emit the commit block(s)
inside a fenced `text` code block so indentation is preserved exactly. Do not
present aligned commit entries as ordinary prose paragraphs.

For commit-entry formatting,
`codex/skills/workflow/plan-series/scripts/format_commit_block.py` is the source
of truth for the required inline-indent layout. When a commit entry includes any
wrapped field or multi-line file list, you must generate the final printed block
from that script's layout rather than hand-formatting it. Do not freehand
wrapped commit blocks in the final response, and do not remove the fenced
`text` block wrapper around the final formatted output.

When printing or writing long field values such as `Summary`, `Files`,
`Source topology`, `Preconditions`, `Postconditions`, `Evidence`, `Review`, and
`Verify`, you must keep the value inline after the label and align continuation
lines under the start of the value. If output does not follow this format, that
is a formatting mistake and should be corrected directly rather than explained
away. For example:

  Summary:       first wrapped line
                 continuation line

For `Files`, you must list one path per line when there is more than one file
or when a single wrapped line would break path readability. Align each path
under the start of the value. For example:

  Files:         crates/igrepd/tests/config_compat.rs
                 crates/igrepd/tests/support/mod.rs
                 crates/igrepd/src/config.rs

Apply the same alignment rule to every wrapped long field, including
`Invariant focus`, `Preconditions`, `Postconditions`, `Evidence`, `Review`, and
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

### Evidence
Pick the highest-leverage proof level that matches the contract being changed
and briefly say why that layer is enough.

Guidance:
- `none` for pure docs, comments, or mechanical changes where another command is
  a better proof than a test
- `regression` for bugfix proof or narrow behavior restoration
- `functional` for behavior exercised through a public feature or workflow
- `integration` for subsystem or boundary interactions
- `unit` for small, stable, logic-dense primitives

Do not default to `unit` just to look rigorous.

### Review
Use this to decide whether the commit deserves extra scrutiny and briefly say
why that gate is enough:
- `none` for low-risk preparatory or straightforward commits
- `structures` when the design boundary still needs a structure-focused check
- `code` for risky semantic changes
- `perf` for optimization or performance claims
- `migration` for cutovers, compatibility, or rollout hazards

### Files
List every file expected to change. Use `(new)` for new files. If uncertain, add
`(?)`.

### Source topology
This is a decision field, not a label. Use one of:
- `owner: <module/path> because <why this owner owns the behavior>`
- `split: <module/path> because <responsibility that deserves its own owner>`
- `not material: <why the existing owner is obvious and no split is needed>`

Do not write a bare `not material`. When a commit adds substantial behavior,
creates a module, grows a large file, or touches a crowded directory, an
unsupported `not material` answer is invalid. If no owner can be named, the plan
is not ready; return to design or ask for a topology decision.

### Preconditions
State what must already exist or be true before starting this commit. Reference
earlier commits by number where useful.

### Postconditions
This is the most important field. Make it testable and observable. Be specific
about what now works, what now builds, or what invariant now holds.

### Verify
Use literal commands. Do not write “run tests” or pseudocode. Include exact
commands when possible.

### Not included
Explicitly state what tempting adjacent work is deferred. This is the main guard
against scope creep.
If you keep a standalone test commit, use `Not included` to justify why that
separation improves reviewability or establishes a real boundary. Call out
non-obvious dependencies or risks here when they affect whether the commit is
safe to start.

## Interaction rules
- After producing a candidate execution contract, immediately run
  `$review-execution` in the same turn.
- Do not end by asking the user to invoke `$review-execution`. Perform the
  review and report its result. This still does not approve implementation; it
  only produces the review result the user may approve.
- Make clear whether the candidate execution contract covers only the current
  execution series or the whole execution artifact.
- Tiny obvious work should be implemented without the series workflow rather
  than creating a candidate execution contract without review.
- Common adjustments:
  - split a commit
  - combine two commits
  - reorder independent commits
  - tighten or relax verification
  - move tests earlier
  - separate optimization from correctness more clearly
- Once `$review-execution` has returned `ready for implementation` and the user
  approves implementation, treat the plan as the execution contract.
- If that contract uses a durable `docs/execution/...` doc, record the user's
  approval in the working doc before `$impl-series` starts, but do not commit
  that approval update yet. The approval state is committed by the first
  `$impl-series` commit, usually the planning-artifacts anchor.
- If later execution reveals that the contract is wrong, update the current
  active execution artifact first. Do not modify unrelated plan docs.

## What good plans look like
Good plans:
- introduce primitives before using them
- keep each commit independently correct
- separate semantics from optimization
- expose scope boundaries explicitly
- keep commit fields decision-oriented instead of expanding the checklist
- give verification commands the implementer can actually run
- make the `AGENTS.md` house rules and `$workflow-house-rules` visible in
  commit boundaries without duplicating the rule text
- name the owning module before adding substantial behavior to a large file or
  crowded directory
- include a source-topology checkpoint when the series materially grows source
  files or directories
- keep approved `docs/plans/...` in a front docs-only commit for real
  multi-commit series, including any same-state `docs/execution/...` artifact
  in that commit, but fold it into a lone semantic implementation commit when
  that yields a cleaner one-commit execution stack
- mark where extra review is warranted without requiring review theater for
  every commit
- fold regression tests into the semantic commit they prove when the work is a
  bugfix or narrow behavior change

Bad plans:
- add fields that only classify the commit without changing implementation,
  review, or verification behavior
- end with a final `tests/coverage only` commit for a small bugfix or narrow
  semantic change when that commit does not establish an independently useful
  contract or failing-spec step
- defer house-rule fixes to a trailing cleanup commit after earlier commits have
  already made docs false or proof placement misleading
- treat source-topology drift as cosmetic cleanup when it changes where future
  behavior will attach

## What this skill does not do
- It does not implement the code.
- It does not generate implementation diffs.
- It does not commit anything.
- It does not silently choose a large architectural direction when design is
  still unresolved.

## Final step
End by reporting the immediate `$review-execution` result, asking for explicit
implementation approval when the result is `ready for implementation`, or
asking for edits before implementation begins.
