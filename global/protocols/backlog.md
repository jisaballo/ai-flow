# Backlog Management Protocol

## Basics

- Sequential IDs: T-001, T-002, ...
- Priorities: `critical`, `high`, `medium`, `low`
- On completion: archive to `.ai-flow/archive/T-XXX/` with summary.md, remove from BACKLOG.md, remove this workstream's row from STATE.md

## State Files

Two files carry state and they never overlap. **A task's state belongs to the task**; `STATE.md` is a
roster of open workstreams.

### `STATE.md` — the roster (coordinator only)

One row per open workstream and nothing task-specific. Only the **coordinator** checkout writes it,
and only at ceremonies — a workstream opens, a task closes and merges. A linked worktree never
receives it and never edits it.

**Areas** names the parts of the codebase a front declared when it opened, in the project's own
`area_kind`. It is what the next opening weighs its own declaration against (see Opening a
Workstream) — front-scoped, decided once, never a running account of what the task turned out to
touch.

```markdown
# Session State

## Workstreams

| Workstream | Checkout | Branch | Task | Epic | Areas | Opened |
|---|---|---|---|---|---|---|
| coordinator | . | main | T-XXX | E-XXX | auth, billing | 2026-08-19 |
| ws-b | ../proj-wt-b | you/t-yyy-slug | T-YYY | E-XXX | notifications | 2026-08-19 |

> Per-task phase, step, autonomy and decisions live in `artifacts/T-XXX/state.md`.
> This file is a roster: the coordinator writes it, only at ceremonies.

## Notes

Cross-workstream context only — nothing that belongs to a single task.

## Quick Tasks Completed

| Date | Description | Commit |
|------|-------------|--------|
```

### `artifacts/T-XXX/state.md` — the task's sheet

Written by whoever works the task, in the checkout where it is worked. It travels with the task's
artifacts and is never reset, so a paused task keeps its sheet: coming back to it, this file is the
whole handoff.

```markdown
# T-XXX — [title]

branch: you/t-xxx-slug
phase: **EXECUTE**
step: 2 of 3
autonomy: Guided

## Decisions

- [decision taken during this task, with the why]

## Resume from here

- last touched: `path/to/file`
- uncommitted: [what sits in the working tree]
- next action: [the next thing to do]
```

**The `phase:` line is machine-read.** The Understand read-only rail parses exactly this form, so the
phase name stays upper-case between the asterisks (`phase: **UNDERSTAND**`).

**The `branch:` line is how a checkout recognises its own task.** A working copy can hold several
sheets — artifacts travel as a whole — so the rail reads the sheet whose branch is the one currently
checked out, and whoever opens a workstream writes that line. A sheet that names *another* branch
belongs to another workstream and is never read here. With no match, only a sheet that declares no
branch at all can still be this checkout's — a project that predates the field keeps the behaviour it
always had. Failing that the rail reads `STATE.md`, where a migrated roster carries no phase, so the
rail stays silent: by design, because nothing in the checkout claims the branch. Two sheets claiming
the same branch land there too — keeping a checkout down to the sheets it owns is the job of the
ceremony that opens a workstream.

### Who writes what, when

| Moment | Roster (`STATE.md`) | Sheet (`artifacts/T-XXX/state.md`) |
|---|---|---|
| **Activation** | the coordinator adds the workstream row, with the front's declared areas | created, with branch, phase, step and autonomy — plus any collision acknowledged at the opening (see Opening a Workstream) |
| **During the phases** | untouched | phase, step, decisions and the resume block kept current |
| **Pause** | untouched | carries everything needed to resume — it IS the handoff |
| **Archive** | the coordinator removes the row | deleted with the rest of `artifacts/T-XXX/` |
| **Quick task** | its row in Quick Tasks Completed, at close | none — a quick task writes no sheet, and states its 1-2 steps in the conversation |

### Migrating an existing ledger

A project already running ai-flow has a `STATE.md` full of task context, and `update` never
overwrites project data — so the move is manual and takes one edit: replace the current-task block
with the `## Workstreams` table, move the active task's phase, step, autonomy and decisions into its
sheet, and keep only the notes that are genuinely cross-task. Nothing else in `.ai-flow/` changes.

A roster that predates the **Areas** column is not broken: a front that declares no areas simply
reads as *cannot compare* at the next opening, which is exactly the verdict the ceremony defines for
it. Adding the column costs one edit and turns that verdict into a real comparison.

## Task Entry Format (business-first)

A task entry leads with behavior, in product language; technical detail is an annex:

- **Line 1 — the business statement**: which role, what changes or breaks for them, why it matters. Readable by someone who never opens the code.
- **Technical annex (optional, below)**: file:line evidence, suspected causes, skills. Welcome — but never the opening line.

A capture that cannot state its business line yet is captured with what is known; the gap is closed in Understand (Business Frame), never silently guessed.

## BACKLOG.md Size Budget (CRITICAL)

BACKLOG.md is loaded at session start — it must contain **only pending work**. Everything closed lives in `archive/`. Closing a task must make the file SMALLER, never bigger.

**Hard rules:**
- **Soft cap ~300 lines.** If BACKLOG.md exceeds it, something closed is being duplicated there — move it to `archive/`.
- **Session-close changelog entries** (`> YYYY-MM-DD — ...`) go to `archive/CHANGELOG.md` (newest first) — that file is the **only** home, written **once**, at close time. BACKLOG.md keeps a **copy** (condensing is fine) of the **3 most recent** as session continuity; when adding a new one, the oldest of the 3 is **deleted from BACKLOG.md, NOT moved anywhere** — it is already in `archive/CHANGELOG.md`.
  - ⚠️ Reading "rotate the oldest out" as "append it to `archive/CHANGELOG.md`" produces duplicate pairs (a short BACKLOG copy prepended above the already-archived long entry). Rotation is a **delete**, never a write to the archive.
  - Several entries with the **same task/epic ID are legitimate** when they record distinct lifecycle events (`opened` / `activated + split` / `re-audited` / `closed` / `visual reverted`). Same ID alone is NOT a duplicate — only same ID **and** same date **and** one text a condensation of the other.
- **Closed epics**: the row moves verbatim to `archive/EPICS.md` (index) — never fatten the row in BACKLOG.md with a close summary; that narrative belongs in `archive/E-XXX-[slug].md`.
- **Execution Order blocks**: only for epics with pending tasks. On epic close, move the block verbatim to `archive/EXECUTION-ORDERS.md`.
- **Dependencies table**: only rows where BOTH epics still have pending work.

## Epics (Lightweight Task Grouping)

Epics group related tasks under a shared goal. They are tracked in a dedicated section of BACKLOG.md — no separate files until archival.

**BACKLOG.md Epics section:**
```markdown
## Epics

| ID | Name | Tasks | Status |
|----|------|-------|--------|
| E-001 | User Auth Overhaul | T-012..T-021 | done |
| E-002 | Payment Flow Fixes | T-001, T-002, T-004 | active |
```

**Rules:**
- Epic IDs: E-001, E-002, ... (sequential — check `archive/EPICS.md` for the highest used ID)
- Status: `backlog`, `active`, `done`
- Tasks can optionally reference their epic in BACKLOG.md (column or note)
- Epics are informational grouping — they do NOT change task lifecycle or create hierarchy
- When all tasks in an epic are done, mark epic as `done` and apply the Size Budget moves (row -> `archive/EPICS.md`, Execution Order block -> `archive/EXECUTION-ORDERS.md`)
- The Epics section in BACKLOG.md lists ONLY epics with pending tasks

### Epic Scope Contract (MANDATORY at epic creation)

When investigation produces an epic, its Execution Order block MUST include:

- **Goal**: one sentence — what done looks like for the epic.
- **Planned Tasks**: the task list produced by the investigation (this count is the baseline for the Growth Budget).
- **Non-Goals**: explicit list of things the investigation saw but deliberately excluded, plus standing exclusions ("Do NOT refactor adjacent code", "Do NOT fix pre-existing issues found along the way").

The contract is FROZEN. Changing Goal or Non-Goals requires explicit user approval — never a mid-task decision.

### Growth Budget

If an epic's committed tasks exceed its Planned Tasks baseline by >50% (or by 2 tasks, whichever is greater), STOP — no new task activation until the user reviews the epic: re-plan it, descope it, or split a follow-up epic.

### Icebox (discoveries)

Discoveries captured via Discovery Triage (see Understanding protocol) live in BACKLOG.md under `## Icebox` as one-liners:

```markdown
- (E-XXX, found in T-YYY) description
```

No T-ID, no priority, no artifacts. Icebox entries count as pending work for the Size Budget but are NEVER activated directly — promotion to real T-XXX tasks happens only at the epic-close batch review (or when the user explicitly asks for one).

**On epic completion**, generate `.ai-flow/archive/E-XXX-[slug].md`:
```markdown
# Epic: E-XXX - [Name]

## Goal
[What this epic aimed to achieve]

## Tasks Completed
| ID | Description | Commit |
|----|-------------|--------|
| T-012 | Implement OAuth2 flow | `0dbd7360` |
| ...  | ... | ... |

## Key Decisions
- [1-2 line summary of important decisions made during the epic]

## What Was NOT Done
- [Anything deferred or descoped, with rationale]

## Completed
[Date]
```

## Archive Summary (Per Task)

When archiving a task, **always** generate `.ai-flow/archive/T-XXX/summary.md`:
```markdown
# T-XXX: [Title]
- **Completed:** [date]
- **Commit(s):** [hashes]
- **Files modified:** [list]
- **Key decisions:** [1-2 lines]
- **Epic:** [E-XXX if applicable, or "none"]
```

This provides single-file context recovery without reading multiple artifacts.

## Handling Composite Tasks in Backlog

When activating a task ("work on T-XXX"), the Understanding phase automatically detects composite tasks and proposes splitting. See Understanding Phase Protocol > Automatic Task Split for the full protocol.

## Opening a Workstream

A second front does not begin by creating a checkout — it begins here, and this ceremony ends in a
verdict. Only the coordinator runs it. It is the symmetric half of the closing checklists below: what
is decided and seeded here is what gets harvested and removed there.

With a single front open — the ordinary case — steps 3 to 6 have nothing to do: there is no other
front to weigh, and the checkout the task is worked in already exists. The ceremony then reduces to
what activation has always been, plus the declaration in step 2.

1. **Mint the ID** and write the task's entry. The ledger lives with the coordinator and only the
   coordinator hands out IDs: the same number issued twice is the one race no later ceremony repairs.

2. **Declare the front's areas** — the parts of the codebase this front expects to touch, named in the
   project's own `area_kind` (see `project.yml`). The declaration is made before the task is
   understood, so it is coarse by construction: name the units, never the files. It is recorded on the
   front's line in the roster, where every later opening reads it.

3. **Weigh the declaration against every open front.** Read the roster and compare this declaration
   with the one each open front made — the coordinator is a front and is weighed like any other.
   Exactly one verdict comes out:
   - **clear** — no open front declared any of these units. Continue.
   - **collision** — an open front declared one of them. Stop. The opening resumes only once the
     collision is acknowledged in writing on the task's own sheet, naming the front it meets and why
     proceeding anyway is acceptable. The acknowledgement is the protection; there is no silent path
     past it, and no refusal either — two fronts of one epic touching one file is ordinary, and a rule
     people route around protects nothing.
   - **cannot compare** — an open front declares nothing, and that is never reported as clear:
     silence is not an all-clear, it is a front that cannot be weighed. Name it, say the comparison
     could not be made, and let the acknowledgement above carry the decision.

4. **Check the default branch is published.** A front cut `fresh` starts from the published default
   branch, so anything committed and unpushed does not exist for it: if the default branch holds
   commits the remote has not seen, stop and name them before anything is created. Publishing is part
   of opening a front, not an afterthought.

5. **Create the linked worktree** with Claude Code's own worktree tooling — `EnterWorktree` in a
   session, `claude -w` from the shell, `isolation: worktree` for an agent — and never a bare
   `git worktree add`, which honours neither `worktree.baseRef` nor `.worktreeinclude` and so
   produces a checkout without the project's data. The worktree goes outside the primary's tree; one
   nested inside it would bind the guardrail hooks to the wrong working copy.

6. **Seed the task's artifacts and prune the rest.** The pattern file carries `artifacts/` wholesale,
   so the new checkout arrives holding the papers of every open task, and the read-only rail cannot
   tell which task is its own from a pile: the checkout must hold only the artifacts of the task it
   owns, so prune every folder this front does not own. What is deleted there are copies — the
   coordinator keeps the originals. The ledger stays with the coordinator: BACKLOG.md, STATE.md, the
   decision log and the archive are never copied in. What the front must read there but must not own —
   its epic's Scope Contract — it reads from the coordinator, read-only (see the Understand protocol).

7. **Write the roster row and the task's sheet.** The row carries workstream, checkout, branch, task,
   epic, the declared areas and the date. The sheet carries the branch that owns the task, the phase,
   the step, the autonomy level, and any acknowledgement from step 3. The `branch:` line is what makes
   the sheet findable in a checkout that holds several: without it, the front the ceremony just opened
   has no state anything can read.

## Directory Hygiene

**CRITICAL:** `.ai-flow/` must stay clean. Run the appropriate checklist after each lifecycle transition.

### After ARCHIVE (single task)

1. **Steering update**: did the task teach or modify a domain rule? -> edit the rule in the steering file's **body** AND regenerate its `## Nano` line **in the same edit** — an edit that touches only one of the two is incomplete. No new rule learned -> skip.
2. **product.md write-back**: copy every rule from understand.md's `New business rules minted` into product.md's Business Rules (with T-XXX provenance); update the Glossary if the task sharpened a term. A business rule that stays only in the archived artifact will be re-asked or re-assumed. None minted -> skip.
3. Generate `archive/T-XXX/summary.md` (see Archive Summary template)
4. **Delete** `artifacts/T-XXX/` entirely
5. Remove task from BACKLOG.md (move from Done to nowhere — it's in the archive now)
6. Write the session-close entry to `archive/CHANGELOG.md` (once — this is its permanent home) **and** copy it to the BACKLOG.md top. If BACKLOG.md then holds more than 3, **delete** the oldest from BACKLOG.md — do NOT re-append it to `archive/CHANGELOG.md`, it has been there since its own close (see Size Budget)
7. Remove this workstream's row from STATE.md (coordinator only — other open fronts keep theirs; the task's `state.md` went with `artifacts/T-XXX/` in step 4)

### Business-Miss Rule

When a shipped task turns out to violate business intent (the code was right; the business was assumed or wrong), treat it as feedback, not just a bug: alongside the fix task, write the missing rule to product.md — or the miss *category* to the relevant protocol. A business miss that only produces a bugfix will repeat.

### Steering Nano Blocks

Every code-domain steering file opens with a `## Nano` block: one line per rule/section, always **derived from the body** (two levels, one file — same-diff is the main defense against drift). `pencil-design.md` (design sessions) is exempt. Readers hit the nano first and read the full body only when the task touches that domain (see Understanding protocol > Steering Files). The nano is regenerated whenever the body changes — step 1 of the archive checklist enforces it.

### After Epic completion

1. **Icebox batch review**: go through the epic's `## Icebox` entries WITH the user — each is promoted to a real T-XXX task (now it gets an ID and priority) or deleted. The Icebox must hold no entries from closed epics.
2. Generate `archive/E-XXX-[slug].md` (see Epic archive template) — surviving Icebox promotions go under "What Was NOT Done"
3. **Delete** `artifacts/T-XXX/` for ALL tasks in the epic
4. Remove all epic tasks from BACKLOG.md Done section
5. Move the epic row to `archive/EPICS.md` + its Execution Order block to `archive/EXECUTION-ORDERS.md` (Size Budget)
6. Remove the epic's workstream rows from STATE.md (coordinator only — rows of fronts outside the epic stay)

### Invariants (always true)

- `artifacts/` contains **only** `T-XXX/` folders for **active or in-progress** tasks — never completed ones
- No root-level files in `artifacts/` (no templates, no loose files)
- No empty directories anywhere in `.ai-flow/`
- BACKLOG.md Done section is **transient** — tasks stay there only until archived, not permanently
- BACKLOG.md stays under ~300 lines and contains only pending work (see Size Budget)
- STATE.md is an index of open workstreams — one row per front, no per-task context and no historical summaries (see State Files)

### Allowed structure

```
.ai-flow/
├── BACKLOG.md
├── STATE.md
├── decisions-global.md
├── product.md              # Product context (users, roles, flows)
├── steering/               # Domain rules and pitfalls (loaded per-task)
├── protocols/              # Phase protocols (loaded on demand)
│   ├── understand.md
│   ├── plan.md
│   ├── execute.md
│   ├── verify.md
│   ├── quick-path.md
│   ├── backlog.md
│   ├── codebase-mapping.md
│   └── discover.md
├── artifacts/              # ONLY open task folders
│   └── T-XXX/              # One folder per open task
│       └── state.md        # That task's phase, step, autonomy and decisions
├── archive/                # Completed work
│   ├── CHANGELOG.md        # Session-close entries (newest first)
│   ├── EPICS.md            # Closed epics index (rows moved from BACKLOG.md)
│   ├── EXECUTION-ORDERS.md # Execution Order blocks of closed epics
│   ├── T-XXX/summary.md
│   └── E-XXX-slug.md
└── codebase/               # Analysis files (optional)
    ├── CONCERNS.md
    ├── TESTING.md
    └── DRIFT.md
```
