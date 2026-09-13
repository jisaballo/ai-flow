# C36 — the scoping pass measures the frame before the suspect, and the phase says what it never delegates.
# Generated in the Conform phase from understand.md's Verifiable Criteria A1-A9; A10 was added in Verify,
# after inspection alone had already missed the clause it guards once, in the very task that introduced it.
#
# Every verdict is derived from a COUNT inside an extracted region, never from a `grep -v` inside an `if`.
# The hazard is NOT BSD grep, which exits 1 on empty input: it is the search tool a session substitutes
# into its shell, which exits 0 — so the shape is safe here and unsafe in a command an agent types.
#
# THE ROWS BELOW WERE SIZED BY MUTATION, not by reading, and seven of them were rewritten because the
# first draft survived the mutation it existed to catch. What each row pins is therefore the IMPERATIVE or
# the PROHIBITION, never a load-bearing noun: `named suspect` is present whether the prose forbids
# inspecting it or orders it, and `survived` was present in a neighbouring sentence, so deleting the whole
# directive left the row green. A row that pins a word its own rule shares with the rule's negation cannot
# tell a pass from a fail.
echo "== C36: the first measurement can break the question, and the convergence is never delegated =="
UND36="global/protocols/understand.md"
SKL36="global/skills/understand/SKILL.md"

# `-r` and `-s`, not `-f`: a mode-000 or truncated protocol satisfies `-f`, and the rows would then report
# nine deletions of prose that is in fact present. The engine's own rule is that a check which cannot run
# says so, rather than answering as if it had.
if [ -r "$UND36" ] && [ -r "$SKL36" ] && [ -s "$UND36" ] && [ -s "$SKL36" ]; then
  UNDT36="$(cat "$UND36")"
  SKLT36="$(cat "$SKL36")"
  # The investigation block, extracted by its own heading. `/^## Investigation$/` is anchored so the
  # `## Investigation Closure` gate further down does NOT re-open the region — which is exactly why the
  # gate needs its own row (A6 leg 3) rather than being covered by this one.
  INV36="$(awk '/^## Investigation$/{f=1;next} /^## /{f=0} f' "$UND36")"
  # The closure gate, its own region, because the clause it carries is the operative one.
  CLO36="$(awk '/^## Investigation Closure/{f=1;next} /^## /{f=0} f' "$UND36")"
  # The epic cap's home section, so relocating the sentence out of it cannot keep the row green.
  EPI36="$(awk '/^## Epic-Scoped Understanding$/{f=1;next} /^## /{f=0} f' "$UND36")"
  # The artifact template, extracted by its fence rather than by line number so an insertion above it
  # cannot silently move the region out from under these rows.
  TPL36="$(awk '/^## Output: understand.md$/{f=1} f && /^```markdown$/{g=1;next} g && /^```$/{exit} g' "$UND36")"

  n36() { printf '%s' "$1" | grep -ciE "$2" | tr -d ' '; }

  # Every extracted region is asserted non-empty by its own row, the house style of C24: a renamed heading
  # must fail as a renamed heading, not as six simultaneous reports that the prose was deleted.
  r36=""
  [ -n "$INV36" ] || r36="$r36 [the investigation block did not extract — heading renamed?]"
  [ -n "$CLO36" ] || r36="$r36 [the closure gate did not extract]"
  [ -n "$EPI36" ] || r36="$r36 [the epic-scoped section did not extract]"
  [ -n "$TPL36" ] || r36="$r36 [the artifact template did not extract — fence changed?]"
  [ -z "$r36" ] && ok "C36's four regions all extract" || bad "C36's four regions all extract ($r36)"

  # A1 — the altitude rule, pinned by the obligation and not by its subject.
  c1_36=""
  [ "$(n36 "$INV36" 'must be able to falsif(y|ies|ying) the framing')" -ge 1 ] || c1_36="$c1_36 [nothing requires the first measurement to be able to falsify the framing]"
  [ -z "$c1_36" ] && ok "A1 the scoping pass requires a first measurement that can falsify the framing of the question" \
                  || bad "A1 the scoping pass requires a first measurement that can falsify the framing of the question ($c1_36)"

  # A2 — the PROHIBITION, not the noun. `named suspect` is present whether the prose forbids inspecting it
  # first or orders it; deleting two words inverted the rule and the first draft of this row stayed green.
  c2_36=""
  [ "$(n36 "$INV36" 'measure the whole')" -ge 1 ] || c2_36="$c2_36 [the whole is never named as what the first measurement covers]"
  [ "$(n36 "$INV36" 'do not inspect the named suspect')" -ge 1 ] || c2_36="$c2_36 [inspecting the suspect the task named is not refused]"
  [ -z "$c2_36" ] && ok "A2 a task arriving with a diagnosis attached is measured whole before its named part" \
                  || bad "A2 a task arriving with a diagnosis attached is measured whole before its named part ($c2_36)"

  # A3 — the rule as a rule. Its two load-bearing words in one region were satisfiable by disjoint
  # sentences: the headline could go while a neighbouring sentence carried both words and stated nothing.
  c3_36=""
  [ "$(n36 "$INV36" 'convergence is never delegated')" -ge 1 ] || c3_36="$c3_36 [the phase does not state that the convergence is never delegated]"
  [ "$(n36 "$INV36" 'answers the question it was given')" -ge 1 ] || c3_36="$c3_36 [the reason — an agent answers the question it was given — is gone]"
  [ -z "$c3_36" ] && ok "A3 the phase states that the convergence is never delegated" \
                  || bad "A3 the phase states that the convergence is never delegated ($c3_36)"

  # A4 — the IMPERATIVE. `survived` also occurs in the provenance bullet, so the first draft of this row
  # stayed green with the entire directive sentence deleted: it had zero discriminating power.
  c4_36=""
  [ "$(n36 "$INV36" 'delegate a fan-out whose question has survived')" -ge 1 ] || c4_36="$c4_36 [nothing requires a question to have survived measurement before a fan-out]"
  [ "$(n36 "$INV36" 'while the question is still moving, investigate inline')" -ge 1 ] || c4_36="$c4_36 [the unripe question is not directed inline]"
  [ -z "$c4_36" ] && ok "A4 a fan-out waits for a question that survived one round of measurement" \
                  || bad "A4 a fan-out waits for a question that survived one round of measurement ($c4_36)"

  # A5 — the repair, in both directions, and the false framing pinned by SHAPE rather than by one literal:
  # `costs a few minutes` reintroduced it verbatim in meaning past a leg that pinned the exact sentence.
  # The token axis is refused HERE, over the protocol, because that is where the decision applies — the
  # skill never had a cost clause to repair. A later task that means to revisit that decision changes this
  # row deliberately; that is the point of pinning a decision rather than a wording.
  c5_36=""
  [ "$(n36 "$UNDT36" 'costs? (a few |several |some )?minutes')" -eq 0 ] || c5_36="$c5_36 [an investigation agent is priced in minutes again]"
  [ "$(n36 "$INV36" 'not a price paid for prudence')" -ge 1 ] || c5_36="$c5_36 [the sentence that denies the prudence framing is gone]"
  [ "$(n36 "$UNDT36" 'tok/turn|cheaper per turn|[0-9]x cheaper|subagents? (are|run) .{0,20}cheaper')" -eq 0 ] || c5_36="$c5_36 [a token-measured licence to delegate was minted, which this task's decision refused]"
  [ "$(n36 "$INV36" 'invalidates the plan')" -ge 1 ] || c5_36="$c5_36 [the true half went out with the false one: nothing says an unresolved area invalidates the plan]"
  [ -z "$c5_36" ] && ok "A5 no investigation agent is priced as a cost accepted for prudence, and the true half survived" \
                  || bad "A5 no investigation agent is priced as a cost accepted for prudence, and the true half survived ($c5_36)"

  # A6 — provenance, in the doctrine AND in the gate. The gate is the third copy of this clause and the one
  # that blocks the write: two auditors found it independently, and the region above cannot see it.
  c6_36=""
  [ "$(n36 "$INV36" 'first-hand')" -ge 1 ] || c6_36="$c6_36 [a fact read first-hand is not distinguished from a finding an agent reported]"
  [ "$(n36 "$INV36" 'lead, not evidence')" -ge 1 ] || c6_36="$c6_36 [nothing says what an answer to an unripe question is worth]"
  [ "$(n36 "$UNDT36" 'evidence \(file:line or agent finding\)')" -eq 0 ] || c6_36="$c6_36 [the collapsed form is still stated somewhere in the document]"
  [ "$(n36 "$CLO36" 'provenance')" -ge 1 ] || c6_36="$c6_36 [the closure gate accepts evidence without naming its provenance]"
  [ -z "$c6_36" ] && ok "A6 what closes an unknown names whether it was read first-hand or reported by an agent" \
                  || bad "A6 what closes an unknown names whether it was read first-hand or reported by an agent ($c6_36)"

  # A7 — the skill is an independent copy, so it carries both rules, each pinned separately: an alternation
  # accepted half the altitude rule. Leg 3 pins only the repaired sentence's own wording — the measured
  # framing is TRUE and forbidding it here would freeze out a correct future edit rather than guard a rule.
  c7_36=""
  [ "$(n36 "$SKLT36" 'falsif(y|ies|ying) the framing')" -ge 1 ] || c7_36="$c7_36 [the skill mandates the pass without the rule governing its first measurement]"
  [ "$(n36 "$SKLT36" 'measure the whole')" -ge 1 ] || c7_36="$c7_36 [the skill does not say to measure the whole]"
  [ "$(n36 "$SKLT36" 'convergence is never delegated')" -ge 1 ] || c7_36="$c7_36 [the skill carries the delegation trigger with no counterweight]"
  [ "$(n36 "$SKLT36" 'costs? (a few |several )?minutes')" -eq 0 ] || c7_36="$c7_36 [the skill acquired a copy of the repaired sentence]"
  [ -z "$c7_36" ] && ok "A7 the phase skill carries both rules and prices no agent" \
                  || bad "A7 the phase skill carries both rules and prices no agent ($c7_36)"

  # A8 — the trace field, each leg pinned to the region that carries it. The first draft rested the whole
  # conditionality claim on the two words `not written` grepped over the entire document, with two of its
  # three alternatives matching nothing at all.
  c8_36=""
  [ "$(n36 "$TPL36" '^## Altitude')" -ge 1 ] || c8_36="$c8_36 [the artifact template records no first measurement]"
  [ "$(n36 "$TPL36" 'could have falsified')" -ge 1 ] || c8_36="$c8_36 [the field does not ask what the measurement could have falsified]"
  [ "$(n36 "$TPL36" 'omitted otherwise')" -ge 1 ] || c8_36="$c8_36 [the template does not mark the field conditional]"
  [ "$(n36 "$INV36" 'the field is not written')" -ge 1 ] || c8_36="$c8_36 [the scoping pass never says the field is left out where no diagnosis arrived]"
  [ "$(n36 "$TPL36" 'EARS')" -ge 1 ] || c8_36="$c8_36 [the criteria format anchor left the template — the only assertion for it matched a heading outside the fence]"
  [ -z "$c8_36" ] && ok "A8 the artifact template carries the first measurement, and only where a diagnosis arrived attached" \
                  || bad "A8 the artifact template carries the first measurement, and only where a diagnosis arrived attached ($c8_36)"

  # A9 — FROZEN ROW, green from the start, and the only row here whose whole value is that a mutation kills
  # it. Both legs are proven: softening either sentence kills it. Each is pinned to the section that must
  # carry it, and the criterion says "removed OR QUALIFIED" — so the qualification is pinned too, which the
  # first draft could not see: `no broad Explore agents unless the Scope Contract is stale` passed it.
  c9_36=""
  [ "$(n36 "$EPI36" 'do NOT relaunch broad Explore agents')" -ge 1 ] || c9_36="$c9_36 [the epic-scoped prohibition is gone from its own section]"
  [ "$(n36 "$INV36" 'no broad Explore agents')" -ge 1 ] || c9_36="$c9_36 [the skip rules no longer carry the cap]"
  [ "$(n36 "$UNDT36" 'broad Explore agents,? (unless|except|save where|other than)')" -eq 0 ] || c9_36="$c9_36 [the cap acquired an exception, which is the reading this task must not license]"
  [ -z "$c9_36" ] && ok "A9 the cap on broad helpers in an epic's later tasks is intact" \
                  || bad "A9 the cap on broad helpers in an epic's later tasks is intact ($c9_36)"

  # A10 — a genuine cross-document comparison, which the first draft's label claimed and its legs never
  # made: both legs read the skill alone. What it pins is that the two copies of one clause agree, so a
  # repair applied to one and not the other goes red. This is T-041's hazard, guarded rather than trusted.
  c10_36=""
  ph36="$(n36 "$INV36" 'first-hand')"; sh36="$(n36 "$SKLT36" 'first-hand')"
  [ "$ph36" -eq 0 ] || [ "$sh36" -ge 1 ] || c10_36="$c10_36 [the protocol names provenance and the skill does not]"
  [ "$sh36" -eq 0 ] || [ "$ph36" -ge 1 ] || c10_36="$c10_36 [the skill names provenance and the protocol does not]"
  [ "$(n36 "$SKLT36" 'lead, not evidence')" -ge 1 ] || c10_36="$c10_36 [the skill does not say what an answer to an unripe question is worth]"
  [ -z "$c10_36" ] && ok "A10 the skill and the protocol agree on what closes an unknown" \
                   || bad "A10 the skill and the protocol agree on what closes an unknown ($c10_36)"
else
  bad "C36 cannot run: the understand protocol or its phase skill is missing, unreadable or empty"
fi
