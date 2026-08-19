#!/usr/bin/env python3
"""Stop hook (ai-flow only): nudges once when a change outgrows the Diff Size Guardrail.
Two ceilings, both measured in the checkout the session runs in — primary or linked worktree:
the step (what is not committed yet) and the task (everything this branch added since its base,
commits included, which the step measure cannot see). No-op outside ai-flow projects."""
import sys, json, subprocess, re, os

STEP_THRESHOLD = 150   # one execution step: uncommitted work
TASK_THRESHOLD = 400   # the whole task: the branch's distance from its base

# Test suites don't count as production diff. Conventions across the stacks ai-flow is used on,
# not just JS/TS: a Kotlin *Test.kt counted as production code makes the brake fire on test work.
# The suffix arm needs its left boundary: without it Latest.cs, Greatest.java and Fastest.kt read
# as test files and their production lines vanish from both ceilings.
TEST_RE = re.compile(
    r"""(\.spec\.|\.test\.|/__tests__/|\.e2e\.|\.cy\.
        |(^|/)[Tt]ests?\.(kt|kts|java|swift|cs)$
        |[A-Za-z0-9]Tests?\.(kt|kts|java|swift|cs)$
        |(^|/)test_[^/]*\.py$
        |_test\.(py|go|rb)$
        |(^|/)(test|tests|spec|specs)/)""",
    re.X,
)


def is_test(path: str) -> bool:
    return bool(TEST_RE.search(path))


def is_binary(path: str) -> bool:
    try:
        with open(path, 'rb') as f:
            return b'\x00' in f.read(1024)
    except Exception:
        return True  # unreadable -> don't count it


def git(root, *args) -> str:
    try:
        return subprocess.run(
            ['git', '-C', root, *args], capture_output=True, text=True, timeout=6
        ).stdout
    except Exception:
        return ''


def toplevel() -> str:
    try:
        return subprocess.run(
            ['git', 'rev-parse', '--show-toplevel'], capture_output=True, text=True, timeout=3
        ).stdout.strip()
    except Exception:
        return ''


def base_ref(root: str):
    """Where this branch started: the remote's default branch, else a local main/master.
    None means no base is knowable — the task ceiling then has nothing to measure against."""
    ref = git(root, 'symbolic-ref', 'refs/remotes/origin/HEAD').strip()
    # symbolic-ref answers even when the ref it points at is gone (a dangling origin/HEAD after a
    # renamed default branch): accepting it unverified would leave merge-base empty and the task
    # ceiling permanently, silently absent.
    if ref and git(root, 'rev-parse', '--verify', '--quiet', ref).strip():
        return ref
    for cand in ('main', 'master'):
        if git(root, 'rev-parse', '--verify', '--quiet', cand).strip():
            return cand
    return None


def numstat_total(root: str, rev: str) -> int:
    total = 0
    for line in git(root, 'diff', '--numstat', rev).splitlines():
        parts = line.split('\t')
        if len(parts) < 3:
            continue
        added, deleted, path = parts[0], parts[1], parts[2]
        if added == '-':  # binary
            continue
        if is_test(path):
            continue
        total += int(added) + int(deleted)
    return total


def untracked_total(root: str) -> int:
    """New files are part of both measures: git diff sees neither."""
    total = 0
    for path in git(root, 'ls-files', '--others', '--exclude-standard').splitlines():
        if not path.strip() or is_test(path):
            continue
        full = os.path.join(root, path)
        if is_binary(full):
            continue
        try:
            with open(full, 'r', errors='ignore') as f:
                total += sum(1 for _ in f)
        except Exception:
            pass
    return total


def ack_path(root: str):
    """Lives in the git dir, not in the project tree: never committed, and each linked worktree
    gets its own by construction."""
    gitdir = git(root, 'rev-parse', '--absolute-git-dir').strip()
    return os.path.join(gitdir, 'ai-flow-diff-guard-ack') if gitdir else None


def acknowledged(path) -> int:
    try:
        with open(path) as f:
            return int(f.read().strip())
    except Exception:
        return 0


def main():
    root = toplevel()
    if not root or not os.path.isdir(os.path.join(root, '.ai-flow')):
        sys.exit(0)  # ai-flow projects only
    try:
        data = json.load(sys.stdin)
    except Exception:
        data = {}
    if not isinstance(data, dict):
        data = {}  # a non-object payload must not traceback a hook that runs every turn
    # don't re-fire within the same stop/continue cycle
    if data.get('stop_hook_active'):
        sys.exit(0)

    try:
        new_files = untracked_total(root)
        step_total = numstat_total(root, 'HEAD') + new_files
        base = base_ref(root)
        task_total = None
        if base:
            merge_base = git(root, 'merge-base', base, 'HEAD').strip()
            if merge_base:
                task_total = numstat_total(root, merge_base) + new_files
    except Exception:
        sys.exit(0)

    notices = []
    if step_total > STEP_THRESHOLD:
        notices.append(
            f"step ceiling exceeded — {step_total} uncommitted LOC (excl. tests, limit {STEP_THRESHOLD})"
        )
    # The task total only ever grows — committing raises it and nothing lowers it — so without an
    # acknowledgement the notice would block the end of every turn for the rest of the task. Firing
    # records the total; it speaks again only once the branch has grown another step's worth past it.
    ack_file = ack_path(root) if task_total is not None else None
    task_notice = (
        task_total is not None
        and task_total > TASK_THRESHOLD
        and (ack_file is None or task_total > acknowledged(ack_file) + STEP_THRESHOLD)
    )
    if task_notice:
        notices.append(
            f"task ceiling exceeded — {task_total} LOC on this branch since {base} "
            f"(excl. tests, limit {TASK_THRESHOLD}). Committing does not lower this one: either the "
            f"task is intentionally this big, or it should be split into a follow-up task"
        )

    if notices:
        if task_notice and ack_file:
            try:
                with open(ack_file, 'w') as f:
                    f.write(str(task_total))
            except Exception:
                pass
        print(
            "Diff guardrail: " + "; ".join(notices) + ". "
            "Per your rule, pause and evaluate: is this intentionally large, or should the step be "
            "split / committed?",
            file=sys.stderr,
        )
        sys.exit(2)
    sys.exit(0)


main()
