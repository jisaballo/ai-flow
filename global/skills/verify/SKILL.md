---
name: verify
description: Run the ai-flow Verify phase for the active task — criterion-by-criterion audit against understand.md, then a deterministic multi-agent review (coverage/security/architecture) with adversarial refutation of HIGH/MEDIUM findings via the verify-review workflow. Use when the user says "verify", "verifica", or runs the ai-flow verify phase. Requires an .ai-flow/ directory.
---

# ai-flow Verify Phase

Runs the Verify phase of the ai-flow workflow. Works in any project that has `.ai-flow/`.

## Steps

1. **Read the protocol**: `.ai-flow/protocols/verify.md` (project-local spec for the criterion audit, status meanings, templates, skip conditions). If it does not exist, this project is not ai-flow — tell the user and stop.

2. **Read the spec**: get the active task `T-XXX` from `.ai-flow/STATE.md`, then read `.ai-flow/artifacts/T-XXX/understand.md`. Focus on Verifiable Criteria + Expected Behavior. (Also check `.ai-flow/artifacts/T-XXX/verify.md` first — if it exists, follow the Artifact-Check rule: show it and ask before regenerating.)

3. **Criterion audit (YOU do this — it needs full task context, do not delegate)**: for each criterion, cite evidence (`file:line`, test name, or observable behavior) and mark ✅ / ⚠️ / ❌. Re-run every Verify command from each `plan.md` step (catches cross-step regressions a later step may have introduced).

4. **Decide whether to skip the multi-agent review.** Skip it for: Quick-path tasks, Auto-level tasks (rely on test validation only), or pure style/i18n/config changes with no logic. Otherwise continue.

5. **Gather the diff** (working tree, uncommitted — ai-flow doesn't commit until validated):
   - `git diff HEAD` → modified tracked files (this is `diffText`)
   - `git ls-files --others --exclude-standard` → untracked files; Read them and append their content to the diff context
   - Build `changedFiles`, scoped to the `source_dirs` declared in `.ai-flow/project.yml`. **Fallback:** if `.ai-flow/project.yml` is absent, infer the source directories from CLAUDE.md (legacy behavior).

6. **Invoke the verify-review workflow** (deterministic 3-auditor + adversarial refutation). Call the **Workflow** tool with:
   - `scriptPath`: `~/.claude/workflows/verify-review.js`
   - `args`: `{ taskId, area, understandPath, steeringPath, claudeMdPath, changedFiles, diffText }`
   Resolve `area` from the affected unit using `area_kind` in `.ai-flow/project.yml`, and `steeringPath` from that file's `steering` map (`steering[<area>]`, falling back to `.ai-flow/steering/<area>.md` if present). `claudeMdPath` = the project `CLAUDE.md`. `understandPath` = the active task's `understand.md`.

7. **Consolidate** the workflow result `{ confirmed, refuted, summary }`:
   - **HIGH confirmed** → ⚠️ flag to the user; blocks archive (same gate as a partial criterion).
   - **MEDIUM / LOW confirmed** → list under `## Review Findings` for awareness, don't block.
   - **refuted** → list briefly under "Dismissed (refuted)" so the audit trail stays transparent.
   - No findings at all → `## Review Findings: None`.

8. **Write** `.ai-flow/artifacts/T-XXX/verify.md` using the protocol's template, with the workflow findings under `## Review Findings`.

9. **Gate**: if any criterion is ❌ or any finding is HIGH-confirmed → STOP, do NOT proceed to archive. Fix or flag per the protocol's gate rules. ⚠️ partials → flag to user, who decides proceed-or-fix.

## Notes
- The multi-agent review is **always** the workflow — never run those 3 auditors ad-hoc or "in your head". The workflow guarantees parallel execution, schema-validated output, and adversarial refutation.
- Each Guided/Supervised verify therefore spends 3 review agents + N refutation agents (HIGH+MEDIUM). This is intended.
