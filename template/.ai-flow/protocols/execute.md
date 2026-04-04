# Execute Phase Protocol

## Model Delegation

The orchestrator (main model running the session) decides execution strategy per step. No rigid rules — holistic assessment.

### Inline Execution (orchestrator handles directly)

Default for most work. Use when:
- Step requires conversation context or recent decisions
- Complex logic requiring strong reasoning
- Orchestrator already has relevant files loaded
- Debugging or unexpected issues arise

### Agent Delegation (Task tool with lighter model)

Use when the step is **fully self-contained** and **mechanical**:
- Rename/refactor across files (find X, replace with Y)
- Add a field to a model and propagate to related files
- Update imports, selectors, or constants
- Changes fully specified in the plan with zero ambiguity

The agent receives: CLAUDE.md, STATE.md, understand.md, plan.md, execute.md (this protocol), and the specific step to execute.

### How It Works

- **No complexity analysis step** — the orchestrator decides silently per step
- **No approval of model choice** — the plan was already approved
- **Transparent in output** — when delegating, mention it: "Delegating step 1 to agent (mechanical change)"
- **Automatic fallback** — if an agent fails, the orchestrator retakes inline without asking

### What Determines the Choice

| Factor | Inline | Delegate |
|--------|--------|----------|
| Reasoning required | Design decisions, new logic, debugging | None — purely mechanical |
| Context dependency | Needs prior conversation context | Self-contained from plan alone |
| Risk of misunderstanding | Any ambiguity in the step | Zero ambiguity, fully specified |
| File familiarity | Orchestrator already read the files | Fresh read is fine |

## Steering Files

Before executing, re-read the steering file(s) for the affected domain(s) from `.ai-flow/steering/{domain}.md`. These contain domain-specific rules and pitfalls that act as guardrails during implementation.

## Test-Driven Development (TDD)

**CRITICAL: Execute phase MUST validate tests.**

### Execute Step Protocol

For each step:
1. **Read** source files to change
2. **Make** code changes
3. **Run the Verify command from the plan step** — every plan step has a `Verify` field with a copy-pasteable test command
   - If no Verify command in plan (shouldn't happen): run relevant test file
   - If test file missing: Document in commit (create tests later)
   - If tests fail: Intentional change? Fix test. Unexpected? Fix code.
   - **Bounded Retry**: Max 3 fix attempts for the same test/error. After 3 failures, STOP and escalate to user with: what was tried, what failed, what the likely root cause is. Do not continue iterating blindly.
   - All tests MUST pass before proceeding
4. **Stage changes** (do NOT commit — follow Commit Protocol from CLAUDE.md. User must validate first.)

## Replan Gate

**If during execution a plan assumption is invalidated** (API returns different format, service works differently than expected, model lacks expected field), **STOP execution and replan.** Do not hack around broken assumptions.

Steps:
1. STOP current step execution
2. Report to user: what assumption broke, what was discovered
3. Update `artifacts/T-XXX/plan.md` with corrected approach (this is an authorized overwrite — Artifact Check does not apply to replans)
4. Resume execution from the affected step

This applies to factual/technical assumptions — not minor implementation details that can be adjusted inline.

## Diff Size Guardrail

If a single step generates a diff **>150 lines** (excluding test files), pause and evaluate:
- Is this necessary or am I over-engineering?
- Does the plan need revision?

Report to user before continuing. This prevents silent runaway changes.

## Post-Execute: Spec Sync

**After all steps complete and before Verify phase**, review the diff against `artifacts/T-XXX/understand.md`:

1. **Compare** implementation decisions against the spec (approach, edge cases, API shape, data flow)
2. **If divergences exist** (different approach than planned, new edge cases discovered, API shape changed):
   - Append `## Implementation Decisions` section to understand.md
   - List each divergence with rationale:
     ```markdown
     ## Implementation Decisions
     - **[Topic]**: Spec said X, implemented Y because [reason]
     - **[Topic]**: New edge case discovered — [description and how it's handled]
     ```
3. **If no divergences**: Skip — don't add noise to the artifact
4. **Update conformance tests** if any criteria changed (add/modify stubs for new edge cases)

This keeps understand.md as the accurate source of truth for the Verify phase and preserves context across sessions/compaction.

**When to skip**: Quick path tasks (no understand.md exists).

## Deviation Rules During Execution

Follow **Action Boundaries** from CLAUDE.md (Always / Ask First / Never). In summary:
- Auto-fix bugs, imports, deps, type mismatches -> **Always**
- New services, schema changes, lib swaps, >3 unplanned files -> **Ask First**
- Skip tests, commit secrets, force push -> **Never**
