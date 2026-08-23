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


TRUNK = ('main', 'master')

# A literal ref name, as opposed to something the shell or another program will substitute before git
# ever sees it. Braces and `$` are excluded on purpose: `{}` is an xargs placeholder and `$BRANCH` a
# shell variable, and neither says what the destination will be. The charset is what git itself accepts
# in a refspec (`+`, `:`, `^`, `~`, `@` included) minus those substitution markers.
LITERAL_REF = re.compile(r'^[A-Za-z0-9._/+:^~@\-]+$')


def push_args(cmd: str):
    """The tokens after the `push` subcommand, split into flags and positionals.

    Quotes are stripped because a refspec is often written inside them and git never sees them. Shell
    punctuation glued to a token is deliberately *not* stripped: a target written inside a loop arrives
    as `main;` and one inside a subshell as `main)`, and leaving them is what makes those tokens fail
    the literal-ref test below — which routes the command to the broad read that already convicts it.
    Trimming them was measured to protect nothing the broad read does not already protect."""
    toks = re.split(r'\s+', cmd.strip())
    try:
        after = toks[toks.index('push') + 1:]
    except ValueError:
        return [], []
    flags, positionals = [], []
    for tok in after:
        if tok.startswith('-'):
            flags.append(tok)
            continue
        ref = tok.strip('"\'')
        if ref:
            positionals.append(ref)
    return flags, positionals


def targets_trunk(cmd: str, flags, positionals):
    """Whether the command's own text says the trunk is a destination.

    Three answers, not two. `None` means the command names no refspec at all, so its destination is
    the checkout's current branch and is not in the text for this function to read — the caller
    answers that one.

    The destination is the right of `src:dst`, or the whole ref when there is no colon. The side
    matters: pushing the trunk *into* a feature branch is harmless, and no test over the flattened
    command can tell that from the reverse, because both spell the trunk's name."""
    if any(f in ('--mirror', '--all', '--branches') for f in flags):
        return True  # every ref is sent, so the trunk is among them whatever branch we are on
    resolved, unreadable = [], False
    for ref in positionals[1:]:  # the first positional is the repository, never a refspec
        if not LITERAL_REF.match(ref):
            unreadable = True
            continue
        dst = ref.lstrip('+')
        if ':' in dst:
            dst = dst.split(':')[-1]
        resolved.append(re.sub(r'^refs/heads/', '', dst))
    if any(dst in TRUNK for dst in resolved):
        return True
    if unreadable:
        # The destination will be substituted, so the narrow read cannot answer for this command.
        # Fall back to the broad read this guard has always used: it convicts on the trunk's name
        # appearing anywhere, which over-refuses — and over-refusing is the safe direction here.
        return bool(re.search(r'\b(main|master)\b', cmd))
    return False if resolved else None


def current_branch() -> str:
    """The branch of the checkout, or '' when it cannot be read. Run in this process's own directory,
    which is not necessarily the one the session declared — a known defect, tracked separately."""
    try:
        return subprocess.run(
            ['git', 'branch', '--show-current'], capture_output=True, text=True, timeout=3
        ).stdout.strip()
    except Exception:
        return ''


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
            flags, positionals = push_args(cmd)
            targets_main = targets_trunk(cmd, flags, positionals)
            if targets_main is None:
                targets_main = current_branch() in TRUNK  # no refspec: git pushes the current branch
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
