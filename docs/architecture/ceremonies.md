# ceremonies — architecture card

## Nano

- **What it is** — the rulebook, the ladder's one code home, the opening ceremony's seeding mechanism, and
  four guardrail hooks that each enforce one ceremony rule on their own.
- **The artifacts** — the task-resolution ladder's inputs and outputs, the two ceremonies, and a task's own
  papers.
- **The homes table** — the six concepts backlog ceremonies are made of, against every file that carries
  each, computed rather than authored.
- **External dependencies** — what ceremonies needs from install, and what degrades in the guardrail hooks
  that enforce a ceremony rule without ceremonies knowing it.

## What it is

`global/protocols/backlog.md` is the **rulebook**. It defines the task-resolution ladder, the phase
precondition, the two ceremonies (`## Opening a Workstream`, `## Closing a Workstream`), the
STATE.md/state.md/brief.md shapes, the Icebox, and the BACKLOG/STATE size budget. It is read and never
runs; a defect here is a rule two readers implement differently.

`global/hooks/_aiflow_state.py` is the ladder's **one code home** — its own docstring states it is the
ladder's authority in code, as the backlog protocol's State Files is its home in prose. A defect here is
the ladder disagreeing with itself between two readers: the read-only rail and a phase command.

`global/scripts/seed-front.sh` is the opening ceremony's **seeding mechanism** — what actually creates a
front's checkout and prunes the papers it does not own. A defect here is a new front inheriting another
task's artifacts.

Four **guardrail hooks** each enforce one ceremony rule, independent of the three pieces above:
`global/hooks/artifact-write-guard.py` (the never-overwrite rule), `global/hooks/index-line-budget-guard.py`
(the Icebox ceiling), `global/hooks/check-state-size.sh` (the BACKLOG/STATE size budget), and
`global/hooks/context-structure-guard.py` (gates the archive checklist's context-writing moves on the
checklist's own `phase == ARCHIVE` marking). A defect in any one silently reopens the rule it was written
to hold shut.

## The artifacts

| Artifact | Inputs | Outputs |
|---|---|---|
| The task-resolution ladder | the checkout's current branch, every sheet's `branch:`/`phase:` line, STATE.md's roster | which task a checkout is on, or a stop naming the rungs tried |
| The opening ceremony | the front's declared areas, the epic (if any), `project.yml`'s `front_tool` | a new front's checkout, its seeded `artifacts/`, a STATE.md row |
| The closing ceremony | the task's approved work, its artifacts | `archive/T-XXX/` with `summary.md`, its BACKLOG.md/STATE.md row removed, context files written per `docs/context/context.md` > Writing |
| A task's own papers | whoever works the task, per phase | `brief.md` (capture), `state.md` (every phase's progress), the Icebox's `IB-XXX.md` |

## The homes table

Every concept backlog ceremonies are made of, against every file that carries it. To change one, tick the row.

| Concept | Files |
|---|---|
| Task-resolution ladder | `global/protocols/backlog.md` (## State Files > Resolving the task), `global/hooks/_aiflow_state.py` |
| Task-papers shapes | `global/protocols/backlog.md`, `template/.ai-flow/STATE.md`, `global/hooks/_aiflow_state.py`, `global/hooks/artifact-write-guard.py` |
| Opening ceremony's seeding move | `global/protocols/backlog.md` (## Opening a Workstream), `global/scripts/seed-front.sh` |
| Closing ceremony / archive checklist | `global/protocols/backlog.md` (### After ARCHIVE), `docs/context/context.md`, `global/hooks/context-structure-guard.py` |
| Icebox mechanism | `global/protocols/backlog.md` (### Icebox), `global/hooks/_aiflow_state.py`, `global/hooks/index-line-budget-guard.py` |
| BACKLOG/STATE size budget | `global/protocols/backlog.md` (## BACKLOG.md Size Budget), `global/hooks/_aiflow_state.py`, `global/hooks/check-state-size.sh` |

Every row is **computed**, the same way `verify.md`'s own table is — see that card's own closing
paragraph under **The homes table** for the mechanism.

## External dependencies

What ceremonies needs from the rest of the engine, and what it becomes without each. An entry whose
degradation is "stops" is a hard requirement; the others are why the map draws an `enriches` arrow.

| Needs | From | Without it |
|---|---|---|
| A front's checkout to seed into | install | Stops. There is nothing to open a workstream against. |
| The never-overwrite rule on a phase artifact | guardrail hooks | Degrades. A replan or a re-run can blind-overwrite a previous session's decisions with no refusal. |
| The Icebox's word ceiling | guardrail hooks | Degrades. An entry can grow past its own budget silently, one entry at a time. |
| The BACKLOG/STATE size budget's enforcement | guardrail hooks | Degrades. The ledger can grow past the size backlog.md itself states, unnoticed until a session reads the whole file. |
| The archive checklist's phase gate | guardrail hooks | Degrades. A context file can be written outside the close, on no ceremony's authority. |
