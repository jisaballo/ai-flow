#!/usr/bin/env bash
# ai-flow context-file-size note. A task's own papers -- a brief, an epic's own contract, a state sheet,
# a phase artifact, an Icebox body, an archived summary -- are measured against ~8,000 words, in
# WHICHEVER checkout is working them.
#
# Deliberately NOT gated by check-state-size.sh's own coordinator-only worktree exemption. That gate
# exists because BACKLOG.md/STATE.md/archive/EPICS.md live only in the coordinator checkout; a task's own
# artifacts live wherever it is worked, worktree included -- gating this note the same way would silence
# it in exactly the checkout most likely to be carrying the oversized file (Unknown #6). That is the
# whole reason this is a separate file rather than a branch inside check-state-size.sh.
#
# Never blocks: registered at UserPromptSubmit and Stop alike, always exits 0. No-op in any project
# without an .ai-flow/.

set -u

root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$root" ] || root="."
AIFLOW="$root/.ai-flow"
[ -d "$AIFLOW" ] || exit 0

# The shared note-delivery mechanics -- read_payload, json_escape, emit_note, spoken_already -- live in
# one file this guard and check-state-size.sh both source. See _note-lib.sh's own header. Pure parameter
# expansion, never `dirname`: this guard is exercised under a PATH holding nothing but the tools it
# names as its own dependencies, and `dirname` would be an undeclared one.
. "${BASH_SOURCE[0]%/*}/_note-lib.sh"

# The payload this note reads its own prior delivery, and its own confirmed event, out of.
PAYLOAD="$(read_payload)"

# The confirmed event, read the same way check-state-size.sh reads it and gated the same way (its own
# `if [ "$EVENT_NAME" = "$NOTE_EVENT" ]` at the note's own event): `additionalContext` reaches the model
# only when this hook is actually invoked at `UserPromptSubmit` (global/hooks/README.md > "Which channel
# reaches whom") -- registered at `Stop` too only so a straight glob never has to special-case that event,
# never so a Stop-time firing should try to speak to the model. Firing there anyway costs more than a
# missed report: `spoken_already()` below reads its own `systemMessage` back out of the transcript, so a
# Stop-time note would mark itself delivered and then permanently silence the one firing that could
# actually have reached the model. An unparseable or absent event is read the same as check-state-size.sh
# reads it -- NEITHER half -- so this note never fires on a payload it cannot place.
NOTE_EVENT="UserPromptSubmit"
EVENT_NAME=""
TRANSCRIPT=""
if [ -n "$PAYLOAD" ] && command -v python3 >/dev/null 2>&1; then
  PARSED="$(printf '%s' "$PAYLOAD" | python3 -c 'import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    d = {}
if not isinstance(d, dict):
    d = {}
for key in ("hook_event_name", "transcript_path"):
    v = d.get(key)
    print(v if isinstance(v, str) else "")' 2>/dev/null || true)"
  EVENT_NAME="$(printf '%s\n' "$PARSED" | sed -n 1p)"
  TRANSCRIPT="$(printf '%s\n' "$PARSED" | sed -n 2p)"
fi
if [ -z "$EVENT_NAME" ] && [ -n "$PAYLOAD" ] && ! command -v python3 >/dev/null 2>&1; then
  case "$PAYLOAD" in
    *'"hook_event_name"'*"$NOTE_EVENT"*) EVENT_NAME="$NOTE_EVENT" ;;
  esac
fi
[ "$EVENT_NAME" = "$NOTE_EVENT" ] || exit 0

report=""
add_report() { if [ -n "$report" ]; then report="$report
$1"; else report="$1"; fi; }

# Every context file reachable from this checkout: a task's own brief/state/phase artifacts, an epic's
# own contract, an Icebox body, an archived summary. Globbed by where these classes conventionally live
# rather than enumerated by name, so a task or epic this session has never opened is still measured.
# `archive/E-*.md` and never the bare `archive/*.md`: the top level of `archive/` also holds
# `CHANGELOG.md` and `EPICS.md`, the six-index-surfaces mechanism's own subjects (Size Budget / the
# 25-word ceiling) and never this note's -- CHANGELOG.md in particular is a permanent, append-only ledger
# with no rule anywhere asking it to shrink, so sweeping it in here would be a false, unfixable note on
# every future session.
for f in "$AIFLOW"/artifacts/*/*.md "$AIFLOW"/icebox/*.md "$AIFLOW"/archive/*/*.md "$AIFLOW"/archive/E-*.md; do
  [ -f "$f" ] && [ -r "$f" ] || continue
  words="$(wc -w < "$f" 2>/dev/null | tr -d ' ')"
  case "$words" in ''|*[!0-9]*) continue ;; esac
  [ "$words" -gt 8000 ] || continue
  rel="${f#"$root"/}"
  # Keyed on the FILE (Decision D5), never on the threshold alone: two different oversized files must
  # each be heard once, so a mark shared between them would silence the second file's own note the
  # moment the first one had been delivered.
  mark="ai-flow context file size note [$rel]"
  spoken_already "$mark" && continue
  add_report "$mark — $words words (budget 8000), which every session that opens it re-reads. Nothing is blocked by this. See protocols/backlog.md > Size Budget."
done

[ -n "$report" ] && emit_note "$report"
exit 0
