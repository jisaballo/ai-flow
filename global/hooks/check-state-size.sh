#!/usr/bin/env bash
# ai-flow STATE.md + BACKLOG.md guardian (Stop hook).
# Blocks session stop if:
#   - STATE.md carries narrative of closed work outside its two sanctioned records
#   - BACKLOG.md exceeds its size budget (~300 lines) or holds >3 session-close changelog entries
# No-op in any project without an .ai-flow/, so it's safe globally.
#
# It reports at most once per request. Where the payload says the stop is one the harness is
# re-delivering after a refusal, the guard exits quietly rather than turning one refusal into a loop.

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

problems=""
# Appends one report, separating with a newline only when something is already there. Five sources can
# now write here (the ledger directory, each ledger file, and each of the two budget checks), and the
# plain assignment this replaces would have let whichever ran last silently discard the others.
add_problem() { if [ -n "$problems" ]; then problems="$problems
$1"; else problems="$1"; fi; }

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
  add_problem "Cannot enter $AIFLOW, so neither STATE.md nor BACKLOG.md was checked. This is not a clean verdict — it is the absence of one. Fix the permission (chmod u+rx '$AIFLOW') and finish again."
fi

STATE="$root/.ai-flow/STATE.md"
if [ -f "$STATE" ] && [ ! -r "$STATE" ]; then
  # `-f` is true for a file whose contents cannot be read: stat only needs the parent directory. That is
  # the whole defect this pair closes — the guard concluded "no closed-work narrative" from an extraction
  # that never ran, and on exit 0 the harness discards a Stop hook's stderr, so the diagnostic the tools
  # did print reached nobody. What the hook sells is that somebody looked.
  add_problem "Cannot read $STATE, so the roster was not checked for closed-work narrative. This is not a clean verdict — it is the absence of one. Fix the permission (chmod u+r '$STATE') and finish again."
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
    add_problem "Could not read $STATE while extracting the lines to police, so the roster was not checked. This is not a clean verdict — it is the absence of one. Fix the permission (chmod u+r '$STATE') and finish again."
  elif [ "$n_broken" -eq 1 ]; then
    add_problem "Could not count the closed-work lines in $STATE — the search failed and produced no number, so the roster was not checked. This is not a clean verdict — it is the absence of one."
  elif [ "$n" -gt 0 ]; then
    add_problem "STATE.md carries $n line(s) of closed-work narrative. Its home is archive/E-XXX-*.md (or archive/T-XXX/summary.md); trim STATE.md down to the roster — one row per open front — before finishing. Neither the roster nor the Quick Tasks Completed table is policed — both stay where they are."
  fi
fi

BACKLOG="$root/.ai-flow/BACKLOG.md"
if [ -f "$BACKLOG" ] && [ ! -r "$BACKLOG" ]; then
  # Gated once, ahead of both counts, because neither count can report its own failure: on a failed read
  # `wc -l <` and `grep -cE` each yield the empty string, `[ "" -gt N ]` raises `integer expression
  # expected`, and both checks are then SKIPPED rather than mis-answered — so the guard passed a 400-line
  # backlog. The counts cannot be made to carry it either: `grep -c` answers 1 for a legitimate "found
  # none", which is the passing case, so its status alone cannot separate an error from a clean count.
  add_problem "Cannot read $BACKLOG, so neither its size budget nor its changelog count was measured. This is not a clean verdict — it is the absence of one. Fix the permission (chmod u+r '$BACKLOG') and finish again."
elif [ -f "$BACKLOG" ]; then
  lines=$(wc -l < "$BACKLOG" | tr -d ' ')
  if [ "$lines" -gt 300 ]; then
    add_problem "BACKLOG.md is $lines lines (budget ~300). It must contain only pending work — move closed content to archive/ (changelog entries -> archive/CHANGELOG.md, closed epic rows -> archive/EPICS.md, their Execution Order blocks -> archive/EXECUTION-ORDERS.md). See protocols/backlog.md > Size Budget."
  fi
  entries=$(grep -cE '^> 20[0-9]{2}-' "$BACKLOG")
  if [ "$entries" -gt 3 ]; then
    add_problem "BACKLOG.md holds $entries session-close changelog entries (max 3). Rotate the oldest into archive/CHANGELOG.md (newest first)."
  fi
fi

if [ -n "$problems" ]; then
  echo "$problems" >&2
  exit 2
fi
exit 0
