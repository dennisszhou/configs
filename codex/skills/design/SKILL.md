---
name: design
description: Produce an architecture or design artifact for a feature, refactor, migration, or risky bugfix before execution planning. Use when the solution shape, data model, API boundary, invariants, or rollout is not yet settled.
---

# Design

Produce the design artifact that answers what is being built and why it should
have this shape.

This skill is for architecture and design work. It is not for series planning,
code generation, or implementation.

## When to use this
Use this skill when:
- the task is a non-trivial feature or refactor
- the API, data model, or ownership model is not already obvious
- rollout, migration, or compatibility questions matter
- a bugfix changes behavior enough that the fix shape should be reviewed first

Do not use this skill for:
- trivial changes whose design is already obvious
- series planning
- code review of an existing diff

This skill works best while native plan mode is on.

## Goal
Produce a concrete, reviewable design artifact that can be approved before
series planning begins.

The artifact should make these things hard to miss:
- whether the design is still draft or approved for execution planning
- what problem is being solved
- why this solution shape was chosen
- what the source-of-truth state is
- what data structures or API boundaries will exist
- what invariants must hold
- what operational or lifecycle contracts matter, when they are relevant
- what risks and tradeoffs remain

## Rules

1. Design first
- Decide the solution shape before thinking about commit sequencing.
- Do not generate a commit stack here.

2. Structures belong here
- Propose the data model, ownership model, and API shape here.
- Do not leave the core structure to be invented later during review or coding.

3. Be concrete, not expansive
- Prefer a narrow, implementable design over brainstorming many optional ideas.
- Call out non-goals so the design does not sprawl.

4. Respect plan mode
- Use native plan mode as the place for early reasoning and revisions.
- Stay in design mode until the user approves or requests revision.

5. Stop for approval
- End with explicit design exit criteria and a recommended next step.
- Do not move on to series planning inside this skill.

## Process

1. State the problem and goal
- Make the current pain, missing capability, or broken contract explicit.

2. Identify constraints and non-goals
- Include compatibility, rollout, performance, reliability, or reviewability
  constraints when they matter.

3. Define the end state
- Describe what will be true when the work is done.

4. Propose the shape
- Describe the data model, API boundary, ownership model, and control flow.
- Distinguish source-of-truth state from cached and derived state.
- When relevant, make request-path versus background-path boundaries explicit.

5. State invariants
- List the conditions that must always hold.
- Call out illegal states, ambiguity, or concurrency assumptions when relevant.

6. Make operational and lifecycle contracts explicit when relevant
- For concurrent, async, stateful, or operator-facing systems, include the
  operational contracts that matter to correctness and operability.
- Useful examples include:
  - lifecycle or state-transition summaries
  - startup and shutdown expectations
  - queueing, retries, cancellation, and removal rules
  - public status or progress truthfulness expectations
  - late-completion rules for work that may finish after a user-visible change
- Do not force these sections for simple or purely local changes.

7. Compare alternatives
- Include only the alternatives that materially affected the decision.

8. Describe rollout and validation
- Include migration, compatibility, or staged rollout when relevant.
- Choose validation that matches the actual contract, not default unit-test
  ritual.

9. End with approval criteria
- Say what must be true for the design to be ready for structure review.
- Include explicit status metadata for the plan doc.

## Output format

Produce the design artifact in this shape:

Status
- `draft` while the design is being revised
- `approved` only after the user accepts it and the structure review is ready
  for series planning
- `superseded` only when a newer design replaces it

Problem
- ...

Goal
- ...

Constraints
- ...

Non-goals
- ...

End state
- ...

Proposed approach
- ...

Data model / API shape
- ...

Invariants
- ...

Alternatives considered
- ...

Migration / rollout
- Use `not needed` when irrelevant.

Validation strategy
- ...

Risks
- ...

Open questions
- Use `none` when there are no real open questions.

Design exit criteria
- ...

Recommended next step
- Usually `$review-plan` after approval.

## Quality bar
The design is not ready if:
- the source of truth is vague
- data structures are hand-waved
- invariants are missing
- migration or rollout risk is ignored where relevant
- validation is described only as generic “add tests”

## What this skill does not do
- It does not write code.
- It does not produce a commit stack.
- It does not replace skeptical structure review.
- It does not continue into execution without approval.
