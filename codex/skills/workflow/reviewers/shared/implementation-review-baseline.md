# Implementation Review Baseline

This baseline is the minimum bar for reviewing an implemented series. Both
`$review-series` and `$series-reviewer` must satisfy it. Deep or parallel review
may add lens-specific depth, but it must not replace or weaken this baseline.

Use this file as the shared contract. Keep detailed engineering doctrine in
`~/workplace/llm-wiki` and load the relevant page when the diff touches that
primitive or risk area.

## Baseline Checks

1. Contract alignment
- Compare the diff against the approved design, execution contract, commit
  postconditions, and `Not included` scope.
- Flag hidden semantic drift, unplanned API changes, or scope creep.

2. Invariants and source of truth
- Check that the implementation preserves the stated invariants.
- Confirm authoritative, cached, derived, and advisory state remain distinct.
- Treat correctness that depends silently on stale hints or derived state as a
  finding unless the approved contract explicitly allows it.

3. Source topology and ownership
- Confirm substantial behavior landed in the named owning module rather than
  the nearest broad file or crowded directory.
- Check whether new or changed files leave an obvious dumping ground for the
  next unrelated feature.
- Keep edge adapter types at boundaries, and prefer owning-module imports for
  internal code.

4. API and boundary drift
- Check inputs, outputs, failure modes, optionality, ownership, and lifecycle
  behavior against the approved contract.
- Flag compatibility or migration changes that appear in the diff without being
  staged in the execution contract.

5. Evidence and proof quality
- Confirm proof travels with the behavior it proves.
- Check that tests or equivalent evidence exercise the real contract at the
  right layer.
- Flag mock-heavy, low-signal, or implementation-restating tests when a smaller
  boundary-level proof would be stronger.

6. Documentation truth
- Check durable docs, operator docs, README files, examples, and workflow docs
  touched by the series for current-state truth.
- Working artifacts may describe the active change, but they must not be
  mistaken for durable current-state guidance after the series moves on.

7. Claims and measurements
- Require concrete support for performance, reliability, migration, or
  concurrency claims.
- Distinguish measured results from structural arguments and from speculation.

8. Residual risk and verdict
- Return findings first, ordered by severity.
- State open questions, residual risks, and whether the series is acceptable,
  acceptable with follow-up, or not ready.

## Wiki Routing

Load these llm-wiki pages as needed instead of copying their full doctrine into
reviewer skills:

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
