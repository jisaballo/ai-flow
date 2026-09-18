#!/bin/bash
# Refuse an understanding whose Verifiable Criteria do not each carry `observed:` and `falsified-by:`.
#
# The Understand protocol has asked every criterion for both fields in writing for several releases, and
# until this script nothing ever looked: a task reached planning with criteria that said nothing about
# how they could fail, and nobody found out. This is what turns that rule into an answer. It is the
# material leg of the plan precondition (protocols/backlog.md), and it runs by hand on the same terms.
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
# Entries are the list items at the indent the region's FIRST item line sits at, so the sub-bullets
# carrying the fields are body rather than criteria of their own, under either spelling and without
# keying on a depth. The first item fixes it rather than the shallowest seen so far: a running minimum
# assigns the region's opening lines against an indent it has not met yet, so what a line is read as
# depends on what comes after it.
#
# A CRITERION'S FIELDS ARE READ FROM ITS DIRECT CHILDREN AND FROM NOTHING ELSE -- the item lines at the
# shallowest indent deeper than its own, inside its own block. Three failures live in the difference,
# and each was measured rather than reasoned:
#
#   The criterion's OWN sentence is not part of what is searched. Read as body, a criterion that merely
#   NAMES the two fields in its text satisfies them while carrying neither -- and in an engine whose
#   criteria are frequently about the fields themselves, that is the ordinary sentence, not an exotic one.
#
#   Prose inside the region is not part of it either. A note written there as ordinary prose -- which is
#   what the template asks for, so that a note is not read as a criterion -- would otherwise be appended
#   to the last criterion above it and hand it any field name the note happens to mention.
#
#   A DEEPER DESCENDANT IS NOT A DIRECT CHILD. A criterion accidentally written one level too deep is,
#   by the paper's own structure, a sub-bullet; read as body it lends its `observed:` and `falsified-by:`
#   to the criterion above, MASKING a field that criterion genuinely lacks. Reading direct children only
#   removes the mask: the block is judged on what it carries at its own next level.
#
# WHAT THIS DOES NOT DO, since a limit unstated is a limit nobody can act on: the mis-indented criterion
# is still not COUNTED as a criterion -- markdown offers nothing that tells it from a sub-bullet, and
# guessing which one the author meant is a judgement about intent this script does not make anywhere
# else. What changes is that the paper no longer passes: the criterion above it is refused for the
# fields it really lacks, and the author is stopped at the block that holds the mistake.
#
# Refusing every sub-bullet that is not one of the declared fields was the other candidate and it was
# REJECTED ON MEASUREMENT, not on taste: across the 31 understandings this engine has written, 205 such
# sub-bullets exist in 16 of them -- amendment notes under a field, and the criteria of the grouped
# layout that predates the flat template. A refusal there is a FALSE one, and this mechanism ships with
# no flag to suppress it, so a false refusal stops a correct author with nothing they can do about it.
REPORT="$(awk '
function flush(  b) {
  if (lead == "") return
  b = (kidind == "") ? "" : kid
  if (b !~ /observed:/)     miss[++n] = lead SUBSEP "observed:"
  if (b !~ /falsified-by:/) miss[++n] = lead SUBSEP "falsified-by:"
  entries++
  lead = ""; kid = ""; kidind = ""
}
function endregion() { flush(); inregion = 0; depth = ""; bullet = 0 }
{
  # Tabs are admitted as indentation and must therefore be MEASURED as indentation. Counting a tab as
  # one column puts a tab-indented line at a depth no space-indented sibling can equal.
  line = $0
  while (match(line, /^[ ]*\t/)) sub(/\t/, "        ", line)

  if (!inregion) {
    if (line ~ /^###[ \t]+Verifiable Criteria/)        { inregion = 1; bullet = 0; found = 1; next }
    if (line ~ /^-[ \t]+\*\*Verifiable Criteria\*\*/)  { inregion = 1; bullet = 1; found = 1; next }
    next
  }
  if (line ~ /^#{1,6}[ \t]/)          { endregion(); next }
  if (bullet && line ~ /^-[ \t]/)     { endregion(); next }
  if (line ~ /^[ \t]*$/)              { next }

  # An item line, and its indent. The FIRST item line of the region fixes where a criterion sits; an
  # item line deeper than that belongs to the criterion above it, and only the SHALLOWEST such level --
  # the direct children of that criterion -- is what the fields are read from. A line that is neither is
  # ignored: prose, a continuation, a grandchild. Nothing here is refused for its shape.
  if (match(line, /^[ \t]*-[ \t]/)) {
    ind = index(line, "-") - 1
    if (depth == "") { depth = ind }
    if (ind == depth) {
      flush()
      lead = line
      sub(/^[ \t]*-[ \t]*/, "", lead)
      next
    }
    if (ind > depth && lead != "") {
      # A shallower child than any seen so far replaces what was collected: the deeper lines were
      # descendants of a child, never children themselves.
      if (kidind == "" || ind < kidind) { kidind = ind; kid = "" }
      if (ind == kidind)                { kid = kid " " line }
    }
  }
}
END {
  endregion()
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
