# C58 — a fifth axis judges the design itself, and the header keeps every reviewer blunt.
# Generated in the Conform phase from understand.md's Verifiable Criteria.
#
# The three shapes C57's header names are kept here for the same reasons: a verdict is a COUNT inside an
# extracted REGION, never a bare file-wide grep — the workflow says "auditor", "schema" and "structure"
# in a dozen places that are not the ones under audit; where a rule has a positive and a negative half
# BOTH are asserted, because the positive alone is satisfied by prose that also permits what the rule
# forbids; and no pattern below uses a bounded proximity repeat, per the standing entry IB-012, which
# `ugrep` refuses under -i over UTF-8 with a complexity error that reaches the row as an empty count
# rather than as a failure. Every discriminator here is a literal or an alternation of literals.
#
# One reach is deliberately NOT asserted here. That all five auditor prompts and the refuter inherit the
# shared header is already the subject of Fact 3b above, which this task's first step moves from four to
# five. A second copy of that count is the restatement this engine's own architecture list names first,
# and the two would drift toward disagreeing about how many auditors there are — which is precisely the
# defect this task exists to close. A3 below asserts only what is new: the clause itself, stated once,
# and kept away from the prover.
echo "== C58: a fifth axis judges the design itself, and the header keeps every reviewer blunt =="

SKV83="global/skills/verify/SKILL.md"
VP83="global/protocols/verify.md"
LC83="global/protocols/lifecycle.md"
RD83="README.md"
DOC83="docs/customization.md"
TPL83="template/.ai-flow/project.yml"

n83() { printf '%s\n' "$2" | grep -ciE "$1" | tr -d ' '; }

c58_readable=1
for f83 in "$VW83" "$SKV83" "$VP83" "$LC83" "$RD83" "$DOC83" "$TPL83"; do
  [ -r "$f83" ] || { bad "C58 cannot run: $f83 is unreadable"; c58_readable=0; }
done

if [ "$c58_readable" = "1" ]; then

  CTX83="$(awk '/^const ctx = \[/{f=1;next} /^\]\.join/{f=0} f' "$VW83")"
  FS83="$(awk '/^const FINDINGS_SCHEMA = \{/{f=1;next} /^\}$/{f=0} f' "$VW83")"
  STRUCT83="$(awk "/^[[:space:]]+key: 'structure'/{f=1} f && /^  \},/{exit} f" "$VW83")"
  # The exit is guarded by `f`, or it fires on the first top-level `}` in the file — which closes the
  # SHARED schema, sixty lines above this one, and the region comes back empty.
  SFS83="$(awk '/^const STRUCTURE_FINDINGS_SCHEMA = \{/{f=1;next} f && /^\}$/{exit} f' "$VW83")"
  PRV83="$(awk '/const provePrompt = \[/{f=1;next} f && /^  \]\.join/{exit} f' "$VW83")"
  S7_83="$(awk '/^7\. \*\*Invoke/{f=1} f && /^8\. /{exit} f' "$SKV83")"

  # ---- A1: the review defines five dimensions, and one of them is this axis ------------------------
  # The count is read off the array's own `key:` lines rather than off any prose about it: a description
  # that says five while the array holds four is the defect with the arithmetic corrected, and it is the
  # exact shape eight files carrying one count have already produced once.
  a1_83=""
  [ -n "$DIM83" ] || a1_83="$a1_83 [the DIMENSIONS array could not be extracted]"
  [ "$k83" = "5" ] || a1_83="$a1_83 [the review defines $k83 auditor dimensions, not five]"
  [ "$(n83 "key: 'structure'" "$DIM83")" -ge 1 ] || a1_83="$a1_83 [no dimension is keyed structure]"
  [ "$(n83 'Simplicity & Structure' "$DIM83")" -ge 1 ] \
    || a1_83="$a1_83 [the fifth axis is not labelled Simplicity & Structure]"
  [ -z "$a1_83" ] && ok "A1 the review defines five auditor dimensions and one of them is the structure axis" \
                  || bad "A1 the review defines five auditor dimensions and one of them is the structure axis:$a1_83"

  # ---- A2: the strict schema belongs to that axis ALONE --------------------------------------------
  # Three legs pulling in different directions, because a structural finding that names no remedy leaves
  # the author guessing and a strict schema applied to all five would make every auditor drop findings it
  # cannot write a fix for. So: the STRICT schema requires the fix inside its own region; the SHARED one
  # still does not; exactly one dimension declares a schema of its own; and the call site actually reads
  # it. The leg that carries the row is the one naming the VALUE — `schema: STRUCTURE_FINDINGS_SCHEMA` —
  # because every other leg is answered just as happily by `schema: FINDINGS_SCHEMA` on that same line,
  # which is the whole of the composition this row exists to prove. A file-wide `required:` count was the
  # first form and it certified the orphaned const, not the axis.
  a2_83=""
  [ -n "$FS83" ] || a2_83="$a2_83 [the shared findings schema could not be extracted]"
  [ -n "$SFS83" ] || a2_83="$a2_83 [the strict schema could not be extracted]"
  [ "$(printf '%s\n' "$SFS83" | grep -E 'required:' | grep -c 'suggestedFix' | tr -d ' ')" -ge 1 ] \
    || a2_83="$a2_83 [the strict schema does not require suggestedFix]"
  [ "$(printf '%s\n' "$FS83" | grep -E 'required:' | grep -c 'suggestedFix' | tr -d ' ')" = "0" ] \
    || a2_83="$a2_83 [the shared schema requires suggestedFix, so all five axes are held to it]"
  s83="$(printf '%s\n' "$DIM83" | grep -cE '^[[:space:]]+schema: ' | tr -d ' ')"
  [ "$s83" = "1" ] || a2_83="$a2_83 [$s83 dimensions declare a schema of their own, not one]"
  [ "$(n83 'schema: STRUCTURE_FINDINGS_SCHEMA' "$STRUCT83")" -ge 1 ] \
    || a2_83="$a2_83 [the structure axis does not hold the strict schema]"
  grep -qE 'schema: d\.schema' "$VW83" \
    || a2_83="$a2_83 [the call site passes a fixed schema, so a dimension's own is never read]"
  [ -z "$a2_83" ] && ok "A2 the structure axis alone is held to a schema that requires a named fix" \
                  || bad "A2 the structure axis alone is held to a schema that requires a named fix:$a2_83"

  # ---- A3: the honesty clause, stated once, and withheld from the prover ---------------------------
  # The refutation stage is paid to knock findings down and nothing balances it — 47% of HIGH findings
  # were refuted or downgraded — so an auditor that under-calls leaves no trace at all, where a false
  # positive costs a visible triage. The `pad` leg counts rather than finds: the clause ABSORBS the
  # sentence already in the header, and two statements of one rule in one header is the restatement this
  # engine's own architecture list names first. The prover leg is the negative half: it reports what a
  # run did and is asked for no judgment, so a clause telling it how to judge does not belong to it.
  a3_83=""
  [ -n "$CTX83" ] || a3_83="$a3_83 [the shared header could not be extracted]"
  [ "$(n83 'soften' "$CTX83")" -ge 1 ] || a3_83="$a3_83 [the header does not forbid softening a real problem]"
  [ "$(n83 'quantif' "$CTX83")" -ge 1 ] || a3_83="$a3_83 [the header does not ask for quantification]"
  [ "$(n83 'high-conviction|high conviction' "$CTX83")" -ge 1 ] \
    || a3_83="$a3_83 [the header does not prefer a few high-conviction findings to a long list]"
  p83="$(n83 "don't pad|do not pad" "$CTX83")"
  [ "$p83" = "1" ] || a3_83="$a3_83 [the padding rule is stated $p83 times in the header, not once]"
  [ -n "$PRV83" ] || a3_83="$a3_83 [the prover's prompt could not be extracted]"
  [ "$(n83 'soften|high-conviction' "$PRV83")" = "0" ] \
    || a3_83="$a3_83 [the prover was handed the honesty clause; it reports what a run did and judges nothing]"
  [ -z "$a3_83" ] && ok "A3 the honesty clause is stated once in the header the auditors and the skeptic read" \
                  || bad "A3 the honesty clause is stated once in the header the auditors and the skeptic read:$a3_83"

  # ---- A4: every shipped document names the CURRENT count, and no other ----------------------------
  # Eight files carry this one count and nothing had ever asserted they agree. The count is derived from
  # the DIMENSIONS array (`k83`, computed by A1) rather than written here, because a row pinned to the
  # four-to-five transition goes green on documents still saying five the day a sixth axis lands — the
  # same defect one transition later. So: the current count must appear, and every other count in the
  # range must not. `4-auditor` is why the shapes carry the hyphen: the first form of this row missed a
  # hyphenated singular in README's layout block and reported green over a page naming both counts.
  #
  # One loop, not a loop beside a hand-copied branch. The template differs only in its presence
  # discriminator — it has no prose, just commented example axis keys — so that is what the table varies.
  # `simplicity` is the discriminator for the other six rather than `structure`: they already say
  # "structure" about directories and about prose, and none says "simplicity".
  a4_83=""
  # ---- The homes sweep: one marker per concept, and the corpus every marker runs over ---------------
  # This machinery sits here, inside the auditor-count check, for one reason: the auditor marker IS the
  # count shapes built just above, and a second copy of those shapes is precisely the drift the card's
  # homes table exists to end. The legs that consume it live with the card, further down.
  #
  # The corpus is what the repository TRACKS, minus this file. The suite names every marker by
  # construction, so leaving it in would place it in five of the six sweeps and make every row false. The
  # exclusion runs through a named constant rather than an inline literal, so that it is visible in the
  # guard rather than performed silently — a sweep that quietly skipped a file would be the same silence
  # the table used to be.
  # Every file the suite is made of, repo-relative. Excluding ONE of its seventy-six would not be
  # excluding the suite: the harness names every concept it audits, so a sweep that reads any part of it
  # reports that part as a home of all of them.
  # The axis names, derived from the same array k83 above is counted from — one source for the count and
  # for the names, so a sixth axis reaches every marker that needs it without an edit anywhere here.



  # The documents are COMPUTED, never enumerated. This list was hand-written until it was measured against
  # the sweep above and found to agree — and agreement proves the sweep, not the list: what a hand list
  # omits is exactly what nobody remembered to add, so it can only ever be wrong in the direction nothing
  # detects. A floor and two anchors come first, because a sweep returning nothing satisfies every leg
  # below it in silence and reads in a report exactly like a guard that passed.
  # The marker's stale half selects nothing while every home is current, so no leg below reads it and it
  # can be deleted with the suite green — and with it goes the one behaviour it exists for: a document
  # naming an obsolete count must stay IN the set, to be failed by the count leg rather than vanish from
  # it. Anchored to the marker line, which the assertion's own line cannot match.
  grep -qE "^      sweep89 i \"\\\$now83[|]\\\$stale83\" ;;\$" $SUITE_SRC \
    || a4_83="$a4_83 [the auditor marker no longer sweeps stale counts, so a stale home would leave the set]"
  DOCS83="$(marker89 "Auditor list")"
  nd83="$(printf '%s\n' "$DOCS83" | grep -c . | tr -d ' ')"
  [ "$nd83" -ge 2 ] || a4_83="$a4_83 [the auditor-document sweep found $nd83 documents]"
  for anc83 in "$VW83" "$SKV83"; do
    printf '%s\n' "$DOCS83" | grep -qxF "$anc83" || a4_83="$a4_83 [$anc83 is not in the swept set]"
  done
  while IFS= read -r d83; do
    [ -n "$d83" ] || continue
    if ! b83="$(tr '\n' ' ' < "$ROOT/$d83" 2>/dev/null)"; then
      a4_83="$a4_83 [unreadable: $d83]"; continue
    fi
    [ "$(n83 "$stale83" "$b83")" = "0" ] || a4_83="$a4_83 [$d83 names a count that is not $k83]"
    [ "$(n83 "$now83" "$b83")" -ge 1 ]   || a4_83="$a4_83 [$d83 never names the current count of $k83]"
    # One alternation for every document, where the list carried a discriminator per file. A derived set
    # cannot carry one, and the trade is named rather than buried: `simplicity` is what seven of the eight
    # say, `structure:` is the template's, which has no prose at all — so a document swept in later could
    # satisfy this through the weaker branch. The gap fails towards accepting too much, which is the
    # admissible direction; a gap that failed towards protecting too little would not be.
    [ "$(n83 'simplicity|structure:' "$b83")" -ge 1 ] || a4_83="$a4_83 [$d83 never names the fifth axis]"
  done <<< "$DOCS83"
  [ -z "$a4_83" ] && ok "A4 every shipped document names the review's current auditor count, and no other" \
                  || bad "A4 every shipped document names the review's current auditor count, and no other:$a4_83"

  # ---- A5: the axis's list has exactly ONE home ----------------------------------------------------
  # The rule the other four already live by, applied to the fifth on the day it is born: what each axis
  # looks for is stated in the workflow and cited everywhere else. Counted across every readable file
  # under global/, by an alternation of two literal phrases from the list itself — two so a single
  # legitimate rewording does not break the row, literal because a bounded proximity repeat is not
  # portable across greps. Counted with the one-line idiom this file already uses for the same question
  # at :2147 and :2171: both discriminators are single-line literals, so the per-file flatten the longhand
  # form was built around bought nothing but a second idiom for one recurring question.
  # The count sweeps everything the repository TRACKS, not `global/` alone, and it goes through the same
  # corpus every homes marker uses — which is what excludes this file, whose own discriminator line
  # carries both literals and would otherwise take the count to two. Rooted at `global/`, the row said
  # nothing about the documents an adopter reads: `README.md` sits at the repository root, so a front
  # door that restated this axis's list was outside the count entirely, and a comment elsewhere in this
  # suite invoked this row as the protection that covered exactly that case. It could not. It can now.
  #
  # It fingerprints the STRUCTURE axis and no other. The remaining four axes' content is asserted
  # nowhere, in this file or any other: their lists carry no phrase distinctive enough to key on, and a
  # per-axis vocabulary written out here is the hand-built enumeration this suite spent a whole task
  # removing. The gap is named rather than papered over, because the alternative — a guard that claims a
  # reach it does not have — is the defect this widening repairs.
  a5_83=""
  h83="$(sweep89 i 'relocates complexity|earning its keep' | grep -c . | tr -d ' ')"
  [ "$h83" = "1" ] || a5_83="$a5_83 [the structure axis's list is enumerated in $h83 tracked files, not one]"
  [ -z "$a5_83" ] && ok "A5 the structure axis's list is enumerated in exactly one tracked file" \
                  || bad "A5 the structure axis's list is enumerated in exactly one tracked file:$a5_83"

  # ---- A6: the fifth checklist is passed on the same terms as the other four -----------------------
  # C57's A8 already asserts that a checklist path is probed before it is passed, and that leg is not
  # restated here. What is new is that the fifth argument exists, rides the SAME args object as the other
  # four — a checklist resolved into a variable nobody passes is the hole the prover opened once already —
  # and that the prompt on the far end actually reads it.
  a6_83=""
  [ -n "$S7_83" ] || a6_83="$a6_83 [step 7 could not be extracted]"
  [ "$(n83 'structureChecklist' "$S7_83")" -ge 1 ] || a6_83="$a6_83 [structureChecklist is never passed]"
  [ "$(grep -E 'contractChecklist' "$SKV83" | grep -c 'structureChecklist' | tr -d ' ')" -ge 1 ] \
    || a6_83="$a6_83 [the fifth checklist is not in the same args list as the other four]"
  [ "$(n83 'a\.structureChecklist' "$STRUCT83")" -ge 1 ] \
    || a6_83="$a6_83 [the structure prompt never reads the checklist it is handed]"
  [ -z "$a6_83" ] && ok "A6 the fifth checklist is passed on the same terms as the other four and is read" \
                  || bad "A6 the fifth checklist is passed on the same terms as the other four and is read:$a6_83"

  # ---- A7: the severity rule, the remedy vocabulary, and no stack in the generic --------------------
  # This axis surfaces rather than blocks: HIGH is reserved for a change that actively makes the structure
  # worse, because HIGH is what holds the archive gate and a design opinion is not a blocker. The remedy
  # legs are sampled from the vocabulary rather than enumerating it — three literals that no other axis's
  # prompt uses. The last leg is the negative half of the engine's oldest rule about these lists: the
  # reference this axis is drawn from writes its type-boundary check in TypeScript, and a generic list
  # that assumed a stack would ask a prose repository about a stack it is not written in.
  a7_83=""
  [ -n "$STRUCT83" ] || a7_83="$a7_83 [the structure dimension could not be extracted]"
  [ "$(n83 'simpler design' "$STRUCT83")" -ge 1 ] \
    || a7_83="$a7_83 [a finding is not required to arrive with the simpler design proposed]"
  [ "$(n83 'actively makes|only where the change|only when the change' "$STRUCT83")" -ge 1 ] \
    || a7_83="$a7_83 [HIGH is not reserved for a change that makes the structure worse]"
  v83=0
  for w83 in 'dispatcher' 'pass-through' 'canonical helper'; do
    [ "$(n83 "$w83" "$STRUCT83")" -ge 1 ] && v83=$((v83+1))
  done
  [ "$v83" -ge 3 ] || a7_83="$a7_83 [the remedy vocabulary names $v83 of the three sampled moves]"
  [ "$(n83 'typescript|javascript|python' "$STRUCT83")" = "0" ] \
    || a7_83="$a7_83 [the prompt names a language, and the engine's generic lists name none]"
  [ -z "$a7_83" ] && ok "A7 the structure prompt surfaces with a design proposed, reserves HIGH, and names the remedies" \
                  || bad "A7 the structure prompt surfaces with a design proposed, reserves HIGH, and names the remedies:$a7_83"

  # ---- A8: the report carries the fifth axis beside the fourth --------------------------------------
  # An equality with a floor under it. Both counts derive from the report template's own `### ` headings,
  # so a renamed or reflowed template collapses them to 0 and `0 = 0` would certify the fifth axis over
  # zero templates — the negative that opts out on empty input.
  a8_83=""
  arch83="$(grep -c '^### Architecture Boundaries' "$VP83" | tr -d ' ')"
  simp83="$(grep -c '^### Simplicity & Structure' "$VP83" | tr -d ' ')"
  [ "$arch83" -ge 1 ] 2>/dev/null \
    || a8_83="$a8_83 [no report template could be located: $arch83 axis sections found]"
  [ "$simp83" = "$arch83" ] \
    || a8_83="$a8_83 [$simp83 report templates carry the fifth axis, against $arch83 that carry the fourth]"
  [ -z "$a8_83" ] && ok "A8 the report template carries the fifth axis beside the other four" \
                  || bad "A8 the report template carries the fifth axis beside the other four:$a8_83"
fi
