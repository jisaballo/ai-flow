# C52 — the repairs the Verify phase made to the work of the pass above. Every row here guards a fact that
# was true in the prose and asserted by nothing: reverting it left the whole suite green. Two were found
# by this phase's mutation battery, the rest by the multi-agent review; the HIGH among them was proved by
# the prover, which reverted the backlog.md hunk and got a byte-for-byte identical result set.
#
# The regions are re-extracted here rather than shared with C51 on purpose: C51 is a frozen contract with
# a manifest behind it, and a row that reaches into another section's variables makes the two fail and
# pass together for reasons neither states.
echo "== C52: the sites the first pass left unguarded =="
U52="global/protocols/understand.md"; E52="global/protocols/execute.md"
V52="global/protocols/verify.md";     S52="global/skills/verify/SKILL.md"
Q52="global/protocols/quick-path.md"; B52="global/protocols/backlog.md"
C52="global/CLAUDE.md"

c52_readable=1
for f52 in "$U52" "$E52" "$V52" "$S52" "$Q52" "$B52" "$C52"; do
  { [ -r "$f52" ] && [ -s "$f52" ]; } || c52_readable=0
done

if [ "$c52_readable" -eq 0 ]; then
  bad "C52's seven documents are all readable and non-empty"
else
  TRI52="$(awk '/^## Discovery Triage/{f=1;next} /^## /{f=0} f' "$U52")"
  DEV52="$(awk '/^## Deviation Rules During Execution/{f=1;next} /^## /{f=0} f' "$E52")"
  TSK52="$(awk '/^## Triaging the Unadjudicated/{f=1;next} /^## /{f=0} f' "$S52")"
  ICE52="$(awk '/^### Icebox \(discoveries\)/{f=1;next} /^#/{f=0} f' "$B52")"
  QKP52="$(cat "$Q52")"; VER52="$(cat "$V52")"; CLD52="$(cat "$C52")"
  n52() { printf '%s' "$1" | grep -ciE "$2" | tr -d ' '; }

  r52=""
  [ -n "$TRI52" ] || r52="$r52 [the triage section did not extract]"
  [ -n "$DEV52" ] || r52="$r52 [Execute's deviation section did not extract]"
  [ -n "$TSK52" ] || r52="$r52 [the verify skill's triage did not extract]"
  [ -n "$ICE52" ] || r52="$r52 [the backlog protocol's Icebox section did not extract]"
  [ -z "$r52" ] && ok "C52's four regions all extract" || bad "C52's four regions all extract ($r52)"

  # R1 — THE HIGH. Every site that routes a finding refuses the ledger IN WORDS, and so does the ledger's
  # own home. The first pass guarded the destination only by pinning four historical phrases: a revert of
  # backlog.md's two lines left all twelve C51 rows green while the engine named two destinations at once.
  # A positive refusal per site is what a revert cannot survive.
  h52=""
  [ "$(n52 "$TRI52" 'in flight')" -ge 1 ] || h52="$h52 [the triage's own section]"
  [ "$(n52 "$DEV52" 'in flight')" -ge 1 ] || h52="$h52 [Execute's summary]"
  [ "$(n52 "$VER52" 'in flight')" -ge 1 ] || h52="$h52 [the verify protocol]"
  [ "$(n52 "$TSK52" 'in flight')" -ge 1 ] || h52="$h52 [the verify skill's triage]"
  [ "$(n52 "$ICE52" 'in flight')" -ge 1 ] || h52="$h52 [the ledger's own home]"
  [ -z "$h52" ] && ok "R1 every routing site refuses the ledger in words, the ledger's home included" \
                || bad "R1 every routing site refuses the ledger in words, the ledger's home included (silent at:$h52)"

  # R2 — the verify skill states the protocol's order and not another one. Positional, like C51's A1:
  # the skill claimed to follow "its order" while listing Stage before Discard, which files a false
  # positive as a real finding whenever it happens to sit outside the diff.
  f52a="$(printf '%s\n' "$TSK52" | grep -niE '\*\*Fix now\*\*'    | head -1 | cut -d: -f1)"
  d52a="$(printf '%s\n' "$TSK52" | grep -niE '\*\*Discard it\*\*' | head -1 | cut -d: -f1)"
  s52a="$(printf '%s\n' "$TSK52" | grep -niE '\*\*Stage it\*\*'   | head -1 | cut -d: -f1)"
  o52=""
  [ -n "$f52a" ] || o52="$o52 [no fix outcome]"
  [ -n "$d52a" ] || o52="$o52 [no discard outcome]"
  [ -n "$s52a" ] || o52="$o52 [no stage outcome]"
  if [ -n "$f52a" ] && [ -n "$d52a" ] && [ -n "$s52a" ]; then
    [ "$f52a" -lt "$d52a" ] || o52="$o52 [the discard is offered at or before ownership]"
    [ "$d52a" -lt "$s52a" ] || o52="$o52 [staging is offered at or before the discard test]"
  fi
  [ -z "$o52" ] && ok "R2 the verify skill states the routing test's order and not another one" \
                || bad "R2 the verify skill states the routing test's order and not another one ($o52)"

  # R3 — the discard test is stated as the FAILURE not occurring, in both documents that state it. Written
  # on reach alone it cannot be satisfied in good faith for two of the three cases the skill itself admits
  # (intended behavior, already handled elsewhere): the flow reaches both and neither is a failure.
  x52=""
  [ "$(n52 "$TRI52" 'cannot occur')" -ge 1 ] || x52="$x52 [the triage states the test on reach alone]"
  [ "$(n52 "$TSK52" 'cannot occur')" -ge 1 ] || x52="$x52 [the verify skill states the test on reach alone]"
  [ -z "$x52" ] && ok "R3 the discard test is the failure not occurring, not the flow not reaching" \
                || bad "R3 the discard test is the failure not occurring, not the flow not reaching ($x52)"

  # R4 — the written reason has ONE home, and it is named where the obligation is stated. Three documents
  # required the reason and none but an oblique "the file below" said where it goes, while the verify
  # template routed the same record into verify.md instead.
  y52=""
  [ "$(n52 "$TRI52" '## Discarded')" -ge 1 ]  || y52="$y52 [the triage does not name the section the reason goes in]"
  [ "$(n52 "$TRI52" 'only home')" -ge 1 ]     || y52="$y52 [the triage does not say it is the only home]"
  # Scoped to the two regions of the verify protocol that actually carry a claim about the reason, never
  # to the file. Read file-wide, this leg was answered by the report template's own placeholder bullet
  # while the NORMATIVE paragraph it is about had stopped naming the home altogether — a leg satisfied by
  # a document's example rather than by its rule. Two legs now, because the protocol does two different
  # things: the routing paragraph DELEGATES the home to the test that owns it, and the report template
  # NAMES it for the writer filling the report in.
  VERMED52="$(awk '/^\*\*MEDIUM and LOW come back unadjudicated/{f=1;print;next} f && /^$/{exit} f' "$V52" | tr '\n' ' ')"
  VERTRI52="$(grep -F 'Triaged in-phase' -A2 "$V52" | tr '\n' ' ')"
  [ -n "$VERMED52" ] || y52="$y52 [the verify protocol's routing paragraph did not extract]"
  [ -n "$VERTRI52" ] || y52="$y52 [the verify protocol's triage report section did not extract]"
  [ "$(n52 "$VERMED52" 'Discovery Triage')" -ge 1 ] \
    || y52="$y52 [the routing paragraph does not delegate the reason's home to the test that owns it]"
  [ "$(n52 "$VERTRI52" '## Discarded')" -ge 1 ] \
    || y52="$y52 [the verify protocol does not route the reason there]"
  [ "$(n52 "$TSK52" '## Discarded')" -ge 1 ]  || y52="$y52 [the verify skill does not route the reason there]"
  [ -z "$y52" ] && ok "R4 the written reason has one named home, and every site that requires it names it" \
                || bad "R4 the written reason has one named home, and every site that requires it names it ($y52)"

  # R5 — discards are not siblings of findings in the staging file. D7's consumer walks the `##` headings
  # and moves each body verbatim; at the same level it republishes as pending work exactly what a written
  # reason killed, which is the leak this epic exists to close.
  [ "$(n52 "$TRI52" '###. per discard|one .###. per')" -ge 1 ] \
    && ok "R5 a discard is nested under its section, not a sibling of the findings" \
    || bad "R5 a discard is nested under its section, not a sibling of the findings ([nothing distinguishes a discard from a finding by shape])"

  # R6 — ownership is a property of the finding, not of the hour. The set is the task diff, which is empty
  # by construction during Understand and Plan — the phases where the triage most often runs — so the
  # question answered `no` for every discovery found before the first edit.
  [ "$(n52 "$TRI52" 'already \*\*named\*\*|Files Affected table')" -ge 1 ] \
    && ok "R6 the ownership question has an answer before Execute has written anything" \
    || bad "R6 the ownership question has an answer before Execute has written anything ([the empty-diff phases are unaddressed])"

  # R7 — size bounds the ACTION, never the routing. Terminal and unbounded, the rule ordered a fix that
  # Surgical Changes and the `>3 unplanned files -> Ask First` boundary both forbid. Two legs, because the
  # bound is worthless without the guarantee that a bounded finding still does not escape.
  z52=""
  [ "$(n52 "$TRI52" 'small and traceable')" -ge 1 ] || z52="$z52 [the fix is ordered without bound]"
  [ "$(n52 "$TRI52" 'never escapes|stays \*\*owned\*\*')" -ge 1 ] || z52="$z52 [a bounded finding is not held inside the task]"
  [ "$(n52 "$TSK52" 'small and traceable')" -ge 1 ] || z52="$z52 [the verify skill orders the fix without bound]"
  [ -z "$z52" ] && ok "R7 size bounds the action and never the routing, and what it bounds stays owned" \
                || bad "R7 size bounds the action and never the routing, and what it bounds stays owned ($z52)"

  # R8 — the cross-checkout read has a branch for failing. The twin instruction 60 lines above stops an
  # Understand over an unreadable Scope Contract; this read copied the locator and dropped the branch, so
  # an unreachable roster silently produced no stamp — the one field D7 says cannot be reconstructed later.
  [ "$(n52 "$TRI52" 'unknown')" -ge 1 ] \
    && ok "R8 an unreadable roster yields a named stamp, not a missing one" \
    || bad "R8 an unreadable roster yields a named stamp, not a missing one ([the read has no failure branch])"

  # R9 — the quick path. Two legs the first pass left open: the two terminals it claims to take (only the
  # surfacing was checked), and the moment it surfaces them at. Its own close is the coordinator's
  # ceremony, which a linked checkout never writes, so a survivor promised to "the close" of a quick task
  # worked in a front is promised to a ceremony held elsewhere, after the sitting that found it ended.
  q52=""
  [ "$(n52 "$QKP52" 'fixed now|fix it now')" -ge 1 ] || q52="$q52 [the fix terminal is not stated]"
  # Keyed on the discard TEST, not on the word: an earlier form pinned `discarded`, which the section's
  # own mention of `## Discarded` satisfied on its own — the leg passed with the terminal deleted. Found
  # by this phase's own battery, in a leg this phase had just written.
  [ "$(n52 "$QKP52" 'cannot occur')" -ge 1 ]         || q52="$q52 [the discard terminal is not stated]"
  [ "$(n52 "$QKP52" 'working sitting')" -ge 1 ]      || q52="$q52 [the surfacing moment is not distinguished from the coordinator's close]"
  [ -z "$q52" ] && ok "R9 the quick path states both terminals and the sitting it surfaces them in" \
                || bad "R9 the quick path states both terminals and the sitting it surfaces them in ($q52)"

  # R10 — the always-loaded file. Its Scope & Session Guard extended to "your own drive-by temptations"
  # and sent the lot to BACKLOG.md, reopening in the document read on every turn the leak the routing test
  # closes everywhere else. A request the user brings may still be captured there; a finding of your own
  # may not.
  w52=""
  [ "$(n52 "$CLD52" 'Discovery Triage')" -ge 1 ] || w52="$w52 [the guard never routes a finding to the triage]"
  [ "$(n52 "$CLD52" 'never to BACKLOG.md while a task is in flight')" -ge 1 ] || w52="$w52 [the guard does not refuse the ledger for a finding of your own]"
  [ -z "$w52" ] && ok "R10 the always-loaded guard sends a request to the ledger and a finding to the triage" \
                || bad "R10 the always-loaded guard sends a request to the ledger and a finding to the triage ($w52)"
fi
