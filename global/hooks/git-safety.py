#!/usr/bin/env python3
"""PreToolUse/Bash guard (global): reports whether the repository's own protection is in place.

This file used to judge commands. It read the whole command as text, decided from that text whether git
was being invoked and at what, and refused on the strength of that reading. Three audit passes and four
rounds of narrowing established that the reading cannot be made safe: the entire value of any fix is
*lifting* refusals, so every gap in the parser is a lost protection, and the design that inverted it —
letting the parse only lift, never create — lost four protections of its own. Meanwhile the guard refused
documents that merely quoted a forbidden operation, nine measured shapes of them, including the papers of
the task that replaced it and six of its own investigation scripts.

The two `Never` rules now live where the answer is not a matter of reading: git's own pre-push and
pre-commit hooks, which are handed the refs and the index rather than the command. What is left here is
the one question those hooks cannot answer about themselves — *are they actually in place here?* — and it
is a question about a repository, not about a command.

That inverts the direction of the risk, which is why this file can be short where the matcher needed
forty-six conformance rows. The trigger below is a text test and it is allowed to be a crude one: its
gaps cost a **missed reminder**, never a lost protection, because the protection is the git hook and in a
repository without one there is nothing left to lose. A false trigger costs a `git config` call. That is
the corrected form of the rule this repository already carries — where a list is unavoidable, choose the
one whose gaps fall on the harmless side.

Reads the hook JSON on stdin; exit 2 blocks the tool call and feeds the message back to Claude.
"""
import json
import os
import re
import subprocess
import sys

# Where the installer puts the git hooks, and what a repository's hook path must resolve to for the
# protection to be running there.
ENGINE_HOOKS = os.path.expanduser("~/.claude/hooks/git")
HOOK_NAMES = ("pre-push", "pre-commit")

# The repository-scoped acknowledgement. A repository that cannot take the engine's hooks — one whose
# own tooling owns the hook path, which is the ordinary case for a project using a hook manager — turns
# the reminder off by recording that the gap is known. A silent gap and an accepted one look identical
# from outside, and this is what tells them apart.
ACK_KEY = "aiflow.protection"

# Commands that would record or publish something. Crude on purpose (see the module docstring): a shape
# this misses is a reminder that does not fire, in a repository that git's own hooks are not guarding
# either way.
RECORDS_OR_PUBLISHES = re.compile(r"\bgit\b[\s\S]*\b(push|commit)\b|\b(push|commit)\b[\s\S]*\bgit\b")


def git(cwd, *args):
    """Run git in the directory the session declared, or None when it cannot be run there."""
    try:
        out = subprocess.run(
            ("git",) + args, cwd=cwd, capture_output=True, text=True, timeout=3
        )
    except Exception:
        return None
    return out.stdout.strip() if out.returncode == 0 else None


def same_path(a, b):
    try:
        return os.path.realpath(a) == os.path.realpath(b)
    except Exception:
        return False


def protection_state(cwd):
    """One of 'absent-engine', 'displaced', 'missing', 'acknowledged', 'active', or None.

    None means there is nothing to report: the directory is not a repository, or git cannot answer.
    """
    if git(cwd, "rev-parse", "--is-inside-work-tree") != "true":
        return None

    # Read from this repository's own configuration and no wider. Reading every scope let a single
    # global setting silence the reminder on the whole machine while the refusal that offers it says
    # "this repository only" — an accepted gap turning into a silent one, which is the distinction this
    # key exists to make.
    if git(cwd, "config", "--local", "--get", ACK_KEY):
        return "acknowledged"

    # The engine's own copies have to be there AND runnable before anything can be pointed at them. The
    # first version of this line asked only whether they existed, while the branch below asked a
    # repository's own copies whether they could run — the weaker question, asked of the branch the
    # installer always takes. With the two files present at mode 644 the rail called the protection
    # active while git ran neither hook: both rules off, and the guard whose only job is to say so
    # said nothing. The executable bit is exactly what git tests, so it is what this must test.
    if not all(os.access(os.path.join(ENGINE_HOOKS, n), os.X_OK) for n in HOOK_NAMES):
        return "absent-engine"

    configured = git(cwd, "config", "--get", "core.hooksPath")
    if configured:
        # A relative hook path is relative to the top of the working tree, which is what git resolves it
        # against — not to this process's directory, and not to the directory the session declared.
        top = git(cwd, "rev-parse", "--show-toplevel") or cwd
        resolved = configured if os.path.isabs(configured) else os.path.join(top, configured)
        return "active" if same_path(resolved, ENGINE_HOOKS) else "displaced"

    # No hook path configured: git looks in the repository's own hooks directory, which is shared with
    # every linked worktree. Both hooks must be there and be runnable — a hook without its executable
    # bit is skipped by git with a hint and nothing else, which is the quietest way this protection can
    # fail.
    common = git(cwd, "rev-parse", "--git-common-dir")
    if not common:
        return None
    if not os.path.isabs(common):
        common = os.path.join(cwd, common)
    if all(os.access(os.path.join(common, "hooks", n), os.X_OK) for n in HOOK_NAMES):
        return "active"
    return "missing"


def report(state, cwd):
    lines = ["BLOCKED: the trunk and secret protections are not active in this repository."]
    if state == "displaced":
        configured = git(cwd, "config", "--get", "core.hooksPath")
        lines.append(f"  Its own hook path ({configured}) takes precedence over the engine's, so neither")
        lines.append("  git hook runs here. Install them into that path, or accept the gap explicitly:")
    elif state == "absent-engine":
        lines.append(f"  The engine's git hooks are not installed ({ENGINE_HOOKS} has no {HOOK_NAMES[0]}).")
        lines.append("  Run the installer, then set the hook path:")
        lines.append("    ./install.sh update")
    else:
        lines.append("  Point git at the engine's hooks, or accept the gap explicitly:")
    lines.append(f"    git config --global core.hooksPath {ENGINE_HOOKS}")
    lines.append(f"    git config {ACK_KEY} acknowledged   # this repository only, gap accepted")
    return "\n".join(lines)


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)
    if not isinstance(data, dict):
        sys.exit(0)  # a non-object payload must not traceback a hook that runs on every command

    # The same rule one level in: the object's fields are payload too, and a field whose type the guard
    # cannot use is a command it cannot judge. Each field is checked where it is read, so nothing
    # unusable is carried forward to be cashed by a later line. Standing aside is not a weakening: this
    # hook's non-zero exit is a non-blocking error, so a traceback would run the command with no guard at
    # all. Falling over was never the safe direction.
    tool_input = data.get("tool_input")
    cmd = tool_input.get("command") if isinstance(tool_input, dict) else None
    if not isinstance(cmd, str) or not cmd:
        sys.exit(0)
    if not RECORDS_OR_PUBLISHES.search(cmd):
        sys.exit(0)

    # The directory the session declares, never this process's own — and when the session declares none
    # the answer is silence, not a guess. Falling back to "." made this rail judge whatever directory it
    # happened to be standing in and refuse there, which is both halves of what it must not do: a field
    # it cannot use is a command it cannot judge, and the directory it judges is the declared one. The
    # guess was reproduced refusing over a repository the session never named.
    cwd = data.get("cwd")
    if not isinstance(cwd, str) or not os.path.isdir(cwd):
        sys.exit(0)

    state = protection_state(cwd)
    if state in (None, "active", "acknowledged"):
        sys.exit(0)

    print(report(state, cwd), file=sys.stderr)
    sys.exit(2)


main()
