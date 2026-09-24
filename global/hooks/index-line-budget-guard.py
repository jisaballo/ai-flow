#!/usr/bin/env python3
"""PreToolUse/Edit|Write guard (global): an index line this session introduces or changes, on one of
ai-flow's index surfaces (Icebox lines and BACKLOG task/epic rows and changelog copies in BACKLOG.md,
roster rows in STATE.md, closed-epic rows in archive/EPICS.md, Execution Order items in an epic's own
epic.md), is held to the shared 25-word ceiling that protocols/backlog.md states once for all of them. A
new STATE.md section outside the two sanctioned ones (`## Workstreams`, `## Quick Tasks Completed`) is
refused the same way.

Only text that appears inside the tool call's own new content is ever measured -- `new_string` for an
Edit, `content` for a Write -- so a pre-existing over-budget line an edit's replaced span merely passes
through untouched is never this guard's business; debt that already existed is check-state-size.sh's own
report, never a refusal.

Reads the hook JSON on stdin; exit 2 blocks the tool call and feeds the message back to Claude."""
import sys, json, re
from pathlib import Path

# No bytecode: a hook is a one-shot process that gains nothing from a cache, and the cache is a directory
# of .pyc files carrying the absolute path they were compiled from -- inside the user's ~/.claude/hooks/,
# and inside anything that packs this repository. Set before the import, which is the only import that
# would write one.
sys.dont_write_bytecode = True

from _aiflow_state import ledger_root

# The 25-word ceiling every surface shares, stated once in protocols/backlog.md's own prose (Size
# Budget) and cited here rather than shared as code: no constants file exists anywhere in this engine,
# and check-state-size.sh's own 8,000/15,000 thresholds are themselves undeclared inline literals.
CEILING = 25

ICEBOX_RE = re.compile(r'^- IB-\d+\b')
TABLE_ROW_RE = re.compile(r'^\|.*\|\s*$')
CHANGELOG_RE = re.compile(r'^> \d{4}-\d{2}-\d{2}\b')
EXEC_ORDER_RE = re.compile(r'^\d+\.\s')
HEADING_RE = re.compile(r'^(#{2,3})\s+(.*?)\s*$')
SANCTIONED_HEADINGS = ('Workstreams', 'Quick Tasks Completed')


def line_shapes(rel: str):
    """The shapes THIS file's own index lines take, or None when the path is not one of the four the
    guard has jurisdiction over. A line shaped like another surface's own convention -- an Execution
    Order item typed into BACKLOG.md by hand -- is not what that file's rule was written for, so each
    surface is judged only by its own shapes and never by the union of all of them."""
    if rel == '.ai-flow/BACKLOG.md':
        return (ICEBOX_RE, TABLE_ROW_RE, CHANGELOG_RE)
    if rel == '.ai-flow/STATE.md':
        return (TABLE_ROW_RE,)
    if rel == '.ai-flow/archive/EPICS.md':
        return (TABLE_ROW_RE,)
    if rel.startswith('.ai-flow/artifacts/E-') and rel.endswith('/epic.md'):
        return (EXEC_ORDER_RE,)
    return None


def new_text(tool_name: str, tool_input: dict):
    """The text this write is introducing, per Unknown #4's ruling: `content` for a Write, `new_string`
    for an Edit -- and nothing else, since neither the file's prior content nor `old_string` is any part
    of what this session is adding. None when the payload carries nothing usable, which the caller reads
    as "nothing to judge" rather than as a violation."""
    if tool_name == 'Write':
        content = tool_input.get('content')
        return content if isinstance(content, str) else None
    if tool_name == 'Edit':
        new_string = tool_input.get('new_string')
        return new_string if isinstance(new_string, str) else None
    return None


def refuse(message: str) -> None:
    """Exit 2, the only channel a PreToolUse hook has to reach anyone."""
    print('BLOCKED: ' + message, file=sys.stderr)
    sys.exit(2)


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)
    if not isinstance(data, dict):
        sys.exit(0)  # a non-object payload must not traceback a hook that runs on every write

    tool_name = data.get('tool_name')
    if tool_name not in ('Edit', 'Write'):
        sys.exit(0)  # jurisdiction is the guard's own, not the matcher's alone

    tool_input = data.get('tool_input')
    file_path = tool_input.get('file_path') if isinstance(tool_input, dict) else None
    if not isinstance(file_path, str) or not file_path:
        sys.exit(0)

    # A payload with no usable directory -- absent, null, or empty -- falls back to this process's own,
    # which is the session's on every real invocation. A field declared in a type that cannot be a path
    # is the different case: guessing a directory on top of a value the session did name would judge a
    # file nobody was writing.
    declared_cwd = data.get('cwd')
    if declared_cwd is not None and not isinstance(declared_cwd, str):
        sys.exit(0)
    cwd = Path(declared_cwd or '.')

    root = ledger_root(cwd)
    if root is None:
        sys.exit(0)  # not an ai-flow project: no jurisdiction to have

    try:
        rel = Path(cwd, file_path).resolve().relative_to(root.resolve())
    except (ValueError, OSError, RuntimeError):
        sys.exit(0)  # outside this checkout, or unresolvable: not a file this guard can judge

    rel_str = rel.as_posix()
    shapes = line_shapes(rel_str)
    if shapes is None:
        sys.exit(0)  # not one of the watched surfaces, whatever the write contains

    text = new_text(tool_name, tool_input)
    if text is None:
        sys.exit(0)  # the payload carries no usable new text -- nothing here to judge

    # --- the ceiling: every line in the new text shaped like THIS surface's own index line -------------
    for line in text.splitlines():
        if not any(pattern.match(line) for pattern in shapes):
            continue
        words = line.split()
        if len(words) > CEILING:
            refuse(
                f"this line is {len(words)} words, over the {CEILING}-word ceiling for '{rel_str}':\n"
                f"  {line.strip()}\n"
                f"Trim it to {CEILING} words or fewer. Debt that already existed before this session is "
                f"never this guard's business -- check-state-size.sh reports it as a count instead."
            )

    # --- STATE.md's own shape: no heading outside the two sanctioned ones --------------------------------
    if rel_str == '.ai-flow/STATE.md':
        for line in text.splitlines():
            found = HEADING_RE.match(line)
            if found and found.group(2) not in SANCTIONED_HEADINGS:
                refuse(
                    f"'{found.group(1)} {found.group(2)}' is a new STATE.md section. Only "
                    f"'## Workstreams' and '## Quick Tasks Completed' are sanctioned -- give this "
                    f"content its own home (archive/, the task's own state sheet, or decisions-global.md) "
                    f"rather than adding a section here."
                )

    sys.exit(0)


main()
