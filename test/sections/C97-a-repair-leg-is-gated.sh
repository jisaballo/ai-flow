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
# Timing is NOT the licence. Both rows below are keyed on a home count and on list-item boundaries.
# NEITHER READS WHAT THE RULE SAYS: rewriting every sentence of the acceptance rule, its prohibition and
# its record leaves this block green, and the manifest's mutation record is what makes that claim payable.
#
# WHAT THESE ROWS DO NOT REACH, recorded now rather than discovered later:
#   - ROW 4 counts DISTINCT list items of the skill, not WHICH ones. A citation moved from the triage
#     branch to some third item keeps the count at two. The defect it exists for -- a citation deleted
#     from one site while the other keeps it -- is caught; a relocation is not.
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

# Which top-level list items of a file carry a given reference. The unit is the LIST ITEM, which is
# structure: a line `N. ` or a line `- ` opens an item and every line after it belongs to that item
# until the next one opens. The extractor never learns any particular site -- it reads whatever cites.
citing_items97() { # $1 = file, $2 = needle -> one item key per line
  awk -v needle="$2" '
    /^[0-9]+\. / || /^- / { item = NR }
    item != "" && index($0, needle) > 0 { print item }
  ' "$1" | sort -u
}

# ROW 1 -- the corpus. Every verdict below is a count, and a count over a corpus that silently emptied
# reads exactly like a corpus that was genuinely wrong.
FERR97="$T97/find.err"
nmd97="$(find "$GLOB97" -name '*.md' 2>"$FERR97" | grep -c . | tr -d ' ')"
if [ -d "$GLOB97" ] && [ "${nmd97:-0}" -ge 6 ] && [ -r "$SKILL97" ] && [ ! -s "$FERR97" ]; then
  ok "the engine corpus is populated and the verify skill is readable"
else
  bad "the engine corpus is populated and the verify skill is readable (${nmd97:-0} markdown file(s))"
fi

# ROW 2 -- the item extractor is shown to MEASURE, on planted fixtures, before any verdict is read.
#
# Each fixture plants the exact shape its verdict must catch: a file whose two references sit in ONE
# item beside one whose references sit in three, across both item shapes the skill actually uses. An
# extractor that found nothing would score every verdict below perfect.
mkdir -p "$T97/fx"
{ printf '%s\n' '1. first step'
  printf '%s\n' '2. second step'
  printf '%s\n' '   - one mention of the widget rule'
  printf '%s\n' '   - and again the widget rule'
} > "$T97/fx/collapsed.md"
{ printf '%s\n' '1. first step, see the widget rule'
  printf '%s\n' '- a bullet that also names the widget rule'
  printf '%s\n' '- a second bullet naming the widget rule'
} > "$T97/fx/spread.md"
c97="$(citing_items97 "$T97/fx/collapsed.md" 'widget rule' | grep -c . | tr -d ' ')"
s97="$(citing_items97 "$T97/fx/spread.md"    'widget rule' | grep -c . | tr -d ' ')"
if [ "${c97:-0}" = "1" ] && [ "${s97:-0}" = "3" ]; then
  ok "the item extractor tells a collapsed citation from one spread across three items"
else
  bad "the item extractor tells a collapsed citation from one spread across three items (collapsed=${c97:-} spread=${s97:-})"
fi
MEASURING97=$([ "${c97:-0}" = "1" ] && [ "${s97:-0}" = "3" ] && echo 1 || echo 0)

# ROW 3 (A1) -- the acceptance rule has exactly ONE home under global/.
#
# The rule this task ships binds every actor that writes a leg, so it is the shape a second copy costs
# the most: two homes drift, and the site citing the stale one gates against a rule nobody else applies.
r3_97=""
if [ "${nmd97:-0}" -ge 6 ]; then
  nh97="$(grep -rlxF "$HOME97" --include='*.md' "$GLOB97" 2>/dev/null | grep -c . | tr -d ' ')"
  [ "${nh97:-0}" = 1 ] || r3_97=" [the acceptance rule for a repair leg has ${nh97:-0} homes under global/, not one]"
else
  r3_97=" [the corpus did not answer]"
fi
[ -z "$r3_97" ] \
  && ok "the acceptance rule for a repair leg has exactly one home under global/" \
  || bad "the acceptance rule for a repair leg has exactly one home under global/ ($r3_97)"

# ROW 4 (A2) -- two DISTINCT items of the verify skill reach that rule.
#
# The skill has two sites at which a repair may author a leg. A gate reached from one of them is a gate
# the other walks past, and the walk leaves no trace: the leg is written, the finding closes, and
# nothing anywhere says the falsifier was never run.
r4_97=""
if [ -r "$SKILL97" ] && [ "$MEASURING97" = 1 ]; then
  ni97="$(citing_items97 "$SKILL97" "$NEEDLE97" | grep -c . | tr -d ' ')"
  [ "${ni97:-0}" -ge 2 ] || r4_97=" [only ${ni97:-0} item(s) of the verify skill reach the acceptance rule; every repair site must]"
else
  r4_97=" [the verify skill or the extractor did not answer]"
fi
[ -z "$r4_97" ] \
  && ok "two distinct items of the verify skill reach the acceptance rule for a repair leg" \
  || bad "two distinct items of the verify skill reach the acceptance rule for a repair leg ($r4_97)"

rm -rf "$T97"
