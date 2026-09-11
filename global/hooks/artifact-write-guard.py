#!/usr/bin/env python3
"""PreToolUse/Write guard (global): refuses a Write that would REPLACE an existing
.ai-flow/artifacts/<task>/{understand,plan,verify,discoveries}.md. Those four hold decisions taken in
earlier sessions, and a wholesale rewrite destroys them with nothing left to compare against; amending
one is untouched and is what the refusal names. Creating one of the four is allowed — the rail is about
replacement, not creation — and state.md is deliberately outside it: every phase writes that file at
every close, and a rail over the most-written file is the rail that gets routed around.
Needs neither the phase nor the task-resolution ladder: the verdict is a path test and an existence
test, and depends on nothing about which task or phase is live.
Reads the hook JSON on stdin; exit 2 blocks the tool call and feeds the message back to Claude."""
import sys, json, os
from pathlib import Path

# This rail needs neither the phase nor the task-resolution ladder -- its verdict is a path test
# and an existence test. It shares `ledger_root` only, and shares it rather than copying it: the
# boundary rule that stops the climb at the checkout root is one rule, and three copies of it is
# three places a correction has to land.
# No bytecode: a hook is a one-shot process that gains nothing from a cache, and the cache is a
# directory of .pyc files carrying the absolute path they were compiled from -- inside the user's
# ~/.claude/hooks/, and inside anything that packs this repository. Set before the import, which is
# the only import that would write one.
sys.dont_write_bytecode = True

from _aiflow_state import ledger_root

# The four names, and the one deliberately absent from them. A sibling list of the phase commands'
# rather than a copy of it: discoveries.md is no command's, and execute produces no artifact at all.
GUARDED = ('understand.md', 'plan.md', 'verify.md', 'discoveries.md')


def shown_as(path: Path, root: Path) -> str:
    try:
        return str(path.relative_to(root))
    except ValueError:
        return str(path)


def refuse_replacement(path: Path, root: Path) -> None:
    """The refusal names the file and the remedy, and it never opens it: a guard that echoed the
    artifact it saved would have copied a session's decisions into the scrollback and the transcript to
    prove it was protecting them."""
    print(
        f"BLOCKED: '{shown_as(path, root)}' already exists, and a Write replaces it wholesale — the "
        f"decisions an earlier session recorded there would be gone with nothing to compare against. "
        f"Read it, then AMEND it with Edit, which this rail never judges. There is no exemption to "
        f"declare: a replan amends the plan artifact too. If the file is genuinely to be rebuilt, say "
        f"so to the user and let them remove it first.",
        file=sys.stderr,
    )
    sys.exit(2)


def refuse_unread(path: Path, root: Path, why: str) -> None:
    """A rail that can act says what it could not read; it never goes quiet because a path failed to
    answer. This is not permission to write — it is the absence of a verdict, and the write it would
    wave through is the one this rail exists for. Exits 2, the only channel a PreToolUse hook has."""
    print(
        f"BLOCKED: cannot tell whether '{shown_as(path, root)}' already exists ({why}), so whether "
        f"this Write creates an artifact or destroys one is unknown. Fix the permission (chmod u+rwX on "
        f"the directory holding it) and retry, or ask the user.",
        file=sys.stderr,
    )
    sys.exit(2)


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)
    if not isinstance(data, dict):
        sys.exit(0)  # a non-object payload must not traceback a hook that runs on every write

    # Jurisdiction over the TOOL, in the guard's own code and not in the registration alone. The
    # matcher this ships with names Write and nothing else, but the README asks every adopter to merge
    # that JSON by hand into their own settings, and a hand-merge into the neighbouring Edit|Write
    # group is exactly how it widens. Edit is the amendment this refusal advertises as the way out, so a
    # guard that could ever judge one would deny the remedy it names — the same defect the sibling rail
    # paid for by ordering a refusal ahead of its jurisdiction.
    if data.get('tool_name') != 'Write':
        sys.exit(0)

    # The object's fields are payload too, and a field whose type the guard cannot use is a write it
    # cannot judge. Checked where each is read, so nothing unusable is carried forward.
    tool_input = data.get('tool_input')
    file_path = tool_input.get('file_path') if isinstance(tool_input, dict) else None
    if not isinstance(file_path, str) or not file_path:
        sys.exit(0)

    # A payload with no usable directory — absent, null, or empty — falls back to this process's own,
    # which is the session's on every real invocation. A field declared in a type that cannot be a path
    # is the different case: guessing a directory on top of a value the session did name would judge a
    # file nobody was writing.
    declared_cwd = data.get('cwd')
    if declared_cwd is not None and not isinstance(declared_cwd, str):
        sys.exit(0)

    cwd = Path(declared_cwd or '.')
    root = ledger_root(cwd)
    if root is None:
        sys.exit(0)  # not an ai-flow project: the designed silence, so this is safe to install globally

    try:
        # Against the directory the session declares, the same source the ledger root came from — never
        # this process's own, which is nothing the payload describes: a relative path resolved there
        # lands outside the project and the write is waved through, or lands at a sibling of the real
        # one and the block names a file nobody was writing. An absolute path is unaffected, pathlib
        # discarding the base for it.
        target = Path(cwd, file_path).resolve()
        rel = target.relative_to(root.resolve())
    except (ValueError, OSError, RuntimeError):
        # Outside the repo, or a path that cannot be resolved at all — a symlink loop, an unreadable
        # component. Neither is an artifact of this project's, which is what this branch says; a
        # traceback here would take the rail down while spilling over an ordinary write.
        sys.exit(0)

    parts = rel.parts
    if len(parts) < 3 or parts[0] != '.ai-flow' or parts[1] != 'artifacts':
        sys.exit(0)  # every other path, inside the ledger or out of it
    if parts[-1] not in GUARDED:
        sys.exit(0)  # state.md, the conformance manifest, anything else the papers hold

    # The existence test, and the one place this file cannot use pathlib. `Path.exists()` answers False
    # on a PermissionError, so an artifact the guard is not allowed to look at would be reported as
    # absent and its replacement waved through — a rail lifted by the very condition it must refuse on.
    # `os.stat` raises instead, which is what lets the two answers leave by different exits.
    try:
        os.stat(target)
    except FileNotFoundError:
        sys.exit(0)  # creation, not replacement: the rail has no business here
    except NotADirectoryError:
        sys.exit(0)  # a component of the path is a file, so no artifact can exist at it
    except OSError as exc:
        refuse_unread(target, root, exc.strerror or exc.__class__.__name__)
    else:
        refuse_replacement(target, root)


main()
