echo "== C23: a checkout holds one claim to its branch, and the close deletes what it archived =="
BLG23="global/protocols/backlog.md"
# Extractors re-declared rather than inherited: a criterion reading another's extractor changes verdict
# when that one is re-scoped. Each is asserted non-empty before any verdict is trusted — an assertion
# that fails because its extractor found nothing passes on anything once the file is edited.
sec23() {  # a "### " section, fence-aware: the skeletons it quotes start lines with "## "
  awk -v h="$1" '$0 ~ h {f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^#+ /){f=0} f' "$BLG23" \
    | tr '\n' ' ' | tr -s ' '
}
raw23() { awk -v h="$1" '$0 ~ h {f=1;next} /^```/{c=1-c; next} (c==0 && /^#+ /){f=0} f' "$BLG23"; }

SHEET23="$(sec23 '^### .artifacts/T-XXX/state.md.')"
LADDER23="$(raw23 '^### Resolving the task')"
RUNG23="$(item23 4 "$LADDER23")"
OPEN23="$(raw23 '^## Opening a Workstream')"
MOVE23="$(item23 7 "$OPEN23")"
ARCH23="$(raw23 '^### After ARCHIVE')"
CLO23="$(raw23 '^## Closing a Workstream')"
# The deletion of the papers, located by the ACT and never by a number: a stale number does not fail, it
# extracts a neighbour that answers differently. WHERE the close states it — a move of the ceremony or a
# step of the checklist — is asserted elsewhere; the three legs below read WHAT it says, which is the same
# claim in either home, so the lookup takes the ceremony first and falls back to the checklist. The probe
# is silenced and the fallback is not: one of the two must answer, and the failure names the act.
if NDEL23="$(step_no "$DEL_ACT" "$CLO23" 2>/dev/null)"; then
  STEP23="$(item23 "$NDEL23" "$CLO23")"
elif NDEL23="$(step_no "$DEL_ACT" "$ARCH23")"; then
  STEP23="$(item23 "$NDEL23" "$ARCH23")"
else
  STEP23=""
fi
INV23="$(sec23 '^### Invariants')"

# A1 — the rule lands where the sheet's shape is defined, in three parts that can each be deleted
# alone: the invariant, the obligation that keeps it, and the form a released claim takes.
if [ -n "$SHEET23" ]; then
  printf '%s' "$SHEET23" | grep -qiE 'at most one|only one|exactly one' \
    && printf '%s' "$SHEET23" | grep -qi 'claim' \
    && ok "the sheet's section states a checkout holds at most one claim to its branch" \
    || bad "the sheet's section states a checkout holds at most one claim to its branch"
  printf '%s' "$SHEET23" | grep -qiE 'releas[a-z]* every other claim' \
    && ok "the sheet's section obliges a new claim to release every other claim there" \
    || bad "the sheet's section obliges a new claim to release every other claim there"
  printf '%s' "$SHEET23" | grep -q 'released-branch' \
    && printf '%s' "$SHEET23" | grep -qiE 'anchor|start of the line' \
    && ok "the sheet's section names the released form and why it is not read as a claim" \
    || bad "the sheet's section names the released form and why it is not read as a claim"
else
  bad "the sheet's section states a checkout holds at most one claim to its branch (no section)"
  bad "the sheet's section obliges a new claim to release every other claim there (no section)"
  bad "the sheet's section names the released form and why it is not read as a claim (no section)"
fi

# A2 — the writer for the datum rung 1 reads. Scoped to the move that writes the sheet: a
# section-wide grep would pass on the pruning move above it, which releases nothing.
if [ -n "$MOVE23" ]; then
  printf '%s' "$MOVE23" | grep -qiE 'releas[a-z]* every other claim' \
    && ok "the move that writes a task's sheet releases every other claim to that branch" \
    || bad "the move that writes a task's sheet releases every other claim to that branch"
else
  bad "the move that writes a task's sheet releases every other claim to that branch (no move)"
fi

# A6 — the rung today credits the opening ceremony alone, which is what sent this task's own capture
# down a false trail. It must name the rule that actually prevents the situation.
if [ -n "$RUNG23" ]; then
  printf '%s' "$RUNG23" | grep -qiE 'one claim|at most one|releas' \
    && ok "the last rung names what prevents two claims to one branch" \
    || bad "the last rung names what prevents two claims to one branch"
else
  bad "the last rung names what prevents two claims to one branch (no rung)"
fi

# A3 — three conjuncts, three assertions. A criterion with two conjuncts can ship with one of them
# implemented, so reach, safety and ordering are each asserted where they can each be deleted alone.
if [ -n "$STEP23" ]; then
  printf '%s' "$STEP23" | grep -qiE 'every checkout|each checkout|wherever|both checkouts' \
    && ok "the archive step deletes the papers in every checkout that holds them" \
    || bad "the archive step deletes the papers in every checkout that holds them"
  printf '%s' "$STEP23" | grep -qiE 'record is written|already written|archive holds|summary' \
    && ok "the archive step names the written record as what makes the deletion safe" \
    || bad "the archive step names the written record as what makes the deletion safe"
  printf '%s' "$STEP23" | grep -qiE 'never before the collection|not before the collection|never at collection' \
    && ok "the archive step forbids deleting before the collection" \
    || bad "the archive step forbids deleting before the collection"
else
  bad "the archive step deletes the papers in every checkout that holds them (no step)"
  bad "the archive step names the written record as what makes the deletion safe (no step)"
  bad "the archive step forbids deleting before the collection (no step)"
fi

# A7 — the invariant the widened deletion makes true. Unqualified, it reads as a property of the one
# checkout that keeps the record, which is exactly the reading that left every other copy behind.
if [ -n "$INV23" ]; then
  printf '%s' "$INV23" | grep -qiE 'every checkout|each checkout|in any checkout' \
    && ok "the artifacts invariant holds in every checkout" \
    || bad "the artifacts invariant holds in every checkout"
else
  bad "the artifacts invariant holds in every checkout (no section)"
fi

# O2's machine half — the hook README enumerates why a sheet declares no branch, and this change adds
# a second reason. A positive requirement, not a denylist: the row must name the released claim.
ROW23="$(grep -m1 '^| .understand-write-guard.py.' global/hooks/README.md)"
if [ -n "$ROW23" ] \
   && printf '%s' "$ROW23" | grep -q 'released-branch' \
   && printf '%s' "$ROW23" | grep -qi 'claim was released'; then
  ok "the rail's own documentation names the released claim as a reason a sheet declares no branch"
else
  bad "the rail's own documentation names the released claim as a reason a sheet declares no branch"
fi

# The two corrections this change made to statements it falsified elsewhere. Both were shipped by the
# change and neither was asserted: the review reproduced it — reverting either left the whole suite
# green while the document contradicted itself. A correction nothing guards is a correction with a
# half-life.
R2_23="$(item23 2 "$LADDER23")"
if [ -n "$R2_23" ]; then
  printf '%s' "$R2_23" | grep -qiE 'releas' \
    && printf '%s' "$R2_23" | grep -qiE 'alone among|among the sheets' \
    && ok "rung 2 admits the released claim and scopes 'alone' to the sheets declaring no branch" \
    || bad "rung 2 admits the released claim and scopes 'alone' to the sheets declaring no branch"
else
  bad "rung 2 admits the released claim and scopes 'alone' to the sheets declaring no branch (no rung)"
fi

# The preamble used to carve out the one step that reached into another checkout. That step is now a move
# of the ceremony, so the carve-out is not merely stale — kept, it would send a reader looking inside this
# checklist for an act no step here performs. Both halves: the checklist is wholly the ledger writer's, and
# the act that left is named where it went, or the preamble states a scope with no account of the exception
# every earlier reader was told about.
PRE23="$(awk '/^### After ARCHIVE/{f=1;next} /^[0-9]+\. /{f=0} f' "$BLG23" | tr '\n' ' ' | tr -s ' ')"
if [ -n "$PRE23" ]; then
  p23=""
  printf '%s' "$PRE23" | grep -qiE 'except step [0-9]' \
    && p23="$p23 [the preamble still carves out a step that no longer deletes anything]"
  printf '%s' "$PRE23" | grep -qiE 'nothing here reaches|reaches into no|no step (here )?reaches' \
    || p23="$p23 [the preamble does not state that no step here leaves the coordinator]"
  # Bound to the number the DELETION actually holds, never to "some move of the closing ceremony": the
  # preamble's own first sentence reads "what move 4 of `## Closing a Workstream` runs", and a leg spelled
  # `move [0-9]+ of .## Closing` matched it — the `.` matches the backtick — so it was answered by prose
  # that predates this rule, and the clause it was written to guard could be deleted with the row green.
  if [ -z "$NDEL23" ]; then
    p23="$p23 [the close states no deletion of the papers, so the preamble has no move to name]"
  else
    printf '%s' "$PRE23" | grep -qiE "move $NDEL23 of the ceremony|move $NDEL23 of .## Closing" \
      || p23="$p23 [the preamble does not name move $NDEL23, where the act that left went]"
  fi
  [ -z "$p23" ] && ok "the checklist preamble keeps the whole checklist inside the coordinator" \
                || bad "the checklist preamble keeps the whole checklist inside the coordinator ($p23)"
else
  bad "the checklist preamble keeps the whole checklist inside the coordinator (no preamble)"
fi

# The index a reader consults for what happens to the sheet at archive. The review's prover added this
# very assertion and watched it fail against the shipped row: proven unguarded before it was written.
WRT23="$(sec23 '^### Who writes what, when')"
if [ -n "$WRT23" ]; then
  printf '%s\n' "$WRT23" | grep -oE '\| \*\*Archive\*\*[^|]*\|[^|]*\|[^|]*\|' | grep -qiE 'every checkout|each checkout' \
    && ok "the writers table's archive row scopes the deletion to every checkout" \
    || bad "the writers table's archive row scopes the deletion to every checkout"
else
  bad "the writers table's archive row scopes the deletion to every checkout (no section)"
fi
