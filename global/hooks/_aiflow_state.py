"""Shared state-file reading for the ai-flow PreToolUse rails.

This module is NOT a hook and is never registered as one. It is imported by the rails that must answer
the same question -- which task is this checkout working? -- and it exists because that question had two
implementations and no arbiter. The backlog protocol's `## State Files` > `### Resolving the task` is the
ladder's authority in prose; this file is its authority in code, and the leading underscore says it is
neither invoked nor catalogued in the hooks channel table.

The import works without any path manipulation because Python puts the script's own directory at
sys.path[0], and every rail lands in the same directory the installer copies them to. That is a property
of how the hooks are launched (`python3 $HOME/.claude/hooks/<name>.py`), not an assumption about the
caller's working directory, which is why a rail run from anywhere still finds this file.
"""
import re
import subprocess
from pathlib import Path

# The accepted forms are the backlog protocol's, State Files. Both rails read the FIRST line declaring a
# field and no other: a sheet is a prose document carrying the task's decisions, so a task that discusses
# its own phases reproduces the field's syntax as a matter of course, and scanning the whole text would
# read that mention as the declaration.
PHASE_RE = re.compile(r'(?i)^\s*(?:fase actual|current phase|phase)\s*:\s*\*{0,2}\s*([A-Za-z]+)')
BRANCH_RE = re.compile(r'(?i)^\s*branch\s*:\s*(\S+)\s*$')

# Index-surface line shapes, and STATE.md's own sanctioned headings: read by BOTH
# index-line-budget-guard.py (new/changed lines this session writes) and check-state-size.sh (every line,
# via a python3 -c call that imports this module), so which shape counts as a surface's own index line --
# and which STATE.md heading is sanctioned -- is stated exactly once. Born duplicated across a Python
# regex and a hand-translated awk pattern in the same diff that introduced both consumers, and already
# drifted before either consumer next changed: the awk `ICEBOX_RE` equivalent matched a literal trailing
# space (`^- IB-[0-9]+ `) where the Python one matched a word boundary (`^- IB-\d+\b`), so a line like
# `- IB-042,` was judged differently by the two. This module is what that table's single definition
# looks like; a hand-translated second copy is not written again beside either consumer.
ICEBOX_RE = re.compile(r'^- IB-\d+\b')
TABLE_ROW_RE = re.compile(r'^\|.*\|\s*$')
CHANGELOG_RE = re.compile(r'^> \d{4}-\d{2}-\d{2}\b')
EXEC_ORDER_RE = re.compile(r'^\d+\.\s')
HEADING_RE = re.compile(r'^(#{2,3})\s+(.*?)\s*$')

# Which shapes count as THIS surface's own index line, keyed by the surface name both consumers share. A
# line shaped like another surface's own convention -- an Execution Order item typed into BACKLOG.md by
# hand -- is not what that surface's rule was written for, so each surface is judged only by its own
# shapes and never by the union of all of them.
SURFACE_SHAPES = {
    'backlog': (ICEBOX_RE, TABLE_ROW_RE, CHANGELOG_RE),
    'table': (TABLE_ROW_RE,),
    'exec': (EXEC_ORDER_RE,),
}

SANCTIONED_HEADINGS = ('Workstreams', 'Quick Tasks Completed')


def git(cwd: Path, *args) -> str:
    try:
        return subprocess.run(
            ['git', '-C', str(cwd), *args], capture_output=True, text=True, timeout=3
        ).stdout.strip()
    except Exception:
        return ''


def ledger_root(cwd: Path):
    """The checkout the session runs in owns the answer. The search climbs from the cwd -- so a
    subproject ledger inside a monorepo is still found -- but stops at the checkout root: past it lies
    another working copy, and a worktree nested inside its own primary would otherwise bind to the
    primary's ledger and be judged by a task it is not working on. Only a non-git tree, which has no
    boundary to respect, is searched all the way up."""
    top = git(cwd, 'rev-parse', '--show-toplevel')
    boundary = Path(top).resolve() if top else None
    for parent in [cwd, *cwd.parents]:
        if (parent / '.ai-flow').is_dir():
            return parent
        if boundary is not None and parent.resolve() == boundary:
            return None
    return None


def current_branch(cwd: Path) -> str:
    """The checked-out branch, or '' when there is none to speak of -- a detached HEAD answers with the
    literal 'HEAD', which names no branch and must never match a state sheet."""
    name = git(cwd, 'rev-parse', '--abbrev-ref', 'HEAD')
    return '' if name in ('', 'HEAD') else name


def sheet_branch(sheet: Path):
    """The branch a state sheet declares as its own, '' when it declares none, and None when the sheet
    cannot be read at all. A sheet without the line is nobody's: absence is never a match for every
    branch. Unreadable is a third answer, not a second name for the second one -- a sheet whose text is
    unavailable can neither be claimed as this checkout's nor excluded as another workstream's, and
    collapsing it into '' silently changes WHICH task the ladder resolves. Only the read is guarded, so a
    genuine parse miss still answers ''."""
    try:
        text = sheet.read_text(encoding='utf-8')
    except Exception:
        return None
    for line in text.splitlines():
        found = BRANCH_RE.match(line)
        if found:
            return found.group(1)
    return ''


def resolve_task_sheet(root: Path, cwd: Path, fall_to_ledger: bool):
    """Which task is this checkout working? Rungs 1 and 2 of the protocol's ladder, with rung 3 --
    STATE.md -- taken or left by the caller.

    A working copy can hold several state sheets: the coordinator holds every open task's by
    construction, and a front takes on its next task while the paused one keeps its papers. The sheet
    declaring the branch currently checked out is the task actually being worked here. Failing that, the
    older rule still answers: exactly one sheet declaring NO branch is still this checkout's own task.

    `fall_to_ledger` is the single real difference between this module's two callers, and it is an
    argument rather than two copies of the ladder because that is what it always was. The phase rail
    passes True: STATE.md carries a phase, and it is the only state a project that has not migrated yet
    has. The structure rail passes False: STATE.md is a roster and carries neither of that rail's two
    keys, so a checkout falling to it has no declaration to read, and a rail refusing there would refuse
    over a file that could never have opened it.

    Answers a pair: the file to read from, and the sheet that stopped the ladder from answering. The
    second is set only where reading that sheet could have changed the outcome -- a readable claim on the
    current branch settles it, and an unreadable sibling cannot outrank a claim the ladder already found.
    Refusing on any unreadable sheet anywhere under artifacts/ would let one stale sheet block every
    write, which is a worse rail than the one being repaired."""
    aiflow = root / '.ai-flow'
    artifacts = aiflow / 'artifacts'
    try:
        # `iterdir`, not `glob`. The directory list is taken by a call that RAISES on a directory it
        # cannot read; `Path.glob` swallows that fault inside its own walk and answers with an empty
        # match, so the `except OSError` written around it was unreachable and an unlistable ledger read
        # as a checkout with no task -- which is a passing exit. The rail failed OPEN on exactly the
        # state it was meant to refuse over, and the handler that looked like the remedy was what hid it.
        # The raise is still the authority rather than an access check in front of it: a readability test
        # is a guess about what the next call will do.
        per_task = sorted(p / 'state.md' for p in artifacts.iterdir() if (p / 'state.md').is_file())
    except FileNotFoundError:
        per_task = []  # no artifacts/ at all is a project with no task open, not a fault
    except OSError:
        return None, artifacts
    branch = current_branch(cwd)
    if branch:
        owned = [sheet for sheet in per_task if sheet_branch(sheet) == branch]
        if len(owned) == 1:
            return owned[0], None
        # Consulted only where NO readable sheet claims the branch: an unreadable sibling cannot change
        # an answer a readable claim already settled. Two readable claimants is a different stall -- one
        # this rung must not answer for, or the refusal would name a sheet that is not the reason the
        # ladder stopped -- so it keeps falling through.
        unreadable = [] if owned else [sheet for sheet in per_task if sheet_branch(sheet) is None]
        if unreadable:
            # No sheet claims this branch and one could not be read: it may be the claimant, so the task
            # is not resolved. Rung 4 -- stop and name what was looked for -- and for a rail that can
            # act, stopping is a refusal, not the silence a passing exit gives.
            return None, unreadable[0]
        # A sheet naming another branch is another workstream's; reading it would judge this checkout
        # by a task it is not working, the inversion this resolution exists to end.
        # Only a sheet claiming no branch at all can still be ours, and for either of TWO reasons: a
        # project written before the field existed, or a task whose claim was released when this
        # checkout took on another one -- `released-branch:`, which the anchored pattern above cannot
        # read as a claim.
        # `== ''` is explicit: None is falsy too, so `not sheet_branch(...)` would sweep an unreadable
        # sheet into the rung that must only ever answer for a sheet declaring no branch.
        unclaimed = [sheet for sheet in per_task if sheet_branch(sheet) == '']
        if len(unclaimed) == 1:
            return unclaimed[0], None
    elif len(per_task) == 1:
        # No branch to speak of (detached HEAD, no git): the lone sheet answers whatever it declares --
        # unless it cannot be read, which is the same stop as above.
        if sheet_branch(per_task[0]) is None:
            return None, per_task[0]
        return per_task[0], None
    if not fall_to_ledger:
        return None, None
    state = aiflow / 'STATE.md'
    return (state, None) if state.exists() else (None, None)
