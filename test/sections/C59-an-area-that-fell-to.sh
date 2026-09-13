# C59 — an area that fell to the engine's generic lists says so, and an explicit choice is the only silence.
# Generated in the Conform phase from understand.md's Verifiable Criteria (A1-A7; the observables are
# inspection).
#
# The three shapes C57's header names are kept here, for the reasons it gives. A verdict is a COUNT inside
# an extracted REGION, never a bare file-wide grep: step 7, step 10, the report template and the
# discover protocol all say these words in places that are not the ones under audit. Where a rule has a
# positive and a negative half BOTH are asserted, because the positive alone is satisfied by prose that
# also permits what the rule forbids — and this task INVERTS a rule, so the negative half is what proves
# the old one is gone rather than merely joined by a newer sentence. And no pattern below uses a bounded
# proximity repeat (`[^.]{0,N}`), per the standing entry IB-012: `ugrep` refuses it under -i over UTF-8 and
# the counting helper answers an empty string rather than a count, so a row's verdict would depend on which
# `grep` was first on PATH. Every discriminator here is a literal or an alternation of literals.
#
# One further shape, from IB-003, which this task's scan loaded and deferred: no leg below is an alternation
# whose other branch is satisfied by text that was already there. Where two spellings are admitted they are
# spellings of the SAME new claim, never a new claim OR an old neighbour.
echo "== C59: an area that fell to the generic says so, and an explicit choice is the only silence =="

SKV86="global/skills/verify/SKILL.md"
VP86="global/protocols/verify.md"
TPL86="template/.ai-flow/project.yml"
DOC86="docs/customization.md"
DSC86="global/protocols/discover.md"
DSK86="global/skills/discover/SKILL.md"

n86() { printf '%s' "$2" | grep -ciE "$1" | tr -d ' '; }

c59_readable=1
for f86 in "$SKV86" "$VP86" "$TPL86" "$DOC86" "$DSC86" "$DSK86"; do
  { [ -r "$f86" ] && [ -s "$f86" ]; } || c59_readable=0
done

if [ "$c59_readable" -eq 0 ]; then
  bad "C59's six documents are all readable and non-empty"
else
  # Step 7 states the resolution and the line; step 10 states what the report records. Both terminate at
  # the next numbered step, never at a heading: these steps are list items.
  S7_86="$(awk '/^7\. \*\*Invoke/{f=1} f && /^8\. /{exit} f' "$SKV86")"
  S10_86="$(awk '/^10\. \*\*Write/{f=1} f && /^11\. /{exit} f' "$SKV86")"
  B_SKV86="$(tr '\n' ' ' < "$SKV86")"

  # One region per bullet of step 7, keyed on a literal the bullet must contain. A row asserting over the
  # whole of step 7 is answered by a sibling bullet — which is how C57's own ordering leg came to be green
  # for a sentence four bullets away about the mutation prover.
  bullet86() {
    printf '%s\n' "$S7_86" | awk -v k="$1" '
      !f && index($0,k) { f=1; print; next }
      f && /^[[:space:]]*- / { exit }
      f && /^[[:space:]]*\|/ { exit }
      f { print }'
  }

  # The matrix that replaced step 7's bullets is NOT a bullet, and `bullet86` cannot bound it: a row is
  # one line and the line after it is another row, so a region keyed on a literal inside a row runs to
  # the end of the step and every leg pointed at it is answered by any row, any paragraph, or the step's
  # closing sentence. Hence a terminator on `|` above, and three extractors below, each bounded by its
  # own shape. A leg belongs to the region that OWNS its claim — the whole of step 7 owns nothing.
  #   pre86  — the preamble: the two channels and the ordering that governs all rows, up to the header
  #   row86  — the ONE table row carrying a literal, and nothing else
  #   exc86  — the exception paragraph beneath the table
  pre86() {
    printf '%s\n' "$S7_86" | awk '
      !f && /What each resolution says/ { f=1; print; next }
      f && /^[[:space:]]*\|/ { exit }
      f { print }'
  }
  row86() {
    printf '%s\n' "$S7_86" | awk -v k="$1" '/^[[:space:]]*\|/ && index($0,k) { print; exit }'
  }
  exc86() {
    printf '%s\n' "$S7_86" | awk '
      !f && /The last row has one exception/ { f=1; print; next }
      f && /^[[:space:]]*$/ { exit }
      f { print }'
  }

  # ---- A1: the fall to the generic is named, before anything is judged -----------------------------
  # Every leg on the region that owns its claim. The line itself is now a TABLE ROW, so the row is the
  # region — `bullet86` would have run from that row to the end of the step, where any paragraph answers
  # anything. The ordering is the one claim the row does not own: it is stated once in the preamble and
  # governs all five rows, so it is asserted over the preamble and nowhere wider. The bare presence of
  # `generic` in step 7 was already true before this task — it is the fallback's own name — which is why
  # no leg here reads the step as a whole.
  a1_86=""
  FALL86="$(row86 'generic lists only')"
  PRE86="$(pre86)"
  [ -n "$FALL86" ] || a1_86="$a1_86 [the table row that carries the line could not be located]"
  [ -n "$PRE86" ]  || a1_86="$a1_86 [the table's preamble could not be located]"
  [ "$(n86 'generic lists only' "$FALL86")" -ge 1 ] \
    || a1_86="$a1_86 [the line does not say the change was read against the generic lists only]"
  [ "$(n86 'own output' "$PRE86")" -ge 1 ] \
    || a1_86="$a1_86 [the line is not written in the run's own output]"
  # One spelling, over the preamble alone. The alternation that admitted `before the Workflow call` was
  # answered by the path-probe bullet, which orders a `[ -r ]` test and says nothing about when the
  # disclosure is printed — a new claim OR an old neighbour, which the header of this block forbids.
  [ "$(n86 'before any auditor runs' "$PRE86")" -ge 1 ] \
    || a1_86="$a1_86 [the disclosure is not ordered before the auditors]"
  [ "$(n86 'to sharpen it' "$FALL86")" -ge 1 ] \
    || a1_86="$a1_86 [the line names no remedy the operator can act on]"
  # The trigger, which no leg pinned: strip the opening condition and every leg above still counts 1, so
  # the row would certify a notice printed on every run of every project — the one outcome the spec puts
  # under Out of scope. Both halves, because the positive alone permits an unconditional notice that also
  # happens to mention the condition.
  [ "$(n86 'resolved to no profile' "$FALL86")" -ge 1 ] \
    || a1_86="$a1_86 [the line is not conditioned on the area resolving to no profile]"
  [ "$(n86 'on every run|whatever resolved|regardless of what resolved' "$FALL86")" -eq 0 ] \
    || a1_86="$a1_86 [the bullet obliges the line unconditionally]"
  [ "$(n86 'no line about profiles is written at all|writes no line' "$FALL86")" -eq 0 ] \
    || a1_86="$a1_86 [the bullet still says an omission produces no line]"
  [ -z "$a1_86" ] && ok "A1 an area that fell to the generic is named before anything is judged" \
                  || bad "A1 an area that fell to the generic is named before anything is judged:$a1_86"

  # ---- A2: an explicit written choice is the only silence -------------------------------------------
  # The inversion, asserted on both halves and in both places it must hold. The negative is the load-
  # bearing leg: adding the new sentence while leaving the old test in place would satisfy every positive
  # leg here and still leave the engine keying its silence on what a project omitted.
  a2_86=""
  # ONE leg for the exemption, on the row that states it, keyed on the PAIR the row exists to assert —
  # the reserved value and the silence it buys. `engine-generic` counted over the whole of step 7 was
  # written three times here under three different failure labels, and all three were answered by the
  # resolution bullet, which names the value and says nothing about any silence.
  # Keyed on the row's own SUBJECT, never on the bare value: `engine-generic` occurs first in row 4's
  # remedy text ("...or `review_profile: <area>: engine-generic` to accept the generic on purpose"), so a
  # row selected by the bare value is row 4 — the wrong row, silently. D12 of this task recorded the same
  # trap from the other side, where a table-wide count of the value stayed green with row 5 renamed away.
  EXEROW86="$(row86 'resolved to `engine-generic`')"
  [ -n "$EXEROW86" ] || a2_86="$a2_86 [the table has no row for the reserved value]"
  [ "$(n86 'nothing about profiles' "$EXEROW86")" -ge 1 ] \
    || a2_86="$a2_86 [the reserved value's row does not pair it with the silence it owes]"
  [ "$(n86 'the only silence|only legitimate zero' "$EXEROW86")" -ge 1 ] \
    || a2_86="$a2_86 [nothing says an explicit choice is the only silence]"
  [ "$(n86 'the project declared none|declared no profiles' "$B_SKV86")" -eq 0 ] \
    || a2_86="$a2_86 [the skill still keys its silence on what the project omitted]"
  # Step 10 no longer states the outcomes: it cites the table's third column, which is where the
  # exemption now lives. Both halves are asserted — the citation exists, and the table carries the
  # exemption — because the citation alone would be satisfied by a pointer at nothing.
  [ -n "$S10_86" ] || a2_86="$a2_86 [step 10 could not be extracted]"
  [ "$(n86 "table" "$S10_86")" -ge 1 ] \
    || a2_86="$a2_86 [step 10 does not cite the outcome table]"
  [ -z "$a2_86" ] && ok "A2 an explicit choice of the generic is the only silence" \
                  || bad "A2 an explicit choice of the generic is the only silence:$a2_86"

  # ---- A3: the reserved value is resolved before the lookup ----------------------------------------
  # Three legs. Order alone is not the claim — what matters is the consequence the order buys, so the
  # consequence is asserted beside it: read in the other order, the one declaration whose whole purpose is
  # to silence the line is the declaration that produces it.
  a3_86=""
  [ "$(n86 'recognised before the|resolved before the' "$S7_86")" -ge 1 ] \
    || a3_86="$a3_86 [nothing orders the reserved value before the review: lookup]"
  [ "$(n86 'is never looked up|never looked up in' "$S7_86")" -ge 1 ] \
    || a3_86="$a3_86 [nothing says the reserved value is never looked up]"
  [ "$(n86 'never be reported as a declaration that did not resolve|never reported as a declaration' "$S7_86")" -ge 1 ] \
    || a3_86="$a3_86 [nothing exempts the reserved value from the unresolved-declaration report]"
  [ -z "$a3_86" ] && ok "A3 the reserved value is resolved before the lookup and never reported unresolved" \
                  || bad "A3 the reserved value is resolved before the lookup and never reported unresolved:$a3_86"

  # ---- A4: every report template carries the line and its exemption -------------------------------
  # Counts derived from the `**Audited**` anchor, with a floor under the equality: both counts collapse to
  # 0 if the marker is renamed or reflowed, and `0 = 0` would certify the line over zero templates. The
  # floor guards the duplication as well as this row's own claim: the two copies are slated to be
  # collapsed into one, and until they are, a clause added to one and not the other is a red row rather
  # than a silent divergence.
  a4_86=""
  AUD86="$(grep -c '^\*\*Audited\*\*' "$VP86" | tr -d ' ')"
  OLD86="$(awk '/^\*\*Audited\*\*/{f=1} f{buf=buf" "$0} f&&/^$/{if(buf ~ /no line about them/) n++; f=0; buf=""} END{print n+0}' "$VP86")"
  [ "$AUD86" -ge 1 ] 2>/dev/null \
    || a4_86="$a4_86 [the report template could not be located: $AUD86 found]"
  # The two clauses moved to the outcome table, which is now their single home; the template cites it.
  # Each is read off the ROW that states it, not off the step: over the step both were answered by the
  # resolution bullet, which names the reserved value and states neither clause. The two per-template
  # counts these legs replaced (`GEN86`, `EXE86`) are gone rather than left computed and unread — an
  # orphan count is a leg a reader believes exists.
  [ "$(n86 'generic lists only' "$(row86 'generic lists only')")" -ge 1 ] \
    || a4_86="$a4_86 [the outcome table does not carry the fall-to-generic line]"
  [ "$(n86 'nothing about profiles' "$(row86 'resolved to `engine-generic`')")" -ge 1 ] \
    || a4_86="$a4_86 [the outcome table does not carry the explicit-choice exemption]"
  # The template-side negative stays, because a template still promising the old omission silence would
  # contradict the table whatever the table says.
  [ "$OLD86" -eq 0 ] || a4_86="$a4_86 [$OLD86 report templates still keep the omission silence]"
  [ -z "$a4_86" ] && ok "A4 every report template carries the fall-to-generic line and its exemption" \
                  || bad "A4 every report template carries the fall-to-generic line and its exemption:$a4_86"

  # ---- A5: the guide and the template document the reserved value ----------------------------------
  # The reserved VALUE beside the reserved KEY, in both adopter-facing documents, joined to the one fact
  # this task can break: neither document may still promise the old silence.
  #
  # It does NOT also assert that the template ships both keys undeclared. C57 A7 owns that claim and owned
  # it first, and a second copy here would be two checks in charge of one fact — the same duplication the
  # B1 and B3 legs above were retired for. A5's first draft carried it as a guard against passing these
  # legs the wrong way, by DECLARING the reserved value in the shipped template rather than documenting it
  # in a comment; that route is already red through A7, so the join bought nothing the suite did not have.
  a5_86=""
  [ "$(n86 'engine-generic' "$(tr '\n' ' ' < "$DOC86")")" -ge 1 ] \
    || a5_86="$a5_86 [the guide does not document the reserved value]"
  [ "$(n86 'engine-generic' "$(tr '\n' ' ' < "$TPL86")")" -ge 1 ] \
    || a5_86="$a5_86 [the template does not document the reserved value]"
  grep -q 'Declare neither key and nothing changes' "$DOC86" \
    && a5_86="$a5_86 [the guide still promises that declaring neither key changes nothing]"
  [ "$(n86 'nothing about profiles until you declare' "$(tr '\n' ' ' < "$TPL86")")" -eq 0 ] \
    || a5_86="$a5_86 [the template still promises the run says nothing until you declare a profile]"
  # The guide's POSITIVE promise, inside its own section. The legs above are a token count and two
  # absences, and an absence is satisfied by deleting the passage and writing nothing — so the paragraph
  # that is the only human-readable statement of the new rule was guarded by nothing at all.
  DOC5_86="$(awk '/^### Review profiles/{f=1;next} f && /^### /{exit} f' "$DOC86")"
  [ -n "$DOC5_86" ] || a5_86="$a5_86 [the guide's Review profiles section could not be extracted]"
  [ "$(n86 'the only silence' "$DOC5_86")" -ge 1 ] \
    || a5_86="$a5_86 [the guide never states that an explicit written choice is the only silence]"
  [ "$(n86 'to sharpen it' "$DOC5_86")" -ge 1 ] \
    || a5_86="$a5_86 [the guide never states the line names what to declare to sharpen it]"
  [ -z "$a5_86" ] && ok "A5 the guide and the template document the reserved value, and neither promises the old silence" \
                  || bad "A5 the guide and the template document the reserved value, and neither promises the old silence:$a5_86"

  # ---- A6: a decline is offered the explicit choice, and no skeleton is generated ------------------
  # Both halves, and the second is the one at risk: a section told to propose checklist sets is one edit
  # away from generating empty ones, which is the rule that already governs steering in this same section.
  # Scoped to section 5 — the protocol says "suggest" and "propose" in places that are not this obligation.
  a6_86=""
  DSC5_86="$(awk '/^## 5\./{f=1;next} f && /^## /{exit} f' "$DSC86")"
  S4_86="$(awk '/^4\. /{f=1} f && /^5\. /{exit} f' "$DSK86")"
  [ -n "$DSC5_86" ] || a6_86="$a6_86 [the discover protocol's section 5 could not be extracted]"
  [ "$(n86 'engine-generic' "$DSC5_86")" -ge 1 ] \
    || a6_86="$a6_86 [the section never names the explicit choice it must offer]"
  [ "$(n86 'declin' "$DSC5_86")" -ge 1 ] \
    || a6_86="$a6_86 [the section names no decline to offer it on]"
  [ "$(n86 'offer' "$DSC5_86")" -ge 1 ] \
    || a6_86="$a6_86 [the section does not oblige offering anything]"
  # One leg per object, because the section forbids two generations and a single `not generate` count is
  # satisfied by the steering sentence alone — which predates this change, so the row would report the same
  # verdict whether the checklist prohibition exists or not.
  [ "$(n86 'not generate steering' "$DSC5_86")" -ge 1 ] \
    || a6_86="$a6_86 [the section stopped forbidding generated steering skeletons]"
  [ "$(n86 'not generate checklist files' "$DSC5_86")" -ge 1 ] \
    || a6_86="$a6_86 [the section stopped forbidding generated checklist files]"
  # Scoped to the table rows of section 2, never the whole file: `review_profile` is named in section 5 by
  # this task's own prose, so a file-wide count answers with that and reports nothing about the table row
  # it claims to guard.
  TBL86="$(awk '/^## 2\./{f=1;next} f && /^## /{exit} f' "$DSC86" | grep '^|')"
  [ -n "$TBL86" ] || a6_86="$a6_86 [the detected-field table could not be extracted]"
  [ "$(n86 'review_profile' "$TBL86")" -ge 1 ] \
    || a6_86="$a6_86 [the protocol's detected-field table knows nothing of review_profile]"
  [ -n "$S4_86" ] || a6_86="$a6_86 [the discover skill's step 4 could not be extracted]"
  [ "$(n86 'review_profile|checklist' "$S4_86")" -ge 1 ] \
    || a6_86="$a6_86 [the skill's step 4 names checklist sets nowhere beside steering]"
  [ -z "$a6_86" ] && ok "A6 a decline is offered the explicit choice, and no skeleton is ever generated" \
                  || bad "A6 a decline is offered the explicit choice, and no skeleton is ever generated:$a6_86"

  # ---- A7: a set declared under the reserved name is named, not dropped ---------------------------
  # Two claims, two regions. The RESOLUTION — which value wins — stays in the bullet. The DISCLOSURE —
  # that the shadowing is spoken in both channels — is the exception paragraph's, and it is asserted
  # there and only there, keyed on the pair of channels rather than on a token.
  #
  # Read over the whole of step 7 instead, both disclosure legs were hollow: `the run says|is named` was
  # answered by the table's own column header "What the run says here", and the bare `shadow` by the
  # resolution bullet's "is not silently shadowed" — a sentence about which value wins, not about what is
  # disclosed. The comment above them already forbade exactly that shape and the legs were written anyway,
  # which is why the region is now extracted rather than trusted to a bounded phrase.
  a7_86=""
  SHAD86="$(bullet86 'shadow')"
  EXC86="$(exc86)"
  [ -n "$SHAD86" ] || a7_86="$a7_86 [the shadowed-declaration clause could not be located]"
  [ -n "$EXC86" ]  || a7_86="$a7_86 [the table's exception paragraph could not be located]"
  [ "$(n86 'reserved value wins|reserved value still wins|reserved name wins' "$SHAD86")" -ge 1 ] \
    || a7_86="$a7_86 [nothing says the reserved value wins over a declaration of the same name]"
  # The run's side and the report's side, each named, because the claim is that BOTH channels carry it:
  # one leg over the pair would be satisfied by either half, and a rule disclosed to only one channel is
  # the failure this row exists to catch.
  [ "$(n86 'shadowed by the reserved name' "$EXC86")" -ge 1 ] \
    || a7_86="$a7_86 [the run is not obliged to say the declaration was shadowed]"
  [ "$(n86 'step 10 records it' "$EXC86")" -ge 1 ] \
    || a7_86="$a7_86 [the report is not obliged to record the shadowed declaration]"
  # The negative that makes the pair load-bearing: the paragraph must not grant the shadowing the very
  # silence the row denies it. Without this, inverting the rule to "dropped without a word" leaves both
  # positives above unsatisfied but says nothing about a paragraph that asserts the opposite outright.
  [ "$(n86 'dropped without|without a word|neither the run nor step 10' "$EXC86")" -eq 0 ] \
    || a7_86="$a7_86 [the exception paragraph grants the shadowing the silence this row denies it]"
  # The floor stays on the template so a renamed anchor cannot certify over zero of them.
  TPLN86="$(grep -c '^\*\*Audited\*\*' "$VP86" | tr -d ' ')"
  [ "$TPLN86" -ge 1 ] 2>/dev/null \
    || a7_86="$a7_86 [the report template could not be located: $TPLN86 found]"
  [ -z "$a7_86" ] && ok "A7 a checklist set declared under the reserved name is named, not dropped" \
                  || bad "A7 a checklist set declared under the reserved name is named, not dropped:$a7_86"
fi
