echo "== C11: worktree-aware hooks =="
T11="$(mkbox)" || fatal 'C11 fixtures'



# --- the read-only rail ---------------------------------------------------
if [ "$PY3" = 1 ]; then
  P1="$T11/p1"; mkproj "$P1" main
  W1="$T11/w1"; $GIT -C "$P1" worktree add -q -b wt1 "$W1" >/dev/null 2>&1
  mkdir -p "$W1/.ai-flow/artifacts/sample-task"
  printf '# Task state\n\nphase: **UNDERSTAND**\n' > "$W1/.ai-flow/artifacts/sample-task/state.md"

  out="$(wguard "$W1" "$W1/app.txt")"; rc=$?
  [ "$rc" = 2 ] && ok "write rail blocks code writes while the phase is UNDERSTAND" \
                || bad "write rail blocks code writes while the phase is UNDERSTAND (exit $rc)"
  case "$out" in
    *"artifacts/sample-task/state.md"*) ok "block message names the state file it read" ;;
    *) bad "block message names the state file it read" ;;
  esac
  out="$(wguard "$W1" "$W1/.ai-flow/artifacts/sample-task/notes.md")"; rc=$?
  [ "$rc" = 0 ] && ok "write rail still allows ledger writes" \
                || bad "write rail still allows ledger writes (exit $rc)"

  P2="$T11/p2"; mkproj "$P2" main
  mkdir -p "$P2/.ai-flow/artifacts/sample-task"
  printf 'Current phase: **EXECUTE**\n' > "$P2/.ai-flow/STATE.md"
  printf 'phase: **UNDERSTAND**\n'      > "$P2/.ai-flow/artifacts/sample-task/state.md"
  out="$(wguard "$P2" "$P2/app.txt")"; rc=$?
  [ "$rc" = 2 ] && ok "per-task state wins over the ledger phase" \
                || bad "per-task state wins over the ledger phase (exit $rc)"

  P3="$T11/p3"; mkproj "$P3" main
  mkdir -p "$P3/.ai-flow"
  printf 'Current phase: **UNDERSTAND**\n' > "$P3/.ai-flow/STATE.md"
  out="$(wguard "$P3" "$P3/app.txt")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *".ai-flow/STATE.md"*) ok "falls back to the ledger STATE when no per-task state exists" ;;
      *) bad "falls back to the ledger STATE when no per-task state exists (blocked, but does not name the ledger)" ;;
    esac
  else
    bad "falls back to the ledger STATE when no per-task state exists (exit $rc)"
  fi

  # --- the declaration, not the shape found anywhere in the document ------
  # The sheet is a prose document: it carries decisions and a resume block, and a task that discusses
  # its own phases reproduces the field's syntax as a matter of course. Scanning the whole text reads
  # the mention and raises the rail over a task nobody is understanding.
  PDECL="$T11/pdecl"; mkproj "$PDECL" main
  mkdir -p "$PDECL/.ai-flow/artifacts/prose"
  printf '# Task state\n\nbranch: main\nphase: **EXECUTE**\n\n## Decisions\n\n- the precondition passed: the sheet declared phase: **UNDERSTAND** at the time\n' \
    > "$PDECL/.ai-flow/artifacts/prose/state.md"
  out="$(wguard "$PDECL" "$PDECL/app.txt")"; rc=$?
  [ "$rc" = 0 ] && ok "prose that mentions the phase field is not the declaration" \
                || bad "prose that mentions the phase field is not the declaration (exit $rc)"

  # The arm that separates "the first declaration decides" from "any line that starts with the field":
  # a quoted example at margin zero survives an anchored pattern and would still raise the rail.
  printf '# Task state\n\nbranch: main\nphase: **EXECUTE**\n\n## Decisions\n\n```\nphase: **UNDERSTAND**\n```\n' \
    > "$PDECL/.ai-flow/artifacts/prose/state.md"
  out="$(wguard "$PDECL" "$PDECL/app.txt")"; rc=$?
  [ "$rc" = 0 ] && ok "a declaration quoted below the first one is not read" \
                || bad "a declaration quoted below the first one is not read (exit $rc)"

  # The accepted form carries its colon, exactly as the branch field does. Asserted because the
  # narrowing is silent: without this, the form nothing documents keeps working by accident.
  printf '# Task state\n\nbranch: main\nphase **UNDERSTAND**\n' > "$PDECL/.ai-flow/artifacts/prose/state.md"
  out="$(wguard "$PDECL" "$PDECL/app.txt")"; rc=$?
  [ "$rc" = 0 ] && ok "a phase written without its colon is not a declaration" \
                || bad "a phase written without its colon is not a declaration (exit $rc)"

  # --- the file judged is the one the session names ------------------------
  # Every other path in the guard is resolved against the working directory the payload declares; the
  # written path was resolved against the guard's own. From a foreign directory a relative path lands
  # outside the project and the write is waved through; from a subdirectory a ledger write is blocked
  # and the message names a file that does not exist.
  PREL="$T11/prel"; mkproj "$PREL" main
  mkdir -p "$PREL/.ai-flow/artifacts/rel" "$PREL/sub" "$T11/foreign"
  printf 'branch: main\nphase: **UNDERSTAND**\n' > "$PREL/.ai-flow/artifacts/rel/state.md"
  out="$( cd "$T11/foreign" && wguard "$PREL" "app.txt" )"; rc=$?
  [ "$rc" = 2 ] && ok "a relative code write is judged against the session's directory" \
                || bad "a relative code write is judged against the session's directory (exit $rc)"
  case "$out" in
    *"'app.txt'"*) ok "the block names the path the session would have written" ;;
    *) bad "the block names the path the session would have written" ;;
  esac
  out="$( cd "$PREL/sub" && wguard "$PREL" ".ai-flow/artifacts/rel/notes.md" )"; rc=$?
  [ "$rc" = 0 ] && ok "a relative ledger write is allowed from a foreign working directory" \
                || bad "a relative ledger write is allowed from a foreign working directory (exit $rc)"

  # --- the protective direction of "the first declaration wins" -----------
  # Three arms above prove the rail LIFTS where it used to block. This one proves it still blocks, and it
  # is the arm that separates "the first declaration decides" from "the declaration decides if it is the
  # only one": a reader keyed on uniqueness passes every other assertion in this file, because every
  # blocking fixture declares exactly one phase — and then goes silent on the ordinary shape of a real
  # sheet, a task under investigation whose own decisions reproduce the field's syntax. That is this
  # task's defect inverted, a leak where the original was a false block.
  printf '# Task state\n\nbranch: main\nphase: **UNDERSTAND**\n\n## Decisions\n\n- the phase: **EXECUTE** line is what the close will write\n\n```\nphase: **EXECUTE**\n```\n' \
    > "$PDECL/.ai-flow/artifacts/prose/state.md"
  out="$(wguard "$PDECL" "$PDECL/app.txt")"; rc=$?
  [ "$rc" = 2 ] && ok "a first declaration of UNDERSTAND still raises the rail past later declarations" \
                || bad "a first declaration of UNDERSTAND still raises the rail past later declarations (exit $rc)"
  case "$out" in
    *"artifacts/prose/state.md"*) ok "the rail names the sheet it read, not the line it matched" ;;
    *) bad "the rail names the sheet it read, not the line it matched" ;;
  esac

  # --- what the accepted form does and does not require --------------------
  # The rule says the label and its colon are load-bearing and the asterisks and case are house style.
  # Both directions asserted, because both were unpinned: the pattern's tolerance could be narrowed and
  # the prose's claim widened, each with the suite green.
  printf '# Task state\n\nbranch: main\nphase: understand\n' > "$PDECL/.ai-flow/artifacts/prose/state.md"
  out="$(wguard "$PDECL" "$PDECL/app.txt")"; rc=$?
  [ "$rc" = 2 ] && ok "the case of the phase name is not load-bearing" \
                || bad "the case of the phase name is not load-bearing (exit $rc)"
  printf '# Task state\n\nbranch: main\nphase: UNDERSTAND\n' > "$PDECL/.ai-flow/artifacts/prose/state.md"
  out="$(wguard "$PDECL" "$PDECL/app.txt")"; rc=$?
  [ "$rc" = 2 ] && ok "the emphasis around the phase name is not load-bearing" \
                || bad "the emphasis around the phase name is not load-bearing (exit $rc)"

  # The Spanish legacy label sat inside the alternation this task rewrote and no fixture had ever
  # written it, in this diff or before it — the protocol now advertises it, so it is exercised.
  PES="$T11/pes"; mkproj "$PES" main
  mkdir -p "$PES/.ai-flow"
  printf 'Fase actual: **UNDERSTAND**\n' > "$PES/.ai-flow/STATE.md"
  out="$(wguard "$PES" "$PES/app.txt")"; rc=$?
  [ "$rc" = 2 ] && ok "the Spanish legacy label declares a phase like the other two" \
                || bad "the Spanish legacy label declares a phase like the other two (exit $rc)"

  # A path the guard cannot resolve is not a repo file it can judge. `resolve()` raises on a symlink
  # loop, which `relative_to`'s ValueError never covered: uncaught, an ordinary write became a traceback
  # with the rail down. Exit 0 is the answer; exit 1 is the defect.
  PLOOP="$T11/ploop"; mkproj "$PLOOP" main
  mkdir -p "$PLOOP/.ai-flow/artifacts/loop"
  printf 'branch: main\nphase: **UNDERSTAND**\n' > "$PLOOP/.ai-flow/artifacts/loop/state.md"
  ln -s b "$PLOOP/a" 2>/dev/null; ln -s a "$PLOOP/b" 2>/dev/null
  out="$(wguard "$PLOOP" "$PLOOP/a/x.py")"; rc=$?
  if [ "$rc" = 0 ]; then
    ok "an unresolvable path answers like any file the guard cannot judge"
  else
    bad "an unresolvable path answers like any file the guard cannot judge (exit $rc)"
  fi
  case "$out" in
    *Traceback*) bad "the guard spills no traceback on an unresolvable path" ;;
    *) ok "the guard spills no traceback on an unresolvable path" ;;
  esac


  PBAD="$T11/pbad"; mkproj "$PBAD" main
  mkdir -p "$PBAD/.ai-flow/artifacts/bad"
  printf 'branch: main\nphase: **UNDERSTAND**\n' > "$PBAD/.ai-flow/artifacts/bad/state.md"

  # The oldest arm of the promise at the top of that function, and the one nothing had ever sent: every
  # fixture in this file was a JSON object, so the check could be deleted and the suite would not notice.
  malformed "a top-level payload that is not an object is waved through without a traceback" \
    '["x"]'
  malformed "a tool_input that is not an object is waved through without a traceback" \
    "{\"cwd\":\"$PBAD\",\"tool_input\":\"oops\"}"
  malformed "a cwd that is not a string is waved through without a traceback" \
    "{\"cwd\":123,\"tool_input\":{\"file_path\":\"$PBAD/app.txt\"}}"
  malformed "a file_path that is not a string is waved through without a traceback" \
    "{\"cwd\":\"$PBAD\",\"tool_input\":{\"file_path\":7}}"
  # The other half of the same test, fused into one condition and only half asserted. Dropping it is not
  # a traceback but a block naming nothing: an empty path resolves to the project root, whose relative
  # form has no first part to compare against the ledger directory.
  malformed "an empty file_path is waved through and blocks nothing" \
    "{\"cwd\":\"$PBAD\",\"tool_input\":{\"file_path\":\"\"}}"

  # The other arm of the directory check, and the one that keeps the rail alive. Nothing pinned it —
  # every fixture in this file declares a directory — so the check could be widened to stand aside on a
  # field that is merely absent, and the rail would go silent for that whole shape with the suite green.
  out="$( cd "$PBAD" && wraw "{\"tool_input\":{\"file_path\":\"app.txt\"}}" )"; rc=$?
  [ "$rc" = 2 ] && ok "a payload declaring no directory is judged against the one the hook runs in" \
                || bad "a payload declaring no directory is judged against the one the hook runs in (exit $rc)"

  # The control, and it sits in the same project as the three above on purpose. Without it all three
  # are satisfied by a guard that exits 0 unconditionally, and their verdict would be borrowed from a
  # section elsewhere in this file — which is no verdict at all. Green before the fix by design: what
  # establishes it is the mutation that makes the guard wave everything through, not a red baseline.
  out="$(wguard "$PBAD" "$PBAD/app.txt")"; rc=$?
  [ "$rc" = 2 ] && ok "the same project still blocks a well-formed code write" \
                || bad "the same project still blocks a well-formed code write (exit $rc)"
  # The contract promises the block AND the naming over this same project. Asserting the naming only
  # against a fixture elsewhere in this file is the borrowed verdict the paragraph above rejects.
  case "$out" in
    *"artifacts/bad/state.md"*) ok "and that block names the sheet it read, in this same fixture" ;;
    *) bad "and that block names the sheet it read, in this same fixture" ;;
  esac
else
  echo "  [skip] read-only rail checks (python3 unavailable)"
fi


if [ "$PY3" = 1 ]; then
  P5="$T11/p5"; mkproj "$P5" main
  mkdir -p "$P5/.ai-flow"; printf 'Current phase: **EXECUTE**\n' > "$P5/.ai-flow/STATE.md"
  nlines 200 > "$P5/big.txt"
  out="$(brake "$P5")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *"step ceiling"*) ok "step ceiling fires on a large uncommitted change" ;;
      *) bad "step ceiling fires on a large uncommitted change (fires, but does not name the step ceiling)" ;;
    esac
  else
    bad "step ceiling fires on a large uncommitted change (exit $rc)"
  fi

  P6="$T11/p6"; mkproj "$P6" main
  mkdir -p "$P6/.ai-flow"; printf 'Current phase: **EXECUTE**\n' > "$P6/.ai-flow/STATE.md"
  $GIT -C "$P6" checkout -q -b feat
  nlines 500 > "$P6/feature.txt"
  $GIT -C "$P6" add app.txt feature.txt >/dev/null 2>&1
  $GIT -C "$P6" commit -q -m feature
  out="$(brake "$P6")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *"task ceiling"*) ok "task ceiling fires on a large committed branch" ;;
      *) bad "task ceiling fires on a large committed branch (fires, but does not name the task ceiling)" ;;
    esac
  else
    bad "task ceiling fires on a large committed branch (exit $rc)"
  fi

  P7="$T11/p7"; mkproj "$P7" main
  mkdir -p "$P7/.ai-flow"; printf 'Current phase: **EXECUTE**\n' > "$P7/.ai-flow/STATE.md"
  $GIT -C "$P7" checkout -q -b feat
  nlines 500 > "$P7/FooTest.kt"
  $GIT -C "$P7" add FooTest.kt >/dev/null 2>&1
  $GIT -C "$P7" commit -q -m tests
  nlines 200 > "$P7/bar_test.go"
  out="$(brake "$P7")"; rc=$?
  [ "$rc" = 0 ] && ok "non-JS test suites are excluded from both counts" \
                || bad "non-JS test suites are excluded from both counts (exit $rc)"

  P8="$T11/p8"; mkproj "$P8" wip
  mkdir -p "$P8/.ai-flow"; printf 'Current phase: **EXECUTE**\n' > "$P8/.ai-flow/STATE.md"
  nlines 500 > "$P8/orphan.txt"
  $GIT -C "$P8" add orphan.txt >/dev/null 2>&1
  $GIT -C "$P8" commit -q -m orphan
  out="$(brake "$P8")"; rc=$?
  [ "$rc" = 0 ] && ok "no base ref leaves the task ceiling out of play" \
                || bad "no base ref leaves the task ceiling out of play (exit $rc)"
  nlines 200 > "$P8/wip.txt"
  out="$(brake "$P8")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *"step ceiling"*) ok "no base ref leaves the step ceiling alone" ;;
      *) bad "no base ref leaves the step ceiling alone (fires, but does not name the step ceiling)" ;;
    esac
  else
    bad "no base ref leaves the step ceiling alone (exit $rc)"
  fi
else
  echo "  [skip] diff brake checks (python3 unavailable)"
fi

# --- the file-size note --------------------------------------------------
# A third measure beside the two ceilings: the size a touched file ends up at. It is a note, never a
# ceiling, and it now sits at its own event — the ceilings refuse at `Stop`, the note is addressed to the
# model and travels at `UserPromptSubmit`, carrying `systemMessage` for the operator and
# `hookSpecificOutput.additionalContext` for the model in one object. The helper DECLARES that event,
# which the ceilings' helper above deliberately does not: an empty payload is the ceilings' occasion, and
# a helper that declared nothing would exercise the refusing half while claiming to measure the note.
# Channels are asserted separately here because the two are the contract: the combined-output helper
# above cannot tell a note that blocked from one that did not.
brake_out() { ( cd "$1" && printf '{"hook_event_name":"UserPromptSubmit"}' | python3 "$HK/diff-size-guard.py" 2>"$T11/note-err" ); }

if [ "$PY3" = 1 ]; then
  N1="$T11/n1"; mkbig "$N1" big.py 1050
  nlines 10 >> "$N1/big.py"
  out="$(brake_out "$N1")"; rc=$?
  if [ "$rc" = 0 ] && printf '%s' "$out" | grep -q 'systemMessage' \
     && printf '%s' "$out" | grep -q 'big.py' && printf '%s' "$out" | grep -q '1060'; then
    ok "A1 the brake notes a grown large file without blocking"
  else
    bad "A1 the brake notes a grown large file without blocking (exit $rc, stdout: ${out:-<empty>})"
  fi

  # Run again over the same file at the same size: the record lives in the git dir, never the tree.
  out2="$(brake_out "$N1")"; rc2=$?
  if [ "$rc2" = 0 ] && ! printf '%s' "$out2" | grep -q 'systemMessage' \
     && [ -f "$N1/.git/ai-flow-diff-guard-ack" ] && ! [ -e "$N1/ai-flow-diff-guard-ack" ]; then
    ok "A6 the note speaks once per file"
  else
    bad "A6 the note speaks once per file (exit $rc2, stdout: ${out2:-<empty>})"
  fi

  N2="$T11/n2"; mkbig "$N2" big.py 1050
  head -n 1030 "$N2/big.py" > "$N2/big.tmp" && mv "$N2/big.tmp" "$N2/big.py"
  out="$(brake_out "$N2")"; rc=$?
  if [ "$rc" = 0 ] && ! printf '%s' "$out" | grep -q 'systemMessage'; then
    ok "A2 a trimmed large file draws no note"
  else
    bad "A2 a trimmed large file draws no note (exit $rc, stdout: ${out:-<empty>})"
  fi

  N3="$T11/n3"; mkbig "$N3" tests/big_test.py 1050
  nlines 10 >> "$N3/tests/big_test.py"
  out="$(brake_out "$N3")"; rc=$?
  if [ "$rc" = 0 ] && ! printf '%s' "$out" | grep -q 'systemMessage'; then
    ok "A3 a large test file draws no note"
  else
    bad "A3 a large test file draws no note (exit $rc, stdout: ${out:-<empty>})"
  fi

  N4="$T11/n4"; mkbig "$N4" mod.py 60
  printf 'name: n4\nlarge_file_lines: 50\n' > "$N4/.ai-flow/project.yml"
  nlines 5 >> "$N4/mod.py"
  out="$(brake_out "$N4")"; rc=$?
  if [ "$rc" = 0 ] && printf '%s' "$out" | grep -q 'systemMessage' && printf '%s' "$out" | grep -q 'mod.py'; then
    ok "A4 the project layer sets the threshold"
  else
    bad "A4 the project layer sets the threshold (exit $rc, stdout: ${out:-<empty>})"
  fi

  # A5 -- RE-KEYED. It required the note to ride the ceiling's stderr line, and that merge is GONE with
  # the event split: the note has a channel of its own, so it is never on the refusing run's stream to be
  # lost, and the merge was the one delivery that laid no mark. What replaces it is the separation the
  # split creates, which nothing else here would notice: on ONE fixture breaching both, each half speaks
  # at its own event and neither carries the other's report.
  N5="$T11/n5"; mkbig "$N5" big.py 1050
  nlines 200 >> "$N5/big.py"
  a5n=""
  out="$(brake "$N5")"; rc=$?
  [ "$rc" = 2 ] || a5n="$a5n [the ceiling no longer refuses at its own event (exit $rc)]"
  printf '%s' "$out" | grep -q 'step ceiling' || a5n="$a5n [the refusal does not name the ceiling]"
  printf '%s' "$out" | grep -q 'big.py' && a5n="$a5n [the refusal still carries the note, which now has a channel of its own]"
  out="$(brake_out "$N5")"; rc=$?; err="$(cat "$T11/note-err")"
  [ "$rc" = 0 ] || a5n="$a5n [the note refused at its own event, where a refusal blocks the prompt (exit $rc)]"
  printf '%s' "$out" | grep -q 'big.py' || a5n="$a5n [the note is lost on a change that also breaches a ceiling]"
  printf '%s' "$out" | grep -q 'additionalContext' || a5n="$a5n [the note reaches the operator but not the model]"
  [ -z "$err" ] || a5n="$a5n [the note wrote to stderr, which is discarded at exit 0]"
  [ -z "$a5n" ] && ok "A5 a ceiling and a note in one change speak at their own events, neither carrying the other" \
                || bad "A5 a ceiling and a note in one change speak at their own events, neither carrying the other ($a5n)"

  # A13 -- an event this hook cannot place is not an occasion to block anything.
  #
  # The ceilings refuse at `Stop`, where a refusal costs a turn-close. This hook is registered at the
  # prompt event too, and there the same exit 2 stops the operator's message from being sent -- over a
  # report whose remedy is not bounded by the turn. So a payload that ARRIVED and could not be read must
  # not reach the refusing half at all: it cannot say which event it is at, and only one of the two can
  # absorb a block.
  #
  # The row exists because the change that introduced this had NO row. Both halves of the split were
  # written together, the sibling guardian's half was covered by C55 A4, and this one was covered by
  # nothing -- proved by making the hook refuse at every event and watching the whole suite stay green.
  # Two legs pulling opposite ways, because the negative alone is satisfied by a hook that stopped
  # refusing anywhere at all, which is the same defect with the blast radius inverted.
  N13="$T11/n13"; mkbig "$N13" big.py 1050
  nlines 200 >> "$N13/big.py"
  a13=""
  o13="$( cd "$N13" && printf '{"stop_hook_active":true' | python3 "$HK/diff-size-guard.py" 2>&1 )"; rc13=$?
  [ "$rc13" = 0 ] \
    || a13="$a13 [an unplaceable payload reached the refusing half, which at the note's event costs the operator their prompt (exit $rc13)]"
  o13c="$(brake "$N13")"; rc13c=$?
  [ "$rc13c" = 2 ] \
    || a13="$a13 [CONTROL: the ceiling no longer refuses at the event where refusing IS possible (exit $rc13c)]"
  printf '%s' "$o13c" | grep -q 'step ceiling' \
    || a13="$a13 [CONTROL: the refusal at Stop no longer names the ceiling it broke]"
  [ -z "$a13" ] && ok "A13 an event the hook cannot place is not an occasion to block" \
                || bad "A13 an event the hook cannot place is not an occasion to block ($a13)"

  # Derived from the hook's own source: rename the key or change the default there and this row names
  # every home that lags. The default is accepted in either spelling the prose uses (1000 / 1,000).
  NKEY="$(sed -n "s/^THRESHOLD_KEY = ['\"]\([a-z_]*\)['\"].*/\1/p" "$HK/diff-size-guard.py" | head -1)"
  NDEF="$(sed -n 's/^FILE_THRESHOLD = \([0-9]*\).*/\1/p' "$HK/diff-size-guard.py" | head -1)"
  NDEFC="$(printf '%s' "$NDEF" | sed 's/\([0-9]\)\([0-9][0-9][0-9]\)$/\1,\2/')"
  miss7=""
  [ -n "$NKEY" ] || miss7="$miss7 [the hook declares no THRESHOLD_KEY]"
  [ -n "$NDEF" ] || miss7="$miss7 [the hook declares no FILE_THRESHOLD]"
  for h7 in template/.ai-flow/project.yml docs/customization.md global/hooks/README.md global/protocols/execute.md; do
    [ -n "$NKEY" ] && { grep -q "$NKEY" "$h7" || miss7="$miss7 $h7(key)"; }
    [ -n "$NDEF" ] && { grep -q -e "$NDEF" -e "$NDEFC" "$h7" || miss7="$miss7 $h7(default)"; }
  done
  [ -n "$NKEY" ] && { grep -q "^# $NKEY:" template/.ai-flow/project.yml || miss7="$miss7 template(commented-key)"; }
  [ -z "$miss7" ] && ok "A7 the key the hook reads is the key the template and the docs show" \
                  || bad "A7 the key the hook reads is the key the template and the docs show (missing:$miss7)"

  # An untracked file is every line an addition; the note must see it although no diff does.
  N8="$T11/n8"; mkbig "$N8" mod.py 5
  printf 'name: n8\nlarge_file_lines: 50\n' > "$N8/.ai-flow/project.yml"
  nlines 60 > "$N8/new.py"
  out="$(brake_out "$N8")"; rc=$?
  if [ "$rc" = 0 ] && printf '%s' "$out" | grep -q 'systemMessage' && printf '%s' "$out" | grep -q 'new.py' \
     && printf '%s' "$out" | grep -q '60'; then
    ok "A8 a new large file draws the note although no diff sees it"
  else
    bad "A8 a new large file draws the note although no diff sees it (exit $rc, stdout: ${out:-<empty>})"
  fi

  # Re-speaking, both directions, on N4 (threshold 50, mod.py at 65 and recorded): a step's worth of growth
  # or less stays silent; past it the note returns and the record moves to the new count.
  #
  # The record's line is still `count<TAB>key`, but the key now carries the SCOPE its measure resets on --
  # here `file:<fingerprint of the open task folders>:<path>`. The fingerprint is not spelled out: this
  # row pins that the count moved and that the entry belongs to the file, and pinning the digest of an
  # empty artifacts directory would make it a test of the hash function.
  $GIT -C "$N4" add -A >/dev/null 2>&1; $GIT -C "$N4" commit -q -m grown
  nlines 100 >> "$N4/mod.py"
  out="$(brake_out "$N4")"; rc=$?
  if [ "$rc" = 0 ] && ! printf '%s' "$out" | grep -q 'systemMessage'; then
    ok "A9 a recorded file grown by less than a step's worth stays silent"
  else
    bad "A9 a recorded file grown by less than a step's worth stays silent (exit $rc, stdout: ${out:-<empty>})"
  fi
  $GIT -C "$N4" add -A >/dev/null 2>&1; $GIT -C "$N4" commit -q -m grown2
  nlines 60 >> "$N4/mod.py"
  out="$(brake_out "$N4")"; rc=$?
  if [ "$rc" = 0 ] && printf '%s' "$out" | grep -q 'systemMessage' && printf '%s' "$out" | grep -q '225' \
     && grep -q "^225	file:[0-9a-f]*:mod\.py$" "$N4/.git/ai-flow-diff-guard-ack"; then
    ok "A10 a recorded file grown past a step's worth speaks again and the record moves"
  else
    bad "A10 a recorded file grown past a step's worth speaks again and the record moves (exit $rc, stdout: ${out:-<empty>})"
  fi

  # No base to resolve: the note judges the step's files, and a key nested under another mapping is not
  # the threshold — with it honoured (2000) this file would be silent.
  N11="$T11/n11"; mkproj "$N11" wip
  mkdir -p "$N11/.ai-flow"; printf 'Current phase: **EXECUTE**\n' > "$N11/.ai-flow/STATE.md"
  printf 'name: n11\ncommands:\n  large_file_lines: 2000\n' > "$N11/.ai-flow/project.yml"
  nlines 1050 > "$N11/big.py"
  $GIT -C "$N11" add -A >/dev/null 2>&1; $GIT -C "$N11" commit -q -m big
  nlines 10 >> "$N11/big.py"
  out="$(brake_out "$N11")"; rc=$?
  if [ "$rc" = 0 ] && printf '%s' "$out" | grep -q 'systemMessage' && printf '%s' "$out" | grep -q '1060'; then
    ok "A11 with no base the note judges the step's files, and a nested key is not the threshold"
  else
    bad "A11 with no base the note judges the step's files, and a nested key is not the threshold (exit $rc, stdout: ${out:-<empty>})"
  fi

  # A rename in a committed step reaches numstat as `old => new`; the note must open the new path.
  N12="$T11/n12"; mkbig "$N12" big.py 1050
  $GIT -C "$N12" mv big.py big2.py; nlines 10 >> "$N12/big2.py"
  $GIT -C "$N12" add -A >/dev/null 2>&1; $GIT -C "$N12" commit -q -m rename
  out="$(brake_out "$N12")"; rc=$?
  if [ "$rc" = 0 ] && printf '%s' "$out" | grep -q 'systemMessage' && printf '%s' "$out" | grep -q 'big2.py'; then
    ok "A12 a renamed and grown large file is judged at its new path"
  else
    bad "A12 a renamed and grown large file is judged at its new path (exit $rc, stdout: ${out:-<empty>})"
  fi
else
  echo "  [skip] file-size note checks (python3 unavailable)"
fi

# --- the ledger guardian ------------------------------------------------
# A state file a reader would recognise as a real ledger, carrying the one thing the invariant forbids:
# a closed-epic narrative outside the sanctioned sections. The previous fixture was the bare string the
# retired phrase list happened to match, so the five rows below could keep passing while proving nothing
# about detection — two of them expect exit 0 and would have passed on a file that triggers nothing.
mkviolstate() {  # $1 = the project's .ai-flow directory
  {
    printf '# Session State\n\n## Workstreams\n\n'
    printf '| Workstream | Checkout | Task | Epic | Areas | Tool | Opened |\n'
    printf '|---|---|---|---|---|---|---|\n'
    printf '| coordinator | . | T-100 | E-009 | auth | - | 2026-08-01 |\n\n'
    printf '## Notes\n\n'
    printf '**Epic E-007 (payments overhaul) CLOSED 2026-07-30.** Sealed decisions: `archive/E-007-payments.md`.\n\n'
    printf '## Quick Tasks Completed\n\n| Date | Description | Commit |\n|------|-------------|--------|\n'
  } > "$1/STATE.md"
}
P9="$T11/p9"; mkproj "$P9" main
mkdir -p "$P9/.ai-flow"
mkviolstate "$P9/.ai-flow"
printf '# Backlog\n'                > "$P9/.ai-flow/BACKLOG.md"
W9="$T11/w9"; $GIT -C "$P9" worktree add -q -b wt9 "$W9" >/dev/null 2>&1
cp -R "$P9/.ai-flow" "$W9/.ai-flow"   # models what .worktreeinclude will copy
( cd "$W9" && bash "$HK/check-state-size.sh" >/dev/null 2>&1 ); rc=$?
[ "$rc" = 0 ] && ok "ledger guardian is silent in a linked worktree" \
              || bad "ledger guardian is silent in a linked worktree (exit $rc)"
( cd "$P9" && bash "$HK/check-state-size.sh" >/dev/null 2>&1 ); rc=$?
[ "$rc" = 2 ] && ok "guardian still blocks in the main copy" \
              || bad "guardian still blocks in the main copy (exit $rc)"

# --- a project with no git at all ---------------------------------------
NG="$T11/nogit"; mkdir -p "$NG/.ai-flow"
printf 'Current phase: **UNDERSTAND**\n' > "$NG/.ai-flow/STATE.md"
printf '# Backlog\n' > "$NG/.ai-flow/BACKLOG.md"
printf 'x\n' > "$NG/app.txt"
if [ "$PY3" = 1 ]; then
  out="$(wguard "$NG" "$NG/app.txt")"; rc=$?
  [ "$rc" = 2 ] && ok "write rail still applies with no git repository" \
                || bad "write rail still applies with no git repository (exit $rc)"
  out="$(brake "$NG")"; rc=$?
  [ "$rc" = 0 ] && ok "diff brake stays out of the way with no git repository" \
                || bad "diff brake stays out of the way with no git repository (exit $rc)"
fi
mkviolstate "$NG/.ai-flow"
( cd "$NG" && bash "$HK/check-state-size.sh" >/dev/null 2>&1 ); rc=$?
[ "$rc" = 2 ] && ok "ledger guardian still applies with no git repository" \
              || bad "ledger guardian still applies with no git repository (exit $rc)"

# --- the engine drift guard ---------------------------------------------
E11="$T11/engine"; mkproj "$E11" main
mkdir -p "$E11/global/hooks"; printf 'v1\n' > "$E11/global/hooks/x.sh"
$GIT -C "$E11" add global >/dev/null 2>&1; $GIT -C "$E11" commit -q -m engine
WE="$T11/engine-wt"; $GIT -C "$E11" worktree add -q -b eng "$WE" >/dev/null 2>&1
printf 'v2\n' > "$WE/global/hooks/x.sh"
$GIT -C "$WE" add global >/dev/null 2>&1; $GIT -C "$WE" commit -q -m engine-v2
TH11="$T11/home"; mkdir -p "$TH11/.claude/ai-flow" "$TH11/.claude/hooks"
printf '%s\n' "$E11" > "$TH11/.claude/ai-flow/source.path"
printf 'v2\n' > "$TH11/.claude/hooks/x.sh"   # installed matches the worktree's HEAD
( cd "$WE" && HOME="$TH11" bash "$HK/drift-check.sh" >/dev/null 2>&1 <<<'{}' ); rc=$?
[ "$rc" = 0 ] && ok "drift guard compares against the working copy's HEAD" \
              || bad "drift guard compares against the working copy's HEAD (exit $rc)"
printf 'v3\n' > "$WE/global/hooks/x.sh"      # uncommitted engine change in the worktree
printf 'v9\n' > "$TH11/.claude/hooks/x.sh"   # installed matches nothing
( cd "$WE" && HOME="$TH11" bash "$HK/drift-check.sh" >/dev/null 2>&1 <<<'{}' ); rc=$?
[ "$rc" = 0 ] && ok "drift guard is quiet on the working copy's WIP" \
              || bad "drift guard is quiet on the working copy's WIP (exit $rc)"

# --- gaps closed after the multi-agent review --------------------------------
# the guardian must survive a subdirectory cwd (git answers --git-dir absolute, --git-common-dir relative)
P10="$T11/p10"; mkproj "$P10" main
mkdir -p "$P10/.ai-flow" "$P10/sub"
mkviolstate "$P10/.ai-flow"
( cd "$P10/sub" && bash "$HK/check-state-size.sh" >/dev/null 2>&1 ); rc=$?
[ "$rc" = 2 ] && ok "guardian still blocks from a subdirectory of the main copy" \
              || bad "guardian still blocks from a subdirectory of the main copy (exit $rc)"
W10="$T11/w10"; $GIT -C "$P10" worktree add -q -b wt10 "$W10" >/dev/null 2>&1
cp -R "$P10/.ai-flow" "$W10/.ai-flow"; mkdir -p "$W10/sub"
( cd "$W10/sub" && bash "$HK/check-state-size.sh" >/dev/null 2>&1 ); rc=$?
[ "$rc" = 0 ] && ok "guardian stays silent from a subdirectory of a linked worktree" \
              || bad "guardian stays silent from a subdirectory of a linked worktree (exit $rc)"

if [ "$PY3" = 1 ]; then
  # a worktree nested inside its own primary must not be judged by the primary's ledger
  P11="$T11/p11"; mkproj "$P11" main
  mkdir -p "$P11/.ai-flow"
  printf 'Current phase: **UNDERSTAND**\n' > "$P11/.ai-flow/STATE.md"
  NEST="$P11/.claude/worktrees/w1"
  $GIT -C "$P11" worktree add -q -b nested "$NEST" >/dev/null 2>&1
  out="$(wguard "$NEST" "$NEST/app.txt")"; rc=$?
  [ "$rc" = 0 ] && ok "a nested worktree is not bound to the enclosing ledger" \
                || bad "a nested worktree is not bound to the enclosing ledger (exit $rc)"

  # several per-task states, or one that is not UNDERSTAND, hand the question back
  P12="$T11/p12"; mkproj "$P12" main
  mkdir -p "$P12/.ai-flow/artifacts/one" "$P12/.ai-flow/artifacts/two"
  printf 'Current phase: **EXECUTE**\n'  > "$P12/.ai-flow/STATE.md"
  printf 'phase: **UNDERSTAND**\n'       > "$P12/.ai-flow/artifacts/one/state.md"
  printf 'phase: **EXECUTE**\n'          > "$P12/.ai-flow/artifacts/two/state.md"
  out="$(wguard "$P12" "$P12/app.txt")"; rc=$?
  [ "$rc" = 0 ] && ok "several per-task states defer to the ledger phase" \
                || bad "several per-task states defer to the ledger phase (exit $rc)"
  P13="$T11/p13"; mkproj "$P13" main
  mkdir -p "$P13/.ai-flow/artifacts/one"
  printf 'Current phase: **UNDERSTAND**\n' > "$P13/.ai-flow/STATE.md"
  printf 'phase: **EXECUTE**\n'            > "$P13/.ai-flow/artifacts/one/state.md"
  out="$(wguard "$P13" "$P13/app.txt")"; rc=$?
  [ "$rc" = 0 ] && ok "a per-task state past UNDERSTAND lifts the rail" \
                || bad "a per-task state past UNDERSTAND lifts the rail (exit $rc)"

  # production files that merely end in "test" are not test files
  P14="$T11/p14"; mkproj "$P14" main
  mkdir -p "$P14/.ai-flow"; printf 'Current phase: **EXECUTE**\n' > "$P14/.ai-flow/STATE.md"
  nlines 200 > "$P14/Latest.cs"
  out="$(brake "$P14")"; rc=$?
  [ "$rc" = 2 ] && ok "a production file ending in test still counts" \
                || bad "a production file ending in test still counts (exit $rc)"

  # the task ceiling speaks once, not every turn
  out="$(brake "$P6")"; rc=$?
  [ "$rc" = 0 ] && ok "the task ceiling stays quiet once acknowledged" \
                || bad "the task ceiling stays quiet once acknowledged (exit $rc)"

  # the base ref that real projects use: the remote's default branch
  P15="$T11/p15"; mkproj "$P15" main
  mkdir -p "$P15/.ai-flow"; printf 'Current phase: **EXECUTE**\n' > "$P15/.ai-flow/STATE.md"
  base_sha="$($GIT -C "$P15" rev-parse HEAD)"
  $GIT -C "$P15" update-ref refs/remotes/origin/main "$base_sha"
  $GIT -C "$P15" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main
  $GIT -C "$P15" checkout -q -b feat
  nlines 500 > "$P15/feature.txt"
  $GIT -C "$P15" add feature.txt >/dev/null 2>&1; $GIT -C "$P15" commit -q -m feature
  out="$(brake "$P15")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *"origin/main"*) ok "the task ceiling measures against the remote default branch" ;;
      *) bad "the task ceiling measures against the remote default branch (fired against something else)" ;;
    esac
  else
    bad "the task ceiling measures against the remote default branch (exit $rc)"
  fi

  # a dangling origin/HEAD must fall back, not switch the ceiling off
  P16="$T11/p16"; mkproj "$P16" main
  mkdir -p "$P16/.ai-flow"; printf 'Current phase: **EXECUTE**\n' > "$P16/.ai-flow/STATE.md"
  $GIT -C "$P16" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/gone
  $GIT -C "$P16" checkout -q -b feat
  nlines 500 > "$P16/feature.txt"
  $GIT -C "$P16" add feature.txt >/dev/null 2>&1; $GIT -C "$P16" commit -q -m feature
  out="$(brake "$P16")"; rc=$?
  [ "$rc" = 2 ] && ok "a dangling remote default falls back instead of disabling the ceiling" \
                || bad "a dangling remote default falls back instead of disabling the ceiling (exit $rc)"
fi

# real drift is still reported: the installed engine matches no checkout
$GIT -C "$WE" add global >/dev/null 2>&1; $GIT -C "$WE" commit -q -m engine-v3
printf 'v9\n' > "$TH11/.claude/hooks/x.sh"
( cd "$WE" && HOME="$TH11" bash "$HK/drift-check.sh" >/dev/null 2>&1 <<<'{}' ); rc=$?
[ "$rc" = 2 ] && ok "drift guard still reports an engine that matches no checkout" \
              || bad "drift guard still reports an engine that matches no checkout (exit $rc)"

rm -rf "$T11"
