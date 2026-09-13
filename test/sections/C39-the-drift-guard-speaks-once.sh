echo "== C39: the drift guard speaks once per request, and its detached-workspace remedy names what it destroys =="
# Conformance rows for the engine drift guard's continuation handling and its front-variant message.
# The guard is exercised, never grepped: every verdict below is this hook's own exit code or its own
# stderr, produced over a fixture where the installed engine genuinely matches no checkout.
T39="$(mktemp -d 2>/dev/null)"
if [ -z "$T39" ] || [ ! -d "$T39" ]; then
  bad "C39 cannot run: mktemp -d failed"
else
  # A trap is global state and setting one REPLACES what an earlier section installed — the rule this
  # file states at C19 and follows at C25. Carry the live paths, and hand the trap back below rather
  # than clearing it: this is the last block, so a cleared trap leaks every earlier sandbox on every run.
  trap 'rm -rf "$T12" "$T13" "$T25" "$T39"' EXIT
  # A clone with an engine, plus a linked worktree of it — the shape that makes the guard's SRC2
  # branch reachable, which is the only branch where the front remedy is ever printed.
  E39="$T39/engine"; mkdir -p "$E39/global/hooks"
  $GIT init -q "$E39" 2>/dev/null
  printf 'v1\n' > "$E39/global/hooks/x.sh"
  $GIT -C "$E39" add global >/dev/null 2>&1; $GIT -C "$E39" commit -q -m engine >/dev/null 2>&1
  W39="$T39/engine-wt"; $GIT -C "$E39" worktree add -q -b eng39 "$W39" >/dev/null 2>&1
  H39="$T39/home"; mkdir -p "$H39/.claude/ai-flow" "$H39/.claude/hooks"
  printf '%s\n' "$E39" > "$H39/.claude/ai-flow/source.path"
  printf 'v9\n' > "$H39/.claude/hooks/x.sh"      # installed matches no checkout -> real drift

  # Delivered through a real pipe, which is the shape a harness uses. A here-string is a temp file and
  # a file is not a pipe: reading one proves nothing about the other, and the read under test is the
  # part that differs between them.
  drift39() {  # $1 = payload; sets out39 / RC39
    out39="$( printf '%s' "$1" | ( cd "$W39" && HOME="$H39" bash "$HK/drift-check.sh" 2>&1 ) )"; RC39=$?
  }

  # A2 first: the fixture must actually be in the state the other rows conclude from. A row asserting
  # silence over a fixture that was never drifted passes for a reason that has nothing to do with the fix.
  drift39 '{}'
  [ "$RC39" = 2 ] && ok "the drift guard still refuses a fresh stop over a drifted engine" \
                  || bad "the drift guard still refuses a fresh stop over a drifted engine (exit $RC39)"

  # The payload production actually sends. Every other row here carries the field ABSENT or true, and
  # absent is a different branch of the decision from present-and-false: with only those, a guard that
  # keyed on the field's NAME and ignored its value would satisfy the whole section while being silenced
  # on every real stop forever. The harness always sends the field, and on a fresh stop it sends false.
  drift39 '{"session_id":"s","transcript_path":"/t","stop_hook_active":false}'
  a2b39=""
  [ "$RC39" = 2 ] || a2b39="$a2b39 [exit $RC39, expected 2]"
  printf '%s' "$out39" | grep -q 'engine drift' || a2b39="$a2b39 [no report was printed]"
  [ -z "$a2b39" ] && ok "the guard refuses when the harness says the stop is a fresh one" \
                  || bad "the guard refuses when the harness says the stop is a fresh one:$a2b39"

  # A1 — the continuation the harness is already re-delivering
  drift39 '{"stop_hook_active":true}'
  a1_39=""
  [ "$RC39" = 0 ] || a1_39="$a1_39 [exit $RC39, expected 0]"
  [ -z "$out39" ] || a1_39="$a1_39 [it still printed a report]"
  [ -z "$a1_39" ] && ok "the drift guard is silent on a stop the harness is re-delivering" \
                  || bad "the drift guard is silent on a stop the harness is re-delivering:$a1_39"

  # The same continuation with a space after the colon — the form any serializer emits by default, and
  # the one a text match tuned to the compact shape silently stops recognising.
  drift39 '{"stop_hook_active": true}'
  [ "$RC39" = 0 ] && ok "the continuation is recognised whatever spacing the payload uses" \
                  || bad "the continuation is recognised whatever spacing the payload uses (exit $RC39)"

  # Malformed input is absent input, and absent reports. A guard deciding by the characters of its
  # payload reads a truncated write, or the field quoted inside another value, as an instruction to go
  # quiet — a false all-clear over an engine that really is undistributed.
  m39=""
  drift39 '{"stop_hook_active":true'
  [ "$RC39" = 2 ] || m39="$m39 [a truncated payload silenced it: exit $RC39]"
  drift39 'error: stop_hook_active: true'
  [ "$RC39" = 2 ] || m39="$m39 [a non-JSON blob silenced it: exit $RC39]"
  drift39 '{"msg":"stop_hook_active true","stop_hook_active":false}'
  [ "$RC39" = 2 ] || m39="$m39 [the field inside another value silenced it: exit $RC39]"
  [ -z "$m39" ] && ok "a payload that is not a well-formed object carrying the field is treated as absent" \
                || bad "a payload that is not a well-formed object carrying the field is treated as absent:$m39"

  # A3 — a payload that never arrives must not become a hung session, AND must not become a silent
  # pass. The wall clock is only half the row: a sentinel written unconditionally proves the process
  # returned and nothing about what it returned, so the exit code is what gets recorded and asserted.
  F39="$T39/fifo"; RCF39="$T39/rc"
  if mkfifo "$F39" 2>/dev/null; then
    ( exec 9>"$F39"; sleep 8 ) &
    holder39=$!
    ( cd "$W39" && HOME="$H39" bash "$HK/drift-check.sh" >/dev/null 2>&1 <"$F39"; echo "$?" > "$RCF39" ) &
    w39=0
    while [ ! -s "$RCF39" ] && [ "$w39" -lt 5 ]; do sleep 1; w39=$((w39+1)); done
    a3_39=""
    if [ ! -s "$RCF39" ]; then
      a3_39="$a3_39 [still waiting after ${w39}s]"
    else
      [ "$(cat "$RCF39")" = 2 ] || a3_39="$a3_39 [it returned $(cat "$RCF39"), not a refusal — a stall was replaced by a false all-clear]"
    fi
    [ -z "$a3_39" ] && ok "the drift guard returns its verdict when the payload never arrives" \
                    || bad "the drift guard returns its verdict when the payload never arrives:$a3_39"
    kill "$holder39" 2>/dev/null; wait 2>/dev/null
  else
    bad "the drift guard returns its verdict when the payload never arrives (no sandbox: mkfifo failed)"
  fi

  # The plain no-stdin case, which is not the same as the one above: here EOF is immediate and the
  # guard must still refuse rather than read the silence as a continuation.
  out39="$( cd "$W39" && HOME="$H39" bash "$HK/drift-check.sh" 2>&1 </dev/null )"; RC39=$?
  n39=""
  [ "$RC39" = 2 ] || n39="$n39 [exit $RC39, expected 2]"
  printf '%s' "$out39" | grep -q 'engine drift' || n39="$n39 [no report was printed]"
  [ -z "$n39" ] && ok "an empty payload is absent input and still refuses" \
                || bad "an empty payload is absent input and still refuses:$n39"

  # A4 — the front remedy is printed only from a linked checkout, and must name the permanent silence.
  drift39 '{}'
  a4_39=""
  printf '%s' "$out39" | grep -q "the checkout this session is in" \
    || a4_39="$a4_39 [the fixture never reached the front branch, so this row proves nothing]"
  # Word-presence alone certifies a mention, not the act: a message that kept offering the front
  # install as an annotated option, with "source.path" and "silent" dropped into the comment beside
  # it, satisfied every keyword this row first asked for. What separates the repair from that is
  # structure and cause, so both are what is asserted -- the consequence stands on its own lines
  # ahead of the command, and the silence is tied to the thing that produces it.
  cmdline39="$(printf '%s\n' "$out39" | grep -n "install\.sh' update" | tail -1 | cut -d: -f1)"
  srcline39="$(printf '%s\n' "$out39" | grep -n 'source\.path' | head -1 | cut -d: -f1)"
  if [ -z "$srcline39" ]; then
    a4_39="$a4_39 [the message does not say the guard's own source gets repointed]"
  elif [ -z "$cmdline39" ] || [ "$srcline39" -ge "$cmdline39" ]; then
    a4_39="$a4_39 [the consequence does not stand ahead of the command it qualifies]"
  fi
  # The command is a last resort, not an entry in a list: an annotation riding on its own line is how
  # it reads as the second column of a choice.
  printf '%s\n' "$out39" | grep "install\.sh' update" | grep -q '#' \
    && a4_39="$a4_39 [the command is still annotated as an option rather than named as a last resort]"
  printf '%s' "$out39" | grep -qiE 'silen(t|ce)' \
    || a4_39="$a4_39 [the message does not name the silence it costs]"
  # A hedge is not a consequence. The silence has a cause -- the closing dismantles the checkout -- and
  # a message that says only "it may go silent" has told the operator nothing they can act on.
  printf '%s' "$out39" | grep -qiE 'dismantl|closes|close ' \
    || a4_39="$a4_39 [the silence is not tied to the checkout being dismantled]"
  printf '%s' "$out39" | grep -q "reverts this checkout's engine commits" \
    && a4_39="$a4_39 [the old sentence still prices the choice by which commits get installed]"
  [ -z "$a4_39" ] && ok "the front remedy names the permanent silence it costs" \
                  || bad "the front remedy names the permanent silence it costs:$a4_39"

  # The ordinary remedy was promised untouched, and nothing asserted it. A4 cannot: its command probe
  # takes the LAST match, so deleting the clone line above leaves every one of its arms satisfied.
  o39=""
  cloneline39="$(printf '%s\n' "$out39" | grep -n "bash '$E39/install.sh' update" | head -1 | cut -d: -f1)"
  [ -n "$cloneline39" ] || o39="$o39 [the clone remedy is gone]"
  [ -n "$cloneline39" ] && [ -n "$cmdline39" ] && [ "$cloneline39" -ge "$cmdline39" ] \
    && o39="$o39 [the clone remedy no longer stands first]"
  [ -z "$o39" ] && ok "the ordinary remedy is still offered, and still first" \
                || bad "the ordinary remedy is still offered, and still first:$o39"

  rm -rf "$T39"
  trap 'rm -rf "$T12" "$T13" "$T25"' EXIT   # handed back to the section that owned it
fi
