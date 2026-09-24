# C103 — a context file (a task's brief, an epic's contract, a state.md, a phase artifact, an Icebox
# body, an archived summary) is measured against ~8,000 words in whichever checkout is working it,
# worktree included — never gated by check-state-size.sh's own coordinator-only exemption, which is
# exactly the property this note exists to have and that exemption would remove. Generated in the Conform
# phase from understand.md's Verifiable Criteria, against a hook that does not exist yet:
# global/hooks/context-surface-size-note.sh is the plan's own third step, so every row below is bound to its
# absence today — `bash: .../context-surface-size-note.sh: No such file or directory` matches none of the
# content substrings asserted below, so the red is for the right reason and not a coincidence of exit code.
echo "== C103: a context file over ~8,000 words is noted, in any checkout =="
GRD103="$HK/context-surface-size-note.sh"
UPS103='{"hook_event_name":"UserPromptSubmit"}'

run103() { ( cd "$1" && printf '%s' "$2" | bash "$GRD103" 2>"$T103/err" ); }
UNDERSTAND103=".ai-flow/artifacts/T-100/understand.md"

T103=""
if ! T103="$(mkbox)" || [ ! -d "$T103" ]; then
  bad "A1 a context file over ~8,000 words is noted, naming the count and the file (no sandbox: mktemp -d failed)"
  bad "A2 the same file trimmed to ~8,000 words stays silent (no sandbox: mktemp -d failed)"
  bad "A3 the note fires from a linked worktree, not only the coordinator checkout (no sandbox: mktemp -d failed)"
  bad "A4 the note speaks once per file and is not repeated once this session has heard it (no sandbox: mktemp -d failed)"
elif [ ! -r "$GRD103" ] || [ ! -s "$GRD103" ]; then
  bad "A1 a context file over ~8,000 words is noted, naming the count and the file (the guard is unreadable)"
  bad "A2 the same file trimmed to ~8,000 words stays silent (the guard is unreadable)"
  bad "A3 the note fires from a linked worktree, not only the coordinator checkout (the guard is unreadable)"
  bad "A4 the note speaks once per file and is not repeated once this session has heard it (the guard is unreadable)"
  rm -rf "$T103"
else
  P103="$T103/proj"; mkproj "$P103" main
  mkdir -p "$P103/.ai-flow/artifacts/T-100"

  # --- A1/A2: the boundary, on the coordinator checkout itself -----------------------------------------
  nwords 8001 > "$P103/.ai-flow/artifacts/T-100/understand.md"
  o103="$(run103 "$P103" "$UPS103")"; rc103=$?
  c1_103=""
  [ "$rc103" = 0 ] || c1_103="$c1_103 [an oversized context file did not let the turn close (exit $rc103)]"
  case "$o103" in *systemMessage*) : ;; *) c1_103="$c1_103 [no systemMessage on stdout, so the note reaches nobody]" ;; esac
  case "$o103" in *"8001 words"*) : ;; *) c1_103="$c1_103 [the note does not state the measured word count]" ;; esac
  case "$o103" in *"8000"*) : ;; *) c1_103="$c1_103 [the note does not state its ~8,000-word threshold]" ;; esac
  case "$o103" in *"$UNDERSTAND103"*) : ;; *) c1_103="$c1_103 [the note does not name which file crossed the threshold]" ;; esac
  [ -z "$c1_103" ] && ok "A1 a context file over ~8,000 words is noted, naming the count and the file" \
                    || bad "A1 a context file over ~8,000 words is noted, naming the count and the file:$c1_103"

  nwords 8000 > "$P103/.ai-flow/artifacts/T-100/understand.md"
  o103="$(run103 "$P103" "$UPS103")"; rc103=$?
  c2_103=""
  [ "$rc103" = 0 ] || c2_103="$c2_103 [a file at exactly ~8,000 words did not let the turn close (exit $rc103)]"
  case "$o103" in *systemMessage*) c2_103="$c2_103 [8,000 words spoke, so the boundary fires one word early]" ;; esac
  [ -z "$c2_103" ] && ok "A2 the same file trimmed to ~8,000 words stays silent" \
                    || bad "A2 the same file trimmed to ~8,000 words stays silent:$c2_103"

  # --- A3: unscoped by checkout -- the whole reason this is a separate file from check-state-size.sh ----
  W103="$T103/wt"
  $GIT -C "$P103" worktree add -q -b wt103 "$W103" >/dev/null 2>&1
  c3_103=""
  if [ ! -d "$W103" ]; then
    c3_103="$c3_103 [could not create the linked worktree fixture]"
  else
    mkdir -p "$W103/.ai-flow/artifacts/T-100"
    nwords 8001 > "$W103/.ai-flow/artifacts/T-100/understand.md"
    o103="$(run103 "$W103" "$UPS103")"; rc103=$?
    [ "$rc103" = 0 ] || c3_103="$c3_103 [a linked worktree's oversized file did not let the turn close (exit $rc103)]"
    case "$o103" in *"8001 words"*) : ;; *) c3_103="$c3_103 [the note did not fire from the linked worktree — this note must not be coordinator-only]" ;; esac
  fi
  [ -z "$c3_103" ] && ok "A3 the note fires from a linked worktree, not only the coordinator checkout" \
                    || bad "A3 the note fires from a linked worktree, not only the coordinator checkout:$c3_103"

  # --- A4: once per file, both directions driven so an always-silent guard cannot satisfy this row ------
  TR103="$T103/spoken.jsonl"
  # The mark is keyed on the FILE, per Decision D5, never on the threshold alone: two different
  # oversized files must each be heard once, so sharing one "[8000]" mark between them (the ledger-size
  # note's own convention, which has only one subject) would silence the second file's own note.
  printf '%s\n' "{\"attachment\":{\"type\":\"hook_system_message\",\"content\":\"ai-flow context file size note [$UNDERSTAND103] — is 8001 words (budget 8000)\"}}" > "$TR103"
  nwords 8001 > "$P103/.ai-flow/artifacts/T-100/understand.md"
  c4_103=""
  o103="$(run103 "$P103" "$UPS103")"
  case "$o103" in *"8001 words"*) : ;; *) c4_103="$c4_103 [with no prior transcript the note did not speak at all]" ;; esac
  o103="$(run103 "$P103" "{\"hook_event_name\":\"UserPromptSubmit\",\"transcript_path\":\"$TR103\"}")"
  case "$o103" in *"8001 words"*) c4_103="$c4_103 [the note was spoken twice for the same file in one session]" ;; esac
  [ -z "$c4_103" ] && ok "A4 the note speaks once per file and is not repeated once this session has heard it" \
                    || bad "A4 the note speaks once per file and is not repeated once this session has heard it:$c4_103"

  # --- A5: CHANGELOG.md and EPICS.md are NOT context-file subjects — they are the six-index-surfaces
  # mechanism's own, a permanent append-only ledger this note must never flag -------------------------
  mkdir -p "$P103/.ai-flow/archive"
  nwords 8001 > "$P103/.ai-flow/archive/CHANGELOG.md"
  nwords 8001 > "$P103/.ai-flow/archive/EPICS.md"
  o103="$(run103 "$P103" "$UPS103")"
  c5_103=""
  case "$o103" in *"archive/CHANGELOG.md"*) c5_103="$c5_103 [the note mentions archive/CHANGELOG.md, a ledger file out of scope]" ;; esac
  case "$o103" in *"archive/EPICS.md"*) c5_103="$c5_103 [the note mentions archive/EPICS.md, a ledger file out of scope]" ;; esac
  [ -z "$c5_103" ] && ok "A5 archive/CHANGELOG.md and archive/EPICS.md are never treated as context-file subjects" \
                    || bad "A5 archive/CHANGELOG.md and archive/EPICS.md are never treated as context-file subjects:$c5_103"
  rm -f "$P103/.ai-flow/archive/CHANGELOG.md" "$P103/.ai-flow/archive/EPICS.md"

  # --- A6: an Icebox body over budget is noted — the icebox/*.md glob ----------------------------------
  mkdir -p "$P103/.ai-flow/icebox"
  nwords 8001 > "$P103/.ai-flow/icebox/IB-042.md"
  o103="$(run103 "$P103" "$UPS103")"
  c6_103=""
  case "$o103" in *"icebox/IB-042.md"*) : ;; *) c6_103="$c6_103 [an oversized Icebox body was not noted]" ;; esac
  [ -z "$c6_103" ] && ok "A6 an oversized Icebox body is noted (icebox/*.md)" \
                    || bad "A6 an oversized Icebox body is noted (icebox/*.md):$c6_103"
  rm -f "$P103/.ai-flow/icebox/IB-042.md"

  # --- A7: an archived task summary over budget is noted — the archive/*/*.md glob ---------------------
  mkdir -p "$P103/.ai-flow/archive/T-050"
  nwords 8001 > "$P103/.ai-flow/archive/T-050/summary.md"
  o103="$(run103 "$P103" "$UPS103")"
  c7_103=""
  case "$o103" in *"archive/T-050/summary.md"*) : ;; *) c7_103="$c7_103 [an oversized archived task summary was not noted]" ;; esac
  [ -z "$c7_103" ] && ok "A7 an oversized archived task summary is noted (archive/*/*.md)" \
                    || bad "A7 an oversized archived task summary is noted (archive/*/*.md):$c7_103"
  rm -rf "$P103/.ai-flow/archive/T-050"

  # --- A8: an archived epic summary over budget is still noted — archive/E-*.md is A5's positive control
  nwords 8001 > "$P103/.ai-flow/archive/E-050-a-slug.md"
  o103="$(run103 "$P103" "$UPS103")"
  c8_103=""
  case "$o103" in *"archive/E-050-a-slug.md"*) : ;; *) c8_103="$c8_103 [an oversized archived epic summary was not noted]" ;; esac
  [ -z "$c8_103" ] && ok "A8 an oversized archived epic summary is noted (archive/E-*.md)" \
                    || bad "A8 an oversized archived epic summary is noted (archive/E-*.md):$c8_103"
  rm -f "$P103/.ai-flow/archive/E-050-a-slug.md"

  # --- A9: a Stop-time firing never speaks (additionalContext does not reach the model at Stop) AND never
  # marks itself delivered — the mark left by a Stop firing would otherwise permanently silence the one
  # firing that could actually reach the model, the next real UserPromptSubmit ------------------------
  P103B="$T103/proj-stop"; mkproj "$P103B" main
  mkdir -p "$P103B/.ai-flow/artifacts/T-100"
  nwords 8001 > "$P103B/.ai-flow/artifacts/T-100/understand.md"
  o103="$(run103 "$P103B" '{"hook_event_name":"Stop"}')"
  c9_103=""
  case "$o103" in *systemMessage*) c9_103="$c9_103 [a Stop-event firing spoke at all — additionalContext never reaches the model at Stop]" ;; esac
  o103="$(run103 "$P103B" "$UPS103")"
  case "$o103" in *"8001 words"*) : ;; *) c9_103="$c9_103 [the following real UserPromptSubmit stayed silent — a Stop firing left a false already-spoken mark]" ;; esac
  [ -z "$c9_103" ] && ok "A9 a Stop-event firing never speaks and never permanently silences the note" \
                    || bad "A9 a Stop-event firing never speaks and never permanently silences the note:$c9_103"
fi
