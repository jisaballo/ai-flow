#!/usr/bin/env python3
"""PreToolUse/Edit|Write guard (global): while the active ai-flow phase is UNDERSTAND,
blocks Edit/Write to repo files outside .ai-flow/ (investigation is read-only for code).
Reads the hook JSON on stdin; exit 2 blocks the tool call and feeds the message back to Claude."""
import sys, json, re
from pathlib import Path

PHASE_RE = re.compile(r'(?i)(fase actual|current phase|phase)\s*:?\s*\*{0,2}\s*UNDERSTAND\b')


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    file_path = ((data.get('tool_input') or {}).get('file_path') or '')
    if not file_path:
        sys.exit(0)

    # Find the enclosing ai-flow repo by walking up from cwd
    cwd = Path(data.get('cwd') or '.')
    state = None
    for parent in [cwd, *cwd.parents]:
        candidate = parent / '.ai-flow' / 'STATE.md'
        if candidate.exists():
            state, root = candidate, parent
            break
    if state is None:
        sys.exit(0)  # not an ai-flow project

    try:
        if not PHASE_RE.search(state.read_text(encoding='utf-8')):
            sys.exit(0)  # any phase other than UNDERSTAND: no restriction
    except Exception:
        sys.exit(0)

    try:
        rel = Path(file_path).resolve().relative_to(root.resolve())
    except ValueError:
        sys.exit(0)  # outside the repo (scratchpad, memory, ~/.claude): fine

    if rel.parts and rel.parts[0] == '.ai-flow':
        sys.exit(0)  # artifacts, STATE.md, BACKLOG.md: fine

    print(
        f"BLOCKED: the active ai-flow phase is UNDERSTAND (read-only for code). "
        f"Writing '{rel}' is not allowed until the phase moves past Understanding. "
        f"Artifacts under .ai-flow/ are allowed; throwaway repro scripts go to the "
        f"scratchpad directory. If this write is truly needed, update the phase in "
        f"STATE.md first (moving to PLAN/EXECUTE) or ask the user.",
        file=sys.stderr,
    )
    sys.exit(2)


main()
