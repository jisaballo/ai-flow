# Plan Phase Protocol

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
     Status: (confirmed) = user settled it in Understand; (proposed) = needs their eyes at this gate. -->
- **D1** (proposed): [decision] — consequence: [what it means for the product]. Recommended: [option].
- **D2** (confirmed in Understand): [decision] — consequence: [...].

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
| [EARS criterion / Observable] | Step N | `[spec file] > [it() description]` — or "— (inspection)" |
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

1. **Read** the Verifiable Criteria from `artifacts/T-XXX/understand.md` — they arrive in EARS format (see Understand protocol). GIVEN/WHEN/THEN is the **test format**: each EARS criterion becomes one or more GWT stubs.
2. **For each Automated criterion**: Create a failing test stub in the target spec file
   - Use `it.todo('...')` or a minimal `it('...', () => { expect(true).toBe(false); })` that clearly fails
   - Test description maps 1:1 to the criterion text
3. **For each Behavioral criterion**: Create a failing test that sets up the GIVEN (the EARS state/context), triggers the WHEN, and asserts the THEN (the EARS response)
4. **Observable criteria** don't generate tests (they're verified by code inspection in Verify phase)
5. **Run the test suite** — all new stubs MUST fail (red phase of TDD)
6. **Freeze the contracts**: write the baseline manifest to `artifacts/T-XXX/conformance-baseline/manifest.md` — one row per stub: spec file, `it()` description, source criterion, assert direction (what must grow/shrink/equal what). A **manifest**, not a copy of the spec files: the stub *body* is free to change during Execute; the manifest rows are the frozen contract (see Execute protocol > Conformance Contracts Exception).
7. **Proceed to Execute** — the goal is now "make these tests pass"

### What this enables

- Execute becomes **goal-directed**: the agent knows it's done when all conformance tests pass
- Verify phase has **concrete test evidence** for every criterion
- Reduces need for human supervision during Execute — tests are the arbiter

### When to skip

- Quick path tasks (no understand.md, no conformance tests)
- Tasks with no Automated or Behavioral criteria (pure config/style changes)
- When existing tests already cover the criteria (note this in plan.md instead of creating duplicates)

### Template for conformance test stubs

```typescript
// Conformance: [what this suite guarantees, in behavior terms]

describe('[Feature/Component]', () => {
  // Criterion 1: [text from understand.md]
  it('should [criterion as test description]', () => {
    // GIVEN: [setup]
    // WHEN: [action]
    // THEN: [expected result]
    expect(true).toBe(false); // RED — implement in Execute
  });

  // Criterion 2: [text from understand.md]
  it('should [criterion as test description]', () => {
    expect(true).toBe(false); // RED — implement in Execute
  });
});
```

No task IDs in headers, test names, or comments — the criterion text is the self-contained reference (see Execute protocol > Code Comments & Provenance).

## Constraints

- **Max 3 steps per plan** — if more are needed, the task should be split into smaller tasks
- Each step should be independently verifiable (tests pass after each step, not just at the end)
- **Vertical slices over horizontal layers** — prefer steps that cut through all of the project's layers to deliver one observable behavior end-to-end, rather than steps that build a single layer in isolation. A wrong assumption surfaces at the first slice, not after the UI step. Only split by layer when a slice genuinely exceeds the diff guardrail.
