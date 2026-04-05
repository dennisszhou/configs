# Codex Workflow

This is a small local workflow for turning vague engineering work into an
approved design, an approved execution contract, and a disciplined commit
stack.

The workflow is intentionally narrow:
- native plan mode is for early design thinking only
- local skills define the artifacts that must be reviewed and approved
- execution should not casually reopen architecture once design is approved
- roadmap work is optional and only for multi-component or milestone-driven work

## Lanes

### Feature or refactor lane
Use this for non-trivial features, refactors, migrations, or anything where the
API, data model, or rollout shape is not already obvious.

1. Turn native plan mode on.
2. Run `$design <task>`.
3. Review and approve the design.
4. Run `$review-plan`.
5. Review and approve the structure review result.
6. Turn native plan mode off.
7. Run `$plan-series`.
8. Review and approve the series plan.
9. Run `$impl-series`.

For large migrations, rewrites, or milestone-driven work, insert `$roadmap`
before `$design`.

### Trivial lane
Use this for small, obvious changes where the design and data shape are already
clear from the task and existing code.

1. Run `$plan-series`.
2. Review and approve the series plan.
3. Run `$impl-series`.

If series planning reveals unclear architecture, stop and move back to the
feature/refactor lane.

### Bugfix lane
Use this when the main job is to restore an existing contract.

1. Reproduce the bug or define concrete regression evidence.
2. Write a short design note only if the root cause or fix shape is not obvious.
3. Run `$plan-series`.
4. Review and approve the series plan.
5. Run `$impl-series`.

For high-risk bugfixes, use the full feature/refactor lane.

## Skill Boundaries

`$design`
- Design and architecture only.
- Produces the proposed end state, data model or API shape, invariants, risks,
  and validation strategy.
- Stops for approval.
- Does not write code or produce a commit stack.

`$roadmap`
- Discovers components, slices, milestones, dependencies, and the design-doc
  backlog for large work.
- Use it when one design doc would be too coarse.
- Stops before detailed per-slice design.

`$review-plan`
- Skeptical review of the proposed design shape.
- Checks source of truth, authoritative versus cached versus derived state,
  ownership, lifecycle, API boundaries, invariants, and testability.
- Ends with either `ready for series planning` or `needs design revision`.

`$plan-series`
- Turns an approved design or otherwise settled task into atomic,
  independently-correct commits.
- Each commit must include concrete verification, `Invariant focus`,
  `Test level`, and `Review gate`.

`$impl-series`
- Executes the approved series plan as an execution contract.
- Anchors an approved active `docs/plans/...` file as the first execution
  commit when one exists and is not yet committed on the branch.
- Verifies every commit before committing.
- Stops on real mismatches, not on every boundary.

`$review-series`
- Skeptical code review for risky semantic, optimization, migration, or
  reliability-sensitive commits.
- Optional by default; use it selectively where the series plan calls for a
  review gate.

`$series-reviewer`
- Optional advanced review mode for larger or riskier series.
- Synthesizes a small set of focused reviewer lenses, currently correctness,
  runtime, and performance when relevant.
- Invocation of this skill authorizes the reviewer subagents it needs.
- Not part of the default workflow.

`$polish-series`
- Optional local-history cleanup after execution is stable.
- Can fold later `docs/plans` update commits back into one clean docs/plans
  commit and squash tiny obvious fixups when safe.
- Not part of core execution correctness.

## Plan Mode

Keep native plan mode on through:
- `$roadmap`
- `$design`
- design revisions
- `$review-plan`

Turn native plan mode off before:
- `$plan-series`
- `$impl-series`

The point is simple: plan mode helps early reasoning, but approved local
artifacts define the real contract. Once design and structure review are
approved, execution should stay tight.

## Approval Boundaries

Approval is required after:
- `$roadmap` when used
- `$design`
- `$review-plan` when it says `ready for series planning`
- `$plan-series`

`$impl-series` may proceed through the approved stack without asking between
commits. Stop only when:
- the plan no longer matches reality
- verification fails in a way that needs out-of-scope changes
- a meaningful design choice reappears
- scope expands beyond minor mechanical changes

Use `$review-series` during execution only where the plan says a commit has a real
review gate such as `code`, `perf`, or `migration`.

If an approved active `docs/plans/...` file exists when execution starts,
`$impl-series` begins by committing that docs/plans file as Commit 1. The plan
doc may still be amended before execution begins. Once implementation commits
exist, meaningful plan updates should usually become new docs/plans update
commits rather than silently rewriting the original plan commit underneath code
history.

After execution is stable, `$polish-series` may fold those later docs/plans
update commits back into one clean docs/plans commit for final review.

## Exit Criteria

Design is ready to approve when:
- the problem and end state are explicit
- constraints and non-goals are clear
- the proposed data model or API shape is concrete
- source of truth and invariants are stated
- rollout or migration is defined when relevant
- the validation strategy matches the real contract

Structure review is ready for series planning when:
- authoritative, cached, and derived state are clearly separated
- ownership and lifecycle are coherent
- API boundaries are implementable without hidden ambiguity
- illegal states are blocked or at least explicit
- the proposed boundaries support high-signal regression, functional, or
  integration testing where appropriate

## Testing Philosophy

Validate every non-trivial change. Use the highest-leverage evidence that
exercises the real contract at reasonable cost.

Prefer regression, functional, or integration tests when behavior lives at a
subsystem boundary. Use unit tests mainly for small, stable, logic-dense
primitives. Do not require TDD. Avoid mock-heavy tests, tests that mostly mirror
implementation, abstractions introduced mainly to make unit tests easier, and
broad low-signal test volume that substitutes for a few good checks.
