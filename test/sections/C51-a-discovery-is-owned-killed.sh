# C51 — a discovery is owned by the work that found it, killed with a written reason, or staged in that
# work's own papers. Generated in the Conform phase from understand.md's Verifiable Criteria.
#
# Every verdict is derived from a COUNT inside an extracted region, never from a `grep -v` inside an `if`.
#
# THE PAIRING IS THE DESIGN. Four of the rows below come in presence/absence pairs, and neither half is
# the criterion on its own: presence alone is satisfied by leaving the old destination beside the new one,
# which is the exact failure this task exists to prevent (the engine would then state two destinations at
# once); absence alone is satisfied by deleting the passage. The absence half pins the OLD prose's own
# operative words — `iceboxed`, `line in BACKLOG.md`, `goes to the BACKLOG.md Icebox`, `sent to the
# Icebox` — chosen because they were read at their line numbers before this section was written and
# because the new prose has no reason to use any of them. A pin the correct new prose could also carry
# would report the same verdict either way.
echo "== C51: a discovery is owned, killed with a reason, or staged in the task's own papers =="
UND71="global/protocols/understand.md"
EXE71F="global/protocols/execute.md"
VER71F="global/protocols/verify.md"
SKV71F="global/skills/verify/SKILL.md"
QCK71F="global/protocols/quick-path.md"
BKL71F="global/protocols/backlog.md"
CLD71F="global/CLAUDE.md"

# `-r` and `-s`, not `-f`: a mode-000 or truncated protocol satisfies `-f`, and the rows would then report
# a dozen deletions of prose that is in fact present.
c51_readable=1
for f71 in "$UND71" "$EXE71F" "$VER71F" "$SKV71F" "$QCK71F" "$BKL71F" "$CLD71F"; do
  { [ -r "$f71" ] && [ -s "$f71" ]; } || c51_readable=0
done

if [ "$c51_readable" -eq 0 ]; then
  bad "C51's seven documents are all readable and non-empty"
else
  # The triage's own section, extracted by its heading. Its rules are the ones every other site summarises,
  # so a row that read the whole protocol could be satisfied by prose three sections away.
  TRI71="$(awk '/^## Discovery Triage/{f=1;next} /^## /{f=0} f' "$UND71")"
  # Execute's deviation section, which carries the one-line summary of the triage.
  DEV71="$(awk '/^## Deviation Rules During Execution/{f=1;next} /^## /{f=0} f' "$EXE71F")"
  # The verify skill's triage section — the same region Fact 3e greps, so the two rows judge one text.
  TSK71="$(awk '/^## Triaging the Unadjudicated/{f=1;next} /^## /{f=0} f' "$SKV71F")"
  # The quick path in full: it is short, and the rule it must gain has no section of its own yet.
  QKP71="$(cat "$QCK71F")"
  # The backlog protocol's Icebox section. Terminated on the first line starting with `#` because the
  # prose below it opens a fenced block whose own headings would otherwise re-open the region.
  ICE71="$(awk '/^### Icebox \(discoveries\)/{f=1;next} /^#/{f=0} f' "$BKL71F")"
  # The papers table's own row, not the whole document: a file-wide grep for the new paper would be
  # satisfied by naming it in prose anywhere and never by the table a reader actually consults.
  # The papers row itself, keyed on its first cell. An earlier form took every table row carrying
  # `artifacts/T-XXX/` and matched three rows from two different tables, so naming the paper on the
  # `pause` command row satisfied O1 while the papers row stayed silent — found by mutation at Verify.
  PAP71="$(grep -F '| `artifacts/T-XXX/` |' "$CLD71F")"
  VERT71="$(cat "$VER71F")"

  n71() { printf '%s' "$1" | grep -ciE "$2" | tr -d ' '; }
  # Files under global/ carrying a pattern. The absence legs must reach zero across the whole engine,
  # not merely inside one region: a directive moved one section over is a directive that still runs.
  g71() { grep -rIloE "$1" global/ 2>/dev/null | wc -l | tr -d ' '; }

  # Every extracted region is asserted non-empty by its own row, the house style: a renamed heading must
  # fail as a renamed heading, not as ten simultaneous reports that the prose was deleted.
  r71=""
  [ -n "$TRI71" ] || r71="$r71 [the Discovery Triage section did not extract — heading renamed?]"
  [ -n "$DEV71" ] || r71="$r71 [Execute's deviation section did not extract]"
  [ -n "$TSK71" ] || r71="$r71 [the verify skill's triage section did not extract]"
  [ -n "$QKP71" ] || r71="$r71 [the quick path did not read]"
  [ -n "$ICE71" ] || r71="$r71 [the backlog protocol's Icebox section did not extract]"
  [ -n "$PAP71" ] || r71="$r71 [the papers table row did not extract]"
  [ -z "$r71" ] && ok "C51's six regions all extract" || bad "C51's six regions all extract ($r71)"

  # A1 — THE ORDER, which is the whole point of the test: ownership is asked before the staging
  # destination is offered, or everything large escapes even where the current task is its owner. Derived
  # from the first line each appears on inside the region, so swapping the two sentences fails and
  # deleting either one fails for its own reason. A count-only row would pass on both mutations.
  a1fix71="$(printf '%s\n' "$TRI71" | grep -niE 'fix it now' | head -1 | cut -d: -f1)"
  a1stg71="$(printf '%s\n' "$TRI71" | grep -niE 'discoveries\.md' | head -1 | cut -d: -f1)"
  c1_71=""
  [ -n "$a1fix71" ] || c1_71="$c1_71 [the triage never tells the task to fix what it owns]"
  [ -n "$a1stg71" ] || c1_71="$c1_71 [the triage never names the staging file]"
  if [ -n "$a1fix71" ] && [ -n "$a1stg71" ] && [ "$a1fix71" -ge "$a1stg71" ]; then
    c1_71="$c1_71 [the staging destination is offered at or before the ownership question — the order is inverted]"
  fi
  [ -z "$c1_71" ] && ok "A1 the triage asks ownership before it offers the staging destination" \
                  || bad "A1 the triage asks ownership before it offers the staging destination ($c1_71)"

  # A2 — the third outcome is three outcomes. One leg per outcome, so deleting any single one of them
  # fails on its own name rather than being carried by its neighbours.
  c2_71=""
  [ "$(n71 "$TRI71" 'fix it now')" -ge 1 ]        || c2_71="$c2_71 [the fix outcome is not named]"
  [ "$(n71 "$TRI71" 'discard|dismiss')" -ge 1 ]   || c2_71="$c2_71 [the discard outcome is not named]"
  [ "$(n71 "$TRI71" 'discoveries\.md')" -ge 1 ]   || c2_71="$c2_71 [the staging outcome is not named]"
  [ -z "$c2_71" ] && ok "A2 the third outcome is three outcomes, and each is named" \
                  || bad "A2 the third outcome is three outcomes, and each is named ($c2_71)"

  # A3 (presence half) — every path that routes a finding names the staging destination. Paired with A4
  # below: this half alone is satisfied by a document naming both destinations.
  c3_71=""
  [ "$(n71 "$TRI71" 'discoveries\.md')" -ge 1 ]  || c3_71="$c3_71 [the triage's own section]"
  [ "$(n71 "$DEV71" 'discoveries\.md')" -ge 1 ]  || c3_71="$c3_71 [Execute's summary of it]"
  [ "$(n71 "$TSK71" 'discoveries\.md')" -ge 1 ]  || c3_71="$c3_71 [the verify skill's triage]"
  [ "$(n71 "$VERT71" 'discoveries\.md')" -ge 1 ] || c3_71="$c3_71 [the verify protocol]"
  [ -z "$c3_71" ] && ok "A3 every path that routes a finding names the staging destination" \
                  || bad "A3 every path that routes a finding names the staging destination (missing in:$c3_71)"

  # A4 (absence half) — and no path still sends an in-flight capture to the ledger. Each pattern is the
  # old prose's own operative words, read at its line number before this row was written: `iceboxed` at
  # verify.md:194,255; `ONE line in BACKLOG.md under` at understand.md:78 and its twin at execute.md:149;
  # `goes to the BACKLOG.md Icebox` at the verify skill:75; `sent to the Icebox` at verify.md:187.
  # Counted across the whole engine, because a directive relocated one section over still runs.
  c4_71=""
  [ "$(g71 'iceboxed')" -eq 0 ]                       || c4_71="$c4_71 [a finding is still reported \"iceboxed\"]"
  [ "$(g71 'line in BACKLOG\.md')" -eq 0 ]            || c4_71="$c4_71 [a capture is still directed to one line in BACKLOG.md]"
  [ "$(g71 'goes to the BACKLOG\.md Icebox')" -eq 0 ] || c4_71="$c4_71 [the verify skill still sends a MEDIUM to the ledger]"
  [ "$(g71 'sent to the Icebox')" -eq 0 ]             || c4_71="$c4_71 [the verify protocol still offers the ledger as an exit]"
  [ -z "$c4_71" ] && ok "A4 no path still sends an in-flight capture to the ledger" \
                  || bad "A4 no path still sends an in-flight capture to the ledger ($c4_71)"

  # A5 — the declared ground is reached the way every other cross-checkout reader reaches the coordinator.
  # Two legs: the locator, and the read-only qualifier. Dropping the qualifier is the mutation that turns a
  # read into a licence to write the coordinator's roster from a front.
  c5_71=""
  [ "$(n71 "$TRI71" 'git worktree list')" -ge 1 ] || c5_71="$c5_71 [the coordinator's roster is not located by git's own worktree listing]"
  [ "$(n71 "$TRI71" 'read-only')" -ge 1 ]         || c5_71="$c5_71 [the read is not stated to be read-only]"
  [ -z "$c5_71" ] && ok "A5 the declared ground is read from the coordinator, located the way every other reader locates it" \
                  || bad "A5 the declared ground is read from the coordinator, located the way every other reader locates it ($c5_71)"

  # A6 — the diff set is referenced, not re-derived. Both directions, and the absence half is the one the
  # Understand phase earned: the task arrived proposing `git diff --name-only`, which sees neither committed
  # nor staged nor untracked work, so a re-derived command here would silently narrow what a task owns.
  c6_71=""
  # Fixed-string and case-SENSITIVE, because the claim is that the triage *references* the definition.
  # `n71` is `grep -ciE`, so the earlier form matched the bare lowercase words: the prose
  # "the set is the task diff you compute yourself" — unreferenced and re-derived, the exact shape this
  # criterion forbids — passed the row. Found by mutation at Verify.
  [ "$(printf '%s' "$TRI71" | grep -cF '`## The Task Diff`' | tr -d ' ')" -ge 1 ] || c6_71="$c6_71 [the triage does not reference the engine's own task-diff definition]"
  [ "$(n71 "$TRI71" 'git diff')" -eq 0 ]      || c6_71="$c6_71 [the triage states a git diff command of its own instead of referencing the definition]"
  [ -z "$c6_71" ] && ok "A6 the diff set is referenced, not re-derived" \
                  || bad "A6 the diff set is referenced, not re-derived ($c6_71)"

  # A7 — the one path that keeps no papers still loses nothing silently. Three legs, and the third is the
  # DIRECTIONAL control that keeps the row from passing over prose which sent a quick task's survivor to
  # the ledger at the close.
  #
  # Its first form pinned a NOUN — `Icebox` counted zero times — and the correct prose broke it on the
  # first try: the sentence that FORBIDS the routing has to name the thing it forbids. That is this
  # harness's own documented failure mode (see C36: a pin its rule shares with the rule's negation cannot
  # tell a pass from a fail), and it was repaired here rather than by deleting the sentence, which would
  # have been shaping the prose around a defective assertion.
  #
  # The repair is directional instead of absolute: the ledger may be NAMED in this path, but only under a
  # refusal. Every line mentioning it must also carry a negation, so `a survivor goes to the Icebox at the
  # close` fails while `a quick task never writes to the Icebox` passes.
  qk_ice71="$(printf '%s\n' "$QKP71" | grep -cE 'Icebox' | tr -d ' ')"
  # The negation has to refuse the WRITING, not merely appear on the line. `never|not |no ` accepted any
  # of those tokens anywhere, so "a survivor that is not fixed here goes to the Icebox at the close"
  # passed — the same defect (a pin the rule shares with its negation) the repair above was made to
  # escape, one level in. Raised by the review at Verify.
  qk_neg71="$(printf '%s\n' "$QKP71" | grep -E 'Icebox' | grep -ciE 'never writes|never reaches|nothing reaches|never to BACKLOG|does not write' | tr -d ' ')"
  c7_71=""
  [ "$(n71 "$QKP71" 'discover')" -ge 1 ]            || c7_71="$c7_71 [the quick path says nothing about a discovery]"
  [ "$(n71 "$QKP71" 'surfac|put in front of')" -ge 1 ] || c7_71="$c7_71 [a survivor is not surfaced to the operator]"
  [ "$qk_ice71" -eq "$qk_neg71" ]                   || c7_71="$c7_71 [the ledger is named here outside a refusal — a survivor is being routed to it]"
  [ -z "$c7_71" ] && ok "A7 the path that keeps no papers still loses nothing silently" \
                  || bad "A7 the path that keeps no papers still loses nothing silently ($c7_71)"

  # O1 — the papers table names every paper the engine writes. Asserted on the table's own row, so naming
  # the file in prose elsewhere cannot satisfy it.
  [ "$(n71 "$PAP71" 'discoveries\.md')" -ge 1 ] \
    && ok "O1 the papers table names every paper the engine writes" \
    || bad "O1 the papers table names every paper the engine writes ([the artifacts row does not name discoveries.md])"

  # O2 IS RETIRED, and this comment is what stands where it stood. It was a frozen row holding the format
  # rules and the epic-close review for the task that owns the published layout — and that task has now
  # shipped, so the row's own subject is prose the engine deliberately no longer carries: the entry format
  # admits an identifier and a body file, and the epic-close review is a confirmation sweep. A guard that
  # pins retired behaviour is worse than no guard at all, so it is not left green by loosening its legs.
  #
  # Its guarantee is not dropped, it is re-homed: what it protected against was an edit rewriting the whole
  # section unnoticed, and the section's new rules are now asserted positively — the identifier form, the
  # surviving refusal of a priority, the reason the trade was made, and the sweep — with the retired prose
  # pinned to zero across the engine so the old sentence cannot sit beside the new one. Those live in C53
  # A6 and A7. Deleting this comment along with the row would leave the next reader of C51 with eleven rows
  # and no account of the twelfth.

  # B1 — a dismissal with no written reason is not a dismissal. Three legs: the requirement, the
  # prohibition, and what the reason must actually name. The prohibition is separate because prose reading
  # "discard it with the reason" satisfies a requirement leg while obliging nobody to write anything.
  c9_71=""
  [ "$(n71 "$TRI71" 'written reason|reason in writing')" -ge 1 ] || c9_71="$c9_71 [no written reason is required to discard]"
  [ "$(n71 "$TRI71" 'no reason written|there is no dismissal|is not a dismissal')" -ge 1 ] || c9_71="$c9_71 [nothing says a discard without one does not stand]"
  [ "$(n71 "$TRI71" 'cannot reach')" -ge 1 ]                     || c9_71="$c9_71 [the reason is not tied to the flow being unable to reach the failure]"
  [ -z "$c9_71" ] && ok "B1 a dismissal with no written reason is not a dismissal" \
                  || bad "B1 a dismissal with no written reason is not a dismissal ($c9_71)"

  # D7 — the staging file's shape, which the next task consumes: it moves the body verbatim and regenerates
  # a one-liner from it. The ground field is the part that cannot be reconstructed later, so it is the part
  # pinned; the heading and the body are asserted by A2's staging leg and by the file existing at all.
  [ "$(n71 "$TRI71" 'ground:')" -ge 1 ] \
    && ok "D7 a staged finding carries the ground it was found on, as a field" \
    || bad "D7 a staged finding carries the ground it was found on, as a field ([no ground field is named])"
fi
