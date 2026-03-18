---
name: plan-commits
description: Decompose an implementation plan into a sequence of small, independent, self-contained commits. Use this skill whenever the user says "/plan-commits", asks to "break this into commits", "plan the commit sequence", "make this into small commits", or wants to turn a design or implementation plan into an ordered series of atomic, reviewable commits. Also trigger when the user has just finished planning (e.g., after /ecc:plan) and wants to move to implementation with clean commit hygiene. This skill is about commit sequencing and scoping — not about writing code or generating diffs.
---

# Plan Commits

Turn an implementation plan into a sequence of small, independently correct commits.

## Why this exists

Large implementations tend to drift into massive commits that are hard to review, hard to bisect, and hard to verify. The goal of this skill is to insert a planning step between "here's what we're building" and "start coding" that forces each commit to be:

- **Atomic**: one logical change per commit
- **Independently correct**: the tree compiles, tests pass, and nothing is left in a broken state after each commit
- **Reviewable**: small enough that a human can verify correctness by reading the diff
- **Ordered**: each commit's preconditions are satisfied by prior commits

## Inputs

This skill works best when it has an existing plan to decompose. That plan can come from:

- A prior `/ecc:plan` output
- A design doc or architecture description in the conversation
- A TODO list or feature spec the user provides
- The user describing what they want to build conversationally

If no plan exists yet, ask the user to describe what they're building before generating the commit sequence. Don't try to simultaneously design the system and plan the commits — those are separate steps.

## Output format

Produce a numbered commit plan. Each commit entry has these fields:

```
Commit N/Total: <conventional commit message>

  Summary:      1-2 sentence plain English description of the change
  Files:        explicit list of files created or modified
  Preconditions:  what must already be true in the tree before this commit
  Postconditions: what is true after this commit lands — compilation, tests, observable behavior
  Verify:       copy-pasteable command(s) to prove the postconditions hold
  Not included: what this commit explicitly does NOT do (scope boundary)
  Depends on:   commit number(s) this depends on (usually just N-1, but call out non-obvious deps)
```

### Field guidance

**Commit message**: Use conventional commits (`feat`, `fix`, `refactor`, `test`, `docs`, `chore`). Include a scope when the project has clear modules, e.g., `feat(driver): add PCI probe skeleton`. The message should be the actual message that will be used — not a placeholder.

**Summary**: Brief plain English so someone skimming the plan can understand the arc without reading every field.

**Files**: List every file that will be created or modified. This makes scope visible at a glance. If you're unsure, note it with a `(?)` suffix. New files should say `(new)`.

**Preconditions**: State what must exist or be true before starting this commit. Reference prior commits by number. Examples: "Commit 2 landed — struct ring_buf exists in asic_eth.h", "pytest suite passes", "module loads and unloads cleanly".

**Postconditions / invariants**: The most important field. These are testable assertions about the state of the tree after the commit. Be specific: "compiles cleanly" is okay as a baseline, but add observable behavior: "insmod succeeds, dmesg shows probe message", "`make test` passes with new test_ring_alloc", "API returns 200 on GET /health".

**Verify**: Literal commands. Not pseudocode, not "run the tests" — the actual invocation. If it requires setup (like loading a module or starting a server), include that. The user should be able to paste this into a terminal.

**Not included**: Explicitly name things this commit does NOT do, especially things that are tempting to bundle in. This is the primary defense against scope creep during implementation. Examples: "Does not wire up the completion path", "No error handling for malformed packets yet", "Skips authentication — added in commit 5".

**Depends on**: Usually the previous commit, but call out non-obvious dependencies. If commits 3 and 4 are independent of each other but both depend on commit 2, say so — this tells the implementer they could be done in either order.

## Generating the plan

Follow this process:

1. **Identify the end state.** What does "done" look like? What's the final set of capabilities?

2. **Find the natural seams.** Look for boundaries between:
   - Data structures and the code that uses them
   - Interface definitions and implementations
   - Infrastructure (build system, config) and logic
   - Happy path and error handling
   - Core functionality and optimizations

3. **Order by dependency, not by importance.** The first commit is whatever everything else depends on — often a skeleton, a type definition, or build system setup. Resist the urge to put the "interesting" work first.

4. **Check each commit for independence.** For every commit, ask: "If I stopped here and shipped, would the tree be in a valid state?" If no, the commit needs to be split or merged with an adjacent one.

5. **Look for hidden coupling.** Two changes that seem independent might share a precondition that doesn't exist yet. If adding a new function and a new test both require a new header file, the header file is its own commit (or part of the first one that needs it).

6. **Keep commits small.** A rough heuristic: if a commit touches more than 3-4 files or would produce a diff over ~150 lines, look for a way to split it. This isn't a hard rule — some commits are legitimately large — but it's a good default.

7. **Write the "not included" field first** for each commit, then fill in the rest. Starting with what's excluded forces you to think about scope boundaries before you think about content.

## Example

Given a plan to "build a PCI device driver with zero-copy mmap userspace interface":

```
Commit 1/6: chore(driver): add module skeleton with Kbuild and Kconfig

  Summary:      Empty loadable kernel module with build system integration.
  Files:        drivers/net/asic_eth/asic_eth.c (new),
                drivers/net/asic_eth/Makefile (new),
                drivers/net/asic_eth/Kconfig (new)
  Preconditions:  clean kernel tree, no prior module
  Postconditions: module compiles with `make M=drivers/net/asic_eth`,
                  insmod/rmmod cycle works, prints load/unload messages to dmesg
  Verify:       make -C /lib/modules/$(uname -r)/build M=$PWD &&
                sudo insmod asic_eth.ko &&
                dmesg | tail -3 &&
                sudo rmmod asic_eth
  Not included: no PCI registration, no device operations, no headers
  Depends on:   none

Commit 2/6: feat(driver): add PCI probe/remove with device ID table

  Summary:      Register as a PCI driver, bind to the ASIC's vendor/device ID,
                map BAR0 in probe.
  Files:        asic_eth.c, asic_eth.h (new)
  Preconditions:  commit 1 — module loads and unloads
  Postconditions: module binds to PCI device on load, ioremap succeeds,
                  dmesg shows BAR0 address and size, clean unbind on rmmod
  Verify:       sudo insmod asic_eth.ko &&
                dmesg | grep "BAR0" &&
                ls /sys/bus/pci/drivers/asic_eth/ &&
                sudo rmmod asic_eth
  Not included: no DMA allocation, no char device, no interrupt setup
  Depends on:   1

Commit 3/6: feat(driver): allocate DMA coherent ring buffers

  Summary:      Allocate TX and RX descriptor rings and data buffers using
                dma_alloc_coherent in probe, free in remove.
  Files:        asic_eth.c, asic_eth.h
  Preconditions:  commit 2 — PCI probe works, BAR0 mapped
  Postconditions: dmesg shows DMA addresses for both rings, no memory leaks
                  on rmmod (check with kmemleak if available)
  Verify:       sudo insmod asic_eth.ko &&
                dmesg | grep "DMA ring" &&
                sudo rmmod asic_eth &&
                dmesg | grep -c "leak" | grep -q "^0$"
  Not included: no descriptor ring logic (head/tail), no userspace interface,
                no mmap support
  Depends on:   2

Commit 4/6: feat(driver): add char device with open/release

  Summary:      Register a misc char device so userspace can open a file
                descriptor to the driver. No operations beyond open/release.
  Files:        asic_eth.c, asic_eth.h
  Preconditions:  commit 2 — probe works (does not depend on commit 3)
  Postconditions: /dev/asic_eth0 appears after insmod, open() and close()
                  succeed from userspace
  Verify:       sudo insmod asic_eth.ko &&
                ls -la /dev/asic_eth0 &&
                python3 -c "f=open('/dev/asic_eth0','rb'); f.close()" &&
                sudo rmmod asic_eth
  Not included: no mmap, no ioctl, no read/write operations
  Depends on:   2 (independent of 3 — can be reordered)

Commit 5/6: feat(driver): implement mmap for DMA ring buffers

  Summary:      Add mmap file operation that maps the DMA ring buffers into
                userspace using remap_pfn_range. Userspace gets direct access
                to descriptor rings and data buffers.
  Files:        asic_eth.c, asic_eth.h
  Preconditions:  commits 3 and 4 — DMA buffers allocated AND char device works
  Postconditions: userspace can mmap the device fd, read/write to mapped memory,
                  values are visible in kernel-side DMA buffers
  Verify:       sudo insmod asic_eth.ko &&
                python3 test_mmap.py &&
                sudo rmmod asic_eth
  Not included: no doorbell mechanism, no tx_head/tx_tail logic, no completion
                notification
  Depends on:   3, 4

Commit 6/6: feat(driver): add doorbell write and MSI-based eventfd completion

  Summary:      Wire up the TX doorbell (MMIO write to BAR0 offset), descriptor
                ring head/tail management, and MSI interrupt that signals an
                eventfd for completion notification to userspace.
  Files:        asic_eth.c, asic_eth.h
  Preconditions:  commit 5 — mmap works, userspace can see ring buffers
  Postconditions: full TX path works: userspace writes descriptor, writes
                  doorbell, waits on eventfd, gets completion signal.
                  Verified with test harness.
  Verify:       sudo insmod asic_eth.ko &&
                python3 test_tx_doorbell.py &&
                sudo rmmod asic_eth
  Not included: no RX path, no error recovery, no multi-queue support
  Depends on:   5
```

Notice that commits 3 and 4 are independent — the plan calls this out explicitly so the implementer knows they can be done in either order. Commit 5 is where they converge.

## Interacting with the user

After generating the plan, ask the user to review it before implementation begins. Common adjustments:

- "Commit 3 is too big, can you split it?" — look for a sub-seam within that commit
- "I want to combine 2 and 3" — fine, as long as the combined commit is still independently correct
- "The verify command won't work in my setup" — adjust to their environment
- "I want to add error handling earlier" — reorder, but make sure preconditions still hold

Once the user approves the plan, the plan becomes the contract for implementation. Each commit should be implemented and verified before moving to the next. If implementation reveals that a commit needs to change (e.g., an unforeseen dependency), update the plan first, then proceed.

## Integration with /ecc:plan

The typical workflow is:

1. `/ecc:plan` — design the system, figure out architecture and approach
2. `/plan-commits` — decompose that plan into an ordered commit sequence
3. Implement commit by commit, verifying postconditions at each step

This skill is step 2. It takes the output of step 1 as input and produces the contract for step 3.
