# Plan Phase Protocol

**Which task**: the phase runs on the task this checkout owns. Resolve it by the ladder in the backlog
protocol (`## State Files` → `### Resolving the task`) — stated there and only there — and stop rather
than choose if it ends without one. Then test the phase precondition (same document, `### The phase precondition`) — stated there
and only there too, so this document names no accepted position and no leg of its own. A manual
run performs the check; the command is a convenience over this procedure, never its only carrier.

## The Pyramid Rule (gate semantics)

plan.md is written in three layers, read top-down from simple to complex. The user's reading depth is their control dial — they decide how deep to go before approving.

1. **Contract (layer 1)** — the approval surface. 6-10 lines, product language, zero file paths.
2. **Decision Register (layer 2)** — every technical decision that is hard to reverse or has a business consequence. One line each: decision + consequence + recommendation.
3. **Mechanics (layer 3)** — agent-owned. Files, steps, observables, mocks, verify commands.

**Rules:**
- **No decision may live below its layer.** Reading layers 1-2 must be SUFFICIENT to approve safely. Layer 3 may only contain mechanics whose failure machines catch (conformance tests, verify review). A decision found only in Mechanics is a protocol violation — hoist it before presenting the plan.
- **The plan gate presents layers 1-2 in chat.** Layer 3 stays in the artifact, shown on demand — never pushed. Routine task -> the user can approve on layer 1; risk smell -> layer 2; schema or data changes -> as deep as they want.
- **Approval semantics:** user approval covers Contract + Decision Register. Mechanics are the agent's responsibility, machine-audited against what was approved. Approval of layers 1-2 never implies approval of anything stated only in layer 3.
- **Irreversible operations** (data migration/deletion, credential operations, anything a steering rule marks irreversible, production/store releases) are always layer-1 visible and individually confirmed, regardless of autonomy level.

## Plan Template (Structured Verify)

**CRITICAL:** Every step in plan.md MUST include a `Verify` command and `Done` criteria. This is mandatory, not optional.

Write `artifacts/T-XXX/plan.md` with:
```markdown
# Plan: [Task ID] - [Task Title]

## Contract
<!-- Layer 1 — product language, zero file paths. Drafted from understand.md's Business Frame. -->
- **Today**: [what the product does today]
- **After**: [what it will do]
- **What is lost**: [capability given up — or "nothing"]
- **Out of scope**: [deliberately untouched]
- **You will see it working**: [observable scenarios]
- **Irreversible**: [irreversible actions this plan performs — or "nothing"]

## Decision Register
<!-- Layer 2 — one line per decision: what + business consequence + recommendation.
     Status: (confirmed) = user settled it in Understand; (proposed) = needs their eyes at this gate.
     (global) marks a decision that reaches beyond this task, so the close writes it as a section of
     decisions-global.md — the archive checklist's global-decision move reads this marker and nothing else.
     (structure: context) marks a decision that changes the structure of a context file or of the context
     mechanism itself, so approving this plan writes the line `structure: context` to the task's sheet and
     the structure guard opens for the work — on the terms `## The Pyramid Rule` above gives irreversible
     operations, since a structural change is layer-1 visible and individually confirmed. One writer, at
     the moment the approval is already being recorded: Conform's close, the same write that advances the
     sheet to EXECUTE. -->
- **D1** (proposed): [decision] — consequence: [what it means for the product]. Recommended: [option].
- **D2** (confirmed in Understand): [decision] — consequence: [...].
- **D3** (confirmed in Understand) **(global)**: [decision reaching beyond this task] — consequence: [...].

## Mechanics

### Step 1: [Action-oriented title]
- **Files:** `path/to/file1.ts`, `path/to/file2.ts`
- **Skills:** [workspace skills whose domain this step touches — omit the line if none]
- **Changes:** [Specific description of what to change and why]
- **Verify:** `[test or build command]`
- **Done:** [Measurable acceptance state — not "it works", but what specifically passes]

### Step 2: [Action-oriented title]
- **Files:** `path/to/file3.ts`
- **Changes:** [Specific description]
- **Verify:** `[test or lint command]`
- **Done:** [Measurable acceptance state]

### Step 3: [Action-oriented title]
- **Files:** `path/to/file4.ts`
- **Changes:** [Specific description]
- **Verify:** `[test command]`
- **Done:** [Measurable acceptance state]

## Criteria Coverage

| Criterion (understand.md) | Step | Stub |
|---------------------------|------|------|
| [EARS criterion / Observable] | Step N | `[spec file] > [it() description]` — or, for a non-emitting criterion, "— (inspection)", "— (gap)" or "— (covered)" |
```

## Criteria Coverage (mandatory)

Every plan.md ends with a `Criteria Coverage` table mapping each Verifiable Criterion from understand.md to the step that implements it and the conformance stub that will test it:

- **Criterion without a step** -> replan, or mark it `deferred` with a written justification.
- **Step without a criterion** -> justify it in the table as a technical necessity (scaffolding, migration, tooling).
- **VERIFY inherits this mapping** — the Verify phase audits against this table instead of reconstructing criterion->evidence from scratch.

## Verify vs Done

- **Verify** = a command to run (technical check, must be copy-pasteable)
- **Done** = the expected outcome state (what "passing" looks like)

Both are required per step. If no test file exists for a step, Verify should be a build command (at minimum, it compiles).

The test command comes from `commands.test` in `.ai-flow/project.yml` (interpolate the `{area}` placeholder with the area the step touches); if `project.yml` is absent, infer it from CLAUDE.md.

## Skills per Step

Each step declares a `Skills:` line listing the workspace skills whose domain it touches (the skills the project declares in its CLAUDE.md). Omit the line when none applies. The skill descriptions' TRIGGER/SKIP boundaries tell you which apply. Execute loads them lazily per step — see the execute protocol.

## Conformance Tests (Post-Plan, Pre-Execute)

**After the plan is approved and before Execute begins**, generate conformance test stubs from the Verifiable Criteria in understand.md.

### How it works

**Before step 1 runs, resolve context.** Resolve the task's affected `steering:` entries and the fixed
parts of `product.md` and `decisions-global.md`, by the cuts `protocols/context.md` > `## Reading`
defines — the rule owns the set, the cuts and the read-once rule, and this paragraph restates none of
it.

1. **Read** the Verifiable Criteria from `artifacts/T-XXX/understand.md` — they arrive in EARS format (see Understand protocol), each carrying `observed:` and `falsified-by:`. GIVEN/WHEN/THEN is the **test format**: an emitting criterion becomes one or more GWT stubs.
2. **Emission is keyed on `observed:`, and not on the criterion's kind.** `run`, `compute` and `resolve` emit a row. `read` emits none: it is the value with no oracle, so a stub over it would be written and read by the same actor, and what that detects is a change rather than a fault. **`observed:` decides whether a row is owed; it does not decide that one is written.** A criterion an existing assertion already reaches is owed a row and gets none, because the row exists — that is the `covered` cause below, and it is the only way an emitting value produces no new row. Recording it is what keeps the two apart: a manifest that shows `run` beside `covered` says *asserted elsewhere*, and one that shows `run` beside no row at all is a row someone forgot.
3. **The stub's body is the real assertion from the first minute.** A body that fails by construction is forbidden — it proves the stub runs, never that it reads its subject. Red at Conform therefore means *bound to the subject*, green after Execute means *the change made it true*, and the pair is a mutation the plan gets for nothing under the condition below.
4. **The kind Conform keys on is the falsifier-derived one** (Understand protocol > the `falsified-by:` rule). Where the author's declared bucket disagrees with it, Conform proceeds on the derived kind and **records the disagreement** in the manifest: a recorded wrong label is a datum a reviewer can challenge, a silent one is the failure. The declared bucket is advisory for exactly as long as the criteria template keeps asking the author for it.
5. **A row that cannot be born red pays at authorship instead.** A row green from the start — an invariant, a regression guard — runs its `falsified-by` **once, now**, and the manifest records what was mutated, what the suite reported, and that the mutation was reverted. A falsifier written and never run is a falsifier that was believed. **Now** is the moment the row is authored, and Conform is not the only such moment: a row authored later in the task's life pays at its own authorship on the same terms, under the rule the Verify protocol states at `### The acceptance rule for a repair leg`.
6. **A non-emitting criterion is recorded, never silent**, with one of **three** causes, which are not interchangeable:
   - **inspection** — the `falsified-by:` names a change only the criterion's own author would make. No second source ever existed and nothing was lost.
   - **gap** — it names a change another actor could make, and **no honest assertion reaches the criterion as written**. A real hole, recorded rather than refused, because a gate turning on *no honest assertion exists* asks the author to prove a negative. *As written* is load-bearing: an assertion that reaches some neighbouring string — a retired spelling, one instance of the class the criterion forbids — has not reached the criterion, and filing such a row as anything but a gap records a coverage the task does not have.
   - **covered** — an honest assertion reaches it and **something already asserts it**. Neither of the others fits: a gap would be false, and inspection would claim no second source exists when one does.
7. **Run the test suite** — every emitted stub MUST fail, and each must fail for its own reason rather than by construction. Sizing an assertion by mutating the thing it guards is governed by the verify protocol's `Mutation and the Working Copy`, stated there and only there — do not reproduce its obligations here.
8. **Freeze the contracts**: write the baseline manifest to `artifacts/T-XXX/conformance-baseline/manifest.md`, whose fields are stated at `### The frozen row` below and nowhere else.
9. **Proceed to Execute** — the goal is now "make these rows green".

### The free mutation, and the condition it rides on

The red→green pair **discharges a row's mutation only where the task's diff touches nothing but the row's named subject.** Otherwise the pair shows the row discriminates between two tree states, and the diff between them carries everything else that changed — so a targeted mutation is still owed.

The condition is a **comparison and not the author's judgement of their own row**: the manifest names the subject, git names the diff, and both sides are already there to be read.

**The window is the task and not the step that owns the row**, and the reason is the same one that governs the exemption in the Execute protocol: a step boundary is a claim a plan makes about itself and can be redrawn by the actor the condition is meant to constrain, while a task boundary is a fact the record already holds. The wider window is also the safe direction — a broader diff is harder to touch nothing but the subject within, so the change can only reduce free discharges, never manufacture one.

**The verdict is not frozen at Conform.** Its evidence is the task's diff, which does not exist yet; what Conform freezes is the **condition**, and the verdict is recorded when it can be determined. Which of the fields below is frozen and which is completed later is marked in the table itself.

### The frozen row

One row per emitted stub, and one per recorded absence. A **manifest**, not a copy of the spec files: the stub *body* is free to change during Execute, while the fields below are the frozen contract (see Execute protocol > Conformance Contracts Exception).

**Two lifecycles, marked per field.** *Frozen at Conform* is the contract: it exists before step 1 and the audit refuses it changed without a written decision. *Completed at the close* is a field whose evidence does not exist at Conform — recorded when it can be determined, and therefore **not** divergence when it appears. A field of the second kind frozen as if it were the first freezes a guess, and the audit then demands a decision entry for the row simply doing what it was told.

| Field | Lifecycle | What it holds |
|---|---|---|
| spec file | frozen at Conform | where the stub lives |
| `it()` description | frozen at Conform | maps 1:1 to the criterion text |
| source criterion | frozen at Conform | the criterion the row was emitted from, with its `observed:` |
| assert direction | frozen at Conform | what must grow, shrink or equal what |
| falsifier | frozen at Conform | the criterion's `falsified-by:`, carried verbatim |
| free-mutation condition | frozen at Conform | the row's named subject, against which the task's diff is compared |
| kind disagreement | frozen at Conform | the author's declared bucket where it differs from the falsifier-derived kind, or *none* |
| authorship mutation run | frozen at Conform | for a row that cannot be born red: what was mutated, what the suite reported, and that it was reverted |
| cause | frozen at Conform | for a recorded absence: `inspection`, `gap` or `covered` — why this criterion emitted no row |
| free-mutation verdict | **completed at the close** | discharged by the pair, or a targeted mutation still owed |

**A recorded absence is a row of the same table** — it fills the fields above that apply to it and leaves the rest empty, and this sentence names none of them, because naming them here would be the shorter list the next paragraph forbids. A manifest that is mostly recorded absences is this rule working, not this rule failing.

**A row appended after the freeze is appended under its own section, and is not divergence.** A leg authored during the task's life rather than at Conform — the repair legs the Verify protocol governs at `### The acceptance rule for a repair leg` are the case that exists — is recorded here by adding a section, never by amending a frozen row. The audit compares the rows the freeze already holds; a section that was not there to be frozen is not one of them, so an append weakens no contract and needs no decision entry to excuse it.

**This section is the field list's one home.** Anything that needs the list cites this table rather than restating it — including anything that needs only the *frozen* subset, which is this table's Lifecycle column and not a shorter list kept elsewhere.

### What this enables

- Execute becomes **goal-directed**: the agent knows it's done when all conformance rows are green
- Verify phase has **concrete test evidence** for every criterion that could carry any
- Reduces need for human supervision during Execute — tests are the arbiter

### When to skip

- Quick path tasks (no understand.md, no conformance tests)
- Tasks whose every criterion is `observed: read` (pure prose, config or style changes) — the absences are still recorded
- When existing tests already cover the criteria (note this in plan.md instead of creating duplicates) — this is a non-emitting path like the others, and its rows are recorded with the cause **covered**

### Template for conformance test stubs

```typescript
// Conformance: [what this suite guarantees, in behavior terms]

describe('[Feature/Component]', () => {
  // Criterion: [text from understand.md]
  it('should [criterion as test description]', () => {
    // GIVEN: [setup]
    const subject = [the thing the criterion is about];
    // WHEN: [action]
    const actual = [observe it];
    // THEN: [expected result]
    expect(actual).toBe([what the criterion says it must be]);
  });
});
```

The assertion is the real one before Execute has written a line, so it is red because the subject does not yet satisfy it — never because the body was built to fail.

No task IDs in headers, test names, or comments — the criterion text is the self-contained reference (see Execute protocol > Code Comments & Provenance).

## Constraints

- **Max 3 steps per plan** — if more are needed, the task should be split into smaller tasks
- Each step should be independently verifiable (tests pass after each step, not just at the end)
- **Vertical slices over horizontal layers** — prefer steps that cut through all of the project's layers to deliver one observable behavior end-to-end, rather than steps that build a single layer in isolation. A wrong assumption surfaces at the first slice, not after the UI step. Only split by layer when a slice genuinely exceeds the diff guardrail.
- **Risk-first ordering** — order the steps so the assumption most likely to break is tested first, subject to the dependencies between them, so the Replan Gate fires before the work is written rather than after. This orders the slices and does not displace the shape rule above it: a plan slices vertically, then orders by risk.
