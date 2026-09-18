"""The repository paths a verdict site reads, so that a red at baseline can be told from a red over
nothing at all.

A site that fails at its own baseline has two very different reasons to: the fact it names was FALSE
back then -- which is a real red and evidence the assertion discriminates -- or the thing it reads did
not EXIST back then, which is evidence of nothing whatever. The second is the class every leg written
for a new subject lands in, and it is the population this instrument is blind on, so it is kept as its
own outcome and never folded into the first.

Telling them apart needs the site's subject, and the subject is a path. They are written three ways in
this corpus and all three are read here: bare and repo-relative (`global/protocols/verify.md`), under
`$ROOT/`, and under `$HK/`, which the preamble binds to the hooks directory.
"""
import re

PREFIX = {'HK': 'global/hooks'}
TOP = r'(?:global|template|docs|bin|examples|hooks)'
PATH = re.compile(r'\$\{?(ROOT|HK)\}?/([A-Za-z0-9_./-]+)'
                  r'|(?<![A-Za-z0-9_/.-])(' + TOP + r'/[A-Za-z0-9_./-]+)'
                  r'|(?<![A-Za-z0-9_/.-])(install\.sh|CLAUDE\.md|README\.md|package\.json|\.worktreeinclude)')


def paths(region):
    """Every repository path the region names, repo-relative and de-duplicated."""
    out = []
    for var, rest, bare, top in PATH.findall(region):
        if var:
            p = (PREFIX[var] + '/' + rest) if var in PREFIX else rest
        else:
            p = bare or top
        p = p.rstrip('/.,:;"\')')
        if p and p not in out:
            out.append(p)
    return out
