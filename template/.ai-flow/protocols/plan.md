# Plan Phase Protocol

## Plan Template (Structured Verify)

**CRITICAL:** Every step in plan.md MUST include a `Verify` command and `Done` criteria. This is mandatory, not optional.

Write `artifacts/T-XXX/plan.md` with:
```markdown
# Plan: [Task ID] - [Task Title]

## Step 1: [Action-oriented title]
- **Files:** `path/to/file1.ts`, `path/to/file2.ts`
- **Changes:** [Specific description of what to change and why]
- **Verify:** `[test or build command]`
- **Done:** [Measurable acceptance state — not "it works", but what specifically passes]

## Step 2: [Action-oriented title]
- **Files:** `path/to/file3.ts`
- **Changes:** [Specific description]
- **Verify:** `[test or lint command]`
- **Done:** [Measurable acceptance state]

## Step 3: [Action-oriented title]
- **Files:** `path/to/file4.ts`
- **Changes:** [Specific description]
- **Verify:** `[test command]`
- **Done:** [Measurable acceptance state]
```

## Verify vs Done

- **Verify** = a command to run (technical check, must be copy-pasteable)
- **Done** = the expected outcome state (what "passing" looks like)

Both are required per step. If no test file exists for a step, Verify should be a build command (at minimum, it compiles).

The test command comes from `commands.test` in `.ai-flow/project.yml` (interpolate the `{area}` placeholder with the area the step touches); if `project.yml` is absent, infer it from CLAUDE.md.

## Conformance Tests (Post-Plan, Pre-Execute)

**After the plan is approved and before Execute begins**, generate conformance test stubs from the Verifiable Criteria in understand.md.

### How it works

1. **Read** the Verifiable Criteria from `artifacts/T-XXX/understand.md`
2. **For each Automated criterion**: Create a failing test stub in the target spec file
   - Use `it.todo('...')` or a minimal `it('...', () => { expect(true).toBe(false); })` that clearly fails
   - Test description maps 1:1 to the criterion text
3. **For each Behavioral criterion (GIVEN/WHEN/THEN)**: Create a failing test that sets up the GIVEN, triggers the WHEN, and asserts the THEN
4. **Observable criteria** don't generate tests (they're verified by code inspection in Verify phase)
5. **Run the test suite** — all new stubs MUST fail (red phase of TDD)
6. **Proceed to Execute** — the goal is now "make these tests pass"

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
// Conformance tests for T-XXX: [Task Title]
// Generated from understand.md Verifiable Criteria

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

## Constraints

- **Max 3 steps per plan** — if more are needed, the task should be split into smaller tasks
- Each step should be independently verifiable (tests pass after each step, not just at the end)
