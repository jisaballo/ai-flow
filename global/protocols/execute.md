# Execute Phase Protocol

**Which task, and whether this phase may run on it**: the phase runs on the task this checkout owns.
Resolve it by the ladder in the backlog protocol (`## State Files` → `### Resolving the task`) — stated
there and only there — and stop rather than choose if it ends without one. Then test the phase
precondition (same document, `### The phase precondition`), stated there and only there too, so this
document names no accepted position and no leg of its own.

A manual run performs the check; the command is a convenience over this procedure, never its only
carrier — the same standing this phase's three siblings give theirs.

## Model Delegation

The orchestrator decides the strategy for each step, silently and without approval — the plan was
already approved. When it delegates it says so, and if the agent fails it retakes the step inline
without asking.

**Inline is the default. Delegate a step only where it is fully self-contained and mechanical** — the
change is specified in the plan with no ambiguity, it needs no design judgment, and nothing the
orchestrator learned inside this phase's own sitting bears on it. That last clause is the inline
criterion, and it is not "what the papers hold": a delegated agent receives them, so naming them
discriminates nothing. It names what the papers do not carry and no session boundary destroys — a
correction the operator gave during this phase, a diagnosis still open from an earlier step of it.
Prior conversation is not a criterion: the chain cuts the session at Understand's close and at this
phase's, so a rule resting on it decides by what has already been thrown away.

A delegated agent receives CLAUDE.md, this protocol, the task's own sheet (`artifacts/T-XXX/state.md`),
understand.md, plan.md, and the step to execute.

## Skills per Step — Lazy Load

Before executing a step, invoke each skill declared in its plan `Skills:` line, if not already loaded this session. Lazy, per step — do NOT preload every declared skill upfront. If a step turns out to need a skill that was not declared, load it and write the miss to the task's sheet (`artifacts/T-XXX/state.md`), which is where Verify asks for it.

## Steering Files

Before executing, re-read the sections the `steering:` map's affected entries name — **by the cuts `protocols/context.md` defines**, which owns what is loaded and how; `.ai-flow/steering/{domain}.md` is the convention, not the only place an entry may point. The step's `Files` are what make an entry affected.

## Code Comments & Provenance

Comments must stand alone. A comment states the constraint, evidence, or rationale the code cannot show — in full, in place. Forbidden in committed source (comments, test names, `describe`/`it` descriptions): task/epic IDs (`T-XXX`, `E-XXX`) and paths into `artifacts/` or `.ai-flow/`. If the rationale is too long for a comment, it goes in the commit message body. Line->task provenance is `git blame` -> commit message `(T-XXX)` — never the comment.

Existing committed references stay untouched. Verify enforces the rule over the added lines of the task diff, whose reach is defined once in Verify protocol > The Task Diff and named nowhere else. That reach is the diff's and not the task's: a trunk's unpublished commits are inside it until they are published, which drops them below the base.

## Test-Driven Development (TDD)

**CRITICAL: Execute phase MUST validate tests.**

Where the task's level is **Auto**, a bug fix writes the reproducing test before the fix and that
failure is the evidence — the plan is inline at that level, so no criteria are minted and no stub is
frozen, and nothing else in its chain produces a red step. A mechanical refactor at the same level has
nothing to reproduce.

### Execute Step Protocol

For each step:
1. **Read** source files to change
2. **Make** code changes
3. **Run the Verify command from the plan step** — every step of a plan *artifact* carries one. Where the plan was inline and there is no artifact (**Auto**, the quick path), run the test file the change touches.
   - **No reassurance re-runs**: do not run a command again over code unchanged since that command
     last ran — a repeat that cannot change its own answer is a turn spent buying confidence — while the
     audit's re-run of every step's Verify command (Verify protocol > Re-run all Verify commands) is not
     this rule's subject, since it re-asks a question a later step may have changed the answer to.
   - If tests fail -> Intentional change? Fix test. Unexpected? Fix code. (Conformance specs are the exception — see below.)
   - **Bounded Retry**: Max 3 fix attempts for the same test/error. After 3 failures, STOP and escalate to user with: what was tried, what failed, what the likely root cause is. Do not continue iterating blindly.
   - All tests MUST pass before proceeding
4. **Commit the step.** A step whose Verify command passes is committed where it stands, and the commit
   seeks no approval of its own — the approval for the task's work is given once, at move 1 of the closing
   ceremony (backlog protocol), which owns the gate and states why it sits there. Where the task's level
   sets a gate between steps — **Supervised**, whose criteria stay in `protocols/lifecycle.md`'s autonomy
   table, which owns the levels — that gate is untouched by the commit: it governs whether the next step
   begins, never whether this one is committed, and what it obliges is item 5 below. Two rules ride on
   this commit and are the loop's own. A step with no test file documents that in its commit and the
   missing test is written later:
   - **Atomic**: `type(scope): description`, with the `Co-Authored-By` line. One step, one commit.
   - **Green**: the commit must pass tests. Step 3 above is what proves it, and a step that cannot get
     there is escalated by its own Bounded Retry rather than committed red.
5. **Between steps.** Where the task's sheet declares **Supervised**, show the diff of the step just
   finished and wait for the operator before the next step begins. **This is the gate's one home** — the
   level table states which tasks earn the level and states none of this, and no command may restate it.
   At every other level the loop goes straight back to 1.

### Conformance Contracts Exception

Stubs recorded in `artifacts/T-XXX/conformance-baseline/manifest.md` are **frozen contracts** — "intentional -> fix test" does NOT apply to them. During Execute it is forbidden to:

- delete or rename a contract stub,
- invert or weaken its assertion,
- adjust its expected value to match the observed one,
- **switch it off** — skipped, disabled, ignored, or left unreached because a sibling was focused. The
  audit at the end of the phase greps the task diff for it (Verify protocol > Skip-marker grep), so a stub
  switched off here is reported there.

A stub that is **objectively wrong** (bad assumption, impossible setup, criterion itself invalidated) = **Replan Gate**, not a test fix — stop, report, update plan + understand.md, and the manifest with it. In **Auto** level, needing to touch any contract escalates the task to Guided. Non-conformance specs keep the normal fix-test rule.

## Replan Gate

**If during execution a plan assumption is invalidated** (API returns different format, service works differently than expected, model lacks expected field), **STOP execution and replan.** Do not hack around broken assumptions.

Steps:
1. STOP current step execution
2. Report to user: what assumption broke, what was discovered
3. **Amend** `artifacts/T-XXX/plan.md` with the corrected approach — amend it, never replace it, and
   `artifact-write-guard.py` carries no exemption for a replan. Update `understand.md` and the
   conformance manifest the same way
4. Resume execution from the affected step

This applies to factual/technical assumptions — not minor implementation details that can be adjusted inline.

## Diff Size Guardrail

Two ceilings and one note. The two **ceilings** count **added lines** only. The **note** is the exception
and keeps net growth: it asks whether the change *grew* the file, and the number it reports is the file's
own line count rather than any diff total. All three ignore test suites, everything under the repository's
own `.ai-flow/`, and dependency lockfiles (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`,
`Cargo.lock`, `poetry.lock`, `Gemfile.lock`).

- **Step** — uncommitted work **>150 added lines**.
- **Task** — **>400 added lines** on this branch since its base (commits included). Committing does not
  lower this one. Where that base is a remote-tracking ref the measure is the branch's distance from what
  the remote has, and the report names it as work not yet published.
- **File** — a touched file the change has **grown** past **1,000 lines** (`large_file_lines` in
  `project.yml` overrides it). A note, not a ceiling: it reports and never pauses — but ten small diffs
  build this shape with both ceilings green, so the file is named once, with the ask: decompose before
  adding.

On either ceiling, pause and evaluate:
- Is this necessary or am I over-engineering?
- Does the plan need revision?

Report to user before continuing. When no base branch can be resolved (no remote default, no local `main`/`master`), the task ceiling has nothing to measure against
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

**When to skip**: Quick path tasks (no understand.md exists).

## The close of Execute

**After Spec Sync, the phase closes**: advance the sheet to the position Verify will declare, end with the
fixed line, and end the turn. This is the second of the chain's two cut points (`lifecycle.md` >
`## Sessions`); what that line carries, and what else the close owes, is stated in the backlog protocol's
`### The phase precondition` and only there — route to it, never restate it.

It hangs on the close of the phase and **not** on Spec Sync, whose conformant behaviour where there are
no divergences is to skip and say nothing (step 3 above).

## Deviation Rules During Execution

The two tiers that govern doing the work are stated here, in the phase that does it. The **hard stops**
are CLAUDE.md's, at `### Never (hard stops)`, where each is routed to the mechanism that performs it,
or says that none exists.

### Always (do without asking)
- Fix broken imports, null pointers, type mismatches
- Add error handling, null checks, validation where the flow can reach the failure — not for impossible
  scenarios (CLAUDE.md > Core Principles, Simplicity First)
- Fix missing deps, build config issues
- The step's test discipline is the loop's own, at `### Execute Step Protocol` item 3

### Ask First (need user approval)
- New services, components, or modules
- Schema changes (models, database, APIs)
- Library additions or swaps
- Changes to >3 files not in the plan
- Architectural decisions (new patterns, state shape)

**New work discovered along the way** (not in the task or plan) -> **Discovery Triage** (see Understanding protocol): blocks this task -> Replan Gate; contradicts the epic's Goal/Non-Goals -> escalate to user; everything else -> the routing test, ownership asked first — a finding in a file already inside this task's diff is the task's to fix now, a finding whose failure cannot occur is discarded with the reason written under `## Discarded` in `artifacts/T-XXX/discoveries.md`, and whatever survives is staged in that same file with its ground stamp — then continue the plan. Never create new T-XXX tasks mid-epic, and nothing reaches BACKLOG.md while the task is in flight.
