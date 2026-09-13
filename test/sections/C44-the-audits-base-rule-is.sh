echo "== C44: the audit's base rule is watched everywhere it is stated, and the purity sweep reads only what ships =="

# --- the purity sweep reads what ships, not what the disk holds -------------
# GIVEN an engine tree that carries both a file which will be distributed and a file git ignores,
# WHEN the purity sweep runs,
# THEN it reports the first and never the second.
#
# The fixture is a throwaway repository, never this one: a sweep proven by littering the tree it audits
# is the mutation the engine's own rule forbids, and an ignored file left behind would silently change
# the next run's verdict — which is the very defect this pair exists to close.
# The sandbox is guarded: creating one can fail, and a teardown against an empty path is a delete
# against the filesystem root. `mkbox` answers nothing and a non-zero status when it cannot, and the
# guard below is what turns that into failed rows rather than a run operating on "/".
if ! T44="$(mkbox)" || [ ! -d "$T44" ]; then
  T44=""
  bad "the purity sweep ignores what git ignores (no sandbox: mktemp -d failed)"
  bad "the purity sweep still catches a real leak in a file that ships (no sandbox: mktemp -d failed)"
  bad "the sweep refuses to answer when it cannot read, instead of answering clean (no sandbox: mktemp -d failed)"
else
mkdir -p "$T44/global/hooks/__pycache__"
printf '__pycache__/\n' > "$T44/.gitignore"
# The file that ships, carrying the leak the sweep must still catch.
printf 'HOME_HINT = "/Users/someone/projects/thing"\n' > "$T44/global/hooks/real.py"
# The byte-compiled twin, carrying the identical string. `install.sh` fetches named files and never
# this one, so it is not the shipped engine and must not be read as if it were.
printf 'X/Users/someone/projects/thing/global/hooks/real.py\n' > "$T44/global/hooks/__pycache__/real.cpython-310.pyc"
git -C "$T44" init -q 2>/dev/null
git -C "$T44" add -A >/dev/null 2>&1
git -C "$T44" -c user.email=t@t -c user.name=t commit -qm base >/dev/null 2>&1
# The sweep's contract is tracked files PLUS untracked ones git is not ignoring, and a fixture that
# commits everything exercises only the first half -- so this one arrives after the commit and stays
# untracked. Without it, dropping `--others` from the sweep would leave every row green.
printf 'NOTE = "/Users/someone/projects/thing"\n' > "$T44/global/hooks/fresh.py"
# The fixture proves itself before anything concludes from it: `git init` can fail, and a sandbox that
# was never built produces no hits, which reads exactly like a clean sweep.
FIX44=""
git -C "$T44" rev-parse --git-dir >/dev/null 2>&1 || FIX44="$FIX44 fixture-is-not-a-repository"
[ -f "$T44/global/hooks/real.py" ] || FIX44="$FIX44 fixture-missing-the-tracked-file"
[ -f "$T44/global/hooks/__pycache__/real.cpython-310.pyc" ] || FIX44="$FIX44 fixture-missing-the-ignored-file"
[ -f "$T44/global/hooks/fresh.py" ] || FIX44="$FIX44 fixture-missing-the-untracked-file"

# `purity_sweep <repo-root> <subpath>` prints one `file:line:text` per hit over the files that could
# actually ship — tracked, plus untracked that git does not ignore. It is defined beside the live sweep
# it serves; the absence branch below is what keeps these rows from passing vacuously if it is ever
# deleted or renamed, since an absent function returns no output and no output names no ignored file.
if command -v purity_sweep >/dev/null 2>&1 || type purity_sweep 2>/dev/null | grep -q function; then
  OUT44="$(purity_sweep "$T44" global 2>/dev/null)"; RC44=$?
  # A sweep that refused to run also returns no output, and no output names no ignored file -- so the
  # row below would read a refusal as a pass. The status separates the two.
  [ "$RC44" -eq 0 ] || SWEEP44_ABSENT=1
else
  OUT44=""
  SWEEP44_ABSENT=1
fi

r44a="$FIX44"
[ -n "${SWEEP44_ABSENT:-}" ] && r44a="$r44a sweep-absent-or-refused"
printf '%s' "$OUT44" | grep -q '__pycache__' && r44a="$r44a reads-an-ignored-file"
[ -z "$r44a" ] \
  && ok "the purity sweep ignores what git ignores" \
  || bad "the purity sweep ignores what git ignores (missing:$r44a)"

# The other direction, and it is the one that costs money to get wrong: a sweep narrowed until it reads
# nothing passes the row above for the wrong reason. Asserted on the file's name in the output, not on a
# count, so a sweep that reports a hit in some other file cannot stand in for this one.
r44b="$FIX44"
[ -n "${SWEEP44_ABSENT:-}" ] && r44b="$r44b sweep-absent-or-refused"
printf '%s' "$OUT44" | grep -q 'real\.py'  || r44b="$r44b misses-a-tracked-file-that-ships"
printf '%s' "$OUT44" | grep -q 'fresh\.py' || r44b="$r44b misses-an-untracked-file-that-ships"
[ -z "$r44b" ] \
  && ok "the purity sweep still catches a real leak in a file that ships" \
  || bad "the purity sweep still catches a real leak in a file that ships (missing:$r44b)"

# --- the working-copy comparison states its own reach -----------------------
# GIVEN the step that compares the working copy against the snapshot,
# WHEN it reports the tree left as found,
# THEN the step says what that verdict does not cover — files git ignores, which neither probe reaches.
#
# Scoped to the compare bullet of the snapshot-comparison step, resolved by content rather than by
# number: the word `ignore` appears elsewhere in the skill (`--exclude-standard` prose, the untracked
# listing), so a file-wide grep would be green before the clause is written.
VS44="global/skills/verify/SKILL.md"
NC44="$(grep -nE '^[0-9]+\. \*\*Compare the working copy' "$VS44" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/')"
# The COMPARE BULLET, not the whole step. An earlier form of this row sliced from step 8 to step 9 and
# so read the Precondition, Identical and Different bullets too -- any of which can feed a vocabulary
# leg in a future edit. `sbullet` is the helper this file already uses for exactly that reason.
CMP44="$([ -n "$NC44" ] && sbullet "$VS44" "$NC44" 'Compare[.]')"
# The FACT, not two vocabulary hits. Both legs of the earlier form were satisfied by the bullet's own
# opening clause -- `not ignoring` fed one and `reach of` fed the other -- so the sentence that carries
# the criterion was deletable with the suite green, and prose asserting the OPPOSITE passed as well.
# Leg 1 binds an ignored file to being outside the probes, within one sentence. Leg 2 is what kills the
# inversion: a passage claiming the probes cover everything cannot state this consequence.
r44c=""
[ -n "$CMP44" ] || r44c="$r44c compare-bullet-did-not-extract"
printf '%s' "$CMP44" | grep -qE 'ignore[sd]?[^.]{0,40}outside' || r44c="$r44c ignored-not-bound-to-outside"
printf '%s' "$CMP44" | grep -qE 'verdict about that reach|never about the whole directory' || r44c="$r44c consequence-not-stated"
[ -z "$r44c" ] \
  && ok "the comparison names the reach it does not cover" \
  || bad "the comparison names the reach it does not cover (missing:$r44c)"

# --- the refusal that makes the git-scoped narrowing safe -------------------
# Added at Verify: the review proved this uncovered by flipping the sweep's `return 2` to `return 0`
# with the suite green, so a sweep that concludes from nothing could be reintroduced in silence. Both
# refusals, because they are different branches -- a selection naming no file, and a tree that is not a
# repository at all -- and the second is the one that turns a missing `.git` into a clean purity verdict.
r44d=""
purity_sweep "$T44" nosuchpath >/dev/null 2>&1 && r44d="$r44d empty-selection-read-as-clean"
if ! NR44="$(mkbox)" || [ ! -d "$NR44" ]; then
  r44d="$r44d no-sandbox-for-the-non-repository-leg"
else
  mkdir -p "$NR44/global"; printf 'x\n' > "$NR44/global/f.txt"
  purity_sweep "$NR44" global >/dev/null 2>&1 && r44d="$r44d non-repository-read-as-clean"
  rm -rf "$NR44"
fi
[ -z "$r44d" ] \
  && ok "the sweep refuses to answer when it cannot read, instead of answering clean" \
  || bad "the sweep refuses to answer when it cannot read, instead of answering clean (missing:$r44d)"
fi
