# Verify Phase Protocol (LLM-as-Judge)

**CRITICAL:** Verify is NOT just "run tests and confirm they pass". It's a criterion-by-criterion audit against understand.md.

> **Run via the `/verify` skill** (global, `~/.claude/skills/verify/`). It performs the criterion audit below and then invokes the deterministic `verify-review` workflow for the multi-agent review. This protocol is the spec the skill follows. If the skill is not installed, follow the steps here manually.

## Steps

1. **Resolve the task** by the ladder in the backlog protocol (`## State Files` → `### Resolving the task`) — stated there and only there, and a stop rather than a choice if it ends without one — then **re-read** `artifacts/T-XXX/understand.md` (Verifiable Criteria + Expected Behavior) and the **Criteria Coverage table** in plan.md — VERIFY inherits that mapping; do not reconstruct criterion->step from scratch.
2. **For each criterion**, cite the specific evidence (file:line, test name, or observable behavior) that satisfies it
3. **Contract check**: diff the current conformance specs against `artifacts/T-XXX/conformance-baseline/manifest.md`. Every frozen row must still exist with the same `it()` description and assert direction; any divergence must have a matching `## Implementation Decisions` entry in understand.md. Divergence without entry -> ❌.
4. **Reverse audit (diff->plan)**: every hunk in the task diff (see **The Task Diff** below) must trace to a plan step, a criterion, or an Implementation Decision. Orphan hunks -> record under `Gaps Found` as **scope creep** (this is the audited form of the Surgical Changes rule).
5. **Provenance grep**: the task diff's **added lines** must carry no task/epic IDs (two legs, because the task diff has two: `git diff <merge-base> | grep -E '^\+.*\b[TE]-[0-9]+'` for tracked work, and the same pattern over the files `git ls-files --others --exclude-standard` names, which no diff reaches — the base resolved as **The Task Diff** below defines it) in code, comments, or test names — the rule lives in Execute protocol > Code Comments & Provenance. Hits -> ❌ (fix before archive; provenance belongs in the commit message).
6. **Re-run all Verify commands** from each plan.md step (catches cross-step regressions — a later step may have broken an earlier one)
7. **Write** `artifacts/T-XXX/verify.md` with the audit table
8. **If any ❌ exists** -> STOP, do not proceed to archive. Fix or flag to user.
9. **If any ⚠️ exists** -> flag to user with what's missing. User decides: proceed to archive or fix first.

## The Task Diff

What the audit judges, defined once: steps 4 and 5 above, the multi-agent review below, and the
`/verify` skill that gathers it all read this and nothing else.

**The task diff is everything the current branch added since its base, commits included, plus what is
still uncommitted, plus untracked files.** A front working on its own branch is therefore judged on its
own work: a step the task already committed is part of the audit instead of invisible to it.

**The base is resolved exactly as the diff brake resolves it** (`~/.claude/hooks/diff-size-guard.py`):
`origin/HEAD` when it verifies, else a local `main`, else `master`. The diff runs from
`merge-base(base, HEAD)` and that is one measure, not two — a diff taken against a commit reaches the
working tree, so the branch's commits and the uncommitted work arrive together. Untracked files appear
in neither and are collected separately.

**The base is the published one**, so a checkout holding commits the remote has not seen audits them
alongside the current task's work. That overlap is reported, never silent: verify.md records the base and
how many commits it covered, which is what turns an unexplained orphan hunk into a traceable one.

**IF no base resolves, or `merge-base` comes back empty, THEN the audit narrows to what is uncommitted
and says so** — verify.md records that the branch scope was unavailable. A repository with no published
default branch and no local `main`/`master` still gets a verify; it gets a smaller one, announced.

## verify.md Template

```markdown
# Verify: T-XXX - [Title]

**Audited**: `T-XXX`, resolved from `[the state file the ladder answered with]`. The task diff — base
`[base ref]`, `[N]` commit(s) on this branch since it, plus what is still uncommitted. If no base
resolved: `branch scope unavailable — uncommitted work only`.

## Criteria Audit
| # | Criterion (from understand.md) | Status | Evidence |
|---|-------------------------------|--------|----------|
| 1 | [criterion text] | ✅/⚠️/❌ | `file.ts:line` or test name |
| 2 | [criterion text] | ✅/⚠️/❌ | `file.ts:line` or test name |

## Test Results
- `[verify command 1]` -> PASS/FAIL
- `[verify command 2]` -> PASS/FAIL

## Gaps Found
[List anything missed, or "None"]
```

## Status Meanings

- ✅ **Met** — code + test evidence exists
- ⚠️ **Partially met** — implemented but missing test coverage or edge case
- ❌ **Not met** — not implemented or broken

## Skills Feedback

As part of the audit, answer two questions: were the skills declared in plan.md actually consulted during Execute? Did any step need a skill that was NOT declared? Record misses under `## Gaps Found` in verify.md. Recurring misses for the same domain are the evidence that justifies a hard rule (a skill hard-wired in CLAUDE.md Action Boundaries) — do not add hard rules without this evidence.

## Auditing Behavioral Criteria (GIVEN/WHEN/THEN)

For Behavioral criteria, evidence must cite a test that exercises the full scenario (GIVEN->WHEN->THEN), or file:line showing both the trigger handler and the expected result. A single line of code is not sufficient — the full flow must be traceable.

## Multi-Agent Review (Post-Audit)

After the criterion audit (steps 1-4), the multi-agent review runs **deterministically via the `verify-review` workflow** — invoked by the `/verify` skill (script: `~/.claude/workflows/verify-review.js`). Do **not** run these auditors ad-hoc or "in your head"; the workflow guarantees they always run in parallel with schema-validated output and adversarial refutation.

### What it does

Runs 4 auditors in parallel over the task diff (see **The Task Diff** above):

- **Business Contract Auditor** — audits the diff against the user-approved contract (understand.md `Business Frame` + plan.md `Contract` and `Decision Register`), which is the oracle: (a) contract requirements missing or partial; (b) behavior the contract never asked for (business-level scope creep); (c) requirements that look implemented but wrong. Every finding quotes the contract line it violates.
- **Test Coverage Auditor** — public methods/branches/edge-cases without tests; existing tests that should have been updated but weren't.
- **Security & Error Handling** — unvalidated (esp. user-facing) input; async without error handling; subscriptions without unsubscribe; sensitive data in logs/templates/state; missing null/undefined checks on external data.
- **Architecture Boundaries** — imports crossing forbidden module/layer boundaries defined by the project; modules reaching into another module's internals instead of its public entry point; code bypassing the project's established access pattern; steering-rule and reference-implementation divergences.

Then it **adversarially refutes every HIGH and MEDIUM finding**: a skeptic agent reads the code in context and tries to refute it; only findings that survive (confirmed=true) surface. LOW findings are listed without refutation.

### Consolidation into verify.md

- **HIGH confirmed** -> ⚠️ flag to user; blocks archive (same gate as a partial criterion).
- **MEDIUM / LOW confirmed** -> list under `## Review Findings` for awareness, don't block.
- **Refuted** -> list briefly under "Dismissed (refuted)" for a transparent audit trail.
- No findings -> `## Review Findings: None`.

### Presentation to the user

What the user reads in chat is **one line per axis**: finding count + the worst finding of that axis. Business Contract findings are phrased in product language (what the product does vs. what the contract says — no file paths). Full detail lives in verify.md and is shown on demand — never pushed.

### When to Skip

- **Quick path** tasks (no formal verify)
- **Auto level** tasks (rely on test validation only)
- Pure style/i18n/config changes with no logic

### verify.md Template (with Review Findings)

```markdown
# Verify: T-XXX - [Title]

**Audited**: `T-XXX`, resolved from `[the state file the ladder answered with]`. The task diff — base
`[base ref]`, `[N]` commit(s) on this branch since it, plus what is still uncommitted. If no base
resolved: `branch scope unavailable — uncommitted work only`.

## Criteria Audit
| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| 1 | [text] | ✅/⚠️/❌ | `file:line` or test name |

## Test Results
- `[verify command]` -> PASS/FAIL

## Review Findings
### Business Contract
- [finding (quoting the violated contract line) or "Contract honored"]

### Test Coverage
- [finding or "No gaps found"]

### Security & Error Handling
- [finding or "No issues found"]

### Architecture Boundaries
- [finding or "No violations found"]

### Dismissed (refuted)
- [finding + why refuted, or "None"]

## Gaps Found
[Consolidated list from audit + review, or "None"]
```
