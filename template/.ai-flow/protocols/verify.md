# Verify Phase Protocol (LLM-as-Judge)

**CRITICAL:** Verify is NOT just "run tests and confirm they pass". It's a criterion-by-criterion audit against understand.md.

> **Run via the `/verify` skill** (global, `~/.claude/skills/verify/`). It performs the criterion audit below and then invokes the deterministic `verify-review` workflow for the multi-agent review. This protocol is the spec the skill follows. If the skill is not installed, follow the steps here manually.

## Steps

1. **Re-read** `artifacts/T-XXX/understand.md` — specifically the Verifiable Criteria and Expected Behavior sections
2. **For each criterion**, cite the specific evidence (file:line, test name, or observable behavior) that satisfies it
3. **Re-run all Verify commands** from each plan.md step (catches cross-step regressions — a later step may have broken an earlier one)
4. **Write** `artifacts/T-XXX/verify.md` with the audit table
5. **If any X exists** -> STOP, do not proceed to archive. Fix or flag to user.
6. **If any warning exists** -> flag to user with what's missing. User decides: proceed to archive or fix first.

## verify.md Template

```markdown
# Verify: T-XXX - [Title]

## Criteria Audit
| # | Criterion (from understand.md) | Status | Evidence |
|---|-------------------------------|--------|----------|
| 1 | [criterion text] | Met/Partial/Not met | `file.ts:line` or test name |
| 2 | [criterion text] | Met/Partial/Not met | `file.ts:line` or test name |

## Test Results
- `[verify command 1]` -> PASS/FAIL
- `[verify command 2]` -> PASS/FAIL

## Gaps Found
[List anything missed, or "None"]
```

## Status Meanings

- **Met** — code + test evidence exists
- **Partially met** — implemented but missing test coverage or edge case
- **Not met** — not implemented or broken

## Auditing Behavioral Criteria (GIVEN/WHEN/THEN)

For Behavioral criteria, evidence must cite a test that exercises the full scenario (GIVEN->WHEN->THEN), or file:line showing both the trigger handler and the expected result. A single line of code is not sufficient — the full flow must be traceable.

## Multi-Agent Review (Post-Audit)

**After the criterion audit (steps 1-4), the multi-agent review runs deterministically via the `verify-review` workflow** — invoked by the `/verify` skill (`~/.claude/workflows/verify-review.js`). It catches issues outside the scope of the specified criteria. Do NOT run these auditors ad-hoc or "in your head"; the workflow guarantees they run in parallel with schema-validated output and adversarial refutation.

The workflow runs three auditors in parallel over the task diff, then sends every HIGH/MEDIUM finding to a skeptic agent that tries to refute it (only survivors are reported):

### Auditor 1: Test Coverage
- Public methods/functions without test coverage
- Branches not exercised (if/else, switch cases, error paths)
- Edge cases from understand.md without corresponding tests
- Regression risk: existing tests that should have been updated but weren't

### Auditor 2: Security & Error Handling
- Inputs without validation (especially user-facing)
- Async operations without error handling
- Resources acquired but never released (subscriptions, listeners, handles, connections)
- Sensitive data exposed in logs, responses, or state
- Missing null/undefined checks on external data

### Auditor 3: Architecture Boundaries
- Imports crossing forbidden module/layer boundaries defined by the project
- Modules reaching into another module's internals instead of its public entry point
- Code bypassing the project's established access pattern (skipping a defined abstraction layer)
- Divergences from the project's reference/gold-standard pattern
- Steering-file rules violated

### Integration

1. The `/verify` skill invokes the workflow with the task diff, changed files, `CLAUDE.md`, and the affected `steering/<area>.md`.
2. Consolidate the result `{ confirmed, refuted, summary }` into verify.md under `## Review Findings`.
3. **HIGH confirmed** -> flag to user (same gate as partial criteria); blocks archive.
4. **MEDIUM/LOW confirmed** -> list in verify.md for awareness, don't block.
5. **refuted** -> list briefly under "Dismissed (refuted)" to keep the audit trail transparent.
6. No findings at all -> add `## Review Findings: None`.

If the workflow/skill is not installed, fall back to launching the three auditors above via the Agent tool in parallel.

### verify.md Template (Updated)

```markdown
# Verify: T-XXX - [Title]

## Criteria Audit
| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| 1 | [text] | Met/Partial/Not met | `file:line` or test name |

## Test Results
- `[verify command]` -> PASS/FAIL

## Review Findings
### Test Coverage
- [finding or "No gaps found"]

### Security & Error Handling
- [finding or "No issues found"]

### Architecture Boundaries
- [finding or "No violations found"]

## Gaps Found
[Consolidated list from audit + review, or "None"]
```

### When to Skip Multi-Agent Review

- **Quick path** tasks (no formal verify)
- **Auto level** tasks (rely on test validation only)
- Pure style/config changes with no logic
