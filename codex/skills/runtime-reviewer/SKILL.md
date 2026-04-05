---
name: runtime-reviewer
description: Review an implemented series for lifecycle, background-work, queueing, cancellation, shutdown, removal, and public-status/progress truthfulness risks. Use as a focused reviewer lens under series-reviewer.
---

# Runtime Reviewer

Review the implemented series for operational and lifecycle coherence.

This is a narrow reviewer lens, not a standalone workflow. It is best used
under `series-reviewer`.

## Focus
Check these directly when relevant:
- can request-path work accidentally block on background work
- can queued or deferred work make public status misleading
- can removed or shutdown entities still publish, mutate shared state, or
  complete late in unsafe ways
- are cancellation, retry, shutdown, and removal rules coherent in practice
- are progress signals truthful enough for their intended audience

## Output format

Findings
- Ordered by severity. Use `none` if there are no findings.

Lifecycle risks
- ...

Status/progress risks
- ...

Residual risks
- ...
