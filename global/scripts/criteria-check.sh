#!/bin/bash
# Refuse an understanding whose Verifiable Criteria do not each carry `observed:` and `falsified-by:`.
#
# The engine has asked every criterion for both fields in writing since T-131 and T-132, and until this
# script nothing ever looked: a task reached planning with criteria that said nothing about how they
# could fail, and nobody found out. This is what turns that rule into an answer. It is the material leg
# of the plan precondition (protocols/backlog.md), and it runs by hand on the same terms.
#
# WHAT IT TESTS IS PRESENCE, NEVER HONESTY. A falsifier phrased against the assertion -- "the check would
# go red" -- rather than against the subject satisfies this script with the field present. That remains a
# judgement the author owes, and the Understand gate is what refuses it. Said in the refusal itself as
# well as here, so whoever meets a green run can see from where they stand what it did not reach.
#
# THERE IS NO SUPPRESSION FLAG, and the absence is deliberate rather than unimplemented. An author who
# cannot write a falsifier does not have a criterion this mechanism should yield to -- they have one the
# Understand gate already refuses. An escape hatch readmits exactly what this exists to stop.
#
# Usage: criteria-check.sh <path to an understand.md>
#        Exit 0 when every criterion carries both fields; 1 on a refusal, naming each criterion and the
#        field it lacks; 2 when the argument is unusable.
#
# `set -e` is deliberately absent: this COLLECTS refusals, and dying at the first would report one
# criterion and stay silent about every other. Every exit below is taken on purpose.
set -uo pipefail

# The one word a refusal spends to say a field is absent. Declared here because the conformance
# contract freezes this token: the sentences around it are free to change, this is not.
MISSWORD="missing"

say() { printf 'criteria-check: %s\n' "$1"; }
die() { printf 'criteria-check: %s\n' "$1" >&2; exit 2; }

case "${1-}" in
  -h|--help) sed -n '18,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  '')        die "name the understanding to judge: criteria-check.sh <path to an understand.md>" ;;
esac
FILE="$1"
[ -f "$FILE" ] && [ -r "$FILE" ] || die "no such readable file: $FILE"

# The two live region spellings and the two live field layouts are BOTH read here, because both are in
# the corpus: a Verifiable Criteria heading at `###` level with the criteria at column zero, and the same
# name as a bold bullet with them one level in; the two fields on one sub-bullet split by a middle dot,
# and one sub-bullet per field. A parse keyed on either spelling alone reports clean over half the
# archive, which is the failure this script would otherwise ship with.
#
# THE SPELLINGS ARE DESCRIBED ABOVE RATHER THAN QUOTED, and that is a disclosed workaround rather than a
# style choice. Written as a backticked `###` string, the first one is read by the suite's citation
# extractor as a POINTER TO AN ENGINE SECTION, and refused because no heading of that name exists under
# `global/` -- true by shape and false by meaning, since this is a heading spelling this parser looks for
# in a task's artifacts and points at nothing here. Same family as the subject resolver that cannot tell
# a path a section builds from one it reads. Stated in the open, as that one is, rather than papered over.
#
# The region ends at the next markdown heading, and -- for the bullet spelling only -- at the next
# sibling bullet at column zero, which is where `- **Verifiable Criteria**` hands back to its section.
# Entries are the list items at the SHALLOWEST indent the region holds, so the sub-bullets carrying the
# fields are body rather than criteria of their own, under either spelling and without keying on a depth.
REPORT="$(awk '
function flush(  i) {
  if (lead == "") return
  if (body !~ /observed:/)     miss[++n] = lead SUBSEP "observed:"
  if (body !~ /falsified-by:/) miss[++n] = lead SUBSEP "falsified-by:"
  entries++
  lead = ""; body = ""
}
{
  if (!inregion) {
    if ($0 ~ /^###[ \t]+Verifiable Criteria/)        { inregion = 1; bullet = 0; found = 1; next }
    if ($0 ~ /^-[ \t]+\*\*Verifiable Criteria\*\*/)  { inregion = 1; bullet = 1; found = 1; next }
    next
  }
  if ($0 ~ /^#{1,6}[ \t]/)          { flush(); inregion = 0; next }
  if (bullet && $0 ~ /^-[ \t]/)     { flush(); inregion = 0; next }
  if ($0 ~ /^[ \t]*$/)              { next }

  # An item line, and its indent. The shallowest one seen in the region is what a criterion sits at;
  # anything deeper is the body of the criterion above it, whichever layout wrote it.
  if (match($0, /^[ \t]*-[ \t]/)) {
    ind = index($0, "-") - 1
    if (depth == "" || ind < depth) { depth = ind }
    if (ind == depth) {
      flush()
      lead = $0
      sub(/^[ \t]*-[ \t]*/, "", lead)
      body = $0
      next
    }
  }
  if (lead != "") body = body " " $0
}
END {
  flush()
  if (!found)   { print "NOREGION"; exit }
  if (!entries) { print "NOENTRIES"; exit }
  for (i = 1; i <= n; i++) {
    split(miss[i], p, SUBSEP)
    print "MISS" SUBSEP p[1] SUBSEP p[2]
  }
}' "$FILE")"

case "$REPORT" in
  NOREGION)
    say "$FILE: no Verifiable Criteria section could be found."
    say "  Looked for '### Verifiable Criteria' and '- **Verifiable Criteria**'. A section that cannot be"
    say "  located is refused rather than reported clean, so renaming the heading is not a way past this."
    exit 1 ;;
  NOENTRIES)
    say "$FILE: the Verifiable Criteria section holds no criterion."
    say "  An empty section is refused: passed, it would be indistinguishable from every criterion being"
    say "  complete, and both readers of the criteria would be working over zero."
    exit 1 ;;
esac

[ -n "$REPORT" ] || exit 0

# One line per missing field, naming the criterion it belongs to. A refusal that said only `malformed`
# would send the reader to search the whole artifact for what it already knew.
while IFS= read -r r; do
  [ -n "$r" ] || continue
  crit="$(printf '%s' "$r" | cut -d"$(printf '\034')" -f2 | cut -c1-80)"
  fld="$(printf '%s' "$r" | cut -d"$(printf '\034')" -f3)"
  say "$FILE: $crit: $MISSWORD $fld"
done <<< "$REPORT"

say "A criterion states both what was observed and what would prove it false. Notes inside the criteria"
say "section are read as criteria, so write a note as ordinary prose rather than as a bullet there."
say "This tests PRESENCE and not honesty: a falsifier phrased against the assertion rather than against"
say "the subject passes it. No flag suppresses this refusal, and that is deliberate."
exit 1
