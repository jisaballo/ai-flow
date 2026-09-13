echo "== C19: putting the work into effect is a move of the close =="
BLG6="global/protocols/backlog.md"
PY19="template/.ai-flow/project.yml"
# The ceremony, bounded at the next section, fence-aware. Re-declared rather than inherited from C15:
# a criterion that reads another's extractor changes verdict when that one is re-scoped.
CLO6="$(awk '/^## Closing a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG6")"
D5="$(dmove 5)"

if [ -n "$D5" ]; then
  # Where it runs and what it distributes. Running it from a front repoints the installed engine's
  # source at a checkout the next move deletes, which silences the drift guard for good — so the
  # checkout is half the fact and the trunk is the other half.
  printf '%s' "$D5" | grep -qi 'coordinator' \
    && printf '%s' "$D5" | grep -qiE 'trunk|merged' \
    && ok "the distribution runs in the coordinator, from the merged trunk" \
    || bad "the distribution runs in the coordinator, from the merged trunk"

  # The generic core may name no project's command. Positive scoped to the move, negative over the
  # whole protocol: a project-specific command smuggled into any other section is the same breach.
  if printf '%s' "$D5" | grep -qiE 'project layer|project\.yml' \
     && printf '%s' "$D5" | grep -qi 'commands' \
     && ! grep -qiE 'install\.sh|\./install' "$BLG6"; then
    ok "the distribution move reads the project layer and names no project's command"
  else
    bad "the distribution move reads the project layer and names no project's command"
  fi

  # Silence and a clean result read identically in a report — the rule this engine already carries for an
  # audit that cannot prove what it claims, applied here to a project that
  # declares nothing. Both halves: the condition AND the obligation to say it out loud.
  printf '%s' "$D5" | grep -qiE 'declares (no|none|nothing)|no distribution command|no such command|absent' \
    && printf '%s' "$D5" | grep -qiE 'say so|says so|state[sd]? the no-op|stated no-op|out loud|never silen' \
    && ok "an undeclared distribution command is a stated no-op" \
    || bad "an undeclared distribution command is a stated no-op"

  # A command that reports success without writing anything is the failure this move exists to catch,
  # so ordering the run is not enough: the move must demand the result be shown, and demand it be
  # named unproven when the project has no check.
  # The second half is pinned to words only that branch owns. Accepting a bare 'cannot' let the whole
  # branch be deleted and still pass, on the 'cannot be shown' of the stop sentence two clauses later —
  # a neighbour's word answering for a fact it does not carry.
  printf '%s' "$D5" | grep -qiE 'shows?|prove[sn]?|proof|demonstrat' \
    && printf '%s' "$D5" | grep -qiE 'no check|unproven' \
    && ok "the distribution move proves it took effect, or says it cannot" \
    || bad "the distribution move proves it took effect, or says it cannot"

  # What carries an interrupted distribution. The record is already written by then, so the only thing
  # left saying work remains is the front's row — which is why the move sits before the tail.
  printf '%s' "$D5" | grep -qiE 'stops?|stop there|halt' \
    && printf '%s' "$D5" | grep -qiE 'roster row|row (is )?still|row in place' \
    && ok "an unprovable distribution stops the ceremony with the roster row in place" \
    || bad "an unprovable distribution stops the ceremony with the roster row in place"

  # The condition belongs to the tail and NOT here: a quick task's close and a front's non-final close
  # both distribute. The positive half is load-bearing — a bare negative passes on a deleted sentence.
  # The tail is the ceremony's LAST TWO moves, derived from its own count. Written as 6 and 7 this leg
  # was green over the publishing move's insertion while pointing one move short of the tail it names.
  nclo6="$(printf '%s\n' "$CLO6" | grep -cE '^[0-9]+\. ')"
  if printf '%s' "$D5" | grep -qiE 'every (task )?close|each (task )?close|always' \
     && ! printf '%s' "$D5" | grep -qiE 'no next task|has no next|last task' \
     && printf '%s' "$(dmove $((nclo6-1)))" | grep -qiE 'no next task|has no next|last task' \
     && printf '%s' "$(dmove "$nclo6")" | grep -qiE 'no next task|has no next|last task'; then
    ok "the distribution move runs at every close, unlike the tail"
  else
    bad "the distribution move runs at every close, unlike the tail"
  fi
else
  bad "the distribution runs in the coordinator, from the merged trunk (no fifth move)"
  bad "the distribution move reads the project layer and names no project's command (no fifth move)"
  bad "an undeclared distribution command is a stated no-op (no fifth move)"
  bad "the distribution move proves it took effect, or says it cannot (no fifth move)"
  bad "an unprovable distribution stops the ceremony with the roster row in place (no fifth move)"
  bad "the distribution move runs at every close, unlike the tail (no fifth move)"
fi

# The declaration point, in the shipped template. Bounded at the first unindented line — a key OR a
# comment: bounding at the next key alone swallows the steering block's comments above it, and then a
# note written anywhere below the map answers for the map. Which also fixes the form of the note: to be
# read here it must sit inside the mapping, indented, where a reader of commands actually meets it.
CMDS6="$(awk '/^commands:/{f=1;next} (f && /^[^[:space:]]/){f=0} f' "$PY19")"
if [ -n "$CMDS6" ]; then
  # Live with a value, every adopting project inherits a command that is not theirs and the close runs
  # it — so "commented out" is the fact, not a formatting preference.
  if printf '%s' "$CMDS6" | grep -qi 'distribute' \
     && printf '%s' "$CMDS6" | grep -qi 'optional' \
     && printf '%s' "$CMDS6" | grep -qiE 'no-op|nothing to distribute' \
     && ! printf '%s' "$CMDS6" | grep -qE '^[[:space:]]*distribute:'; then
    ok "the shipped template documents the distribution command as optional, and declares none"
  else
    bad "the shipped template documents the distribution command as optional, and declares none"
  fi
else
  bad "the shipped template documents the distribution command as optional, and declares none (no commands block)"
fi

# Fix the JOIN, not each half. The move names a key and the template documents one; nothing compared
# them, so the two deliverables of this task were connected by no check at all — a mutation renaming the
# template's key killed only the template-side assertion. The key is READ from the protocol and looked
# for everywhere it must also appear, so renaming it on any side goes red.
KEY6="$(printf '%s' "$D5" | grep -oE 'commands\.[a-z_]+' | head -1 | cut -d. -f2)"
if [ -n "$KEY6" ]; then
  ok "the distribution move names the key it reads, not just the map (commands.$KEY6)"
  keyed "$CMDS6" \
    && ok "the shipped template documents the same key the move reads" \
    || bad "the shipped template documents the same key the move reads"
  # The doc restates the schema for a human reader — pre-existing, and therefore a second home that can
  # go stale. Pinned to the same key so it cannot.
  keyed "$(awk '/^```yaml/{f=1;next} /^```/{f=0} f' docs/customization.md)" \
    && ok "the schema the docs show carries the same key" \
    || bad "the schema the docs show carries the same key"
else
  bad "the distribution move names the key it reads, not just the map"
  bad "the shipped template documents the same key the move reads (no key named)"
  bad "the schema the docs show carries the same key (no key named)"
fi

# The preamble's move numbers, derived rather than spelled. Reverting them to the pre-insertion pair left
# the whole suite green, so the preamble could call the unconditional move part of the conditional tail.
# The tail is not a literal here: it is whichever moves carry the condition, read from the moves.
CLOI6="$(printf '%s\n' "$CLO6" | awk '/^1\. /{exit} {print}' | tr '\n' ' ' | tr -s ' ')"
TAIL6=""; DIS6=""; MRG6=""
# The range is read from the moves too, not only which of them carry the condition: a literal list ends
# at its last index, so a move appended to the ceremony is never offered to any of the three tests below
# and the preamble could name a tail that had grown.
nclo6="$(printf '%s\n' "$CLO6" | grep -cE '^[0-9]+\. ')"
i=1
while [ "$i" -le "$nclo6" ]; do
  m="$(dmove "$i")"
  printf '%s' "$m" | grep -qiE 'no next task|has no next|last task' && TAIL6="$TAIL6 $i"
  printf '%s' "$m" | grep -qi 'dismantl' && DIS6="$i"
  printf '%s' "$m" | grep -qi 'merge lands' && MRG6="$i"
  i=$((i+1))
done
set -- $TAIL6
if [ -n "$CLOI6" ] && [ "$#" -eq 2 ] && [ -n "$DIS6" ] && [ -n "$MRG6" ]; then
  printf '%s' "$CLOI6" | grep -qF "moves $1 and $2" \
    && ok "the preamble names the tail by the moves that actually carry the condition" \
    || bad "the preamble names the tail by the moves that actually carry the condition (moves $1 and $2)"
  # The escape hatch carries three moves, not two: two need no second checkout and one needs no merge,
  # because a task worked in the coordinator has no branch to land. Both numbers stay derived for the
  # reason the comment above gives — a move inserted anywhere renumbers the rest, and a spelled number
  # would then point at whichever move happens to sit there.
  printf '%s' "$CLOI6" | grep -qF "moves 2, $MRG6 and $DIS6" \
    && ok "the single-front escape hatch names the merge and dismantle moves by their real numbers" \
    || bad "the single-front escape hatch names the merge and dismantle moves by their real numbers (moves 2, $MRG6 and $DIS6)"
else
  bad "the preamble names the tail by the moves that actually carry the condition (nothing to compare)"
  bad "the single-front escape hatch names the merge and dismantle moves by their real numbers (nothing to compare)"
fi

# A wider negative for "names no project's command". The old one grepped a single string, so appending
# "For this repo that command is \`npm run deploy\`" to the move read green while contradicting the
# sentence before it. Still a denylist — prose cannot be proven free of commands — but one that costs an
# author real effort to slip past, and the honest limit is stated rather than implied.
if printf '%s' "$D5" | grep -qiE '(^|[^a-z])(npm|yarn|pnpm|make|cargo|pip|docker|gradle|mvn|bash|sh)[[:space:]]|\./|install\.sh'; then
  bad "the move names no concrete command of any project"
else
  ok "the move names no concrete command of any project"
fi

# The installer's own report, in update mode. Functional and sandboxed: a fake HOME and a path that
# must not exist afterwards. Structural greps cannot see a mkdir that runs before the dispatch.
TH19="$(mkbox)" || fatal 'C19 fixtures'; TW19="$(mkbox)" || fatal 'C19 fixtures'
# A trap is global state, and setting one REPLACES what an earlier section installed: this block used to
# drop T12/T13 from the teardown, so two sandboxes leaked on every run, clean or interrupted. Carry the
# live trap's paths, and hand it back below rather than clearing it.
trap 'rm -rf "$TH19" "$TW19" "$T12" "$T13"' EXIT
GHOST19="$TW19/never-written"
OUT19="$( cd "$TW19" && HOME="$TH19" bash "$ROOT/install.sh" update "$GHOST19" </dev/null 2>&1 )" || true
if [ ! -e "$GHOST19" ] && ! printf '%s' "$OUT19" | grep -qF "$GHOST19"; then
  ok "update creates no project target and prints none"
else
  bad "update creates no project target and prints none"
fi
# And it names what it does write, or the line above is satisfied by printing no target at all.
printf '%s' "$OUT19" | grep -qE 'Target:.*\.claude' \
  && ok "update names the toolchain it actually writes" \
  || bad "update names the toolchain it actually writes"
rm -rf "$TH19" "$TW19"
trap 'rm -rf "$T12" "$T13"' EXIT   # handed back to the section that owned it

# The teardown is a fact of this block, not a courtesy: the leak above went unnoticed because nothing
# ever looked. A probe is cheaper than the next reviewer finding it by hand.
{ [ ! -d "$TH19" ] && [ ! -d "$TW19" ] && [ -d "$T12" ]; } \
  && ok "the sandbox is torn down and the live cleanup trap survives this block" \
  || bad "the sandbox is torn down and the live cleanup trap survives this block"
