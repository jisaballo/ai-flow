echo ""
echo "== C65: every non-blocking note reaches the model, and the close reads the numbers it is given =="
# A sandbox of this block's own. It used to read the one C11 opens, which is why this section could
# not be asked for on its own: under a filter C11 never runs and every path below collapses to "/".
BOX65="$(mkbox)" || fatal 'C65 fixtures'
# Conformance: three guardrail notes are printed for the operator and never enter the model's context, so
# the actor the note is addressed to cannot act on it; and the phase close, by its own written rule,
# therefore states no recommendation about stopping. Generated in the Conform phase from understand.md's
# Verifiable Criteria; each row names the criterion it comes from. Two rows are CONTROLS in the sense
# C48/C49 already use -- they pin behaviour this task must NOT take away, so they are green from the start
# by construction rather than by achievement.
#
# The behavioural rows RUN the hooks rather than reading them, and that is the row's whole point: the
# ticket that opened this task diagnosed the defect from the transcript's own delivery records and was
# wrong, because the harness writes a full-content record for a message it never shows the model. What a
# hook WRITES is therefore not evidence of what a hook DELIVERS, and a suite keyed on the source would
# have certified the same false conclusion. What is asserted here is the shape of the object on stdout,
# which is the one thing the harness reads.
BL65="$ROOT/global/protocols/backlog.md"
NOTE65="$HK/context-cost-note.py"
LED65="$HK/check-state-size.sh"
BRK65="$HK/diff-size-guard.py"
REG65="$HK/settings.hooks.json"
RDM65="$HK/README.md"
M65='ai-flow context note [150]'

# THREE levels, not two, and the third is the whole correction. The bar the close is handed compares what
# this session carries against what STARTING OVER would cost -- and starting over does not cost the bare
# floor. A session restarted there cannot resume: it has to read the task's papers back first, and the
# measurement this rule was derived from prices exactly that. Its own columns say so, a fresh-session
# start of 52k/57k/62k/67k/72k against handoffs of 10k/15k/20k/25k/30k being the same floor plus the
# handoff every time.
#
# So a fixture with only two levels cannot tell a correct bar from the degenerate one: keyed on the bare
# floor the comparison is true from the second turn onward, the close recommends at every close, and a
# two-level transcript agrees with both readings. The middle level is what separates them.
BARE65=41000    # turn 1: the bare floor -- system prompt, instructions, tools. Never the bar.
FRESH65=55000   # turn 2: the leanest working state, i.e. what a fresh session starts from
CTX65=87000     # later turns: what this session is now carrying

if [ "$PY3" = 0 ]; then
  echo "  [skip] C65 (python3 unavailable)"
else
T65="$BOX65/c65"; mkdir -p "$T65"
P65="$T65/proj"; mkdir -p "$P65/.ai-flow"

# A transcript of $2 main-loop turns rising from the floor to the carried context, plus any extra raw
# records given on stdin -- which is how the delivery records a dedupe row needs get in without this
# builder having to know what they look like.
mk_tx65() {  # $1 = path, $2 = turns
  : > "$1"
  local i=1 ctx
  while [ "$i" -le "$2" ]; do
    if [ "$i" = 1 ]; then ctx="$BARE65"
    elif [ "$i" = 2 ]; then ctx="$FRESH65"
    else ctx="$CTX65"; fi
    printf '{"type":"assistant","message":{"usage":{"input_tokens":12,"cache_read_input_tokens":%s}}}\n' "$ctx" >> "$1"
    i=$((i+1))
  done
  cat >> "$1"
}

# A session that has loaded its papers and done little since: the case the bar must NOT call a cut. Its
# carried context sits at its own working level, so a correct bar reads them equal and recommends
# nothing, while the bar keyed on the bare floor calls this a cut -- twelve to twenty-six turns before
# the break-even it was supposedly derived from.
mk_short65() {  # $1 = path, $2 = turns
  : > "$1"
  local i=1 ctx
  while [ "$i" -le "$2" ]; do
    if [ "$i" = 1 ]; then ctx=45000; else ctx=50000; fi
    printf '{"type":"assistant","message":{"usage":{"input_tokens":0,"cache_read_input_tokens":%s}}}\n' "$ctx" >> "$1"
    i=$((i+1))
  done
}

# Each supplied quantity read BY ITS ROLE, never as a substring loose in the line. The row this serves
# exists to catch an inversion of the very comparison the close's bar is, and a bare `grep -q 87` cannot
# see one: proved, by swapping the hook's two arguments and watching the whole suite stay green.
role65() {  # $1 = delivered text, $2 = carried|fresh -> that role's figure in thousands
  printf '%s' "$1" | python3 -c 'import re, sys
t = sys.stdin.read()
pat = r"([0-9]+)k carried" if sys.argv[1] == "carried" else r"([0-9]+)k to start fresh"
m = re.search(pat, t)
sys.stdout.write(m.group(1) if m else "")' "$2" 2>/dev/null
}

run65() {  # $1 = transcript, $2 = event -> the hook's stdout
  printf '{"hook_event_name":"%s","transcript_path":"%s","cwd":"%s","session_id":"s65","prompt":"go"}' \
    "$2" "$1" "$P65" | ( cd "$P65" && python3 "$NOTE65" 2>/dev/null )
}

# The two halves of the delivery, read the way the harness reads them. `additionalContext` is taken
# through a list branch as well as a string one because that is the shape the harness was measured to
# write it back as, and a reader that only handles the string matches the other by accidental
# stringification -- an accident is not a contract.
model65() {
  printf '%s' "$1" | python3 -c 'import json,sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
if not isinstance(d, dict):
    sys.exit(0)
h = d.get("hookSpecificOutput") or {}
c = h.get("additionalContext") if isinstance(h, dict) else None
if isinstance(c, list):
    c = " ".join(str(x) for x in c)
sys.stdout.write(c or "")' 2>/dev/null
}
oper65() {
  printf '%s' "$1" | python3 -c 'import json,sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
sys.stdout.write((d.get("systemMessage") or "") if isinstance(d, dict) else "")' 2>/dev/null
}

TXA65="$T65/crossed.jsonl"; mk_tx65 "$TXA65" 160 </dev/null
OUTA65="$(run65 "$TXA65" UserPromptSubmit)"

# A1 -- WHEN a guardrail emits a note without refusing, the engine shall emit it on `UserPromptSubmit`
# carrying `hookSpecificOutput.additionalContext`. Generated in the Conform phase from understand.md's
# Verifiable Criteria.
#
# One row, three legs, one per note carrier, because the rule is about the CLASS and a row per hook lets
# two of them move while the third is forgotten with every row still green. The first leg runs the hook;
# the other two read the emission site, because their fixtures are a git checkout and a ledger over
# budget and the claim under test here is the channel, not the condition that opens it -- each of those
# two conditions already has its own section in this file.
a1_65=""
[ -n "$OUTA65" ] || a1_65=" [the cost note emits nothing at UserPromptSubmit]"
printf '%s' "$(model65 "$OUTA65")" | grep -qF "$M65" \
  || a1_65="$a1_65 [the cost note's delivery carries no additionalContext the model can read]"
# Keyed on the JSON KEY and not on the word. Both files carry `hookSpecificOutput.additionalContext` in
# their header prose -- dotted, in backticks, explaining the measurement -- so a bare word search was
# satisfied by the explanation of the fix rather than by the fix, and stayed green with the whole
# dual-audience object reverted in either hook. The quote-and-colon form appears only where the object is
# actually built: four sites in the ledger guard, one in the diff guardrail, none in any comment.
# check-state-size.sh's own emit_note now lives in _note-lib.sh (sourced by it and by
# context-surface-size-note.sh, the shared note-delivery mechanics' one home), so the class this row
# names -- the JSON key actually built -- is looked for in either file.
grep -q '"additionalContext":' "$LED65" || grep -q '"additionalContext":' "$HK/_note-lib.sh" \
  || a1_65="$a1_65 [the ledger guard's note half emits no additionalContext]"
grep -q '"additionalContext":' "$BRK65" \
  || a1_65="$a1_65 [the diff guardrail's note half emits no additionalContext]"
[ -z "$a1_65" ] && ok "A1 the note travels on the channel the model reads" \
                || bad "A1 the note travels on the channel the model reads ($a1_65)"

# A2 -- The engine shall register no note-only guardrail on an event whose exit-0 output the model cannot
# read. Generated in the Conform phase from understand.md's Verifiable Criteria.
#
# PARSED, never grepped, and the reason is this file's own subject: `context-cost-note.py` appears in the
# registration whichever event it sits under, so a text search proves only that the string is present and
# would be green with the hook still bound to the channel that reaches nobody. Two legs pull the other
# way and they are the CONTROL half of this row: the two guardrails that also refuse keep their `Stop`
# registration, because moving a refusal to a prompt event would take away the block entirely.
reg65() {  # $1 = event, $2 = hook file name -> how many registrations
  python3 -c 'import json,sys
try:
    d = json.load(open(sys.argv[1]))
except Exception:
    print("E"); sys.exit(0)
n = 0
for g in (d.get(sys.argv[2]) or []):
    for h in (g.get("hooks") or []):
        if sys.argv[3] in (h.get("command") or ""):
            n += 1
print(n)' "$REG65" "$1" "$2" 2>/dev/null || printf 'E'
}
a2_65=""
[ "$(reg65 Stop context-cost-note.py)" = 0 ] \
  || a2_65=" [the note-only guardrail is still registered at Stop, where its exit-0 output reaches nobody]"
[ "$(reg65 UserPromptSubmit context-cost-note.py)" = 1 ] \
  || a2_65="$a2_65 [it is not registered exactly once at the event the model reads]"
[ "$(reg65 UserPromptSubmit check-state-size.sh)" = 1 ] \
  || a2_65="$a2_65 [the ledger guard's note half is not registered at the event the model reads]"
[ "$(reg65 UserPromptSubmit diff-size-guard.py)" = 1 ] \
  || a2_65="$a2_65 [the diff guardrail's note half is not registered at the event the model reads]"
[ "$(reg65 Stop check-state-size.sh)" = 1 ] \
  || a2_65="$a2_65 [CONTROL: the ledger guard lost the Stop registration its refusal needs]"
[ "$(reg65 Stop diff-size-guard.py)" = 1 ] \
  || a2_65="$a2_65 [CONTROL: the diff guardrail lost the Stop registration its refusal needs]"
[ -z "$a2_65" ] && ok "A2 no note-only guardrail is registered on a channel the model cannot read" \
                || bad "A2 no note-only guardrail is registered on a channel the model cannot read ($a2_65)"

# A3 -- WHEN a note is emitted, the engine shall carry the same mark in both halves, so the reader that
# suppresses a repeat finds it in either. Generated in the Conform phase from understand.md's Verifiable
# Criteria.
#
# The operator half is the leg that matters here and it is the one a careless move deletes: the point of
# carrying two fields in one object is that the person keeps seeing exactly what they see today. A row
# asserting only the model half would call a regression to a model-only note a success.
a3_65=""
printf '%s' "$(oper65 "$OUTA65")" | grep -qF "$M65" \
  || a3_65=" [the operator's half no longer carries the mark, so the move cost the person their note]"
printf '%s' "$(model65 "$OUTA65")" | grep -qF "$M65" \
  || a3_65="$a3_65 [the model's half does not carry the mark, so a repeat cannot be suppressed from it]"
[ -z "$a3_65" ] && ok "A3 both halves of a note carry the same mark" \
                || bad "A3 both halves of a note carry the same mark ($a3_65)"

# A4 -- WHILE a threshold stands already spoken in the session's transcript, the engine shall emit no
# second note for that threshold. Generated in the Conform phase from understand.md's Verifiable Criteria.
#
# The fixture's delivery record is `hook_additional_context` with a LIST-valued `content`, which is what
# the harness was measured to write for the new channel and is outside the reader's accepted types today.
# The mark is SPLIT ACROSS two elements, at a space: with it whole inside one element, stringifying the
# list still carries it contiguously, so the accident this row exists to forbid would pass the row. Only
# the join reconstitutes a split mark.
# Keyed on the shape rather than on the type name because the list is the half that gets forgotten: a
# reader that adds the type and keeps stringifying the content matches by accident, and an accident that
# happens to work is the failure this row exists to make visible.
#
# The second leg is the row's other half: suppression must silence the NOTE and not the delivery. The
# always-on line is owed on every prompt, threshold or no threshold, so a hook that returns early on a
# spoken mark takes the close's own signal away with it -- green under a one-legged row.
TXB65="$T65/spoken.jsonl"
mk_tx65 "$TXB65" 160 <<TXB65EOF
{"type":"attachment","attachment":{"type":"hook_additional_context","content":["ai-flow context note","[150] — already said."]}}
TXB65EOF
OUTB65="$(run65 "$TXB65" UserPromptSubmit)"
# The suppression leg reads the WHOLE emission and not the model half, so it is live before the channel
# it guards exists: measured against the half this change is about to create, the leg is satisfied by that
# half being empty and proves nothing until the step that fills it -- a stub that cannot fail on the code
# it was written against is a stub that was never sized.
a4_65=""
printf '%s' "$OUTB65" | grep -qF "$M65" \
  && a4_65=" [the note is spoken a second time for a threshold the transcript already records]"
[ -n "$(model65 "$OUTB65")" ] \
  || a4_65="$a4_65 [suppressing the note also silenced the line the close is owed on every prompt]"
[ -z "$a4_65" ] && ok "A4 a threshold already spoken is not spoken again" \
                || bad "A4 a threshold already spoken is not spoken again ($a4_65)"

# A5 -- IF `transcript_path` names anything that is not a regular file, THEN the ledger guard's mark
# reader shall answer *not yet spoken* without opening it. Generated in the Conform phase from
# understand.md's Verifiable Criteria; it is the remedy the Icebox entry on this reader was taken for.
#
# Read over the FUNCTION BODY and not the file, and structural rather than behavioural, for one reason
# each. The body, because `check-state-size.sh` tests file readability in three other places and a
# file-wide search is satisfied by any of them while this reader still opens a directory. Structural,
# because both the guarded and the unguarded reader answer 1 -- *not yet spoken* is the direction every
# failure here takes on purpose -- so the two are indistinguishable from outside, and what this row is
# actually about is the unbounded read behind that identical answer.
# spoken_already now lives in _note-lib.sh (sourced by check-state-size.sh) rather than in its own
# source, so its body is read from there.
SPK65="$(awk '/^spoken_already\(\)/{f=1} f{print} f&&/^}$/{exit}' "$HK/_note-lib.sh")"
a5_65=""
[ -n "$SPK65" ] || a5_65=" [the mark reader's body could not be located, so its guards prove nothing]"
if [ -n "$SPK65" ]; then
  printf '%s' "$SPK65" | grep -qE '\-f "?\$(TRANSCRIPT|\{TRANSCRIPT)|isfile' \
    || a5_65="$a5_65 [it does not refuse a transcript path that is not a regular file]"
  # The alternation names every shape a bounded read takes here rather than one of them: written to the
  # single mechanism first imagined, the leg reported the whole transcript still being read while the
  # bound was in place and working. A negative leg is only as wide as the ways the thing it wants can be
  # written, and the direction it must hold — the read is bounded — is unchanged.
  # The byte-addressed arm names the SEEK and not the constant. Keyed on `TAIL_BYTES` alone the leg
  # matched the declaration, so deleting the seek that uses it left the row green while the reader parsed
  # every line from byte zero again -- on every prompt now, not only at every close. A bound nobody seeks
  # to is not a bound. The other arms stay: the direction is that the read is bounded, not that it is
  # bounded this one way.
  printf '%s' "$SPK65" | grep -qE 'seek\([^)]*TAIL_BYTES|tail -n|LINE_CAP|deque\(' \
    || a5_65="$a5_65 [it reads the whole transcript from the start rather than a bounded tail]"
fi
[ -z "$a5_65" ] && ok "A5 the mark reader refuses a transcript that is not a regular file" \
                || bad "A5 the mark reader refuses a transcript that is not a regular file ($a5_65)"

# A6 -- WHEN a prompt is submitted, the engine shall supply the model with the session's accumulated
# context and a fresh session's starting cost, whether or not any threshold has been crossed. Generated
# in the Conform phase from understand.md's Verifiable Criteria.
#
# The fixture is deliberately BELOW every threshold. That is the gap the operator raised and the one
# measurement could not answer: a note that persists once delivered answers every close AFTER the
# threshold, and nothing at all answered a close at turn 30 -- which is where the simulated break-even
# actually sits. A row run at 160 turns would be green on the threshold note alone.
TXC65="$T65/quiet.jsonl"; mk_tx65 "$TXC65" 30 </dev/null
OUTC65="$(run65 "$TXC65" UserPromptSubmit)"
MC65="$(model65 "$OUTC65")"
#
# Each quantity is read BY ITS ROLE. The legs this replaces searched the delivered line for `87` and `41`
# anywhere in it, which asserts the two numbers EXIST and binds neither to what it means -- so the row
# stayed green with the two swapped, and a swap inverts the comparison the close's whole bar is. That is
# not a hypothetical: it was proved by inverting the hook's two arguments, and the suite held at 868/0
# with this row printing [ok]. A third leg pins the bar off the bare floor, which is the value the
# fixture's turn 1 carries and the value a correct reading must never report.
a6_65=""
[ -n "$MC65" ] || a6_65=" [nothing is supplied to the model on a prompt that crosses no threshold]"
[ "$(role65 "$MC65" carried)" = "${CTX65%000}" ] \
  || a6_65="$a6_65 [the carried figure is not the context this session has accumulated]"
[ "$(role65 "$MC65" fresh)" = "${FRESH65%000}" ] \
  || a6_65="$a6_65 [the start-fresh figure is not what a fresh session would start with, so the bar is wrong]"
[ "$(role65 "$MC65" fresh)" = "${BARE65%000}" ] \
  && a6_65="$a6_65 [it reports the BARE floor as the cost of starting over, which makes the cut pay from turn 2]"
printf '%s' "$MC65" | grep -qF "$M65" \
  && a6_65="$a6_65 [it spoke the threshold note on a session that crossed no threshold]"
[ -z "$a6_65" ] && ok "A6 the context and the fresh-session floor are supplied on every prompt" \
                || bad "A6 the context and the fresh-session floor are supplied on every prompt ($a6_65)"

# A11 -- CALIBRATION. The two quantities must not read as *cut recommended* on a session BELOW the
# measured break-even. A6 above proves each figure is the right one on a session far past the bar; this
# row is the other side, and without it the bar can be wrong in the one direction that costs something.
#
# The failure it exists for shipped once. Keyed on the bare turn-1 floor, `carried > start` holds from the
# second turn of every session -- so the close recommended cutting always, criterion A9's quiet branch was
# unreachable, and no row in the suite could see it because every fixture placed the session far past any
# plausible bar. The fixture here is the missing region: a session that has read its papers back and done
# little since, which the measurement says has NOT reached break-even.
TXE65="$T65/short.jsonl"; mk_short65 "$TXE65" 8
ME65="$(model65 "$(run65 "$TXE65" UserPromptSubmit)")"
a11_65=""
[ -n "$ME65" ] || a11_65=" [nothing is supplied on a short session, so the close has no signal at all]"
c11_65="$(role65 "$ME65" carried)"; f11_65="$(role65 "$ME65" fresh)"
if [ -n "$c11_65" ] && [ -n "$f11_65" ]; then
  [ "$c11_65" -gt "$f11_65" ] \
    && a11_65="$a11_65 [a session below the break-even reads as cut-recommended (${c11_65}k carried against ${f11_65}k to start fresh)]"
else
  a11_65="$a11_65 [the two quantities cannot be read by role, so the bar cannot be checked at all]"
fi
[ -z "$a11_65" ] && ok "A11 a session below the break-even does not read as cut-recommended" \
                 || bad "A11 a session below the break-even does not read as cut-recommended ($a11_65)"

# A7 -- IF a guardrail refuses, THEN it shall refuse at `Stop`, on stderr, with exit 2. CONTROL: it pins
# the healthy half against being carried along by the move, and is green from the start.
#
# Three legs, and the third is the one a half-done move breaks: a run that blocks must put NOTHING on
# stdout, because a `Stop` hook exiting 2 has its stdout unread -- so a refusal that started emitting the
# new object beside its stderr line would be losing the object silently while looking correct here.
P7_65="$T65/led"; mkproj "$P7_65" main >/dev/null 2>&1
mkdir -p "$P7_65/.ai-flow"
printf '# Session State\n\n## Workstreams\n\n| Workstream | Task |\n|---|---|\n| coordinator | T-001 |\n' \
  > "$P7_65/.ai-flow/STATE.md"
{ echo '# Backlog'; echo ''
  echo '> 2026-01-01 — one.'; echo '> 2026-02-01 — two.'
  echo '> 2026-03-01 — three.'; echo '> 2026-04-01 — four.'; } > "$P7_65/.ai-flow/BACKLOG.md"
OUT7_65="$( cd "$P7_65" && printf '{"hook_event_name":"Stop"}' | bash "$LED65" 2>"$T65/err7" )"; rc7_65=$?
a7_65=""
[ "$rc7_65" = 2 ] || a7_65=" [the refusal no longer exits 2 at Stop (exit $rc7_65)]"
grep -q 'changelog entries' "$T65/err7" 2>/dev/null \
  || a7_65="$a7_65 [the refusal does not name its cause on stderr, which is the only stream a Stop refusal is read from]"
[ -z "$OUT7_65" ] || a7_65="$a7_65 [the refusing run wrote to stdout, which a Stop hook exiting 2 has unread]"
[ -z "$a7_65" ] && ok "A7 the refusing half still refuses at Stop, on stderr" \
                || bad "A7 the refusing half still refuses at Stop, on stderr ($a7_65)"

# A8 -- IF a hook is invoked at an event that is not the one it serves, THEN it shall exit 0 and emit
# nothing. Generated in the Conform phase from understand.md's Verifiable Criteria.
#
# Not a hypothetical: the installer is additive and never removes, so every existing install keeps its
# `Stop` entry after an update and the hook meets that event on the very next session. The transcript is
# the one that DOES cross a threshold, so a hook that ignored the event would speak here -- keyed on the
# quiet transcript the row would be green with no event check written at all.
OUTD65="$(run65 "$TXA65" Stop)"; rcd65=$?
a8_65=""
[ "$rcd65" = 0 ] || a8_65=" [it does not exit 0 at an event that is not its own (exit $rcd65)]"
[ -z "$OUTD65" ] || a8_65="$a8_65 [it emitted something at an event that is not its own]"
[ -z "$a8_65" ] && ok "A8 a hook at an event that is not its own exits 0 and says nothing" \
                || bad "A8 a hook at an event that is not its own exits 0 and says nothing ($a8_65)"

# O2 -- The cost note's delivered text is at most 70 words, against ~130 today.
#
# Measured on the DELIVERED text and not on the source, which is the only measurement that means
# anything here: the note is assembled from a template and a computed clause, so a word count taken over
# the file counts the template's own punctuation and misses the clause. The whole delivery is counted,
# the always-on line included -- that line rides in the same object on the turn a threshold is crossed,
# and a bound that excluded it would let the saving be spent on the thing delivered every single turn.
w65="$(model65 "$OUTA65" | wc -w | tr -d ' ')"
[ "${w65:-0}" -ge 1 ] && [ "${w65:-0}" -le 70 ] \
  && ok "O2 the cost note is at most 70 words" \
  || bad "O2 the cost note is at most 70 words (delivered $w65)"

# --- the close reads the numbers it is now given ---------------------------
#
# The form paragraph ALONE, for the reason C50's own rows record at length: every element of the line has
# a second satisfier somewhere in `### The phase precondition`, and a row keyed on the region would be
# green with the form's own requirement deleted.
# FLATTENED at the source, so every leg below is keyed on the words and not on where the paragraph was
# wrapped. Written line-wise first, two legs reported the rule missing while it stood — the same defect
# O3 had, in the same change, and the second time is what says it belongs at the extraction rather than
# in each reader's memory.
# The paragraph must stay ONE paragraph, and this extraction is why: it stops at the first blank line,
# so a blank line inserted inside the form silently drops everything after it out of what is read. That
# constraint used to be written into the protocol itself, addressed to whoever might reformat it -- an
# editing instruction about a grep, carried in a document the model reads at every close. It is gone from
# there, because it does not need saying: split the paragraph and the legs below go red on the spot, which
# is the mechanism enforcing the rule instead of the prose asking someone to remember it.
FORM65="$(awk '/\*\*The form is fixed/{f=1} f&&/^[[:space:]]*$/{exit} f' "$BL65" 2>/dev/null | tr -s ' \n' '  ')"

# A9 -- WHILE the accumulated context exceeds a fresh session's starting cost, the phase close shall
# recommend cutting at this stop; and WHILE it does not, the close shall state no recommendation.
# Generated in the Conform phase from understand.md's Verifiable Criteria.
#
# FOUR legs, and the fourth is a retirement rather than a requirement. `recommendation` alone is no
# discriminator: the paragraph carries the word today, in the sentence that says there is none and in the
# one promising there will be on the day the signal arrives. So the positive leg is keyed on the ACT, and
# the retired sentence is keyed negatively -- left standing beside the new rule, the paragraph would say
# both that the recommendation is deliberately absent and that it is made, and the next reader repairs
# the contradiction by deleting whichever half they met first.
a9_65=""
[ -n "$FORM65" ] || a9_65=" [the form paragraph for the close's line could not be located]"
if [ -n "$FORM65" ]; then
  printf '%s' "$FORM65" | grep -qiE 'recommends? (the )?cut|recommend cutting|recommends stopping' \
    || a9_65="$a9_65 [the close does not recommend the cut, so the signal it is now handed changes nothing]"
  printf '%s' "$FORM65" | grep -qiE 'exceeds[^.]*fresh session|fresh session would start|starting (cost|context)' \
    || a9_65="$a9_65 [it does not condition the recommendation on the comparison the phase is handed]"
  printf '%s' "$FORM65" | grep -qiE 'no recommendation|recommends nothing|states none|says nothing about' \
    || a9_65="$a9_65 [it does not say the close stays quiet below the bar, so the recommendation reads as unconditional]"
  printf '%s' "$FORM65" | grep -qiE 'deliberately absent|absence is a decision|until the (context-)?cost note reaches' \
    && a9_65="$a9_65 [the retired sentence still says the recommendation is deliberately absent, contradicting the rule beside it]"
fi
[ -z "$a9_65" ] && ok "A9 the close recommends the cut only while the numbers say it pays" \
                || bad "A9 the close recommends the cut only while the numbers say it pays ($a9_65)"

# A10 -- The engine shall derive the close's bar by comparing those two supplied quantities, and shall
# record no fitted constant for it. Generated in the Conform phase from understand.md's Verifiable
# Criteria.
#
# Two legs pulling opposite ways, which is what an anti-drift rule needs: the positive alone is satisfied
# by prose that calls a written-down number "derived", and the negative alone is satisfied by deleting
# the bar altogether. The negative is a digit search over the paragraph rather than a list of the
# candidate numbers, because a constant nobody predicted is exactly the one that gets written -- the
# operator's own 100 was three to four times past the measured break-even and was about to be recorded.
a10_65=""
[ -n "$FORM65" ] || a10_65=" [the form paragraph for the close's line could not be located]"
if [ -n "$FORM65" ]; then
  # Keyed on the DERIVATION claim, not on the words `comparison` or `exceeds` loose in the paragraph:
  # A9's own sentence carries both, so the old alternation was satisfied by prose A9 already guards and
  # the derivation sentence could be deleted whole with this row still green.
  printf '%s' "$FORM65" | grep -qiE 'comparison and not a threshold|nothing is written down|cannot go stale' \
    || a10_65="$a10_65 [it does not say the bar is a comparison between the two supplied quantities]"
  printf '%s' "$FORM65" | grep -qE '[0-9]' \
    && a10_65="$a10_65 [the paragraph records a number, so the bar is fitted and will go stale]"
fi
[ -z "$a10_65" ] && ok "A10 the close's bar is derived and no constant is recorded" \
                 || bad "A10 the close's bar is derived and no constant is recorded ($a10_65)"

# O3 -- `global/protocols/backlog.md` no longer claims the cost note is delivered to the operator and not
# to the phase.
#
# Whole-file and not the paragraph, deliberately: the claim is the justification the retired rule leaned
# on, and a justification left anywhere in the document is one a later reader will follow back to the
# rule it justifies. It is false as of the first step of this change.
# FLATTENED before it is searched, and that is the row and not a detail. Written line-wise it was GREEN
# against the live sentence, which wraps between `delivered to the operator` and `and not to the phase` --
# so an absence check reported the claim gone while it stood, in a document whose every paragraph is
# wrapped. A negative leg over prose that is not flattened first is a leg keyed on where someone pressed
# return.
FLAT65="$(tr -s ' \n' '  ' < "$BL65")"
o3_65=""
printf '%s' "$FLAT65" | grep -qiE 'delivered to the operator and not to the phase|the phase (cannot|can not) see (that|the) signal' \
  && o3_65=" [the protocol still claims the cost note never reaches the phase]"
[ -z "$o3_65" ] && ok "O3 the protocol no longer claims the note reaches only the operator" \
                || bad "O3 the protocol no longer claims the note reaches only the operator ($o3_65)"

# O4 -- CONTROL. The close's line stays within the three things its fixed form already allows and gains
# no fourth. Green from the start by construction: the recommendation rides INSIDE the availability
# element rather than beside it, so what this row pins is the decision not to grow the line -- which is
# the one thing a rewrite adding a recommendation is most likely to spend.
o4_65=""
[ -n "$FORM65" ] || o4_65=" [the form paragraph for the close's line could not be located]"
printf '%s' "$FORM65" | grep -qiE 'three things and no more|carries three things' \
  || o4_65="$o4_65 [the form no longer bounds the line to three things]"
printf '%s' "$FORM65" | grep -qiE 'requests? no input|no input is (requested|sought)' \
  || o4_65="$o4_65 [the form no longer forbids the close from requesting an input]"
[ -z "$o4_65" ] && ok "O4 the close's line gains no fourth element" \
                || bad "O4 the close's line gains no fourth element ($o4_65)"

# O1 -- Every row of `global/hooks/README.md` names the event(s) its hook is actually registered at.
#
# Read from the row's EVENT CELL and not from the row, because every one of these rows discusses events
# in its prose -- the ledger guard's row explains what a `Stop` hook exiting 2 does with its stdout -- so
# a row-wide search would report the column correct while it still says the opposite of the registration.
ev65() {  # $1 = hook name -> its Event cell
  awk -F'|' -v h="$1" 'index($2, h) { print $3; exit }' "$RDM65"
}
o1_65=""
printf '%s' "$(ev65 context-cost-note)" | grep -q 'UserPromptSubmit' \
  || o1_65=" [the cost note's row does not name the event it is registered at]"
printf '%s' "$(ev65 context-cost-note)" | grep -q 'Stop' \
  && o1_65="$o1_65 [the cost note's row still names the event it left]"
printf '%s' "$(ev65 check-state-size)" | grep -q 'UserPromptSubmit' \
  || o1_65="$o1_65 [the ledger guard's row does not name the event its note half runs at]"
printf '%s' "$(ev65 check-state-size)" | grep -q 'Stop' \
  || o1_65="$o1_65 [the ledger guard's row lost the event its refusal runs at]"
printf '%s' "$(ev65 diff-size-guard)" | grep -q 'UserPromptSubmit' \
  || o1_65="$o1_65 [the diff guardrail's row does not name the event its note half runs at]"
printf '%s' "$(ev65 diff-size-guard)" | grep -q 'Stop' \
  || o1_65="$o1_65 [the diff guardrail's row lost the event its refusal runs at]"
[ -z "$o1_65" ] && ok "O1 every hook row names the event it is registered at" \
                || bad "O1 every hook row names the event it is registered at ($o1_65)"
fi
