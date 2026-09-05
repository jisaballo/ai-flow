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

**Checkout** names where that front's working copy lives, and it is what locates the front. **Four**
sites match it against the repository's own worktree listing: the collection move of the closing
ceremony, that ceremony's dismantling move and its last move, and the deletion step of the archive
checklist. Front-scoped and decided once, like Areas and Tool — and unlike a branch, which a front
changes with every task in its chain, so a branch could never key this row: it would name the front's
first task forever. The coordinator's own row names its own checkout and none of the four looks for it —
a task worked there has its papers there already, nothing of it is dismantled, and its row is not a
front's.

**How the column is compared — stated here once, for all four readers**, because a rule each site
restates is a rule they can come to disagree about. Both sides are resolved before they are compared:
the listing answers in absolute paths and a row may record a relative one. A relative row is read
against **the coordinator's own checkout root** and never against whatever directory the session happens
to sit in — two levels down, `../proj-wt-digest-emails` otherwise resolves to a sibling of that subdirectory and
matches nothing, which is the wrong-meaning stop this key was chosen to remove, reintroduced through the
base. And **a path that does not resolve is not a match**: two unresolvable sides each answer with
nothing, and nothing equals nothing, so a checkout deleted by hand — still listed, because git has not
pruned it — would otherwise read as located and let the collection report success over papers that are
gone. `~/.claude/ai-flow/scripts/seed-front.sh` performs this same comparison for the opening's seeding
move, so a reader wanting it in code has one; the rule above is the protocol's own and does not depend on
that script keeping its present shape.

**Areas** names the parts of the codebase a front declared when it opened, in the project's own
`area_kind`. It is what the next opening weighs its own declaration against (see Opening a
Workstream) — front-scoped, decided once, never a running account of what the task turned out to
touch.

**Tool** names what created that front's checkout. Front-scoped and decided once, like Areas, and read by
**two** sites — the count is the fact, for the reason **Checkout** above gives about its own four. The
closing ceremony's **dismantling** move: the ownership condition says the checkout is removed by whatever
created it, and this column is the only thing that says what that was. And the archive checklist's
**step 7**, whose label rewrite has first to ask whether that tool offers a mutable label at all; it runs
in the coordinator, which has nothing else to learn the front's tool from. The coordinator's own row has
nothing to name — nothing created it.

```markdown
# Session State

## Workstreams

| Workstream | Checkout | Task | Epic | Areas | Tool | Opened |
|---|---|---|---|---|---|---|
| coordinator | . | T-XXX | E-XXX | auth, billing | — | 2026-08-19 |
| digest-emails | ../proj-wt-digest-emails | T-YYY | E-XXX | notifications | <tool> | 2026-08-19 |

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

## Ruled out

- hypothesis: [what was tested, and what killed it]
- alternative: [a route considered and not taken, with the reason it was rejected]

## Resume from here

- last touched: `path/to/file`
- uncommitted: [what sits in the working tree]
- next action: [the next thing to do]
```

**`## Ruled out` holds what a cut destroys.**
Both its lines are written only when there is something to write.
`## Decisions` above it records a decision *taken*, with its why; neither a hypothesis that
was tested and died nor a route considered and rejected is a decision, so neither had anywhere to go —
they lived in the session's context and nowhere else, and a session that ends takes them with it. That is
not hypothetical: one interrupted task's sheet was a partial dump and its split proposal, with the
alternatives it had rejected, was lost with the context. Each label is a **list item**, and a reader
looks for the bullet and then the label: `- hypothesis:`, `- alternative:`. That is deliberately **not**
the form `phase:` and `branch:` take — those two are declarations at the start of their line, and the
patterns that read them are anchored to exactly that, so a pattern written for them finds nothing here.
The distinction is stated because the difference is invisible in a rendered document and a guard written
to the wrong one of the two reports "nothing ruled out" for every task, green and false. Repeated labels
are the reason for the list: a task rules out several things, while the fields declared above are each
written once. The section is omitted entirely when the task ruled nothing out. Omitted, not filled
with "none": a field that almost always reads "none" is a field that stops being read, which is the
engine's own lesson that an alarm nobody is obliged to act on is an alarm nobody acts on.

The block above is a sheet **in flight**. A sheet the opening ceremony has just written carries
`phase: **ACTIVATE**` and no step yet — the position is stated below, and this is the one thing a reader
copying this block must not take from the illustration.

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

**The first position is `ACTIVATE`.** Activation writes `phase: **ACTIVATE**` on the machine-read line
above — the field is never left absent, because a sheet declaring no phase is read exactly as one that
has none. What it writes is a position and not a phase: it records that the task is open and in none
yet, and every phase after it is recorded by the command that enters it (see
`### The phase precondition`). Stated here, once, because a value each session picks is a value that
drifts — measured across 41 sheets it had taken four, and the read-only rail therefore stood raised over
some tasks and lowered over others, decided by nothing. Two failures come from the two wrong answers,
and naming the position is what closes both: written as `UNDERSTAND`, the rail is up from the instant
the task exists — before any investigation, and on a path that runs no phase command, for good, so the
task can never be written. Written as a phase further along, the rail stays down through the whole
investigation and the read-only discipline is unenforced in silence, and the audit's own leg would
accept a task nobody had planned. What the position costs is the gap between opening a task and
entering its first phase: writes there are not refused, which is accepted because no part of the
lifecycle asks for code inside it.

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
sheets — the coordinator holds every open task's by construction, and a front takes on its next task
while the paused one keeps its papers — so whoever opens a workstream writes that line, and every
reader that needs to know which task a checkout is on follows the same four rungs, in order. What a
front receives when it is created is pruned by the ceremony that created it; neither of those two
producers is, so the situation the ladder answers to is the one no ceremony removes.

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

A phase command reads three things — after it has resolved its task, and before it does any of the
phase's work. Two of the three are tested and can refuse the run; the third is read and reports. All
three come from the task's own sheet and its papers, never from what the session remembers.

- **Accepted positions.** `understand` runs on any position not later than its own: open below on
  purpose, because the first position the opening ceremony writes sits beneath it, and a leg that
  accepted only its own position would refuse the ordinary path — the one every task takes, straight
  from being opened into being understood. `plan` runs on UNDERSTAND or PLAN.
  `verify` runs on EXECUTE or VERIFY. `execute` runs on EXECUTE, which is the position `plan` writes
  when Conform closes — the same write the clean-pass bullet below already describes, so the position it
  accepts is one something in the chain actually produces. Its own command does not exist yet, and the
  check is performed meanwhile by a manual run: the plan protocol names that run as the real carrier and
  the command as a convenience over it, which is what keeps a position stated ahead of its command from
  reading as unreachable and being deleted by the next editor who looks for who enforces it.
- **The autonomy read.** The supervision level the task was granted is read from the same sheet, from its
  `autonomy:` line, and it is read **before the material leg is tested** — not by preference: the level
  decides what that leg may require, so a run that tested the material first would refuse an Auto task for
  lacking papers an Auto task never produces. The read itself refuses nothing — a level is a fact about how
  the run behaves, never a reason to stop it — and it still comes first, because the leg that does refuse
  cannot be evaluated without it. The command **names the level and the
  source it read it from**, then says what that level changes **for its own phase**; where it changes
  nothing there, it says so, because a level left unsaid is indistinguishable from a level nobody looked
  for, and the operator has nothing to correct. Where the sheet declares no level at all — a sheet
  written before the field, or one whose line was lost — the command proceeds as **Guided** and says it
  is defaulting, which is the map's own answer for an ambiguous classification; announcing the default is
  what separates a level that was read from one that was assumed. The levels themselves belong to the
  lifecycle map and are restated neither here nor in any command: what a command carries is the branch
  its own phase takes, and a command one sentence away from listing the levels is how the map grows the
  second copy its own home guard exists to prevent.
- **The material leg.** A phase that consumes what an earlier one produced checks it is there: `plan`
  needs `understand.md`; `verify` needs `plan.md` and the Criteria Coverage table inside it, which is
  the mapping the audit inherits instead of rebuilding — **except where the level says no artifact was
  produced**: at **Auto** the plan is inline, so `plan` consumes nothing and its leg requires nothing, and
  `verify` is not reached by that path at all. The exemption is the leg's own principle rather than a
  concession to it: what a phase must find is what it *consumes*, which is why `understand` has no leg and
  why an inline plan has nothing to be missing. Without it the engine refuses every Auto task at its
  second phase while its own map promises that path runs — the level being read one bullet earlier is what
  makes this decidable at all. `execute` needs that same `plan.md` and its
  Criteria Coverage table, and the conformance baseline manifest as well — the frozen contract the work
  is measured against, without which a step that quietly rewrote a stub has nothing to be caught by. The
  manifest is not required where Conform was legitimately skipped, and which runs those are is the plan
  protocol's own list (`## Conformance Tests` > `### When to skip`) — cited, never summarised here, and
  never counted: a count of another document's cases is wrong the moment it gains one. What matters at
  this end is that the list reaches ordinary full-path work and not only the quick path, so demanding a
  manifest here would refuse a lawful task — which is why dropping the exemption as a caveat turns a
  working phase into a blocked one. `understand` consumes no artifact and so
  has no material leg — said out loud, because a silence is not a check that happened.
- **On disagreement.** Either *tested* leg failing — the position or the material, never the autonomy
  read, which refuses nothing — is reported before anything is written: the phase the sheet
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

  **Two closes carry the end of the session with them: the close of Understand and the close of Execute.**
  Each writes the position the phase *after* it will declare — the close of Understand writes PLAN, the close
  of Execute writes VERIFY — which is the shape `plan` already uses at Conform's close rather than a new one.
  The close writes the phase, writes the sheet's `next action:` naming what the next session runs, announces
  the cut, and **ends the turn**. It **asks nothing**: no approval is sought, no option offered, and an
  operator who says to carry on gets the next phase in the same session with nothing refused and nothing
  recorded as an exception. It is not a gate, and it is not a warning printed and walked past either, because
  the work has not begun. The reason it rides on these writes rather than on steps of their own is that a
  habit announced beside an act that must happen anyway cannot be forgotten separately from that act.

  **Why these two and not every boundary.** A cut point is chosen on what the phase ahead reads, never on what
  it saves — measured across the chain the candidates worth taking sit within a few points of each other with
  overlapping spreads, so the saving cannot separate them. What separates them is that Plan is drafted from
  `understand.md`, and Verify reads the sheet, `understand.md`, the plan's Criteria Coverage table and the
  diff from git, and no conversation at all; whereas the phase after Conform names prior conversation as an
  input to the path it calls its default.
  So the write that advances the sheet to EXECUTE when Conform closes **announces nothing**, and that
  silence is a decision rather than an omission. What a cut costs is the account of *why* something was done: the next
  session can answer only from what was written, which is what `## Ruled out` above exists to catch.

  **Both closes state the line on every sitting, the short ones included.** **No threshold decides whether
  the line is spoken**: it is owed whatever the numbers say. What this replaced spoke only where the engine
  had judged the sitting costly — a judgement made on a signal the operator can see and the phase could
  not — so the operator paid a turn asking whether stopping was possible at all, which is the measured cost
  that bought the change.
  Saying it always is what makes it a fact rather than a suggestion: a line that appears only sometimes is
  one whose absence has to be interpreted, and guidance that is wrong on the short sitting is guidance that
  stops being read on the long one.
  What the close measures is therefore **not whether to speak but what to recommend** once it has, and the
  two are kept apart deliberately: a condition allowed to reach the first of them is a condition that
  silences the line, which is the whole of what this paragraph replaced.

  **The form is fixed, and it is short.** The line carries three things and no more: **cut available** — whether this sitting can end here — stated as a fact, not advice,
  and it **recommends the cut** wherever the context this session has accumulated exceeds what a fresh
  session would start with; the position the sheet now declares; and where the next session picks up, which
  is a pointer to the sheet's `next action:` and never a copy of it. It **requests no input**. That bar is a
  **comparison and not a threshold**, and both of its quantities are handed to the phase on every prompt by
  the hook that measures them, so nothing is written down here and nothing can go stale — the day a fresh
  session starts from somewhere else, the rule is still right. It was derived rather than chosen, and what
  that bought is on the record: the number this paragraph was about to record as a judgement sat three to
  four times past the simulated break-even, and turn count, which is what an unmeasured rule would have
  keyed on, predicts that break-even three to four times more loosely than context does. Below the bar the
  close **states no recommendation at all**, which is not the same as reassurance — an absence carries no
  claim, while a line calling the sitting cheap is one more thing to be wrong about, and a line that is
  wrong once stops being read. Cost is also not the only reason to stay, and the recommendation must not be
  read as licence to cut anywhere: it stops being the binding constraint early, and what keeps a cut from
  being taken at every possible stop is quality — which is why the chain permits one only at the two
  boundaries where a handoff artifact already exists. The precondition's own legs, the rung the task was
  resolved by and the ladder are not part of it: those are the run's report, and a close that narrates them
  buries its own reason under procedure. A turn ended with the operator's instruction unserved is itself a
  request to repeat it, so a close given no form to end in is one the model fills with a question — which is
  how a rule obliging it to ask nothing produced, in the field, *"tell me `continue` next time"*.

  **Where the sheet already declares the position the write is about to set, nothing is announced** and the
  phase's work proceeds. That branch is not tidiness, and it is written down because what it prevents is
  invisible in this prose: the session the cut created re-runs the command, the precondition accepts the
  position, the line is rewritten — and unguarded the announcement fires **again**, on the very session it
  produced, and again after that. The position it is about to overwrite is the discriminator, and it is data
  the command already holds. Nothing is needed for the out-of-phase confirmed run above: it leaves the line
  unchanged, so there is no write and no announcement.

  The quick and auto paths never reach either close, by construction rather than by a predicate written to
  exclude them: a quick task writes no sheet at all, and an auto task skips Understand, holds no criteria and
  skips Verify — so the write never occurs on either. Said out loud because a silence is not a check that
  happened; refused as a predicate because a rule with nothing to enforce is a rule that goes unread.

### Who writes what, when

| Moment | Roster (`STATE.md`) | Sheet (`artifacts/T-XXX/state.md`) |
|---|---|---|
| **Activation** | the coordinator adds the workstream row, with the front's declared areas | created, with branch, the first position, step and autonomy — plus any collision acknowledged at the opening (see Opening a Workstream) |
| **During the phases** | untouched | the phase command writes the phase when it enters one, and the `next action:` line with it wherever that write ends the session (see The phase precondition above); step, decisions and the rest of the resume block kept current by whoever works the task |
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

A roster that still carries a **Branch** column is not broken: nothing consults it. The close reads a
front's branch from the checkout it has just located, never from the roster, so the column is a value
nobody keeps current and nobody asks for. Dropping it costs one edit; leaving it costs a field that is
wrong from each front's second task onward, for whoever reads the roster rather than the ceremony.

## Task Entry Format (business-first)

A task entry leads with behavior, in product language; technical detail is an annex:

- **Line 1 — the business statement**: which role, what changes or breaks for them, why it matters. Readable by someone who never opens the code.
- **Technical annex (optional, below)**: file:line evidence, suspected causes, skills. Welcome — but never the opening line.

A capture that cannot state its business line yet is captured with what is known; the gap is closed in Understand (Business Frame), never silently guessed.

## BACKLOG.md Size Budget (CRITICAL)

BACKLOG.md must contain **only pending work**. Everything closed lives in `archive/`. **A close must leave nothing closed behind** — that is the whole of the rule, and it is stated about closed work because a close also *publishes*: the Icebox write-back admits pending work at exactly that moment, and one index line per surviving discovery is the price of the finding not being lost. So a close ordinarily shrinks this file and is not required to; what it may never do is leave a closed task's row, narrative or changelog copy sitting here. The earlier form of this rule was an absolute — *smaller, never bigger* — written before anything published at a close, and an absolute contradicted by the engine's own ceremony is a rule its next reader either obeys by dropping findings or ignores entirely.

**Hard rules:**
- **Soft cap 8,000 words, and a firmer one at 15,000.** Counted in **words**, because the unit that used to be counted could not see what grows: one entry is one line however long it is, so this ledger reached **27% of a 300-line cap while holding 10,118 words** — three times the prose that cap assumed. Lines stopped discriminating the moment an entry became an essay, which the business-first entry format above makes it. Words rather than estimated tokens because words are the unit this document already budgets prose in (the 25-word index line below) and because a word count is a fact its reader can check by hand, where an estimate invites arguing about the estimator instead of about the excess. The two numbers are anchored outside this engine rather than picked: of six comparable systems surveyed, **none guards the size of a shared file at all**, and the only one that proposes such a guard proposes it non-blocking — 8,000 words is about the 8k tokens BMAD sizes one unit of reading at, 15,000 about the 20k Kiro targets for a heavy operation, and the `AGENTS.md` convention's 32 KiB technical maximum sits between them while this ledger was already at 61.6 KiB.
  - **Over it, the engine says so and does not refuse.** The `Stop` guard reports once per session per threshold and lets the turn close — with one exception, stated because an invariant that silently does not hold is read as a broken mechanism rather than an unreachable one: what suppresses the repeat is the record of a *delivery*, so a note carried out beside a blocking report is never marked and returns at the next close, until a run carries it alone. It used to block, and blocking was wrong twice over: it fired while a requirement was being handed over, so the entry that paid was the one being written, and it re-fired on every turn close after that because it could not tell a re-delivered stop from a first one.
  - **Name the cause before acting: there are three causes, and only two of them have a remedy that removes anything.** Closed content duplicated here — move it to `archive/`. Or a `## Icebox` grown long, which is **pending** work and belongs in neither `archive/` nor a deletion — sweep it, promoting or retiring entries. Until the write-back began admitting at a close, the first was the only cause, which is why the remedy used to be stated alone; a reader handed that remedy alone against the second cause finds nothing to move and concludes the measurement was wrong.
  - **Or open task rows written as essays, and that one has no prune.** Measured on this engine's own ledger the day the budget was set: `## Ready` was **7,234 of 10,118 words — 71%**, against a rule that named the two causes above and neither of them it. Nothing may be moved and nothing may be deleted: an open row is pending work, and its detail has nowhere else to live, because `artifacts/T-XXX/` admits only active tasks (see the invariants). So the remedy is **not a prune** — it is the ledger-split decision parked in `## Backlog (candidate, not yet prioritized)`, a file-per-task layout that needs an index or a CLI first. Written down because a breach whose largest cause has no remedy would otherwise send its reader looking for closed content that is not there, and a report pointing at the wrong remedy is one its reader learns to ignore.
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

BACKLOG.md's `## Icebox` holds one line per parked discovery, and the discovery itself lives in a file of
its own:

```markdown
- IB-XXX (found in T-YYY) statement
```

The line is **regenerated from the body**, never written beside it — `.ai-flow/icebox/IB-XXX.md` holds the
essay, moved there verbatim by the write-back that admitted it (`### After ARCHIVE (single task)`, step 3),
and the line is derived from that essay in the same edit. Retired entries live at
`.ai-flow/archive/icebox/`, keeping the reason they died; a number is never reused, so the highest ever
issued is the highest across those two directories.

**The line has a budget: 25 words, counted over the whole line including its `- IB-XXX (found in T-YYY)`
prefix.** A number rather than a judgment, because the cost it governs is paid by every task that starts:
the scan in Understanding protocol > Investigation reads one such line per entry, so the budget times the
number of entries *is* what a task pays before it has investigated anything. Measured on this engine's own
ledger the day the budget was set — 27 entries at 2,483 words, and the four written under this layout ran
61 to 70 each — the cut lands almost entirely on the **remedy**, which the body already holds. A budget
that forced real content out would be the wrong budget; this one squeezes out a duplicate.

**The body grows only through a `## Sightings` log.** Under the essay, one dated line per encounter:

    YYYY-MM-DD — T-YYY — narrowed — what this encounter learned, in one line

and the verb comes from a **closed vocabulary of exactly five**, and no other:

- `confirmed` — the entry was met and still holds as written.
- `re-priced` — it holds, but its cost or its urgency is not what the body says.
- `narrowed` — part of it fell. What survives is smaller, and where nothing survives the entry is retired.
- `falsified` — it does not hold. The entry is retired, and the reason it died goes with it.
- `deferred` — it holds and this task is not taking it, naming the task that deferred it.

The vocabulary is closed so the log stays countable: an open list of verbs is a log that cannot be read by
anything but a human re-reading every line. `falsified` and `narrowed` are the reason the mechanism is worth
its cost — they let an entry die in the hands of a reader who already has the context loaded, which is the
cheapest reaping this engine has. The log is the **only** growing part of an entry: the essay is amended in
place and the index line is regenerated, never appended to.

**Two counts ride on the log: `closes survived` and `times deferred`, both derived at read time, stored
nowhere, and no field is defined for either.** The first is the number of task closes archived later than
the entry's own `found in T-YYY`, counted from `archive/T-XXX/`; the second is the number of `deferred`
lines in the entry's own log. Storing them was refused for the reason every stored count is refused here: a
stored count must be kept true by every writer that could change it, and a close interrupted halfway leaves
it lying with nothing to say so. Neither is read by any mechanism today — they exist so the operator's own
review arrives pre-ordered, and so the automation this epic deliberately did not build has a substrate.
`closes survived` in particular **cannot** be written by the log at all: an entry nobody met still survived
the close, so a sightings-driven counter would undercount exactly the entries that have been ignored
longest.

**Two deferrals is a signal, not an act**: where the log carries a second `deferred` line, the scan that
finds it says so, and the operator promotes the entry to a real task or retires it — the two doors below,
neither of them new. The engine performs neither on its own; there is no automatic promotion and no
automatic retirement, which is this epic's frozen non-goal and the reason this is stated as a report and
not as a rule with teeth. Something that keeps being relevant and keeps not being done is a task, and the
judgment about which of the two it has become is the operator's.

**An entry carries an identifier and a body file. It still carries no priority, and it is never activated
directly.** The identifier and the body are a deliberate reversal of the older rule, which forbade both:
what that rule was protecting is the *ceremony* — no priority, no investigation, no lifecycle — and the
protection is unchanged. What was given up is the austerity, bought so the index stops being an essay and
so an entry can be **cited by name**. Without an identifier a cross-reference can only say *"the entry
above"*, which every entry written under the old rule in fact did, and which breaks on the first reorder.
Icebox entries count as pending work for the Size Budget.

**Nothing reaches this section while a task is in flight — sightings included.** A discovery found during
a task is routed by the test in Understanding protocol > The routing test and staged in that task's own
papers; the write-back at that task's close is the **only** act that admits an entry here, and it admits
nothing the operator has not approved. A sighting is staged the same way and published by the same move's
amendments half, so it reaches an entry at the moment somebody is reading and never before: a second
producer writing at encounter time would have broken this rule, and would have broken it only from a linked
worktree, where nobody would have seen it. Taking a line out is not putting one in: the epic-close sweep
removes the lines of the entries it promotes or retires, and that is the one other hand this section ever
sees. Entries that predate
this layout are the exception that proves the rule: they arrived under a rule that admitted anything in one
line, and migrating them is its own task.

Promotion to a real T-XXX task happens at the epic-close sweep, or whenever the operator asks for one —
**two doors, and the write-back is not one of them.** What that move admits is an entry, never a task.
Nothing is lost by the omission: the operator is reading both halves while it runs, so a staged finding that
plainly deserves a task is promoted by them asking — the second door firing at that moment rather than a
third one. A promotion act written into the move would have to mint a T-ID, choose a priority and place a
row in `## Ready`: the second door's work rebuilt inside a move that already has the operator in the room.
Stated with its reason because the sentence this replaces claimed the write-back as a door and the move
never defined the act.

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
   move 6's, on every path. **How both are configured is documented in
   `~/.claude/ai-flow/docs/customization.md`, which the engine installs beside these protocols** — named
   as a path rather than as "the docs" because a reader who has to leave for a browser to find out what
   `worktree.baseRef` accepts is a reader this move sent away mid-ceremony. It creates
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

   **What the front is called** is settled here, and it is the last thing this move does because nothing
   later settles it cheaply. Of the fields a creation-time name touches, two are **chosen once and never
   rewritten** — the checkout's own path, and the front's name on its roster row — and those two carry the
   front's **subject**, with **no task identifier** in either. Its granularity is *inherited* from the
   front rather than chosen: what the front is about where it is one task, its epic or its grouping
   concept where it is broader. There is no discriminator to apply, which is the point — a classification
   made at every opening yields inconsistent names, and inconsistency reads worse at a glance than a
   boring uniform scheme. The **current task** goes on whatever **mutable label** the tool offers, and is
   rewritten there by the act that already advances the roster's task field (`### After ARCHIVE (single
   task)`, step 7) rather than by an act of its own. Where the tool **offers no** such label, nothing is
   added and the **roster is the glance** — said out loud, because a silence here reads as a step somebody
   forgot rather than as the floor it is. And a creation-time name that seeds several fields at once names
   the **path**, **never the branch**: a front's branch is **task-scoped** for the reason `## State Files`
   above already gives, and a durable name would be wrong on it from that front's second task onward.

6. **Seed the task's artifacts and prune the rest.** The new checkout arrives holding the papers of
   every open task, and the read-only rail cannot tell which task is its own from a pile: the checkout
   must hold only the artifacts of the task it owns, so prune every folder this front does not own — on
   **either** layout, because what put the pile there differs and the prune does not. Where the project
   **ignores** its data directory the pattern file carries `artifacts/` wholesale and the copy is what
   brings it; where the project **commits** it, git carried the whole directory in with the checkout and
   the pattern file selects nothing among the ignored paths, so there the prune is the only work left. A
   data directory neither ignored nor tracked is not a third layout but the documented precondition
   failing, which the mechanism below names rather than seeding a front with no project data. What is
   deleted there are copies — the coordinator keeps the originals. The engine ships the mechanism —
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

7. **Write the roster row and the task's sheet.** The row carries workstream, checkout, task, epic,
   the declared areas, **what created the checkout** — the tool identified in move 5, which is
   what the dismantling move reads — and the date. The sheet carries the branch that owns the task, the first
   position, the step, the autonomy level, and any acknowledgement from step 3. The position is the one
   named in `## State Files` and is not chosen here: this move writes a task that is open and in no
   phase, and the phase commands record every position after it. The row is the coordinator's; the
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

It runs at **every task close**, not once per front: moves 8 and 9 are its tail and run only when the
front has no next task, because a worktree holds a workstream — an epic with its serial chain inside —
and lives across the tasks in it.

With a single front open — the ordinary case — moves 2, 3 and 8 have nothing to do: the task was worked in
the coordinator, so its papers are already there, there is no branch to merge, and there is no second
checkout to take down. The ceremony then reduces to what closing has always been. Naming only the two that
need no second checkout reads as though the merge always has work, which turns the ordinary close into a
ritual with a dead move in it.

**Commits are free per step, in every checkout.** A step that passes its Verify command is committed
where it stands — the front's disposable branch and the coordinator's trunk alike — and nothing is asked
between steps. What the operator approves is the task's *work*, once, at move 1, and one approval is all
the ceremony has. The approval can sit there because the publishing move is where the work stops being
undoable by hand: until it is published a commit is local history, and a `reset` reaches it. The rule is
stated here, with the ceremony that enforces it, rather than in the manual — which carries the reason it
cannot live there, and carries it once.

**This ceremony follows the task's last commit immediately**, and never the next task's first step. A task
left closed-but-unarchived is one whose papers, roster row and trunk all disagree about whether it is done.

**The order is the protection.** Nothing merges before the coordinator holds the papers, and nothing is
recorded as done before it is in the trunk — so a ceremony interrupted at any move leaves either work
still to do or work already safe, never a lie in the record. Nothing enforces the order: the task's own
sheet is where an interrupted close is written down, and the roster is the queue.

**Which is why the papers survive every move that can stop the ceremony.** The sentence above designates
them as the carrier, and a carrier must outlive every stop it is designated for — so nothing destroys
them while a later move can still halt. That is what puts their deletion at the end and not in the
record: the ceremony has grown two stops past the merge, and the deletion's own reason for sitting late
was written when the merge was the last thing that could fail.

1. **The user validates the work.** Commits are free per step in every checkout (see above), so what is
   approved here is the task's work as a whole and never each commit: the front's branch where the task
   was worked in one, the task's own commits on the trunk where it was worked in the coordinator.
   Nothing merges without it and nothing is published without it. This is the ceremony's only approval,
   and it is the same approval either way — a second gated move would force a reader to work out which
   of the two was theirs, in the coordinator as much as in a front.

2. **The coordinator collects the task's papers.** `artifacts/T-XXX/` is written in the checkout where
   the task is worked and lives outside version control, so it does not travel with the branch and the
   merge carries none of it. The coordinator locates the front's checkout in the repository's own
   worktree listing, matched by the checkout path on that front's roster row — git is the authority, and
   that path is the one field on the row no chain of tasks changes: a front takes a new branch with every
   task in its chain, so a branch could never have keyed this row, while the path was never wrong about
   where the front lives. How the two sides are compared is the column's own rule, stated with the
   column (see `## State Files`). If the listing does not name that path, stop: the checkout is gone, so
   the papers may be gone with it, and no later move reconstructs them. The collection **replaces**
   whatever the coordinator holds for that task, and it is the one sanctioned exception to never
   overwriting a task's papers — the copy from the checkout where
   the task was worked is the authoritative one, while the coordinator's is a snapshot from the moment
   the front opened. The coordinator pulls; a linked worktree still never writes here.

3. **The merge lands in the coordinator**, one front at a time. The branch to merge is read from the
   checkout move 2 just located, by asking its own git what it is on — never from the roster, which
   carries no branch at all: a front's branch changes with every task in its chain, and the checkout is
   the only thing that knows the current one. If it cannot complete, the ceremony stops
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

6. **The trunk is published.** Until this move runs, work the ceremony has just finished landing sits on
   one machine and exists for nobody else — which is a third lie, distinct from the two the moves above
   prevent: not that the work is unfinished, and not that it is uninstalled, but that it is unreachable.
   It runs in the coordinator, on the trunk the merge landed in, and it **reports what it published** —
   the branch and how far it moved — because a push that says nothing is indistinguishable from one that
   never ran. Where there is no remote, or no remote trunk resolves, there is nothing to publish to: the
   move **says so and the ceremony continues**, which is the same answer the audit gives an unresolvable
   remote trunk rather than inventing a zero. If the push itself cannot complete — a diverged trunk, no
   permission — the ceremony **stops** here with the front's roster row still in place, the shape the
   move above already uses: the ledger is written by now, so the row is the only thing left saying work
   remains. It runs at **every task close**, a quick task's included, and carries none of the condition
   the two moves below it do.

7. **The task's papers are deleted.** `artifacts/T-XXX/` goes, in **every checkout that holds it** and
   not only the coordinator's. A task worked in a linked worktree leaves a copy there, and the tail below
   takes that checkout down only where the front's chain ends: a front continuing its chain keeps the
   copy, the next task's sheet claims the same branch, and the checkout is left with two claims and no
   way to say which task it is on. Locate the front's checkout the way move 2 does, which is the one
   place that rule is written. What makes this safe is that the record is already written: the archive
   checklist's summary step ran inside move 4, so what is deleted is a copy of what the archive holds.
   Which is why it happens **here and not earlier — never before the collection, and never at collection
   time**: what can still fail is not the merge alone but the merge, the distribution and the publish,
   and a front stopped at any of the three is a front still working that task, with the papers it needs
   gone and git unable to restore what it never tracked. It runs at **every task close** and carries
   none of the condition the two moves below it do — a quick task keeps no papers, so it has nothing
   here to delete, and the move **says so** rather than reading as a step somebody skipped.
   The two moves below it are conditional; this one never is.

8. **The front's working copy is dismantled by whatever created it** — the counterpart of the ownership
   condition in step 5 of the opening, and what created it is read from that front's **roster row**,
   where move 7 of the opening wrote it. Claude Code's `ExitWorktree` removes only what `EnterWorktree`
   created **in this session** and is a declared no-op for anything else, so it takes down a front opened
   in this session and nothing more: a front lives across the tasks in it, and one opened earlier — or by
   another front-end — is removed by that tool's own means, or by `git worktree remove`, which is also
   what a row naming no tool leaves the move with. What says the
   move happened is the repository's own answer, not the tool's: the checkout no longer appears in
   `git worktree list`. Never before move 2: removing the checkout destroys the task's papers before the
   coordinator holds them, and git cannot restore what it never tracked. Runs only when the front has no
   next task.

9. **The front's roster row is removed** — the coordinator's last write, and the roster's own proof that
   the front is closed. Not while `git worktree list` still names that front's checkout: the row is then
   the only thing left saying work remains. Runs only when the front has no next task.

## Directory Hygiene

**CRITICAL:** `.ai-flow/` must stay clean. Run the appropriate checklist after each lifecycle transition.

### After ARCHIVE (single task)

This checklist is what move 4 of `## Closing a Workstream` runs, and it runs in the coordinator:
the ledger has one writer, and every step below is that writer at work. Nothing here reaches into
another checkout — the one act that did is now move 7 of the ceremony, which is the only move of the
close that touches a checkout the coordinator does not own.

1. **Steering update**: did the task teach or modify a domain rule? -> edit the rule in the steering file's **body** AND regenerate its `## Nano` line **in the same edit** — an edit that touches only one of the two is incomplete. No new rule learned -> skip.
2. **product.md write-back**: copy every rule from understand.md's `New business rules minted` into product.md's Business Rules (with T-XXX provenance); update the Glossary if the task sharpened a term. A business rule that stays only in the archived artifact will be re-asked or re-assumed. None minted -> skip.
3. **Icebox write-back**: publish what this task found and did not own, and amend what it touched.
   Two halves, and **both are shown to the operator — nothing is written until they approve**. That is
   the whole repair: the shared list grew unowned because entries reached it while nobody was reading.
   **Additions** are the findings staged under their own `##` headings in
   `artifacts/T-XXX/discoveries.md`; the `## Discarded` section is not read here, and a discard's reason
   dies with the papers, which is the trade the routing test already states out loud. The `## Sightings`
   section is not read here either, and for a different reason: it is the other half's input, not a
   finding, and read at this level it would be republished as pending work the task never found.
   **Amendments** are the entries this task touched: each sighting staged under `## Sightings` is published
   by appending it to that entry's own log, the index line is then **regenerated from the body within its
   budget** — rewritten, never appended to — and an entry this task fixed, or whose sighting `falsified` it
   or `narrowed` it to nothing, is **retired**, with the reason it died written into its
   body. Retiring is the cheapest reaping there is — the only reader who can kill an entry for nothing is
   the one who already has the context loaded. This move is the **only** act that admits an entry to
   `## Icebox`; nothing staged reaches it on its own, and nothing reaches it while work is in flight. The
   epic-close sweep writes here too, but only to take out what it promotes or retires.

   An admitted addition becomes `icebox/IB-XXX.md`. The body is the essay the task already wrote,
   **moved verbatim, not authored again** — an essay re-authored at the close is re-authored by whoever
   has the least context left of anyone who will ever hold it. One line is then **regenerated from that
   body in the same edit** and written to the ledger's `## Icebox`:
   `- IB-XXX (found in T-YYY) statement`. One edit and not two, for the reason the steering `## Nano`
   blocks give (step 1 above): two levels inside one diff is the only defence against an index drifting
   from the thing it indexes.

   **The identifier is minted here, in the coordinator**, where the ledger already has a single writer —
   so the race the opening ceremony spends a whole move avoiding cannot occur here, and no front ever
   issues a number. The highest ever issued is the highest in `icebox/` and `archive/icebox/` taken
   together, which is what makes the other half safe: **retirement moves the body to `archive/icebox/`**
   and the **number is never reused**, so a citation written a year ago still names one thing. **Where
   either directory is absent this move creates it** — the installer's data skeleton runs on a fresh
   install alone, so every project that adopted the engine earlier arrives at its first write-back with
   nothing there. **The same for the ledger's `## Icebox` heading**, which the shipped BACKLOG.md does not
   carry: it is created below `## Epics`, after any Execution Order block. A fresh install is the mirror of
   the case above — it arrives with both directories and no section to write into — and a heading two
   readers place in two positions is a section neither of them can cite.

   Nothing staged and nothing touched -> skip, and say which of the two halves was empty. It is not a
   prompt offering two empty lists.

   **Why it sits here.** It publishes **from** the task's papers, and move 7 of the closing ceremony
   deletes them: this checklist runs inside move 4, so the papers are still there to read from, and no
   step below it may be allowed to outlive them. That is also why the position is not a preference — any
   position that satisfies it renumbers the steps beneath, and the citations move with them.
4. Generate `archive/T-XXX/summary.md` (see Archive Summary template)
5. Remove task from BACKLOG.md (move from Done to nowhere — it's in the archive now)
6. Write the session-close entry to `archive/CHANGELOG.md` (once — this is its permanent home) **and** copy it to the BACKLOG.md top. If BACKLOG.md then holds more than 3, **delete** the oldest from BACKLOG.md — do NOT re-append it to `archive/CHANGELOG.md`, it has been there since its own close (see Size Budget)
7. Leave the workstream row to move 9 of `## Closing a Workstream`, its sole owner: the row is removed
   only when the front has no next task, and a front continuing its chain keeps its row with the task
   field advanced (coordinator only — other open fronts keep theirs). **The same act rewrites the front's
   mutable label** where its tool offers one, to the task the row now names — this is the only statement
   of the continuing case, so a label left to an act of its own is a label nobody would ever rewrite, and
   the front would go on announcing a task that closed here. Where the tool offers none there is nothing
   to rewrite and the row is the whole of it (see move 5 of `## Opening a Workstream`). The task's
   `state.md` is still here: it goes with `artifacts/T-XXX/` at move 7 of the ceremony, two moves after
   this checklist has finished.

### Business-Miss Rule

When a shipped task turns out to violate business intent (the code was right; the business was assumed or wrong), treat it as feedback, not just a bug: alongside the fix task, write the missing rule to product.md — or the miss *category* to the relevant protocol. A business miss that only produces a bugfix will repeat.

### Steering Nano Blocks

Every code-domain steering file opens with a `## Nano` block: one line per rule/section, always **derived from the body** (two levels, one file — same-diff is the main defense against drift). `pencil-design.md` (design sessions) is exempt. Readers hit the nano first and read the full body only when the task touches that domain (see Understanding protocol > Steering Files). The nano is regenerated whenever the body changes — step 1 of the archive checklist enforces it.

### After Epic completion

1. **Icebox confirmation sweep**: go through the epic's `## Icebox` entries WITH the user — each is
   promoted to a real T-XXX task (now it gets a priority and a lifecycle) or retired, its body moved to
   `archive/icebox/` with the reason it died. This is a **sweep and no longer the route out**: every entry
   here was already put in front of the operator by the write-back that admitted it, so what this move
   catches is what has since gone stale, not what nobody has read. It was the only door once, and that is
   precisely why the list it governs reached 23 entries outliving five closed epics — a door reachable only
   by a ceremony most entries never live to see is a door that is shut.
2. Generate `archive/E-XXX-[slug].md` (see Epic archive template) — surviving Icebox promotions go under "What Was NOT Done"
3. **Verify** that `artifacts/` retains no folder of a task of this epic — deleting is move 7 of
   `## Closing a Workstream`, which runs after the publish and knows what it archived. If a folder is
   still there, name it and stop: it belongs to a task closed without its checklist, to a front that is
   still open, or to a **close halted after the record** — the deletion is the last thing the ceremony
   does, so a close stopped at the distribution or the publish leaves exactly this folder behind, and
   a sweep cannot tell the three apart. Naming all three is the whole of the move: a diagnosis offering
   two sends the operator to re-run a checklist that already ran.
4. Remove all epic tasks from BACKLOG.md Done section
5. Move the epic row to `archive/EPICS.md` + its Execution Order block to `archive/EXECUTION-ORDERS.md` (Size Budget)
6. **Verify** the roster holds no row for a front of this epic — move 9 of `## Closing a Workstream` is
   the only remover, and by now it has run for each of them. A row still there names a front that is
   still open: name it and stop, rather than removing it here (rows of fronts outside the epic stay).

### Invariants (always true)

- `artifacts/` contains **only** `T-XXX/` folders for **active or in-progress** tasks — never completed
  ones, and this holds in **every checkout**, not only the coordinator's. A copy left behind in a front
  is what puts two claims on one branch (see State Files)
- No root-level files in `artifacts/` (no templates, no loose files)
- No empty directories anywhere in `.ai-flow/`
- BACKLOG.md Done section is **transient** — tasks stay there only until archived, not permanently
- BACKLOG.md stays under 8,000 words and contains only pending work (see Size Budget)
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
├── icebox/                 # One parked discovery per file
│   └── IB-XXX.md           # The body its `## Icebox` line is regenerated from
└── archive/                # Completed work
    ├── CHANGELOG.md        # Session-close entries (newest first)
    ├── EPICS.md            # Closed epics index (rows moved from BACKLOG.md)
    ├── EXECUTION-ORDERS.md # Execution Order blocks of closed epics
    ├── T-XXX/summary.md
    ├── E-XXX-slug.md
    └── icebox/IB-XXX.md    # Retired entries — the number is never reused
```

**The phase protocols are not in this tree.** They live centrally at `~/.claude/ai-flow/protocols/`,
installed once and shared by every project: a project holds only its **data**, and the engine is versioned
in the ai-flow repository. A project directory that still contains them is a stale install, not a valid
structure — and a drift-check hook nags whenever the installed engine and the trunk diverge.
