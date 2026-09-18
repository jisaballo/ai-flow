# =====================================================================================================
# C99 -- a criterion with no falsifier is refused by something other than its author
#
# Generated in the Conform phase from the Verifiable Criteria of the task that gives the criteria block
# the check the engine already asks for in writing. Written RED: A1-A4 fail while
# `global/scripts/criteria-check.sh` does not exist, A5 fails while the installer's script list does not
# name it. A1-A4 turn green with the check, A5 with the delivery.
#
# WHAT IT GUARDS. Every criterion in an understanding is asked, in writing, for what was observed and for
# what would prove it false, and until this block nothing ever looked -- zero readers of an
# `understand.md`'s CONTENTS anywhere in the engine. A rule nothing enforces is a rule the next hurried
# author skips with no consequence, and the field exists precisely to break the single-actor loop where
# the same person writes a claim and the evidence for it.
#
# WHY THE FOUR RUNNING LEGS ARE RUN AND NOT READ. The subject is an artifact the task's author writes;
# the check is written by the engine at another time by another actor. Two independent sources, so a
# fixture can disagree with the check and the failure mode is WRONG rather than CHANGED. Nothing here
# greps this engine's own prose for the rule it states.
#
# THE CONTROL IS NOT DECORATION. A5 aside, a block asserting only refusals is satisfied by a check that
# refuses everything, and a block asserting only passes by one that refuses nothing. So A1 asserts that
# the COMPLETE criterion in the same paper is NOT named, and A2 runs four well-formed papers -- both
# live region spellings crossed with both live field layouts -- and requires silence on all four. The
# four shapes are not invented: every one of them was read first-hand off the archived understandings
# this engine has already produced -- `- **Verifiable Criteria**:` with the criteria one level in
# against `### Verifiable Criteria` with them at column zero, and both fields on one sub-bullet split
# by a middle dot against one sub-bullet per field. Each spelling and each layout appears in more than
# one archived paper, so neither is a single author's habit. A check keyed on either spelling alone
# ships reporting clean over half the corpus, and that is what A2 exists to catch.
#
# WHAT IT DOES NOT REACH, stated here because the reader of a green suite stands here too:
#
#   IT TESTS PRESENCE, NEVER HONESTY. A falsifier phrased against the assertion -- "the check would go
#   red" -- rather than against the subject satisfies every leg below with the field present. That
#   remains a judgement the author owes, refused by the Understand gate and by no row here.
#
#   NOTHING HERE ASSERTS THAT THE PLANNING PHASE INVOKES THE CHECK. The honest assertion is a grep of
#   the protocol block that states what `plan` consumes, and C98 refuses it: a new read-class verdict
#   site whose subject is an engine document. The invocation therefore rests on the engine's standing
#   trust in its own protocols, which every phase step already rests on. Recorded as a gap in this
#   task's conformance manifest rather than dressed up as coverage, and distinct from a check nothing
#   invokes at all.
#
#   NO ROW OFFERS AN ESCAPE HATCH, and there is none to assert: the check has no suppression flag by
#   design. An author who cannot write a falsifier does not have a criterion this mechanism should
#   yield to -- they have one the Understand gate already refuses.
# =====================================================================================================
echo ""
echo "== C99: a criterion with no falsifier is refused by something other than its author =="

CHK99="global/scripts/criteria-check.sh"

# The two field keys and the refusal's own vocabulary, declared once. FROZEN in this task's conformance
# manifest: the check's sentences are free to change during Execute, these tokens are not, because A1
# asks that a refusal name the field that is missing and a leg keyed on a whole sentence would be a leg
# about wording rather than about the fact.
FOBS99="observed:"
FFAL99="falsified-by:"
MISS99="missing"

BOX99="$(mkbox)" || fatal 'the criteria-check fixtures'
OUT99="$BOX99/out"

# Run the check over one paper and leave its output in a file. The status reaches the caller through the
# substitution and the OUTPUT goes to a FILE: a variable assigned inside `$( )` dies with the subshell,
# so a helper reporting both out of band would report neither.
run99() {  # $1 = the paper to judge
  bash "$ROOT/$CHK99" "$1" > "$OUT99" 2>&1
  printf '%s' "$?"
}

# Every paper below is built from one skeleton, so a deriver breaks exactly one thing. The criteria
# carry marker words -- ZETAONE, ZETATWO -- because "the refusal names the criterion" is only a
# measurement if a leg can tell WHICH criterion was named.
#
# $1 = the file to write; $2 = the region marker line; $3 = the indent the criteria sit at;
# $4 = the body of the second criterion's field block, already indented by the caller.
paper99() {
  local f="$1" marker="$2" ind="$3" second="$4"
  {
    printf '# Understanding: a fixture\n\n## Requirements Clarification\n\n'
    printf -- '- **Goal**: a fixture the criteria check can be measured against.\n\n'
    printf '%s\n\n' "$marker"
    printf '%s- IF the gateway settles a batch ZETAONE, THEN the ledger shall carry one row per batch.\n' "$ind"
    printf '%s  - `%s` run · `%s` a settled batch leaves no ledger row\n\n' "$ind" "$FOBS99" "$FFAL99"
    printf '%s- WHILE a refund is open ZETATWO, the charge it reverses shall stay readable.\n' "$ind"
    printf '%s\n' "$second"
    printf '\n## Technical Considerations\n\nNothing further.\n'
  } > "$f"
}

# The two live region spellings, read off the archived corpus rather than invented.
MK99A='- **Verifiable Criteria**:'   # criteria one level in
MK99B='### Verifiable Criteria'      # criteria at column zero

# --- A1: a criterion missing one field is refused, and the refusal names it and the field ----------
# Both directions, because the two fields are two rules and a check that looks for one of them passes
# half this leg. The complete criterion in the same paper must NOT be named: without that arm the leg is
# satisfied by a check that names every criterion it ever reads, which measures nothing about the fields.
a1_99=""
if [ ! -r "$CHK99" ]; then
  a1_99=" [$CHK99 is not there -- no verdict drawn from an absent check]"
else
  # Missing the falsifier. The `observed:` line is present and alone.
  P99="$BOX99/miss-falsifier.md"
  paper99 "$P99" "$MK99A" '  ' "    - \`$FOBS99\` run"
  rc99="$(run99 "$P99")"
  [ "$rc99" != 0 ] || a1_99="$a1_99 [a criterion with no ${FFAL99} is reported clean]"
  grep -q 'ZETATWO' "$OUT99" || a1_99="$a1_99 [the refusal does not name the incomplete criterion]"
  grep -q "$MISS99 $FFAL99" "$OUT99" || a1_99="$a1_99 [the refusal does not say which field is missing]"
  grep -q 'ZETAONE' "$OUT99" && a1_99="$a1_99 [the refusal also names the complete criterion]"
  grep -q "$MISS99 $FOBS99" "$OUT99" && a1_99="$a1_99 [the refusal reports ${FOBS99} missing where it is present]"

  # Missing the observation. Same paper, the other field removed.
  P99="$BOX99/miss-observed.md"
  paper99 "$P99" "$MK99A" '  ' "    - \`$FFAL99\` an open refund makes the charge unreadable"
  rc99="$(run99 "$P99")"
  [ "$rc99" != 0 ] || a1_99="$a1_99 [a criterion with no ${FOBS99} is reported clean]"
  grep -q 'ZETATWO' "$OUT99" || a1_99="$a1_99 [the ${FOBS99} refusal does not name the incomplete criterion]"
  grep -q "$MISS99 $FOBS99" "$OUT99" || a1_99="$a1_99 [the ${FOBS99} refusal does not say which field is missing]"
  grep -q "$MISS99 $FFAL99" "$OUT99" && a1_99="$a1_99 [the refusal reports ${FFAL99} missing where it is present]"

  # A criterion carrying NEITHER field, named once and for both.
  P99="$BOX99/miss-both.md"
  paper99 "$P99" "$MK99A" '  ' "    - it simply says nothing about either field"
  rc99="$(run99 "$P99")"
  [ "$rc99" != 0 ] || a1_99="$a1_99 [a criterion with neither field is reported clean]"
  grep -q "$MISS99 $FOBS99" "$OUT99" || a1_99="$a1_99 [the both-missing refusal does not name ${FOBS99}]"
  grep -q "$MISS99 $FFAL99" "$OUT99" || a1_99="$a1_99 [the both-missing refusal does not name ${FFAL99}]"

  # A criterion whose OWN SENTENCE quotes the field names and carries no field block at all. Read as
  # part of what is searched, the criterion's text satisfies the fields it never wrote -- and in an
  # engine whose criteria are routinely ABOUT these two fields, that is the ordinary sentence rather
  # than a contrived one. The complete criterion above it must still not be named.
  P99="$BOX99/self-quoting.md"
  { printf '# Understanding: a fixture\n\n## Requirements Clarification\n\n'
    printf '%s\n\n' "$MK99A"
    printf '  - IF the gateway settles a batch ZETAONE, THEN the ledger shall carry one row per batch.\n'
    printf '    - `%s` run · `%s` a settled batch leaves no ledger row\n\n' "$FOBS99" "$FFAL99"
    printf '  - IF a criterion ZETATWO carries no `%s`, or no `%s`, THEN it is malformed.\n' "$FOBS99" "$FFAL99"
    printf '\n## Technical Considerations\n\nNothing further.\n'
  } > "$P99"
  rc99="$(run99 "$P99")"
  [ "$rc99" != 0 ] || a1_99="$a1_99 [a criterion quoting the field names in its own sentence is reported clean]"
  grep -q 'ZETATWO' "$OUT99" || a1_99="$a1_99 [the self-quoting refusal does not name the criterion]"
  grep -q "$MISS99 $FOBS99" "$OUT99" || a1_99="$a1_99 [the self-quoting refusal does not name ${FOBS99}]"
  grep -q "$MISS99 $FFAL99" "$OUT99" || a1_99="$a1_99 [the self-quoting refusal does not name ${FFAL99}]"
  grep -q 'ZETAONE' "$OUT99" && a1_99="$a1_99 [the self-quoting refusal also names the complete criterion]"

  # A PROSE NOTE inside the region -- which is the shape the template now asks for, so that a note is not
  # read as a criterion. Read as part of the criterion above it, a note that mentions a field name hands
  # that criterion the field it never wrote. This task shipped the instruction and the hole together.
  P99="$BOX99/prose-note.md"
  { printf '# Understanding: a fixture\n\n## Requirements Clarification\n\n'
    printf '%s\n\n' "$MK99A"
    printf '  - WHILE a refund is open ZETATWO, the charge it reverses shall stay readable.\n\n'
    printf '  **On the fields.** Every criterion states `%s` and `%s` in its own block.\n' "$FOBS99" "$FFAL99"
    printf '\n## Technical Considerations\n\nNothing further.\n'
  } > "$P99"
  rc99="$(run99 "$P99")"
  [ "$rc99" != 0 ] || a1_99="$a1_99 [a prose note quoting the field names satisfies the criterion above it]"
  grep -q 'ZETATWO' "$OUT99" || a1_99="$a1_99 [the prose-note refusal does not name the criterion]"

  # THE MASKING CASE, and it is the sharpest of the three. A criterion written one level too deep is a
  # sub-bullet by the paper's own structure; if its fields are read as the body of the criterion ABOVE,
  # they satisfy a field that criterion genuinely lacks. The check then reports clean over precisely the
  # defect it is the sole reader of.
  P99="$BOX99/deeper-sibling.md"
  { printf '# Understanding: a fixture\n\n## Requirements Clarification\n\n'
    printf '%s\n\n' "$MK99A"
    printf '  - IF the gateway settles a batch ZETAONE, THEN the ledger shall carry one row per batch.\n'
    printf '    - WHILE a refund is open ZETATWO, the charge it reverses shall stay readable.\n'
    printf '      - `%s` run\n' "$FOBS99"
    printf '      - `%s` an open refund makes the charge unreadable\n' "$FFAL99"
    printf '\n## Technical Considerations\n\nNothing further.\n'
  } > "$P99"
  rc99="$(run99 "$P99")"
  [ "$rc99" != 0 ] || a1_99="$a1_99 [a criterion one level deeper masks the missing fields of the one above it]"
  grep -q 'ZETAONE' "$OUT99" || a1_99="$a1_99 [the masking refusal does not name the criterion that lacks the fields]"
  grep -q "$MISS99 $FOBS99" "$OUT99" || a1_99="$a1_99 [the masking refusal does not name ${FOBS99}]"
  grep -q "$MISS99 $FFAL99" "$OUT99" || a1_99="$a1_99 [the masking refusal does not name ${FFAL99}]"
fi
[ -z "$a1_99" ] && ok "A1 a criterion missing either field is refused, and the refusal names the criterion and the field" \
                || bad "A1 a criterion missing either field is refused, and the refusal names the criterion and the field:$a1_99"

# --- A2: the control -- a well-formed paper passes in both spellings and both layouts --------------
# Four papers, the cross product, and the reason it is a cross product rather than two papers is that
# the spelling decides where the criteria sit and the layout decides how the fields are written: a check
# keyed on one spelling and one layout passes a two-paper control and still sees half the live corpus.
a2_99=""
if [ ! -r "$CHK99" ]; then
  a2_99=" [$CHK99 is not there -- no verdict drawn from an absent check]"
else
  # Both fields on ONE sub-bullet, split by a middle dot, against one sub-bullet PER field -- the two
  # layouts the archived corpus holds. Held as the field block each paper's second criterion carries.
  for sp99 in A B; do
    case "$sp99" in
      A) mk99="$MK99A"; ind99='  ' ;;
      B) mk99="$MK99B"; ind99=''   ;;
    esac
    P99="$BOX99/well-$sp99-inline.md"
    paper99 "$P99" "$mk99" "$ind99" "${ind99}  - \`$FOBS99\` run · \`$FFAL99\` an open refund makes the charge unreadable"
    rc99="$(run99 "$P99")"
    [ "$rc99" = 0 ] || a2_99="$a2_99 [spelling $sp99 with the fields inline on one sub-bullet is refused although both are present: $(tr '\n' ' ' < "$OUT99")]"

    P99="$BOX99/well-$sp99-split.md"
    paper99 "$P99" "$mk99" "$ind99" "${ind99}  - \`$FOBS99\` run
${ind99}  - \`$FFAL99\` an open refund makes the charge unreadable
${ind99}  - \`kind:\` **Automated**"
    rc99="$(run99 "$P99")"
    [ "$rc99" = 0 ] || a2_99="$a2_99 [spelling $sp99 with one sub-bullet per field is refused although both are present: $(tr '\n' ' ' < "$OUT99")]"
  done
  # And the same check still refuses inside the other spelling, so A2's silence is a check that looks
  # rather than a check that has stopped looking at spelling B entirely.
  P99="$BOX99/miss-falsifier-B.md"
  paper99 "$P99" "$MK99B" '' "  - \`$FOBS99\` run"
  rc99="$(run99 "$P99")"
  [ "$rc99" != 0 ] || a2_99="$a2_99 [under spelling B a criterion with no ${FFAL99} is reported clean]"
  grep -q 'ZETATWO' "$OUT99" || a2_99="$a2_99 [under spelling B the refusal does not name the incomplete criterion]"

  # THE REGION'S END, which no fixture above reached. Under the bullet spelling the region hands back to
  # its section at the next column-zero bullet; every paper the skeleton builds goes straight from the
  # criteria to a heading, so that branch ran zero times in this whole block.
  #
  # THE SIBLING BULLET MUST CARRY ITS OWN SUB-BULLETS, and that is the whole measurement rather than a
  # detail of the fixture. A bare sibling is absorbed by the indent rule alone -- it sits shallower than
  # the criteria and is ignored whether or not the region ever ended -- so a fixture built from one is
  # green with the terminator deleted and tests nothing. What only the terminator can prevent is the
  # sibling's OWN children being read at the criteria indent and promoted to criteria of a region that
  # should already have closed. Its failure direction is the bad one: a FALSE refusal on a well-formed
  # paper, from a mechanism that ships no flag to suppress it.
  P99="$BOX99/sibling-after.md"
  { printf '# Understanding: a fixture\n\n## Requirements Clarification\n\n'
    printf '%s\n\n' "$MK99A"
    printf '  - IF the gateway settles a batch ZETAONE, THEN the ledger shall carry one row per batch.\n'
    printf '    - `%s` run · `%s` a settled batch leaves no ledger row\n\n' "$FOBS99" "$FFAL99"
    printf -- '- **Unverified Assumptions**: what this fixture puts after the region.\n'
    printf '  - ZETATHREE, which is an assumption and carries no field because it is not a criterion.\n'
    printf '\n## Technical Considerations\n\nNothing further.\n'
  } > "$P99"
  rc99="$(run99 "$P99")"
  [ "$rc99" = 0 ] || a2_99="$a2_99 [a sibling section after the criteria list is read as criteria and refused: $(tr '\n' ' ' < "$OUT99")]"
  grep -q 'ZETATHREE' "$OUT99" && a2_99="$a2_99 [a bullet outside the region is named by the refusal]"
fi
[ -z "$a2_99" ] && ok "A2 a well-formed paper passes in either region spelling and either field layout" \
                || bad "A2 a well-formed paper passes in either region spelling and either field layout:$a2_99"

# --- A3: no region located is a refusal, never a clean report --------------------------------------
# This is the whole reason the check fails closed. A paper whose criteria heading was renamed has no
# region to read; a check that reports clean over it turns "rename the heading" into the escape hatch
# the design refuses to ship as a flag.
a3_99=""
if [ ! -r "$CHK99" ]; then
  a3_99=" [$CHK99 is not there -- no verdict drawn from an absent check]"
else
  P99="$BOX99/no-region.md"
  paper99 "$P99" '- **Checkable Statements**:' '  ' "    - \`$FOBS99\` run · \`$FFAL99\` a settled batch leaves no ledger row"
  rc99="$(run99 "$P99")"
  [ "$rc99" != 0 ] || a3_99="$a3_99 [a paper whose criteria heading was renamed is reported clean]"
  # A paper with no criteria section at all, which is the same fact arriving by the other road.
  printf '# Understanding: a fixture\n\n## Requirements Clarification\n\n- **Goal**: nothing to check.\n' > "$BOX99/bare.md"
  rc99="$(run99 "$BOX99/bare.md")"
  [ "$rc99" != 0 ] || a3_99="$a3_99 [a paper carrying no criteria section at all is reported clean]"
fi
[ -z "$a3_99" ] && ok "A3 a paper whose criteria region cannot be located is refused, not reported clean" \
                || bad "A3 a paper whose criteria region cannot be located is refused, not reported clean:$a3_99"

# --- A4: a located region holding no criterion is a refusal ----------------------------------------
# Region present and empty is the same fact as region absent wearing another shape. Passed, it would
# make "every criterion complete" indistinguishable from "there were none", and both consumers of the
# criteria -- the plan's coverage table and Conform's emission -- would be working over zero.
a4_99=""
if [ ! -r "$CHK99" ]; then
  a4_99=" [$CHK99 is not there -- no verdict drawn from an absent check]"
else
  for sp99 in "$MK99A" "$MK99B"; do
    P99="$BOX99/empty-region.md"
    { printf '# Understanding: a fixture\n\n## Requirements Clarification\n\n'
      printf -- '- **Goal**: a region with nothing in it.\n\n'
      printf '%s\n\n' "$sp99"
      printf '\n## Technical Considerations\n\nNothing further.\n'
    } > "$P99"
    rc99="$(run99 "$P99")"
    [ "$rc99" != 0 ] || a4_99="$a4_99 [an empty criteria region under '$sp99' is reported clean]"
  done
fi
[ -z "$a4_99" ] && ok "A4 a located criteria region holding no criterion is refused" \
                || bad "A4 a located criteria region holding no criterion is refused:$a4_99"

# --- A5: the check is delivered executable, and survives the sweep ---------------------------------
# Two producers, because the delivery is two mechanisms: the installer's script list, and the sweep that
# prunes what that list no longer names. A leg over the list alone is satisfied by a name nothing copies.
# The companion assertion on the sibling script is what keeps a fixture that installed NOTHING from
# reading as a fixture that installed everything but this one.
a5_99=""
IH99="$BOX99/home-install"; IT99="$BOX99/target"; mkdir -p "$IH99" "$IT99"
( cd "$BOX99" && HOME="$IH99" bash "$ROOT/install.sh" update "$IT99" </dev/null >/dev/null 2>&1 ) || true
[ -x "$IH99/.claude/ai-flow/scripts/context-check.sh" ] \
  || a5_99="$a5_99 [the installer delivered neither script, so this fixture proves nothing]"
[ -x "$IH99/.claude/ai-flow/scripts/criteria-check.sh" ] \
  || a5_99="$a5_99 [the installer does not deliver the criteria check]"
if [ -x "$IH99/.claude/ai-flow/scripts/criteria-check.sh" ]; then
  ( cd "$BOX99" && HOME="$IH99" bash "$ROOT/install.sh" update "$IT99" </dev/null >/dev/null 2>&1 ) || true
  [ -x "$IH99/.claude/ai-flow/scripts/criteria-check.sh" ] \
    || a5_99="$a5_99 [the sweep removed what the same run installed]"
fi
[ -z "$a5_99" ] && ok "A5 the check is delivered executable under the engine's scripts directory" \
                || bad "A5 the check is delivered executable under the engine's scripts directory:$a5_99"
