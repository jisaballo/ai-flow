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

# The transcript this note reads its own prior delivery out of, read exactly as check-state-size.sh's own
# payload is: bounded, because a hook waiting on stdin it never receives is a hung session, and the
# `-t 0` gate keeps a hand run from blocking on a terminal that will never speak.
PAYLOAD=""
stop_line=""
if [ ! -t 0 ]; then
  while IFS= read -r -t 2 stop_line || [ -n "$stop_line" ]; do
    PAYLOAD="$PAYLOAD$stop_line"
    stop_line=""
  done
fi
TRANSCRIPT=""
if [ -n "$PAYLOAD" ] && command -v python3 >/dev/null 2>&1; then
  TRANSCRIPT="$(printf '%s' "$PAYLOAD" | python3 -c 'import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    d = {}
v = d.get("transcript_path") if isinstance(d, dict) else None
print(v if isinstance(v, str) else "")' 2>/dev/null || true)"
fi

# Escaping for the path with no parser to serialise with -- the same three characters
# check-state-size.sh's own json_escape guards, for the same reason: `printf` splices this text into a
# JSON string literal, and the accumulator below joins reports with a raw newline.
json_escape() {  # $1 = raw text -> the same text safe inside a JSON string literal
  printf '%s' "$1" \
    | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' \
    | awk 'NR>1 { printf "\\n" } { printf "%s", $0 }'
}

emit_note() {  # $1 = the text both audiences receive
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import json, sys
print(json.dumps({"systemMessage": sys.argv[1],
                  "hookSpecificOutput": {"hookEventName": "UserPromptSubmit",
                                         "additionalContext": sys.argv[1]}}))' "$1"
  else
    esc="$(json_escape "$1")"
    printf '{"systemMessage": "%s", "hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": "%s"}}\n' \
      "$esc" "$esc"
  fi
}

# $1 = the exact mark text. Keyed on the FILE (Decision D5), never on the threshold alone: two different
# oversized files must each be heard once, so a mark shared between them would silence the second file's
# own note the moment the first one had been delivered.
spoken_already() {
  [ -f "$TRANSCRIPT" ] || return 1
  command -v python3 >/dev/null 2>&1 || return 1
  python3 - "$TRANSCRIPT" "$1" 2>/dev/null <<'MARKPY'
import json, os, sys

path, mark = sys.argv[1], sys.argv[2]
DELIVERY = ("hook_system_message", "hook_success", "hook_additional_context")
TAIL_BYTES = 4 * 1024 * 1024
try:
    fh = open(path, errors="replace")
except Exception:
    sys.exit(1)
with fh:
    try:
        size = os.fstat(fh.fileno()).st_size
        if size > TAIL_BYTES:
            fh.seek(size - TAIL_BYTES)
            fh.readline()
    except Exception:
        pass
    for line in fh:
        try:
            rec = json.loads(line)
        except Exception:
            continue
        if not isinstance(rec, dict):
            continue
        att = rec.get("attachment")
        if not isinstance(att, dict) or att.get("type") not in DELIVERY:
            continue
        content = att.get("content")
        if isinstance(content, list):
            content = " ".join(str(x) for x in content)
        if mark in "%s%s" % (content or "", att.get("stdout") or ""):
            sys.exit(0)
sys.exit(1)
MARKPY
}

report=""
add_report() { if [ -n "$report" ]; then report="$report
$1"; else report="$1"; fi; }

# Every context file reachable from this checkout: a task's own brief/state/phase artifacts, an epic's
# own contract, an Icebox body, an archived summary. Globbed by where these classes conventionally live
# rather than enumerated by name, so a task or epic this session has never opened is still measured.
for f in "$AIFLOW"/artifacts/*/*.md "$AIFLOW"/icebox/*.md "$AIFLOW"/archive/*/*.md "$AIFLOW"/archive/*.md; do
  [ -f "$f" ] && [ -r "$f" ] || continue
  words="$(wc -w < "$f" 2>/dev/null | tr -d ' ')"
  case "$words" in ''|*[!0-9]*) continue ;; esac
  [ "$words" -gt 8000 ] || continue
  rel="${f#"$root"/}"
  mark="ai-flow context file size note [$rel]"
  spoken_already "$mark" && continue
  add_report "$mark — $words words (budget 8000), which every session that opens it re-reads. Nothing is blocked by this. See protocols/backlog.md > Size Budget."
done

[ -n "$report" ] && emit_note "$report"
exit 0
