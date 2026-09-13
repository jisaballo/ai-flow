# C60 — a capability has one written shape, and the session that touches it receives it.
# Generated in the Conform phase from understand.md's Verifiable Criteria (A1-A7; the two observables and
# the first behavioural are inspection, per D2 — the wiring lives in a gitignored file the suite never
# reads, and a fixture would prove a different claim).
#
# Written red in Conform and replaced leg by leg in Execute, one step at a time. Every row below now
# asserts; none is a placeholder. A3's exemption and A6's document set were both widened at Verify, each
# against a confirmed HIGH — the comments at those two rows say what they were and why they moved.
echo "== C60: a capability has one written shape, and the session that touches it receives it =="

# One name per path, declared before either block reads it: A3 reads the map for the budget it declares
# and A5 reads it for the diagram, and two spellings of one path are two things to keep in step.
MAP88="docs/architecture/README.md"
CARD88="docs/architecture/verify.md"
CARDDIR88="$(dirname "$MAP88")"
BLOCKS88="What it is|The artifacts|The homes table|External dependencies"

# THE REGISTER, derived from the map's own cards table, once, and named. Never a second literal and never
# a list written beside it: the map is the document that governs the card type, so a guard keeping its own
# list would enforce the rule on whatever it remembered instead of on what is registered — which is how
# this block came to measure one card while the rule it applied was written for any.
# Rows are taken on `^| `, which the separator's `|---|` cannot match; the header is dropped on its own
# subject rather than on position; the link target is the row's only `](…)` span, resolved against the
# map's own directory because a card is registered as a sibling filename.
CARDSEC88="$(awk '/^## The cards$/{f=1;next} /^## /{f=0} f' "$MAP88" 2>/dev/null)"
CARDS88="$(printf '%s\n' "$CARDSEC88" | grep '^| ' | grep -vE '^\| Capability \|' \
           | grep -oE '\]\([^)]+\)' | sed -E 's/^\]\((.*)\)$/\1/' \
           | awk -v d="$CARDDIR88" 'NF{print d "/" $0}' | sort -u)"

# --- A12: the map's cards table IS the register, and the register is complete both ways -------------
# Five legs. FLOORED, because a register that extracts to nothing turns every loop below into a green row
# over no card at all — the failure A9 already guards against beside A8. ANCHORED, because a floor is
# satisfied by one wrong card. BOTH DIRECTIONS, and each cut to the clause that owns it rather than
# folded into one pattern over the pair: a card registered with no file, and a card file nobody
# registered, are opposite defects, and exchanging the two verdicts has to leave the row red.
# The map's prose is the fifth, in two legs because it makes two claims and prose carrying either one
# alone would satisfy a single pattern: the table is the register, and a card it does not list is not a
# card. A rule enforced here with no home in the document that governs the card type is the drift the
# whole single-home discipline exists to remove.
a12_88=""
[ -n "$CARDS88" ] || a12_88="$a12_88 [the map's cards table yielded no card at all]"
printf '%s\n' "$CARDS88" | grep -qxF "$CARD88" \
  || a12_88="$a12_88 [the register does not name $CARD88]"
while IFS= read -r c88; do
  [ -n "$c88" ] || continue
  { [ -r "$c88" ] && [ -s "$c88" ]; } \
    || a12_88="$a12_88 [registered and not a readable file: $c88]"
done <<< "$CARDS88"
for f88 in "$CARDDIR88"/*.md; do
  [ -e "$f88" ] || continue
  # The map is the register and not a card, so it is excepted BY NAME: a rule that excepted "the file the
  # guard happens to read" would except whatever the guard was pointed at next.
  [ "$f88" = "$MAP88" ] && continue
  printf '%s\n' "$CARDS88" | grep -qxF "$f88" \
    || a12_88="$a12_88 [a card file the map does not register: $f88]"
done
# A row whose Card cell is NOT A LINK yields no card, so it reaches neither direction above: the map
# registers it and the guard never measures it — the first half of the rule this row asserts, defeated
# without a file being missing or an entry being absent. The two counts are of the same kind, so the leg
# is an equality and the diagnostic carries both numbers; a verdict saying only "a row registered nothing"
# would not say how many of either. The extraction is `sort -u`, so two rows naming one file collapse and
# are named here too, which is the same defect wearing the other sign.
ROWN88="$(printf '%s\n' "$CARDSEC88" | grep '^| ' | grep -vcE '^\| Capability \|' | tr -d ' ')"
CARDN88="$(printf '%s\n' "$CARDS88" | grep -c . | tr -d ' ')"
[ "$ROWN88" = "$CARDN88" ] \
  || a12_88="$a12_88 [the cards table carries $ROWN88 rows but $CARDN88 of them registered a card]"
# Two claims of the same shape, so each is bound to its own SUBJECT AND PREDICATE, adjacent, in a single
# pattern. Two loose words in one sentence is not enough and the failure is not hypothetical: it accepts
# either claim NEGATED ("this table is not the register"), and it accepts the exchange this comment used to
# quote as the thing it defended against — "this table is not a card, a card not listed here is the
# register" — because the helper splits a region on the period alone, so a comma-joined exchange is ONE
# chunk carrying every pattern of both legs. Cutting to the sentence is therefore no remedy at all where
# the writer uses a comma; binding the predicate to its subject is, and it holds whatever the punctuation.
# Words are separated by a whitespace CLASS rather than by literal spaces, and the helper flattens the
# region's own line breaks, so neither leg can redden because unchanged words were re-wrapped mid-claim.
[ "$(insent "$CARDSEC88" 'this[[:space:]]+table[[:space:]]+is[[:space:]]+the[[:space:]]+register')" = 1 ] \
  || a12_88="$a12_88 [the map never says its cards table is the register]"
[ "$(insent "$CARDSEC88" 'not[[:space:]]+listed[[:space:]]+here[[:space:]]+is[[:space:]]+not[[:space:]]+a[[:space:]]+card')" = 1 ] \
  || a12_88="$a12_88 [the map never says a card it does not list is not a card]"
[ -z "$a12_88" ] && ok "A12 the map's cards table is the register, and it is complete in both directions" \
                 || bad "A12 the map's cards table is the register, and it is complete in both directions:$a12_88"

# A1, A2 and A3 accumulate ACROSS THE REGISTER: one ok/bad row each whatever the register's size, so the
# suite's row count does not grow with the number of cards, and every diagnostic names the card it came
# from — a verdict reading "a card is over the budget" would send its reader back to measure every
# registered file by hand. Each row carries the register's floor, because a loop over an empty set
# satisfies every assertion written inside it.
a1_88=""; a2_88=""; a3_88=""
if [ -z "$CARDS88" ]; then
  a1_88="$a1_88 [the register yielded no card to measure]"
  a2_88="$a2_88 [the register yielded no card to measure]"
  a3_88="$a3_88 [the register yielded no card to measure]"
fi

# The two ceilings are read from the map ONCE, before the loop: they are the budget of a card as such and
# not of one card, so re-reading them per card would extract the same number N times. The NUMBERS are
# extracted, not pinned: the comparisons below use what the map declares, so raising a ceiling there
# raises it here, which is what "the map is the home" has to mean if it is to mean anything.
if ! { [ -r "$MAP88" ] && [ -s "$MAP88" ]; }; then
  a3_88="$a3_88 [the map that declares the budget is unreadable or empty: $MAP88]"
  NLIM88=""; WLIM88=""
else
  NLIM88="$(grep -oE '\*\*[0-9]+ lines\*\*' "$MAP88" | head -1 | grep -oE '[0-9]+')"
  WLIM88="$(grep -oE '\*\*[0-9]+ words\*\*' "$MAP88" | head -1 | grep -oE '[0-9]+')"
fi
[ -n "$NLIM88" ] || a3_88="$a3_88 [the map declares no Nano ceiling]"
[ -n "$WLIM88" ] || a3_88="$a3_88 [the map declares no body ceiling]"

while IFS= read -r c88; do
  [ -n "$c88" ] || continue
  if ! { [ -r "$c88" ] && [ -s "$c88" ]; }; then
    # A per-card diagnostic INSIDE the loop, not a branch around the three rows: with a register holding
    # more than one card, gating the rows on readability would silence three verdicts about every other
    # card because one was unreadable.
    a1_88="$a1_88 [$c88 is unreadable or empty]"
    a2_88="$a2_88 [$c88 is unreadable or empty]"
    a3_88="$a3_88 [$c88 is unreadable or empty]"
    continue
  fi
  # Sections and Nano lines are read from EXTRACTED regions, never from a file-wide grep: the card's prose
  # names its own block titles, and a bare grep would accept a card whose headings say one thing and whose
  # summary says another — which is the exact drift the derived-summary rule exists to prevent.
  SECS88="$(grep '^## ' "$c88" | grep -v '^## Nano$' | sed 's/^## //' | sort)"
  NANO88="$(awk '/^## Nano$/{f=1;next} /^## /{f=0} f' "$c88")"
  NTITLES88="$(printf '%s\n' "$NANO88" | grep '^- \*\*' | sed -E 's/^- \*\*(.*)\*\* —.*/\1/' | sort)"

  # --- A1: the card exists and carries the four blocks -----------------------
  printf '%s\n' "$NANO88" | grep -q '^- ' || a1_88="$a1_88 [$c88: the Nano block carries no lines]"
  n1_88=0
  IFS='|'; for b88 in $BLOCKS88; do
    printf '%s\n' "$SECS88" | grep -qxF "$b88" || a1_88="$a1_88 [$c88: $b88 is not a section]"
    n1_88=$((n1_88+1))
  done; unset IFS
  # A count, so a card that grows a sixth block is caught rather than passing on containment alone.
  [ "$(printf '%s\n' "$SECS88" | grep -c .)" = "$n1_88" ] \
    || a1_88="$a1_88 [$c88: the card carries $(printf '%s\n' "$SECS88" | grep -c .) sections, not $n1_88]"

  # --- A2: the summary is derived from the body, in BOTH directions ----------
  # Set equality, not containment. A section with no Nano line is an undescribed block; a Nano line naming
  # no section is a summary of something that is not there. Only both legs catch both.
  [ -n "$NTITLES88" ] || a2_88="$a2_88 [$c88: no Nano line declares a section title]"
  MISS88="$(comm -23 <(printf '%s\n' "$SECS88") <(printf '%s\n' "$NTITLES88") | tr '\n' ' ')"
  EXTRA88="$(comm -13 <(printf '%s\n' "$SECS88") <(printf '%s\n' "$NTITLES88") | tr '\n' ' ')"
  [ -z "$(printf '%s' "$MISS88" | tr -d ' ')" ] \
    || a2_88="$a2_88 [$c88: sections with no Nano line: $MISS88]"
  [ -z "$(printf '%s' "$EXTRA88" | tr -d ' ')" ] \
    || a2_88="$a2_88 [$c88: Nano lines naming no section: $EXTRA88]"

  # --- A3: the budget the map declares, measured on this card ----------------
  # The exemption the map grants is the HOMES TABLE's rows and no other table's. Stripping every `^|` line
  # forgave the artifacts and external-dependencies tables too — 275 of the verify card's own words at the
  # time this was found — and left two of the four bounded blocks unbounded for good, over a map that
  # names the homes table as the only one licensed to grow.
  BODY88="$(awk '/^## Nano$/{f=1;next} /^## /{f=0} !f' "$c88")"
  NLINES88="$(printf '%s\n' "$NANO88" | grep -c '^- ' | tr -d ' ')"
  # The section heading is KEPT here and skipped in the homes count below, so the two partition the body
  # exactly — which is what lets the identity leg further down be an equality rather than an inequality
  # that would pass over any exemption at all.
  BWORDS88="$(printf '%s\n' "$BODY88" | awk '/^## The homes table$/{h=1} /^## /{if(!/^## The homes table$/)h=0} !(h && /^\|/)' | wc -w | tr -d ' ')"
  [ -z "$NLIM88" ] || [ "$NLINES88" -le "$NLIM88" ] 2>/dev/null \
    || a3_88="$a3_88 [$c88: the Nano is $NLINES88 lines, over the map's $NLIM88]"
  [ -z "$WLIM88" ] || [ "$BWORDS88" -le "$WLIM88" ] 2>/dev/null \
    || a3_88="$a3_88 [$c88: the body is $BWORDS88 words, over the map's $WLIM88]"
  # The table is the block licensed to grow, so the count must actually exclude it: a measurement that
  # counted table rows would make the exemption a sentence nothing honours.
  # Anti-hollowness, and it names WHICH table: that some pipe-prefixed line was dropped proves nothing, and
  # proving nothing is how the wrong exemption survived this row's first draft. So both directions — the
  # homes table's rows are out of the count, and the other tables' rows are in it.
  ALL88="$(printf '%s\n' "$BODY88" | wc -w | tr -d ' ')"
  HOMEW88="$(printf '%s\n' "$BODY88" | awk '/^## The homes table$/{h=1;next} /^## /{h=0} h && /^\|/' | wc -w | tr -d ' ')"
  OTHERW88="$(printf '%s\n' "$BODY88" | awk '/^## The homes table$/{h=1;next} /^## /{h=0} !h && /^\|/' | wc -w | tr -d ' ')"
  [ "$HOMEW88" -gt 0 ] 2>/dev/null && [ "$ALL88" = "$((BWORDS88 + HOMEW88))" ] 2>/dev/null \
    || a3_88="$a3_88 [$c88: the count does not exclude exactly the homes table's rows: body $ALL88, counted $BWORDS88, homes $HOMEW88]"
  [ "$OTHERW88" = "0" ] 2>/dev/null || [ "$BWORDS88" -gt "$OTHERW88" ] 2>/dev/null \
    || a3_88="$a3_88 [$c88: the other tables' rows ($OTHERW88 words) are not inside the count]"
done <<< "$CARDS88"

[ -z "$a1_88" ] && ok "A1 every registered card exists and carries its summary and its four blocks" \
                || bad "A1 every registered card exists and carries its summary and its four blocks:$a1_88"
[ -z "$a2_88" ] && ok "A2 every registered card's summary is derived from its body, in both directions" \
                || bad "A2 every registered card's summary is derived from its body, in both directions:$a2_88"
[ -z "$a3_88" ] && ok "A3 every registered card is inside the budget a card is given" \
                || bad "A3 every registered card is inside the budget a card is given:$a3_88"

# --- A4: THE VERIFY CARD is inside the guard that keeps the count current ---------------------------
# This row is pinned to ONE card on purpose, and the next reader should not generalise it by symmetry.
# Its claim is that the document carrying the auditor count is swept by the guard that keeps that count
# current — a fact about the verify capability, not about cards as a type: another card has no auditor
# count to keep current, and asserting this of the register would be red on a correct second card.
# It reads the SET the guard consumes and never opens the card, so it needs no readability branch and
# stands outside the register loop above. Read from that set and never from a second list: a copy here
# would go green while the guard itself had dropped the card, which is the only failure this row exists
# to see.
a4_88=""
if ! command -v marker89 >/dev/null 2>&1; then
  a4_88="$a4_88 [the marker table was never defined — the auditor-count check did not run]"
else
  DOCS88="$(marker89 "Auditor list")"
  [ -n "$DOCS88" ] || a4_88="$a4_88 [the auditor-document sweep selected nothing]"
  printf '%s\n' "$DOCS88" | grep -qxF "$CARD88" \
    || a4_88="$a4_88 [the card is not among the documents the auditor-count guard reads]"
fi
[ -z "$a4_88" ] && ok "A4 the card is inside the guard that keeps every home naming the current count" \
                || bad "A4 the card is inside the guard that keeps every home naming the current count:$a4_88"

# A7 is gated on nothing the register owns, because it reads only the suite: gated on a card it would
# go silent on an unreadable card while asserting nothing about one.
# --- A7: the hand-written document list has not been reverted -------------
# What the computed set replaced was a literal list of eight, and the value of replacing it is lost the
# moment one is written back beside it: a dead list reads to the next reader as the authority. So this
# row's claim is the ABSENCE, and it is distinct from A10's below, which requires the presence of the
# computed one — a guard could read the sweep and still keep a stale list beside it, and only this row
# would see that. Neither pattern can match the line asserting it: one is anchored to the start of a
# continuation line, the other to the start of an assignment.
a7_88=""
[ "$(suite_src | grep -c '^  for e83 in ' | tr -d ' ')" = "0" ] \
  || a7_88="$a7_88 [the auditor guard still enumerates its documents by hand]"
[ "$(suite_src | grep -cE '^CRD83=' | tr -d ' ')" = "0" ] \
  || a7_88="$a7_88 [a variable from the hand-written document list survives]"
[ -z "$a7_88" ] && ok "A7 the hand-written document list has not been reverted" \
                || bad "A7 the hand-written document list has not been reverted:$a7_88"
if ! { [ -r "$MAP88" ] && [ -s "$MAP88" ]; }; then
  bad "A5 the root map draws the engine's capabilities and both arrow kinds ($MAP88 is unreadable or empty)"
else
  # The verdict is a count inside the EXTRACTED mermaid block, never a file-wide grep: the prose around the
  # diagram names every capability too, and a bare grep would pass over a map with no diagram at all.
  a5_88=""
  FENCE88="$(awk '/^```mermaid$/{f=1;next} /^```$/{f=0} f' "$MAP88")"
  [ -n "$FENCE88" ] || a5_88="$a5_88 [no mermaid block could be extracted]"
  # Nine capabilities, each as a NODE — matched on the quoted label a node declaration carries, so a
  # capability that only appears inside an arrow line does not count as drawn.
  for cap88 in understand plan execute verify "backlog ceremonies" ralph install harness "guardrail hooks"; do
    printf '%s\n' "$FENCE88" | grep -qF "[\"$cap88\"]" || a5_88="$a5_88 [$cap88 is not a node]"
  done
  # Both arrow kinds, and no third: an unlabelled edge or a third verb would make the map's own legend false.
  for kind88 in requires enriches; do
    [ "$(printf '%s\n' "$FENCE88" | grep -c -- "|$kind88|" | tr -d ' ')" -ge 1 ] \
      || a5_88="$a5_88 [no edge is labelled $kind88]"
  done
  EDGES88="$(printf '%s\n' "$FENCE88" | grep -c -- '-->' | tr -d ' ')"
  LABELLED88="$(printf '%s\n' "$FENCE88" | grep -c -E -- '-->\|(requires|enriches)\|' | tr -d ' ')"
  [ "$EDGES88" = "$LABELLED88" ] \
    || a5_88="$a5_88 [$LABELLED88 of $EDGES88 edges carry one of the two arrow kinds]"
  # conform is not a node, and the map says why rather than leaving the absence to be read as an oversight.
  printf '%s\n' "$FENCE88" | grep -qF '["conform"]' && a5_88="$a5_88 [conform is drawn as a node]"
  grep -qi 'conform.*not a node' "$MAP88" || a5_88="$a5_88 [the map never says conform is not a node]"
  [ -z "$a5_88" ] && ok "A5 the root map draws the engine's capabilities and both arrow kinds" \
                  || bad "A5 the root map draws the engine's capabilities and both arrow kinds:$a5_88"
fi
# ONE home and three routes, where this row once demanded the rule in three documents. What it protected
# is unchanged — a phase that resolves the entry to the DIRECTORY silently drops every entry naming
# something else — and the protection is now stronger by shape: three copies of a rule can drift apart
# with every row green, while one home plus a route per resolver cannot. The three documents that
# resolve an entry are still all read, because the loosening reaches every phase that resolves one and a
# list of two missed the phase that writes the code.
CTXH88="global/protocols/context.md"
UP88="global/protocols/understand.md"
USK88="global/skills/understand/SKILL.md"
EXP88="global/protocols/execute.md"
a6_88=""
RULE88="the map's value|whatever path it names"
if ! h88="$(tr '\n' ' ' < "$CTXH88" 2>/dev/null)"; then
  a6_88="$a6_88 [unreadable: $CTXH88]"
else
  # The home states it. Asserted before the count below, so "no document states it" and "several do"
  # can never read alike: a deleted rule would otherwise satisfy an exactly-one count at zero.
  [ "$(printf '%s' "$h88" | grep -ciE "$RULE88" | tr -d ' ')" -ge 1 ] \
    || a6_88="$a6_88 [$CTXH88 does not state the rule it is the home of]"
fi
# And EXACTLY ONE document states it, counted over the resolvers plus the home rather than asserted of
# each: a second copy anywhere in this set is the drift this row exists to prevent.
#
# Counted PER CLAUSE, and a clause that names the home is a ROUTE rather than a copy — because a route
# has to name the fact it hands over or it asserts nothing, so a document-wide count of the rule's own
# words reports every correct route as the second home. Split on the sentence and never inside a
# filename: `. ` ends a sentence, `.md` does not.
# The execute SKILL is in the count and not in the route legs below, and the asymmetry is deliberate. It
# is a resolver — it re-reads the affected entries per step — so a copy of the rule there is the second
# home this row now claims cannot exist, and nothing else would count it. It is left out of the route
# legs because the route it carries is already asserted per-fact elsewhere, and because it names no
# conventional directory: a leg demanding one of a command file would fail for saying nothing wrong.
# The TEMPLATE is in the count and not in the route legs, on the execute skill's terms plus one of its
# own: it declares the map rather than resolving it, and it is the file every adopter edits, so a copy of
# the rule there ships to every project. It is also the shape this count CANNOT see -- the copy it once
# carried sat in the same clause as its route, which the per-clause discount above forgives. So the count
# here is the criterion's own words made checkable, and `C90 A2`'s negative over this file is the leg that
# actually catches it. Both are kept, and which one is load-bearing is stated rather than left to a reader
# to work out from two greens.
ESKH88="global/skills/execute/SKILL.md"
TYMH88="template/.ai-flow/project.yml"
n6_88=0
for d88 in "$CTXH88" "$UP88" "$USK88" "$EXP88" "$ESKH88" "$TYMH88"; do
  if ! b88="$(tr '\n' ' ' < "$d88" 2>/dev/null)"; then
    a6_88="$a6_88 [unreadable: $d88]"; continue
  fi
  c6_88="$(printf '%s' "$b88" | sed 's/\. /.\
/g' | grep -iE "$RULE88" | grep -civE 'context\.md' | tr -d ' ')"
  [ "$c6_88" = 0 ] || n6_88=$((n6_88 + 1))
done
[ "$n6_88" = 1 ] || a6_88="$a6_88 [$n6_88 documents state the map's-value rule, not one]"
for d88 in "$UP88" "$USK88" "$EXP88"; do
  if ! b88="$(tr '\n' ' ' < "$d88" 2>/dev/null)"; then continue; fi
  # Each resolver carries a ROUTE naming both the home and the fact it hands over — never a bare
  # filename, which asserts nothing about what was handed over, and bound in one clause so the two
  # cannot be satisfied by unrelated sentences at opposite ends of a manual.
  #
  # SINGLE-quoted, and that is not a style choice. A literal `{0,N}` interval inside a DOUBLE-quoted
  # pattern in an inline `[ "$(…)" ]` test is brace-expanded into two words, and the test dies with
  # `too many arguments` — so the leg reports its `||` branch and never examines a document at all.
  # Written that way first, this row failed on all three resolvers while the identical grep returned a
  # match by hand. The 28 other interval patterns in this file are single-quoted, which is why they work.
  [ "$(printf '%s' "$b88" | grep -ciE 'context\.md([^.]|\.[a-zA-Z]){0,200}(loaded|read|cuts|owns)|(loaded|read|cuts|owns)([^.]|\.[a-zA-Z]){0,200}context\.md' | tr -d ' ')" -ge 1 ] \
    || a6_88="$a6_88 [$d88 carries no route naming the home and what it hands over]"
  # Negative: nothing still resolves the entry TO THE DIRECTORY. The positive alone is satisfied by a
  # document that gained the route and kept the old sentence, which is the shape a relocation takes when
  # it is written as an addition instead of a replacement.
  [ "$(printf '%s' "$b88" | grep -ciE "steering files from .\.ai-flow/steering|steering file\(s\) for the affected domain\(s\) from|read the corresponding steering files|Load steering files for the affected domains|are the values of the .steering:. map in .\.ai-flow/project\.yml. \(files under" | tr -d ' ')" = "0" ] \
    || a6_88="$a6_88 [$d88 still resolves the entry to the steering directory]"
  # And the directory survives as the CONVENTION rather than being deleted: a relocation that erased it
  # would leave every project that follows the convention with no statement of where its files go.
  [ "$(printf '%s' "$b88" | grep -ciE "\.ai-flow/steering" | tr -d ' ')" -ge 1 ] \
    || a6_88="$a6_88 [$d88 no longer names the conventional place at all]"
done
[ -z "$a6_88" ] && ok "A6 the map's-value rule has one home, and every resolver routes to it" \
                || bad "A6 the map's-value rule has one home, and every resolver routes to it:$a6_88"

# Every concept the card's homes table names is held to a set COMPUTED from the repository, so no row can
# be wrong in silence and no row can exist that nothing computes. The markers themselves live with the
# auditor-count check above, because the auditor marker IS the count shapes derived there.
if ! command -v marker89 >/dev/null 2>&1; then
  for r89 in \
    "A8 every homes row of every registered card has a marker, and every marker a row" \
    "A9 every row's cited files are exactly what its marker selects, for every registered card" \
    "A11 the sweep's corpus excludes the suite, and the guard says so"; do
    bad "$r89 (the marker table was never defined — the auditor-count check did not run)"
  done
else
  # Every registered card's rows, header and separator dropped, each row carried WITH the card it came
  # from: a verdict naming a row without its card is unreadable the moment the register holds more than
  # one. The pair is card TAB row, so the row's own pipes can never be read as the separator.
  # A row's LABEL is its first cell; its CITED PATHS are its backticked spans carrying a file extension —
  # filtered on the extension and never on a slash, because README.md sits at the repository root and a
  # slash-keyed filter would drop it from the card's side while the marker still found it, which is a
  # guard blaming the document for its own reader.
  # The readability of each card is TESTED here rather than discarded: `2>/dev/null` over the extractor
  # turned an unreadable registered card into zero rows, which the collective floor below then read as
  # nothing at all to say about it.
  PAIRS89="$(printf '%s\n' "$CARDS88" | while IFS= read -r c89; do
      [ -n "$c89" ] || continue
      { [ -r "$c89" ] && [ -s "$c89" ]; } || continue
      awk '/^## The homes table$/{f=1;next} /^## /{f=0} f && /^\| /' "$c89" \
        | grep -vE '^\| Concept \||^\|[-| ]*$' \
        | awk -v c="$c89" '{print c "\t" $0}'
    done)"
  LABELS89="$(printf '%s\n' "$PAIRS89" | cut -f2- \
              | sed -E 's/^\|[[:space:]]*([^|]*[^|[:space:]])[[:space:]]*\|.*/\1/' | sort -u)"
  # THE FLOOR IS PER CARD, not over the union. A floor over every card's rows at once is satisfied by ANY
  # card's rows, so at a register of two a card contributing nothing is read by neither row below while
  # both report on "every registered card" — the exact shape both rows were widened to remove, one level
  # up. A header and a separator with no data rows is how that state arrives without the card looking
  # broken anywhere else: A1 sees the section, and A3's identity leg is satisfied by the header's own words.
  # Unreadable is kept distinct from empty, because they are different things to go and fix.
  NOROWS89=""
  while IFS= read -r c89; do
    [ -n "$c89" ] || continue
    if ! { [ -r "$c89" ] && [ -s "$c89" ]; }; then
      NOROWS89="$NOROWS89 [$c89 is unreadable or empty, so its rows were never compared]"
    elif ! printf '%s\n' "$PAIRS89" | cut -f1 | grep -qxF "$c89"; then
      NOROWS89="$NOROWS89 [$c89 yielded no homes row at all]"
    fi
  done <<< "$CARDS88"
  # The keys the marker table actually knows, read out of the case statement itself. A second list here
  # would go green while the table it claims to describe had lost a branch, which is the whole defect.
  KEYS89="$(awk '/^marker89\(\) \{$/{f=1;next} f&&/^  esac$/{exit} f' $SUITE_SRC \
            | grep -oE '^    "[^"]+"\)' | sed -E 's/^ +"(.*)"\)$/\1/' | sort -u)"

  # --- A8: every row has a marker, and every marker a row --------------------
  # Set equality, not containment, and the second direction is not decoration: a marker left behind for a
  # concept every card has dropped is a rule nothing governs, and it reads as coverage.
  a8_89=""
  # The register-level floor stays BESIDE the per-card one and is not replaced by it: it is the only leg
  # that speaks when the register itself is empty, where there is no card for the per-card floor to walk.
  [ -n "$PAIRS89" ]  || a8_89="$a8_89 [no registered card yielded a homes row]"
  a8_89="$a8_89$NOROWS89"
  [ -n "$LABELS89" ] || a8_89="$a8_89 [no row label could be extracted]"
  [ -n "$KEYS89" ]   || a8_89="$a8_89 [the marker table's keys could not be extracted]"
  if [ -n "$KEYS89" ]; then
    # The first direction is walked PER PAIR rather than over the union of labels, because this is the
    # direction whose verdict has to name the CARD as well as the row: a label absent from the keys tells
    # its reader nothing about which registered card carries it.
    while IFS= read -r pair89; do
      [ -n "$pair89" ] || continue
      c89="$(printf '%s\n' "$pair89" | cut -f1)"
      lab89="$(printf '%s\n' "$pair89" | cut -f2- \
               | sed -E 's/^\|[[:space:]]*([^|]*[^|[:space:]])[[:space:]]*\|.*/\1/')"
      printf '%s\n' "$KEYS89" | grep -qxF "$lab89" \
        || a8_89="$a8_89 [$c89: a row nothing computes: $lab89]"
    done <<< "$PAIRS89"
    # The second direction is the marker table's own and has no card to name — it is a key no registered
    # card claims, whichever card that key was written for.
    if [ -n "$LABELS89" ]; then
      NOROW89="$(comm -13 <(printf '%s\n' "$LABELS89") <(printf '%s\n' "$KEYS89") | tr '\n' ';')"
      [ -z "$(printf '%s' "$NOROW89" | tr -d ';')" ] \
        || a8_89="$a8_89 [markers naming no row: $NOROW89]"
    fi
  fi
  [ -z "$a8_89" ] && ok "A8 every homes row of every registered card has a marker, and every marker a row" \
                  || bad "A8 every homes row of every registered card has a marker, and every marker a row:$a8_89"

  # --- A9: each row's cited files are exactly what its marker selects --------
  # Per row, both directions, and the card and the file are NAMED on either side — a verdict that said
  # only "row 6 is wrong" would send its reader back to do the sweep by hand, which is the work this row
  # exists to spend.
  a9_89=""
  # The floor A8 already applies, applied here too: this row's loop body never runs on an empty register,
  # so without it the row implementing "cited exactly" reports green over a card it never read.
  [ -n "$PAIRS89" ] || a9_89="$a9_89 [no registered card yielded a homes row to compare]"
  # The same per-card floor A8 applies, applied here for the same reason: this row's loop walks pairs, so a
  # card that produced none is a card it reports on without having read.
  a9_89="$a9_89$NOROWS89"
  while IFS= read -r pair89; do
    [ -n "$pair89" ] || continue
    c89="$(printf '%s\n' "$pair89" | cut -f1)"
    row89="$(printf '%s\n' "$pair89" | cut -f2-)"
    lab89="$(printf '%s\n' "$row89" | sed -E 's/^\|[[:space:]]*([^|]*[^|[:space:]])[[:space:]]*\|.*/\1/')"
    span89="$(printf '%s\n' "$row89" | grep -oE '`[^`]+`' | tr -d '`' | sort -u)"
    # Two ways to be a citation, unioned: an extension the engine writes in, OR an exact tracked path.
    # The extension half catches a typo (a path that resolves to nothing is still compared and still
    # fails); the corpus half closes the sixteen tracked files no extension in that list can express.
    cite89="$( { printf '%s\n' "$span89" | grep -E '\.(md|js|yml|sh|py)$'
                 printf '%s\n' "$span89" | grep -xF -f <(printf '%s\n' "$CORPUS89") ; } 2>/dev/null | sort -u)"
    if ! swp89="$(marker89 "$lab89")"; then
      a9_89="$a9_89 [$c89 $lab89: no marker, so nothing was compared]"; continue
    fi
    # A floor before the equality. An extractor that returns nothing satisfies every containment test ever
    # written over it, and reads in a report exactly like a row that passed.
    [ -n "$swp89" ]   || a9_89="$a9_89 [$c89 $lab89: the marker selected no file at all]"
    [ -n "$cite89" ]  || a9_89="$a9_89 [$c89 $lab89: the row cites no file at all]"
    [ -n "$swp89" ] && [ -n "$cite89" ] || continue
    MISS89="$(comm -13 <(printf '%s\n' "$cite89") <(printf '%s\n' "$swp89") | tr '\n' ' ')"
    EXTRA89="$(comm -23 <(printf '%s\n' "$cite89") <(printf '%s\n' "$swp89") | tr '\n' ' ')"
    [ -z "$(printf '%s' "$MISS89" | tr -d ' ')" ] \
      || a9_89="$a9_89 [$c89 $lab89 omits: $MISS89]"
    [ -z "$(printf '%s' "$EXTRA89" | tr -d ' ')" ] \
      || a9_89="$a9_89 [$c89 $lab89 cites what its marker does not select: $EXTRA89]"
  done <<< "$PAIRS89"
  [ -z "$a9_89" ] && ok "A9 every row's cited files are exactly what its marker selects, for every registered card" \
                  || bad "A9 every row's cited files are exactly what its marker selects, for every registered card:$a9_89"

  # --- A11: the corpus excludes the suite, and the exclusion is visible ------
  # Three legs, because two of them alone prove the wrong thing. That the suite is absent from the sweeps
  # is worth nothing if the file were simply untracked, so its tracked-ness is asserted first: only then is
  # the absence an EXCLUSION rather than an accident. And the third leg is what makes it visible — the
  # exclusion runs through a named constant, so a reader of the guard meets it instead of inferring it.
  a11_89=""
  TRACKED89="$(cd "$ROOT" && git ls-files 2>/dev/null)"
  while IFS= read -r x89; do
    [ -n "$x89" ] || continue
    printf '%s\n' "$TRACKED89" | grep -qxF "$x89" \
      || a11_89="$a11_89 [$x89 is not tracked, so its absence from the corpus proves nothing]"
    printf '%s\n' "$CORPUS89" | grep -qxF "$x89" \
      && a11_89="$a11_89 [the corpus still holds $x89]"
  done <<< "$SELFEX89"
  # Anchored to the ASSIGNMENT, because the unanchored form matched this very line: a leg whose pattern
  # occurs inside its own text is satisfied by itself and can never fail, whatever the corpus does.
  grep -qE '^CORPUS89=.*grep -vxF -f .*\$SELFEX89' $SUITE_SRC \
    || a11_89="$a11_89 [the corpus does not exclude the suite through a named constant]"
  [ -n "$KEYS89" ] || a11_89="$a11_89 [no marker key was extracted, so no marker was swept]"
  while IFS= read -r k89; do
    [ -n "$k89" ] || continue
    printf '%s\n' "$(marker89 "$k89")" | grep -qxF -f <(printf '%s\n' "$SELFEX89") \
      && a11_89="$a11_89 [$k89 sweeps in the suite itself]"
  done <<< "$KEYS89"
  [ -z "$a11_89" ] && ok "A11 the sweep's corpus excludes the suite, and the guard says so" \
                   || bad "A11 the sweep's corpus excludes the suite, and the guard says so:$a11_89"
fi
# --- A10: the guard and the card's row consume ONE computed set ------------------------------------
# Not a comparison of two lists — that is precisely what this change removed, and a comparison written back
# here would be the second list wearing a different hat. The claim is identity: the set the auditor-count
# guard iterates is the value of the very marker A9 holds the card's row to, so there is no second thing
# left that could be wrong. Floored and anchored, because an identity between two empty sets is not one.
a10_89=""
if ! command -v marker89 >/dev/null 2>&1; then
  a10_89="$a10_89 [the marker table was never defined — the auditor-count check did not run]"
else
  SET89="$(marker89 "Auditor list")"
  n10_89="$(printf '%s\n' "$SET89" | grep -c . | tr -d ' ')"
  [ "$n10_89" -ge 2 ] || a10_89="$a10_89 [the computed set holds $n10_89 documents]"
  # The card is NOT an anchor here: A4_88 above already holds exactly that claim over the same marker
  # call, and asserting it twice is the duplicate-check defect this task spent its A7 avoiding.
  for anc89 in "global/workflows/verify-review.js"; do
    printf '%s\n' "$SET89" | grep -qxF "$anc89" || a10_89="$a10_89 [$anc89 is not in the computed set]"
  done
  # Both halves of the consumption, because either alone is satisfied by a guard that computes the set and
  # then walks a different one: the assignment says where the set comes from, the loop says what is read.
  [ "$(suite_src | grep -c '^  DOCS83="\$(marker89 "Auditor list")"$' | tr -d ' ')" = "1" ] \
    || a10_89="$a10_89 [the auditor guard does not take its documents from the marker, exactly once]"
  [ "$(suite_src | grep -c '^  done <<< "\$DOCS83"$' | tr -d ' ')" = "1" ] \
    || a10_89="$a10_89 [the auditor guard's loop does not iterate that set]"
fi
[ -z "$a10_89" ] && ok "A10 the auditor guard and the card's row consume one computed set" \
                 || bad "A10 the auditor guard and the card's row consume one computed set:$a10_89"
