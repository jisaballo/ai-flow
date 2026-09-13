# The front door is the only page most readers open, and it had never been asserted to know that a
# project can teach the review its own stack. Six legs, and the three shapes the neighbouring checks
# already keep: a verdict is a COUNT inside an EXTRACTED REGION, never a bare file-wide grep — the README
# says "review" and "profile" in places that are not the ones under audit; where a rule has more than one
# claim EVERY claim is asserted separately, because one of them is satisfied by prose that also omits the
# rest; and no pattern here uses a bounded proximity repeat, per the standing entry IB-012.
#
# Three claims are deliberately NOT asserted here, and each already has a home. That the door names the
# current auditor count and the fifth axis is `C58 A4`, over a set this document is already in. That the
# card's homes row cites this document is `C59 A9`, by set equality against the marker that selects it.
# That the door links the lifecycle map at the copy an adopter receives is `C43 A3`. A second assertion of
# any of them is the duplicate-check defect the standing entry IB-015 counts three instances of.
#
# **Nothing here enforces the Rail** — the door states the shape of the review and never the axis lists.
# That is `C58 A5`, whose one-home count now sweeps everything the repository tracks rather than `global/`
# alone, and it fingerprints the STRUCTURE axis only. The other four axes' content is asserted by nothing,
# in this file or any other. The gap is stated because an earlier form of A5 below claimed to close it and
# could not: it counted physical prose lines over a document that does not hard-wrap, so five checklists
# fitted inside one of the lines it was counting, and the two protections its comment invoked — the
# `Axis content` marker, anchored on a JS array declaration, and `C58 A5` rooted under `global/` — were
# both structurally incapable of matching a file at the repository root. A guard that names a protection
# it does not have is worse than one that names none.
echo "== C61: the front door knows profiles exist, and describes the review as it is built =="

RD61="README.md"
CARD61="docs/architecture/verify.md"

n61() { printf '%s\n' "$2" | grep -ciE "$1" | tr -d ' '; }

# Only the README gates this section. Every leg below reads that file and nothing else: the card's path
# appears here as a literal string to search FOR, never as a file to open, so gating on it would silence
# five verdicts about a document that is perfectly readable. That is the anti-pattern this suite names at
# `A7 is gated on nothing the register owns` — the card's own existence is A4's leg instead, where the
# diagnosis says the door links a card that is not there.
if [ ! -r "$RD61" ]; then
  for r61 in \
    "A1 the front door carries the profiles subsection, sited and linked" \
    "A2 the door states whose the checklists are, and what the engine keeps" \
    "A3 the review paragraph names the additive rule, the single writer, and the rule's owner" \
    "A4 the documentation list points at the card that describes the review" \
    "A5 the profiles subsection is inside the anti-bloat budget a front-door section is given" \
    "A6 the subsection states no resolution outcome"; do
    bad "$r61 ($RD61 is unreadable)"
  done
else

  # Both regions are read FENCE-AWARE, and that is not defensive polish: the Steering Files subsection
  # ships an example steering file whose body carries `## Rules`, `## Patterns` and `## Pitfalls` inside a
  # fenced block. A region terminating on the first heading exits there and comes back truncated before
  # this subsection exists — which is how the first form of the siting leg reported the subsection absent
  # while it sat ten lines below where the extractor had stopped. The subsection's own fence lines are
  # KEPT, because A5 counts them; what the fence suppresses is the terminator, not the content.
  ORDER61="$(awk '
    /^```/  { fence = !fence; next }
    fence   { next }
    /^## /  { inc = ($0 == "## Customization"); next }
    inc && /^### / { sub(/^### /, ""); print }
  ' "$RD61")"
  RP61="$(awk '
    /^```/ { fence = !fence; if (f) print; next }
    !f && !fence && /^### Review Profiles$/ { f=1; next }
    f && !fence && /^#{1,3} / { exit }
    f { print }
  ' "$RD61")"
  VWP61="$(awk '/^\*\*verify-review workflow\*\*/{f=1} f{if ($0 ~ /^[[:space:]]*$/) exit; print}' "$RD61")"
  DOCS61="$(awk '
    /^```/ { fence = !fence; next }
    fence  { next }
    /^## / { inc = ($0 == "## Documentation"); next }
    inc    { print }
  ' "$RD61")"
  # The prose and the example, split once and consumed by A5 and A1 alike.
  PROSE61="$(printf '%s\n' "$RP61" | awk '/^```/{f=!f;next} !f')"
  YML61="$(printf '%s\n' "$RP61" | awk '/^```/{f=!f;next} f')"

  # ---- A1: the subsection exists, is sited between its neighbours, names both keys, links the guide ---
  # The siting is asserted in BOTH directions — what precedes it and what follows it — because either
  # alone is satisfied by a subsection appended to the end of the section, which is where prose about
  # configuration goes to be unread. The key names are counted TWICE and over different regions: once in
  # the prose, and once anchored at line start inside the fenced example. One alternation over the whole
  # subsection was the first form, and its `^review:` branch could never be load-bearing — the paragraph
  # above the fence names both keys in backticks, so the alternation was satisfied before the example was
  # read, and the five lines an adopter actually copies were asserted by nothing but their line count.
  a1_61=""
  [ -n "$ORDER61" ] || a1_61="$a1_61 [the Customization section yielded no subsection headings]"
  [ -n "$RP61" ]    || a1_61="$a1_61 [no ### Review Profiles subsection could be extracted]"
  [ -n "$YML61" ]   || a1_61="$a1_61 [the subsection carries no fenced example]"
  P61="$(printf '%s\n' "$ORDER61" | grep -n -xF 'Review Profiles' | head -1 | cut -d: -f1)"
  S61="$(printf '%s\n' "$ORDER61" | grep -n -xF 'Steering Files'  | head -1 | cut -d: -f1)"
  if [ -z "$P61" ] || [ -z "$S61" ]; then
    a1_61="$a1_61 [Review Profiles or Steering Files is not a subsection of Customization]"
  else
    [ "$P61" = "$((S61 + 1))" ] \
      || a1_61="$a1_61 [Review Profiles is subsection $P61, not the one after Steering Files at $S61]"
    NEXT61="$(printf '%s\n' "$ORDER61" | sed -n "$((P61 + 1))p")"
    [ "$NEXT61" = "Project CLAUDE.md" ] \
      || a1_61="$a1_61 [what follows Review Profiles is '$NEXT61', not Project CLAUDE.md]"
  fi
  [ "$(n61 '`review_profile:`' "$PROSE61")" -ge 1 ] \
    || a1_61="$a1_61 [the prose never names review_profile:]"
  [ "$(n61 '`review:`' "$PROSE61")" -ge 1 ] \
    || a1_61="$a1_61 [the prose never names review:]"
  [ "$(printf '%s\n' "$YML61" | grep -c '^review_profile:' | tr -d ' ')" -ge 1 ] \
    || a1_61="$a1_61 [the example declares no top-level review_profile: key]"
  [ "$(printf '%s\n' "$YML61" | grep -c '^review:' | tr -d ' ')" -ge 1 ] \
    || a1_61="$a1_61 [the example declares no top-level review: key]"
  [ "$(n61 'docs/customization\.md' "$PROSE61")" -ge 1 ] \
    || a1_61="$a1_61 [the subsection never links the guide that explains it in full]"
  # The link is asserted to RESOLVE and not merely to be spelled: a literal-string leg passes over a
  # front door pointing at a document that is not there, which is the same hole A4 closes for the card.
  [ -r "docs/customization.md" ] \
    || a1_61="$a1_61 [the subsection links a guide that is not there: docs/customization.md]"
  [ -z "$a1_61" ] && ok "A1 the front door carries the profiles subsection, sited and linked" \
                  || bad "A1 the front door carries the profiles subsection, sited and linked:$a1_61"

  # ---- A2: the door says whose the checklists are, and what the engine keeps ------------------------
  # Two claims, asserted separately, because they are the two halves of one rule and prose carrying
  # either alone is the rule half-stated: a reader told the checklists are theirs and not told the engine
  # ships none still expects a pack to arrive, and a reader told the engine ships none and not told whose
  # they are learns only that something is missing.
  a2_61=""
  [ -n "$PROSE61" ] || a2_61="$a2_61 [no subsection prose to read the rule from]"
  [ "$(n61 "the project's own|belong to the project|are the project's|yours to write" "$PROSE61")" -ge 1 ] \
    || a2_61="$a2_61 [the subsection never says the checklists are the project's own]"
  [ "$(n61 'ships none|keeps none|carries none|no stack-specific|none of its own' "$PROSE61")" -ge 1 ] \
    || a2_61="$a2_61 [the subsection never says the engine ships none of them]"
  [ -z "$a2_61" ] && ok "A2 the door states whose the checklists are, and what the engine keeps" \
                  || bad "A2 the door states whose the checklists are, and what the engine keeps:$a2_61"

  # ---- A3: the paragraph names the additive rule, the single writer, and the rule's owner ----------
  # Five claims on one paragraph, and the count is over the PARAGRAPH rather than the page: the engine's
  # generic floor and the prover are both described elsewhere in this repository, and a file-wide grep
  # would pass on a paragraph that gained neither. No negative leg on "instead of": the guide's own
  # wording of the additive rule is "on top of ..., never instead of it", so a pattern forbidding the
  # phrase would forbid the correct sentence.
  #
  # The last two legs replaced one that asserted the exclusivity in the rule's own words. The door is
  # licensed to state the review's SHAPE — its actors and their order — and not to restate a rule the
  # verify protocol owns, so what is asserted now is the shape (the auditors only read, one serialised
  # prover writes) together with the CITATION of the owner: file and section, which is what makes a
  # citation usable rather than a gesture. A leg keyed on `prover` alone was the first form, and the two
  # words "serialised prover" answered it and the serialisation leg both.
  a3_61=""
  [ -n "$VWP61" ] || a3_61="$a3_61 [the verify-review workflow paragraph could not be extracted]"
  [ "$(n61 "stack-agnostic|generic list|engine's own list|generic floor" "$VWP61")" -ge 1 ] \
    || a3_61="$a3_61 [the paragraph never names the engine's own list per axis]"
  [ "$(n61 'on top of|added to|over the engine' "$VWP61")" -ge 1 ] \
    || a3_61="$a3_61 [the paragraph never says a project's checklist is read on top of it]"
  [ "$(n61 'serialised|serialized' "$VWP61")" -ge 1 ] \
    || a3_61="$a3_61 [the paragraph never says the prover is serialised]"
  [ "$(n61 'only read|read-only|never change a file|do not write' "$VWP61")" -ge 1 ] \
    || a3_61="$a3_61 [the paragraph never says the auditors only read]"
  [ "$(n61 'global/protocols/verify\.md' "$VWP61")" -ge 1 ] \
    || a3_61="$a3_61 [the paragraph states the mutation rule without citing the file that owns it]"
  [ "$(n61 'Mutation and the Working Copy' "$VWP61")" -ge 1 ] \
    || a3_61="$a3_61 [the citation names no section, so a reader cannot find the rule]"
  [ -z "$a3_61" ] && ok "A3 the review paragraph names the additive rule, the single writer, and the rule's owner" \
                  || bad "A3 the review paragraph names the additive rule, the single writer, and the rule's owner:$a3_61"

  # ---- A4: the documentation list points at the card, and the card is there ------------------------
  # Counted inside the list, and the entry must also SAY what it is: a bare path in a list of four is a
  # link a reader has no reason to follow, and the whole point of the line is that verify's shape is
  # findable from the door. **Both** the parenthesised target and the bracketed label are stripped before
  # the description is counted, and the discriminators are words the label cannot supply. Stripping the
  # target alone was the first form and it asserted nothing: the label reads `[Verify architecture card]`
  # and the count is case-insensitive, so the word `verify` in the link's own name answered an assertion
  # about the prose beside it. The mutation that certified that form had replaced the whole row, label
  # included, so it measured a change the leg was not making.
  a4_61=""
  [ -n "$DOCS61" ] || a4_61="$a4_61 [the Documentation section could not be extracted]"
  ROW61="$(printf '%s\n' "$DOCS61" | grep -m1 -F "$CARD61")"
  [ -n "$ROW61" ] || a4_61="$a4_61 [the Documentation list does not link $CARD61]"
  if [ -n "$ROW61" ]; then
    TXT61="$(printf '%s\n' "$ROW61" | sed -e 's/([^)]*)//g' -e 's/\[[^]]*\]//g')"
    [ "$(n61 'built|carries|homes|concepts|pieces' "$TXT61")" -ge 1 ] \
      || a4_61="$a4_61 [the entry links the card without a description saying what it is]"
  fi
  [ -r "$CARD61" ] || a4_61="$a4_61 [the Documentation list links a card that is not there: $CARD61]"
  [ -z "$a4_61" ] && ok "A4 the documentation list points at the card that describes the review" \
                  || bad "A4 the documentation list points at the card that describes the review:$a4_61"

  # ---- A5: the subsection is inside the anti-bloat budget a front-door section is given ------------
  # This is a SIZE guard and nothing more, and the header above says what it is not. Its first form
  # counted physical non-blank prose lines and was offered as the Rail's enforcement; README.md does not
  # hard-wrap — its longest line is 839 characters and this subsection's prose lines run to 373 — so a
  # ceiling of eight lines licensed thousands of characters and five axis checklists fitted inside a line
  # that was already there. Worse, a line count over unwrapped prose is typographic: re-wrapping these
  # same words at the ~108 columns `docs/customization.md` uses would turn the row red with the content
  # unchanged, which this suite forbids in eleven separate comments.
  #
  # So prose is measured in WORDS and the example in LINES, which is the split the card's own budget
  # already makes: `wc -w` for prose, and a line count reserved for a region where each line is one key
  # by construction and the count is therefore structural. The ceilings live in this guard and nowhere
  # else, because no document owns a budget for one README subsection and inventing one to hold two
  # numbers is a new artifact for a derived check's worth of value. Floors come first: a region that
  # extracted as empty satisfies every ceiling ever written over it and reads in a report exactly like a
  # subsection that passed.
  a5_61=""
  PWMAX61=200; PWMIN61=40; YMAX61=6; YMIN61=3
  PW61="$(printf '%s\n' "$PROSE61" | wc -w | tr -d ' ')"
  YLN61="$(printf '%s\n' "$YML61" | grep -c '[^[:space:]]' | tr -d ' ')"
  [ "$PW61" -ge "$PWMIN61" ] 2>/dev/null \
    || a5_61="$a5_61 [the subsection carries $PW61 words of prose, under the floor of $PWMIN61]"
  [ "$YLN61" -ge "$YMIN61" ] 2>/dev/null \
    || a5_61="$a5_61 [the example carries $YLN61 lines, under the floor of $YMIN61]"
  [ "$PW61" -le "$PWMAX61" ] 2>/dev/null \
    || a5_61="$a5_61 [the subsection carries $PW61 words of prose, over the ceiling of $PWMAX61]"
  [ "$YLN61" -le "$YMAX61" ] 2>/dev/null \
    || a5_61="$a5_61 [the example carries $YLN61 lines, over the ceiling of $YMAX61]"
  [ -z "$a5_61" ] && ok "A5 the profiles subsection is inside the anti-bloat budget a front-door section is given" \
                  || bad "A5 the profiles subsection is inside the anti-bloat budget a front-door section is given:$a5_61"

  # ---- A6: the subsection states no resolution outcome --------------------------------------------
  # The five resolution outcomes — a profile resolved, the profile is absent, a checklist path does not
  # read, the area resolved to nothing, the area resolved to the reserved value — are the guide's to
  # state, and the standing entry IB-016 already counts four prose homes for the matrix they sit in. The
  # door NAMES the topic and links it; a door that re-asserted an outcome would be the fifth home, and
  # the one no marker selects. Floored on the region, because an absence leg over an empty extraction is
  # green for the wrong reason.
  a6_61=""
  [ -n "$PROSE61" ] || a6_61="$a6_61 [no subsection prose, so the absence proves nothing]"
  [ "$(n61 'declare nothing|declare neither|resolves to nothing|engine-generic|shallower|never wrong' "$PROSE61")" = "0" ] \
    || a6_61="$a6_61 [the subsection restates a resolution outcome; the guide is its home]"
  [ -z "$a6_61" ] && ok "A6 the subsection states no resolution outcome" \
                  || bad "A6 the subsection states no resolution outcome:$a6_61"

fi
