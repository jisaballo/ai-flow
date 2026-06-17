---
name: plan
description: Run the ai-flow Plan + Conform phase for the active task — read the protocol, write a max-3-step plan.md (Verify + Done per step), then generate failing conformance test stubs from the Verifiable Criteria. Use when the user says "plan", "planifica", or after understand is approved. Requires an .ai-flow/ directory.
---

# ai-flow Plan + Conform Phase

Runs the Plan + Conform phase of the ai-flow workflow. Works in any project that has `.ai-flow/`.

## Steps

1. **Read the protocol first**: `.ai-flow/protocols/plan.md`. If it does not exist, this project is not ai-flow — tell the user and stop.

2. **Artifact check**: if `.ai-flow/artifacts/T-XXX/plan.md` already exists, show it and ask whether to proceed or regenerate. **Never blind-overwrite.**

3. **Write the plan**:
   - **Max 3 steps.** A plan needing >3 steps signals the task should be split (it's also a context-budget rule).
   - Each step has a **Verify** command and a **Done** criterion. For the Verify command, read `.ai-flow/project.yml` and use `commands.test` (interpolate the `{area}` placeholder with the area the step touches), not just a build, per the TDD rule. **Fallback:** if `.ai-flow/project.yml` is absent, infer the test command from CLAUDE.md (legacy behavior).

4. **Conform** (after plan approval): generate failing test stubs from the `understand.md` Verifiable Criteria, so Execute becomes "make the tests pass" — goal-directed.

5. Respect the phase gate: Plan → Conform is automatic; Conform → Execute requires user approval of the plan (Guided/Supervised).
