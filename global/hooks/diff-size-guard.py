#!/usr/bin/env python3
"""Stop hook (ai-flow only): nudges once when the uncommitted working-tree diff exceeds 150 LOC (excluding tests).
Enforces the ai-flow Diff Size Guardrail. No-op outside ai-flow projects."""
import sys, json, subprocess, re, os

THRESHOLD = 150


def is_test(path: str) -> bool:
    return bool(re.search(r'(\.spec\.|\.test\.|/__tests__/|\.e2e\.|\.cy\.)', path))


def is_binary(path: str) -> bool:
    try:
        with open(path, 'rb') as f:
            return b'\x00' in f.read(1024)
    except Exception:
        return True  # unreadable -> don't count it


def main():
    # ai-flow projects only
    if not os.path.isfile('.ai-flow/STATE.md'):
        sys.exit(0)
    try:
        data = json.load(sys.stdin)
    except Exception:
        data = {}
    # don't re-fire within the same stop/continue cycle
    if data.get('stop_hook_active'):
        sys.exit(0)

    total = 0
    try:
        ns = subprocess.run(
            ['git', 'diff', 'HEAD', '--numstat'], capture_output=True, text=True, timeout=6
        ).stdout
        for line in ns.splitlines():
            parts = line.split('\t')
            if len(parts) < 3:
                continue
            added, deleted, path = parts[0], parts[1], parts[2]
            if added == '-':  # binary
                continue
            if is_test(path):
                continue
            total += int(added) + int(deleted)
        # new untracked files (not in git diff HEAD)
        un = subprocess.run(
            ['git', 'ls-files', '--others', '--exclude-standard'], capture_output=True, text=True, timeout=6
        ).stdout
        for path in un.splitlines():
            if not path.strip() or is_test(path) or is_binary(path):
                continue
            try:
                with open(path, 'r', errors='ignore') as f:
                    total += sum(1 for _ in f)
            except Exception:
                pass
    except Exception:
        sys.exit(0)

    if total > THRESHOLD:
        print(
            f"Diff guardrail: uncommitted working-tree diff is {total} LOC (excl. tests, threshold {THRESHOLD}). "
            "Per your rule, pause and evaluate: is this step intentionally large, or should it be split / committed per step? "
            "(This nudge fires once.)",
            file=sys.stderr,
        )
        sys.exit(2)
    sys.exit(0)


main()
