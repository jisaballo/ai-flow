echo "== C45: a guard proves its input usable before it concludes from it =="
# This section is the only one that chmods a directory to 000, and a tree that cannot be entered defeats
# `rm -rf` (EACCES on traversal), so an interrupt inside a two-line window would leave an undeletable
# directory in TMPDIR. That is why the one teardown in the preamble restores modes before removing --
# this block is the reason that `chmod` is there.
T45=""; T45R=""
# Conformance rows for the fail-open class: a guard whose input cannot be read must refuse and name the
# file, while an input that is merely ABSENT keeps the silence each guard documents as designed. The two
# directions are asserted together on purpose — this class was found four times as a guard nothing
# exercised, and a refusal row with no control beside it cannot tell a fixed guard from one that now
# refuses everything.
GRD45="$HK/check-state-size.sh"

# chmod 000 is the entire method here and it does not work for a superuser: root reads a mode-000 file
# regardless, so every row below would report the fail-open repaired while measuring nothing. Probed
# once against a real file rather than inferred from a user id, because the capability is what matters
# and a container may deny it to a non-root user too.
UNREAD45=1
if PRB45="$(mktemp 2>/dev/null)"; then
  printf 'x\n' > "$PRB45"; chmod 000 "$PRB45"
  cat "$PRB45" >/dev/null 2>&1 && UNREAD45=0
  chmod 644 "$PRB45" 2>/dev/null; rm -f "$PRB45"
else
  UNREAD45=0
fi

# A roster whose only non-table lines are its own headings: readable, and carrying no closure narrative.
# It is the control for the unreadable rows — the guard must pass it — and it is also what makes those
# rows mean something, since a guard that refused everything would fail here.
ros45() {
  printf '# Session State\n\n## Workstreams\n\n'
  printf '| Workstream | Checkout | Task | Epic | Areas | Tool | Opened |\n'
  printf '|---|---|---|---|---|---|---|\n'
  printf '| coordinator | . | T-100 | E-009 | auth | - | 2026-08-01 |\n'
}
# The one thing the invariant forbids, placed in the notes.
vio45() { ros45; printf '\n## Notes\n\n**Epic E-007 CLOSED 2026-07-30.** Sealed: `archive/E-007.md`.\n'; }
# Session-close changelog entries, the shape the guard counts.
log45() { i=0; while [ "$i" -lt "$1" ]; do printf '> 2026-0%s-01 session close\n' "$((i+1))"; i=$((i+1)); done; }

if ! T45="$(mkbox)" || [ ! -d "$T45" ]; then
  bad "an unreadable STATE.md is refused, not reported clean (no sandbox: mktemp -d failed)"
  bad "an unreadable BACKLOG.md is refused, not reported clean (no sandbox: mktemp -d failed)"
  bad "a readable roster with no closed-work narrative still passes (no sandbox: mktemp -d failed)"
  bad "a backlog over its size budget is refused (no sandbox: mktemp -d failed)"
  bad "a backlog over its changelog ceiling is refused (no sandbox: mktemp -d failed)"
  bad "a backlog within both budgets still passes (no sandbox: mktemp -d failed)"
  bad "an unreadable recorded clone path is refused, not reported clean (no sandbox: mktemp -d failed)"
  bad "no recorded clone path stays silent (no sandbox: mktemp -d failed)"
elif [ ! -r "$GRD45" ] || [ ! -s "$GRD45" ]; then
  bad "an unreadable STATE.md is refused, not reported clean (the guard is unreadable)"
  bad "an unreadable BACKLOG.md is refused, not reported clean (the guard is unreadable)"
  bad "a readable roster with no closed-work narrative still passes (the guard is unreadable)"
  bad "a backlog over its size budget is refused (the guard is unreadable)"
  bad "a backlog over its changelog ceiling is refused (the guard is unreadable)"
  bad "a backlog within both budgets still passes (the guard is unreadable)"
  bad "an unreadable recorded clone path is refused, not reported clean (the guard is unreadable)"
  bad "no recorded clone path stays silent (the guard is unreadable)"
  rm -rf "$T45"
else

# --- A1: the ledger's state half, unreadable ---------------------------------
P45A="$T45/a"; mkproj "$P45A" main
mkdir -p "$P45A/.ai-flow"; vio45 > "$P45A/.ai-flow/STATE.md"; printf '# Backlog\n' > "$P45A/.ai-flow/BACKLOG.md"
a1_45=""
if [ "$UNREAD45" = 0 ]; then
  echo "  [skip] 6 refusal rows: unreadable STATE.md / BACKLOG.md / clone path / state sheet / ledger"
  echo "         directory / ledger-with-no-sheet, plus the search-vs-read bit. This user reads a"
  echo "         mode-000 file, so the fixture cannot be built and the fail-open is NOT measured here."
else
  chmod 000 "$P45A/.ai-flow/STATE.md"
  out45="$( cd "$P45A" && bash "$GRD45" 2>&1 )"; rc45=$?
  chmod 644 "$P45A/.ai-flow/STATE.md"
  [ "$rc45" = 2 ] || a1_45="$a1_45 [an unreadable STATE.md did not refuse (exit $rc45)]"
  case "$out45" in *STATE.md*) : ;; *) a1_45="$a1_45 [the refusal does not name STATE.md]" ;; esac
  # D4: the same fault one level up. With the directory unreadable the ledger files test as ABSENT, which
  # is the guard's designed no-op for a project that has no .ai-flow at all -- so the fail-open survives
  # the file-level repair unless the directory is told from a missing one.
  chmod 000 "$P45A/.ai-flow"
  outd45="$( cd "$P45A" && bash "$GRD45" 2>&1 )"; rcd45=$?
  chmod 745 "$P45A/.ai-flow"
  [ "$rcd45" = 2 ] || a1_45="$a1_45 [an unreadable .ai-flow directory did not refuse (exit $rcd45)]"
  case "$outd45" in *.ai-flow*) : ;; *) a1_45="$a1_45 [the refusal does not name the directory]" ;; esac
  [ -z "$a1_45" ] && ok "an unreadable STATE.md is refused, not reported clean" \
                  || bad "an unreadable STATE.md is refused, not reported clean:$a1_45"
fi

# --- the permission bit the directory gate turns on --------------------------
# Mode 000 (above) removes BOTH bits, so it passes whichever one the gate tests -- which is how an
# `-r` gate shipped while the fail-open it closes survived one bit away. These two rows separate them.
# A guard that opens known paths needs SEARCH on their directories; it needs READ only to list one.
if [ "$UNREAD45" = 1 ]; then
  ab_45=""
  # Listable, not searchable: `-r` is true, so an `-r` gate says nothing -- yet neither `-f` can stat its
  # file, both blocks skip, and the guard exits 0 over a roster that violates the invariant.
  P45J="$T45/j"; mkproj "$P45J" main
  mkdir -p "$P45J/.ai-flow"; vio45 > "$P45J/.ai-flow/STATE.md"; printf '# Backlog\n' > "$P45J/.ai-flow/BACKLOG.md"
  chmod 400 "$P45J/.ai-flow"
  ( cd "$P45J" && bash "$GRD45" >/dev/null 2>&1 ); rcj45=$?
  chmod 745 "$P45J/.ai-flow"
  [ "$rcj45" = 2 ] || ab_45="$ab_45 [a listable-but-not-searchable ledger directory did not refuse (exit $rcj45)]"
  # Searchable, not listable: every file is read by name and a real verdict is available, so refusing
  # here is a false report standing in front of a true one.
  P45K="$T45/k"; mkproj "$P45K" main
  mkdir -p "$P45K/.ai-flow"; ros45 > "$P45K/.ai-flow/STATE.md"; printf '# Backlog\n' > "$P45K/.ai-flow/BACKLOG.md"
  chmod 100 "$P45K/.ai-flow"
  ( cd "$P45K" && bash "$GRD45" >/dev/null 2>&1 ); rck45=$?
  chmod 745 "$P45K/.ai-flow"
  [ "$rck45" = 0 ] || ab_45="$ab_45 [a searchable ledger directory was refused though every file reads (exit $rck45)]"
  [ -z "$ab_45" ] && ok "the ledger directory gate turns on search, not read" \
                  || bad "the ledger directory gate turns on search, not read:$ab_45"
fi

# --- A2: the ledger's backlog half, unreadable -------------------------------
P45B="$T45/b"; mkproj "$P45B" main
mkdir -p "$P45B/.ai-flow"; ros45 > "$P45B/.ai-flow/STATE.md"; nlines 400 > "$P45B/.ai-flow/BACKLOG.md"
if [ "$UNREAD45" = 1 ]; then
  a2_45=""
  chmod 000 "$P45B/.ai-flow/BACKLOG.md"
  out45="$( cd "$P45B" && bash "$GRD45" 2>&1 )"; rc45=$?
  chmod 644 "$P45B/.ai-flow/BACKLOG.md"
  [ "$rc45" = 2 ] || a2_45="$a2_45 [an unreadable BACKLOG.md did not refuse (exit $rc45)]"
  case "$out45" in *BACKLOG.md*) : ;; *) a2_45="$a2_45 [the refusal does not name BACKLOG.md]" ;; esac
  # The shape it fails in today: both counts yield the empty string and `[ "" -gt N ]` raises, so the two
  # checks are SKIPPED rather than mis-answered. A repair that merely silenced the error would leave the
  # verdict exactly as wrong, so the diagnostic must not be what the row keys on.
  case "$out45" in *"integer expression expected"*) a2_45="$a2_45 [the counts still run on a failed read]" ;; esac
  [ -z "$a2_45" ] && ok "an unreadable BACKLOG.md is refused, not reported clean" \
                  || bad "an unreadable BACKLOG.md is refused, not reported clean:$a2_45"
fi

# --- A3: the readable control for A1 -----------------------------------------
P45C="$T45/c"; mkproj "$P45C" main
mkdir -p "$P45C/.ai-flow"; ros45 > "$P45C/.ai-flow/STATE.md"; printf '# Backlog\n' > "$P45C/.ai-flow/BACKLOG.md"
( cd "$P45C" && bash "$GRD45" >/dev/null 2>&1 ); rc45=$?
[ "$rc45" = 0 ] && ok "a readable roster with no closed-work narrative still passes" \
                || bad "a readable roster with no closed-work narrative still passes (exit $rc45)"

# --- A4: the size budget, exercised for the first time ------------------------
# Retargeted from lines to words, and from a refusal to a note. The budget's unit changed because lines
# stopped discriminating — one entry is one line however long it is — and its breach stopped refusing
# because its remedy is not bounded: the largest cause of it has no prune at all. What this row keeps is
# its own claim, that a ledger over the budget does not pass in silence; C55 holds the channel, the two
# thresholds and the once-per-session mark. The fixture is the filler alone, with no heading, so its count
# is exactly 8,001 — one word over. The boundary itself is C55 A3's row, not this one's.
# The payload DECLARES the note's event, which the refusal rows around it deliberately do not: the note
# half runs at `UserPromptSubmit` and the refusing half at `Stop`, so a row measuring the note over an
# empty payload measures the other half and reports the note missing when it is merely elsewhere.
UPS45='{"hook_event_name":"UserPromptSubmit"}'
P45D="$T45/d"; mkproj "$P45D" main
mkdir -p "$P45D/.ai-flow"; ros45 > "$P45D/.ai-flow/STATE.md"; nwords 8001 > "$P45D/.ai-flow/BACKLOG.md"
out45="$( cd "$P45D" && printf '%s' "$UPS45" | bash "$GRD45" 2>&1 )"; rc45=$?
a4_45=""
[ "$rc45" = 0 ] || a4_45="$a4_45 [a backlog over the word budget did not let the turn close (exit $rc45)]"
case "$out45" in *"8001 words"*) : ;; *) a4_45="$a4_45 [the note does not state the measured size]" ;; esac
[ -z "$a4_45" ] && ok "a backlog over its size budget is noted" \
                || bad "a backlog over its size budget is noted:$a4_45"

# --- A5: the changelog ceiling, exercised for the first time -------------------
P45E="$T45/e"; mkproj "$P45E" main
mkdir -p "$P45E/.ai-flow"; ros45 > "$P45E/.ai-flow/STATE.md"
{ printf '# Backlog\n\n'; log45 5; } > "$P45E/.ai-flow/BACKLOG.md"
out45="$( cd "$P45E" && bash "$GRD45" 2>&1 )"; rc45=$?
a5_45=""
[ "$rc45" = 2 ] || a5_45="$a5_45 [5 changelog entries did not refuse (exit $rc45)]"
case "$out45" in *"5 session-close"*) : ;; *) a5_45="$a5_45 [the refusal does not state the measured count]" ;; esac
[ -z "$a5_45" ] && ok "a backlog over its changelog ceiling is refused" \
                || bad "a backlog over its changelog ceiling is refused:$a5_45"

# --- A6: the readable control for A4 and A5 -----------------------------------
P45F="$T45/f"; mkproj "$P45F" main
mkdir -p "$P45F/.ai-flow"; ros45 > "$P45F/.ai-flow/STATE.md"
{ printf '# Backlog\n\n'; nlines 100; log45 3; } > "$P45F/.ai-flow/BACKLOG.md"
( cd "$P45F" && bash "$GRD45" >/dev/null 2>&1 ); rc45=$?
[ "$rc45" = 0 ] && ok "a backlog within both budgets still passes" \
                || bad "a backlog within both budgets still passes (exit $rc45)"

# --- the case that makes the status check mean anything -----------------------
# A3 is "readable and carries only table rows", and that is the twin of the unreadable case: BOTH yield an
# empty extraction, and only the status separates them (0 here, 2 there). The roster fixture above carries
# headings, so its extraction is non-empty and the discriminating case went unexercised — the row passed
# on a weaker input than the criterion names. A guard keying on emptiness instead of status would pass
# every row in this section except this one.
P45L="$T45/l"; mkproj "$P45L" main
mkdir -p "$P45L/.ai-flow"
{ printf '| Workstream | Checkout | Task |\n'; printf '|---|---|---|\n'; printf '| coordinator | . | T-100 |\n'; } > "$P45L/.ai-flow/STATE.md"
printf '# Backlog\n' > "$P45L/.ai-flow/BACKLOG.md"
( cd "$P45L" && bash "$GRD45" >/dev/null 2>&1 ); rc45=$?
[ "$rc45" = 0 ] && ok "an all-table roster passes, where the extraction is empty for the lawful reason" \
                || bad "an all-table roster passes, where the extraction is empty for the lawful reason (exit $rc45)"

# --- the size budget's boundary ----------------------------------------------
# The edge itself, which for the line budget was never touched: it was driven at 400 and at ~104, so an
# off-by-one either way would have shipped green. Retargeted to words along with the budget, and to the
# note channel along with its breach — a ledger over the budget now exits 0 with a systemMessage rather
# than refusing, so keying this row on the exit code alone would report a guard that had stopped measuring
# as a guard at its edge. The changelog ceiling's edge is already covered (3 entries, exactly).
ae_45=""
P45M="$T45/m"; mkproj "$P45M" main
mkdir -p "$P45M/.ai-flow"; ros45 > "$P45M/.ai-flow/STATE.md"
nwords 8000 > "$P45M/.ai-flow/BACKLOG.md"
out45="$( cd "$P45M" && printf '%s' "$UPS45" | bash "$GRD45" 2>&1 )"; rc45=$?
[ "$rc45" = 0 ] || ae_45="$ae_45 [a backlog of exactly 8,000 words did not pass (exit $rc45)]"
case "$out45" in *systemMessage*) ae_45="$ae_45 [8,000 words spoke, so the budget fires one word early]" ;; esac
nwords 8001 > "$P45M/.ai-flow/BACKLOG.md"
out45="$( cd "$P45M" && printf '%s' "$UPS45" | bash "$GRD45" 2>&1 )"; rc45=$?
[ "$rc45" = 0 ] || ae_45="$ae_45 [8,001 words refused instead of speaking (exit $rc45)]"
case "$out45" in *systemMessage*) : ;; *) ae_45="$ae_45 [8,001 words stayed silent, so the budget fires one word late]" ;; esac
[ -z "$ae_45" ] && ok "the size budget speaks at 8,001 and passes at 8,000" \
                || bad "the size budget speaks at 8,001 and passes at 8,000:$ae_45"

# --- two reports in one run ---------------------------------------------------
# The accumulator exists because five sources can write to the blocking bucket, and every other row keys
# on the exit code, which is 2 whether one report survives or five. Without this row a regression that
# keeps only the last report ships green and the operator loses the line naming the actual blocker.
#
# RE-KEYED. Its second half required the size note to travel on the blocker's stderr line, and that merge
# is GONE with the event split — the note has a channel of its own, so there is nothing to lose on the
# refusing run and nothing that could be delivered there without laying its mark. The accumulator claim
# survives untouched and is what this row is for, so it is now driven with TWO BLOCKERS rather than a
# blocker and a note: that is the shape the accumulator exists for, and the retired pairing was never
# testing it. The separation the split creates is C11's A5 row, on the sibling that has both halves.
af_45=""
P45N="$T45/n"; mkproj "$P45N" main
mkdir -p "$P45N/.ai-flow"; vio45 > "$P45N/.ai-flow/STATE.md"
{ printf '# Backlog\n\n'; log45 5; } > "$P45N/.ai-flow/BACKLOG.md"
out45="$( cd "$P45N" && bash "$GRD45" 2>&1 )"; rc45=$?
[ "$rc45" = 2 ] || af_45="$af_45 [two blockers in one run did not refuse (exit $rc45)]"
case "$out45" in *"closed-work narrative"*) : ;; *) af_45="$af_45 [the roster report was dropped]" ;; esac
case "$out45" in *"5 session-close"*) : ;; *) af_45="$af_45 [the changelog report was dropped]" ;; esac
[ -z "$af_45" ] && ok "two violations in one run both reach the operator" \
                || bad "two violations in one run both reach the operator:$af_45"

# --- A7 / A8: the drift guard's recorded clone path ---------------------------
E45="$T45/eng"; mkproj "$E45" main
mkdir -p "$E45/global/hooks"; printf 'v1\n' > "$E45/global/hooks/x.sh"
$GIT -C "$E45" add global >/dev/null 2>&1; $GIT -C "$E45" commit -q -m engine
H45="$T45/home"; mkdir -p "$H45/.claude/ai-flow" "$H45/.claude/hooks"
printf '%s\n' "$E45" > "$H45/.claude/ai-flow/source.path"
printf 'v9\n' > "$H45/.claude/hooks/x.sh"     # installed matches nothing: real drift, so silence is wrong
if [ "$UNREAD45" = 1 ]; then
  a7_45=""
  chmod 000 "$H45/.claude/ai-flow/source.path"
  out45="$( cd "$E45" && HOME="$H45" bash "$HK/drift-check.sh" 2>&1 <<<'{}' )"; rc45=$?
  chmod 644 "$H45/.claude/ai-flow/source.path"
  [ "$rc45" = 2 ] || a7_45="$a7_45 [an unreadable recorded path did not refuse (exit $rc45)]"
  case "$out45" in *source.path*) : ;; *) a7_45="$a7_45 [the refusal does not name source.path]" ;; esac
  [ -z "$a7_45" ] && ok "an unreadable recorded clone path is refused, not reported clean" \
                  || bad "an unreadable recorded clone path is refused, not reported clean:$a7_45"
fi
# A7 above freezes "over a fixture where real drift is present, so silence is provably wrong", and nothing
# measured that: the readability gate fires before any comparison, so A7's exit 2 would read the same over
# a fixture that had stopped drifting. This asserts the precondition itself.
ag_45=""
out45="$( cd "$E45" && HOME="$H45" bash "$HK/drift-check.sh" 2>&1 <<<'{}' )"; rc45=$?
[ "$rc45" = 2 ] || ag_45="$ag_45 [the fixture does not actually drift, so A7 proves nothing (exit $rc45)]"
case "$out45" in *differs*) : ;; *) ag_45="$ag_45 [the drift report names no differing file]" ;; esac
[ -z "$ag_45" ] && ok "the drift fixture really does drift, so silence over it would be wrong" \
                || bad "the drift fixture really does drift, so silence over it would be wrong:$ag_45"

# A record that was readable is not a record that is usable, and each of these left by the silence
# reserved for "no clone is recorded" — over genuinely drifted files.
ah_45=""
d45() { printf '%s' "$1" > "$H45/.claude/ai-flow/source.path"
        ( cd "$E45" && HOME="$H45" bash "$HK/drift-check.sh" >/dev/null 2>&1 <<<'{}' ); }
d45 ""; [ $? = 2 ] || ah_45="$ah_45 [an empty record read as no record]"
d45 "$E45
$E45"; [ $? = 2 ] || ah_45="$ah_45 [a two-line record read as no record]"
d45 "$T45/gone-away"; [ $? = 2 ] || ah_45="$ah_45 [a moved or deleted clone read as no record]"
printf '%s\n' "$E45" > "$H45/.claude/ai-flow/source.path"   # put the fixture back for the rows below
[ -z "$ah_45" ] && ok "a recorded clone that cannot be reached is refused, not read as no clone" \
                || bad "a recorded clone that cannot be reached is refused, not read as no clone:$ah_45"

# Absent is the documented remote-install no-op and must survive the repair untouched.
H45B="$T45/home-none"; mkdir -p "$H45B/.claude/hooks"
( cd "$E45" && HOME="$H45B" bash "$HK/drift-check.sh" >/dev/null 2>&1 <<<'{}' ); rc45=$?
[ "$rc45" = 0 ] && ok "no recorded clone path stays silent" \
                || bad "no recorded clone path stays silent (exit $rc45)"

chmod -R u+rwX "$T45" 2>/dev/null
rm -rf "$T45"
fi

# --- A9 / A10: the read-only rail's state sheet -------------------------------
if [ "$PY3" != 1 ]; then
  echo "  [skip] the read-only rail's unreadable-sheet rows (python3 unavailable)"
elif ! T45R="$(mkbox)" || [ ! -d "$T45R" ]; then
  bad "an unreadable state sheet refuses the write (no sandbox: mktemp -d failed)"
  bad "no declared phase leaves the rail silent (no sandbox: mktemp -d failed)"
else
  P45G="$T45R/g"; mkproj "$P45G" main
  mkdir -p "$P45G/.ai-flow/artifacts/T-AAA"
  printf 'branch: main\nphase: **UNDERSTAND**\n' > "$P45G/.ai-flow/artifacts/T-AAA/state.md"
  if [ "$UNREAD45" = 1 ]; then
    a9_45=""
    # The sheet loses its `branch:` claim along with its phase, so WHICH task resolves changes silently --
    # reproduced as a rail that went quiet where it must refuse. The row therefore asserts the refusal,
    # not merely that a phase was read.
    chmod 000 "$P45G/.ai-flow/artifacts/T-AAA/state.md"
    out45="$(wguard "$P45G" "$P45G/app.txt")"; rc45=$?
    chmod 644 "$P45G/.ai-flow/artifacts/T-AAA/state.md"
    [ "$rc45" = 2 ] || a9_45="$a9_45 [an unreadable sheet did not refuse the write (exit $rc45)]"
    case "$out45" in *state.md*) : ;; *) a9_45="$a9_45 [the refusal does not name the sheet it could not read]" ;; esac
    [ -z "$a9_45" ] && ok "an unreadable state sheet refuses the write" \
                    || bad "an unreadable state sheet refuses the write:$a9_45"

    # The escape hatch the refusal names must actually be open. The rail is documented to judge only repo
    # files OUTSIDE .ai-flow/, and its refusal text sends the operator to correct the sheet -- so a
    # refusal that also blocks .ai-flow/ denies the remedy it advertises, and during UNDERSTAND that is
    # the entire output of the phase. An unknown phase cannot change an answer that never depended on the
    # phase, which is why jurisdiction is settled before any verdict.
    a11_45=""
    chmod 000 "$P45G/.ai-flow/artifacts/T-AAA/state.md"
    out45="$(wguard "$P45G" "$P45G/.ai-flow/artifacts/T-AAA/understand.md")"; rc45=$?
    outx45="$(wguard "$P45G" "/tmp/somewhere-outside-the-repo.txt")"; rcx45=$?
    chmod 644 "$P45G/.ai-flow/artifacts/T-AAA/state.md"
    [ "$rc45" = 0 ] || a11_45="$a11_45 [an unreadable sheet refused a write under .ai-flow/ (exit $rc45)]"
    [ "$rcx45" = 0 ] || a11_45="$a11_45 [an unreadable sheet refused a write outside the repo (exit $rcx45)]"
    [ -z "$a11_45" ] && ok "an unreadable sheet still leaves .ai-flow/ and outside-the-repo writes alone" \
                     || bad "an unreadable sheet still leaves .ai-flow/ and outside-the-repo writes alone:$a11_45"

    # The directory level of the same fault, mirroring the ledger guardian's gate. pathlib RAISES when it
    # cannot list the ledger, and an uncaught raise is exit 1 -- non-blocking for PreToolUse, so the
    # write went through and a traceback was printed over it. Both halves asserted: the refusal, and the
    # absence of a traceback, because exit 1 with a stack trace is the shape this failed in.
    a12_45=""
    chmod 000 "$P45G/.ai-flow"
    out45="$(wguard "$P45G" "$P45G/app.txt")"; rc45=$?
    chmod 745 "$P45G/.ai-flow"
    [ "$rc45" = 2 ] || a12_45="$a12_45 [an unreadable .ai-flow directory did not refuse the write (exit $rc45)]"
    case "$out45" in *Traceback*) a12_45="$a12_45 [the rail crashed instead of refusing]" ;; esac
    case "$out45" in *.ai-flow*) : ;; *) a12_45="$a12_45 [the refusal does not name the ledger it could not read]" ;; esac
    [ -z "$a12_45" ] && ok "an unreadable ledger directory refuses the write instead of crashing" \
                     || bad "an unreadable ledger directory refuses the write instead of crashing:$a12_45"

    # The rail has TWO refusal sites and the row above reaches only the first: with a per-task sheet
    # present the ladder stops inside its own resolution. This drives the second -- no per-task sheet at
    # all, so the ladder falls through to the ledger, which exists (stat needs only the parent) and
    # cannot be read. That is the configuration a project which never migrated is in. Deleting this
    # site's refusal left the suite fully green before this row existed.
    a13_45=""
    P45I="$T45R/i"; mkproj "$P45I" main
    mkdir -p "$P45I/.ai-flow"
    printf 'Current phase: **UNDERSTAND**\n' > "$P45I/.ai-flow/STATE.md"
    chmod 000 "$P45I/.ai-flow/STATE.md"
    out45="$(wguard "$P45I" "$P45I/app.txt")"; rc45=$?
    chmod 644 "$P45I/.ai-flow/STATE.md"
    [ "$rc45" = 2 ] || a13_45="$a13_45 [an unreadable ledger did not refuse the write (exit $rc45)]"
    case "$out45" in *STATE.md*) : ;; *) a13_45="$a13_45 [the refusal does not name STATE.md]" ;; esac
    [ -z "$a13_45" ] && ok "an unreadable ledger refuses the write where no task sheet resolves" \
                     || bad "an unreadable ledger refuses the write where no task sheet resolves:$a13_45"
  fi
  # D5 says an unreadable sibling cannot change an answer a readable claim already settled. Two readable
  # claimants is a DIFFERENT stall, and the unreadable rung must not answer for it — doing so refuses
  # while naming a sheet that is not the reason the ladder stopped.
  P45P="$T45R/p"; mkproj "$P45P" main
  mkdir -p "$P45P/.ai-flow/artifacts/A" "$P45P/.ai-flow/artifacts/B" "$P45P/.ai-flow/artifacts/C"
  printf 'branch: main\nphase: **EXECUTE**\n' > "$P45P/.ai-flow/artifacts/A/state.md"
  printf 'branch: main\nphase: **EXECUTE**\n' > "$P45P/.ai-flow/artifacts/B/state.md"
  printf 'branch: main\n'                     > "$P45P/.ai-flow/artifacts/C/state.md"
  if [ "$UNREAD45" = 1 ]; then
    chmod 000 "$P45P/.ai-flow/artifacts/C/state.md"
    out45="$(wguard "$P45P" "$P45P/app.txt")"; rc45=$?
    chmod 644 "$P45P/.ai-flow/artifacts/C/state.md"
    [ "$rc45" = 0 ] && ok "an unreadable sibling does not answer for a stall that is not its own" \
                    || bad "an unreadable sibling does not answer for a stall that is not its own (exit $rc45)"
  fi
  # A sheet that declares no phase at all is the rail's designed silence, and it must survive the repair:
  # absent is not unreadable.
  P45H="$T45R/h"; mkproj "$P45H" main
  mkdir -p "$P45H/.ai-flow/artifacts/T-BBB"
  printf 'branch: main\n' > "$P45H/.ai-flow/artifacts/T-BBB/state.md"
  out45="$(wguard "$P45H" "$P45H/app.txt")"; rc45=$?
  [ "$rc45" = 0 ] && ok "no declared phase leaves the rail silent" \
                  || bad "no declared phase leaves the rail silent (exit $rc45)"
  chmod -R u+rwX "$T45R" 2>/dev/null
  rm -rf "$T45R"
fi
