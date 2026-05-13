---
name: workflow-house-rules
description: Workflow-specific house rules for Codex planning, execution, review, polish, and finish. Use when a workflow skill needs policy for approval movement, planning artifact commits, current-series boundaries, finish eligibility, or preserving truthful execution history.
---

# Workflow House Rules

These are the workflow-specific rules for Codex planning, execution, review,
polish, and finish. Apply the house rules in `codex/AGENTS.md` alongside these
for general docs, proof, commit-path, and source-ownership policy.

## Rules

### Reviews Advise; Approval Moves
Review skills may return a `ready` result, but a ready review does not start the
next action by itself. Ask the user for explicit approval before moving from
product to roadmap, roadmap to design, design to series planning, execution
review to implementation, or implementation review to closeout.

### Implement The Approved Current Series Only
`$impl-series` executes the approved current execution series. Do not continue
into a later series unless that later continuation is explicitly approved by
the user or already approved in the execution contract.

### Finish Requires Finish Approval
The implementation review gate can say the implemented series is acceptable,
but that does not authorize `$finish-series`. Mark a series finished only when
the user explicitly approves closeout, either before implementation or after
reviewing the implementation and review result.

### Parallel Review Is A Synthesis Tool
Parallel review uses subagents as context reducers and focused reviewer lenses.
It may run only when the user explicitly asks for subagents or parallel review,
or when the user approves an execution contract whose implementation review mode
is `parallel-deep`.

Reviewer subagents are read-only by default. Use the smallest useful lens set,
and keep the parent agent responsible for final synthesis, severity ordering,
coverage checks, and verdict. Do not concatenate competing reviewer reports.

Each reviewer report must state:
- scope inspected
- exact file or symbol references for findings
- blockers
- non-blocking findings
- unknowns or assumptions
- commands run
- residual risk

### Planning Artifacts Stay Together
When active `docs/plans/...` and `docs/execution/...` changes describe the same
planning state or approval boundary, commit them together. Approval state may
be written into the working tree before `$impl-series`, but do not create a
standalone approval-only commit; include it in the first implementation-series
commit, usually the planning-artifacts anchor.

### Documentation Lifetimes
Durable documentation is part of the current system contract. Keep `AGENTS.md`,
README files, architecture docs, operator or setup docs, API or configuration
docs, and other reference docs truthful at every commit. They may describe
accepted future goals when clearly labeled that way, but current-state
descriptions must match the checkout.

Working artifacts coordinate a change in flight. Product briefs, roadmaps,
design docs, `docs/plans/...`, and `docs/execution/...` must be accurate for
the phase or series they govern, including approval state and discovered plan
changes. They are not general current-state architecture references unless
their durable conclusions are promoted into the appropriate reference docs.

Rule of thumb: if a reader might use the doc to operate, extend, review, or use
the repo outside the active change series, treat it as durable and keep it
always current. If the doc only explains what this change intends, why the
series is staged a certain way, or what remains in the current execution, treat
it as a working artifact. Mark completed or superseded working artifacts when
they could otherwise be mistaken for current guidance.

### Preserve Truth Before Polish
During `$impl-series`, preserve truthful execution history. If implementation
reveals a meaningful plan change after code commits exist, record it as a new
docs update commit instead of silently rewriting the original approved artifact.
Use `$polish-series` later, after the series is stable, to fold safe docs or
fixup history when that improves final review.

## How To Apply
- Planning skills should make these rules visible in boundaries and approval
  handoffs without duplicating the rule bodies.
- Review skills should flag violations and may apply small non-structural
  wording fixes when their own skill allows minor amendments.
- Implementation skills should check these rules before each commit and before
  any finish-series handoff.
