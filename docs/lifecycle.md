# Task Lifecycle Deep Dive

## Overview

Every task in ai-flow follows a structured lifecycle. Each phase has a specific purpose, defined inputs/outputs, and gates that prevent premature progression.

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

**Purpose**: Load the task as the single focus of the session.

**Input**: A ready task
**Output**: STATE.md updated with task context, status set to `active`

**Rule**: Only one task can be active at a time. This prevents context dilution.

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
5. Stage changes (do NOT commit)

**Guardrails**:
- **Bounded Retry**: 3 failures on the same error → stop and escalate
- **Replan Gate**: If an assumption breaks → stop and revise the plan
- **Diff Size**: >150 LOC in a single step → pause and evaluate
- **Action Boundaries**: Some changes always need user approval

**Post-Execute**: Spec Sync reviews the diff against understand.md and documents any divergences.

### 8. VERIFY

**Purpose**: Prove that every criterion is met with evidence.

**What happens**:
1. Re-read understand.md criteria
2. For each criterion, cite evidence (file:line, test name)
3. Re-run all Verify commands from the plan (catches cross-step regressions)
4. Launch 3 review agents in parallel:
   - Test Coverage Auditor
   - Security & Error Handling
   - Architecture Boundaries
5. Write verify.md with audit table and findings

**Output**: `artifacts/T-XXX/verify.md`

**Gate**: If any criterion is not met → fix before archiving. Partial → user decides.

### 9. ARCHIVE

**Purpose**: Clean up and preserve knowledge.

**What happens**:
1. Generate `archive/T-XXX/summary.md` with key decisions and commits
2. Delete `artifacts/T-XXX/` (the archive has the summary)
3. Remove from BACKLOG.md
4. Reset STATE.md

## Execution Paths

Not every task needs the full ceremony:

| Path | When to use | Phases |
|------|-------------|--------|
| **Full** | >2 files, ambiguous scope, new features | All phases |
| **Quick** | <=2 files, unambiguous, small fixes | Plan (inline) → Execute |

## Autonomy Levels

Different tasks need different supervision:

| Level | Behavior | Best for |
|-------|----------|----------|
| **Auto** | Minimal gates, auto-commit | Bug fixes, renames, dep bumps |
| **Guided** | All gates, user approves plan | Features, domain changes |
| **Supervised** | Per-step approval in Execute | Schema changes, new domains |

## Why This Structure Works

1. **Understanding prevents rework**: 10 minutes of questions saves hours of iteration
2. **Plans create shared expectations**: User and AI agree on approach before code changes
3. **Conformance tests define "done"**: No ambiguity about completion
4. **Verification builds trust**: Evidence-based audit, not "looks good to me"
5. **Archives preserve context**: Future sessions can recover decisions without re-investigating
