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
   - `args`: `{ taskId, area, understandPath, planPath, steeringPath, claudeMdPath, changedFiles, diffText, testCommand, contractChecklist, coverageChecklist, securityChecklist, architectureChecklist }`
   Resolve `area` from the affected unit using `area_kind` in `.ai-flow/project.yml`, and `steeringPath` from that file's `steering` map (`steering[<area>]`, falling back to `.ai-flow/steering/<area>.md` if present). `claudeMdPath` = the project `CLAUDE.md`. `understandPath` = the active task's `understand.md`; `planPath` = its `plan.md` (the Business Contract auditor reads the `Business Frame`, `Contract`, and `Decision Register` from these). `testCommand` = `commands.test` from `.ai-flow/project.yml` — the prover runs it to settle what a proposal shows, and reports the proposal unproven rather than guessing when it has none.

   **Resolve the review profile**, from the same `.ai-flow/project.yml`, keyed on the `area` already resolved above — the identical key the `steering` map uses, which is why it needs no resolution of its own:
   - `review_profile[<area>]`, else `review_profile.default` **where the operator wrote one**, else **nothing**. An area that resolves to nothing is reviewed with the engine's own **generic**, stack-agnostic lists, and **no project default is ever inferred** — an omission makes the review shallower, never wrong. `default:` is a reserved key inside `review_profile:` and never an area name.
   - The resolved profile is a map of axis → checklist path in `review[<profile>]`. **Test each path before the Workflow call** — `[ -r <path> ]`, named here the way step 3 names `git rev-parse --verify --quiet` and step 8 names its `diff -q`, because a promise whose probe is unstated is a promise nothing performs. A path that reads is passed as the matching `*Checklist` argument; a path that does not is **dropped from the args**, so that axis reviews with the engine generic. An axis the profile does not declare is passed nothing, and that is the ordinary case, not an error: **nothing is reported as a problem**, though step 10 still records that the axis used the engine generic, because the report's job is to say what judged the change.
   - **Say in the run's own output, at this point and before any auditor runs, which profile resolved and which checklist each axis received** — and, where a profile or a path did not resolve, name it. Both cases, not only the failure: the operator who declared a profile is the one this feature was built for, and a run that tells them only when they got it wrong leaves them reading the report afterwards to learn what judged their change. Same shape step 3's trunk lag takes, and for the same reason — a warning that arrives after the verdict is not a warning.
   - **A declaration that does not resolve is named, and the run continues.** The failure is the operator's configuration, not the task under audit, so the run never refuses over it. A profile absent from `review:` falls the whole area to the engine generic; a checklist path that does not read falls **that axis alone**, and every other axis keeps the checklist it resolved. Name it in the run's own output beside the line above — the same place and the same moment, so the operator reads what resolved and what did not in one breath — and step 10 records it.
   - **Where no profile resolves for this area and the project declared none, no line about profiles is written at all** — not in the run's output and not in the report. The test is on what **resolved**, never on whether the keys are present: the shipped template hands every adopter a `project.yml` that already carries both keys, so a test on presence would report the zero on precisely the majority case this rule calls ordinary. A zero is never reported as a zero: the run reads exactly as it did before profiles existed.

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
   - **`proofs`** → each entry carries what the run did (`red` / `green` / `unproven`) and the shape the workflow attached to it from the proposal it belongs to, or `kind: 'unknown'` where the answer could not be attributed to one proposal — its `unattributed` field carries which of the four ways the attribution failed, and the protocol obliges that reason into the report rather than a reason you invent. What each pair means for a finding is the protocol's `Consolidation into verify.md` — read it there, and restate it nowhere, this file included: the mapping was once stated here as well, and two independent copies of it are how they came to say different things. The prover's `treeRestored` is its own word and never the verdict — step 8's comparison is.
   - **Presentation to the user**: one line per axis (finding count + worst finding), and the count says how many were adjudicated versus triaged in-phase — a reader who cannot tell the two apart is reading one number for two different guarantees. Business Contract findings in product language — what the product does vs. what the contract says, no file paths. Full detail stays in verify.md, shown on demand.

10. **Write** `.ai-flow/artifacts/T-XXX/verify.md` using the protocol's template, with the workflow findings under `## Review Findings`. Its `**Audited**` line carries the task it resolved and the source it read, plus what step 3 noted — the base, the number of commits on this branch since it, and how far the trunk is ahead of its remote with publishing named as what removes the overlap — or, when no base resolved, that the branch scope was unavailable, and when the trunk is current or no remote trunk resolved, no lag line at all; and the tree verdict from step 8: left as found, or what differed and what was restored; and what step 7 resolved — the review profile and the checklist each axis received, or that an axis received none, plus any profile or checklist path that did not resolve. The review's content varies by project, so a report that does not name the checklists it was judged against cannot be checked at all; where the project declared no profiles, nothing about them is written. An audit that does not say what it read cannot be checked against what it should have read.

11. **Gate**: if any criterion is ❌ or any finding is HIGH-confirmed → STOP, do NOT proceed to archive. Fix or flag per the protocol's gate rules. ⚠️ partials → flag to user, who decides proceed-or-fix.

## Triaging the Unadjudicated

The review hands back every MEDIUM and LOW finding without a verdict. That is deliberate: HIGH is the only
level that holds the archive gate, so it is the only level where paying a skeptic changes an outcome. But a
finding nobody decides is a finding that bought nothing — four auditors were paid to produce it — so the
decision happens here instead, where the diff, the criteria and the plan are already in context.

**Take each MEDIUM finding through the routing test of Discovery Triage** (understand protocol), in its
order. Read the cited code before deciding; the auditor saw the diff, not the surrounding flow.

The order below **is** the protocol's, and the order is the mechanism: ownership first, then the discard
test, and staging as what is left. Offering staging before the discard files a false positive as a real
finding whenever it happens to sit outside the diff.

- **Fix now** — the finding sits in a file this task already reaches, so the task owns it. Fix it,
  re-run the step's Verify command, and record it in verify.md as fixed during verify. **Asked before
  scope, not after**: a MEDIUM the task already owns does not become somebody else's because the fix is
  large. What bounds it is the *action*, not the routing — fix it where the fix is small and traceable in
  the sense Surgical Changes gives those words, and where it is not, stage it **still owned**, with the
  `own ground` stamp and the reason it was not fixed here. It never leaves the task on account of its
  size, and the reverse audit has nothing untraceable to flag.
- **Discard it** — the failure it describes cannot occur: the code was misread, the behavior is intended,
  or something downstream already prevents it. Say which, in one line, and say why the failure cannot
  occur — **not** why the flow cannot reach it, which two of those three cases reach and survive anyway.
  The reason goes under `## Discarded` in `artifacts/T-XXX/discoveries.md`; what is recorded here is the
  decision and a pointer to it. This is the judgment a refutation agent used to make, made by the actor
  that did not have to rebuild the context to make it.
- **Stage it** — what is left: real, and not in a file this task already reaches. It goes to
  `artifacts/T-XXX/discoveries.md` with its ground stamp, never to BACKLOG.md while the task is in flight
  and never as a new task mid-epic. Record where it went.

**Say which outcome each one got.** An unadjudicated finding that reaches verify.md still unadjudicated has
only moved the omission into the record — and `## Review Findings` is then a list whose reader cannot tell
what was checked from what was merely typed. LOW findings are exempt: they are listed as raised, marked
unadjudicated, and no outcome is required of them.

**This is not the criterion audit.** A MEDIUM that contradicts a Verifiable Criterion is not a MEDIUM — it is
a ❌ on that criterion, and it goes through step 4, not through here.

## Notes
- The multi-agent review is **always** the workflow — never run those 4 auditors ad-hoc or "in your head". The workflow guarantees parallel execution, schema-validated output, and adversarial refutation.
- Each Guided/Supervised verify therefore spends 4 review agents + one refutation agent per HIGH finding. MEDIUM and LOW get no agent: they come back unadjudicated and this phase decides them, because it already holds the diff, the criteria and the plan that a fresh skeptic would have to rebuild from scratch to read a single finding.
