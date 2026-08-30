---
name: verify
description: Run the ai-flow Verify phase for the active task — criterion-by-criterion audit against understand.md, then a deterministic multi-agent review (contract/coverage/security/architecture) with adversarial refutation of HIGH findings and in-phase triage of the rest via the verify-review workflow. Use when the user says "verify", "verifica", or runs the ai-flow verify phase. Requires an .ai-flow/ directory.
---

# ai-flow Verify Phase

Runs the Verify phase of the ai-flow workflow. Works in any project that has `.ai-flow/`.

## Steps

1. **Read the protocol**: `~/.claude/ai-flow/protocols/verify.md` (central engine — the spec for the criterion audit, status meanings, templates, skip conditions). If the project has no `.ai-flow/` directory, it is not ai-flow — tell the user and stop.

2. **Resolve the task**, then read the spec: the task is the one this checkout owns, not the one the session remembers — follow the ladder in `~/.claude/ai-flow/protocols/backlog.md` (`## State Files` → `### Resolving the task`), written there and only there, so do not reproduce its rungs here. State which task you resolved and the source it read (the task's sheet, or the shared state when that is the rung that answered); if the ladder ends without a task, stop and say which rungs you tried. Then test the phase precondition (same document, `## State Files` → `### The phase precondition`) — written there and only there, so do not reproduce the accepted positions here. On a clean pass, write its own phase to the sheet before any of the phase's work. Ordinarily the sheet already declares VERIFY, because the close of Execute set it and the cut fell there — then nothing is announced and the audit proceeds. Where this run is instead the one that moves the position, write it and carry straight on to step 3. The cut is **not** offered here: it belongs to the close of Execute, which either made it or stayed silent because the sitting was still cheap, and a stop offered at the entry to the audit halts a session that has done nothing — the late-firing stop this arrangement exists to remove. The obligations that do attach to a close are stated in that same document and only there, so do not reproduce them here. On a disagreement, report and wait, and if the operator says go, run without moving the line. Then read `.ai-flow/artifacts/T-XXX/understand.md` (Verifiable Criteria + Expected Behavior) and the **Criteria Coverage table** in `plan.md` — the audit inherits that criterion→step→stub mapping; don't rebuild it. (Also check `.ai-flow/artifacts/T-XXX/verify.md` first — if it exists, follow the Artifact-Check rule: show it and ask before regenerating.)

3. **Gather the task diff** — everything this branch added since its base, commits included, plus what is still uncommitted. The protocol's **The Task Diff** section defines it; the base resolution below is a prose copy of the one in `~/.claude/hooks/diff-size-guard.py` (`base_ref`), which stays the original — if the two ever read differently, that file wins.
   - Resolve the base: `git symbolic-ref refs/remotes/origin/HEAD`, **verified** with `git rev-parse --verify --quiet <ref>` — a dangling `origin/HEAD`, left behind by a renamed default branch, answers the first command but resolves to nothing, and an unverified answer yields an empty merge-base and a silently absent branch scope. Else a local `main`, else `master`, each checked the same way, in that order.
   - Capture it once: `MB="$(git merge-base <base> HEAD)"`.
   - **IF no base resolved, or `MB` is empty, THEN** the branch scope is unavailable: use `git diff HEAD`, and record that in verify.md. Never report a working-copy audit as a branch one. The guard sits before the use, so nothing ever diffs against an empty ref.
   - Otherwise the task diff is `git diff "$MB"` → this is `diffText`. One call, not two: a diff taken against a commit reaches the working tree, so the branch's commits and the uncommitted work arrive together.
   - `git ls-files --others --exclude-standard` → untracked files; Read them and append their content to the diff context (no diff sees them).
   - Build `changedFiles` from that same base-scoped diff (`--name-only`) plus those untracked files, scoped to the `source_dirs` declared in `.ai-flow/project.yml`. **Fallback:** if `.ai-flow/project.yml` is absent, infer the source directories from CLAUDE.md (legacy behavior).
   - Note the base and how many commits it covers (`git rev-list --count "$MB"..HEAD`) — step 10 writes both into the report.
   - **Note the trunk's lag**, here and not later: this is where the trunk the base resolved to is known, so determining it here puts it in hand before any criterion is judged — and **say it in the run's own output at this point**, not only in the report, because a warning that arrives after the verdict is not a warning. With `<trunk>` that branch, verify both `refs/remotes/origin/<trunk>` and `refs/heads/<trunk>` with `git rev-parse --verify --quiet`, then `git rev-list --left-right --count refs/remotes/origin/<trunk>...refs/heads/<trunk>`.
     - **Right side non-zero** → the trunk is that many commits ahead of its remote; the report says so, names publishing as what removes the overlap, and the audit **continues** — it never refuses over this.
     - **Left side non-zero as well** → the trunk has diverged and a push would be refused: say diverged, and that reconciling with the remote comes before publishing.
     - **Right side zero, or either ref absent** → **no lag line is written at all**. The trunk is current, or no lag is possible; either way the run reads exactly as it did before this rule existed. A zero is never reported as a zero.
     - **Where the branch under audit is itself `<trunk>`** → those unpublished commits are the task diff, and some may be steps this task committed. The report says so, and the publish remedy names earlier work only — never the task's own, which would push what the audit is judging and leave the next run measuring from the task's own tip.
     Worktrees share the ref store, so this reads the same from a linked checkout as from the coordinator.

4. **Criterion audit (YOU do this — it needs full task context, do not delegate)**: for each criterion, cite evidence (`file:line`, test name, or observable behavior) and mark ✅ / ⚠️ / ❌. Re-run every Verify command from each `plan.md` step (catches cross-step regressions a later step may have introduced). Then two more checks from the protocol:
   - **Contract check**: diff current conformance specs against `artifacts/T-XXX/conformance-baseline/manifest.md` — every frozen row keeps its `it()` description and assert direction; divergence without an `## Implementation Decisions` entry → ❌.
   - **Reverse audit (diff→plan)**: every hunk in the task diff step 3 gathered traces to a plan step, a criterion, or an Implementation Decision; orphan hunks → `Gaps Found` as scope creep.

5. **Decide whether to skip the multi-agent review.** Skip it for: Quick-path tasks, Auto-level tasks (rely on test validation only), or pure style/i18n/config changes with no logic. Otherwise continue.

6. **Take the byte-exact copy of the working tree, before the review is invoked.** The protocol's `Mutation and the Working Copy` is the rule this serves. It goes to a path step 8 can recompute rather than inherit: `SNAP="${TMPDIR:-/tmp}/ai-flow-verify-T-XXX"`, outside the repository and never inside it. A shell variable does not survive from one step to the next, and a snapshot whose location is forgotten is a snapshot that cannot be compared against — worse, a restore branch reached with `$SNAP` empty writes to the filesystem root and discards work against nothing. Then `rm -rf "$SNAP"; mkdir -p "$SNAP/untracked"`, `git diff --binary HEAD > "$SNAP/tree.patch"` — **`--binary`**, because a plain patch cannot represent a binary change and therefore cannot put one back — `git status --porcelain > "$SNAP/status.txt"`, `git ls-files --others --exclude-standard > "$SNAP/untracked.txt"`, and copy each path it lists into `"$SNAP/untracked/"` keeping its directories, since no patch reaches an untracked file. This is the record step 8 compares against, and it is taken on every review, including the ones that prove nothing.

7. **Invoke the verify-review workflow** (deterministic 4-auditor + adversarial refutation). **Copy the script into the scratchpad first** — `cp ~/.claude/workflows/verify-review.js <scratchpad>/verify-review.js` — and pass that path. The Workflow tool accepts only a path it returned or one you can already read, which `~/.claude/` is not: passing the installed path directly is refused, and the refusal names no remedy. Copy per run, never once and reused, or an edit to the installed workflow silently stops reaching the review. Call the **Workflow** tool with:
   - `scriptPath`: the scratchpad copy just made (source: `~/.claude/workflows/verify-review.js`)
   - `args`: `{ taskId, area, understandPath, planPath, steeringPath, claudeMdPath, changedFiles, diffText, testCommand }`
   Resolve `area` from the affected unit using `area_kind` in `.ai-flow/project.yml`, and `steeringPath` from that file's `steering` map (`steering[<area>]`, falling back to `.ai-flow/steering/<area>.md` if present). `claudeMdPath` = the project `CLAUDE.md`. `understandPath` = the active task's `understand.md`; `planPath` = its `plan.md` (the Business Contract auditor reads the `Business Frame`, `Contract`, and `Decision Register` from these). `testCommand` = `commands.test` from `.ai-flow/project.yml` — the prover runs it to settle whether an assertion is hollow, and reports the proposal unproven rather than guessing when it has none.

8. **Compare the working copy against the copy taken in step 6.** Recompute the path — `SNAP="${TMPDIR:-/tmp}/ai-flow-verify-T-XXX"` — and never rely on having inherited it.
   - **Precondition.** If `"$SNAP/tree.patch"` is missing, the comparison cannot be made: report that the working copy could not be proven as found, name the copy that is absent, and do **not** enter the restore branch. A missing record is never a licence to discard work.
   - **Compare.** `git diff --binary HEAD > "$SNAP/after.patch"`, then `diff -q "$SNAP/tree.patch" "$SNAP/after.patch"`, and the same over `git status --porcelain` and over `git ls-files --others --exclude-standard` with the contents under `"$SNAP/untracked/"`. Byte-exact, or it did not hold. **Those three probes are the whole reach of this comparison**: tracked changes, and untracked files git is not ignoring. A file git **ignores** is outside all three, so *left as found* is a verdict about that reach and never about the whole directory — bytecode, build output and local caches can appear or change under a review and this step will not see them.
   - **Identical** → the verdict is that the working copy was left as found.
   - **Different** → restore, in the only order that cannot lose the work. **Nothing is discarded before both moves are known to apply**: `git apply -R --check "$SNAP/after.patch"` (undo what is there now) and `git apply --check "$SNAP/tree.patch"` (put back what was there). If either check fails, restore **nothing**: keep the copy, report what differed and where the copy is, and leave the recovery to the user — a restore that erases the tree and then fails to replay it is the one outcome worse than a dirty tree. If both check clean, run them in that order, put the untracked copies back, delete any untracked file that appeared, record exactly what differed, and mark the review's verdict suspect per the protocol's consolidation rules. A restored difference is never folded into a clean report. **Never restore with `git checkout -- .`**: it discards from the index rather than from this record, it is relative to the current directory, and it is the same command the prover is forbidden, for the same reason.
   This runs whether or not anything was proven and whether or not the review's agents completed: it is the phase's own step, so an agent killed mid-change cannot take the restoration down with it.

9. **Consolidate** the workflow result `{ confirmed, refuted, unverified, proofs, summary }`. Three sets, and they are not interchangeable: a finding was cleared by a skeptic, killed by one, or never read by one.
   - **`confirmed` still carrying `severity: high`** → ⚠️ flag to the user; blocks archive (same gate as a partial criterion). A HIGH the skeptic downgraded stands as a finding and no longer holds the gate.
   - **`unverified`** → nobody has adjudicated these. **Triage the MEDIUM ones yourself, now, before writing the report** — see `## Triaging the Unadjudicated` below. LOW ones are listed as-is.
   - **`refuted`** → list briefly under "Dismissed (refuted)" so the audit trail stays transparent.
   - No findings at all → `## Review Findings: None`.
   - **`proofs`** → for each proposed mutation the prover ran: `died` retires the finding (the assertion does guard its fact), `survived` keeps it (the assertion is hollow), `unproven` keeps it with its reason. The prover's `treeRestored` is its own word and never the verdict — step 8's comparison is.
   - **Presentation to the user**: one line per axis (finding count + worst finding), and the count says how many were adjudicated versus triaged in-phase — a reader who cannot tell the two apart is reading one number for two different guarantees. Business Contract findings in product language — what the product does vs. what the contract says, no file paths. Full detail stays in verify.md, shown on demand.

10. **Write** `.ai-flow/artifacts/T-XXX/verify.md` using the protocol's template, with the workflow findings under `## Review Findings`. Its `**Audited**` line carries the task it resolved and the source it read, plus what step 3 noted — the base, the number of commits on this branch since it, and how far the trunk is ahead of its remote with publishing named as what removes the overlap — or, when no base resolved, that the branch scope was unavailable, and when the trunk is current or no remote trunk resolved, no lag line at all; and the tree verdict from step 8: left as found, or what differed and what was restored. An audit that does not say what it read cannot be checked against what it should have read.

11. **Gate**: if any criterion is ❌ or any finding is HIGH-confirmed → STOP, do NOT proceed to archive. Fix or flag per the protocol's gate rules. ⚠️ partials → flag to user, who decides proceed-or-fix.

## Triaging the Unadjudicated

The review hands back every MEDIUM and LOW finding without a verdict. That is deliberate: HIGH is the only
level that holds the archive gate, so it is the only level where paying a skeptic changes an outcome. But a
finding nobody decides is a finding that bought nothing — four auditors were paid to produce it — so the
decision happens here instead, where the diff, the criteria and the plan are already in context.

**Take each MEDIUM finding and reach one of three outcomes.** Read the cited code before deciding; the
auditor saw the diff, not the surrounding flow.

- **Fix now** — it is real, small, and inside this task's scope. Fix it, re-run the step's Verify command,
  and record it in verify.md as fixed during verify.
- **Backlog it** — it is real but outside this task's scope. It goes to the BACKLOG.md Icebox under
  Discovery Triage (understand protocol), never as a new task mid-epic. Record where it went.
- **Discard it** — it is a false positive: already handled elsewhere, intended behavior, or a misread of the
  code. Say which, in one line. This is the judgment a refutation agent used to make, made by the actor that
  did not have to rebuild the context to make it.

**Say which outcome each one got.** An unadjudicated finding that reaches verify.md still unadjudicated has
only moved the omission into the record — and `## Review Findings` is then a list whose reader cannot tell
what was checked from what was merely typed. LOW findings are exempt: they are listed as raised, marked
unadjudicated, and no outcome is required of them.

**This is not the criterion audit.** A MEDIUM that contradicts a Verifiable Criterion is not a MEDIUM — it is
a ❌ on that criterion, and it goes through step 4, not through here.

## Notes
- The multi-agent review is **always** the workflow — never run those 4 auditors ad-hoc or "in your head". The workflow guarantees parallel execution, schema-validated output, and adversarial refutation.
- Each Guided/Supervised verify therefore spends 4 review agents + one refutation agent per HIGH finding. MEDIUM and LOW get no agent: they come back unadjudicated and this phase decides them, because it already holds the diff, the criteria and the plan that a fresh skeptic would have to rebuild from scratch to read a single finding.
