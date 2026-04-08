---
name: roadmap
description: Map a large feature, migration, refactor, or product initiative into components, integration slices, milestone targets, dependencies, and a design-doc backlog before detailed design begins. Use when one design doc is too coarse and the work needs an ordered roadmap of what must be designed next.
---

# Roadmap

Produce the roadmap artifact that says what technical slices exist, how they
relate, and which ones need dedicated design work before implementation.

This skill sits above `design`. It is for large work where a single design pass
is too coarse because the problem spans multiple components, multiple maturity
levels, or multiple milestones.

When a `docs/products/...` doc exists, this skill consumes that product artifact
as the source of truth for user journeys, release slices, and integration
expectations. It should not silently redefine those product decisions.

## When to use this
Use this skill when:
- the task is a large feature, migration, rewrite, or refactor spanning
  multiple components or subsystems
- the task is a product initiative that already has enough product definition to
  decompose technically
- one design doc would be too coarse to manage the work safely
- the work needs milestone sequencing such as `m1`, `m2`, `m3`
- individual components may have `v1`, `v2`, `v3` slices that land in different
  milestones
- you need to decide which slices deserve dedicated `docs/plans/...` design
  docs before implementation
- the roadmap may produce a real multi-item design backlog rather than one
  immediate design path

Do not use this skill when:
- the task is small enough for a single `design` pass
- the architecture is already decomposed and the only remaining job is staging
  commits
- the user only wants implementation planning

This skill works best while native plan mode is on.

## Goal
Answer these questions before detailed design begins:
- what product input constrains this roadmap, when a product doc exists
- what are the important components or capability areas
- what cross-cutting integration slices must work as one user-visible flow
- what maturity or parity slices exist for each component
- which slices belong in which milestone
- what the first shippable vertical slice is, when the work is app- or
  product-like
- what dependencies constrain milestone ordering
- which slices need dedicated design docs
- what should be designed next

The output should let the workflow move from one vague large objective into a
small set of explicit design tasks.

If the roadmap produces a genuine multi-item design backlog, this skill should
usually write or update a roadmap doc under `docs/roadmaps/` so the component
map, milestone map, and design backlog stay explicit across sessions.

If the roadmap only sharpens one immediate design path, an in-chat roadmap is
usually enough.

## Principles

1. Milestone-first, not component-only
- A component may span multiple milestones.
- A milestone may include slices from multiple components.

2. Discover slices, not just modules
- Model the work as component-version or capability-version slices.
- For parity migrations, make parity targets explicit per slice.
- Distinguish component slices from integration slices when that helps.

3. Use slice lenses when they help
- For large features, migrations, refactors, rewrites, or other multi-phase
  work, it is often useful to distinguish among:
  - correctness or contract slices
  - operational or lifecycle slices
  - optimization or performance slices
- This is a helpful lens, not a required taxonomy.

4. Design backlog, not execution backlog
- This skill identifies what needs design.
- It does not produce the final implementation series.

5. Keep the roadmap lightweight
- Prefer a small number of meaningful milestones.
- Prefer a focused design-doc backlog over exhaustive decomposition theater.
- The point is to notice when one umbrella design doc is too coarse and should
  split into a clearer backlog, not to classify every slice exhaustively.

6. Stop before detailed design
- Do not invent detailed data models or APIs for every slice here.
- That belongs in `design`.
- Do not drift into detailed execution planning here either.

## Process

1. State the objective
- Define the overall outcome, such as migration, parity goal, or staged feature
  rollout.

2. Read the product input when it exists
- Identify the target journeys, release slices, and integration expectations
  that the roadmap must preserve.

3. Identify components or capability areas
- Group the work into meaningful areas with distinct responsibilities or
  contracts.

4. Define slices
- Identify both:
  - component slices
  - integration slices
- For each slice, identify the meaningful stage such as `v1`, `v2`, `v3`,
  parity stage, bridge stage, or rollout stage.

5. Build the milestone map
- Assign slices to milestones such as `m1`, `m2`, `m3`.
- A later version of one component may land after earlier versions of other
  components.
- When the work is product-driven, make milestone exits user-meaningful rather
  than purely technical.

6. Identify dependencies
- Record what must exist before another slice can be designed or implemented.
- Focus on real constraints, not tidy but fake sequencing.

7. Identify parity and validation requirements
- When relevant, call out slices that need explicit compatibility, validation,
  regression, or operator-facing proof.

8. Identify the first shippable vertical slice when relevant
- For app or product work, make explicit the first end-to-end slice that proves
  the product loop.

9. Build the design-doc backlog
- Decide which slices need dedicated `docs/plans/YYYY-MM-DD-topic.md` design
  docs.
- Distinguish component-local design docs from integration design docs.
- Decide which slices can remain sections in an umbrella roadmap or umbrella
  design doc.

If this roadmap should be saved to disk, use a dated filename such as:
- `docs/roadmaps/YYYY-MM-DD-topic.md`

10. Recommend the next design steps
- End with the smallest set of next design tasks that would unblock progress.

## Output format

Produce the roadmap artifact using
`codex/skills/roadmap/TEMPLATE.md` as a starting point:

- keep the milestone, dependency, and design-backlog structure
- adapt the shape when the work needs a simpler or more focused roadmap
- do not force every section when it would add ceremony without clarity

Product input
- Use `not needed` when there is no product doc.

Objective
- ...

Scope and assumptions
- ...

Components / capability areas
- ...

Slice matrix
- Use rows like
  `<slice type> | <component or integration> | <slice> | <goal> | <parity target or maturity>`.

Milestone map
- Use rows like `<milestone> | <included slices> | <exit condition>`.

Dependencies
- Use rows like `<slice> -> <depends on> | <why>`.

Parity / migration requirements
- Use `not applicable` when irrelevant.

First shippable slice
- Use `not needed` when the work is not app- or product-like.

Design-doc backlog
- For each item, say:
  - slice or topic
  - slice type: component | integration
  - dedicated design doc required: yes | no
  - suggested doc path if yes
  - why it needs dedicated design

Risk hotspots
- ...

What not to design yet
- ...

Recommended next design tasks
- Ordered list of the next `design` calls or plan-doc drafts to create.

Roadmap exit criteria
- ...

## Quality bar
The roadmap is not ready if:
- components are listed without meaningful slice definitions
- integration slices are missing for work that depends on cross-cutting
  user-visible flows
- milestones exist but do not have exit conditions
- dependencies are mostly implied rather than stated
- operationally meaningful slices are hidden inside an over-broad umbrella item
- everything is marked as needing a dedicated design doc
- the roadmap drifts into detailed API design for every slice

## What this skill does not do
- It does not replace `$product`.
- It does not replace `design`.
- It does not produce a series plan.
- It does not write code.
- It does not require subagents.
- It does not force one design doc per component.
- It does not pretend milestones are strictly component-by-component when they
  are not.
