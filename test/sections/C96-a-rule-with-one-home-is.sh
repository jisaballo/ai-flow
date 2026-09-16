# =====================================================================================================
# C96 -- a rule with one home is reached by every region that must reach it
#
# THE ADMISSIBILITY TEST THIS BLOCK IS BUILT TO, because the next reader will ask why these rows exist
# where their neighbours are recorded as absences instead:
#
#   A leg is admissible where it asserts STRUCTURE -- how many homes a rule has, whether each region
#   that must reach it does, and whether a citation names something that exists -- because all three are
#   computed from the tree and can disagree with it. A leg is refused where its only available key is
#   the WORDING, whenever it was written.
#
# Timing is NOT the licence. A leg emitted before the prose it reads exists was not fooling its author
# in that one moment; it says nothing about the years it then sits in the suite being read by editors
# who were not there. Every row below is keyed on counts, list-item boundaries and name resolution. NOT
# ONE OF THEM READS WHAT A SECTION SAYS, and the mutation record in the manifest is what makes that
# claim payable rather than asserted: rewording every sentence of the exemption leaves this block green.
#
# WHAT THESE ROWS DO NOT REACH, recorded now rather than discovered later:
#   - ROW 3 counts DISTINCT list items, not which ones. A citation moved from item 3 to a new item 9
#     keeps the count at two. The defect it exists for -- both citations collapsing into one item, which
#     is what actually shipped once -- is caught; a reshuffle is not.
#   - ROW 4 resolves a citation to a heading of that name ANYWHERE under global/. It does not check the
#     heading is in the file the citing sentence names.
#   - ROW 5 compares two sites against each other. Both moving together in the same wrong direction is
#     invisible to it, as it is to any agreement check.
# =====================================================================================================
echo ""
echo "== C96: a rule with one home is reached by every region that must reach it =="

T96="$(mkbox)" || fatal 'C96 fixtures'

PROT96="$ROOT/global/protocols"
EXEC96="$PROT96/execute.md"
PLAN96="$PROT96/plan.md"

# Citations, extracted structurally: a backtick-quoted `### Name` anywhere under global/. The extractor
# never learns any particular name -- it reads whatever the corpus cites.
cites96() { grep -rhoE '`### [A-Za-z][^`]*`' "$1" 2>/dev/null | sed 's/^`//;s/`$//' | sort -u; }

# Which top-level numbered items of a region carry a given reference. The unit is the LIST ITEM, which
# is structure: a line `N. ` opens item N and every line after it belongs to N until the next one.
citing_items96() { # $1 = file, $2 = region heading, $3 = needle -> one item number per line
  awk -v head="$2" -v needle="$3" '
    $0 == head { f = 1; next }
    f && /^### / { exit }
    f { if (match($0, /^[0-9]+\. /)) { item = substr($0, 1, RSTART + RLENGTH - 3) }
        if (item != "" && index($0, needle) > 0) print item }
  ' "$1" | sort -u
}

# ROW 1 -- the corpus. Every verdict below is a count, and a count over a corpus that silently emptied
# is the same number as a corpus that was genuinely clean.
FERR96="$T96/find.err"
nmd96="$(find "$PROT96" -name '*.md' 2>"$FERR96" | grep -c . | tr -d ' ')"
if [ -d "$PROT96" ] && [ "${nmd96:-0}" -ge 6 ] && [ -r "$EXEC96" ] && [ ! -s "$FERR96" ]; then
  ok "the protocol corpus is populated and wholly readable"
else
  bad "the protocol corpus is populated and wholly readable (${nmd96:-0} file(s))"
fi

# ROW 2 -- both extractors are shown to MEASURE, on planted fixtures, before any verdict is read.
#
# Each fixture plants the exact shape its verdict must catch: a region whose two references sit in ONE
# item (the defect that actually shipped) beside one whose references sit in two, and a citation naming
# a heading that does not exist beside one that does. An extractor that found nothing would score every
# verdict below perfect.
mkdir -p "$T96/fx"
{ printf '%s\n' '### Execute Step Protocol'
  printf '%s\n' '1. first'
  printf '%s\n' '2. second'
  printf '%s\n' '   - see the widget rule below'
  printf '%s\n' '   - and again the widget rule below'
  printf '%s\n' '### Something Else'
} > "$T96/fx/collapsed.md"
{ printf '%s\n' '### Execute Step Protocol'
  printf '%s\n' '1. first, see the widget rule below'
  printf '%s\n' '2. second'
  printf '%s\n' '   - also the widget rule below'
  printf '%s\n' '### Something Else'
} > "$T96/fx/spread.md"
{ printf '%s\n' 'A citation of `### Real Heading` and one of `### Ghost Heading`.'
  printf '%s\n' '### Real Heading'
} > "$T96/fx/cited.md"
c96="$(citing_items96 "$T96/fx/collapsed.md" '### Execute Step Protocol' 'widget rule' | tr '\n' ' ' | sed 's/ *$//')"
s96="$(citing_items96 "$T96/fx/spread.md"    '### Execute Step Protocol' 'widget rule' | tr '\n' ' ' | sed 's/ *$//')"
g96="$(cites96 "$T96/fx" | tr '\n' ' ' | sed 's/ *$//')"
if [ "$c96" = "2" ] && [ "$s96" = "1 2" ] && [ "$g96" = "### Ghost Heading ### Real Heading" ]; then
  ok "the item extractor tells a collapsed citation from a spread one, and the citation extractor reads names"
else
  bad "the item extractor tells a collapsed citation from a spread one, and the citation extractor reads names (collapsed='$c96' spread='$s96' cites='$g96')"
fi
MEASURING96=$([ "$c96" = "2" ] && [ "$s96" = "1 2" ] && [ "$g96" = "### Ghost Heading ### Real Heading" ] && echo 1 || echo 0)

# ROW 3 -- the exemption has ONE home, and TWO DISTINCT items of the step loop reach it.
#
# This is the H1 defect expressed as a count. The exemption shipped once on the commit rule alone while
# the gate that actually blocks the loop was untouched: one distinct item, not two. Nothing read it, and
# the review found it rather than the suite.
r3_96=""
if [ "${nmd96:-0}" -ge 6 ] && [ "$MEASURING96" = 1 ]; then
  nh96="$(grep -rlxF '### The frozen-row exemption' --include='*.md' "$PROT96" 2>/dev/null | grep -c . | tr -d ' ')"
  [ "${nh96:-0}" = 1 ] || r3_96="$r3_96 [the exemption has ${nh96:-0} homes, not one]"
  ni96="$(citing_items96 "$EXEC96" '### Execute Step Protocol' 'frozen-row exemption' | grep -c . | tr -d ' ')"
  [ "${ni96:-0}" -ge 2 ] || r3_96="$r3_96 [only ${ni96:-0} item(s) of the step loop reach it; both gates must]"
else
  r3_96=" [the corpus or the extractors did not answer]"
fi
[ -z "$r3_96" ] \
  && ok "the frozen-row exemption has one home and two distinct step-loop items reach it" \
  || bad "the frozen-row exemption has one home and two distinct step-loop items reach it ($r3_96)"

# ROW 4 -- every cited section name resolves to a heading that exists.
#
# A pointer is only worth the thing it points at. The one-home repair replaced enumerations with
# citations, so from that moment a renamed heading leaves every home count correct and every pointer
# dangling. This never reads what a section SAYS -- only that what is named is there.
r4_96=""
if [ "${nmd96:-0}" -ge 6 ] && [ "$MEASURING96" = 1 ]; then
  nc96="$(cites96 "$ROOT/global" | grep -c . | tr -d ' ')"
  if [ "${nc96:-0}" -lt 4 ]; then
    r4_96=" [only ${nc96:-0} section citations found under global/: the extractor is not reading the corpus]"
  else
    while IFS= read -r h96; do
      [ -n "$h96" ] || continue
      grep -rqlxF "$h96" --include='*.md' "$ROOT/global" 2>/dev/null \
        || r4_96="$r4_96 [$h96 is cited and no heading of that name exists]"
    done <<EOF
$(cites96 "$ROOT/global")
EOF
  fi
else
  r4_96=" [the corpus or the extractors did not answer]"
fi
[ -z "$r4_96" ] \
  && ok "every cited section name resolves to a heading that exists" \
  || bad "every cited section name resolves to a heading that exists ($r4_96)"

# ROW 5 -- the cause vocabulary and the template that must offer it agree.
#
# Two independent sites, each read from the document and compared against the other -- neither is a list
# this file keeps. A cause added to one and not the other goes red, which is exactly how the third cause
# reached the vocabulary while the mandatory template still offered the first alone.
r5_96=""
if [ "${nmd96:-0}" -ge 6 ] && [ -r "$PLAN96" ]; then
  DEF96="$(awk '/^6\. \*\*A non-emitting criterion/{f=1;next} f&&/^[0-9]+\. /{exit} f&&/^   - \*\*/{gsub(/^   - \*\*/,"");sub(/\*\*.*/,"");print}' "$PLAN96" | sort -u | tr '\n' ' ' | sed 's/ *$//')"
  TPL96="$(grep -oE '"— \([a-z]+\)"' "$PLAN96" | sed 's/.*(\(.*\)).*/\1/' | sort -u | tr '\n' ' ' | sed 's/ *$//')"
  [ -n "$DEF96" ] || r5_96="$r5_96 [no cause definitions extracted: the leg is not reading the vocabulary]"
  [ -n "$TPL96" ] || r5_96="$r5_96 [no causes extracted from the template]"
  [ -z "$r5_96" ] && [ "$DEF96" != "$TPL96" ] \
    && r5_96="$r5_96 [the vocabulary defines '$DEF96' and the template offers '$TPL96']"
else
  r5_96=" [no plan protocol to read]"
fi
[ -z "$r5_96" ] \
  && ok "every cause the vocabulary defines is a cause the mandatory template offers" \
  || bad "every cause the vocabulary defines is a cause the mandatory template offers ($r5_96)"

# ROW 6 -- every field the frozen-row table carries is marked with a lifecycle.
#
# The COMPLETENESS half of the same criterion -- does the table hold every field the section orders --
# is not here and cannot be: deciding what the prose orders means reading the prose. This is the half
# that is structural. A table cell is a cell; a field added without a lifecycle leaves one empty, and
# the audit that compares "every field marked frozen at Conform" then has a field it cannot classify.
# The value is never inspected, only its presence: naming the two lifecycles here would pin the wording
# this block exists to avoid.
r6_96=""
if [ -r "$PLAN96" ]; then
  TBL96="$(awk '/^### The frozen row$/{f=1;next} f&&/^### /{exit} f&&/^\| /{print}' "$PLAN96" \
           | grep -v '^| *Field *|' | grep -v '^|[ -]*|[ -]*|[ -]*|$')"
  nr96="$(printf '%s\n' "$TBL96" | grep -c . | tr -d ' ')"
  if [ "${nr96:-0}" -lt 5 ]; then
    r6_96=" [only ${nr96:-0} field row(s) extracted: the leg is not reading the table]"
  else
    nblank96="$(printf '%s\n' "$TBL96" | awk -F'|' '{ g=$3; gsub(/[[:space:]]/,"",g); if (g=="") print }' | grep -c . | tr -d ' ')"
    [ "${nblank96:-0}" = 0 ] || r6_96=" [${nblank96} field row(s) carry no lifecycle]"
  fi
else
  r6_96=" [no plan protocol to read]"
fi
[ -z "$r6_96" ] \
  && ok "every field of the frozen-row table is marked with a lifecycle" \
  || bad "every field of the frozen-row table is marked with a lifecycle ($r6_96)"

rm -rf "$T96"
