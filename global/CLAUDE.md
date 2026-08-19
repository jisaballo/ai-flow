# ai-flow — Global Instructions

## Personal Preferences

<!-- Customize this section for your workflow -->

- All generated code, comments, commit messages, and documentation must be in **English**
<!-- - User communicates in [language] — respond in [language] when conversational, English for technical output -->

## Workflow: .ai-flow

All task management lives in `.ai-flow/`. No external todo files.

| File/Directory | Purpose |
|----------------|---------|
| `BACKLOG.md` | All tasks with status and priority (includes Epics section) |
| `STATE.md` | Workstream roster: one row per open front — written by the coordinator, only at ceremonies |
| `decisions-global.md` | Workflow/system decisions (not task-specific) |
| `artifacts/T-XXX/` | Task artifacts organized by task ID (state.md, understand.md, plan.md, verify.md) |
| `archive/T-XXX/` | Completed tasks with all artifacts, decisions, and summary.md |
| `product.md` | Product context: users, roles, apps, core business flows (read at start of new epics) |
| `steering/` | Domain-specific rules, patterns, and pitfalls (loaded per-task based on affected domains) |
| `codebase/` | Lightweight codebase analysis (concerns, testing patterns, drift detection) |

### Task Lifecycle

```
CAPTURE → BACKLOG.md (backlog) → PRIORITIZE (ready) → ACTIVATE (active + STATE.md) → UNDERSTAND → PLAN → CONFORM → EXECUTE → VERIFY → ARCHIVE
```

**Phases:**
1. **CAPTURE**: Add task to BACKLOG.md with initial description
2. **PRIORITIZE**: Set priority (critical/high/medium/low) and status (ready)
3. **ACTIVATE**: Run the opening ceremony (backlog protocol) — mint the ID, declare the front's areas, weigh them against every open front, create the worktree if this is a second front, then create `artifacts/T-XXX/state.md`, add the workstream row to STATE.md, mark as active
4. **UNDERSTAND**: Decompose if composite, ask contextual questions, write understand.md
5. **PLAN**: Create execution plan (max 3 steps), write plan.md
6. **CONFORM**: Generate failing test stubs from Verifiable Criteria (see plan protocol)
7. **EXECUTE**: Implement with TDD validation (make conformance tests pass), spec sync post-execute
8. **VERIFY**: Audit criteria against understand.md, write verify.md
9. **ARCHIVE**: Run archive checklist

### Execution Paths

**Full Path** (>2 files or ambiguous requirements): `understand → plan → conform → execute → verify`
**Quick Path** (<=2 files, clear scope, no design decisions): `plan (inline) → execute`

**CRITICAL:** Understanding phase is **MANDATORY** for Full Path. Quick Path skips formal understanding, conform, and verify phases.

### Autonomy Levels

At task activation, classify the task into an autonomy level. User confirms or adjusts.

| Level | Criteria | What changes |
|-------|----------|-------------|
| **Auto** | Bug fix with reproducible test, mechanical refactor, tests already green | Plan inline (no artifact), no understand->plan gate, no plan->execute gate, auto-commit if all tests pass. User validates post-commit. |
| **Guided** (default) | New features, domain changes, moderate scope | All gates as defined in Full Path. Default behavior. |
| **Supervised** | Schema changes, new domain/lib, >5 files, architectural decisions | All gates + step-by-step approval during Execute (show diff per step, wait for user OK before next step) |

**Classification triggers:**
- `auto` keywords: "fix", "bug", "refactor", "rename", "update dep", "bump"
- `supervised` keywords: "new domain", "schema", "migration", "architecture", "new lib"
- When ambiguous -> default to **Guided**

**Auto level constraints:**
- Still runs conformance tests (if criteria exist) or existing tests
- Still respects Bounded Retry (3 attempts max)
- Still respects Diff Size Guardrail (>150 LOC uncommitted in a step, or >400 LOC on the branch since its base -> pause)
- Commit message includes `[auto]` tag: `type(scope): [auto] description`
- If anything unexpected happens (test failure after 3 retries, >3 files needed, design decision required) -> **escalate to Guided**

### Phase Protocols (MANDATORY)

**Before starting ANY phase, read the corresponding protocol file:**

| Phase | Protocol file |
|-------|--------------|
| Activate | `~/.claude/ai-flow/protocols/backlog.md` |
| Understand | `~/.claude/ai-flow/protocols/understand.md` |
| Plan + Conform | `~/.claude/ai-flow/protocols/plan.md` |
| Execute + Spec Sync | `~/.claude/ai-flow/protocols/execute.md` |
| Verify | `~/.claude/ai-flow/protocols/verify.md` |
| Quick Path | `~/.claude/ai-flow/protocols/quick-path.md` |
| Backlog/Archive/Epics | `~/.claude/ai-flow/protocols/backlog.md` |
| Codebase Mapping | `~/.claude/ai-flow/protocols/codebase-mapping.md` |

### Phase Orchestration

| Command | Action |
|---------|--------|
| `continue` | Resume from the task's `artifacts/T-XXX/state.md` (STATE.md lists the open fronts) |
| `status` | Show current state |
| `understand` | Run Understanding phase (read protocol first) |
| `plan` | Run Plan phase (read protocol first) |
| `execute` | Run Execute phase (read protocol first) |
| `verify` | Run Verify phase (read protocol first) |
| `pause` | Save session state to the task's `artifacts/T-XXX/state.md` |

### Quick Commands

- **Add task**: "add to backlog: [description]"
- **View backlog**: "show backlog"
- **Start task**: "work on T-XXX" -> auto-triggers Understanding phase
- **Quick task**: "quick: [description]" -> skip backlog, inline plan, execute (read quick-path protocol)
- **Check status**: "status"
- **Understand**: "understand" -> run Understanding phase for active task
- **More questions**: "more questions" -> gather additional context during Understanding
- **Map codebase**: "map codebase" -> run lightweight codebase analysis (read codebase-mapping protocol)
- **Discover project**: "discover" -> derive `.ai-flow/project.yml` for an existing repo (read discover protocol)

### Commit Protocol

**CRITICAL: DO NOT commit until user explicitly validates and approves.**

- Work stays uncommitted during development and iterations
- Only commit when user explicitly approves
- If user requests changes, continue iterating without committing
- Exception: In multi-step plans, you may commit individual steps but STILL ask first
- **Auto level exception**: Auto tasks may commit without pre-approval IF all tests pass. User validates post-commit and can revert.
- Atomic commits: `type(scope): description` with Co-Authored-By line
- Each commit must pass tests (TDD validation)

**Post-Commit (mandatory):**
After every successful task commit, **immediately** run the archive checklist (read backlog protocol) — do NOT move to the next task first. For quick tasks, archive = log to Quick Tasks table in STATE.md (no backlog archive needed).

**Quick task commit format:** `type(scope): quick - description` (see quick-path protocol).

### Session Continuity

- **On start**: Read STATE.md for the open fronts, then this workstream's `artifacts/T-XXX/state.md`. If a task is active, also read the protocol for the current phase
- **On pause**: Update the task's `artifacts/T-XXX/state.md` with last file, uncommitted changes, context — it is the handoff, and it survives the pause
- **On compaction**: STATE.md and BACKLOG.md are re-read automatically

### Artifact Check Before Create (MANDATORY)

**CRITICAL:** Before running ANY phase (understand, plan, verify), ALWAYS check if `artifacts/T-XXX/` already has the corresponding file:

1. **Check first**: Read `artifacts/T-XXX/understand.md`, `plan.md`, or `verify.md` BEFORE attempting to create one
2. **If artifact exists**: Show its content, ask user if they want to proceed with the existing artifact or regenerate
3. **If artifact does NOT exist**: Proceed normally with the phase
4. **NEVER blindly overwrite** an existing artifact — it may contain decisions from a previous session

### Context Management

- **On compaction during execution**: Re-read `artifacts/T-XXX/state.md` + `artifacts/T-XXX/plan.md` + the active phase protocol file before continuing
- **Max 3 steps per plan** is also a context budget rule — plans with >3 steps signal the task should be split
- **>5 files modified in a task**: Prefer executing steps via Task tool agents (fresh context) over inline execution
- **STATE.md must stay lean**: Only the workstream roster — per-task context lives in the task's own state sheet. Move completed task details to archive promptly

## Action Boundaries

### Always (do without asking)
- Fix broken imports, null pointers, type mismatches
- Add error handling, null checks, validation where the flow can reach the failure (not for impossible scenarios — see Simplicity First)
- Fix missing deps, build config issues
- Run tests after every code change
- Auto-fix test if code change was intentional

### Ask First (need user approval)
- New services, components, or modules
- Schema changes (models, database, APIs)
- Library additions or swaps
- Changes to >3 files not in the plan
- Architectural decisions (new patterns, state shape)

### Never (hard stops)
- Commit without user validation
- Skip or disable tests
- Commit secrets, credentials, or .env files
- Delete user data or drop tables/collections
- Force push to main
- Overwrite existing artifacts without checking

## Working Rules

- **One active task at a time** in STATE.md
- **Scope & Session Guard** — If a request arrives that is NOT part of the active task's plan, flag it in one line before acting: name whether it looks unrelated or related-but-separable, and ask whether to capture it to BACKLOG.md and keep the session clean, or switch tasks (closing the current one first — archive + prune STATE.md). User decides. Applies to your own drive-by temptations too (incidental refactors, "I noticed X nearby"). Exception: a genuine blocker for the active task is the Replan Gate, not this.
- **Surgical Changes** — Every changed line must trace directly to the request. Don't "improve" adjacent code, comments, or formatting; don't refactor what isn't broken; match existing style even if you'd do it differently. Clean up only the orphans YOUR change created (now-unused imports/vars/functions) — never pre-existing dead code, just mention it. This is the line/diff-level counterpart to the Scope & Session Guard (which operates at task level).
- **Understanding phase MANDATORY** before planning — never skip to plan without gathering context
- **Detect composite tasks** — propose splitting tasks that mix multiple concerns into independent backlog tasks (not subtasks) before planning
- **Ask contextual questions** — gather all necessary context to produce polished code
- **Update the task's state sheet** (`artifacts/T-XXX/state.md`) with step progress during execution
- **Atomic commits**: `type(scope): description`
- **Phase gates (Guided)**: understand -> plan (user approves), plan -> conform (automatic), conform -> execute (user approves plan), execute -> spec sync (automatic), execute -> verify (automatic), verify -> archive (user approves)
- **Phase gates (Auto)**: plan inline -> conform/execute (automatic), verify via tests -> auto-commit -> user validates post-commit
- **Phase gates (Supervised)**: same as Guided + user approves each execute step individually
- **Max 3 steps per plan** — split larger work into sub-plans
- **Test validation REQUIRED** in Execute phase (TDD compliance)

## Core Principles

- **Simplicity First**: Minimum code that solves the problem, nothing speculative.
  - No abstractions for single-use code.
  - No "flexibility" or "configurability" that wasn't requested.
  - No error handling for scenarios the flow cannot reach.
  - Self-check: "Would a senior engineer say this is overcomplicated?" If yes, rewrite.
- **Minimize Impact**: Only touch code relevant to the task
- **No Shortcuts**: Find root causes, no temporary fixes
- **Senior-Level Quality**: Thoroughness and professionalism
- **TDD Compliance**: Validate tests after every code change
- **CRITICAL**: When debugging, trace through the ENTIRE code flow step by step. No assumptions.
