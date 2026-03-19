---
name: do-commits
description: Execute an approved /plan-commits plan by implementing and committing each step sequentially. Use this skill whenever the user says "/do-commits", "implement the plan", "start implementing", "execute the commits", or wants to begin working through a commit plan. Also trigger on "continue", "keep going", or "resume" in the context of an active commit plan. This skill runs continuously — it implements, verifies, and commits each step, only stopping when it hits a question, a problem, or finishes the plan.
---

# Do Commit

Execute an approved `/plan-commits` plan by implementing each commit in sequence. Commits are made as you go so the work is always auditable. Keep going until you hit a question, a problem, or finish the plan.

## Core rules

1. **Commit after each step.** Every planned commit gets implemented, verified, and `git commit`-ed before moving to the next. The git history is the audit trail — not conversation output, not staged changes, not uncommitted work.

2. **Stop on questions, not on commit boundaries.** Don't pause between commits to ask "should I continue?" Just keep going. Stop only when:
   - Something is wrong (verification fails, plan doesn't match reality, unexpected dependency)
   - You need a decision from the user (ambiguous requirement, multiple valid approaches)
   - The plan is complete

3. **Never bundle commits.** Each planned commit is a separate `git commit`. Don't combine "small" adjacent commits. Don't split a planned commit into multiple git commits without flagging it. The plan is the contract.

## Inputs

This skill expects an approved commit plan from `/plan-commits` earlier in the conversation or provided by the user. If there's no plan, tell the user to run `/plan-commits` first.

The user can optionally specify where to start:
- `/do-commit` — start from the first unimplemented commit (auto-detected from git log)
- `/do-commit 3` — start from commit 3

## Process

### Determine starting point

Git log is the source of truth for progress.

Run:

```bash
git log --oneline --reverse
git status
```

Compare the log against the commit plan's subject lines. The first commit in the plan that does NOT appear in git log is where you start.

Print the progress:

```
Commit plan progress:
  ✅ 1/6: asic_eth: add module skeleton with Kbuild and Kconfig
  ✅ 2/6: asic_eth: add PCI probe/remove with device ID table
  ➡️ 3/6: dma: allocate coherent ring buffers  ← starting here
  ⬜ 4/6: asic_eth: add char device with open/release
  ⬜ 5/6: mmap: implement DMA ring buffer mapping to userspace
  ⬜ 6/6: tx: add doorbell write and MSI-based eventfd completion
```

If `git status` shows uncommitted changes, warn the user and stop — a prior run may have left dirty state.

### For each remaining commit, repeat this cycle:

#### 1. Restate the contract

Print the commit's plan entry: message, files, preconditions, postconditions, verify command, and "not included" list. This keeps the scope visible.

#### 2. Check preconditions

Verify preconditions are met. For the first commit in a run, check against git log and the actual system state. For subsequent commits in the same run, preconditions should be satisfied by what you just committed — but verify anyway.

If preconditions fail, stop and tell the user. Don't try to fix precondition failures from a prior commit.

#### 3. Implement

Write the code. Stay within the planned file list. If you need to touch a file outside the plan, flag it but keep going if the reason is obvious (e.g., a missing import). If it's a real scope change, stop and ask.

Respect the "not included" list. Don't add things that belong to future commits.

Guidelines:
- Follow the project's existing code style
- Write the minimum code to satisfy the postconditions
- If the plan includes tests, write them as part of this commit
- If there's genuine ambiguity about an implementation choice, stop and ask

#### 4. Verify

Run the verify command(s) from the plan. If verification fails, fix the issue and re-verify. If the fix requires out-of-scope changes, stop and ask.

#### 5. Commit

Stage and commit. This is not optional — you actually run `git commit`, you don't wait for the user.

```bash
git add <files from the plan>
git diff --cached --stat
```

If files outside the plan were modified, note it in your output but proceed if the changes are minor and expected (e.g., auto-generated files). If unexpected files changed, stop and ask.

Write a meaningful commit message with:

- **Subject line** from the plan (`subsystem: description` format)
- **Why** this change exists — not what (the diff shows what), but why it's needed
- **Key decisions** — non-obvious implementation choices and their rationale
- **What's deferred** — what this commit intentionally leaves out

Format:

```
<subject line from plan>

<why — 1-3 sentences>

<key decisions, if any — 1-2 sentences each>

Not included in this commit:
- <deferred item 1>
- <deferred item 2>
```

Commit using a temp file for clean multi-line messages:

```bash
cat > /tmp/commit-msg.txt << 'EOF'
dma: allocate coherent ring buffers

Allocate TX and RX descriptor rings in probe using dma_alloc_coherent so
the device can DMA directly into host memory. Buffers are freed in remove.
Using coherent allocations here because the rings are long-lived and
accessed by both CPU and device continuously — streaming DMA mappings
would add unnecessary map/unmap overhead per descriptor.

Not included in this commit:
- Descriptor ring head/tail logic
- Userspace interface or mmap support
- Completion notification path
EOF
git commit -F /tmp/commit-msg.txt
```

Print a brief summary after each commit:

```
✅ 3/6: dma: allocate coherent ring buffers
   Files: asic_eth.c, asic_eth.h
   Verified: dmesg shows DMA addresses, clean rmmod
```

Then immediately move to the next commit. No pause, no "shall I continue?"

### When the plan is complete

After the last commit, print the full summary:

```
Plan complete. All 6 commits landed:
  ✅ 1/6: asic_eth: add module skeleton with Kbuild and Kconfig
  ✅ 2/6: asic_eth: add PCI probe/remove with device ID table
  ✅ 3/6: dma: allocate coherent ring buffers
  ✅ 4/6: asic_eth: add char device with open/release
  ✅ 5/6: mmap: implement DMA ring buffer mapping to userspace
  ✅ 6/6: tx: add doorbell write and MSI-based eventfd completion

Verify full history:
  git log --oneline
```

## Handling problems

**Verification fails.** Fix and retry. If the fix is within scope, just do it. If it requires out-of-scope changes, stop and explain. Don't commit code that fails its own verification.

**Plan doesn't match reality.** If you discover mid-implementation that the plan is wrong (missed dependency, unrealistic postconditions, bad file list), stop and propose an amendment. Wait for approval before continuing. Don't silently deviate from the plan.

**Scope creep temptation.** If you notice something that should be fixed but isn't in the current commit's scope, note it in your output: "Note: spotted X — should be addressed in commit N+2 or as a separate follow-up." Then move on.

**Ambiguous implementation choice.** If there are multiple valid approaches and the plan doesn't specify, stop and ask. Present the options with tradeoffs. This is the main reason for stopping mid-run.

**Need to modify a prior commit.** Don't. Note the issue, keep going, and the user can decide to `git rebase -i` later or add a fixup commit at the end. The exception: if a prior commit is broken in a way that blocks the current one, stop and explain.

## Resuming after a stop

When the user says "continue", "keep going", or `/do-commits` after a prior stop:

1. Run `git log --oneline` to find where you are
2. Pick up from the next unimplemented commit
3. If you stopped mid-commit (asked a question during implementation), incorporate the user's answer and finish that commit first

This means the user can close the session, come back later, and `/do-commits` will resume from where the git history left off.

## What this skill does NOT do

- It does not generate or modify the commit plan. That's `/plan-commits`.
- It does not combine or skip planned commits.
- It does not push. The user pushes when ready.
- It does not amend prior commits unless explicitly asked.
- It does not stop between commits to ask permission to continue.

## Example session

```
User: /do-commits

Claude: Checking commit plan progress...

  ✅ 1/6: asic_eth: add module skeleton with Kbuild and Kconfig
  ✅ 2/6: asic_eth: add PCI probe/remove with device ID table
  ➡️ 3/6: dma: allocate coherent ring buffers  ← starting here
  ⬜ 4/6: asic_eth: add char device with open/release
  ⬜ 5/6: mmap: implement DMA ring buffer mapping to userspace
  ⬜ 6/6: tx: add doorbell write and MSI-based eventfd completion

--- Commit 3/6: dma: allocate coherent ring buffers ---
Contract:
  Files: asic_eth.c, asic_eth.h
  Postconditions: dmesg shows DMA addresses, no leaks on rmmod
  Not included: descriptor ring logic, userspace interface, mmap

Preconditions verified — commit 2 in log, probe works.
Implementing...
[writes code]
Verification passed.

✅ 3/6: dma: allocate coherent ring buffers
   Files: asic_eth.c, asic_eth.h
   Verified: DMA addresses in dmesg, clean rmmod

--- Commit 4/6: asic_eth: add char device with open/release ---
Contract:
  Files: asic_eth.c, asic_eth.h
  Postconditions: /dev/asic_eth0 appears, open/close works
  Not included: mmap, ioctl, read/write

Preconditions verified.
Implementing...
[writes code]
Verification passed.

✅ 4/6: asic_eth: add char device with open/release
   Files: asic_eth.c, asic_eth.h
   Verified: /dev/asic_eth0 present, open/close succeeds

--- Commit 5/6: mmap: implement DMA ring buffer mapping to userspace ---
Contract:
  Files: asic_eth.c, asic_eth.h
  Postconditions: userspace mmap works, values visible in kernel DMA buffers
  Not included: doorbell, tx_head/tx_tail, completion notification

Preconditions verified — commits 3 and 4 both in log.
Implementing...
[writes code]

⚠️  Stopping — need a decision:
The plan says to use remap_pfn_range, but the DMA buffers from commit 3
were allocated with dma_alloc_coherent which returns a kernel virtual
address. We need the physical page frame number. Two options:
  (a) Use virt_to_phys() on the coherent allocation — works on most
      platforms but technically not portable
  (b) Switch to dma_mmap_coherent() which handles the mapping directly
      — cleaner, but the plan's verify script assumes raw mmap offsets

Which approach do you prefer?

User: go with dma_mmap_coherent, update the verify script

Claude: Got it. Continuing with dma_mmap_coherent...
[finishes implementation, updates verify]
Verification passed.

✅ 5/6: mmap: implement DMA ring buffer mapping to userspace
   Files: asic_eth.c, asic_eth.h
   Verified: mmap works, kernel/userspace memory coherent
   Note: used dma_mmap_coherent instead of remap_pfn_range per discussion

--- Commit 6/6: tx: add doorbell write and MSI-based eventfd completion ---
...
[implements, verifies, commits]

✅ 6/6: tx: add doorbell write and MSI-based eventfd completion
   Files: asic_eth.c, asic_eth.h
   Verified: full TX path works end-to-end

Plan complete. All 6 commits landed:
  ✅ 1/6: asic_eth: add module skeleton with Kbuild and Kconfig
  ✅ 2/6: asic_eth: add PCI probe/remove with device ID table
  ✅ 3/6: dma: allocate coherent ring buffers
  ✅ 4/6: asic_eth: add char device with open/release
  ✅ 5/6: mmap: implement DMA ring buffer mapping to userspace
  ✅ 6/6: tx: add doorbell write and MSI-based eventfd completion

Verify full history:
  git log --oneline
```
