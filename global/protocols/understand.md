# Understanding Phase Protocol

**CRITICAL:** This phase ensures polished code by gathering all necessary context BEFORE planning.

**Read-only rail (hook, not Plan Mode):** While the task's state sheet (`artifacts/T-XXX/state.md`) marks the current phase as UNDERSTAND, a PreToolUse hook (`~/.claude/hooks/understand-write-guard.py`) blocks Edit/Write to any repo file outside `.ai-flow/`. If the hook is not installed, honor the rail by discipline — same rule, unenforced. Do NOT use Plan Mode for this phase. Investigation is unrestricted — reads, greps, Explore agents, and running tests/commands to reproduce a failure are all allowed. Writing understand.md needs no special step (it lives under `.ai-flow/`); throwaway repro scripts go to the scratchpad directory, not the repo.

**Which task**: the phase runs on the task this checkout owns. Resolve it by the ladder in the backlog
protocol (`## State Files` → `### Resolving the task`) — stated there and only there — and stop rather
than choose if it ends without one. Then test the phase precondition (same document, `### The phase precondition`) — stated there
and only there too, so this document names no accepted position and no leg of its own. A manual
run performs the check; the command is a convenience over this procedure, never its only carrier.

## Product Context

Read `.ai-flow/product.md` at the start of EVERY Understanding phase — not just for new epics. It is the living domain model (app map, glossary, business rules): the oracle the Business Frame below is drafted against and checked for contradictions.

## Business Frame (before any investigation or question)

**The agent owns the code; the user owns the business. Never assume the business — extract it.** Before investigating code, draft the Business Frame from the task description + product.md:

- **Role affected**: who experiences this change (one of the project's user roles — see product.md)
- **Business rule served**: the real-world rule or job this change enforces or enables
- **Today / after**: what the product does today vs. what it will do — in product language
- **What is lost**: any capability a role gives up (there almost always is one — name it and ask)
- **Out of scope**: what this task deliberately does not change
- **Observable success**: how the user will SEE it working (concrete, user-visible scenarios)

Holes in the frame become the FIRST round of questions — before any technical round. If the frame cannot be drafted at all, the task description was born technical: reconstruct the business intent and confirm it with the user before proceeding.

## Epic-Scoped Understanding

From an epic's **second task onward**, do NOT relaunch broad Explore agents. Read the epic's Scope Contract (its Execution Order block in BACKLOG.md) plus the task's understand.md if it was created upfront at epic planning; investigation is limited to the task's own files. Anything noticed outside them goes through Discovery Triage — it does NOT widen this task's investigation.

**The Icebox scan is exempt from the second of the two restrictions above** — the limit to the task's own
files — and still runs in full. It buys no licence over the first: the cap on broad Explore agents stands
untouched, and the scan launches none. Reading one summary line per entry sizes the investigation rather
than widening it, and the entries likeliest to be dead are the oldest ones, which no task's own files would
ever surface. The exemption is written here rather than left to
inference because second-and-later tasks are the majority: a scan that quietly stopped running on them
would die exactly where this epic's own evidence says it is needed.

From a **linked worktree** the Scope Contract is not local: the ledger stays with the coordinator, so locate the main checkout with git's own worktree listing (`git worktree list` — the main worktree is its first entry, the same anchor the guardrail hooks resolve) and read its `BACKLOG.md` read-only — never copy it in, and never write there. A copy would go stale against a contract the coordinator can amend; the read does not. If the main checkout or its `BACKLOG.md` cannot be reached, say so and stop: an unreadable contract is a blocked Understand, never an absent constraint.

Exception: if the task's own files contradict an assumption in the Scope Contract, flag it to the user — re-scoping investigation is then allowed. A wrong contract is a Replan signal, not a reason to stay blind.

## Automatic Task Split

**BEFORE asking questions**, analyze if the task mixes multiple concerns:

**IMPORTANT: Split tasks are independent first-class tasks — NOT subtasks. Each gets its own T-XXX ID, its own backlog entry, and its own full lifecycle. There is no parent/child relationship.**

**Indicators of composite tasks:**
- Task mentions multiple features ("Add X and Y")
- Task affects multiple unrelated domains (auth + UI + data-access)
- Task description uses "and", "also", "plus" repeatedly
- Task solves problems in different places (component + service + state)
- Task has dependencies that could be separate tasks

**When detected:**
1. **STOP** and propose splitting the task
2. Use `AskUserQuestion` to confirm split:
   ```
   Question: "I detected this task mixes multiple concerns:"
   Options:
   - "Work on [Concern 1] first, add others to backlog as independent tasks (Recommended)"
   - "Keep all concerns together"
   - "Different split: [alternative]"

   Context shown:
   - Concern 1: [description]
   - Concern 2: [description]
   - Concern 3: [description]
   ```
3. If user confirms split:
   - Keep ONLY the first concern in current task, update its description
   - Create each remaining concern as a **new independent task** in BACKLOG.md (T-XXX+1, T-XXX+2, etc.)
   - These new tasks are **peers**, not subtasks — same format, same lifecycle as any other backlog task
4. If user rejects, proceed with full task (but warn about complexity)

## Discovery Triage (any phase)

A "discovery" is work NOT described in the active task nor in the epic's Planned Tasks. Splitting the active task's OWN scope into concerns is NOT a discovery — the Automatic Task Split above still applies. Everything else found along the way is triaged:

1. **Blocks the active task** -> Replan Gate (see Execute protocol).
2. **Invalidates the epic's Goal or a Non-Goal** -> STOP, escalate to user before any further work.
3. **Everything else takes the routing test below.** Not a catch-all and not a third destination: three
   outcomes, reached by two questions the engine answers for itself, in a fixed order.

### The routing test

**Ownership is asked first, and the order is the whole mechanism.** Asked anywhere but first, a finding
big enough to be inconvenient escapes to a shared list even where the current task is its owner — which
is how one ledger reached 23 entries, some outliving five closed epics, under a rule that admitted
everything in one line.

1. **Is the finding in a file already inside this task's diff?** -> **yes: the task owns it, fix it now.**
   Terminal for the routing; nothing further is asked. The set is `## The Task Diff` as the Verify
   protocol defines it — commits included, uncommitted work, untracked files — referenced from there and
   never re-derived here. A command written out at this point narrows the answer silently, and what it
   drops is precisely the work the task has already committed.

   **Before Execute has written anything that set is empty**, and a question answering *no* by
   construction is not a mechanism — it is a clock. So until the first edit lands, the same question is
   asked against the files the task has already **named**: the Files Affected table above, and the plan's
   per-step file lists. From Execute onward it is asked against the diff. Ownership is a property of the
   finding and of the reach this task declared, never of the hour it was noticed.

   **What the task owns it fixes now — where the fix is small and traceable**, in the sense Surgical
   Changes gives those words. Where it is not, the finding stays **owned**: it is staged with the
   `own ground` stamp and the reason it was not fixed here, and it never escapes to the shared list on
   account of its size. Ownership is asked before size so that nothing large escapes merely for being
   large; size then bounds the **action** and never the routing. That is the whole of the distinction,
   and it is what keeps this rule from ordering a change that Surgical Changes and the
   *>3 unplanned files -> Ask First* boundary both forbid.

2. **Is the finding on ground this front declared?** -> a **stamp**, never a branch. The declaration is
   the front's areas from move 2 of the opening ceremony, carried on its roster row. From a linked
   worktree that roster is not local: locate the main checkout with git's own worktree listing
   (`git worktree list` — its first entry, the same anchor the guardrail hooks resolve) and read
   `STATE.md` there **read-only**, never copying it in and never writing there. The answer is *own
   ground* or *foreign ground*, recorded with the inputs that produced it
   (`foreign ground (installer ∉ {protocols})`). **Where the read cannot be made** — no main checkout
   reachable, no `STATE.md` there, no row for this front, or a row whose areas cell is empty — the stamp
   is `unknown` with the cause named, and it is never simply omitted. The twin instruction above stops an
   Understand over an unreadable Scope Contract because a contract is a constraint and acting without it
   is acting blind; a stamp is a record, and the failure to avoid here is the opposite one — a record
   that goes missing quietly is the thing the close cannot recover. It is deliberately not terminal: making own ground
   force the fix would turn a front's entire declared area into scope creep, against the Surgical
   Changes rule. What it buys is that a wrong hand-off is visible at the close instead of invisible
   forever.

Then exactly one of two outcomes:

- **Discard** — the failure the finding describes **cannot occur**: either the flow **cannot reach** it,
  or it reaches it and cannot fail there. Both halves are needed, because only one of the three shapes a
  false positive takes is about reachability — the code was misread — while the other two are reached and
  are still not failures: the behaviour is intended, or something downstream already prevents it. A test
  written on reach alone cannot be satisfied in good faith for those two, and an agent held to it will
  either fabricate the sentence or stall on an outcome this same list calls valid.
  This is the one judgment nothing can derive, so what is checkable is the **written reason**: name why
  the failure cannot occur, under `## Discarded` in `artifacts/T-XXX/discoveries.md`. **That file is its
  only home.** A phase that also records the outcome in a report of its own records the decision and a
  pointer — never the reason instead, or the record that makes the discard valid lives where the rule
  requiring it will not look. With no reason written there is no dismissal — a discard nobody wrote down
  cannot be told apart from a finding nobody triaged.
- **Stage** — everything else goes to `artifacts/T-XXX/discoveries.md`, the task's own papers, **never
  to BACKLOG.md while work is in flight**. One `##` heading per finding, then `ground:` carrying the
  stamp and its inputs, then the body: what was found and why it matters, written once, here, in full.
  **Discards live in that same file under a single `## Discarded` section, one `###` per discard** — not
  as `##` headings of their own. The consumer this shape exists for walks the `##` headings and moves
  each body verbatim; at the same level it would read the killed findings as live ones and republish, as
  pending work, precisely what a written reason had killed. **Sightings live in that same file under a
  single `## Sightings` section, one `###` per entry met** — not as `##` headings of their own, for the
  same reason discards are not: that consumer would republish a sighting as a finding this task never
  made.

**Where a staged finding goes next is the write-back at this task's close** — `Icebox write-back`, step 3
of the single-task archive checklist (see Backlog protocol). It publishes what the task found and did not
own: the operator sees both halves, and what they admit becomes one index line plus its own body file, the
essay moved there verbatim from this staging file. Until that close the finding lives here and nowhere
else, which is the point — a staged finding is the task's paper while the task is in flight, and it becomes
the ledger's only at a moment somebody is reading. The quick path keeps no papers at all, so it takes these
outcomes and surfaces what survives at its close (see Quick Path protocol).

Entries already in BACKLOG.md's `## Icebox` are swept WITH the operator at epic close, and promoted or
retired there. That sweep is no longer the only route out and no longer the first reader: the write-back
above is. Nothing new reaches that section while a task is in flight. See Backlog protocol > Icebox.

## Steering Files

**After task split analysis**, identify which domains the task affects and read what the `steering:` map in `.ai-flow/project.yml` names for each. These contain domain-specific rules, patterns, and pitfalls that inform better questions and plans.

**What is loaded is the map's value, whatever path it names.** `.ai-flow/steering/<domain>.md` is the conventional place and not the only one: a project may point an entry at any file it keeps — a checklist, an architecture card, a document it already maintains elsewhere. Resolving to the directory instead of to the value would silently drop every entry that names something else, and drop it with no diagnostic, since a path never looked up cannot be reported missing.

If the map names nothing for the affected domain, proceed without one. Each file it does name opens with a `## Nano` block (one line per rule or section) — read the nano first; read the full body when the task actually touches that domain.

## Investigation

**After task split analysis and steering file load** (if applicable):

**Scoping pass (always, inline):** before deciding how to investigate, locate the entry points of the affected behavior (grep, read the obvious files) and produce a candidate list of affected areas. This pass SIZES the investigation — it is not the investigation itself.

**Icebox scan (always, inline)** — a step of that same pass, run once it holds the candidate areas and
before the unknowns are written. It reads **only the summary lines** in the ledger's `## Icebox`, one per
entry, and **loads a body only where an entry's statement touches this task's ground** — the file is
`.ai-flow/icebox/IB-XXX.md`. The intersection is a **judgment over that statement**, and never a stored field: an
area field on the entry would have to be kept true every time the entry is re-priced, and measured against
this engine's own ledger the front's declared areas matched 4 of 4 entries, discriminating nothing. So what
is auditable here is the scan's **record**, never its computation.

The scan writes **one aggregate line**: how many entries were scanned, and which ones matched. A scan that
matched nothing still writes its count — otherwise a skipped scan and a scan with no matches read
identically, which is the defect the `## Unknowns` list already suffers. Entries that did not match get
nothing written into them; a line per entry per task is 27 writes and a log that fills with "did not
apply" is a log that stops being read. Every entry whose body **was** loaded leaves a record, and the two
branches leave different ones. The entry this task **takes** it takes under the ownership rule the routing
test above already states — its ground is inside this task's diff, so it is the task's to fix — and its
record is the retirement the write-back's amendments half performs, or a `narrowed` sighting where what the
task took only made it smaller. **Taking an entry is never promoting it to a task**: the doors for that are
Backlog protocol > Icebox and neither of them is here, which is why this branch mints no identifier and
chooses no priority. The entry this task does **not** take owes a `deferred` sighting staged in this task's
papers (see Discovery Triage above), naming the task that deferred it. The investigation spent declining an
entry is the same investigation that would have priced it — discarded, the next reader pays for it again.

Where a loaded entry's log already carries a second `deferred` line, the scan **says so beside its
aggregate line** and performs nothing else: two deferrals is a signal and the rule it serves is Backlog
protocol > Icebox, which also holds the five verbs a sighting may carry and the two counts derived from the
log.

From a **linked worktree both halves are read at the main checkout and neither locally** — the summary
lines in its `BACKLOG.md` and the bodies those lines name — located by `git worktree list` as the Scope
Contract read above locates it, and **read-only: never copied in and never written to**. The bodies are
deliberately not carried to a front (`.worktreeinclude` keeps them with the primary checkout, which stays
their single writer), so a front resolving `.ai-flow/icebox/` against itself finds an empty directory and
would read every matched entry as an entry with no body.

**Three failures, and the whole value of the count is that they do not read alike.** A summary line naming
a body genuinely absent at the main checkout is reported by name and the scan continues — an entry is never
silently dropped. A `## Icebox` that is absent or empty is zero scanned and not an error: the ordinary
state of a fresh install. And a **main checkout or ledger that cannot be reached at all is not zero
scanned** — it takes the answer the Scope Contract read above already gives, say so and stop, because an
unreadable ledger recorded as an empty one is exactly the indistinguishability this whole paragraph exists
to refuse.

**Unknowns list — the mandatory, written output of the scoping pass.** The scoping pass is not done until it produces a `## Unknowns` list presented in chat: every open question about the code, one line each ("who else consumes X?", "does flow Y survive Z?"). "No unknowns" is a valid outcome but must be stated explicitly with its source ("Unknowns: none — files pinned by the epic ficha"). The decision inline-vs-agents is never mental: it is derived from this list, and the list lands in understand.md (see template). An unknown that is really a business decision goes to Contextual Questions, not to investigation.

**Altitude — what the first measurement must be able to break.** The first measurement must be able to falsify the framing of the question, not merely answer it. When the task arrives with a diagnosis already attached — named in the task's own text, or recorded by an earlier phase — measure the whole and locate the part; do not inspect the named suspect first. A confirmed suspect proves nothing, because it was named before anything was measured; a falsified frame saves the phase. The artifact records that first measurement and what it could have falsified. Where no diagnosis arrived attached, the field is not written: a note that fires on every run is how a check stops being read.

**Resolution — one Decision per unknown:**
- Every unknown closes with a **Decision + evidence** — never a global feeling of "enough context". The evidence names its provenance, because a fact read first-hand and an agent finding are not one standing: the first carries its `file:line`, the second carries whose answer it was. Both close an unknown; only the first was checked by the one who is about to plan on it. An agent's answer to a question that had not yet survived a round of measurement is a lead, not evidence.
- **Unknowns spanning 2+ areas**, or 1 area whose flow crosses layers/files you have not read -> launch Explore agents in parallel, one per area.
- **Single-area unknowns with affected files already identified** -> resolve inline, tracing the flow end-to-end (see Investigation Closure below).
- **Scope still unclear after the scoping pass** -> that IS the signal to launch agents. Unclear scope is never a reason to guess and move on.

What rules the decision is the area left unmeasured: a missed area invalidates the plan during Execute, and it does so long after the phase that could have read it cheaply. Delegating is not a price paid for prudence — the resolution rules above say when a fan-out is the right shape, and the skip rules below say where it is refused. Pricing the fan-out as an expense is not what decides it.

**The convergence is never delegated.** An agent answers the question it was given, confidently, including when the question is wrong — so a fan-out launched over a question that is still moving buys a confident answer to the wrong question, and buys it in the shape of a finding. Delegate a fan-out whose question has survived one round of measurement — the scoping pass above is that round, so scope still unclear *after* it is a measured question and the fan-out there is the rule above, not an exception to this one. While the question is still moving, investigate inline. Settling what the question is stays here, in every case.

**Example:** Task affects auth + payments + notifications ->
- Agent 1: Explore auth domain (models, services, state)
- Agent 2: Explore payments domain (relevant interfaces, APIs)
- Agent 3: Explore notification service (current patterns, triggers)

**When to skip (explicit, mirrors Verify's skip rules):**
- **Epic tasks from the second onward** — Epic-Scoped Understanding above applies: unknowns limited to the task's own files, no broad Explore agents.
- **Quick path / Auto level** — the phase is skipped entirely, so neither reaches the Icebox scan: the
  quick path keeps no papers to stage a sighting in, and the auto level runs no phase to scan from. Said
  rather than left silent, because a mechanism absent by decision and one absent by accident read
  identically from outside.

Use the results to formulate better contextual questions. Do NOT ask the user questions that could be answered by reading the codebase.

## Contextual Questions

After decomposition and investigation (or if task is atomic), gather missing context.

**Facts vs decisions — the airtime rule.** Finding facts is the agent's job, never the user's. Anything answerable by reading the codebase, docs, or logs is investigated, not asked — if a question could be answered by grep, it is forbidden. The user's airtime is reserved for **decisions**: business intent, trade-offs, domain boundaries, what is acceptable to lose.

**Always ask when:**
- The Business Frame has holes (role, rule served, what is lost, or observable success unknown)
- A NEW business rule would be minted (never silently invent a rule of the user's product)
- Task has ambiguous requirements ("improve UX", "optimize performance")
- Multiple approaches exist whose difference has a business consequence
- Expected behavior is not explicitly defined
- Edge cases are not specified

**Question format — every question, no exceptions:**
1. **Self-contained, in product language**: the question carries its own context — what I found (one line, plain), what is at stake (the business consequence), 2-4 options. If it cannot be phrased so the user understands it without re-asking, the question is not ready: the gap is my investigation or my translation, never the user's reading.
2. **Business consequence stated**: if I cannot state a question's business consequence, it is mechanics in disguise — I resolve it myself and record it in the plan's Decision Register instead of asking.
3. **Recommended answer marked**: the user corrects rather than authors.
4. **No-cost escape**: "I need more context" is always a valid option. The user choosing it means MY question failed — rephrase simpler. Never pressure toward "the closest option": a guessed answer recorded as a decision is worse than no answer.
- Use `AskUserQuestion`, 2-4 questions per round, each with 2-4 options; always include "Mas preguntas".

**Interrogation techniques (grill):**
- **Simple -> complex ladder**: each round's answers build the context the next round needs. Prefer 3 simple questions over 1 dense one. Probe with concrete scenarios rather than abstract compound questions ("a viewer-only member of account A opens Settings -> Members: what should they see?").
- **Re-question against code/docs**: do not accept the first answer at face value — check it against what the code and docs actually allow; if they disagree, come back with the contradiction as a follow-up question.
- **Hunt contradictions on TWO fronts**: what the task asks vs. what the code permits, AND what the task asks vs. the business model (product.md glossary + business rules). Every contradiction found on either front is a question the user must settle, not a detail to silently resolve.
- **Frontier ordering**: a question is ready only when its prerequisite questions AND the context the user needs to understand it are both settled — ask in dependency order, not everything at once.
- **Closure criterion**: Understanding is done when you can restate the goal and the user corrects nothing. If your restatement draws a correction, the phase is not over.
- **Re-asks are telemetry**: one re-ask = my question was mis-pitched, fix it in the moment. Recurring re-asks in the same area = missing standing context -> write it to product.md so it is never asked again.

## Criteria Format (EARS)

Every **Automated** and **Behavioral** criterion in understand.md is written in one of the 5 EARS patterns:

| Pattern | Shape | Use for |
|---------|-------|---------|
| Ubiquitous | The [system] shall [response] | Always-true invariants |
| Event-driven | WHEN [trigger], the [system] shall [response] | Reactions to events |
| State-driven | WHILE [state], the [system] shall [response] | Behavior sustained during a state |
| Unwanted behavior | IF [condition], THEN the [system] shall [response] | Errors, edge cases, failure paths |
| Optional feature | WHERE [feature/platform applies], the [system] shall [response] | Config/platform-dependent behavior |

**Gate (before Plan):** a criterion that does not parse as one of the 5 patterns, or whose response/THEN is not observable (nothing to point at — no test, no file:line, no visible behavior), must be reformulated before proceeding to Plan.

GIVEN/WHEN/THEN is no longer the criterion format — it moves down to CONFORM as the **test format** (see Plan protocol): each EARS criterion becomes one or more GWT test stubs.

**Exempt:** Auto-level and quick-path tasks.

## Business Closure (gate before writing understand.md)

Restate the Business Frame to the user in their language — role affected, rule served, what is lost, out of scope, observable success. **Zero file paths, zero code identifiers.** Understanding is not over until the user corrects nothing.

This gate is symmetric to Investigation Closure below: the technical gate proves I know WHERE the change lands; this one proves I know WHY it exists. Both must hold before writing understand.md.
**Exempt:** Auto-level and quick-path tasks.

## Investigation Closure (gate before writing understand.md)

Do not write understand.md until all four hold:

1. **Every Unknown closed** — each entry in the Unknowns list has a Decision + evidence whose provenance is named (see Resolution above); none resolved by assumption, and none closed by an agent's answer to a question that had not survived a round of measurement.
2. **file:line for every expected change** — verified by reading the file, not inferred from naming or convention.
3. **Flow traced end-to-end** — entry point -> affected behavior -> its consumers, and you can state what each hop actually does (no assumptions; see CLAUDE.md debugging rule).
4. **Blind spots named** — you can list what you did NOT read and say why it cannot change the plan.

If any of the four fails, the fix is more investigation — never an estimate.
**Exempt:** Auto-level and quick-path tasks (they skip this phase entirely).

## Output: understand.md

Include only fields relevant to the task type. Omit sections that don't apply (e.g., skip UI/UX Details for backend-only tasks).

Write `artifacts/T-XXX/understand.md` with:
```markdown
# Understanding: [Task ID] - [Task Title]

## Business Frame
<!-- Readable alone, product language only — zero file paths, zero code identifiers -->
- **Role affected**: [who experiences this change]
- **Business rule served**: [the real-world rule this enforces/enables]
- **Today / after**: [what the product does today -> what it will do]
- **What is lost**: [capability a role gives up + the user's explicit acceptance — or "nothing"]
- **Out of scope**: [what this task deliberately does not change]
- **Observable success**: [user-visible scenarios they will see working]
- **New business rules minted**: [rules confirmed in this task that product.md must gain at archive — or "none"]

## Original Task
[Original description from backlog]

## Task Decomposition
- **Status**: [Atomic / Decomposed]
- **Active Scope**: [What we're solving now]
- **Deferred to Backlog**: [List of new task IDs, if decomposed]

## Altitude
<!-- Only where the task arrived with a diagnosis already attached — omitted otherwise. -->
- **First measurement**: [what was measured first, and what it could have falsified]

## Unknowns & Resolution
<!-- Copied from the scoping pass — or the explicit line "Unknowns: none — [source]" -->
| # | Unknown | Resolved via | Decision + evidence |
|---|---------|--------------|---------------------|
| 1 | [open question about the code] | inline | [decision] — `file:line`, read first-hand |
| 2 | [open question about the code] | Explore agent | [decision] — reported by [which agent, over what] |

- **Icebox scan**: [N] scanned, matched: [IB-XXX, IB-YYY — or "none"]; deferred twice: [IB-XXX — or "none"]; unread: [IB-XXX (body absent) — or "none"]

## Context Gathered
[Answers from user questions]

## Requirements Clarification
- **Goal**: [Clear, specific goal]
- **Expected Behavior**: [Detailed behavior description]
- **UI/UX Details**: [Specific details: position, style, interactions]
- **Edge Cases**: [How to handle edge cases]
- **Verifiable Criteria** (Automated + Behavioral in EARS — see Criteria Format):
  - **Automated** (tests): [EARS criterion] -> `[spec file]`
  - **Observable** (code inspection): [concrete checkable fact]
  - **Behavioral** (UI/flow tasks only):
    - WHEN [trigger], the [system] shall [response]
    - IF [condition], THEN the [system] shall [response]

## Technical Considerations
- **Files Affected (verified)**: [files confirmed by reading — path + one line on why each changes]
- **Unverified Assumptions**: [anything the plan will rely on that was NOT confirmed in code — ideally "none"; each entry here is a candidate Replan Gate]
- **Approach**: [Preferred approach based on user answers]
- **Risks**: [Potential issues to watch for]
```

## Understanding -> Plan Transition

Before proceeding to plan:
1. Present the Business Frame in chat (product language, no file paths) — this IS the summary the user reads; the technical half of understand.md is available on demand
2. Use `AskUserQuestion`:
   ```
   Question: "Do you need to clarify anything else before I create the plan?"
   Options:
   - "No, proceed with the plan (Recommended)"
   - "Yes, I have more questions"
   ```
3. Only proceed to plan when user confirms clarity (the write-guard hook stops restricting once the close below writes PLAN to the task's state sheet — the rail is released by step 4, one boundary earlier than the `plan` command, because that is where the position now moves; see the backlog protocol's `### The phase precondition`)
4. **Close the phase**: advance the sheet to the position Plan will declare, end with the fixed line, and end the turn. This is one of the chain's two cut points (`lifecycle.md` > `## Sessions`); what that line carries, and what else the close owes, is stated in the backlog protocol's `### The phase precondition` and only there — route to it, do not restate it here.
