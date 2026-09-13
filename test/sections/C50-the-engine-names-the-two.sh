echo ""
echo "== C50: the engine names the two places where stopping pays, and says so on every sitting =="
# Conformance: the session cut rides the write that advances the sheet to the NEXT position at the close of
# Understand and at the close of Execute, and announces only where this session has already become expensive.
# Generated in the Conform phase from understand.md's Verifiable Criteria; each row names the criterion it
# comes from. C49 remains the earlier guard over the same bullet.
#
# THE BLOCK'S RULE CHANGED under it, and this header is the corrected one. The title spoke of the engine
# speaking "only where stopping pays"; both closes now state their line on EVERY sitting, cheap or long,
# and what is guarded is the line's fixed form (A7), the retired gate's absence everywhere installed (A8),
# the positive rule that emits it (A3'), the routing surfaces (A10), the map's dropped silence claim (A11)
# and the line's single home (A12). A conformance header describing the retired rule is the first thing a
# reader trusts and the last thing anyone edits.
BL50="$ROOT/global/protocols/backlog.md"
MAP50="$ROOT/global/protocols/lifecycle.md"

# Same region as C49, and for the same reason: the obligation is a property of ONE act. A whole-file search
# is satisfied by `## State Files` and by the out-of-phase bullet, both of which name positions and sittings,
# so it would report the rule present before a word of it was written.
CP50="$(awk '/^- \*\*A clean pass\.\*\*/{f=1} f&&/^### /{exit} f' "$BL50" 2>/dev/null)"
if [ -z "$CP50" ]; then
  bad "the clean-pass bullet can be located for the two-boundary rule (nothing extracted: every row below would be about an empty string)"
else
  # A1+A2 -- WHEN Understand closes, and WHEN Execute closes, on a session past the threshold, the engine
  # shall write the NEXT position, its `next action:`, announce and end the turn. Both boundaries are read on
  # ONE row and each names the position it writes, because a row satisfied by either alone passes over a rule
  # that shipped half of it -- which is precisely the shape the earlier rule left behind, one boundary out of two.
  a50=""
  printf '%s' "$CP50" | grep -qiE 'close of Understand|Understand closes|closes Understand' \
    || a50=" [the bullet does not name the close of Understand as a boundary that announces]"
  printf '%s' "$CP50" | grep -qiE 'close of Execute|Execute closes|closes Execute' \
    || a50="$a50 [it does not name the close of Execute as a boundary that announces]"
  # Case-SENSITIVE, like its VERIFY sibling below and unlike its own first draft: the region has always
  # carried lowercase `plan` -- "`plan` additionally advances the sheet", "the plan's Criteria Coverage
  # table" -- so a -i here was green before the requirement existed and stayed green when the clause naming
  # it was deleted. Uppercase PLAN appears on exactly one line, the one this leg is about.
  printf '%s' "$CP50" | grep -q 'PLAN' \
    || a50="$a50 [it does not name PLAN as the position the close of Understand writes]"
  printf '%s' "$CP50" | grep -q 'VERIFY' \
    || a50="$a50 [it does not name VERIFY as the position the close of Execute writes]"
  [ -z "$a50" ] && ok "both boundaries are named, each with the position its close writes" \
                || bad "both boundaries are named, each with the position its close writes ($a50)"

  # A3's rule is RETIRED here, in the same change that removes the prose it asserted. `b50` required the
  # announcement to be gated on a measured cost signal and the cheap branch to carry its own verdict of
  # silence; both closes now state their line on every sitting, so the row would have pinned the engine to
  # a condition it no longer has -- and pinned it GREEN, which is worse than not guarding it, because the
  # removal could not have shipped without the suite objecting. Its replacement is A7's `a7_50` (the line's
  # fixed form, availability as a fact) together with A8's `GONE50` (the gate stated nowhere). The rows are
  # not silently dropped: this comment is what stops the next reader finding a retired key in the frozen
  # manifest and concluding a leg went missing.
  # A3' -- WHILE any sitting closes, cheap or long, the engine shall state that the line is owed. The
  # POSITIVE half of the replacement, and it was missing: A8 counts zero statements of the retired gate,
  # A7 reads the form paragraph for the line's elements, A11 forbids the map's silence claim -- and
  # nothing at all read the paragraph that says WHEN the line is emitted. Its single home could be
  # deleted outright, leaving the engine with a form for a line and no rule requiring it, and every row
  # of C49, C50 and C63 stayed green.
  #
  # This is the class the project's own coverage checklist calls the most expensive: a rule that replaces
  # one behaviour with another needs both halves, because absence alone is satisfied by deleting the
  # passage and writing nothing. The retired `b50` did pair them; its replacements kept only the negative
  # side, which is how a pairing gets lost in a re-key rather than in an omission.
  #
  # Three legs, and the third is not decoration: without `no threshold`, the paragraph can shrink to a
  # bare adverb that no longer denies the thing it replaced.
  a3p_50=""
  printf '%s' "$CP50" | grep -qiE '(state|states|carry|carries|end with)[^.]*(on|at) every sitting|every sitting[^.]*(included|cheap)' \
    || a3p_50=" [nothing says the line is owed on every sitting, so the rule that emits it has no home]"
  printf '%s' "$CP50" | grep -qiE 'short ones included|cheap or expensive|cheap ones included|the short ones' \
    || a3p_50="$a3p_50 [the short sitting is not named as included, which is the case the retired rule excluded]"
  # RE-KEYED, and the retired alternation is named rather than quietly dropped. It accepted `nothing to
  # measure`, and the close now measures: what is unconditional is the LINE, what is measured is the
  # recommendation inside it. Left as it was, the paragraph could be written back to "nothing for the
  # close to measure" and stay green while contradicting the rule two paragraphs down — green, which is
  # worse than unguarded. The direction it held is unchanged and stays first: the EMISSION is denied a
  # threshold. The second leg is what the re-key adds, and it is the half that stops a condition creeping
  # back onto whether the line is spoken at all — which is the failure the whole paragraph replaced.
  printf '%s' "$CP50" | grep -qiE 'no threshold decides|owed whatever the numbers' \
    || a3p_50="$a3p_50 [it does not deny that a threshold decides whether the line is spoken]"
  printf '%s' "$CP50" | grep -qiE 'not whether to speak but what to recommend|whether to speak[^.]*what to recommend' \
    || a3p_50="$a3p_50 [it does not separate what the close measures from whether the line is owed, so a condition can creep back onto the emission]"
  [ -z "$a3p_50" ] && ok "A3' the line is owed on every sitting, the short ones named, and the threshold denied" \
                   || bad "A3' the line is owed on every sitting, the short ones named, and the threshold denied ($a3p_50)"

  # A5 -- WHERE the write advances the sheet to EXECUTE at Conform's close, the engine shall announce no cut.
  # Written down because it is the one boundary a reader would assume symmetric: three closes write a next
  # position and only two of them speak. Without this row the third can start announcing and nothing objects.
  c50=""
  # NOT the bare presence of `EXECUTE`: the region carried it before this task ("`plan` additionally
  # advances the sheet to EXECUTE when Conform closes"), so that leg was green on prose predating the
  # requirement -- the same disease as a50's PLAN leg, and this row's own frozen direction already said
  # bare presence "is not sufficient". Keyed instead on the fact only the new requirement supplies: that
  # the silence at that boundary is chosen, which is what stops a later reader from repairing it.
  printf '%s' "$CP50" | grep -qiE 'silence is a decision|decision rather than an omission' \
    || c50=" [it does not say the silence at Conform's close is a decision rather than an omission]"
  printf '%s' "$CP50" | grep -qiE 'EXECUTE[^.]*(does not announce|announces nothing|no announcement|is not a boundary|not a cut)|(does not announce|announces nothing|no announcement|not a cut point)[^.]*EXECUTE' \
    || c50="$c50 [it does not say that the write closing Conform announces nothing]"
  [ -z "$c50" ] && ok "the write that closes Conform is named as the boundary that does not announce" \
                || bad "the write that closes Conform is named as the boundary that does not announce ($c50)"

  # A6's rule is RETIRED here for the same reason as A3's, and by the same change. `d50` required the
  # recommendation FIRST; the line is now a fact and carries no recommendation at all, deliberately, until
  # the cost note reaches the phase. Two of its legs were real coverage of obligations that survive -- that
  # the line requests no input, and that it is short -- so they are CARRIED FORWARD into A7's row below
  # rather than lost with the key that held them. `FORM50` stays: A7 reads the same paragraph. The row
  # itself is GONE from this file rather than standing beside A7.
  # FLATTENED at the extraction, exactly as C65's FORM65 is, and for the third time in one task: a leg
  # keyed line-wise over hard-wrapped prose answers on where someone pressed return. Eight of the eleven
  # legs below used to read this unflattened while three got a flattened copy through a local variable --
  # so the same paragraph was being judged two ways in one row block. The fix belongs at the extraction,
  # which is where the other two occurrences ended up.
  # The paragraph must stay ONE paragraph, and this extraction is why: it stops at the first blank line,
  # so a blank line inserted inside the form silently drops everything after it out of what is read. That
  # constraint used to be written into the protocol itself, addressed to whoever might reformat it -- an
  # editing instruction about a grep, carried in a document the model reads at every close. It is gone from
  # there, because it does not need saying: split the paragraph and the legs below go red on the spot, which
  # is the mechanism enforcing the rule instead of the prose asking someone to remember it.
  FORM50="$(printf '%s' "$CP50" | awk '/\*\*The form is fixed/{f=1} f&&/^[[:space:]]*$/{exit} f' | tr -s ' \n' '  ')"
  # A7 -- WHEN either close writes the next position, the engine shall state that the close ends with one
  # fixed line carrying cut availability, the position the sheet now declares, and where the next session
  # resumes. Generated in the Conform phase from understand.md's Verifiable Criteria.
  #
  # Read over the FORM PARAGRAPH ALONE, for the reason d50's comment records at length: every element of a
  # form has a second satisfier somewhere in this region, and keyed on the region this row would be green
  # with the form's own requirement deleted. `d50` above is the RETIRED form -- recommendation-first -- and
  # is GONE from this file. The two coexisted only between Conform and Step 3 of the change that wrote this
  # row, which is what the baseline manifest records; a comment claiming they still stand beside each other
  # would send the next reader looking for a row that is not here.
  #
  # `cut available` is the line's own marker and appears nowhere else in the engine, which is what makes it
  # a discriminator and also what makes A12's home count possible. The fact-not-advice leg is the decision
  # itself (D2): without it the recommendation walks back in as soon as someone reads the absence as an
  # omission, which is why the deliberateness leg is here too -- the same guard c50 puts on Conform's
  # chosen silence.
  a7_50=""
  if [ -z "$FORM50" ]; then
    a7_50=" [the bullet states no form paragraph for the close's line at all]"
  else
    printf '%s' "$FORM50" | grep -qi 'cut available' \
      || a7_50=" [the form does not carry the line's own marker, so no surface can route to it and nothing can count its home]"
    printf '%s' "$FORM50" | grep -qiE 'fact, not advice|a fact and not advice|not advice' \
      || a7_50="$a7_50 [it does not say the line is a fact rather than advice]"
    printf '%s' "$FORM50" | grep -qiE 'position the sheet now declares|position now declared|the position it has just written' \
      || a7_50="$a7_50 [it does not name the position the sheet now declares as an element of the line]"
    # TWO legs, because the alternation held two different facts and mutation showed only one of them was
    # guarded: deleting "a pointer to the sheet's `next action:` and never a copy of it" left the row green
    # on the surviving "where the next session picks up", so the line could have grown a COPY of the resume
    # text and nothing objected. A copy is the failure -- the sheet is the one place that line lives, and an
    # announcement carrying its own duplicate is state kept in two places at once.
    printf '%s' "$FORM50" | grep -qiE 'where the next session picks up|next action:' \
      || a7_50="$a7_50 [it does not name where the next session resumes as an element of the line]"
    printf '%s' "$FORM50" | grep -qiE 'pointer to the sheet|never a copy' \
      || a7_50="$a7_50 [it does not require that element to be a pointer rather than a copy of the sheet's line]"
    # RE-KEYED. It required the recommendation to be *deliberately absent*, and the recommendation is now
    # made — the signal it waited for reaches the phase, which is the condition this very paragraph named
    # as the day it would. Left standing, the leg pins the engine to prose that contradicts the rule
    # beside it, and pins it GREEN, so the change could not ship without the suite objecting to it.
    # What replaces it is the pairing the new rule needs: the recommendation is made, and it is made on a
    # COMPARISON rather than on a number — the half a later editor spends first, because a constant reads
    # as more concrete than a rule.
    #
    # FLATTENED, unlike the legs above, and only because it has to be: both phrases straddle a line break
    # in the paragraph as it is wrapped today. A leg keyed on where someone pressed return reports a rule
    # missing while it stands — this suite has now been bitten by that twice in one change.
    printf '%s' "$FORM50" | grep -qiE 'recommends? (the )?cut|recommend cutting' \
      || a7_50="$a7_50 [the line makes no recommendation, so the signal the phase is now handed changes nothing]"
    printf '%s' "$FORM50" | grep -qiE 'comparison and not a threshold|comparison, not a threshold' \
      || a7_50="$a7_50 [it does not say the bar is a comparison rather than a threshold, so a constant can be written back in]"
    printf '%s' "$FORM50" | grep -qiE 'deliberately absent|until the (context-)?cost note reaches' \
      && a7_50="$a7_50 [the retired sentence still says the recommendation is absent, contradicting the rule beside it]"
    # The two legs CARRIED FORWARD from the retired `d50`. They guarded obligations the new rule keeps, and
    # they are here because the key that held them is gone: dropped with it, the form could start asking for
    # an input or grow to a paragraph and nothing would object. `one sentence` is deliberately not an
    # alternative to the shortness leg -- d50's own comment records that a shortness leg accepting it is
    # satisfied by its neighbour and guards nothing of its own.
    printf '%s' "$FORM50" | grep -qiE 'requests? no input|no input is (requested|sought)' \
      || a7_50="$a7_50 [it does not forbid the close from requesting an input]"
    printf '%s' "$FORM50" | grep -qiE 'short|brief|few lines' \
      || a7_50="$a7_50 [it does not require the line to be short]"
  fi
  [ -z "$a7_50" ] && ok "A7 the close's line is fixed: availability as a fact, the position now declared, and where the next session resumes" \
                  || bad "A7 the close's line is fixed: availability as a fact, the position now declared, and where the next session resumes ($a7_50)"
fi

# `e50` is RETIRED here: it required the gate to be stated in exactly ONE file, and the gate is now stated
# in none. A8's `GONE50` above is that count with the direction inverted AND the reach widened, which is
# why this is a replacement rather than a deletion. `GATE50` itself survives -- A8 reads it, and the pattern is the
# retired wording's definition, which is exactly what an absence check needs.
GATE50='(become|becomes|has become) expensive|crossed the (context-)?cost threshold'
# The `s50` loop is RETIRED here and replaced by A10 below, which sweeps the same three surfaces. Its
# gate leg required each of them to carry the routing paraphrase `grown costly`, so it asserted the very
# condition this change removes -- and its own comment explains that the paraphrase was chosen to keep
# e50's home count at one, a pairing that no longer has a partner. A10 keeps the two-legs-pulling-opposite-
# ways shape it shared with `e49`, and re-points the gate leg from requiring the condition to forbidding it.
# A4, on the command that lands in the re-entry the close of Understand creates. The plan command is the
# only one of the three whose whole share of this mechanism is arriving to find the work already done, so
# it is guarded on that and not on a close it does not have.
h50=""
grep -qiE 'already declares PLAN' "$ROOT/global/skills/plan/SKILL.md" 2>/dev/null \
  || h50=" [the plan command does not state the re-entry it ordinarily lands in]"
grep -qiE 'nothing is announced|announces nothing' "$ROOT/global/skills/plan/SKILL.md" 2>/dev/null \
  || h50="$h50 [it does not say that re-entry announces nothing]"
[ -z "$h50" ] && ok "the plan command states the re-entry it lands in, and that it announces nothing" \
              || bad "the plan command states the re-entry it lands in, and that it announces nothing ($h50)"

# The per-leg mutation rule, guarded where it now lives. Not a row about this task's mechanism at all --
# it is the method that FAILED to catch two of this block's own hollow legs, and a rule recorded only in a
# task's artifacts is one the next Conform phase never reads. Two legs: the verify protocol must state that
# independent legs are mutated one apiece, and must say what the cheaper battery does not prove -- because
# a rule given without the failure it prevents is the one a later reader trims as verbosity.
VP50="$ROOT/global/protocols/verify.md"
i50=""
# `own mutation` was an alternative here and had to go: the paragraph BELOW the requirement narrates the
# failure that produced it ("each killed by their own mutation, and reported proved on that basis"), so
# deleting the requirement left this leg green on its own justification. Caught by mutation, on the very
# row that guards the rule about exactly this -- which is the argument for the rule, made against itself.
grep -qiE 'each leg gets its own mutation|per leg, not per row' "$VP50" 2>/dev/null \
  || i50=" [the verify protocol does not require independent legs to be mutated one apiece]"
grep -qiE 'not vacuous|says nothing about whether the other legs' "$VP50" 2>/dev/null \
  || i50="$i50 [it does not say what a per-row battery leaves unproved]"
[ -z "$i50" ] && ok "the verify protocol requires a mutation per leg, and says what per-row leaves unproved" \
              || bad "the verify protocol requires a mutation per leg, and says what per-row leaves unproved ($i50)"

# The workflow's script path. The skill named a path the Workflow tool refuses (`~/.claude/` is neither a
# path it returned nor one the session can already read), so every Guided verify hit a refusal that names
# no remedy. The row guards the remedy rather than the prohibition: what must survive is the instruction to
# copy, since a skill that merely drops the bad path leaves the next reader to rediscover the wall.
SKV50="$ROOT/global/skills/verify/SKILL.md"
j50=""
grep -qiE 'copy the script into the scratchpad|scratchpad copy' "$SKV50" 2>/dev/null \
  || j50=" [the verify skill does not tell the run to copy the workflow into the scratchpad]"
grep -qiE 'copy per run|never once and reused' "$SKV50" 2>/dev/null \
  || j50="$j50 [it does not say the copy is per run, so an edit to the installed workflow would stop reaching the review]"
[ -z "$j50" ] && ok "the verify skill routes the workflow through a path the tool accepts, per run" \
              || bad "the verify skill routes the workflow through a path the tool accepts, per run ($j50)"

# O2 -- The lifecycle map shall name three sittings and both boundaries. Paired on one row: a map saying
# "three sittings" without naming where they are divided sends the reader to count phases and guess, and
# naming the boundaries while still saying two contradicts the rule it routes to.
f50=""
grep -qiE '(three|3) *(sittings|sessions)' "$MAP50" 2>/dev/null \
  || f50=" [the map does not say a full-path task is three sittings]"
grep -qiE 'close of Understand|Understand closes' "$MAP50" 2>/dev/null \
  || f50="$f50 [it does not name the close of Understand as one of the boundaries]"
grep -qiE 'close of Execute|Execute closes' "$MAP50" 2>/dev/null \
  || f50="$f50 [it does not name the close of Execute as the other]"
[ -z "$f50" ] && ok "the map names three sittings and both boundaries" \
              || bad "the map names three sittings and both boundaries ($f50)"

# A8 -- IF any installed file conditions the announcement on the session having become expensive, THEN the
# check shall fail. Generated in the Conform phase from understand.md's Verifiable Criteria.
#
# This is `e50` INVERTED, not a second copy of it: e50 requires exactly one statement of the gate, this
# row requires none. Both are here through Conform on purpose -- one green, one red -- so the baseline
# shows which rule replaced which; Step 3 retires e50 in the same change that turns this green. The
# reach is e50's own, and for its reason: `template/` is what an adopting project receives and `docs/` is
# what its operator reads, so a gate surviving in either makes the invariant false where nobody looks.
#
# THE REACH is A12's, not the retired `e50`'s, and the widening is the row. `e50` swept four directories
# and this row inherited them while its own message claims "no installed file" -- and `global/CLAUDE.md`
# IS installed (`install.sh:427` fetches it to `~/.claude/CLAUDE.md`, the file read on every turn of every
# project), as are `global/workflows/`, `global/ralph/`, `global/hooks/`, `global/scripts/` and
# `README.md`. So the retired gate could be written back into the most-read installed file in the engine
# with this row green, which is the one thing the decision behind it was taken to prevent. A12 twelve
# rows down had already chosen the wider reach; two sibling rows of one change disagreeing about what
# "installed" means is how a guard comes to claim a reach it does not have.
#
# THE PATTERN carries the routing paraphrases too, and that is the second half. The retired condition was
# written two ways: canonically here, and as `grown costly` / `still cheap` on the surfaces that routed to
# it. A10 forbids the paraphrases on the three surfaces it sweeps -- and `global/skills/verify/SKILL.md`,
# the fifth surface that carried the condition, is in no loop at all, so it could have regrown the gate in
# paraphrase with every row green. Measured before widening: all three paraphrases have zero hits across
# the installed surface, so this costs nothing today and closes the hole permanently.
#
# `grown expensive` is deliberately NOT in the pattern. `global/hooks/context-cost-note.py` opens with
# "the session has grown expensive" -- that hook's whole subject IS session cost, it is legitimate, and
# C49's `f49` control exists to keep it exactly as it is. A negative leg that reddens the file another
# leg protects is a leg that will be deleted rather than obeyed.
#
# THIS ROW SURVIVES the close gaining a recommendation, and the reason is written here because without it
# the next reader meets a row forbidding a cost condition beside a rule that states one, and deletes the
# row as contradicted. The two are different rules. What this forbids is the RETIRED gate: a condition on
# whether the line is SPOKEN at all, inferred from how expensive the sitting felt. What the close now
# carries is a condition on what the line RECOMMENDS, computed from two quantities the hook measures and
# hands over. The line is still owed on every sitting -- A3' is the positive half of exactly that -- and
# the retired vocabulary appears nowhere, which is what this row counts.
GATE50_ANY="$GATE50"'|grown costly|grew costly|still cheap'
# The sweep roots are PROVEN to exist before the count is trusted. With `2>/dev/null` swallowing grep's
# errors, a renamed or missing directory yields no hits, the count is zero, and a search that never
# happened reports as a pass -- the failure mode an absence check is least able to notice, because its
# green state and its broken state look identical.
# ONE definition of "the installed surface", shared by A8 and A12 below. Two hand-rolled copies landed in
# this change and disagreed -- A8 swept four directories, A12 swept `global/` plus README.md -- and the
# narrower one is what let the retired gate survive in the most-read installed file. A concept written
# out longhand twice is a concept that will be written out differently twice.
INSTALLED50_1="$ROOT/global/"; INSTALLED50_2="$ROOT/template/"; INSTALLED50_3="$ROOT/docs/"; INSTALLED50_4="$ROOT/README.md"
GONEROOTS50="$INSTALLED50_1 $INSTALLED50_2 $INSTALLED50_3 $INSTALLED50_4"
g8_50=""
for r50 in $GONEROOTS50; do
  [ -e "$r50" ] || g8_50="$g8_50 [the sweep root $r50 does not exist, so its absence of hits proves nothing]"
done
GONE50="$(grep -rliE "$GATE50_ANY" "$INSTALLED50_1" "$INSTALLED50_2" "$INSTALLED50_3" "$INSTALLED50_4" 2>/dev/null | wc -l | tr -d ' ')"
[ "$GONE50" -eq 0 ] || g8_50="$g8_50 [$GONE50 installed file(s) still state the retired gate or one of its paraphrases]"
if [ -z "$g8_50" ]; then
  ok "A8 no installed file gates the close's line on the session having become expensive"
else
  bad "A8 no installed file gates the close's line on the session having become expensive ($g8_50)"
fi

# A10 -- WHERE a surface other than the backlog protocol carries a close, that surface shall state the
# fixed line, shall not gate it on cost, and shall not restate the rule. Generated in the Conform phase
# from understand.md's Verifiable Criteria.
#
# The `s50` loop re-keyed, and running beside it through Conform for the same reason A8 runs beside e50.
# Four legs, two pulling each way -- the shape `s50` and `e49` already use: the surface must carry the
# ACT (a close that ends the turn and names the line), and must NOT carry the RULE. The marker leg is
# deliberately NEGATIVE here: `cut available` is the line's own wording and A12 requires exactly ONE home
# for it, so a surface satisfying its own leg with the canonical marker would turn A12 red. This row says
# the line must be named here, A12 says it must be spelled only there.
# THE LOOP IS DERIVED, not a list of three paths, and that is what makes the Observable true: the promise
# is that "a fifth uncounted copy cannot grow", and a hard-coded list can only ever check the four copies
# somebody already found by hand. Any installed file that carries a close is swept -- so a surface added
# next year is checked the day it appears, with nobody remembering to add it here. The engine's own
# discipline for exactly this is that a row is COMPUTED: the guard declares the rule that recognises a
# member, never the members.
#
# A member is a file that names one of the two closes AND says a turn ends there -- the shape a surface
# carrying a close has, and one no mere citation has. The home is excluded by name: it is where the line
# is specified, so the negative legs below would refuse it by construction.
# Case-INSENSITIVE, like the per-surface legs below. Written case-sensitive first, the derivation missed
# `global/protocols/execute.md` outright -- its heading is `## The close of Execute`, capital T -- so the
# sweep silently dropped a surface it was built to find, and the floor leg is what caught it. That is the
# whole argument for the floor: a derived set that quietly selects too little looks exactly like a clean run.
S10SET50="$(grep -rliE 'close the phase|the close of Execute' "$INSTALLED50_1" "$INSTALLED50_2" 2>/dev/null \
  | while IFS= read -r c50f; do grep -qiE 'end the turn|ends the turn' "$c50f" 2>/dev/null && printf '%s\n' "${c50f#$ROOT/}"; done \
  | grep -v '^global/protocols/backlog\.md$' | sort)"
# The derivation must SELECT something, and the three surfaces already known to carry a close are the
# floor. A derived sweep that silently matches nothing is the failure mode that replaces a stale list
# with an empty one.
n10_50="$(printf '%s\n' "$S10SET50" | grep -c . | tr -d ' ')"
[ "$n10_50" -ge 3 ] \
  && ok "A10 the close-carrying surfaces are derived, not listed ($n10_50 found)" \
  || bad "A10 the close-carrying surfaces are derived, not listed (found $n10_50, expected at least the three known)"
for s10_50 in $S10SET50; do
  k50=""
  grep -qiE 'close the phase|the close of Execute' "$ROOT/$s10_50" 2>/dev/null \
    || k50=" [it names no close that advances the sheet to the next position]"
  grep -qiE 'end the turn|ends the turn' "$ROOT/$s10_50" 2>/dev/null \
    || k50="$k50 [its close does not say the turn ends there]"
  grep -qiE 'fixed line|fixed cut line' "$ROOT/$s10_50" 2>/dev/null \
    || k50="$k50 [its close does not say it ends with the fixed line]"
  grep -qiE 'grown costly|still cheap' "$ROOT/$s10_50" 2>/dev/null \
    && k50="$k50 [its close is still gated on the sitting having grown costly]"
  grep -qi 'cut available' "$ROOT/$s10_50" 2>/dev/null \
    && k50="$k50 [it spells the line out instead of routing to the one home that specifies it]"
  grep -q 'next action:' "$ROOT/$s10_50" 2>/dev/null \
    && k50="$k50 [it restates the close's own obligation instead of routing to it]"
  [ -z "$k50" ] && ok "A10 $s10_50 states the fixed line and routes the rule" \
                || bad "A10 $s10_50 states the fixed line and routes the rule ($k50)"
done

# A11 -- IF the lifecycle map claims the closes stay silent on a sitting that never grew costly, THEN the
# check shall fail. Generated in the Conform phase from understand.md's Verifiable Criteria.
#
# Its own row rather than a leg of `f50`: f50 is about what the map must SAY (three sittings, both
# boundaries) and this is about what it must no longer say, so a shared row would report a true claim
# missing when a false one is merely present. The map is the one surface that asserts the silence as a
# property of the closes rather than routing to it, which is why it needs a leg and the other routers do
# not -- theirs is A10's.
# Both inflections, and the reason is a gap mutation found: the pattern read `grew costly` alone, which is
# the wording the MAP happened to use ("on a sitting that never grew costly") -- while every routing surface
# said `grown costly`. So the map could have regrown the claim with one word changed and this row stayed
# green. A negative leg is only as wide as the ways the claim can be written, which is why the widening
# belongs here rather than in a future reader's memory. `stay silent` is the claim's own verb, keyed loosely
# on purpose: it catches a re-add that avoids the cost words altogether.
# The file is PROVEN READABLE before its silence is believed. An absence check over a path that cannot be
# read finds nothing and reports green, so a renamed or deleted map would certify the very claim this row
# forbids -- and this is the only row standing between the map and a re-added cost condition.
#
# UNAFFECTED by the close gaining a recommendation, for A8's reason one row up: what the map may not claim
# is that the closes STAY SILENT on a cheap sitting, and they do not -- the line is owed always, and only
# the recommendation inside it is conditional. A reader who reads this row as contradicted by the new bar
# has confused the emission with its content, which is the confusion A3''s second leg now guards.
a11_50=""
[ -r "$MAP50" ] || a11_50=" [the lifecycle map cannot be read, so its silence proves nothing]"
grep -qiE 'grew costly|grown costly|still cheap|stays? silent (on|while|where)' "$MAP50" 2>/dev/null \
  && a11_50="$a11_50 [the map still claims the closes stay silent on a sitting that never grew costly]"
[ -z "$a11_50" ] && ok "A11 the map no longer claims the closes stay silent on a sitting that never grew costly" \
                 || bad "A11 the map no longer claims the closes stay silent on a sitting that never grew costly ($a11_50)"

# A12 -- The engine shall count the homes of the announcement obligation, and the count shall be exactly
# one. Generated in the Conform phase from understand.md's Verifiable Criteria; it is the remedy the
# Icebox entry on this gap was taken for -- nothing counted the obligation's homes, though the map
# asserts it lives in one place "and nowhere else", and that absent count is why four restatements of the
# retired condition were found by hand rather than by this suite.
#
# COUNTED, not merely found, for the reason C22's and C43's home guards both give: the anti-drift design
# is that a second statement cannot exist, and a check asking only whether the rule is present anywhere
# is satisfied by every copy at once. Keyed on the line's own marker, which is what selects a STATEMENT
# of the line over a surface that merely routes to it -- a router never has to spell the line out, which
# is exactly what A10's negative leg requires of the three of them.
MARK50='cut available'
# The SAME installed surface A8 sweeps, by the same four names: the two rows count opposite things over
# one reach, and a reach that drifts between them is how one row came to promise what the other did not.
HOMEOB50="$(grep -rli "$MARK50" "$INSTALLED50_1" "$INSTALLED50_2" "$INSTALLED50_3" "$INSTALLED50_4" 2>/dev/null | wc -l | tr -d ' ')"
l50=""
[ "$HOMEOB50" -eq 1 ] || l50=" [the close's line is spelled out in $HOMEOB50 installed files, not exactly one]"
grep -qi "$MARK50" "$BL50" 2>/dev/null || l50="$l50 [the backlog protocol, which is its home, does not spell it out]"
[ -z "$l50" ] && ok "A12 the close's line has exactly one home, and it is the backlog protocol" \
              || bad "A12 the close's line has exactly one home, and it is the backlog protocol ($l50)"
