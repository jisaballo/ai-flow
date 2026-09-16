# =====================================================================================================
# C97 -- a leg written while repairing is gated, and every site that may write one reaches the gate
#
# THE ADMISSIBILITY TEST THIS BLOCK IS BUILT TO, stated here because four of this criterion set's seven
# criteria are recorded as absences instead and the next reader will ask why these two are not:
#
#   A leg is admissible where it asserts STRUCTURE -- how many homes a rule has, and whether each region
#   that must reach it does -- because both are computed from the tree and can disagree with the text. A
#   leg is refused where its only available key is the WORDING, whenever it was written.
#
# Timing is NOT the licence. Both rows below are keyed on a home count and on region membership. NEITHER
# READS WHAT THE RULE SAYS: rewriting every sentence of the acceptance rule, its prohibition and its
# record leaves this block green, and the manifest's mutation record is what makes that claim payable.
#
# WHAT THESE ROWS DO NOT REACH, recorded now rather than discovered later:
#   - ROW 4 names the TWO regions that can author a leg today and asks each to reach the rule. A THIRD
#     authoring site added later is not caught: nothing in the tree says how many such sites there are,
#     so the count cannot be derived and is written here instead. What the row does catch is the defect
#     it exists for -- a citation deleted from one site while the other keeps it -- and, since the repair
#     of 2026-09-16, a citation that moved OUT of an authoring region: mentions elsewhere in the file no
#     longer satisfy it.
#   - ROW 3 counts files carrying the heading LINE, whole-line and fixed-string. A second file that
#     states the acceptance rule in prose, or under a different heading, escapes the count -- the same
#     limit C95:18-20 records for its own counter.
#   - Neither row checks the cited heading RESOLVES. That is already computed, for every backtick-quoted
#     `### Name` under global/, by the citation row of the one-home block; a second copy here would be
#     the double source these blocks exist to close.
# =====================================================================================================
echo ""
echo "== C97: a leg written while repairing is gated, and every site that may write one reaches the gate =="

T97="$(mkbox)" || fatal 'C97 fixtures'

GLOB97="$ROOT/global"
SKILL97="$GLOB97/skills/verify/SKILL.md"
HOME97='### The acceptance rule for a repair leg'
NEEDLE97='The acceptance rule for a repair leg'

# ROW 1 -- the corpus. Every verdict below is a count, and a count over a corpus that silently emptied
# reads exactly like a corpus that was genuinely wrong.
FERR97="$T97/find.err"
nmd97="$(md_count "$GLOB97" "$FERR97")"
if [ -d "$GLOB97" ] && [ "${nmd97:-0}" -ge 6 ] && [ -r "$SKILL97" ] && [ ! -s "$FERR97" ]; then
  ok "the engine corpus is populated and the verify skill is readable"
else
  bad "the engine corpus is populated and the verify skill is readable (${nmd97:-0} markdown file(s))"
fi

# ROW 2 -- the item extractor is shown to MEASURE, on planted fixtures, before any verdict is read.
#
# Both the extractor and the fixtures that prove it measures live in the preamble: two sections read it,
# and a proof retyped per section is a proof each section owns a copy of. An extractor that found nothing
# would score every verdict below perfect.
IEM97="$(item_extractor_measures "$T97")" && MEASURING97=1 || MEASURING97=0
if [ "$MEASURING97" = 1 ]; then
  ok "the item extractor tells a collapsed citation from one spread across three items"
else
  bad "the item extractor tells a collapsed citation from one spread across three items (${IEM97})"
fi

# ROW 3 (A1) -- the acceptance rule has exactly ONE home under global/.
#
# The rule this task ships binds every actor that writes a leg, so it is the shape a second copy costs
# the most: two homes drift, and the site citing the stale one gates against a rule nobody else applies.
r3_97=""
if [ "${nmd97:-0}" -ge 6 ]; then
  nh97="$(home_count "$HOME97" "$GLOB97")"
  [ "${nh97:-0}" = 1 ] || r3_97=" [the acceptance rule for a repair leg has ${nh97:-0} homes under global/, not one]"
else
  r3_97=" [the corpus did not answer]"
fi
[ -z "$r3_97" ] \
  && ok "the acceptance rule for a repair leg has exactly one home under global/" \
  || bad "the acceptance rule for a repair leg has exactly one home under global/ ($r3_97)"

# ROW 4 (A2) -- EACH region of the verify skill at which a repair may author a leg reaches that rule.
#
# The skill has two such sites and they sit in different structures: the gate is numbered item 11 of the
# `## Steps` loop, and the *Fix now* branch is a bullet of `## Triaging the Unadjudicated`. A gate reached
# from one of them is a gate the other walks past, and the walk leaves no trace: the leg is written, the
# finding closes, and nothing anywhere says the falsifier was never run.
#
# Each region is asked SEPARATELY, which is what a bare count over the whole file could not do: two
# mentions in unrelated bullets satisfied a count, and satisfy neither leg below.
r4_97=""
if [ -r "$SKILL97" ] && [ "$MEASURING97" = 1 ]; then
  STEPS97="$(awk '$0=="## Steps"{f=1;next} f&&/^## /{exit} f' "$SKILL97")"
  GATE97="$(nitem 11 "$STEPS97")"
  if [ -z "$GATE97" ]; then
    r4_97="$r4_97 [item 11 of the skill's step loop could not be read]"
  else
    case "$GATE97" in
      *"$NEEDLE97"*) ;;
      *) r4_97="$r4_97 [the step-11 gate does not reach the acceptance rule]" ;;
    esac
  fi
  ntri97="$(citing_items "$SKILL97" '## Triaging the Unadjudicated' "$NEEDLE97" | grep -c . | tr -d ' ')"
  [ "${ntri97:-0}" -ge 1 ] || r4_97="$r4_97 [no item of the triage branch reaches the acceptance rule]"
else
  r4_97=" [the verify skill or the extractor did not answer]"
fi
[ -z "$r4_97" ] \
  && ok "both regions of the verify skill that may author a leg reach the acceptance rule" \
  || bad "both regions of the verify skill that may author a leg reach the acceptance rule ($r4_97)"

rm -rf "$T97"
