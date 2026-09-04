# Task Lifecycle Protocol

## Overview

Every task in ai-flow follows a structured lifecycle. Each phase has a specific purpose, defined inputs/outputs, and gates that prevent premature progression.

**This is the map's single home.** The phase chain, the execution paths and the autonomy levels are
stated here and nowhere else: a second copy drifts against the one the phases actually read, and the
copies that used to exist had already drifted — one described archiving as bookkeeping and omitted the
move that puts the work into effect, two dropped half the criteria for the strictest autonomy level.
Documents that need the map **cite this file**; they do not restate it.

It lives with the protocols rather than with the published documentation for a reason that is not
editorial: **the documentation directory is never installed.** What an operator needs in order to *run*
the engine has to reach their machine, and only the engine's own surface does — so the file a session can
open and the file a reader browses before installing are deliberately the same file. What is needed only
to *evaluate* ai-flow may stay on the website.

Unlike its sibling protocols, no phase command reads this one: it is read at activation, alongside the
backlog protocol, to choose the execution path and the autonomy level, and by whoever wants the whole
chain in one place. The global manual routes to it and states none of it.

```
CAPTURE → PRIORITIZE → ACTIVATE → UNDERSTAND → PLAN → CONFORM → EXECUTE → VERIFY → ARCHIVE
```

## Phases

### 1. CAPTURE

**Purpose**: Record a task idea before it's lost.

**Input**: A description from the user
**Output**: New row in BACKLOG.md with a T-XXX ID

No analysis happens here — just capture. The description can be rough.

### 2. PRIORITIZE

**Purpose**: Assess importance relative to other work.

**Input**: Task in backlog
**Output**: Priority assigned (critical/high/medium/low), status set to `ready`

### 3. ACTIVATE

**Purpose**: Make the task the focus of its workstream.

**Input**: A ready task
**Output**: `artifacts/T-XXX/state.md` created with the task's branch, phase, step and autonomy; one row added to the roster in STATE.md; status set to `active`

Activation is the **opening ceremony**, and the backlog protocol owns its moves. Three of them are the
ones a summary drops, and they are why the ceremony exists rather than being a step called "start":
the front **declares the areas** it expects to touch, in the project's own vocabulary; that declaration
is **weighed against every open front**, returning clear, collision, or cannot-compare — and a collision
is acknowledged in writing on the task's own sheet rather than waved through; and the default branch is
checked to be **published**, because a front cut from it cannot see work that was committed and never
pushed. With a single front open the weighing and the checkout moves have nothing to do. The declaration,
the sheet and the roster row always do.

**Rule**: One active task per workstream. Two fronts is the working parallelism, three the ceiling. This prevents context dilution without pinning the whole repository to one job.

### 4. UNDERSTAND

**Purpose**: Gather all context needed to produce high-quality code. This is where ai-flow diverges from "just start coding" workflows.

**What happens**:
1. **Composite detection**: Is this actually multiple tasks? If so, split.
2. **Steering file load**: Read domain-specific rules that apply.
3. **Parallel investigation**: For multi-domain tasks, explore the codebase in parallel.
4. **Contextual questions**: Ask the user what can't be determined from code alone.
5. **Write understand.md**: Document requirements, edge cases, and verifiable criteria.

**Output**: `artifacts/T-XXX/understand.md`

**Gate**: User must approve before proceeding to Plan.

### 5. PLAN

**Purpose**: Create a concrete, verifiable execution plan.

**Constraints**:
- Maximum 3 steps (if more are needed, the task should be split)
- Every step must have a `Verify` command and `Done` criteria
- Steps must be independently verifiable

**Output**: `artifacts/T-XXX/plan.md`

**Gate**: User must approve the plan before execution.

### 6. CONFORM

**Purpose**: Generate failing tests from the verifiable criteria (TDD red phase).

**What happens**:
1. Read criteria from understand.md
2. Create test stubs that will fail (proving they test something real)
3. Run tests to confirm they fail
4. Execute phase's goal becomes: make these tests pass

**Output**: Failing test files in the codebase

This phase bridges planning and execution. The tests become the contract.

### 7. EXECUTE

**Purpose**: Make the code changes that satisfy the plan.

**For each step**:
1. Read source files
2. Make changes
3. Run the step's Verify command
4. Handle failures (bounded retry: max 3 attempts per error)
5. Commit the step — `protocols/execute.md` owns the commit, its format and its green precondition

**Guardrails**:
- **Bounded Retry**: 3 failures on the same error → stop and escalate
- **Replan Gate**: If an assumption breaks → stop and revise the plan
- **Diff Size**: >150 LOC uncommitted in a single step, or >400 LOC on the branch since its base → pause and evaluate
- **Action Boundaries**: Some changes always need user approval

**Post-Execute**: Spec Sync reviews the diff against understand.md and documents any divergences.

### 8. VERIFY

**Purpose**: Prove that every criterion is met with evidence.

**What happens**:
1. Re-read understand.md criteria
2. For each criterion, cite evidence (file:line, test name)
3. Re-run all Verify commands from the plan (catches cross-step regressions)
4. Launch 5 auditors in parallel:
   - Business Contract Auditor — the diff against the contract the user approved
   - Test Coverage Auditor
   - Security & Error Handling
   - Architecture Boundaries
   - Simplicity & Structure
5. Adversarially refute each HIGH finding — a skeptic reads the code in context and tries to refute it,
   and only what survives holds the gate. HIGH is refuted because HIGH is what blocks. MEDIUM and LOW come
   back unadjudicated and the verify phase triages them itself, in the context it already has
6. Write verify.md with audit table and findings

**Output**: `artifacts/T-XXX/verify.md`

**Gate**: If any criterion is not met → fix before archiving. Partial → user decides.

### 9. ARCHIVE

**Purpose**: Land the work, preserve the knowledge, and take the front down.

Archiving is a **ceremony**, not a cleanup: it runs at every task close, one front at a time, and only in
the coordinator. **The order is the protection** — nothing is recorded as done before it is in the trunk.
The backlog protocol owns the order and owns these moves:

1. The user validates the work — commits are free per step in every checkout, so what gets approved is
   the task's work as a whole and never each commit: the branch in a front, the task's own commits on the
   trunk in the coordinator. One approval, and the ceremony has no other
2. The coordinator collects the task's papers, which live outside version control and never travel with
   the branch
3. The merge lands in the coordinator
4. The record is written: `archive/T-XXX/summary.md`, the row out of BACKLOG.md, `artifacts/T-XXX/` deleted
5. **The work is put into effect** — the project's own distribution command runs. Committed is not
   installed: a close that ends before this leaves the work non-existent for the sessions it governs
6. **The trunk is published** — at every close, a quick task's included. Landed is not reachable: a close
   that ends before this leaves the work sitting on one machine
7. The front's working copy is dismantled — only when the front has no next task
8. The front's roster row is removed, the coordinator's last write — only when the front has no next task

With a single front open, the collect, merge and dismantle moves have nothing to do: the task was worked in
the coordinator, so its papers are already there, and there is no branch to merge and no second checkout to
take down. Named by role rather than by number, because a move inserted anywhere renumbers the rest.

## Execution Paths

Not every task needs the full ceremony:

| Path | When to use | Phases |
|------|-------------|--------|
| **Full** | >2 files, ambiguous scope, new features | understand → plan → conform → execute → verify |
| **Quick** | <=2 files, unambiguous, small fixes | plan (inline) → execute |

The path names what runs **between** activation and archive; capture, prioritize, activate and archive
happen on both. Understanding is mandatory on the full path — the quick path skips the formal
understanding, conform and verify phases, which is the whole of what makes it quick.

## Sessions

**A full-path task is three sittings, and each task starts in a fresh one.** The two cuts fall at the
close of Understand and at the close of Execute, and they are stated here because they are a property of
the chain rather than of any one phase.

The reason is measured, on two independent populations and by segmenting each transcript on its own phase
markers. Each of the two boundaries is worth roughly a quarter of what the rest of the task would otherwise
cost, against a turn-1 floor of about 47k that no cut removes. The chain offers a third candidate of the same
value, and it is not taken: the boundaries sit close enough together that the saving cannot choose between
them, so what chooses is what the phase ahead reads. Plan is drafted from `understand.md`; VERIFY is 38–40%
of a task's turns and 49–56% of its price-weighted bill and enters carrying a median 224k of context it never
reads — every input that phase has is an artifact, listed in the backlog protocol beside the rule, and none
of them is the conversation. A phase that inherits a conversation it cannot use is paying for it twice. The
candidate that is refused is the one whose next phase names prior conversation among its own inputs.

The cut is a **habit**, not a gate. What performs the announcement is the write that advances the sheet to
the position the next phase will declare, and what those writes announce, oblige and refuse to ask is
stated in the backlog protocol (`### The phase precondition`) and nowhere else, including the operator's
way out of it. The quick and auto
paths never reach those writes.

What the cut destroys is the only thing to guard against: a conversation ends and takes with it every
hypothesis it killed and every route it rejected. Those go on the sheet before the cut, under
`## Ruled out` — decisions taken are already recorded; those two are not.

## Autonomy Levels

Different tasks need different supervision:

The level is classified at activation; the user confirms or adjusts it.

| Level | Criteria | What changes |
|-------|----------|--------------|
| **Auto** | Bug fix with a reproducible test, mechanical refactor, tests already green | Plan inline (no artifact), no understand→plan gate, no plan→execute gate, auto-commit if all tests pass. User validates post-commit. |
| **Guided** (default) | New features, domain changes, moderate scope | All gates as defined in the full path. Default behavior. |
| **Supervised** | Schema changes, new domain or library, **>5 files**, **architectural decisions** | All gates + step-by-step approval during Execute (show the diff per step, wait for the user before the next one) |

**The gates each level runs:**
- **Guided**: understand → plan (user approves), plan → conform (automatic), conform → execute (user approves the plan), execute → spec sync (automatic), execute → verify (automatic), verify → archive (user approves)
- **Auto**: plan inline → conform/execute (automatic), verify via tests → auto-commit → user validates post-commit
- **Supervised**: same as Guided, plus the user approving each execute step individually

**Classification triggers:**
- `auto` keywords: "fix", "bug", "refactor", "rename", "update dep", "bump"
- `supervised` keywords: "new domain", "schema", "migration", "architecture", "new lib"
- When ambiguous → default to **Guided**

**Auto level constraints:**
- Still runs conformance tests (if criteria exist) or existing tests
- Still respects Bounded Retry (3 attempts max)
- Still respects the diff guardrail (>150 LOC uncommitted in a step, or >400 LOC on the branch since its base → pause)
- Commit message includes an `[auto]` tag: `type(scope): [auto] description`
- If anything unexpected happens (test failure after 3 retries, >3 files needed, a design decision required) → **escalate to Guided**

## Why This Structure Works

1. **Understanding prevents rework**: 10 minutes of questions saves hours of iteration
2. **Plans create shared expectations**: User and AI agree on approach before code changes
3. **Conformance tests define "done"**: No ambiguity about completion
4. **Verification builds trust**: Evidence-based audit, not "looks good to me"
5. **Archives preserve context**: Future sessions can recover decisions without re-investigating
