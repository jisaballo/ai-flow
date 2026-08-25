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

### Task Lifecycle

```
CAPTURE → PRIORITIZE → ACTIVATE → UNDERSTAND → PLAN → CONFORM → EXECUTE → VERIFY → ARCHIVE
```

**What each phase does, which path a task takes, how the autonomy levels differ and which gates each
one runs are stated in the lifecycle protocol below, and are not restated here** — this file is read on
every turn of every project, so a copy kept here is the engine's most expensive copy and the first to drift.

### Phase Protocols (MANDATORY)

**Before starting ANY phase, read the corresponding protocol file:**

| Phase | Protocol file |
|-------|--------------|
| The whole chain, the paths, the autonomy levels | `~/.claude/ai-flow/protocols/lifecycle.md` |
| Activate | `~/.claude/ai-flow/protocols/backlog.md` |
| Understand | `~/.claude/ai-flow/protocols/understand.md` |
| Plan + Conform | `~/.claude/ai-flow/protocols/plan.md` |
| Execute + Spec Sync | `~/.claude/ai-flow/protocols/execute.md` |
| Verify | `~/.claude/ai-flow/protocols/verify.md` |
| Quick Path | `~/.claude/ai-flow/protocols/quick-path.md` |
| Backlog/Archive/Epics | `~/.claude/ai-flow/protocols/backlog.md` |

### Phase Orchestration

| Command | Action |
|---------|--------|
| `continue` | Resume the task this checkout owns — resolved by the ladder in the backlog protocol (`Resolving the task`), then read its `artifacts/T-XXX/state.md` |
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
- **Discover project**: "discover" -> derive `.ai-flow/project.yml` for an existing repo (read discover protocol)
- **Unattended run**: `bash ~/.claude/ai-flow/ralph/ralph.sh` -> work `[afk]`-tagged backlog tasks, one
  disposable session each, serial, on a dedicated `afk/YYYY-MM-DD` branch, **up to 5 per run**. Push and
  the destructive git verbs are denied to the agent by permission patterns — a rail against mistakes,
  not a sandbox: review the branch before merging, and never run it with permissions bypassed. It aborts
  on a dirty tree, and a parked iteration discards uncommitted work with `reset --hard` and `clean -fd`.

### Commit Protocol

**CRITICAL: DO NOT commit until user explicitly validates and approves.**

**Inside a linked worktree the gate is the branch, not each commit** — commits are free there and the user's approval sits before the merge, at move 1 of the closing ceremony (backlog protocol), which owns the rule; that ceremony runs when the task closes, never per commit. In the coordinator the gate below applies unchanged.

- Work stays uncommitted during development and iterations
- Only commit when user explicitly approves
- If user requests changes, continue iterating without committing
- Exception: In multi-step plans, you may commit individual steps but STILL ask first
- **Auto level exception**: Auto tasks may commit without pre-approval IF all tests pass. User validates post-commit and can revert.
- Atomic commits: `type(scope): description` with Co-Authored-By line
- Each commit must pass tests (TDD validation)

**Post-Commit (mandatory):**
After every successful task commit, **immediately** run the closing ceremony (read backlog protocol) — do NOT move to the next task first. For quick tasks the close is the merge plus its row in the Quick Tasks table of STATE.md, written in the coordinator (no backlog archive needed).

**Quick task commit format:** `type(scope): quick - description` (see quick-path protocol).

### Session Continuity

- **On start**: Resolve which task this checkout owns by the ladder in the backlog protocol (`Resolving the task`), then read that task's `artifacts/T-XXX/state.md`; STATE.md is the roster of open fronts. If a task is active, also read the protocol for the current phase
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
- **STATE.md must stay lean**: the workstream roster and the Quick Tasks Completed table, and nothing else — per-task context lives in the task's own state sheet. Move completed task details to archive promptly

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
- Commit without user validation — in the coordinator; inside a front the gate is the branch (see Commit Protocol)
- Skip or disable tests
- Commit secrets, credentials, or .env files
- Delete user data or drop tables/collections
- Force push to main
- Overwrite existing artifacts without checking

## Working Rules

- **One active task at a time per workstream** — STATE.md's roster holds one row per open front, and each front runs its own single active task; 2 fronts is the working parallelism, 3 the ceiling (measure the real cost before raising it)
- **Scope & Session Guard** — If a request arrives that is NOT part of the active task's plan, flag it in one line before acting: name whether it looks unrelated or related-but-separable, and ask whether to capture it to BACKLOG.md and keep the session clean, open it as a parallel workstream (the opening ceremony in the backlog protocol, subject to the front ceiling above), or switch tasks (closing the current one first — the closing ceremony). User decides. Applies to your own drive-by temptations too (incidental refactors, "I noticed X nearby"). Exception: a genuine blocker for the active task is the Replan Gate, not this.
- **Surgical Changes** — Every changed line must trace directly to the request. Don't "improve" adjacent code, comments, or formatting; don't refactor what isn't broken; match existing style even if you'd do it differently. Clean up only the orphans YOUR change created (now-unused imports/vars/functions) — never pre-existing dead code, just mention it. This is the line/diff-level counterpart to the Scope & Session Guard (which operates at task level).
- **Understanding phase MANDATORY** before planning — never skip to plan without gathering context
- **Detect composite tasks** — propose splitting tasks that mix multiple concerns into independent backlog tasks (not subtasks) before planning
- **Ask contextual questions** — gather all necessary context to produce polished code
- **Update the task's state sheet** (`artifacts/T-XXX/state.md`) with step progress during execution
- **Atomic commits**: `type(scope): description`
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
