# AGENTS.md

This file defines my default coding-agent behavior across repositories.

It is a global baseline. Repository-local `AGENTS.md` files may add repo-specific
rules or override these defaults for files in their scope. Follow the nearest
applicable `AGENTS.md` first.

## Scope and precedence
- Follow the most specific applicable instructions first.
- Treat this file as a default, not as a substitute for reading the repository.
- Before changing code, read the relevant local context:
  - `README`
  - `CONTRIBUTING`
  - architecture docs
  - existing tests
  - build files
  - lint/format configs
  - the nearest `AGENTS.md`
- Match the repository’s tooling and conventions unless changing them is part of
  the task.

## Local reference material
- `~/workplace/llm-wiki` contains LLM-managed wikis for work we have done
  together.
- When answering questions, planning work, or looking for reference material,
  consider checking `~/workplace/llm-wiki` for relevant prior context.
- Treat the wiki as helpful context, not as a replacement for the current
  repository, nearest instructions, source code, tests, or official docs.

## Environment
- Primary machine is macOS on Apple Silicon.
- Editor is Neovim.
- Prefer tools and approaches that work on both macOS and Linux.
- Some work happens inside Docker or remote Linux environments.
- Do not assume macOS-only or Linux-only unless the repo clearly requires it.
- Confirm before running unfamiliar or destructive shell commands.

## Workflow
- Plan first for any non-trivial change.
- Use the planning model below to distinguish architecture/design planning from
  execution planning.
- For non-trivial work, show the data model, key structures, or API shape before
  implementation.
- If something breaks mid-task or the plan stops matching reality: stop, re-plan,
  and check in. Do not push forward on a stale plan.
- If the task is ambiguous in a way that affects correctness, API shape,
  migration, or reviewability, ask instead of guessing.
- Read existing code and project-level instructions before touching anything.
- Match repo style. When unsure about a pattern, inspect the codebase instead of
  inventing a new one.
- Keep changes scoped to what was asked. No drive-by refactors.
- For non-trivial work, use the lightest lane that fits:
  - small work: optional native `/plan`, then `$plan-series`, then
    either explicit implementation approval or `$review-execution`, then
    `$impl-series`
  - medium work: `$design` with `docs/plans/...` when needed,
    `$review-plan`, `$plan-series`, then `$review-execution`, then
    `$impl-series`
  - large technical work: `$roadmap`, `$review-plan`, `$design`,
    `$review-plan`, `$plan-series` with `docs/execution/...` when needed,
    `$review-execution`, `$impl-series`, then `$finish-series` only when
    explicitly approved
  - large product or app work: `$product`, `$review-plan`, `$roadmap`,
    `$review-plan`, `$design`, `$review-plan`, `$plan-series` with
    `docs/execution/...` when needed, `$review-execution`, `$impl-series`,
    then `$finish-series` only when explicitly approved
- Native `/plan` is optional. It is useful for lightweight planning discussion,
  but durable docs become the source of truth once work is large enough to need
  them. Once a roadmap, design doc, or execution doc exists for the effort,
  chat should not quietly replace that artifact as the source of truth.
- For bugfixes, reproduce the bug or define regression evidence first; use a
  short design note only when the fix shape is not obvious.

## Planning model

Planning happens in two distinct phases. Do not collapse them into one.

### 1. Architecture / design planning
Use architecture or design planning when the problem, API, data model, migration
strategy, or high-level implementation approach is not yet settled.

This phase is for deciding:
- what problem is being solved
- what the constraints and non-goals are
- what the API or data model should look like
- what invariants must hold
- what the authoritative source-of-truth state is
- what state is derived versus cached versus authoritative
- what tradeoffs are being made
- what migration or compatibility strategy is needed
- what the overall shape of the solution should be

For substantial features, refactors, or migrations, write or update a design doc
under `docs/plans/` before implementation begins.

For substantial app or initiative work where user journeys, release slices, or
cross-surface integration are not yet clear, first produce a product doc under
`docs/products/` before roadmap or design planning begins.

When the work is too large for one design doc, first produce a roadmap that
identifies components, slices, milestones, dependencies, and which slices need
their own dedicated design docs under `docs/plans/`.

Product docs should use dated filenames in this form:
- `docs/products/YYYY-MM-DD-topic.md`

Examples:
- `docs/products/2026-03-20-collab-notes-v1.md`
- `docs/products/2026-03-20-admin-ops-console.md`

`docs/products/...` is the source of truth for:
- target audience or operator
- core user journeys
- release slices
- major integration expectations
- in-scope versus out-of-scope initiative boundaries

Product docs should be used mostly for:
- new apps
- major product initiatives
- broad user-facing efforts spanning multiple subsystems

Do not force a product doc for technical migrations, narrow internal changes,
or feature work already well-bounded by existing product context.

Use dated filenames in this form:
- `docs/plans/YYYY-MM-DD-topic.md`

Examples:
- `docs/plans/2026-03-20-auth-token-refresh.md`
- `docs/plans/2026-03-20-percpu-bitmap-migration.md`

A written design plan is required when:
- the work is large or likely to span multiple sessions
- the architecture or API is not already clear
- there are migration or compatibility risks
- there are multiple milestones or validation checkpoints
- correctness changes must be staged separately from optimizations

A design or architecture plan should include, when relevant:
- status
- title
- date
- goal
- constraints
- non-goals
- proposed approach
- data model or API shape
- invariants
- source-of-truth, derived-state, and cached-state boundaries
- migration strategy
- validation milestones
- open questions

When a task is already associated with an existing design plan:
- update only the current active plan doc for that task
- do not edit older or unrelated plan docs
- treat other plan docs as historical records unless explicitly told otherwise

Design docs under `docs/plans/` should carry an explicit status field:
- `Status: draft` while the design is still being revised
- `Status: approved` once design review via `$review-plan` is complete enough
  for execution planning
- `Status: superseded` when a newer plan replaces it as the active design

Docs produced under `docs/` by this workflow should:
- include explicit top-of-doc metadata appropriate to the artifact type
- include `Title`, `Date`, and `Status` sections
- wrap prose at `80` columns for terminal and review readability

### 2. Execution planning
Execution planning happens after the architecture or design is already understood
well enough to implement.

Execution planning is about:
- breaking the work into commits
- deciding whether execution should stay in one reviewable series or move into a
  durable `docs/execution/...` execution artifact
- staging verification
- separating correctness from optimization
- making the work reviewable and bisectable
- choosing the order of implementation

`$plan-series` is a commit-series planning step, not an architecture-planning
step or a replacement for a higher-level execution contract.

Use `$plan-series` only after one of these is true:
- the design is already clear from the task and existing code
- a design discussion has already settled the approach
- an approved design doc under `docs/plans/` already exists

If the architecture is still unclear, do not jump straight to `$plan-series`.
First do design planning.

## Planning workflow
Use this workflow for non-trivial work:

1. Determine whether product planning is needed.
2. If needed, create or update `docs/products/...`.
3. Use `$review-plan` on a product artifact before roadmap planning that
   depends on it. Continue only after the result is `ready for roadmap`.
4. Determine whether roadmap planning is needed.
5. If needed, create or update `docs/roadmaps/...`.
6. Use `$review-plan` on a roadmap artifact before design planning that depends
   on it. Continue only after the result is `ready for design`.
7. If needed, create or update `docs/plans/...`.
8. Use `$review-plan` on the design context before series planning. Continue
   only after the result is `ready for series planning`.
9. Use `$plan-series` to produce the execution contract:
   - a response-only current-series commit plan for small enough work
   - or a durable `docs/execution/...` artifact plus the current-series commit
     plan when staged execution tracking is needed
10. Decide whether `$review-execution` is needed:
   - require it for durable `docs/execution/...` artifacts, multi-series work,
     risky boundaries, material review gates, unclear verification, or anything
     that is not obviously small and low-risk
   - allow skipping it only for a small, low-risk response-only plan when the
     user explicitly approves implementation from the `$plan-series` output
11. If `$review-execution` runs and returns `ready for implementation`, or the
   user explicitly approves a small low-risk bypass, record that approval before
   execution:
   - for response-only plans, the chat approval is enough
   - for durable execution docs, update the doc so whole-doc approval and the
     current series approval are explicit
12. Use `$impl-series` to execute that approved commit stack. This always
    includes a final `$review-series` pass over the implemented current series
    before any closeout decision.
13. If the series is stable and local-history cleanup would improve review,
    optionally run `$polish-series`.
14. Run `$finish-series` only when a durable execution doc exists and the user
    explicitly approved marking the current series finished. That approval may
    be given before implementation, such as "implement this and then finish the
    series", or after reviewing the implementation and `$review-series` result.
    If finish approval is absent, stop after the implementation and review
    summary.
15. If implementation reveals that the product, roadmap, design, or execution
    plan is wrong, stop, update the relevant doc, and only then continue.

The active `docs/plans/...` file remains mutable during design, `$review-plan`,
and series planning. The active `docs/execution/...` file remains mutable during
`$plan-series` and `$review-execution`. Once `$impl-series` begins:
- if the active approved plan doc is not yet committed on the execution branch
  and more than one implementation commit will follow, commit it first as a
  docs-only commit
- if execution will be exactly one semantic commit, folding the approved
  `docs/plans/...` update into that lone implementation commit is allowed
- do not use that single-commit exception to skip a committed approved plan doc
  for larger multi-commit series
- if only that initial docs/plans commit exists and no implementation commit has
  landed yet, amending it in place is acceptable
- once implementation commits exist, meaningful design or execution-plan updates
  should usually be recorded as new docs commits rather than silently rewriting
  the original approved artifact underneath code history

## Heuristics
- Small, obvious tasks may not need a written design plan.
- Non-trivial tasks should usually use `$plan-series`.
- Large app or initiative work should usually start with `docs/products/...`
  before roadmap or design work.
- Large, ambiguous, multi-step, or multi-session tasks should usually have a
  written design plan under `docs/plans/` before `$plan-series`.

## Large execution planning
Prefer one execution series when the work is still reviewable, independently
correct, and realistically implementable as one stack.

Require a durable `docs/execution/...` execution doc when any of these hard
triggers apply:
- one execution effort spans multiple approved design docs
- execution requires multiple series
- implementation is likely to span multiple sessions
- the plan depends on explicit checkpoints or staged approvals between series

Allow `$plan-series` to return a response-only execution plan only when all of
these are true:
- the execution effort depends on one approved design doc
- the work fits in one execution series
- the stack remains small enough to review coherently as one unit
- no durable checkpoint or staged approval boundary is needed

Execution docs should use dated filenames in this form:
- `docs/execution/YYYY-MM-DD-topic.md`

`docs/plans/...` remains the architecture source of truth.
`docs/execution/...` is the execution source of truth when a durable execution
artifact is required.

Execution docs should define the higher-level staged execution contract:
- the goal and relevant planning inputs
- the ordered series list and dependencies
- the stable checkpoint for each series
- the per-series approval state
- the completion state for the effort

Execution docs should be strong enough to constrain implementation, but they do
not need to pre-plan every future commit. `$plan-series` is responsible for
decomposing the current approved execution series into a clean commit stack.
The exact execution-doc shape belongs in the relevant skill and template, not
here.

Durable execution-doc plans must pass `$review-execution` before `$impl-series`
begins. Response-only series plans should usually pass `$review-execution`, but
may skip it when the plan is small, low-risk, and explicitly approved for
implementation from the `$plan-series` output. When it runs,
`$review-execution` should test not only whether the execution contract is
coherent, but whether the series boundaries, commit chain, review gates, and
verification plan can be made more reviewable without changing the approved
design.

Proof belongs to each series. Do not default to a final standalone
“proof/cleanup” series when the real evidence should live with the series that
establishes each checkpoint.

Cleanup should be placed where it best reduces risk or improves reviewability.
Use a standalone cleanup series only when that cleanup itself forms a real,
independently correct milestone.

## Important distinction
Do not treat series planning as a substitute for design.

- Product planning decides what experience should exist and what release slice
  matters first.
- Roadmap planning decides what technical slices and milestones are needed to
  realize that product or initiative.
- Design planning decides what to build.
- `$review-plan` reviews each planning artifact before the next planning or
  execution phase: product before roadmap, roadmap before design, and design
  before series planning.
- `$plan-series` decides how to stage building it and produces the execution
  contract: either a response-only series plan or a durable execution doc plus
  the current-series commit chain.
- `$review-execution` reviews that execution contract before implementation,
  looking for better commit boundaries, series boundaries, review gates, and
  verification placement while staying within the approved design. It is
  required for durable or risky execution and optional for small low-risk
  response-only plans.
- `$impl-series` executes the current approved execution series and always runs
  `$review-series` on the implemented series before any closeout decision.
- `$polish-series` optionally cleans local history after a series is stable.
- `$finish-series` records truthful closeout only after implementation,
  review, and explicit user approval to mark the current series finished.

## Approval boundaries
- Present a plan before non-trivial code changes when approval is expected.
- Do not treat a `docs/plans/...` artifact as implementation-ready until it is
  explicitly marked `Status: approved`.
- Do not start `$impl-series` until either `$review-execution` has returned
  `ready for implementation` for the current execution contract, or the user has
  explicitly approved implementation from a small low-risk response-only
  `$plan-series` output.
- When a `docs/execution/...` artifact exists, also require the whole execution
  doc to be approved and the current execution series to be explicitly approved.
- If `$review-execution` finds the execution contract ready but the durable
  execution doc still says approval is pending, update the doc's approval state
  before starting `$impl-series`.
- Do not mark an execution series finished, including by running
  `$finish-series`, unless the user explicitly approves that closeout. The
  approval may be part of the original request or given after implementation
  and end-of-series review.
- Before committing, show the staged diff and proposed commit message when the
  workflow expects review.
- If an explicit execution workflow has already been approved through
  `$review-execution` or through the small low-risk bypass path, that approval
  authorizes `$impl-series` to execute the planned commits sequentially until a
  real question, failure, or plan mismatch arises.
- Use selective review gates rather than mandatory review theater on every
  commit. Typical gates are `structures`, `code`, `perf`, and `migration`.
- Stop for approval again when:
  - the plan needs to change materially
  - verification fails in a way that requires out-of-scope changes
  - there are multiple valid implementation choices with meaningful tradeoffs
  - unexpected files or side effects expand the scope

Preserve truthful execution history while work is ongoing. Do not polish the
branch history during `$impl-series`; later docs/plans or docs/execution update
commits are acceptable when the plan changes materially.

## Core principles
- Solve the right problem before optimizing the implementation.
- Prefer deletion over addition when deletion solves the problem cleanly.
- Prefer clarity over cleverness.
- Make important truths hard to miss.
- Make important mistakes hard to make.
- Keep one clear source of truth for important state.
- Separate structure, semantics, and optimization so each can be reviewed on its
  own.
- Match the amount of process and evidence to the risk of the change.
- Data structures first: model the problem, then write the functions.
- Build what is needed now, but design so extension is straightforward later.
  Avoid speculative features without painting the code into a corner.
- Prefer explicit over implicit, established over custom, and extensible over
  clever.

## Commit structure
Prefer commit stacks that separate concerns:

1. preparatory cleanup or code motion
2. primitive / helper / API introduction
3. tests for the new primitive or contract
4. adoption by callers or behavior changes
5. performance optimizations
6. docs and cleanup

Rules:
- Keep each commit understandable on its own.
- Do not mix unrelated concerns in one commit.
- Do not hide semantic changes inside refactors.
- Do not mix API changes with performance optimizations unless separation would
  be misleading or impossible.
- Do not mix dependency upgrades with behavior changes.
- Preserve bisectability whenever practical: intermediate commits should build
  and pass the relevant tests.
- Prefer small, isolated commits with one logical change per commit.
- For bugfixes and narrow semantic changes, tests should usually land in the
  same commit as the behavior change they prove.
- Do not default to a trailing test-only commit whose only purpose is added
  regression coverage for a small fix or narrow semantic change.
- Proof belongs with the commit that establishes the behavior unless the test
  commit is itself introducing the primitive or contract boundary being defined.

## Primitive-first development
- When introducing a new primitive, helper, abstraction, or API boundary, also
  introduce tests for its contract.
- Tests should define what the primitive guarantees as it is introduced.
- Prefer to establish the boundary and its tests before layering behavior or
  optimizations on top of it.
- Purely mechanical renames or code motion do not need new tests by themselves,
  but a new primitive usually does.

## Commit correctness
- Every commit should stand on its own:
  - the repo remains correct
  - relevant verification passes
  - the intermediate state is truthful and reviewable
- Commit boundaries exist for bisectability and ease of review.
- Do not add dormant feature-specific helpers, branches, or plumbing whose
  first real user exists only in a later commit.
- Acceptable preparatory work is narrower:
  - extract helpers from already-used code
  - improve shared boundaries used by current code
  - restructure live code so a later semantic commit is smaller and clearer

## Testing and evidence
- Validate every non-trivial change.
- Choose the lightest form of evidence that meaningfully reduces uncertainty:
  - unit tests
  - integration tests
  - regression tests
  - scenario walkthroughs
  - traces
  - profiles
  - benchmarks
  - before/after behavior checks
- Prefer the highest-leverage evidence that exercises the real contract at
  reasonable cost.
- Prefer regression, functional, or integration tests when the behavior of
  interest lives at a subsystem boundary.
- Use unit tests mainly for small, stable, logic-dense primitives.
- Do not require TDD.
- Avoid mock-heavy tests that mainly restate implementation.
- Avoid creating abstractions mainly to make unit tests easier.
- Avoid broad low-signal test volume when one or two high-signal checks would
  prove more.
- Stronger evidence is expected when:
  - replacing mature code
  - changing user-visible behavior
  - touching hot paths
  - changing concurrency behavior
  - changing memory, latency, throughput, scale, or reliability characteristics
  - increasing architectural complexity
- Do not require heavyweight benchmarking for every change.
- Do not make performance or reliability claims without supporting evidence.
- If the project has test or lint commands, run them before marking work done.
- Before committing, run the repo's relevant formatter and linter, or their
  check modes, when they apply to the touched files.
- Do not mark a task complete without verification.
- Flag untested edge cases instead of ignoring them.

## Bug-fix discipline
- Reproduce the bug first when practical.
- Prefer the smallest failing case that still demonstrates the problem.
- Add a regression test for the bug when feasible.
- Fold end-to-end or user-path regression tests into the same commit as the
  behavior fix by default.
- Use a separate test commit only when it stands on its own as a useful
  failing-spec step, defines a new primitive boundary before adoption, or is
  large enough that separation materially improves reviewability.
- Fix the root cause, not only the visible symptom, unless a narrow hotfix is
  explicitly the goal.
- If the bug cannot be reproduced directly, say what evidence is available and
  what remains uncertain.
- For bugfixes, let regression evidence drive the plan; only require a design
  phase when the fix changes structure, API shape, or rollout risk.

## Correctness and API design
- Make contracts explicit:
  - inputs and outputs
  - ownership and lifetime
  - units
  - optionality
  - failure modes
  - ordering guarantees
  - retry / idempotence behavior
  - concurrency assumptions
- Make illegal states unrepresentable when practical.
- Distinguish clearly between:
  - source-of-truth state
  - cached state
  - derived state
  - hints / heuristics
- Correctness must not silently depend on stale or approximate derived state
  unless that is an explicit design choice.
- If stale hints are allowed, they must fail in the safe direction.
- Design docs describe intent, constraints, and non-goals. They do not replace
  clear code or explicit invariants.

## Structure review
Before execution planning on non-trivial work, perform a skeptical structure
review of the proposed model. The review should confirm:
- the source of truth is explicit
- authoritative, cached, and derived state are clearly separated
- ownership and lifecycle are coherent
- API boundaries are concrete enough to implement
- invariants and illegal states are explicit
- the chosen boundaries support high-signal regression, functional, or
  integration testing

Execution should not casually reopen architecture after design and structure
review are approved. Reopen it only when implementation exposes a real mismatch.

## Separate correctness from optimization
- First make the boundary explicit and testable.
- Then make the implementation better behind that boundary.
- Reviewers should be able to evaluate correctness without also evaluating
  optimization logic.
- Optimize against an already-defined and already-tested interface whenever
  possible.
- Prefer bounded and predictable work on hot paths over fragile best-case tricks.

## Naming and abstraction
- Use names that reflect meaning, not just mechanics.
- Encode important distinctions in names when relevant:
  - units (`_ms`, `_bytes`, `_count`, `_idx`)
  - ownership
  - lifetime
  - cached vs authoritative
  - local vs global
  - raw vs normalized
- Rename things when semantics change.
- Prefer small, purpose-built helpers over broad, premature abstraction.
- Generalize only after repeated concrete need or a strong invariant that
  clearly deserves a shared abstraction.
- Do not preserve misleading legacy names for convenience.

## Scope discipline
- Do not opportunistically refactor unrelated code.
- Do not do drive-by formatting or renaming in semantic commits.
- Prefer the smallest change that cleanly solves the real problem.
- When existing structure blocks a correct change, do preparatory cleanup in
  separate commits.
- Minimal diffs: change only what is needed.

## Compatibility and migration
When replacing existing behavior:
- Separate:
  - preparation
  - compatibility layer or bridge
  - cutover
  - cleanup
- Preserve backward compatibility by default unless breaking it is the point of
  the change.
- Breaking changes must be explicit.
- Provide migration notes for changed contracts, config, behavior, or data shape.
- Temporary compatibility shims should have a clear removal condition.

## Concurrency and async behavior
For concurrent, async, queued, or retried code:
- Make thread-safety assumptions explicit.
- Make ordering guarantees explicit.
- Make cancellation behavior explicit.
- Make retry semantics explicit.
- Make idempotence expectations explicit.
- Do not rely on “probably safe” interleavings.

## Error handling and observability
- Raise errors explicitly with enough context to diagnose the failure.
- Use specific error types where practical.
- Fail loudly when invariants are violated unless there is a deliberate recovery
  strategy.
- Error messages should help the next engineer diagnose the issue.
- Preserve or improve diagnostics during refactors.
- New retries, caches, queues, state machines, or background behavior should
  expose enough state to debug.
- Do not spam logs.
- Do not log secrets or sensitive user data.
- No silent fallbacks unless explicitly asked.

## Documentation and comments
- Comments should explain the model, invariant, or reason.
- Do not write comments that merely paraphrase syntax.
- Inline docs should explain why, not what.
- Write docs for substantial new features, major behavior changes, and important
  architectural additions.
- Add docs when the feature is introduced or in the same change series.
- Do not defer documentation updates to a final docs-only commit when earlier
  commits change the user-facing behavior, API, workflow, or mental model.
- Update documentation alongside the commit that introduces the behavior so any
  single checked-out commit remains internally consistent and correct.
- Large concepts spanning multiple modules should have a dedicated doc.
- Keep one authoritative place per concept; avoid duplicated documentation that
  can drift.
- Docs should explain, when relevant:
  - the problem being solved
  - the user-facing behavior
  - the core design or architecture
  - important constraints and non-goals
  - configuration, limits, and failure modes
  - operational expectations
- Update documentation when the mental model, API, behavior, configuration, or
  operational workflow changes.
- Keep docs, examples, tests, and comments consistent with the code.
- Treat stale documentation as a bug.
- Record important non-obvious tradeoffs and non-goals.
- Do not leave vague TODOs. A TODO should include enough context to know what is
  missing and what would justify removing it.

## Dependencies and generated files
- Prefer existing dependencies and standard library tools over adding new
  dependencies.
- New dependencies should be justified by clear value.
- Separate dependency changes from behavioral changes when practical.
- Do not hand-edit generated files unless that is the established workflow.
- When generated artifacts change, update the source of truth and regenerate
  them in a clear, reviewable step.
- Note the generator or command when it is not obvious.

## Security and safety
- Treat external input as untrusted.
- Validate at boundaries.
- Prefer safe defaults.
- Minimize privileges and data exposure.
- Be careful with auth, permissions, secrets, filesystem access, subprocess use,
  and network access.
- Do not add insecure convenience behavior without calling it out explicitly.

## Terminal and tooling
- Prefer non-interactive commands and explicit flags over prompts.
- Avoid interactive pagers in agent-driven workflows.
- Prefer repository-aware tools such as `rg` where available.
- Use `git --no-pager diff` or equivalent when a pager would interfere.

## Commit hygiene
- Never use `--no-verify` when committing.
- Commit messages should explain why the change is needed, not merely what
  changed.
- Commit bodies should be cohesive prose, not a series of isolated one-sentence
  paragraphs. Do not put a blank line after every sentence.
- The first body paragraph should explain the problem, motivation, or constraint
  that makes the change necessary. If the body only restates what the diff does,
  rewrite it before committing.
- Subsequent body paragraphs should group related rationale, tradeoffs,
  compatibility notes, risks, or intentionally deferred work. Avoid converting
  the commit plan's checklist fields into separate sentence-per-field
  paragraphs.
- Use `subsystem: short description` subject lines when appropriate for the repo.
- Wrap commit-message bodies cleanly.
- Default to the ideal 50/72 rule for commit formatting unless the repository
  clearly uses a different local convention:
  - concise subject, ideally within 50 characters
  - blank line
  - explanatory body wrapped at about 72 columns
- Use `$git-commit` for creating, amending, rewording, squashing, or
  fixup-folding commits.
- Agent-created commits must write the message under `.tmp/`, preview it, use
  a file-based commit path such as `git commit -F <message-file>`, and delete
  the temporary message file after a successful commit.
- Do not use `git commit -m`, including multiple `-m` flags, for
  agent-created commits. Git will not wrap long `-m` arguments, and shell
  escaping makes multi-paragraph bodies easy to corrupt.
- Before finalizing a commit, ensure the message preview contains real wrapped
  lines and no literal `\n` sequences.
- Do not add assistant attribution trailers unless explicitly requested.

For docs/plans commits, prefer specific subjects such as:
- `docs/plans: add <topic> design`
- `docs/plans: revise <topic> design`
- `docs/plans: clarify <topic> invariants`

For docs/execution commits, prefer specific subjects such as:
- `docs/execution: add <topic> execution plan`
- `docs/execution: revise <topic> execution plan`
- `docs/execution: update <topic> series checkpoints`

Avoid vague subjects such as `update docs` or `fix plan`.

## History polishing
`$polish-series` is an optional local-history cleanup step after execution is
stable. It may fold later docs/plans or docs/execution update commits back into
one clean docs commit and squash obvious tiny fixups when safe. The rewrite
target should follow the repository or nearest-`AGENTS.md` commit-hygiene
rules, falling back to kernel-style formatting when no more specific convention
exists.

It is not part of core execution correctness and should not be used to hide
ambiguous or still-changing implementation history.

## Repo respect
- Follow the repository’s formatter, linter, test, and naming conventions.
- Match local idioms unless those idioms are part of the problem being solved.
- When no convention exists, choose the simplest rule and apply it consistently.
- Keep the tree easier to understand than you found it.

## Communication
Before presenting non-trivial work back to the user, perform at least one
explicit skeptical review pass over the result.

Scale the review to the difficulty and risk of the problem:
- for straightforward work, do one skeptical review pass for correctness,
  completeness, and instruction-following
- for harder, riskier, or more ambiguous work, do additional passes before
  handoff; re-check assumptions, edge cases, verification quality, and whether
  the presented answer actually solves the user’s problem cleanly
- do not present the first plausible answer when another review pass would
  likely catch mistakes, weak reasoning, or avoidable gaps
- stop iterating when another pass is unlikely to materially improve
  correctness, completeness, or clarity
- do not iterate indefinitely; if remaining uncertainty is structural or cannot
  be resolved locally, surface it explicitly instead of spinning

When presenting a non-trivial implementation, include:
- the problem statement
- the constraints and invariants
- the plan
- the commit stack
- what was validated
- what remains uncertain
- any questions that materially affect correctness, API shape, migration, or
  reviewability

Commit messages and change summaries should make clear whether a step is:
- preparatory
- semantic
- optimization
- follow-up
- documentation

## Policy maintenance
- After a correction that reflects a recurring mistake or category of mistake,
  propose an update to this file so the mistake is less likely to repeat.

## Default quality bar
A change is in good shape when:
- the problem is clearly stated
- the contract is explicit
- the commit stack is reviewable
- at least one explicit skeptical review pass has been completed before
  handoff, with additional passes for harder problems when they are still
  likely to improve the result
- new primitives have tests
- correctness-facing changes are separate from optimization-facing changes
- validation matches the risk
- docs match reality
- the worktree remains respectful of existing user changes
