---
name: review-plan
description: Skeptically review product, roadmap, or design planning artifacts before asking the user to approve the next workflow action. Use automatically after product before roadmap, after roadmap before design, and after design before plan-series to test scope, milestones, state boundaries, ownership, invariants, and readiness without starting the next action.
---

# Review Plan

Review whether the proposed planning artifact is coherent enough to ask for
approval to start the next workflow phase.

This skill is intentionally skeptical. Its job is not to invent new product
scope, roadmap slices, or design structure from scratch. Its job is to test
whether the artifact is clear enough to constrain the next planning or
execution-planning step without hidden ambiguity. A `ready` result is not
approval to start that next step.

## When to use this
Use this skill when:
- a product artifact exists and roadmap planning depends on it
- a roadmap artifact exists and design planning depends on it
- an approved or near-approved design exists and series planning depends on it
- the work introduces or changes data models, ownership boundaries, or APIs
- the user wants a skeptical planning review before moving to the next phase

Do not use this skill when:
- there is no product, roadmap, or design artifact to review
- the task is small enough that no product, roadmap, or design artifact is
  needed and series planning is enough
- the user wants diff review of implemented code

This skill works best while native plan mode is still on.

## Goal
Answer one question:

Is this artifact coherent enough to ask the user to approve the next phase?

The outcome must be one of:
- `ready for roadmap`
- `ready for design`
- `ready for series planning`
- `needs product revision`
- `needs roadmap revision`
- `needs design revision`

## Review lens

For product review, check:
- target audience or operator
- core user journeys
- release slices and first shippable slice
- integration expectations
- in-scope versus out-of-scope boundaries
- whether roadmap would still need to invent product truth

For roadmap review, check:
- product context preservation, when a product artifact exists
- component, capability, and integration slices
- milestone exits and dependency ordering
- design-doc backlog boundaries
- first vertical slice, when app or product work is involved
- whether design would still need to invent roadmap truth

For design review, check:
- source of truth
- authoritative versus cached versus derived state
- data structure choices
- lifecycle and ownership
- API boundary clarity
- invariants
- illegal states and ambiguity
- whether the boundaries support high-signal regression, functional, or
  integration testing

When relevant, also ask whether the operational truth is coherent enough:
- can public status misrepresent queued or deferred work
- can removed or shutdown entities still publish or mutate shared state
- can request handlers accidentally block on background work
- are progress signals truthful enough for their intended audience

This is a review, not a redesign session. If the model is weak, say so directly
and point to the smallest revision needed.

## Process

1. Identify the review mode
- State whether this is `product review`, `roadmap review`, or `design review`.

2. Restate the proposed artifact
- Summarize the artifact and upstream context briefly so the review has a clear
  target.

3. For product review, check product boundaries
- Confirm audience, journeys, release slices, integration expectations, and
  non-goals are explicit enough to constrain roadmap planning.
- Skip this step when the target is not product.

4. For roadmap review, check roadmap boundaries
- Confirm slices, milestones, dependencies, and design-doc backlog are explicit
  enough to constrain design planning.
- Skip this step when the target is not roadmap.

5. For design review, check source of truth
- Identify the authoritative state.
- Flag any place where cached or derived state appears to drive correctness
  implicitly.
- Skip this and the remaining design-only checks when the target is not design.

6. Check structure choices
- Are the proposed data structures aligned with the invariants?
- Are important distinctions encoded explicitly rather than by convention?

7. Check ownership and lifecycle
- Who creates, owns, mutates, and discards each important piece of state?
- Are state transitions and update paths clear?

8. Check API boundaries
- Are inputs, outputs, failure modes, and responsibilities explicit enough for
  implementation and review?

9. Check illegal states
- Which invalid combinations are impossible by structure?
- Which remain possible and require explicit handling?

10. Check validation shape
- Would the proposed boundaries support regression, functional, or integration
  tests at the right layer?
- Are unit tests being forced by the structure rather than chosen because they
  match the contract?

11. Check operational truth when relevant
- For async, concurrent, stateful, background, or operator-facing systems,
  check whether lifecycle and public-status behavior are explicit enough.
- Only apply this lens when the system actually has these concerns.

12. Decide readiness
- For product review, return `ready for roadmap` or `needs product revision`.
- For roadmap review, return `ready for design` or `needs roadmap revision`.
- For design review, return `ready for series planning` or
  `needs design revision`.
- If the target is a design doc and it is ready, the design doc should be able
  to carry `Status: approved`.
- A `ready` result should recommend asking the user for explicit approval for
  the next action. Do not start `$roadmap`, `design`, or `$plan-series` from
  this skill.

## Output format

Review target
- ...

Review mode
- `product review`
- `roadmap review`
- `design review`

Planning inputs
- `product: ...`
- `roadmap: ...`
- `design docs: ...`

Findings
- ...

Product scope check
- Use `not applicable` unless this is product review.

Roadmap boundary check
- Use `not applicable` unless this is roadmap review.

Source of truth check
- Use `not applicable` unless this is design review.

State boundary check
- Use `not applicable` unless this is design review.

Data structure check
- Use `not applicable` unless this is design review.

Ownership and lifecycle check
- Use `not applicable` unless this is design review.

API boundary check
- Use `not applicable` unless this is design review.

Invariant check
- Use `not applicable` unless this is design review.

Testability check
- Use `not applicable` unless this is design review.

Blocking issues
- Use `none` if there are no blockers.

Ready criteria
- ...

Design doc status
- `draft` | `approved` | `superseded`
- Use this section only when the review target is a design doc.
- Use `approved` only when the review result is `ready for series planning`.

Result
- `ready for roadmap`
- `ready for design`
- `ready for series planning`
- `needs product revision`
- `needs roadmap revision`
- `needs design revision`

Recommended next step
- Ask the user whether to approve the next action, such as `$roadmap`,
  `design`, or `$plan-series`, when the result is ready.

## Exit criteria for “ready”
Only return `ready for roadmap` when:
- audience, journeys, release slices, and integration expectations are clear
- roadmap can decompose the work without inventing product scope
- non-goals and deferred slices are explicit enough to prevent scope creep

Only return `ready for design` when:
- roadmap slices, milestones, dependencies, and exits are clear
- design-doc backlog boundaries are concrete enough to choose the next design
- design can proceed without inventing milestone or slice truth

Only return `ready for series planning` when:
- authoritative, cached, and derived state are clearly separated
- core structures can express the intended invariants
- ownership and lifecycle are not ambiguous
- API boundaries are concrete enough to stage in commits
- testing can target the real contract at the right layer
- and, when operational concerns are relevant, lifecycle and public-status
  contracts are explicit enough not to mislead implementers or operators

## What this skill does not do
- It does not produce a commit stack.
- It does not write code.
- It does not turn into open-ended brainstorming.
- It does not paper over structural ambiguity with “implementation details”.
