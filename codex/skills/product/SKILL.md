---
name: product
description: Produce a product or initiative artifact that defines the target audience, core user journeys, release slices, and major integration expectations before roadmap decomposition begins. Use for new apps, major product initiatives, or broad user-facing efforts where roadmap would otherwise need to invent product scope.
---

# Product

Produce the product artifact that answers what experience should exist, for
whom, and what must feel coherent in the first release slices.

This skill sits above `roadmap`. It is for app or initiative work where
user-facing scope, release slicing, or integration expectations are not yet
clear enough for technical decomposition.

## When to use this
Use this skill when:
- the task is a new app
- the task is a major product initiative
- the work spans multiple user-facing surfaces or subsystems
- roadmap would otherwise need to invent scope, audience, or release slicing

Do not use this skill when:
- the work is a technical migration or refactor with little product ambiguity
- the feature is already well-bounded by existing product context
- one design doc is already enough to define the work safely

This skill works best while native plan mode is on.

## Goal
Answer these questions before roadmap decomposition begins:
- who is this for
- what problem are they trying to solve
- what core user journeys must feel coherent
- what the first shippable slice is
- what later slices are intentionally deferred
- what major integrations must work together for the product to feel real

The output should let the workflow move from a vague app or initiative idea
into a clearer technical roadmap without making roadmap invent product truth.

If the effort is large enough to span multiple sessions or multiple roadmap
slices, this skill should usually write or update a product doc under
`docs/products/`.

## Principles

1. Product first, not subsystem first
- Start from the user or operator experience.
- Do not begin with technical components.

2. Journeys and release slices matter most
- Identify the core loops that must work together.
- Make the first shippable slice explicit.

3. Integration expectations belong here
- Call out where multiple surfaces or subsystems must feel coherent as one
  experience.
- Leave technical decomposition of those integrations to `roadmap`.

4. Stay above design
- Do not define data models, APIs, or ownership here.
- Do not drift into execution planning.

5. Keep it sharp
- Prefer a small number of meaningful journeys and release slices.
- Avoid PRD theater or exhaustive requirement dumps.

## Process

1. State the product objective
- Define the app, initiative, or user-facing outcome.

2. Identify the audience
- Name the primary user, operator, or team this work serves.

3. Define the core user journeys
- Identify the few flows that must work end-to-end.

4. Define release slices
- Make explicit:
  - the first shippable slice
  - later slices
  - what is intentionally deferred

5. Define integration expectations
- Name the surfaces or subsystems that must work together for the experience to
  feel coherent.

6. State success criteria and constraints
- Include what would make this effort meaningfully successful.
- Include constraints and non-goals when they matter.

7. Recommend the next step
- Usually `$roadmap` after approval.

## Output format

Produce the product artifact using
`codex/skills/product/TEMPLATE.md` as a starting point:

- keep the audience, journey, release-slice, and integration structure
- adapt the shape when the work needs a simpler or more focused product brief
- do not turn the template into a giant PRD

## Quality bar
The product artifact is not ready if:
- the audience is vague
- user journeys are implied rather than stated
- the first shippable slice is unclear
- major integration expectations are missing
- roadmap would still need to invent the core experience from scratch

## What this skill does not do
- It does not replace `roadmap`.
- It does not replace `design`.
- It does not define data models or APIs.
- It does not produce a series plan.
- It does not write code.
