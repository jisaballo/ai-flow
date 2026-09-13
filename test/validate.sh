#!/bin/bash
# Conformance harness for T-001 — layered project model (project.yml).
# Generated in the Conform phase from understand.md Verifiable Criteria.
# Dependency-free (grep-based) so it runs on any device; optional YAML lint if python3+pyyaml present.
# Exit 0 only when every section is green.

set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

. "$ROOT/test/lib/preamble.sh"
# --- the run ------------------------------------------------------------------------------------------
# Sections are SOURCED, not spawned: one process keeps the counters summing with no output to parse, and
# keeps a full run as fast as it was when this was a single file. It is therefore NOT the independence
# check -- a section reading a neighbour's variable still passes here. test/tools/self-sufficiency.sh is
# what answers that question, by running each section alone.
#
# Numeric order, which is not the order a glob gives: sorted as text, C10 precedes C2.
WANT="${1-}"
RAN=0
for SECTION in $(suite_sections); do
  case "$WANT" in
    "") ;;
    *) [ "$(section_id "$SECTION")" = "$WANT" ] || continue ;;
  esac
  RAN=$((RAN + 1))
  . "$SECTION"
done

# An identifier naming no section stops the run and says so. Running everything instead would answer a
# question nobody asked; running nothing would report a clean suite over nothing at all.
if [ -n "$WANT" ] && [ "$RAN" -eq 0 ]; then
  echo "no section is named $WANT" >&2
  printf '  sections:' >&2
  suite_sections | while IFS= read -r s; do printf ' %s' "$(section_id "$s")" >&2; done
  echo "" >&2
  exit 2
fi

# A run that produced no row is not a clean run. The branch above covers the filtered half -- an
# identifier naming no section -- and this covers the other: an absent, renamed or unreadable corpus
# makes `suite_sections` answer with nothing and a status of 0, which is byte-identical to a corpus of
# zero files. Without this, `Result: 0 passed, 0 failed` and an exit of 0 report a clean suite over
# nothing at all, which is the one verdict this harness exists to refuse.
if [ "$((PASS + FAIL))" -eq 0 ]; then
  echo "no section produced a row: the section corpus is empty or unreadable" >&2
  exit 2
fi

echo ""
echo "Result: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
