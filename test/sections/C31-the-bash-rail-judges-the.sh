echo "== C31: the Bash rail judges the fields it can read =="
# A sandbox of this block's own. It used to read the one C11 opens, which is why this section could
# not be asked for on its own: under a filter C11 never runs and every path below collapses to "/".
T11="$(mkbox)" || fatal 'C31 fixtures'
# The first behavioural coverage this rail has ever had. Until now the only assertions naming it counted
# its entry in settings.json, which is installer structure — so there was no positive control anywhere in
# this file to borrow, and A4 builds one here, in the same fixture as the payload checks. That control is
# load-bearing rather than decorative: "exit 0, no traceback" is satisfied by a rail that exits 0
# unconditionally, and going quiet, not crashing, is this rail's real failure mode.
#
# Scope: the payload the rail reads, and nothing about how it matches a command. The matcher is a task of
# its own; three audit passes established that judging a shell command by pattern needs more than this
# section can hold, and the evidence went back to the backlog with it.
if [ "$PY3" = 1 ]; then
  GS="$HK/git-safety.py"
  gcmd() {  # $1 = command string -> same, wrapped in a well-formed payload
    python3 -c 'import json,sys; print(json.dumps({"tool_input":{"command":sys.argv[1]}}))' "$1" \
      | python3 "$GS" 2>&1
  }


  # The oldest arm of the promise and the one nothing had ever sent: this rail has no dict check at all,
  # so every one of these is a traceback today. `null` and `true` were in nobody's report — the reach of
  # the hardening is measured from what the code reads, not from what was noticed.
  waved "a top-level payload that is not an object is waved through in silence" \
    '["x"]' '"oops"' '7' 'null' 'true'

  # A truthy non-object only: a falsy one (`null`, `[]`, `""`, `0`) already survives through `or {}` and
  # must keep surviving. The line is drawn at the type, not at emptiness.
  waved "a tool_input that is not an object is waved through in silence" \
    '{"tool_input":"oops"}' '{"tool_input":["a"]}' '{"tool_input":7}'

  # Truthy non-strings, which reach the first regex and raise there rather than at the read. `true` is
  # in the set because a bool is not a str and nothing else in this file would have noticed.
  waved "a command that is not a string is waved through in silence" \
    '{"tool_input":{"command":123}}' '{"tool_input":{"command":["git","push"]}}' \
    '{"tool_input":{"command":{"a":1}}}' '{"tool_input":{"command":true}}'

  # The control, and it is the load-bearing assertion of this whole group: without it the three checks
  # above are all satisfied by a rail that exits 0 unconditionally, and their verdict would be borrowed
  # from elsewhere in this file, which is no verdict at all.
  #
  # What it controls for changed with the rail's job. It used to drive a hard force-push, because the
  # rail judged commands; the rail no longer judges any command, so that fixture would now be green for
  # a reason unrelated to what it is named for. The control is the same shape against the new job: a
  # repository with no protection in place, where the rail must refuse and say so. It is driven from a
  # fixture whose state is known rather than from whatever repository this suite happens to run in.
  # A sandboxed HOME as well as a fixture repository: the rail resolves the engine's hook directory from
  # HOME, so a control that leaves it real reads the state of the machine running the suite and inverts
  # once the installer has been run there. The engine copies here are throwaway and executable, so the
  # fixture reaches the question it means to ask instead of stopping at "no engine hooks installed".
  C31H="$T11/c31home"; mkdir -p "$C31H/.claude/hooks/git"
  printf '#!/bin/sh\nexit 0\n' > "$C31H/.claude/hooks/git/pre-push"
  printf '#!/bin/sh\nexit 0\n' > "$C31H/.claude/hooks/git/pre-commit"
  chmod 755 "$C31H/.claude/hooks/git/pre-push" "$C31H/.claude/hooks/git/pre-commit"
  C31R="$T11/c31rail"; mkproj "$C31R" main
  out="$(printf '{"cwd":"%s","tool_input":{"command":"git push origin main"}}' "$C31R" | HOME="$C31H" python3 "$GS" 2>&1)"; rc=$?
  case "$out" in *"not active in this repository"*) said=1 ;; *) said=0 ;; esac
  { [ "$rc" = 2 ] && [ "$said" = 1 ]; } \
    && ok "the same fixture still refuses where the protection is not in place" \
    || bad "the same fixture still refuses where the protection is not in place (exit $rc, said: $out)"
else
  echo "  [skip] Bash rail checks (python3 unavailable)"
fi
