# ai-flow note-delivery library. Sourced by every hook that reports a non-blocking note to the
# operator and, where the confirmed event allows, to the model: check-state-size.sh and
# context-surface-size-note.sh both need the same four pieces -- reading the hook's own bounded
# payload, escaping free text into a JSON string with no parser to help, building the one object both
# audiences read, and reading a prior delivery back out of the transcript so a note speaks once per
# session per mark. This file is that "one home", named after the same failure _aiflow_state.py's own
# docstring names: two independent copies of this machinery had already drifted before this extraction
# closed the gap.
#
# Never sourced blind: a caller that needs `spoken_already` sets `$TRANSCRIPT` itself, and a caller
# that needs `emit_note` sets `$NOTE_EVENT` itself -- this file declares neither, since the value each
# one holds is the caller's own confirmed fact, not a fact this library could default correctly for
# every source.

# Bounded, because a hook waiting on stdin it never receives is a hung session, strictly worse than
# anything a note is protecting, and a read that waits for a delimiter loses on bash 3.2 whatever it
# had already taken. The `-t 0` gate keeps a hand run -- or a conformance row that feeds nothing -- from
# waiting on a terminal that will never speak. Prints the payload to stdout; the caller captures it.
read_payload() {
  local line=""
  if [ ! -t 0 ]; then
    while IFS= read -r -t 2 line || [ -n "$line" ]; do
      printf '%s' "$line"
      line=""
    done
  fi
}

# $1 = raw text -> the same text safe inside a JSON string literal. `printf` splices this text straight
# into a JSON string literal with nothing else checking it, so the three characters that would break
# one -- backslash, quote, newline -- are escaped by hand.
json_escape() {
  printf '%s' "$1" \
    | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' \
    | awk 'NR>1 { printf "\\n" } { printf "%s", $0 }'
}

# ONE object, two audiences. `systemMessage` is what the operator has always seen; `additionalContext`
# is the only field measured to enter the model's context, and only when `hookEventName` names the
# event this hook was ACTUALLY invoked at -- a value the caller has already confirmed before calling
# this, never guessed here. The SAME text goes in both fields, so the mark `spoken_already` reads back
# is found whichever record the harness writes for this delivery.
# $1 = the text both audiences receive. Reads the caller's own `$NOTE_EVENT`.
emit_note() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import json, sys
print(json.dumps({"systemMessage": sys.argv[1],
                  "hookSpecificOutput": {"hookEventName": sys.argv[2],
                                         "additionalContext": sys.argv[1]}}))' "$1" "$NOTE_EVENT"
  else
    # Hand-built only where there is no parser to serialise with, and escaped because `printf` splices
    # this text straight into two JSON string literals with nothing else checking it.
    esc="$(json_escape "$1")"
    printf '{"systemMessage": "%s", "hookSpecificOutput": {"hookEventName": "%s", "additionalContext": "%s"}}\n' \
      "$esc" "$NOTE_EVENT" "$esc"
  fi
}

# Whether this session has already been told about a given mark. The note's own text IS the mark, so
# there is no sentinel file: no path to choose, no session-versus-checkout scope to decide between, and
# nothing left behind to clean up. What makes that possible is that the harness records a delivered
# message back into the session's own transcript, in three independent records -- the
# `hook_system_message` the operator half becomes, the `hook_additional_context` the model half
# becomes, and the verbatim `stdout` kept beside the hook's exit status.
#
# The mark is read ONLY out of those records, and that restriction is the whole of what makes it mean
# anything. An unanchored search of the file counts every other way the text can arrive -- a user
# naming it, an assistant quoting it, a tool result grepping it -- and this engine's own conformance
# suite holds marks verbatim while being the Verify command of every step of every task here. Under a
# plain text search the first session to run the suite would mark every threshold as spoken and the
# note would never fire again, in the one repository the thresholds were measured on.
#
# EVERY failure returns 1, which means "not yet spoken", which means the note speaks. A missed
# suppression costs a repeated line; a false suppression costs the note entirely, on a session that
# never heard it. Absent transcript, unreadable file, half-flushed last line, no python3 -- all of them
# land on the side that talks.
#
# The read is BOUNDED to the tail. The transcripts this parses are the long ones by construction -- a
# note fires on sessions that have been going a while -- and reading every line from the start, on
# every close, is unbounded work for a mark that is either in the file or is not. The bound is bytes
# and not lines because bytes are what the seek can address without reading what it skips; the partial
# line the seek lands inside is discarded, and the cost of the bound is the honest one: a mark older
# than the tail reads as unspoken and the note is repeated once -- the direction every other failure
# here already takes.
# $1 = the exact mark text to look for. Reads the caller's own `$TRANSCRIPT`.
spoken_already() {
  [ -f "$TRANSCRIPT" ] || return 1
  command -v python3 >/dev/null 2>&1 || return 1
  # stderr silenced for the reason the sibling parse elsewhere silences it: this can run BEFORE a note
  # or a refusal is printed, and on a blocking path stderr is what the operator reads, so a stray byte
  # from here either prefixes the note or lands in the middle of a refusal.
  python3 - "$TRANSCRIPT" "$1" 2>/dev/null <<'MARKPY'
import json, os, sys

path, mark = sys.argv[1], sys.argv[2]
# The model half of a delivery is written back as `hook_additional_context`, and its `content` is a
# LIST, so it is joined below rather than matched by accidental stringification.
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
            fh.readline()  # the seek lands mid-line; that fragment is not a record
    except Exception:
        pass
    for line in fh:
        # A transcript is written while it is being read, so its last line can be half-flushed. A
        # reader that raised there would go silent for the rest of the session -- silent on a session
        # that is, by construction, a long one.
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
