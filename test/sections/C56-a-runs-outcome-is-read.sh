echo "== C56: a run's outcome is read against the kind of change that produced it =="
VW56="$ROOT/global/workflows/verify-review.js"
VP56="$ROOT/global/protocols/verify.md"
VS56="$ROOT/global/skills/verify/SKILL.md"

# Brace-depth extraction rather than an indentation range: a reformat must not silently empty the region
# a row asserts over, because an empty region satisfies every negative leg written against it.
blk56() { awk -v k="$1" '$0 ~ k {f=1} f{ print; n+=gsub(/\{/,"{"); n-=gsub(/\}/,"}"); if (n==0) exit }' "$2"; }
n56() { printf '%s' "$2" | grep -ciE "$1" | tr -d ' '; }
# Occurrences, not lines. Every region above is flattened to a single line, so `grep -c` over one of them
# answers 0 or 1 and can never carry a count — a leg written as "exactly once" against it asserts nothing
# more than presence, which is the hollow shape this very section exists to stop being reported as proof.
o56() { printf '%s' "$2" | grep -oiE "$1" | wc -l | tr -d ' '; }

CTX56="$(awk '/^const ctx = \[/{f=1;next} /^\]\.join/{f=0} f' "$VW56" | tr '\n' ' ')"
PM56="$(blk56 'proposedMutation:' "$VW56" | tr '\n' ' ')"
PS56="$(blk56 '    proofs: \{' "$VW56" | tr '\n' ' ')"
PP56="$(awk '/^  const provePrompt = \[/{f=1;next} /^  \]\.join/{f=0} f' "$VW56" | tr '\n' ' ')"
# The join is what the run does with the prover's answer, so its region starts at the call that gets one.
JOIN56="$(awk '/proofs = await agent\(/{f=1} f' "$VW56" | tr '\n' ' ')"
# The consolidation's proof bullet: a run of LINES, bounded by the next bullet — the shape Fact 9 above
# already uses, and for its reason: the section-wide text would answer for a sentence it does not carry.
CONS56="$(awk '/^### Consolidation into verify.md/{c=1;next} (c && /^#+ /){exit} c' "$VP56" \
  | awk '/^- \*\*A proof came back/{f=1;print;next} f && /^- /{exit} f' | tr '\n' ' ')"
SP56="$(awk '/\*\*`proofs`\*\*/{f=1;print;next} f && /^   - /{exit} f' "$VS56" | tr '\n' ' ')"

if [ ! -f "$VW56" ] || [ ! -f "$VP56" ] || [ ! -f "$VS56" ]; then
  bad "A1 a proposal declares which kind of change it is (verify surface not found)"
else
  # A1 — the kind is DECLARED, which means required by the schema and asked for in the instruction. A
  # property the schema merely permits is one an agent omits, and an omitted kind is the unknown path.
  c1_56=""
  [ -n "$PM56" ] || c1_56="$c1_56 [the proposal block could not be extracted]"
  [ "$(n56 "required:[^]]*'kind'" "$PM56")" -ge 1 ] || c1_56="$c1_56 [kind is not required of a proposal]"
  [ "$(n56 "kind:[^}]*enum:[^]]*'weaken'" "$PM56")" -ge 1 ] || c1_56="$c1_56 [the weakening kind is not an admitted value]"
  [ "$(n56 "kind:[^}]*enum:[^]]*'add-check'" "$PM56")" -ge 1 ] || c1_56="$c1_56 [the new-check kind is not an admitted value]"
  [ "$(n56 "(say|state|declare|name) which" "$CTX56")" -ge 1 ] || c1_56="$c1_56 [the reviewers are not told to declare which kind they propose]"
  [ -z "$c1_56" ] && ok "A1 a proposal declares which kind of change it is" \
                  || bad "A1 a proposal declares which kind of change it is:$c1_56"

  # A2 — the kind reaches the reading DERIVED. The negative leg is the load-bearing one: asking the
  # prover to report the kind would put the judgment back in the actor this whole change removes it from,
  # and a positive-only row stays green over exactly that mutation.
  c2_56=""
  [ -n "$PS56" ] && [ -n "$JOIN56" ] || c2_56="$c2_56 [the outcome schema or the join could not be extracted]"
  [ "$(n56 "required:[^]]*'index'" "$PS56")" -ge 1 ] || c2_56="$c2_56 [an outcome carries no join key back to its proposal]"
  # Keyed on the DECLARATION, not on the word: prose about the kind is what the block should carry, and a
  # bare-word leg would fail on a comment explaining why the prover is not asked for it.
  [ "$(n56 "kind: |'weaken'|'add-check'" "$PS56")" -eq 0 ] || c2_56="$c2_56 [the prover is asked to report the kind it must not decide]"
  [ "$(n56 "proposals\[" "$JOIN56")" -ge 1 ] || c2_56="$c2_56 [the run never reads the proposal an outcome belongs to]"
  # The kind attached must be the PROPOSAL's — read from it, then attached. Two legs, because the read
  # survives deleting the attach: `kind: *[a-z]` matches an unquoted value and never the `'unknown'`
  # literal that answered the first draft of this leg.
  [ "$(n56 'proposedMutation\.kind' "$JOIN56")" -ge 1 ] || c2_56="$c2_56 [the run never reads the proposal's shape]"
  [ "$(n56 'kind: *[a-z]' "$JOIN56")" -ge 1 ] || c2_56="$c2_56 [the run attaches no kind to an outcome]"
  [ -z "$c2_56" ] && ok "A2 each outcome carries the kind of its proposal, derived and not re-decided" \
                  || bad "A2 each outcome carries the kind of its proposal, derived and not re-decided:$c2_56"

  # A3 — every way the join can fail lands on one value. Three ways, and a row naming only the missing
  # index passes over the two that a confident agent actually produces: a number out of range, and two
  # answers claiming one proposal.
  c3_56=""
  [ "$(n56 "'unknown'" "$JOIN56")" -ge 1 ] || c3_56="$c3_56 [an unmatched outcome is not marked unknown]"
  # One leg per conjunct, because an OR over them reports a pass on either half alone: keyed as a single
  # alternation, `Number.isInteger` answered it and the range comparison could be deleted with the row
  # green. Two repairs have now moved this leg's hollowness rather than removing it, which is why it is
  # split rather than reworded a third time.
  [ "$(n56 'Number\.isInteger\([^)]*index' "$JOIN56")" -ge 1 ] || c3_56="$c3_56 [an index that is not an integer is not caught]"
  [ "$(n56 'index *< *1|index *>= *1' "$JOIN56")" -ge 1 ] && [ "$(n56 'index *> *[a-z]+\.length|index *<= *[a-z]+\.length' "$JOIN56")" -ge 1 ] \
    || c3_56="$c3_56 [an index outside the proposals is not caught]"
  # The branch the row's own title claims ("exactly one") and that no leg touched: deleting the whole
  # duplicate guard left all three original legs matching, proved by mutation — the suite stayed at
  # 758/0 with the fact untrue. Keyed on the call form, never on the word `claimed`, which the region's
  # own comment already carries.
  [ "$(n56 'claims\.set\(' "$JOIN56")" -ge 1 ] || c3_56="$c3_56 [answers claiming one proposal are never counted]"
  [ "$(n56 'claims\.get\([^)]*\) *> *1|> *1[^;]{0,20}claims\.get' "$JOIN56")" -ge 1 ] \
    || c3_56="$c3_56 [a proposal claimed more than once still gets a reading]"
  # Keyed on the COMPARISON, not on the word: the region's own comment names the title, so a bare-word
  # leg stayed green with the whole cross-check deleted.
  [ "$(n56 'title *!== *[a-z]+\.title|title *=== *[a-z]+\.title' "$JOIN56")" -ge 1 ] || c3_56="$c3_56 [the join is never cross-checked against the title]"
  # The reason travels with the value, on EVERY branch. A6 obliges the report to name the attribution and
  # the report cannot satisfy it from a bare `unknown`; counted, so dropping it from one branch of four
  # fails here rather than surfacing when a report has to explain why a finding was kept.
  [ "$(o56 "unattributed" "$JOIN56")" = "$(o56 "kind: 'unknown'" "$JOIN56")" ] \
    || c3_56="$c3_56 [an unknown outcome does not carry the reason it could not be attributed]"
  # The one value the reading hangs on, checked against the set the schema admits before it is attached.
  [ "$(n56 "!== *'weaken'|!== *'add-check'" "$JOIN56")" -ge 1 ] \
    || c3_56="$c3_56 [the shape is attached without being checked against the admitted set]"
  [ -z "$c3_56" ] && ok "A3 an outcome that cannot be matched to exactly one proposal is marked unknown" \
                  || bad "A3 an outcome that cannot be matched to exactly one proposal is marked unknown:$c3_56"

  # A4 — the vocabulary reports the observation. Both directions: the observation words are there, and
  # the interpreting words are gone. Kept apart because the defect this task closes shipped with the
  # right three-term shape and the wrong meanings inside it.
  ENUM56="$(printf '%s' "$PS56" | grep -oE "outcome: \{[^}]*\}")"
  c4_56=""
  [ -n "$ENUM56" ] || c4_56="$c4_56 [the outcome enum could not be extracted]"
  [ "$(n56 "'red'" "$ENUM56")" -ge 1 ] || c4_56="$c4_56 [the enum does not name a red run]"
  [ "$(n56 "'green'" "$ENUM56")" -ge 1 ] || c4_56="$c4_56 [the enum does not name a green run]"
  [ "$(n56 "'unproven'" "$ENUM56")" -ge 1 ] || c4_56="$c4_56 [the enum drops the case where nothing ran]"
  [ "$(n56 "'died'|'survived'" "$ENUM56")" -eq 0 ] || c4_56="$c4_56 [the enum still names an outcome by what it would mean]"
  [ "$(n56 "retire|really does guard|the finding stands" "$PP56")" -eq 0 ] || c4_56="$c4_56 [the prover is told what an outcome means for a finding]"
  # File-wide, over the two prose homes as well: the enum leg above is scoped to the schema, so the report
  # template and the prover-stage paragraph could each revert to the retired words with every row green.
  [ "$(o56 '`died`|`survived`' "$(cat "$VP56" "$VS56")")" = "0" ] \
    || c4_56="$c4_56 [a document still names an outcome by the retired vocabulary]"
  # And the template positively names both halves of the pair, since it is the surface the report is
  # written from and the behavioral criterion is delivered through it.
  TPL56="$(awk '/^### Proven \(mutation\)/{f=1;next} f && /^#+ /{exit} f' "$VP56" | tr '\n' ' ')"
  [ "$(n56 "weaken" "$TPL56")" -ge 1 ] && [ "$(n56 "red" "$TPL56")" -ge 1 ] \
    || c4_56="$c4_56 [the report template does not name the shape declared and what the run did]"
  [ -z "$c4_56" ] && ok "A4 the outcome vocabulary names what the run did and never what it means" \
                  || bad "A4 the outcome vocabulary names what the run did and never what it means:$c4_56"

  # A7 — one fact stated at both actors, the shape C18 already uses for the restore prohibition. The
  # negative is the half that matters: the contradiction this task repairs was an instruction admitting
  # two kinds and a framing asserting there was only ever one.
  c7_56=""
  # `weaken[^a-z]` and not the bare word: the block also carries the prose sentence about a change that
  # "weakens an existing assertion", which answered a bare-word leg while the declaration itself was gone.
  # Written without backticks on purpose — a backticked pattern inside this nesting is not reliably quoted.
  [ "$(n56 'weaken[^a-z]' "$CTX56")" -ge 1 ] && [ "$(n56 'add-check' "$CTX56")" -ge 1 ] \
    || c7_56="$c7_56 [the reviewers are not told about both kinds]"
  [ "$(n56 "weaken" "$PP56")" -ge 1 ] && [ "$(n56 "add-check" "$PP56")" -ge 1 ] \
    || c7_56="$c7_56 [the prover is not told about both kinds]"
  [ "$(n56 '[Ee]ach auditor[^.]{0,80}hollow|every proposal[^.]{0,80}hollow' "$PP56")" -eq 0 ] \
    || c7_56="$c7_56 [the prover is still told every proposal suspects a hollow assertion]"
  # Counted across the engine, not at the prover alone: the diff removed the single-shape narrowing from
  # three places (the prover prompt, the protocol's rule sentence, the skill's invoke step) and only the
  # first was pinned, so two of the three could revert with the suite green.
  n7_56=0
  for h56 in $(grep -rIl 'hollow' "$ROOT/global/" 2>/dev/null); do
    t56="$(tr '\n' ' ' < "$h56")"
    [ "$(n56 '[Ee]ach auditor[^.]{0,80}hollow|every proposal[^.]{0,80}hollow|whether an assertion is hollow' "$t56")" -eq 0 ] || n7_56=$((n7_56+1))
  done
  [ "$n7_56" = "0" ] || c7_56="$c7_56 [$n7_56 document(s) still narrow every proposal to a hollow-assertion suspicion]"
  # And the rule the whole narrowing came from names the second shape POSITIVELY. Written as a negative
  # only, the sentence could revert to its single-shape original and fail nothing: there is no phrase a
  # correct two-shape sentence is obliged to avoid, so what has to be pinned is what it must contain.
  RULE56="$(awk '/^## Mutation and the Working Copy/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^#+ /){f=0} f' "$VP56" | tr '\n' ' ')"
  [ "$(n56 'two shapes|second shape' "$RULE56")" -ge 1 ] && [ "$(n56 'adding the assertion|adds the assertion|add-check' "$RULE56")" -ge 1 ] \
    || c7_56="$c7_56 [the rule that proving takes two shapes names only one]"
  [ -z "$c7_56" ] && ok "A7 the reviewers and the prover are told about the same two kinds of proposal" \
                  || bad "A7 the reviewers and the prover are told about the same two kinds of proposal:$c7_56"

  # A5 — retirement has exactly one door. The count is the discriminator and not decoration: a second
  # retiring sentence added anywhere in the bullet is the whole defect returning, and a co-occurrence
  # leg alone would stay green beside it.
  c5_56=""
  [ -n "$CONS56" ] || c5_56="$c5_56 [the consolidation's proof bullet could not be extracted]"
  [ "$(o56 "retire" "$CONS56")" = "1" ] || c5_56="$c5_56 [retirement is not stated exactly once]"
  [ "$(insent "$CONS56" 'weaken' '`red`' 'retire')" = 1 ] \
    || c5_56="$c5_56 [retirement is not tied to a weakening that went red]"
  # Tied to the RED run, because that is the case this leg exists for. Untied, the bullet's own
  # `add-check` + `green` sentence answered the leg and the red one could be deleted with the row green.
  # The token is matched as the document writes it — backticked. Bare `red` is three characters that
  # `declared` and `restored` both carry, and this same bullet uses both words, so the green sentence
  # would sit one ordinary word away from answering a leg about the red one.
  [ "$(insent "$CONS56" 'add-check' '`red`' 'stands|keeps|kept|demonstrat')" = 1 ] \
    || c5_56="$c5_56 [a new check that went red does not keep its finding]"
  [ -z "$c5_56" ] && ok "A5 a finding is retired only where existing code was weakened and the suite went red" \
                  || bad "A5 a finding is retired only where existing code was weakened and the suite went red:$c5_56"

  # A6 — the fail-closed branch, and the obligation to say so. Silence and a clean result read identically
  # in a report: the rule this engine already carries for an audit that cannot prove what it claims.
  c6_56=""
  [ "$(n56 "unknown|could not be attributed|cannot be attributed" "$CONS56")" -ge 1 ] \
    || c6_56="$c6_56 [an unattributable outcome has no branch]"
  [ "$(n56 '(unknown|attribut)[^.]{0,200}(keeps|kept|stands)' "$CONS56")" -ge 1 ] \
    || c6_56="$c6_56 [an unattributable outcome does not keep its finding]"
  [ "$(n56 '(record|say|name)[^.]{0,120}(attribut|unknown)|(unknown|attribut)[^.]{0,120}(recorded|named)' "$CONS56")" -ge 1 ] \
    || c6_56="$c6_56 [the reason an outcome could not be read is not written down]"
  [ -z "$c6_56" ] && ok "A6 an unattributable outcome keeps its finding and says so" \
                  || bad "A6 an unattributable outcome keeps its finding and says so:$c6_56"

  # O2 — one home. Counted across the engine rather than asserted at the two known sites: the drift this
  # closes was a second, independent statement of the mapping, and a row naming both files would go green
  # the moment a third surface restated it.
  c8_56=""
  # Keyed on the CONSEQUENCE and counted per file, which is the fix the review named. Two earlier forms
  # were wrong in opposite directions: a recursive proximity pattern that at least one grep refuses over
  # UTF-8, returning a clean zero; and an intersection of the bare words `retire` and `weaken`, which
  # fired on a rationale comment that states no rule and could not see the mapping restated in synonyms —
  # which is exactly how it came to be written twice while the count said one. Read per file into a
  # string, because the proximity quantifier is refused only in recursive mode.
  H56=0
  for f56 in $(grep -rIl 'weaken' "$ROOT/global/" 2>/dev/null); do
    b56="$(tr '\n' ' ' < "$f56")"
    [ "$(n56 'weaken[^.]{0,200}(retire|finding falls|finding stands)|(retire|finding falls|finding stands)[^.]{0,200}weaken' "$b56")" -eq 0 ] || H56=$((H56+1))
  done
  [ "$H56" = "1" ] || c8_56="$c8_56 [the retirement rule is stated in $H56 files, not one]"
  [ -n "$SP56" ] || c8_56="$c8_56 [the skill's proofs bullet could not be extracted]"
  [ "$(n56 "verify.md|verify protocol|Consolidation" "$SP56")" -ge 1 ] || c8_56="$c8_56 [the skill does not cite the home]"
  [ "$(n56 "retire" "$SP56")" -eq 0 ] || c8_56="$c8_56 [the skill restates the mapping it should cite]"
  # The count above rides on two ordinary words and cannot see a restatement in synonyms — which is how
  # the workflow came to tell reviewers a red made their finding "fall" or "stand", the consolidation's own
  # rows in other words, while the count reported one home. Scoped negatives on the two prompt regions
  # catch what a repo-wide word count cannot.
  [ "$(n56 "retire|finding falls|finding stands|closes your finding|keeps your finding" "$CTX56")" -eq 0 ] \
    || c8_56="$c8_56 [the reviewers are told what the report will do with the pair]"
  [ "$(n56 "finding falls|finding stands" "$PP56")" -eq 0 ] \
    || c8_56="$c8_56 [the prover is told what the report will do with the pair]"
  [ -z "$c8_56" ] && ok "O2 the meaning of an outcome is stated once and cited everywhere else" \
                  || bad "O2 the meaning of an outcome is stated once and cited everywhere else:$c8_56"
fi
