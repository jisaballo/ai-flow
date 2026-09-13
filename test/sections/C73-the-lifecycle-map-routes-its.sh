echo "== C73: the lifecycle map routes its execution rules and states neither ceiling =="
# Generated in the Conform phase from understand.md's Verifiable Criteria. The change this block guards is
# a DELETION -- 19 lines out of the map and the numbers out of three more -- and a deletion is the one
# change a green run cannot vouch for. So every leg below was sized by its own mutation against a COPY of
# the files it reads before it was trusted. A4 is the leg to distrust: it asserts over prose this task
# never edits, so it is green from the moment it is written and the suite will never fail it, hollow or
# not -- its six mutations are recorded in the task's conformance manifest, which is the only evidence
# it works.
#
# EVERY LEG GUARDS ITS OWN REGION and none of them leans on E0 for that. A negative asked of an empty
# region answers "clean", so an extractor that stopped matching would have turned A2, A3 and A5 green for
# reading nothing -- measured, all three, by renaming the section heading against a copy. E0 is the
# aggregate report and not the thing that keeps the others honest.
#
# S73 is this block's own. C71 assigns S71 inside its own block, and a block that borrowed it would break
# the day an edit above moved either one -- a staleness trap this suite has already paid for once.
S73='[[:space:]]+'
LCM73="$ROOT/global/protocols/lifecycle.md"
# `[[:space:]]*` and never `${S73}?`: a `?` applied to a `+` is two duplication symbols in a row,
# which POSIX leaves undefined -- one grep reads it as `*`, another as `+`, a third may refuse the
# pattern outright, and a refused pattern exits 2, which a bare `&&` reads as "no match" (IB-023).
# `*` is what the leg means and is defined everywhere. Measured under the grep this suite resolves
# to: `${S73}?` required the space and let `3attempts` through.
RETRY73="[0-9]+[[:space:]]*(attempts?|failures?|retries|tries)"

# --- the regions, each cut to its own subject before it is read --------------------------------------
SECT73="$(msect "$LCM73" '^### 7[.] EXECUTE')"
# The route paragraph, selected by SHAPE and never by position: the block inside the section that names
# the rulebook and does not open with a list marker. Position would have keyed this on "the last
# paragraph", which the first note appended after the route silently moves. Before the prune the section
# has no such block -- both its `execute.md` mentions sit inside lists -- which is why A3 opens red.
P73="$(printf '%s\n' "$SECT73" | awk '
  function flush(){ if (blk != "" && first !~ /^[[:space:]]*([-*+]|[0-9]+[.)])/ && blk ~ /execute\.md/) print blk; blk=""; first="" }
  /^[[:space:]]*$/ { flush(); next }
  { if (blk == "") first = $0; blk = (blk == "" ? $0 : blk " " $0) }
  END { flush() }')"
# The Auto block, and inside it the SET of constraint bullets -- never one variable per bullet keyed on
# the fact that bullet states. Keyed that way, a bullet that lost its fact would stop extracting and the
# leg asserting the fact could never fire: the run reports "did not extract" for a bullet that is sitting
# right there, and the assertion that would have named the real defect is dead code. Measured against a
# copy, both ways round.
# The anchor carries NO backslash escape: `msect` hands it to `awk -v`, which strips a single
# backslash before the regex is compiled, so `^\*\*Auto` compiles as `^**Auto` -- a duplication
# symbol with no operand, undefined in POSIX and refused by some awks. Two dots need no escaping and
# key on the same words, so renaming the heading still reddens E0, A5 and A6.
AUTO73="$(msect "$LCM73" '^..Auto level constraints:')"
AS73="$(printf '%s\n' "$AUTO73" | grep -iE "^-${S73}Still${S73}respects")"
# The two surviving prose homes, and the mechanism they must agree with.
DG73="$(awk '/^## Diff Size Guardrail/{f=1;next} f && /^## /{exit} f' "$ROOT/global/protocols/execute.md" 2>/dev/null)"
# The README row is selected by the hook's own filename and never read whole: `150` appears again four
# rows below, where it means 150 TURNS in the session-cost note and is correct.
RD73="$(grep -F 'diff-size-guard.py' "$ROOT/global/hooks/README.md" 2>/dev/null)"
ST73="$(grep -E '^STEP_THRESHOLD[[:space:]]*=' "$HK/diff-size-guard.py" 2>/dev/null | grep -oE '[0-9]+' | head -1)"
TT73="$(grep -E '^TASK_THRESHOLD[[:space:]]*=' "$HK/diff-size-guard.py" 2>/dev/null | grep -oE '[0-9]+' | head -1)"

# E0 -- the aggregate report, so a run naming one region says so once rather than through five rows.
e0_73=""
[ -n "$SECT73" ] || e0_73="$e0_73 [the map's EXECUTE section did not extract -- heading renamed?]"
[ -n "$P73" ]    || e0_73="$e0_73 [the map's route paragraph did not extract -- still a list, or it names no rulebook]"
# ONE home, counted. The extractor prints every qualifying block, and A3's facts are then read over the
# concatenation -- five facts satisfiable across two paragraphs while no single one routes. That is the
# defect C69's comment two blocks up was written for, and it arrives with the next edit to the section,
# not today: `**Input**`/`**Output**` names understand.md and is one word from qualifying.
[ -z "$P73" ] || [ "$(printf '%s\n' "$P73" | grep -c .)" = 1 ] \
                 || e0_73="$e0_73 [the section holds more than one route paragraph -- A3 would read their concatenation]"
[ -n "$AUTO73" ] || e0_73="$e0_73 [the Auto level's constraint block did not extract]"
[ -n "$AS73" ]   || e0_73="$e0_73 [the Auto block states no constraint at all]"
[ -n "$DG73" ]   || e0_73="$e0_73 [execute.md's Diff Size Guardrail section did not extract]"
[ -n "$RD73" ]   || e0_73="$e0_73 [the hooks README carries no row for the brake]"
[ -n "$ST73" ]   || e0_73="$e0_73 [STEP_THRESHOLD did not extract from the hook]"
[ -n "$TT73" ]   || e0_73="$e0_73 [TASK_THRESHOLD did not extract from the hook]"
[ -z "$e0_73" ] && ok "E0 every region C73 reads extracts" \
                || bad "E0 every region C73 reads extracts ($e0_73)"

# A1 -- the map states neither ceiling. NUMBER-KEYED, because a number has no paraphrase: a home cannot
# restate `>150 added lines` without writing 150. That narrows IB-028 in this one instance and remedies
# nothing about the class. SCOPED TO THE MAP: the same leg written over the engine reddens
# `context-cost-note.py`, whose 150 is turns and is right.
# DERIVED and then unioned with the two literals, because the label claims a property and the pattern
# must implement it: derived, so raising the hook's ceiling keeps the map guarded against the number the
# brake now uses -- a hand-copied `150` here would leave the map free to state `>200 added lines` with
# this leg reporting "neither ceiling"; unioned, so a revert to the wording this task deleted is still
# caught after the hook has moved. A threshold that failed to extract falls back to its literal rather
# than emptying the alternation, which would match every line for a reason A1 is not about; E0 is the
# row that reports the failed extraction. An unreadable map is REPORTED and never counted as zero.
NUM73="${ST73:-150}|${TT73:-400}|150|400"
if [ ! -r "$LCM73" ]; then
  bad "A1 the map states neither ceiling (the map could not be read -- no verdict drawn from no bytes)"
else
  a1_73="$(grep -cE "(^|[^0-9])($NUM73)([^0-9]|$)" "$LCM73" 2>/dev/null)"
  [ "${a1_73:-0}" = 0 ] && ok "A1 the map states neither ceiling" \
                        || bad "A1 the map states neither ceiling ($a1_73 line(s) still carry a ceiling)"
fi

# A2 -- the section teaches no step and no count. Both halves: a section that kept the list passes a
# retry-only leg, and one that moved `max 3 attempts` into prose passes a list-only leg.
a2_73=""
if [ -z "$SECT73" ]; then a2_73=" [the section did not extract -- no verdict drawn from an empty region]"
else
  printf '%s\n' "$SECT73" | grep -qE '^[[:space:]]*[0-9]+[.)]' \
    && a2_73="$a2_73 [the section still walks the loop as a numbered list]"
  # The bullet form of the same content, which the numbered leg alone lets back in: a `- **Replan Gate**:
  # if an assumption breaks, revise the plan.` carries no digit and no `1.` and is the second home this
  # section exists not to be. The marker class takes `-`, `+` and a `*` followed by SPACE, never a bare
  # `*`: `**Purpose**` and `**Input**` open with one and are the delivered shape, not a list.
  printf '%s\n' "$SECT73" | grep -qE '^[[:space:]]*([-+]|\*[[:space:]])' \
    && a2_73="$a2_73 [the section teaches its rules as a bullet list again]"
  printf '%s\n' "$SECT73" | grep -qiE "$RETRY73" \
    && a2_73="$a2_73 [the section still states a retry count]"
fi
[ -z "$a2_73" ] && ok "A2 the EXECUTE section states no loop step and no retry count" \
                || bad "A2 the EXECUTE section states no loop step and no retry count ($a2_73)"

# A3 -- CO-OCCURRENCE, one variable per fact over the route paragraph: the route names the file AND each
# rule it hands over (IB-035). A bare `grep -qi 'execute.md'` is the shape that entry was opened for --
# green over a paragraph that names the file and hands over nothing.
#
# THE LIST IS EVERY RULE THE PARAGRAPH HANDS OVER, and the count is the fact rather than a detail: written
# with five it omitted the bounded retry and the Replan Gate, and deleting `the bounded retry, the Replan
# Gate,` from the route left all 1012 rows green -- measured, not suspected. Those two are the rules whose
# ONLY trace in the map is this paragraph, so the omission was the one that cost most. The facts are order
# INDEPENDENT: each is its own grep, and nothing here asserts the sequence they appear in.
a3_73=""
if [ -z "$P73" ]; then a3_73=" [the route paragraph did not extract -- no verdict drawn from an empty region]"
else
  printf '%s' "$P73" | grep -qi 'execute\.md' || a3_73="$a3_73 [the route names no file]"
  for f73 in "loop:step${S73}loop" "commit:commit" "retry:bounded${S73}retry" \
             "replan:Replan${S73}Gate" "guardrail:guardrail" "tiers:Action${S73}Boundaries" \
             "tiers-home:Deviation${S73}Rules" "spec-sync:Spec${S73}Sync"; do
    n73="${f73%%:*}"; g73="${f73#*:}"
    printf '%s' "$P73" | grep -qiE "$g73" || a3_73="$a3_73 (the route hands over no $n73)"
  done
fi
[ -z "$a3_73" ] && ok "A3 the route names its file and every rule it hands over" \
                || bad "A3 the route names its file and every rule it hands over ($a3_73)"

# A4 -- the DERIVED binding, and the replacement for the two legs C69 O2 loses to this task. The value is
# read from the hook the way LOCK69 reads LOCKFILES: raise STEP_THRESHOLD there and this names every prose
# home that lags, where a literal 150 written here would be a fifth hand-copy guarding the other four. A
# home that fails to extract is REPORTED and never skipped: `continue` would have made this green for
# reading nothing, which is the one failure a derived leg must not have.
#
# EACH CEILING IS BOUND TO ITS OWN CLAUSE, never to the region: both regions state both numbers, so a
# region-wide grep is green after a TRANSPOSITION -- Step >400 and Task >150 -- which is prose
# contradicting the very brake it is bound to, and the Contract's promise is two answers that AGREE with
# the brake, not two numbers that are present. `insent` cannot do this on the README: both ceilings sit
# inside one sentence of that row, so a sentence-scoped pair cannot tell them apart. The label is the
# scope instead -- the rulebook's two bullets and the README's two parentheticals -- with `[^0-9]*`
# between label and value, so the number matched is the first one that clause states and never its
# neighbour's. And a threshold that did not extract binds NOTHING: reported here rather than left to E0,
# because an empty `$ST73` turns every one of these greps green for reading nothing.
a4_73=""
if [ -z "$ST73" ] || [ -z "$TT73" ]; then
  a4_73=" [a threshold did not extract from the hook -- no home was bound and no verdict is drawn]"
else
  if [ -z "$DG73" ]; then a4_73="$a4_73 execute.md(did-not-extract)"
  else
    printf '%s\n' "$DG73" | grep -qE "\*\*Step\*\*[^0-9]*$ST73" || a4_73="$a4_73 execute.md(step=$ST73)"
    printf '%s\n' "$DG73" | grep -qE "\*\*Task\*\*[^0-9]*$TT73" || a4_73="$a4_73 execute.md(task=$TT73)"
  fi
  if [ -z "$RD73" ]; then a4_73="$a4_73 README.md(did-not-extract)"
  else
    printf '%s' "$RD73" | grep -qE "\*\*step\*\*[^0-9]*$ST73" || a4_73="$a4_73 README.md(step=$ST73)"
    printf '%s' "$RD73" | grep -qE "\*\*task\*\*[^0-9]*$TT73" || a4_73="$a4_73 README.md(task=$TT73)"
  fi
fi
[ -z "$a4_73" ] && ok "A4 both surviving homes state the hook's own two thresholds" \
                || bad "A4 both surviving homes state the hook's own two thresholds (missing:$a4_73)"

# A5 -- the Auto level keeps both facts and neither number. A bullet DELETED outright passes a
# number-only leg while granting the fastest level an exemption it does not have, so the SET is counted
# as well as read, and each member is asserted to route the rule it no longer states.
a5_73=""
if [ -z "$AS73" ]; then a5_73=" [no Auto constraint bullet extracted -- no verdict drawn from an empty region]"
else
  n5_73="$(printf '%s\n' "$AS73" | grep -c .)"
  [ "$n5_73" = 2 ] || a5_73="$a5_73 [the Auto level states $n5_73 of its two 'still respects' constraints]"
  printf '%s\n' "$AS73" | grep -qiE 'retry|retries' || a5_73="$a5_73 [the Auto level dropped the bounded retry]"
  printf '%s\n' "$AS73" | grep -qi  'guardrail'     || a5_73="$a5_73 [the Auto level dropped the diff guardrail]"
  printf '%s\n' "$AS73" | grep -qE  '[0-9]'         && a5_73="$a5_73 [an Auto constraint still states a number]"
  while IFS= read -r l5_73; do
    [ -n "$l5_73" ] || continue
    printf '%s' "$l5_73" | grep -qi 'execute\.md' || a5_73="$a5_73 [an Auto constraint routes nowhere]"
  done <<EOF5_73
$AS73
EOF5_73
fi
[ -z "$a5_73" ] && ok "A5 the Auto level keeps both facts and neither number" \
                || bad "A5 the Auto level keeps both facts and neither number ($a5_73)"

# A6 -- the same criterion's other half, and a home understand.md's inventory of the retry bound missed:
# the escalation bullet says `test failure after 3 retries`, so the bound has FOUR prose homes and not
# three, and D2's stated consequence -- two left after this task -- is false while that line stands. The
# leg is over the whole Auto block rather than the `still respects` set, because that is where the fourth
# copy sits, and it is retry-keyed rather than digit-keyed: `>3 files needed` on the same line is a file
# count, not the bound, and it stays.
a6_73=""
if [ -z "$AUTO73" ]; then a6_73=" [the Auto block did not extract -- no verdict drawn from an empty region]"
else printf '%s\n' "$AUTO73" | grep -qiE "$RETRY73" \
       && a6_73=" [the Auto block still states the retry bound as a number]"; fi
[ -z "$a6_73" ] && ok "A6 the Auto block states the retry bound nowhere as a number" \
                || bad "A6 the Auto block states the retry bound nowhere as a number ($a6_73)"
