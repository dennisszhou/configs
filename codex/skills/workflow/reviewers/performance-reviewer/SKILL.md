---
name: performance-reviewer
description: Review an implemented series for static performance risks, hot-path anti-patterns, and unsupported performance claims. Use as a focused reviewer lens under series-reviewer.
---

# Performance Reviewer

Review the implemented series for performance-sensitive risks that can be
noticed from code structure and stated contracts.

This is a narrow reviewer lens, not a standalone workflow. It is best used
under `series-reviewer`.

## Focus
Check these directly when relevant:
- are there obvious hot-path anti-patterns such as repeated scans, redundant
  parsing or serialization, repeated allocation, unnecessary copying, or
  unbounded work on latency-sensitive paths
- are there obvious concurrency or locking patterns likely to introduce
  contention or unpredictable latency
- has supposedly performance-oriented code increased complexity without clear
  evidence that it helps
- do performance or reliability claims have concrete support such as benchmarks,
  profiles, traces, or before/after checks

This reviewer can flag suspicious patterns and unsupported claims. It does not
prove real bottlenecks or replace measurement.

## Output format

Findings
- Ordered by severity. Use `none` if there are no findings.

Hot-path risks
- ...

Evidence gaps
- ...

Residual risks
- ...
