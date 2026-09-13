echo "== C24: a machine-read field is read where it is declared =="
RAIL24="global/hooks/understand-write-guard.py"

# The paragraph that carries the rule, not the subsection around it: a section-wide grep passes on a
# neighbour's words, and the neighbours here are the claim rules that talk about lines and fields too.
# Emphasis marks fall wherever the prose needs them, so a phrase asserted raw can be cut in half by a
# pair of asterisks — the same way the message below is cut by its concatenation boundary. What is
# asserted is what the rule says, never where its typography lands.
PH24="$(awk 'BEGIN{RS=""} /machine-read/{print; exit}' "$BLG24" | tr -s ' \n' '  ' | tr -d '*')"
if [ -n "$PH24" ]; then
  ok "the section that owns the state-file rules states what is machine-read"
  miss24=""
  printf '%s' "$PH24" | grep -qiE 'first line|first such line|first declaration' || miss24="$miss24 first"
  printf '%s' "$PH24" | grep -qiE 'no other|nowhere else|not read|prose'         || miss24="$miss24 rest-is-prose"
  printf '%s' "$PH24" | grep -qi  'colon'                                        || miss24="$miss24 colon"
  printf '%s' "$PH24" | grep -qiE 'roster|STATE.md|never migrated|legacy'        || miss24="$miss24 legacy-label"
  printf '%s' "$PH24" | grep -qiE 'Fase actual'                                  || miss24="$miss24 spanish-label"
  # The sentence that authorises this task's accepted loss: without it the narrowing is a silent one
  # nobody wrote down, which is the accidental silence the standing law forbids. Its four neighbours all
  # stayed green when it was deleted, which is how it got here.
  printf '%s' "$PH24" | grep -qiE 'declares no phase|no phase at all'            || miss24="$miss24 no-phase-consequence"
  # What the form requires versus what it merely prefers. Both directions were unpinned: the pattern's
  # tolerance could be narrowed and the prose's claim widened, each with the suite green.
  printf '%s' "$PH24" | grep -qiE 'load-bearing'                                 || miss24="$miss24 load-bearing"
  printf '%s' "$PH24" | grep -qiE 'house style|not the contract'                  || miss24="$miss24 house-style"
  [ -z "$miss24" ] && ok "the rule states the declaration is the first such line, with its colon, and that nothing else is read" \
                   || bad "the rule states the declaration is the first such line, with its colon, and that nothing else is read (missing:$miss24)"
else
  bad "the section that owns the state-file rules states what is machine-read"
  bad "the rule states the declaration is the first such line, with its colon, and that nothing else is read (no paragraph)"
fi

# The remedy must change the thing the check names. A positive requirement, not a denylist: the message
# names the command that records the phase — every rewording that still sends the operator to the hand
# edit fails the second arm, and one that names nothing fails the first.
# The message is an f-string split across source lines, so the phrase a check looks for is cut by the
# concatenation boundary: matched raw, every arm below would pass on finding nothing. Normalised to the
# prose the operator actually reads before anything is asserted about it.
MSG24="$(sed -n '/^    print($/,/^    )$/p' "$RAIL24" | tr '\n' ' ' | sed 's/f"//g; s/"//g' | tr -s ' ')"
# The remedy the operator is sent to FIRST is the one the check is about, so it is extracted rather than
# searched for: from the trigger to the end of that sentence. Bare `plan` was matched before, which is a
# substring of planning, plan.md and the plan protocol — a message naming no command at all passed.
REM24="${MSG24#*truly needed}"; REM24="${REM24%%. *}"
if [ -n "$MSG24" ] && [ -n "$REM24" ]; then
  if printf '%s' "$REM24" | grep -q 'run the `plan` command' \
     && printf '%s' "$REM24" | grep -qiE 'records the phase|writes the phase'; then
    ok "the block message names the command that moves the phase"
  else
    bad "the block message names the command that moves the phase"
  fi
  # The class, not four phrasings. Scoped to the primary remedy: the wrong-sheet clause below it names a
  # hand correction on purpose, and a ban over the whole message would forbid the case the user asked for.
  # A denylist of exact wordings passed a rewrite that routed the operator to a hand edit verbatim.
  if printf '%s' "$REM24" | grep -qiE 'yourself|manually|by hand|(edit|set|change|update)[^.]{0,20}the phase'; then
    bad "the primary remedy is a command, not an edit the operator makes"
  else
    ok "the primary remedy is a command, not an edit the operator makes"
  fi
  # And the case where the sheet itself is wrong: there the command is the wrong action, and a message
  # that names no route for it sends the operator to do the wrong thing — the defect this epic already
  # closed once, in a smaller form.
  if printf '%s' "$MSG24" | grep -qiE 'not the task you are working' \
     && printf '%s' "$MSG24" | grep -q 'branch:'; then
    ok "the block message names what to do when the sheet it read is the wrong one"
  else
    bad "the block message names what to do when the sheet it read is the wrong one"
  fi
else
  bad "the block message names the command that moves the phase (no message)"
  bad "the primary remedy is a command, not an edit the operator makes (no message)"
  bad "the block message names what to do when the sheet it read is the wrong one (no message)"
fi

# The paragraph that settles which layer wins. It is its own paragraph, so the extractor above cannot
# reach it, and a rule whose authority is unstated is a rule an editor may read as a description.
AUTH24="$(awk 'BEGIN{RS=""} /is the authority/{print; exit}' "$BLG24" | tr -s ' \n' '  ' | tr -d '*')"
if [ -n "$AUTH24" ] \
   && printf '%s' "$AUTH24" | grep -qiE 'note about the enforcer|the enforcer' \
   && printf '%s' "$AUTH24" | grep -qiE 'the pattern is the thing to correct|the rule is what'; then
  ok "the rule is stated as the authority and the pattern as the enforcer's note"
else
  bad "the rule is stated as the authority and the pattern as the enforcer's note"
fi

# The operator-facing catalog row is the layer someone reads when the rail is down and the sheet looks
# right. It spells out the branch ladder in full; the reading rule was the one thing it did not carry.
ROW24="$(grep -m1 '^| .understand-write-guard.py.' global/hooks/README.md | tr -d '*`' | tr -s ' ')"
if [ -n "$ROW24" ] \
   && printf '%s' "$ROW24" | grep -qiE 'first line|first .{0,12}line' \
   && printf '%s' "$ROW24" | grep -qiE 'no other line|any other form'; then
  ok "the guard's catalog row carries the reading rule, not only where the phase is read from"
else
  bad "the guard's catalog row carries the reading rule, not only where the phase is read from"
fi

# The guard's own comment enumerates why a sheet declares no branch, and a released claim is the second
# reason. The README row already carries it; the comment gave one reason where there are two.
CMT24="$(awk 'BEGIN{RS=""} /claiming no branch/{print; exit}' global/hooks/_aiflow_state.py | tr -s ' \n' '  ')"
if [ -n "$CMT24" ] \
   && printf '%s' "$CMT24" | grep -qiE 'before the field|predates the field' \
   && printf '%s' "$CMT24" | grep -qiE 'released|took on another'; then
  ok "the guard's comment names both reasons a sheet declares no branch"
else
  bad "the guard's comment names both reasons a sheet declares no branch"
fi
