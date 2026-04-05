---
name: review-plan
description: Skeptically review an approved or near-approved design to decide whether its data model, state boundaries, ownership, and invariants are coherent enough for implementation. Use after design and before series planning.
---

# Review Plan

Review whether the proposed plan and design are coherent enough to implement
before execution starts.

This skill is intentionally skeptical. Its job is not to invent a new design
from scratch. Its job is to test whether the proposed plan and model are
coherent enough to implement without hidden ambiguity.

## When to use this
Use this skill when:
- an approved or near-approved design already exists
- the work introduces or changes data models, ownership boundaries, or APIs
- the user wants a structure-focused review before series planning

Do not use this skill when:
- there is no design artifact to review
- the task is so small that series planning is enough
- the user wants diff review of implemented code

This skill works best while native plan mode is still on.

## Goal
Answer one question:

Is the proposed state and boundary model coherent enough to implement?

The outcome must be one of:
- `ready for series planning`
- `needs design revision`

## Review lens

Review the design against these points:
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

This is a review, not a redesign session. If the design is weak, say so
directly and point to the smallest revision needed.

## Process

1. Restate the proposed model
- Summarize the design’s state shape and boundaries briefly so the review has a
  clear target.

2. Check source of truth
- Identify the authoritative state.
- Flag any place where cached or derived state appears to drive correctness
  implicitly.

3. Check structure choices
- Are the proposed data structures aligned with the invariants?
- Are important distinctions encoded explicitly rather than by convention?

4. Check ownership and lifecycle
- Who creates, owns, mutates, and discards each important piece of state?
- Are state transitions and update paths clear?

5. Check API boundaries
- Are inputs, outputs, failure modes, and responsibilities explicit enough for
  implementation and review?

6. Check illegal states
- Which invalid combinations are impossible by structure?
- Which remain possible and require explicit handling?

7. Check validation shape
- Would the proposed boundaries support regression, functional, or integration
  tests at the right layer?
- Are unit tests being forced by the structure rather than chosen because they
  match the contract?

8. Check operational truth when relevant
- For async, concurrent, stateful, background, or operator-facing systems,
  check whether lifecycle and public-status behavior are explicit enough.
- Only apply this lens when the system actually has these concerns.

9. Decide readiness
- If the model is coherent, say `ready for series planning`.
- Otherwise say `needs design revision` and list the blocking issues.

## Output format

Review target
- ...

Findings
- ...

Source of truth check
- ...

State boundary check
- ...

Data structure check
- ...

Ownership and lifecycle check
- ...

API boundary check
- ...

Invariant check
- ...

Testability check
- ...

Blocking issues
- Use `none` if there are no blockers.

Ready criteria
- ...

Result
- `ready for series planning` | `needs design revision`

Recommended next step
- ...

## Exit criteria for “ready”
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
