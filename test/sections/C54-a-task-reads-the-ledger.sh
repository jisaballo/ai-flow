# C54 — the intersection at task start: a task reads the ledger's summary lines before it investigates,
# and every encounter it makes writes back into the entry it met.
# Generated in the Conform phase from understand.md's Verifiable Criteria (A1-A17; O1-O3 are inspection).
#
# Every verdict is derived from a COUNT inside an extracted region, never from a `grep -v` inside an `if`.
#
# TWO SHAPES CARRY THIS SECTION, and each answers a defect this engine has already paid for.
#
#   * POSITION, for the one criterion that is an ORDER rather than a presence (A1). The scan reads what the
#     scoping pass produces and feeds the list the inline-vs-agents call is derived from, so it sits
#     between them. A presence-only row passes a scan pasted at the foot of the section, where nothing it
#     computes is ever read — and the row would be green over a mechanism that does not run.
#
#   * THE CLAIM, NOT THE WORDING. Every pattern is an alternation over the operative claim, because the
#     prose does not exist yet: this section IS the frozen contract and Execute writes against it. What is
#     pinned is what each sentence must SAY. The single exception is A7, where the five verbs are
#     themselves the contract and each is pinned literally, backticked — a vocabulary whose members are
#     negotiable is not a closed vocabulary, and an unbackticked `narrowed` is matched by ordinary prose.
#
# NO ABSENCE HALVES, and the omission is deliberate. This task overrules nothing: it extends the Icebox's
# schema and adds a step to a phase, so there is no retired sentence that could be left standing beside
# the new one. Said out loud because C51 and C53 both carry pairings, and a reader who knows those
# sections would otherwise read the absence here as an oversight.
#
# WHAT THIS SECTION DOES NOT ASSERT, because another section already does. That the summary line is
# regenerated FROM the body in the same edit is C53 A3. That retirement burns the number and keeps the
# reason is C53 A5 — which is why `falsified` and `narrowed` need no coverage of their own here: they are
# published by the amendments half, an act already carrying all three of its promises. That no path sends
# an in-flight capture to a single line in the ledger is C51 A4, whose pin this task deliberately did not
# loosen. A second copy of any of them here is a second thing to keep true.
echo "== C54: a task reads the ledger before it investigates, and writes back what it met =="
UN73="global/protocols/understand.md"
BK73="global/protocols/backlog.md"
SK73="global/skills/understand/SKILL.md"

# `-r` and `-s`, not `-f`: a mode-000 or truncated file satisfies `-f`, and the rows would then report a
# dozen deletions of prose that is in fact present.
c54_readable=1
for f73 in "$UN73" "$BK73" "$SK73"; do
  { [ -r "$f73" ] && [ -s "$f73" ]; } || c54_readable=0
done

if [ "$c54_readable" -eq 0 ]; then
  bad "C54's three files are all readable and non-empty"
else
  # The Investigation section — the scan's one home. `/^## Investigation/` also matches
  # `## Investigation Closure` 85 lines below, which is harmless and worth stating: the first match opens
  # the region and the next `## ` closes it, so the later heading is never reached.
  INV73="$(awk '/^## Investigation/{f=1;next} f && /^## /{exit} f' "$UN73")"
  INV73F="$(printf '%s\n' "$INV73" | tr '\n' ' ' | tr -s ' ')"
  # The skip block inside it, from its own bolded lead to the end of the region. A16's subject; a region of
  # the whole section would let the scan's own prose answer for the skip rule, which is the wrong document
  # in the right file.
  SKIP73="$(printf '%s\n' "$INV73" | awk '/\*\*When to skip/{f=1} f' | tr '\n' ' ' | tr -s ' ')"
  EPS73="$(awk '/^## Epic-Scoped Understanding/{f=1;next} f && /^## /{exit} f' "$UN73" | tr '\n' ' ' | tr -s ' ')"
  TRI73="$(awk '/^## Discovery Triage/{f=1;next} f && /^## /{exit} f' "$UN73" | tr '\n' ' ' | tr -s ' ')"
  # The artifact template, fence-bounded and fence-stripped: the aggregate line is a FIELD of a template,
  # and a grep over the protocol would be answered by the rule that mandates the field instead.
  TPL73="$(awk '/^## Output: understand\.md/{f=1;next} f && /^```/{c=1-c;next} f && c' "$UN73")"
  # The Icebox section. Terminated on the first line starting with `#` for the reason C53 gives: the prose
  # below it opens a fenced block whose own headings would re-open the region.
  ICE73="$(awk '/^### Icebox \(discoveries\)/{f=1;next} /^#/{f=0} f' "$BK73")"
  ICE73F="$(printf '%s\n' "$ICE73" | tr '\n' ' ' | tr -s ' ')"
  ARC73="$(awk '/^### After ARCHIVE \(single task\)/{f=1;next} f && /^#{2,4} /{exit} f' "$BK73")"
  # The write-back move alone, from its own numbered step to the next one — C53's extraction, and for its
  # reason: `Steering update` and `product.md write-back` sit beside it and are write-backs too.
  WB73="$(printf '%s\n' "$ARC73" | awk '/Icebox write-back/{f=1} f && /^[0-9]+\. / && !/Icebox write-back/{exit} f')"
  WB73F="$(printf '%s\n' "$WB73" | tr '\n' ' ' | tr -s ' ')"
  SKL73="$(cat "$SK73")"

  n73() { printf '%s' "$1" | grep -ciE "$2" | tr -d ' '; }
  # Files carrying a claim, across all three trees a rule can be copied into. C22's own reason for looking
  # past global/: a copy in the shipped template or the docs is as much a second home as one in the engine.
  g73() { grep -rIloE "$1" global/ template/ docs/ 2>/dev/null | wc -l | tr -d ' '; }
  # First line a pattern appears on inside a region: for the facts that are an ORDER, which presence greps
  # cannot see. Empty when absent, and every caller tests that before comparing.
  ln73() { printf '%s\n' "$1" | grep -nE "$2" | head -1 | cut -d: -f1; }

  # Every extracted region is asserted non-empty by its own row, the house style: a renamed heading must
  # fail as a renamed heading, not as seventeen simultaneous reports that the prose was deleted.
  r73=""
  [ -n "$INV73" ]  || r73="$r73 [the Investigation section did not extract — heading renamed?]"
  [ -n "$SKIP73" ] || r73="$r73 [the investigation's skip block did not extract]"
  [ -n "$EPS73" ]  || r73="$r73 [the Epic-Scoped Understanding section did not extract]"
  [ -n "$TRI73" ]  || r73="$r73 [the Discovery Triage section did not extract]"
  [ -n "$TPL73" ]  || r73="$r73 [the understand.md template block did not extract]"
  [ -n "$ICE73" ]  || r73="$r73 [the Icebox section did not extract]"
  [ -n "$WB73" ]   || r73="$r73 [no numbered move names the Icebox write-back]"
  [ -z "$r73" ] && ok "C54's seven regions all extract" || bad "C54's seven regions all extract ($r73)"

  # A1 — POSITION, plus the home count. Both patterns name the ACT and not a line number, so a section
  # rewritten around them still answers. The home count is C22's idiom keyed on the rule's operative claim
  # rather than on a heading, because the scan is a step and not a section of its own: the skill's pointer
  # (A17) points at the rule and has no reason to carry it.
  sc73="$(ln73 "$INV73" 'candidate list of affected areas')"
  ic73="$(ln73 "$INV73" '[Ii]cebox scan')"
  uk73="$(ln73 "$INV73" '\*\*Unknowns list')"
  c1_73=""
  [ -n "$ic73" ] || c1_73="$c1_73 [the Investigation section names no Icebox scan]"
  { [ -n "$ic73" ] && [ -n "$sc73" ] && [ "$ic73" -gt "$sc73" ]; } \
    || c1_73="$c1_73 [the scan does not follow the pass whose areas it reads]"
  { [ -n "$ic73" ] && [ -n "$uk73" ] && [ "$ic73" -lt "$uk73" ]; } \
    || c1_73="$c1_73 [the scan does not precede the list the inline-vs-agents call derives from]"
  # Widened at Verify from the single literal the first draft pinned: the count is of HOMES, so a copy that
  # rewords the read was invisible to it — which is the one place this section had departed from its own
  # stated design, THE CLAIM NOT THE WORDING.
  [ "$(g73 'only the (summary|index|nano) lines|one (summary|index|nano) line per entry')" -eq 1 ] \
    || c1_73="$c1_73 [the scan's rule is stated in other than exactly one document]"
  [ -z "$c1_73" ] && ok "A1 the scan is a step of the scoping pass and has exactly one home" \
                  || bad "A1 the scan is a step of the scoping pass and has exactly one home ($c1_73)"

  # A2 — the read is bounded and the body is conditional. Two legs and not one: prose that says only the
  # summary lines are read, while saying nothing about when a body is opened, describes a scan that can
  # never look at anything; prose that says a body is loaded on intersection, without bounding the read,
  # describes the cost this task exists to avoid.
  c2_73=""
  [ "$(n73 "$INV73F" 'only the (summary|index|nano) lines')" -ge 1 ] \
    || c2_73="$c2_73 [the scan does not say it reads only the summary lines]"
  [ "$(n73 "$INV73F" '(load|open|read)s? (the |a |its )?bod(y|ies)[^.]{0,120}(intersect|touch|match)|(intersect|touch|match)[^.]{0,120}(load|open)s? (the |a |its )?bod')" -ge 1 ] \
    || c2_73="$c2_73 [a body is not said to be loaded only where there is an intersection]"
  [ -z "$c2_73" ] && ok "A2 only the summary lines are read; a body is loaded on intersection" \
                  || bad "A2 only the summary lines are read; a body is loaded on intersection ($c2_73)"

  # A3 — three legs, and the third is the REASON, which this engine treats as part of the rule: without it
  # the next reader adds the area field this task refused, and refuses nothing when they do.
  c3_73=""
  [ "$(n73 "$INV73F" 'judg(e)?ment')" -ge 1 ] \
    || c3_73="$c3_73 [the intersection is not stated as a judgment]"
  [ "$(n73 "$INV73F" 'not a (stored )?field|never a (stored )?field|no (area|domain) field')" -ge 1 ] \
    || c3_73="$c3_73 [the refusal of a field is not stated]"
  [ "$(n73 "$INV73F" 'kept true|re-priced|goes stale')" -ge 1 ] \
    || c3_73="$c3_73 [the refusal is stated without the reason it was made]"
  [ -z "$c3_73" ] && ok "A3 the intersection is a judgment, not a field, and says why" \
                  || bad "A3 the intersection is a judgment, not a field, and says why ($c3_73)"

  # A4 — the rule that mandates the line AND the template that carries the field. One without the other is
  # the failure the `## Unknowns` list already measured: a mandate nothing provides a slot for was written
  # by 0 of 16 sessions.
  c4_73=""
  [ "$(n73 "$INV73F" '(aggregate|one) line[^.]{0,160}scan|scan[^.]{0,160}(aggregate|one) line')" -ge 1 ] \
    || c4_73="$c4_73 [the scan's written output is not stated as one line]"
  [ "$(n73 "$INV73F" 'scanned')" -ge 1 ] \
    || c4_73="$c4_73 [the line is not said to carry the count scanned]"
  [ "$(n73 "$INV73F" 'matched|which ones|entries that touch')" -ge 1 ] \
    || c4_73="$c4_73 [the line is not said to name the entries matched]"
  # Re-keyed at Verify. The first draft asked only that the word `Icebox` appear inside the template, so the
  # slot could lose both fields the criterion names and still pass — the very failure this row's comment
  # cites. Two legs, because either field can be dropped alone.
  [ "$(n73 "$TPL73" '[Ii]cebox')" -ge 1 ] \
    || c4_73="$c4_73 [the artifact template has no slot for the scan's line]"
  [ "$(n73 "$TPL73" 'scanned')" -ge 1 ] \
    || c4_73="$c4_73 [the template slot does not carry the count scanned]"
  [ "$(n73 "$TPL73" 'matched')" -ge 1 ] \
    || c4_73="$c4_73 [the template slot does not carry the entries matched]"
  [ -z "$c4_73" ] && ok "A4 the scan's written output is one aggregate line, and the template carries it" \
                  || bad "A4 the scan's written output is one aggregate line, and the template carries it ($c4_73)"

  # A5 — the zero-match case, stated. An ordered co-occurrence rather than two bare words: `nothing` and
  # `still` both appear in ordinary prose, and independently grepped they are satisfied by any two
  # sentences in the section.
  c5_73=""
  [ "$(n73 "$INV73F" '(nothing|none|no entry)[^.]{0,120}still|still[^.]{0,120}(nothing|none|no entry)')" -ge 1 ] \
    || c5_73="$c5_73 [a scan that matched nothing is not addressed]"
  [ "$(n73 "$INV73F" 'still (writes|records|reports)|count is still')" -ge 1 ] \
    || c5_73="$c5_73 [the count is not required when nothing matched]"
  [ -z "$c5_73" ] && ok "A5 a scan that matched nothing still writes its count" \
                  || bad "A5 a scan that matched nothing still writes its count ($c5_73)"

  # A6 — the obligation the whole mechanism rests on: an entry looked at and not taken must not be free.
  # The second leg is what makes the sighting attributable — a `deferred` line naming nobody cannot be
  # counted against a task, and `times deferred` is derived from exactly these lines.
  c6_73=""
  [ "$(n73 "$INV73F" 'deferred')" -ge 1 ] \
    || c6_73="$c6_73 [no sighting is owed by an entry that was looked at and not taken]"
  [ "$(n73 "$INV73F" 'deferred[^.]{0,120}naming|naming the task that deferred')" -ge 1 ] \
    || c6_73="$c6_73 [the deferred sighting does not name the task that deferred it]"
  # Added at Verify. Both original legs keyed on `deferred`, so the DECLINED branch was pinned and the
  # general rule was not: prose keeping the declined case and dropping "every loaded body leaves a record"
  # left an entry the task TOOK owing nothing, and the amendments half with no producer for a retirement.
  [ "$(n73 "$INV73F" 'bod(y|ies)[^.]{0,160}(leaves|owes) a (record|sighting)|(leaves|owes) a (record|sighting)[^.]{0,160}bod')" -ge 1 ] \
    || c6_73="$c6_73 [the general obligation on a loaded body is unstated — only the declined branch is]"
  [ -z "$c6_73" ] && ok "A6 a body loaded and not taken owes a deferred sighting naming the task" \
                  || bad "A6 a body loaded and not taken owes a deferred sighting naming the task ($c6_73)"

  # A7 — the vocabulary, pinned member by member and backticked. Five separate legs because five separate
  # verbs can go missing separately, and a row keyed on the count alone would pass a list of five other
  # words. The closing leg is the difference between a list and a vocabulary: without it a sixth verb is
  # admitted by silence, and the log stops being countable.
  c7_73=""
  for v73 in confirmed re-priced narrowed falsified deferred; do
    [ "$(n73 "$ICE73F" "\`$v73\`")" -ge 1 ] || c7_73="$c7_73 [$v73]"
  done
  [ "$(n73 "$ICE73F" 'closed vocabular|vocabulary is closed|exactly (these )?five|and no other')" -ge 1 ] \
    || c7_73="$c7_73 [the verbs are listed without the vocabulary being closed]"
  [ "$(n73 "$ICE73F" 'Sightings')" -ge 1 ] \
    || c7_73="$c7_73 [the entry's body schema names no log for them to be written in]"
  [ -z "$c7_73" ] && ok "A7 the vocabulary is exactly five verbs and is closed" \
                  || bad "A7 the vocabulary is exactly five verbs and is closed ($c7_73)"

  # A8 — the staging shape, stated where the triage that produces it lives. The third leg accepts a
  # CITATION of `## Discarded`'s reason as well as a restatement of it: citing is this engine's preferred
  # form and a row that demanded the restatement would punish the better prose.
  c8_73=""
  [ "$(n73 "$TRI73" 'Sightings')" -ge 1 ] \
    || c8_73="$c8_73 [the triage names no staging section for sightings]"
  [ "$(n73 "$TRI73" 'Sightings[^.]{0,200}(###|third-level|one per entry)|(###|third-level|one per entry)[^.]{0,200}Sightings')" -ge 1 ] \
    || c8_73="$c8_73 [the section's entries are not said to sit one level down]"
  [ "$(n73 "$TRI73" 'Sightings[^.]{0,240}(republish|new finding|same reason)')" -ge 1 ] \
    || c8_73="$c8_73 [a second-level heading is refused without the reason, or without tying it to this section]"
  [ -z "$c8_73" ] && ok "A8 sightings stage under one section, one level down, with the reason" \
                  || bad "A8 sightings stage under one section, one level down, with the reason ($c8_73)"

  # A9 — the additions half skips the log. Ordered co-occurrence, because `Sightings` and `not read` as two
  # bare words are satisfied by the sentence that already skips `## Discarded` sitting near the new one.
  c9_73=""
  [ "$(n73 "$WB73F" 'Sightings')" -ge 1 ] \
    || c9_73="$c9_73 [the write-back does not mention the log at all]"
  [ "$(n73 "$WB73F" 'Sightings[^.]{0,160}(not read|skipp|is not)|(not read|skipp)[^.]{0,160}Sightings')" -ge 1 ] \
    || c9_73="$c9_73 [the additions half does not skip the log, so a sighting would be republished as a finding]"
  [ -z "$c9_73" ] && ok "A9 the additions half skips the sightings section" \
                  || bad "A9 the additions half skips the sightings section ($c9_73)"

  # A10 — the amendments half gains its first producer. Ordered co-occurrence for the same reason A9 is:
  # the half already says it rewrites the line, so `publish` sitting anywhere in the move would answer.
  c10_73=""
  [ "$(n73 "$WB73F" 'publish[^.]{0,160}sighting|sighting[^.]{0,160}(publish|append)')" -ge 1 ] \
    || c10_73="$c10_73 [nothing publishes the staged sightings, so the staging file has no consumer]"
  [ "$(n73 "$WB73F" '(append|adds each|writes each)[^.]{0,160}sighting|sighting[^.]{0,160}(append|adds each|writes each)')" -ge 1 ] \
    || c10_73="$c10_73 [the log is not said to grow by the encounter rather than be replaced]"
  [ -z "$c10_73" ] && ok "A10 the amendments half publishes the staged sightings" \
                   || bad "A10 the amendments half publishes the staged sightings ($c10_73)"

  # A11 — the budget, and the regeneration bound to it. The number is required as a NUMBER: a budget
  # written as "short" is a budget every writer sizes for themselves, which is the state this task found.
  # The binding leg is on the write-back's own region, because the regeneration happens there and a budget
  # stated only where the entry is defined governs nothing that runs.
  c11_73=""
  [ "$(n73 "$ICE73F" '[0-9]+ words')" -ge 1 ] \
    || c11_73="$c11_73 [the summary line's budget is not stated as a number]"
  [ "$(n73 "$ICE73F" '(line|statement)[^.]{0,160}[0-9]+ words|[0-9]+ words[^.]{0,160}(line|statement)')" -ge 1 ] \
    || c11_73="$c11_73 [the number is not tied to the line it governs]"
  [ "$(n73 "$WB73F" 'budget|[0-9]+ words')" -ge 1 ] \
    || c11_73="$c11_73 [the regeneration is not bound to the budget]"
  [ -z "$c11_73" ] && ok "A11 the summary line has a numeric budget and the regeneration is bound to it" \
                   || bad "A11 the summary line has a numeric budget and the regeneration is bound to it ($c11_73)"

  # A12 — both counts, both derived, neither stored. Four legs: each count can go missing on its own, the
  # word `derived` is the whole design decision, and the absence of a field is what keeps it true. A row
  # that asserted only `derived` would pass prose that named one count and stored the other.
  c12_73=""
  [ "$(n73 "$ICE73F" 'closes survived')" -ge 1 ] \
    || c12_73="$c12_73 [closes survived is not defined]"
  [ "$(n73 "$ICE73F" 'times deferred')" -ge 1 ] \
    || c12_73="$c12_73 [times deferred is not defined]"
  [ "$(n73 "$ICE73F" '(closes survived|times deferred)[^.]{0,200}derived|derived[^.]{0,200}(closes survived|times deferred)')" -ge 1 ] \
    || c12_73="$c12_73 [the counts are not stated as derived]"
  [ "$(n73 "$ICE73F" 'stored nowhere|never stored|not stored|no (stored )?field')" -ge 1 ] \
    || c12_73="$c12_73 [nothing refuses a stored field, so the next writer adds one]"
  [ -z "$c12_73" ] && ok "A12 both counts are derived and neither is stored" \
                   || bad "A12 both counts are derived and neither is stored ($c12_73)"

  # A13 — the signal, and its limit. The third leg is the limit: this epic's frozen non-goal is that no
  # automatic act exists, and a signal stated without it is the reaper arriving by omission.
  c13_73=""
  [ "$(n73 "$ICE73F" '(two|second) deferrals?|deferred twice')" -ge 1 ] \
    || c13_73="$c13_73 [two deferrals is not stated as a signal]"
  [ "$(insent "$ICE73F" '(two|second) deferrals?|deferred twice' 'promot' 'retir')" = 1 ] \
    || c13_73="$c13_73 [the signal does not offer the operator both outcomes]"
  [ "$(n73 "$ICE73F" 'signal, not|not an act|no automatic|never automatic')" -ge 1 ] \
    || c13_73="$c13_73 [nothing says the signal performs no act — the reaper this epic refused]"
  [ -z "$c13_73" ] && ok "A13 two deferrals surface the entry and no automatic act is defined" \
                   || bad "A13 two deferrals surface the entry and no automatic act is defined ($c13_73)"

  # A14 — the in-flight rule extended to the new producer. The section already carries the rule for
  # additions, so the leg has to name the SIGHTING: a bare `in flight` is green today and would let this
  # task ship a second producer that writes at encounter time from a front, where nobody would see it.
  c14_73=""
  [ "$(n73 "$ICE73F" 'in flight')" -ge 1 ] \
    || c14_73="$c14_73 [the in-flight rule is gone from the section]"
  [ "$(n73 "$ICE73F" 'sighting[^.]{0,160}in flight|in flight[^.]{0,160}sighting|sightings? included|amendments? included')" -ge 1 ] \
    || c14_73="$c14_73 [the rule does not reach the sighting, so a front could write to the ledger]"
  [ -z "$c14_73" ] && ok "A14 no sighting reaches the ledger while work is in flight" \
                   || bad "A14 no sighting reaches the ledger while work is in flight ($c14_73)"

  # A15 — the exemption, written where the restriction is. Three legs, and the third is the reason: an
  # exemption whose ground is unwritten is the first thing a later reader deletes for widening the phase.
  c15_73=""
  [ "$(n73 "$EPS73" '[Ii]cebox')" -ge 1 ] \
    || c15_73="$c15_73 [the restriction says nothing about the scan, so the scan is forbidden by it]"
  [ "$(n73 "$EPS73" '([Ii]cebox|scan)[^.]{0,200}(exempt|does not widen|not a widening|still runs)|(exempt|does not widen|not a widening|still runs)[^.]{0,200}([Ii]cebox|scan)')" -ge 1 ] \
    || c15_73="$c15_73 [the scan is mentioned without being exempted]"
  [ "$(n73 "$EPS73" 'sizes? the investigation|rather than widening|not the investigation')" -ge 1 ] \
    || c15_73="$c15_73 [the exemption is stated without the reason it is not a widening]"
  # Added at Verify. The paragraph states TWO restrictions — no broad Explore agents, and investigation
  # limited to the task's own files — and an exemption from "this restriction" is bounded to neither. Read
  # wide it licenses the scan to launch agents, which is the frozen cap C36 A9 guards with a leg keyed on a
  # literal that any other phrasing walks past. So the exemption has to name its half and disclaim the other.
  [ "$(n73 "$EPS73" 'second of the two|limit to the task.s own files|own files.{0,4} .{0,4} and still runs')" -ge 1 ] \
    || c15_73="$c15_73 [the exemption does not say which of the two restrictions it is exempt from]"
  [ "$(n73 "$EPS73" 'launches none|no licence|buys no licence|cap on broad Explore agents stands')" -ge 1 ] \
    || c15_73="$c15_73 [the exemption does not disclaim the cap on broad helpers]"
  [ -z "$c15_73" ] && ok "A15 the scan is exempt from the epic-scoped restriction, with its reason" \
                   || bad "A15 the scan is exempt from the epic-scoped restriction, with its reason ($c15_73)"

  # A16 — the two paths that never reach the scan, said rather than left silent. The reason leg is what
  # makes it a rule instead of a note: quick keeps no papers to stage a sighting in, and auto runs no
  # phase to scan from, and those are different reasons for the same outcome.
  c16_73=""
  [ "$(n73 "$SKIP73" '[Ii]cebox|scan')" -ge 1 ] \
    || c16_73="$c16_73 [the skip rules do not say the scan is unreached, leaving a silence]"
  [ "$(n73 "$SKIP73" '([Ii]cebox|scan)[^.]{0,240}(no papers|keeps no|nothing to stage)|(no papers|keeps no|nothing to stage)[^.]{0,240}([Ii]cebox|scan)')" -ge 1 ] \
    || c16_73="$c16_73 [the skip is asserted without the reason it holds for the scan]"
  [ -z "$c16_73" ] && ok "A16 the quick and auto paths are said not to reach the scan, with why" \
                   || bad "A16 the quick and auto paths are said not to reach the scan, with why ($c16_73)"

  # A17 — the skill cites and restates nothing. The absence leg is the same fact A1's home count sees from
  # the other side, and it is kept because it fails for its own reason: A1 reports "other than one
  # document" and this reports which document is the second one.
  c17_73=""
  [ "$(n73 "$SKL73" '[Ii]cebox')" -ge 1 ] \
    || c17_73="$c17_73 [the skill does not cite the scan, so a session running the skill never performs it]"
  [ "$(n73 "$SKL73" 'only the (summary|index|nano) lines|one (summary|index|nano) line per entry')" -eq 0 ] \
    || c17_73="$c17_73 [the skill restates the rule instead of citing it — a second home that will drift]"
  [ -z "$c17_73" ] && ok "A17 the skill cites the scan and restates none of it" \
                   || bad "A17 the skill cites the scan and restates none of it ($c17_73)"

  # ------------------------------------------------------------------------------------------------------
  # A18-A22 were added during the VERIFY phase, from findings the multi-agent review raised against the
  # seventeen above. They are recorded as such rather than folded in silently: the seventeen were generated
  # from the criteria, and these five were generated from what an auditor found the criteria did not cover.
  # One of them (A18's read-only leg) is the only finding in this task that a MUTATION proved: the bound was
  # deleted from the prose and all 735 rows stayed green, byte-identically.
  # ------------------------------------------------------------------------------------------------------

  # A18 — the cross-checkout read: anchored, and bounded read-only at the scan's OWN site. `.worktreeinclude`
  # keeps the icebox bodies with the primary checkout by design, so a front resolving them locally finds an
  # empty directory — and the fail-open branch below would swallow that as "an entry with no body", no-oping
  # the whole mechanism on exactly the checkouts fronts run in. The read-only legs are anchored to INV73F
  # and not to the file: the pre-existing guard greps every `Scope Contract` line and is satisfied by the
  # epic-contract read 160 lines above, so the scan's own bound was pinned by nothing.
  c18_73=""
  [ "$(n73 "$INV73F" '\.ai-flow/icebox')" -ge 1 ] \
    || c18_73="$c18_73 [the body path is not anchored, so a front resolves it against itself]"
  [ "$(n73 "$INV73F" 'both halves|and the bodies|bodies those lines name')" -ge 1 ] \
    || c18_73="$c18_73 [the worktree rule covers the ledger and says nothing about the bodies]"
  [ "$(n73 "$INV73F" 'read-only')" -ge 1 ] \
    || c18_73="$c18_73 [the scan's own read is not bounded read-only]"
  [ "$(n73 "$INV73F" 'never written to|never copied in|never writes there')" -ge 1 ] \
    || c18_73="$c18_73 [the read is called read-only without refusing the write]"
  [ "$(n73 "$INV73F" 'worktreeinclude')" -ge 1 ] \
    || c18_73="$c18_73 [nothing says why the bodies are not local, so the next reader makes them local]"
  [ -z "$c18_73" ] && ok "A18 the scan's cross-checkout read is anchored and bounded read-only" \
                   || bad "A18 the scan's cross-checkout read is anchored and bounded read-only ($c18_73)"

  # A19 — three failures, three answers. The section's own defining defect is that a skipped scan and an
  # empty one read alike; an UNREACHABLE ledger recorded as `0 scanned` is that same defect, and the
  # protocol answered the identical read the opposite way 160 lines above ("say so and stop"). One read with
  # two answers in force is what this row refuses.
  c19_73=""
  [ "$(n73 "$INV73F" 'bod(y|ies)[^.]{0,160}(reported by name|never silently)|(reported by name|never silently)[^.]{0,160}bod')" -ge 1 ] \
    || c19_73="$c19_73 [a body absent at the main checkout is not reported by name]"
  [ "$(n73 "$INV73F" 'zero scanned')" -ge 1 ] \
    || c19_73="$c19_73 [an absent or empty section is not answered]"
  [ "$(n73 "$INV73F" 'cannot be reached[^.]{0,200}(not zero|stop)|(not zero|say so and stop)[^.]{0,200}cannot be reached')" -ge 1 ] \
    || c19_73="$c19_73 [an unreachable ledger falls through to zero scanned, which is the wrong record]"
  [ -z "$c19_73" ] && ok "A19 the scan's three failures do not read alike" \
                   || bad "A19 the scan's three failures do not read alike ($c19_73)"

  # A20 — the log's line shape, which is the substrate A12's two counts and A13's signal are computed over.
  # A7 pins the five verbs and A10 pins that lines are appended, so without this the format can go and the
  # log becomes free-form prose that nothing can count.
  c20_73=""
  [ "$(n73 "$ICE73F" 'YYYY-MM-DD')" -ge 1 ] \
    || c20_73="$c20_73 [the log line carries no date field]"
  [ "$(n73 "$ICE73F" 'YYYY-MM-DD[^.]{0,80}T-')" -ge 1 ] \
    || c20_73="$c20_73 [the log line does not carry the task beside the date, so a sighting is unattributable]"
  [ "$(n73 "$ICE73F" 'per encounter')" -ge 1 ] \
    || c20_73="$c20_73 [the log is not one line per encounter, so the counts have no unit]"
  [ -z "$c20_73" ] && ok "A20 the log line has the shape the counts are computed over" \
                   || bad "A20 the log line has the shape the counts are computed over ($c20_73)"

  # A21 — the two-deferral signal's other half. The ledger states the rule and names the SCAN as its actor,
  # so the scan's own home must carry the report and the artifact must have somewhere to put it. Found
  # half-shipped: the rule was written and the scan was silent, with every row green.
  c21_73=""
  [ "$(n73 "$INV73F" '(two|second) deferrals?|second .deferred. line')" -ge 1 ] \
    || c21_73="$c21_73 [the scan is never told to notice a second deferral]"
  [ "$(n73 "$INV73F" '((two|second) deferrals?|second .deferred. line)[^.]{0,240}(says so|reports)')" -ge 1 ] \
    || c21_73="$c21_73 [the scan notices it and is not told to report it]"
  [ "$(n73 "$TPL73" 'deferred twice')" -ge 1 ] \
    || c21_73="$c21_73 [the artifact has no slot to report it into, so the signal dies with the session]"
  [ -z "$c21_73" ] && ok "A21 the scan reports the two-deferral signal and the artifact carries it" \
                   || bad "A21 the scan reports the two-deferral signal and the artifact carries it ($c21_73)"

  # A22 — the taken branch, bounded. An entry entering an in-flight task's scope is the one route out of the
  # ledger with no operator in the room, and this engine counts those doors exactly — the commit immediately
  # before this task removed a third one. So the branch has to say it mints nothing and promotes nothing.
  c22_73=""
  [ "$(n73 "$INV73F" 'never promoting|not promoting|never a promotion')" -ge 1 ] \
    || c22_73="$c22_73 [taking an entry is not distinguished from promoting it to a task]"
  [ "$(n73 "$INV73F" 'mints no|chooses no priority')" -ge 1 ] \
    || c22_73="$c22_73 [the branch does not refuse the identifier and the priority a promotion would need]"
  [ "$(n73 "$INV73F" 'ownership rule|its ground is inside this task')" -ge 1 ] \
    || c22_73="$c22_73 [the taken branch cites no rule bounding what it may take]"
  [ -z "$c22_73" ] && ok "A22 taking an entry is bounded and is not a promotion" \
                   || bad "A22 taking an entry is bounded and is not a promotion ($c22_73)"
fi
