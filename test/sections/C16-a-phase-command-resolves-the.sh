echo "== C16: a phase command resolves the task its own checkout owns =="
BLG5="global/protocols/backlog.md"
RAIL="global/hooks/understand-write-guard.py"
PHASE_SKILLS="understand plan execute verify"

# The owner block, bounded at the next heading of any depth: the ladder is ONE fact with ONE home, and
# a section-wide grep over State Files would pass on the neighbouring paragraph that already describes
# the branch field for the rail alone.
BLK="$(awk '/^### Resolving the task/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^#+ /){f=0} f' "$BLG5" | tr -s ' ')"

if [ -n "$BLK" ]; then
  ok "the protocol names the ladder a reader follows to find its task"

  # Each rung carries its own fact. Order is proven by extraction, not by a presence grep: swapping two
  # rungs' contents leaves every phrase in the block and still fails here.
  r1="$(rung 1)"; r2="$(rung 2)"; r3="$(rung 3)"; r4="$(rung 4)"
  miss=""
  printf '%s' "$r1" | grep -qi 'branch currently checked out'  || miss="$miss rung1-branch"
  printf '%s' "$r1" | grep -qi 'exactly one'                   || miss="$miss rung1-unique"
  printf '%s' "$r2" | grep -qi 'no branch'                     || miss="$miss rung2-unclaimed"
  printf '%s' "$r2" | grep -qiE 'lone|alone|single|exactly one' || miss="$miss rung2-unique"
  printf '%s' "$r3" | grep -qi 'exactly one task'              || miss="$miss rung3-unambiguous"
  printf '%s' "$r4" | grep -qiE 'stop'                         || miss="$miss rung4-stop"
  printf '%s' "$r4" | grep -qi 'looked for'                    || miss="$miss rung4-names-what"
  [ -z "$miss" ] && ok "the ladder's rungs are stated in order, from the sheet that claims the branch to the stop" \
                 || bad "the ladder's rungs are stated in order, from the sheet that claims the branch to the stop (missing:$miss)"

  # The condition, not the mention: 'at least one' would keep every word of the rung and invert it.
  if printf '%s' "$r3" | grep -qi 'exactly one task' \
     && ! printf '%s' "$BLK" | grep -qiE 'at least one task|any task it names'; then
    ok "the shared state answers only where it names exactly one task"
  else
    bad "the shared state answers only where it names exactly one task"
  fi

  # Ambiguity and the stop must be joined in one rung. Held apart, the block can say both and still
  # leave a reader free to pick.
  if printf '%s' "$r3$r4" | grep -qiE 'several|more than one|two or more' \
     && printf '%s' "$r4" | grep -qi 'stop'; then
    ok "an ambiguous shared state stops the reader instead of choosing"
  else
    bad "an ambiguous shared state stops the reader instead of choosing"
  fi

  # The rail resolves with no branch checked out at all, and the block used to be silent about it —
  # a path in the implementation that no rung covered, in a document claiming every reader follows the
  # same four rungs. Scoped outside the rungs because it is a precondition of rung 1, not a rung.
  if printf '%s' "$BLK" | grep -qiE 'detached HEAD|no branch to match|with none' \
     && printf '%s' "$BLK" | grep -qi 'whatever branch it declares'; then
    ok "the block states the no-branch case, where the lone sheet answers whatever it declares"
  else
    bad "the block states the no-branch case, where the lone sheet answers whatever it declares"
  fi

  # The block owns the ladder for BOTH readers, so it must name the code half — otherwise the prose and
  # the implementation are two facts again, which is the drift this task exists to close.
  if printf '%s' "$BLK" | grep -q 'understand-write-guard.py' \
     && printf '%s' "$BLK" | grep -qiE 'rungs 1 and 2|first two rungs'; then
    ok "the block names the rail that shares its first two rungs"
  else
    bad "the block names the rail that shares its first two rungs"
  fi
else
  bad "the protocol names the ladder a reader follows to find its task"
  bad "the ladder's rungs are stated in order, from the sheet that claims the branch to the stop (no block)"
  bad "the shared state answers only where it names exactly one task (no block)"
  bad "an ambiguous shared state stops the reader instead of choosing (no block)"
  bad "the block names the rail that shares its first two rungs (no block)"
  bad "the block states the no-branch case, where the lone sheet answers whatever it declares (no block)"
fi

# D5: the pointer runs both ways, so editing the code half leads back to where the rule is written.
# The ladder has one implementation and it is `_aiflow_state.py`, so that file is the one that must point
# back at the protocol -- and each rail must point at it, or the chain from a rail to the rule has a
# missing link. Three legs where there was one: the hop the extraction created is now guarded too.
LADDER="global/hooks/_aiflow_state.py"
p5=""
grep -q 'Resolving the task' "$LADDER" || p5="$p5 [the ladder's implementation does not name the block that owns it]"
for r5 in understand-write-guard context-structure-guard; do
  grep -q '_aiflow_state' "global/hooks/$r5.py" || p5="$p5 [$r5 does not point at the ladder's implementation]"
done
[ -z "$p5" ] \
  && ok "the rail points back at the block that owns the ladder" \
  || bad "the rail points back at the block that owns the ladder ($p5)"

for s in $PHASE_SKILLS; do
  f="global/skills/$s/SKILL.md"
  if [ ! -f "$f" ]; then
    bad "$s cites the ladder's owner (file missing: $f)"
    bad "$s does not restate the ladder (file missing)"
    bad "$s resolves its task before it touches the task's papers (file missing)"
    bad "$s says which task it resolved and what it read (file missing)"
    bad "$s does not name the shared state as its task source (file missing)"
    bad "$s cites the ladder from its protocol too (file missing)"
    continue
  fi
  c="$(cat "$f")"

  # Citing means naming the block AND the document that holds it: the phrase alone could be this
  # skill's own heading.
  if printf '%s' "$c" | grep -q 'Resolving the task' && printf '%s' "$c" | grep -q 'backlog.md'; then
    ok "$s cites the ladder's owner"
  else
    bad "$s cites the ladder's owner"
  fi

  # The anti-drift assertion. A skill may name the ordinary case (the sheet claiming this branch) —
  # that is the headline, not the ladder. What it may never do is re-spell the FALLBACK rungs, because
  # a second statement of those is the copy that drifts.
  if printf '%s' "$c" | grep -qi 'exactly one task' || printf '%s' "$c" | grep -qi 'declares no branch'; then
    bad "$s does not restate the ladder"
  else
    ok "$s does not restate the ladder"
  fi

  # Order, not presence: resolving after the first read of the task's papers is the bug itself.
  o_res="$(off "$c" 'Resolve the task')"
  o_art="$(off "$c" 'artifacts/T-XXX/')"
  if [ -n "$o_res" ] && [ -n "$o_art" ] && [ "$o_res" -lt "$o_art" ]; then
    ok "$s resolves its task before it touches the task's papers"
  else
    ok_res="${o_res:-none}"; ok_art="${o_art:-none}"
    bad "$s resolves its task before it touches the task's papers (resolve@$ok_res papers@$ok_art)"
  fi

  # Saying WHICH task and WHICH file: a report naming only the task cannot be checked against what it
  # should have read. Scoped to the resolving step, not the file: the audit command names the sheet in
  # its report line too, so the file-wide form let the two halves be satisfied by two different steps
  # and survived deleting the source from the step that resolves.
  res="$(nstep "$f" 2)"
  if printf '%s' "$res" | grep -qiE 'state (which|the) task|report (which|the) task|say (which|the) task' \
     && printf '%s' "$res" | grep -qiE 'the (sheet|source|file) it read'; then
    ok "$s says which task it resolved and what it read"
  else
    bad "$s says which task it resolved and what it read"
  fi

  # The shared-state rung belongs to the ladder's owner alone, so no command may name that file as
  # where its task comes from. Ran against the audit command only before — the other two could point
  # at the roster and stay green. Case-insensitive, and the loop's existence guard covers the read.
  if grep -niE 'task' "$f" | grep -qi 'STATE.md'; then
    bad "$s does not name the shared state as its task source"
  else
    ok "$s does not name the shared state as its task source"
  fi

  # M4: the protocol is the declared spec and the path a project without the skill installed follows,
  # so the rule has to be there too — not only in the front-end that reads it.
  pf="global/protocols/$s.md"
  if [ -f "$pf" ] && grep -q 'Resolving the task' "$pf"; then
    ok "$s cites the ladder from its protocol too"
  else
    bad "$s cites the ladder from its protocol too"
  fi
done


# D2's fold: one fact, one place. The report rides the line that already declares what the audit read.
VS16="global/skills/verify/SKILL.md"
n8="$(grep -nE '^[0-9]+\. \*\*Write\*\* ' "$VS16" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/')"
s8="$([ -n "$n8" ] && nstep "$VS16" "$n8")"
# NOT a bare 'resolved': step 8 already carries "when no base resolved", so the loose form passed on
# the BASE's resolution and never saw the task's. The line must name the task or the sheet it came from.
if printf '%s' "$s8" | grep -q 'Audited' \
   && printf '%s' "$s8" | grep -qiE 'the task it resolved|the sheet it read'; then
  ok "the audit's resolution report rides the line that already says what it read"
else
  bad "the audit's resolution report rides the line that already says what it read"
fi
