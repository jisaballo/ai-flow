echo "== C22: a phase refuses to run on a task that is not in that phase =="
PB22="global/protocols/backlog.md"
US22="global/skills/understand/SKILL.md"
PS22="global/skills/plan/SKILL.md"
VS22="global/skills/verify/SKILL.md"
VP22="global/protocols/verify.md"
PRECOND22="The phase precondition"
C22_SKILLS="understand plan execute verify"

# The rule's own block, bounded at the next heading of any depth and fence-aware — the shape C14 and
# C18 use for the task-diff definition and the mutation rule, and for the same reason: a file-wide grep
# finds the citations, never the rule itself.
PBLK22="$(awk -v h="^### $PRECOND22" '$0 ~ h {f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^#+ /){f=0} f' "$PB22")"
# One bolded clause of that block, from its lead to the next lead, flattened. Five facts share this
# block: a block-wide grep would let any one of them stand in for any other, which is the failure this
# harness has now caught eight times.
pclause22() { printf '%s\n' "$PBLK22" | awk -v s="$1" '/^- \*\*/{ if(g) exit; g=($0 ~ s) } g' | tr '\n' ' '; }
# Byte offset of a fixed string: for the facts that are an ORDER, which presence greps cannot see.
# Defined here rather than reused from C14 so this block stands on its own.
poff22() { printf '%s' "$1" | grep -obF "$2" | head -1 | cut -d: -f1; }

# --- the rule has exactly one home -----------------------------------------
# A5a. Counted, not merely found: the whole anti-drift design is that a second statement cannot exist.
# Anchored at line start: a citation names the heading inline ("see `### The phase precondition`"),
# which is how every other cross-reference in the engine is written, so an unanchored count reads each
# of the three citers as a fourth home. A real second home carries the heading itself, at line start.
HOMES22="$(grep -rl "^### $PRECOND22" global/ 2>/dev/null | wc -l | tr -d ' ')"
# The shipped template and the docs are the other two places a rule gets copied into, and a copy there
# is as much a second home as one in global/ — the count above would never see it.
ELSEWHERE22="$(grep -rl "^### $PRECOND22" template/ docs/ 2>/dev/null | wc -l | tr -d ' ')"
if [ "$HOMES22" -eq 1 ] && [ "$ELSEWHERE22" -eq 0 ] && [ -n "$PBLK22" ]; then
  ok "the phase precondition is stated in exactly one document"
else
  bad "the phase precondition is stated in exactly one document (global/: $HOMES22, elsewhere: $ELSEWHERE22)"
fi

# --- the accepted position of each command --------------------------------
ACC22="$(pclause22 'Accepted position')"
if [ -n "$ACC22" ] && printf '%s' "$ACC22" | grep -qiE 'not later than|no later than'; then
  ok "the accepted positions leave understand open below"
else
  bad "the accepted positions leave understand open below"
fi
if [ -n "$ACC22" ] && printf '%s' "$ACC22" | grep -q 'UNDERSTAND or PLAN'; then
  ok "the accepted positions name plan's own two"
else
  bad "the accepted positions name plan's own two"
fi
if [ -n "$ACC22" ] && printf '%s' "$ACC22" | grep -q 'EXECUTE or VERIFY'; then
  ok "the accepted positions name verify's own two"
else
  bad "the accepted positions name verify's own two"
fi
# A5 -- WHEN the accepted positions are stated, the engine shall name EXECUTE as the position
# `execute` runs on. Generated in the Conform phase from understand.md's Verifiable Criteria.
# NOT the bare presence of `EXECUTE`: the clause has always carried it on verify's own pair
# ("`verify` runs on EXECUTE or VERIFY"), so a presence leg was green before the requirement existed --
# the disease c50's comment records twice. What discriminates is the COMMAND named beside the position,
# and the second leg is where that position comes from: a phase whose command does not exist yet is
# honoured by a manual run, and a row that never says who writes the position lets the next reader read
# it as unreachable and delete it.
acc22e=""
printf '%s' "$ACC22" | grep -qE '`execute`[^.]*\bEXECUTE\b|\bEXECUTE\b[^.]*`execute`' \
  || acc22e=" [the accepted positions do not name EXECUTE as the position execute runs on]"
printf '%s' "$ACC22" | grep -qiE 'Conform|`plan`[^.]*(writes|advances)' \
  || acc22e="$acc22e [it does not name what writes that position]"
[ -n "$ACC22" ] && [ -z "$acc22e" ] && ok "A5 the accepted positions name execute's own position, and what writes it" \
                                   || bad "A5 the accepted positions name execute's own position, and what writes it ($acc22e)"

# --- the material leg -----------------------------------------------------
MAT22="$(pclause22 'material')"
if [ -n "$MAT22" ] && printf '%s' "$MAT22" | grep -q 'understand.md'; then
  ok "the material leg names what plan feeds on"
else
  bad "the material leg names what plan feeds on"
fi
# NOT a bare 'plan.md': the clause names both artifacts, so the loose form passed on the other leg's
# word. What verify needs is the table, and a plan without one is the hollow audit's own case.
if [ -n "$MAT22" ] && printf '%s' "$MAT22" | grep -qi 'Criteria Coverage'; then
  ok "the material leg names the table verify inherits, not merely the file"
else
  bad "the material leg names the table verify inherits, not merely the file"
fi
if [ -n "$MAT22" ] && printf '%s' "$MAT22" | grep -qiE 'understand [^.]*none|no material|none of its own'; then
  ok "the material leg says understand has none"
else
  bad "the material leg says understand has none"
fi
# A6 -- WHEN the material leg is stated, the engine shall name `plan.md`, its Criteria Coverage table
# and the conformance manifest as what `execute` feeds on, and shall state that the manifest is not
# required where Conform was skipped. Generated in the Conform phase from understand.md's Verifiable
# Criteria.
#
# Four legs, not one. `plan.md` and `Criteria Coverage` are BOTH already in this clause on verify's
# account, so neither can carry this row: what is new is the manifest, and the exemption that keeps the
# manifest from being demanded where Conform was legitimately skipped -- one of whose three cases is an
# ordinary full-path task with no automated criteria, so the exemption is not a quick-path escape. The
# exemption is the leg most likely to be dropped as a caveat, and dropping it turns a lawful task into a
# refused one.
mat22e=""
printf '%s' "$MAT22" | grep -qE '`execute`' \
  || mat22e=" [the material leg does not name execute at all]"
# The artifact's FULL NAME, not a bare `manifest` -- which was HOLLOW, proven by mutation: the exemption
# leg below needs its own sentence naming the manifest ("The manifest is not required where Conform was
# legitimately skipped"), so deleting the manifest from what execute FEEDS ON left this leg green on the
# exemption's mention. Two legs about the same noun can only discriminate on what each binds it to.
#
# Binding it to `execute` within a sentence was tried first and does not work: `plan.md` carries a period,
# so a `[^.]*` window cannot reach past it, and a `[^;]*` one runs straight into the exemption sentence.
# The full name is where the artifact is INTRODUCED; the exemption refers back to it as "the manifest".
# Residual risk, stated rather than hidden: a rewrite that spelled the full name only in the exemption
# would satisfy this leg with the feeds-on mention gone. The mutation battery is what catches that, and
# it is cheaper than a key elaborate enough to make it unreachable.
printf '%s' "$MAT22" | grep -qi 'conformance baseline manifest' \
  || mat22e="$mat22e [it does not name the conformance baseline manifest as what execute feeds on]"
printf '%s' "$MAT22" | grep -qiE '(manifest|it) is not required|no manifest is required|unless Conform|where Conform was skipped' \
  || mat22e="$mat22e [it does not exempt the manifest where Conform was legitimately skipped]"
# A6b -- the leg requires nothing of a level that produces nothing. Found in the Verify phase: the leg
# demanded `understand.md` of every run, and an Auto task legitimately has none (it skips Understand and
# plans inline), so the engine refused at its second phase every task on a path its own map promises
# works. The exemption is the leg's own principle -- a phase checks what it CONSUMES -- and stating it is
# what makes the Auto branch each command documents a branch that can actually be reached.
printf '%s' "$MAT22" | grep -qiE 'Auto[^.]*(inline|consumes nothing|requires nothing)|(inline|consumes nothing|requires nothing)[^.]*Auto' \
  || mat22e="$mat22e [it does not waive the artifact at Auto, so the level's own documented branch is refused by this leg]"
[ -n "$MAT22" ] && [ -z "$mat22e" ] && ok "A6 the material leg names what execute feeds on, and exempts a skipped Conform" \
                                    || bad "A6 the material leg names what execute feeds on, and exempts a skipped Conform ($mat22e)"

# A6c -- the autonomy read is stated BEFORE the material leg, because the leg's requirement depends on the
# level. An ORDER, which presence greps cannot see, so it is read by byte offset the way this block already
# reads verify's gather-before-judge. Not cosmetic: reversed, a run tests for papers before it knows
# whether this level produces any, which is exactly the refusal the waiver above exists to prevent -- and a
# reader who meets the leg first learns the requirement and never reaches the exception.
O_AUT22="$(poff22 "$PBLK22" 'The autonomy read')"
O_MAT22="$(poff22 "$PBLK22" 'The material leg')"
if [ -n "$O_AUT22" ] && [ -n "$O_MAT22" ] && [ "$O_AUT22" -lt "$O_MAT22" ]; then
  ok "A6c the level is read before the leg whose requirement it decides"
else
  bad "A6c the level is read before the leg whose requirement it decides (autonomy at ${O_AUT22:-absent}, material at ${O_MAT22:-absent})"
fi

# --- what a disagreement produces ----------------------------------------
DIS22="$(pclause22 'disagree')"
if [ -n "$DIS22" ] && printf '%s' "$DIS22" | grep -qiE 'declares|declared'; then
  ok "a disagreement names the phase the sheet declares"
else
  bad "a disagreement names the phase the sheet declares"
fi
if [ -n "$DIS22" ] && printf '%s' "$DIS22" | grep -qiE 'asked for|requested|was asked'; then
  ok "a disagreement names the phase that was asked for"
else
  bad "a disagreement names the phase that was asked for"
fi
if [ -n "$DIS22" ] && printf '%s' "$DIS22" | grep -qiE 'missing|absent|cannot find'; then
  ok "a disagreement names the material that is missing"
else
  bad "a disagreement names the material that is missing"
fi
# B1. The stop is the half that costs something: a warning printed and then walked past is the defect
# with a note attached, which is what the user's own counter-case bought this requirement for.
if [ -n "$DIS22" ] && printf '%s' "$DIS22" | grep -qiE 'no artifact|nothing is written|before .*artifact' \
   && printf '%s' "$DIS22" | grep -qiE 'confirm|the operator'; then
  ok "a disagreement writes no artifact until the operator answers"
else
  bad "a disagreement writes no artifact until the operator answers"
fi

# --- what a confirmed run does and does not do ---------------------------
CONF22="$(pclause22 'confirmed')"
# A2 and B2 are two facts, not one: the sheet holding still is the state, and the report saying so is
# the record. A mutant that keeps the sheet and stays silent about it kills only the second.
if [ -n "$CONF22" ] && printf '%s' "$CONF22" | grep -qiE 'unchanged|untouched|not moved|does not move'; then
  ok "a confirmed out-of-phase run leaves the position line where it is"
else
  bad "a confirmed out-of-phase run leaves the position line where it is"
fi
if [ -n "$CONF22" ] && printf '%s' "$CONF22" | grep -qi 'out of phase' \
   && printf '%s' "$CONF22" | grep -qiE 'report|says'; then
  ok "a confirmed out-of-phase run says so in its report"
else
  bad "a confirmed out-of-phase run says so in its report"
fi

# --- what a clean pass does ---------------------------------------------
CLEAN22="$(pclause22 'clean pass')"
if [ -n "$CLEAN22" ] && printf '%s' "$CLEAN22" | grep -qiE 'writes its own phase|records its own phase'; then
  ok "a clean pass has the command record its own phase"
else
  bad "a clean pass has the command record its own phase"
fi
# The "before" is the half that carries the weight: written at exit instead of at entry, the read-only
# rail engages after the work it exists to restrain, and the understand protocol's line now depends on
# it. A presence grep for the verb cannot see position, and this block already owns the order idiom.
if [ -n "$CLEAN22" ] && printf '%s' "$CLEAN22" | grep -qiE '(own phase|sheet)[^.]*before'; then
  ok "the phase is recorded before the phase's work, not after it"
else
  bad "the phase is recorded before the phase's work, not after it"
fi
# The handover, and its reason. Without the reason the clause reads as a preference and the next editor
# deletes it. RE-KEYED once the phase gained a command: the old reason -- that nothing else could write
# the position, the phase after plan having no command -- became false the moment one existed, and a leg
# still keyed on it would have demanded the engine keep saying something untrue. What is durable is the
# reason underneath it: Conform's close is where the position becomes true, and nothing later in the
# chain reaches back to record it, because a command reads the position it runs on and never writes it.
# Keyed positively on that, never on the absence of the old phrase -- an absence leg passes on silence.
if [ -n "$CLEAN22" ] && printf '%s' "$CLEAN22" | grep -q 'EXECUTE' \
   && printf '%s' "$CLEAN22" | grep -qiE 'reaches back|never writes the one'; then
  ok "the handover to EXECUTE carries the reason it exists"
else
  bad "the handover to EXECUTE carries the reason it exists"
fi


# Every line naming two or more of the accepted positions as a set -- which is what restating them looks
# like, in any wording. $1 = a document's text.
#
# This replaces a pair of literal pins (`UNDERSTAND or PLAN`, `EXECUTE or VERIFY`). Those were an ABSENCE
# keyed on a phrase: red when the precondition reworded its own enumeration and still said the same thing,
# green when a skill restated the set in words nobody had listed -- which is the drift the rows exist to
# catch, walking past them. The claim was never about those two spellings; it is that a second document
# enumerates the set at all. Counting DISTINCT positions per line asks that question directly, so
# `PLAN and EXECUTE`, `VERIFY, EXECUTE` and `either UNDERSTAND or else PLAN` are all caught without anyone
# having to have thought of them.
#
# Per LINE and not per document, because every one of these files names its own phase many times over and
# a document-wide count would report all of them. A line is the unit at which two positions sit together
# as a set.
enum22() {
  printf '%s\n' "$1" | awk '
    { n = 0; delete seen; s = $0
      while (match(s, /(ACTIVATE|UNDERSTAND|PLAN|EXECUTE|VERIFY)/)) {
        w = substr(s, RSTART, RLENGTH)
        if (!(w in seen)) { seen[w] = 1; n++ }
        s = substr(s, RSTART + RLENGTH)
      }
      if (n >= 2) printf "L%d ", NR
    }'
}

# The presence control for it, run once and read by both loops below. Rule of the class: an absence
# verdict is worth exactly what the extractor behind it is worth, and the cheapest way to make "no
# document restates the set" green is an extractor that finds nothing anywhere. The fixture restates the
# set in a wording NEITHER retired pin would have matched, so passing it proves the widening and not just
# the plumbing.
CTL22="$(enum22 'the command runs on PLAN and EXECUTE, never on the position before them')"
NCTL22="$(enum22 'the command runs on its own position and names no other')"
ENUMOK22=1
[ -n "$CTL22" ] || ENUMOK22=0
[ -z "$NCTL22" ] || ENUMOK22=0
[ "$ENUMOK22" = 1 ] \
  && ok "the restatement detector finds a reworded enumeration and reports nothing on a clean line" \
  || bad "the restatement detector finds a reworded enumeration and reports nothing on a clean line (planted=[$CTL22] clean=[$NCTL22])"

# --- the three commands obey it, and restate none of it ------------------
for s in $C22_SKILLS; do
  f="global/skills/$s/SKILL.md"
  if [ ! -f "$f" ]; then
    bad "$s cites the phase precondition (file missing: $f)"
    bad "$s does not restate the accepted positions (file missing)"
    bad "$s records its own phase once both legs pass (file missing)"
    continue
  fi
  c="$(cat "$f")"

  # Citing means naming the block AND the document that holds it — the phrase alone could be a heading
  # of the skill's own.
  if printf '%s' "$c" | grep -q "$PRECOND22" && printf '%s' "$c" | grep -q 'backlog.md'; then
    ok "$s cites the phase precondition's owner"
  else
    bad "$s cites the phase precondition's owner"
  fi

  # The anti-drift assertion, the same one the ladder already earned: a skill may name its own phase,
  # never re-spell the accepted SETS, because a second statement of those is the copy that drifts.
  e22="$(enum22 "$c")"
  if [ "$ENUMOK22" != 1 ]; then
    bad "$s does not restate the accepted positions (the detector is not measuring)"
  elif [ -n "$e22" ] || printf '%s' "$c" | grep -qiE 'not later than|no later than'; then
    bad "$s does not restate the accepted positions ($e22)"
  else
    ok "$s does not restate the accepted positions"
  fi

  # A3b — the write, per command. The rule having a writer is the whole reason the check can refuse on
  # this field at all; a rule stating it while no command does it is an alarm with no owner.
  # NOT a loose 'writes .*phase': the read-only rail's own sentence ("blocks code writes while the
  # phase is UNDERSTAND") satisfied that, so the assertion was green on a neighbour's word before a
  # line of the fix existed. The possessive is the fact — it is the command's OWN phase it records.
  if printf '%s' "$c" | grep -qiE 'writes? its own phase|records? its own phase'; then
    ok "$s records its own phase once both legs pass"
  else
    bad "$s records its own phase once both legs pass"
  fi

  # The skill's step 2 carries THREE obligations and only the write was asserted, so the stop and the
  # no-move could each be deleted from any one command with the suite green. Scoped to step 2, because
  # the operative instruction the command reads at runtime is this one — the protocol states the rule,
  # the command performs it.
  s2="$(vstep "$f" 2)"
  if [ -n "$s2" ] && printf '%s' "$s2" | grep -qiE 'disagreement' \
     && printf '%s' "$s2" | grep -qiE 'report and wait|reports? and waits?'; then
    ok "$s stops and waits on a disagreement"
  else
    bad "$s stops and waits on a disagreement"
  fi
  if [ -n "$s2" ] && printf '%s' "$s2" | grep -qiE 'without moving the line|without moving the phase'; then
    ok "$s runs an authorised override without moving the line"
  else
    bad "$s runs an authorised override without moving the line"
  fi
  # F2's per-command half: the write is at entry, not at exit.
  if [ -n "$s2" ] && printf '%s' "$s2" | grep -qiE '(own phase|sheet)[^.;]*before'; then
    ok "$s records the phase before doing the phase's work"
  else
    bad "$s records the phase before doing the phase's work"
  fi
done

# A5b -- WHERE a phase is given an accepted position, the protocol that phase is run from shall route to
# the precondition at its ENTRY, not only where it closes. Added with execute's row: a position accepted
# and papers insisted on, with nothing at the phase's entry that reads them, is a rule whose only reader
# is the document that declares it.
#
# Scoped to the text ABOVE the first `##` heading, which is where the three sibling protocols put this
# route -- and asserted for execute.md ALONE, deliberately. The same leg run as a loop over all four
# would redden `global/protocols/verify.md`, whose route is real but sits in step 1 under `## Steps`; a
# leg that fails on a document doing the right thing is a leg that gets deleted rather than obeyed. That
# was measured, not guessed: the prover ran this shape and reported exactly that caveat.
EXE22="$(awk '/^## /{exit} {print}' "$ROOT/global/protocols/execute.md" 2>/dev/null | tr '\n' ' ')"
exe22=""
[ -n "$EXE22" ] || exe22=" [execute.md has no text above its first heading, so nothing was examined]"
printf '%s' "$EXE22" | grep -q 'Resolving the task' \
  || exe22="$exe22 [its entry does not route to the ladder that resolves the task]"
printf '%s' "$EXE22" | grep -q "$PRECOND22" \
  || exe22="$exe22 [its entry does not route to the phase precondition, so the row execute was given has no reader]"
# RE-KEYED with the command's arrival, and POSITIVELY, which is the whole point. The old key was
# `no command|only carrier`; the replacement wording is the siblings' -- "never its only carrier" -- and
# it CONTAINS the phrase the old leg searched for. Left alone the row would have gone on passing while
# certifying the exact sentence this task retired, which is the hollow leg this harness has now caught
# nine times. What the head must carry is the standing the three siblings give their own commands.
printf '%s' "$EXE22" | grep -qiE 'convenience over this procedure|is a convenience' \
  || exe22="$exe22 [its head does not give the command the standing its three siblings give theirs: a convenience over a manual run that remains the real carrier]"
[ -z "$exe22" ] && ok "A5b execute.md routes to the precondition at its entry, and says what performs it" \
                || bad "A5b execute.md routes to the precondition at its entry, and says what performs it ($exe22)"

# --- F1b: the rule must reach the layer that is the documented manual fallback -------------
# The sibling ladder is cited in BOTH layers — each protocol head and each command. This one was cited
# only in the commands, so a run that reaches the protocol because the command is not installed
# performed no check at all, and verify.md's own report template demanded a fact its procedure could not
# produce. Same discipline: cite, restate nothing.
# `execute` joined this loop DURING VERIFY, once its protocol became a full member of the class: its head
# now carries the siblings' identical sentence about the manual run and states outright that it names no
# accepted position of its own. The list was not extended when that happened, so the negative half -- the
# one that keeps the accepted set from growing a second home -- was asserted for three protocols of four,
# and the fourth was the one this task had just rewritten.
for pr in understand plan execute verify; do
  pf="global/protocols/$pr.md"
  if [ ! -f "$pf" ]; then
    bad "the $pr protocol cites the phase precondition (file missing)"
    bad "the $pr protocol does not restate the accepted positions (file missing)"
    continue
  fi
  pc="$(cat "$pf")"
  if printf '%s' "$pc" | grep -q "$PRECOND22"; then
    ok "the $pr protocol cites the phase precondition"
  else
    bad "the $pr protocol cites the phase precondition"
  fi
  pe22="$(enum22 "$pc")"
  if [ "$ENUMOK22" != 1 ]; then
    bad "the $pr protocol does not restate the accepted positions (the detector is not measuring)"
  elif [ -n "$pe22" ] || printf '%s' "$pc" | grep -qiE 'not later than|no later than'; then
    bad "the $pr protocol does not restate the accepted positions ($pe22)"
  else
    ok "the $pr protocol does not restate the accepted positions"
  fi
done

# F10 — the rewritten line names its mover. A passive sentence with no owner is what this task found;
# leaving the repair unasserted lets it revert to passive with the suite green.
# Re-keyed when the close of Understand took over the write: the rail is released by step 4 now, so the
# sentence naming the `plan` command as its mover became false three lines above the step that replaced it
# -- and this row was holding that false sentence in place.
if grep -qE 'write-guard hook stops restricting once the close below writes PLAN' "global/protocols/understand.md"; then
  ok "the read-only rail's release names the command that performs it"
else
  bad "the read-only rail's release names the command that performs it"
fi

# A4b — the handover lands in the command that performs it, not only in the rule that describes it.
# Scoped to the step that performs it: two file-wide greps for 'EXECUTE' and an advance verb are
# satisfied by any two unrelated lines, which is the shape of a guard that reports on nothing.
# Reuses `vstep` rather than carrying a third copy of the same extractor: the copy written here escaped
# its step boundary with two backslashes where the other two use four, so its `\.` reached awk as a bare
# dot and the boundary matched any character. It happened to work; it was one edit from not.
N_CONF22="$(grep -nE '^[0-9]+\. \*\*Conform\*\*' "$PS22" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/')"
CONFS22="$([ -n "$N_CONF22" ] && vstep "$PS22" "$N_CONF22")"
if [ -n "$CONFS22" ] && printf '%s' "$CONFS22" | grep -q 'EXECUTE' \
   && printf '%s' "$CONFS22" | grep -qiE 'hands? over|advances?'; then
  ok "the plan command carries the handover to EXECUTE, in the step that closes"
else
  bad "the plan command carries the handover to EXECUTE, in the step that closes"
fi

# O4 — declared, never claimed. understand's phase leg cannot fail from below and it has no material
# leg at all; saying so is what stops a later reader from reading its silence as coverage.
if grep -qiE 'no material|nothing to require|none of its own' "$US22"; then
  ok "understand declares it has no material leg"
else
  bad "understand declares it has no material leg"
fi
if grep -qiE 'cannot fail from below|nothing earlier|no earlier phase' "$US22"; then
  ok "understand declares its phase leg cannot fail from below"
else
  bad "understand declares its phase leg cannot fail from below"
fi

# --- the gather runs before anything judges what it gathers --------------
C_VS22="$(cat "$VS22")"
O_GATH22="$(poff22 "$C_VS22" 'Gather the task diff')"
O_AUD22="$(poff22 "$C_VS22" 'Criterion audit')"
O_COPY22="$(poff22 "$C_VS22" 'byte-exact copy')"
O_REV22="$(poff22 "$C_VS22" 'Invoke the verify-review workflow')"

# A7. The defect itself, stated as an order: the consumer sat ahead of the gather, so what it judged was
# whatever the session happened to hold. Presence greps cannot see this, which is why the harness kept
# it green while asserting the consumer pointed FORWARD at a step that had not run.
if [ -n "$O_GATH22" ] && [ -n "$O_AUD22" ] && [ "$O_GATH22" -lt "$O_AUD22" ]; then
  ok "the gather runs before the criterion audit that reads it"
else
  bad "the gather runs before the criterion audit that reads it"
fi
# A7b — and the consumer stops pointing forward. The old assertion demanded exactly this forward
# reference, so leaving it in place would keep the defect green under a new name.
RA22="$(printf '%s\n' "$C_VS22" | awk '/Reverse audit/{f=1} f{print; if(/^[[:space:]]*$/) exit}' | tr '\n' ' ')"
if [ -n "$RA22" ] && ! printf '%s' "$RA22" | grep -qiE 'as step [0-9]+ gathers|which is not part of what step'; then
  ok "the reverse audit no longer points forward at an ungathered diff"
else
  bad "the reverse audit no longer points forward at an ungathered diff"
fi

# A8. The copy brackets the REVIEW, not the audit. Moved up with the gather it would span the audit's
# own command re-runs, and a file a test creates would then be restored away — work destroyed to fix a
# report.
if [ -n "$O_AUD22" ] && [ -n "$O_COPY22" ] && [ "$O_AUD22" -lt "$O_COPY22" ]; then
  ok "the byte-exact copy is taken after the criterion audit's command re-runs"
else
  bad "the byte-exact copy is taken after the criterion audit's command re-runs"
fi
if [ -n "$O_COPY22" ] && [ -n "$O_REV22" ] && [ "$O_COPY22" -lt "$O_REV22" ]; then
  ok "the byte-exact copy is taken before the review is invoked"
else
  bad "the byte-exact copy is taken before the review is invoked"
fi

# O2 — every step reference inside the command resolves to a step that exists. Counted first: an
# extractor that finds no references passes every check it makes.
REFS22="$(printf '%s\n' "$C_VS22" | grep -oE 'step [0-9]+' | grep -oE '[0-9]+' | sort -u)"
NREFS22="$(printf '%s\n' "$REFS22" | grep -c '[0-9]' || true)"
DANGLING22=""
for n in $REFS22; do
  printf '%s\n' "$C_VS22" | grep -qE "^$n\. " || DANGLING22="$DANGLING22 $n"
done
if [ "$NREFS22" -ge 3 ] && [ -z "$DANGLING22" ]; then
  ok "every step reference inside the verify command resolves to a step that exists"
else
  bad "every step reference inside the verify command resolves to a step that exists (dangling:$DANGLING22)"
fi

# O2's SECOND conjunct — the criterion says a reference resolves to a step that exists *and carries the
# fact cited*. Only the first was implemented. With eleven steps almost every wrong number is still an
# existing one, and pointing at the wrong-but-existing step is exactly how a renumbering fails.
vsn22() { grep -nE "^[0-9]+\. \*\*$1" "$VS22" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/'; }
J_GATH22="$(vsn22 'Gather the task diff')"
J_COPY22="$(vsn22 'Take the byte-exact copy')"
J_CMP22="$(vsn22 'Compare the working copy')"
J_WR22="$(vsn22 'Write')"
JOINS22=0
JBAD22=""
join22() { # phrase-anchored pattern, expected index, label
  local got
  got="$(printf '%s\n' "$C_VS22" | grep -oE "$1" | grep -oE '[0-9]+' | head -1)"
  if [ -n "$got" ]; then
    JOINS22=$((JOINS22 + 1))
    [ "$got" = "$2" ] || JBAD22="$JBAD22 $3(cites=$got,is=$2)"
  else
    JBAD22="$JBAD22 $3(phrase-absent)"
  fi
}
join22 'step [0-9]+ writes both into the report'  "$J_WR22"   'gather-to-write'
join22 'task diff step [0-9]+ gathered'           "$J_GATH22" 'audit-to-gather'
join22 'path step [0-9]+ can recompute'           "$J_CMP22"  'copy-to-compare'
join22 'record step [0-9]+ compares against'      "$J_CMP22"  'copy-to-compare-2'
join22 'copy taken in step [0-9]+'                "$J_COPY22" 'compare-to-copy'
join22 'step [0-9]+.s comparison'                 "$J_CMP22"  'consolidate-to-compare'
join22 'what step [0-9]+ noted'                   "$J_GATH22" 'write-to-gather'
join22 'tree verdict from step [0-9]+'            "$J_CMP22"  'write-to-compare'
# Counted against the class: a guard whose phrases all stop matching asserts nothing about the numbers.
if [ "$JOINS22" -eq 8 ] && [ -z "$JBAD22" ]; then
  ok "every step reference cites the step that carries the fact"
else
  bad "every step reference cites the step that carries the fact ($JOINS22/8 phrases;$JBAD22)"
fi

# The spec's own edge case: with the gather ahead of the audit, the skip decision governs only the
# review. The four offsets asserted above all survive moving the skip decision ABOVE the gather, which
# puts the gather straight back inside what a skipped review appears to skip — the exact confusion the
# old forward-reference parenthetical existed to paper over.
O_SKIP22="$(poff22 "$C_VS22" 'Decide whether to skip')"
if [ -n "$O_GATH22" ] && [ -n "$O_SKIP22" ] && [ "$O_GATH22" -lt "$O_SKIP22" ]; then
  ok "the gather sits outside what a skipped review skips"
else
  bad "the gather sits outside what a skipped review skips"
fi

# O3 — positive form, not a denylist: what bounds these extractors is that they resolve the step by
# content. Counted against the class so a guard whose extractor finds nothing cannot pass.
# `vstep` is in the class too: it is the extractor this change actually re-scoped onto the copy step, so
# a guard naming only the other two misses the one call site the change created. The reach of a rule is
# measured against the call sites that exist, never against the ones that existed when it was written.
INV22="$(grep -oE '(nstep|sbullet|vstep) "\$VS[0-9]*"' $SUITE_SRC | wc -l | tr -d ' ')"
LIT22="$(grep -oE '(nstep|sbullet|vstep) "\$VS[0-9]*" [0-9]' $SUITE_SRC | wc -l | tr -d ' ')"
if [ "$INV22" -ge 6 ] && [ "$LIT22" -eq 0 ]; then
  ok "no assertion reaches a step of the verify command by a hardcoded number"
else
  bad "no assertion reaches a step of the verify command by a hardcoded number ($LIT22 of $INV22 literal)"
fi

# O5 — every report template, counted. A template carrying the note while another stays silent is the
# same half-fix the twin-manual verdicts were: the reader opens whichever one their path reaches.
AUDP22="$(awk '/^\*\*Audited\*\*/{f=1;buf=""} f{buf=buf" "$0} (f && /^[[:space:]]*$/){print buf; f=0} END{if(f) print buf}' "$VP22")"
AUDT22="$(printf '%s\n' "$AUDP22" | grep -c 'Audited' || true)"
AUDW22="$(printf '%s\n' "$AUDP22" | grep -ci 'out of phase' || true)"
if [ "$AUDT22" -ge 1 ] 2>/dev/null && [ "$AUDW22" = "$AUDT22" ]; then
  ok "every report template carries the out-of-phase note"
else
  bad "every report template carries the out-of-phase note ($AUDW22 of $AUDT22)"
fi

# The writers table names who writes the phase field — the field a mechanism now refuses on, which is
# exactly the kind of datum that keeps firing while nothing is obliged to act on it. Anchored to the
# RELATION (an actor, the act of writing, the phase) and bounded to one clause by `[^|;]`: a bare
# alternation over the whole row is answered by the word `command` occurring anywhere in it for any
# reason, so the row would certify the fact while the clause carrying it was gone.
if grep -nE '^\| \*\*During the phases\*\*' "$PB22" | head -1 | grep -qiE 'command[^|;]{0,30}writes[^|;]{0,20}phase|phase[^|;]{0,30}(is )?written by[^|;]{0,20}command'; then
  ok "the writers table names the phase field's writer"
else
  bad "the writers table names the phase field's writer"
fi
