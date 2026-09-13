# C55 — the ledger's size budget is measured in the prose it is made of, said once a session rather than
# refused, and no report from this guardian repeats itself turn after turn. Generated in the Conform phase
# from understand.md's Verifiable Criteria.
#
# Every verdict is derived from an exact exit code or from a COUNT, never from a `grep -v` inside an `if`.
#
# TWO CHANNELS ARE THE DESIGN, and it is what separates these rows from C45's. C45 captures the guard with
# `2>&1` and keys on the exit code, so it cannot tell a message delivered on stdout from one on stderr —
# which is precisely the distinction this task introduces: a `Stop` hook that exits 0 has its stderr
# discarded by the harness, so a note written there would reach nobody, while a blocker's report must NOT
# move to stdout, where a refusing hook's JSON is not read. Every row below therefore captures the two
# streams separately. C45's own rows stay unedited except the three this task retargets, and they remain
# the holders of the exit codes for all five bounded reports.
echo "== C55: the ledger's size budget is prose, said once, and no report repeats =="
GRD55="$HK/check-state-size.sh"
BLG55="$ROOT/global/protocols/backlog.md"

# The same capability probe C45 documents: chmod 000 is the whole method for the unreadable rows and it
# does not work for a superuser, so a row built on it would report a repair while measuring nothing.
UNREAD55=1
if PRB55="$(mktemp 2>/dev/null)"; then
  printf 'x\n' > "$PRB55"; chmod 000 "$PRB55"
  cat "$PRB55" >/dev/null 2>&1 && UNREAD55=0
  chmod 644 "$PRB55" 2>/dev/null; rm -f "$PRB55"
else
  UNREAD55=0
fi

T55=""

# A roster whose only non-table lines are its own headings: readable, carrying no closure narrative. The
# control that keeps every refusal row below from being satisfied by a guard that refuses everything.
ros55() {
  printf '# Session State\n\n## Workstreams\n\n'
  printf '| Workstream | Checkout | Task | Epic | Areas | Tool | Opened |\n'
  printf '|---|---|---|---|---|---|---|\n'
  printf '| coordinator | . | T-100 | E-009 | auth | - | 2026-08-01 |\n'
}
# The one thing the roster invariant forbids, placed in the notes.
vio55() { ros55; printf '\n## Notes\n\n**Epic E-007 CLOSED 2026-07-30.** Sealed: `archive/E-007.md`.\n'; }
log55() { i=0; while [ "$i" -lt "$1" ]; do printf '> 2026-0%s-01 session close\n' "$((i+1))"; i=$((i+1)); done; }
# A project whose ledger holds the given roster and EXACTLY the given word count, heading included. The
# heading is two words to `wc -w` — `#` and `Backlog` — so the filler is short by two. Counted rather than
# assumed because the boundary rows are the whole point of this section: with the filler taking the total
# unadjusted, an 8,001-word fixture measured 8,003, the note reported a number no row was looking for, and
# the 8,000-word control tripped the budget. The rows were right and the fixture was lying to them.
mk55() {  # $1 = dir, $2 = roster fn, $3 = total words in the ledger
  mkproj "$1" main
  mkdir -p "$1/.ai-flow"
  "$2" > "$1/.ai-flow/STATE.md"
  { printf '# Backlog\n\n'; nwords "$(( $3 - 2 ))"; } > "$1/.ai-flow/BACKLOG.md"
}
# The guard run with a payload on stdin, the two streams kept apart. $1 = cwd, $2 = payload.
# stdout lands in the caller's substitution; stderr is diverted to a file the caller reads by name.
run55() { ( cd "$1" && printf '%s' "$2" | bash "$GRD55" 2>"$T55/err" ); }
# The two occasions, named rather than implied. A bare `{}` used to stand for a close and worked only
# because the guard treated any event it could not place as the refusing half -- the default that let a
# refusal reach the prompt event, now removed. A fixture that means a close says so.
STOP55='{"hook_event_name":"Stop"}'
# The note half runs at `UserPromptSubmit` and the refusing half at `Stop`, so every row below says which
# one it is exercising. A note row driven on an empty payload measures the refusing half and reports the
# note missing when it is merely elsewhere; a refusal row driven at the note's event gets exit 0 and no
# refusal at all. The refusal rows keep their empty payload deliberately — that is the refusing half's
# own occasion, and it is also what the malformed and re-delivery rows below need.
UPS55='{"hook_event_name":"UserPromptSubmit"}'

if ! T55="$(mkbox)" || [ ! -d "$T55" ]; then
  bad "A1 a backlog over its word budget is noted, not refused (no sandbox: mktemp -d failed)"
  bad "A2 the firm note states both the measurement and the threshold (no sandbox: mktemp -d failed)"
  bad "A3 the word budget speaks at 8,001 and stays silent at 8,000 (no sandbox: mktemp -d failed)"
  bad "A4 a re-delivered stop is answered with silence, blockers included (no sandbox: mktemp -d failed)"
  bad "A5 two reports in one run both reach the operator, on stderr (no sandbox: mktemp -d failed)"
  bad "A6 a threshold already spoken in this session is not spoken again (no sandbox: mktemp -d failed)"
  bad "A7 every bounded report refuses, and reports on stderr (no sandbox: mktemp -d failed)"
  bad "A8 with no python3 the note speaks rather than falling silent (no sandbox: mktemp -d failed)"
  bad "A9 the size rule names three causes and the third's remedy is not a prune (no sandbox: mktemp -d failed)"
  bad "A10 no document states a line budget for the ledger (no sandbox: mktemp -d failed)"
elif [ ! -r "$GRD55" ] || [ ! -s "$GRD55" ] || [ ! -r "$BLG55" ] || [ ! -s "$BLG55" ]; then
  bad "A1 a backlog over its word budget is noted, not refused (the guard or the protocol is unreadable)"
  bad "A2 the firm note states both the measurement and the threshold (the guard or the protocol is unreadable)"
  bad "A3 the word budget speaks at 8,001 and stays silent at 8,000 (the guard or the protocol is unreadable)"
  bad "A4 a re-delivered stop is answered with silence, blockers included (the guard or the protocol is unreadable)"
  bad "A5 two reports in one run both reach the operator, on stderr (the guard or the protocol is unreadable)"
  bad "A6 a threshold already spoken in this session is not spoken again (the guard or the protocol is unreadable)"
  bad "A7 every bounded report refuses, and reports on stderr (the guard or the protocol is unreadable)"
  bad "A8 with no python3 the note speaks rather than falling silent (the guard or the protocol is unreadable)"
  bad "A9 the size rule names three causes and the third's remedy is not a prune (the guard or the protocol is unreadable)"
  bad "A10 no document states a line budget for the ledger (the guard or the protocol is unreadable)"
  rm -rf "$T55"
else

  # --- A1: over the soft threshold, and nothing else wrong ---------------------
  # WHILE BACKLOG.md holds more than 8,000 words and no blocking report stands, the guardian shall exit 0
  # and deliver its size report as a top-level `systemMessage` on stdout.
  # Three legs, and the stdout one is the criterion's whole point: exit 0 alone is also what a guard that
  # simply stopped measuring would give, and a note on stderr at exit 0 is a note the harness discards.
  P55A="$T55/a"; mk55 "$P55A" ros55 8001
  o55="$(run55 "$P55A" "$UPS55")"; rc55=$?
  e55="$(cat "$T55/err")"
  c1_55=""
  [ "$rc55" = 0 ] || c1_55="$c1_55 [a backlog over the word budget did not let the turn close (exit $rc55)]"
  case "$o55" in *systemMessage*) : ;; *) c1_55="$c1_55 [no systemMessage on stdout, so the note reaches nobody]" ;; esac
  case "$o55" in *"8001 words"*) : ;; *) c1_55="$c1_55 [the note does not state the measured word count]" ;; esac
  case "$o55" in *8000*) : ;; *) c1_55="$c1_55 [the note does not state the threshold it crossed]" ;; esac
  [ -z "$e55" ] || c1_55="$c1_55 [a note-only run wrote to stderr, which a hook exiting 0 has discarded]"
  # THE ENVELOPE MUST PARSE, and a substring cannot ask that. Every other delivery leg in this section and
  # in C45 keys on the glob `*systemMessage*`, which a document that is not JSON at all still matches — so
  # the one failure the hook takes the trouble to write down beside its emitter (no quote, no backslash, no
  # newline, because the python3-absent path has no escaper) is the one failure the suite could not see.
  # The failure is silent and total: the harness drops an unparseable message and the note reaches nobody,
  # with every row green. Reachable rather than theoretical, because `add_note` joins with a raw newline.
  if [ "$PY3" = 1 ]; then
    printf '%s' "$o55" | python3 -c 'import json, sys
d = json.load(sys.stdin)
sys.exit(0 if isinstance(d, dict) and isinstance(d.get("systemMessage"), str) else 1)' 2>/dev/null \
      || c1_55="$c1_55 [the note is not a JSON object the harness can parse into a systemMessage]"
  fi
  # The cause list, in the message the operator actually reads. A9 pins it in the protocol only, and the
  # note could be cut back to a bare word count with every row still green — which is the size-only report
  # this task set out to replace, minus the refusal. Decision 4 is the reason the change is worth making.
  case "$o55" in *archive/CHANGELOG.md*) : ;; *) c1_55="$c1_55 [the note names no destination for closed content]" ;; esac
  case "$o55" in *Icebox*) : ;; *) c1_55="$c1_55 [the note does not name the second cause]" ;; esac
  case "$o55" in *essays*) : ;; *) c1_55="$c1_55 [the note does not name the third cause]" ;; esac
  case "$o55" in *"pruning does not fix"*) : ;; *) c1_55="$c1_55 [the note does not refuse the prune for the third cause]" ;; esac
  [ -z "$c1_55" ] && ok "A1 a backlog over its word budget is noted, not refused" \
                  || bad "A1 a backlog over its word budget is noted, not refused:$c1_55"

  # --- A2: the firm threshold ---------------------------------------------------
  # WHILE BACKLOG.md holds more than 15,000 words, the guardian shall deliver the FIRM form, and that form
  # shall state both the measurement and the threshold. The two forms must be distinguishable, or the
  # second threshold is decoration: the firm note carries its own threshold in its mark, so a guard that
  # spoke the soft form at 15,001 fails here on the mark rather than on the prose.
  P55B="$T55/b"; mk55 "$P55B" ros55 15001
  o55="$(run55 "$P55B" "$UPS55")"; rc55=$?
  c2_55=""
  [ "$rc55" = 0 ] || c2_55="$c2_55 [the firm note refused instead of speaking (exit $rc55)]"
  case "$o55" in *"15001 words"*) : ;; *) c2_55="$c2_55 [the firm note does not state the measurement]" ;; esac
  case "$o55" in *15000*) : ;; *) c2_55="$c2_55 [the firm note does not state its own threshold]" ;; esac
  case "$o55" in *"ledger size note [15000]"*) : ;; *) c2_55="$c2_55 [the firm form is not distinguishable from the soft one]" ;; esac
  # ONLY THE LEVEL REACHED IS SPOKEN — the edge case with the most evidence behind it and, until this leg,
  # no assertion at all. `add_note` is an accumulator, so two notes in one payload is a shape the code can
  # express, and a guard that emitted both satisfied every leg above. Two directions, because they catch
  # different rewrites: both-in-one-run here, and the SEQUENTIAL form below, where a guard written as a
  # search for any unspoken threshold speaks the firm note first, marks only the firm one, and then
  # contradicts itself with the soft one at the next close. That second shape is the one the sibling
  # reproduced live and the one the exit-code and mark legs above cannot see.
  case "$o55" in *"ledger size note [8000]"*) c2_55="$c2_55 [the soft note was spoken beside the firm one]" ;; esac
  TR55F="$T55/firm-spoken.jsonl"
  printf '%s\n' '{"attachment":{"type":"hook_system_message","content":"ai-flow ledger size note [15000] — BACKLOG.md is 15001 words"}}' > "$TR55F"
  o55="$(run55 "$P55B" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$TR55F\"}")"
  case "$o55" in *systemMessage*) c2_55="$c2_55 [with the firm note already spoken the guard fell back to the soft one]" ;; esac
  # And FIRM IN PROSE, not only in the mark. The approved contract promises the guardian speaks "softly
  # above one threshold, firmly above a higher one"; a firm form that differs from the soft one by its
  # numbers and a machine-readable mark alone delivers the second threshold as decoration, and the
  # operator whose ledger has doubled reads the sentence the 8,001-word operator already read.
  P55B2="$T55/b2"; mk55 "$P55B2" ros55 8001
  o55b="$(run55 "$P55B2" "$UPS55")"
  o55="$(run55 "$P55B" "$UPS55")"
  firmonly55=""
  case "$o55"  in *"firm threshold"*) firmonly55=1 ;; esac
  case "$o55b" in *"firm threshold"*) firmonly55="" ;; esac
  [ -n "$firmonly55" ] || c2_55="$c2_55 [the firm form carries no sentence the soft form does not]"
  [ -z "$c2_55" ] && ok "A2 the firm note states both the measurement and the threshold" \
                  || bad "A2 the firm note states both the measurement and the threshold:$c2_55"

  # --- A3: the boundary ---------------------------------------------------------
  # The edge itself, because a budget driven only well above and well below it ships an off-by-one either
  # way. This is the row C45's line-budget boundary row becomes.
  P55C="$T55/c"; mk55 "$P55C" ros55 8000
  o55="$(run55 "$P55C" "$UPS55")"; rc55=$?
  c3_55=""
  [ "$rc55" = 0 ] || c3_55="$c3_55 [a backlog of exactly 8,000 words did not pass (exit $rc55)]"
  case "$o55" in *systemMessage*) c3_55="$c3_55 [8,000 words spoke, so the budget fires one word early]" ;; esac
  mk55 "$P55C" ros55 8001 >/dev/null 2>&1
  o55="$(run55 "$P55C" "$UPS55")"
  case "$o55" in *systemMessage*) : ;; *) c3_55="$c3_55 [8,001 words stayed silent, so the budget fires one word late]" ;; esac
  # The SECOND threshold has an edge too, and this task introduced it in exactly the state this row was
  # written to condemn: driven at 15,001 by A2 and at 8,000-8,001 here, so the 15,000 point is never
  # touched and `-gt 15000` could become `-ge 15000` with the whole suite green.
  mk55 "$P55C" ros55 15000 >/dev/null 2>&1
  o55="$(run55 "$P55C" "$UPS55")"
  case "$o55" in *"ledger size note [8000]"*) : ;; *) c3_55="$c3_55 [exactly 15,000 words did not take the soft level]" ;; esac
  case "$o55" in *"ledger size note [15000]"*) c3_55="$c3_55 [15,000 words took the firm level, so the firm budget fires one word early]" ;; esac
  mk55 "$P55C" ros55 15001 >/dev/null 2>&1
  o55="$(run55 "$P55C" "$UPS55")"
  case "$o55" in *"ledger size note [15000]"*) : ;; *) c3_55="$c3_55 [15,001 words did not take the firm level, so the firm budget fires one word late]" ;; esac
  [ -z "$c3_55" ] && ok "A3 the word budget speaks at 8,001 and stays silent at 8,000" \
                  || bad "A3 the word budget speaks at 8,001 and stays silent at 8,000:$c3_55"

  # --- A4: the loop guard -------------------------------------------------------
  # WHEN the Stop payload declares `stop_hook_active` true, the guardian shall exit 0 and deliver NO report
  # at all, blockers included. This is the row that fails today: the guard reads stdin nowhere, so it
  # re-refuses the stop the harness re-delivers after its own refusal — the defect three siblings at this
  # event already close. The fixture violates the roster invariant AND the word budget, so a guard that
  # honoured the flag for only one of its two buckets fails here.
  P55D="$T55/d"; mk55 "$P55D" vio55 8001
  o55="$(run55 "$P55D" '{"stop_hook_active":true}')"; rc55=$?
  e55="$(cat "$T55/err")"
  c4_55=""
  [ "$rc55" = 0 ] || c4_55="$c4_55 [a re-delivered stop was refused again (exit $rc55)]"
  [ -z "$e55" ]   || c4_55="$c4_55 [a re-delivered stop still wrote a report to stderr]"
  case "$o55" in *systemMessage*) c4_55="$c4_55 [a re-delivered stop still spoke on stdout]" ;; esac
  # The control. Without it a guard that had gone silent for every payload would pass the row above, and
  # the whole section would be measuring a guard that no longer guards.
  o55="$(run55 "$P55D" "$STOP55")"; rc55=$?
  [ "$rc55" = 2 ] || c4_55="$c4_55 [a first-delivery stop over a violating roster no longer refuses (exit $rc55)]"
  # Malformed is ABSENT, and absent REPORTS. RE-KEYED, and the claim is unchanged -- what moved is the
  # channel the report leaves on, because the guard now runs at two events and a truncated payload cannot
  # say which. It required exit 2. A refusal is a block, and a block at the note's event stops the
  # operator's prompt over a report they cannot act on there; so an unplaceable run reports EVERYTHING it
  # found, refusals included, as a note on stdout at exit 0. The direction this leg has always held --
  # a truncated payload is never read as permission to go quiet -- is what the replacement asserts, and it
  # asserts it harder: silence now fails the row whichever bucket the report came from.
  o55="$(run55 "$P55D" '{"stop_hook_active":true')"; rc55=$?
  [ "$rc55" = 0 ] || c4_55="$c4_55 [an unplaceable payload blocked, which at the note's event costs the prompt (exit $rc55)]"
  case "$o55" in *"closed-work narrative"*) : ;; *) c4_55="$c4_55 [a truncated payload was read as an instruction to go quiet]" ;; esac
  [ -z "$c4_55" ] && ok "A4 a re-delivered stop is answered with silence, blockers included" \
                  || bad "A4 a re-delivered stop is answered with silence, blockers included:$c4_55"

  # --- A5: a blocker and a note in one run, RE-KEYED ----------------------------
  # It required the note to join the blocker on stderr, and that merge is GONE: the note has an event of
  # its own now, so it is never on the refusing run's stream to be lost — which is what the merge existed
  # to prevent — and it is no longer delivered by a route that lays no mark, which is what the merge cost.
  # The claim that replaces it is the one the split creates and nothing else here would see: ONE ledger
  # breaching both, each half speaking at its own event, neither carrying the other's report. Driven on
  # one fixture, because two would prove only that each half works alone.
  P55E="$T55/e"; mk55 "$P55E" vio55 8001
  c5_55=""
  o55="$(run55 "$P55E" "$STOP55")"; rc55=$?
  e55="$(cat "$T55/err")"
  [ "$rc55" = 2 ] || c5_55="$c5_55 [the blocker no longer refuses at its own event (exit $rc55)]"
  case "$e55" in *"closed-work narrative"*) : ;; *) c5_55="$c5_55 [the blocking report was dropped]" ;; esac
  case "$e55" in *"8001 words"*) c5_55="$c5_55 [the refusal still carries the note, which now has an event of its own]" ;; esac
  case "$o55" in *systemMessage*) c5_55="$c5_55 [the refusing run wrote to stdout, which a hook exiting 2 has unread]" ;; esac
  o55="$(run55 "$P55E" "$UPS55")"; rc55=$?
  e55="$(cat "$T55/err")"
  [ "$rc55" = 0 ] || c5_55="$c5_55 [the note refused at its own event, where a refusal stops the prompt (exit $rc55)]"
  case "$o55" in *"8001 words"*) : ;; *) c5_55="$c5_55 [the note is lost on a ledger that also carries a blocker]" ;; esac
  case "$o55" in *additionalContext*) : ;; *) c5_55="$c5_55 [the note reaches the operator but not the model, which is the sweeper]" ;; esac
  case "$e55" in *"closed-work narrative"*) c5_55="$c5_55 [the note's run carried the blocker, which cannot refuse there]" ;; esac
  [ -z "$c5_55" ] && ok "A5 a blocker and a note in one ledger speak at their own events, neither carrying the other" \
                  || bad "A5 a blocker and a note in one ledger speak at their own events, neither carrying the other:$c5_55"

  # --- A6: once per session -----------------------------------------------------
  # WHILE a threshold's note already stands in this session's transcript, it is not delivered again. The
  # mark is the note's own text, read ONLY out of the harness's delivery records — never out of a
  # free-text search of the file, which counts every other way the text can arrive and self-silences in
  # this very repository, whose conformance suite holds the mark verbatim. Both directions, because a
  # guard that had simply gone quiet would pass the suppression half alone.
  P55F="$T55/f"; mk55 "$P55F" ros55 8001
  TR55="$T55/spoken.jsonl"
  printf '%s\n' '{"type":"assistant","message":{"usage":{}}}' > "$TR55"
  printf '%s\n' '{"attachment":{"type":"hook_system_message","content":"ai-flow ledger size note [8000] — BACKLOG.md is 8001 words"}}' >> "$TR55"
  TR55B="$T55/unspoken.jsonl"
  printf '%s\n' '{"type":"assistant","message":{"usage":{}}}' > "$TR55B"
  c6_55=""
  o55="$(run55 "$P55F" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$TR55\"}")"
  case "$o55" in *systemMessage*) c6_55="$c6_55 [the note was spoken twice in one session]" ;; esac
  o55="$(run55 "$P55F" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$TR55B\"}")"
  case "$o55" in *systemMessage*) : ;; *) c6_55="$c6_55 [a session that never heard the note did not hear it]" ;; esac
  # A transcript that cannot be read must fall to SPEAKING. A missed note is harmless; a note suppressed
  # on a session that never heard it is the direction this must never fail in.
  o55="$(run55 "$P55F" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$T55/does-not-exist.jsonl\"}")"
  case "$o55" in *systemMessage*) : ;; *) c6_55="$c6_55 [an unreadable transcript silenced the note]" ;; esac
  # THE ANCHORING ITSELF, which the three legs above cannot see: each of them is satisfied by a plain text
  # search of the whole file — the mark is found where it is found, and absent where it is absent. The one
  # shape that discriminates is the mark arriving in a record that is NOT a delivery: a user typing it, a
  # tool result quoting it. That is the failure the hook spends its longest comment on and the sibling
  # reproduced on a 248-turn session, and it is the failure this repository walks into by construction,
  # because the suite two lines up holds the mark verbatim. The house wrote this leg once already for the
  # sibling (C48 A13); this is the same leg for the port.
  TR55Q="$T55/quoted.jsonl"
  printf '%s\n' '{"type":"user","message":{"content":"why did ai-flow ledger size note [8000] not fire"}}' > "$TR55Q"
  printf '%s\n' '{"type":"user","toolUseResult":{"stdout":"ai-flow ledger size note [8000] — BACKLOG.md is 8001 words"}}' >> "$TR55Q"
  o55="$(run55 "$P55F" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$TR55Q\"}")"
  case "$o55" in *systemMessage*) : ;; *) c6_55="$c6_55 [the mark was found outside a delivery record, so a quote of it silences the note]" ;; esac
  # The OTHER delivery record, and it is the common one: the measurement behind this design found 73
  # `hook_system_message` records and 45,821 `hook_success` ones, the mark living in `stdout` there. With
  # only the first shape driven, dropping "hook_success" from DELIVERY — or the `stdout` half of the
  # concatenation — leaves the suite green while the note repeats every turn on every real session.
  TR55S="$T55/spoken-success.jsonl"
  printf '%s\n' '{"attachment":{"type":"hook_success","stdout":"{\"systemMessage\": \"ai-flow ledger size note [8000] — BACKLOG.md is 8001 words\"}"}}' > "$TR55S"
  o55="$(run55 "$P55F" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$TR55S\"}")"
  case "$o55" in *systemMessage*) c6_55="$c6_55 [a delivery recorded as hook_success/stdout did not lay the mark]" ;; esac

  # The THIRD delivery record, and it is the one this split created: the model half is written back as
  # `hook_additional_context`, and its `content` is a LIST. Nothing here drove it — the only two fixtures
  # in the file that carry the type drive the sibling hook — so `hook_additional_context` could be dropped
  # from DELIVERY, or the list-join could be deleted and the content matched by accidental stringification,
  # and this section would stay green while the note repeated on every prompt of every real session. The
  # list is the half that gets forgotten: a reader that adds the type and keeps stringifying matches by
  # accident, and the accident stops the day the harness wraps that list in anything.
  TR55L="$T55/spoken-model.jsonl"
  # The mark is SPLIT ACROSS elements, at a space, and that is the whole discriminating power of the leg.
  # With the mark whole inside one element, `"%s" % the_list` still contains it contiguously — the accident
  # works, and deleting the join leaves the row green, which is how the first version of this fixture was
  # caught. Split, only the join reconstitutes it: joined with a single space the mark is there, while the
  # stringified list reads `['ai-flow ledger size note', '[8000] — ...']` and never carries it whole.
  printf '%s\n' '{"attachment":{"type":"hook_additional_context","content":["ai-flow ledger size note","[8000] — BACKLOG.md is 8001 words"]}}' > "$TR55L"
  o55="$(run55 "$P55F" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$TR55L\"}")"
  case "$o55" in *systemMessage*) c6_55="$c6_55 [a note already delivered to the model was spoken again, so the mark is not read from the model half]" ;; esac
  # And PER THRESHOLD, which is the criterion's own wording and which no leg above varies: every one of
  # them drives 8,001 words against an [8000] mark. Dropping the threshold from the mark and searching the
  # bare prefix passes all of them, and permanently silences the firm note on any session that had already
  # heard the soft one — the normal progression this design expects.
  P55F2="$T55/f2"; mk55 "$P55F2" ros55 15001
  o55="$(run55 "$P55F2" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$TR55\"}")"
  case "$o55" in *"ledger size note [15000]"*) : ;; *) c6_55="$c6_55 [the soft note already spoken silenced the firm one, so the mark is not per-threshold]" ;; esac
  [ -z "$c6_55" ] && ok "A6 a threshold already spoken in this session is not spoken again" \
                  || bad "A6 a threshold already spoken in this session is not spoken again:$c6_55"

  # --- A7: the bounded reports keep refusing, and report on stderr ---------------
  # The five reports whose remedy is bounded and doable in the same turn keep the refusal. C45 holds their
  # exit codes and those rows stay unedited; what this row adds is the CHANNEL, which C45's combined
  # capture cannot see — a blocker moved to stdout is a blocker the harness does not read at exit 2. The
  # permission cases are gated on the same capability probe C45 documents.
  c7_55=""
  P55G="$T55/g"; mk55 "$P55G" vio55 100
  o55="$(run55 "$P55G" "$STOP55")"; rc55=$?; e55="$(cat "$T55/err")"
  [ "$rc55" = 2 ] || c7_55="$c7_55 [closed-work narrative no longer refuses (exit $rc55)]"
  case "$e55" in *"closed-work narrative"*) : ;; *) c7_55="$c7_55 [the narrative report is not on stderr]" ;; esac
  case "$o55" in *systemMessage*) c7_55="$c7_55 [the narrative report moved to stdout, where a refusal is not read]" ;; esac
  P55H="$T55/h"; mkproj "$P55H" main; mkdir -p "$P55H/.ai-flow"; ros55 > "$P55H/.ai-flow/STATE.md"
  { printf '# Backlog\n\n'; log55 5; } > "$P55H/.ai-flow/BACKLOG.md"
  o55="$(run55 "$P55H" "$STOP55")"; rc55=$?; e55="$(cat "$T55/err")"
  [ "$rc55" = 2 ] || c7_55="$c7_55 [the changelog ceiling no longer refuses (exit $rc55)]"
  case "$e55" in *"5 session-close"*) : ;; *) c7_55="$c7_55 [the changelog report is not on stderr]" ;; esac
  if [ "$UNREAD55" = 1 ]; then
    P55I="$T55/i"; mk55 "$P55I" vio55 100
    chmod 000 "$P55I/.ai-flow/STATE.md"
    o55="$(run55 "$P55I" "$STOP55")"; rc55=$?; e55="$(cat "$T55/err")"
    chmod 644 "$P55I/.ai-flow/STATE.md"
    [ "$rc55" = 2 ] || c7_55="$c7_55 [an unreadable roster no longer refuses (exit $rc55)]"
    case "$e55" in *STATE.md*) : ;; *) c7_55="$c7_55 [the unreadable-roster refusal is not on stderr]" ;; esac
    P55K="$T55/k"; mk55 "$P55K" ros55 100
    chmod 000 "$P55K/.ai-flow/BACKLOG.md"
    o55="$(run55 "$P55K" "$STOP55")"; rc55=$?; e55="$(cat "$T55/err")"
    chmod 644 "$P55K/.ai-flow/BACKLOG.md"
    [ "$rc55" = 2 ] || c7_55="$c7_55 [an unreadable ledger no longer refuses (exit $rc55)]"
    case "$e55" in *BACKLOG.md*) : ;; *) c7_55="$c7_55 [the unreadable-ledger refusal is not on stderr]" ;; esac
    P55L="$T55/l"; mk55 "$P55L" ros55 100
    chmod 000 "$P55L/.ai-flow"
    o55="$(run55 "$P55L" "$STOP55")"; rc55=$?
    chmod 745 "$P55L/.ai-flow"
    [ "$rc55" = 2 ] || c7_55="$c7_55 [an unenterable ledger directory no longer refuses (exit $rc55)]"
  fi
  [ -z "$c7_55" ] && ok "A7 every bounded report refuses, and reports on stderr" \
                  || bad "A7 every bounded report refuses, and reports on stderr:$c7_55"

  # --- A8: no python3 -----------------------------------------------------------
  # WHERE python3 is unavailable, the note speaks rather than being suppressed. The engine's drift guard
  # already sets this precedent and states its reason: with no parser there is no suppression at all, the
  # noisy direction, which is the safe one. The shim is a PATH holding symlinks to the tools this guard
  # uses and no python3 — git among them, verified to work through a symlink, so the guard's own git
  # fallback is not what is being measured here.
  c8_55=""
  NP55="$T55/nopy"; mkdir -p "$NP55"
  for t55 in bash sh git awk grep sed tr wc cat head; do
    p55="$(command -v "$t55" 2>/dev/null)" && ln -sf "$p55" "$NP55/$t55"
  done
  # Asked in a CHILD bash, and that is the whole of what makes the question answerable. A hash table is
  # per-process: this harness has run `python3` many times by now, so `command -v python3` in *this* shell
  # answers from the cache and ignores PATH entirely — it reported the shim broken while the shim was
  # fine. The guard under test is itself a child process with an empty table, so a child is also the
  # honest place to ask.
  if PATH="$NP55" bash -c 'command -v python3 >/dev/null 2>&1'; then
    echo "  [skip] A8: python3 is reachable even under the stripped PATH, so absence cannot be staged here."
  else
    P55M="$T55/m"; mk55 "$P55M" ros55 8001
    # With no parser there is no event read either, and the guard must still reach its note half —
    # otherwise this row is green on the refusing half's silence, which is not what it claims to measure.
    o55="$( cd "$P55M" && printf '%s' "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$TR55\"}" | PATH="$NP55" bash "$GRD55" 2>"$T55/err" )"; rc55=$?
    [ "$rc55" = 0 ] || c8_55="$c8_55 [with no python3 the guard refused instead of speaking (exit $rc55)]"
    case "$o55" in *systemMessage*) : ;; *) c8_55="$c8_55 [with no python3 the note fell silent — the one direction it must not fail in]" ;; esac
    # PARSED, and by the harness's own python3 rather than the guard's — the guard is the thing denied a
    # parser here, not this row. Until this leg the only emission path in the file that hand-builds its
    # JSON was also the only one nothing validated: a `case` glob matches `systemMessage` inside a document
    # that is not JSON at all, so the note could reach neither audience with the row green.
    printf '%s' "$o55" | python3 -c 'import json,sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(1)
sys.exit(0 if isinstance(d, dict) else 1)' 2>/dev/null \
      || c8_55="$c8_55 [the hand-built delivery is not valid JSON, so the harness drops it and both audiences lose the note]"
    # And the MODEL half, which is the whole point of the task: without this leg the parser-less path could
    # keep delivering an operator-only note — the defect this change exists to remove — and pass.
    case "$o55" in *additionalContext*) : ;; *) c8_55="$c8_55 [with no python3 the note reaches the operator but not the model, which is the sweeper]" ;; esac
    # The ESCAPER ITSELF, driven directly, because no fixture can reach it through the ledger: every report
    # this file emits states a measured count and never the content it measured, so no quote in a
    # BACKLOG.md can ever land in the note. Written as a fixture it was a leg that proved nothing — dropping
    # the escaper left it green, which is how it was caught.
    #
    # What makes the escaper load-bearing anyway is the accumulator: `add_note` joins reports with a raw
    # newline, which is illegal inside a JSON string, so the first run carrying two reports emits a
    # malformed document and the note reaches neither audience. The function is extracted and fed the three
    # characters that break the literal, which is the honest way to test a thing whose caller cannot yet
    # produce them.
    JE55="$(awk '/^json_escape\(\) \{/{f=1} f{print} f&&/^\}$/{exit}' "$GRD55")"
    if [ -z "$JE55" ]; then
      c8_55="$c8_55 [the parser-less path's escaper could not be located, so nothing proves it escapes]"
    else
      ( eval "$JE55"
        printf '{"m": "%s"}' "$(json_escape 'he said "hi" with a \ backslash
and a second line')" ) > "$T55/esc.json" 2>/dev/null
      python3 -c 'import json,sys
d = json.load(open(sys.argv[1]))
t = d["m"]
assert chr(34) in t and chr(92) in t and chr(10) in t, "the escaper dropped what it was meant to carry"' "$T55/esc.json" 2>/dev/null \
        || c8_55="$c8_55 [a report carrying a quote, a backslash or a newline breaks the hand-built JSON, silently]"
    fi
    [ -z "$c8_55" ] && ok "A8 with no python3 the note speaks rather than falling silent" \
                    || bad "A8 with no python3 the note speaks rather than falling silent:$c8_55"
  fi

  # --- A9 / A10 (paired) — the rule's causes, and the number that must not survive
  # THE PAIRING IS THE DESIGN, the house shape: presence alone is satisfied by leaving the old line budget
  # beside the new word rule, so the engine would state two units at once — which is the exact failure the
  # measurement behind this task found in the cause list. Absence alone is satisfied by deleting the
  # section. Neither half is the criterion on its own.
  SZB55="$(awk '/^## BACKLOG\.md Size Budget/{f=1;next} f && /^#{2,3} /{exit} f' "$BLG55" | tr '\n' ' ' | tr -s ' ')"
  n55() { printf '%s' "$1" | grep -ciE "$2" | tr -d ' '; }
  c9_55=""
  [ -n "$SZB55" ] || c9_55="$c9_55 [the size-budget section did not extract — heading renamed?]"
  [ "$(n55 "$SZB55" '8,?000')" -ge 1 ]  || c9_55="$c9_55 [the section states no soft word threshold]"
  [ "$(n55 "$SZB55" '15,?000')" -ge 1 ] || c9_55="$c9_55 [the section states no firm word threshold]"
  [ "$(n55 "$SZB55" 'three causes')" -ge 1 ] || c9_55="$c9_55 [the cause list is not stated to be three]"
  # The third cause and its refusal of the prune, in one sentence. Two independent searches over the
  # section would pass prose that names the cause and then offers a prune for it anyway, which is the
  # whole reason the cause is being written down: a note pointing at a remedy that does not apply teaches
  # its reader to stop reading it.
  [ "$(insent "$SZB55" 'open|ready' 'essay|row' 'not a prune|no prune|pruning does not|cannot be pruned')" = 1 ] \
    || c9_55="$c9_55 [the third cause is not named with its remedy refused in the same breath]"
  [ -z "$c9_55" ] && ok "A9 the size rule names three causes and the third's remedy is not a prune" \
                  || bad "A9 the size rule names three causes and the third's remedy is not a prune:$c9_55"

  # Counted across the whole engine, because a retired number moved one section over still reads as the
  # budget. Scoped to a LINE budget for this ledger, so the sibling hook's turn thresholds and the diff
  # guardrail's LOC ceilings are not swept up with it.
  g55() { grep -rIloE "$1" "$ROOT/global/" 2>/dev/null | wc -l | tr -d ' '; }
  c10_55=""
  [ "$(g55 '(~|under |budget )300 lines')" -eq 0 ] || c10_55="$c10_55 [a document still states a 300-line budget]"
  [ "$(g55 'lines \(budget')" -eq 0 ]             || c10_55="$c10_55 [the guard still reports the ledger in lines]"
  [ -z "$c10_55" ] && ok "A10 no document states a line budget for the ledger" \
                   || bad "A10 no document states a line budget for the ledger:$c10_55"
fi
