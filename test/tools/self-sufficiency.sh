#!/bin/bash
# Does every section still stand on its own?
#
# A section is self-sufficient when asking for it ALONE yields exactly the passing rows a full run yields
# for that same section, and no failures. The suite is sourced into one process, so a section that reads a
# neighbour's variable still passes a full run -- this is the only instrument that says otherwise, and it
# is why it ships with the split rather than being rebuilt by whoever next touches the suite.
#
# COUNTS, not failure counts, and that is the whole design. A section that dies on an unbound variable
# emits zero [ok] AND zero [FAIL], so a test that only looked for failures scores it green while it is
# running none of its checks. Measuring this wrong cost one full wrong measurement while the split was
# being planned; the comparison below is what that mistake bought.
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

RUNNER="test/validate.sh"
WORK="$(mktemp -d)" || { echo "cannot create a working directory" >&2; exit 1; }
trap 'rm -rf "$WORK"' EXIT

echo "== full run, for the expected counts =="
bash "$RUNNER" </dev/null > "$WORK/full.txt" 2>&1 || true

# Attribute every [ok] to the heading above it. The heading is the section's own first output, so the
# attribution is exact rather than inferred from file boundaries.
awk '/^== C[0-9]+:/{ sub(/:.*/,"",$2); s=$2 } /^  \[ok\]/{ if (s!="") c[s]++ } END{ for (k in c) print k, c[k] }' \
  "$WORK/full.txt" | sort > "$WORK/expected.txt"

TOTAL=0; GOOD=0; LOST=0; BAD_SECTIONS=""
echo ""
echo "== each section alone =="
while IFS= read -r f; do
  [ -n "$f" ] || continue
  id="$(basename "$f")"; id="${id%%-*}"
  TOTAL=$((TOTAL + 1))
  want="$(awk -v s="$id" '$1==s{print $2}' "$WORK/expected.txt")"; want="${want:-0}"
  # stdin from /dev/null, and it is not a nicety: this loop reads its section list from a here-string, and
  # a run that inherited that stdin would swallow the rest of the list. Found by the totals -- the first
  # sweep reported 9 of 10 sections green over a suite of seventy-five, which is the vacuous pass this
  # tool exists to detect in others.
  bash "$RUNNER" "$id" </dev/null > "$WORK/one.txt" 2>&1 || true
  got="$(grep -c '^  \[ok\]' "$WORK/one.txt" || true)"
  fail="$(grep -c '^  \[FAIL\]' "$WORK/one.txt" || true)"
  if [ "$got" = "$want" ] && [ "$fail" = "0" ]; then
    GOOD=$((GOOD + 1))
    printf '  ok    %-6s %s rows\n' "$id" "$got"
  else
    LOST=$((LOST + want - got))
    BAD_SECTIONS="$BAD_SECTIONS $id"
    printf '  LOST  %-6s alone %s of %s rows, %s failing\n' "$id" "$got" "$want" "$fail"
    # A section that cannot even start says so on the first line it managed to print.
    head -3 "$WORK/one.txt" | sed 's/^/          /'
  fi
done <<< "$(ls test/sections/C*.sh | awk -F/ '{n=$NF; sub(/^C/,"",n); sub(/-.*/,"",n); print n"\t"$0}' | sort -n | cut -f2-)"

echo ""
echo "Self-sufficient: $GOOD / $TOTAL sections, $LOST rows lost"
[ -n "$BAD_SECTIONS" ] && echo "Dependent:$BAD_SECTIONS"
[ "$GOOD" = "$TOTAL" ]
