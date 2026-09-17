"""Place each verdict site in one of the four `observed:` classes the criterion field will carry.

Nothing in this repository defines the four, so they are given an OPERATIONAL definition here -- one a
reader can apply to a region of shell and get the same answer:

  run      the region EXECUTES the subject -- a guard, a hook, a script, the installer, the suite's own
           runner -- and the verdict reads what that execution printed or the status it returned. A
           program produced the evidence, so the assertion has an oracle it did not write itself.
  compute  nothing is executed, and the verdict rests on an arithmetic relation between two DERIVED
           quantities: a difference, a count against another count, a set algebra over two extractions.
  resolve  nothing is executed and nothing is counted; the verdict is that a REFERENT resolves -- a path
           exists, a name is bound, a revision names something.
  read     the verdict rests on a pattern matched against a file's TEXT. This is the class with no
           oracle: the pattern and the prose it reads are written by the same actor, so what it detects
           is that the prose CHANGED and never that the rule is wrong.

PRECEDENCE is run > compute > resolve > read, applied to the first class whose signal appears in the
region. It runs strongest-oracle-first on purpose: a `run` site greps the output of what it ran, so a
rule that let the grep speak would file the whole executed population under the class that means "no
program produced this". A site whose region carries no signal at all is `unplaced` -- reported by size,
never as a fifth class, because the decision downstream compares `read` against `run` and a rate
attached to a bucket the field cannot hold is not a rate anyone can read.

The REGION is the code between the previous verdict call in the same file and this site's own arm,
unioned over every arm. It is the evidence-gathering the site actually did. What it deliberately does
NOT include is the section's top-of-file setup: attributing a section-wide `hookcall` to all forty of
its sites would file a whole block under `run` on one neighbour's work, which is the same error as
letting a grep speak for an execution.
"""
import re

VARREF = re.compile(r'\$\{?([A-Za-z_][A-Za-z0-9_]*)')
ASSIGN = 'assignment placeholder'
IFHEAD = re.compile(r'^\s*(if|elif|case)\b')
IFCLOSE = re.compile(r'^\s*(fi|esac)\b')

# Executes something out of the repository under test. The preamble's invocation helpers are named
# because that is how the corpus reaches a guard: `hookcall`/`hookraw` for the write rails, `wguard`/
# `wraw` for the worktree rail, `graw`/`waved`/`malformed` for the payload sweeps, `brake` for the
# diff-size guard, and the `wti_*` family for the selection probe.
RUN = re.compile(r'''\b(hookcall|hookraw|wguard|wraw|graw|waved|malformed|brake|wti_probe|wti_classify|wti_tracked_leak)\b'''
                 r'''|\bpython3?\b|\bbash\b|\bsh\s+-c\b|\bcommand\s+-v\b'''
                 r'''|\./[A-Za-z0-9_./-]*\.(sh|py)\b|\b(install|validate)\.sh\b''')

# Two derived quantities put into an arithmetic relation. A numeric comparison counts only when BOTH
# sides are derived -- `[ "$n" -gt "$m" ]` is a computation, `[ "$rc" -eq 0 ]` is reading a status and
# belongs to whatever produced it.
COMPUTE = re.compile(r'''\$\(\(|\bcomm\s+-|\bdiff\s|\bcmp\s|\bsort\s+-u\b'''
                     r'''|-(eq|ne|gt|lt|ge|le)\s+"?\$''')

# A referent resolves. File tests, and git's two answers about whether a name exists.
RESOLVE = re.compile(r'''\[\s*!?\s*-[fdexrs]\s|\btest\s+!?\s*-[fdexrs]\s'''
                     r'''|\bgit\s+(ls-files|rev-parse|cat-file|show-ref)\b''')

# A pattern against text. `insent`, `nreg`, `keyed` and the section-extractors are the preamble's own
# spellings of it, and they are named so a leg that reaches prose through a helper is not read as having
# reached nothing.
READ = re.compile(r'''\bgrep\b|\bawk\b|\bsed\b|\binsent\b|\bnreg\b|\bkeyed\b'''
                  r'''|\b(msect|mbul|nstep|vstep|dmove|nitem|sbullet|clohead|manfact|step_no|off|pair)\b''')

# Reporting and fixture construction. Expanding these would file a section under whatever built its
# sandbox rather than under what it actually asked.
NOT_EVIDENCE = {'ok', 'bad', 'fatal', 'mkbox', 'mkproj', 'cleanup_boxes', 'nlines', 'nwords', 'mkbig'}

FUNCDEF = re.compile(r'^([a-zA-Z_][a-zA-Z0-9_]*)\(\)\s*\{')


def helpers(paths):
    """name -> body, for every function the corpus defines. One flat map across the files given.

    A section reaches its subject through a name of its own as readily as through the preamble's:
    `run33` pushes to a sandboxed remote, `o31` runs awk over a protocol. Classifying the call site
    without the body reads both as having done nothing, which is where a sixth of the residue sat.
    """
    out = {}
    for path in paths:
        lines = open(path, encoding='utf-8', errors='replace').read().split('\n')
        i = 0
        while i < len(lines):
            m = FUNCDEF.match(lines[i])
            if m and m.group(1) not in NOT_EVIDENCE:
                body, depth, j = [], 0, i
                while j < len(lines) and j < i + 60:
                    body.append(lines[j])
                    depth += lines[j].count('{') - lines[j].count('}')
                    if j > i and depth <= 0:
                        break
                    j += 1
                out.setdefault(m.group(1), '\n'.join(body))
                i = j
            i += 1
    return out


LADDER = (('run', RUN), ('compute', COMPUTE), ('resolve', RESOLVE), ('read', READ))


def enclosing(lines, arm, want=3):
    """The `if`/`elif`/`case` headers this arm sits under, innermost first.

    An `else` arm's own slice holds no condition at all -- `else; bad "project.yml missing"` is the whole
    of it -- so a region cut at the previous verdict reads as though the site tested nothing. Walking the
    nesting back to the headers is what puts `[ -f "$PY" ]` in front of the arm that fires when it fails.
    """
    got, skip, i = [], 0, arm - 2
    while i >= 0 and len(got) < want:
        line = lines[i]
        if IFCLOSE.match(line):
            skip += 1
        elif IFHEAD.match(line):
            if skip:
                skip -= 1
            else:
                got.append(line)
        i -= 1
    return got


# How many hops the name chase follows. One hop is not enough, and that was established by measurement
# rather than argued: a one-hop resolution over this corpus leaves 225 of 376 read sites with no subject
# at all, because a section reaches its subject through a CHAIN -- a region names `$RULE`, `RULE` is
# assigned from `$RULE_LINES`, and `RULE_LINES` is assigned from `$VP`, which is the path. Stopping at
# the first assignment files all three as having read nothing. Four hops carries that chain and brings
# the blind population to 65 of 376; the hops beyond it found nothing further in this corpus.
CHASE_DEPTH = 4

# Never chased. `1` is a positional parameter, and the other two are the runner's own bindings rather
# than anything the site derived -- the region filter drops them before the first hop and the chase has
# to drop them again, because a chased assignment line mentions them as freely as the region does.
NOT_CHASED = {'1', 'ROOT', 'SECTION'}


def assignments(lines, arm, names, depth=CHASE_DEPTH):
    """The preceding assignment of each name the region mentions, followed transitively.

    `case "$out" in *Traceback*) bad ...` says nothing about where `$out` came from, and where it came
    from is the whole classification: `out="$(wguard ...)"` is a program's output and `out="$(cat
    "$DOC")"` is a document's text. Following the name to its assignment is what tells them apart.

    The chase stays INSIDE the section file, which is what keeps it honest: the shared fixture builders
    live in the preamble, so no number of hops can reach `mkbox` and file a section under whatever built
    its sandbox. Resolving against the preamble as well was measured and recovers 8 of 107 -- it is the
    chain within the file that carries the subject, not the shared setup.

    Each name is resolved at most once, so a cycle terminates and a name reached by two paths
    contributes its line once.
    """
    got, seen, frontier = [], set(NOT_CHASED), [n for n in names if n not in NOT_CHASED]
    for _ in range(depth):
        if not frontier:
            break
        nxt = []
        for name in frontier:
            if name in seen:
                continue
            seen.add(name)
            pat = re.compile(r'^\s*(?:local\s+|export\s+)?%s=' % re.escape(name))
            for i in range(arm - 2, -1, -1):
                if pat.match(lines[i]):
                    got.append(lines[i])
                    nxt.extend(n for n in VARREF.findall(lines[i]) if n not in seen)
                    break
        frontier = nxt
    return got


def regions(site, lines, verdict_lines, depth=CHASE_DEPTH):
    """The evidence-gathering code of one site: what sits between the previous verdict and each arm,
    plus the conditions the arm sits under and the assignment of every name it reads."""
    out = []
    for arm in sorted(set(site['lines'])):
        prev = 0
        for v in verdict_lines:
            if v < arm and v > prev:
                prev = v
        slice_ = '\n'.join(lines[prev:arm])        # lines is 0-based: [prev .. arm-1] is prev+1 .. arm
        heads = enclosing(lines, arm)
        names = [n for n in dict.fromkeys(VARREF.findall(slice_ + '\n' + '\n'.join(heads)))
                 if n not in ('1', 'ROOT', 'SECTION')]
        out.append('\n'.join([slice_] + heads + assignments(lines, arm, names, depth=depth)))
    return '\n'.join(out)


CALLNAME = re.compile(r'\b([a-z_][a-z0-9_]*)\b')


def expand(region, funcs):
    """The region plus the body of every helper it calls -- one hop, for the reason `assignments` is."""
    seen = [region]
    for name in dict.fromkeys(CALLNAME.findall(region)):
        if name in funcs:
            seen.append(funcs[name])
    return '\n'.join(seen)


def classify(region, funcs=None):
    text = expand(region, funcs) if funcs else region
    for name, pat in LADDER:
        if pat.search(text):
            return name
    return 'unplaced'
