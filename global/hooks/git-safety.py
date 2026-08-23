#!/usr/bin/env python3
"""PreToolUse/Bash guard (global): blocks hard force-push to main/master and staging of secret/credential files.
Reads the hook JSON on stdin; exit 2 blocks the tool call and feeds the message back to Claude.

The shape of this file is the point, so it is stated once here.

Two rounds of trying to decide "is this really an invocation?" by parsing the command taught the same
lesson twice: every gap in the parse made the invocation invisible, and invisible meant allowed. The
error always fell on the dangerous side, and each fix added new surface for the next gap.

So the verdict is not the parser's. The **flattened** test below is the verdict — the original one, which
looks at every character of the command and therefore cannot be slipped past. The parse only ever gets to
**excuse** it, and only under two conditions: the walk must declare itself sure of what it read, and no
runnable piece of the command may still look dangerous once comments and written documents are set aside.
Anything the walk does not model — a command substitution, an unbalanced quote, a here-document whose
terminator never arrives — withdraws the excuse rather than granting it.

The consequence is deliberate: a bug in this parser costs a refusal of something harmless, with the
`! <cmd>` escape, instead of a protection lost in silence.
"""
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


# Commands whose whole job is copying their standard input somewhere else, so a here-document one of them
# reads is a document being written. Gaps in this list cost a refusal of a harmless write, never a lost
# protection — which is the opposite of what a list of *interpreters* would cost, and the whole reason
# this list is acceptable where that one was not.
STDIN_WRITERS = ('cat', 'tee')
# Constructs the walk does not model. Their presence does not make a command dangerous; it makes the
# walk's reading untrustworthy, which withdraws its right to excuse anything.
UNMODELLED = re.compile(r'\$\(|`|<\(|>\(|\$\{|\beval\b|\bexec\b|\|&|;;|&>')
# A target the rail cannot evaluate by reading. It could name the default branch, so it earns no
# allowance; a glob is in here for the same reason a variable is.
UNRESOLVABLE = re.compile(r'[$`~*?\[\]]')
FILE_REDIRECT = re.compile(r'>>?\s*(?!&)\S')
SEPARATOR = re.compile(r'&&|\|\||;|\|')
HEREDOC_OPEN = re.compile(r"""(?<!<)<<(-?)(?!<)\s*('?"?)([A-Za-z_][A-Za-z0-9_]*)""")
# Values worth not echoing back into a transcript when the refusal names the piece it judged.
ASSIGNED_SECRET = re.compile(r'\b([A-Za-z_][A-Za-z0-9_]*)=(?!\s)\S+')
URL_USERINFO = re.compile(r'(//)[^/\s:@]+:[^/\s@]+@')


def quoted_spans(text: str):
    """Every quoted span in the text, and whether the walk ended outside all of them.

    One walk, used by everything that needs to know where the quoting is: locating separators, deciding
    whether git is really being invoked, and finding comments. Three separate readings of the same
    question is how they came to disagree — and the disagreement was exploitable, because an escaped
    quote fooled one of them and not the others.

    A backslash escapes the next character everywhere except inside single quotes, where the shell
    treats it literally.
    """
    spans, quote, start, i = [], '', 0, 0
    while i < len(text):
        ch = text[i]
        if quote == "'":
            if ch == "'":
                spans.append((start, i + 1))
                quote = ''
        elif quote == '"':
            if ch == '\\':
                i += 1
            elif ch == '"':
                spans.append((start, i + 1))
                quote = ''
        elif ch == '\\':
            i += 1
        elif ch in '\'"':
            quote, start = ch, i
        i += 1
    return spans, quote == ''


def blank(text: str, spans) -> str:
    """The text with the given spans replaced by spaces, so offsets are preserved."""
    out = list(text)
    for a, b in spans:
        for i in range(a, min(b, len(out))):
            if out[i] != '\n':
                out[i] = ' '
    return ''.join(out)


def dequote(text: str) -> str:
    spans, _ = quoted_spans(text)
    return blank(text, spans)


def comment_spans(text: str, spans):
    """Where the comments are, judged on the whole text with the quoting already located.

    Judged on the whole text and not line by line, because a quoted argument may span lines: reading each
    line alone made a `#` opening the second line of a message look like a comment, which deleted the
    rest of the command and everything it was doing.
    """
    covered = [False] * len(text)
    for a, b in spans:
        for i in range(a, min(b, len(text))):
            covered[i] = True
    out, i = [], 0
    while i < len(text):
        if text[i] == '#' and not covered[i] and (i == 0 or text[i - 1] in ' \t\n'):
            end = text.find('\n', i)
            end = len(text) if end < 0 else end
            out.append((i, end))
            i = end
        else:
            i += 1
    return out


def owns_heredoc(line_before: str) -> bool:
    """Whether the simple command that opens a here-document on this line writes it to a file.

    Read from the piece that actually owns the `<<`, not from the whole line: a redirect belonging to a
    later stage of a pipeline made `cat <<EOF | sh > out.log` look like a document being written, and the
    body then ran unjudged. Cutting at the last separator before the operator is what ties the command
    word and the redirect to the same simple command.
    """
    bare = dequote(line_before)
    piece = SEPARATOR.split(bare)[-1]
    words = [w for w in piece.split() if '=' not in w]
    head = words[0].rsplit('/', 1)[-1] if words else ''
    return head in STDIN_WRITERS and bool(FILE_REDIRECT.search(piece))


def parse(cmd: str):
    """The runnable pieces of the command, and whether the walk is sure of them.

    Returns `(pieces, confident)`. `confident` is False the moment the walk meets something it does not
    model, because a reading it cannot vouch for must not be allowed to excuse anything.
    """
    # Line endings are normalised once, so a document written on a CRLF machine still matches its own
    # terminator instead of being read as a body that never ends.
    cmd = cmd.replace('\r\n', '\n')
    spans, balanced = quoted_spans(cmd)
    confident = balanced and not UNMODELLED.search(blank(cmd, spans))

    # comments first: they are not command text, and a `#` inside quotes is not a comment
    text = blank(cmd, comment_spans(cmd, spans))
    # a command wrapped across lines is one command
    text = re.sub(r'\\\n', '  ', text)

    kept, lines, i = [], text.split('\n'), 0
    while i < len(lines):
        line = lines[i]
        kept.append(line)
        match = HEREDOC_OPEN.search(line)
        i += 1
        if not match:
            continue
        dash, tag = match.group(1), match.group(3)
        body, terminated = [], False
        while i < len(lines):
            if (lines[i].strip() if dash else lines[i]) == tag:
                terminated = True
                i += 1
                break
            body.append(lines[i])
            i += 1
        if not terminated:
            confident = False          # a body whose end never arrived was misread, not written
        if not (terminated and owns_heredoc(line[:match.start()])):
            kept.extend(body)          # input to a command, so still command text

    # Separators are located on a copy whose quoted spans are blank, then the ORIGINAL text is sliced at
    # those offsets — so a separator inside an argument neither severs a command nor condemns a note,
    # and every piece keeps its own quotes for the reads that need them.
    joined = '\n'.join(kept)
    jspans, _ = quoted_spans(joined)
    masked = blank(joined, jspans)
    pieces, last = [], 0
    for m in SEPARATOR.finditer(masked):
        pieces.append(joined[last:m.start()])
        last = m.end()
    pieces.append(joined[last:])
    return [p for p in pieces if p.strip()], confident


def invokes(piece: str, subcommand: str) -> bool:
    bare = dequote(piece)
    return bool(re.search(r'\bgit\b', bare)) and bool(re.search(r'\b%s\b' % subcommand, bare))


def lex(text: str):
    """The words of a command with its quotes understood, falling back to a whitespace split when it
    cannot be lexed — the stricter of the two readings, never no reading at all."""
    try:
        return shlex.split(text)
    except ValueError:
        return [t for t in re.split(r'\s+', text) if t]


def current_branch() -> str:
    """The checked-out branch, or the strict answer when it cannot be read.

    A probe that fails used to come back empty, which reads as "not the default branch" and lets a
    force-push through — a protection lost because a subprocess timed out. The failure now takes the
    strict side and says so through the refusal, which has the `! <cmd>` escape.
    """
    try:
        p = subprocess.run(['git', 'branch', '--show-current'],
                           capture_output=True, text=True, timeout=3)
        return p.stdout.strip() if p.returncode == 0 else 'main'
    except Exception:
        return 'main'


def force_push_hit(text: str) -> bool:
    """The flattened test, and the verdict. Run over the whole command it cannot be slipped past; run
    over one piece it says whether that piece is the dangerous one."""
    if not re.search(r'\bpush\b', text):
        return False
    # The two signals are read from different text, and the asymmetry is the point: each errs toward
    # refusing. The force flag is read RAW, so quoting it cannot hide it. The lease is read DE-QUOTED, so
    # a quoted *mention* of `--force-with-lease` — in a message, in prose — cannot switch the protection
    # off. Reading both from the same text would let one of them be faked.
    hard = bool(re.search(r'--force(?!-with-lease)\b', text)) or bool(
        re.search(r'(?:^|\s)-[A-Za-z]*f(?:\s|$)', text))
    if not hard or '--force-with-lease' in dequote(text):
        return False
    if re.search(r'\b(main|master)\b', text):
        return True
    toks = lex(text)
    try:
    # A refspec's source half may legitimately carry characters this guard cannot evaluate — `HEAD~1`
        # is an ordinary way to name a commit — while what the push lands on is the half after the colon.
        # Judging the whole word refused an explicitly named feature branch for the shape of its source.
        positionals = [t for t in toks[toks.index('push') + 1:]
                       if not t.startswith('-') and not UNRESOLVABLE.search(t.rsplit(':', 1)[-1])]
    except ValueError:
        positionals = []
    # An explicitly named branch that is not the default earns its allowance — but only where the text
    # holds nothing this guard cannot read. A command substitution carrying a space is split into words
    # by the lexer, and one of the fragments then reads as an ordinary branch name: `$(cat b)` became
    # `$(cat` and `b)`, the first filtered as unresolvable and the second counted as a named branch. An
    # allowance granted off a reading this guard has already declared untrustworthy is not an allowance.
    if len(positionals) >= 2 and not UNMODELLED.search(dequote(text)):
        return False
    return current_branch() in ('main', 'master')


def staged_secrets(text: str):
    """The secret paths this text would stage, by the flattened reading."""
    if not (re.search(r'\bgit\b', text) and re.search(r'\b(add|commit)\b', text)):
        return []
    toks = lex(text)
    # Shell punctuation glued to a word is not part of the filename. The lexer is not a shell parser,
    # so `git add .env;` inside a loop yields the word `.env;`, and the anchored path test does not match
    # it — the path was there, spelled correctly, and went unseen. Stripped here, in the reading that
    # cannot be slipped past, because that is the one whose misses are protections lost.
    cand = [t.strip('"\'').rstrip(';,)&|') for t in toks if not t.startswith('-')]
    danger = [t for t in cand if is_secret(t)]
    if danger:
        return danger
    broad = any(t in ('-A', '--all', '-u', '--update', '.', './', ':/', ':') for t in toks) or any(
        len(t) > 1 and t[0] == '-' and t[1] != '-' and ('A' in t or 'u' in t) for t in toks)
    if not (broad and re.search(r'\badd\b', text)):
        return []
    try:
        out = subprocess.run(['git', 'status', '--porcelain', '--untracked-files=all'],
                             capture_output=True, text=True, timeout=5).stdout
    except Exception:
        return []
    found = []
    for line in out.splitlines():
        path = line[3:].strip().strip('"')
        if ' -> ' in path:
            path = path.split(' -> ')[-1]
        if is_secret(path):
            found.append(path)
    return found


def quote_for_message(text: str) -> str:
    """The piece the refusal names, with what should not be echoed taken out.

    The refusal exists to make a false one diagnosable in one read, and it goes into the model's context
    and the session transcript. A command line carries inline credentials often enough that echoing it
    verbatim is a leak the diagnosis does not need: the shape is what a reader wants, not the value.
    """
    safe = ASSIGNED_SECRET.sub(lambda m: f'{m.group(1)}=<redacted>', text.strip())
    safe = URL_USERINFO.sub(r'\1<redacted>@', safe)
    return repr(safe if len(safe) <= 200 else safe[:200] + '…')


def refuse(message: str) -> None:
    print(message, file=sys.stderr)
    sys.exit(2)


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)
    if not isinstance(data, dict):
        sys.exit(0)  # a non-object payload must not traceback a hook that runs on every command

    # A field whose type the guard cannot use is a command it cannot judge, and the answer is the one
    # every other stand-aside branch here gives. Checked where each field is read, so nothing unusable is
    # carried forward to be cashed by a later line — the matchers below are exactly that later line.
    tool_input = data.get('tool_input')
    cmd = tool_input.get('command') if isinstance(tool_input, dict) else None
    if not isinstance(cmd, str) or not cmd:
        sys.exit(0)

    hit_force = force_push_hit(cmd)
    hit_secrets = staged_secrets(cmd)
    if not hit_force and not hit_secrets:
        sys.exit(0)          # the flattened reading sees nothing; there is nothing to excuse

    pieces, confident = parse(cmd)

    if hit_force:
        guilty = [p for p in pieces if invokes(p, 'push') and force_push_hit(p)]
        if not confident or guilty:
            named = quote_for_message(guilty[0] if guilty else cmd)
            refuse(
                "BLOCKED: hard force-push to main/master is forbidden (your 'Never' rule). "
                f"Judged this part of the command: {named}. "
                + ("" if confident else "The command uses something this guard cannot read, so it was "
                                        "judged as a whole. ")
                + "Use --force-with-lease, or push a feature branch. "
                "If you truly intend this, run it yourself with '! <cmd>'."
            )

    if hit_secrets:
        guilty = [(p, staged_secrets(p)) for p in pieces
                  if (invokes(p, 'add') or invokes(p, 'commit')) and staged_secrets(p)]
        if not confident or guilty:
            piece, found = guilty[0] if guilty else (cmd, hit_secrets)
            uniq = ', '.join(sorted(set(found)))
            refuse(
                f"BLOCKED: this command appears to stage a secret/credential file: {uniq}. "
                f"Judged this part of the command: {quote_for_message(piece)}. "
                + ("" if confident else "The command uses something this guard cannot read, so it was "
                                        "judged as a whole. ")
                + "Never commit secrets. If it's a false positive, run it yourself with '! <cmd>' "
                "or add the file to .gitignore."
            )

    sys.exit(0)


main()
