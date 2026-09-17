#!/usr/bin/env python3
"""The suite's register of its own verdict sites, and the guard that refuses new ones of two shapes.

WHAT THIS EXISTS FOR. A verdict site whose evidence is a pattern matched against this engine's own prose
has no oracle: the pattern and the sentence it reads are written by the same actor in the same change, so
what it detects is that the prose CHANGED, never that the rule is wrong. Such sites were added here
repeatedly, each time as the answer to the previous one, because nothing anywhere noticed one arriving.
This tool is what notices.

WHAT IT REFUSES, and the two shapes are separate rules with separate evidence:

  md      the site's evidence region resolves a subject that is a `.md` document under this engine's own
          documents, AND the region classifies as `read`. The `read` conjunct is deliberate and is what
          was measured: over a corpus of 288 hand verdicts the pair agrees with the hand verdict 113
          times in 114. Dropping it would refuse a site that EXECUTES a script and merely mentions a
          document path nearby.

  oracle  the site takes a value out of the suite's own text at run time and uses it as the PATTERN of a
          matcher whose haystack is not that stream. The suite then judges another file by a string it
          copied out of itself, so the two sides cannot disagree.

WHAT IT DOES NOT JUDGE, stated here because a guard that hides its blind spots is worse than one that has
none. It never decides whether a site is RIGHT. It cannot perform the sole-and-complete-source test -- a
site reading engine source as text is admissible when that source is the only and complete statement of
the fact, and that is a judgement, not a shape; a rule refusing every such site was measured against the
hand verdicts and would refuse 9 sites that were kept. And the region half of the oracle shape is out of
reach: a suite-derived value consumed by an ABSENCE leg with no floor under it fails open, and that shape
is mechanically indistinguishable from admissible counting.

HOW IT SHIPS GREEN over the sites already here. It judges only what is NEW -- present in the working tree
and absent at the merge-base with the published trunk. Its limit follows from that and is not a caveat:
it bites on any work not yet published, in any checkout, which is every moment a site is being authored
and every moment the suite is run to validate one. Once published, a site is inherited by definition and
this tool stops seeing it.

USAGE
    recurrence-register.py reach <root>    the blind-population figures, one line of key=value
    recurrence-register.py guard <root>    refuse new sites of either shape; see EXITS below

EXITS for `guard`
    0   no new site of either shape
    1   at least one refused; one REFUSE line per site on stdout
    3   the published trunk could not be resolved, so NEW cannot be computed. This is deliberately not
        0: an empty set difference and an unanswerable one are different facts, and reporting the second
        as the first is a guard that certifies whatever it could not look at.
"""
import hashlib
import importlib.util
import re
import os
import subprocess
import sys
import tempfile

# Set BEFORE the first import below, because importing is what would write the file.
#
# This tool imports two things from inside the repository it is measuring: its own helper modules, and
# the diff-size guard, for the one home of the trunk rule. Python's default is to cache each as bytecode
# in a `__pycache__` directory BESIDE THE SOURCE -- so running this guard would leave
# `global/hooks/__pycache__/` in the operator's tree. That is not merely untidy: the repository's own
# purity sweep asserts that nothing git hides can ship, `__pycache__/` is git-ignored, and the sweep
# therefore goes red on a directory this tool created by doing its job. Measured, not predicted: the row
# fired on `global/hooks/__pycache__/diff-size-guard.cpython-310.pyc` the first time the suite ran with
# this section in it.
#
# A guard whose own execution dirties the tree it is judging cannot be run twice with the same answer,
# which is the property every other row here depends on.
sys.dont_write_bytecode = True

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, 'register'))

import lib_classify  # noqa: E402
import lib_sites  # noqa: E402
import lib_subject  # noqa: E402

US = '\x1f'

# The engine's own documents. A `.md` outside these is somebody's notes; a `.md` inside them is a rule in
# force, which is what makes reading it as text the shape this tool refuses.
DOC_ROOTS = ('global/', 'template/', 'docs/')
DOC_FILES = ('CLAUDE.md', 'README.md')


def base_ref(root):
    """The remote's default branch, else a local main/master, else None.

    Imported rather than restated. This rule has ONE home -- `base_ref` in the diff-size guard -- and the
    only other reader that restates it is a shell hook, which says in its own comment that it restates
    because it cannot import. Copying it a third time here would manufacture exactly the second home the
    suite refuses elsewhere.
    """
    path = os.path.join(root, 'global', 'hooks', 'diff-size-guard.py')
    if not os.path.isfile(path):
        return None
    spec = importlib.util.spec_from_file_location('_diff_size_guard', path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod.base_ref(root)


def git(root, *args):
    try:
        out = subprocess.run(('git', '-C', root) + args, capture_output=True, text=True)
    except OSError:
        return ''
    return out.stdout if out.returncode == 0 else ''


def site_key(site, lines_cache):
    """One identity per site that survives a rewrite of everything around it.

    Keyed on the site's OWN anchor lines and not on the verdict lines it shares with its neighbours: a
    key over the shared lines was measured unique and is NOT stable -- deleting one site of a group made
    49 keys disappear and 48 appear, for a net of one.
    """
    lines = lines_cache.setdefault(
        site['path'], open(site['path'], encoding='utf-8', errors='replace').read().split('\n'))
    text = '\n'.join(lines[n - 1].strip() for n in sorted(set(site['lines'])))
    label = ' '.join(str(site['label']).replace(US, ' ').split())
    return US.join((site['section'], label, hashlib.sha1(text.encode()).hexdigest()[:12]))


def is_engine_doc(path):
    return path.endswith('.md') and (path.startswith(DOC_ROOTS) or path in DOC_FILES)


# The suite's own text, as the corpus reaches it: the preamble's helper, and the variable it reads.
SUITE_SRC_RE = re.compile(r'\bsuite_src(_others)?\b|\$\{?SUITE_SRC\b')

ASSIGN_RE = re.compile(r'^\s*(?:local\s+|export\s+)?([A-Za-z_][A-Za-z0-9_]*)=')

# A matcher with its OPTIONS skipped and its first remaining argument captured. That argument is the
# PATTERN, and the position is the entire rule -- see `oracle_sites` for why.
GREP_ARG_RE = re.compile(
    r'\bgrep\b((?:\s+-{1,2}[A-Za-z0-9-]+)*)\s+'
    r'(?:"\$\{?([A-Za-z_][A-Za-z0-9_]*)\}?"|\$\{?([A-Za-z_][A-Za-z0-9_]*)\}?(?=[\s;|)]|$))')


def oracle_sites(region):
    """The names in this region that carry the suite's own text into a matcher's PATTERN slot.

    WHY POSITION AND NOT PROVENANCE. Plenty of admissible rows take a value out of the suite's text --
    counting its markers, enumerating its helpers, deriving a scope. What makes a row unable to fail is
    using that value as the PATTERN against something else: the suite then judges another file by a
    string it copied out of itself, so the two sides cannot disagree and the row is green whatever
    either one says.

    The corpus shows both positions one line apart, which is what makes the discriminator checkable:

        PAT46A="$(suite_src | grep -m1 '...' | ...)"      # from the suite's text
        printf '%s' "$ROW46" | grep -qiE "$PAT46A"        # PATTERN slot, foreign haystack -> REFUSED

        KEYS89="$(awk '...' $SUITE_SRC)"                  # also from the suite's text
        printf '%s\n' "$KEYS89" | grep -qxF "$lab89"      # HAYSTACK slot -> admissible, and needed

    A line that feeds `suite_src` in as its own haystack is excluded: the suite matching its own text
    against itself is self-consistency, not an absent oracle.

    WHAT THIS DOES NOT REACH, and it is the larger half. A suite-derived value consumed by an ABSENCE
    leg with no floor under it fails open by the same mechanism, and that shape cannot be told apart
    from admissible counting by reading the code -- `C25`'s TWINBLK25 is the instance, and it is a
    stated miss rather than an oversight.
    """
    derived, hits = set(), []
    for line in region.split('\n'):
        m = ASSIGN_RE.match(line)
        if m and SUITE_SRC_RE.search(line):
            derived.add(m.group(1))
    if not derived:
        return hits
    for line in region.split('\n'):
        if SUITE_SRC_RE.search(line):
            continue
        for _flags, quoted, bare in GREP_ARG_RE.findall(line):
            name = quoted or bare
            if name in derived and name not in hits:
                hits.append(name)
    return hits


def register(root):
    """Every verdict site of the tree at `root`, with its key, its class and its resolved subjects."""
    funcs = lib_classify.helpers(lib_sites.corpus_files(root))
    out, lines_cache = [], {}
    for site in lib_sites.corpus(root):
        lines = lines_cache.setdefault(
            site['path'], open(site['path'], encoding='utf-8', errors='replace').read().split('\n'))
        # TWO regions of the same site, at two chase depths, and the split is load-bearing.
        #
        # The class is read off the ONE-HOP region and the subject off the chased one. Chasing names
        # transitively is what finds a subject reached through a chain -- a region names `$RULE`, `RULE`
        # comes from `$RULE_LINES`, `RULE_LINES` from `$VP`, which is the path -- and it cuts the sites
        # with no subject at all from 225 of 376 to 109 on the tree where that was measured.
        #
        # But the chased region is the wrong input for the CLASS, because the extra assignment lines
        # carry their own `grep`, `python3` and `$(( ))` tokens. Measured: classifying on the chased
        # region moves 9 sites between classes (`read` rises 376 -> 385, and 191 -> 200 here) for
        # reasons having nothing to do with any site's own evidence. Since the refusal below is keyed on
        # `read`, a reclassification changes WHICH SITES THE GUARD REFUSES -- so letting the chase reach
        # the class would put the deepest failure this suite knows about, a region that does not own the
        # claim it is read for, directly inside the refusal logic.
        shallow = lib_classify.regions(site, lines, site['verdict_lines'], depth=1)
        chased = lib_classify.regions(site, lines, site['verdict_lines'])
        paths = lib_subject.paths(chased)
        out.append({
            'key': site_key(site, lines_cache),
            'section': site['section'],
            'line': min(site['lines']),
            'label': site['label'],
            'klass': lib_classify.classify(shallow, funcs),
            'docs': [p for p in paths if is_engine_doc(p)],
            'others': [p for p in paths if not is_engine_doc(p)],
            # Read off the CHASED region: the assignment that ties a name to `suite_src` is often
            # several hops from the matcher that spends it, and the one-hop region loses the link.
            'oracle': oracle_sites(chased),
        })
    return out


def reach(root):
    """The populations this tool cannot see, counted rather than asserted."""
    reg = [s for s in register(root) if s['klass'] == 'read']
    md_only = sum(1 for s in reg if s['docs'] and not s['others'])
    mixed = sum(1 for s in reg if s['docs'] and s['others'])
    source_only = sum(1 for s in reg if not s['docs'] and s['others'])
    blind = sum(1 for s in reg if not s['docs'] and not s['others'])
    return {'read': len(reg), 'md_only': md_only, 'mixed': mixed,
            'source_only': source_only, 'blind': blind, 'depth': lib_classify.CHASE_DEPTH}


def base_register(root):
    """The register of the merge-base tree, or None when no trunk resolves.

    The base tree is extracted read-only into a temporary directory rather than checked out: this runs
    inside a suite that may itself be running in a worktree, and adding one would mutate the repository
    the caller is being measured in.
    """
    ref = base_ref(root)
    if not ref:
        return None
    merge_base = git(root, 'merge-base', 'HEAD', ref).strip()
    if not merge_base:
        return None
    with tempfile.TemporaryDirectory() as tmp:
        archive = subprocess.run(('git', '-C', root, 'archive', merge_base, 'test'),
                                 capture_output=True)
        if archive.returncode != 0:
            return None
        untar = subprocess.run(('tar', '-x', '-C', tmp), input=archive.stdout, capture_output=True)
        if untar.returncode != 0:
            return None
        return register(tmp)


def guard(root):
    base = base_register(root)
    if base is None:
        print('TRUNK-UNRESOLVED no published trunk resolves, so new sites cannot be told from inherited')
        return 3
    inherited = {s['key'] for s in base}
    here = register(root)
    new = [s for s in here if s['key'] not in inherited]
    refused = [s for s in new if (s['klass'] == 'read' and s['docs']) or s['oracle']]
    # ONE LINE PER (SITE, SHAPE), never one per site. A site can match both shapes at once, and an
    # earlier form of this printed only the first -- so the row owning the unprinted shape reported that
    # no site had it, while such a site was sitting in the tree. Each row must be answerable from the
    # lines naming its OWN shape, or one row goes green on another row's finding.
    for s in sorted(refused, key=lambda s: (s['section'], s['line'])):
        if s['klass'] == 'read' and s['docs']:
            print('REFUSE %s:%s md reads %s -- %s'
                  % (s['section'], s['line'], ','.join(s['docs']), s['label']))
        if s['oracle']:
            print('REFUSE %s:%s oracle %s in pattern position -- %s'
                  % (s['section'], s['line'], ','.join(s['oracle']), s['label']))
    # `sites` is reported so the caller can put a FLOOR under everything else on this line. A register
    # that came back empty -- a renamed corpus, an unreadable section, a glob that matched nothing --
    # produces `new=0 refused=0`, which is byte-identical to a tree that is genuinely clean. Without a
    # count to test, the two readings of a green guard cannot be told apart.
    print('sites=%d base=%d new=%d refused=%d'
          % (len(here), len(base), len(new), len(refused)))
    return 1 if refused else 0


def main(argv):
    if len(argv) != 3 or argv[1] not in ('reach', 'guard'):
        print(__doc__.split('USAGE')[1].strip(), file=sys.stderr)
        return 2
    root = os.path.abspath(argv[2])
    if argv[1] == 'reach':
        print(' '.join('%s=%s' % kv for kv in reach(root).items()))
        return 0
    return guard(root)


if __name__ == '__main__':
    sys.exit(main(sys.argv))
