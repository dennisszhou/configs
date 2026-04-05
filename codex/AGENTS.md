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
- For non-trivial features or refactors, prefer this lane:
  1. native `/plan`
  2. `$design`
  3. approval
  4. `$review-structures`
  5. approval
  6. turn plan mode off
  7. `$plan-series`
  8. approval
  9. `$impl-series`
- For trivial work where design is already clear, skip straight to
  `$plan-series` and then `$impl-series`.
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

### 2. Execution planning
Execution planning happens after the architecture or design is already understood
well enough to implement.

Execution planning is about:
- breaking the work into commits
- staging verification
- separating correctness from optimization
- making the work reviewable and bisectable
- choosing the order of implementation

`$plan-series` is a series-planning step, not an architecture-planning
step.

Native plan mode belongs to design work, not commit execution. Keep native plan
mode on through design and structure review, then turn it off before
`$plan-series` and `$impl-series`.

Use `$plan-series` only after one of these is true:
- the design is already clear from the task and existing code
- a design discussion has already settled the approach
- a design doc under `docs/plans/` already exists

If the architecture is still unclear, do not jump straight to `$plan-series`.
First do design planning.

## Planning workflow
Use this workflow for non-trivial work:

1. Determine whether architecture/design planning is needed.
2. If needed, create or update a design doc under `docs/plans/`.
3. Once the solution shape is clear, use `$plan-series` to produce the commit
   sequence.
4. Review and approve the execution plan.
5. Use `$impl-series` to implement the approved commit sequence.
6. If implementation reveals that the design or execution plan is wrong, stop,
   update the relevant plan, and only then continue.

The active `docs/plans/...` file remains mutable during design, structure
review, and series planning. Once `$impl-series` begins:
- if the active approved plan doc is not yet committed on the execution branch,
  commit it first as a docs-only commit
- if only that initial docs/plans commit exists and no implementation commit has
  landed yet, amending it in place is acceptable
- once implementation commits exist, meaningful plan updates should usually be
  recorded as new docs/plans update commits rather than silently rewriting the
  original plan-doc commit underneath code history

## Heuristics
- Small, obvious tasks may not need a written design plan.
- Non-trivial tasks should usually use `$plan-series`.
- Large, ambiguous, multi-step, or multi-session tasks should usually have a
  written design plan under `docs/plans/` before `$plan-series`.

## Important distinction
Do not treat series planning as a substitute for design.

- Design planning decides what to build.
- `$plan-series` decides how to stage building it.
- `$impl-series` executes that staged implementation.

## Approval boundaries
- Present a plan before non-trivial code changes when approval is expected.
- Before committing, show the staged diff and proposed commit message when the
  workflow expects review.
- If an explicit execution workflow has already been approved — for example an
  approved series plan followed by a commit-execution skill — that approval
  authorizes executing the planned commits sequentially until a real question,
  failure, or plan mismatch arises.
- Use selective review gates rather than mandatory review theater on every
  commit. Typical gates are `structures`, `code`, `perf`, and `migration`.
- Stop for approval again when:
  - the plan needs to change materially
  - verification fails in a way that requires out-of-scope changes
  - there are multiple valid implementation choices with meaningful tradeoffs
  - unexpected files or side effects expand the scope

Preserve truthful execution history while work is ongoing. Do not polish the
branch history during `$impl-series`; later docs/plans update commits are
acceptable when the plan changes materially.

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

## Primitive-first development
- When introducing a new primitive, helper, abstraction, or API boundary, also
  introduce tests for its contract.
- Tests should define what the primitive guarantees as it is introduced.
- Prefer to establish the boundary and its tests before layering behavior or
  optimizations on top of it.
- Purely mechanical renames or code motion do not need new tests by themselves,
  but a new primitive usually does.

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
- Do not mark a task complete without verification.
- Flag untested edge cases instead of ignoring them.

## Bug-fix discipline
- Reproduce the bug first when practical.
- Prefer the smallest failing case that still demonstrates the problem.
- Add a regression test for the bug when feasible.
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
- Use `subsystem: short description` subject lines when appropriate for the repo.
- Wrap commit-message bodies cleanly.
- Do not add assistant attribution trailers unless explicitly requested.

For docs/plans commits, prefer specific subjects such as:
- `docs/plans: add <topic> design`
- `docs/plans: revise <topic> design`
- `docs/plans: update <topic> execution plan`
- `docs/plans: clarify <topic> invariants`

Avoid vague subjects such as `update docs` or `fix plan`.

## History polishing
`$polish-series` is an optional local-history cleanup step after execution is
stable. It may fold later docs/plans update commits back into one clean
docs/plans commit and squash obvious tiny fixups when safe.

It is not part of core execution correctness and should not be used to hide
ambiguous or still-changing implementation history.

## Repo respect
- Follow the repository’s formatter, linter, test, and naming conventions.
- Match local idioms unless those idioms are part of the problem being solved.
- When no convention exists, choose the simplest rule and apply it consistently.
- Keep the tree easier to understand than you found it.

## Communication
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
- new primitives have tests
- correctness-facing changes are separate from optimization-facing changes
- validation matches the risk
- docs match reality
- the worktree remains respectful of existing user changes
