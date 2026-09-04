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
| `artifacts/T-XXX/` | Task artifacts organized by task ID (state.md, understand.md, plan.md, verify.md, discoveries.md) |
| `archive/T-XXX/` | Completed tasks with all artifacts, decisions, and summary.md |
| `icebox/` | One parked discovery per file (`IB-XXX.md`) — the body each `## Icebox` index line is regenerated from; retired entries move to `archive/icebox/`, keeping the reason they died |
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

**This manual states no commit rule of its own — it routes.** Nothing distributes this file: the
installer writes it only when absent and the drift guard excludes it as user-owned, so a rule kept here
drifts against the copy the phases actually read, silently and for as long as nobody diffs the two. Each
fact below therefore lives with the mechanism that performs it:

- **When a commit happens, and the single approval that covers the task's work** — `protocols/backlog.md`,
  `## Closing a Workstream`: the preamble states the gate, move 1 is the approval.
- **What follows a task's last commit** — the same section: that ceremony runs immediately, never after
  the next task has started.
- **The atomic format, and that a commit must be green** — `protocols/execute.md`, the commit step of the
  Execute Step Protocol, which is the loop that performs both.
- **What the Auto level changes** — `protocols/lifecycle.md`, the autonomy table.
- **A quick task's commit format** — `protocols/quick-path.md`.

### Session Continuity

- **On start**: Resolve which task this checkout owns by the ladder in the backlog protocol (`Resolving the task`), then read that task's `artifacts/T-XXX/state.md`; STATE.md is the roster of open fronts. If a task is active, also read the protocol for the current phase
- **On pause**: Update the task's `artifacts/T-XXX/state.md` with last file, uncommitted changes, context — it is the handoff, and it survives the pause
- **On compaction**: re-read STATE.md and BACKLOG.md — nothing reloads them on its own

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
- Publish without user validation — the approval is move 1 of the closing ceremony (backlog protocol), and it covers the task's work in either kind of checkout. Commits themselves are free per step
- Skip or disable tests
- Commit secrets, credentials, or .env files
- Delete user data or drop tables/collections
- Force push to main
- Overwrite existing artifacts without checking

## Working Rules

- **One active task at a time per workstream** — STATE.md's roster holds one row per open front, and each front runs its own single active task; 2 fronts is the working parallelism, 3 the ceiling (measure the real cost before raising it)
- **Scope & Session Guard** — If a request arrives that is NOT part of the active task's plan, flag it in one line before acting: name whether it looks unrelated or related-but-separable, and ask whether to capture it to BACKLOG.md and keep the session clean, open it as a parallel workstream (the opening ceremony in the backlog protocol, subject to the front ceiling above), or switch tasks (closing the current one first — the closing ceremony). User decides. Applies to your own drive-by temptations too (incidental refactors, "I noticed X nearby") — but the destination differs and that difference is load-bearing: a **request** the user brings can be captured to BACKLOG.md, because it arrived from outside the work and the user is present to place it. A **finding of your own** goes through Discovery Triage (Understanding protocol) and never to BACKLOG.md while a task is in flight; routing one here would reopen, in the document loaded on every turn, the leak that test exists to close. Exception: a genuine blocker for the active task is the Replan Gate, not this.
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
