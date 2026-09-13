# C38 — a guard whose signal only its own fixtures produce is a guard over nothing.
# The signal here was taken from three narratives a real ledger had accumulated, not from the engine's
# prose: no ceremony emits either signal and no move owns the notes section, so the guard is a backstop
# over what an operator writes, never a check on an output the engine promises.
# Generated in the Conform phase from understand.md's Verifiable Criteria A1-A6.
#
# The ledger guardian searched for three literal phrases (`shipped + archived`, `CLOSED (party)`, `shipped (`)
# that occur NOWHERE in this engine except the hook itself and the fixtures written to satisfy it — so the
# only producer of the detected input was the test that tests the detector. Meanwhile the live roster held
# three closed-epic narratives, which is precisely what its own invariant forbids, and the hook counted 0.
#
# Two rows here assert SILENCE and are green from the start, which is stated rather than hidden: A2 and A4
# cannot be red at Conform, because today's detector is silent on everything. What sizes them is the
# mutation recorded in the baseline manifest — remove the section scoping and A3 must go red, remove the
# near-miss discrimination and A4 must go red. Their green is provisional until that is shown.
#
# A3 IS red at Conform, and honestly so: its fixture is a completed-quick-task row reading
# "first release shipped (v1)", which the phrase list matches — a real false positive of the code being
# replaced, not a contrivance. The sanctioned table must never be counted.
#
# Every verdict is derived from an exact exit code or a COUNT, never from a `grep -v` inside an `if`. The
# hazard is NOT BSD grep, which exits 1 on empty input: it is the search tool a session substitutes into
# its shell, which exits 0 — so the shape is safe here and unsafe in a command an agent types.
echo "== C38: the ledger guardian judges the narrative a ledger accumulates =="
HK38="global/hooks/check-state-size.sh"
BLG38="global/protocols/backlog.md"

if ! T38="$(mkbox)" || [ ! -d "$T38" ]; then
  bad "a closed-epic narrative in the notes blocks the turn close (no sandbox: mktemp -d failed)"
  bad "a roster with nothing but its own notes passes (no sandbox: mktemp -d failed)"
  bad "the completed-quick-task table is never counted as a violation (no sandbox: mktemp -d failed)"
  bad "a note naming another ledger's still-open epic does not fire (no sandbox: mktemp -d failed)"
  bad "the coordinator blocks and the linked worktree stays silent on the same file (no sandbox: mktemp -d failed)"
elif [ ! -r "$HK38" ] || [ ! -s "$HK38" ] || [ ! -r "$BLG38" ] || [ ! -s "$BLG38" ]; then
  bad "a closed-epic narrative in the notes blocks the turn close (hook or protocol unreadable)"
  bad "a roster with nothing but its own notes passes (hook or protocol unreadable)"
  bad "the completed-quick-task table is never counted as a violation (hook or protocol unreadable)"
  bad "a note naming another ledger's still-open epic does not fire (hook or protocol unreadable)"
  bad "the coordinator blocks and the linked worktree stays silent on the same file (hook or protocol unreadable)"
  rm -rf "$T38"   # mktemp had already succeeded on this branch; without this the sandbox leaks
else
  # A state file a reader would recognise as a real ledger: the roster, the notes section, and the
  # sanctioned completed-quick-task table. The old fixture was the bare string the phrase list matched,
  # which is why five rows could keep passing while proving nothing about detection.
  # $4 places the narrative: `notes` (default) inside the notes section, `tail` appended after the
  # quick-task table, `subhead` under a `### ` heading after that table. The last two exist because a
  # region-based exemption was blind to both and shipped that way until Verify reproduced it: the
  # position of the violation is a parameter, never an assumption.
  # $5 is an extra roster row, for the sanctioned table the guard must not read.
  mkstate38() {  # $1 = dir, $2 = notes body ("" for none), $3 = quick-task row, $4 = position, $5 = extra roster row
    mkdir -p "$1/.ai-flow"
    {
      printf '# Session State\n\n## Workstreams\n\n'
      printf '| Workstream | Checkout | Task | Epic | Areas | Tool | Opened |\n'
      printf '|---|---|---|---|---|---|---|\n'
      printf '| coordinator | . | T-100 | E-009 | auth | - | 2026-08-01 |\n'
      [ -n "${5:-}" ] && printf '%s\n' "${5:-}"
      printf '\n## Notes\n\nCross-workstream context only - nothing that belongs to a single task.\n\n'
      [ -n "${2:-}" ] && [ "${4:-notes}" = notes ] && printf '%s\n\n' "$2"
      printf '## Quick Tasks Completed\n\n| Date | Description | Commit |\n|------|-------------|--------|\n'
      printf '%s\n' "$3"
      [ -n "${2:-}" ] && [ "${4:-notes}" = tail ] && printf '\n%s\n' "$2"
      [ -n "${2:-}" ] && [ "${4:-notes}" = subhead ] && printf '\n### Leftovers\n\n%s\n' "$2"
    } > "$1/.ai-flow/STATE.md"
    printf '# Backlog\n' > "$1/.ai-flow/BACKLOG.md"
  }

  # Carries BOTH signals: a close declaration beside an epic identifier, and a path into the archive.
  VIOL38='**Epic E-007 (payments overhaul) CLOSED 2026-07-30.** Sealed decisions and per-task detail: `archive/E-007-payments.md`.'
  # One signal each, so neither alternative of the pattern can be deleted with every row still green:
  # every fixture carrying both at once is what made half the detector removable undetected.
  ONLYC38='**Epic E-007 (payments overhaul) CLOSED 2026-07-30.** Sealed decisions live in the epic file.'
  ONLYA38='**Epic E-007, the payments overhaul.** Sealed decisions: `archive/E-007-payments.md`.'
  # The near miss, taken from the live roster: it says "not archived", names an epic, declares no closure
  # and cites no archive path. A naive search for "archiv" takes it; the discriminator must not.
  NEAR38='Still open in the other project (unrelated, tracked there): epic E-124 is task-complete but not archived.'
  QOK38='| 2026-07-02 | narrowed the refutation to HIGH | `abc1234` |'
  # A legitimate quick-task description that happens to contain one of the retired phrases.
  # Carries BOTH a retired phrase (which is why this row is red at Conform, against the code being
  # replaced) and a live signal — so once the phrase list is gone the row still discriminates: drop the
  # sanctioned table from the scoping and this fixture fires.
  QBAD38='| 2026-07-02 | first release shipped (v1) after epic E-007 CLOSED | `abc1234` |'

  # A1 — the violation the invariant names must stop the turn.
  P38A="$T38/a"; mkproj "$P38A" main >/dev/null 2>&1; mkstate38 "$P38A" "$VIOL38" "$QOK38"
  ( cd "$P38A" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); r38a=$?
  [ "$r38a" = 2 ] \
    && ok "a closed-epic narrative in the notes blocks the turn close" \
    || bad "a closed-epic narrative in the notes blocks the turn close (exit $r38a)"

  # A2 — the other direction. Green at Conform and provisional: see the manifest's mutation.
  P38B="$T38/b"; mkproj "$P38B" main >/dev/null 2>&1; mkstate38 "$P38B" "" "$QOK38"
  ( cd "$P38B" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); r38b=$?
  [ "$r38b" = 0 ] \
    && ok "a roster with nothing but its own notes passes" \
    || bad "a roster with nothing but its own notes passes (exit $r38b)"

  # A3 — the sanctioned table is outside what the guard polices, whatever its rows happen to say.
  P38C="$T38/c"; mkproj "$P38C" main >/dev/null 2>&1; mkstate38 "$P38C" "" "$QBAD38"
  ( cd "$P38C" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); r38c=$?
  [ "$r38c" = 0 ] \
    && ok "the completed-quick-task table is never counted as a violation" \
    || bad "the completed-quick-task table is never counted as a violation (exit $r38c)"

  # A4 — the near miss. Cross-front context is what the notes section is FOR.
  P38D="$T38/d"; mkproj "$P38D" main >/dev/null 2>&1; mkstate38 "$P38D" "$NEAR38" "$QOK38"
  ( cd "$P38D" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); r38d=$?
  [ "$r38d" = 0 ] \
    && ok "a note naming another ledger's still-open epic does not fire" \
    || bad "a note naming another ledger's still-open epic does not fire (exit $r38d)"

  # A5 — the scoping the five older rows exist for, re-asserted over a file that TRIGGERS. Both legs, so
  # neither can carry the other: a silent worktree proves nothing while the coordinator is silent too.
  P38E="$T38/e"; mkproj "$P38E" main >/dev/null 2>&1; mkstate38 "$P38E" "$VIOL38" "$QOK38"
  mkdir -p "$P38E/sub"
  W38E="$T38/e-wt"; $GIT -C "$P38E" worktree add -q -b wt38 "$W38E" >/dev/null 2>&1
  cp -R "$P38E/.ai-flow" "$W38E/.ai-flow"
  r38e=""
  ( cd "$P38E/sub" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); x38=$?
  [ "$x38" = 2 ] || r38e="$r38e [a subdirectory of the coordinator did not block: exit $x38]"
  ( cd "$W38E" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); x38=$?
  [ "$x38" = 0 ] || r38e="$r38e [the linked worktree was judged on the coordinator's ledger: exit $x38]"
  [ -z "$r38e" ] \
    && ok "the coordinator blocks and the linked worktree stays silent on the same file" \
    || bad "the coordinator blocks and the linked worktree stays silent on the same file:$r38e"

  # A7/A8 — the position of the narrative is not the guard's business. Both were exit 0 under the
  # region-based exemption that shipped into Verify: the quick-task section is LAST in both shipped roster
  # shapes, so exempting to the next `## ` heading exempted to end of file, and `^## ` never matched `### `.
  for pos38 in tail subhead; do
    P38F="$T38/f-$pos38"; mkproj "$P38F" main >/dev/null 2>&1
    mkstate38 "$P38F" "$VIOL38" "$QOK38" "$pos38"
    ( cd "$P38F" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); r38f=$?
    [ "$r38f" = 2 ] \
      && ok "a closed-epic narrative is caught with the narrative in the $pos38 position" \
      || bad "a closed-epic narrative is caught with the narrative in the $pos38 position (exit $r38f)"
  done

  # A9/A10 — each signal alone. Deleting either alternative of the pattern must now cost a row.
  P38G="$T38/g"; mkproj "$P38G" main >/dev/null 2>&1; mkstate38 "$P38G" "$ONLYC38" "$QOK38"
  ( cd "$P38G" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); r38g=$?
  [ "$r38g" = 2 ] \
    && ok "a closure declared beside an identifier is caught with no archive path present" \
    || bad "a closure declared beside an identifier is caught with no archive path present (exit $r38g)"

  P38H="$T38/h"; mkproj "$P38H" main >/dev/null 2>&1; mkstate38 "$P38H" "$ONLYA38" "$QOK38"
  ( cd "$P38H" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); r38h=$?
  [ "$r38h" = 2 ] \
    && ok "a path into the archive is caught with no closure declared" \
    || bad "a path into the archive is caught with no closure declared (exit $r38h)"

  # A12 — the one state file guaranteed to exist in every adopting project. Every other fixture here is a
  # hand-authored lookalike, and a false positive on the shipped template would block the turn close in
  # every adopting project on day one. No fixture to write: the artifact is in the repository.
  P38T="$T38/t"; mkproj "$P38T" main >/dev/null 2>&1; mkdir -p "$P38T/.ai-flow"
  cp "$ROOT/template/.ai-flow/STATE.md" "$P38T/.ai-flow/STATE.md"
  printf '# Backlog\n' > "$P38T/.ai-flow/BACKLOG.md"
  ( cd "$P38T" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); r38t=$?
  [ "$r38t" = 0 ] \
    && ok "the state file the engine ships passes its own ledger guardian" \
    || bad "the state file the engine ships passes its own ledger guardian (exit $r38t)"
  # And the same file with a closed-epic narrative appended is caught — the pair, so a guard that has gone
  # silent everywhere cannot answer for the row above.
  printf '\n%s\n' "$VIOL38" >> "$P38T/.ai-flow/STATE.md"
  ( cd "$P38T" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); r38u=$?
  [ "$r38u" = 2 ] \
    && ok "the shipped state file with a closed-epic narrative appended is caught" \
    || bad "the shipped state file with a closed-epic narrative appended is caught (exit $r38u)"

  # A11 — the roster is the other sanctioned section, and an ordinary area declaration in this very
  # engine names a path inside the archive. A guard that reads it blocks the turn on the line the
  # invariant sanctions, with a message telling the operator to trim the roster it just flagged.
  P38I="$T38/i"; mkproj "$P38I" main >/dev/null 2>&1
  mkstate38 "$P38I" "" "$QOK38" notes '| ws-b | ../p-wt-b | you/t-101-x | T-101 | E-009 | archive/EPICS.md, protocols | git | 2026-08-02 |'
  ( cd "$P38I" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); r38i=$?
  [ "$r38i" = 0 ] \
    && ok "a front declaring an area inside the archive does not make the roster a violation" \
    || bad "a front declaring an area inside the archive does not make the roster a violation (exit $r38i)"

  rm -rf "$T38"
fi

# A6 — the invariant and the template it ships must not disagree. Pinned by the POSITIVE form the rule
# has to carry (it names the section it exempts), never by the absence of the wording it used to have:
# a rule reworded into a different unqualified prohibition would pass a check that only knew the old words.
INV38="$(awk '/^### Invariants \(always true\)/{f=1;next} f && /^#{2,3} /{exit} f' "$BLG38" 2>/dev/null)"
# The invariant is a bullet, not a line: it wraps across several physical lines, and reading only the
# first one asserts about where the typography falls rather than about what the rule says. The region is
# the bullet — from the entry naming the shared state file to the next entry or the end — joined into one
# line before anything is asserted about it, with runs of whitespace squeezed — joining alone is not
# normalising: the continuation indent survives the join, so a phrase broken across two lines comes back
# with two spaces in the middle and a single-spaced pattern misses it. Scoped to that bullet and not to the
# whole block, so a neighbouring invariant carrying the word cannot answer for this one.
S38="$(printf '%s\n' "$INV38" | awk '
  /^- / { if (f) exit; if ($0 ~ /STATE\.md/) { f=1; print; next } ; next }
  f { print }
' | tr '\n' ' ' | tr -s ' ')"
a38=""
[ -n "$INV38" ] || a38="$a38 [the invariants section is absent or empty]"
[ -n "$S38" ]   || a38="$a38 [no invariant names the shared state file]"
printf '%s' "$S38" | grep -q 'Quick Tasks Completed' || a38="$a38 [the invariant does not name the record it exempts]"
# The exemption alone is half a rule: an invariant that named the exempt record and forbade nothing would
# satisfy a check that only looked for the exemption. Both halves, or the narrowing could be widened into a
# permission with this row green.
printf '%s' "$S38" | grep -qE 'no historical narrative|no history' || a38="$a38 [the invariant no longer forbids narrative outside it]"
# O3's other half: the remedy must say where the narrative belongs, not only where it must not go.
REM38="$(grep -i 'trim STATE.md down to' "$HK38" 2>/dev/null)"
printf '%s' "$REM38" | grep -q 'archive/' || a38="$a38 [the remedy does not name the archive as the destination]"
[ -z "$a38" ] \
  && ok "the roster invariant forbids narrative and names the record it exempts, and the remedy names the archive" \
  || bad "the roster invariant forbids narrative and names the record it exempts, and the remedy names the archive:$a38"
