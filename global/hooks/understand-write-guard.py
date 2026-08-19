#!/usr/bin/env python3
"""PreToolUse/Edit|Write guard (global): while the active ai-flow phase is UNDERSTAND,
blocks Edit/Write to repo files outside .ai-flow/ (investigation is read-only for code).
Acts in whichever checkout the session runs in — primary or linked worktree — and reads the
phase from that checkout's own state.
Reads the hook JSON on stdin; exit 2 blocks the tool call and feeds the message back to Claude."""
import sys, json, re, subprocess
from pathlib import Path

PHASE_RE = re.compile(r'(?i)(fase actual|current phase|phase)\s*:?\s*\*{0,2}\s*UNDERSTAND\b')


def git(cwd: Path, *args) -> str:
    try:
        return subprocess.run(
            ['git', '-C', str(cwd), *args], capture_output=True, text=True, timeout=3
        ).stdout.strip()
    except Exception:
        return ''


def ledger_root(cwd: Path):
    """The checkout the session runs in owns the answer. The search climbs from the cwd — so a
    subproject ledger inside a monorepo is still found — but stops at the checkout root: past it
    lies another working copy, and a worktree nested inside its own primary would otherwise bind
    to the primary's ledger and be judged by a task it is not working on. Only a non-git tree,
    which has no boundary to respect, is searched all the way up."""
    top = git(cwd, 'rev-parse', '--show-toplevel')
    boundary = Path(top).resolve() if top else None
    for parent in [cwd, *cwd.parents]:
        if (parent / '.ai-flow').is_dir():
            return parent
        if boundary is not None and parent.resolve() == boundary:
            return None
    return None


def phase_source(root: Path):
    """A worktree carries the state of its own task only; the ledger STATE.md is the
    coordinator's. Exactly one per-task state means "this checkout is working that task";
    zero or several means the phase question belongs to the ledger."""
    per_task = sorted((root / '.ai-flow' / 'artifacts').glob('*/state.md'))
    if len(per_task) == 1:
        return per_task[0]
    state = root / '.ai-flow' / 'STATE.md'
    return state if state.exists() else None


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)
    if not isinstance(data, dict):
        sys.exit(0)  # a non-object payload must not traceback a hook that runs on every write

    file_path = ((data.get('tool_input') or {}).get('file_path') or '')
    if not file_path:
        sys.exit(0)

    root = ledger_root(Path(data.get('cwd') or '.'))
    if root is None:
        sys.exit(0)  # not an ai-flow project

    source = phase_source(root)
    if source is None:
        sys.exit(0)  # no state to read: no rail to enforce

    try:
        if not PHASE_RE.search(source.read_text(encoding='utf-8')):
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
        f"BLOCKED: the active ai-flow phase is UNDERSTAND (read-only for code), per "
        f"'{source.relative_to(root)}'. Writing '{rel}' is not allowed until the phase moves "
        f"past Understanding. Artifacts under .ai-flow/ are allowed; throwaway repro scripts go "
        f"to the scratchpad directory. If this write is truly needed, update the phase in that "
        f"file first (moving to PLAN/EXECUTE) or ask the user.",
        file=sys.stderr,
    )
    sys.exit(2)


main()
