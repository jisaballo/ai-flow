echo "== C66: the papers outlive every stopping move, and the epic's plan is struck by the act that removes the row =="
# Generated in the Conform phase from understand.md's Verifiable Criteria.

BL66="$ROOT/global/protocols/backlog.md"
LC66="$ROOT/global/protocols/lifecycle.md"
VS66="$ROOT/test/validate.sh"

# Local extractors, for the reason C63 and C64 give for defining their own: this block must stand on its
# own, so an edit to another section's helper cannot silently change what these rows are about.
CLO66="$(awk '/^## Closing a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BL66")"
ARC66="$(awk '/^### After ARCHIVE \(single task\)/{f=1;next} (f && /^#+ /){f=0} f' "$BL66")"
EPC66="$(awk '/^### After Epic completion/{f=1;next} (f && /^#+ /){f=0} f' "$BL66")"
INV66="$(awk '/^### Invariants/{f=1;next} (f && /^#+ /){f=0} f' "$BL66")"
L966="$(awk '/^### 9\. ARCHIVE/{f=1;next} (f && /^#+ /){f=0} f' "$LC66")"

itm66() { printf '%s\n' "$2" | awk -v n="$1" '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==n' | tr '\n' ' ' | tr -s ' '; }
# The number of an item is derived by the file's ONE derivation, `step_no` -- the same one A5 below exists
# to certify. A local twin of it was what stood here, and a block whose own row requires that derivation to
# fail loudly cannot be the block that keeps a silent copy of it. What C63's standalone rule protects is the
# REGION each row reads and the patterns it reads for; those stay local below. The probes are silenced where
# a miss is a verdict this block reports in its own words, and every one of them is tested for.
no66() { step_no "$1" "$2" 2>/dev/null || true; }

NMV66="$(printf '%s\n' "$CLO66" | grep -cE '^[0-9]+\. ')"
NSTP66="$(printf '%s\n' "$ARC66" | grep -cE '^[0-9]+\. ')"
NPUB66="$(no66 'publish' "$CLO66")"
NDEL66="$(no66 "delet|papers are (destroyed|thrown)" "$CLO66")"
NROW66="$(no66 'remove task from backlog|removes? the task.s row' "$ARC66")"

# A1 -- the ceremony shall carry a move that deletes the task's papers, positioned after the publishing
# move and before the two moves conditioned on the front having no next task. Every position is DERIVED
# from the act, never spelled: a literal would land on a neighbour after the next insertion and pass.
a1_66=""
if [ -z "$NDEL66" ]; then
  a1_66=" [the ceremony carries no move that deletes the task's papers]"
elif [ -z "$NPUB66" ]; then
  a1_66=" [the ceremony carries no publishing move to position the deletion against]"
else
  [ "$NDEL66" -gt "$NPUB66" ] \
    || a1_66="$a1_66 [the deletion is move $NDEL66 and the publish is move $NPUB66, so a halted publish still destroys the papers]"
  [ "$NDEL66" -eq $((NMV66-2)) ] \
    || a1_66="$a1_66 [the deletion is move $NDEL66 of $NMV66, so it does not sit immediately before the two tail moves]"
  printf '%s' "$(itm66 "$NDEL66" "$CLO66")" | grep -qiE 'every (task )?close|each (task )?close' \
    || a1_66="$a1_66 [the deletion move does not say it runs at every close]"
  printf '%s' "$(itm66 "$NDEL66" "$CLO66")" | grep -qiE 'no next task|has no next|last task' \
    && a1_66="$a1_66 [the deletion move carries the tail's condition, so a front with a next task would keep its papers]"
  # The quick-task clause is the same 'a silence reads as a step somebody forgot' rule the distribution
  # and publish moves carry and that C6 and C64 guard for them. Unguarded it is deletable while green.
  printf '%s' "$(itm66 "$NDEL66" "$CLO66")" | grep -qi 'quick task' \
    || a1_66="$a1_66 [the move does not say what a quick task, which keeps no papers, leaves it to delete]"
fi
[ -z "$a1_66" ] && ok "A1 the papers are deleted by a ceremony move after the publish and before the tail" \
                || bad "A1 the papers are deleted by a ceremony move after the publish and before the tail ($a1_66)"

# A2 -- the single-task archive checklist shall carry no step that deletes the task's papers. The negative
# is the half that matters: a ceremony move added while the checklist keeps its own leaves two deletions.
# Each step FLATTENED, and against every wording the close uses for the act (`DEL_ACT`, one home) rather
# than one retired spelling on one physical line. The file hard-wraps, and the sentence anyone re-adding
# this step would copy is the ceremony move's own -- "The task's papers are deleted. `artifacts/T-XXX/`
# goes" -- which the line-oriented, case-sensitive `delete .artifacts` pattern that stood here matched
# nowhere at all. An absence leg is only as wide as the ways the claim can be written.
a2_66=""
i2_66=1
while [ "$i2_66" -le "$NSTP66" ]; do
  printf '%s' "$(itm66 "$i2_66" "$ARC66")" | grep -qiE "$DEL_ACT" \
    && a2_66="$a2_66 [step $i2_66 still deletes the papers the ceremony's move deletes]"
  i2_66=$((i2_66+1))
done
[ -z "$a2_66" ] && ok "A2 the archive checklist no longer deletes what it archived" \
                || bad "A2 the archive checklist no longer deletes what it archived ($a2_66)"

# A3 -- the step that removes the task's row shall, in the SAME ACT, strike the task's line in its epic's
# Execution Order block and set the epic's status where it still reads `backlog`. The coupling leg is an
# ordered co-occurrence and not two bare words, for the reason ARC7's label leg already records: prose
# that explicitly decouples them keeps both words and stays green.
a3_66=""
if [ -z "$NROW66" ]; then
  a3_66=" [the checklist has no step that removes the task's row]"
else
  ROW66="$(itm66 "$NROW66" "$ARC66")"
  printf '%s' "$ROW66" | grep -qiE 'same act[^.]{0,120}Execution Order|Execution Order[^.]{0,120}same act' \
    || a3_66="$a3_66 [the row's removal does not strike the epic's order line in the same act]"
  printf '%s' "$ROW66" | grep -qiE 'backlog.{0,80}active' \
    || a3_66="$a3_66 [the step does not set an epic still reading backlog to active]"
  printf '%s' "$ROW66" | grep -qiE 'no (numbered )?(order|Execution Order)|nothing to strike' \
    || a3_66="$a3_66 [the step says nothing about an epic whose block carries no order list]"
  # The FORM is the actionable content of the rule -- it is what stops the next three closes striking the
  # line three different ways, which is the inconsistency this row was raised over. Unasserted, the sha,
  # the one line of what shipped and the pointer to the archive are all revertible with the suite green.
  printf '%s' "$ROW66" | grep -qF '~~**T-XXX**~~' \
    || a3_66="$a3_66 [the step does not give the struck line the form the archived orders already use]"
  printf '%s' "$ROW66" | grep -qF 'archive/T-XXX/summary.md' \
    || a3_66="$a3_66 [the struck line does not point at the task's archived summary]"
fi
[ -z "$a3_66" ] && ok "A3 the act that removes the row strikes the epic's order line and sets its status" \
                || bad "A3 the act that removes the row strikes the epic's order line and sets its status ($a3_66)"

# A4 -- WHERE a harness row extracts a step of the single-task archive checklist, the row shall derive that
# step's number from the step's own act rather than name it. IB-001's finding, and this task's renumber is
# the failure it predicted. Each leg is self-avoiding: the literal that would match it is written here with
# a bracket where the digit would be, so this row cannot report itself.
a4_66=""
[ "$(grep -cE 'a41 [0-9]' "$VS66" | tr -d ' ')" -eq 0 ] \
  || a4_66=" [a41 still extracts a checklist step by its number]"
[ "$(grep -cE 'item23 [0-9]+ "\$ARCH' "$VS66" | tr -d ' ')" -eq 0 ] \
  || a4_66="$a4_66 [item23 still extracts a checklist step by its number]"
[ "$(grep -cE 'ARC7=.*\^[0-9]' "$VS66" | tr -d ' ')" -eq 0 ] \
  || a4_66="$a4_66 [ARC7 is still bounded by literal step numbers]"
[ "$(grep -cE 'ARC72.*\^[0-9]' "$VS66" | tr -d ' ')" -eq 0 ] \
  || a4_66="$a4_66 [C72 still pins a checklist position by a literal step number]"
[ -z "$a4_66" ] && ok "A4 no archive-checklist extractor names a step by its number" \
                || bad "A4 no archive-checklist extractor names a step by its number ($a4_66)"

# A5 -- IF the act an extractor keys on is not found, THEN the row shall fail and name the missing act.
# EXECUTED against the shared derivation rather than read off its source: C37 A6 records in this file what
# a text-only leg certifies, which is that the words are present. A default index is the trap IB-029 names.
a5_66=""
if ! type step_no >/dev/null 2>&1; then
  a5_66=" [no shared derivation exists, so each site still spells its own step number]"
else
  OUT5_66="$(step_no 'an act no step of any checklist performs' "$ARC66" 2>&1)"; rc5_66=$?
  [ "$rc5_66" -ne 0 ] \
    || a5_66=" [the derivation succeeds on an act no step performs, so a renumber lands silently]"
  printf '%s' "$OUT5_66" | grep -qF 'an act no step of any checklist performs' \
    || a5_66="$a5_66 [the failure does not name the missing act]"
  printf '%s' "$OUT5_66" | grep -qE '^[0-9]+$' \
    && a5_66="$a5_66 [the derivation still prints a number when the act is absent]"
fi
[ -z "$a5_66" ] && ok "A5 an extractor whose act is absent fails naming it" \
                || bad "A5 an extractor whose act is absent fails naming it ($a5_66)"

# A6 -- the ceremony's preamble shall state that the task's papers survive every move that can stop it.
# Scoped to the order paragraph and not to the section: the sentence that designates the sheet as the
# carrier already lives there, and a section-wide search would read it as the claim this row is about.
PRE66="$(printf '%s\n' "$CLO66" | awk '/^\*\*The order is the protection/{f=1} f&&/^1\. /{exit} f' | tr '\n' ' ' | tr -s ' ')"
a6_66=""
[ -n "$PRE66" ] || a6_66=" [the order paragraph could not be located]"
printf '%s' "$PRE66" | grep -qiE "(papers|sheet)[^.]{0,140}(surviv|outliv)" \
  || a6_66="$a6_66 [the preamble does not state that the papers survive]"
printf '%s' "$PRE66" | grep -qiE "(surviv|outliv)[^.]{0,80}(stop|move that can)" \
  || a6_66="$a6_66 [the preamble does not say what they survive: every move that can stop]"
[ -z "$a6_66" ] && ok "A6 the preamble states the papers outlive every stopping move" \
                || bad "A6 the preamble states the papers outlive every stopping move ($a6_66)"

# B1 -- WHEN the publishing move cannot complete, the ceremony shall stop with the papers still present.
# The ordering is A1's; what this row reads is the deletion move's own STATED REASON, which is where the
# claim "what can still fail is the merge" survived two insertions that falsified it (unknown 6).
b1_66=""
if [ -z "$NDEL66" ] || [ -z "$NPUB66" ]; then
  b1_66=" [the ceremony carries no deletion move, or no publishing move, to relate]"
else
  printf '%s' "$(itm66 "$NPUB66" "$CLO66")" | grep -qiE 'stops?\*{0,2} here|the ceremony \*\*stops\*\*' \
    || b1_66=" [the publishing move no longer stops the ceremony, so there is nothing for the papers to outlive]"
  DEL66="$(itm66 "$NDEL66" "$CLO66")"
  printf '%s' "$DEL66" | grep -qi 'merge' \
    || b1_66="$b1_66 [the deletion move's reason does not name the merge among what can still fail]"
  printf '%s' "$DEL66" | grep -qiE 'distribut|put into effect' \
    || b1_66="$b1_66 [the deletion move's reason does not name the distribution among what can still fail]"
  printf '%s' "$DEL66" | grep -qi 'publish' \
    || b1_66="$b1_66 [the deletion move's reason does not name the publish among what can still fail]"
fi
[ -z "$b1_66" ] && ok "B1 the publishing move's stop leaves the papers standing, and the deletion says why" \
                || bad "B1 the publishing move's stop leaves the papers standing, and the deletion says why ($b1_66)"

# O1 -- no citation of the deletion anywhere in `backlog.md` names it by a checklist step number; each
# names the ceremony's move. The positive is DERIVED from the deletion's own position, so a half-repair
# that renames the citations without moving the move fails here rather than reading green.
o1_66=""
if [ -z "$NDEL66" ]; then
  o1_66=" [no ceremony move for the citations to name]"
else
  [ "$(printf '%s\n' "$ARC66" | grep -c "move $NDEL66" | tr -d ' ')" -ge 2 ] \
    || o1_66=" [the checklist's two citations of the deletion do not both name move $NDEL66]"
  printf '%s\n' "$ARC66" | grep -qE 'step [0-9]+ below|in step [0-9]+\.' \
    && o1_66="$o1_66 [a checklist citation still names the deletion by a step number]"
  printf '%s\n' "$EPC66" | grep -q "move $NDEL66" \
    || o1_66="$o1_66 [the epic sweep does not cite the deletion as move $NDEL66]"
  printf '%s\n' "$EPC66" | grep -qE 'step [0-9]+ above' \
    && o1_66="$o1_66 [the epic sweep still cites the deletion by a step number]"
fi
[ -z "$o1_66" ] && ok "O1 every citation of the deletion names the ceremony's move" \
                || bad "O1 every citation of the deletion names the ceremony's move ($o1_66)"

# O2 -- the lifecycle map's ARCHIVE section carries the deletion as a move of its own and no longer inside
# the record move. Both halves: added beside a record move that still claims it, the map states it twice.
o2_66=""
NL66="$(printf '%s\n' "$L966" | grep -cE '^[0-9]+\. ')"
NLD66="$(no66 'delet' "$L966")"
NLR66="$(no66 'record' "$L966")"
[ -n "$L966" ] || o2_66=" [the lifecycle map's ARCHIVE section could not be located]"
[ "$NL66" -eq "$NMV66" ] \
  || o2_66="$o2_66 [the map lists $NL66 moves and the ceremony has $NMV66]"
[ -n "$NLD66" ] \
  || o2_66="$o2_66 [the map carries no move of its own for the deletion]"
# An absent record move is a verdict this row cannot reach, never a leg that quietly passes: wrapped in a
# bare `if [ -n ... ]`, "could not evaluate" and "evaluated clean" were the same answer. And the deletion
# must be a move of its OWN -- the derivation takes the first item whose lead line carries the word, so a
# record move that regained the deletion would answer both halves by itself and the pair would agree.
[ -n "$NLR66" ] \
  || o2_66="$o2_66 [the map carries no move that writes the record, so this row cannot read its second half]"
[ -n "$NLD66" ] && [ "$NLD66" = "$NLR66" ] \
  && o2_66="$o2_66 [the map's deletion is the record move itself, not a move of its own]"
if [ -n "$NLR66" ]; then
  printf '%s' "$(itm66 "$NLR66" "$L966")" | grep -qiE 'delet' \
    && o2_66="$o2_66 [the map's record move still claims the deletion]"
fi
[ -z "$o2_66" ] && ok "O2 the lifecycle map lists the deletion as a move of its own" \
                || bad "O2 the lifecycle map lists the deletion as a move of its own ($o2_66)"

# O3 -- the `artifacts/` invariant states that a task whose close halted is in flight. Without it the
# invariant reads as violated by exactly the state this task creates on purpose.
o3_66=""
[ -n "$INV66" ] || o3_66=" [the invariants section could not be located]"
printf '%s' "$INV66" | grep -qiE 'halted|interrupted' \
  || o3_66="$o3_66 [the invariant does not admit a close that halted]"
printf '%s' "$INV66" | grep -qiE 'in flight|still working|not finished' \
  || o3_66="$o3_66 [the invariant does not say such a task is still in flight]"
[ -z "$o3_66" ] && ok "O3 the artifacts invariant admits a halted close" \
                || bad "O3 the artifacts invariant admits a halted close ($o3_66)"

# O4 -- the epic sweep's `artifacts/` check names the halted close among the causes it cannot tell apart.
# All three, because a diagnosis naming two of three reports a halted close as a task closed without its
# checklist -- which is the wrong instruction, not merely an incomplete one.
SWP66="$(printf '%s\n' "$EPC66" | awk '/retains no folder/{f=1} f&&/^[0-9]+\. /&&!/retains no folder/{exit} f' | tr '\n' ' ' | tr -s ' ')"
o4_66=""
[ -n "$SWP66" ] || o4_66=" [the sweep's artifacts check could not be located]"
printf '%s' "$SWP66" | grep -qiE 'without its checklist' \
  || o4_66="$o4_66 [the diagnosis drops the task closed without its checklist]"
printf '%s' "$SWP66" | grep -qiE 'still open' \
  || o4_66="$o4_66 [the diagnosis drops the front that is still open]"
printf '%s' "$SWP66" | grep -qiE 'halted|interrupted' \
  || o4_66="$o4_66 [the diagnosis drops the close that halted after the record]"
[ -z "$o4_66" ] && ok "O4 the sweep names all three causes of a surviving folder" \
                || bad "O4 the sweep names all three causes of a surviving folder ($o4_66)"
