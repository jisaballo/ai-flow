# Execute Phase Protocol

## Model Delegation

The orchestrator (main model running the session) decides execution strategy per step. No rigid rules — holistic assessment.

### Inline Execution (orchestrator handles directly)

Default for most work. Use when:
- Step requires conversation context or recent decisions
- Complex logic requiring strong reasoning
- Orchestrator already has relevant files loaded
- Debugging or unexpected issues arise

### Agent Delegation (Task tool with a lighter model)

Use when the step is **fully self-contained** and **mechanical**:
- Rename/refactor across files (find X, replace with Y)
- Add a field to a model and propagate to related files
- Update imports, selectors, or constants
- Changes fully specified in the plan with zero ambiguity

The agent receives: CLAUDE.md, the task's state sheet (`artifacts/T-XXX/state.md`), understand.md, plan.md, execute.md (this protocol), and the specific step to execute.

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

## Skills per Step — Lazy Load

Before executing a step, invoke each skill declared in its plan `Skills:` line, if not already loaded this session. Lazy, per step — do NOT preload every declared skill upfront: irrelevant guidance dilutes the relevant one. If a step turns out to need a skill that was not declared, load it and note the miss for Verify.

## Steering Files

Before executing, re-read the steering file(s) for the affected domain(s) from `.ai-flow/steering/{domain}.md`. These contain domain-specific rules and pitfalls that act as guardrails during implementation.

## Code Comments & Provenance

Comments must stand alone. A comment states the constraint, evidence, or rationale the code cannot show — in full, in place. Forbidden in committed source (comments, test names, `describe`/`it` descriptions): task/epic IDs (`T-XXX`, `E-XXX`) and paths into `artifacts/` or `.ai-flow/`. If the rationale is too long for a comment, it goes in the commit message body. Line->task provenance is `git blame` -> commit message `(T-XXX)` — never the comment.

Existing committed references stay untouched — a mass cleanup would rewrite the blame that now serves as the line->task index. Verify enforces the rule over the added lines of the task diff, whose reach is defined once in Verify protocol > The Task Diff and named nowhere else. What matters to the author: that reach is the diff's, not the task's — a trunk's unpublished commits are inside it until publishing drops them below the base — which is why the audit names the trunk's lag before it judges anything.

## Test-Driven Development (TDD)

**CRITICAL: Execute phase MUST validate tests.**

### Execute Step Protocol

For each step:
1. **Read** source files to change
2. **Make** code changes
3. **Run the Verify command from the plan step** — every plan step has a `Verify` field with a copy-pasteable test command
   - If no Verify command in plan (shouldn't happen): run relevant test file
   - If test file missing -> Document in commit (create tests later)
   - If tests fail -> Intentional change? Fix test. Unexpected? Fix code. (Conformance specs are the exception — see below.)
   - **Bounded Retry**: Max 3 fix attempts for the same test/error. After 3 failures, STOP and escalate to user with: what was tried, what failed, what the likely root cause is. Do not continue iterating blindly.
   - All tests MUST pass before proceeding
4. **Stage changes** (do NOT commit — follow Commit Protocol from CLAUDE.md. User must validate first.)

### Conformance Contracts Exception

Stubs recorded in `artifacts/T-XXX/conformance-baseline/manifest.md` are **frozen contracts** — "intentional -> fix test" does NOT apply to them. During Execute it is forbidden to:

- delete or rename a contract stub,
- invert or weaken its assertion,
- adjust its expected value to match the observed one.

A stub that is **objectively wrong** (bad assumption, impossible setup, criterion itself invalidated) = **Replan Gate**, not a test fix — stop, report, update plan + understand.md, and the manifest with it. In **Auto** level, needing to touch any contract escalates the task to Guided. Non-conformance specs keep the normal fix-test rule.

## Replan Gate

**If during execution a plan assumption is invalidated** (API returns different format, service works differently than expected, model lacks expected field), **STOP execution and replan.** Do not hack around broken assumptions.

Steps:
1. STOP current step execution
2. Report to user: what assumption broke, what was discovered
3. Update `artifacts/T-XXX/plan.md` with corrected approach (this is an authorized overwrite — Artifact Check does not apply to replans)
4. Resume execution from the affected step

This applies to factual/technical assumptions — not minor implementation details that can be adjusted inline.

## Diff Size Guardrail

Two ceilings, both excluding test files:

- **Step** — uncommitted work **>150 lines**. The step you are in has grown past one reviewable unit.
- **Task** — **>400 lines** on this branch since its base (commits included). Committing does not lower
  this one: it exists because free commits on a branch would otherwise let a task grow without a ceiling.

On either, pause and evaluate:
- Is this necessary or am I over-engineering?
- Does the plan need revision?

Report to user before continuing. This prevents silent runaway changes. When no base branch can be
resolved (no remote default, no local `main`/`master`), the task ceiling has nothing to measure against
and the step ceiling stands alone.

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
4. **Update conformance tests** if any criteria changed (add/modify stubs for new edge cases). Modifying a **frozen contract** (a row in `conformance-baseline/manifest.md`) is allowed here ONLY with a matching `## Implementation Decisions` entry documenting why — no entry, no contract change. Update the manifest in the same edit.

This keeps understand.md as the accurate source of truth for the Verify phase and preserves context across sessions/compaction.

**When to skip**: Quick path tasks (no understand.md exists).

## The close of Execute

**After Spec Sync, the phase closes**: advance the sheet to the position Verify will declare, and where this
sitting has grown costly, announce the cut and end the turn. This is the second of the chain's two cut points
(`lifecycle.md` > `## Sessions`); what the close writes, announces, and when it stays silent is stated in the
backlog protocol's `### The phase precondition` and only there — route to it, never restate it.

It hangs on the close of the phase and **not** on Spec Sync. Spec Sync's own conformant behaviour where there
are no divergences is to skip and say nothing (step 3 above), so a close riding it would be indistinguishable
from a close that was forgotten — and in the incident that produced this rule, no Spec Sync was visible in
the sitting where Execute ended.

## Deviation Rules During Execution

Follow **Action Boundaries** from CLAUDE.md (Always / Ask First / Never). In summary:
- Auto-fix bugs, imports, deps, type mismatches -> **Always**
- New services, schema changes, lib swaps, >3 unplanned files -> **Ask First**
- Skip tests, commit secrets, force push -> **Never**

**New work discovered along the way** (not in the task or plan) -> **Discovery Triage** (see Understanding protocol): blocks this task -> Replan Gate; contradicts the epic's Goal/Non-Goals -> escalate to user; everything else -> one line in BACKLOG.md `## Icebox`, then continue the plan. Never create new T-XXX tasks mid-epic.
