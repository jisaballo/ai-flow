echo "== C30: the rule that governs the engine is versioned and loads itself =="
# The defect pinned here: the governing test lived inside a path the repository ignores, so no
# gitignore-respecting search reached it and nothing in the flow read it. Its home is now the file every
# session in this project loads on its own, which is what satisfies its read trigger without a step.
MAN30="CLAUDE.md"
NG30="multi-agent portability"

# The whole test, not a summary of it: each key is a distinct load-bearing part. The verdict names the
# parts that are absent, because a single boolean would say the file is wrong without saying which half
# of the rule went missing — and half a governing rule reads as a complete one.
if [ -f "$MAN30" ]; then
  miss30=""
  for k in \
    "before proposing ANY change to the engine" \
    "demanding requirements discipline" \
    "Rigor is kept" \
    "Weight is cut" \
    "working alone forgets" \
    "Cost ladder" \
    "derived check" \
    "enterprise coordination" \
    "multi-agent portability"
  do
    grep -qF "$k" "$MAN30" || miss30="$miss30 [$k]"
  done
  [ -z "$miss30" ] \
    && ok "the root manual carries the governing test whole" \
    || bad "the root manual carries the governing test whole (absent:$miss30)"
else
  bad "the root manual carries the governing test whole ($MAN30 is not there)"
fi

# Asked of git, because the search that failed is the one that respects .gitignore. git grep answers for
# the index, so a file merely present on disk is still invisible to it — which is exactly the state this
# refuses. The verdict reads a count and never the pipeline's status: git grep exits 1 when it matches
# nothing, an ordinary answer, and a status-derived verdict cannot tell that from git failing to run.
#
# This file is excluded from the search, and the exclusion is the assertion. Naming the thesis in order
# to look for it puts it in a versioned file, so without this the guard passes on its own text — green
# from the moment it is written and forever after, whatever the project's manual says.
n30="$($GIT grep -lF "demanding requirements discipline" -- . 2>/dev/null \
        | grep -vxF -f <(for f30 in $SUITE_SRC; do printf '%s\n' "${f30#$ROOT/}"; done) | wc -l | tr -d ' ')"
case "${n30:-0}" in
  0) bad "the governing test is reachable by a versioned search (no versioned file carries the thesis)" ;;
  *) ok  "the governing test is reachable by a versioned search ($n30 file(s))" ;;
esac

# Scoped to the section the task names, not to the file. The thesis appearing anywhere in a long README
# would satisfy a file-wide grep while the front door itself still said nothing.
why30="$(sed -n '/^## Why ai-flow?/,/^## /p' README.md)"
if printf '%s' "$why30" | grep -q .; then
  miss30w=""
  for k in "demanding requirements discipline" "enterprise coordination" "multi-agent portability"; do
    printf '%s\n' "$why30" | grep -qF "$k" || miss30w="$miss30w [$k]"
  done
  [ -z "$miss30w" ] \
    && ok "the front door states the thesis and both refusals" \
    || bad "the front door states the thesis and both refusals (absent:$miss30w)"
else
  bad "the front door states the thesis and both refusals (no '## Why ai-flow?' section in README.md)"
fi

# Narrowed on purpose: the decision log is legitimately named by a directory tree and an installer note
# in files this task does not touch, so a repo-wide ban would go red on content that is not the defect.
# What is refused is a refusal that defers its reason to a file nobody else can open. Counted rather than
# piped into a verdict, and NOT for the reason this line used to give: `git grep` exits 1 when it matches
# nothing — an ordinary answer here, as this section says 29 lines above — so a status-derived verdict
# would spend one exit code that means two different things. The empty-input hazard named elsewhere in
# this file is a different thing and does not apply here twice over: it is the search tool a Claude Code
# session substitutes into its shell, not this platform's grep, and it is the `-v` cell alone, while the
# count below is a `-c`, which exits 1 on empty input on either tool.
cit30="$($GIT grep -nF "$NG30" -- "$MAN30" README.md 2>/dev/null | grep -cF "decisions-global")"
[ "${cit30:-0}" = 0 ] \
  && ok "no refusal defers its reason to the unversioned decision log" \
  || bad "no refusal defers its reason to the unversioned decision log ($cit30 line(s) cite it)"

# The positive half. A refusal stated without its reason is the one that gets re-argued a year later, so
# both public files have to carry it — asked of each separately, because one carrying it is not the two.
why30r=""
for f in "$MAN30" README.md; do
  if [ -f "$f" ]; then
    grep -qF "dilute" "$f" || why30r="$why30r [$f]"
  else
    why30r="$why30r [$f absent]"
  fi
done
[ -z "$why30r" ] \
  && ok "each refusal carries its reason" \
  || bad "each refusal carries its reason (missing in:$why30r)"

# The cost ladder is a rule for the maintainer, not a selling point, and it stays out of the front door
# deliberately. A negative criterion is vacuously true before the change lands, so this one was sized by
# inserting the phrase and watching this verdict go red, then restoring the file byte-exact against a
# hash taken first. Without that, a guard over an absence is green from birth and proves nothing.
lad30="$(grep -cE "Cost ladder|derived check" README.md)"
[ "${lad30:-0}" = 0 ] \
  && ok "the cost ladder stays out of the front door" \
  || bad "the cost ladder stays out of the front door ($lad30 line(s))"
