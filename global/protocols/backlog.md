# Backlog Management Protocol

## Basics

- Sequential IDs: T-001, T-002, ...
- Priorities: `critical`, `high`, `medium`, `low`
- On completion: archive to `.ai-flow/archive/T-XXX/` with summary.md, remove from BACKLOG.md, reset STATE.md

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

## Directory Hygiene

**CRITICAL:** `.ai-flow/` must stay clean. Run the appropriate checklist after each lifecycle transition.

### After ARCHIVE (single task)

1. **Steering update**: did the task teach or modify a domain rule? -> edit the rule in the steering file's **body** AND regenerate its `## Nano` line **in the same edit** — an edit that touches only one of the two is incomplete. No new rule learned -> skip.
2. **product.md write-back**: copy every rule from understand.md's `New business rules minted` into product.md's Business Rules (with T-XXX provenance); update the Glossary if the task sharpened a term. A business rule that stays only in the archived artifact will be re-asked or re-assumed. None minted -> skip.
3. Generate `archive/T-XXX/summary.md` (see Archive Summary template)
4. **Delete** `artifacts/T-XXX/` entirely
5. Remove task from BACKLOG.md (move from Done to nowhere — it's in the archive now)
6. Write the session-close entry to `archive/CHANGELOG.md` (once — this is its permanent home) **and** copy it to the BACKLOG.md top. If BACKLOG.md then holds more than 3, **delete** the oldest from BACKLOG.md — do NOT re-append it to `archive/CHANGELOG.md`, it has been there since its own close (see Size Budget)
7. Reset STATE.md to idle (remove task-specific context)

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
6. Reset STATE.md to idle

### Invariants (always true)

- `artifacts/` contains **only** `T-XXX/` folders for **active or in-progress** tasks — never completed ones
- No root-level files in `artifacts/` (no templates, no loose files)
- No empty directories anywhere in `.ai-flow/`
- BACKLOG.md Done section is **transient** — tasks stay there only until archived, not permanently
- BACKLOG.md stays under ~300 lines and contains only pending work (see Size Budget)
- STATE.md contains only current task context — no historical summaries

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
├── artifacts/              # ONLY active task folders
│   └── T-XXX/              # Current task only
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
