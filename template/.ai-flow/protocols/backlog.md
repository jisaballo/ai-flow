# Backlog Management Protocol

## Basics

- Sequential IDs: T-001, T-002, ...
- Priorities: `critical`, `high`, `medium`, `low`
- On completion: archive to `.ai-flow/archive/T-XXX/` with summary.md, remove from BACKLOG.md, reset STATE.md

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
- Epic IDs: E-001, E-002, ... (sequential)
- Status: `backlog`, `active`, `done`
- Tasks can optionally reference their epic in BACKLOG.md (column or note)
- Epics are informational grouping — they do NOT change task lifecycle or create hierarchy
- When all tasks in an epic are done, mark epic as `done`

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

When activating a task, the Understanding phase automatically detects composite tasks and proposes splitting. See Understanding Phase Protocol > Automatic Task Split for the full protocol.

## Directory Hygiene

**CRITICAL:** `.ai-flow/` must stay clean. Run the appropriate checklist after each lifecycle transition.

### After ARCHIVE (single task)

1. Generate `archive/T-XXX/summary.md` (see Archive Summary template)
2. **Delete** `artifacts/T-XXX/` entirely
3. Remove task from BACKLOG.md (move from Done to nowhere — it's in the archive now)
4. Reset STATE.md to idle (remove task-specific context)

### After Epic completion

1. Generate `archive/E-XXX-[slug].md` (see Epic archive template)
2. **Delete** `artifacts/T-XXX/` for ALL tasks in the epic
3. Remove all epic tasks from BACKLOG.md Done section
4. Reset STATE.md to idle

### Invariants (always true)

- `artifacts/` contains **only** `T-XXX/` folders for **active or in-progress** tasks — never completed ones
- No root-level files in `artifacts/` (no templates, no loose files)
- No empty directories anywhere in `.ai-flow/`
- BACKLOG.md Done section is **transient** — tasks stay there only until archived, not permanently
- STATE.md contains only current task context — no historical summaries

### Allowed structure

```
.ai-flow/
├── BACKLOG.md
├── STATE.md
├── decisions-global.md
├── product.md              # Product context (users, roles, flows)
├── protocols/              # Phase protocols (loaded on demand)
│   ├── understand.md
│   ├── plan.md
│   ├── execute.md
│   ├── verify.md
│   ├── quick-path.md
│   ├── backlog.md
│   └── codebase-mapping.md
├── artifacts/              # ONLY active task folders
│   └── T-XXX/              # Current task only
├── archive/                # Completed work
│   ├── T-XXX/summary.md
│   └── E-XXX-slug.md
├── steering/               # Domain-specific rules
│   └── {domain}.md
└── codebase/               # Analysis files (optional)
    ├── CONCERNS.md
    ├── TESTING.md
    └── DRIFT.md
```
