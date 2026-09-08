# Execute Phase Protocol

**Which task, and whether this phase may run on it**: the phase runs on the task this checkout owns.
Resolve it by the ladder in the backlog protocol (`## State Files` → `### Resolving the task`) — stated
there and only there — and stop rather than choose if it ends without one. Then test the phase
precondition (same document, `### The phase precondition`), stated there and only there too, so this
document names no accepted position and no leg of its own.

A manual run performs the check; the command is a convenience over this procedure, never its only
carrier — the same standing this phase's three siblings give theirs. Stated at the head rather than left
to the close below, because a phase given a position it accepts and papers it insists on, with nothing at
its entry that reads them, has a rule and no reader: the row would be satisfied by the document that
declares it and performed by nobody.

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

Before executing a step, invoke each skill declared in its plan `Skills:` line, if not already loaded this session. Lazy, per step — do NOT preload every declared skill upfront: irrelevant guidance dilutes the relevant one. If a step turns out to need a skill that was not declared, load it and write the miss to the task's sheet (`artifacts/T-XXX/state.md`), which is where Verify asks for it: the conversation that held it does not survive the close's cut, and the sheet is the one thing this loop already writes to.

## Steering Files

Before executing, re-read what the `steering:` map names for the affected domain(s) — **the map's value, whatever path it names**, on the terms the Understand protocol's `## Steering Files` owns and states; `.ai-flow/steering/{domain}.md` is the convention, not the only place an entry may point. These contain domain-specific rules and pitfalls that act as guardrails during implementation.

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
   - **No reassurance re-runs**: do not run a command again over code unchanged since that command
     last ran — a repeat that cannot change its own answer is a turn spent buying confidence — while the
     audit's re-run of every step's Verify command (Verify protocol, step 7) is not this rule's subject,
     since it re-asks a question a later step may have changed the answer to
   - If no Verify command in plan (shouldn't happen): run relevant test file
   - If test file missing -> Document in commit (create tests later)
   - If tests fail -> Intentional change? Fix test. Unexpected? Fix code. (Conformance specs are the exception — see below.)
   - **Bounded Retry**: Max 3 fix attempts for the same test/error. After 3 failures, STOP and escalate to user with: what was tried, what failed, what the likely root cause is. Do not continue iterating blindly.
   - All tests MUST pass before proceeding
4. **Commit the step.** A step whose Verify command passes is committed where it stands, and the commit
   seeks no approval of its own — the approval for the task's work is given once, at move 1 of the closing
   ceremony (backlog protocol), which owns the gate and states why it sits there. Where the task's level
   sets a gate between steps — **Supervised**, whose criteria stay in `protocols/lifecycle.md`'s autonomy
   table, which owns the levels — that gate is untouched by the commit: it governs whether the next step
   begins, never whether this one is committed, and what it obliges is item 5 below. The
   two are one stop only while the commit is withheld for approval, which is what this step retires; the
   distinction is stated because a clause wide enough to free the commit is wide enough to cancel a rule
   this loop does not own. Two rules ride on this commit and are the loop's own:
   - **Atomic**: `type(scope): description`, with the `Co-Authored-By` line. One step, one commit.
   - **Green**: the commit must pass tests. Step 3 above is what proves it, and a step that cannot get
     there is escalated by its own Bounded Retry rather than committed red.
5. **Between steps.** Where the task's sheet declares **Supervised**, show the diff of the step just
   finished and wait for the operator before the next step begins. **This is the gate's one home** — the
   level table states which tasks earn the level and states none of this, and no command may restate it:
   a phase command is one of this rulebook's four readers, so a copy kept there is a copy three of them
   cannot see and all four can drift against. An item of the loop rather than a clause of the commit
   above, because it shares no precondition with committing — it fires on the level, after the commit, at
   the boundary — and a reader asking what happens *between* steps does not look under "Commit the step".
   At every other level the loop goes straight back to 1.

### Conformance Contracts Exception

Stubs recorded in `artifacts/T-XXX/conformance-baseline/manifest.md` are **frozen contracts** — "intentional -> fix test" does NOT apply to them. During Execute it is forbidden to:

- delete or rename a contract stub,
- invert or weaken its assertion,
- adjust its expected value to match the observed one,
- **switch it off** — skipped, disabled, ignored, or left unreached because a sibling was focused. The
  three above all change what a stub asserts; this one changes nothing about it and simply stops it
  running, which is why the list did not name it and why it is the shape that survives a reading of the
  other three. It is also the one the audit at the end of the phase now greps the task diff for
  (Verify protocol > Skip-marker grep), so a stub switched off here is reported there — the rule and the
  mechanism, rather than the rule alone.

A stub that is **objectively wrong** (bad assumption, impossible setup, criterion itself invalidated) = **Replan Gate**, not a test fix — stop, report, update plan + understand.md, and the manifest with it. In **Auto** level, needing to touch any contract escalates the task to Guided. Non-conformance specs keep the normal fix-test rule.

## Replan Gate

**If during execution a plan assumption is invalidated** (API returns different format, service works differently than expected, model lacks expected field), **STOP execution and replan.** Do not hack around broken assumptions.

Steps:
1. STOP current step execution
2. Report to user: what assumption broke, what was discovered
3. **Amend** `artifacts/T-XXX/plan.md` with the corrected approach — amend it, never replace it. A
   replan is the one place this engine used to sanction a wholesale rewrite, and it never needed one:
   what a replan changes is a step and the assumption under it, which is an edit. `Artifact Check Before
   Create` therefore has no exemption to make here, and `artifact-write-guard.py` carries none — a rail
   the model can open by declaring the exception protects nothing. Update `understand.md` and the
   conformance manifest the same way
4. Resume execution from the affected step

This applies to factual/technical assumptions — not minor implementation details that can be adjusted inline.

## Diff Size Guardrail

Two ceilings and one note. The two **ceilings** count **added lines** only — deletions are cheap to
review and the direction to reward. The **note** is the exception and keeps net growth: it asks whether
the change *grew* the file, so one the change trims draws nothing, and the number it reports is the
file's own line count rather than any diff total. All three ignore test suites, everything under the repository's own
`.ai-flow/`, and dependency lockfiles (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Cargo.lock`,
`poetry.lock`, `Gemfile.lock`). None of the three is code somebody wrote.

- **Step** — uncommitted work **>150 added lines**. The step you are in has grown past one reviewable unit.
- **Task** — **>400 added lines** on this branch since its base (commits included). Committing does not
  lower this one: it exists because free commits on a branch would otherwise let a task grow without a
  ceiling. Where that base is a remote-tracking ref the measure is the branch's distance from what the
  remote has, so the report names it as work not yet published and leaves the reading to you: one task
  grown large, or several already finished.
- **File** — a touched file the change has **grown** past **1,000 lines** (`large_file_lines` in
  `project.yml` overrides it). This one is a note, not a ceiling: it reports and never pauses, because a
  legitimately large file must not be blocked by a heuristic — but ten small diffs build exactly this
  shape with both ceilings green, so the file is named once, with the ask: decompose before adding.

On either ceiling, pause and evaluate:
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

**After Spec Sync, the phase closes**: advance the sheet to the position Verify will declare, end with the
fixed line, and end the turn. This is the second of the chain's two cut points (`lifecycle.md` >
`## Sessions`); what that line carries, and what else the close owes, is stated in the backlog protocol's
`### The phase precondition` and only there — route to it, never restate it.

It hangs on the close of the phase and **not** on Spec Sync. Spec Sync's own conformant behaviour where there
are no divergences is to skip and say nothing (step 3 above), so a close riding it would be indistinguishable
from a close that was forgotten — and in the incident that produced this rule, no Spec Sync was visible in
the sitting where Execute ended.

## Deviation Rules During Execution

Follow **Action Boundaries** from CLAUDE.md (Always / Ask First / Never). In summary:
- Auto-fix bugs, imports, deps, type mismatches -> **Always**
- New services, schema changes, lib swaps, >3 unplanned files -> **Ask First**
- Skip tests, commit secrets, force push -> **Never**

**New work discovered along the way** (not in the task or plan) -> **Discovery Triage** (see Understanding protocol): blocks this task -> Replan Gate; contradicts the epic's Goal/Non-Goals -> escalate to user; everything else -> the routing test, ownership asked first — a finding in a file already inside this task's diff is the task's to fix now, a finding whose failure cannot occur is discarded with the reason written under `## Discarded` in `artifacts/T-XXX/discoveries.md`, and whatever survives is staged in that same file with its ground stamp — then continue the plan. Never create new T-XXX tasks mid-epic, and nothing reaches BACKLOG.md while the task is in flight.
