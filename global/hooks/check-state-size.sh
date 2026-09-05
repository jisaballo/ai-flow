#!/usr/bin/env bash
# ai-flow STATE.md + BACKLOG.md guardian. Two halves at two events.
#
# At `Stop` it BLOCKS session stop if:
#   - STATE.md carries narrative of closed work outside its two sanctioned records
#   - BACKLOG.md holds >3 session-close changelog entries
# At `UserPromptSubmit` it NOTES, without blocking, when:
#   - BACKLOG.md is over its size budget (8,000 words, firmer at 15,000)
# No-op in any project without an .ai-flow/, so it's safe globally.
#
# Why the note sits at the other event. It asks for the ledger to be swept, and the sweeper is the
# model — so a channel the model cannot read delivers nothing, however faithfully the harness records
# it. Measured live on this harness: a hook's exit-0 output at `Stop` never enters the model's context,
# and neither does a `systemMessage` at any event; only `hookSpecificOutput.additionalContext` does. The
# note therefore carries BOTH fields in one object, so the operator keeps seeing exactly what they saw
# before. The refusals stay at `Stop` because that is the only event where refusing is possible.
#
# It reports at most once per request. Where the payload says the stop is one the harness is
# re-delivering after a refusal, the guard exits quietly rather than turning one refusal into a loop.
#
# The size note is additionally once per session per threshold, and the exception that used to qualify
# that is GONE with the mechanism that produced it: the note no longer rides a blocker's stderr line, so
# there is no longer a delivery that lays no mark. Every delivery of the note is now recorded, which is
# what makes "once per session per threshold" true rather than approximately true.

# The ledger belongs to the coordinator checkout. A linked worktree only ever holds a copy of it,
# so policing that copy would report the coordinator's hygiene where nothing can fix it.
# Both paths must be canonicalised before comparing: from a subdirectory git answers --git-dir
# absolute and --git-common-dir relative ("../.git"), which as raw strings never match — the
# guardian would then declare every subdirectory session a worktree and switch itself off.
canon_dir() { ( cd "$1" 2>/dev/null && pwd -P ); }
gitdir="$(git rev-parse --git-dir 2>/dev/null || true)"
common="$(git rev-parse --git-common-dir 2>/dev/null || true)"
if [ -n "$gitdir" ] && [ -n "$common" ] && [ "$(canon_dir "$gitdir")" != "$(canon_dir "$common")" ]; then
  exit 0
fi

# The Stop payload, read once, before any check runs. Three siblings at this event already read it and
# this guard was the only one that did not — measured: `diff-size-guard.py`, `drift-check.sh` and
# `context-cost-note.py` all resolve `stop_hook_active`, and this file read stdin nowhere while being one
# of the three that refuse. The cost of that gap is not a missed report but a loop: on a refusal the
# harness re-delivers the stop, and a guard that cannot tell a re-delivery from a first delivery refuses
# again, and again, for as long as the condition holds. Reported from the field as the guard firing
# "mid-requirement" — which is what a loop looks like from the outside, since every turn close meets it.
#
# The read is BOUNDED and accumulates line-wise. A Stop hook waiting for input it never receives is a
# hung session, strictly worse than anything this guard is protecting; and a read that waits for a
# delimiter loses on bash 3.2 whatever it had already taken. The `|| [ -n "$stop_line" ]` arm is what
# keeps a payload with no trailing newline, which is the ordinary shape: at EOF the read reports failure
# and still assigns what it took. The `-t 0` gate keeps a hand run — or a conformance row that feeds
# nothing — from waiting on a terminal that will never speak.
STOP_PAYLOAD=""
stop_line=""
if [ ! -t 0 ]; then
  while IFS= read -r -t 2 stop_line || [ -n "$stop_line" ]; do
    STOP_PAYLOAD="$STOP_PAYLOAD$stop_line"
    stop_line=""
  done
fi

# Parsed, never matched as text, and for the reason this repository already states about this very field:
# a guard reading the characters of a mechanism cannot tell the field from the same characters appearing
# inside something else, and a truncated or non-JSON payload carrying them would be read as an
# instruction to go quiet — a false all-clear over a ledger this guard was about to report on. Malformed
# is therefore ABSENT, and absent reports.
#
# Where python3 is missing no suppression happens at all and the guard behaves as it did before this
# existed: the noisy direction, which is the safe one for every report here. A guard that fails loud
# costs a repeated message; one that fails quiet costs the verdict itself.
if [ -n "$STOP_PAYLOAD" ] && command -v python3 >/dev/null 2>&1; then
  printf '%s' "$STOP_PAYLOAD" | python3 -c 'import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    d = {}
sys.exit(0 if isinstance(d, dict) and d.get("stop_hook_active") is True else 1)' && exit 0
fi

# The event this run was invoked at, and the transcript the size note reads its own prior delivery out
# of. Taken in ONE parse because both are values and neither can exit the script — unlike the field
# above, whose whole purpose is to exit, which is why it keeps a parse of its own. One parse rather than
# two is also one interpreter start rather than two, and this hook now runs at every prompt as well as
# at every close.
#
# Absent, unreadable and unparseable all collapse to the empty string for both, and for the transcript
# every one of them makes the note speak: see `spoken_already` below for why that is the only safe
# direction. For the event, an empty answer is not this hook's note event, so the run falls through to
# the refusing half — which is the half that was here before any of this, and the safe fallback for a
# payload nothing could be learned from.
NOTE_EVENT="UserPromptSubmit"
EVENT_NAME=""
TRANSCRIPT=""
if [ -n "$STOP_PAYLOAD" ] && command -v python3 >/dev/null 2>&1; then
  PARSED="$(printf '%s' "$STOP_PAYLOAD" | python3 -c 'import json, sys
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

# Where there is no parser the event is matched as TEXT, and that is a deliberate exception to the rule
# the field above states rather than a lapse from it. The two fields fail in opposite directions. A
# misread `stop_hook_active` goes QUIET — a false all-clear over a ledger this guard was about to report
# on — so it is parsed or it is not read at all. A misread event only sends a report to the wrong half of
# a guard that is registered at BOTH events, so it arrives at the next turn instead of this one. Without
# this arm the note is not late but absent: no parser means no event, no event means the refusing half,
# and the refusing half does not carry the note since the split. Silence for want of a parser is the one
# direction every report here is built not to fail in, and this arm only exists on a machine with none.
if [ -z "$EVENT_NAME" ] && [ -n "$STOP_PAYLOAD" ] && ! command -v python3 >/dev/null 2>&1; then
  case "$STOP_PAYLOAD" in
    *'"hook_event_name"'*"$NOTE_EVENT"*) EVENT_NAME="$NOTE_EVENT" ;;
  esac
fi

# TWO BUCKETS, and the split is the whole of what this guard now decides. A report goes to `blockers`
# when its remedy is bounded and doable in the turn it is raised: trim the narrative, delete one
# changelog line, fix one permission. It goes to `notes` when the remedy is not bounded — which is true
# of exactly one report here, the ledger's size, whose largest cause is open task rows written as essays
# and has no prune at all. Measured on this engine's own ledger the day the split was made: that cause
# was 71% of its words, against a rule which named two causes and neither of them it. A guard that
# refuses the turn over a condition the operator cannot clear in that turn is a guard people learn to
# route around, and it takes the four honest refusals down with it.
#
# The two buckets are now two EVENTS, and the merge that used to join them is gone. It existed because a
# `Stop` hook exiting 2 has its stdout JSON unread, so a note-and-blocker run would have lost the note
# entirely; with a channel of its own the note is never on that run's stream to be lost. Dropping the
# merge also removes the one delivery that laid no mark, and with it the exception the header used to
# have to state. See the exits at the bottom.
blockers=""
notes=""
# Each appends one report to its own bucket, separating with a newline only when something is already
# there. Five sources write to the blocking one (the ledger directory, each ledger file, the roster's
# narrative and the changelog ceiling), and the plain assignment this replaces would have let whichever
# ran last silently discard the others. The blocking helper is named for its bucket rather than for
# "problem", which is what it was called while there was only one: the size note is a report this guard
# makes and is not a problem it refuses over, so the old name would now describe half of what it collects.
add_blocker() { if [ -n "$blockers" ]; then blockers="$blockers
$1"; else blockers="$1"; fi; }
add_note() { if [ -n "$notes" ]; then notes="$notes
$1"; else notes="$1"; fi; }

# Whether this session has already been told about a given threshold. The note's own text is the mark, so
# there is no sentinel file: no path to choose, no session-versus-checkout scope to decide between, and
# nothing left behind to clean up. What makes that possible is that the harness records a delivered
# systemMessage back into the session's own transcript, in two independent records — the
# `hook_system_message` it becomes, and the verbatim `stdout` kept beside the hook's exit status.
# Measured on this project's real transcripts before this was written: 73 of the first and 45,821 of the
# second, and one of them read back verbatim as the sibling note's own JSON.
#
# The mark is read ONLY out of those two records, and that restriction is the whole of what makes it mean
# anything. An unanchored search of the file counts every other way the text can arrive — a user naming
# it, an assistant quoting it, a tool result grepping it — and this engine's own conformance suite holds
# marks verbatim while being the Verify command of every step of every task here. Under a plain text
# search the first session to run the suite would mark both thresholds as spoken and the note would never
# fire again, in the one repository the thresholds were measured on. The sibling reproduced exactly that,
# on a 248-turn session silenced by one line of its own tool output.
#
# EVERY failure returns 1, which means "not yet spoken", which means the note speaks. A missed
# suppression costs a repeated line; a false suppression costs the note entirely, on a session that never
# heard it. Absent transcript, unreadable file, half-flushed last line, no python3 — all of them land on
# the side that talks. The two guards below are that same direction made cheap rather than made safe:
# they change no verdict, they only stop the guard doing expensive work to reach one it already knows.
#
# `-f` and not `-n`, and in the SHELL rather than in the parser: the criterion is that a path naming
# anything but a regular file is answered WITHOUT being opened, and a directory handed to `open()` is
# an exception raised after the interpreter has started. A named pipe is the case that costs more than a
# wasted process — `open()` on one blocks until a writer appears, and a guard that hangs takes the
# session's whole turn with it.
#
# And the read is BOUNDED to the tail. The transcripts this parses are the long ones by construction —
# the note fires on sessions that have been going a while — and every line was parsed from the start of
# the file, on every close, for a mark that is either in the file or is not. The bound is bytes and not
# lines because bytes are what the seek can address without reading what it skips; the partial line the
# seek lands inside is discarded, and the cost of the bound is the honest one: a mark older than the
# tail reads as unspoken and the note is repeated once. That is the direction every other failure here
# already takes.
spoken_already() {  # $1 = threshold
  [ -f "$TRANSCRIPT" ] || return 1
  command -v python3 >/dev/null 2>&1 || return 1
  # stderr silenced for the reason the sibling parse above silences it: this runs BEFORE the note is
  # printed, and on the blocking path stderr is what the operator reads, so a stray byte from here either
  # prefixes the note or lands in the middle of a refusal.
  python3 - "$TRANSCRIPT" "$1" 2>/dev/null <<'MARKPY'
import json, os, sys

path, mark = sys.argv[1], "ai-flow ledger size note [%s]" % sys.argv[2]
# Three records now, not two: the model half of a delivery is written back as `hook_additional_context`,
# and its `content` is a LIST, so it is joined below rather than matched by accidental stringification.
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
        # A transcript is written while it is being read, so its last line can be half-flushed. A hook
        # that raised there would go silent for the rest of the session -- silent on a session that is,
        # by construction, a long one.
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

# Resolve the ledger from the checkout root, not from the cwd: a session sitting in a
# subdirectory would otherwise silently find no ledger and pass.
root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$root" ] || root="."

# The ledger's own directory is proven usable before either file is looked for. A directory that cannot
# be entered makes both files test as *absent*, and absent is this guard's designed no-op for a project
# that has no .ai-flow at all — so without this check the fail-open below simply moves up one level,
# reachable by exactly the same permission fault and reported identically to a clean ledger. `-d` still
# answers on such a directory, so it is not what separates them.
#
# The bit that matters is **search** (`-x`), not read (`-r`), and getting that wrong breaks the check in
# both directions — measured, both:
#   mode 0400 (r, no x): `-r` is true so an `-r` gate says nothing, yet neither `-f` below can stat its
#     file, so both blocks skip and the guard exits 0. The exact fail-open this gate exists to close,
#     surviving one permission bit away from it.
#   mode 0100 (x, no r): the guard reads both files by name perfectly and a real verdict is available,
#     yet an `-r` gate refuses the session close claiming nothing was checked — a false report standing
#     in front of a true one.
# This guard opens two files by name and never lists the directory, so search is the whole of what it
# needs and read is irrelevant to it. A guard that DOES list a directory needs both, and in Python the
# listing raises rather than answering — see the hooks README.
AIFLOW="$root/.ai-flow"
if [ -d "$AIFLOW" ] && [ ! -x "$AIFLOW" ]; then
  add_blocker "Cannot enter $AIFLOW, so neither STATE.md nor BACKLOG.md was checked. This is not a clean verdict — it is the absence of one. Fix the permission (chmod u+rx '$AIFLOW') and finish again."
fi

STATE="$root/.ai-flow/STATE.md"
if [ -f "$STATE" ] && [ ! -r "$STATE" ]; then
  # `-f` is true for a file whose contents cannot be read: stat only needs the parent directory. That is
  # the whole defect this pair closes — the guard concluded "no closed-work narrative" from an extraction
  # that never ran, and on exit 0 the harness discards a Stop hook's stderr, so the diagnostic the tools
  # did print reached nobody. What the hook sells is that somebody looked.
  add_blocker "Cannot read $STATE, so the roster was not checked for closed-work narrative. This is not a clean verdict — it is the absence of one. Fix the permission (chmod u+r '$STATE') and finish again."
elif [ -f "$STATE" ]; then
  # The signal is what a real ledger accumulated, measured: three closed-epic narratives an operator had
  # written into one, all three found, and a legitimate cross-front note beside them left alone. It is NOT
  # what the engine's prose emits — no ceremony writes either signal, `CLOSED` appears in no shipped
  # protocol, and no move owns the notes section at all; claiming otherwise would credit the engine for a
  # shape it never prescribes, which is the false-reason defect this same change removed from the size
  # budget. The three literal markers this replaced ('shipped + archived', a party emoji, 'shipped (')
  # occurred nowhere at all except this hook and the fixtures written to satisfy it, so the only producer
  # of the detected input was the test that tested the detector — and that live roster counted zero.
  #
  # Two signals, either one enough: a narrative that cites its archive file without declaring the
  # closure, and one that declares the closure without citing the file, are both caught. Measured on a
  # live roster of three narratives and one legitimate cross-front note reading "task-complete but not
  # archived": either signal alone found the three and left the note alone, while a bare search for
  # 'archiv' took the note too. CLOSED is matched case-sensitively — it is the form the closing narrative
  # writes, and lower-case 'close' occurs in ordinary prose, including in that very note.
  #
  # What the pair does NOT do is close each other's gap, and saying so was wrong: both alternatives are
  # anchored to one line and keyed on the house typography, so a narrative writing 'closed' in lower case
  # with a prose reference instead of a path escapes both, as does one wrapping between the identifier and
  # the close word. Reproduced, both exit 0. That residual gap is accepted rather than papered over,
  # because it costs a missed report and never a false one — the direction this must fail in — and because
  # nothing prescribes the wording of a narrative the invariant forbids in the first place.
  #
  # The guard reads narrative, and narrative is never a table row. Dropping every table line is what
  # implements both sanctioned sections at once — the roster and the quick-task table — and it is why this
  # form has no region edge to get wrong.
  #
  # Two earlier forms did, and both were reproduced before being replaced. Exempting from the quick-task
  # heading to the next `## ` heading left the exemption running to END OF FILE, because that section is
  # last in both shipped roster shapes: the same narrative that exits 2 inside `## Notes` exited 0
  # appended at the bottom of the file, and 0 again under a `### ` subheading, `^## ` not matching it.
  # The bottom of the file is the most natural append point there is. Exempting only the notes region was
  # the mirror of it, blind to everything after the notes. A region named after where the violation was
  # last seen is a region the next violation sits outside of; the sanctioned *shape* has no such edge.
  # The extraction's status is captured on the very next line, because the extracted text cannot carry
  # the difference: a file that could not be read and a roster that is legitimately nothing but table
  # rows both come back empty, and the status is 2 for the first and 0 for the second. Keying on
  # emptiness would report this fail-open as repaired. It also closes the window where the file stops
  # being readable after the test above passed — nothing between the two lines may touch `$?`.
  policed=$(awk '!/^\|/' "$STATE" 2>/dev/null)
  extraction=$?
  # Derived from a count, never from a `grep -v` inside an `if`. The hazard is NOT BSD grep, which exits
  # 1 on empty input and discriminates correctly: it is the search tool a Claude Code session substitutes
  # into its shell, which exits 0 there. A child script like this one runs the system grep and is safe;
  # a command an agent types is not, which is where the shape has actually cost a verdict.
  n=$(printf '%s\n' "$policed" | grep -cE '(E|T)-[0-9]{3}.*CLOSED|CLOSED.*(E|T)-[0-9]{3}|archive/[A-Za-z0-9]' | tr -d ' ')
  # The count's shape, checked because the gate above covers exactly one cause of failure. grep can fail
  # for others — an invalid byte for the current locale is the reachable one — and its status is spent
  # inside the pipeline above. A non-numeric count then reaches `-gt` and raises `integer expression
  # expected`, which SKIPS the closed-work check rather than answering it: the identical shape documented
  # for the two budget counts below, in the one branch that had no gate.
  case "$n" in ''|*[!0-9]*) n_broken=1 ;; *) n_broken=0 ;; esac
  if [ "$extraction" -ne 0 ]; then
    add_blocker "Could not read $STATE while extracting the lines to police, so the roster was not checked. This is not a clean verdict — it is the absence of one. Fix the permission (chmod u+r '$STATE') and finish again."
  elif [ "$n_broken" -eq 1 ]; then
    add_blocker "Could not count the closed-work lines in $STATE — the search failed and produced no number, so the roster was not checked. This is not a clean verdict — it is the absence of one."
  elif [ "$n" -gt 0 ]; then
    add_blocker "STATE.md carries $n line(s) of closed-work narrative. Its home is archive/E-XXX-*.md (or archive/T-XXX/summary.md); trim STATE.md down to the roster — one row per open front — before finishing. Neither the roster nor the Quick Tasks Completed table is policed — both stay where they are."
  fi
fi

BACKLOG="$root/.ai-flow/BACKLOG.md"
if [ -f "$BACKLOG" ] && [ ! -r "$BACKLOG" ]; then
  # Gated once, ahead of both counts, because neither count can report its own failure: on a failed read
  # `wc -l <` and `grep -cE` each yield the empty string, `[ "" -gt N ]` raises `integer expression
  # expected`, and both checks are then SKIPPED rather than mis-answered — so the guard passed a 400-line
  # backlog. The counts cannot be made to carry it either: `grep -c` answers 1 for a legitimate "found
  # none", which is the passing case, so its status alone cannot separate an error from a clean count.
  add_blocker "Cannot read $BACKLOG, so neither its size budget nor its changelog count was measured. This is not a clean verdict — it is the absence of one. Fix the permission (chmod u+r '$BACKLOG') and finish again."
elif [ -f "$BACKLOG" ]; then
  # WORDS, not lines, and the unit is the defect being repaired rather than a preference. One entry is one
  # line however long it is, so the ledger this budget was written for reached 82 lines — 27% of a 300-line
  # cap — while holding 10,118 words, three times the prose the cap assumed. Lines stopped discriminating
  # the moment an entry became an essay, which the business-first entry format makes it. Words rather than
  # estimated tokens because words are what the engine already budgets prose in (the 25-word index line in
  # the Icebox) and because a word count is a fact the operator can check by hand, where an estimate
  # invites arguing about the estimator instead of about the excess.
  #
  # Two thresholds, and ONLY THE LEVEL REACHED is ever spoken. Written as a search for any unspoken
  # threshold this has a defect that breaks its own premise, and the sibling at this event reproduced it
  # live: a session arriving past the firm threshold without having been told hears the firm note, which
  # says it will not be repeated, and then hears the soft one at the next close because the soft mark was
  # never laid down — two notices in descending firmness, one contradicting the other in writing.
  #
  # The numbers are anchored outside this engine rather than picked. Of six comparable systems surveyed,
  # none guards the size of a shared file and the only one that proposes such a guard proposes it
  # non-blocking; the two thresholds are the ends of the bracket that survey leaves: ~8,000 words is about
  # the 8k tokens BMAD sizes one unit of reading at, and ~15,000 is about the 20k Kiro targets for a heavy
  # operation. The AGENTS.md convention's 32 KiB technical maximum sits between them, and this ledger was
  # already at 61.6 KiB when the budget was set.
  words=$(wc -w < "$BACKLOG" | tr -d ' ')
  crossed=""
  if [ "$words" -gt 15000 ]; then crossed=15000
  elif [ "$words" -gt 8000 ]; then crossed=8000
  fi
  if [ -n "$crossed" ] && ! spoken_already "$crossed"; then
    if [ "$crossed" = 15000 ]; then
      firmer="This is the firm threshold and not the soft one: at this size the ledger costs a session more to carry than it returns, and the parked ledger-split decision has become the action rather than an option. "
    else
      firmer=""
    fi
    # No double quote, no backslash and no newline anywhere in this text. That contract now binds only the
    # python3-absent path at the exit below — where python3 is present the note is serialised by json.dumps
    # and cannot be malformed — but it still binds, because that path has no escaper to reach for. The
    # newline is named beside the other two because `add_note` supplies one itself the moment a second note
    # is added, which is the breach no editor of THIS text would think to look for.
    add_note "ai-flow ledger size note [$crossed] — ${firmer}BACKLOG.md is $words words (budget $crossed), which every session that opens it re-reads. Name the cause before acting, because there are three. Closed content duplicated here moves to archive/ (changelog entries -> archive/CHANGELOG.md, closed epic rows -> archive/EPICS.md, their Execution Order blocks -> archive/EXECUTION-ORDERS.md). A long Icebox is pending work and is swept, promoting or retiring entries. Open task rows written as essays are usually most of it, and pruning does not fix that one — it is the ledger-split decision parked in the candidate section, not a tidy-up. Nothing is blocked by this. See protocols/backlog.md > Size Budget."
  fi
  entries=$(grep -cE '^> 20[0-9]{2}-' "$BACKLOG")
  if [ "$entries" -gt 3 ]; then
    add_blocker "BACKLOG.md holds $entries session-close changelog entries (max 3). Rotate the oldest into archive/CHANGELOG.md (newest first)."
  fi
fi

# The two exits, one per event, and each carries exactly one bucket. At the note's event the guard must
# exit 0 whatever it found — a hook that refuses there stops the operator's prompt from being sent, which
# is not a thing this report's remedy is worth — so the blockers are simply not this run's business and
# are left for the close that follows. At `Stop` the refusals travel on stderr with exit 2, which is the
# only stream a refusing hook is read from, and the note is not there to be lost with it.
if [ "$EVENT_NAME" = "$NOTE_EVENT" ]; then
  if [ -n "$notes" ]; then
  # Serialised by the parser wherever there is one, and hand-built only where there is not. The hand-built
  # form splices prose into a JSON string literal, so its validity rests on a contract no mechanism
  # enforces — and the failure it fails with is silent: a malformed document is not rejected loudly, the
  # note simply reaches nobody, on exactly the sessions the note exists for. The accumulator above is what
  # makes that reachable rather than theoretical: `add_note` joins with a raw newline, which is not legal
  # inside a JSON string, so the first second note ever added would break delivery with no edit here at
  # all. Where python3 is present none of that can happen; where it is absent the printf form is still the
  # only option, and the quote-free contract below is what keeps that path working.
    # ONE object, two audiences, and the same text in both — so the mark `spoken_already` reads back is
    # found whichever record the harness writes for this delivery.
    if command -v python3 >/dev/null 2>&1; then
      python3 -c 'import json, sys
print(json.dumps({"systemMessage": sys.argv[1],
                  "hookSpecificOutput": {"hookEventName": sys.argv[2],
                                         "additionalContext": sys.argv[1]}}))' "$notes" "$NOTE_EVENT"
    else
      printf '{"systemMessage": "%s", "hookSpecificOutput": {"hookEventName": "%s", "additionalContext": "%s"}}\n' \
        "$notes" "$NOTE_EVENT" "$notes"
    fi
  fi
  exit 0
fi

if [ -n "$blockers" ]; then
  echo "$blockers" >&2
  exit 2
fi
exit 0
