echo ""
echo "== C49: the cut's obligations, its single home, and the note that points at it =="
# Conformance: the write that stamps VERIFY on the sheet carries the session cut with it -- and only where
# that write CHANGES the position, so the announcement cannot fire on the sitting it created. Generated in
# the Conform phase from understand.md's Verifiable Criteria; each row names the criterion it comes from.
# One row is a CONTROL in the sense C48's rows already use: it pins behaviour this task must NOT take away,
# so it is green from the start by construction rather than by achievement.
BL49="$ROOT/global/protocols/backlog.md"
MAP49="$ROOT/global/protocols/lifecycle.md"
SK49="$ROOT/global/skills/verify/SKILL.md"
NOTE49="$ROOT/global/hooks/context-cost-note.py"

# The region every announcement row reads, and the reason it is a region rather than the whole file. The
# obligation is a property of ONE act -- the clean-pass write -- and the document talks about phases,
# positions and sittings in several other places: the out-of-phase bullet directly above it names the
# position and the report, and `## State Files` names VERIFY while explaining the machine-read line. A
# whole-file search is satisfied by those, so it would report the obligation present before a word of it
# was written. Extracted from the bullet's own lead to the next section heading, which is the shape the
# bullet has: it is the last one in `### The phase precondition`.
CP49="$(awk '/^- \*\*A clean pass\.\*\*/{f=1} f&&/^### /{exit} f' "$BL49" 2>/dev/null)"
if [ -z "$CP49" ]; then
  # Silence is only evidence when something was there to be silent. Every row below reads this region;
  # an extractor that selected nothing would report all five obligations absent for a reason that has
  # nothing to do with whether they were written -- and would report them absent again, identically, on
  # the day the bullet is merely renamed.
  bad "the clean-pass bullet can be located in the phase precondition (nothing extracted: every announcement row below would be about an empty string)"
else
  # A1 -- WHEN the phase precondition passes and the write changes the sheet's position to VERIFY, the
  # engine shall state that the command writes the phase, writes the resume block's `next action:`,
  # announces the end of the sitting, and ends the turn before any of the phase's work. Five legs, each
  # naming the fact it lost: a row reporting only "the announcement is missing" sends the next reader to
  # re-read the whole bullet to find out which half of it went.
  a49=""
  # Re-keyed off the retired discriminator. This leg read `position it is about to overwrite`, which the
  # two-boundary rule kept -- but only in the RE-ENTRY paragraph, about a different condition entirely. So
  # the leg went on passing while the rule it was written for no longer existed, which is the failure a
  # green row hides best. It is keyed now on what carries the obligations under the rule that replaced it.
  printf '%s' "$CP49" | grep -qiE 'Two closes carry the end of the session|close of Understand and the close of Execute' \
    || a49=" [the bullet does not name the two closes as what carries the end of the sitting]"
  printf '%s' "$CP49" | grep -q 'VERIFY' \
    || a49="$a49 [it does not name VERIFY as the position that announces]"
  printf '%s' "$CP49" | grep -q 'next action:' \
    || a49="$a49 [it does not name the resume line the next sitting reads]"
  printf '%s' "$CP49" | grep -qiE 'ends the turn|end the turn|turn ends|stops there' \
    || a49="$a49 [it does not say the turn ends there]"
  printf '%s' "$CP49" | grep -qiE 'asks nothing|asking nothing|no approval|not a gate|nothing is asked' \
    || a49="$a49 [it does not say the announcement asks nothing, so it reads as a gate]"
  [ -z "$a49" ] && ok "the two closes carry all four obligations, and ask nothing" \
                || bad "the two closes carry all four obligations, and ask nothing ($a49)"

  # A2 -- WHILE the sheet already declares VERIFY, the engine shall state that nothing is announced and the
  # phase's work proceeds.
  #
  # The rule and its negation share every noun in sight: both are about VERIFY, both are about announcing,
  # both are about the same write. So neither `VERIFY` nor `announce` can discriminate, and a row keyed on
  # either passes over a bullet that says the opposite of what is wanted. What discriminates is the SECOND
  # branch existing at all -- a sentence that pairs "already" with "nothing" -- and the reason for it being
  # written down, because the loop it prevents is invisible in the prose and is reachable on the very
  # sitting the cut creates: the fresh sitting re-runs the command over a sheet that now declares VERIFY.
  b49=""
  printf '%s' "$CP49" | grep -qiE 'already declares|already at|already says|already VERIFY' \
    || b49=" [the bullet states no second branch for a sheet that already declares the position]"
  # PAIRED on one line, not two independent legs over the region -- which is what the frozen contract
  # asked for ("'already' paired with 'nothing announced'") and what an earlier form of this row did not
  # do. Read separately, the verdict leg was also satisfied by the out-of-phase sentence below ("so there
  # is no write and no announcement"), so the second branch could be INVERTED to say the announcement
  # fires again and all three legs stayed green on the other sentences. Deletion was caught; the
  # semantics-inverting mutation this row's whole comment is about was not.
  printf '%s' "$CP49" | grep -qiE 'already (declares|at|says)[^.]*(nothing is announced|no announcement|announces nothing|is silent)' \
    || b49="$b49 [the sheet-already-declares branch does not itself carry the verdict that nothing is announced]"
  printf '%s' "$CP49" | grep -qiE 'again|re-?run|re-?entry|loop|the sitting it created|the session it created' \
    || b49="$b49 [it does not say why: unguarded, the announcement fires on the sitting the cut created]"
  [ -z "$b49" ] && ok "a write over a sheet already declaring the position announces nothing, and the bullet says why" \
                || bad "a write over a sheet already declaring the position announces nothing, and the bullet says why ($b49)"

  # A3 -- IF the announcement is stated without naming the resume line the following sitting reads, THEN
  # the check shall fail. Both sides are read here so neither can move alone: the announcement points at a
  # line the sheet template must provide, and asserting only the announcement leaves the template free to
  # drop it -- the same pairing C48's A22 row makes between the note and the section it sends the operator
  # to, and for the same reason.
  c49=""
  printf '%s' "$CP49" | grep -q 'next action:' \
    || c49=" [the announcement names no resume line]"
  grep -q '^- next action:' "$BL49" \
    || c49="$c49 [the sheet template declares no next action line for it to point at]"
  [ -z "$c49" ] && ok "the announcement and the sheet template name the same resume line" \
                || bad "the announcement and the sheet template name the same resume line ($c49)"

  # A4 -- D6: the quick and auto paths are excluded by construction and SAID OUT LOUD, never by a
  # predicate. plan.md Step 1 names this paragraph as a deliberate change, and D6's stated consequence is
  # that without it a future path performing the write would announce with nobody having decided it
  # should. The habit row below carries a quick/auto leg, but it reads the lifecycle map -- so without
  # this row the paragraph can be deleted from the protocol and every row stays green. Its three legs are
  # the three facts that make the exclusion true, because "quick and auto are excluded" asserted without
  # them is the predicate the decision refused, written as prose.
  g49=""
  printf '%s' "$CP49" | grep -qiE 'quick and auto|quick or auto' \
    || g49=" [the bullet does not name the quick and auto paths as excluded]"
  printf '%s' "$CP49" | grep -qiE 'writes no sheet|no sheet at all' \
    || g49="$g49 [it does not say a quick task writes no sheet, which is why the write never occurs there]"
  printf '%s' "$CP49" | grep -qiE 'skips Verify|skips Understand' \
    || g49="$g49 [it does not say an auto task skips the phases that would reach the write]"
  [ -z "$g49" ] && ok "the bullet names the quick and auto paths as excluded by construction" \
                || bad "the bullet names the quick and auto paths as excluded by construction ($g49)"
fi

# A4 -- The engine shall state the session-cut habit in the lifecycle map and in no other installed file.
# COUNTED, not merely found, for the reason C43's home guard already gives: the whole anti-drift design is
# that a second statement cannot exist, and a check asking only whether the rule is present anywhere is
# satisfied by every copy at once. What selects a statement rather than a citation is the fact itself --
# how many sittings a full-path task is -- which a document that merely routes to the map never carries.
# Re-keyed from two sittings to three when the cut gained its second boundary: the fact this row
# counts is the one the map states, so a rule change that moves the fact moves this key with it or the row
# starts guarding a sentence nobody writes any more.
HAB49='(three|3) *(sittings|sessions)'
HOME49="$(grep -rliE "$HAB49" "$ROOT/global/" 2>/dev/null | wc -l | tr -d ' ')"
ELSE49="$(grep -rliE "$HAB49" "$ROOT/template/" "$ROOT/docs/" "$ROOT/README.md" 2>/dev/null | wc -l | tr -d ' ')"
d49=""
[ "$HOME49" -eq 1 ] || d49=" [the habit is stated in $HOME49 files under global/, not exactly one]"
grep -qiE "$HAB49" "$MAP49" 2>/dev/null || d49="$d49 [the lifecycle map does not state it]"
[ "$ELSE49" -eq 0 ] || d49="$d49 [$ELSE49 files outside global/ carry a second copy]"
grep -qiE 'quick|auto' "$MAP49" 2>/dev/null && grep -qiE 'never reach|no seal|writes no sheet|by construction' "$MAP49" 2>/dev/null \
  || d49="$d49 [it does not say the quick and auto paths never reach the cut]"
[ -z "$d49" ] && ok "the session-cut habit is stated in the lifecycle map and nowhere else" \
              || bad "the session-cut habit is stated in the lifecycle map and nowhere else ($d49)"

# A5 -- WHERE the audit skill states its clean-pass clause, the skill shall say the turn ends there and
# shall not restate the announcement's own text. Two legs pulling opposite ways on purpose: the automating
# layer must carry the ACT, because a skill that marches on to step 3 defeats a cut stated only in prose --
# and must not carry the RULE, because the engine's cost for a second copy is drift, which is what every
# "stated there and only there" clause in this skill already buys.
# Re-keyed when the cut moved to the two phase closes: the audit command is no longer a place the sitting
# ends, so the leg that required it to say so was pinning a retired behaviour -- and pinning it green, which
# is worse than not guarding it, because the removal could not ship without the suite objecting. What the
# command must carry now is the opposite act: recognise the re-entry it ordinarily lands in and carry on.
e49=""
grep -qiE 'already declares VERIFY' "$SK49" 2>/dev/null \
  || e49=" [the skill does not state the re-entry it ordinarily lands in]"
grep -qiE 'nothing is announced|announces nothing' "$SK49" 2>/dev/null \
  || e49="$e49 [it does not say that re-entry announces nothing]"
grep -qiE 'end the turn|ends the turn|the session ends there' "$SK49" 2>/dev/null \
  && e49="$e49 [it still ends the sitting at the entry to the audit, which is not one of the two closes]"
grep -q 'next action:' "$SK49" 2>/dev/null \
  && e49="$e49 [the skill restates the announcement's own obligation instead of routing to it]"
[ -z "$e49" ] && ok "the audit command re-enters without stopping, and cites the rule" \
              || bad "the audit command re-enters without stopping, and cites the rule ($e49)"

# A6 -- CONTROL. `context-cost-note.py` keeps the recommendation this task deliberately did not demote.
# Green from the start by construction: it pins a decision rather than an achievement. The ticket proposed
# demoting the note to "a stretch overran a boundary", which assumed TWO cuts and therefore short stretches;
# with one cut the pre-audit stretch legitimately runs long -- roughly three fifths of a task's turns by the
# measurements -- so that message would be false for the only long stretch there is, and a note that lies
# once is a note that stops being read. The hook stays the POINTER for a sitting that grew long before
# reaching the boundary; the protocol is the SITE. Without this row, a later reader finds the demotion in the
# ticket, does not find it in the code, and cannot tell a decision from an omission.
f49=""
grep -qi 'next phase boundary' "$NOTE49" 2>/dev/null \
  || f49=" [the note no longer recommends a cut at the next phase boundary]"
grep -qiE 'overran|over-?ran' "$NOTE49" 2>/dev/null \
  && f49="$f49 [the note was demoted to reporting an overrun, which this task decided against]"
[ -z "$f49" ] && ok "control: the note keeps its recommendation and was not demoted" \
              || bad "control: the note keeps its recommendation and was not demoted ($f49)"
