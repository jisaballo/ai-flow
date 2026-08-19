# Understanding Phase Protocol

**CRITICAL:** This phase ensures polished code by gathering all necessary context BEFORE planning.

**Read-only rail (hook, not Plan Mode):** While the task's state sheet (`artifacts/T-XXX/state.md`) marks the current phase as UNDERSTAND, a PreToolUse hook (`~/.claude/hooks/understand-write-guard.py`) blocks Edit/Write to any repo file outside `.ai-flow/`. If the hook is not installed, honor the rail by discipline — same rule, unenforced. Do NOT use Plan Mode for this phase. Investigation is unrestricted — reads, greps, Explore agents, and running tests/commands to reproduce a failure are all allowed. Writing understand.md needs no special step (it lives under `.ai-flow/`); throwaway repro scripts go to the scratchpad directory, not the repo.

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
3. **Everything else** -> ONE line in BACKLOG.md under `## Icebox`: `- (E-XXX, found in T-YYY) description`. No T-ID, no priority, no artifacts, no further investigation. Capture and move on.

Icebox entries are reviewed IN BATCH at epic close (or when the user asks) — promotion to real T-XXX tasks happens only there, never mid-epic. See Backlog protocol > Icebox.

## Steering Files

**After task split analysis**, identify which domains the task affects and read the corresponding steering files from `.ai-flow/steering/{domain}.md`. These contain domain-specific rules, patterns, and pitfalls that inform better questions and plans.

The available steering files are the values of the `steering:` map in `.ai-flow/project.yml` (files under `.ai-flow/steering/`).

If no steering file exists for the affected domain, proceed without one. Each code-domain steering file opens with a `## Nano` block (one line per rule) — read the nano first; read the full body when the task actually touches that domain.

## Investigation

**After task split analysis and steering file load** (if applicable):

**Scoping pass (always, inline):** before deciding how to investigate, locate the entry points of the affected behavior (grep, read the obvious files) and produce a candidate list of affected areas. This pass SIZES the investigation — it is not the investigation itself.

**Unknowns list — the mandatory, written output of the scoping pass.** The scoping pass is not done until it produces a `## Unknowns` list presented in chat: every open question about the code, one line each ("who else consumes X?", "does flow Y survive Z?"). "No unknowns" is a valid outcome but must be stated explicitly with its source ("Unknowns: none — files pinned by the epic ficha"). The decision inline-vs-agents is never mental: it is derived from this list, and the list lands in understand.md (see template). An unknown that is really a business decision goes to Contextual Questions, not to investigation.

**Resolution — one Decision per unknown:**
- Every unknown closes with a **Decision + evidence (file:line or agent finding)** — never a global feeling of "enough context".
- **Unknowns spanning 2+ areas**, or 1 area whose flow crosses layers/files you have not read -> launch Explore agents in parallel, one per area.
- **Single-area unknowns with affected files already identified** -> resolve inline, tracing the flow end-to-end (see Investigation Closure below).
- **Scope still unclear after the scoping pass** -> that IS the signal to launch agents. Unclear scope is never a reason to guess and move on.

The cost asymmetry rules the decision: an unnecessary Explore agent costs minutes; a missed area invalidates the plan during Execute.

**Example:** Task affects auth + payments + notifications ->
- Agent 1: Explore auth domain (models, services, state)
- Agent 2: Explore payments domain (relevant interfaces, APIs)
- Agent 3: Explore notification service (current patterns, triggers)

**When to skip (explicit, mirrors Verify's skip rules):**
- **Epic tasks from the second onward** — Epic-Scoped Understanding above applies: unknowns limited to the task's own files, no broad Explore agents.
- **Quick path / Auto level** — the phase is skipped entirely.

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

1. **Every Unknown closed** — each entry in the Unknowns list has a Decision + evidence (file:line or agent finding); none resolved by assumption.
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

## Unknowns & Resolution
<!-- Copied from the scoping pass — or the explicit line "Unknowns: none — [source]" -->
| # | Unknown | Resolved via | Decision + evidence |
|---|---------|--------------|---------------------|
| 1 | [open question about the code] | inline / Explore agent | [decision] — `file:line` |

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
3. Only proceed to plan when user confirms clarity (the write-guard hook stops restricting once the task's state sheet moves the phase past UNDERSTAND)
