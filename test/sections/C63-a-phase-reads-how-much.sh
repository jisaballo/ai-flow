echo "== C63: a phase reads how much supervision the task was granted, and says what it changes there =="
# Conformance: the supervision level is written at activation and, today, read by nothing -- a task marked
# Supervised runs exactly like one marked Auto. Generated in the Conform phase from understand.md's
# Verifiable Criteria; each row names the criterion it comes from. One row is a CONTROL in the sense
# C48/C49 already use: it pins behaviour this task must NOT make reachable, so it is green from the start
# by construction rather than by achievement.
BL63="$ROOT/global/protocols/backlog.md"
MAP63="$ROOT/global/protocols/lifecycle.md"
C63_SKILLS="understand plan execute verify"
PRECOND63="The phase precondition"

# The rule's own block and one bolded clause of it. A local pair rather than C22's, so this block stands
# on its own -- the same reason C22 gives for defining `poff22` instead of reusing C14's. The narrowing to
# a clause is not stylistic: five facts share this block, and a block-wide grep lets any one of them stand
# in for any other, which is the failure this harness has now caught eight times.
PBLK63="$(awk -v h="^### $PRECOND63" '$0 ~ h {f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^#+ /){f=0} f' "$BL63")"
pclause63() { printf '%s\n' "$PBLK63" | awk -v s="$1" '/^- \*\*/{ if(g) exit; g=($0 ~ s) } g' | tr '\n' ' '; }

# A1a -- the home. WHEN a phase command states its step 2, the engine shall state that the command reads
# the task's `autonomy:` line and names the level and its source. This is the half that lives in the
# protocol; the per-command half is A1b below.
#
# The LEAD is asserted with it, and that is not tidiness: the block opens by saying a command tests "two
# things", and a third bullet landing under a lead that still says two is a document contradicting itself
# on the count a reader uses to know whether they have read all of it. The two legs are paired on one row
# because either alone certifies half a rule -- a bullet under a stale lead, or a corrected lead over a
# bullet that was never written.
AUT63="$(pclause63 'autonomy read')"
a1_63=""
[ -n "$PBLK63" ] || a1_63=" [the phase precondition block could not be located: every row below would be about an empty string]"
[ -n "$AUT63" ] || a1_63="$a1_63 [the block states no autonomy-read bullet]"
printf '%s' "$AUT63" | grep -q 'autonomy:' \
  || a1_63="$a1_63 [the bullet does not name the sheet line the command reads]"
printf '%s' "$AUT63" | grep -qiE 'names the level|state the level|says the level' \
  || a1_63="$a1_63 [it does not oblige the command to name the level]"
printf '%s' "$AUT63" | grep -qiE 'source it read|where it read|and the source' \
  || a1_63="$a1_63 [it does not oblige the command to name the source it read the level from]"
# Scoped to the LEAD PARAGRAPH -- the block's text before its first bullet -- and the narrowing is the
# leg. Read over the whole block this was HOLLOW, proven by mutation: the form paragraph further down
# says "The announcement carries three things and no more", about the close's line and not about what a
# command reads, so the lead could be reverted to two and the row stayed green on a neighbour's count.
# Worse than merely hollow: Step 3 rewrites that paragraph, so the leg would have flipped red later for
# a reason having nothing to do with the fact it names.
LEAD63="$(printf '%s\n' "$PBLK63" | awk '/^- \*\*/{exit} {print}' | tr '\n' ' ')"
printf '%s' "$LEAD63" | grep -qiE '(reads|tests) (three|3) things' \
  || a1_63="$a1_63 [the block's lead still says a command reads two things, so the count contradicts its own bullets]"
[ -z "$a1_63" ] && ok "A1a the precondition states the autonomy read, and its lead counts it" \
                || bad "A1a the precondition states the autonomy read, and its lead counts it ($a1_63)"

# A1b + B1 + A3b -- the three commands perform it, in the step that runs at entry. Scoped to step 2 with
# the shared `vstep` extractor, because the operative instruction the command reads at runtime is that
# one: the protocol states the rule, the command performs it -- and a file-wide grep here is satisfied by
# any later mention, which is the shape of a guard reporting on nothing.
#
# Three legs per command, each its own row, and the reason they are not one row with three legs is the
# per-leg mutation rule: read as one, the level leg is satisfied by the default leg's own sentence, since
# both name Guided. Kept separate, each has to be mutated on its own.
for s63 in $C63_SKILLS; do
  f63="$ROOT/global/skills/$s63/SKILL.md"
  if [ ! -f "$f63" ]; then
    bad "A1b $s63 reads the sheet's autonomy line at entry (file missing: $f63)"
    bad "B1 $s63 says what the level changes for its own phase (file missing)"
    bad "A3b $s63 defaults to Guided out loud where the sheet declares no level (file missing)"
    continue
  fi
  st63="$(vstep "$f63" 2)"

  # NOT a loose `autonomy`: the word will appear in the routing citation once the bullet exists, so a
  # bare match is green on the pointer alone -- the command citing a rule it never performs. The FIELD
  # with its colon is what a command that actually reads the sheet names.
  # The second leg was `sheet|state.md` and had to go before the baseline was frozen: step 2 ALREADY
  # names the task's sheet, for the phase precondition it has always tested, so that leg was green on a
  # neighbour's word before a line of this task existed -- and would have gone on passing with the
  # autonomy read deleted. What is actually new is the REPORT: the command tells the operator the level.
  # Keyed on `the level`, which occurs nowhere in any of the three steps today.
  r63=""
  [ -n "$st63" ] || r63=" [step 2 could not be extracted]"
  printf '%s' "$st63" | grep -q 'autonomy:' \
    || r63="$r63 [it does not name the sheet line it reads]"
  printf '%s' "$st63" | grep -qiE '(name|names|state|says|say)[a-z]* the level' \
    || r63="$r63 [it reads the level without reporting it, so the operator cannot see what supervision the run assumed]"
  # The SOURCE leg RETIRED here and is asserted at its home instead -- A1a's own source leg, one row
  # down. Nothing is weakened by the move: the obligation to name where the level was read from is the
  # protocol's, four commands now route to it rather than three restating it, and a command that still
  # carried the phrase would be the second home the routing was bought to remove. C67's A2 is the
  # negative that keeps it from growing back, per command; this leg and that one cannot both be green,
  # which is why the retirement is part of the same step as the cut and not a later tidy-up.
  # The ROUTE, also its own leg. A2 forbids a second TABLE of the levels; nothing required the command to
  # send the reader anywhere for them. Both halves of "route, restate nothing" are needed: the ban alone
  # is satisfied by a command that states no levels and names no owner either, which leaves the reader to
  # guess where the levels live.
  printf '%s' "$st63" | grep -qiE 'lifecycle map' \
    || r63="$r63 [it does not route the levels to the lifecycle map, so the ban on restating them sends the reader nowhere]"
  [ -z "$r63" ] && ok "A1b $s63 reads the sheet's autonomy line at entry" \
                || bad "A1b $s63 reads the sheet's autonomy line at entry ($r63)"

  # B1. The branch that is pure discipline and therefore the first to be dropped: a level that changes
  # nothing for this phase is still said, WITH that verdict. Without it a command silently omits the
  # level exactly where the operator cannot tell omission from "nothing to report" -- and silence is not
  # a check that happened, which is the rule this engine states about its own legs.
  n63=""
  printf '%s' "$st63" | grep -qiE 'changes nothing|nothing changes|no effect here|changes nothing here' \
    || n63=" [it does not say what happens where the level changes nothing for this phase]"
  [ -z "$n63" ] && ok "B1 $s63 says the level even where it changes nothing for its own phase" \
                || bad "B1 $s63 says the level even where it changes nothing for its own phase ($n63)"

  # A3b RETIRED. The absent-level branch was asserted per command and is now asserted once, at A3a
  # below, where the rule lives. The same discipline the source leg above records: the fact keeps a
  # guard, it just keeps it at its home. What made three copies defensible was that three commands each
  # stated the branch; after the cut none does, so a per-command row would assert an absence and pass
  # for a reason having nothing to do with the rule.
done

# A3a -- the default's home. WHERE the task's sheet declares no autonomy level, the engine shall state
# that the command proceeds as Guided and says that it is defaulting. Its own row rather than a leg of
# A1a, so the bullet can lose the default without losing the read and the report says which went.
a3_63=""
printf '%s' "$AUT63" | grep -qiE 'no autonomy|declares no level|absent' \
  || a3_63=" [the bullet states no branch for a sheet that declares no level]"
printf '%s' "$AUT63" | grep -qiE '(no autonomy|declares no level|absent)[^.]*Guided|Guided[^.]*(no autonomy|declares no level|absent)' \
  || a3_63="$a3_63 [the absent-level branch does not itself carry Guided as the verdict]"
printf '%s' "$AUT63" | grep -qi 'default' \
  || a3_63="$a3_63 [it does not oblige the command to say it is defaulting]"
[ -z "$a3_63" ] && ok "A3a the absent-level branch is stated, and carries Guided as its own verdict" \
                || bad "A3a the absent-level branch is stated, and carries Guided as its own verdict ($a3_63)"

# A2 -- CONTROL. The engine shall state the autonomy levels in the lifecycle map and in no other installed
# file, the skills included. Green from the start by construction: measured before a line of this task was
# written, the map carries three rows and nothing else carries two.
#
# It is a control and still worth its row, because what makes the copy REACHABLE is this task: a command
# that must act on the level is one sentence away from listing the levels, and the existing map-home guard
# does not sweep `global/skills/` at all -- so a phase skill may state the whole table, the very three rows
# whose loss in two copies bought that guard, with every row of it green. This row is the narrowest thing
# that closes the reachable half without pre-judging a later task of this epic.
#
# Keyed on the TABLE and never on any mention of a level -- deliberately, and the reason is a decision
# already frozen in this epic: a later row moves the Supervised per-step rule INTO the execute skill, so a
# guard keyed on mentions would refuse that change. `rows-only` is the existing idiom for exactly this
# distinction: a level LEADING a table cell is a description, a level in prose is a mention.
rows63() { grep -icE "^\| *\*{0,2}(Auto|Guided|Supervised)\b" "$1" 2>/dev/null | tr -d ' '; }
# NUL-delimited, never a word-split string. `$ROOT` is absolute and a checkout path may contain a space,
# which an unquoted `for f in $SET63` splits into fragments that name no file -- and every fragment fails
# the `[ -f ]` guard, so the loop `continue`s over all of them and the sweep examines NOTHING while
# reporting green. A control that silently inspects zero files is worse than no control: it certifies the
# copy it was built to forbid. Found by review, not by a failing run, because no failing run is possible.
copies63=""
while IFS= read -r -d '' f63b; do
  [ -f "$f63b" ] || continue
  [ "$(rows63 "$f63b")" -ge 2 ] && copies63="$copies63 ${f63b#$ROOT/}"
done < <(
  find "$ROOT/global/skills" -name 'SKILL.md' -print0 2>/dev/null
  find "$ROOT/global/protocols" -name '*.md' ! -name 'lifecycle.md' -print0 2>/dev/null
  find "$ROOT/template/.ai-flow" -name '*.md' -print0 2>/dev/null
  find "$ROOT/docs" -name '*.md' -print0 2>/dev/null
  printf '%s\0' "$ROOT/global/CLAUDE.md" "$ROOT/template/CLAUDE.md" "$ROOT/README.md"
)
# The sweep must have SEEN something. Zero files examined is the failure the NUL-delimiting prevents, and
# a count is what proves the prevention rather than assuming it.
seen63=0
while IFS= read -r -d '' f63c; do [ -f "$f63c" ] && seen63=$((seen63+1)); done < <(
  find "$ROOT/global/skills" -name 'SKILL.md' -print0 2>/dev/null
  printf '%s\0' "$ROOT/global/CLAUDE.md" "$ROOT/README.md"
)
c2_63=""
[ "$(rows63 "$MAP63")" -ge 2 ] || c2_63=" [the lifecycle map no longer states the levels as a table, so there is no home to route to]"
[ -z "$copies63" ] || c2_63="$c2_63 [a second table of the levels lives in:$copies63]"
[ "$seen63" -ge 3 ] || c2_63="$c2_63 [the sweep examined $seen63 files, so its verdict is about nothing]"
[ -z "$c2_63" ] && ok "A2 control: the autonomy levels are a table in the lifecycle map and in no other installed file" \
                || bad "A2 control: the autonomy levels are a table in the lifecycle map and in no other installed file ($c2_63)"

# B2 -- IF the sheet declares Auto, THEN `verify` shall skip the multi-agent review and name the sheet as
# what told it to. The unsourced assertion the ticket names: the skip clause states the level as a fact
# about the task with no source at all, so a run cannot tell a level it read from one it assumed. Scoped
# to the clause, because `Auto` and `sheet` both occur elsewhere in that command and a file-wide pair of
# greps is satisfied by any two unrelated lines.
SKV63="$ROOT/global/skills/verify/SKILL.md"
# Scoped with `vstep` to step 5, the step that DECIDES the skip -- not by a file-wide grep for the
# clause's words, which is what the frozen row asked for and what a first pass would write. The read
# added to step 2 says "Auto skips the multi-agent review" and names `autonomy:` in the same sentence,
# so a file-wide pair of greps is satisfied by that line alone and this row would be green with step 5
# untouched: the leg would certify a source the skip clause never names. The narrowing implements the
# frozen direction rather than weakening it -- what is asserted and which way is unchanged.
N_SKIP63="$(grep -nE '^[0-9]+\. \*\*Decide whether to skip' "$SKV63" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/')"
SKIP63="$([ -n "$N_SKIP63" ] && vstep "$SKV63" "$N_SKIP63")"
b2_63=""
[ -n "$SKIP63" ] || b2_63=" [the skip clause could not be located]"
# A KEEP-leg, green from the start and named as such: the clause already says `Auto-level tasks`, and
# what this row is about is the missing source. It stays because the repair rewrites this very sentence,
# and a rewrite that named the sheet while dropping the level would satisfy the source leg alone.
printf '%s' "$SKIP63" | grep -qiE 'Auto' \
  || b2_63="$b2_63 [the skip clause does not name the Auto level]"
printf '%s' "$SKIP63" | grep -qiE "sheet|state\.md|autonomy:" \
  || b2_63="$b2_63 [it names no source for the level, so an assumed level is indistinguishable from a read one]"
# The REACHABILITY of the branch, added in the Verify phase. The clause described a skip for a level whose
# ordinary path never arrives at this phase, so as written it documented a run that does not happen; the
# only way here is an operator asking for it directly, and a rule that does not say so reads as routine.
printf '%s' "$SKIP63" | grep -qiE 'skips it|path itself skips|operator asked|asked for this phase' \
  || b2_63="$b2_63 [it does not say the ordinary Auto path skips this phase, so it documents a run that never happens]"
[ -z "$b2_63" ] && ok "B2 verify's skip names the sheet as what told it the level" \
                || bad "B2 verify's skip names the sheet as what told it the level ($b2_63)"

# B3 -- IF the sheet declares Auto, THEN `plan` shall plan inline and write no plan artifact. The one
# level-dependent behaviour this command has, and the one a reader would otherwise have to infer from the
# lifecycle map's table -- which is precisely the inference A2 stops the command from short-cutting by
# copying the table. Both halves on one row: "inline" without "no artifact" leaves the command writing a
# plan.md it was told not to write, which is the failure the level exists to prevent.
SKP63="$ROOT/global/skills/plan/SKILL.md"
st2_63="$(vstep "$SKP63" 2)"
b3_63=""
printf '%s' "$st2_63" | grep -qiE 'inline' \
  || b3_63=" [it does not say an Auto task is planned inline]"
printf '%s' "$st2_63" | grep -qiE 'no plan artifact|writes no plan|no plan\.md|without writing' \
  || b3_63="$b3_63 [it does not say no plan artifact is written]"
[ -z "$b3_63" ] && ok "B3 the plan command states that Auto plans inline and writes no artifact" \
                || bad "B3 the plan command states that Auto plans inline and writes no artifact ($b3_63)"
