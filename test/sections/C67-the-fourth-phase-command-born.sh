echo "== C67: the fourth phase command, born routing, and the one home its siblings route to =="
# Generated in the Conform phase from understand.md's Verifiable Criteria. Every row reads a document
# rather than drives a mechanism -- which is what this change is, prose four actors obey -- so each is
# built to fail with THE FACT THAT WAS LOST named, never with "the text changed".

BL67="$ROOT/global/protocols/backlog.md"
EX67="$ROOT/global/protocols/execute.md"
MAP67="$ROOT/global/protocols/lifecycle.md"
PS67="$ROOT/global/skills/plan/SKILL.md"
FE67="$ROOT/global/skills/execute/SKILL.md"
INS67="$ROOT/install.sh"
C67_SKILLS="understand plan verify execute"
PRECOND67="The phase precondition"

# Local extractors, for the reason C63 and C66 give for defining their own: this block must stand on its
# own, so an edit to another section's helper cannot silently change what these rows are about.
PBLK67="$(awk -v h="^### $PRECOND67" '$0 ~ h {f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^#+ /){f=0} f' "$BL67")"
pcl67() { printf '%s\n' "$PBLK67" | awk -v s="$1" '/^- \*\*/{ if(g) exit; g=($0 ~ s) } g' | tr '\n' ' '; }
LEAD67="$(printf '%s\n' "$PBLK67" | awk '/^- \*\*/{exit} {print}' | tr '\n' ' ')"
AUT67="$(pcl67 'autonomy read')"
POS67="$(pcl67 'Accepted positions')"
CLN67="$(pcl67 'A clean pass')"
HEAD67="$(awk '/^## /{exit} {print}' "$EX67" 2>/dev/null | tr '\n' ' ')"
LOOP67="$(awk '/^### Execute Step Protocol/{f=1;next} (f && /^#+ /){f=0} f' "$EX67" 2>/dev/null | tr '\n' ' ')"
SKP67="$(awk '/^## Skills per Step/{f=1;next} (f && /^## /){f=0} f' "$EX67" 2>/dev/null | tr '\n' ' ')"
SUP67="$(grep -E "^\| *\*\*Supervised\*\*" "$MAP67" 2>/dev/null | head -1)"
st67() { awk -v s="^$2\\\\. " -v e="^$(($2 + 1))\\\\. " '$0 ~ e {f=0} $0 ~ s {f=1} f' "$1" | tr '\n' ' '; }

# E0 -- the regions all extract. Drawn before any verdict below, because a row read over an empty string
# reports on nothing while looking green: five facts share the precondition block alone.
e0_67=""
[ -n "$PBLK67" ] || e0_67="$e0_67 [the phase precondition block did not extract]"
[ -n "$LEAD67" ] || e0_67="$e0_67 [the precondition's lead paragraph did not extract]"
[ -n "$AUT67" ]  || e0_67="$e0_67 [the autonomy-read bullet did not extract]"
[ -n "$POS67" ]  || e0_67="$e0_67 [the accepted-positions bullet did not extract]"
[ -n "$CLN67" ]  || e0_67="$e0_67 [the clean-pass bullet did not extract]"
[ -n "$HEAD67" ] || e0_67="$e0_67 [the rulebook has no text above its first heading]"
[ -n "$LOOP67" ] || e0_67="$e0_67 [the rulebook's step loop did not extract]"
[ -n "$SKP67" ]  || e0_67="$e0_67 [the rulebook's skills-per-step section did not extract]"
[ -n "$SUP67" ]  || e0_67="$e0_67 [the map has no Supervised row in its level table]"
[ -z "$e0_67" ] && ok "E0 every region C67 reads extracts" || bad "E0 every region C67 reads extracts ($e0_67)"

# A1 -- CONTROL. The engine shall ship exactly the phase-command set its installer delivers, asserted in
# BOTH directions. Green from the start by construction: the four commands on disk are the four the
# installer names. It earns its row because the set is about to CHANGE and nothing in this suite reads it
# -- the task arrived diagnosing `EXPECT37`, which is the PROTOCOL set, and the only declaration of the
# command set is the installer's own list, consumed twice and asserted nowhere. What catches the miss
# today is a runtime hook, not a leg, so a command added and never delivered ships broken.
SKL67="$(grep -E '^SKILLS=' "$INS67" 2>/dev/null | head -1 | sed -E 's/^SKILLS="([^"]*)".*/\1/')"
DIR67="$(ls "$ROOT/global/skills" 2>/dev/null | sort | tr '\n' ' ')"
ECHO67="$(grep -E 'Skills installed' "$INS67" 2>/dev/null | head -1)"
a1_67=""
# Both extractors prove they found their class before a verdict is drawn from either: an empty listing
# would otherwise satisfy the `extra` leg and report a clean engine.
[ -n "$SKL67" ] || a1_67=" [the installer declares no command list, so there is nothing to assert against]"
[ -n "$DIR67" ] || a1_67="$a1_67 [the command directory listed nothing]"
if [ -n "$SKL67" ] && [ -n "$DIR67" ]; then
  x67=""; m67=""
  for d67 in $DIR67; do
    case " $SKL67 " in *" $d67 "*) ;; *) x67="$x67 $d67" ;; esac
  done
  for n67 in $SKL67; do
    case " $DIR67 " in *" $n67 "*) ;; *) m67="$m67 $n67" ;; esac
    [ -f "$ROOT/global/skills/$n67/SKILL.md" ] || m67="$m67 $n67(no SKILL.md)"
  done
  [ -z "$x67" ] || a1_67="$a1_67 [shipped and never delivered:$x67]"
  [ -z "$m67" ] || a1_67="$a1_67 [delivered and never shipped:$m67]"
  for n67 in $SKL67; do
    printf '%s' "$ECHO67" | grep -q "/$n67" \
      || a1_67="$a1_67 [the line the installer prints does not name $n67, so an operator cannot tell what was installed]"
  done
fi
[ -z "$a1_67" ] && ok "A1 control: the engine ships exactly the phase-command set its installer delivers" \
                || bad "A1 control: the engine ships exactly the phase-command set its installer delivers ($a1_67)"

# A1b -- ADDED DURING VERIFY, and it is the other half of what A1 claimed. A1 asserts the set in both
# directions between the installer's list, the shipped directory and the line the installer prints, and
# its own comment justified that reach by stating the set was "consumed twice and asserted nowhere". The
# set is consumed FIVE times: those two, plus the tree diagram of what lands in `~/.claude`, plus the
# README's own table of the phase commands, plus the line getting-started tells a new adopter. All three
# documents were exactly correct before this task and were falsified by it -- the front door named a
# command set the installer no longer delivered, and A1 was green throughout, because A1 cannot see a
# document.
#
# Its own row rather than three more legs on A1: A1's assert direction was frozen at Conform over the
# installer and the directory, and a document is a new surface class rather than a sharper reading of
# those two. Keyed on the PHASE commands (`C67_SKILLS`) and not on the installer's whole list, because the
# README's table is a table of phases and `discover` is deliberately not in it -- a leg over `SKILLS`
# would demand a row the table is right not to have.
RDM67="$ROOT/README.md"
GST67="$ROOT/docs/getting-started.md"
a1b_67=""
for f1b in "$RDM67" "$GST67"; do
  [ -s "$f1b" ] || a1b_67="$a1b_67 [${f1b#$ROOT/} is missing or empty, so this row would report on nothing]"
done
if [ -s "$RDM67" ] && [ -s "$GST67" ]; then
  # The tree diagram of the installed engine, and the adopter's first list of what the skills give them:
  # both enumerate, so both go stale silently. Located by their own anchors rather than by line number.
  TREE67="$(grep -E '^.{0,8}skills/ ' "$RDM67" | head -1)"
  GSL67="$(grep -F 'The skills give you' "$GST67" | head -1)"
  [ -n "$TREE67" ] || a1b_67="$a1b_67 [README's installed-engine tree no longer has a skills line to check]"
  [ -n "$GSL67" ]  || a1b_67="$a1b_67 [getting-started no longer tells the adopter what the skills give them]"
  for n1b in $C67_SKILLS; do
    [ -z "$TREE67" ] || printf '%s' "$TREE67" | grep -q "/$n1b" \
      || a1b_67="$a1b_67 [README's tree of the installed engine does not name /$n1b]"
    [ -z "$GSL67" ] || printf '%s' "$GSL67" | grep -q "/$n1b" \
      || a1b_67="$a1b_67 [getting-started does not tell the adopter about /$n1b]"
    grep -qE "^\| *\`/$n1b\`" "$RDM67" \
      || a1b_67="$a1b_67 [README's table of the phase commands has no row for /$n1b]"
  done
fi
[ -z "$a1b_67" ] && ok "A1b every document that declares the command set names every phase command" \
                 || bad "A1b every document that declares the command set names every phase command ($a1b_67)"

# A2 -- per command, over the step that runs at its ENTRY. The route is a KEEP leg, green from the start:
# all three siblings already cite the block. What is RED is the pair of negatives -- the shared
# obligations still standing in each command, which after this task have exactly one home. Scoped to step
# 2 with a local extractor and not file-wide, because a file-wide negative is reddened by any later
# mention and a file-wide positive is satisfied by one.
for s67 in $C67_SKILLS; do
  f67="$ROOT/global/skills/$s67/SKILL.md"
  if [ ! -f "$f67" ]; then
    bad "A2 $s67 routes the supervision read and states only its own phase's change (file missing: global/skills/$s67/SKILL.md)"
    continue
  fi
  e67="$(st67 "$f67" 2)"
  r67=""
  [ -n "$e67" ] || r67=" [step 2 could not be extracted]"
  printf '%s' "$e67" | grep -q "$PRECOND67" \
    || r67="$r67 [its entry does not route to the block that owns the supervision read]"
  printf '%s' "$e67" | grep -qiE 'sheet it was read from|read from the sheet|the sheet it came from' \
    && r67="$r67 [it still carries the obligation to name the source, which now has one home and four routes]"
  printf '%s' "$e67" | grep -qi 'default' \
    && r67="$r67 [it still carries the absent-level default, which now has one home and four routes]"
  [ -z "$r67" ] && ok "A2 $s67 routes the supervision read and states only its own phase's change" \
                || bad "A2 $s67 routes the supervision read and states only its own phase's change ($r67)"
done

# A3 -- the home, counted rather than merely found. The positive half is green today; what this row adds
# is that the count of commands carrying the same obligation is ZERO. File-wide on purpose here, unlike
# A2: "in no phase command" is a fact about the whole file, not about one step of it.
# The count covers BOTH shared obligations, and the second one was added during Verify to match the
# assert direction this row was frozen with -- "the count of commands carrying the same obligation must be
# zero", of a bullet that obliges all three. As implemented it counted the SOURCE phrase only, while the
# absent-level default was forbidden by A2 alone, which is scoped to step 2. So the sentence this task cut
# from three commands could have been restored verbatim at step 3 of any of them with both rows green --
# the second home regrowing one step below where anything was looking.
n67=0; car67=""
for s67 in $C67_SKILLS; do
  f67="$ROOT/global/skills/$s67/SKILL.md"
  [ -f "$f67" ] || continue
  if grep -qiE 'sheet it was read from|read from the sheet|the sheet it came from' "$f67"; then
    n67=$((n67+1)); car67="$car67 global/skills/$s67/SKILL.md(source)"
  fi
  if grep -qiE '(declares no|no level|no autonomy|absent)[^.]*Guided' "$f67"; then
    n67=$((n67+1)); car67="$car67 global/skills/$s67/SKILL.md(default)"
  fi
done
a3_67=""
printf '%s' "$AUT67" | grep -qiE 'names the level|name the level|state the level' \
  || a3_67=" [the protocol's bullet no longer obliges the command to name the level]"
printf '%s' "$AUT67" | grep -qiE 'source it read|where it read|and the source' \
  || a3_67="$a3_67 [the protocol's bullet no longer obliges the command to name the source]"
printf '%s' "$AUT67" | grep -qi 'default' \
  || a3_67="$a3_67 [the protocol's bullet no longer obliges the command to announce the default]"
[ "$n67" -eq 0 ] || a3_67="$a3_67 [$n67 second home(s) of a shared obligation, which the cut left with exactly one each:$car67]"
[ -z "$a3_67" ] && ok "A3 the shared obligations of the supervision read live in the protocol and in no command" \
                || bad "A3 the shared obligations of the supervision read live in the protocol and in no command ($a3_67)"

# A4 -- the fourth command shall not SPELL the position it accepts. Keyed on the all-caps position token,
# which is how this engine writes a position everywhere it writes one; a command that names it has grown
# the second home of the accepted set that the precondition block exists to prevent.
a4_67=""
if [ ! -f "$FE67" ]; then
  a4_67=" [the command does not exist]"
else
  e4_67="$(st67 "$FE67" 2)"
  [ -n "$e4_67" ] || a4_67=" [its step 2 could not be extracted]"
  printf '%s' "$e4_67" | grep -q "$PRECOND67" \
    || a4_67="$a4_67 [it does not route to the owner of the accepted positions]"
  printf '%s' "$e4_67" | grep -qE '\bEXECUTE\b' \
    && a4_67="$a4_67 [step 2 spells the position it accepts, so the accepted set has a second home]"
fi
[ -z "$a4_67" ] && ok "A4 the execute command does not spell the position it accepts" \
                || bad "A4 the execute command does not spell the position it accepts ($a4_67)"

# A5 -- the gate's HOME, both halves on one row because either alone certifies half a move: the rulebook
# gaining the mechanics while the map keeps them is two copies, and the map losing them while the rulebook
# never gained them is a rule with no statement at all.
a5_67=""
printf '%s' "$SUP67" | grep -qiE 'diff|wait' \
  && a5_67=" [the map's level table still carries the phase mechanics, so the rule has two homes]"
printf '%s' "$SUP67" | grep -qiE '>5 files|architectural' \
  || a5_67="$a5_67 [the map's level table lost the criteria that earn the level, which stay its own]"
printf '%s' "$LOOP67" | grep -qi 'Supervised' \
  || a5_67="$a5_67 [the rulebook's step loop does not name the level whose gate it now owns]"
[ -z "$a5_67" ] && ok "A5 the supervised step-boundary gate lives with the loop it governs, not in the level table" \
                || bad "A5 the supervised step-boundary gate lives with the loop it governs, not in the level table ($a5_67)"

# A5b -- ADDED DURING VERIFY. A5 above asks whether the gate LEFT the level table for the loop; this asks
# whether it ARRIVED at one home or at three. Its own row rather than a fourth leg on A5, which Conform
# froze: the fact is new, so it earns its own red and A5 keeps the assert direction it was frozen with.
#
# The defect it was written against shipped inside this task, in the commit whose own message is "the gate
# moves to the loop it governs". The map was stripped and the rulebook gained the mechanics -- and then the
# command stated the same two-clause rule twice more, in wording that already differed from the protocol's
# and from itself, two copies eight lines apart in a 33-line file whose opening paragraph declares it born
# routing. Three homes, up from one, and every A5 leg green throughout: A5 reads the map and the rulebook
# and never the command.
#
# The negative is FILE-WIDE, unlike A2's, and the difference is the point. A2 forbids an obligation that
# has a legitimate home one step away, so a file-wide negative there would redden a correct command; here
# no step of this command may spell the gate, so a scoped negative would only relocate the copy it found.
# The positive is what keeps the row from being satisfied by a command that says nothing at all: silence
# leaves the reader of a Supervised run with no idea a boundary exists.
a5b_67=""
if [ ! -f "$FE67" ]; then
  a5b_67=" [the command does not exist]"
else
  grep -qiE 'show(ing)? the diff|wait for the operator' "$FE67" \
    && a5b_67=" [the command spells the step-boundary gate instead of routing to the loop that owns it]"
  printf '%s' "$(st67 "$FE67" 2)" | grep -q 'Execute Step Protocol' \
    || a5b_67="$a5b_67 [it names the level's stop without sending the reader to the loop that states what the stop obliges]"
fi
[ -z "$a5b_67" ] && ok "A5b the command routes the step-boundary gate and spells none of it" \
                 || bad "A5b the command routes the step-boundary gate and spells none of it ($a5b_67)"

# A6a -- the rulebook's head. Re-keyed POSITIVELY to the siblings' own form: a leg keyed on the ABSENCE of
# `only carrier` would redden the correct replacement, whose sentence is "never its only carrier". What is
# forbidden is the ASSERTIVE form, and what is required is the sibling wording.
a6a_67=""
printf '%s' "$HEAD67" | grep -q 'Resolving the task' \
  || a6a_67=" [its entry no longer routes to the ladder that resolves the task]"
printf '%s' "$HEAD67" | grep -q "$PRECOND67" \
  || a6a_67="$a6a_67 [its entry no longer routes to the phase precondition]"
printf '%s' "$HEAD67" | grep -qiE 'convenience over this procedure|the command is a convenience' \
  || a6a_67="$a6a_67 [it does not carry the siblings' form, which names the manual run as the real carrier and the command as a convenience over it]"
printf '%s' "$HEAD67" | grep -qi 'no command' \
  && a6a_67="$a6a_67 [it still claims this phase has no command of its own]"
printf '%s' "$HEAD67" | grep -qiE 'is the only carrier|only carrier the check has' \
  && a6a_67="$a6a_67 [it still claims the manual run is the only carrier the check has]"
[ -z "$a6a_67" ] && ok "A6a the rulebook's head routes to a command that exists" \
                 || bad "A6a the rulebook's head routes to a command that exists ($a6a_67)"

# A6b -- the precondition's own two claims: the bullet that says the command is not yet written, and the
# lead's COUNT, which a reader uses to know whether they have read all of it.
a6b_67=""
printf '%s' "$POS67" | grep -qiE 'does not exist yet|no command' \
  && a6b_67=" [the accepted-positions bullet still says the command is unwritten]"
printf '%s' "$LEAD67" | grep -qiE 'four commands' \
  || a6b_67="$a6b_67 [the lead does not count four commands, so the block contradicts its own membership]"
printf '%s' "$LEAD67" | grep -qiE 'three commands' \
  && a6b_67="$a6b_67 [the lead still counts three commands]"
[ -z "$a6b_67" ] && ok "A6b the precondition counts four commands and claims none of them is unwritten" \
                 || bad "A6b the precondition counts four commands and claims none of them is unwritten ($a6b_67)"

# A6c -- the two homes of plan's handover. The WRITE survives in both; only its reason changes, and the
# reason must still be there: without one the clause reads as a preference and the next editor deletes it.
a6c_67=""
P5_67="$([ -f "$PS67" ] && st67 "$PS67" 5)"
[ -n "$P5_67" ] || a6c_67=" [plan's conform step could not be extracted]"
printf '%s' "$CLN67" | grep -q 'EXECUTE' \
  || a6c_67="$a6c_67 [the clean-pass bullet lost the handover to EXECUTE]"
printf '%s' "$P5_67" | grep -q 'EXECUTE' \
  || a6c_67="$a6c_67 [plan's conform step lost the handover to EXECUTE]"
printf '%s' "$CLN67" | grep -qiE 'because|so that|so nothing|which is why' \
  || a6c_67="$a6c_67 [the clean-pass handover carries no reason, so it reads as a preference]"
printf '%s' "$P5_67" | grep -qiE 'because|so that|so nothing|which is why' \
  || a6c_67="$a6c_67 [plan's handover carries no reason, so it reads as a preference]"
printf '%s' "$CLN67" | grep -qi 'no command' \
  && a6c_67="$a6c_67 [the clean-pass handover is still justified by a command that now exists]"
printf '%s' "$P5_67" | grep -qi 'no command' \
  && a6c_67="$a6c_67 [plan's handover is still justified by a command that now exists]"
[ -z "$a6c_67" ] && ok "A6c the handover to EXECUTE survives in both homes, carrying a reason that is true" \
                 || bad "A6c the handover to EXECUTE survives in both homes, carrying a reason that is true ($a6c_67)"

# A7 -- the note with no destination. The audit asks this phase for exactly this answer and today receives
# nothing, because the only place it was held was the conversation the close destroys.
a7_67=""
printf '%s' "$SKP67" | grep -qiE 'not declared|was not declared|undeclared' \
  || a7_67=" [the rulebook no longer describes a step needing guidance its plan step did not declare]"
printf '%s' "$SKP67" | grep -qiE "task's sheet|state\.md|artifacts/T-XXX/state" \
  || a7_67="$a7_67 [the miss is noted nowhere that survives the end of the sitting]"
[ -z "$a7_67" ] && ok "A7 the undeclared-guidance miss names the task's sheet as its destination" \
                || bad "A7 the undeclared-guidance miss names the task's sheet as its destination ($a7_67)"

# A8 -- the fourth command performs, at entry, what its three siblings perform. Five legs over step 2,
# each its own fact: read as one row with a single grep, the ladder's citation alone would stand in for
# all of them.
a8_67=""
if [ ! -f "$FE67" ]; then
  a8_67=" [the command does not exist]"
else
  e8_67="$(st67 "$FE67" 2)"
  [ -n "$e8_67" ] || a8_67=" [its step 2 could not be extracted]"
  printf '%s' "$e8_67" | grep -q 'Resolving the task' \
    || a8_67="$a8_67 [it does not resolve the task by the ladder]"
  printf '%s' "$e8_67" | grep -qiE 'which task|state which|resolved' \
    || a8_67="$a8_67 [it does not say which task it resolved, nor the source that answered]"
  printf '%s' "$e8_67" | grep -qiE '(own phase|its own position|the sheet)[^.]*before' \
    || a8_67="$a8_67 [it does not record its own position before the phase's work]"
  printf '%s' "$e8_67" | grep -qiE 'report and wait|report[^.]*wait' \
    || a8_67="$a8_67 [it does not stop and wait on a disagreement]"
  printf '%s' "$e8_67" | grep -qiE 'without moving the line|leaves the line|does not move the line' \
    || a8_67="$a8_67 [an authorised override would stamp the position it never earned]"
fi
[ -z "$a8_67" ] && ok "A8 the execute command performs at entry what its three siblings perform" \
                || bad "A8 the execute command performs at entry what its three siblings perform ($a8_67)"

# B1 -- the gate's CONTENT, distinct from A5's question of where it lives. Both acts, because a gate that
# waits without showing what changed asks the operator to approve a diff they were never given, and one
# that shows without waiting is a report, not a gate.
b1_67=""
printf '%s' "$LOOP67" | grep -qiE 'diff' \
  || b1_67=" [the gate does not show what the finished step changed]"
printf '%s' "$LOOP67" | grep -qiE 'wait[^.]*(next|step)|(next|step)[^.]*wait' \
  || b1_67="$b1_67 [the gate does not hold the next step until the operator answers]"
[ -z "$b1_67" ] && ok "B1 the supervised gate shows the finished step and waits before the next begins" \
                || bad "B1 the supervised gate shows the finished step and waits before the next begins ($b1_67)"

# B2 -- the disagreement, and the material, as the command carries them. Two legs: the report waits
# without writing, and the missing material is named as a FILE rather than as a phase.
b2_67=""
if [ ! -f "$FE67" ]; then
  b2_67=" [the command does not exist]"
else
  e2b_67="$(st67 "$FE67" 2)"
  printf '%s' "$e2b_67" | grep -qiE 'writ(es|ing|e) (no|nothing)|no artifact is written|without writing' \
    || b2_67="$b2_67 [it does not say the run writes nothing while it waits]"
  printf '%s' "$e2b_67" | grep -qiE 'material' \
    || b2_67="$b2_67 [it does not route the leg that tests the papers the phase consumes]"
  printf '%s' "$e2b_67" | grep -qiE 'named as a file|names the missing|missing[^.]*file' \
    || b2_67="$b2_67 [a missing paper would be reported as a phase rather than as a file the operator can look for]"
fi
[ -z "$b2_67" ] && ok "B2 a disagreement is reported without writing, and a missing paper is named as a file" \
                || bad "B2 a disagreement is reported without writing, and a missing paper is named as a file ($b2_67)"

# B3 -- the bounded retry. The rulebook's half is green from the start and stays as a KEEP leg, because
# the command's route is worth nothing if the three facts stop being demanded where they live.
b3_67=""
printf '%s' "$LOOP67" | grep -qiE 'what was tried' \
  || b3_67=" [the escalation no longer names what was tried]"
printf '%s' "$LOOP67" | grep -qiE 'what failed' \
  || b3_67="$b3_67 [the escalation no longer names what failed]"
printf '%s' "$LOOP67" | grep -qiE 'root cause' \
  || b3_67="$b3_67 [the escalation no longer names the likely root cause]"
if [ ! -f "$FE67" ]; then
  b3_67="$b3_67 [the command does not exist, so nothing routes an operator to the retry bound]"
else
  grep -qiE 'bounded retry|three (fix )?attempts|retry' "$FE67" \
    || b3_67="$b3_67 [the command's loop does not route to the bounded retry]"
fi
[ -z "$b3_67" ] && ok "B3 the bounded retry escalates with its three facts, and the command routes to it" \
                || bad "B3 the bounded retry escalates with its three facts, and the command routes to it ($b3_67)"

# B4 -- the close. Four legs, and they are the close's own obligations rather than this command's
# invention: the position, the resume line, the fixed announcement, and the turn ending.
b4_67=""
if [ ! -f "$FE67" ]; then
  b4_67=" [the command does not exist]"
else
  CLS67="$(awk '/^[0-9]+\. /{last=NR} {a[NR]=$0} END{for(i=last;i<=NR;i++) printf "%s ", a[i]}' "$FE67")"
  printf '%s' "$CLS67" | grep -qiE 'VERIFY|the position the audit' \
    || b4_67="$b4_67 [its close does not advance the sheet to the position the audit declares]"
  # CORRECTED during Execute against C50's A10, which sweeps every installed surface carrying a close
  # and forbids exactly this restatement. The leg as frozen demanded the `next action:` spelling and was
  # unsatisfiable beside that rule -- a bad assumption at Conform, taken through the Replan Gate rather
  # than by weakening either side. What the criterion wants is that the next sitting learns where to pick
  # up; what the engine requires is that the obligation be ROUTED to its one home, not copied here.
  printf '%s' "$CLS67" | grep -q "$PRECOND67" \
    || b4_67="$b4_67 [its close does not route to the block that says what else the close writes]"
  printf '%s' "$CLS67" | grep -q 'next action:' \
    && b4_67="$b4_67 [it spells the close's own obligation instead of routing to it, which C50's A10 forbids on every close-carrying surface]"
  printf '%s' "$CLS67" | grep -qiE 'fixed line|the line it states|announce' \
    || b4_67="$b4_67 [its close does not state the fixed announcement]"
  printf '%s' "$CLS67" | grep -qiE 'ends? the turn' \
    || b4_67="$b4_67 [its close does not end the turn, so the cut is announced and walked past]"
fi
[ -z "$b4_67" ] && ok "B4 the close writes the position, the resume line and the fixed announcement, then ends the turn" \
                || bad "B4 the close writes the position, the resume line and the fixed announcement, then ends the turn ($b4_67)"

# B5 -- ADDED DURING VERIFY, and it is the complement of B2 rather than a leg of it: B2 asks what happens
# when a paper the phase consumes is MISSING, and this asks what happens at the one level where it was
# never owed. Its own row and not an extra leg on B2, because B2 is a frozen contract row and this fact is
# not one of the three it froze.
#
# The defect it was written against shipped in this task and the suite was green over it: the material
# bullet exempted `plan` and `verify` by name and said nothing of `execute`, and the command's step 2 read
# the level without acting on it while step 4 opened both papers unconditionally. So the first thing the
# new command did to an Auto task was refuse it and name a file the Auto path is documented never to
# write. Both halves are asserted, because either alone certifies half the fix: an exempting protocol the
# command does not act on still refuses the task, and a command that acts on an exemption the protocol
# does not grant is a command contradicting its own rulebook.
MAT67="$(pcl67 'material leg')"
b5_67=""
[ -n "$MAT67" ] || b5_67=" [the material-leg bullet did not extract, so this row would report on nothing]"
if [ -n "$MAT67" ]; then
  printf '%s' "$MAT67" | grep -qiE '`execute`[^.]*Auto|Auto[^.]*`execute`' \
    || b5_67="$b5_67 [the material bullet exempts other phases at Auto and not this one, so an Auto task is refused for papers Auto never produces]"
fi
if [ ! -f "$FE67" ]; then
  b5_67="$b5_67 [the command does not exist]"
else
  printf '%s' "$(st67 "$FE67" 2)" | grep -qiE 'Auto[^.]*(requires nothing|requires neither|no plan artifact|was inline|is inline)' \
    || b5_67="$b5_67 [the command reads the level and then tests the material leg as though every level produced papers]"
fi
[ -z "$b5_67" ] && ok "B5 an Auto task is not refused at Execute for papers Auto never produces" \
                || bad "B5 an Auto task is not refused at Execute for papers Auto never produces ($b5_67)"
