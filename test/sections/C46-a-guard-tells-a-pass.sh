echo "== C46: a guard tells a pass from a fail, and says so when it cannot run =="
# Each row here is written against BOTH answers: the fact as the engine states it,
# and the same region with the fact removed and the guard's own matched word planted in a neighbour.
# A row that only ever sees the input that made it necessary passes for a reason unrelated to the fact.
BLG46="global/protocols/backlog.md"

# The region extractors this section concludes from are asserted usable before any verdict: an extractor
# that returns nothing passes every pattern test made of it.
CLO46="$(awk '/^## Closing a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG46")"
OPN46="$(awk '/^## Opening a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG46")"
mv46() { printf '%s\n' "$1" | awk -v n="$2" '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==n' | tr '\n' ' ' | tr -s ' '; }

if [ -z "$CLO46" ] || [ -z "$OPN46" ]; then
  bad "the writers table's phase-field guard survives a reword of its own row (no section)"
  bad "the closing ceremony's move count is read, not assumed (no section)"
  bad "closing move 1 names the coordinator's commits as what the approval covers there (no section)"
  bad "the seed-and-prune move's stop on live work survives a reword of move 6 (no section)"
  bad "the opening ceremony names its single runner (no section)"
  bad "a section that cannot create its sandbox says so (no section)"
else

# Row 1 (A1) — the writers-table guard, applied to its own row with the fact removed and the matched
# word planted next door. The pattern is READ FROM THE HARNESS at run time, never restated here: a
# restated pattern tests this section's copy and goes green while the live guard stays blind.
# Located by the guard's own subject, never by an offset from a comment: a comment that gains a line
# moves the guard out of a fixed window, and the row then reports "not found" instead of a verdict.
PAT46A="$(suite_src | grep -m1 'During the phases' | grep -oE "grep -qiE '[^']*'" | sed "s/grep -qiE '//; s/'$//")"
ROW46="$(grep -E '^\| \*\*During the phases\*\*' "$BLG46" | head -1)"
if [ -z "$PAT46A" ] || [ -z "$ROW46" ]; then
  bad "the writers table's phase-field guard survives a reword of its own row (pattern or row not found)"
else
  # The decoy goes in the SAME cell the fact was removed from. Planted in a neighbouring cell it was
  # unreachable behind the pattern's own `[^|;]` fence, so the arm passed whatever the guard read — a
  # negative arm that cannot fail is not a second answer, it is the first one written twice.
  MUT46A="$(printf '%s' "$ROW46" \
    | sed 's/the phase command writes the phase when it enters one[^;]*; /a command is named here but writes nothing; /')"
  # The positive arm answers FIRST. Asking "did the mutation apply?" before "is the fact there?" reports
  # a protocol that lost the rule as a broken harness, and sends the reader to the wrong file.
  if ! printf '%s' "$ROW46" | grep -qiE "$PAT46A"; then
    bad "the writers table's phase-field guard survives a reword of its own row (the row no longer names the phase field's writer)"
  elif [ "$MUT46A" = "$ROW46" ] || ! printf '%s' "$MUT46A" | grep -q 'writes nothing'; then
    bad "the writers table's phase-field guard survives a reword of its own row (mutation did not apply)"
  elif ! printf '%s' "$MUT46A" | grep -qiE "$PAT46A"; then
    ok "the writers table's phase-field guard survives a reword of its own row"
  else
    bad "the writers table's phase-field guard survives a reword of its own row (matches a neighbour's word)"
  fi
fi

# Row 2 (A2) — the move count is read from the protocol, never enumerated in the check. A literal list
# stops at its last index, so a move appended after the roster row is never looked at.
NMOV46="$(printf '%s\n' "$CLO46" | grep -cE '^[0-9]+\. ')"
# Counted outside THIS BLOCK only, and the exclusion reopens at the next section header. Skipping to end
# of file instead — which the first form of this row did — exempts every section appended after this one,
# which is exactly where the next one gets written. And the input is proved readable before any verdict:
# `END{print n+0}` prints 0 for a file that cannot be read, and 0 is this row's value for a pass.
# Emits the harness OUTSIDE this block; the matching is left to grep. A dynamic regex handed to awk
# arrives with the shell's escaping already spent, so `\]` and `\$\(` reached it as bare `]` and `$(`
# and awk refused the program — after which the count was empty, `[ "$x" -ne 0 ]` errored, and this row
# fell through to its own `ok`. A row that passes because its extractor broke is the defect it audits.
RNG46() { suite_src_others; }
LINES46="$(suite_src | wc -l | tr -d ' ')"
OUT46="$(RNG46 | wc -l | tr -d ' ')"
# Any spelling of an assumed range, not the one the defect happened to wear: a literal list, a bare
# numeric bound, or a seq. Pinning the single string this task deleted leaves `while [ "$i" -le 7 ]`
# reinstating it with the row green.
# Scoped to the two loops that actually iterate ceremony moves, found by the call each makes rather than
# by a range spelling: a bare hunt for `for i in N N` also flags `for i in 1 2; do git push ...`, an
# ordinary fixture, and a row that fires on those is one the next person deletes. For each marker, the
# six lines above it must bound the loop on a value derived from the protocol — which refuses a literal
# list, a bare numeric bound and a `seq` alike, without naming any of them.
LOOPS46="$(RNG46 | grep -cE 'clohead "\$i"|dmove "\$i"' || true)"
BOUND46="$(RNG46 | grep -B6 -E 'clohead "\$i"|dmove "\$i"' | grep -cE 'while \[ "\$i" -le "\$nclo6?" \]' || true)"
DERIV46="$(RNG46 | grep -cE 'nclo6?="\$\(printf' || true)"
if [ -z "$LINES46" ] || [ "$LINES46" -lt 100 ] || [ -z "$OUT46" ] || [ "$OUT46" -lt 100 ] \
   || [ -z "$LOOPS46" ] || [ -z "$BOUND46" ] || [ -z "$DERIV46" ]; then
  bad "the closing ceremony's move count is read, not assumed (the harness could not be read: ${LINES46:-?} lines, ${OUT46:-?} outside this block)"
elif [ "$NMOV46" -lt 2 ]; then
  bad "the closing ceremony's move count is read, not assumed (only $NMOV46 moves extracted)"
elif [ "$LOOPS46" -lt 2 ]; then
  bad "the closing ceremony's move count is read, not assumed (only $LOOPS46 ceremony loops found, expected 2)"
elif [ "$BOUND46" -ne "$LOOPS46" ]; then
  bad "the closing ceremony's move count is read, not assumed ($((LOOPS46 - BOUND46)) ceremony loops assume their range)"
elif [ "$DERIV46" -lt 2 ]; then
  # Both converted loops must derive their bound from the protocol, not merely avoid the old spelling.
  bad "the closing ceremony's move count is read, not assumed (a ceremony loop does not derive its bound)"
else
  ok "the closing ceremony's move count is read, not assumed"
fi

# Row 3 (A3) — what the one approval in closing move 1 COVERS in the coordinator, which no assertion in
# this harness read before this section existed: the fact was deletable with the suite green. Two-armed,
# like rows 1 and 4 — the fact present must match, the fact removed with a decoy planted must not.
#
# The row used to name the coordinator's per-commit exception. That exception is gone: commits are free in
# every checkout now, and the same single approval covers the work wherever it was done. What survives is
# the half that mattered — move 1 must still say what it is approving in the coordinator, which is the
# task's own commits on the trunk, or the generalisation quietly drops the checkout it was written for.
M1_46="$(mv46 "$CLO46" 1)"
PAT46C='coordinator[^.]{0,80}trunk|trunk[^.]{0,80}coordinator'
if [ -z "$M1_46" ]; then
  bad "closing move 1 names the coordinator's commits as what the approval covers there (move not extracted)"
else
  # The mutation removes the fact and plants the matched word in a NEIGHBOURING SENTENCE — past a period,
  # which the pattern's own [^.] class cannot cross. A guard answered by mere co-presence of "coordinator"
  # and "trunk" anywhere in the move passes the mutant and is caught here, rather than years later by the
  # edit that hollows it.
  MUT46C="$(printf '%s' "$M1_46" \
    | sed "s/, the task's own commits on the trunk where it was worked in the coordinator//" \
    | sed 's/in the coordinator as much as in a front\./in the coordinator as much as in a front. The trunk is no different./')"
  if ! printf '%s' "$M1_46" | grep -qiE "$PAT46C"; then
    bad "closing move 1 names the coordinator's commits as what the approval covers there (absent from the protocol)"
  elif [ "$MUT46C" = "$M1_46" ] || ! printf '%s' "$MUT46C" | grep -q 'no different'; then
    bad "closing move 1 names the coordinator's commits as what the approval covers there (mutation did not apply)"
  elif ! printf '%s' "$MUT46C" | grep -qiE "$PAT46C"; then
    ok "closing move 1 names the coordinator's commits as what the approval covers there"
  else
    bad "closing move 1 names the coordinator's commits as what the approval covers there (absent, or matched from a neighbour)"
  fi
fi

# Row 4 (A4) — the move-6 anchor, same shape as row 1: pattern read from the harness, applied to move 6
# with the live-work stop removed and a word naming a refusal planted in a neighbouring sentence.
PAT46B="$(suite_src | grep -m1 'no-stop-on-live-work' | grep -oE "grep -qiE '[^']*'" | sed "s/grep -qiE '//; s/'$//")"
M6_46="$(mv46 "$OPN46" 6)"
if [ -z "$PAT46B" ] || [ -z "$M6_46" ]; then
  bad "the seed-and-prune move's stop on live work survives a reword of move 6 (pattern or move not found)"
else
  MUT46B="$(printf '%s' "$M6_46" \
    | sed 's/ Where those papers were written \*after\* the coordinator[^.]*\.//' \
    | sed 's/The ledger stays with the coordinator/The ledger refuses to travel and stays with the coordinator/')"
  if ! printf '%s' "$M6_46" | grep -qiE "$PAT46B"; then
    bad "the seed-and-prune move's stop on live work survives a reword of move 6 (the move no longer states the stop)"
  elif [ "$MUT46B" = "$M6_46" ] || ! printf '%s' "$MUT46B" | grep -q 'refuses to travel'; then
    bad "the seed-and-prune move's stop on live work survives a reword of move 6 (mutation did not apply)"
  elif ! printf '%s' "$MUT46B" | grep -qiE "$PAT46B"; then
    ok "the seed-and-prune move's stop on live work survives a reword of move 6"
  else
    bad "the seed-and-prune move's stop on live work survives a reword of move 6 (matches a neighbour's word)"
  fi
fi

# Row 5 (A5) — the opening ceremony's single runner. Its closing twin has been pinned since the sheet
# rules were written; this one was asserted nowhere, so a meaning-preserving deletion cost zero failing
# assertions. Two-armed, as row 3.
PRE46="$(printf '%s\n' "$OPN46" | awk '/^1\. /{exit} {print}' | tr '\n' ' ' | tr -s ' ')"
PAT46D='only the coordinator runs it'
if [ -z "$PRE46" ]; then
  bad "the opening ceremony names its single runner (preamble not extracted)"
else
  MUT46D="$(printf '%s' "$PRE46" \
    | sed 's/ Only the coordinator runs it\.//' \
    | sed 's/ends in a verdict/ends in a verdict the coordinator records/')"
  if ! printf '%s' "$PRE46" | grep -qiE "$PAT46D"; then
    bad "the opening ceremony names its single runner (absent from the protocol)"
  elif [ "$MUT46D" = "$PRE46" ] || ! printf '%s' "$MUT46D" | grep -q 'verdict the coordinator records'; then
    bad "the opening ceremony names its single runner (mutation did not apply)"
  elif ! printf '%s' "$MUT46D" | grep -qiE "$PAT46D"; then
    ok "the opening ceremony names its single runner"
  else
    bad "the opening ceremony names its single runner (absent, or matched from a neighbour)"
  fi
fi

# Row 6 (A6) — a sandbox that cannot be created is named as the reason. The engine already owns the
# idiom at ten sites; the count is of call sites that reach for a sandbox without it.
# The first form of this row counted a stderr REDIRECTION and called it a diagnostic, and the nineteen
# converted sites carry no `mktemp` text at all, so the entry point this task built was invisible to the
# row standing for it: deleting a caller's `|| fatal` reinstated the whole defect with the row green.
# What is policed now is the entry point and the two properties that make it work.
BOX46="$(grep -o -E '\$\(mkbox\)' $SUITE_SRC 2>/dev/null | wc -l | tr -d ' ')"
GRD46="$(grep -o -E '\$\(mkbox\)" \|\| fatal ' $SUITE_SRC 2>/dev/null | wc -l | tr -d ' ')"
RAW46="$(grep -o -E '\$\(mktemp -d' $SUITE_SRC 2>/dev/null | wc -l | tr -d ' ')"
RGD46="$(grep -o -E '\$\(mktemp -d 2>/dev/null' $SUITE_SRC 2>/dev/null | wc -l | tr -d ' ')"
if [ "$BOX46" -eq 0 ]; then
  bad "a section that cannot create its sandbox says so (no sandbox call sites found — extractor is wrong)"
elif [ "$BOX46" -ne "$GRD46" ]; then
  bad "a section that cannot create its sandbox says so ($((BOX46 - GRD46)) call sites do not stop on failure)"
elif [ "$((RAW46 - RGD46))" -ne 0 ]; then
  bad "a section that cannot create its sandbox says so ($((RAW46 - RGD46)) sites bypass the helper entirely)"
elif ! grep -qE '^\s*\[ -n "\$d" \] && \[ -d "\$d" \] \|\| return 1' $SUITE_SRC; then
  # The helper must RETURN, never exit: a command substitution runs in a subshell, so an exit inside it
  # ends only that subshell and leaves the caller running with the empty path this exists to prevent.
  bad "a section that cannot create its sandbox says so (the helper does not return a status to its caller)"
elif ! printf '%s' "$(awk '/^fatal\(\) \{/{f=1} f{print} f && /^\}/{exit}' $SUITE_SRC)" | grep -q 'bad "'; then
  # And the report must go through the run's own accounting, in the parent — not an open-coded echo.
  bad "a section that cannot create its sandbox says so (the failure is reported outside the run accounting)"
else
  ok "a section that cannot create its sandbox says so"
fi

fi
