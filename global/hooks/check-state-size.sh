#!/usr/bin/env bash
# ai-flow STATE.md + BACKLOG.md guardian (Stop hook).
# Blocks session stop if:
#   - STATE.md still holds summaries of CLOSED/ARCHIVED tasks
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
  n=$(grep -cE 'shipped \+ archived|CLOSED 🎉|shipped \(' "$STATE")
  if [ "$n" -gt 0 ]; then
    problems="STATE.md holds $n closed/archived task summary marker(s). Move each to archive/T-XXX/summary.md (or archive/E-XXX-*.md) and trim STATE.md down to the active task only before finishing."
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
