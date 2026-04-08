---
name: polish-series
description: Rewrite a local branch into a cleaner final patch series after execution is stable. Use to fold docs/plans update commits back into one high-quality docs/plans commit, squash obvious tiny fixups, and preserve a reviewable final series without changing intended behavior.
---

# Polish Series

Clean up a local branch history after execution is stable.

This skill is for final local-history cleanup, not for core execution
correctness. Use it after the branch behavior is settled and the truthful
working history has already done its job.

In a staged execution workflow, this skill is typically used after the current
series is complete and stable, before planning or starting the next series.

## When to use this
Use this skill when:
- execution is complete or stable enough that history cleanup will not hide
  ongoing change
- the branch has accumulated multiple `docs/plans` update commits
- or the branch has accumulated `docs/execution` update commits for the same
  active execution artifact
- there are obvious tiny fixup commits that should fold into their parent
- the user wants a cleaner final patch series for review

Do not use this skill when:
- implementation is still actively changing
- the branch history is ambiguous and the intended final series is unclear
- the branch may already be shared or pushed unless the user explicitly says to
  rewrite it

## Goal
Produce a cleaner final patch series without changing the intended final
behavior of the branch.

The common case is:
- preserve one high-quality `docs/plans` commit
- preserve one high-quality `docs/execution` commit when a durable execution
  artifact exists
- preserve the real implementation commits
- fold later `docs/plans` revisions back into that original docs/plans commit
  when appropriate
- fold later `docs/execution` revisions back into that original docs/execution
  commit when appropriate
- fold tiny obvious fixups into their intended parent commits when safe
- normalize the final series to the repository or nearest-`AGENTS.md`
  commit-message style, falling back to kernel-style formatting when no more
  specific convention exists

## Safety model

Safe default:
- assume rewrite is only for local or private branch history

If the branch may be shared or pushed:
- stop and explain the rewrite risk
- do not proceed unless explicitly told to continue

Do not rewrite history if:
- the intended parent for a fixup is ambiguous
- folding commits would collapse independently reviewable semantic changes into a
  blob
- the rewritten series would misrepresent how the branch actually ended up

## Process

1. Inspect the branch history
- Identify the initial `docs/plans` anchoring commit.
- Identify the initial `docs/execution` anchoring commit when one exists.
- Identify later `docs/plans` revise, update, or clarify commits.
- Identify later `docs/execution` revise or update commits.
- Identify tiny obvious fixup commits.

2. Classify candidates
- `docs/plans` follow-up commits that should fold into the original plan commit
- `docs/execution` follow-up commits that should fold into the original
  execution commit
- tiny fixups that obviously belong to a nearby parent
- semantic commits that should remain independent

3. Check rewrite safety
- Confirm the branch is local/private or the user explicitly approved rewrite.
- Confirm the target parent for each fold is unambiguous.
- Confirm final behavior and final docs content are already stable.

4. Propose the final series
- Show which commits should remain.
- Show which commits should be squashed or fixup-folded.
- Explain why each rewrite improves reviewability.

5. Rewrite locally
- Rewrite only when the cleanup is clear and safe.
- Preserve the intended final content.
- Preserve independently reviewable semantic commits.
- When rewording, squashing, or amending commits during cleanup, normalize the
  resulting commit messages to the repository or nearest-`AGENTS.md`
  commit-hygiene rules.
- If there is no more specific local convention, fall back to kernel-style
  formatting:
  - concise subject, usually within 72 characters
  - blank line
  - explanatory body wrapped at about 72 columns

6. Preserve commit-message quality
- Do not let history cleanup degrade a good commit into a subject-only message
  when the original change needs explanatory body text.
- Preserve or improve the `why` in the commit body when folding docs/plans
  updates or obvious fixups into a parent commit.

7. Verify after rewrite
- Re-run the relevant verification needed to confirm the cleaned series still
  lands in the same final state.

## What to fold

Usually good candidates:
- later `docs/plans: revise ...`, `docs/plans: update ...`, and
  `docs/plans: clarify ...` commits that simply evolve the same active plan doc
- later `docs/execution: revise ...` and `docs/execution: update ...` commits
  that simply evolve the same active execution doc
- tiny typo or missed-import fixups
- one-line correction commits that obviously belong to the immediately preceding
  commit

Usually bad candidates:
- semantic commits that stand on their own
- migrations or behavior changes that deserve their own review boundary
- commits whose parent is unclear
- commits whose combination would blur correctness versus optimization

## Output format

History inspection
- ...

Rewrite candidates
- ...

Keep as independent commits
- ...

Proposed final series
- ...

Safety check
- local/private history: yes | no | unclear
- ambiguity: none | describe it

Rewrite plan
- ...

Verification after rewrite
- ...

Stop conditions
- ...

## Language guidance
Use practical git cleanup language:
- squash
- fixup
- fold into parent
- preserve as standalone
- do not rewrite shared history

## What this skill does not do
- It does not change intended final behavior.
- It does not replace `$impl-series`.
- It does not invent a different architecture or commit order than the final
  approved series warrants.
- It does not casually rewrite shared or public history.
- It does not hide ambiguous execution history behind a neat but misleading
  series.
