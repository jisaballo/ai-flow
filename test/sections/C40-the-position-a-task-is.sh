echo "== C40: the position a task is opened at is named, and it is not a phase =="
# The rail is raised while a sheet declares UNDERSTAND, and lowered by the phase commands that own the
# field. What nothing owned was the value activation writes: measured over 41 sheets it took four
# (UNDERSTAND 26, ACTIVATE 13, EXECUTE 3, ACTIVATED 1), so the rail stood up on some tasks and stayed
# down on others, decided by nothing. Both halves of that are guarded here, and the value is read from
# the protocol rather than restated: a test carrying its own copy would let the prose drift back with
# the suite green — a guard that certifies the state it exists to prevent.
B40="global/protocols/backlog.md"
# Not anchored at line start: a restatement appended mid-paragraph is a second home, and an anchored
# count is blind to precisely the copy someone would write by accident.
DECL40='\*\*The first position is `[A-Z]+`\.\*\*'
# The lifecycle's own phase vocabulary. The row's name claims the position is not a phase, and a check
# that rejects only UNDERSTAND leaves the other wrong answer open: a first position of EXECUTE passes
# every arm below while satisfying the audit's accepted positions, so `verify` would run clean on a task
# nobody planned. The claim the section makes is the claim that gets pinned.
PHASES40='UNDERSTAND|PLAN|CONFORM|EXECUTE|VERIFY|ARCHIVE'

# --- the value has exactly one home, inside the section that owns it -------
# Counted, not merely found: two statements are how the template and the ceremony come to disagree, and
# a presence grep cannot see the second one. Counted twice over — once across global/, once inside the
# section move 7 points at — so the pointer in move 7 is verified rather than assumed. The shipped
# template and the docs are counted too: a copy there is as much a second home as one in global/.
# Fence-aware, the shape C22 uses for the precondition block: this section embeds the ledger and sheet
# templates in code fences, and those carry markdown headings of their own — a naive bound ends the
# section at the first `## Workstreams` inside a fence and reads the declaration as living outside it.
SF40="$(awk '/^## State Files/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$B40")"
ALL40="$(grep -rhoE "$DECL40" global/ 2>/dev/null | wc -l | tr -d ' ')"
IN40="$(printf '%s\n' "$SF40" | grep -oE "$DECL40" | wc -l | tr -d ' ')"
ELSEWHERE40="$(grep -rhoE "$DECL40" template/ docs/ 2>/dev/null | wc -l | tr -d ' ')"
POS40="$(grep -rhoE "$DECL40" global/ 2>/dev/null | head -1 | sed -E 's/.*`([A-Z]+)`.*/\1/')"
a1_40=""
[ "$ALL40" = "1" ] || a1_40="$a1_40 [declared $ALL40 times in global/, want exactly 1]"
[ "$IN40" = "1" ] || a1_40="$a1_40 [declared $IN40 times inside ## State Files, where move 7 points]"
[ "$ELSEWHERE40" = "0" ] || a1_40="$a1_40 [declared $ELSEWHERE40 times outside global/]"
[ -n "$POS40" ] || a1_40="$a1_40 [no position named]"
printf '%s' "$POS40" | grep -qxE "$PHASES40" \
  && a1_40="$a1_40 [the position is a phase ($POS40); activation writes no phase]"
[ -z "$a1_40" ] && ok "the opening ceremony names exactly one first position, and it is not a phase" \
                || bad "the opening ceremony names exactly one first position, and it is not a phase:$a1_40"

# --- the sites that write or judge the position point at that home --------
# Move 7 and the Activation row are what a session reads at activation; the accepted-positions clause is
# what judges the value afterwards, and it is Step 2's whole deliverable — unasserted, it could revert to
# calling the position undefined with the suite green. Flattened with the whitespace squeezed, not merely
# with newlines swapped: these are wrapped markdown paragraphs, so a naive swap keeps the continuation
# indent inside the text and a phrase straddling a line break stops matching. An assertion whose verdict
# depends on where a paragraph happens to wrap cannot tell a pass from a fail.
flat40() { tr '\n' ' ' | tr -s ' '; }
M40="$(awk '/^7\. \*\*Write the roster row/{f=1} f&&/^## /{exit} f' "$B40" | flat40)"
R40="$(grep -E '^\| \*\*Activation\*\*' "$B40" | flat40)"
A40="$(awk '/^- \*\*Accepted positions\.\*\*/{f=1} f&&/^- \*\*The material leg/{exit} f' "$B40" | flat40)"
a2_40=""
[ -n "$M40" ] || a2_40="$a2_40 [move 7 not found]"
[ -n "$R40" ] || a2_40="$a2_40 [the Activation row not found]"
[ -n "$A40" ] || a2_40="$a2_40 [the accepted-positions clause not found]"
for pair40 in "move-7:$M40" "activation-row:$R40" "accepted-positions:$A40"; do
  who40="${pair40%%:*}"; txt40="${pair40#*:}"
  printf '%s' "$txt40" | grep -qF 'first position' \
    || a2_40="$a2_40 [$who40 does not point at the first position rule]"
done
# The two writing sites must name no value of their own. The forbidden set is derived from the value that
# was read, not hard-coded: the most likely restatement is move 7 adding "it is ACTIVATE", which a list
# of phase names alone cannot see.
for pair40 in "move-7:$M40" "activation-row:$R40"; do
  who40="${pair40%%:*}"; txt40="${pair40#*:}"
  printf '%s' "$txt40" | grep -qE "\b(${POS40:-__none__}|$PHASES40)\b" \
    && a2_40="$a2_40 [$who40 names a position of its own instead of citing the rule]"
done
# The clause that judges the value legitimately names phases (`plan` runs on UNDERSTAND or PLAN), so the
# arm it gets is the false claim this task retired, not a token ban.
printf '%s' "$A40" | grep -qiF 'undefined' \
  && a2_40="$a2_40 [the accepted-positions clause still calls the first position undefined]"
# The template is the block a reader copies from, and it is the third site the criterion names. It is
# asserted positively — it must carry the position — because it also carries an in-flight illustration on
# purpose, so a token ban would either fail on that or pass on nothing.
# Bounded to the text ABOVE the declaration, not to the whole subsection: the declaration states the
# write in its own prose, so a check over the section as a whole is satisfied by the very paragraph it
# is meant to be independent of — delete the template's line and it still passes. What must carry the
# position is the block a reader copies and the note beside it, which is everything before the rule.
T40BLK="$(awk '/^### `artifacts\/T-XXX\/state.md`/{f=1;next} f&&index($0,"**The first position is")>0{exit} f&&/^### /{exit} f' "$B40" | flat40)"
[ -n "$T40BLK" ] || a2_40="$a2_40 [the sheet a reader copies from not found]"
[ -n "$POS40" ] && { printf '%s' "$T40BLK" | grep -qF "phase: **$POS40**" \
  || a2_40="$a2_40 [the sheet a reader copies from never shows the first position]"; }
[ -z "$a2_40" ] && ok "the ceremony's writing sites cite the first position instead of restating one" \
                || bad "the ceremony's writing sites cite the first position instead of restating one:$a2_40"

# --- the named position leaves the rail down, and UNDERSTAND still raises it -
# Derived from the declaration above: this is the assertion that makes the prose load-bearing. The
# UNDERSTAND arm is not decoration — a fixture that only proves "exit 0" is satisfied by a hook that
# never blocks anything, so both verdicts are taken from the same fixture. A missing interpreter is a
# skip, the way every sibling section treats it: reporting it as a failure blames the protocol for the
# machine. The sandbox is guarded and registered on the trap, the convention this file states and keeps.
if [ -z "$POS40" ]; then
  bad "the position the ceremony writes leaves the read-only rail down [no position to derive from]"
elif [ "$PY3" != 1 ]; then
  echo "  [skip] the read-only rail fixture (python3 unavailable)"
elif ! T40="$(mktemp -d 2>/dev/null)" || [ ! -d "$T40" ]; then
  bad "the position the ceremony writes leaves the read-only rail down (no sandbox: mktemp -d failed)"
else
  trap 'rm -rf "$T12" "$T13" "$T25" "$T40"' EXIT
  P40="$T40/p"; mkproj "$P40" main
  mkdir -p "$P40/.ai-flow/artifacts/opened"
  a3_40=""
  [ -d "$P40/.git" ] || a3_40="$a3_40 [the fixture repository was never built]"
  printf 'branch: main\nphase: **%s**\n' "$POS40" > "$P40/.ai-flow/artifacts/opened/state.md"
  out_open40="$(wguard "$P40" "$P40/app.txt" 2>&1)"; rc_open40=$?
  printf 'branch: main\nphase: **UNDERSTAND**\n'   > "$P40/.ai-flow/artifacts/opened/state.md"
  out_und40="$(wguard "$P40" "$P40/app.txt" 2>&1)"; rc_und40=$?
  [ "$rc_open40" = 0 ] || a3_40="$a3_40 [a sheet at $POS40 refused a code write (exit $rc_open40)]"
  # Exit 1 is the hook erroring, not refusing, and a discarded diagnostic reports the two identically.
  [ "$rc_und40" = 2 ] || a3_40="$a3_40 [the same sheet at UNDERSTAND did not refuse (exit $rc_und40: $(printf '%s' "$out_und40" | tr '\n' ' ' | cut -c1-120))]"
  case "$out_und40" in
    *"artifacts/opened/state.md"*) : ;;
    *) a3_40="$a3_40 [the refusal does not name the sheet it read]" ;;
  esac
  [ -z "$a3_40" ] && ok "the position the ceremony writes leaves the read-only rail down" \
                  || bad "the position the ceremony writes leaves the read-only rail down:$a3_40"
  rm -rf "$T40"
  trap 'rm -rf "$T12" "$T13" "$T25"' EXIT   # handed back to the section that owned it
fi
