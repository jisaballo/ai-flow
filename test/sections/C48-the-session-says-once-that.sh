echo ""
echo "== C48: the session says once that its own context has become the bill =="
# Conformance: a session that has grown expensive says so once, recommends a cut at the next phase
# boundary, names the two things a cut destroys, and never stops the operator working.
#
# The note's own text is what the no-repeat searches for, so the two markers below are a contract
# between the hook and this section: the hook writes them, this section reads them, and nothing else
# produces them. A detector keyed on phrases the system never writes only detects its own fixtures.
NOTE48="$ROOT/global/hooks/context-cost-note.py"
M48_1='ai-flow context note [150]'
M48_2='ai-flow context note [300]'

# A transcript of $1 main-loop turns, plus any extra raw lines given on stdin.
mk_tx48() {  # $1 = path, $2 = number of usage-carrying main-loop records
  : > "$1"
  local i=0
  while [ "$i" -lt "$2" ]; do
    printf '{"type":"assistant","message":{"usage":{"input_tokens":1,"cache_read_input_tokens":1000,"output_tokens":1}}}\n' >> "$1"
    i=$((i+1))
  done
}
# Runs the note in $1 with the payload on $2, leaving stdout in $OUT48, stderr in $ERR48, status in $RC48.
run48() {  # $1 = cwd, $2 = payload json
  OUT48="$( cd "$1" && printf '%s' "$2" | python3 "$NOTE48" 2>"$1/.err48" )"
  RC48=$?
  ERR48="$(cat "$1/.err48" 2>/dev/null)"
}
# Silence is only evidence when something was there to be silent. Every assertion below that reads
# "no note was emitted" appends this first: an interpreter that could not find the file emits nothing
# either, and without this the whole silent half of the section is green on an empty repository -- the
# hollow-proof shape this suite has been bitten by four times.
ran48() {  # echoes a fault when the note did not actually run and choose silence
  [ -f "$NOTE48" ] || { printf ' [the note does not exist, so its silence proves nothing]'; return; }
  [ "$RC48" -eq 0 ] || printf ' [the note exited %s instead of running to a silent verdict]' "$RC48"
}

B48="$(mkbox)" || fatal "the context-cost note cannot be exercised"
if [ -n "${B48:-}" ]; then
  mkdir -p "$B48/proj/.ai-flow" "$B48/bare"
  TX48="$B48/proj/tx.jsonl"

  # A1 -- WHEN the count first reaches 150 and no note stands, exactly one note goes to stdout, exit 0.
  mk_tx48 "$TX48" 150
  run48 "$B48/proj" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$TX48\",\"stop_hook_active\":false}"
  a48=""
  printf '%s' "$OUT48" | grep -q 'systemMessage' || a48="$a48 [no systemMessage on stdout]"
  case "$OUT48" in *"$M48_1"*) : ;; *) a48="$a48 [the first threshold's marker is absent]" ;; esac
  [ "$RC48" -eq 0 ] || a48="$a48 [exited $RC48, not 0]"
  [ -z "$a48" ] && ok "the note fires once on crossing the first threshold" \
                || bad "the note fires once on crossing the first threshold ($a48)"

  # A2 -- WHILE that note already stands in the session's own record, it is never written again.
  printf '{"type":"attachment","attachment":{"type":"hook_system_message","content":"%s ..."}}\n' "$M48_1" >> "$TX48"
  run48 "$B48/proj" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$TX48\",\"stop_hook_active\":false}"
  b48=""
  case "$OUT48" in *"$M48_1"*) b48=" [the first note was written a second time]" ;; esac
  [ "$RC48" -eq 0 ] || b48="$b48 [exited $RC48, not 0]"
  [ -z "$b48" ] && ok "a threshold already noted is never noted again" \
                || bad "a threshold already noted is never noted again ($b48)"

  # A3 -- WHEN the count reaches the second threshold and only the first note stands, the second fires.
  mk_tx48 "$B48/proj/tx2.jsonl" 300
  printf '{"type":"attachment","attachment":{"type":"hook_system_message","content":"%s ..."}}\n' "$M48_1" >> "$B48/proj/tx2.jsonl"
  run48 "$B48/proj" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$B48/proj/tx2.jsonl\",\"stop_hook_active\":false}"
  c48=""
  case "$OUT48" in *"$M48_2"*) : ;; *) c48=" [the second threshold did not fire]" ;; esac
  case "$OUT48" in *"$M48_1"*) c48="$c48 [the first note repeated]" ;; esac
  [ -z "$c48" ] && ok "the second threshold fires after the first has already fired" \
                || bad "the second threshold fires after the first has already fired ($c48)"

  # A4 -- The note exits 0 on every path. This is what separates it from all three of its siblings, and
  # it is asserted over the silent paths too: an exit code is only a promise where nothing was emitted.
  #
  # "Every path" is enumerated rather than sampled, and that is not pedantry: a first form of this row
  # probed three of them, and turning the re-delivery path into a refusal was survived by the whole
  # suite. An assertion that says "every" while exercising a subset is a guard encoding less than its
  # own rule states -- it reports clean on the paths it never walked. Each path below is one the hook
  # returns from, plus the one it speaks from, because an exit code is a promise on the loud path too.
  d48=""
  run48 "$B48/bare" '{"hook_event_name":"UserPromptSubmit","stop_hook_active":false}'
  [ "$RC48" -eq 0 ] || d48="$d48 [outside an ai-flow checkout it exited $RC48]"
  run48 "$B48/proj" '{"hook_event_name":"UserPromptSubmit","transcript_path":"/nonexistent/x.jsonl","stop_hook_active":false}'
  [ "$RC48" -eq 0 ] || d48="$d48 [on an unreachable transcript it exited $RC48]"
  run48 "$B48/proj" 'not json at all'
  [ "$RC48" -eq 0 ] || d48="$d48 [on a broken payload it exited $RC48]"
  run48 "$B48/proj" '["a","list","is","not","an","object"]'
  [ "$RC48" -eq 0 ] || d48="$d48 [on a non-object payload it exited $RC48]"
  mk_tx48 "$B48/proj/tx6.jsonl" 400
  # The re-delivered-stop path is GONE with the field that read it: there is no re-delivery loop at this
  # hook's event and no payload there carries `stop_hook_active`. What replaced it is the path an
  # additive installer makes reachable on every existing install — an invocation at the event this hook
  # left, which it must survive as quietly as it survives everything else here.
  run48 "$B48/proj" "{\"hook_event_name\":\"Stop\",\"transcript_path\":\"$B48/proj/tx6.jsonl\"}"
  [ "$RC48" -eq 0 ] || d48="$d48 [at an event that is not its own it exited $RC48]"
  run48 "$B48/proj" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$B48/proj/tx6.jsonl\",\"stop_hook_active\":false}"
  [ "$RC48" -eq 0 ] || d48="$d48 [on the path where it actually speaks it exited $RC48]"
  [ -z "$d48" ] && ok "every path exits 0, including the ones that emit nothing" \
                || bad "every path exits 0, including the ones that emit nothing ($d48)"

  # A5 -- IF neither route reaches a transcript, THEN silence. The gap must fall on the harmless side.
  run48 "$B48/proj" '{"hook_event_name":"UserPromptSubmit","transcript_path":"/nonexistent/x.jsonl","stop_hook_active":false}'
  e48=""
  [ -n "$OUT48" ] && case "$OUT48" in *systemMessage*) e48=" [a note was emitted with no transcript to count]" ;; esac
  e48="$e48$(ran48)"
  [ -z "$e48" ] && ok "an unreachable transcript produces silence, not a note" \
                || bad "an unreachable transcript produces silence, not a note ($e48)"

  # A6 -- IF stdin is not a JSON object, THEN no note and no traceback. A hook that runs at every turn
  # close must survive a payload it did not expect; the traceback is checked because exit 0 alone would
  # hide it and the harness discards a Stop hook's stderr at exit 0.
  run48 "$B48/proj" 'not json at all'
  f48=""
  case "$OUT48" in *systemMessage*) f48=" [a note was emitted from an unparseable payload]" ;; esac
  case "$ERR48" in *Traceback*) f48="$f48 [it tracebacked]" ;; esac
  run48 "$B48/proj" '["a","list","is","not","an","object"]'
  case "$OUT48" in *systemMessage*) f48="$f48 [a note was emitted from a non-object payload]" ;; esac
  case "$ERR48" in *Traceback*) f48="$f48 [a non-object payload tracebacked]" ;; esac
  f48="$f48$(ran48)"
  [ -z "$f48" ] && ok "a payload that is not an object is survived in silence" \
                || bad "a payload that is not an object is survived in silence ($f48)"

  # A7 -- WHERE the checkout has no .ai-flow, no note. The note points at a paper that only exists here.
  cp "$TX48" "$B48/bare/tx.jsonl" 2>/dev/null
  mk_tx48 "$B48/bare/tx.jsonl" 400
  run48 "$B48/bare" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$B48/bare/tx.jsonl\",\"stop_hook_active\":false}"
  g48=""
  case "$OUT48" in *systemMessage*) g48=" [a note was emitted in a checkout the engine does not govern]" ;; esac
  g48="$g48$(ran48)"
  [ -z "$g48" ] && ok "a checkout the engine does not govern gets no note" \
                || bad "a checkout the engine does not govern gets no note ($g48)"

  # A8 is RETIRED and the row is GONE from this file rather than standing weakened beside its
  # replacement. It required silence on a re-delivered stop, and there is no such thing at this hook's
  # event: nothing re-delivers a prompt, and no payload there carries the field the rule was keyed on.
  # What answers for the same class of invocation now is the event check, which is guarded one row up in
  # A4's enumeration and, in its own right, by the row asserting that an invocation at an event this hook
  # does not serve exits 0 and emits nothing.

  # A9 -- The note names both labels it sends the operator to. Without this the note and the sheet drift
  # apart in silence: the note would keep pointing at a field the template no longer declares.
  mk_tx48 "$B48/proj/tx4.jsonl" 150
  run48 "$B48/proj" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$B48/proj/tx4.jsonl\",\"stop_hook_active\":false}"
  i48=""
  case "$OUT48" in *hypothesis*) : ;; *) i48=" [the note does not name the hypothesis label]" ;; esac
  case "$OUT48" in *alternative*) : ;; *) i48="$i48 [the note does not name the alternative label]" ;; esac
  [ -z "$i48" ] && ok "the note names both labels it sends the operator to" \
                || bad "the note names both labels it sends the operator to ($i48)"

  # A10 -- WHERE a record is marked isSidechain it is not counted. Measured: subagent turns are absent
  # from a project transcript and are 1.2% of the bill, so the count is main-loop turns by construction
  # -- and a count that quietly included them would fire the note early on a session that never grew.
  mk_tx48 "$B48/proj/tx5.jsonl" 100
  n48=0
  while [ "$n48" -lt 100 ]; do
    printf '{"type":"assistant","isSidechain":true,"message":{"usage":{"input_tokens":1,"output_tokens":1}}}\n' >> "$B48/proj/tx5.jsonl"
    n48=$((n48+1))
  done
  run48 "$B48/proj" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$B48/proj/tx5.jsonl\",\"stop_hook_active\":false}"
  j48=""
  case "$OUT48" in *systemMessage*) j48=" [100 main-loop turns plus 100 subagent turns crossed the threshold]" ;; esac
  j48="$j48$(ran48)"
  [ -z "$j48" ] && ok "subagent turns are not counted toward the threshold" \
                || bad "subagent turns are not counted toward the threshold ($j48)"


  # A13 -- The mark is read only where the harness wrote it. Every other way the text can reach the
  # transcript is a session TALKING about the note, and an unanchored search counted all of them: this
  # very file holds both marks verbatim and is the Verify command of every step of every task here, so a
  # text search silenced the note in the first session that read it -- reproduced live at 248 turns, no
  # note ever delivered. Both non-harness shapes are exercised, because the record type is what the
  # implementation must key on and either one alone would let the other through.
  mk_tx48 "$B48/proj/tx7.jsonl" 200
  printf '{"type":"assistant","message":{"content":[{"type":"text","text":"as in %s, quoted"}]}}\n' "$M48_1" >> "$B48/proj/tx7.jsonl"
  printf '{"type":"user","message":{"content":"why did %s not fire"}}\n' "$M48_1" >> "$B48/proj/tx7.jsonl"
  run48 "$B48/proj" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$B48/proj/tx7.jsonl\",\"stop_hook_active\":false}"
  m48=""
  case "$OUT48" in *"$M48_1"*) : ;; *) m48=" [a session that merely quotes the mark was treated as already noted]" ;; esac
  [ -z "$m48" ] && ok "quoting the mark is not the same as having been told" \
                || bad "quoting the mark is not the same as having been told ($m48)"

  # A14 -- The firmer note is terminal. A session arriving past the second threshold with nothing said is
  # told once, at the level its length earned -- and nothing follows it. Written as a scan for any
  # unspoken threshold, the hook told such a session "this is the second and last time" and then emitted
  # the SOFTER note on the very next close, because the first threshold's mark had never been written.
  # Both closes are asserted here: the one that speaks, and the one after it that must not.
  mk_tx48 "$B48/proj/tx8.jsonl" 400
  run48 "$B48/proj" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$B48/proj/tx8.jsonl\",\"stop_hook_active\":false}"
  n48b=""
  case "$OUT48" in *"$M48_2"*) : ;; *) n48b=" [a late-arriving session was not told at the level it had reached]" ;; esac
  case "$OUT48" in *"$M48_1"*) n48b="$n48b [it was told at the softer level instead]" ;; esac
  # the harness's own delivery record, which is the only shape the mark may be read from
  printf '{"type":"attachment","attachment":{"type":"hook_system_message","content":"%s ..."}}\n' "$M48_2" >> "$B48/proj/tx8.jsonl"
  run48 "$B48/proj" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$B48/proj/tx8.jsonl\",\"stop_hook_active\":false}"
  case "$OUT48" in *systemMessage*) n48b="$n48b [something followed the note that said it was the last]" ;; esac
  n48b="$n48b$(ran48)"
  [ -z "$n48b" ] && ok "the firmer note is terminal, and nothing softer follows it" \
                 || bad "the firmer note is terminal, and nothing softer follows it ($n48b)"

  # A23 -- The note's claim about its own history is true in both arrival orders. The firmer one cannot
  # say "the second and last time" to a session that is hearing it FIRST -- which is every session in
  # flight the day the hook is installed, and any that ran a stretch with no readable transcript. A
  # message that misdescribes the conversation the operator just had is how one stops being read.
  # Observed on a live 318-turn session, which heard "the second and last time" as the only thing said.
  mk_tx48 "$B48/proj/txC.jsonl" 400
  run48 "$B48/proj" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$B48/proj/txC.jsonl\",\"stop_hook_active\":false}"
  y48=""
  case "$OUT48" in *"second and last"*) y48=" [a session hearing the note for the first time was told it was the second]" ;; esac
  case "$OUT48" in *"not again"*) : ;; *) y48="$y48 [the note does not say it will not come back]" ;; esac
  mk_tx48 "$B48/proj/txD.jsonl" 400
  printf '{"type":"attachment","attachment":{"type":"hook_system_message","content":"%s ..."}}\n' "$M48_1" >> "$B48/proj/txD.jsonl"
  run48 "$B48/proj" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$B48/proj/txD.jsonl\",\"stop_hook_active\":false}"
  case "$OUT48" in *"second and last"*) : ;; *) y48="$y48 [a session that HAD been told first was not told this was the second]" ;; esac
  y48="$y48$(ran48)"
  [ -z "$y48" ] && ok "the note's claim about its own history is true either way it arrives" \
                || bad "the note's claim about its own history is true either way it arrives ($y48)"

  # A15 -- A threshold the session has passed is never revisited. The terminal state the manual promises
  # -- "never a third time" -- had no assertion at all, so the worst failure the hook can have (the note
  # re-emitted at every close for the remaining hundreds of turns of a long session) was invisible.
  mk_tx48 "$B48/proj/tx9.jsonl" 400
  printf '{"type":"attachment","attachment":{"type":"hook_system_message","content":"%s ..."}}\n' "$M48_1" >> "$B48/proj/tx9.jsonl"
  printf '{"type":"attachment","attachment":{"type":"hook_success","hookName":"Stop","stdout":"{\\"systemMessage\\":\\"%s ...\\"}"}}\n' "$M48_2" >> "$B48/proj/tx9.jsonl"
  run48 "$B48/proj" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$B48/proj/tx9.jsonl\",\"stop_hook_active\":false}"
  o48=""
  case "$OUT48" in *systemMessage*) o48=" [a note was emitted with both thresholds already spoken]" ;; esac
  o48="$o48$(ran48)"
  [ -z "$o48" ] && ok "both thresholds spoken means silence for the rest of the session" \
                || bad "both thresholds spoken means silence for the rest of the session ($o48)"


  # A16 -- The declared working directory is the one that decides, not the hook process's own. The engine
  # states this for the sibling rail in as many words, and until now only the fallback arm ran: every
  # fixture above supplies the directory by cd-ing into it and carries no `cwd` key at all. Both
  # directions are asserted, because the primary is wrong in two ways and each is silent on its own.
  mkdir -p "$B48/proj/deep/deeper"
  mk_tx48 "$B48/proj/txA.jsonl" 200
  p48=""
  # declared inside the project while the process sits outside one -> the note is owed
  run48 "$B48/bare" "{\"hook_event_name\":\"UserPromptSubmit\",\"cwd\":\"$B48/proj\",\"transcript_path\":\"$B48/proj/txA.jsonl\",\"stop_hook_active\":false}"
  case "$OUT48" in *systemMessage*) : ;; *) p48=" [a declared ai-flow directory was ignored in favour of the process's own]" ;; esac
  # declared outside while the process sits inside -> silence is owed
  run48 "$B48/proj" "{\"hook_event_name\":\"UserPromptSubmit\",\"cwd\":\"$B48/bare\",\"transcript_path\":\"$B48/proj/txA.jsonl\",\"stop_hook_active\":false}"
  case "$OUT48" in *systemMessage*) p48="$p48 [a note went to a declared directory the engine does not govern]" ;; esac
  p48="$p48$(ran48)"
  [ -z "$p48" ] && ok "the declared working directory decides, not the hook's own" \
                || bad "the declared working directory decides, not the hook's own ($p48)"

  # A17 -- A session in a subdirectory is still inside its project. The walk upward is the only reason
  # the search is a loop, and until now no fixture entered the loop body: the rows above test a
  # directory that IS the project root and one whose whole ancestry has none. The sessions most likely
  # to run long are exactly the ones sitting a few directories down.
  run48 "$B48/proj/deep/deeper" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$B48/proj/txA.jsonl\",\"stop_hook_active\":false}"
  q48=""
  case "$OUT48" in *systemMessage*) : ;; *) q48=" [a session two directories inside the project was treated as outside it]" ;; esac
  q48="$q48$(ran48)"
  [ -z "$q48" ] && ok "a session in a subdirectory is still inside its project" \
                || bad "a session in a subdirectory is still inside its project ($q48)"

  # A18 -- The climb stops at the checkout boundary, which is what every sibling hook does. Unbounded it
  # reaches the filesystem root, so a repository with no engine data nested inside one that has it would
  # get a note pointing at a sheet it does not have -- a WRONG note, the one direction this hook must
  # never fail in. Needs a real repository, because the boundary is git's answer and nothing else's.
  if command -v git >/dev/null 2>&1; then
    mkdir -p "$B48/proj/nested"
    ( cd "$B48/proj/nested" && git init -q . 2>/dev/null && git config user.email t@t && git config user.name t ) || true
    run48 "$B48/proj/nested" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$B48/proj/txA.jsonl\",\"stop_hook_active\":false}"
    r48=""
    case "$OUT48" in *systemMessage*) r48=" [the climb passed the nested checkout's own boundary]" ;; esac
    r48="$r48$(ran48)"
    [ -z "$r48" ] && ok "the search for engine data stops at the checkout boundary" \
                  || bad "the search for engine data stops at the checkout boundary ($r48)"
  else
    ok "the search for engine data stops at the checkout boundary [skipped: no git]"
  fi

  # A19 -- A turn is an assistant record. Measured across 60 real transcripts: 11,738 records carry
  # `message.usage` and every one is an assistant record. Reading `usage` alone gives the same count
  # today and would inflate it the day another shape carries the field -- firing the note early on a
  # session that never grew. Asserted in the direction the gap actually costs something.
  mk_tx48 "$B48/proj/txB.jsonl" 100
  t48=0
  while [ "$t48" -lt 100 ]; do
    printf '{"type":"user","message":{"usage":{"input_tokens":1,"output_tokens":1}}}\n' >> "$B48/proj/txB.jsonl"
    t48=$((t48+1))
  done
  run48 "$B48/proj" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$B48/proj/txB.jsonl\",\"stop_hook_active\":false}"
  u48=""
  case "$OUT48" in *systemMessage*) u48=" [100 assistant turns plus 100 non-assistant records crossed the threshold]" ;; esac
  u48="$u48$(ran48)"
  [ -z "$u48" ] && ok "only assistant records count as turns" \
                || bad "only assistant records count as turns ($u48)"

  # A20 -- The fallback route is exercised in its POSITIVE direction. The row above proves only what
  # happens when it finds nothing, so the whole fallback -- the slug shape, the glob, and picking the
  # NEWEST rather than any file -- could have been deleted with the suite green. HOME is redirected, the
  # way the installer rows here already do it, so the operator's own records are never read.
  HB48="$(mkbox)" || fatal 'the transcript fallback cannot be exercised'
  if [ -n "${HB48:-}" ]; then
    SLUG48="$(printf '%s' "$B48/proj" | sed 's/[^A-Za-z0-9]/-/g')"
    mkdir -p "$HB48/.claude/projects/$SLUG48"
    mk_tx48 "$HB48/.claude/projects/$SLUG48/old.jsonl" 10
    mk_tx48 "$HB48/.claude/projects/$SLUG48/new.jsonl" 200
    touch -t 200001010000 "$HB48/.claude/projects/$SLUG48/old.jsonl"
    v48=""
    OUT48="$( cd "$B48/proj" && printf '{"hook_event_name":"UserPromptSubmit","cwd":"%s","stop_hook_active":false}' "$B48/proj" \
              | HOME="$HB48" python3 "$NOTE48" 2>/dev/null )"; RC48=$?
    case "$OUT48" in *systemMessage*) : ;; *) v48=" [the fallback did not find the newest record for this working copy]" ;; esac
    [ "$RC48" -eq 0 ] || v48="$v48 [it exited $RC48]"
    [ -z "$v48" ] && ok "with no declared transcript the newest record for this working copy is read" \
                  || bad "with no declared transcript the newest record for this working copy is read ($v48)"
    rm -rf "$HB48"
  else
    bad "with no declared transcript the newest record for this working copy is read (no sandbox)"
  fi

  rm -rf "$B48"
fi

# A11 -- The note reaches the sessions it governs. Committed is not installed: the engine's own rule.
k48=""
grep -q 'context-cost-note.py' "$ROOT/install.sh" || k48=" [the installer does not publish it]"
grep -q 'context-cost-note.py' "$ROOT/global/hooks/settings.hooks.json" || k48="$k48 [it is not registered in settings]"
# One Stop array, not two: a second array is valid JSON and silently replaces nothing, so the count is
# what carries the fact rather than the presence of the name.
s48="$(grep -c '"Stop"' "$ROOT/global/hooks/settings.hooks.json" | tr -d ' ')"
[ "$s48" = "1" ] || k48="$k48 [the Stop key appears $s48 times; the note belongs in the existing array]"
grep -q 'context-cost-note' "$ROOT/global/hooks/README.md" || k48="$k48 [it is undocumented]"
[ -z "$k48" ] && ok "the note is published by the installer and wired into the Stop array" \
              || bad "the note is published by the installer and wired into the Stop array ($k48)"

# A21 -- and it actually ARRIVES. The row above reads the installer's source, which is the same shape a
# sibling section records as having gone green while the three lines that did the delivering were
# deleted: a declared set and a tree can agree perfectly about a file nothing writes. So the installer is
# RUN, into a sandboxed HOME that is never the operator's, and the landed file is what is checked.
TI48="$(mkbox)" || fatal 'the installed-note row cannot build its home'
TP48="$(mkbox)" || fatal 'the installed-note row cannot build its project'
TC48="$(mkbox)" || fatal 'the installed-note row cannot build its working directory' 
if [ -n "${TI48:-}" ] && [ -n "${TP48:-}" ] && [ -n "${TC48:-}" ]; then
  mkdir -p "$TP48/.ai-flow/protocols"
  ( cd "$TC48" && HOME="$TI48" bash "$ROOT/install.sh" update "$TP48" </dev/null >/dev/null 2>&1 ) || true
  w48=""
  test -f "$TI48/.claude/hooks/context-cost-note.py" || w48=" [the installer did not land it in ~/.claude/hooks]"
  SJ48="$TI48/.claude/settings.json"
  if [ -f "$SJ48" ]; then
    c48c="$(grep -c 'context-cost-note.py' "$SJ48" 2>/dev/null | tr -d ' ')"
    [ "$c48c" = "1" ] || w48="$w48 [the merged settings name it $c48c time(s), expected exactly 1]"
  else
    w48="$w48 [no settings.json was produced to merge into]"
  fi
  [ -z "$w48" ] && ok "the note is installed and merged, not merely committed" \
                || bad "the note is installed and merged, not merely committed ($w48)"
  rm -rf "$TI48" "$TP48" "$TC48"
else
  bad "the note is installed and merged, not merely committed (no sandbox)"
fi

# A12 -- The sheet declares both labels and says they are optional. Asserted label by label: a prose edit
# inside a region an assertion greps is invisible unless the assertion names each fact separately, which
# is what a single combined pattern would have hidden.
l48=""
SH48="$ROOT/global/protocols/backlog.md"
grep -q '^- hypothesis:' "$SH48" || l48=" [the sheet template declares no hypothesis label]"
grep -q '^- alternative:' "$SH48" || l48="$l48 [the sheet template declares no alternative label]"
grep -qi 'only when there is something to write\|written only when non-empty' "$SH48" \
  || l48="$l48 [the template does not say the two fields are written only when non-empty]"
[ -z "$l48" ] && ok "the sheet template carries both labels and the rule that they are optional" \
              || bad "the sheet template carries both labels and the rule that they are optional ($l48)"

# A22 -- the note sends the operator to a NAMED section, and only the template provides it. Asserting the
# two labels on each side left the heading itself unguarded: rename it on either side, or drop it from the
# template while keeping the labelled lines, and the note points at a section that does not exist with
# every row green. Both sides are read here so neither can move alone.
x48=""
grep -q '^## Ruled out' "$SH48" || x48=" [the sheet template declares no Ruled out section]"
grep -q 'Ruled out' "$ROOT/global/hooks/context-cost-note.py" \
  || x48="$x48 [the note does not name the section it sends the operator to]"
[ -z "$x48" ] && ok "the note and the template name the same section" \
              || bad "the note and the template name the same section ($x48)"

# --- the engine records a source that outlives it, and a version anyone can read ----------------
# Generated in the Conform phase from understand.md's Verifiable Criteria; each row names the criterion
# it comes from. Two of them are CONTROLS in the sense the A6 row above already uses: they pin behaviour
# the fix must not take away, so they are green from the start by construction rather than by achievement.

CB="$(mkbox)" || fatal 'the engine-provenance rows'
mkdir -p "$CB/h1" "$CB/h2" "$CB/h3" "$CB/h4" "$CB/h5"
# An engine tree that is NOT a git checkout: what an installed package directory looks like on disk.
mkdir -p "$CB/pkg"
cp "$ROOT/install.sh" "$CB/pkg/"
cp -R "$ROOT/global" "$ROOT/docs" "$ROOT/template" "$CB/pkg/" 2>/dev/null
rm -rf "$CB/pkg/.git"
cp -R "$CB/pkg" "$CB/pkg-gone"

# B1 -- WHERE the installer runs from a directory that is not a git checkout, the installer shall record
# no engine source path. Recording one is what turns the guard's designed silence into a permanent
# refusal the moment a package cache is evicted.
( cd "$CB/pkg" && HOME="$CB/h1" bash "$CB/pkg/install.sh" update </dev/null >/dev/null 2>&1 ) || true
if [ -f "$CB/h1/.claude/ai-flow/source.path" ]; then
  bad "an install from a directory that is not a checkout records no source path (it recorded '$(cat "$CB/h1/.claude/ai-flow/source.path" 2>/dev/null)')"
else
  ok "an install from a directory that is not a checkout records no source path"
fi

# B2 -- CONTROL for B1. WHERE the installer runs from a git checkout, it shall record that checkout.
# Without this row the cheapest way to pass B1 is to stop recording the path at all, which would take the
# drift guard away from the one install it is able to watch.
( cd "$ROOT" && HOME="$CB/h2" bash "$ROOT/install.sh" update </dev/null >/dev/null 2>&1 ) || true
if [ "$(cat "$CB/h2/.claude/ai-flow/source.path" 2>/dev/null)" = "$ROOT" ]; then
  ok "an install from a checkout still records it as the engine source path"
else
  bad "an install from a checkout still records it as the engine source path (recorded '$(cat "$CB/h2/.claude/ai-flow/source.path" 2>/dev/null)')"
fi

# B3 -- WHEN an install completes, the installer shall record the installed engine version. Its CONTENT is
# what is read, per route, and that is the whole point of the row: an earlier form asserted only that the
# file was non-empty, so every route could have written the same wrong word and the row would have passed.
# Four routes, four things the file must be able to say apart.
mkdir -p "$CB/h6" "$CB/h7" "$CB/pkg-manifest"
cp -R "$CB/pkg/." "$CB/pkg-manifest/"
cp "$ROOT/package.json" "$CB/pkg-manifest/" 2>/dev/null || true
( cd "$CB/pkg-manifest" && HOME="$CB/h6" bash "$CB/pkg-manifest/install.sh" update </dev/null >/dev/null 2>&1 ) || true
( cd "$CB" && AI_FLOW_MODE=remote AI_FLOW_REPO_URL="file://$CB/absent" HOME="$CB/h7" \
    bash "$ROOT/install.sh" update </dev/null >/dev/null 2>&1 ) || true
v3=""
case "$(cat "$CB/h2/.claude/ai-flow/version" 2>/dev/null)" in
  "checkout "*" — $ROOT") : ;;
  *) v3=" [a checkout did not name its commit and directory: '$(cat "$CB/h2/.claude/ai-flow/version" 2>/dev/null)']" ;;
esac
case "$(cat "$CB/h1/.claude/ai-flow/version" 2>/dev/null)" in
  "directory (unversioned) — "*) : ;;
  *) v3="$v3 [a tree that is neither a checkout nor a package did not say so: '$(cat "$CB/h1/.claude/ai-flow/version" 2>/dev/null)']" ;;
esac
# The manifest is named as a manifest that was read, never as a release identity. This repository carries a
# package.json of its own, so a zip or a copy of the trunk finds one too — and the one thing this file must
# never do is answer "which release is this?" confidently and wrongly.
case "$(cat "$CB/h6/.claude/ai-flow/version" 2>/dev/null)" in
  "package.json "*" — "*) : ;;
  *) v3="$v3 [a tree carrying a manifest did not name it as one: '$(cat "$CB/h6/.claude/ai-flow/version" 2>/dev/null)']" ;;
esac
case "$(cat "$CB/h7/.claude/ai-flow/version" 2>/dev/null)" in
  "trunk"*) : ;;
  *) v3="$v3 [the one-line door did not name itself: '$(cat "$CB/h7/.claude/ai-flow/version" 2>/dev/null)']" ;;
esac
[ -z "$v3" ] && ok "the version names which of the four routes installed the engine, and never invents a release" \
             || bad "the version names which of the four routes installed the engine, and never invents a release ($v3)"

# B4 -- WHERE the installer ran from a directory that is not a git checkout, the drift guard shall exit
# silently at session close. Both halves are asserted: while that directory still exists, and once it is
# gone. The second half is the one an evicted package cache produces, and it is the failure this task exists for.
( cd "$CB/pkg-gone" && HOME="$CB/h3" bash "$CB/pkg-gone/install.sh" update </dev/null >/dev/null 2>&1 ) || true
rm -rf "$CB/pkg-gone"
s4=""
HOME="$CB/h1" bash "$ROOT/global/hooks/drift-check.sh" </dev/null >/dev/null 2>&1 \
  || s4=" [it refuses while the install directory still exists]"
HOME="$CB/h3" bash "$ROOT/global/hooks/drift-check.sh" </dev/null >/dev/null 2>&1 \
  || s4="$s4 [it refuses once the install directory is gone]"
[ -z "$s4" ] && ok "a checkout-less install closes a session in silence, before and after its directory is gone" \
             || bad "a checkout-less install closes a session in silence, before and after its directory is gone ($s4)"

# B5 -- CONTROL for B4. IF the recorded source path names a directory that no longer exists, THEN the
# guard shall still refuse the close and name it. The cheapest way to pass B4 is to soften that refusal,
# which trades a false refusal for a false all-clear over installs that really have drifted.
mkdir -p "$CB/h4/.claude/ai-flow"
printf '%s\n' "$CB/never-existed" > "$CB/h4/.claude/ai-flow/source.path"
out5="$( HOME="$CB/h4" bash "$ROOT/global/hooks/drift-check.sh" </dev/null 2>&1 )" && rc5=0 || rc5=$?
r5=""
[ "${rc5:-0}" -eq 2 ] || r5=" [it did not refuse (exit ${rc5:-0})]"
case "$out5" in *"$CB/never-existed"*) : ;; *) r5="$r5 [the refusal does not name the recorded path]" ;; esac
[ -z "$r5" ] && ok "a recorded source path that has vanished still refuses the close and names it" \
             || bad "a recorded source path that has vanished still refuses the close and names it ($r5)"

# B6 -- WHEN the package entry point is invoked with a subcommand, it shall run the installer with that
# same subcommand. Reported as NOT CHECKED rather than passed where node is absent: the row would
# otherwise be green for the one reason that has nothing to do with the entry point.
if ! command -v node >/dev/null 2>&1; then
  bad "the entry point forwards its subcommand and its exit code to the installer — NOT CHECKED: node is not available"
elif [ ! -f "$ROOT/bin/ai-flow.js" ]; then
  bad "the entry point forwards its subcommand and its exit code to the installer (no bin/ai-flow.js)"
else
  HOME="$CB/h5" node "$ROOT/bin/ai-flow.js" update </dev/null >/dev/null 2>&1 && rc6=0 || rc6=$?
  r6=""
  [ "${rc6:-1}" -eq 0 ] || r6=" [it exited ${rc6:-1}]"
  [ -s "$CB/h5/.claude/ai-flow/protocols/understand.md" ] || r6="$r6 [the update it forwarded installed nothing]"
  # Everything above is equally true of an entry point that ignores its arguments and always runs `update`,
  # so on its own the row cannot tell forwarding from a hardcoded subcommand. What separates them is an
  # argument that must produce a DIFFERENT outcome. It is also this surface's own contract: the installer
  # reads an unrecognised first argument as a project directory to create, which on the documented npm door
  # turns `ai-flow updat` into a scaffolded project called `updat` reported as a success.
  out6="$( cd "$CB" && HOME="$CB/h5x" node "$ROOT/bin/ai-flow.js" updat </dev/null 2>&1 )" && rcx6=0 || rcx6=$?
  [ "${rcx6:-0}" -ne 0 ] || r6="$r6 [an unknown subcommand was accepted]"
  [ -d "$CB/updat" ] && r6="$r6 [an unknown subcommand created the directory '$CB/updat']"
  case "$out6" in *usage*) : ;; *) r6="$r6 [the refusal prints no usage line]" ;; esac
  [ -z "$r6" ] && ok "the entry point forwards a real subcommand and refuses one it does not know" \
               || bad "the entry point forwards a real subcommand and refuses one it does not know ($r6)"
fi

# B7 -- derived, and it closes a class rather than a case. npm's packing falls back to the package's OWN
# .gitignore and reads neither a personal global ignore nor .git/info/exclude, so the set git hides on a
# given machine and the set npm hides are not the same set -- a file hidden only by the first ships in
# silence, which is how the author's local Claude Code overrides reached a published tarball. Measured
# rather than remembered: every path the package would carry is put to git, which reads all three sources.
real_hidden() {  # $1 = a path -> 0 when the developer's own ignore rules hide it
  (
    if [ -n "$REAL_XDG" ]; then export XDG_CONFIG_HOME="$REAL_XDG"; else unset XDG_CONFIG_HOME; fi
    if [ -n "$REAL_GCG" ]; then export GIT_CONFIG_GLOBAL="$REAL_GCG"; else unset GIT_CONFIG_GLOBAL; fi
    git -C "$ROOT" check-ignore -q "$1" 2>/dev/null
  )
}
if ! command -v npm >/dev/null 2>&1; then
  bad "the package ships nothing git hides — NOT CHECKED: npm is not available"
else
  L7="$CB/pack.list"
  ( cd "$ROOT" && npm pack --dry-run --json 2>/dev/null ) \
    | grep -o '"path": *"[^"]*"' | sed 's/.*"path": *"//; s/"$//' > "$L7"
  if [ ! -s "$L7" ]; then
    # An empty listing is not an empty package; it is a question that went unanswered, and scoring it
    # green would be the false all-clear this row exists to prevent.
    bad "the package ships nothing git hides — NOT CHECKED: npm listed no files"
  else
    leak7=""
    while IFS= read -r p7; do
      [ -n "$p7" ] || continue
      real_hidden "$p7" && leak7="$leak7 [$p7]"
    done < "$L7"
    # A positive control, for the reason B2 and B5 exist. `real_hidden` returning false for every path is
    # indistinguishable from a package with no leak, and its verdict depends on the machine: on a runner
    # with no personal global ignore the loop finds nothing whatever the repository says. Something the
    # repo's OWN .gitignore names must come back hidden, or this row is measuring nothing.
    real_hidden ".ai-flow/BACKLOG.md" || leak7="$leak7 [the check cannot detect a path the repository itself ignores]"
    # And the one concrete entry this change added, pinned by name: without this the line can be deleted
    # and the row above stays green everywhere except the author's own machine.
    grep -q '^/\.claude/settings\.local\.json$' "$ROOT/.gitignore" \
      || leak7="$leak7 [.gitignore no longer names the local override file]"
    [ -z "$leak7" ] && ok "the package ships nothing git hides, and the check can prove it sees hiding" \
                    || bad "the package ships nothing git hides, and the check can prove it sees hiding ($leak7)"
  fi
fi

# B8 -- an install that records nothing must not REMOVE what is already there. The two are indistinguishable
# to every row above, because each installs into a fresh HOME where there was nothing to lose. An existing
# record names a checkout that still exists, and the guard comparing this engine against it reports a
# difference: true, and a report rather than a lost protection. The first draft of this function deleted,
# and no fixture could tell.
mkdir -p "$CB/h8/.claude/ai-flow" "$CB/h9/.claude/ai-flow"
printf '%s\n' "$ROOT" > "$CB/h8/.claude/ai-flow/source.path"
printf '%s\n' "$ROOT" > "$CB/h9/.claude/ai-flow/source.path"
( cd "$CB/pkg" && HOME="$CB/h8" bash "$CB/pkg/install.sh" update </dev/null >/dev/null 2>&1 ) || true
if [ "$(cat "$CB/h8/.claude/ai-flow/source.path" 2>/dev/null)" = "$ROOT" ]; then
  ok "an install that is not a checkout leaves an existing source path alone"
else
  bad "an install that is not a checkout leaves an existing source path alone (it now reads '$(cat "$CB/h8/.claude/ai-flow/source.path" 2>/dev/null || echo DELETED)')"
fi

# B9 -- the same, for the one-line door, which had no coverage of this at all. It is the documented update
# path, so an operator who installed from a clone and updates this way must not lose the watch in silence.
( cd "$CB" && AI_FLOW_MODE=remote AI_FLOW_REPO_URL="file://$CB/absent" HOME="$CB/h9" \
    bash "$ROOT/install.sh" update </dev/null >/dev/null 2>&1 ) || true
if [ "$(cat "$CB/h9/.claude/ai-flow/source.path" 2>/dev/null)" = "$ROOT" ]; then
  ok "the one-line door leaves an existing source path alone"
else
  bad "the one-line door leaves an existing source path alone (it now reads '$(cat "$CB/h9/.claude/ai-flow/source.path" 2>/dev/null || echo DELETED)')"
fi

# B10 -- where a package is actually installed: inside the operator's own repository. Asking git whether the
# directory has a commit answers YES there, about THEIR project, so the engine recorded their repository as
# its source and stamped their commit as its version. Everything the row above protects is undone by that
# one, which is why the question has to be whether this directory IS a checkout, not whether it sits in one.
mkdir -p "$CB/userrepo" "$CB/h10"
( cd "$CB/userrepo" && git init -q . && git -c user.email=t@example.invalid -c user.name=t commit -q --allow-empty -m x ) >/dev/null 2>&1
mkdir -p "$CB/userrepo/node_modules/ai-flow"
cp -R "$CB/pkg/." "$CB/userrepo/node_modules/ai-flow/"
( cd "$CB/userrepo/node_modules/ai-flow" && HOME="$CB/h10" bash ./install.sh update </dev/null >/dev/null 2>&1 ) || true
n10=""
[ -f "$CB/h10/.claude/ai-flow/source.path" ] \
  && n10=" [it recorded '$(cat "$CB/h10/.claude/ai-flow/source.path" 2>/dev/null)']"
case "$(cat "$CB/h10/.claude/ai-flow/version" 2>/dev/null)" in
  "checkout "*) n10="$n10 [it stamped the host repository's commit: '$(cat "$CB/h10/.claude/ai-flow/version" 2>/dev/null)']" ;;
esac
[ -z "$n10" ] && ok "a package unpacked inside another repository records neither that repository nor its commit" \
              || bad "a package unpacked inside another repository records neither that repository nor its commit ($n10)"

# B11 -- the spec's named edge case: a checkout whose commit cannot be read. It must name the route and
# invent nothing. Driven with a git that answers and then fails, which reaches the same branch as a git
# that is absent and does not depend on reconstructing a PATH without one.
mkdir -p "$CB/shim" "$CB/h11"
printf '#!/bin/sh\nexit 1\n' > "$CB/shim/git"; chmod +x "$CB/shim/git"
( cd "$ROOT" && PATH="$CB/shim:$PATH" HOME="$CB/h11" bash "$ROOT/install.sh" update </dev/null >/dev/null 2>&1 ) || true
g11=""
case "$(cat "$CB/h11/.claude/ai-flow/version" 2>/dev/null)" in
  "checkout (commit unreadable) — "*) : ;;
  *) g11=" [it wrote '$(cat "$CB/h11/.claude/ai-flow/version" 2>/dev/null)']" ;;
esac
[ -z "$g11" ] && ok "a checkout whose commit cannot be read names the route and invents no commit" \
              || bad "a checkout whose commit cannot be read names the route and invents no commit ($g11)"

# B12 -- the declared set, in the direction a declaration can be wrong. package.json now states what the
# package carries; stating too LITTLE is invisible to every other row, because they all run the installer
# from the repository, where every file is present whether or not it was declared. This one packs the
# package as the registry would, unpacks only that, and installs from it -- the adopter's path, which the
# author otherwise never walks again.
if ! command -v npm >/dev/null 2>&1; then
  bad "the packed package holds everything the installer needs — NOT CHECKED: npm is not available"
else
  mkdir -p "$CB/packed" "$CB/h12"
  ( cd "$ROOT" && npm pack --pack-destination "$CB/packed" >/dev/null 2>&1 ) || true
  TGZ12="$(ls "$CB/packed"/*.tgz 2>/dev/null | head -1)"
  if [ -z "$TGZ12" ]; then
    bad "the packed package holds everything the installer needs — NOT CHECKED: npm produced no tarball"
  else
    ( cd "$CB/packed" && tar xf "$TGZ12" ) 2>/dev/null
    p12=""
    [ -f "$CB/packed/package/install.sh" ] || p12=" [the tarball carries no installer]"
    if [ -z "$p12" ]; then
      # The download base is pointed at nothing that exists, and that is what makes this row measure the
      # tarball. Without it a package missing `global/` fails the installer's own mode detection, falls
      # back to REMOTE, and fetches the very files it failed to carry -- from the network, inside a suite
      # that states it involves none. The row then reported a complete package because the internet
      # completed it.
      ( cd "$CB/packed/package" && AI_FLOW_REPO_URL="file://$CB/absent" HOME="$CB/h12" \
          bash ./install.sh update </dev/null >/dev/null 2>&1 ) || true
      for f12 in \
        "ai-flow/protocols/understand.md" "ai-flow/protocols/lifecycle.md" "ai-flow/docs/customization.md" \
        "skills/understand/SKILL.md" "workflows/verify-review.js" "hooks/drift-check.sh" \
        "hooks/git/pre-push" "ai-flow/ralph/ralph.sh" "ai-flow/scripts/seed-front.sh"; do
        [ -s "$CB/h12/.claude/$f12" ] || p12="$p12 [$f12 never arrived]"
      done
      [ -s "$CB/h12/.claude/ai-flow/version" ] || p12="$p12 [it recorded no version]"
      [ -f "$CB/h12/.claude/ai-flow/source.path" ] && p12="$p12 [a package recorded a source path]"
    fi
    [ -z "$p12" ] && ok "the packed package holds everything the installer needs" \
                  || bad "the packed package holds everything the installer needs ($p12)"
  fi
fi

rm -rf "$CB"
