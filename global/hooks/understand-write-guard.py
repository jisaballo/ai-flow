#!/usr/bin/env python3
"""PreToolUse/Edit|Write guard (global): while the active ai-flow phase is UNDERSTAND,
blocks Edit/Write to repo files outside .ai-flow/ (investigation is read-only for code).
Acts in whichever checkout the session runs in — primary or linked worktree — and reads the
phase from the task that checkout is working: the per-task state sheet naming its current
branch, else the single sheet that names no branch, else the ledger.
Reads the hook JSON on stdin; exit 2 blocks the tool call and feeds the message back to Claude."""
import sys, json, re, subprocess
from pathlib import Path

PHASE_RE = re.compile(r'(?i)^\s*(?:fase actual|current phase|phase)\s*:\s*\*{0,2}\s*([A-Za-z]+)')
BRANCH_RE = re.compile(r'(?i)^\s*branch\s*:\s*(\S+)\s*$')


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


def current_branch(cwd: Path) -> str:
    """The checked-out branch, or '' when there is none to speak of — a detached HEAD answers
    with the literal 'HEAD', which names no branch and must never match a state sheet."""
    name = git(cwd, 'rev-parse', '--abbrev-ref', 'HEAD')
    return '' if name in ('', 'HEAD') else name


def sheet_branch(sheet: Path) -> str:
    """The branch a state sheet declares as its own, or '' when it declares none. A sheet
    without the line is nobody's: absence is never a match for every branch."""
    try:
        for line in sheet.read_text(encoding='utf-8').splitlines():
            found = BRANCH_RE.match(line)
            if found:
                return found.group(1)
    except Exception:
        return ''
    return ''


def declared_phase(source: Path) -> str:
    """The phase a state file declares, or '' when it declares none — read the way the branch above is
    read: the first line that declares it, and no other. The sheet is a prose document, carrying the
    task's decisions and its resume block, so a task that discusses its own phases reproduces the field's
    syntax as a matter of course; scanning the whole text reads that mention and raises the rail over a
    task nobody is understanding. A later line that declares the field is a quoted example, not the
    declaration. The accepted form is written down in the backlog protocol, State Files."""
    try:
        for line in source.read_text(encoding='utf-8').splitlines():
            found = PHASE_RE.match(line)
            if found:
                return found.group(1).upper()
    except Exception:
        return ''
    return ''


def phase_source(root: Path, cwd: Path):
    """Which task is this checkout working? The ladder is written down in the backlog protocol,
    State Files > "Resolving the task", which the phase commands follow too; rungs 1 and 2 are
    implemented here and this file wins if the two ever read differently.

    A working copy can hold several state sheets — the coordinator holds every open task's by
    construction, and a front takes on its next task while the paused one keeps its papers — and the
    one that declares the branch currently checked out is the task actually being worked here. Failing
    that, the older rule still answers: exactly one sheet means "this checkout is working that task",
    and zero or several hand the phase question back to the ledger STATE.md — the coordinator's, and
    the only state a project that has not migrated yet has."""
    per_task = sorted((root / '.ai-flow' / 'artifacts').glob('*/state.md'))
    branch = current_branch(cwd)
    if branch:
        owned = [sheet for sheet in per_task if sheet_branch(sheet) == branch]
        if len(owned) == 1:
            return owned[0]
        # A sheet that names another branch is another workstream's — reading it would judge this
        # checkout by a task it is not working, the very inversion this resolution exists to end.
        # Only a sheet claiming no branch at all can still be ours, for either of two reasons: a
        # project written before the field existed, or a task whose claim was released when this
        # checkout took on another one — `released-branch:`, which the anchored pattern above cannot
        # read as a claim.
        unclaimed = [sheet for sheet in per_task if not sheet_branch(sheet)]
        if len(unclaimed) == 1:
            return unclaimed[0]
    elif len(per_task) == 1:
        return per_task[0]  # no branch to speak of (detached HEAD, no git): the older rule answers
    state = root / '.ai-flow' / 'STATE.md'
    return state if state.exists() else None


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)
    if not isinstance(data, dict):
        sys.exit(0)  # a non-object payload must not traceback a hook that runs on every write

    # The same rule one level in: the object's fields are payload too, and a field whose type the guard
    # cannot use is a write it cannot judge — the answer every other branch here already gives. Checked
    # where each field is read, so nothing unusable is carried forward to be cashed by a later line.
    tool_input = data.get('tool_input')
    file_path = tool_input.get('file_path') if isinstance(tool_input, dict) else None
    if not isinstance(file_path, str) or not file_path:
        sys.exit(0)

    # A payload with no usable directory — the field absent, null, or empty — falls back to this
    # process's own, which is the session's on every real invocation, and is the behaviour that predates
    # this check. A field declared in a type that cannot be a path is the different case: guessing a
    # directory on top of a value the session did name would judge a file nobody was writing.
    declared_cwd = data.get('cwd')
    if declared_cwd is not None and not isinstance(declared_cwd, str):
        sys.exit(0)

    cwd = Path(declared_cwd or '.')
    root = ledger_root(cwd)
    if root is None:
        sys.exit(0)  # not an ai-flow project

    source = phase_source(root, cwd)
    if source is None:
        sys.exit(0)  # no state to read: no rail to enforce

    if declared_phase(source) != 'UNDERSTAND':
        sys.exit(0)  # any phase other than UNDERSTAND, or none declared: no restriction

    try:
        # Against the directory the session declares, the same source the ledger root came from — never
        # this process's own, which is nothing the payload describes: a relative path resolved there
        # lands outside the project and the write is waved through, or lands at a sibling of the real
        # one and the block names a file nobody was writing. An absolute path is unaffected, pathlib
        # discarding the base for it.
        rel = Path(cwd, file_path).resolve().relative_to(root.resolve())
    except (ValueError, OSError, RuntimeError):
        # Outside the repo (scratchpad, memory, ~/.claude): fine — and the same answer for a path that
        # cannot be resolved at all. `resolve()` raises on a symlink loop and on an unreadable
        # component, neither of which `relative_to`'s ValueError covers; joining the session's directory
        # in front of a relative path made the resolved chain longer and more of it comes from outside
        # this guard. Unresolvable means "not a repo file I can judge", which is what this branch says,
        # and a traceback here would take the rail down while spilling on an ordinary write.
        sys.exit(0)

    if rel.parts and rel.parts[0] == '.ai-flow':
        sys.exit(0)  # artifacts, STATE.md, BACKLOG.md: fine

    print(
        f"BLOCKED: the active ai-flow phase is UNDERSTAND (read-only for code), per "
        f"'{source.relative_to(root)}'. Writing '{rel}' is not allowed until the phase moves "
        f"past Understanding. Artifacts under .ai-flow/ are allowed; throwaway repro scripts go "
        f"to the scratchpad directory. If this write is truly needed, run the `plan` command — it "
        f"records the phase when it enters it. If that sheet is not the task you are working, correct "
        f"its `phase:`/`branch:` lines (writes under .ai-flow/ are allowed) — or ask the user.",
        file=sys.stderr,
    )
    sys.exit(2)


main()
