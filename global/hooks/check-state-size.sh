#!/usr/bin/env bash
# ai-flow STATE.md + BACKLOG.md guardian (Stop hook).
# Blocks session stop if:
#   - STATE.md carries narrative of closed work outside its two sanctioned records
#   - BACKLOG.md exceeds its size budget (~300 lines) or holds >3 session-close changelog entries
# No-op in any project without an .ai-flow/, so it's safe globally.

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

problems=""

# Resolve the ledger from the checkout root, not from the cwd: a session sitting in a
# subdirectory would otherwise silently find no ledger and pass.
root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$root" ] || root="."

STATE="$root/.ai-flow/STATE.md"
if [ -f "$STATE" ]; then
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
  policed=$(awk '!/^\|/' "$STATE")
  # Derived from a count, never from a `grep -v` inside an `if`: on BSD grep an empty input exits 0, so
  # that shape reports the same verdict either way.
  n=$(printf '%s\n' "$policed" | grep -cE '(E|T)-[0-9]{3}.*CLOSED|CLOSED.*(E|T)-[0-9]{3}|archive/[A-Za-z0-9]' | tr -d ' ')
  if [ "$n" -gt 0 ]; then
    problems="STATE.md carries $n line(s) of closed-work narrative. Its home is archive/E-XXX-*.md (or archive/T-XXX/summary.md); trim STATE.md down to the roster — one row per open front — before finishing. Neither the roster nor the Quick Tasks Completed table is policed — both stay where they are."
  fi
fi

BACKLOG="$root/.ai-flow/BACKLOG.md"
if [ -f "$BACKLOG" ]; then
  lines=$(wc -l < "$BACKLOG" | tr -d ' ')
  if [ "$lines" -gt 300 ]; then
    problems="$problems
BACKLOG.md is $lines lines (budget ~300). It must contain only pending work — move closed content to archive/ (changelog entries -> archive/CHANGELOG.md, closed epic rows -> archive/EPICS.md, their Execution Order blocks -> archive/EXECUTION-ORDERS.md). See protocols/backlog.md > Size Budget."
  fi
  entries=$(grep -cE '^> 20[0-9]{2}-' "$BACKLOG")
  if [ "$entries" -gt 3 ]; then
    problems="$problems
BACKLOG.md holds $entries session-close changelog entries (max 3). Rotate the oldest into archive/CHANGELOG.md (newest first)."
  fi
fi

if [ -n "$problems" ]; then
  echo "$problems" >&2
  exit 2
fi
exit 0
