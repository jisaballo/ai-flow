#!/usr/bin/env python3
"""PreToolUse/Bash guard (global): blocks hard force-push to main/master and staging of secret/credential files.
Reads the hook JSON on stdin; exit 2 blocks the tool call and feeds the message back to Claude."""
import sys, json, re, subprocess


def is_secret(path: str) -> bool:
    p = path.lower().strip('"\'')
    SAFE = ('.env.example', '.env.template', '.env.sample', '.env.dist', '.env.local.example')
    if any(p.endswith(s) for s in SAFE):
        return False
    if re.search(r'(^|/)\.env($|\.)', p):
        return True
    if re.search(r'\.(pem|p12|pfx|jks|keystore)$', p):
        return True
    if re.search(r'(^|/)id_(rsa|dsa|ecdsa|ed25519)$', p):
        return True
    if re.search(r'service[-_]?account.*\.json$', p):
        return True
    return False


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)
    if not isinstance(data, dict):
        sys.exit(0)  # a non-object payload must not traceback a hook that runs on every command

    # The same rule one level in: the object's fields are payload too, and a field whose type the guard
    # cannot use is a command it cannot judge — the answer every other branch here already gives. Each
    # field is checked where it is read, so nothing unusable is carried forward to be cashed by a later
    # line; the regexes below are exactly that later line, and a non-string command reaches them as a
    # TypeError. Standing aside is not a weakening: this hook's non-zero exit is a non-blocking error, so
    # a traceback ran the command with no guard at all. Falling over was never the safe direction.
    tool_input = data.get('tool_input')
    cmd = tool_input.get('command') if isinstance(tool_input, dict) else None
    if not isinstance(cmd, str) or not cmd:
        sys.exit(0)

    # 1) Hard force-push to main/master (allow --force-with-lease and feature branches)
    if re.search(r'\bpush\b', cmd):
        hard_force = bool(re.search(r'--force(?!-with-lease)\b', cmd)) or bool(
            re.search(r'(?:^|\s)-[A-Za-z]*f(?:\s|$)', cmd)
        )
        with_lease = '--force-with-lease' in cmd
        if hard_force and not with_lease:
            if re.search(r'\b(main|master)\b', cmd):
                targets_main = True  # main/master named explicitly
            else:
                # no main/master mentioned: if an explicit (non-main) branch is given, allow;
                # only fall back to the current branch when no refspec is provided.
                toks = re.split(r'\s+', cmd.strip())
                try:
                    positionals = [t for t in toks[toks.index('push') + 1:] if not t.startswith('-')]
                except ValueError:
                    positionals = []
                if len(positionals) >= 2:
                    targets_main = False  # explicit non-main branch
                else:
                    try:
                        cur = subprocess.run(
                            ['git', 'branch', '--show-current'], capture_output=True, text=True, timeout=3
                        ).stdout.strip()
                        targets_main = cur in ('main', 'master')
                    except Exception:
                        targets_main = False
            if targets_main:
                print(
                    "BLOCKED: hard force-push to main/master is forbidden (your 'Never' rule). "
                    "Use --force-with-lease, or push a feature branch. "
                    "If you truly intend this, run it yourself with '! <cmd>'.",
                    file=sys.stderr,
                )
                sys.exit(2)

    # 2) Staging secret/credential files
    if re.search(r'\bgit\b', cmd) and re.search(r'\b(add|commit)\b', cmd):
        danger = []
        # explicitly named files in the command
        for tok in re.split(r'\s+', cmd):
            if tok and not tok.startswith('-') and is_secret(tok):
                danger.append(tok)
        # broad add (git add . / -A / --all / -u): inspect what would be staged
        if not danger and re.search(r'\badd\b', cmd) and re.search(r'(?:\s|^)(-A|--all|-u|\.)(?:\s|$)', cmd):
            try:
                out = subprocess.run(
                    ['git', 'status', '--porcelain', '--untracked-files=all'],
                    capture_output=True, text=True, timeout=5,
                ).stdout
                for line in out.splitlines():
                    path = line[3:].strip().strip('"')
                    if ' -> ' in path:
                        path = path.split(' -> ')[-1]
                    if is_secret(path):
                        danger.append(path)
            except Exception:
                pass
        if danger:
            uniq = ', '.join(sorted(set(danger)))
            print(
                f"BLOCKED: this command appears to stage a secret/credential file: {uniq}. "
                "Never commit secrets. If it's a false positive, run it yourself with '! <cmd>' "
                "or add the file to .gitignore.",
                file=sys.stderr,
            )
            sys.exit(2)

    sys.exit(0)


main()
