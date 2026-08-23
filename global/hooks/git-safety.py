#!/usr/bin/env python3
"""PreToolUse/Bash guard (global): blocks hard force-push to main/master and staging of secret/credential files.
Reads the hook JSON on stdin; exit 2 blocks the tool call and feeds the message back to Claude."""
import sys, json, re, shlex, subprocess


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


# The two `<` must be exactly two: a `<<<` here-string is not a here-document, and reading one as an
# opener starts a hunt for a terminator that never arrives, which used to swallow every following line.
HEREDOC_OPEN = re.compile(r"""(?<!<)<<(-?)(?!<)\s*'?"?([A-Za-z_][A-Za-z0-9_]*)'?"?""")
# Commands whose whole job is to copy their standard input somewhere else. A here-document one of these
# reads is a document being written, not a command being run.
#
# This list is safe in the exact way a list of interpreters was not, and the difference is the direction
# of its gaps. A command missing from here has its body JUDGED — a false refusal, with the `! <cmd>`
# escape. An interpreter missing from that other list would have had its body EXECUTED UNJUDGED, which is
# a protection silently lost. Same shape of list, opposite failure mode, so the objection that refused
# the one does not reach the other.
STDIN_WRITERS = ('cat', 'tee', 'dd')
# A target carrying any of these is one the rail cannot evaluate by reading: a variable, a command
# substitution, a home-directory expansion. It could name the default branch, so it earns no allowance.
UNRESOLVABLE = re.compile(r'[$`~]')
# A redirect to a file, which is what makes a here-document body data. `>&1` and friends redirect to a
# descriptor, not a file, so they are excluded: a body is not written just because stderr was merged.
FILE_REDIRECT = re.compile(r'>>?\s*(?!&)\S')
QUOTED_SPAN = re.compile(r"""'[^']*'|"[^"]*\"""")
SEPARATOR = re.compile(r'&&|\|\||;|\||\n')


def split_outside_quotes(text: str):
    """Cut on the shell's separators, but only where they are not inside a quoted span.

    Locating separators in the raw text severs a quoted argument in half, and both directions of that
    are wrong. A commit message carrying a semicolon left `git commit -m "wip` in one piece and
    ` more" secrets` in another — and the piece holding the path had no `git` in it, so nothing ever
    inspected it. The mirror of the same cut refuses a note whose quoted prose happens to contain a
    separator, which is the false refusal this whole change exists to remove.

    The separators are found on a copy whose quoted spans are blanked to the SAME LENGTH, and the raw
    text is sliced at those offsets, so every piece that comes out still carries its own quotes — the
    target reads need them, and only the invocation test blanks them.
    """
    masked = QUOTED_SPAN.sub(lambda m: ' ' * len(m.group(0)), text)
    parts, last = [], 0
    for m in SEPARATOR.finditer(masked):
        parts.append(text[last:m.start()])
        last = m.end()
    parts.append(text[last:])
    return [p for p in parts if p.strip()]


def strip_comment(line: str) -> str:
    """A trailing shell comment is not part of the command.

    Reading one as part of the command is how a note *about* a forbidden operation gets refused *as*
    the operation: `git add README.md  # never add .env` stages one file and mentions another. Quote
    state is tracked because `-m "fix #1"` is a message, not a comment.
    """
    quote, i = '', 0
    while i < len(line):
        ch = line[i]
        if quote == "'":
            if ch == "'":       # inside single quotes a backslash is an ordinary character
                quote = ''
        elif ch == '\\':
            i += 1              # an escaped character is data, never a quote and never a comment marker
        elif quote:
            if ch == quote:
                quote = ''
        elif ch in '\'"':
            quote = ch
        elif ch == '#' and (i == 0 or line[i - 1].isspace()):
            return line[:i]
        i += 1
    return line


def lex(seg: str):
    """The words of one command, with its quotes understood.

    This is what separates a file being staged from a file being mentioned: under a whitespace split
    `git commit -m "add .env to gitignore"` yields a bare `.env` token and the message reads as a
    staged secret. It closes the opposite hole too — `git add "."` was never inspected at all, because
    the broad-add test could not see a quoted dot, so a repository holding an untracked secret was
    staged with no check. A command that cannot be lexed falls back to the whitespace split, which is
    the stricter of the two readings; never to no scan.
    """
    try:
        return shlex.split(seg)
    except ValueError:
        return [t for t in re.split(r'\s+', seg) if t]


def writes_body(opener: str) -> bool:
    """Whether this opening line copies its here-document into a file rather than running it.

    Two things must hold, and the earlier version of this check asked only the second. The command
    reading the document must be one whose whole job is copying its input — otherwise
    `bash <<'EOF' > out.log` read as a write, and its body, a hard force-push, executed unjudged. And the
    line must redirect somewhere, or `cat <<'EOF' | sh` is a write too and its body would go free.

    The redirect is read with quoted spans blanked, so a `>` inside an argument is not a redirect.
    """
    bare = QUOTED_SPAN.sub(' ', opener)
    words = [w for w in re.split(r'\s+', bare.strip()) if w and '=' not in w]
    head = words[0].rsplit('/', 1)[-1] if words else ''
    return head in STDIN_WRITERS and bool(FILE_REDIRECT.search(bare))


def segments(cmd: str):
    """The command as the shell would run it, one runnable piece at a time.

    A here-document body is dropped only where `writes_body` says the line copies it into a file, and
    kept everywhere else — including where its terminator never arrived, since a body whose end was
    never found was misread rather than written. Dropping written bodies is what lets a document quote a
    forbidden command without being refused for it; keeping every other body is what stops an
    interpreter from running one unjudged.

    Then the rest is cut on the shell's own separators — outside quoted spans, and after joining lines
    a trailing backslash continues — so each protection is judged against one runnable piece rather
    than the whole line. This scopes rather than positions: it never asks whether `git` is the first
    word, so an invocation behind `sudo`, after an environment assignment, inside a `for ... do` loop,
    after a directory change or under `xargs` is still found — while an unrelated `rm -rf` in another
    piece can no longer condemn a safe push.
    """
    kept, lines, i = [], cmd.split('\n'), 0
    while i < len(lines):
        opener = lines[i]
        kept.append(opener)
        match = HEREDOC_OPEN.search(opener)
        i += 1
        if not match:
            continue
        dash, tag = match.group(1), match.group(2)
        body, terminated = [], False
        while i < len(lines):
            # only the dash form lets its terminator be indented; the plain form wants it exactly, so a
            # body line that merely looks like the terminator cannot end the document early
            if (lines[i].strip() if dash else lines[i]) == tag:
                terminated = True
                i += 1  # the terminator line is not a command either
                break
            body.append(lines[i])
            i += 1
        # A body whose end never arrived was misread, not written: treating those lines as a document
        # would let a mis-spelled terminator swallow every command after it. Judge them instead — the
        # stricter reading, which is the direction every fallback in this file already takes.
        if not terminated or not writes_body(opener):
            kept.extend(body)  # a command's input, or a body whose terminator was never found
    text = '\n'.join(strip_comment(line) for line in kept)
    # A command wrapped across lines with a trailing backslash is one command, and cutting on the newline
    # made two of it — the invocation in one piece, its force flag or its target in another, and neither
    # piece complete enough to judge. Joined after the here-document pass, whose openers need their own
    # line, and before the cut. Comments go first, so a backslash inside a comment is already gone.
    text = re.sub(r'\\\n', ' ', text)
    return split_outside_quotes(text)


def invokes(seg: str, subcommand: str) -> bool:
    """Whether this piece of the command really invokes `git <subcommand>`.

    Asked of the piece with its quoted spans blanked out, because a note that quotes a command is prose
    and not an invocation. Only this question is asked of the de-quoted text: what the command is aimed
    at — which branch, which files — is read from the raw piece, since a branch name or a path may
    legitimately be quoted. Blanking the quotes there would let a real command through.
    """
    bare = QUOTED_SPAN.sub(' ', seg)
    return bool(re.search(r'\bgit\b', bare)) and bool(re.search(r'\b%s\b' % subcommand, bare))


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

    # 1) Hard force-push to main/master (allow --force-with-lease and feature branches).
    # Judged one runnable piece at a time: the invocation, the force signal and the target must all be
    # in the same piece, so a force flag belonging to another command no longer condemns a safe push.
    for seg in segments(cmd):
        if not invokes(seg, 'push'):
            continue
        hard_force = bool(re.search(r'--force(?!-with-lease)\b', seg)) or bool(
            re.search(r'(?:^|\s)-[A-Za-z]*f(?:\s|$)', seg)
        )
        with_lease = '--force-with-lease' in seg
        if hard_force and not with_lease:
            if re.search(r'\b(main|master)\b', seg):
                targets_main = True  # main/master named explicitly
            else:
                # no main/master mentioned: if an explicit (non-main) branch is given, allow;
                # only fall back to the current branch when no refspec is provided.
                # A target the rail cannot resolve is not an explicit safe branch. A positional naming a
                # shell variable could hold anything, main included, so it does not earn the allowance
                # that a named non-main branch earns; the judgement falls through to the checked-out
                # branch instead. Flattening used to catch the assignment by coincidence — only while it
                # sat in the same command, so a variable set in an earlier one was never covered at all.
                # Read with the same lexer the staging protection uses, rather than a second tokenizer
                # re-derived here; two readings of one string in one file is how they drift apart.
                toks = lex(seg)
                try:
                    positionals = [t for t in toks[toks.index('push') + 1:]
                                   if not t.startswith('-') and not UNRESOLVABLE.search(t)]
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
                # Naming the piece that was judged is what makes the next false refusal diagnosable in
                # one read, instead of by re-deriving what the rail matched against.
                print(
                    "BLOCKED: hard force-push to main/master is forbidden (your 'Never' rule). "
                    f"Judged this part of the command: {seg.strip()!r}. "
                    "Use --force-with-lease, or push a feature branch. "
                    "If you truly intend this, run it yourself with '! <cmd>'.",
                    file=sys.stderr,
                )
                sys.exit(2)

    # 2) Staging secret/credential files — judged one runnable piece at a time, like the protection
    # above, and with the piece's own words rather than whatever the whitespace fell between.
    for seg in segments(cmd):
        stages = invokes(seg, 'add')
        if not stages and not invokes(seg, 'commit'):
            continue
        toks = lex(seg)
        # explicitly named files in this piece of the command
        # Reported without the quoting around it. `is_secret` already strips quotes to make its own
        # decision, so a raw token here named the file one way and judged it another — and on the
        # whitespace fallback, where tokens keep their quotes, that is the path the refusal printed.
        danger = [t.strip('"\'') for t in toks if not t.startswith('-') and is_secret(t)]
        # broad add (git add . / -A / --all / -u): inspect what would be staged
        if not danger and stages and any(t in ('-A', '--all', '-u', '.') for t in toks):
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
                f"Judged this part of the command: {seg.strip()!r}. "
                "Never commit secrets. If it's a false positive, run it yourself with '! <cmd>' "
                "or add the file to .gitignore.",
                file=sys.stderr,
            )
            sys.exit(2)

    sys.exit(0)


main()
