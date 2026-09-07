#!/usr/bin/env python3
"""Two halves at two events (ai-flow only): nudges once when a change outgrows the Diff Size Guardrail.

Two ceilings at `Stop`, both measured in the checkout the session runs in — primary or linked worktree:
the step (what is not committed yet) and the task (everything this branch added since its base,
commits included, which the step measure cannot see). They refuse, on stderr, with exit 2.

And one note at `UserPromptSubmit`, which never blocks: a touched file that the change has grown past a
healthy size — the shape ten small diffs build with every ceiling green. It sits at the other event
because it is addressed to the MODEL, which is what must decompose before adding; which channel reaches
the model is a measured fact this file does not own (see `global/hooks/README.md` > `## Which channel reaches whom`, which owns it). The
note carries both halves in one object, so neither audience loses anything.

No-op outside ai-flow projects."""
import sys, json, subprocess, re, os, stat, hashlib

EVENT = 'UserPromptSubmit'  # the note's event; the ceilings keep `Stop`, where a refusal is possible
STOP_EVENT = 'Stop'         # named, because a refusal is issued only on a POSITIVE match against it

STEP_THRESHOLD = 150   # one execution step: uncommitted work
TASK_THRESHOLD = 400   # the whole task: the branch's distance from its base
FILE_THRESHOLD = 1000  # a touched file's size after the change; the project layer may override it
THRESHOLD_KEY = 'large_file_lines'  # top-level key in .ai-flow/project.yml carrying that override

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


RENAME_RE = re.compile(r'\{[^{}]* => ([^{}]*)\}')


def numstat_path(raw: str) -> str:
    """numstat reports a rename as `old => new` or `dir/{old => new}/f`; the note needs the path that
    exists in the working tree, which is the right-hand side. The ceilings never opened the path, so
    they never met this."""
    if '{' in raw:
        return RENAME_RE.sub(r'\1', raw).replace('//', '/')
    if ' => ' in raw:
        return raw.split(' => ', 1)[1]
    return raw


def numstat_files(root: str, rev: str) -> dict:
    """Per non-test, non-binary file: (added, deleted) between rev and the working tree."""
    files = {}
    for line in git(root, 'diff', '--numstat', rev).splitlines():
        parts = line.split('\t')
        if len(parts) < 3:
            continue
        added, deleted, path = parts[0], parts[1], numstat_path(parts[2])
        if added == '-':  # binary
            continue
        if is_test(path):
            continue
        files[path] = (int(added), int(deleted))
    return files


def count_lines(full: str):
    """None where the file is gone, is not a regular file, or cannot be read — a size nobody measured
    is not a size. The regular-file test comes first because opening a FIFO or a device blocks, and a
    Stop hook that blocks holds the turn."""
    try:
        if not stat.S_ISREG(os.lstat(full).st_mode):
            return None
    except Exception:
        return None
    if is_binary(full):
        return None
    try:
        with open(full, 'r', errors='ignore') as f:
            return sum(1 for _ in f)
    except Exception:
        return None


def untracked_files(root: str) -> dict:
    """New files are part of every measure: git diff sees none of them. Every line is an addition."""
    files = {}
    for path in git(root, 'ls-files', '--others', '--exclude-standard').splitlines():
        if not path.strip() or is_test(path):
            continue
        lines = count_lines(os.path.join(root, path))
        if lines is not None:
            files[path] = (lines, 0)
    return files


def total(files: dict) -> int:
    return sum(a + d for a, d in files.values())


def read_threshold(root: str) -> int:
    """The project layer's override, read as a line and not as YAML: a hook that runs at every turn
    close takes on no library it could fail to import. Absent file, absent key, unreadable file —
    all mean the default, silently: a configuration read that fails must not turn a note into anything."""
    try:
        with open(os.path.join(root, '.ai-flow', 'project.yml'), 'r', errors='ignore') as f:
            for line in f:
                m = re.match(r'^' + THRESHOLD_KEY + r':\s*(\d+)\s*(#.*)?$', line)
                if m:
                    return int(m.group(1))
    except Exception:
        pass
    return FILE_THRESHOLD


def large_grown_files(files: dict, root: str, threshold: int, sizes: dict) -> list:
    """(path, lines) for every file the change GREW past the threshold. Growth is the discriminator:
    a task trimming a large file must not be answered with 'decompose before adding'. `sizes` holds
    the counts already taken (the untracked files), so nothing is read twice; a file of at most
    `threshold` bytes cannot hold more than `threshold` lines, so it is not read at all."""
    found = []
    for path, (added, deleted) in sorted(files.items()):
        if added - deleted <= 0:
            continue
        full = os.path.join(root, path)
        lines = sizes.get(path)
        if lines is None:
            try:
                if os.lstat(full).st_size <= threshold:
                    continue
            except Exception:
                continue
            lines = count_lines(full)
        if lines is not None and lines > threshold:
            found.append((path, lines))
    return found


def step_scope(root: str) -> str:
    """What the step measure resets on: the commit the checkout is on.

    `--verify --quiet`, never a bare `rev-parse HEAD`. In a repository with no commit the bare form exits
    128 but PRINTS the literal string `HEAD` on stdout, and `git` above returns stdout while ignoring the
    status — so the bare form hands back `HEAD` as a scope that looks usable and the fallback here is
    never reached. Measured on an empty repository, not assumed."""
    return git(root, 'rev-parse', '--verify', '--quiet', 'HEAD').strip() or 'no-head'


def task_scope(root: str) -> str:
    """What the two task-lived measures reset on: the checkout's set of open task folders.

    A fingerprint of the DIRECTORY NAMES and never of their contents, which is the whole of the design:
    it answers *did the task set change* without ever answering *which task is this*. Resolving the
    latter is one document's rule with one implementation, and hooks share no module — so any other
    route here would have been a second copy of it, drifting against the first with nothing to notice.

    A folder opening or closing re-arms the measures whether or not the change was a close. That is the
    direction that speaks, and speaking is the failure this record can afford."""
    d = os.path.join(root, '.ai-flow', 'artifacts')
    try:
        names = sorted(n for n in os.listdir(d) if os.path.isdir(os.path.join(d, n)))
    except Exception:
        names = []
    return hashlib.sha1('\n'.join(names).encode('utf-8', 'replace')).hexdigest()[:12]


def ack_path(root: str):
    """Lives in the git dir, not in the project tree: never committed, and each linked worktree
    gets its own by construction."""
    gitdir = git(root, 'rev-parse', '--absolute-git-dir').strip()
    return os.path.join(gitdir, 'ai-flow-diff-guard-ack') if gitdir else None


def acknowledged(path) -> dict:
    """{key: count last reported}, one `count<TAB>key` line each. Every key carries the scope its measure
    resets on — `step:<commit>`, `task:<fingerprint>`, `file:<fingerprint>:<path>` — so an entry whose
    scope has passed is read and matches nothing, and `record` drops it. A record written before scopes
    existed partitions to a key no scope can produce and is inert by the same rule: ignored, never
    migrated. Unreadable or absent reads as nothing reported, the direction that speaks; one bad line
    loses that line, never the lines after it."""
    spoken = {}
    try:
        with open(path) as f:
            for line in f:
                count, _, key = line.rstrip('\n').partition('\t')
                try:
                    spoken[key] = int(count)
                except ValueError:
                    continue
    except Exception:
        pass
    return spoken


def outgrown(reported, now: int) -> bool:
    """The one rule both measures speak by: once, then again only after another step's worth."""
    return reported is None or now > reported + STEP_THRESHOLD


def file_note(large: list, threshold: int) -> str:
    named = ', '.join(f"{path} ({lines} lines)" for path, lines in large)
    return (
        f"this change grows an already-large file — {named}, threshold {threshold}; decompose "
        f"before adding. A note, not a ceiling: nothing is blocked"
    )


def main():
    root = toplevel()
    if not root or not os.path.isdir(os.path.join(root, '.ai-flow')):
        sys.exit(0)  # ai-flow projects only
    # The RAW text is kept, because a parse failure and a literal `{}` both leave `data` empty and the two
    # must not be treated alike below: one is a payload that arrived and could not be read, the other is
    # no payload at all.
    try:
        raw = sys.stdin.read()
    except Exception:
        raw = ''
    try:
        data = json.loads(raw)
    except Exception:
        data = {}
    if not isinstance(data, dict):
        data = {}  # a non-object payload must not traceback a hook that runs every turn
    note_half = data.get('hook_event_name') == EVENT
    # A refusal is only ever issued where refusing is POSSIBLE, and that is a positive test rather than a
    # fallback -- the sibling guardian states the same rule at its own exit, for the same reason. This
    # hook is registered at two events and exit 2 does not mean the same thing at both: at `Stop` it costs
    # a turn-close, at the note's event it stops the operator's prompt from being sent. A payload that
    # positively names `Stop` may refuse, and so may NO payload at all -- a hand run, or a harness older
    # than the field, where `Stop` is the only event the ceilings were ever registered at. A payload that
    # ARRIVED and could not be read may not: the ceilings are still there at the next close, and a blocked
    # prompt is not a cost this report's remedy is worth.
    may_refuse = data.get('hook_event_name') == STOP_EVENT or not raw.strip()
    # don't re-fire within the same stop/continue cycle. Only the ceilings can meet a re-delivery:
    # there is no such loop at the note's event, and no payload there carries the field.
    if not note_half and data.get('stop_hook_active'):
        sys.exit(0)
    if not note_half and not may_refuse:
        sys.exit(0)  # an event this hook cannot place is not an occasion to block anything

    try:
        new_files = untracked_files(root)
        step_files = numstat_files(root, 'HEAD')
        step_total = total(step_files) + total(new_files)
        base = base_ref(root)
        task_total = None
        task_files = None
        if base:
            merge_base = git(root, 'merge-base', base, 'HEAD').strip()
            if merge_base:
                task_files = numstat_files(root, merge_base)
                task_total = total(task_files) + total(new_files)
        # The note judges the task diff's files where a base resolves, the step's where none does,
        # and the new files in either case.
        touched = dict(task_files if task_files is not None else step_files)
        touched.update(new_files)
        threshold = read_threshold(root)
        large = large_grown_files(touched, root, threshold, {p: a for p, (a, _) in new_files.items()})
    except Exception:
        sys.exit(0)

    # All three speakers acknowledge, by one rule: once, then again only after another step's worth of
    # growth. Each measure would otherwise block the end of every turn for as long as its subject sits
    # there — the task total only ever grows, a large file stays in the diff for the rest of the task,
    # and an uncommitted step stays uncommitted until it is committed, which is what produced 80 of the
    # 81 firings measured across this engine's own transcripts. The note's first speaking is
    # unconditional: measured against zero it would demand a step's worth of growth as well, and a
    # project with a low threshold would never hear it.
    #
    # And every record is SCOPED to what its measure resets on, because "say it once" and "stop speaking"
    # are the same mechanism read at two lifetimes. A step record kept past its commit disarms the step
    # ceiling for good — the step total returns to 0 at every commit while `outgrown` assumes a measure
    # that only climbs, so the next oversized step is compared against a total it can never beat.
    ack_file = ack_path(root)
    spoken = acknowledged(ack_file) if ack_file else {}
    sscope, tscope = step_scope(root), task_scope(root)
    step_key, task_key = f"step:{sscope}", f"task:{tscope}"
    file_prefix = f"file:{tscope}:"

    def in_scope(key: str) -> bool:
        return key in (step_key, task_key) or key.startswith(file_prefix)

    def record(reported):
        """Mark ONLY what this run actually delivered.

        Load-bearing now that the two halves sit at two events, and it is the failure the sibling
        guardian already shipped once in the other direction: a mark laid for a message that was never
        delivered silences it for the rest of the session, and a delivery that lays none repeats
        forever. The record is shared by both halves, so a run that wrote the ceilings' key while the
        note went out at the other event would silence a note nobody had read."""
        if not reported or not ack_file:
            return
        spoken.update(reported)
        # Only current-scope entries survive the rewrite, which is what makes an expired record expire:
        # a step entry from a previous commit, a task entry from a different set of open tasks, and any
        # line written before scopes existed all fail this test and are gone. Dropping them is not
        # housekeeping — without it the file grows one line per commit for the life of the checkout, and
        # a pre-scope line goes on silencing whatever it silenced when it was written.
        for dead in [k for k in spoken if not in_scope(k)]:
            del spoken[dead]
        try:
            with open(ack_file, 'w') as f:
                f.writelines(f"{n}\t{p}\n" for p, n in sorted(spoken.items()))
        except Exception:
            pass

    if note_half:
        to_note = [(p, n) for p, n in large if outgrown(spoken.get(file_prefix + p), n)]
        if to_note:
            # ONE object, two audiences: `systemMessage` for the person, who sees exactly what they saw
            # before, and `additionalContext` for the model, which is the actor the note asks to act.
            text = "Diff guardrail note: " + file_note(to_note, threshold) + "."
            print(json.dumps({
                "systemMessage": text,
                "hookSpecificOutput": {"hookEventName": EVENT, "additionalContext": text},
            }))
            # Marked AFTER the message is out, never before. `record` exists because a mark laid for a
            # message nobody received silences it for the rest of the session -- and writing the mark first
            # is that same failure with a shorter window: a closed pipe between the two lines leaves the
            # file recorded as spoken and the note never delivered.
            record({file_prefix + p: n for p, n in to_note})
        sys.exit(0)

    notices = []
    step_notice = step_total > STEP_THRESHOLD and outgrown(spoken.get(step_key), step_total)
    if step_notice:
        notices.append(
            f"step ceiling exceeded — {step_total} uncommitted LOC (excl. tests, limit {STEP_THRESHOLD})"
        )
    task_notice = (
        task_total is not None
        and task_total > TASK_THRESHOLD
        and outgrown(spoken.get(task_key), task_total)
    )
    if task_notice:
        notices.append(
            f"task ceiling exceeded — {task_total} LOC on this branch since {base} "
            f"(excl. tests, limit {TASK_THRESHOLD}). Committing does not lower this one: either the "
            f"task is intentionally this big, or it should be split into a follow-up task"
        )

    if notices:
        marks = {}
        if step_notice:
            marks[step_key] = step_total
        if task_notice:
            marks[task_key] = task_total
        record(marks)
        print(
            "Diff guardrail: " + "; ".join(notices) + ". "
            "Per your rule, pause and evaluate: is this intentionally large, or should the step be "
            "split / committed?",
            file=sys.stderr,
        )
        sys.exit(2)
    sys.exit(0)


main()
