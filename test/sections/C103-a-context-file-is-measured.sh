# C103 — a context file (a task's brief, an epic's contract, a state.md, a phase artifact, an Icebox
# body, an archived summary) is measured against ~8,000 words in whichever checkout is working it,
# worktree included — never gated by check-state-size.sh's own coordinator-only exemption, which is
# exactly the property this note exists to have and that exemption would remove. Generated in the Conform
# phase from understand.md's Verifiable Criteria (T-170), against a hook that does not exist yet:
# global/hooks/context-surface-size-note.sh is Step 3 of T-170's plan, so every row below is bound to its
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
fi
