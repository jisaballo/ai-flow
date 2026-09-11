#!/usr/bin/env python3
"""PreToolUse/Edit|Write guard (global): changing how the context mechanism works, or the shape of a
file that gives a task its context, is a DECLARED act. Two subjects, judged differently: a write naming
the shipped rulebook (protocols/context.md) or the measure (context-check.sh) is structural outright,
there being no content half to either; a write to a context file is structural only where it changes the
file's structural signature -- the ordered list of its '## ' titles and its '## Nano' block. Adding or
correcting a rule inside an existing section passes untouched.

Two keys open the rail, both read from the sheet of the task this checkout is working: the sanctioned
moment (the task inside its archive checklist, which the close marks by writing phase: **ARCHIVE**), or
the declared decision (the line `structure: context`). The refusal names both.

Reads the hook JSON on stdin; exit 2 blocks the tool call and feeds the message back to Claude."""
import sys, json, os, re
from pathlib import Path

# The ladder this rail follows has ONE implementation, and it is not this file: `_aiflow_state` is its
# home in code, as the backlog protocol's State Files is its home in prose. This rail stops at rung 2 --
# STATE.md is a roster and carries neither key, so a checkout falling to it has no declaration to read,
# and refusing there would refuse over a file that could never have opened it.
# No bytecode: a hook is a one-shot process that gains nothing from a cache, and the cache is a
# directory of .pyc files carrying the absolute path they were compiled from -- inside the user's
# ~/.claude/hooks/, and inside anything that packs this repository. Set before the import, which is
# the only import that would write one.
sys.dont_write_bytecode = True

from _aiflow_state import PHASE_RE, ledger_root, resolve_task_sheet

STRUCTURE_RE = re.compile(r'(?i)^\s*structure\s*:\s*context\s*$')

# The measure's own default set, and for the measure's own reason: WHERE THE FILES LIVE. A delivery map
# is not consulted, so a document borrowed from elsewhere is not judged by ceilings its home refuses and
# a steering file nobody declared is judged all the same.
DATA_FILES = ('product.md', 'decisions-global.md')
STEERING_EXCLUDED = ('pencil-design.md',)


def task_sheet(root: Path, cwd: Path):
    """Which task is this checkout working? The ladder lives in `_aiflow_state.resolve_task_sheet`, and
    this rail passes `fall_to_ledger=False`: rung 3 is the roster, which carries neither of this rail's
    two keys.

    Answers the pair that function answers: the sheet to read the keys from, and the sheet that stopped
    the ladder from answering."""
    return resolve_task_sheet(root, cwd, fall_to_ledger=False)


def keys_on(sheet: Path):
    """The two keys, or None when the sheet cannot be read at all -- which is not the same fact as a
    sheet that declares neither, and must not leave by the same exit.

    The phase is read from the FIRST line declaring it and no other: the sheet is a prose document
    carrying the task's decisions, so a task that discusses its own phases reproduces the field's syntax
    as a matter of course, and scanning the whole text would read that mention as the declaration. The
    structure key has no such first-line rule -- it is a flag rather than a position, it is written by
    approval rather than by a phase, and any line declaring it is the declaration."""
    try:
        text = sheet.read_text(encoding='utf-8')
    except Exception:
        return None
    phase, structure = '', False
    for line in text.splitlines():
        if not phase:
            found = PHASE_RE.match(line)
            if found:
                phase = found.group(1).upper()
        if STRUCTURE_RE.match(line):
            structure = True
    return phase == 'ARCHIVE', structure


def signature(text: str):
    """What the measure would call this file's shape: the ordered '## ' titles, and the '## Nano' block's
    own lines. The question is asked the way `scripts/context-check.sh` asks it -- fenced blocks skipped,
    HTML comments stripped, '## ' at line start, the title trimmed, nano bullets joined with their
    continuation lines. Where a question has an authority the guard asks it: a guard that decided for
    itself what counts as a section would refuse writes the measure calls clean, and pass writes it
    calls broken, which is worse than no rail.

    Returns (titles, nano_lines). `nano_lines` is None when the file carries no '## Nano' block, which is
    a different fact from an empty one -- losing the block entirely is the structural change the index
    exists to make visible."""
    titles, nano, in_nano, fence, in_comment = [], None, False, False, False
    for raw in text.splitlines():
        if raw.lstrip().startswith('```'):
            fence = not fence
            continue
        if fence:
            continue
        line, rest = '', raw
        while rest:
            if in_comment:
                i = rest.find('-->')
                if i < 0:
                    rest = ''
                    break
                rest, in_comment = rest[i + 3:], False
            else:
                i = rest.find('<!--')
                if i < 0:
                    line += rest
                    break
                line += rest[:i]
                rest, in_comment = rest[i + 4:], True
        if line.startswith('# '):
            continue
        if line.startswith('## '):
            title = line[3:].strip()
            if title == 'Nano':
                nano, in_nano = [], True
            else:
                in_nano = False
                titles.append(title)
            continue
        if in_nano:
            if re.match(r'^[-*][ \t]', line):
                nano.append(' '.join(line.split()))
            elif nano and re.match(r'^[ \t]+\S', line):
                nano[-1] = nano[-1] + ' ' + ' '.join(line.split())
            continue
    return titles, nano


def describe(before, after) -> str:
    """What changed about the shape, in the words a reader can act on. Never a dump of both signatures:
    the message is read in a terminal, and a diff of two long title lists buries the one line that says
    which rule was broken."""
    bt, bn = before
    at, an = after
    parts = []
    if bt != at:
        gone = [t for t in bt if t not in at]
        new = [t for t in at if t not in bt]
        if gone:
            parts.append('sections removed: ' + ', '.join(repr(t) for t in gone))
        if new:
            parts.append('sections added: ' + ', '.join(repr(t) for t in new))
        if not gone and not new:
            parts.append('the sections are reordered')
    if bn != an:
        if bn is None:
            parts.append("a '## Nano' block is added")
        elif an is None:
            parts.append("the '## Nano' block is removed")
        else:
            parts.append("the '## Nano' block changes")
    return '; '.join(parts) if parts else 'its structure changes'


def refuse(message: str) -> None:
    """Exit 2, the only channel a PreToolUse hook has to reach anyone."""
    print('BLOCKED: ' + message, file=sys.stderr)
    sys.exit(2)


def refuse_unread(shown, what: str) -> None:
    """A rail that can act says which state it could not read; it never goes quiet because something
    failed to open. An unreadable input has not been found clean -- no verdict was reached at all, and
    the two must never leave by the same exit."""
    refuse(
        f"cannot read '{shown}', so whether this write changes {what} is unknown. This is not "
        f"permission to write -- it is the absence of a verdict. Fix the permission (chmod u+r on that "
        f"file) and retry, or correct the sheet this rail should read (writes under .ai-flow/ that touch "
        f"no context file are allowed) -- or ask the user."
    )


KEYS_TEXT = (
    "Two keys open this rail, both read from the task's sheet '{sheet}':\n"
    "  (1) the sanctioned moment -- the task is inside its archive checklist, which the close marks by "
    "writing `phase: **ARCHIVE**` to that sheet immediately before each of the checklist's three "
    "context writes and clearing it immediately after;\n"
    "  (2) the declared decision -- the line `structure: context` on that sheet, written when the plan's "
    "Decision Register entry is approved, or after the operator's go-ahead at Auto.\n"
    "Adding or correcting a rule INSIDE an existing section needs neither key. If this change is wanted, "
    "take it to the operator and get one of the two -- never by editing the sheet to get past this "
    "message."
)


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)
    if not isinstance(data, dict):
        sys.exit(0)  # a non-object payload must not traceback a hook that runs on every write

    # The object's fields are payload too, and a field whose type the guard cannot use is a write it
    # cannot judge. Checked where each field is read, so nothing unusable is carried forward.
    tool_name = data.get('tool_name')
    if tool_name not in ('Edit', 'Write'):
        # Jurisdiction is the guard's own, not the matcher's alone: this JSON is hand-merged into each
        # adopter's settings, and a hand-merge is exactly how a matcher widens.
        sys.exit(0)

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
        sys.exit(0)  # not an ai-flow project

    # --- jurisdiction, settled LEXICALLY and before the path is resolved ---------------------------
    # This is the mirror of the sibling rail's, and the mirror inverts its bug. That rail judges
    # everything OUTSIDE .ai-flow/, so a path it cannot resolve is correctly a pass -- "not a repo file
    # I can judge". This one judges what is INSIDE, so the same code would be a silent hole: a path that
    # cannot be resolved but lexically sits in the judged set is exactly the write that must not slip
    # past. So the set is decided on the normalised path, with no symlink resolution and no filesystem
    # access at all, and an unresolvable member of it is refused further down rather than waved through.
    lex = os.path.normpath(os.path.join(str(cwd), file_path))
    base = os.path.basename(lex)

    # Subject one: the mechanism itself, matched by the shape of its own path rather than by living
    # under any root -- the rulebook ships to ~/.claude/ai-flow/protocols/ and sits at global/protocols/
    # in the engine's own checkout, and neither is inside a project's .ai-flow/.
    is_mechanism = lex.endswith(os.sep + os.path.join('protocols', 'context.md')) \
        or base == 'context-check.sh'

    # Subject two: a context file, which is a checkout's OWN .ai-flow/ and nothing else. A shipped
    # skeleton under template/.ai-flow/ is outside this test by construction -- it is the engine's
    # product, judged by the conformance suite, not one project's context.
    data_dir = os.path.join(str(root), '.ai-flow')
    is_context = False
    if lex.startswith(data_dir + os.sep):
        inner = lex[len(data_dir) + 1:]
        parts = inner.split(os.sep)
        if len(parts) == 1 and inner in DATA_FILES:
            is_context = True
        elif len(parts) == 2 and parts[0] == 'steering' \
                and parts[1].endswith('.md') and parts[1] not in STEERING_EXCLUDED:
            is_context = True

    if not is_mechanism and not is_context:
        sys.exit(0)  # nothing this rail judges, whatever the keys turn out to say

    try:
        shown = os.path.relpath(lex, str(root))
    except ValueError:
        shown = lex

    # --- the task, and only now -------------------------------------------------------------------
    sheet, unread = task_sheet(root, cwd)
    if unread is not None:
        refuse_unread(os.path.relpath(str(unread), str(root)), 'the structure of a context file')
    if sheet is None:
        # No task resolves from this checkout, so there is no declaration to make and nothing to read
        # one from. A deliberate hole, named in the task's papers: an operator between tasks repairs a
        # context file by hand, and refusing instead would make hand-repair need a task opened to
        # declare on. This is a rail against mistakes, not a sandbox.
        sys.exit(0)

    found = keys_on(sheet)
    if found is None:
        refuse_unread(os.path.relpath(str(sheet), str(root)), 'this write is a declared act')
    archiving, declared = found
    if archiving or declared:
        sys.exit(0)

    sheet_shown = os.path.relpath(str(sheet), str(root))

    # --- the verdict ------------------------------------------------------------------------------
    if is_mechanism:
        # No content half to compare. The rulebook states the rule this whole mechanism performs and the
        # measure computes it; a write to either changes how the mechanism works, whatever it changes
        # inside the file.
        refuse(
            f"'{shown}' is the context mechanism itself -- its rulebook or its measure -- and changing "
            f"how the mechanism works is a declared act. There is no content half to these two.\n"
            + KEYS_TEXT.format(sheet=sheet_shown)
        )

    try:
        os.stat(lex)
        exists = True
    except FileNotFoundError:
        exists = False
    except OSError:
        # It is there and cannot be looked at -- a permission fault, or a symlink loop, which is the
        # unresolvable path this rail's jurisdiction was settled lexically in order to catch.
        refuse_unread(shown, "this write changes a context file's structure")

    if not exists:
        if tool_name == 'Write':
            # Creating a context file is the strongest structural act there is, and it costs the
            # ordinary flow nothing: the one moment the engine itself creates one is the archive
            # checklist's first step, already inside key 1's window.
            refuse(
                f"'{shown}' is a context file that does not exist yet, and creating one is a structural "
                f"act -- the strongest there is.\n" + KEYS_TEXT.format(sheet=sheet_shown)
            )
        sys.exit(0)  # an Edit cannot create; the tool will refuse it on its own

    try:
        before_text = Path(lex).read_text(encoding='utf-8')
    except Exception:
        refuse_unread(shown, "this write changes a context file's structure")

    if tool_name == 'Write':
        after_text = tool_input.get('content')
        if not isinstance(after_text, str):
            refuse_unread(shown, "this write changes a context file's structure -- the payload carries "
                                 "no usable `content`, and that")
    else:
        old = tool_input.get('old_string')
        new = tool_input.get('new_string')
        if not isinstance(old, str) or not isinstance(new, str) or old == '':
            # A field the verdict needs, absent or of a type it cannot use. An empty `old_string` is the
            # same case wearing a usable type: there is no occurrence to splice, so no "after" exists to
            # compare, and answering anything about it would be answering about a write nobody made.
            refuse_unread(shown, "this write changes a context file's structure -- the payload carries "
                                 "no usable `old_string`/`new_string`, and that")
        replace_all = tool_input.get('replace_all')
        if replace_all is None:
            replace_all = False
        if not isinstance(replace_all, bool):
            refuse_unread(shown, "this write changes a context file's structure -- `replace_all` is of "
                                 "a type the guard cannot use, and that")
        hits = before_text.count(old)
        if hits == 0 or (hits > 1 and not replace_all):
            sys.exit(0)  # the tool refuses this edit anyway; there is no write here to judge
        after_text = before_text.replace(old, new) if replace_all else before_text.replace(old, new, 1)

    before, after = signature(before_text), signature(after_text)
    if before == after:
        sys.exit(0)  # content, which is what this rail exists to leave alone

    refuse(
        f"'{shown}' is a context file and this write changes its structure "
        f"({describe(before, after)}). A structural change is a declared act.\n"
        + KEYS_TEXT.format(sheet=sheet_shown)
    )


main()
