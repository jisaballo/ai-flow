# =====================================================================================================
# C93 -- the suite is a set of independent sections behind a filtering runner
#
# Generated in the Conform phase from understand.md's Verifiable Criteria; every row is RED until the
# preamble, the section files, the runner's filter and the sweep exist.
#
# This block judges THIS suite's own source, which is the shape that produced one defect class five
# times in C92 and cost that task four verify rounds. Three rules are applied here because of that, and
# a row added later that breaks one of them is a hollow row whatever it prints:
#
#   1. Every corpus EXCLUDES this block's own file by name, and the exclusion is ASSERTED POPULATED
#      before any verdict is read from it. An absence leg over a corpus that silently emptied is green
#      for the wrong reason, and a glob that stops matching is how it empties.
#   2. Every absence leg is PAIRED with a presence control over the same corpus and the same machinery.
#      "the old wording is gone" and "the corpus carries no wordings at all" are otherwise the same
#      green row.
#   3. The three runner rows are FUNCTIONAL and run against a FIXTURE section set inside a sandbox,
#      never against this repo's own sections: a row that invoked the real runner would re-enter this
#      file, and a structural grep over the runner's source would judge the words rather than the act.
# =====================================================================================================
echo ""
echo "== C93: the suite is a set of independent sections behind a filtering runner =="

T93="$(mkbox)" || fatal 'C93 fixtures'
trap 'chmod -R u+rwX "$T12" "$T13" "$T25" "$T44" "$T45" "$T45R" "$T47" "$T55" "$T69" "$T70" "$T92" "$T93" 2>/dev/null; rm -rf "$T12" "$T13" "$T25" "$T44" "$T45" "$T45R" "$T47" "$T55" "$T69" "$T70" "$T92" "$T93"' EXIT   # extended, never replaced

SECD93="$ROOT/test/sections"
PRE93="$ROOT/test/lib/preamble.sh"
SWEEP93="$ROOT/test/tools/self-sufficiency.sh"

# The corpus, minus this block's own file. Rule 1 above: read once, asserted below before any verdict
# reads it. `find` on a directory that does not exist prints nothing and says so on stderr; the guard
# keeps that off the transcript without turning the absence into a pass.
corpus93() {
  [ -d "$SECD93" ] || return 0
  find "$SECD93" -maxdepth 1 -name 'C*.sh' 2>/dev/null | grep -v '/C93-' | sort
}
CORPUS93="$(corpus93)"
n93="$(printf '%s\n' "$CORPUS93" | grep -c .)"

# ROW 1 -- the corpus itself. Nothing below means anything without it.
if [ "${n93:-0}" -ge 74 ] && ! printf '%s\n' "$CORPUS93" | grep -q '/C93-'; then
  ok "the section corpus is populated and holds every section but this one"
else
  bad "the section corpus is populated and holds every section but this one (${n93:-0} file(s))"
fi

# -----------------------------------------------------------------------------------------------------
# The runner, exercised functionally against a fixture section set (rule 3).
#
# Three sections named C2, C9 and C10, because that triple is the only one that tells a NUMERIC
# iteration from a LEXICAL one: sorted as text the answer is C10 C2 C9, and a runner that iterates its
# directory with a bare glob gets exactly that and looks fine on any single-digit suite.
# -----------------------------------------------------------------------------------------------------
mkdir -p "$T93/test/lib" "$T93/test/sections" "$T93/test/tools"
if [ -d "$SECD93" ] && [ -r "$ROOT/test/validate.sh" ] && [ -r "$PRE93" ]; then
  cp "$ROOT/test/validate.sh" "$T93/test/validate.sh"
  cp "$PRE93" "$T93/test/lib/preamble.sh"
  for f93 in 2 9 10; do
    printf 'echo "== C%s: fixture =="\nok "C%s ran"\n' "$f93" "$f93" > "$T93/test/sections/C$f93-fixture.sh"
  done
  r93_ready=1
else
  r93_ready=0
fi

# ROW 2 -- no argument runs everything, in numeric order.
if [ "$r93_ready" = 1 ]; then
  ord93="$( cd "$T93" && bash test/validate.sh 2>/dev/null | sed -n 's/^== C\([0-9][0-9]*\).*/\1/p' | tr '\n' ' ' )"
else
  ord93=""
fi
[ "$ord93" = "2 9 10 " ] \
  && ok "an unfiltered run executes every section in numeric order" \
  || bad "an unfiltered run executes every section in numeric order (order: '${ord93}')"

# ROW 3 -- a filter runs one section and reports that section's totals, not the suite's.
if [ "$r93_ready" = 1 ]; then
  flt93="$( cd "$T93" && bash test/validate.sh C9 2>/dev/null )"
else
  flt93=""
fi
if printf '%s\n' "$flt93" | grep -q '^== C9:' \
   && ! printf '%s\n' "$flt93" | grep -qE '^== C(2|10):' \
   && printf '%s\n' "$flt93" | grep -qF 'Result: 1 passed, 0 failed'; then
  ok "a filtered run executes only the named section and reports only its totals"
else
  bad "a filtered run executes only the named section and reports only its totals"
fi

# ROW 4 -- an identifier naming no section is named, and the run fails.
#
# BOTH legs, because either alone is satisfied by a broken runner: a run that names the identifier and
# exits 0 is a silent full run, and a run that exits non-zero saying nothing is indistinguishable from a
# crash.
if [ "$r93_ready" = 1 ]; then
  ( cd "$T93" && bash test/validate.sh C999 ) > "$T93/unknown.out" 2>&1
  rc93=$?
else
  rc93=0; : > "$T93/unknown.out"
fi
{ [ "$rc93" != 0 ] && grep -qF 'C999' "$T93/unknown.out"; } \
  && ok "an identifier naming no section is named and the run exits non-zero" \
  || bad "an identifier naming no section is named and the run exits non-zero (status $rc93)"

# -----------------------------------------------------------------------------------------------------
# The independence properties, read off the corpus.
# -----------------------------------------------------------------------------------------------------

# ROW 5 -- no section file defines a helper the preamble owns.
#
# The 37 names are written out rather than derived from the corpus, and that is the point: derived from
# the files it judges, this row would assert that whatever is there is what belongs there. This list is
# the frozen contract from understand.md.
HELP93='a41 brake clohead dmove hookcall hookraw item23 itm90 keyed ledger malformed manfact manstate
marker89 mbul mkbig mkproj msect near90 nearok90 nearzero90 nlines nstep nwords off pair purity_sweep
rung sbullet sec90 sheet vstep waved wguard wti_classify wti_probe wti_tracked_leak'
r5_93=""
if [ "${n93:-0}" -ge 74 ] && [ -r "$PRE93" ]; then
  for h93 in $HELP93; do
    grep -qE "^${h93}\(\)[[:space:]]*\{" "$PRE93" || r5_93="$r5_93 [$h93 is not defined in the preamble]"
    printf '%s\n' "$CORPUS93" | while IFS= read -r f93; do
      grep -qE "^[[:space:]]*${h93}\(\)[[:space:]]*\{" "$f93" && printf '%s' "x"
    done | grep -q x && r5_93="$r5_93 [$h93 is still defined inside a section]"
  done
else
  r5_93=" [no preamble or no corpus to read]"
fi
[ -z "$r5_93" ] \
  && ok "every helper more than one section reads is defined in the preamble and in no section" \
  || bad "every helper more than one section reads is defined in the preamble and in no section ($r5_93)"

# ROW 6 -- no trap names a sandbox another section owns.
#
# Read per file: every `$VAR` a trap mentions must be assigned in the same file. The cumulative chain
# this retires is exactly the shape that fails here -- C92's trap names eleven sandboxes, ten of which
# belong to other blocks.
r6_93=""
if [ "${n93:-0}" -ge 74 ]; then
  while IFS= read -r f93; do
    [ -n "$f93" ] || continue
    for v93 in $(grep -hE '^[[:space:]]*trap ' "$f93" | grep -oE '\$\{?[A-Za-z_][A-Za-z0-9_]*' | tr -d '${' | sort -u); do
      grep -qE "^[[:space:]]*${v93}=" "$f93" || r6_93="$r6_93 [$(basename "$f93"): \$$v93]"
    done
  done <<< "$CORPUS93"
else
  r6_93=" [no corpus to read]"
fi
[ -z "$r6_93" ] \
  && ok "every trap names only sandboxes its own section owns" \
  || bad "every trap names only sandboxes its own section owns ($r6_93)"

# ROW 7 -- the two rows whose claim the split makes impossible carry their new wording, and only it.
#
# Scoped to the two files that own the rows, never to the corpus: this block quotes both wordings above
# and would answer itself over any corpus that included it. The presence control is rule 2 -- a
# neighbouring description from the same file, read by the same grep, so "the old wording is gone"
# cannot be satisfied by a file that was never read.
C19F93="$(printf '%s\n' "$CORPUS93" | grep -E '/C19-' | head -1)"
C21F93="$(printf '%s\n' "$CORPUS93" | grep -E '/C21-' | head -1)"
r7_93=""
for f93 in "$C19F93" "$C21F93"; do
  if [ -z "$f93" ] || [ ! -r "$f93" ]; then r7_93="$r7_93 [a section file is missing]"; continue; fi
  grep -qF 'ok "the sandbox is torn down"' "$f93" \
    || r7_93="$r7_93 [$(basename "$f93") does not carry the new wording]"
  grep -qF 'the sandbox is torn down and the live cleanup trap survives this block' "$f93" \
    && r7_93="$r7_93 [$(basename "$f93") still carries the old wording]"
  grep -qF 'the sandbox is torn down' "$f93" \
    || r7_93="$r7_93 [$(basename "$f93") was not read at all]"
done
[ -z "$r7_93" ] \
  && ok "the two trap-survival rows carry the new wording and no longer claim the neighbour's cleanup" \
  || bad "the two trap-survival rows carry the new wording and no longer claim the neighbour's cleanup ($r7_93)"

# ROW 8 -- marker89's inputs are derived outside C58's readable branch (IB-021).
#
# Scoped to C58's own file for the reason ROW 7 gives: the names below appear in this comment.
C58F93="$(printf '%s\n' "$CORPUS93" | grep -E '/C58-' | head -1)"
r8_93=""
if [ -n "$C58F93" ] && [ -r "$C58F93" ]; then
  grep -qE '^[[:space:]]*marker89\(\)' "$C58F93" && r8_93="$r8_93 [marker89 is still defined in C58]"
  for v93 in now83 stale83 DIM83 k83; do
    grep -qE "^${v93}=" "$C58F93" || r8_93="$r8_93 [\$$v93 is not derived at the top level]"
  done
else
  r8_93=" [C58's section file is missing]"
fi
[ -z "$r8_93" ] \
  && ok "marker89's inputs are derived outside the readable branch" \
  || bad "marker89's inputs are derived outside the readable branch ($r8_93)"

# ROW 9 -- the sweep ships. A session script that produced the same numbers would leave the next task
# re-deriving them, which is what this one paid twice for.
if [ -r "$SWEEP93" ] && $GIT ls-files --error-unmatch test/tools/self-sufficiency.sh >/dev/null 2>&1; then
  ok "the self-sufficiency sweep is a tracked file in the repository"
else
  bad "the self-sufficiency sweep is a tracked file in the repository"
fi

rm -rf "$T93"
