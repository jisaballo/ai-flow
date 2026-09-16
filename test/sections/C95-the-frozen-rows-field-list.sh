# =====================================================================================================
# C95 -- the frozen row's field list has exactly one home
#
# Generated in the Conform phase from understand.md's Verifiable Criteria. RED at Conform by design: the
# tree carries TWO homes (the protocol's own table, and a hand-written subset in the audit protocol), and
# the step that removes the second is what turns this green. The pair is the evidence; there is no
# placeholder here and never was one.
#
# WHY THIS ROW IS ADMISSIBLE WHERE ITS NEIGHBOURS ARE NOT, because the neighbouring criteria in the same
# task deliberately carry NO row and a later reader will ask why this one does:
#
#   The actor who would add a second home is a FUTURE EDITOR -- not this author, in this turn. So the
#   subject can disagree with the check and the failure mode is *wrong*, not *changed*. It counts HOMES
#   and never phrasing: no leg here asserts that any particular sentence still reads a particular way.
#   A grep over prose this same turn wrote would be a change detector, which is why the completeness and
#   lifecycle halves of the same criterion are recorded as absences instead of asserted here.
#
# WHAT THIS ROW DOES NOT REACH, recorded rather than discovered later: a second home worded unlike the
# list escapes the count, and a citation worded like the list would be miscounted as one. It is a
# heuristic count. Pinning the phrasing is a different problem and a different task owns it.
#
# The window is what separates an ENUMERATION from prose that happens to use one of the words: three
# distinct field names inside three lines is a list; the same word three times in a paragraph is not.
# =====================================================================================================
echo ""
echo "== C95: the frozen row's field list has exactly one home =="

T95="$(mkbox)" || fatal 'C95 fixtures'

# The field names, normalised: markup is stripped from the line before matching, so a table cell reading
# `it()` description and a sentence reading "it() description" are the same statement of the same field.
FIELDS95='spec file|it() description|source criterion|assert direction|falsifier|free-mutation verdict'

homes95() { # $1 = root to search -> one path per file that STATES the list
  find "$1" -name '*.md' 2>/dev/null | sort | while IFS= read -r f95; do
    awk -v fields="$FIELDS95" '
      BEGIN { split(fields, F, "|") }
      { line = tolower($0); gsub(/[`*_]/, "", line)
        for (i = 3; i > 1; i--) w[i] = w[i-1]; w[1] = line
        delete seen; n = 0
        for (i = 1; i <= 3; i++) {
          if (w[i] == "") continue
          for (k in F) if (index(w[i], F[k]) > 0 && !(F[k] in seen)) { seen[F[k]] = 1; n++ }
        }
        if (n >= 3) { print "HOME"; exit }
      }' "$f95" | grep -q HOME && printf '%s\n' "$f95"
  done
}

# ROW 1 -- the corpus. Nothing below means anything without it: a verdict of "one home" over a corpus
# that silently emptied is the same green as a corpus that was actually cleaned up, and a `find` whose
# root was renamed prints nothing and exits 0.
GLOB95="$ROOT/global"
nmd95="$(find "$GLOB95" -name '*.md' 2>/dev/null | grep -c . | tr -d ' ')"
if [ -d "$GLOB95" ] && [ "${nmd95:-0}" -ge 15 ]; then
  ok "the published markdown corpus is populated"
else
  bad "the published markdown corpus is populated (${nmd95:-0} file(s))"
fi

# ROW 2 -- the counter is shown to MEASURE before any verdict is read from it.
#
# Three fixtures in one answer, because each alone leaves the cheapest wrong machine passing:
#   a) a file enumerating the fields IS a home -- without this, a counter that finds nothing scores a
#      perfect "one home" the moment the real home is reworded;
#   b) a SECOND such file is also counted -- a counter that stops at the first match can never go red;
#   c) a file that CITES the home without naming the fields is NOT one -- without this, the repair the
#      row is asking for (replace the list with a citation) would leave the row red forever, and the
#      row would be unsatisfiable rather than demanding.
mkdir -p "$T95/fx"
{ printf '%s\n' '| Field | What it holds |'
  printf '%s\n' '| spec file | where the stub lives |'
  printf '%s\n' '| `it()` description | maps to the criterion |'
  printf '%s\n' '| assert direction | what must grow or shrink |'
} > "$T95/fx/a-home.md"
printf '%s\n' 'Every frozen row must still carry the same `it()` description, assert direction and falsifier.' \
  > "$T95/fx/b-home.md"
{ printf '%s\n' 'The contract check compares the fields the plan protocol marks as frozen at Conform.'
  printf '%s\n' 'Anything needing the list cites that table rather than restating it.'
  printf '%s\n' 'A row whose falsifier may be rewritten in flight is frozen in name only.'
} > "$T95/fx/c-citation.md"
FX95="$(homes95 "$T95/fx" | sed "s|^$T95/fx/||" | sort | tr '\n' ' ' | sed 's/ *$//')"
if [ "$FX95" = "a-home.md b-home.md" ]; then
  ok "the home counter finds both planted homes and does not count a citation"
else
  bad "the home counter finds both planted homes and does not count a citation (found: '${FX95}')"
fi

# ROW 3 -- the verdict. RED at Conform: the tree states the list twice.
#
# Read only after ROW 1 said the corpus exists and ROW 2 said the counter can speak; guarded on both, so
# a green here is never the silence of a machine that stopped working.
if [ "${nmd95:-0}" -ge 15 ] && [ "$FX95" = "a-home.md b-home.md" ]; then
  H95="$(homes95 "$GLOB95")"
  n95="$(printf '%s\n' "$H95" | grep -c . | tr -d ' ')"
  w95="$(printf '%s\n' "$H95" | sed "s|^$ROOT/||" | tr '\n' ' ' | sed 's/ *$//')"
else
  n95="-1"; w95="the corpus or the counter did not answer"
fi
if [ "$n95" = 1 ]; then
  ok "exactly one file under global/ states the frozen row's field list"
else
  bad "exactly one file under global/ states the frozen row's field list (${n95}: ${w95})"
fi

rm -rf "$T95"
