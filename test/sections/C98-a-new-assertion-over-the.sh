# =====================================================================================================
# C98 -- a new assertion over this engine's own prose cannot be added in silence
#
# WHAT THIS BLOCK GUARDS. A verdict site whose evidence is a pattern matched against this engine's own
# documents has no oracle: the pattern and the sentence it reads are written by the same actor in the
# same change, so what it detects is that the prose CHANGED and never that the rule is wrong. Sites of
# that shape were added here six tasks running, each as the answer to the previous one, because nothing
# noticed one arriving. These rows are what notices.
#
# HOW IT STAYS GREEN over the sites already here: it judges only what is NEW -- present in the working
# tree and absent at the merge-base with the published trunk. The limit follows from that and is not a
# caveat to be read past: IT BITES ON ANY WORK NOT YET PUBLISHED, IN ANY CHECKOUT, which is every moment
# a site is being authored and every moment this suite is run to validate one. After publication a site
# is inherited by definition and these rows stop seeing it.
#
# WHAT IT DOES NOT REACH, and the first figure is the one to read:
#
#   RECALL IS 43%. Against 237 verdict sites a human hand condemned as prose-reading, the rule refuses
#   102 and ADMITS 135 (measured at 294a89c, split chase, transitive subject resolution at depth 4).
#   Precision is what makes it safe to ship -- 102 of 103 refusals agree with that hand, the single
#   disagreement being C13:86 -- but MOST NEW PROSE ASSERTIONS STILL PASS. So the claim these rows
#   support is not "a new assertion over the engine's prose cannot be added in silence"; it is the
#   smaller and true one, that THE SHAPES THIS GUARD RECOGNISES cannot be. The rule is deliberately not
#   widened: widening costs precision, precision costs false refusals, false refusals demand an escape
#   hatch, and an escape hatch is the silence readmitted through the front door.
#
#   THE SOLE-SOURCE JUDGEMENT IS DECLARED AND NEVER PERFORMED. A site reading engine SOURCE as text is
#   admissible where that source is the only and complete statement of the fact -- a judgement, not a
#   shape. A rule refusing every such site was measured against the same hand corpus and would refuse 9
#   sites that were kept, so it is not attempted here.
#
#   THE ORACLE SHAPE'S REGION HALF IS OUT OF REACH. A suite-derived value consumed by an ABSENCE leg
#   with no floor under it fails open, and that shape is mechanically indistinguishable from admissible
#   counting. C66's A4 is the live instance and is carried forward by name, not repaired here.
#
# THE POPULATION THIS GUARD LOOKS AT, recomputed from the tree on every run and held by ROW 7:
#
#   REACH (this tree): read=191 md_only=118 mixed=20 source_only=16 blind=37 depth=4
#
# `blind` is the count of sites that read SOMETHING this tool could not resolve to a path at all, so it
# is the share of the read population these rows cannot even classify. It is not the same number as the
# recall above and must not be read as one.
#
# WHAT ROW 7 HOLDS AND WHAT IT DOES NOT. It holds the REACH line and nothing else on this page: the line
# is prose a person maintains, the figures are computed from the corpus, and the corpus is written by
# whoever adds a section rather than by this block's author -- so the two sides can disagree, and that is
# what makes it a check. Add a verdict site and the computation moves while the line stays where it was.
#
# The RECALL and PRECISION figures above are NOT held by any row here, and saying so is the point: they
# were measured against 288 hand verdicts in a ledger that is not tracked in this repository, at a commit
# most of whose sites no longer exist. No row can recompute them, and a row claiming a reach it does not
# have is worse than one claiming none, because the next reader stops looking.
#
# A RED ON ROW 7 IS NOT AN INSTRUCTION TO PASTE THE NEW NUMBERS IN. The REACH line is a claim about this
# guard's coverage, so a red asks whether that claim still holds -- and if the blind share has grown, the
# honest answer may be that it no longer does. Four figures in this engine's recent chain of tasks
# propagated because they were stated without the revision, the chase depth or the instrument variant
# they were taken on. Every figure on this page carries all three, and a figure without its provenance
# is not a measurement; it is a number that will be repeated.
# =====================================================================================================
echo ""
echo "== C98: a new assertion over this engine's own prose cannot be added in silence =="

TOOL98="$ROOT/test/tools/recurrence-register.py"

# ROW 1 -- the instrument is present before any verdict below is read.
#
# Every row after this one rests on what one tool reports, and a tool that is missing or unreadable would
# leave them all reading an empty string, which every absence leg here would score perfect.
if [ -r "$TOOL98" ] && [ -d "$ROOT/test/tools/register" ]; then
  ok "the recurrence register's extractor is present and readable"
else
  bad "the recurrence register's extractor is present and readable (no ${TOOL98})"
fi

# ROW 2 -- THE GUARD RAN. Not "the guard found nothing": a different fact, and keeping the two apart is
# this row's whole job.
#
# The extractor needs python3, and this suite's degradation is otherwise silent -- 14 sections branch on
# PY3, 4 of them with no else-arm at all, and validate.sh refuses only a run of ZERO rows. So a missing
# interpreter removes verdicts and still prints `Result: N passed, 0 failed`. A `[skip]` line here would
# reproduce exactly that: the suite would report clean over a guard that never executed.
OUT98=""
rc98=0
if [ "$PY3" = 1 ]; then
  OUT98="$(python3 "$TOOL98" guard "$ROOT" 2>&1)"
  rc98=$?
  ok "the recurrence guard ran"
else
  rc98=-1
  bad "the recurrence guard ran (python3 is unavailable, so THE GUARD DID NOT RUN -- which is not the same finding as the guard having found nothing)"
fi

# ROW 3 -- the register answered with a populated corpus.
#
# The floor is here because `new=0 refused=0` is what a clean tree reports AND what a corpus that
# silently emptied reports. A renamed section directory, an unreadable file, a glob that matched
# nothing: all three produce a green guard over nothing at all, which is the one verdict this engine
# exists to refuse.
r3_98=""
if [ "$rc98" = 0 ] || [ "$rc98" = 1 ]; then
  n98="$(printf '%s\n' "$OUT98" | sed -n 's/.*sites=\([0-9][0-9]*\).*/\1/p' | head -1)"
  b98="$(printf '%s\n' "$OUT98" | sed -n 's/.*base=\([0-9][0-9]*\).*/\1/p' | head -1)"
  case "${n98:-}" in
    ''|*[!0-9]*) r3_98=" [the register reported no site count]" ;;
    *) [ "$n98" -ge 700 ] || r3_98=" [the register holds only ${n98} sites]" ;;
  esac
  case "${b98:-}" in
    ''|*[!0-9]*) r3_98="$r3_98 [the merge-base register reported no count]" ;;
    *) [ "$b98" -ge 700 ] || r3_98="$r3_98 [the merge-base register holds only ${b98} sites]" ;;
  esac
else
  r3_98=" [the guard did not reach a register]"
fi
[ -z "$r3_98" ] \
  && ok "both registers are populated, so a clean guard is not a guard over nothing" \
  || bad "both registers are populated, so a clean guard is not a guard over nothing ($r3_98)"

# ROW 4 -- the published trunk resolved, so NEW could be told from INHERITED.
#
# An unresolvable trunk makes the set difference unanswerable, and an unanswerable difference is empty.
# Reported as a clean guard, that certifies whatever it could not look at. The trunk rule is not restated
# here: the extractor imports `base_ref` from the diff-size guard, which is its one home.
if [ "$rc98" = 3 ]; then
  bad "the published trunk resolved, so a new site can be told from an inherited one (it did not resolve, so the guard could not look)"
elif [ "$rc98" = 0 ] || [ "$rc98" = 1 ]; then
  ok "the published trunk resolved, so a new site can be told from an inherited one"
else
  bad "the published trunk resolved, so a new site can be told from an inherited one (the guard did not run)"
fi

# ROW 5 -- NO NEW SITE READS THIS ENGINE'S OWN DOCUMENTS AS TEXT. The row this block exists for.
#
# Keyed on the conjunction `read` AND a `.md` subject under the engine's documents, which is the only
# version of the rule with evidence behind it: 102 of 103 against 288 hand verdicts. The bare subject
# rule, without the class, has never been measured. The conjunction is the NARROWER of the two and
# therefore the weaker guard, which is the safe direction for a mechanism with no escape hatch.
if [ "$rc98" = 1 ] || [ "$rc98" = 0 ]; then
  MD98="$(printf '%s\n' "$OUT98" | grep '^REFUSE .* md ' | tr '\n' ' ')"
  [ -z "$MD98" ] \
    && ok "no newly added verdict site reads this engine's own documents as text" \
    || bad "no newly added verdict site reads this engine's own documents as text (${MD98})"
else
  bad "no newly added verdict site reads this engine's own documents as text (the guard did not answer)"
fi

# ROW 6 -- NO NEW SITE TAKES THE SUITE'S OWN TEXT INTO A MATCHER'S PATTERN SLOT.
#
# The second shape, and it is a separate rule with separate evidence rather than a variant of ROW 5.
# Taking a value OUT of the suite's text is ordinary and often necessary -- counting its markers,
# enumerating its helpers, deriving a scope from it. What cannot fail is spending that value as the
# PATTERN against a different stream: the suite then judges another file by a string it copied out of
# itself, and the two sides have no way to disagree.
#
# Position is the whole discriminator, and the corpus carries both positions one line apart, which is
# what makes it checkable rather than a matter of taste. The detector was controlled against the tree
# before the prose-reading purge: it fires there on 5 sites carrying exactly PAT46A and PAT46B -- the
# two values attested independently as second-order -- and on nothing else, while C60's KEYS89, C62's
# TPLVARS62, C92's ABOVE92, C93's MACH93 and C25's BLOCK25 all take the suite's text into the HAYSTACK
# slot and are correctly left alone. Every one of those five is load-bearing and a rule that refused
# them would be unusable.
#
# C25's TWINBLK25 is a STATED MISS: it reaches the same failure through the haystack's shape, which
# cannot be told from admissible counting by reading the code.
if [ "$rc98" = 1 ] || [ "$rc98" = 0 ]; then
  OR98="$(printf '%s\n' "$OUT98" | grep '^REFUSE .* oracle ' | tr '\n' ' ')"
  [ -z "$OR98" ] \
    && ok "no newly added verdict site spends the suite's own text as a matcher's pattern" \
    || bad "no newly added verdict site spends the suite's own text as a matcher's pattern (${OR98})"
else
  bad "no newly added verdict site spends the suite's own text as a matcher's pattern (the guard did not answer)"
fi

# ROW 7 -- THE COVERAGE THIS BLOCK DECLARES IS THE COVERAGE IT HAS.
#
# Two independently written sides, which is the only reason this is a check and not a change detector:
# the REACH line in the header is prose a person maintains, and the figures it is compared against are
# computed from the corpus by the extractor. The third party is the CORPUS -- written by whoever adds a
# section, not by whoever wrote this block -- so adding a verdict site moves the computation while the
# line stays put, and editing the line alone moves it the other way. Either direction reddens.
#
# No expected value is written into this row. Freezing the number here would make the row assert what
# the extractor prints, which has one source and would be green forever.
r7_98=""
if [ "$PY3" = 1 ]; then
  HDR98="$(grep -m1 'REACH (this tree):' "$SECTION" | sed 's/.*REACH (this tree):[[:space:]]*//')"
  CMP98="$(python3 "$TOOL98" reach "$ROOT" 2>&1)"
  [ -n "$HDR98" ] || r7_98=" [the header declares no REACH line]"
  [ -n "$CMP98" ] || r7_98="$r7_98 [the extractor reported no figures]"
  if [ -n "$HDR98" ] && [ -n "$CMP98" ] && [ "$HDR98" != "$CMP98" ]; then
    r7_98=" [declared '${HDR98}' but the tree gives '${CMP98}']"
  fi
else
  r7_98=" [python3 is unavailable, so the declared coverage was never checked]"
fi
[ -z "$r7_98" ] \
  && ok "the coverage this block declares is the coverage the tree gives it" \
  || bad "the coverage this block declares is the coverage the tree gives it ($r7_98)"
