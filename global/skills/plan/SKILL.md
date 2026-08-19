---
name: plan
description: Run the ai-flow Plan + Conform phase for the active task — read the protocol, write a max-3-step plan.md (Verify + Done per step), then generate failing conformance test stubs from the Verifiable Criteria. Use when the user says "plan", "planifica", or after understand is approved. Requires an .ai-flow/ directory.
---

# ai-flow Plan + Conform Phase

Runs the Plan + Conform phase of the ai-flow workflow. Works in any project that has `.ai-flow/`.

## Steps

1. **Read the protocol first**: `~/.claude/ai-flow/protocols/plan.md` (central engine). If the project has no `.ai-flow/` directory, it is not ai-flow — tell the user and stop.

2. **Resolve the task**: the task is the one this checkout owns, not the one the session remembers. Follow the ladder in `~/.claude/ai-flow/protocols/backlog.md` (`## State Files` → `### Resolving the task`) — it is written there and only there, so do not reproduce its rungs here. State which task you resolved and the source it read (the task's sheet, or the shared state when that is the rung that answered) before touching anything under `artifacts/`; if the ladder ends without a task, stop and say which rungs you tried.

3. **Artifact check**: if `.ai-flow/artifacts/T-XXX/plan.md` already exists, show it and ask whether to proceed or regenerate. **Never blind-overwrite.**

4. **Write the plan — in pyramid form** (see the protocol's Pyramid Rule):
   - **Contract (layer 1)**: 6-10 lines, product language, zero file paths — today / after / what is lost / out of scope / observable success / irreversible.
   - **Decision Register (layer 2)**: every decision that is hard to reverse or has a business consequence — one line each: decision + consequence + recommendation, marked (confirmed) or (proposed).
   - **Mechanics (layer 3)**: the steps. **Max 3 steps.** A plan needing >3 steps signals the task should be split (it's also a context-budget rule). Each step has a **Verify** command and a **Done** criterion. For the Verify command, read `.ai-flow/project.yml` and use `commands.test` (interpolate the `{area}` placeholder with the area the step touches), not just a build, per the TDD rule. **Fallback:** if `.ai-flow/project.yml` is absent, infer the test command from CLAUDE.md (legacy behavior).
   - **No decision may live below its layer** — reading layers 1-2 must be sufficient to approve safely; a decision found only in Mechanics gets hoisted before presenting.
   - End with the mandatory **Criteria Coverage table** (criterion → step → stub): criterion without a step → replan or justified `deferred`; step without a criterion → justify as technical necessity. VERIFY inherits this mapping.
   - **The plan gate presents layers 1-2 in chat**; Mechanics stays in the artifact, shown on demand. Irreversible operations are always layer-1 visible and individually confirmed.

5. **Conform** (after plan approval): generate failing test stubs (GWT format) from the `understand.md` Verifiable Criteria (which arrive in EARS), then **freeze the contracts**: write the baseline manifest to `artifacts/T-XXX/conformance-baseline/manifest.md` (per stub: spec file, `it()` description, source criterion, assert direction — a manifest, not file copies). Execute becomes "make the tests pass" — goal-directed.

6. Respect the phase gate: Plan → Conform is automatic; Conform → Execute requires user approval of the plan (Guided/Supervised).
