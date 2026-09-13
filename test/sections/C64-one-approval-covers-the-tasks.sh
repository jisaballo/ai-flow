echo ""

echo "== C64: one approval covers the task's work, and the close ends by publishing the trunk =="
# Conformance: today the coordinator asks before every commit, and the close ends without publishing -- so
# a three-step task stops three times and a task recorded as done can sit unpublished on the machine while
# the next one starts. Generated in the Conform phase from understand.md's Verifiable Criteria; each row
# names the criterion it comes from.
BL64="$ROOT/global/protocols/backlog.md"
MAN64="$ROOT/global/CLAUDE.md"
EXE64="$ROOT/global/protocols/execute.md"
QP64="$ROOT/global/protocols/quick-path.md"

# The ceremony's moves, extracted locally. A local pair rather than C17's `clomove`, for the reason C63
# gives for defining its own extractors: this block must stand on its own, so an edit to another section's
# helper cannot silently change what these rows are about.
CLO64="$(awk '/^## Closing a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BL64")"
mv64() { printf '%s\n' "$CLO64" | awk -v n="$1" '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==n' | tr '\n' ' ' | tr -s ' '; }
NMV64="$(printf '%s\n' "$CLO64" | grep -cE '^[0-9]+\. ')"
# The publishing move is located by its own ACT and never by arithmetic. Keyed on the number, every row
# below would land on the distribution move while the publishing move does not exist -- and B4 would pass
# on the neighbour's own stop sentence, which is a row certifying a fact nobody wrote.
NPUB64="$(printf '%s\n' "$CLO64" | awk '/^[0-9]+\. /{h=tolower($0); if (h ~ /publish/ && h !~ /distribut/ && h !~ /effect/) {print $0+0; exit}}')"
PUB64=""
[ -n "$NPUB64" ] && PUB64="$(mv64 "$NPUB64")"
# The papers' deletion, located by its act for the same reason: it is what now sits between the publish
# and the tail, and every leg that used to measure the publish against the end measures it through this.
NDEL64="$(step_no 'delet' "$CLO64")" || NDEL64=""

# A1 -- the gate's home. The system shall state the commit gate in `global/protocols/backlog.md` and not
# in `global/CLAUDE.md`. Both halves on one row: the positive alone leaves the manual free to keep its own
# copy, which is the drift this task exists to remove, and the negative alone leaves the rule homeless.
# The positive is RELATIONAL -- "commits are free" already occurs in move 1, scoped to a front, so a bare
# presence check was green before a line of this task existed.
GATE64="$(printf '%s' "$CLO64" | tr -s ' \n' '  ')"
MSEC64="$(msect "$MAN64" '^### Commit Protocol' | tr -s ' \n' '  ')"
a1_64=""
[ -n "$CLO64" ] || a1_64=" [the closing ceremony could not be located: every row below would be about an empty string]"
printf '%s' "$GATE64" | grep -qiE 'commits are free[^.]{0,90}(every checkout|either checkout|wherever|whichever)' \
  || a1_64="$a1_64 [the closing protocol does not state that commits are free per step in every checkout]"
printf '%s' "$GATE64" | grep -qiE 'immediately|before the next task|never .{0,40}next task first' \
  || a1_64="$a1_64 [the closing protocol does not carry the post-commit obligation that left the manual]"
printf '%s' "$MSEC64" | grep -qiE 'do not commit until|only commit when|stays uncommitted|still ask first' \
  && a1_64="$a1_64 [the manual still states when to commit, so the rule has two homes]"
[ -z "$a1_64" ] && ok "A1 the commit gate is stated by the ceremony that enforces it, and the manual states none" \
                || bad "A1 the commit gate is stated by the ceremony that enforces it, and the manual states none ($a1_64)"

# A2 -- WHEN the closing ceremony is read, the system shall yield validate -> collect -> merge -> record
# -> distribute -> publish -> dismantle -> roster. The count is READ from the protocol, never enumerated:
# a literal bound stops at its last index, so a move appended past it is never looked at.
seq64=""
i64=1
while [ "$i64" -le "$NMV64" ]; do
  case "$(printf '%s\n' "$CLO64" | grep -E "^$i64\. " | head -1 | tr 'A-Z' 'a-z')" in
    *valid*)               seq64="$seq64 V" ;;
    *collect*|*harvest*)   seq64="$seq64 C" ;;
    *merge*)               seq64="$seq64 M" ;;
    *distribut*|*effect*)  seq64="$seq64 X" ;;
    # Ahead of the record arm for the reason C17's twin states: a lead sentence carrying another role's
    # word would file this move as that role, and the sequence would read green over the wrong reading.
    *publish*)             seq64="$seq64 P" ;;
    *record*|*ledger*)     seq64="$seq64 L" ;;
    # The papers' own move, ahead of the dismantling arm: this head speaks of a checkout, and the arm
    # that owns that word would file the deletion as the dismantling and read the sequence green.
    *delet*)               seq64="$seq64 K" ;;
    *dismantl*|*worktree*) seq64="$seq64 D" ;;
    *roster*|*row*)        seq64="$seq64 R" ;;
    *)                     seq64="$seq64 ?" ;;
  esac
  i64=$((i64+1))
done
[ "$seq64" = " V C M L X P K D R" ] \
  && ok "A2 the ceremony publishes between the distribution and its tail" \
  || bad "A2 the ceremony publishes between the distribution and its tail (moves unnamed or out of order:$seq64)"

# A3 -- the "no next task" condition sits on the two TAIL moves and not on the publishing move, and each
# position is DERIVED from the ceremony's own move count. Keying a leg on a literal number is the failure
# IB-001 names: after an insertion the leg lands on a different move and passes for the wrong reason.
a3_64=""
if [ -z "$NPUB64" ]; then
  a3_64=" [the ceremony carries no publishing move]"
else
  # The publish is followed by the papers' deletion and then the tail, so its distance from the end is
  # three and not two. Both ends stay derived: what this leg is about is that the publish precedes every
  # unconditional move that can still stop the ceremony, and a literal would have to be rewritten by the
  # next insertion rather than fail on it.
  [ -n "$NDEL64" ] && [ "$NPUB64" -lt "$NDEL64" ] && [ "$NDEL64" -eq $((NMV64-2)) ] \
    || a3_64="$a3_64 [the publish is move $NPUB64 and the deletion move $NDEL64 of $NMV64, so the publish does not precede the deletion that precedes the tail]"
  printf '%s' "$PUB64" | grep -qiE 'every (task )?close|each (task )?close|always' \
    || a3_64="$a3_64 [the publishing move does not say it runs at every close]"
  printf '%s' "$PUB64" | grep -qiE 'no next task|has no next|last task' \
    && a3_64="$a3_64 [the publishing move carries the tail's condition, so a front with a next task would never publish]"
fi
printf '%s' "$(mv64 $((NMV64-1)))" | grep -qiE 'no next task|has no next|last task' \
  || a3_64="$a3_64 [the first tail move drops its condition]"
printf '%s' "$(mv64 "$NMV64")" | grep -qiE 'no next task|has no next|last task' \
  || a3_64="$a3_64 [the second tail move drops its condition]"
[ -z "$a3_64" ] && ok "A3 the tail keeps its condition at its new position, and the publishing move does not take it" \
                || bad "A3 the tail keeps its condition at its new position, and the publishing move does not take it ($a3_64)"

# A4 -- WHILE a hard stop forbids publishing without validation, the system shall name the approval that
# lifts it. Asserted on the stop's own bullet: a stop that merely cross-references the gate still reads
# unconditionally, which is the state `mf_commit_stop` was written to catch and this row inherits.
NB64="$(mbul "$MAN64" '^### Never' 'without user validation')"
a4_64=""
[ -n "$NB64" ] || a4_64=" [no hard stop about validation was found]"
printf '%s' "$NB64" | grep -qiE 'publish|push' \
  || a4_64="$a4_64 [the hard stop still forbids committing, which the engine now does freely per step]"
printf '%s' "$NB64" | grep -qiE 'closing ceremony|move 1|backlog protocol' \
  || a4_64="$a4_64 [it does not name where the approval that lifts it is given]"
[ -z "$a4_64" ] && ok "A4 the hard stop forbids publishing without validation and names the approval that lifts it" \
                || bad "A4 the hard stop forbids publishing without validation and names the approval that lifts it ($a4_64)"

# A5 -- IF closing move 1 is reworded to drop the approval it now covers in both kinds of checkout, THEN
# the suite shall fail. Two-armed like C46's rows: the fact present must match, and the fact removed must
# not -- the decoy leaves "the work" standing in a neighbouring sentence, so a guard answered by mere
# co-presence of "validates" and "work" is caught here rather than years later by the edit that hollows it.
M1_64="$(mv64 1)"
PAT64='(validates|approves|validation of) the work'
if [ -z "$M1_64" ]; then
  bad "A5 closing move 1 states the one approval that covers the task's work in either checkout (move not extracted)"
else
  # A plain substitution, with no alternation: BSD sed's basic regex has no `\|`, so a pattern written
  # with one silently matches nothing and the row reports its own mutation as unapplied rather than
  # judging the fact. The arm below catches exactly that, which is how this was found.
  MUT64="$(printf '%s' "$M1_64" | sed 's/validates the work/validates the branch/')"
  if ! printf '%s' "$M1_64" | grep -qiE "$PAT64"; then
    bad "A5 closing move 1 states the one approval that covers the task's work in either checkout (absent from the protocol)"
  elif [ "$MUT64" = "$M1_64" ]; then
    bad "A5 closing move 1 states the one approval that covers the task's work in either checkout (mutation did not apply)"
  elif ! printf '%s' "$MUT64" | grep -qiE "$PAT64"; then
    ok "A5 closing move 1 states the one approval that covers the task's work in either checkout"
  else
    bad "A5 closing move 1 states the one approval that covers the task's work in either checkout (matched from a neighbour)"
  fi
fi

# B1 + O2 -- WHEN a plan step passes its Verify command, the system shall commit it without asking for
# approval, and the execute loop shall carry the atomic format and the tests-per-commit rule that left the
# manual. The negative leg is the one that matters: a step 4 that commits AND still cites the old gate is
# a loop stating two rules, which is exactly the drift the relocation is for.
ST4_64="$(awk '/^### Execute Step Protocol/{f=1;next} (f && /^#+ /){exit} f' "$EXE64" | awk '/^4\. /{g=1} g' | tr '\n' ' ' | tr -s ' ')"
b1_64=""
[ -n "$ST4_64" ] || b1_64=" [step 4 of the Execute Step Protocol could not be extracted]"
printf '%s' "$ST4_64" | grep -qiE 'commit the step|commits the step|commit it' \
  || b1_64="$b1_64 [step 4 does not commit the step]"
printf '%s' "$ST4_64" | grep -qiE 'do not commit|user must validate|Commit Protocol from CLAUDE' \
  && b1_64="$b1_64 [step 4 still withholds the commit for an approval]"
printf '%s' "$ST4_64" | grep -qi 'type(scope)' \
  || b1_64="$b1_64 [step 4 does not carry the atomic commit format that left the manual]"
printf '%s' "$ST4_64" | grep -qiE 'must pass|passing tests|tests pass' \
  || b1_64="$b1_64 [step 4 does not carry the tests-per-commit rule that left the manual]"
[ -z "$b1_64" ] && ok "B1 the execute loop commits its step, cites no approval, and holds the two rules that left the manual" \
                || bad "B1 the execute loop commits its step, cites no approval, and holds the two rules that left the manual ($b1_64)"

# B1b -- the lifecycle map does not contradict the loop that owns the commit. The map is what a session
# opens at activation, so a retired rule surviving there is the copy that wins in practice. Nothing read
# it: before this leg, `grep -n 'Stage changes' test/validate.sh` returned zero rows, while B1 above bans
# the identical idiom one file over -- path-scoped, so none of it reached the map.
#
# Judged on the SECTION and never on its numbered list, because the list is scheduled to go: the map's own
# prune reduces this section to purpose, output, gate and a route, and a leg reading the list would go red
# on that change for doing exactly the right thing. What survives both shapes is the pair below -- the map
# must not tell the reader to withhold the commit, and must point at the file that owns it. Both halves:
# the negative alone passes on a section emptied of everything, the positive alone on a section that
# routes and still says not to commit.
LCM64="$ROOT/global/protocols/lifecycle.md"
LC64="$(awk '/^### 7\. EXECUTE/{f=1;next} (f && /^#+ /){exit} f' "$LCM64" | tr '\n' ' ' | tr -s ' ')"
b1b_64=""
[ -n "$LC64" ] || b1b_64=" [the map's EXECUTE section could not be extracted]"
printf '%s' "$LC64" | grep -qiE 'stage changes|do not commit' \
  && b1b_64="$b1b_64 [the map still withholds the commit, contradicting execute.md step 4]"
printf '%s' "$LC64" | grep -qi 'execute\.md' \
  || b1b_64="$b1b_64 [the map neither commits the step nor routes to the loop that owns the commit]"
[ -z "$b1b_64" ] && ok "B1b the lifecycle map does not contradict the loop that owns the commit" \
                 || bad "B1b the lifecycle map does not contradict the loop that owns the commit ($b1b_64)"

# B1c -- freeing the commit must not cancel a gate this loop does not own. The clause replaced here
# ("nothing is asked between steps") was wider than the fact step 4 needed, which is that the COMMIT seeks
# no approval. Read literally it also cancelled Supervised's rule -- a step-boundary gate, never the
# commit's -- which `lifecycle.md`'s autonomy table owns and this epic keeps rather than retires (T-098
# moves it into the execute skill; T-104 leaves the table standing until it does). The positive leg is
# what makes this more than a banned phrase: step 4 has to CEDE the gate, not merely stop mentioning it.
b1c_64=""
[ -n "$ST4_64" ] || b1c_64=" [step 4 of the Execute Step Protocol could not be extracted]"
printf '%s' "$ST4_64" | grep -qiE 'nothing is asked between steps' \
  && b1c_64="$b1c_64 [step 4 cancels every between-step gate, including the one the autonomy table owns]"
printf '%s' "$ST4_64" | grep -qiE 'lifecycle\.md|autonomy table' \
  || b1c_64="$b1c_64 [step 4 does not cede the between-step gate to the level's owner]"
[ -z "$b1c_64" ] && ok "B1c the execute loop frees the commit without cancelling the level's own gate" \
                 || bad "B1c the execute loop frees the commit without cancelling the level's own gate ($b1c_64)"

# B2 -- WHEN the ceremony reaches its publishing move, the system shall publish the trunk and report what
# it published. The report is the leg, not the push: a move that pushes silently leaves the operator with
# no way to tell a publish that happened from one that was skipped -- the same reason move 5 states its
# own no-op out loud.
b2_64=""
if [ -z "$PUB64" ]; then
  b2_64=" [the ceremony carries no publishing move]"
else
  printf '%s' "$PUB64" | grep -qiE 'trunk' \
    || b2_64="$b2_64 [the move does not name the trunk as what it publishes]"
  printf '%s' "$PUB64" | grep -qiE 'report|says what|names what|shows what' \
    || b2_64="$b2_64 [the move publishes without reporting what it published]"
fi
[ -z "$b2_64" ] && ok "B2 the publishing move publishes the trunk and reports what it published" \
                || bad "B2 the publishing move publishes the trunk and reports what it published ($b2_64)"

# B3 -- IF the trunk has no remote to publish to, THEN the system shall say so and continue the ceremony.
# The RELATION is the fact: "says so" alone would be satisfied by the stop rule one sentence away, and
# "continues" alone by any sentence about the ceremony carrying on.
b3_64=""
if [ -z "$PUB64" ]; then
  b3_64=" [the ceremony carries no publishing move]"
else
  printf '%s' "$PUB64" | grep -qiE 'no remote|remote .{0,30}(does not|cannot) resolve|no remote trunk|unresolvable' \
    || b3_64="$b3_64 [the move does not name the case where there is nothing to publish to]"
  printf '%s' "$PUB64" | grep -qiE '(says?|states?) so[^.]{0,60}(continue|carries on|does not stop)|continue[^.]{0,60}says? so' \
    || b3_64="$b3_64 [it does not say that an absent remote is stated and the ceremony continues]"
fi
[ -z "$b3_64" ] && ok "B3 an unresolvable remote trunk is stated, and the ceremony continues" \
                || bad "B3 an unresolvable remote trunk is stated, and the ceremony continues ($b3_64)"

# B4 -- IF the publish cannot complete, THEN the system shall stop the ceremony with the front's roster
# row still in place. The same shape move 5 already uses for an unprovable distribution, and the reason is
# the same: the record is written by then, so the row is the only thing left saying work remains.
b4_64=""
if [ -z "$PUB64" ]; then
  b4_64=" [the ceremony carries no publishing move]"
else
  printf '%s' "$PUB64" | grep -qiE 'stops?|halts?' \
    || b4_64="$b4_64 [a refused publish does not stop the ceremony]"
  printf '%s' "$PUB64" | grep -qiE 'roster row|row (is )?still|row in place' \
    || b4_64="$b4_64 [it does not leave the front's roster row in place, so nothing is left saying work remains]"
fi
[ -z "$b4_64" ] && ok "B4 a refused publish stops the ceremony with the roster row in place" \
                || bad "B4 a refused publish stops the ceremony with the roster row in place ($b4_64)"

# O4 -- the quick path's guarantee sits at the close, not before each commit. Both halves, because the
# negative alone is satisfied by deleting the bullet: a guarantee removed is not a guarantee moved.
QG64="$(msect "$QP64" '^## Guarantees Maintained' | tr -s ' \n' '  ')"
o4_64=""
[ -n "$QG64" ] || o4_64=" [the Guarantees section could not be located]"
printf '%s' "$QG64" | grep -qiE 'validation before commit|validate before commit' \
  && o4_64="$o4_64 [the guarantee still sits before each commit]"
printf '%s' "$QG64" | grep -qiE 'at the close|before the close|closing ceremony|at its close' \
  || o4_64="$o4_64 [the guarantee does not name the close as where the approval sits]"
[ -z "$o4_64" ] && ok "O4 the quick path's approval sits at the close, not before each commit" \
                || bad "O4 the quick path's approval sits at the close, not before each commit ($o4_64)"
