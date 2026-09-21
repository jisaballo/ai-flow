# Context Files Protocol

**What this owns**: the mechanism governing every file that gives a task its context — what such a file
is, the shape it takes, how it is read, how it is written, and how it is kept. Every phase routes here
when it loads one and states only its own use of it: that Understand drafts the Business Frame against
`product.md` is a rule of Understand, and lives there.

## The classes

| Class | What it is | What it answers |
|---|---|---|
| `steering/<key>.md` | What a task must respect and the code cannot show: rules, patterns and pitfalls, in three layers — the workspace one every task loads, an app's own, a domain's own | What this area knows |
| `product.md` | The business model in the business's language: the product, its users and roles, its applications, its core flows, its terms, and its business rules grouped by key | Who the roles are, what a term means, and which rule governs |
| `decisions-global.md` | Decisions that cross tasks, each with the context and the alternatives that keep it from being re-argued | What was already settled, and why |

One vocabulary names an area across every class: the keys are the `steering:` map's keys, `workspace`
included, so a task that touches one area loads that area's rules from each class and no other's.
`workspace` is a **reserved key** — never an area — on the same terms as `default:` inside
`review_profile:`. A project that declares no workspace entry is told so in one line by every run that
resolves context, and the line disappears the day the entry exists.

The file itself carries a title and its content, and **no header describing itself**: its identity is the
row above, and a description kept in the data is a second copy of it.

## Visibility

Nothing of this mechanism is written into any `CLAUDE.md`. That file carries the harness — commands,
skills, how the engine is mounted — so that another harness needs another adapter and the same engine;
what a project knows about itself lives in context files. The phase protocols route here, and a pointer in
a file loaded on every turn would be paid on every turn and fire never.

## Three cuts

| Cut | What it is | Bounded by |
|---|---|---|
| Nano | The `## Nano` block: one line per body section, in body order, opening with the section's exact title in bold, then one sentence holding what every task reaching this file needs | The length of a line |
| Section | One `##` block, addressed by the title its nano line carries | The length of a section |
| Body | The whole file, the source the nano is regenerated from | How many sections a file holds |

**Sections are topics.** Everything known about one topic lives under one heading, so that reading one
part brings its neighbours. A file may hold one section of file-wide scope. A section title carries no
task ID and, in a domain file, no app name — a title that needs an app's name belongs in that app's file,
which is the derived test for a rule written into the wrong layer and it costs nothing.

**The nano is an index of pointers.** Its line is what decides whether a section is opened, so the title
comes first, being both the trigger and the address. What goes in the sentence is settled by looking, not
by weighing importance: what every task reaching this file needs is in the sentence, what only some tasks
reach is in the section.

**The marker is `##` for every class.** One command then reads every file, and a class needing groups
expresses them in the title, as `product.md` does with `Rules: <key> — <topic>`.

**The thresholds are numbers, and numbers live in one place**: the check named under Keeping, which prints
them. This protocol names the measures — nano line length, section length, sections per file — and never
their values. A document that broke its own one-number-one-home rule in its first sentence would be the
one nobody keeps.

## Reading

1. **Resolve the affected files.** An entry of the `steering:` map is affected when it is the reserved
   `workspace` key; when its key names a directory the task touches — `apps/<key>`, `libs/<key>`, or a
   directory under `source_dirs` carrying the key's name; or when the scoping pass names it. What the task
   touches is what the phase already holds: the candidate areas of the scoping pass in Understand, the
   step's `Files` in Execute, the changed files in Verify. Several keys may name one file, and it is read
   once. The classes with a fixed part — `product.md`, `decisions-global.md` — are always in the set.
   **What is loaded is the map's value, whatever path it names**: `.ai-flow/steering/<key>.md` is the
   convention and not the only place an entry may point, and resolving to the directory instead of to the
   value would silently drop every entry naming something else, with no diagnostic, since a path never
   looked up cannot be reported missing.

   **A value is a path resolved from the repository root, and from no other base.** This sentence is the
   base's one home; every other mention of the convention cites it rather than saying it again, because a
   base stated twice is a base that can be corrected in one place and left standing in the other. The
   convention `.ai-flow/steering/<key>.md` describes **where a file of the class conventionally sits** and
   never the form the value takes — written as the value, the same string reads as a path from `.ai-flow/`
   and the two readings never meet: 15 of 15 values in one measured project resolved to nothing, and its
   steering had plausibly never reached a review. There is deliberately **no second base and no
   fallback**: one string with two meanings is the wrong-meaning hazard this engine refuses elsewhere, and
   a value written the other way is a value the check names rather than one the reader guesses at.
   **What an entry points at is delivered, not shaped**: the map answers which document a task receives,
   so a value may name a `CLAUDE.md`, a card or a skill, and pointing at one says nothing about what class
   of file it is or what rules its shape must obey.
2. **Check before cutting.** A file that passes the check is read by cuts. A file that fails has no cuts
   to trust: it is read whole, the phase says so with its word count, and the repair described under
   Keeping opens. The stated cost is the pressure; nothing else nags.
3. **Read the nano, then the sections that intersect the task.** One command, the title as its variable;
   it cuts on exact string equality and ends on its own at the next heading:

   ```bash
   awk -v t="Nano"        '/^## /{f=($0=="## "t)} f' .ai-flow/steering/payments.md   # the nano
   awk -v t="Idempotency" '/^## /{f=($0=="## "t)} f' .ai-flow/steering/payments.md   # one section
   cat .ai-flow/steering/payments.md                                                 # the body, as a choice
   ```

   A section is loaded when its nano line intersects the task's ground — a judgment over the line, of the
   kind the Icebox scan makes over an entry's statement, and like it auditable only through its record. A
   section already loaded in the session is not loaded again.
4. **Write the aggregate line — the reading step's completion criterion.** Every file with its nano line
   count, every section loaded by title; a file whose nano matched nothing still appears with its count,
   so a skipped read and an empty match never read alike. Understand writes it in `understand.md`;
   Execute writes it in the task's sheet at each step that read; Conform writes it in its own manifest,
   `artifacts/T-XXX/conformance-baseline/manifest.md`.

   ```
   Context: .ai-flow/steering/workspace.md nano (9); sections: Import boundaries | .ai-flow/steering/payments.md nano (12); sections: Idempotency, Refund flow | product.md fixed + Rules: checkout (3) | decisions-global.md nano (7); sections: none
   ```
5. **Verify receives the list.** The resolved files travel to the review as one list: the architecture
   auditor reads the workspace file for boundaries and import rules, the security auditor the steering of
   the affected area. Where the list holds no workspace file the run says so in one line — a legitimate
   zero is a written choice.

## Writing

**Who writes, and when.** The archive checklist — its steering move, its `product.md` move, and its
global-decision move — the Business-Miss Rule, and the operator by hand. **A task in flight writes no
context file**: a lesson learned mid-task is noted in the task's sheet and placed at the close, where the
operator approves what is written.

**Where a lesson goes.** Asked in this order; the first *yes* places it:

1. Does every task in the repository need it? → the workspace file.
2. Does every consumer of the domain need it? → the domain file, in its topic's section.
3. Does only this app need it? → the app file.
4. Is it this app's twist on a shared topic? → the app file, as a pointer to the domain's section with the
   twist in one sentence.
5. Is it about the business — a rule, a role, a term — rather than the code? → `product.md`, under the key
   it belongs to.

Before any of them: **a rule the code, a test or a config already states is not a context file's.** It is
a cache of the environment, and the environment holds it without going stale.

**How it lands.** A lesson merges into the section of its topic; a new section is a new topic, never a new
task. Provenance sits at the end of the rule's line as `(T-XXX)`, where it lets a reader open the archive
holding the occasion — never in the title, which is the topic's address. **The nano line of the edited
section is rewritten from that section in the same edit**: one diff is the whole defence against an index
drifting from what it indexes. A rule that retires an older one takes it out in the same edit.

A decision is the one class written as an essay: its alternatives and their reasons are what keep it from
being reopened, so the section length does not apply to a decision's body. The nano line's length applies
in full, since that line is what every task reads.

**The section count bounds topics, and a record is not a topic.** The count is what catches a file that
has become a drawer, and it can only ask that of sections a writer chooses to open. A section that is a
**record** of an enumeration the mechanism itself grows — one per decision, one per group of business
rules — rises with use and by nothing the writer did wrong, and no repair stated here can lower it: a
ceiling over records is a ceiling nothing can meet, and a check nobody can satisfy is the alarm that
teaches everyone to route around it. So the count skips the record sections and bounds the rest. Two
classes have them: `product.md`, whose `Rules:` sections are its growing part while its fixed part is
counted, and `decisions-global.md`, which is records end to end and to which the rule therefore does not
apply at all. That exemption, and the section length's above it, answer `n/a` rather than a passing
verdict — a verdict of `ok` would claim a rule was applied and held when it was never asked, and silence
would hide the exemption from a reader as surely as a false `ok` would. Both classes are resolved from
where the file lives, never from its basename: a file that borrows the reserved name from inside the
steering directory is a steering file and keeps neither exemption.

## Keeping

**The check.** `~/.claude/ai-flow/scripts/context-check.sh [file …]` reads only `.ai-flow/`; with no argument it takes the
steering directory's own files plus `product.md` and `decisions-global.md`, once each — where the files
live, never what a delivery map points at, so a document borrowed from outside is never measured with
ceilings its own home refuses and a steering file nobody declared is measured all the same. It returns a
verdict per file and per rule — nano titles equal to body headings and in the same order, a nano present, each
nano line and each section within its length, the file within its section count, no app key in a domain
file's titles, the `##` marker only — and one verdict per entry of the delivery map: every value resolves
to a file that exists, against the base `## Reading` step 1 states and against no other. That last one is
a verdict about the **declaration** and never about the document, so an entry pointing outside `.ai-flow/`
resolves, passes and is measured by nothing, while one that resolves to nothing is named together with the
file it probably meant. `--report` prints every verdict with the thresholds applied.
It runs by hand, from CI, and as the `Verify` of the archive moves that write a context
file.

**The structure guard.** Changing how this mechanism works is not something another task does in passing.
*Structure* is this protocol, the classes table, the check, and in any context file the `##` lines, the
nano block and the order of sections. *Content* is a rule added or corrected inside a section, and it
passes. A structural change is layer-1 visible: one line in chat naming the file and the change, and the
operator's permission, on the terms the Plan protocol gives irreversible operations. **The permission is
granted per task, not per change** — the key below is written once, at the approval, and stands until the
task ends. Naming it here because the rule and its rail must not read differently: a per-change key would
need a writer on every change, and a step that writes its own permission is not a gate. What the operator
approves is therefore a task that will restructure, and the layer-1 line is owed for each change within
it whether or not the rail asks again. The guard opens on
two keys, both read from the task's sheet — the **sanctioned moment**, the task inside its archive
checklist, or the **declared decision**, the line `structure: context`, written when the plan's Decision
Register entry is approved or after the operator's go-ahead at Auto. A harness adapter denies a structural
write holding neither key and names both. The sanctioned moment is **narrowed to the move that needs it**: the
position is written immediately before each of the close's three context writes and cleared immediately
after. A close halted anywhere else therefore strands nothing, and one halted inside a move strands that
move's position alone — the direction is **closed**, and a key held across the whole ceremony is what
that narrowing buys off.
**The rule is this paragraph; the adapter is its rail** — and the rail sees only a checkout whose branch
a per-task sheet claims, so where none does the rule stands alone with nothing performing it.

**Repair moves forward with use.** A file that fails the check is repaired by the first task that needs
it, and named by nothing until then. The phase reads it whole and says so with the cost. Understand,
having read it, proposes the **topic map** — which existing sections and rules go under which titles — as
one question of its rounds, its own grouping as the recommended option, and the approved map is recorded
in `understand.md`. The archive's steering move executes it: paragraphs move under their headings, task
IDs leave titles for the rules' lines, the nano is written from the new sections, and the check is that
move's `Verify`. A file first met in Execute has the fact noted in the sheet and its question goes to the
close, where the operator's approval is already the first move. The decision is made where context is
highest and executed where the file is already being written. **There is no migration session and no
autonomous fix.**

## Several projects

A monorepo is the general case and a single project its degenerate case, and not one rule above
distinguishes them — the map does. In a **monorepo** the map holds keys of both kinds, and the directories
resolve them: an `apps/<key>` or `libs/<key>` the task touches makes its entry affected without anyone
judging it. In a **single project** the app layer does not exist, the app being the workspace, and the map
holds `workspace` plus domain keys with no directory of their own, which the scoping pass alone resolves.
