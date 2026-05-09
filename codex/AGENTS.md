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
- Native `/plan` is optional. It is useful for lightweight planning discussion,
  but durable docs become the source of truth once work is large enough to need
  them. Once a roadmap, design doc, or execution doc exists for the effort,
  chat should not quietly replace that artifact as the source of truth.
- For bugfixes, reproduce the bug or define regression evidence first; use a
  short design note only when the fix shape is not obvious.
- Use the lightest workflow skills that fit the risk and ambiguity. The
  workflow source of truth is split by responsibility:
  - `codex/AGENTS.md` is the always-loaded baseline.
  - The house rules below are always loaded and apply to all agent work.
  - `$workflow-house-rules` owns workflow-specific policy: approval movement,
    current-series boundaries, planning-artifact commits, finish eligibility,
    and truthful execution history.
  - `$product`, `$roadmap`, `$design`, and `$review-plan` own product and
    architecture planning.
  - `$plan-series` and `$review-execution` own execution planning.
  - `$impl-series`, `$review-series`, `$polish-series`, and `$finish-series`
    own implementation, review, history cleanup, and closeout.
  - `$git-commit` owns commit-message mechanics.
- Do not duplicate detailed workflow procedure in this file. Update the owning
  skill when a workflow rule changes.

## House rules
- Docs stay truthful. Keep architecture docs, README, AGENTS.md, operator docs,
  and workflow/config docs accurate as behavior, setup, commands, or agent
  expectations change. Future-state or vision sections are fine when clearly
  labeled, but current-state and prior-state descriptions must not become false.
- Proof travels with behavior. Keep tests or equivalent proof with the commit
  that introduces the behavior they prove. Separate proof commits are
  acceptable only when they define a standalone primitive or contract boundary,
  provide a large final integration scenario whose separation materially
  improves review, or are otherwise independently useful.
- Source topology is architecture. For non-trivial code changes, check whether
  new behavior is landing in the correct owning module or merely in the nearest
  existing file. Before adding substantial behavior to a large file or crowded
  directory, name the owner that should contain it. Split by responsibility
  when a coherent owner can be named, but do not force premature abstraction or
  split tiny files that still represent one idea.
- When source topology or repository shape is in question, consider checking
  `~/workplace/llm-wiki/wiki/topics/project-bootstrap/source-topology.md`,
  `~/workplace/llm-wiki/wiki/topics/project-bootstrap/repo-shape.md`, and
  relevant project notes such as `wiki/projects/nbd-server.md` for doctrine and
  examples. Keep those long examples in the wiki rather than duplicating them
  here.
- Use `$git-commit` for creating, amending, rewording, squashing, or
  fixup-folding commits. Agent-created commits must use a file-based message
  path and must not use `git commit -m`. `$git-commit` owns the exact `.tmp`
  file, preview, 50/72, amend, reword, squash, fixup, and cleanup mechanics.
- Keep one owning source. When a rule or workflow behavior changes, update the
  owning source first and replace duplicated copies with pointers. Keep
  `AGENTS.md` as baseline behavior, skills as procedural authorities, and index
  files as maps rather than parallel policy documents.

## Planning model
Keep architecture/design planning distinct from execution planning:
- Architecture/design planning settles product scope, roadmap slices, data
  model, API shape, source/module topology, ownership, invariants, and rollout.
- Execution planning stages the approved shape into commits, verification,
  review gates, and series checkpoints.

If architecture is still unclear, do not jump straight to `$plan-series`. Use
the relevant product, roadmap, design, and review-plan skills first. Once
`$plan-series` produces a candidate execution contract, run
`$review-execution` before `$impl-series`. Tiny obvious work should be
implemented without the series workflow rather than creating a candidate
execution contract without review.

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
Prefer commit stacks that separate concerns while keeping proof and
documentation with the behavior that needs them. Treat this as a dependency
ordering heuristic, not as a requirement to create separate test or docs
commits:

1. preparatory cleanup or code motion
2. primitive / helper / API introduction, with contract proof when useful
3. adoption by callers or behavior changes, with regression or functional proof
4. performance optimizations behind an established and proven boundary
5. cleanup or docs-only work that is independently true and reviewable

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
- Follow the house rule that proof travels with behavior instead of defaulting
  to trailing test-only commits.
- Do not move tests or docs later just to match the outline above; if they are
  needed to make the current commit correct, truthful, or reviewable, they
  belong in that commit.

## Primitive-first development
- When introducing a new primitive, helper, abstraction, or API boundary,
  include the proof needed to make its contract clear.
- Proof should define what the primitive guarantees as it is introduced.
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
- source/module topology reflects named ownership boundaries
- ownership and lifecycle are coherent
- API boundaries are concrete enough to implement
- invariants and illegal states are explicit
- edge adapter types stay at boundaries instead of leaking into core code
- root facades are used for compatibility, while internal imports prefer
  owning modules
- the chosen boundaries support high-signal regression, functional, or
  integration testing

Execution should not casually reopen architecture after design and structure
review are approved. Reopen it only when implementation exposes a real mismatch.
For non-trivial code changes, include this source-topology checkpoint before
handoff: "Did this change leave a file or directory as the obvious dumping
ground for the next unrelated feature?"

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
- Follow the house rule that docs stay truthful for current-state architecture,
  README, AGENTS.md, operator, and workflow/config documentation.
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
- Use `$git-commit` for creating, amending, rewording, squashing, or
  fixup-folding commits. It is the canonical source for file-based commit
  mechanics, 50/72 formatting, `.tmp` message files, and avoiding
  `git commit -m`.
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
- Use specific docs subjects when committing planning artifacts. Avoid vague
  subjects such as `update docs` or `fix plan`.
- Apply `$workflow-house-rules` for workflow planning-artifact commit
  boundaries.
- Do not add assistant attribution trailers unless explicitly requested.

## History polishing
Use `$polish-series` for optional local-history cleanup after execution is
stable. Do not use polishing to hide ambiguous or still-changing implementation
history.

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
