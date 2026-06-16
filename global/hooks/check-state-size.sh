#!/usr/bin/env bash
# ai-flow STATE.md + BACKLOG.md guardian (Stop hook).
# Blocks session stop if:
#   - STATE.md still holds summaries of CLOSED/ARCHIVED tasks
#   - BACKLOG.md exceeds its size budget (~300 lines) or holds >3 session-close changelog entries
# No-op in any project without an .ai-flow/, so it's safe globally.
problems=""

STATE=".ai-flow/STATE.md"
if [ -f "$STATE" ]; then
  n=$(grep -cE 'shipped \+ archived|CLOSED 🎉|shipped \(' "$STATE")
  if [ "$n" -gt 0 ]; then
    problems="STATE.md holds $n closed/archived task summary marker(s). Move each to archive/T-XXX/summary.md (or archive/E-XXX-*.md) and trim STATE.md down to the active task only before finishing."
  fi
fi

BACKLOG=".ai-flow/BACKLOG.md"
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
