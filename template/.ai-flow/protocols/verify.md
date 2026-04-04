# Verify Phase Protocol (LLM-as-Judge)

**CRITICAL:** Verify is NOT just "run tests and confirm they pass". It's a criterion-by-criterion audit against understand.md.

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

**After the criterion audit (steps 1-4), launch 3 review agents in parallel.** These catch issues outside the scope of the specified criteria.

### Agent 1: Test Coverage Auditor
```
Input: The task diff (all changed files) + existing spec files
Task: Find test coverage gaps:
- Public methods without test coverage
- Branches not exercised (if/else, switch cases)
- Edge cases from understand.md without corresponding tests
- Regression risk: existing tests that should have been updated but weren't
Output: List of gaps with priority (critical / nice-to-have)
```

### Agent 2: Security & Error Handling
```
Input: The task diff
Task: Find security and robustness issues:
- Inputs without validation (especially user-facing)
- Async operations without error handling (missing catch, try-catch)
- Subscriptions without cleanup (memory leak risk)
- Sensitive data exposed in logs, templates, or state
- Missing null/undefined checks on external data
Output: Findings with severity (high / medium / low)
```

### Agent 3: Architecture Boundaries
```
Input: The task diff + CLAUDE.md import rules + steering file for affected domain
Task: Find architecture violations:
- Imports crossing forbidden layer boundaries
- Services bypassing facade or abstraction layers
- Models used outside their domain without proper exports
- Patterns that diverge from established conventions
- Steering file rules violated (domain-specific patterns)
Output: Violations with the rule violated and suggested fix
```

### Integration

1. Launch all 3 agents via Agent tool (subagent_type=general-purpose) in parallel
2. Consolidate findings into verify.md under `## Review Findings`
3. **HIGH severity findings** -> flag to user (same as partial criteria)
4. **MEDIUM/LOW findings** -> list in verify.md for awareness, don't block
5. If no findings across all 3 agents -> add `## Review Findings: None`

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
