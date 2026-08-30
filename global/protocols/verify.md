# Verify Phase Protocol (LLM-as-Judge)

**CRITICAL:** Verify is NOT just "run tests and confirm they pass". It's a criterion-by-criterion audit against understand.md.

> **Run via the `/verify` skill** (global, `~/.claude/skills/verify/`). It performs the criterion audit below and then invokes the deterministic `verify-review` workflow for the multi-agent review. This protocol is the spec the skill follows. If the skill is not installed, follow the steps here manually.

## Steps

1. **Resolve the task** by the ladder in the backlog protocol (`## State Files` → `### Resolving the task`) — stated there and only there, and a stop rather than a choice if it ends without one — then test the **phase precondition** (same document, `### The phase precondition`), stated there and only there too, so this document names no accepted position and no leg of its own: a run that reaches this file because the command is not installed performs the check itself, which is also what makes the out-of-phase clause in the templates below reachable. Then **re-read** `artifacts/T-XXX/understand.md` (Verifiable Criteria + Expected Behavior) and the **Criteria Coverage table** in plan.md — VERIFY inherits that mapping; do not reconstruct criterion->step from scratch.
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

**Verifying measures from a published trunk — publishing precedes verifying**, the way it already
precedes opening a front. Where the local default branch holds commits the remote has not seen, the
audit says how many it is ahead of its remote and that publishing them removes the overlap, and then
continues: it never refuses to run, because a clean task halted by a condition outside itself is the
very defect this rule exists to remove, relocated. The lag is determined where the base is resolved, so
it is in hand before any criterion is judged, and it is recorded as its own fact beside the base — how
far the branch has come since the base and how far the trunk is from its remote are different numbers,
and one standing for both is a report nobody can act on. What the audit *accepts* does not change: the
checks below keep exactly the reach they have, and an identifier a previous task committed is still
reported. What the operator gains is the one remedy that can change the subject — publish, and measure
again.

**Three cases get no lag line at all**, and each is a silence rather than a zero: the trunk is current,
where the run reads exactly as it read before this rule existed, because a notice that fires on every
run is how a check stops being read; no remote trunk resolves — no remote, or no local branch of that
name — where silence means no lag is possible, not that one was measured and found to be nothing; and
no base resolved, where the branch scope is already declared unavailable and a lag has no subject.

**The remedy names only commits the task does not own.** Where the branch under audit *is* the trunk —
the ordinary shape of a coordinator — the unpublished commits are the task diff, and some of them may
be steps this task committed: publishing those would push work the audit is judging past the gate that
validates it, and would leave the next run measuring from the task's own tip, auditing nothing. So the
report says which case it is and the call stays with the operator; what the remedy names is earlier
work, never the task's own. **And where the trunk has diverged** — the remote moved too — the count is
one side of two and the push would be refused: the report says diverged, and that reconciling with the
remote comes before publishing.

**IF no base resolves, or `merge-base` comes back empty, THEN the audit narrows to what is uncommitted
and says so** — verify.md records that the branch scope was unavailable. A repository with no published
default branch and no local `main`/`master` still gets a verify; it gets a smaller one, announced.

## Mutation and the Working Copy

**An audit never modifies what it audits.** Reading is the whole of the job: an auditor that edits the
work it is judging changes what every other auditor is reading at that moment, and the finding it then
writes describes a state that never existed. That damage leaves nothing behind to find it by — which is
why the rule is not "restore whatever you broke" but "do not break it".

Proving a fact does sometimes require a change: an assertion is only shown to be hollow by making the
thing it guards untrue and watching the suite stay green. Where that is so:

- **The proof is made by one actor at a time**, alone, never beside another and never by the parallel
  auditors. A change worth making is data an auditor hands over — performing it belongs to whoever the
  procedure appoints for it.
- **The change is taken back before the run ends**, each one restored before the next is applied, so the
  working copy never carries two at once.
- **The run proves the working copy was left as it was found**, byte-exact, against a copy taken before
  it started — byte-exact over what version control can see, which is where the proof's reach ends: a
  file the project ignores is outside it, and a check that reads the tree rather than asking git is
  reading through that gap. That proof is executed by the phase that invokes the run, never by the actor that mutates:
  an actor killed mid-change restores nothing, which is precisely how the discipline has failed before.
- **A run that cannot prove it clean says so**, rather than staying silent. In a report, silence and a
  clean working copy read identically, and there is no third source to settle which one happened.
- **An auditor reading beside other auditors reports what it read, never what it ran.** A finding
  resting on the outcome of a run — a suite's failures, a command's exit — is an account nobody else can
  check: the run happened inside one actor while the others were reading the same copy, and the report is
  the only trace it leaves. **Three of four** auditors once reported the same four failures against a
  suite that had none, with the rule above already stated to each of them and already guarded — which is
  why these are two rules and not one. The first governs the damage; this one governs the evidence, and
  forbidding the act never forbade the account. The scope is the parallel readers and only them: the
  phase that invokes them runs alone, and what it reports under Test Results is its own — so the closing
  sentence below, which binds every actor the lifecycle appoints, reaches this bullet's siblings and not
  this bullet. A suspicion only a run can settle is handed over as a proposed mutation, and the actor
  appointed to run it is the one whose outcome the report may carry.

The rule binds every actor the lifecycle appoints, not the review's alone: a Conform sweep that mutates
to size its own assertions is the same act with a different author.

## What a Mutation Has To Prove

**Where a row's legs are independent, each leg gets its own mutation.** One mutation per row proves the row
is not vacuous — that something, somewhere in it, is load-bearing. It says nothing about whether the other
legs are keyed on anything, and a row is only as strong as its weakest leg, because every leg has to hold for
the row to be green and therefore any hollow one can be deleted from the source with the row none the wiser.

This is written down because the cheaper battery reads as sufficient and is not. A block whose six rows were
each killed by their own mutation, and reported proved on that basis, was then found to carry two legs green
on prose that predated the requirement: one matched case-insensitively against a word the surrounding
paragraph had always used, the other asserted the bare presence of a term the region already contained. Both
survived the per-row battery untouched, because in each case a *different* leg of the same row was what the
mutation killed. It was the third time the same defect had been found in that block and the first time the
rule was stated.

**The mutation deletes or falsifies the exact sentence the leg names — never a neighbour.** A leg that
survives its own sentence being deleted is satisfied by something else in the region, and what that something
is must be found before the row is called proved: the usual answer is a sibling leg, a heading, or prose the
task never wrote. **A leg keyed on a word rather than on a claim is the shape to distrust first**, and
case-insensitivity is how such a leg most often reaches text its author never considered.

Where a row's legs genuinely stand or fall together, one mutation is the honest count and the report says
which case it is. What is never acceptable is a count that leaves the reader unable to tell the two apart.

## verify.md Template

```markdown
# Verify: T-XXX - [Title]

**Audited**: `T-XXX`, resolved from `[the state file the ladder answered with]`. The task diff — base
`[base ref]`, `[N]` commit(s) on this branch since it, plus what is still uncommitted. If no base
resolved: `branch scope unavailable — uncommitted work only`. Where the trunk is behind: `[M]`
commit(s) ahead of its remote, and publishing what is not this task's own removes the overlap; where
the trunk is current, where no remote trunk resolved, or where no base resolved, no lag line is
written. The working copy was left as found; if it was
not, what changed and what was restored. If the audit ran out of phase on the operator's word, that it
did and that the sheet's position was not moved.

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

Then it **adversarially refutes every HIGH finding**: a skeptic agent reads the code in context and tries to refute it; only findings that survive (confirmed=true) hold the gate. HIGH is refuted because HIGH is what blocks — it is the one level where a false finding costs something to hold.

**MEDIUM and LOW come back unadjudicated, and the phase decides them.** No skeptic is spent there: a MEDIUM neither blocks the archive nor gets fixed by the review, so an agent spent refuting one buys a tidier list and no decision — and buys it at the price of rebuilding the whole diff to read a single finding. The phase already holds the diff, the criteria and the plan, so the judgment a refuter used to make is made where the context already is. The rule is that it *is* made: a finding nobody decides is a finding four auditors were paid to produce and nobody used. MEDIUM findings are triaged one of three ways — fixed now, sent to the Icebox, or discarded as a false positive with the reason — and each outcome is recorded. LOW findings are listed as raised and marked unadjudicated; no outcome is required of them.

Finally, **one prover** — alone, after every auditor and refuter has finished reading, and only when a surviving finding proposed one. The auditors are read-only (see **Mutation and the Working Copy** above): an auditor that suspects an assertion is hollow returns the change that would settle it instead of making it, and this stage is the actor the rule appoints. It applies them one at a time, runs the project's test command, and puts each file back before the next. Proposals naming a path outside the repository or outside the reviewed scope are dropped before the stage runs.

### Consolidation into verify.md

- **HIGH confirmed, still rated high** -> ⚠️ flag to user; blocks archive (same gate as a partial criterion). A HIGH the skeptic downgraded stands as a finding and no longer holds the gate.
- **MEDIUM unadjudicated** -> triaged here (fixed / iceboxed / discarded), and the outcome recorded. Never listed as though a skeptic had cleared it.
- **LOW unadjudicated** -> listed as raised, marked unadjudicated, doesn't block.
- **Refuted** -> list briefly under "Dismissed (refuted)" for a transparent audit trail.
- No findings -> `## Review Findings: None`.
- **A proof came back** -> `died` retires the finding: the assertion does guard its fact. `survived` keeps it, now
  demonstrated rather than suspected. `unproven` keeps it with the reason the proof could not be run. The prover's
  own claim to have restored what it touched is its word, never the verdict — the comparison below is.
- **The working copy differs from the copy taken before the review** -> restore from it, record exactly
  what differed, and mark the review's verdict **suspect**: it may have been written against a state that
  no longer exists. The user decides between accepting it and re-running the review — the same gate as a
  partial criterion. A restored difference is never folded into a clean report.

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
resolved: `branch scope unavailable — uncommitted work only`. Where the trunk is behind: `[M]`
commit(s) ahead of its remote, and publishing what is not this task's own removes the overlap; where
the trunk is current, where no remote trunk resolved, or where no base resolved, no lag line is
written. The working copy was left as found; if it was
not, what changed and what was restored. If the audit ran out of phase on the operator's word, that it
did and that the sheet's position was not moved.

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

### Triaged in-phase (unadjudicated by the review)
- [MEDIUM finding + fixed / iceboxed / discarded + the reason, or "None"]
- [LOW findings, listed as raised and unadjudicated]

### Proven (mutation)
- [finding + died/survived/unproven + the evidence, or "Nothing proposed"]

## Gaps Found
[Consolidated list from audit + review, or "None"]
```
