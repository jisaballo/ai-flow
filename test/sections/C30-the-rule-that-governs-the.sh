echo "== C30: the rule that governs the engine is versioned and loads itself =="
# The defect pinned here: the governing test lived inside a path the repository ignores, so no
# gitignore-respecting search reached it and nothing in the flow read it. Its home is now the file every
# session in this project loads on its own, which is what satisfies its read trigger without a step.
MAN30="AGENTS.md"
NG30="coordination as an end in itself"

# The whole test, not a summary of it: each key is a distinct load-bearing part. The verdict names the
# parts that are absent, because a single boolean would say the file is wrong without saying which half
# of the rule went missing — and half a governing rule reads as a complete one.
if [ -f "$MAN30" ]; then
  miss30=""
  for k in \
    "before proposing any change to the engine" \
    "Quality is the objective" \
    "Cost and speed are the budgets" \
    "The discipline is the method" \
    "must outlive whoever is running it" \
    "Coordination is not an end in itself"
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
n30="$($GIT grep -lF "maintained and scaled over time" -- . 2>/dev/null \
        | grep -vxF -f <(for f30 in $SUITE_SRC; do printf '%s\n' "${f30#$ROOT/}"; done) | wc -l | tr -d ' ')"
case "${n30:-0}" in
  0) bad "the governing test is reachable by a versioned search (no versioned file carries the thesis)" ;;
  *) ok  "the governing test is reachable by a versioned search ($n30 file(s))" ;;
esac

# Three legs left with the rewrite that orphaned them: each read a sentence of the front door or of
# the manual, and re-pointing one at the sentence the same change had just written would have been a
# fresh assertion with no oracle — which is what the recurrence guard refused when it was tried. What
# stays is the pair with a subject outside the prose: the manual is present, and the purpose it states
# is reachable by a search that respects .gitignore.
