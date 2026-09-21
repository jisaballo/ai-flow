# Context files — the mechanism

This document defines the mechanism that governs every file giving a task its context. In the engine the
mechanism is `protocols/context.md`, and the phase protocols route to it whenever they load a context
file. Each class of file has its own document beside this one, stating only what is specific to the class:
[steering](steering.md), [product.md](product.md), [decisions-global.md](decisions-global.md).

## Nano

- **What a context file is** — a file under `.ai-flow/` any task may need and no task owns; its identity
  is stated once, in its class document.
- **Three cuts** — nano, section, body; sections are topics, the nano is one line per section, the body is
  the source.
- **Reading** — the affected files are derived from what the task touches, read by cuts with one `awk`
  command, and the phase writes one line naming every file and section it loaded.
- **Writing** — ordered questions place a lesson, it merges into its topic's section, provenance rides the
  rule's line, the nano is regenerated in the same edit.
- **Keeping** — a check script measures, a structure guard with two keys makes structural change
  deliberate, and a file in an older shape is repaired the first time a task uses it.
- **Several projects** — a monorepo is the general case and a single project its degenerate case; the map
  in `project.yml` distinguishes them, the mechanism does not.

## What a context file is

A **context file** is a file under `.ai-flow/` that any task may need and no task owns. Three things are
said about each one, each in one place:

| Question | Where it is answered | Times |
|---|---|---|
| What it is and what it answers | Its class document, and the classes table of the protocol | Once |
| How it is shaped, read, written and kept | This mechanism | Once |
| What a consumer does with it | The consumer's protocol — that Understand drafts the Business Frame against `product.md` is a rule of Understand | Once per consumer |

The file itself carries a title and its content, and no header describing itself: its identity lives in
its class document, and a description kept in the data is a second copy of it.

The harness file, `CLAUDE.md`, carries the harness — commands, skills, how the engine is mounted. What a
project knows about itself lives in context files, so that another harness needs another adapter and the
same engine. Nothing of this mechanism is written into any `CLAUDE.md`: the phase protocols route to it, and
a pointer in a file loaded on every turn would be paid on every turn and fire never.

## Three cuts

| Cut | What it is | Bounded by |
|---|---|---|
| Nano | The `## Nano` block: one line per body section, in body order, opening with the section's exact title in bold, then one sentence holding what every task reaching this file needs | Line length |
| Section | One `##` block, addressed by the title its nano line carries | Section length |
| Body | The whole file, the source the nano is regenerated from | Sections per file |

**Sections are topics.** Everything known about one topic lives under one heading, so that reading one
part brings its neighbours. A file may hold one section of file-wide scope. A section title carries no
task ID and, in a domain file, no app name: a title that needs an app's name belongs in that app's file.

**The nano is an index of pointers.** Its line is what decides whether a section is reached, so it is
written as a pointer: the title first, because it is the trigger and the address; one sentence; and the
test for what goes in the sentence is answered by looking, not by weighing importance — what every task
reaching this file needs is in the sentence, what only some tasks reach is in the section.

**The marker is `##` for every class.** One command then reads every file; a class that needs grouping
expresses it in the title, as `product.md` does with `Rules: <key> — <topic>`.

**The thresholds are numbers, and numbers live in one place**: the check script, which prints them. This
mechanism names the measures — nano line length, section length, sections per file — and never the
values.

## Reading

1. **Resolve the affected files.** An entry of the `steering:` map is affected when it is the reserved
   `workspace` key; when its key names a directory the task touches — `apps/<key>`, `libs/<key>`, or a
   directory under `source_dirs` carrying the key's name; or when the scoping pass names it. What the task
   touches is what each phase already holds: the candidate areas of the scoping pass in Understand, the
   step's `Files` in Execute, `changedFiles` in Verify. Several keys may name one file; it is read once.
   The classes with a fixed part — `product.md`, `decisions-global.md` — are always in the set.
2. **Check before cutting.** A file that passes the check is read by cuts. A file that fails has no cuts to
   trust: it is read whole, the phase states so with its word count, and the repair described under Keeping
   opens. The stated cost is the pressure; nothing else nags.
3. **Read the nano, then the sections that intersect.** One command, the title as its variable; it cuts on
   exact string equality and ends on its own at the next heading:

   ```bash
   awk -v t="Nano"         '/^## /{f=($0=="## "t)} f' .ai-flow/steering/payments.md   # the nano
   awk -v t="Idempotency"  '/^## /{f=($0=="## "t)} f' .ai-flow/steering/payments.md   # one section
   cat .ai-flow/steering/payments.md                                                  # the body, as a choice
   ```

   A section is loaded when its nano line intersects the task's ground — a judgment over the line, of the
   kind the Icebox scan makes over an entry's statement, and like it auditable only through its record. A
   section already loaded in the session is not loaded again.
4. **Write the aggregate line — the step's completion criterion.** Every file with its nano line count,
   every section loaded by title; a file whose nano matched nothing still appears with its count, so a
   skipped read and an empty match never read alike. Understand writes it in `understand.md`; Execute in the
   task's sheet at each step that read.

   ```
   Context: .ai-flow/steering/workspace.md nano (9); sections: Import boundaries | .ai-flow/steering/payments.md nano (12); sections: Idempotency, Refund flow | product.md fixed + Rules: checkout (3) | decisions-global.md nano (7); sections: none
   ```
5. **Verify receives the list.** The resolved files travel to the review workflow as one list. The
   architecture auditor reads the workspace file for boundaries and import rules; the security auditor
   reads the steering of the affected area. Where the list holds no workspace file, the run says so in one
   line: a legitimate zero is a written choice.

## Writing

**Who writes, and when.** The archive checklist — step 1 for steering, step 2 for `product.md`, the
global decision for `decisions-global.md` — the Business-Miss Rule, and the operator by hand. A task in
flight writes no context file: a lesson learned mid-task is noted in the task's sheet and placed at the
close, where the operator approves what is written.

**Where a lesson goes.** Asked in this order; the first *yes* places it:

1. Does every task in the repository need it? → the workspace steering file.
2. Does every consumer of the domain need it? → the domain file, in its topic's section.
3. Does only this app need it? → the app file.
4. Is it this app's twist on a shared topic? → the app file, as a pointer to the domain section with the
   twist in one sentence.
5. Is it about the business — a rule, a role, a term — rather than the code? → `product.md`, under the key
   it belongs to.

Before any of them: a rule the code, a test or a config already states is not a context file's. It is a
cache of the environment, and the environment holds it without going stale.

**How it lands.** A lesson merges into the section of its topic; a new section is a new topic, never a new
task. Provenance sits at the end of the rule's line as `(T-XXX)`, where it lets a reader open the archive
that holds the occasion — never in the title, which is the topic's address. The nano line of the edited
section is rewritten from the section in the same edit: one diff is the whole defence against an index
drifting from what it indexes. A rule that retires an older one takes it out in the same edit.

**The section count bounds topics, and a record is not a topic.** The count catches a file that has become
a drawer, and it can only ask that of sections a writer chooses to open. A section that is a **record** of
an enumeration the mechanism itself grows — one per decision, one per group of business rules — rises with
use and by nothing the writer did wrong, and no repair stated here can lower it: a ceiling over records is
a ceiling nothing can meet. So the count skips the record sections and bounds the rest. `product.md`'s
`Rules:` sections are its growing part and are skipped while its fixed part is counted;
`decisions-global.md` is records end to end, so the rule does not apply to it at all — and, on the same
terms as the section length, it answers `n/a` rather than a passing verdict: a verdict of `ok` would claim
a rule was applied and held when it was never asked, and silence would hide the exemption from a reader as
surely as a false `ok` would. Both classes are resolved from where the file lives, never from its
basename: a file that borrows the reserved name from inside the steering directory is a steering file and
keeps neither exemption.

## Keeping

**The check.** `scripts/context-check.sh [file …]` reads only `.ai-flow/`; with no argument it takes the
steering directory's own files plus `product.md` and `decisions-global.md`, once each — where the files
live, never what a delivery map points at, so a document borrowed from outside is never measured with
ceilings its own home refuses and a steering file nobody declared is measured all the same. A verdict per
file and per rule: nano titles equal to body headings, in order; a nano present; each nano line within its length;
each section within its length; the file within its section count; no app key in a domain file's titles;
the `##` marker only. And one verdict per entry of the delivery map: every value resolves to a file that
exists, against the base the mechanism's own `## Reading` step 1 states and against no other — a verdict
about the declaration and never about the document, so an entry pointing outside `.ai-flow/` resolves,
passes and is measured by nothing. `--report` prints every file's verdicts with the thresholds applied. It
runs by hand, from CI, and as the `Verify` of the archive steps that write a context file.

**The structure guard.** Changing how the mechanism works is not something another task does in passing.
*Structure* is the protocol, the classes table, the check script, and in any context file the `##` lines,
the nano block and the order of sections. *Content* is a rule added or corrected inside a section, and it
passes. A structural change is layer-1 visible: one line in chat naming the file and the change, and the
operator's permission, on the terms the Plan protocol gives irreversible operations. The guard opens on two
keys, both read from the task's sheet: the **sanctioned moment**, the task inside its archive checklist; or
the **declared decision**, the line `structure: context`, written when the plan's Decision Register entry is
approved, or after the operator's go-ahead at Auto. A harness adapter — in Claude Code a `PreToolUse` hook
on Edit and Write — denies a structural write holding neither key and names both. The rule is the
paragraph; the hook is its rail.

**Repair moves forward with use.** A file that fails the check is repaired by the first task that needs
it, and named by nothing until then. The phase reads it whole and says so with the cost. Understand, having
read it, proposes the **topic map** — which existing sections and rules go under which titles — as one
question of its rounds, its own grouping as the recommended option; the approved map is recorded in
`understand.md`. Archive step 1 executes it: paragraphs move under their headings, task IDs leave titles for
the rules' lines, the nano is written from the new sections, and the check is the step's `Verify`. A file
first met in Execute notes the fact in the sheet, and its question goes to the close, where the operator's
approval is already the first move. The decision is made where context is highest and executed where the
file is already being written. There is no migration session and no autonomous fix.

## Several projects

A monorepo is the general case. Steering has three layers — workspace, app, domain — and a task loads the
ones its resolution reaches; `product.md`'s rule groups use the same keys, so one vocabulary names an area
across every class. A **single project** is the case with one app: workspace is the app, the map's keys are
domains with no directory of their own, and the scoping pass alone resolves them. Not one rule above
distinguishes the two cases; the map does. The layers are stated in the [steering document](steering.md).
