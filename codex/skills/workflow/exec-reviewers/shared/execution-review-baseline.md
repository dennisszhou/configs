# Execution Review Baseline

This baseline is the minimum bar for reviewing an execution contract. Both
`$review-execution` and any deeper execution-reviewer path must satisfy it.
Deep or parallel review may add lens-specific depth, but it must not replace
or weaken this baseline.

Use this file as the shared contract. Keep detailed engineering doctrine in
`~/workplace/llm-wiki` and load the relevant page when the execution plan
depends on that primitive or risk area.

## Baseline Checks

1. Planning input and approval state
- Confirm the product, roadmap, design, or user-supplied inputs are explicit
  enough to constrain implementation.
- Check that approval state, current-series state, and finish eligibility are
  not implied only by chat.

2. Design boundary preservation
- Confirm the execution contract stages the approved model instead of reopening
  architecture, API shape, source of truth, rollout semantics, or migration
  policy.
- Return the work to design review when the better execution shape requires
  changing those truths.

3. Series boundaries and checkpoints
- Check that each series boundary creates a stable, reviewable checkpoint.
- Flag arbitrary multi-series splits and single series that are too broad for
  reliable review.

4. Commit atomicity and ordering
- Confirm each commit can stand on its own and has one clear purpose.
- Check that preparation, primitive introduction, adoption, optimization,
  cleanup, and docs are ordered so semantic changes are visible.
- Flag dormant helpers or feature plumbing whose first real use appears only in
  a later commit.

5. Proof placement and evidence shape
- Confirm proof travels with the behavior it proves.
- Check that the chosen evidence exercises the real contract at the right layer
  and is not mainly restating implementation.

6. Verification and review gates
- Confirm verification commands are literal and high-signal for the changed
  contract.
- Check that review gates are placed on risky commits or series boundaries, not
  copied everywhere as checklist metadata.
- Require explicit authorization before any parallel reviewer subagents are
  part of the execution-review path.

7. Source topology and ownership
- Confirm substantial source changes are assigned to named owning modules.
- Check that `not material` topology decisions give a real owner or scope
  reason when source files or directories grow.
- Flag plans that turn a broad file or crowded directory into the next dumping
  ground.

8. Migration, rollback, and dependency ordering
- Check whether compatibility bridges, migrations, rollout order, cleanup, and
  rollback assumptions are staged coherently.
- Flag hidden dependency ordering that could make an intermediate commit
  misleading or unsafe.

9. Documentation truth
- Confirm durable docs, working planning artifacts, execution docs, examples,
  and review instructions stay truthful at every commit where they matter.
- Check that approval, completion, and deferred follow-up state are represented
  in the owning artifact.

10. Residual risk and verdict
- Return findings first, ordered by severity.
- State open questions, residual risks, and whether the execution contract is
  ready for implementation, needs series revision, needs execution-doc
  revision, or needs design revision.

## Wiki Routing

Load these llm-wiki pages as needed instead of copying their full doctrine into
execution-reviewer skills:

- Source topology:
  `~/workplace/llm-wiki/wiki/engineering-guides/project-bootstrap/source-topology.md`
- Testing and proof:
  `~/workplace/llm-wiki/wiki/engineering-guides/systems-primitives/testing-and-proof.md`
- Background work and lifecycle:
  `~/workplace/llm-wiki/wiki/engineering-guides/systems-primitives/background-work-and-lifecycle.md`
- Synchronization:
  `~/workplace/llm-wiki/wiki/engineering-guides/systems-primitives/synchronization.md`
- Caches and derived state:
  `~/workplace/llm-wiki/wiki/engineering-guides/systems-primitives/caches-and-derived-state.md`
- Storage and database shape:
  `~/workplace/llm-wiki/wiki/engineering-guides/systems-primitives/storage-and-database-shape.md`
- Errors and diagnostics:
  `~/workplace/llm-wiki/wiki/engineering-guides/systems-primitives/errors-and-diagnostics.md`

If a relevant wiki page is missing or too weak for the review, say so in
residual risk rather than inventing new durable doctrine inside a reviewer
skill.
