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
#   REACH (this tree): read=198 md_only=118 mixed=20 source_only=18 blind=42 depth=4
#
#   T-182 moved this by one (read, blind): C57's new A10 leg reads the coverage-auditor prompt's own
#   source text (COV82, a shell variable extracted by dim_region()) as its haystack, the same shape every
#   other check already in this count uses (C57's own A1-A9/B1-B3) -- not a new kind of blind spot, one
#   more member of the family already here. ROW 5 and ROW 6 both stay green over it: it reads no engine
#   `.md` as its subject and spends no text copied from the corpus as a matcher's pattern (the patterns
#   are literal strings this test wrote, not values pulled out of verify-review.js). Recall and precision
#   above are unaffected -- they are frozen measurements at a fixed commit, not a function of population
#   size.
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

# ROW 8 -- THE WRAPPER ROSTER EXPLAINS EVERY PRODUCER IN THE CORPUS.
#
# `WRAPPERS` in `lib_sites.py` is DECLARED by hand, and the comment that declares it names
# `unregistered()` as the one thing that makes hand-declaring it safe: every parameter-claim call the
# roster does not explain is reported rather than silently miscounted. Until this row the driver never
# asked, so the register shipped the plan-side list with no tree-side counter -- and an eighth
# reporter-shaped wrapper would have made every verdict emitted through it invisible to the register,
# hence to ROW 5 and ROW 6, with nothing anywhere going red.
#
# The two sides are independently written, which is what makes this a check: the roster is maintained by
# whoever maintains the instrument, the producers by whoever adds a section. The floor is ZERO because a
# single unexplained producer is a population these rows cannot see at all.
r8_98=""
if [ "$rc98" = 0 ] || [ "$rc98" = 1 ]; then
  u98="$(printf '%s\n' "$OUT98" | sed -n 's/.*unreg=\([0-9][0-9]*\).*/\1/p' | head -1)"
  case "${u98:-}" in
    ''|*[!0-9]*) r8_98=" [the register reported no unexplained-producer count]" ;;
    *) [ "$u98" -eq 0 ] || r8_98=" [${u98} parameter-claim call(s) no wrapper explains]" ;;
  esac
else
  r8_98=" [the guard did not reach a register]"
fi
[ -z "$r8_98" ] \
  && ok "every verdict producer in the corpus is explained by the wrapper roster" \
  || bad "every verdict producer in the corpus is explained by the wrapper roster ($r8_98)"

# ROW 9 -- THE ORACLE DISCRIMINATOR STILL TELLS THE TWO POSITIONS APART.
#
# ROW 6 above reports what the detector FOUND, and on a clean tree it finds nothing -- by design, since
# the refused shape was purged from this corpus. So ROW 6 alone cannot distinguish a detector that looked
# and saw none from one that stopped looking: `SUITE_SRC_RE`, `ASSIGN_RE`, `GREP_ARG_RE` and the
# derived-name pass could each be emptied and ROW 6 would stay green over a dead discriminator. That was
# this block's own blind spot, and its only validation was prose describing a hand-run at a tree that no
# longer exists -- the instrument destroyed while its output survives in prose, which is the defect this
# whole section was built to stop.
#
# The control is the corpus's own pair of positions, one line apart, because position IS the entire rule:
# a name derived from the suite's text spent as a matcher's PATTERN against a foreign stream is refused,
# while the same provenance spent as the HAYSTACK is admissible and load-bearing -- C60's KEYS89 is the
# live instance, and a rule that refused it would be unusable. Exactly one hit, and it is the
# pattern-slot name: an empty answer means the detector went blind, and two means it fell back to
# provenance and would refuse the rows this suite cannot do without.
r9_98=""
if [ "$PY3" = 1 ]; then
  H9_98="$(python3 - "$TOOL98" <<'PYEOF' 2>&1
import importlib.util
import sys
sys.dont_write_bytecode = True   # the tool asserts this of itself; loading it must not break the promise
spec = importlib.util.spec_from_file_location('_recurrence_register', sys.argv[1])
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)
region = '\n'.join((
    'PATZZ="$(suite_src | grep -m1 marker)"',
    'KEYZZ="$(suite_src | sed -n 2p)"',
    'printf "%s" "$ROWZZ" | grep -qE "$PATZZ"',
    'printf "%s\\n" "$KEYZZ" | grep -qxF "$labzz"',
))
print(','.join(mod.oracle_sites(region)))
PYEOF
)"
  case "$H9_98" in
    PATZZ) : ;;
    '') r9_98=" [the discriminator named nothing in a region carrying both positions]" ;;
    *) r9_98=" [the discriminator answered '${H9_98}', not the pattern-slot name alone]" ;;
  esac
else
  r9_98=" [python3 is unavailable, so the discriminator was never exercised]"
fi
[ -z "$r9_98" ] \
  && ok "the oracle discriminator separates the pattern slot from the haystack slot" \
  || bad "the oracle discriminator separates the pattern slot from the haystack slot ($r9_98)"

# ROW 10 -- THE `.md` REFUSAL PATH, EXERCISED END TO END OVER A FIXTURE TREE.
#
# The symmetric hole to the one ROW 9 closes, and it was the larger of the two. ROW 5 is green on a clean
# tree by design, so it cannot tell a live detector from a dead one: `lib_classify.classify`,
# `lib_subject.paths` and `is_engine_doc` could each be gutted and every row above would stay green -- a
# guard with a dead-man's-switch problem, which is this epic's own defect wearing the guard's clothes.
#
# THE REAL ENTRY POINT, OVER A FIXTURE TREE, AND NOT THE THREE UNITS CALLED IN ORDER. Reassembling the
# composition `register()` performs would put a SECOND HOME for that composition here: when `register()`
# changes the fixture would not, and this row would go green over an arrangement that no longer exists.
# So the sandbox is a whole small repository -- a trunk, a committed section, three uncommitted ones --
# and what runs against it is `guard`, the same entry point the suite runs against itself. Nothing is
# restated, so nothing can drift.
#
# THE TWO NEGATIVE ARMS ARE WHY THIS IS A CHECK AND NOT A TRIPWIRE. The conjunction has two halves and
# each has a planted counter-example: C03 reads a `.md` OUTSIDE the engine's documents (subject fails),
# and C04 EXECUTES a script while mentioning an engine `.md` nearby (class fails). Both are new, both
# must be admitted, and `new=4` is asserted so that "exactly one md refusal" cannot be satisfied by a
# fixture tree that silently lost them. C05 is the fourth and it is not a negative arm: it is refused
# for the OTHER shape while carrying a document, which is the only shape under which the conjunct's
# second home is observable at all. See its own comment below.
B10="$(mkbox)" || fatal 'C98 md-path fixture'
r10_98=""
if [ "$PY3" = 1 ]; then
  $GIT init -q "$B10" >/dev/null 2>&1
  $GIT -C "$B10" symbolic-ref HEAD refs/heads/main
  mkdir -p "$B10/test/lib" "$B10/test/sections" "$B10/global/hooks" "$B10/global/protocols" "$B10/notes"
  DOC10="global/protocols/sample"
  cp "$ROOT/global/hooks/diff-size-guard.py" "$B10/global/hooks/diff-size-guard.py"
  printf 'the bounded retry rule is stated here\n' > "$B10/$DOC10.md"
  printf 'some notes\n' > "$B10/notes/scratch.md"
  printf '# the fixture corpus needs a preamble to enumerate\n' > "$B10/test/lib/preamble.sh"
  cat > "$B10/test/sections/C01-inherited.sh" <<'FIX'
ok "a claim with no subject at all"
FIX
  $GIT -C "$B10" add -A >/dev/null 2>&1
  $GIT -C "$B10" commit -q -m init >/dev/null 2>&1
  # Written AFTER the commit, so all three are new against the fixture's own published trunk.
  # THE FIXTURE'S DOCUMENT PATH IS ASSEMBLED, NEVER WRITTEN WHOLE, AND THIS IS NOT EVASION -- IT IS THE
  # ONLY HONEST FORM AVAILABLE. The subject resolver is textual: it reads a path out of a region and
  # cannot tell a document this row READS from one this row WRITES INTO A SANDBOX. Written contiguously,
  # `$DOC10.md` would sit in this row's own region and the guard would refuse ROW 10 for its fixture's
  # DATA, naming a file that does not exist in this repository at all. That refusal would be true by
  # shape and false by meaning, and the mechanism has no escape hatch by design -- so the fixture names
  # its document in two pieces, and the join happens in the sandbox where the claim actually lives.
  # The blind spot itself is real and is staged rather than patched: a section that builds a fixture
  # corpus is indistinguishable, to this guard, from one that reads the corpus it builds.
  { printf 'VP02="$ROOT/%s.md"\n' "$DOC10"
    printf 'RULE02="$(grep -c %s %s)"\n' "'bounded retry'" '"$VP02"'
    printf '[ "$RULE02" -ge 1 ] && ok "the protocol states the bounded retry rule" || bad "the protocol states the bounded retry rule"\n'
  } > "$B10/test/sections/C02-reads-a-protocol.sh"
  cat > "$B10/test/sections/C03-reads-outside.sh" <<'FIX'
NP03="$ROOT/notes/scratch.md"
N03="$(grep -c 'some notes' "$NP03")"
[ "$N03" -ge 1 ] && ok "the notes file carries its line" || bad "the notes file carries its line"
FIX
  # C04's mention of the document must be RESOLVABLE or this arm tests nothing. Written as a bare
  # `sample.md` it was invisible to the subject resolver, so C04 was admitted for having no subject at
  # all and the class half of the conjunct went unexercised -- a control that lied about its own
  # coverage, found by the falsifier below rather than by reading. Same two-piece assembly, same reason.
  { printf 'O04="$(python3 "$ROOT/global/hooks/diff-size-guard.py" --help 2>&1)"\n'
    printf 'case "$O04" in *Traceback*) bad "the hook $ROOT/%s.md describes runs clean" ;; *) ok "the hook $ROOT/%s.md describes runs clean" ;; esac\n' "$DOC10" "$DOC10"
  } > "$B10/test/sections/C04-runs-and-mentions.sh"
  # C05 -- THE CONJUNCT'S SECOND HOME. The rule is written twice: once in the `refused` set that decides
  # the exit code, once in the print condition that chooses which line to emit. The set dominates, so
  # dropping the print's half is unobservable UNLESS a refused site carries a doc while classifying
  # something other than `read` -- which is exactly a site refused for the ORACLE shape that mentions a
  # document nearby. C05 is that site, and without it half the rule has no falsifier at all.
  { printf 'PAT05="$(suite_src | grep -m1 marker)"\n'
    printf 'O05="$(python3 "$ROOT/global/hooks/diff-size-guard.py" --help 2>&1)"\n'
    printf 'printf "%%s" "$O05" | grep -qE "$PAT05" && ok "the hook $ROOT/%s.md describes answers" || bad "the hook $ROOT/%s.md describes answers"\n' "$DOC10" "$DOC10"
  } > "$B10/test/sections/C05-oracle-and-mentions.sh"
  O10="$(python3 "$TOOL98" guard "$B10" 2>&1)"
  rc10=$?
  MD10="$(printf '%s\n' "$O10" | grep -c '^REFUSE .* md ' | tr -d ' ')"
  NEW10="$(printf '%s\n' "$O10" | sed -n 's/.*new=\([0-9][0-9]*\).*/\1/p' | head -1)"
  # BOTH COUNTS, because the conjunction is written TWICE in the extractor -- once in the `refused` set
  # that decides the exit code, once in the print condition that emits the line ROW 5 parses. They are
  # one rule with two homes, so they can disagree: dropping the `read` half from the set alone refuses a
  # second site, exits 1 over it, and prints no line naming it -- a refusal nobody can read. Counting
  # only the lines left that half of the rule unexercised, which a falsifier found and reading did not.
  REF10="$(printf '%s\n' "$O10" | sed -n 's/.*refused=\([0-9][0-9]*\).*/\1/p' | head -1)"
  [ "$rc10" = 1 ] || r10_98=" [the guard answered ${rc10} over a tree carrying one prose-reading site]"
  OR10="$(printf '%s\n' "$O10" | grep -c '^REFUSE .* oracle ' | tr -d ' ')"
  [ "${NEW10:-0}" = 4 ] || r10_98="$r10_98 [the fixture offered ${NEW10:-no} new site(s), not the 4 planted]"
  [ "${REF10:-0}" = 2 ] || r10_98="$r10_98 [the guard refused ${REF10:-no} site(s), not the 2 planted]"
  [ "$MD10" = 1 ] || r10_98="$r10_98 [${MD10} md refusal(s), not exactly 1]"
  [ "$OR10" = 1 ] || r10_98="$r10_98 [${OR10} oracle refusal(s), not exactly 1]"
  printf '%s\n' "$O10" | grep -q "^REFUSE C02:.* md reads ${DOC10}\.md " \
    || r10_98="$r10_98 [no refusal naming C02 and the protocol it reads]"
else
  r10_98=" [python3 is unavailable, so the .md refusal path was never exercised]"
fi
[ -z "$r10_98" ] \
  && ok "the md refusal path names the site that reads an engine document and admits the two that do not" \
  || bad "the md refusal path names the site that reads an engine document and admits the two that do not ($r10_98)"
