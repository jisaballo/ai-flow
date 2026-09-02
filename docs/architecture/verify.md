# verify — architecture card

## Nano

- **What it is** — three pieces: a protocol that defines, a skill that runs, a workflow that judges.
- **The artifacts** — what each piece reads and writes; `verify.md` is the only thing the capability produces.
- **The homes table** — every concept the review is made of, against every file that carries it.
- **External dependencies** — what verify needs from the rest of the chain, and what it degrades to without each.

## What it is

Three pieces, and the split is worth holding in mind because each fails differently.

`global/protocols/verify.md` is the **rulebook**. It defines the task diff, the status meanings, the
mutation rule, the consolidation mapping and the report templates. It is read and never runs; a defect
here is a rule two readers implement differently.

`global/skills/verify/SKILL.md` is the **referee**. It resolves the task, audits each criterion itself,
takes the snapshot, invokes the review, compares the tree afterwards and writes the report. A defect here
is a step skipped in silence.

`global/workflows/verify-review.js` is the **machine**. It holds the five auditors — business contract,
test coverage, security & error handling, architecture boundaries, simplicity & structure — with their
prompts, their schemas and the adversarial refutation. A defect here is a judgement made against the wrong text — and it
is the only piece whose content the reviewing agents actually receive.

## The artifacts

| Artifact | Inputs | Outputs |
|---|---|---|
| The skill's run | the task's sheet, `understand.md`, `plan.md` and its Criteria Coverage table, `project.yml` (`commands.test`, `steering`, `review`, `review_profile`), the task diff from git | `.ai-flow/artifacts/T-XXX/verify.md` |
| The workflow call | `args`: `taskId`, `area`, `understandPath`, `planPath`, `steeringPath`, `claudeMdPath`, `changedFiles`, `diffText`, `testCommand`, and the five optional `*Checklist` paths | `{ confirmed, refuted, unverified, proofs, summary }` |
| The protocol | nothing — it is read, not executed | nothing |

The skill is the only piece that touches the filesystem. The workflow is pure with respect to the
repository: its agents are read-only by instruction, and the one mutation stage runs alone, afterwards.

## The homes table

Every concept the review is made of, against every file that carries it. To change one, tick the row.

| Concept | Files |
|---|---|
| Auditor list | `global/workflows/verify-review.js`, `global/skills/verify/SKILL.md`, `global/protocols/verify.md`, `global/protocols/lifecycle.md`, `README.md`, `docs/customization.md`, `template/.ai-flow/project.yml`, `docs/architecture/verify.md` — this card is a home too, because the guard below obliges it to name the axes |
| Axis content (what each auditor looks for) | `global/workflows/verify-review.js` (`DIMENSIONS`) — one home by design, plus whatever a project declares under `review:` in its own `project.yml` |
| Workflow arguments | `global/workflows/verify-review.js` (the header comment and each `a.*` read), `global/skills/verify/SKILL.md` (step 7), `docs/architecture/verify.md` — this card's artifacts table names them too, and a card that omitted itself here would be the miscount it exists to prevent |
| Declarable profile axes | `template/.ai-flow/project.yml`, `docs/customization.md`, `global/skills/verify/SKILL.md` (step 7's resolution) |
| Report template | `global/protocols/verify.md` — each copy anchored on `**Audited**`, which is what the suite counts them by rather than trusting a number written here |
| Severities | `global/workflows/verify-review.js` (the finding schema, the verdict schema, `REFUTE`), `global/protocols/verify.md` (the gate rules), `global/skills/verify/SKILL.md`, `global/protocols/lifecycle.md` |

Two rows are guarded and the rest are not, which is worth knowing before trusting them. The auditor list
is checked against the suite's own document set, and the auditor count inside each of those files is
checked against the number of dimensions the workflow declares. Nothing yet checks the other rows.

## External dependencies

What verify needs from the rest of the engine, and what it becomes without each. An entry whose
degradation is "stops" is a hard requirement; the others are why the map draws an `enriches` arrow.

| Needs | From | Without it |
|---|---|---|
| The task-resolution ladder, the phase precondition | backlog ceremonies | Stops. It cannot say which task it is auditing, and a wrong answer overwrites another task's papers. |
| The Verifiable Criteria; the routing test for findings below the blocking level | understand | Stops. The criterion audit has no oracle, and triage has nowhere to send what it does not fix. |
| The Criteria Coverage table; the contract the user approved | plan | Stops. The audit would rebuild the criterion mapping from scratch, and the contract auditor falls back to a Goal paragraph. |
| The conformance baseline manifest | plan, at Conform's close | Degrades. Stub bodies drift with nothing frozen to compare them against. |
| The diff itself | execute | Stops. There is nothing to judge. |
| The base resolution for the task diff | guardrail hooks (the diff brake) | Degrades. The skill's prose copy becomes the only authority, and the two can drift apart unnoticed. |
| The project's test command | harness | Degrades. The prover reports a proposal unproven rather than guessing. |
