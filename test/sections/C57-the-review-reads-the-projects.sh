# C57 — the review reads the project's stack, and an omission is answered by the engine's own list.
# Generated in the Conform phase from understand.md's Verifiable Criteria (T-082); hardened during Verify
# against the review's own findings, each recorded in that task's verify.md.
#
# Three shapes recur below, all three earned rather than chosen. Verdicts are derived from a COUNT inside an
# extracted REGION, never from a bare file-wide grep: the four auditor prompts, the report templates and the
# skill's step 7 all sit in files that say the same words elsewhere. Where a rule has a positive and a
# negative half, BOTH are asserted, because the positive alone is satisfied by prose that also permits what
# the rule forbids. And no pattern here uses a bounded proximity repeat (`[^.]{0,N}`): the first draft of
# this section did, and `ugrep` refuses it under `-i` over UTF-8 with a complexity error, so `n82` returned
# the empty string and A1's verdict depended on which `grep` was first on PATH — an environment failure
# wearing a conformance verdict's costume. C56's own comment records the same refusal for a sibling pattern.
echo "== C57: the review reads the project's stack, and an omission falls to the engine's own list =="

SKV82="global/skills/verify/SKILL.md"
VW82="global/workflows/verify-review.js"
VP82="global/protocols/verify.md"
TPL82="template/.ai-flow/project.yml"
DOC82="docs/customization.md"

n82() { printf '%s' "$2" | grep -ciE "$1" | tr -d ' '; }

c57_readable=1
for f82 in "$SKV82" "$VW82" "$VP82" "$TPL82" "$DOC82"; do
  { [ -r "$f82" ] && [ -s "$f82" ]; } || c57_readable=0
done

if [ "$c57_readable" -eq 0 ]; then
  bad "C57's five documents are all readable and non-empty"
else
  DIM82="$(awk '/^const DIMENSIONS = \[/{f=1;next} /^\]$/{f=0} f' "$VW82")"
  # One region per axis: from that axis's `key:` to the next one. A row asserting over the whole array
  # would be answered by a sibling prompt, which is how `steeringPath` came to be believed present on an
  # auditor that never received it.
  dim_region() { printf '%s' "$DIM82" | awk -v k="key: '$1'" 'index($0,k){f=1;next} f && /key: '"'"'/{exit} f'; }
  SEC82="$(dim_region security)"
  ARC82="$(dim_region architecture)"
  CON82="$(dim_region contract)"
  COV82="$(dim_region coverage)"
  STRUCT82="$(dim_region structure)"
  # The skill's step 7 states the resolution; step 10 states the report's provenance. Both terminate at the
  # next numbered step, never at a heading: these steps are list items.
  S7_82="$(awk '/^7\. \*\*Invoke/{f=1} f && /^8\. /{exit} f' "$SKV82")"
  S10_82="$(awk '/^10\. \*\*Write/{f=1} f && /^11\. /{exit} f' "$SKV82")"

  # ---- A1: EACH axis's checklist content has exactly one home ---------------------------------------
  # Per axis, not per conjunction. The first draft counted a file as a home only when it restated TWO
  # different axes, so the cheapest next drift — one axis restated in one document — kept the count at 1
  # and the row green while that axis had two homes. Criterion A-1 is per axis and is now read that way.
  # Each discriminator is an alternation of literal item phrases from that axis's own list: literals
  # because a bounded proximity repeat is not portable across greps (see the header), an alternation of
  # two so a single legitimate rewording does not break the row while any restatement elsewhere trips it.
  a1_82=""
  for axis82 in \
    "contract:contract requirements missing|business-level scope creep" \
    "coverage:no test exercises|regression risk: an existing test" \
    "security:inputs without validation|sensitive data exposed where it is" \
    "architecture:forbidden module/layer boundaries|another module's internals"; do
    k82="${axis82%%:*}"; pat82="${axis82#*:}"
    h82=0
    # A quoted read, and the file list taken one line at a time rather than word-split: `for f in $(...)`
    # tears any path containing a space into fragments, the read of a nonexistent path then fails with its
    # status swallowed by the substitution, and every count comes back empty. The project's own bash
    # checklist names that as the ordinary case, not an exotic one.
    while IFS= read -r f82; do
      [ -n "$f82" ] || continue
      if ! b82="$(tr '\n' ' ' < "$f82" 2>/dev/null)"; then
        a1_82="$a1_82 [unreadable: $f82]"; continue
      fi
      [ "$(n82 "$pat82" "$b82")" -ge 1 ] && h82=$((h82+1))
    done <<EOF82
$(grep -rIl . "$ROOT/global/" 2>/dev/null | sort -u)
EOF82
    [ "$h82" = "1" ] || a1_82="$a1_82 [$k82's list is enumerated in $h82 engine files, not one]"
  done
  # And the protocol cites the home rather than restating it. Asserted WITH the absence above, because
  # deleting the lists and citing nothing leaves a reader no way to find them.
  WID82="$(awk '/^### What it does/{f=1} f && /^#{2,3} [^W]/{exit} f' "$VP82")"
  [ -n "$WID82" ] || a1_82="$a1_82 [the protocol's 'What it does' section could not be extracted]"
  [ "$(n82 'verify-review|the workflow' "$WID82")" -ge 1 ] \
    || a1_82="$a1_82 [the protocol does not cite the workflow as the home of the lists]"
  # The protocol must not restate the RESOLUTION rule either — the copy it deleted for drifting was the
  # axis lists, and a fresh copy of the neighbouring rule shipped in the same section a commit later.
  [ "$(n82 'skill.{0,3} step 7|/verify. skill' "$WID82")" -ge 1 ] \
    || a1_82="$a1_82 [the protocol does not cite the skill as the home of the resolution rule]"
  [ "$(n82 'review_profile\[|else .review_profile|falls the whole area' "$WID82")" -eq 0 ] \
    || a1_82="$a1_82 [the protocol restates the resolution rule instead of citing it]"
  [ -z "$a1_82" ] && ok "A1 each axis's checklist content has exactly one home, and the protocol cites it" \
                  || bad "A1 each axis's checklist content has exactly one home, and the protocol cites it:$a1_82"

  # ---- A2: the generic lists assume no stack -------------------------------------------------------
  # A token blacklist, and it under-detects by construction (plan.md D10): it cannot see a stack-specific
  # phrase it does not list. Scoped to the array so the prompt's machinery cannot answer for the prose.
  a2_82=""
  for t82 in 'async' 'unsubscribe' 'subscription' 'promise' 'npm' 'null/undefined'; do
    [ "$(n82 "$t82" "$DIM82")" -eq 0 ] || a2_82="$a2_82 [$t82]"
  done
  [ -z "$a2_82" ] && ok "A2 the five generic lists name no stack, language or runtime" \
                  || bad "A2 the five generic lists name no stack, language or runtime (found:$a2_82)"

  # ---- A3: each prompt reads its own checklist, only when given one, and ADDITIVELY ------------------
  # The third leg is the feature's floor and nothing asserted it: the prover changed "apply it IN ADDITION
  # to the list above" to "apply it INSTEAD of the list above — it replaces that list" and the suite stayed
  # 768/0. A project that could replace the engine's list could make its own review shallower than the
  # floor, which is the one thing the contract says a profile can never do.
  a3_82=""
  for pair82 in "contract:$CON82" "coverage:$COV82" "security:$SEC82" "architecture:$ARC82" "structure:$STRUCT82"; do
    k82="${pair82%%:*}"; r82="${pair82#*:}"
    [ -n "$r82" ] || { a3_82="$a3_82 [$k82 region absent]"; continue; }
    [ "$(n82 "${k82}Checklist" "$r82")" -ge 1 ] || a3_82="$a3_82 [$k82 receives no checklist]"
    [ "$(n82 'IN ADDITION' "$r82")" -ge 1 ] || a3_82="$a3_82 [$k82's clause does not say the checklist is additive]"
    [ "$(n82 'never narrows it|only add questions' "$r82")" -ge 1 ] \
      || a3_82="$a3_82 [$k82's clause does not forbid narrowing the engine list]"
    [ "$(n82 'INSTEAD of the list|replaces that list' "$r82")" -eq 0 ] \
      || a3_82="$a3_82 [$k82's clause lets a checklist replace the engine list]"
    [ "$(n82 'cannot be read' "$r82")" -ge 1 ] \
      || a3_82="$a3_82 [$k82's clause tells the auditor nothing about a checklist it cannot read]"
  done
  # The floor is the population, never a constant beside it: at 4-of-4 dropping any axis's ternary turned
  # the row red, and a floor left behind while the array grew is a count that has quietly become slack.
  [ "$(n82 'Checklist \?' "$DIM82")" -ge "$(printf '%s\n' "$DIM82" | grep -cE "^[[:space:]]+key: '")" ] \
    || a3_82="$a3_82 [a checklist clause is not conditional on one having been given]"
  [ -z "$a3_82" ] && ok "A3 each prompt reads its own checklist, only when given one, and only additively" \
                  || bad "A3 each prompt reads its own checklist, only when given one, and only additively:$a3_82"

  # ---- A4: steering reaches security as well as architecture ---------------------------------------
  # Both halves; the architecture half was already true, so a row asserting only the new half stays green
  # after a refactor drops the old one.
  a4_82=""
  [ "$(n82 'steeringPath' "$SEC82")" -ge 1 ]  || a4_82="$a4_82 [security]"
  [ "$(n82 'steeringPath' "$ARC82")" -ge 1 ]  || a4_82="$a4_82 [architecture]"
  [ -z "$a4_82" ] && ok "A4 the steering file reaches both the security and the architecture auditor" \
                  || bad "A4 the steering file reaches both the security and the architecture auditor (missing:$a4_82)"

  # ---- A5: an omission falls to the generic, never to an inferred default --------------------------
  # The pairing is the criterion: the fallback alone is satisfied by prose that ALSO permits inferring a
  # project default, the one outcome ruled out — an omission must produce a shallower review, never a wrong one.
  a5_82=""
  [ -n "$S7_82" ] || a5_82="$a5_82 [step 7 could not be extracted]"
  [ "$(n82 'review_profile' "$S7_82")" -ge 1 ] || a5_82="$a5_82 [step 7 resolves no profile]"
  [ "$(n82 'generic' "$S7_82")" -ge 1 ] || a5_82="$a5_82 [no fallback to the generic]"
  [ "$(n82 'no project default is ever inferred|never inferred|default the operator did not write' "$S7_82")" -ge 1 ] \
    || a5_82="$a5_82 [nothing forbids inferring a default the operator did not write]"
  [ -z "$a5_82" ] && ok "A5 an omission falls to the generic and never to an inferred project default" \
                  || bad "A5 an omission falls to the generic and never to an inferred project default:$a5_82"

  # ---- A6: an unresolved declaration is named and never refused ------------------------------------
  # Three legs, because any two of them describe a different behaviour: a run that names and stops, or one
  # that continues in silence, both satisfy a two-legged row.
  a6_82=""
  [ -n "$S7_82" ] || a6_82="$a6_82 [step 7 could not be extracted]"
  [ "$(n82 'does not resolve|cannot be read|unresolved|did not resolve' "$S7_82")" -ge 1 ] \
    || a6_82="$a6_82 [the unresolved case is not described]"
  # Joined to WHAT is named. The bare verb form of this leg was green before a line of this task was
  # written — satisfied by `reports the proposal unproven`, four sentences away and about the mutation
  # prover. A leg green for an unrelated reason asserts nothing; IB-003 records the same defect in this file.
  # The naming now lives in the outcome table's own cells, which say `names the declaration` and `names
  # the path`; the phrase list is widened to reach them rather than the prose being bent to the pattern.
  # The list is still an enumeration and that is still its weakness — the claim is "the run names what did
  # not resolve", and only a phrase list is available to express it over prose.
  [ "$(n82 'name it|naming it|named in that same output|name the profile|names the declaration|names the path' "$S7_82")" -ge 1 ] \
    || a6_82="$a6_82 [nothing says the run names the profile or checklist that did not resolve]"
  [ "$(n82 'the run continues|never refuses over it|and continue' "$S7_82")" -ge 1 ] \
    || a6_82="$a6_82 [nothing says the run continues]"
  [ -z "$a6_82" ] && ok "A6 a declaration that does not resolve is named, and the run continues" \
                  || bad "A6 a declaration that does not resolve is named, and the run continues:$a6_82"

  # ---- A7: both keys are documented where an adopter reads -----------------------------------------
  # The guide is the home of the rules; the template cites it and ships both keys COMMENTED OUT, so that a
  # project which has not opted in genuinely declares neither — the first draft shipped `review: {}` and
  # `review_profile: {}`, which made B-3's silence rule unreachable for every new adopter.
  a7_82=""
  grep -q 'review_profile' "$DOC82" || a7_82="$a7_82 [the guide lacks review_profile]"
  grep -qE '^\s*review:' "$DOC82"   || a7_82="$a7_82 [the guide lacks review:]"
  grep -q 'review_profile' "$TPL82" || a7_82="$a7_82 [the template never mentions review_profile]"
  grep -qE '^\s*review:'        "$TPL82" && a7_82="$a7_82 [the template declares review: rather than commenting it out]"
  grep -qE '^\s*review_profile:' "$TPL82" && a7_82="$a7_82 [the template declares review_profile: rather than commenting it out]"
  # `default:` reserved, joined to what must be reserved. The first draft accepted the bare word `reserved`
  # anywhere in the template — an alternation whose loose branch decides the verdict, which the project's
  # own harness checklist lists as its second failure mode.
  b82="$(tr '\n' ' ' < "$TPL82")"
  [ "$(n82 'default:. is RESERVED|.default:. is a RESERVED|RESERVED here' "$b82")" -ge 1 ] \
    || a7_82="$a7_82 [the template does not say default: itself is reserved]"
  [ -z "$a7_82" ] && ok "A7 the guide documents both keys and the template ships them undeclared" \
                  || bad "A7 the guide documents both keys and the template ships them undeclared:$a7_82"

  # ---- A8: the resolution the skill states is one the skill actually performs -----------------------
  # Two proven holes. The prover deleted `securityChecklist` from the skill's `args` list and the suite
  # stayed 768/0 — nothing asserted the arguments are passed at all. And step 7 promised "a checklist path
  # that does not read falls that axis alone" while naming no probe that would produce it, so the report
  # could record a checklist no auditor ever read. Every other step that depends on a filesystem fact names
  # its probe; this one now does too.
  a8_82=""
  for arg82 in contractChecklist coverageChecklist securityChecklist architectureChecklist structureChecklist; do
    [ "$(n82 "$arg82" "$S7_82")" -ge 1 ] || a8_82="$a8_82 [$arg82 is never passed]"
  done
  [ "$(n82 '\[ -r |readab|Test each path' "$S7_82")" -ge 1 ] \
    || a8_82="$a8_82 [step 7 names no probe that tests a checklist path]"
  [ "$(n82 'before the Workflow call|before any auditor runs' "$S7_82")" -ge 1 ] \
    || a8_82="$a8_82 [the probe is not ordered before the review]"
  [ -z "$a8_82" ] && ok "A8 all five checklists are passed, and a path is tested before it is passed" \
                  || bad "A8 all five checklists are passed, and a path is tested before it is passed:$a8_82"

  # ---- B1: provenance is spoken on BOTH paths, and written in every report template -----------------
  # The resolved case is the one the feature was built for, and the first draft obliged an announcement
  # only for the profile that FAILED to resolve: an operator who declared a profile correctly got the same
  # silence as before and learned what judged their change by opening the report afterwards. The prover
  # demonstrated it — tightening this leg to two occurrences of `own output` took the suite to 767/1.
  b1_82=""
  [ "$(n82 'profile' "$S7_82")" -ge 1 ] || b1_82="$b1_82 [step 7 never names the profile]"
  [ "$(printf '%s' "$S7_82" | grep -ciE 'own output' | tr -d ' ')" -ge 2 ] \
    || b1_82="$b1_82 [only one of the two cases — resolved and unresolved — is spoken in the run's own output]"
  [ "$(n82 'which profile resolved|profile resolved and which checklist' "$S7_82")" -ge 1 ] \
    || b1_82="$b1_82 [the resolved profile is not what step 7 obliges the run to speak]"
  # Re-keyed on the claim rather than on its first wording: the sentence used to open "Both cases",
  # whose antecedent was two bullets that no longer exist, and the two spellings admitted below are
  # spellings of the SAME claim — every outcome is announced, not only the ones reporting a failure.
  [ "$(n82 'not only the rows that report a failure|not only the failure' "$S7_82")" -ge 1 ] \
    || b1_82="$b1_82 [nothing forbids announcing the failure case alone]"
  [ -n "$S10_82" ] || b1_82="$b1_82 [step 10 could not be extracted]"
  [ "$(n82 'profile' "$S10_82")" -ge 1 ] || b1_82="$b1_82 [step 10 does not record the profile]"
  # A floor before the equality. Both counts derive from the same `**Audited**` anchor, so a renamed or
  # reflowed marker collapses them to 0 and `0 = 0` certifies the provenance over zero templates — the
  # "negative that opts out on empty input" the project's harness checklist names last.
  AUD82="$(grep -c '^\*\*Audited\*\*' "$VP82" | tr -d ' ')"
  PRO82="$(awk '/^\*\*Audited\*\*/{f=1} f{buf=buf" "$0} f&&/^$/{if(buf ~ /profile/) n++; f=0; buf=""} END{print n+0}' "$VP82")"
  [ "$AUD82" -ge 1 ] 2>/dev/null \
    || b1_82="$b1_82 [the report template could not be located: $AUD82 found]"
  [ "$AUD82" = "$PRO82" ] || b1_82="$b1_82 [$PRO82 of $AUD82 report templates carry the profile provenance]"
  # The silence half of this row is gone, and deliberately: the clause it counted — every template keeping
  # the no-profiles silence — was reversed, and the claim that replaced it belongs to C59, which asserts it
  # with a floor, an equality over the new clause, and a negative proving the old one is absent. Restating
  # it here would put two checks in charge of one fact, which is how they come to disagree.
  [ -z "$b1_82" ] && ok "B1 the profile is spoken on both paths before the verdict and recorded in every report template" \
                  || bad "B1 the profile is spoken on both paths before the verdict and recorded in every report template:$b1_82"

  # ---- B2: a missing checklist costs one axis, not the run -----------------------------------------
  # The blast radius is the criterion. Prose that falls the WHOLE profile to the generic when one file is
  # missing satisfies A6 completely and is still wrong: three axes had checklists that resolved, and
  # discarding them turns one typo into a review three axes shallower than declared. The second leg is the
  # mechanism — the promise had none, and a promise nothing performs is not a behaviour.
  b2_82=""
  [ "$(n82 'that axis alone|the affected axis|for that axis' "$S7_82")" -ge 1 ] \
    || b2_82="$b2_82 [a missing checklist is not scoped to its own axis]"
  [ "$(n82 'dropped from the args|is dropped' "$S7_82")" -ge 1 ] \
    || b2_82="$b2_82 [nothing says what happens to an unreadable path before the call]"
  [ -z "$b2_82" ] && ok "B2 a checklist that does not resolve costs its own axis and not the run" \
                  || bad "B2 a checklist that does not resolve costs its own axis and not the run:$b2_82"

  # ---- B3: the rule is keyed on what RESOLVED, never on which keys are present ----------------------
  # What this row asserted first — that a project which declared nothing gets no line at all — was
  # reversed: an omission now produces a line and the only silence is an explicit choice, a claim C59 owns
  # whole. What survived the reversal is the half below, which nothing else asserts and which the new rule
  # needs just as much as the old one did: the shipped template hands every adopter both keys, commented
  # out, so a rule keyed on key presence would stay silent on precisely the majority case the new rule was
  # written to reach.
  b3_82=""
  [ "$(n82 'on what \*\*resolved\*\*|never on whether the keys|test is on what' "$S7_82")" -ge 1 ] \
    || b3_82="$b3_82 [the rule is keyed on key presence rather than on what resolved]"
  [ -z "$b3_82" ] && ok "B3 the rule is keyed on what resolved, never on which keys are present" \
                  || bad "B3 the rule is keyed on what resolved, never on which keys are present:$b3_82"
fi
