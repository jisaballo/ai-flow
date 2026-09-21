# =====================================================================================================
# C100 -- the gate order has one voice, and the two citers do not repeat it
#
# Appended at the Replan Gate opened by T-157's own Verify (a HIGH, adversarially confirmed, finding):
# the fact this task fixes -- where the plan's approval gate sits relative to Conform -- had a second
# actor (a future editor of any one of three files) and an oracle (cross-file comparison) and was left
# `observed: read` with no stub. This is that stub.
#
# BUILT ON ITS OWN FILE SET, NOT AN EXTENSION OF SET43/C63's A2. IB-025 records that those sweeps cannot
# see the phase skills, and one of this fact's three homes IS a phase skill (`skills/plan/SKILL.md`).
# Extending either would certify this fix while the one copy it was written against sat untouched --
# the exact blind spot C68 hit first and answered the same way: its own three-file set, named here.
#
# WHY THIS SECTION IS ALLOWED TO READ PROSE, STATED HERE SO A FUTURE READER DOES NOT HAVE TO GUESS IT.
# `test/tools/recurrence-register.py` (C98) refuses a new verdict site whose evidence is a pattern read
# against this engine's own `.md` prose, because ordinarily that pattern and the sentence it reads are
# written by the same actor in the same change -- so what it detects is that the prose changed, never
# that the rule is wrong. C98's own header declares the one case it will not mechanize: "A site reading
# engine SOURCE as text is admissible where that source is the only and complete statement of the fact
# -- a judgement, not a shape." And it says why there is no allow-list to satisfy instead: "widening
# costs precision, precision costs false refusals, false refusals demand an escape hatch, and an escape
# hatch is the silence readmitted through the front door." THIS is that case, by that judgement: T-157's
# whole subject is prose consistency across three documents, and there is no other implementation
# behaviour to check the fact against -- the prose is the only and complete statement of it.
#
# A judgement is not a claim taken on its own word, so it was proven by mutation against every row's own
# subject before this section was accepted, and the manifest at `artifacts/T-157/conformance-baseline/`
# carries all four runs:
#   - Run 1: `lifecycle.md:222`'s Guided bullet reverted to its pre-T-157 wording, `plan.md`/`SKILL.md`
#     left as this task wrote them -> A1 and A2 reddened, each naming the exact side that had flipped;
#     restored, back to green.
#   - Run 2: `SKILL.md`'s step 6 reverted to its pre-repair restatement, `lifecycle.md` left untouched ->
#     A4 reddened, naming the restatement; restored, back to green.
#   - Run 3: `plan.md`'s citation clause stripped from its scoping sentence, `lifecycle.md`/`SKILL.md`
#     left untouched -> A3 reddened, naming the missing citation; restored, back to green.
#   - Run 4 (a Verify repair leg, added after the review confirmed a HIGH against A4 on the diff this
#     header first shipped with): `SKILL.md` step 5's disclosure sentence deleted alone, its opening
#     parenthetical left untouched -> A5 reddened, naming the missing disclosure, while A4 correctly
#     stayed green (the citation itself was untouched); restored, back to green. A4 alone was fooled by
#     the parenthetical's own word "discloses", exactly as a bare `grep -qi disclos` would be -- A5 keys
#     on the sentence `disclose the frozen stubs ... to the operator` as one clause (`insent`), which the
#     parenthetical does not carry, so a fragment surviving is not enough to pass it.
# Four runs, not one, because the fact has four subjects that can each break on their own -- the wrong
# file could state the order, a citer could restate it, a citer could drop the citation and state
# nothing, or a citer could keep its citation while dropping the obligation the citation was covering for
# -- and a falsifier proven against one subject says nothing about the other three.
#
# REJECTED, on the record: reshaping A1/A2/A3 to read as `run` (wrap the same grep in a helper script) or
# as `resolve` (a decoy `[ -f ... ]` or `git cat-file` alongside the grep) so C98's classifier passes them
# uninspected. Either would satisfy the pattern-matcher while adding nothing C98 actually cares about --
# the exact escape hatch its header names and refuses to offer. Not done here, on purpose.
#
# NOTED IN PASSING, not this task's to fix: A4 and A5 both read `SKILL.md` as text and neither is refused
# by C98 -- its own subject resolver does not recognise `global/skills/*/SKILL.md` as one of this engine's
# own documents, the identical blind spot `IB-025` records against `SET43`/`C63`'s A2 sweep, now shared by
# a guard built after both. Worth a sighting, not a fix here: C98's own reach is not this section's ground.
#
# WHAT C98 THEREFORE PRINTS, EXACTLY, UNTIL THIS BRANCH PUBLISHES -- stated in the tool's own terms, since
# a criterion naming row labels the tool never prints cannot be checked by whoever is holding its output:
#
#   REFUSE C100:129 md reads global/protocols/lifecycle.md -- a1 the guided bullet ...
#   REFUSE C100:142 md reads global/protocols/lifecycle.md -- a2 conform's close is stated as ...
#   REFUSE C100:167 md reads global/protocols/lifecycle.md,global/protocols/plan.md -- a3 plan.md cites ...
#
# Three sites, no fourth, none naming a different row's own `-- a1/a2/a3 ...` suffix -- that suffix, not
# the file list, is what tells the three apart: A1 and A2 both read as `global/protocols/lifecycle.md`
# alone, since both extract from the same Guided-bullet region, and a reader distinguishing them by file
# would see no difference at all. A3's line names BOTH `lifecycle.md` and `plan.md` because A3's own
# region reads both (the citation check spans the two), which is the classifier reporting what a region
# resolves, never a summary of what the row is about. A4 and A5 read prose too (see above) but resolve to
# `SKILL.md`, which this guard does not see -- so three, not five, is the count this guard can ever print
# against this file as it stands today. A fourth site, one naming only `plan.md` alone, or one of these
# three losing a file from its list, is the change to watch for. Line numbers drift with any edit to this
# header; re-run the tool to reconfirm before citing them as current. On merge C100 is inherited exactly
# as C43/C63/C68/C96 were, and C98 stops seeing it -- proven at the coordinator before the trunk publishes,
# not assumed here.
LC100="$ROOT/global/protocols/lifecycle.md"
PL100="$ROOT/global/protocols/plan.md"
SK100="$ROOT/global/skills/plan/SKILL.md"

# Every row below is built to fail with THE FACT THAT WAS LOST named -- which side of the gate is
# automatic, which side discloses, which file states either in its own words -- never with "the text
# changed". None of them greps for this task's own prose; all of them key on the STRUCTURE the three
# files must carry: an arrow-separated transition list in lifecycle.md, and an absence of that same
# vocabulary everywhere else.

echo ""
echo "== C100: the gate order has one voice, and the two citers do not repeat it =="

# E0 -- every region this block reads extracts, before any verdict is read over it.
GB100="$(grep -m1 '^- \*\*Guided\*\*:' "$LC100" 2>/dev/null)"
PC100="$(printf '%s' "$GB100" | grep -oE 'plan → conform \([^)]*\)')"
CE100="$(printf '%s' "$GB100" | grep -oE 'conform → execute \([^)]*\)')"
SKTXT100="$(cat "$SK100" 2>/dev/null)"
STEP5_100="$(nitem 5 "$SKTXT100")"
STEP6_100="$(nitem 6 "$SKTXT100")"
CTSECT100="$(msect "$PL100" '^## Conformance Tests')"
PLSENT100="$(printf '%s' "$CTSECT100" | grep -m1 'the plan is approved')"

e0_100=""
[ -f "$LC100" ] || e0_100="$e0_100 [lifecycle.md is not on disk]"
[ -f "$PL100" ] || e0_100="$e0_100 [plan.md is not on disk]"
[ -f "$SK100" ] || e0_100="$e0_100 [the plan skill is not on disk]"
[ -n "$GB100" ] || e0_100="$e0_100 [the Guided gate bullet did not extract]"
[ -n "$PC100" ] || e0_100="$e0_100 [the plan → conform transition did not extract from the Guided bullet]"
[ -n "$CE100" ] || e0_100="$e0_100 [the conform → execute transition did not extract from the Guided bullet]"
[ -n "$STEP5_100" ] || e0_100="$e0_100 [SKILL.md step 5 did not extract]"
[ -n "$STEP6_100" ] || e0_100="$e0_100 [SKILL.md step 6 did not extract]"
[ -n "$PLSENT100" ] || e0_100="$e0_100 [plan.md's Conformance Tests scoping sentence did not extract]"
[ -z "$e0_100" ] && ok "E0 every region C100 reads extracts" || bad "E0 every region C100 reads extracts ($e0_100)"

# A1 -- criterion 1: the order itself, read structurally off the arrow-separated transition list rather
# than off any sentence this task wrote. `compute`-shaped: two derived extractions (which parenthetical
# sits on which transition) are compared against each other, never against a copy of the prose.
#
# THE FALSIFIER, run and recorded: reverting this bullet to its pre-T-157 wording --
# "plan → conform (automatic), conform → execute (user approves the plan)" -- was applied to a scratch
# copy and this row was confirmed to redden and name the reversed side; the manifest carries the run.
a1_100=""
if [ -n "$PC100" ] && [ -n "$CE100" ]; then
  printf '%s' "$PC100" | grep -qi 'approv' || a1_100="$a1_100 [plan → conform does not read as user-approved]"
  printf '%s' "$PC100" | grep -qi 'automatic' && a1_100="$a1_100 [plan → conform reads as automatic, the reverse of D1's ruling]"
  printf '%s' "$CE100" | grep -qi 'automatic' || a1_100="$a1_100 [conform → execute does not read as automatic]"
  printf '%s' "$CE100" | grep -qi 'approv' && a1_100="$a1_100 [conform → execute reads as requiring approval, the reverse of D1's ruling]"
else
  a1_100=" [one or both transitions did not extract -- see E0]"
fi
[ -z "$a1_100" ] \
  && ok "A1 the Guided bullet puts the operator's approval on plan → conform, not on conform → execute" \
  || bad "A1 the Guided bullet puts the operator's approval on plan → conform, not on conform → execute ($a1_100)"

# A2 -- criterion 4: Conform's close is a disclosure, never a second gate, read off the same segment.
a2_100=""
if [ -n "$CE100" ]; then
  printf '%s' "$CE100" | grep -qi 'disclos' || a2_100="$a2_100 [conform → execute does not name a disclosure to the operator]"
  printf '%s' "$CE100" | grep -qiE 'not a second|never a second|no second' \
    || a2_100="$a2_100 [conform → execute does not deny that the disclosure is a second gate]"
else
  a2_100=" [conform → execute did not extract -- see E0]"
fi
[ -z "$a2_100" ] \
  && ok "A2 Conform's close is stated as a disclosure and denies being a second approval gate" \
  || bad "A2 Conform's close is stated as a disclosure and denies being a second approval gate ($a2_100)"

# Shared by A3 and A4: does BODY cite lifecycle.md > Autonomy Levels without restating which side is
# automatic? One home for the identical question asked of two different citers, folded in as a Verify
# repair (the review's own MEDIUM finding: A3 and A4 duplicated this verbatim instead of sharing it).
citecheck100() {  # $1 = label, $2 = body -> prints accumulated issues, empty if clean
  local lbl="$1" body="$2" issues=""
  printf '%s' "$body" | grep -qi 'automatic' \
    && issues="$issues [$lbl restates which side is automatic instead of citing lifecycle.md for it]"
  printf '%s' "$body" | grep -qF 'protocols/lifecycle.md' \
    || issues="$issues [$lbl does not cite protocols/lifecycle.md]"
  printf '%s' "$body" | grep -qi 'Autonomy Levels' \
    || issues="$issues [$lbl does not cite the Autonomy Levels section]"
  printf '%s' "$issues"
}

# A3 -- criterion 3, plan.md's half: the scoping sentence may keep its own scope (D1's Decision Register,
# Step 3's "correction" -- this sentence was the right side of the original contradiction and the ruling
# vindicated it) but may not independently restate WHICH side is automatic, and must point at the one
# home for that fact. `resolve`-shaped: the cited heading must exist, not merely be typed.
a3_100="$(citecheck100 "plan.md's scoping sentence" "$PLSENT100")"
grep -qxF '## Autonomy Levels' "$LC100" 2>/dev/null \
  || a3_100="$a3_100 [protocols/lifecycle.md carries no ## Autonomy Levels heading for the citation to resolve to]"
[ -z "$a3_100" ] \
  && ok "A3 plan.md cites lifecycle.md > Autonomy Levels for the order instead of restating it" \
  || bad "A3 plan.md cites lifecycle.md > Autonomy Levels for the order instead of restating it ($a3_100)"

# A4 -- criteria 2 and 3, SKILL.md's half. Criterion 2 (the skill's own steps must not assign two
# different orders) is SUBSUMED here rather than checked by comparing the two steps to each other: a
# step forbidden from stating the order at all cannot disagree with its sibling about what the order is.
# Reintroducing the disagreement this task fixed requires reintroducing a restatement first, and this row
# catches that the moment it lands in either step, before a second step exists to disagree with it.
a4_100=""
for label100 in "step 5:$STEP5_100" "step 6:$STEP6_100"; do
  nm100="${label100%%:*}"; body100="${label100#*:}"
  [ -n "$body100" ] || { a4_100="$a4_100 [SKILL.md $nm100 did not extract]"; continue; }
  a4_100="$a4_100$(citecheck100 "SKILL.md $nm100" "$body100")"
done
[ -z "$a4_100" ] \
  && ok "A4 SKILL.md's steps 5 and 6 cite lifecycle.md > Autonomy Levels and neither restates the order" \
  || bad "A4 SKILL.md's steps 5 and 6 cite lifecycle.md > Autonomy Levels and neither restates the order ($a4_100)"

# A5 -- criterion 4, SKILL.md's own half, repaired: A4 above is satisfied by step 5's opening parenthetical
# alone ("what this step discloses are ... cited and not restated here"), so deleting the actual disclosure
# obligation left every row in the suite green -- the review's confirmed HIGH finding. A grep for `disclos`
# alone repeats the same mistake, since the parenthetical's own word "discloses" would still satisfy it;
# this keys on the specific sentence that carries the obligation, in one clause, so a fragment surviving
# is not enough.
a5_100=""
if [ -n "$STEP5_100" ]; then
  [ "$(insent "$STEP5_100" 'disclose the frozen stubs' 'to the operator')" = "1" ] \
    || a5_100="$a5_100 [SKILL.md step 5 does not carry the disclosure obligation sentence itself]"
else
  a5_100=" [SKILL.md step 5 did not extract -- see E0]"
fi
[ -z "$a5_100" ] \
  && ok "A5 SKILL.md step 5 carries the disclosure obligation itself, not just a citation for it" \
  || bad "A5 SKILL.md step 5 carries the disclosure obligation itself, not just a citation for it ($a5_100)"
