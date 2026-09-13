# C62 — the rulebook states its rules and not the occasions that produced them, the report form has one
# copy, and the run's resolution outcomes have a single home.
# Generated in the Conform phase from understand.md's Verifiable Criteria. Written red; each leg below
# fails today for the reason it names, not for a missing fixture or an extractor that returns nothing.
#
# Two shapes are deliberate. Every absence leg is **floored on its own region**: an extraction that comes
# back empty makes an absence trivially true, and a renamed heading would then certify the prune over
# nothing. And every prose deletion carries a **positive** leg naming the reason that must survive it —
# an absence alone is satisfied by deleting the whole passage, rule and reason together, which is the
# opposite of what this section asks for.
#
# `A2` owns the template count as a claim. `A3` reads singleness as a *precondition* and owns the
# contents, so the two are not one check twice: they fail together today and for different reasons, and
# the comment says which is which so a later reader does not retire the wrong one.
echo "== C62: the rulebook states rules, not occasions; one report form; one home for the outcomes =="

VP62="global/protocols/verify.md"
SK62="global/skills/verify/SKILL.md"
HN62="$ROOT/test/validate.sh"
CD62="docs/architecture/verify.md"

c62_readable=1
for f62 in "$VP62" "$SK62" "$HN62" "$CD62"; do
  { [ -r "$f62" ] && [ -s "$f62" ]; } || c62_readable=0
done

if [ "$c62_readable" -eq 0 ]; then
  bad "C62's four documents are all readable and non-empty"
else
  # Occurrences, not lines: this file's prose is one paragraph per line in places, so a line count
  # undercounts a phrase that repeats inside one of them.
  # A refused pattern must be LOUD, never a clean zero. `grep` exits 2 when it will not compile the
  # pattern and prints nothing, so `grep | wc -l` answers `0` — and every absence leg below tests for
  # `-eq 0`, so the whole battery certifies green on a pattern that never ran. That is IB-012's symptom
  # by the route the entry does not name, and this helper is where this block would meet it: `REFUSED`
  # is not a number, so an arithmetic test on it fails loudly instead of passing quietly.
  o62() {
    o62out="$(printf '%s' "$2" | grep -oiE "$1" 2>/dev/null)"; o62rc=$?
    [ "$o62rc" -le 1 ] || { printf 'REFUSED'; return 0; }
    printf '%s' "$o62out" | grep -c . | tr -d ' '
  }
  VPT62="$(tr '\n' ' ' < "$VP62")"
  SKT62="$(tr '\n' ' ' < "$SK62")"

  # ---- A1: no rule is justified by recounting the occasion that produced it ------------------------
  # Keyed on the NARRATIVE form — a past occurrence being told — and NOT on the phrases that carried it
  # before the prune. A pattern built from the deleted phrases is a blocklist: it goes green on a
  # reworded anecdote, which is the assertion-keyed-on-a-word defect this repository has paid for
  # repeatedly. The alternation below is therefore the grammar of past tense applied to a rule's own
  # history — `it was two`, `used to be`, `had drifted`, `once`, `the Nth time` — and it is swept over
  # all three surfaces a rule can be stated on, not the protocol alone. Scope is the point: the first
  # form of this leg read one file, so the same commit that deleted four anecdotes from the protocol
  # wrote new ones into the skill and the card and this row stayed green over every one of them.
  a1_62=""
  NARR62='once (reported|said|stated)|it was the (second|third|fourth) time|already had, for long enough|was false the day it was written|and it was two|used to be|drifted by construction|had (already )?drifted|had .* prose (homes|copies)|this concept had'
  [ -n "$VPT62" ] || a1_62="$a1_62 [the protocol could not be read, so the absence proves nothing]"
  [ -n "$SKT62" ] || a1_62="$a1_62 [the skill could not be read, so the absence proves nothing]"
  CDT62="$(tr '\n' ' ' < "$CD62")"
  [ -n "$CDT62" ] || a1_62="$a1_62 [the architecture card could not be read, so the absence proves nothing]"
  for pair62 in "protocol:$VPT62" "skill:$SKT62" "card:$CDT62"; do
    who62="${pair62%%:*}"; txt62="${pair62#*:}"
    n62="$(o62 "$NARR62" "$txt62")"
    [ "$n62" = "0" ] || a1_62="$a1_62 [the $who62 recounts the occasion that produced a rule in $n62 place(s)]"
  done
  # The four reasons the anecdotes introduce. Each must outlive its story.
  [ "$(o62 'two rules and not one' "$VPT62")" -ge 1 ] \
    || a1_62="$a1_62 [the reason that the act and the account are two rules is gone]"
  [ "$(o62 'each leg gets its own mutation' "$VPT62")" -ge 1 ] \
    || a1_62="$a1_62 [the per-leg mutation rule is gone]"
  [ "$(o62 'a description of the review rather than the review' "$VPT62")" -ge 1 ] \
    || a1_62="$a1_62 [the reason a second copy of the axis lists would drift is gone]"
  [ "$(o62 'consequence half' "$VPT62")" -ge 1 ] \
    || a1_62="$a1_62 [the consolidation boundary's own rule is gone]"
  [ -z "$a1_62" ] && ok "A1 the protocol states every rule without recounting the occasion that produced it" \
                  || bad "A1 the protocol states every rule without recounting the occasion that produced it:$a1_62"

  # ---- A2: the report form has exactly one copy ----------------------------------------------------
  # A floor under the equality, for the reason the sibling checks already give: both numbers collapse to
  # 0 if the anchor is renamed or reflowed, and `0` would then read as a successful collapse.
  a2_62=""
  AUD62="$(grep -c '^\*\*Audited\*\*' "$VP62" | tr -d ' ')"
  [ "$AUD62" -ge 1 ] 2>/dev/null || a2_62="$a2_62 [no report template located at all: $AUD62 found]"
  [ "$AUD62" -eq 1 ] 2>/dev/null || a2_62="$a2_62 [$AUD62 report templates, not one]"
  [ -z "$a2_62" ] && ok "A2 the report template has one copy, counted by its own anchor" \
                  || bad "A2 the report template has one copy, counted by its own anchor:$a2_62"

  # ---- A3: the surviving template keeps the clauses that do not move to the dispatcher -------------
  # Scope narrowed at Conform: the profile provenance, the fall-to-generic line and the shadowed
  # declaration are the dispatcher's rows and A6 forbids the template to state them, so asserting them
  # here would contradict A6. What stays is the tree verdict, the out-of-phase note and the diff's own
  # facts. Singleness is read as a precondition here; A2 owns it as a claim.
  a3_62=""
  AUDP62="$(awk '/^\*\*Audited\*\*/{f=1;buf=""} f{buf=buf" "$0} (f && /^[[:space:]]*$/){print buf; f=0} END{if(f) print buf}' "$VP62")"
  AUDN62="$(printf '%s\n' "$AUDP62" | grep -c 'Audited' || true)"
  if [ "$AUDN62" -ne 1 ]; then
    a3_62="$a3_62 [the template is not single yet: $AUDN62 found, so its contents cannot be read as one]"
  else
    [ "$(o62 'left as (it was )?found' "$AUDP62")" -ge 1 ] || a3_62="$a3_62 [no clean tree verdict]"
    # Keyed on the claim, not on `was not`: that phrase is the CONDITIONAL the branch hangs off ("if it
    # was not"), so it survives the branch being replaced by anything at all. Proven by mutation — the
    # earlier form stayed green with "what changed and what was restored" gone. What the branch owes is
    # both halves: what differed, and what was put back.
    [ "$(o62 'what changed' "$AUDP62")" -ge 1 ]            || a3_62="$a3_62 [the dirty branch does not say what changed]"
    [ "$(o62 'restored' "$AUDP62")" -ge 1 ]                || a3_62="$a3_62 [the dirty branch does not say what was restored]"
    [ "$(o62 'out of phase' "$AUDP62")" -ge 1 ]            || a3_62="$a3_62 [no out-of-phase note]"
    [ "$(o62 'ahead of its remote' "$AUDP62")" -ge 1 ]     || a3_62="$a3_62 [no trunk lag]"
    [ "$(o62 'no lag line' "$AUDP62")" -ge 1 ]             || a3_62="$a3_62 [no silence for a current trunk]"
  fi
  [ -z "$a3_62" ] && ok "A3 the surviving template carries every clause that does not move to the dispatcher" \
                  || bad "A3 the surviving template carries every clause that does not move to the dispatcher:$a3_62"

  # ---- A4: no leg compares one template count against another -------------------------------------
  # Both shapes of the comparison, because retiring one leaves the other. The literal shape is a count
  # tested against 2; the derived shape is a template count tested against a clause count. With one
  # template both are tautologies — green whatever the prose says — which is the hollow leg the
  # per-row battery cannot see.
  a4_62=""
  # Its own lines are excluded: the patterns below contain the very shapes they look for, so a sweep that
  # read them would count itself and could never reach zero. That is the leg-matches-its-own-text defect,
  # and excluding the definition is the same exception the homes sweep makes for the suite.
  #
  # What is forbidden is the **literal 2**, never a count-against-a-count: `total >= 1 && carrying ==
  # total` is the correct shape here — it says every template that exists carries the clause, floors out
  # the zero-template certification, and holds a third template to the same rule. A leg that encodes two
  # as the expected number is the one that breaks, and the one that would let a silently re-added second
  # template pass unnoticed.
  #
  # The template-bearing lines are found by DERIVING the variable names from the file rather than listing
  # them. The first form of this leg carried a hand-written set (`AUD*|TPLN*|TC*|TL*`) and ID-3 of this
  # task had already recorded what that costs: the measurement said six sites and there were eight,
  # because a discriminator that is enumerated cannot measure what the list omits. So the names are read
  # off the assignments that count the anchor, and any line mentioning one of them is in scope.
  SELF62='SELF62|TPLVARS62|TPLLIT62|TPLBOTH62'
  # The self-exclusion happens BEFORE the derivation, not only before the sweep, and that ordering is the
  # whole of the floor's meaning. Derived after it, the set was `TPLLIT62|TPLVARS62` — its own two lines,
  # the only ones in the file where the anchor appears UNESCAPED — so the sweep dropped to
  # `(Audited|# Verify: T-XXX)`, a new literal-2 leg naming neither was invisible, and `[ -n ... ]` passed
  # because the leg had found itself. A floor satisfied by the leg's own text is not a floor.
  #
  # And the read is multi-line, because these extractors are: `TC`, `TC27` and `TL27` open with `VAR="$(`
  # and carry the anchor inside an awk program on a later line, so a per-line derivation misses exactly
  # the three sites ID-3 recorded as missed by the hand-written list.
  TPLVARS62="$(suite_src | grep -vE "$SELF62" | awk '
    function nm(s){ sub(/^[[:space:]]*/,"",s); sub(/=.*/,"",s); return s }
    /^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*="\$\(/ { var=nm($0); inblk=1; hit=0 }
    inblk { if ($0 ~ /Audited/ || $0 ~ /# Verify: T-XXX/) hit=1
            if ($0 ~ /\)"[[:space:]]*$/) { if (hit) print var; inblk=0 }
            next }
    /^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*=/ && ($0 ~ /Audited/ || $0 ~ /# Verify: T-XXX/) { print nm($0) }
  ' | sort -u | paste -sd'|' -)"
  [ -n "$TPLVARS62" ] || a4_62="$a4_62 [no variable in the suite is derived from the template anchor, so the sweep has no scope]"
  TPLLIT62="$(suite_src | grep -nE "(Audited|# Verify: T-XXX|$TPLVARS62)" | grep -vE "$SELF62" | grep -cE '(= *"2"|-eq 2|-ge 2|"2/2")' || true)"
  # The second leg reads the assertion's own stated claim, which is where a two-template world is
  # declared: a row describing itself as covering "both" templates is asserting that there are two.
  # Plural `templates` is the discriminator, and the plural is the whole of it: three unrelated rows say
  # "both ... the template" in the singular ("both keys and the template ships them", "both paths ... in
  # every report template") and none of them claims there are two. An earlier form of this leg matched
  # "both" near "template" and counted all three. It also carried an **empty alternation branch**, which
  # `ugrep` refuses outright — the pattern then yields no output at all and the leg compares an empty
  # string, which reads in the report as a count of nothing rather than as a broken pattern.
  TPLBOTH62="$(suite_src | grep -cE '(ok|bad) "[^"]*both[^"]*templates' || true)"
  [ "$TPLLIT62" -eq 0 ]  || a4_62="$a4_62 [$TPLLIT62 leg(s) still test a template count against the literal 2]"
  [ "$TPLBOTH62" -eq 0 ] || a4_62="$a4_62 [$TPLBOTH62 assertion(s) still claim to cover both templates]"
  # What this row asserts, stated narrowly because the verdict below reads wider than the legs reach:
  # no leg encodes TWO as the expected number of templates, and no assertion claims to cover "both" of
  # them. It does NOT assert that every count-against-a-count in the suite is sound — `total >= 1 &&
  # carrying == total` is the correct shape at one template and is deliberately permitted. The narrower
  # claim is the one these two legs can carry; the wider one is declared uncovered rather than implied.
  [ -z "$a4_62" ] && ok "A4 no leg encodes two as the expected number of report templates" \
                  || bad "A4 no leg encodes two as the expected number of report templates:$a4_62"

  # ---- A5: the resolution outcomes are one table ---------------------------------------------------
  # The table is found by its HEADER's three columns, never by a row: a row is prose and would match the
  # bullets it replaces. Widened at Conform to take the three clauses A3 gave up.
  a5_62=""
  S7_62="$(awk '/^7\. \*\*Invoke the verify-review workflow/{f=1;next} f && /^[0-9]+\. \*\*/{exit} f' "$SK62")"
  [ -n "$S7_62" ] || a5_62="$a5_62 [step 7 could not be extracted]"
  DISP62="$(printf '%s\n' "$S7_62" | grep -iE '^[[:space:]]*\|.*outcome.*\|.*(run|say).*\|.*(record|report)' | head -1)"
  [ -n "$DISP62" ] || a5_62="$a5_62 [no outcome table: nothing in step 7 heads three columns of outcome, what the run says, what the report records]"
  # Each moved clause once, and in the table's own region rather than anywhere in the step.
  # Rows for what is a row; the block for what is deliberately a note. The shadowed declaration rides on
  # the reserved-value row as its one exception, so it is prose beneath the table and not a sixth row —
  # reading it out of the `|` lines alone would fail a design decision rather than a defect.
  TBL62="$(printf '%s\n' "$S7_62" | grep -E '^[[:space:]]*\|')"
  TBLBLK62="$(printf '%s\n' "$S7_62" | awk '/What each resolution says/{f=1} f')"
  # PER ROW, and each on the pair of things only that row says. A token counted over the whole table is
  # answered by whichever row happens to mention it: `engine-generic` appears in the fall-to-generic row's
  # own remedy, so a table-wide count of it stayed green with the reserved-value row renamed away. Proven
  # by mutation. The pair is what discriminates — the outcome and the disclosure it owes.
  [ "$(printf '%s\n' "$TBL62" | grep -c 'generic lists only' | tr -d ' ')" -ge 1 ] \
    || a5_62="$a5_62 [no row carries the fall-to-generic line]"
  [ "$(printf '%s\n' "$TBL62" | grep 'engine-generic' | grep -c 'nothing about profiles' | tr -d ' ')" -ge 1 ] \
    || a5_62="$a5_62 [no row pairs the reserved value with the silence it owes]"
  [ "$(printf '%s\n' "$TBL62" | grep -c 'that axis alone\|axis alone' | tr -d ' ')" -ge 1 ] \
    || a5_62="$a5_62 [no row carries the per-axis blast radius]"
  [ "$(o62 'shadow' "$TBLBLK62")" -ge 1 ] \
    || a5_62="$a5_62 [the table's block does not carry the shadowed-declaration exception]"
  # The cardinality is DERIVED, not read. The preamble spells a number and three surfaces used to spell
  # it too; a spelled count nothing computes is the shape that goes quietly false the day a row is added.
  # So the word is turned back into a number and compared against the rows actually present — header and
  # separator excluded — which is the cheapest kind of check this engine has and the one its own homes
  # table is built on.
  NROW62="$(printf '%s\n' "$TBL62" | grep -cE '^[[:space:]]*\|' | tr -d ' ')"
  NROW62=$((NROW62 - 2))
  SAID62="$(printf '%s\n' "$TBLBLK62" | tr 'A-Z' 'a-z' \
              | sed -nE 's/.*[^a-z](one|two|three|four|five|six|seven|eight) outcomes.*/\1/p; s/^(one|two|three|four|five|six|seven|eight) outcomes.*/\1/p' | head -1)"
  case "$SAID62" in
    one) SAIDN62=1 ;; two) SAIDN62=2 ;; three) SAIDN62=3 ;; four) SAIDN62=4 ;;
    five) SAIDN62=5 ;; six) SAIDN62=6 ;; seven) SAIDN62=7 ;; eight) SAIDN62=8 ;; *) SAIDN62="" ;;
  esac
  [ -n "$SAIDN62" ] || a5_62="$a5_62 [the table's preamble spells no count of the outcomes]"
  [ -n "$SAIDN62" ] && [ "$SAIDN62" = "$NROW62" ] \
    || a5_62="$a5_62 [the preamble says $SAIDN62 outcomes and the table has $NROW62 rows]"
  [ -z "$a5_62" ] && ok "A5 the resolution outcomes have one home and it is a table" \
                  || bad "A5 the resolution outcomes have one home and it is a table:$a5_62"

  # ---- A6: the report writer and the template cite the table and restate none of it ---------------
  # Floored on both regions: an absence over an extraction that failed is the false green this whole
  # section is written against.
  a6_62=""
  # The header line is KEPT, not skipped: this step is a single line, and an extractor that skipped it
  # would return the blank line after it — an empty region, on which every absence leg below is trivially
  # true. That is the false green the floors in this section exist to refuse.
  S10_62="$(awk '/^10\. \*\*Write\*\*/{f=1} f && /^11\. \*\*/{exit} f' "$SK62")"
  [ -n "$S10_62" ] || a6_62="$a6_62 [step 10 could not be extracted]"
  [ -n "$AUDP62" ] || a6_62="$a6_62 [the report template could not be extracted]"
  ROW62='generic lists only|engine-generic|resolved to no profile|shadow'
  S10N62="$(o62 "$ROW62" "$S10_62")"
  TPLN62="$(o62 "$ROW62" "$AUDP62")"
  [ "$S10N62" -eq 0 ] || a6_62="$a6_62 [step 10 still states $S10N62 outcome row(s) instead of citing the table]"
  [ "$TPLN62" -eq 0 ] || a6_62="$a6_62 [the template still states $TPLN62 outcome row(s) instead of citing the table]"
  # The POSITIVE half, and it is the one the whole collapse turns on: both regions must point AT the
  # table. Absence alone is satisfied by deleting the pointer — the leg gets greener as the report loses
  # the only thing telling its writer where the outcomes are. The C62 header promises every prose
  # deletion a positive leg naming what must survive it, and this deletion is the one the task was for.
  [ "$(o62 "step 7's table|table at step 7" "$S10_62")" -ge 1 ] \
    || a6_62="$a6_62 [step 10 does not point at the table it defers to]"
  [ "$(o62 "step 7 of the .verify. skill|table at step 7|step 7's table" "$AUDP62")" -ge 1 ] \
    || a6_62="$a6_62 [the template does not point at the table it defers to]"
  # The reach beyond the two known citers. A6 read step 10 and the template only, so the recurrence the
  # single home exists to prevent — the matrix re-enumerated in some third document — was outside every
  # leg. Swept over what the repository TRACKS, excluding the suite (whose own ROW62 carries the tokens)
  # and the table's own file, so any other surface stating two or more of the outcome rows is named.
  while IFS= read -r f62x; do
    [ -n "$f62x" ] || continue
    case "$f62x" in "$HN62"|"$SK62") continue ;; esac
    b62x="$(tr '\n' ' ' < "$f62x" 2>/dev/null)" || continue
    hits62="$(printf '%s' "$b62x" | grep -oiE "$ROW62" | sort -u | grep -c . | tr -d ' ')"
    [ "$hits62" -lt 2 ] \
      || a6_62="$a6_62 [$f62x re-enumerates $hits62 of the table's outcomes instead of citing it]"
  done <<EOF62
$(git ls-files 2>/dev/null | grep -E '\.md$')
EOF62
  [ -z "$a6_62" ] && ok "A6 the report writer and the template cite the outcome table and restate none of it" \
                  || bad "A6 the report writer and the template cite the outcome table and restate none of it:$a6_62"

  # ---- A7: the routing of mild findings is cited, never enumerated --------------------------------
  # The positive and the negative together: the citation must be there AND the outcomes must not be
  # spelled out beside it, because a citation that summarises what it cites is a second copy wearing a
  # pointer's clothes.
  a7_62=""
  MED62="$(awk '/^\*\*MEDIUM and LOW come back unadjudicated/{f=1;print;next} f && /^$/{exit} f' "$VP62" | tr '\n' ' ')"
  [ -n "$MED62" ] || a7_62="$a7_62 [the paragraph deciding mild findings could not be extracted]"
  [ "$(o62 'Discovery Triage' "$MED62")" -ge 1 ] || a7_62="$a7_62 [the routing test is not cited at all]"
  ENUM62="$(o62 'fixed now|discarded as a false positive|staged in that same file' "$MED62")"
  [ "$ENUM62" -eq 0 ] || a7_62="$a7_62 [$ENUM62 routing outcome(s) enumerated beside the citation]"
  [ -z "$a7_62" ] && ok "A7 the protocol cites the routing test and enumerates none of its outcomes" \
                  || bad "A7 the protocol cites the routing test and enumerates none of its outcomes:$a7_62"

  # ---- A8: the merged template names the case that omits its review section -----------------------
  # The one consumer of the review-less form is a full-path task whose review was skipped; quick and auto
  # skip the phase outright. Merging the two forms without saying so silently obliges that task to file
  # findings it never gathered.
  a8_62=""
  TPLREG62="$(awk '/^## verify\.md Template/{f=1;next} f && /^## [^v]/{exit} f' "$VP62" | tr '\n' ' ')"
  [ -n "$TPLREG62" ] || a8_62="$a8_62 [the template section could not be extracted]"
  # Both halves of the claim, and neither is `skipped`: that word occurs in a neighbouring sentence of
  # the very note this leg guards ("a task whose review was skipped still writes this report"), so the
  # earlier form was satisfied by prose one clause away from the sentence it names. Proven by mutation.
  # `Review Findings` discriminates here because the template's own heading of that name sits past this
  # region's bound, so the only source inside it is the note.
  [ "$(o62 'omitted' "$TPLREG62")" -ge 1 ] \
    || a8_62="$a8_62 [nothing says the review section is omitted where no review ran]"
  # The CONDITION, which no leg pinned: strip it and the note reads as an unconditional omission, so the
  # row would certify a template that drops its findings block on every run — the opposite of the rule.
  # Both halves, because the positive alone permits a note that omits always and merely mentions a skip.
  [ "$(o62 'where no review ran|where a review was skipped' "$TPLREG62")" -ge 1 ] \
    || a8_62="$a8_62 [the omission is not conditioned on no review having run]"
  [ "$(o62 'omitted on every run|always omitted|never written' "$TPLREG62")" -eq 0 ] \
    || a8_62="$a8_62 [the note omits the review block unconditionally]"
  [ "$(o62 'Review Findings' "$TPLREG62")" -ge 1 ] \
    || a8_62="$a8_62 [the note does not name the block that is omitted]"
  [ -z "$a8_62" ] && ok "A8 the merged template names the case that omits its review section" \
                  || bad "A8 the merged template names the case that omits its review section:$a8_62"

fi
