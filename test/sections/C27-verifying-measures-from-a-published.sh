echo "== C27: verifying measures from a published trunk =="
VP27="global/protocols/verify.md"
VS27="global/skills/verify/SKILL.md"
EP27="global/protocols/execute.md"

# Steps resolved by CONTENT, not by number: moving a step renumbers every step after it, and an
# assertion that dies to renumbering tests the numbering rather than the fact. Same reason as C14's.
vsn27() { grep -nE "^[0-9]+\. \*\*$1" "$VS27" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/'; }
NG27="$(vsn27 'Gather the task diff')"
NA27="$(vsn27 'Criterion audit')"

# The one definition every consumer reads, bounded at the next heading and fence-aware, then stripped
# of emphasis and rewrapped: an extractor that can pass or fail on where a line wraps or on a pair of
# asterisks is asserting typography, not content.
TD27="$(awk '/^## The Task Diff/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^#+ /){f=0} f' "$VP27" \
        | tr -d '*`' | tr -s ' \n' '  ')"

# A1 — the rule itself, in the section that owns the base. Asserted on a non-empty extractor first:
# a section that failed to extract satisfies no requirement and would otherwise report as a clean miss.
m27=""
[ -n "$TD27" ] || m27="$m27 section-absent"
printf '%s' "$TD27" | grep -qiE 'published trunk'                  || m27="$m27 published-trunk"
printf '%s' "$TD27" | grep -qiE 'publishing precedes verifying'    || m27="$m27 rule"
printf '%s' "$TD27" | grep -qiE 'removes the overlap'              || m27="$m27 remedy"
[ -z "$m27" ] \
  && ok "the task-diff definition states that verifying measures from a published trunk" \
  || bad "the task-diff definition states that verifying measures from a published trunk (missing:$m27)"

# A3 — the behaviour on a trunk that is behind, both halves. A guard that only reads the naming half
# passes on a rule that names the lag and then refuses to run, which is the outcome the user rejected.
n27=""
[ -n "$TD27" ] || n27="$n27 section-absent"
printf '%s' "$TD27" | grep -qiE 'ahead of its remote'                     || n27="$n27 count"
printf '%s' "$TD27" | grep -qiE 'publish'                                 || n27="$n27 remedy"
printf '%s' "$TD27" | grep -qiE 'continues|never refuses|does not refuse' || n27="$n27 continues"
[ -z "$n27" ] \
  && ok "a lagging trunk is named with its count and its remedy, and the audit continues" \
  || bad "a lagging trunk is named with its count and its remedy, and the audit continues (missing:$n27)"

# A4 — the silence AND what triggers it. A bare 'no lag' substring is satisfied by a silence attached
# to any condition at all: the review rewrote the trigger to its opposite — collapsing "no lag is
# possible here" into "measured, found nothing", the distinction the manifest calls load-bearing — and
# this stayed green. The sentence carrying the silence is extracted and the triggers read inside it.
S4_27="$(printf '%s' "$TD27" | grep -o 'no lag[^.]*\.' | head -1)"
q27=""
[ -n "$S4_27" ] || q27="$q27 sentence-absent"
printf '%s' "$S4_27" | grep -qi 'trunk is current'  || q27="$q27 trunk-current"
printf '%s' "$S4_27" | grep -qi 'no remote'         || q27="$q27 no-remote"
printf '%s' "$S4_27" | grep -qi 'no local branch'   || q27="$q27 no-local-branch"
printf '%s' "$S4_27" | grep -qi 'no base resolved'  || q27="$q27 no-base"
[ -z "$q27" ] \
  && ok "the silences name what triggers each of them" \
  || bad "the silences name what triggers each of them (missing:$q27)"

# A2 — the measurement lives where the base is already resolved, and is therefore made before anything
# is judged. Two facts: the command is there, and the gather step precedes the audit step. The order is
# over step INDEXES, which a renumbering-without-moving cannot fake.
G27="$([ -n "$NG27" ] && nstep "$VS27" "$NG27")"
o27=""
[ -n "$G27" ] || o27="$o27 step-absent"
# The range is what discriminates. The step already runs rev-list and already names
# refs/remotes/origin (that is how the base is resolved), so presence greps for either would be
# satisfied by the text as it stands today and would report a lag nobody computes.
printf '%s' "$G27" | grep -qE 'refs/remotes/origin/[^ ]*\.\.refs/heads/' || o27="$o27 lag-range"
printf '%s' "$G27" | grep -qF 'rev-list'                                  || o27="$o27 rev-list"
{ [ -n "$NG27" ] && [ -n "$NA27" ] && [ "$NG27" -lt "$NA27" ]; } || o27="$o27 order"
# The commands are half the step; what to do with the number is the other half, and the review deleted
# every branch of it with all six assertions still green. Each outcome is required by name.
printf '%s' "$G27" | grep -qF 'rev-parse --verify'                        || o27="$o27 ref-check"
printf '%s' "$G27" | grep -qiE 'continues|never refuses'                  || o27="$o27 continue-branch"
printf '%s' "$G27" | grep -qi 'no lag line'                               || o27="$o27 silence-branch"
printf '%s' "$G27" | grep -qi 'branch under audit'                        || o27="$o27 own-work-branch"
[ -z "$o27" ] \
  && ok "the skill determines the trunk's lag where it resolves the base" \
  || bad "the skill determines the trunk's lag where it resolves the base (missing:$o27)"

# A6 — counted, not merely present: a template check that finds its fact once cannot tell one template
# carrying it from two. Read off non-comment lines, the shape C14 arrived at after a commented-out
# fallback line satisfied the same check.
TL27="$(awk '
  /^```/ {
    if (inf) {
      if (seen) { gsub(/[[:space:]]+/, " ", s); total++; if (tolower(s) ~ /ahead of its remote/) good++ }
      seen=0; s=""
    }
    inf=1-inf; next
  }
  inf {
    if ($0 ~ /# Verify: T-XXX/) seen=1
    if ($0 ~ /^[[:space:]]*<!--/) next
    s = s " " $0
  }
  END { print (good+0) "/" (total+0) }
' "$VP27")"
[ "${TL27#*/}" -ge 1 ] 2>/dev/null && [ "${TL27%/*}" = "${TL27#*/}" ] \
  && ok "every report template records the trunk's lag beside the base" \
  || bad "every report template records the trunk's lag beside the base ($TL27)"

# A5 — the sentence the branch-scoped task diff falsified, repaired. Positive requirement first,
# because what bounds a statement is the form it must carry; the one negative is aimed at the exact
# claim that went false, not at a list of wordings that might.
PR27="$(awk '/^## Code Comments & Provenance/{f=1;next} /^## /{f=0} f' "$EP27" | tr -d '*`' | tr -s ' \n' '  ')"
p27=""
[ -n "$PR27" ] || p27="$p27 section-absent"
printf '%s' "$PR27" | grep -qiE 'task diff'                     || p27="$p27 scope"
printf '%s' "$PR27" | grep -qiE 'publish'                       || p27="$p27 publishing"
printf '%s' "$PR27" | grep -qiE 'until it is published|unpublished' || p27="$p27 condition"
printf '%s' "$PR27" | grep -qiE 'on new work only'              && p27="$p27 stale-claim"
[ -z "$p27" ] \
  && ok "the provenance rule states the reach the grep actually has" \
  || bad "the provenance rule states the reach the grep actually has (missing:$p27)"


# A7 — the ordinary run, which the contract singles out as the one that must not change. Counted over
# every report template, for the same reason A6 is: one carrying the escape while another stays silent is
# the half-fix, and a slot enumerating only the branch where the notice fires prints "0 commit(s)
# ahead — publish them" on every clean run.
TC27="$(awk '
  /^```/ {
    if (inf) {
      if (seen) { gsub(/[[:space:]]+/, " ", s); total++; if (tolower(s) ~ /trunk is current/) good++ }
      seen=0; s=""
    }
    inf=1-inf; next
  }
  inf {
    if ($0 ~ /# Verify: T-XXX/) seen=1
    if ($0 ~ /^[[:space:]]*<!--/) next
    s = s " " $0
  }
  END { print (good+0) "/" (total+0) }
' "$VP27")"
[ "${TC27#*/}" -ge 1 ] 2>/dev/null && [ "${TC27%/*}" = "${TC27#*/}" ] \
  && ok "every report template writes no lag line where the trunk is current" \
  || bad "every report template writes no lag line where the trunk is current ($TC27)"

# A8 — the report writer's own enumeration of what the Audited line carries. It was repaired because
# this change falsified it, and a repair nothing asserts is revertible with the suite green.
NW27="$(vsn27 'Write')"
W27="$([ -n "$NW27" ] && nstep "$VS27" "$NW27")"
w27=""
[ -n "$W27" ] || w27="$w27 step-absent"
printf '%s' "$W27" | grep -qi 'ahead of its remote' || w27="$w27 lag"
printf '%s' "$W27" | grep -qi 'no lag line'         || w27="$w27 silence"
printf '%s' "$W27" | grep -qi 'trunk is current'    || w27="$w27 trunk-current"
[ -z "$w27" ] \
  && ok "the report writer enumerates the lag and its silences" \
  || bad "the report writer enumerates the lag and its silences (missing:$w27)"

# A9 — the two cases where the remedy would harm rather than help: the branch under audit IS the trunk,
# so publishing pushes work the audit is judging and empties the next run's scope; and a diverged trunk,
# where the push is refused outright. A remedy that cannot succeed is the defect this task exists to fix.
r27=""
[ -n "$TD27" ] || r27="$r27 section-absent"
printf '%s' "$TD27" | grep -qi 'branch under audit'        || r27="$r27 own-trunk-case"
printf '%s' "$TD27" | grep -qi 'never the task'            || r27="$r27 ownership-limit"
printf '%s' "$TD27" | grep -qi 'diverged'                  || r27="$r27 diverged"
[ -z "$r27" ] \
  && ok "the remedy excludes the task's own commits and a diverged trunk" \
  || bad "the remedy excludes the task's own commits and a diverged trunk (missing:$r27)"


echo "== The paper trail names the model the engine runs =="

# A1 — the front door. Two claims read as a pair: the roster carries its own name, and activation writes
# the task's own sheet. The stale wording is asserted ABSENT in the same breath, because a README that
# gains the new sentence while keeping the old one teaches both and the reader cannot tell which won.
# Each half is scoped to the line that carries its claim. File-wide greps let the structure block's
# comment answer for the activation row and vice versa, so the criterion's two halves could both be
# satisfied by one edit in one place.
RD24="README.md"
LC24="global/protocols/lifecycle.md"

# The two halves now live in two files, and that is the point of the split rather than an accident of it:
# the front door keeps the claim its own structure line makes, and the claim about what activation writes
# follows the phase description to the one document that describes phases. Scoped to the ACTIVATE section
# and terminated at the next heading of ANY depth — the sibling A3 extractor exits on `## ` alone, which
# is correct only because ARCHIVE is the last phase and is not correct here.
ACT24="$(awk '/^### 3\. ACTIVATE/{f=1;next} f && /^#+ /{exit} f' "$LC24" 2>/dev/null)"
RST24="$(grep '── STATE.md' "$RD24")"
a1=""
[ -n "$ACT24" ] || a1="$a1 activate-section-absent"
[ -n "$RST24" ] || a1="$a1 structure-line-absent"
printf '%s' "$RST24" | grep -qi 'roster of open workstreams' || a1="$a1 roster-name"
printf '%s' "$ACT24" | grep -q  'artifacts/T-XXX/state.md'   || a1="$a1 task-sheet"
printf '%s' "$ACT24" | grep -qi 'roster'                     || a1="$a1 roster-row"
printf '%s' "$RST24" | grep -qi 'Current session context'    && a1="$a1 stale-session-context"
printf '%s' "$ACT24" | grep -qi 'as the active task'         && a1="$a1 stale-activation"
[ -z "$a1" ] \
  && ok "the front door names the roster and the map names the task's own sheet" \
  || bad "the front door names the roster and the map names the task's own sheet (missing:$a1)"


# A2 — the audit runs five auditors. The count is asserted by naming all five, not by matching a numeral:
# a document that says "four" and lists three is the same defect with the arithmetic corrected. The stale
# count is asserted absent for the reason A1 gives.
a2=""
grep -q  'Business Contract'         "$LC24" || a2="$a2 contract"
grep -q  'Test Coverage'             "$LC24" || a2="$a2 coverage"
grep -qi 'Security & Error Handling' "$LC24" || a2="$a2 security"
grep -q  'Architecture Boundaries'   "$LC24" || a2="$a2 architecture"
grep -q  'Simplicity & Structure'    "$LC24" || a2="$a2 structure"
grep -qiE '(3|three) review agents'  "$LC24" && a2="$a2 stale-count"
[ -z "$a2" ] \
  && ok "the lifecycle names all five auditors of the review" \
  || bad "the lifecycle names all five auditors of the review (missing:$a2)"

# A3 — archiving is a ceremony, and the move that puts the work into effect is the one a reader most needs:
# a close that ends before distribution leaves the engine committed and not installed — the work is in the
# trunk and does not exist for the sessions it governs. Scoped to the archive section so a mention anywhere
# else cannot answer for it.
ARC24="$(awk '/^### 9\. ARCHIVE/{f=1} f && /^## /{exit} f' "$LC24")"
a3=""
[ -n "$ARC24" ] || a3="$a3 section-absent"
printf '%s' "$ARC24" | grep -qi 'ceremony'         || a3="$a3 ceremony"
printf '%s' "$ARC24" | grep -qi 'distribut'        || a3="$a3 distribution"
printf '%s' "$ARC24" | grep -qi 'backlog protocol' || a3="$a3 authority"
[ -z "$a3" ] \
  && ok "the lifecycle archive is a ceremony and names the distribution move" \
  || bad "the lifecycle archive is a ceremony and names the distribution move (missing:$a3)"

# A4 — the direction that must still hold. Every other assertion here checks that a document gained the
# right sentence; this one checks that NO document anywhere claims a single active task without naming the
# front it is scoped to. A guard written only in the lifting direction goes silent the moment the claim
# reappears in a file the fix never opened.
#
# The pattern matches the CURRENT wording's regression shapes, not the wording that was repaired. Written
# against the repaired text it would have been blind to every way the claim can come back — "One active
# task at a time", "Only one task is active at a time", or simply the workstream qualifier deleted — and a
# guard nothing can trip is indistinguishable from one that holds. The signal is ACTIVENESS, never a count:
# "names exactly one task", "ONE task per run" and "the single-task archive checklist" are legitimate and
# must stay unflagged, which is why singularity alone is not enough to select a line.
a4="$(grep -rniE '(one|a single|only one)[[:space:]]+active[[:space:]]+task|(one|a single|only one)[[:space:]]+task[^.]{0,30}(active|at a time)|single[- ]task focus|single focus of the session|task at a time' \
        README.md docs/ global/ 2>/dev/null | grep -cviE 'workstream|per front|each front')"
[ "$a4" = "0" ] \
  && ok "no document claims a single active task without naming the workstream" \
  || bad "no document claims a single active task without naming the workstream ($a4 line(s))"

# A5 — the hook's remedy. It runs on the coordinator, so a message sending the operator to trim the roster
# "down to the active task only" instructs them to destroy the rows of every other open front. The
# assertion is on the text alone: the exit codes are covered five times over and must not move.
# Scoped to the remedy line itself, and the absence half asks what the trim TARGET is rather than pinning
# one historic phrase: a reworded destructive remedy ("down to the current task", "down to the open task")
# passed a check that only knew the words "active task only".
HK24="global/hooks/check-state-size.sh"
TRM24="$(grep -i 'trim STATE.md down to' "$HK24")"
a5=""
[ -n "$TRM24" ] || a5="$a5 remedy-absent"
printf '%s' "$TRM24" | grep -qi 'down to the roster'   || a5="$a5 roster"
printf '%s' "$TRM24" | grep -qiE 'down to the (active|current|open|single|one)' && a5="$a5 destructive-target"
[ -z "$a5" ] \
  && ok "the state-size hook trims to the roster, not to the active task" \
  || bad "the state-size hook trims to the roster, not to the active task (missing:$a5)"

# Terminated at the next heading. Without one the window runs to end of file, so "scoped to the section"
# is a claim the extractor does not keep — true only for as long as this happens to be the last section.
AS24="$(awk '/^### Allowed structure/{f=1;next} f && /^#{2,3} /{exit} f' "$BLG24")"

# A6 — the structure a project is allowed to have. Listing the phase protocols inside .ai-flow/ tells the
# reader to look for the engine where the engine is not, and tells an adopter their project owns files it
# must never edit. Both halves asserted: the stale subtree gone, and the central path named in its place.
a6=""
[ -n "$AS24" ] || a6="$a6 section-absent"
printf '%s' "$AS24" | grep -q 'state.md'                 || a6="$a6 task-sheet"
printf '%s' "$AS24" | grep -q -- '── protocols/'         && a6="$a6 stale-subtree"
printf '%s' "$AS24" | grep -q 'claude/ai-flow/protocols' || a6="$a6 central-engine"
[ -z "$a6" ] \
  && ok "the allowed structure puts the phase protocols in the central engine" \
  || bad "the allowed structure puts the phase protocols in the central engine (missing:$a6)"

# A7 — the ordinary case of the closing ceremony. Two moves need no second checkout and a third needs no
# merge, because a task worked in the coordinator has no branch to land. Naming two of the three reads as
# though the merge always had work to do, which turns the ordinary close into a ritual with a dead move.
CLO24="$(awk '/^## Closing a Workstream/{f=1;next} f && /^## /{exit} f' "$BLG24")"
PRE24="$(printf '%s\n' "$CLO24" | awk '/^1\. /{exit} {print}' | tr '\n' ' ' | tr -s ' ')"
a7=""
[ -n "$PRE24" ] || a7="$a7 preamble-absent"
printf '%s' "$PRE24" | grep -qiE 'no branch to merge|nothing to merge' || a7="$a7 merge-reason"
printf '%s' "$PRE24" | grep -qi 'moves 2 and 6'                       && a7="$a7 stale-move-list"
[ -z "$a7" ] \
  && ok "a single open front has no branch to merge either" \
  || bad "a single open front has no branch to merge either (missing:$a7)"

QP24="global/protocols/quick-path.md"

# A8 — a quick task's only written trace. The protocol said the row exists and never said whose hand
# writes it or when: a linked checkout that writes it puts the ledger in a worktree the close deletes.
# Scoped to the Tracking section: the file names BACKLOG.md twice for unrelated reasons, so a check over
# the whole document answers "the authority is named" from a line about backlog entries and T-XXX IDs.
TRK24="$(awk '/^## Tracking/{f=1;next} f && /^## /{exit} f' "$QP24")"
a8=""
[ -n "$TRK24" ] || a8="$a8 section-absent"
printf '%s' "$TRK24" | grep -qi 'coordinator'                            || a8="$a8 writer"
printf '%s' "$TRK24" | grep -qiE 'closing ceremony|ceremony that closes' || a8="$a8 moment"
printf '%s' "$TRK24" | grep -qi 'backlog protocol'                       || a8="$a8 authority"
[ -z "$a8" ] \
  && ok "the quick close names the coordinator and the ceremony that writes its row" \
  || bad "the quick close names the coordinator and the ceremony that writes its row (missing:$a8)"

# A9 — the skeleton mirrors the roster, so it must mirror its heading level too: copied as written, the
# table lands nested under whatever section precedes it and stops being the roster's own.
a9=""
grep -q '^## Quick Tasks Completed'  "$QP24" || a9="$a9 level"
grep -q '^### Quick Tasks Completed' "$QP24" && a9="$a9 stale-level"
[ -z "$a9" ] \
  && ok "the quick-path skeleton heads Quick Tasks at the roster's own level" \
  || bad "the quick-path skeleton heads Quick Tasks at the roster's own level (missing:$a9)"

# A10 — carried over from a harness nothing ran. Four sections were asserted only there, so deleting it
# would have retired the one thing standing between them and a silent removal.
VP24="global/protocols/verify.md"
UP24="global/protocols/understand.md"
a10=""
grep -q  'Business Contract'     "$VP24" || a10="$a10 verify-contract-auditor"
grep -qi 'Skills Feedback'       "$VP24" || a10="$a10 verify-skills-feedback"
grep -q  'Investigation Closure' "$UP24" || a10="$a10 understand-closure"
grep -q  'EARS'                  "$UP24" || a10="$a10 understand-ears"
[ -z "$a10" ] \
  && ok "the retired harness's own anchors survive it" \
  || bad "the retired harness's own anchors survive it (missing:$a10)"

# A11 — the two repairs that had no guard at all. The identical falsehood is a hard failure for the front
# door under A1, so leaving these unasserted made the same claim policed in one document and free in
# another — and an unguarded prose repair is revertible with the suite green.
CU24="docs/customization.md"
a11=""
CON24="$(grep -i '| .continue. / .continua. |' "$CU24")"
EPH24="$(grep -i '`.ai-flow/STATE.md`' "$CU24")"
[ -n "$CON24" ] || a11="$a11 continue-row-absent"
[ -n "$EPH24" ] || a11="$a11 ephemeral-line-absent"
printf '%s' "$CON24" | grep -qiE 'own sheet|this checkout owns' || a11="$a11 continue-reads-sheet"
printf '%s' "$CON24" | grep -qi 'Resume from STATE.md'          && a11="$a11 stale-continue"
printf '%s' "$EPH24" | grep -qi 'roster'                        || a11="$a11 roster"
printf '%s' "$EPH24" | grep -qi 'session state'                 && a11="$a11 stale-session-state"
[ -z "$a11" ] \
  && ok "the customization guide names the sheet and the roster" \
  || bad "the customization guide names the sheet and the roster (missing:$a11)"

# A12 — the stale-install shape, in the direction that must hold. A6 declares a project directory holding
# the phase protocols invalid; a newcomer document that promises the installer creates one teaches the
# adopter to expect exactly what A6 calls stale. Counted across every document a newcomer reads, because
# the claim is not confined to the file this task happened to open.
a12="$(grep -rniE '\.ai-flow/[^ ]* (directory )?with protocols|\.ai-flow/ (directory )?(with|contains|holds) .*protocol' \
        README.md docs/ 2>/dev/null | wc -l | tr -d ' ')"
[ "$a12" = "0" ] \
  && ok "no newcomer document says the project's .ai-flow/ holds the phase protocols" \
  || bad "no newcomer document says the project's .ai-flow/ holds the phase protocols ($a12 line(s))"

# A13 — the refutation's reach. The engine refutes HIGH and hands MEDIUM and LOW to the phase
# unadjudicated; a document claiming every finding is refuted promises a guarantee the run does not make,
# and one still naming MEDIUM describes a stage that no longer exists — the same class of falsehood,
# reached by drift rather than by edit.
REF24="$(grep -ni 'refut' "$LC24")"
a13=""
[ -n "$REF24" ] || a13="$a13 refutation-absent"
printf '%s' "$REF24" | grep -qi 'HIGH'                          || a13="$a13 scope"
printf '%s' "$REF24" | grep -qiE 'HIGH and MEDIUM|HIGH/MEDIUM'  && a13="$a13 stale-medium"
printf '%s' "$REF24" | grep -qiE 'every (surviving )?finding'   && a13="$a13 overclaim"
[ -z "$a13" ] \
  && ok "the lifecycle states which findings are adversarially refuted" \
  || bad "the lifecycle states which findings are adversarially refuted (missing:$a13)"

# A14 — the ceremony as the newcomer reads it. Four claims the protocol makes and the summary dropped:
# move 1 approves the task's WORK and does so once, the ceremony ends by publishing, the last two moves
# run only when the front has no next task, and the single-front clause must not spell move numbers — the
# sibling guard derives them precisely because a move inserted anywhere renumbers the rest, and the copy a
# newcomer reads had them hardcoded with nothing reading them.
#
# The first claim used to be the coordinator's per-commit exception, and it is not a rename: that exception
# no longer exists anywhere in the engine, so a summary still carrying it would be describing a gate the
# protocol dropped. What replaces it is the fact that took its place.
a14=""
[ -n "$ARC24" ] || a14="$a14 section-absent"
printf '%s' "$ARC24" | grep -qiE 'validates the work|approves is the task|the task.s work' \
  || a14="$a14 move1-one-approval"
printf '%s' "$ARC24" | grep -qi 'publish'                            || a14="$a14 publishing-move"
printf '%s' "$ARC24" | grep -qiE 'no next task|has no next'          || a14="$a14 tail-conditional"
printf '%s' "$ARC24" | grep -qiE 'moves? [0-9], |moves? [0-9] and'   && a14="$a14 hardcoded-numbers"
[ -z "$a14" ] \
  && ok "the lifecycle ceremony carries its conditions and spells no move numbers" \
  || bad "the lifecycle ceremony carries its conditions and spells no move numbers (missing:$a14)"

# P1/P2 — restored from the harness this task retired. It carried the only assertions that the generic core
# stays generic: an origin-project identifier or the author's home path reaching global/ is the one defect
# that breaks the product's central promise for every adopter at once, and the migration that kept four of
# its anchors had missed these because they live inside a loop rather than on a literal check line.
# `\bisn\b` rather than a bare `isn`, which matches "isn't" — a guard that fires on ordinary prose is a
# guard the next person deletes.
PUR24='\bisn\b|residents|gate-manager|zoomin|esp32|firestore|ionic|angular|haiku|/architect|/ngrx|/data-access|/frontend-design'
p1=""
# `context` added when that protocol was born. `discover` was already outside this hand list before
# that, and is left alone: pre-existing ground, mentioned in the task's papers and not fixed here.
for f in backlog context execute lifecycle plan quick-path understand verify; do
  grep -qiE "$PUR24" "global/protocols/$f.md"                     && p1="$p1 $f:identifier"
  grep -qiE 'E-099|T-7[0-9][0-9]|T-9[0-9][0-9]' "global/protocols/$f.md" && p1="$p1 $f:foreign-task-id"
done
[ -z "$p1" ] \
  && ok "the swept phase protocols carry no origin-project identifier" \
  || bad "the swept phase protocols carry no origin-project identifier (found:$p1)"

P2OUT="$(purity_sweep . global)"; P2RC=$?
p2="$(printf '%s' "$P2OUT" | grep -c . | tr -d ' ')"
if [ "$P2RC" -ne 0 ]; then
  bad "the shipped engine carries no private project name and no author home path (the sweep could not run: not a repository, or it selected no file)"
elif [ "$p2" = "0" ]; then
  ok "the shipped engine carries no private project name and no author home path"
else
  bad "the shipped engine carries no private project name and no author home path ($p2 line(s))"
fi
