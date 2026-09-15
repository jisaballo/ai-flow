# =====================================================================================================
# C94 -- verify receives the task's context files as one list, and says when the repository one is absent
#
# Generated in the Conform phase from understand.md's Verifiable Criteria; every row is RED until the
# skill passes the list, the workflow reads it, and the absence is declared in both channels.
#
# Three house rules apply here and a row that breaks one is hollow whatever it prints:
#
#   1. Verdicts come from a COUNT inside an EXTRACTED REGION, never from a file-wide grep. The skill,
#      the workflow and the protocol all say these words elsewhere, which is how the steering argument
#      came to be believed present on an auditor that never received it (C57's own comment records it).
#      A region is not enough on its own: a whole numbered step is coarse, and this section shipped two
#      legs that a NEIGHBOURING concept's prose answered. A leg keyed on a verb takes its object with it.
#   1b. The extractors AND the count are the preamble's. `vstep`, `sbullet` and `msect` compute these
#      exact regions and are frozen as preamble-owned by C93's ROW 5; re-deriving them here passed that
#      row only by not reusing them. The count-in-a-region pipeline had no home at all — thirteen
#      sections each wrote it out under a name of their own, in two incompatible argument orders — so
#      this section's copy was the fourteenth and was in the minority order. It is `nreg` now, and the
#      thirteen are pre-existing and untouched.
#   2. A2 is an ABSENCE leg, so it is paired with a PRESENCE control over the SAME corpus and the SAME
#      machinery, and the corpus is asserted populated before either verdict is read. "the retired names
#      are gone" and "the corpus emptied and nothing was read" are otherwise the same green row.
#   3. This block's own file is excluded from the corpus BY NAME: it states both retired names in the
#      pattern below, so a corpus holding it can never go empty of them.
# =====================================================================================================
echo ""
echo "== C94: verify receives the task's context files as one list =="

SKV94="global/skills/verify/SKILL.md"
VW94="global/workflows/verify-review.js"
VP94="global/protocols/verify.md"
SELF94="test/sections/C94-verify-receives-the-tasks-context.sh"


c94_readable=1
for f94 in "$SKV94" "$VW94" "$VP94"; do
  { [ -r "$ROOT/$f94" ] && [ -s "$ROOT/$f94" ]; } || c94_readable=0
done

if [ "$c94_readable" -eq 0 ]; then
  bad "C94's three documents are all readable and non-empty"
else
  # The skill's two channels and the report template's one home, through the preamble's own extractors.
  # `vstep` flattens the step to one line, which costs nothing here — every leg below is a presence
  # count — and buys the adjacency legs their reach across a wrapped sentence.
  S7_94="$(vstep "$ROOT/$SKV94" 7)"
  S10_94="$(vstep "$ROOT/$SKV94" 10)"
  # THE ARGS LITERAL ALONE — the list the Workflow tool is actually handed, cut out of the step that
  # describes it. `sbullet` reaches the bullet but runs on into the paragraph below it, which is where
  # the prose naming `contextPaths` lives; the brace is the literal's own end and is what separates the
  # two. A prover deleted `contextPaths, ` from this literal and the row stayed green, because every leg
  # was reading a step region that still carried the word four sentences later. The call and the prose
  # about the call are two facts and they need two regions.
  CTXP94="$(sbullet "$ROOT/$SKV94" 7 '^[[:space:]]*- .args.:')"
  ARGS94="$(printf '%s' "$CTXP94" | sed 's/}.*//')"
  TPL94="$(msect "$ROOT/$VP94" '^[*][*]Audited[*][*]:')"
  # TWO regions of the workflow, and the split is the point. `ARGH94` is the args COMMENT, lines 11-24:
  # it ends where `let a = args` begins. A leg over it reads documentation. `CODE94` is the code that
  # runs, and it is the only place the argument is actually consumed.
  ARGH94="$(awk '/^\/\/ args \(from the/{f=1} f && /^let a = args/{exit} f' "$ROOT/$VW94")"
  CODE94="$(awk '/^let a = args/{f=1} f && /^const FINDINGS_SCHEMA/{exit} f' "$ROOT/$VW94")"

  # ---- A1: the call names the context list on both sides, and the workflow READS it ----------------
  # Both halves, because one side naming it is a call nothing on the other side receives. The third leg
  # is what the first two cannot give: a prover renamed the property at its single consumer and this row
  # stayed green, because every leg was reading prose. `a\.contextPaths` keys on the form the code uses
  # and the documentation cannot — the leading `a.` is the argument being dereferenced.
  a1_94=""
  [ -n "$S7_94" ]  || a1_94="$a1_94 [step 7 could not be extracted]"
  [ -n "$ARGH94" ] || a1_94="$a1_94 [the workflow's args header could not be extracted]"
  [ -n "$CODE94" ] || a1_94="$a1_94 [the workflow's code region could not be extracted]"
  [ -n "$ARGS94" ] || a1_94="$a1_94 [the call's args literal could not be extracted]"
  [ "$(nreg "$ARGS94" 'contextPaths')" -ge 1 ] || a1_94="$a1_94 [the call does not pass the list]"
  [ "$(nreg "$S7_94" 'contextPaths')"  -ge 1 ] || a1_94="$a1_94 [step 7 does not name the list]"
  [ "$(nreg "$ARGH94" 'contextPaths')" -ge 1 ] || a1_94="$a1_94 [the args header does not name the list]"
  # The trailing boundary is load-bearing and was added after a mutation walked straight through its
  # absence: unanchored, `a\.contextPaths` matches inside `a.contextPathsX`, so the rename this leg
  # exists to catch left it green. A leg keyed on a prefix is keyed on nothing a rename cannot satisfy.
  [ "$(nreg "$CODE94" 'a\.contextPaths([^A-Za-z0-9_]|$)')" -ge 1 ] \
    || a1_94="$a1_94 [nothing in the workflow's code reads the argument]"
  # The rendering the spec owes every auditor: key AND path, and the branch for an empty list.
  [ "$(nreg "$CODE94" 'e\.key')" -ge 1 ]   || a1_94="$a1_94 [the shared block renders no key]"
  [ "$(nreg "$CODE94" 'e\.path')" -ge 1 ]  || a1_94="$a1_94 [the shared block renders no path]"
  [ "$(nreg "$CODE94" 'none resolved')" -ge 1 ] \
    || a1_94="$a1_94 [an empty list renders as nothing rather than as a stated zero]"
  # THE GUARDS, KEYED ON THE GUARD AND NOT ON THE FIELD IT PROTECTS. The list crosses into the workflow
  # from outside, so every element is defended — and a leg counting `e\.key` matches `(e) => e.key`
  # exactly as it matches `(e) => e && e.key && e.path`, which leaves every defence free to be deleted
  # with this row green. Each is a distinct branch and each is named here: the container test, the one
  # membership predicate both the lookup and the rendering read, and the guard that refuses an
  # UNDEFINED key rather than letting `find` match the first entry whose own key is undefined.
  [ "$(nreg "$CODE94" 'Array\.isArray\(a\.contextPaths\)')" -ge 1 ] \
    || a1_94="$a1_94 [nothing refuses a context argument that is not a list]"
  [ "$(nreg "$CODE94" 'e && e\.key && e\.path')" -ge 1 ] \
    || a1_94="$a1_94 [the membership test no longer requires a key and a path]"
  [ "$(nreg "$CODE94" 'ctxList\.filter\(ctxHas\)')" -ge 1 ] \
    || a1_94="$a1_94 [the rendering no longer filters on the same predicate the lookup uses]"
  [ "$(nreg "$CODE94" 'k \? \(ctxList\.find')" -ge 1 ] \
    || a1_94="$a1_94 [an undefined key is looked up rather than refused]"
  # THE LOOKUP, BOUND TO THE KEY IT IS DEFINED ON. The leg above says the argument is dereferenced; it
  # says nothing about what is read OUT of it. A prover swapped `ctxOf('workspace')` for
  # `ctxOf('architecture')` and every leg in this section and in C57 stayed green — the reserved entry
  # the whole design rests on was named by nothing. The area entry is the same fact for the other
  # consumer: keyed on the area the run resolved, never on a literal that happens to match today.
  [ "$(nreg "$CODE94" "ctxWorkspace = ctxOf\('workspace'\)")" -ge 1 ] \
    || a1_94="$a1_94 [the repository-wide entry is not looked up on the reserved key]"
  [ "$(nreg "$CODE94" "ctxArea = ctxOf\(a\.area\)")" -ge 1 ] \
    || a1_94="$a1_94 [the area entry is not looked up on the area the run resolved]"
  # AND NOTHING DEFAULTS, OVER THE WHOLE FILE. The operator's central decision for this task was that the
  # retirement of the harness-file argument is CLEAN — no silent fallback to a literal `CLAUDE.md` once
  # it goes. That invariant is file-wide, and it was guarded twice over two disjoint regions that between
  # them reached 71 of the file's 471 lines: this leg over the code region, and `C57 A9`'s fourth leg
  # over the architecture prompt. A reinstated default in the security, contract, coverage or structure
  # prompt, or in either of the refute and prove prompts, passed both. One invariant, one home, the
  # file's whole reach — and `C57 A9` keeps its other three legs, which assert the architecture prompt's
  # positive shape and are a different fact. This is an ABSENCE leg (house rule 2): its presence control
  # is the legs above it, over the same file through the same helper, and `-s` is what refuses an empty
  # read — a file that did not read would otherwise answer zero and pass.
  VWALL94="$(cat "$ROOT/$VW94" 2>/dev/null)"
  [ -n "$VWALL94" ] || a1_94="$a1_94 [the workflow file could not be read whole]"
  [ "$(nreg "$VWALL94" 'CLAUDE[.]md')" -eq 0 ] \
    || a1_94="$a1_94 [a literal harness-file default is back in the workflow]"
  [ -z "$a1_94" ] && ok  "A1 the call names the context list on both sides, and the workflow reads it" \
                  || bad "A1 the call names the context list on both sides, and the workflow reads it:$a1_94"

  # ---- A2: the retired names are gone, and the new one stands where they stood ----------------------
  # Rule 2 above. The corpus is the preamble's whole-tree one minus this file; the sweep is the
  # preamble's, and `.ai-flow/` is gitignored here, so the archive is out by construction rather than by
  # a filter that could be written wrongly. Both legs run the same machinery on the same corpus,
  # differing only in the pattern, which is what makes the presence control a control rather than a
  # second opinion.
  CORP94="$(printf '%s\n' "$CORPUS_ALL89" | grep -vxF "$SELF94")"
  GONE94="$(sweep89 s 'steeringPath|claudeMdPath' "$CORP94")"
  HERE94="$(sweep89 s 'contextPaths' "$CORP94")"
  a2_94=""
  [ "$(printf '%s\n' "$CORP94" | grep -c . | tr -d ' ')" -ge 1 ] || a2_94="$a2_94 [the corpus is empty — nothing was read]"
  [ "$(printf '%s\n' "$GONE94" | grep -c . | tr -d ' ')" -eq 0 ] || a2_94="$a2_94 [retired names survive in: $(printf '%s' "$GONE94" | tr '\n' ' ')]"
  # The floor is a floor, never a census: below it the sweep has plainly stopped reading, and a census
  # written here would be a second statement of the homes row the card already computes.
  [ "$(printf '%s\n' "$HERE94" | grep -c . | tr -d ' ')" -ge 4 ] || a2_94="$a2_94 [the presence control found the new name in $(printf '%s\n' "$HERE94" | grep -c . | tr -d ' ') files]"
  # THE SECOND RETIREMENT, WHICH THE SWEEP ABOVE CANNOT SEE. This change retires two things and the legs
  # above guard one: the argument NAMES. The other is the private resolution verify used to keep —
  # `steering[<area>]`, falling back to `.ai-flow/steering/<area>.md` — retired on the decision that
  # verify was the only phase that had it, and that keeping it would re-separate verify from the
  # mechanism this task exists to converge it with (`understand.md`, Implementation Decision 5). A
  # prover re-inserted that clause in current terms and the whole suite stayed green: the rule can come
  # back and nothing says so. A retirement recorded in the Decision Register with a stated adopter
  # consequence and no leg is a regression guard that was never written.
  #
  # BOTH HALVES, over step 7's own region, because a rule that replaces one behaviour with another owes
  # both: the route that replaced it must be there, and the thing it replaced must not. The route half
  # is also the presence control for the absence half — same region, same helper — and `-n "$S7_94"` is
  # what refuses an empty one. The negative is keyed on the RESOLUTION, not on the retired argument
  # name: a paste-back written in current terms carries no retired name at all, which is exactly how
  # this survived a sweep that catches `steeringPath` anywhere in the tree.
  [ "$(nreg "$S7_94" 'context\.md')" -ge 1 ] \
    || a2_94="$a2_94 [step 7 no longer routes to the mechanism that owns the resolution]"
  [ "$(nreg "$S7_94" 'steering\[|falling back to .?\.ai-flow/steering|\.ai-flow/steering/<')" -eq 0 ] \
    || a2_94="$a2_94 [step 7 resolves the entry privately again, beside the route that replaced it]"
  [ -z "$a2_94" ] && ok  "A2 the retired names are gone and the new one stands where they stood" \
                  || bad "A2 the retired names are gone and the new one stands where they stood:$a2_94"

  # ---- A3: an absent workspace entry is declared in both channels -----------------------------------
  # Three homes, all required: the run's own output at step 7, the report at step 10, and the template
  # that shapes that report. A line promised in the skill and absent from the template is a promise the
  # next editor of the template deletes without knowing it existed.
  a3_94=""
  [ -n "$S10_94" ] || a3_94="$a3_94 [step 10 could not be extracted]"
  [ -n "$TPL94" ]  || a3_94="$a3_94 [the report template could not be extracted]"
  # The alternatives tolerate an inline code span around the key, which is how this repository spells it
  # everywhere else. Tolerating the span does not weaken the leg: with no absent case stated at all, none
  # of the four alternatives matches, and the row is red exactly as before.
  [ "$(nreg "$S7_94" 'holds no .?workspace|holds none|without a .?workspace|no .?workspace.? entry')" -ge 1 ] \
    || a3_94="$a3_94 [step 7 states no absent case]"
  # THE REMEDY, BOUND TO ITS OBJECT. This leg read `declare|what to declare` over the whole of step 7 and
  # was green at the branch base off seven lines of review-profile prose that predate this concept — a
  # verb matched free of its object, and the sole guard of the condition the operator made acceptance
  # turn on. A prover deleted the remedy in full and the row stayed green. What distinguishes the remedy
  # from every neighbouring "declare" is the pair of keys it names: the reserved entry, and the map it
  # goes in, and `insent` is what binds them: one sentence of the region carrying both. The character
  # bridge this replaced (`workspace.{0,60}steering:`) was an approximation of that, and C57's own head
  # comment records the cost — a bounded repeat is a pattern one of the two search engines a developer
  # may have can REFUSE, and a refusal returns the empty string, which is not a count and is not a zero.
  [ "$(insent "$S7_94" 'workspace' 'steering:')" = 1 ] \
    || a3_94="$a3_94 [step 7's absent case names no remedy: the reserved entry is not joined to the map it is declared in]"
  # Presence of the key alone, kept as a floor beneath the leg above and no longer standing in for it.
  [ "$(nreg "$S7_94" 'workspace')" -ge 1 ] || a3_94="$a3_94 [step 7 never names the reserved entry]"
  [ "$(nreg "$S10_94" 'contextPaths|context list|context files')" -ge 1 ] \
    || a3_94="$a3_94 [step 10 records no context list]"
  # Step 10 and the template are one physical line and one block respectively, so a bare `workspace`
  # count there says only that the word occurs. Both legs take the absent case with them.
  [ "$(nreg "$S10_94" 'no .?workspace.? entry|held no .?workspace|holds no .?workspace')" -ge 1 ] \
    || a3_94="$a3_94 [step 10 owes no line for the absent case]"
  [ "$(nreg "$TPL94" 'no .?workspace.? entry|was among them|holds no .?workspace')" -ge 1 ] \
    || a3_94="$a3_94 [the report template carries no such line]"
  # THE OTHER PROMISE THIS STEP MAKES ABOUT THE LIST, and it had no leg at all. `understand.md`'s Edge
  # Cases: *a path that does not read — reported by name; it never empties the list silently*. Step 7
  # stated the outcome and named no probe, which is the defect its own neighbouring bullet six lines
  # below records being caught once already: a promise whose probe is unstated is a promise nothing
  # performs. Two legs, because they are two facts — the verb bound to its object, and the probe that
  # makes the verb happen.
  #
  # OVER THE CONTEXT PARAGRAPH AND NOT OVER THE STEP. Written first over `S7_94`, both legs were answered
  # by the CHECKLIST bullet six lines below — which states the same promise about a different object and
  # names the same probe — so the prover deleted the context sentence in full, and then the probe with
  # it, and the row stayed green twice. The very defect this pair exists to catch, one concept to the
  # left. `CTXP94` is the args bullet and its own paragraph, which is where the context promise lives and
  # where the checklist's does not.
  [ -n "$CTXP94" ] || a3_94="$a3_94 [the context paragraph could not be extracted]"
  [ "$(insent "$CTXP94" 'does not read|cannot be read' 'named|names|reported')" = 1 ] \
    || a3_94="$a3_94 [the context paragraph does not say that an unreadable path is named]"
  [ "$(nreg "$CTXP94" '\[ -r |Test each resolved path')" -ge 1 ] \
    || a3_94="$a3_94 [the context paragraph names no probe for a path that does not read]"
  [ -z "$a3_94" ] && ok  "A3 an absent workspace entry is declared in both channels" \
                  || bad "A3 an absent workspace entry is declared in both channels:$a3_94"

  # ---- A4: a present workspace entry writes no such line --------------------------------------------
  # A3's other half, and unprovable from A3 alone: prose stating the absent case is satisfied by prose
  # that ALSO writes the line when the entry is there, which is the one outcome "exactly when absent"
  # rules out. Asserted over the same region, by the same machinery, for the same reason A2's control is.
  a4_94=""
  [ -n "$S7_94" ] || a4_94="$a4_94 [step 7 could not be extracted]"
  [ -n "$TPL94" ] || a4_94="$a4_94 [the report template could not be extracted]"
  # THE PRESENT CASE, BOUND TO ITS OUTCOME. This leg read five alternatives over the whole of step 7 and
  # any ONE of them answered it — so `holds one` alone was enough, and a prover inverted the sentence to
  # *"where the list holds one, the same line is written"*: the exact outcome this row exists to forbid,
  # and the row stayed green on the words that introduce it. A leg keyed on the condition and not on
  # what follows from it is keyed on nothing. `insent` binds the two inside one sentence.
  #
  # The OUTCOME half is the rule's own words and not the sentence's explanation of them. Written first as
  # `neither line|no such line|nothing is (said|written)`, this leg stayed green under the very inversion
  # above — because the clause that follows the rule, *"nothing is said about an entry that is there"*,
  # sits in the same sentence and answered the third alternative whatever the rule had been changed to.
  # An alternative loose enough to match the prose AROUND the fact is an alternative that unbinds the leg.
  [ "$(insent "$S7_94" 'holds one|holds a .?workspace|entry exists' 'neither line|no such line')" = 1 ] \
    || a4_94="$a4_94 [step 7 never states that a present entry writes nothing]"
  # The template carries the same two-halves rule and only its absence half was read. Invert the
  # present-case clause there — "and where one was, the same line" — and every other leg stays green
  # while the template instructs the one outcome "exactly when absent" exists to rule out.
  [ "$(nreg "$TPL94" 'where one was, no such line|no such line|neither line')" -ge 1 ] \
    || a4_94="$a4_94 [the report template states no present case]"
  [ -z "$a4_94" ] && ok  "A4 a present workspace entry writes no such line" \
                  || bad "A4 a present workspace entry writes no such line:$a4_94"
fi
