echo "== C72: the rulebook states its rules, and each hard stop names what stops you =="

EX72="$ROOT/global/protocols/execute.md"
MN72="$ROOT/global/CLAUDE.md"

# The two tier rules' OWN CONTENT, never the tier names and never the heading parentheticals. Measured
# against the pre-change manual before this list was frozen: each of the 15 hits the tiers block exactly
# once and the rest of the manual zero times. `do without asking` and `need user approval` were candidates
# and were DROPPED -- they are the two sub-heading parentheticals, which is to say they are the words a
# correct route would reuse, and a leg that fails on a document doing the right thing is a leg that gets
# deleted rather than obeyed.
#
# The residual is named because a marker cannot see a paraphrase: a tier rule reworded in fresh words
# evades every phrase below. That is the known ceiling of home counting by marker, not a gap this block
# can close, and it is why A4 asserts a POSITIVE home as well as the absence.
TIER72='broken imports|null pointers|type mismatches|missing deps|build config|auto-fix test'
TIER72="$TIER72"'|library additions|new services|schema changes|null checks|impossible scenarios'
TIER72="$TIER72"'|state shape|new patterns|architectural decisions|files not in the plan'

# TWO SETS, and the split is load-bearing. The NEGATIVES keep all 15: a document that grows back any tier
# sentence must redden, including the one the deviation section no longer states itself. The POSITIVE
# counts only what that section is supposed to carry -- 14, because the test-discipline bullet was retired
# in favour of a route to the loop that owns it (`### Execute Step Protocol` item 3), and a positive
# demanding a phrase the correct document deliberately lacks is red on a correct document.
TIERPOS72='broken imports|null pointers|type mismatches|missing deps|build config'
TIERPOS72="$TIERPOS72"'|library additions|new services|schema changes|null checks|impossible scenarios'
TIERPOS72="$TIERPOS72"'|state shape|new patterns|architectural decisions|files not in the plan'

# The hard stops' OWN CONTENT, for the mirror negative below. Measured against the post-change rulebook
# before this list was frozen: all nine hit zero there, and each hits the manual's `### Never` list.
# `force[ -]push` is kept even though the manual no longer says it -- the leg's job is to catch the OLD
# wording coming back into the wrong file, and the retired form is exactly what a reverting editor pastes.
STOP72='publish without|skip or disable|commit secrets|delete user data|drop tables|drop collections'
STOP72="$STOP72"'|published trunk|overwrite existing artifacts|force[ -]push'

# Its own extractor, stopping only at the next SAME-LEVEL heading. `msect` exits on any `^#+ `, and the
# two tiers arrive as `###` sub-headings of this section -- measured, on a copy carrying the finished text:
# msect truncated the region to the section's intro line and this row went RED on a correct document.
DEV72="$(awk '/^## Deviation Rules During Execution/{f=1;next} f&&/^## /{exit} f' "$EX72" | tr -s ' \n' '  ')"
EXALL72="$(tr -s ' \n' '  ' < "$EX72")"
W72="$(wc -w < "$EX72" | tr -d ' ')"

# E0 -- every region this block reads on the RULEBOOK side extracts. A row that is green over an empty
# string is a row about nothing. The manual side needs no guard here: its five facts are manfact
# predicates below, and each returns 1 when its own region fails to extract.
e0_72=""
[ -f "$EX72" ] || e0_72="$e0_72 [the execute protocol is not on disk]"
[ -f "$MN72" ] || e0_72="$e0_72 [the manual is not on disk]"
[ -n "$DEV72" ] || e0_72="$e0_72 [the rulebook's deviation section did not extract]"
[ -n "$EXALL72" ] || e0_72="$e0_72 [the rulebook read as empty]"
[ "${W72:-0}" -gt 0 ] || e0_72="$e0_72 [the execute protocol counted zero words]"
[ -z "$e0_72" ] && ok "E0 every region C72 reads extracts" || bad "E0 every region C72 reads extracts ($e0_72)"

# A1 -- the rulebook is within its frozen word budget.
#
# WORDS, not lines: re-wrapping the same words must not move the number, and retired prose restored as
# unwrapped lines must not slip under it. Same metric and same reason as C68's own budget row.
#
# THE NUMBER IS DERIVED FROM THE DELIVERED FILE, and the derivation was corrected at Verify after a
# mutation showed the first one hollow. The rule the criterion states is that the slack must sit BELOW THE
# SMALLEST REGION THIS TASK REMOVED, so no single removed region can return with this row green. The first
# freeze read that rule against the ten regions' GROSS sizes (66 was called the smallest) and against a
# PROJECTED floor of 2,003. Both were wrong. What governs whether a region can return is the NET prose a
# restoration adds, and three sections were pruned by less than the slack: Steering Files by 12 words,
# Post-Execute Spec Sync by 19, Skills per Step by 30. The prover restored three of them -- 28 words --
# and the whole suite stayed at 996 passed, 0 failed.
#
# So the floor is measured, not projected, and the slack is 11 -- below the true smallest removed region
# of 12. The file is deliberately close to pinned: this rulebook is finished, and a task that needs to add
# prose to it re-derives this number in the open rather than spending slack nobody sized.
#
# RE-DERIVED ONCE, and this is that re-derivation in the open. The rulebook's approval tier gained the
# structural-context change, which is prose it did not have and which the slack could not cover: the
# bullet is 38 words against 10 left. The floor is re-measured on the delivered file at 2,085 and the
# slack stays 11, so the budget is 2,096. The invariant the number exists for is unchanged and still
# holds: the smallest region the freezing task removed is 12 words, and 2,085 + 12 exceeds 2,096, so no
# single removed region can return with this row green. What moved is the floor, never the rule -- and
# the bullet was cut to its minimum BEFORE the number was touched, which is the order that keeps a budget
# from becoming a formality.
a1_72=""
[ "${W72:-0}" -le 2096 ] || a1_72="$a1_72 [the rulebook is $W72 words, over the 2096-word budget]"
[ -z "$a1_72" ] && ok "A1 the Execute protocol is within its frozen word budget" \
                || bad "A1 the Execute protocol is within its frozen word budget ($a1_72)"

# A2 -- each hard stop that has a mechanism elsewhere names it IN ITS OWN BULLET. One variable per stop,
# never one grep over the whole list: a single sweep is green while one bullet carries every name and the
# other four carry none, which is the shape a routed list decays into first.
#
# THROUGH manfact, like every other fact this suite asserts about the manual, and that is a repair rather
# than a style choice. Nothing distributes CLAUDE.md -- the installer writes it only when absent -- so a
# leg reading the shipped copy alone goes green while the manual actually loaded on every turn says the
# opposite. Measured at the Verify that added this: the live twin still carried both retired tiers and the
# retired `type(scope)` bullet, with A3 and A5 green. manfact judges both copies and its failure names the
# hand-merge, which is the only remedy this file has.
mf72_stops() {
  local m
  # Two selectors are chosen to be INDEPENDENT OF WHAT THEY ASSERT, and the reason was measured. Selecting
  # the trunk stop on `push` read the very string the leg exists to find: the only `push` in a correct
  # bullet is inside `pre-push`, so a bullet that lost its mechanism stopped being selectable, `mbul`
  # retargeted, and A2 reported "names no mechanism" while A2b reported the bullet as absent -- one edit
  # reddening two rows for a reason neither stated. Each now selects on the stop's own SUBJECT, which no
  # repair to the mechanism can move.
  for pair72 in "validation:closing ceremony|move 1|backlog" "tests:verify|audit" "secrets:pre-commit|commit guard" \
                "trunk:pre-push|push guard" "Overwrite:artifact-write-guard"; do
    m="$(mbul "$1" '^### Never [(]hard stops[)]' "${pair72%%:*}")"
    [ -n "$m" ] || return 1
    printf '%s' "$m" | grep -qiE "${pair72#*:}" || return 1
  done
  return 0
}
manfact mf72_stops "A2 each hard stop with an owner names the mechanism that performs it"

# A2b (free) -- the force-push stop names NO BRANCH. Costs one line and closes what A2 above cannot see:
# a bullet routing to the push guard while still saying `main` satisfies A2 and states a trunk the guard
# now deliberately lets through in a `develop` repository.
mf72_nobranch() {
  local b; b="$(mbul "$1" '^### Never [(]hard stops[)]' 'trunk')"
  [ -n "$b" ] || return 1
  printf '%s' "$b" | grep -qiE '\bmain\b|\bmaster\b' && return 1
  return 0
}
manfact mf72_nobranch "A2b the force-push stop names no branch"

# A3 -- the manual states no execution-time tier rule ANYWHERE. File-wide and not section-scoped: that
# reach is IB-032's third remedy, and a section-scoped negative is green the day a tier rule reappears
# four headings away, which is how two of the manual's commit facts came to sit outside the section that
# claims to route them.
mf72_notier() {
  tr -s ' \n' '  ' < "$1" | grep -qiE "$TIER72" && return 1
  return 0
}
manfact mf72_notier "A3 the manual states no Always- or Ask-First-tier rule anywhere in the file"

# A3b -- the manual's Action Boundaries section ROUTES to the tiers' new home. The absence legs above
# cannot see this half, and without it the section can be deleted outright, or left as a heading standing
# over nothing, with every other row in this block green -- while `docs/getting-started.md` still tells an
# adopter to merge it. A relocation has two halves and only one of them was guarded.
mf72_route() {
  local s; s="$(msect "$1" '^## Action Boundaries' | tr -s ' \n' '  ')"
  [ -n "$s" ] || return 1
  printf '%s' "$s" | grep -qi 'execute.md'                  || return 1
  printf '%s' "$s" | grep -qi 'Deviation Rules'             || return 1
  return 0
}
manfact mf72_route "A3b the manual routes the two tiers to the phase that states them"

# A4 -- the rulebook's deviation section is the tiers' ONE home. A positive and a negative, and both are
# needed: the negative alone is satisfied by a set in which nobody states the rules at all.
#
# The swept set names `global/skills/` BY NAME (IB-025), and it is walked with -print0 because a checkout
# path containing a space otherwise splits every entry into fragments that all fail the -f guard, leaving
# the sweep green having read nothing. `seen72` is what tells those two apart.
a4_72=""
# The positive COUNTS the tiers' own phrases and requires ALL FOURTEEN. It was frozen at 13 of 15 to leave
# room "for a word changing in the move"; the move is finished, and measured after it the section carried
# every phrase it is supposed to carry. Slack in a positive over a finished document buys nothing but
# DELETION TOLERANCE, and this section is now the engine's only copy of these rules -- at 13 of 15, two
# approval boundaries could leave their sole home with the whole suite green.
n4_72="$(printf '%s' "$DEV72" | grep -oiE "$TIERPOS72" | tr 'A-Z' 'a-z' | sort -u | wc -l | tr -d ' ')"
[ "${n4_72:-0}" -ge 14 ] \
  || a4_72="$a4_72 [the deviation section states only $n4_72 of the tiers' 14 rules, so it does not state them whole]"
# Both sub-headings, asserted because nothing else does: the count above survives a section that has
# merged the two tiers into one undifferentiated list, which loses the distinction the tiers ARE.
printf '%s' "$DEV72" | grep -qi '### Always'    || a4_72="$a4_72 [the Always tier has no heading]"
printf '%s' "$DEV72" | grep -qi '### Ask First' || a4_72="$a4_72 [the Ask First tier has no heading]"
#
# TWO REGIONS ARE EXEMPT BY NAME, and each is a document doing the right thing rather than a concession.
# Measured on the pre-change tree, before this leg was frozen: the sweep reddened on
# `lifecycle.md` > `## Autonomy Levels`, whose Supervised row states which tasks EARN that level -- the map
# is the declared home of the levels and the row is not a tier rule -- and on the preamble of
# `quick-path.md`, whose `No new services/components/modules` is a prohibition on quick tasks rather than
# an Ask First rule. The marker cannot tell either apart from the thing it hunts, so the exemption is cut
# to the REGION and never to the file: a real tier rule elsewhere in either document is still caught.
strip72() {
  case "$1" in
    */protocols/lifecycle.md)
      awk '/^## Autonomy Levels/{f=1} f&&/^## /&&!/^## Autonomy Levels/{f=0} !f' "$1" ;;
    */protocols/quick-path.md)
      awk '/^## /{f=1} f' "$1" ;;
    *) cat "$1" ;;
  esac
}
seen72=0; homes72=""
while IFS= read -r -d '' f72; do
  case "$f72" in *"/global/protocols/execute.md") continue ;; esac
  seen72=$((seen72+1))
  strip72 "$f72" | grep -qiE "$TIER72" && homes72="$homes72 ${f72#"$ROOT"/}"
done < <(find "$ROOT/global" "$ROOT/template" "$ROOT/docs" -name '*.md' -print0 2>/dev/null)
# The floor is what separates a sweep that found nothing from a sweep that READ nothing, and it is set
# from the measured corpus rather than from a round number: this tree yields 25, so the old floor of 10
# would have stayed silent through fifteen documents vanishing from the walk.
[ "$seen72" -ge 20 ] || a4_72="$a4_72 [the home sweep read only $seen72 documents, so its silence proves nothing]"
[ -n "$homes72" ] && a4_72="$a4_72 [a second home states a tier rule:$homes72]"
[ -z "$a4_72" ] && ok "A4 the deviation section states both tiers and is their only home" \
                || bad "A4 the deviation section states both tiers and is their only home ($a4_72)"

# A4b -- THE MIRROR, and it is the half the contract promised and the first build did not deliver. A4's
# sweep skips `execute.md` by name, so nothing in this suite reads the rulebook for a HARD STOP: proven at
# Verify by pasting a `### Never` heading with three stops into the deviation section, after which the
# whole suite still reported 996 passed, 0 failed. The relocation runs both ways -- if either home grows a
# copy of the other's rule, the run has to say so -- and this is the other way.
a4b_72=""
printf '%s' "$EXALL72" | grep -qiE "$STOP72" \
  && a4b_72=" [the rulebook states a hard stop: $(printf '%s' "$EXALL72" | grep -oiE "$STOP72" | sort -u | tr '\n' ' ')]"
grep -qE '^### Never' "$EX72" && a4b_72="$a4b_72 [the rulebook has grown a Never heading]"
[ -z "$a4b_72" ] && ok "A4b the rulebook states no hard stop, so neither home carries the other's rules" \
                 || bad "A4b the rulebook states no hard stop, so neither home carries the other's rules ($a4b_72)"

# A5 -- the atomic commit format appears nowhere in the manual. File-wide with NO section exception, which
# is stronger than the criterion asked for and is what the measurement licensed: `type(scope)` occurs once
# in the whole file, at the stray bullet this task deletes, and the Commit Protocol section states the
# fact by ROUTE ("the atomic format ... protocols/execute.md") rather than by form. That is also why the
# pattern is bound: a bare `atomic` reddens on the route the section legitimately carries.
mf72_nocommitfmt() {
  tr -s ' \n' '  ' < "$1" | grep -qiE 'type\(scope\)|atomic commit' && return 1
  return 0
}
manfact mf72_nocommitfmt "A5 the manual states the atomic commit format nowhere"

# A6 -- the one stop with no mechanism anywhere else is stated in the manual AND SAYS SO. The second half
# is the whole point: a list that routes five stops and silently keeps the sixth is indistinguishable from
# a list with a hole in it, and the reader has no way to learn which. Sentence-scoped, so the claim binds
# to the stop rather than floating anywhere in the section, and with $S71 rather than a literal space --
# insent flattens the newline to one space but the next line's indent survives it.
mf72_noowner() {
  local n; n="$(msect "$1" '^### Never [(]hard stops[)]' | tr -s ' \n' '  ')"
  [ -n "$n" ] || return 1
  [ "$(insent "$n" 'user data|drop tables|drop collections' "no${S71}mechanism|nothing${S71}else|no${S71}other${S71}home|stated${S71}here")" = 1 ] \
    || return 1
  return 0
}
manfact mf72_noowner "A6 the stop with no owner is stated in the manual and says why it is"

# A7 -- the two DISTRIBUTED pointers name the tiers' new home and state no rule of their own. The second
# half rides A4's sweep, which reads both files; this is the first half, and without it either pointer can
# be reverted to the sentence it replaced with every other row green. These two are protocols, so they are
# asserted directly: unlike the manual, the installer overwrites them and there is no twin to port to.
#
# EACH SURFACE IS SELECTED BY ITS OWN ANCHOR, and that is the correction rather than a complication. Both
# are now prose inside a section -- the lifecycle pointer was a BULLET inside `### 7. EXECUTE` until that
# section became a citation -- but the anchors differ and neither is `Action Boundaries`: a section grep
# for that heading finds nothing, because there is none in either file. What was measured RED on a correct
# document, and is the reason the two are not merged into one loop, was a LINE grep: it found the verify
# heading and the sentence it introduces on different lines.
a7_72=""
l7a="$(msect "$ROOT/global/protocols/lifecycle.md" '^### 7[.] EXECUTE' | tr -s ' \n' '  ')"
if [ -z "$l7a" ]; then a7_72="$a7_72 [lifecycle.md's EXECUTE section did not extract]"
else printf '%s' "$l7a" | grep -qi 'Deviation Rules' \
       || a7_72="$a7_72 [lifecycle.md does not point at the tiers' home]"; fi
l7b="$(msect "$ROOT/global/protocols/verify.md" '^## Skills Feedback' | tr -s ' \n' '  ')"
if [ -z "$l7b" ]; then a7_72="$a7_72 [verify.md's Skills Feedback section did not extract]"
else printf '%s' "$l7b" | grep -qi 'Deviation Rules' \
       || a7_72="$a7_72 [verify.md does not point at the tiers' home]"; fi
[ -z "$a7_72" ] && ok "A7 the distributed pointers name the tiers' home" \
                || bad "A7 the distributed pointers name the tiers' home ($a7_72)"
