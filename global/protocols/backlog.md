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

**Two records in this file are history and are meant to be**: the roster table, and `## Quick Tasks
Completed`, which is the only trace a quick task leaves anywhere. Everything else is the present — a
closed epic's or task's narrative belongs in `archive/`, and the ledger guardian reports it wherever in
the file it sits. The exemption is named rather than left implicit because a rule forbidding history
outright would contradict this very skeleton, and a guard written to such a rule's literal words would
flag the template's own section. The guard implements the pair by reading narrative prose and never a
table row: a record kept as a table is exempt by its shape, so there is no region boundary to place
wrongly — an earlier form of it exempted from the quick-task heading to the next heading, and since that
section is last here, the exemption ran to end of file and a narrative appended at the bottom was
invisible.

**Areas** names the parts of the codebase a front declared when it opened, in the project's own
`area_kind`. It is what the next opening weighs its own declaration against (see Opening a
Workstream) — front-scoped, decided once, never a running account of what the task turned out to
touch.

**Tool** names what created that front's checkout. Front-scoped and decided once, like Areas, and read
by the closing ceremony's dismantling move: the ownership condition says the checkout is removed by
whatever created it, and this column is the only thing that says what that was. The coordinator's own
row has nothing to name — nothing created it.

```markdown
# Session State

## Workstreams

| Workstream | Checkout | Branch | Task | Epic | Areas | Tool | Opened |
|---|---|---|---|---|---|---|---|
| coordinator | . | main | T-XXX | E-XXX | auth, billing | — | 2026-08-19 |
| ws-b | ../proj-wt-b | you/t-yyy-slug | T-YYY | E-XXX | notifications | <tool> | 2026-08-19 |

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

**The `phase:` line is machine-read, and the declaration is a line — not a shape found anywhere in the
document.** What is read is the **first** line that declares the field, and two things about that line
are load-bearing: it begins with the label, and the label is followed by a colon. Write it as
`phase: **UNDERSTAND**` — the asterisks and the upper-case are the house style, not the contract, and a
reader that treats them as optional is reading correctly. No other line is read, so the rest of the
sheet is prose and stays prose: a decision that quotes the field, a resume note that names it, a code
block that shows the form, none of them declare anything. A sheet whose phase is written in any other
form declares no phase at all, and a reader that finds none acts as it does on a sheet that has none.
Two legacy labels are accepted in the same position — `Current phase:` and its Spanish twin
`Fase actual:` — which is what a project that never migrated declares its phase with in the ledger.

That rule is the authority, and the Understand read-only rail's pattern is a note about the enforcer:
where the two disagree the rule is what the writers of the sheet and the readers with no parser go by,
and the pattern is the thing to correct.

**A checkout holds at most one sheet claiming its branch.** The `branch:` line is a claim, and the
resolution below reads it as one: two sheets claiming the branch a checkout is on have no unique owner,
so the reader stops and the work stops with it. The limit is what keeps that from happening, and it is
kept by an obligation on the writer — **whoever writes a claim releases every other claim in that
checkout, in the same act**. The writer sits at the claim and nowhere else: that is the moment the
reader would break, and an obligation placed at any other moment is one that gets forgotten while the
sheet it protects is already unreadable.

**The `branch:` line is machine-read on the same terms as the phase line above.** What is read is the
**first** line that declares the field, and two things about that line are load-bearing: it begins with
the label, and the label is followed by a colon. The value is a **single token** — a branch name and
nothing else — so `branch: main (paused)` declares no claim at all: a sheet that means to pause renames
the line rather than annotating it. No other line is read, so a decision that quotes a branch or a code
block that shows the form claims nothing. A sheet whose claim is written in any other form declares no
branch, and the resolution below answers for it exactly as it does for a sheet that names none — which
is silent by construction, so the accepted form is written here rather than left to the pattern.

A released claim is not a deleted one. The sheet keeps its papers and keeps the branch it belongs to,
in a field the rail cannot mistake for a claim:

```markdown
released-branch: you/t-xxx-slug
phase: **EXECUTE**
```

The rail's branch pattern is anchored at the start of the line, so `released-branch:` is not a claim to
it — it reads the sheet as declaring no branch, which is exactly what a released claim is. **The line is
renamed, not duplicated**: a sheet carrying both is still a claim, and a half-done release produces the
ambiguity the limit exists to prevent, with no diagnostic to say so. Resuming the
task re-claims the branch and releases whatever claimed it meanwhile; a released sheet left alone in a
checkout is still that checkout's own task, and the resolution below answers with it.

Two tasks open in one checkout is what makes this reachable — a paused task beside the one now being
worked. That is allowed and unchanged; what the paused one gives up is the claim, never its papers.

### Resolving the task

**The `branch:` line is how a checkout recognises its own task.** A working copy can hold several
sheets — artifacts travel as a whole — so whoever opens a workstream writes that line, and every
reader that needs to know which task a checkout is on follows the same four rungs, in order.

Two readers follow them. The read-only rail wants a phase, and `phase_source` in
`~/.claude/hooks/understand-write-guard.py` is the implementation of rungs 1 and 2 — the file that
wins if the two ever read differently. The phase commands want a task identifier. The ladder is
written here and nowhere else: a second statement of it is a copy that will drift, and two readers
disagreeing about which task a checkout is on is the failure the ladder exists to prevent.

The rungs assume a branch is checked out. **With none — a detached HEAD, or no git at all — there is
nothing to match, and the lone sheet answers whatever branch it declares.** Both readers do this, and
it is the one case where a sheet naming another branch may still be read: no branch is there to
contradict it. Two or more sheets and this case falls straight to rung 3.

1. **The sheet whose `branch:` is the branch currently checked out** — exactly one of them. A claim is
   a line that begins with `branch:`; `released-branch:` is not one and belongs to rung 2, and this
   holds for whoever is reading, not only for the rail whose pattern enforces it. A sheet that names
   *another* branch belongs to another workstream and is never read here.
2. **Failing that, the lone sheet that declares no branch.** Two kinds of sheet land here: one from a
   project that predates the field, which keeps the behaviour it always had, and one whose claim was
   released when the checkout took on another task — a lone released sheet is still that checkout's own
   task. Absence is never a wildcard, so this rung answers only while that sheet is alone among the
   sheets declaring no branch.
3. **Failing that, `STATE.md` — and only where it names exactly one task.** For the rail that is where
   a migrated roster carries no phase, so it stays silent by design. For a phase command the file is
   the task identifier itself, which is what makes the condition load-bearing: a roster holding
   several open fronts names several tasks, and a pre-migration ledger names the one task it was
   built around.
4. **Failing all of it, stop and name what was looked for.** A reader that cannot resolve a task does
   not choose one — ambiguity resolved by choice is indistinguishable from a correct answer, and for a
   phase command a wrong answer overwrites another task's papers. The rail has nothing to enforce and
   says nothing; a phase command says which rungs it tried and stops before writing any artifact. Two
   sheets claiming the same branch land here too, and what keeps them from arriving is stated above,
   not here: a checkout holds at most one claim, because writing a claim releases every other claim in
   that checkout. Two ceremonies carry it — the one that opens a workstream prunes the papers a new
   checkout does not own, and the one that closes a task deletes what it archived from every checkout
   that holds it. A rung crediting the opening alone reads as though the situation could only be born
   at creation, and the one that actually produces it is a front taking on its next task.

### The phase precondition

The ladder above answers *which task*. This answers *whether this phase may run on it*, and it is
stated here for the same reason the ladder is: three commands each holding their own copy of the
accepted positions is three copies that drift, and a command that accepts what another refuses is
worse than no check at all.

A phase command tests two things — after it has resolved its task, and before it does any of the
phase's work. Both are read from the task's own sheet and its papers, never from what the session
remembers.

- **Accepted positions.** `understand` runs on any position not later than its own: open below on
  purpose, because what the opening ceremony writes as a task's first position is undefined, and a
  precondition depending on it would refuse the ordinary path. `plan` runs on UNDERSTAND or PLAN.
  `verify` runs on EXECUTE or VERIFY.
- **The material leg.** A phase that consumes what an earlier one produced checks it is there: `plan`
  needs `understand.md`; `verify` needs `plan.md` and the Criteria Coverage table inside it, which is
  the mapping the audit inherits instead of rebuilding. `understand` consumes no artifact and so has
  no material leg — said out loud, because a silence is not a check that happened.
- **On disagreement.** Either leg failing is reported before anything is written: the phase the sheet
  declares, the phase that was asked for, and the material that is missing, named as a file. Then the
  command waits. No artifact is written until the operator answers. A warning printed and walked past
  is the defect with a note attached, and the operator has nothing to judge the answer with unless
  the report carries all three.
- **A confirmed run.** The operator may say go, and then the command runs — but the `phase:` line is
  left unchanged, and the run says in its report that it went out of phase. An audit authorised over a
  half-understood task does not make the task audited: stamping the position would erase the one fact
  that made the warning possible, and would leave a rail raised over a phase nobody is working.
- **A clean pass.** Both legs holding, the command writes its own phase to the sheet before starting
  the work. That write is what makes this precondition mean anything: a field a mechanism refuses on
  must have a writer, or the first forgotten edit blocks correct work and teaches everyone to route
  around the rule. `plan` additionally advances the sheet to EXECUTE when Conform closes, because the
  phase after it has no command of its own and nothing else would ever record it.

### Who writes what, when

| Moment | Roster (`STATE.md`) | Sheet (`artifacts/T-XXX/state.md`) |
|---|---|---|
| **Activation** | the coordinator adds the workstream row, with the front's declared areas | created, with branch, phase, step and autonomy — plus any collision acknowledged at the opening (see Opening a Workstream) |
| **During the phases** | untouched | the phase command writes the phase when it enters one (see The phase precondition above); step, decisions and the resume block kept current by whoever works the task |
| **Pause** | untouched | carries everything needed to resume — it IS the handoff |
| **Archive** | the coordinator removes the row, last | collected into the coordinator first, then deleted with the rest of `artifacts/T-XXX/` — in every checkout that holds it, not only the coordinator's |
| **Quick task** | its row in Quick Tasks Completed, at close | none — a quick task writes no sheet, and states its 1-2 steps in the conversation |

### Migrating an existing ledger

A project already running ai-flow has a `STATE.md` full of task context, and `update` never
overwrites project data — so the move is manual and takes one edit: replace the current-task block
with the `## Workstreams` table, move the active task's phase, step, autonomy and decisions into its
sheet, and keep only the notes that are genuinely cross-task. Nothing else in `.ai-flow/` changes.

A roster that predates the **Tool** column is not broken either: a front that names no tool reads as one
whose creator is unknown, and the dismantling move falls back to `git worktree remove` — the removal git
itself can always perform. Naming it is what lets the move reach for the tool's own means instead.

A roster that predates the **Areas** column is not broken: a front that declares no areas simply
reads as *cannot compare* at the next opening, which is exactly the verdict the ceremony defines for
it. Adding the column costs one edit and turns that verdict into a real comparison.

## Task Entry Format (business-first)

A task entry leads with behavior, in product language; technical detail is an annex:

- **Line 1 — the business statement**: which role, what changes or breaks for them, why it matters. Readable by someone who never opens the code.
- **Technical annex (optional, below)**: file:line evidence, suspected causes, skills. Welcome — but never the opening line.

A capture that cannot state its business line yet is captured with what is known; the gap is closed in Understand (Business Frame), never silently guessed.

## BACKLOG.md Size Budget (CRITICAL)

BACKLOG.md must contain **only pending work**. Everything closed lives in `archive/`. Closing a task must make the file SMALLER, never bigger.

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
verdict. Only the coordinator runs it. It is the symmetric half of `## Closing a Workstream` below: what
is decided and seeded here is what gets collected and removed there.

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

5. **Create the linked worktree.** It opens with a question asked before anything is created: **what
   tool is this project managed in?** The answer is read from the project layer (`front_tool` in
   `project.yml`) — and reading it is the point: **the decision may already have been made there, and
   then it is not this opening's to make.** Identifying it is this move's first act rather than a
   preference applied afterwards, because the reader who most needs this line is the one who does not
   know the project layer could have settled it already: they do not form an intention and go looking for
   permission, they look first. The reason is the shape of everything below: the conditions are facts the repository can
   answer, and the surface a person works in is not one of them — so a checkout can satisfy every one of
   them and still be a front its operator never sees.

   The tool the project declares is the default. It is preferred wherever it can satisfy the conditions,
   and what it does not bring is **completed** rather than traded away. Where the project **declares
   none**, the ceremony uses the native path and **says** it is doing so because nothing was declared: a
   silence and a declaration read identically in a report, and this is the one that used to be assumed
   for free.

   What a front needs, whatever produced it, is not a particular brand but a checkout that satisfies
   four conditions, each of them read from the repository rather than taken on trust:

   They are not symmetric across tools, and the move says which ones a tool is taking on **by hand** —
   an operator who reads a list of conditions without reading who pays for each discovers the unpaid
   ones at the moment they fail. What a tool actually brings is **read from the checkout it produced,
   never from its documentation**: a tool's silence about a condition is not evidence it ignores it, and
   what one version brings another may not. The attributions below say where each condition usually comes
   from; the checkout is what says whether it arrived.

   - **base** — the branch starts from the **published default branch**, which is what step 4 above
     checks: work committed and unpushed does not exist for a front cut from it. The native path gets it
     from `worktree.baseRef`; every other tool takes it on by hand, by naming the base ref explicitly at
     creation.
   - **data** — the checkout holds what the project's pattern file declares travels, and **only the
     papers** of the task it owns. Move 6 below is what makes that true. The native path gets the
     arriving half from `.worktreeinclude`; whether any other tool does is **per-tool and per-version**
     and is settled by looking — one measured case transferred exactly what that file selects while its
     own help never mentioned the file at all. So look first and take on by hand only what the checkout
     does not already hold. The prune is move 6's on every path regardless: a copy taken at creation is a
     snapshot, and a snapshot can arrive holding papers of tasks this front does not own.
   - **visibility** — the checkout is not visible to the coordinator's own **audit**. Outside the
     primary's tree that holds by construction; a checkout nested inside it holds only where the
     project's ignore rules cover that path. Left uncovered, a nested front is untracked content in the
     coordinator: the audit copies the whole of it into its snapshot and then requires the tree to be
     byte-exact against a working copy another session is writing. This one is **per-tool**: which of
     those two cases applies is decided by where the tool puts the checkout.
   - **ownership** — whatever created the checkout is what removes it, which is what the closing
     ceremony's dismantling move spends. A tool keeping a registry of its own is left pointing at a
     checkout something else deleted. This one holds on **every path** and is free on none: the tool
     that created the front is the one obliged to take it down, whichever tool that was.

   The native path — `EnterWorktree` in a session, `claude -w` from the shell, `isolation: worktree` for
   an agent — is **the floor**: the yardstick the rest are measured against and what the ceremony falls
   back to, never the first choice and never a requirement. It honours `worktree.baseRef` and
   `.worktreeinclude`, so base holds without help and the data arrives without help — the prune is still
   move 6's, on every path. It creates
   the checkout inside `.claude/worktrees/`, so there visibility is precisely what the project's ignore
   rules must cover — one line the ceremony **names and does not write**, because a project's ignore
   rules are the project's own. **No particular front-end is required**: any tool serves where the four
   conditions hold, and one that satisfies only some of them is completed by the move below.

   Where the declared tool cannot satisfy a condition and nothing completes it, the ceremony falls back
   to the floor — and that fallback costs something the four conditions cannot express: the operator
   loses their own view of the front. **Stop.** The opening resumes only once that is **acknowledged in
   writing on the task's sheet**, naming the condition that could not be satisfied and why proceeding
   without that view is acceptable. It is the same acknowledgement — and the same halt — that move 3
   above requires of a collision, for the same reason: a loss the ceremony chooses is a loss somebody
   decided, and there is no silent path past a decision. What is
   never acceptable is a checkout nobody checked.

6. **Seed the task's artifacts and prune the rest.** The pattern file carries `artifacts/` wholesale,
   so the new checkout arrives holding the papers of every open task, and the read-only rail cannot
   tell which task is its own from a pile: the checkout must hold only the artifacts of the task it
   owns, so prune every folder this front does not own. What is deleted there are copies — the
   coordinator keeps the originals. The engine ships the mechanism —
   `~/.claude/ai-flow/scripts/seed-front.sh <checkout> <T-XXX>` — which is what satisfies the data
   condition for a front-end that does not: it selects by the project's own pattern file, copies what
   that selects, and prunes what this front does not own. On the native path the copy has already
   happened and running it is what prunes. It leaves alone every file the checkout already holds, with
   one exception: **the papers of the task it is seeded for are replaced from the coordinator's**. That
   is the collection's sanctioned exception (`## Closing a Workstream`) read from the other side — the
   authoritative copy is the one from the checkout where the task was worked, and a front that has not
   worked it yet has none. What it repairs is a checkout born holding papers that have since
   moved on: what created it took a snapshot, and the coordinator writes to those papers both before
   that moment and after it. It is not how move 7's sheet reaches the front — that move writes the
   sheet there — and this move runs before it, so at an ordinary opening the replacement carries what
   the coordinator holds at that moment and nothing later.
   Where those papers were written *after* the coordinator's, the front is already working that task and
   its copy is the authoritative one: the move replaces none of them and **stops**, naming both copies,
   because no mechanism can choose there and choosing wrong destroys the only account of work in
   progress. The
   papers that stay are the ones **named on the command line** — the task it is seeded for, plus any
   further task this front is also working, paused or not. Naming them is the point: a front taking on its
   next task runs this move over papers that are live work, and inferring which those are from what is
   already present cannot tell them from the ones a creation-time copy dropped there a moment earlier —
   which on the native path is all of them, so nothing would ever be pruned. The ledger stays with the coordinator: BACKLOG.md, STATE.md, the
   decision log and the archive are never copied in. What the front must read there but must not own —
   its epic's Scope Contract — it reads from the coordinator, read-only (see the Understand protocol).

7. **Write the roster row and the task's sheet.** The row carries workstream, checkout, branch, task,
   epic, the declared areas, **what created the checkout** — the tool identified in move 5, which is
   what the dismantling move reads — and the date. The sheet carries the branch that owns the task, the phase,
   the step, the autonomy level, and any acknowledgement from step 3. The row is the coordinator's; the
   sheet is written **in the checkout where the task is worked** — the coordinator's when the task stays
   there, the front's when this ceremony created one — which is the rule the sheet already lives by
   (`## State Files`). It is written there rather than copied across afterwards because the seeding move
   ran before this one: a sheet written only in the coordinator is one the front has no way to receive. The `branch:` line is what makes
   the sheet findable in a checkout that holds several: without it, the front the ceremony just opened
   has no state anything can read. Writing it is writing a claim, so this move carries the obligation
   that comes with one: **release every other claim to that branch in this checkout**, in the same act
   (see `## State Files`). Ordinarily there is nothing to release — the move before this one pruned the
   checkout — but a front taking on its next task runs this move over a checkout it has been working,
   and that is the case the release exists for.

## Closing a Workstream

A front's work does not reach the coordinator by merging — it reaches it by this ceremony, of which the
merge is one move. Only the coordinator runs it, and it runs one front at a time. It is the symmetric
half of `## Opening a Workstream` above: what that ceremony declared, created and seeded is what this
one validates, collects and takes down.

It runs at **every task close**, not once per front: moves 6 and 7 are its tail and run only when the
front has no next task, because a worktree holds a workstream — an epic with its serial chain inside —
and lives across the tasks in it.

With a single front open — the ordinary case — moves 2, 3 and 6 have nothing to do: the task was worked in
the coordinator, so its papers are already there, there is no branch to merge, and there is no second
checkout to take down. The ceremony then reduces to what closing has always been. Naming only the two that
need no second checkout reads as though the merge always has work, which turns the ordinary close into a
ritual with a dead move in it.

**The order is the protection.** Nothing merges before the coordinator holds the papers, and nothing is
recorded as done before it is in the trunk — so a ceremony interrupted at any move leaves either work
still to do or work already safe, never a lie in the record. Nothing enforces the order: the task's own
sheet is where an interrupted close is written down, and the roster is the queue.

1. **The user validates the branch.** Inside a front commits are free — the branch is disposable by
   construction — so what the user approves is the branch and not each commit, and nothing merges
   without it. In the coordinator the per-commit rule of the Commit Protocol is untouched: there is no
   branch to approve.

2. **The coordinator collects the task's papers.** `artifacts/T-XXX/` is written in the checkout where
   the task is worked and lives outside version control, so it does not travel with the branch and the
   merge carries none of it. The coordinator locates the front's checkout in the repository's own
   worktree listing, matched by the branch on that front's roster row — git is the authority, the row can
   be stale. If the listing does not name it, stop: the papers may already be gone, and no later move
   reconstructs them. The collection **replaces** whatever the coordinator holds for that task, and it is
   the one sanctioned exception to never overwriting a task's papers — the copy from the checkout where
   the task was worked is the authoritative one, while the coordinator's is a snapshot from the moment
   the front opened. The coordinator pulls; a linked worktree still never writes here.

3. **The merge lands in the coordinator**, one front at a time. If it cannot complete, the ceremony stops
   here: the front stays open and the record is not written, because a task recorded as done that is not
   in the trunk is a lie in the record. The papers are already safe — that is what collecting first
   bought.

4. **The record is written, and only here.** What this move runs is the single-task archive checklist
   below, plus the epic-completion checklist when the epic ends with this task. A quick task has no papers
   to collect and no archive to write: its close is the merge plus its row in the coordinator's Quick
   Tasks table — a row a linked checkout never writes.

5. **The work is put into effect.**
   A task the record calls done still does not exist for the sessions it governs until whatever
   distributes it has run: committed is not installed, and a close that ends before this is a
   different lie than the one move 3 prevents. The command is the project's own, read from the
   project layer (`commands.distribute` in `project.yml`) — this protocol names no project's command. A project
   that declares none has nothing to distribute, and the move **says so**: in a report, silence and a
   distribution that never happened read identically. It runs in the coordinator, on the trunk the
   merge just landed, and nowhere else — run from a front it would repoint what the installed
   toolchain calls its source at a checkout the next move deletes, and the guard that watches for
   exactly this divergence goes quiet for good. The run **shows** the distribution took effect, by
   whatever check the project has; where there is no check it reports the result unproven rather than
   assuming it. If it cannot be shown to have landed, the ceremony **stops** here with the front's
   roster row still in place — the record is written by now, so the row is the only thing left saying
   work remains, which is why this move sits before the tail and not after it. It runs at **every
   task close**, a quick task's included, and carries none of the condition the two moves below it do.

6. **The front's working copy is dismantled by whatever created it** — the counterpart of the ownership
   condition in step 5 of the opening, and what created it is read from that front's **roster row**,
   where move 7 of the opening wrote it. Claude Code's `ExitWorktree` removes only what `EnterWorktree`
   created **in this session** and is a declared no-op for anything else, so it takes down a front opened
   in this session and nothing more: a front lives across the tasks in it, and one opened earlier — or by
   another front-end — is removed by that tool's own means, or by `git worktree remove`, which is also
   what a row naming no tool leaves the move with. What says the
   move happened is the repository's own answer, not the tool's: the checkout no longer appears in
   `git worktree list`. Never before move 2: removing the checkout destroys the task's papers, and git
   cannot restore what it never tracked. Runs only when the front has no next task.

7. **The front's roster row is removed** — the coordinator's last write, and the roster's own proof that
   the front is closed. Not while `git worktree list` still names that front's checkout: the row is then
   the only thing left saying work remains. Runs only when the front has no next task.

## Directory Hygiene

**CRITICAL:** `.ai-flow/` must stay clean. Run the appropriate checklist after each lifecycle transition.

### After ARCHIVE (single task)

This checklist is what move 4 of `## Closing a Workstream` runs, and it runs in the coordinator:
the ledger has one writer, and every step below is that writer at work — except step 4, which also
reaches into the checkout where the task was worked to delete a copy of what it just archived.

1. **Steering update**: did the task teach or modify a domain rule? -> edit the rule in the steering file's **body** AND regenerate its `## Nano` line **in the same edit** — an edit that touches only one of the two is incomplete. No new rule learned -> skip.
2. **product.md write-back**: copy every rule from understand.md's `New business rules minted` into product.md's Business Rules (with T-XXX provenance); update the Glossary if the task sharpened a term. A business rule that stays only in the archived artifact will be re-asked or re-assumed. None minted -> skip.
3. Generate `archive/T-XXX/summary.md` (see Archive Summary template)
4. **Delete** `artifacts/T-XXX/` entirely — in **every checkout that holds it**, not only here. A task
   worked in a linked worktree leaves a copy there, and the ceremony's tail removes that checkout only
   when the front has no next task: a front continuing its chain keeps the copy, the next task's sheet
   claims the same branch, and the checkout is left with two claims and no way to say which task it is
   on. Locate the front's checkout the way move 2 of the closing ceremony locates it — the repository's
   own worktree listing, matched by the branch on that front's roster row. What makes this safe is that
   the record is already written: step 3 generated the summary, so what is deleted is a copy of what the
   archive holds. Which is also why it happens **here and not earlier — never before the collection, and
   never at collection time**: move 3 can still stop the ceremony, and a front whose merge failed is a
   front still working that task, with the papers it needs gone and git unable to restore what it never
   tracked.
5. Remove task from BACKLOG.md (move from Done to nowhere — it's in the archive now)
6. Write the session-close entry to `archive/CHANGELOG.md` (once — this is its permanent home) **and** copy it to the BACKLOG.md top. If BACKLOG.md then holds more than 3, **delete** the oldest from BACKLOG.md — do NOT re-append it to `archive/CHANGELOG.md`, it has been there since its own close (see Size Budget)
7. Leave the workstream row to move 7 of `## Closing a Workstream`, its sole owner: the row is removed
   only when the front has no next task, and a front continuing its chain keeps its row with the task
   field advanced (coordinator only — other open fronts keep theirs). The task's `state.md` went with
   `artifacts/T-XXX/` in step 4.

### Business-Miss Rule

When a shipped task turns out to violate business intent (the code was right; the business was assumed or wrong), treat it as feedback, not just a bug: alongside the fix task, write the missing rule to product.md — or the miss *category* to the relevant protocol. A business miss that only produces a bugfix will repeat.

### Steering Nano Blocks

Every code-domain steering file opens with a `## Nano` block: one line per rule/section, always **derived from the body** (two levels, one file — same-diff is the main defense against drift). `pencil-design.md` (design sessions) is exempt. Readers hit the nano first and read the full body only when the task touches that domain (see Understanding protocol > Steering Files). The nano is regenerated whenever the body changes — step 1 of the archive checklist enforces it.

### After Epic completion

1. **Icebox batch review**: go through the epic's `## Icebox` entries WITH the user — each is promoted to a real T-XXX task (now it gets an ID and priority) or deleted. The Icebox must hold no entries from closed epics.
2. Generate `archive/E-XXX-[slug].md` (see Epic archive template) — surviving Icebox promotions go under "What Was NOT Done"
3. **Verify** that `artifacts/` retains no folder of a task of this epic — deleting is the per-task
   close's own move (step 4 above), which knows what it archived. If a folder is still there, name it
   and stop: it belongs either to a task closed without its checklist or to a front that is still
   open, and a sweep cannot tell those apart.
4. Remove all epic tasks from BACKLOG.md Done section
5. Move the epic row to `archive/EPICS.md` + its Execution Order block to `archive/EXECUTION-ORDERS.md` (Size Budget)
6. **Verify** the roster holds no row for a front of this epic — move 7 of `## Closing a Workstream` is
   the only remover, and by now it has run for each of them. A row still there names a front that is
   still open: name it and stop, rather than removing it here (rows of fronts outside the epic stay).

### Invariants (always true)

- `artifacts/` contains **only** `T-XXX/` folders for **active or in-progress** tasks — never completed
  ones, and this holds in **every checkout**, not only the coordinator's. A copy left behind in a front
  is what puts two claims on one branch (see State Files)
- No root-level files in `artifacts/` (no templates, no loose files)
- No empty directories anywhere in `.ai-flow/`
- BACKLOG.md Done section is **transient** — tasks stay there only until archived, not permanently
- BACKLOG.md stays under ~300 lines and contains only pending work (see Size Budget)
- STATE.md is an index of open workstreams — one row per front, no per-task context, and **no historical
  narrative outside its two sanctioned records**: the roster table and `## Quick Tasks Completed`. Closed
  work's narrative belongs in `archive/` wherever in the file it is written (see State Files)

### Allowed structure

```
.ai-flow/
├── BACKLOG.md
├── STATE.md
├── decisions-global.md
├── product.md              # Product context (users, roles, flows)
├── steering/               # Domain rules and pitfalls (loaded per-task)
├── artifacts/              # ONLY open task folders
│   └── T-XXX/              # One folder per open task
│       └── state.md        # That task's phase, step, autonomy and decisions
└── archive/                # Completed work
    ├── CHANGELOG.md        # Session-close entries (newest first)
    ├── EPICS.md            # Closed epics index (rows moved from BACKLOG.md)
    ├── EXECUTION-ORDERS.md # Execution Order blocks of closed epics
    ├── T-XXX/summary.md
    └── E-XXX-slug.md
```

**The phase protocols are not in this tree.** They live centrally at `~/.claude/ai-flow/protocols/`,
installed once and shared by every project: a project holds only its **data**, and the engine is versioned
in the ai-flow repository. A project directory that still contains them is a stale install, not a valid
structure — and a drift-check hook nags whenever the installed engine and the trunk diverge.
