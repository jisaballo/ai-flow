"""Enumerate the suite's verdict sites and give each one an identity that survives a rewrite.

A VERDICT SITE is a decision point, not an emitted row. The suite writes one as a branch whose arms
call `ok` and `bad` with the SAME claim, the failing arm adding a parenthetical reason:

    && ok "an unfiltered run executes every section in numeric order" \
    || bad "an unfiltered run executes every section in numeric order (order: '${ord93}')"

So a site's identity is (section, claim): the message with its trailing reason removed and its shell
interpolations erased. That pairing is what separates the site from the row -- a site inside a loop
emits many rows, a site in a branch nothing reaches emits none -- and it is the unit a later repair
can act on, because it is the unit the source file actually holds.

Two consequences are deliberate. An absence arm (`bad "A1 ... (no $GUARD92)"` in a block guarded on the
subject's existence) carries the same claim as the real arm and therefore joins the SAME site: it is one
decision reported from two branches, not two decisions. And a `bad` with no `ok` anywhere in its section
stands as a site of its own -- a claim that can only ever fail is still a decision point.
"""
import re, os, glob

# A verdict call in COMMAND position. The guard on what may precede it is the whole point: `grep -qF 'ok
# "the sandbox is torn down"'` is a string that mentions a verdict, not a verdict, and a bare search for
# the name counts it. C46:194 is the live instance and was found by this filter refusing it.
CALL = re.compile(r'''(?:^|[;&|{]|\)(?=[ \t])|\bthen\b|\belse\b|\bdo\b)[ \t]*(ok|bad)[ \t]+"''')

# A reason appended with a colon rather than a parenthesis -- `bad "the claim:$a2b39"` -- is the other
# spelling the corpus uses, and it is removed after interpolation erasure leaves the colon dangling.
TRAILER = re.compile(r'[\s:;,.\-\u2014]+$')

# `$(...)`, `${...}` and `$var` all erase to nothing: two arms of one site differ exactly by what they
# interpolate, so a claim that kept them would split the site it exists to join.
INTERP = re.compile(r'\$\([^)]*\)|\$\{[^}]*\}|\$[A-Za-z_][A-Za-z0-9_]*')
WS = re.compile(r'\s+')

# A claim that is a PARAMETER rather than a literal. This one test is the whole enumeration: a call whose
# message is a literal claim IS the site; a call whose message is a parameter is a WRAPPER's, its own line
# is not a site, and each of its callers is one. The partition is total over the set of calls, which is
# what makes the enumeration complete without parsing a line of shell structure.
PARAM = re.compile(r'^\$\{?[0-9A-Za-z_]')


def mask_quoted(line):
    """The line with every quoted span's CONTENT blanked, so nothing inside one can be read as syntax.

    `grep -qE 'ok "|bad "'` (C25:125) is a search pattern, not two verdicts -- but the literal `|` inside
    it satisfies CALL's command-position guard, so the call matches and only `read_string`'s
    unterminated-quote rule rejects it. That rescue is an ACCIDENT: the same row written with its quotes
    closed would be enumerated as a verdict about the suite's own source. These are `C92`'s self-judging
    rows, so the corpus being measured contains a description of the thing measuring it.

    Masking rather than matching, deliberately: the exclusion written as a regex was refused by the search
    engine for complexity -- `IB-023`'s failure, where a refused pattern reads as a clean absence. A
    single-pass scan cannot be refused and cannot come back falsely empty.

    Both quote kinds are masked and the DELIMITERS are kept, because `CALL` ends at the message's opening
    `"`: the match still lands, and `m.end()` indexes the same character in the masked line as in the
    original, so `read_string` reads the real message. Length is preserved for exactly that reason.

    A naive single-state toggle is wrong here and the corpus proves it in one line: the apostrophe in
    `ok "C36's four regions all extract" || bad "C36's ..."` would turn masking on mid-message and blank
    the `|| bad` arm that follows, losing a real verdict. A quote is only a delimiter when no other kind
    is open.
    """
    out = []
    mode = None
    i = 0
    while i < len(line):
        ch = line[i]
        if mode is None:
            out.append(ch)
            if ch in ('"', "'"):
                mode = ch
        elif mode == '"':
            if ch == '\\' and i + 1 < len(line):
                out.append('  '); i += 2; continue
            out.append(ch if ch == '"' else ' ')
            if ch == '"':
                mode = None
        else:
            out.append("'" if ch == "'" else ' ')
            if ch == "'":
                mode = None
        i += 1
    return ''.join(out)


# Functions whose verdict's claim is their own parameter. DECLARED, not derived -- and the declaration is
# checked by `unregistered()` below, which is what makes hand-declaring it safe. Deriving the attribution
# from shell structure was tried twice and failed twice, the same way both times: brace counting ran
# through a quoted `awk` program and indentation anchoring ran past a brace written at another indent, so
# a "body" swallowed the rest of the file and every literal verdict in it. Both are the mis-balance defect
# this instrument's own classifier carries. See `producers.md`.
#
# `decisions` is how many verdicts ONE call contributes. `manfact` is the only multiplier: it judges the
# shipped manual and then, only where `$MANTWIN` exists, the live twin -- so the corpus size is a property
# of the HOST, and the report says which host it was taken on.
#
# `denominator` False means enumerated and reported but never counted as a verdict site. `fatal` is the
# only one: its body is one `bad` and then `exit 1`. It asserts nothing about any subject, no falsifier can
# be written for it, and no later task will repair or prune one -- so counting its 39 sites would depress
# every fraction-carrying-a-falsifier figure in the direction that flatters the epic's own premise.
WRAPPERS = {
    'manfact':    {'decisions': 2, 'denominator': True,  'cause': None,            'arg': 2},
    'pair':       {'decisions': 1, 'denominator': True,  'cause': None,            'arg': 4},
    'malformed':  {'decisions': 1, 'denominator': True,  'cause': None,            'arg': 1},
    'amalformed': {'decisions': 1, 'denominator': True,  'cause': None,            'arg': 1},
    'waved':      {'decisions': 1, 'denominator': True,  'cause': None,            'arg': 2},
    'mpair':      {'decisions': 1, 'denominator': True,  'cause': None,            'arg': 4},
    'fatal':      {'decisions': 1, 'denominator': False, 'cause': 'harness-abort', 'arg': 1},
}

# Contexts where a parameter-claim call is NOT a wrapper: a top-level loop printing one row per claim from
# a literal word list -- `for r in "claim A" "claim B"; do bad "$r (...)"; done`. The claims are in the
# loop's own list, which no relation here reaches, so such a call collapses several decisions into one
# site. Enumerated as the single site it currently reads as, COUNTED as a known under-count, and reported:
# it is why the corrected site total is itself a floor rather than a census.
LOOP_IDIOM_SECTIONS = ('C16', 'C22', 'C29', 'C61', 'C18', 'C5', 'C60')


def read_string(line, start):
    """The double-quoted argument beginning at `start`, or None when it does not close on this line."""
    out = []
    i = start
    while i < len(line):
        c = line[i]
        if c == '\\' and i + 1 < len(line):
            out.append(line[i + 1]); i += 2; continue
        if c == '"':
            return ''.join(out)
        out.append(c); i += 1
    return None


def strip_reason(msg):
    """Remove one balanced parenthetical at the very end -- the failing arm's reason.

    Balanced rather than greedy: `(${n93:-0} file(s))` closes on its own last paren, and a rule keyed
    on the first `(` would cut the claim in half.
    """
    s = msg.rstrip()
    if not s.endswith(')'):
        return s
    depth = 0
    for i in range(len(s) - 1, -1, -1):
        if s[i] == ')':
            depth += 1
        elif s[i] == '(':
            depth -= 1
            if depth == 0:
                return s[:i].rstrip() if i > 0 else s
    return s


def claim_of(msg):
    # Order is load-bearing: the parenthetical is cut from the RAW message, because the reason inside it
    # is usually an interpolation and erasing first would leave `()` behind; the dangling separator is
    # cut AFTER, because that is what erasing an interpolation leaves.
    s = strip_reason(msg)
    s = INTERP.sub('', s)
    s = TRAILER.sub('', s)
    s = WS.sub(' ', s).strip().lower()
    # A message that is NOTHING but an interpolation -- `bad "$m (creation move not found)"`, the loop
    # idiom -- erases to empty, and an empty key would make three sites share one identity and match
    # nothing in history. Such a message keeps its literal text instead. Done here rather than at the
    # callers because both the enumerator and the provenance pass key on this function, and a fallback
    # only one of them applied is a site that can never find its own birth.
    return s if s else WS.sub(' ', msg).strip().lower()


def normalize(msg):
    """An EMITTED row's message, reduced the same way a claim is but with nothing cut from the end."""
    return WS.sub(' ', INTERP.sub('', msg)).strip().lower()


def match(msg, labels):
    """Which site emitted this row: the longest label the message begins with, or None.

    Matching a row to its site by re-deriving a claim from the message does not work, and the failure is
    silent in the worst direction. A failing arm appends its reason, and the corpus writes that reason
    three ways -- `(...)`, `:$var`, and a literal `: [what went wrong]` whose text may itself carry
    unbalanced brackets and parentheses. The first two erase cleanly because the source holds an
    interpolation; the third does not, because by the time the row is printed the variable is gone and
    what is left is ordinary prose. A row like `A4 ... nano: [docs/customization.md's skeleton teaches no
    nano block]` therefore derived a claim no site owned, and the site that emitted it was recorded as
    having emitted NOTHING -- a red counted as `does-not-emit`, which is the one direction that flatters
    the corpus. Longest-prefix against the labels the enumeration already knows has no reason format to
    get right.
    """
    text = normalize(msg)
    best = None
    for label in labels:
        if text.startswith(label) and (best is None or len(label) > len(best)):
            best = label
    return best


def section_id(path):
    return os.path.basename(path).split('-', 1)[0]


def scan_file(path):
    """Every verdict call in one section: (line_no, verb, raw message)."""
    hits = []
    with open(path, encoding='utf-8', errors='replace') as fh:
        for n, line in enumerate(fh, 1):
            # Searched on the masked line, read from the real one. Masking preserves length, so the two
            # index identically -- without it a `|` written inside a quoted SEARCH PATTERN reads as a
            # command separator and the suite's own description of a verdict is enumerated as a verdict.
            masked = mask_quoted(line)
            pos = 0
            while True:
                m = CALL.search(masked, pos)
                if not m:
                    break
                pos = m.end()
                msg = read_string(line, m.end())
                if msg is None:      # not a verdict: an unterminated quote is a mention, not a call
                    continue
                hits.append((n, m.group(1), msg))
    return hits


DEF_ANY = re.compile(r'^\s*([a-zA-Z_][a-zA-Z0-9_]*)\(\)\s*\{')


def defs_of(path):
    """(line, name) for every function definition in the file, in source order."""
    out = []
    with open(path, encoding='utf-8', errors='replace') as fh:
        for n, line in enumerate(fh, 1):
            m = DEF_ANY.match(line)
            if m:
                out.append((n, m.group(1)))
    return out


def owner_of(defs, line_no):
    """The nearest function definition at or above `line_no`.

    This is the NEAREST-PRECEDING rule, which is wrong in general -- it cannot see where a body ends, so
    a call after a function has closed is attributed to it anyway. It is used here only to ask whether a
    parameter-claim call sits in a REGISTERED wrapper, and `unregistered()` is what makes that safe: every
    call this rule fails to explain is reported rather than silently miscounted. Deriving the answer
    properly needs the body, and two attempts to find a body by parsing structure both failed -- see
    `producers.md`.
    """
    best = None
    for n, name in defs:
        if n <= line_no and (best is None or n > best[0]):
            best = (n, name)
    return best[1] if best else None


def corpus_files(root):
    return [os.path.join(root, 'test', 'lib', 'preamble.sh')] + \
        sorted(glob.glob(os.path.join(root, 'test', 'sections', '*.sh')))


def unregistered(root):
    """Every parameter-claim call the wrapper registry does not explain.

    The completeness check, and the reason `WRAPPERS` may be declared by hand at all. A parameter-claim
    call is either a registered wrapper's or a known loop idiom's; anything else is a producer nobody has
    accounted for, and the pipeline refuses to publish a count while this is non-empty. A new wrapper
    added to the suite therefore breaks the measurement loudly instead of shrinking it quietly.
    """
    out = []
    for path in corpus_files(root):
        defs = defs_of(path)
        sec = section_id(path)
        for (line, _verb, msg) in scan_file(path):
            if not PARAM.match(msg.strip()):
                continue
            if owner_of(defs, line) in WRAPPERS:
                continue
            if sec in LOOP_IDIOM_SECTIONS:
                continue
            out.append((sec, line, owner_of(defs, line), msg[:70]))
    return out


def wrapper_call_re(name):
    """What a call of `name` looks like in command position. ONE definition, two readers: the enumeration
    that turns a call into a site, and the provenance pass that must find the same call in history."""
    return re.compile(r'(?:^|[;&|{]|\)(?=[ \t])|\bthen\b|\belse\b|\bdo\b)[ \t]*'
                      + re.escape(name) + r'[ \t]+[^\s)]')


def wrapper_call_sites(root, name):
    """Every call of `name` in a section: (section, path, line). The definition itself is never one."""
    pat = wrapper_call_re(name)
    out = []
    for path in sorted(glob.glob(os.path.join(root, 'test', 'sections', '*.sh'))):
        with open(path, encoding='utf-8', errors='replace') as fh:
            for n, line in enumerate(fh, 1):
                m = DEF_ANY.match(line)
                if m and m.group(1) == name:
                    continue
                if pat.search(mask_quoted(line)):
                    out.append((section_id(path), path, n))
    return out



def args_at(line, name):
    """The arguments of a `name ...` call on this line, quoted ones unquoted, in order.

    The claim a wrapper prints is one of ITS CALLER'S arguments, so this is what gives each call site a
    claim of its own instead of the wrapper's `$1`. A bare (unquoted) argument is kept as written: it is
    usually the name of the predicate function the wrapper will run, which is not a claim but does occupy
    a position, and dropping it would shift every argument after it.
    """
    i = line.find(name)
    if i < 0:
        return []
    i += len(name)
    out = []
    while i < len(line):
        while i < len(line) and line[i] in ' \t':
            i += 1
        if i >= len(line) or line[i] in '\n#':
            break
        if line[i] in '"\'':
            # Single quotes count: the corpus passes regexes as `'stays open|remains open'`, and a reader
            # that only knows double quotes splits one argument into three on its spaces and every
            # argument after it shifts position -- which is how `mpair`'s label came back as the fragment
            # `open|front`.
            q = line[i]
            j = i + 1
            buf = []
            while j < len(line) and line[j] != q:
                if q == '"' and line[j] == '\\' and j + 1 < len(line):
                    buf.append(line[j + 1]); j += 2; continue
                buf.append(line[j]); j += 1
            if j >= len(line):
                break
            out.append(''.join(buf))
            i = j + 1
        elif line[i] == '\\':
            break
        else:
            j = i
            while j < len(line) and line[j] not in ' \t':
                j += 1
            out.append(line[i:j])
            i = j
    return out


def wrapper_sites(root):
    """One site per wrapper CALL, per verdict that call emits, labelled with the caller's own claim."""
    out = []
    for name, spec in sorted(WRAPPERS.items()):
        for sec, path, line in wrapper_call_sites(root, name):
            with open(path, encoding='utf-8', errors='replace') as fh:
                src = fh.readlines()
            # A call written across a line continuation keeps its later arguments on the following lines,
            # and the claim is usually the LAST of them: `mpair 3 'pattern' 'pattern' \\` puts the label
            # out of reach of a single-line read, which returned a regex fragment as the claim and left
            # three sites unable to match any row they emit.
            text = src[line - 1]
            k = line
            while text.rstrip('\n').endswith('\\') and k < len(src):
                text = text.rstrip('\n')[:-1] + ' ' + src[k]
                k += 1
            a = args_at(text, name)
            raw = a[spec['arg'] - 1] if len(a) >= spec['arg'] else ''
            base = claim_of(raw) if raw else ('%s call at %s:%d' % (name, sec, line))
            for k in range(spec['decisions']):
                # `manfact`'s SECOND decision judges the live twin -- `~/.claude/CLAUDE.md`, which nothing
                # distributes and which sits outside the repository. It cannot be made untrue in a copy of
                # the repository, so it can never yield the yes/no a mutation is made of. Marked HERE,
                # where the two decisions are still distinguishable: by the time the sampler sees a row,
                # both read as `manfact` sites and excluding on the wrapper's name would throw away the
                # shipped-copy decision too, which is perfectly mutable.
                out.append({'section': sec, 'path': path, 'line': line,
                            'label': base if k == 0 else 'the live twin: ' + base,
                            'lines': [line], 'verbs': {'ok', 'bad'}, 'verdict_lines': [line],
                            'wrapper': name, 'in_denominator': spec['denominator'],
                            'cause': spec['cause'], 'outside_repo': k > 0})
    return out


def corpus(root):
    """Every verdict site in the suite, each with its arms joined.

    Two relations join arms into one site, and both are needed because the corpus writes the decision
    two ways. The SAME CLAIM joins the modern form, where the failing arm repeats the claim and appends
    its reason. The SAME LINE joins the older one-liner -- `test -f X && ok "hook exists" || bad "hook
    missing"` -- whose arms word themselves differently and would otherwise read as two decisions about
    one file. Joined transitively, so a claim written across three failing arms and one green arm is one
    site rather than four.
    """
    import glob
    out = []
    for path in sorted(glob.glob(os.path.join(root, 'test', 'sections', '*.sh'))):
        # A registered wrapper's own verdict call is its DEFINITION, not a decision: `mpair` (C15) and
        # `amalformed` (C70) are defined inside sections and were enumerated as sites, which is where two
        # of the published rows carrying a bare `$4`/`$1` as their label came from. The preamble's five
        # wrappers were never reached at all, this loop globbing only `test/sections/`.
        # BOTH conditions, and the second alone is not safe: `owner_of` is nearest-preceding, so in C70
        # every literal verdict written after `amalformed`'s definition is attributed to it, and filtering
        # on ownership alone silently deleted 21 real sites. A wrapper prints its own PARAMETER -- a
        # literal-claim call is never a wrapper's own verdict -- so the partition's test is what bounds it.
        defs = defs_of(path)
        hits = [h for h in scan_file(path)
                if not (PARAM.match(h[2].strip()) and owner_of(defs, h[0]) in WRAPPERS)]
        parent = list(range(len(hits)))

        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x

        def union(a, b):
            ra, rb = find(a), find(b)
            if ra != rb:
                parent[ra] = rb

        by_claim, by_line = {}, {}
        for i, (line, _verb, msg) in enumerate(hits):
            by_claim.setdefault(claim_of(msg), []).append(i)
            by_line.setdefault(line, []).append(i)
        for group in list(by_claim.values()) + list(by_line.values()):
            for j in group[1:]:
                union(group[0], j)

        members = {}
        for i in range(len(hits)):
            members.setdefault(find(i), []).append(i)
        for _root_i, group in sorted(members.items(), key=lambda kv: min(hits[i][0] for i in kv[1])):
            arms = [hits[i][0] for i in group]
            out.append({'section': section_id(path), 'path': path, 'line': min(arms),
                        'label': claim_of(hits[group[0]][2]), 'lines': sorted(set(arms)),
                        'verbs': {hits[i][1] for i in group},
                        'verdict_lines': [h[0] for h in hits],
                        'wrapper': None, 'in_denominator': True, 'cause': None})
    out.extend(wrapper_sites(root))
    return out
