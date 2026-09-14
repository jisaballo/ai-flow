# =====================================================================================================
# C94 -- verify receives the task's context files as one list, and says when the repository one is absent
#
# Generated in the Conform phase from understand.md's Verifiable Criteria; every row is RED until the
# skill passes the list, the workflow reads it, and the absence is declared in both channels.
#
# Three house rules apply here and a row that breaks one is hollow whatever it prints:
#
#   1. Verdicts come from a COUNT inside an EXTRACTED REGION, never from a file-wide grep. The skill,
#      the workflow and the protocol all say these words elsewhere, which is how `steeringPath` came to
#      be believed present on an auditor that never received it (C57's own comment records it).
#   2. A2 is an ABSENCE leg, so it is paired with a PRESENCE control over the SAME corpus and the SAME
#      machinery, and the corpus is asserted populated before either verdict is read. "the retired names
#      are gone" and "the corpus emptied and nothing was read" are otherwise the same green row.
#   3. This block's own file is excluded from the corpus BY NAME: it states both retired names in the
#      pattern below, so a corpus holding it can never go empty of them.
# =====================================================================================================
echo ""
echo "== C94: verify receives the task's context files as one list =="

SKV94="global/skills/verify/SKILL.md"
VW94="global/workflows/verify-review.js"
VP94="global/protocols/verify.md"
SELF94="test/sections/C94-verify-receives-the-tasks-context.sh"

n94() { printf '%s' "$2" | grep -ciE "$1" | tr -d ' '; }
# The same machinery both legs of A2 run on. Two calls differing only in their pattern is what makes the
# presence control a control: a control run by other means proves nothing about the leg it guards.
sw94() { printf '%s\n' "$CORP94" | tr '\n' '\0' | (cd "$ROOT" && xargs -0 grep -lIE -- "$1" 2>/dev/null) | sort -u; }
cnt94() { printf '%s\n' "$1" | grep -c . | tr -d ' '; }

c94_readable=1
for f94 in "$SKV94" "$VW94" "$VP94"; do
  { [ -r "$ROOT/$f94" ] && [ -s "$ROOT/$f94" ]; } || c94_readable=0
done

if [ "$c94_readable" -eq 0 ]; then
  bad "C94's three documents are all readable and non-empty"
else
  # The skill's two channels, and the report template's one home. Extracted the way C57 extracts them,
  # because the same words appear in neighbouring steps of the same file.
  S7_94="$(awk '/^7\. \*\*Invoke/{f=1} f && /^8\. /{exit} f' "$ROOT/$SKV94")"
  S10_94="$(awk '/^10\. \*\*Write/{f=1} f && /^11\. /{exit} f' "$ROOT/$SKV94")"
  ARGH94="$(awk '/^\/\/ args \(from the/{f=1} f && /^let a = args/{exit} f' "$ROOT/$VW94")"
  TPL94="$(awk '/^\*\*Audited\*\*:/{f=1} f && /^## /{exit} f' "$ROOT/$VP94")"

  # ---- A1: the call names the context list on both sides -------------------------------------------
  # Both halves, because one side naming it is a call nothing on the other side receives.
  a1_94=""
  [ -n "$S7_94" ]  || a1_94="$a1_94 [step 7 could not be extracted]"
  [ -n "$ARGH94" ] || a1_94="$a1_94 [the workflow's args header could not be extracted]"
  [ "$(n94 'contextPaths' "$S7_94")"  -ge 1 ] || a1_94="$a1_94 [step 7 does not name the list]"
  [ "$(n94 'contextPaths' "$ARGH94")" -ge 1 ] || a1_94="$a1_94 [the args header does not name the list]"
  [ -z "$a1_94" ] && ok  "A1 the call names the context list on both sides" \
                  || bad "A1 the call names the context list on both sides:$a1_94"

  # ---- A2: the retired names are gone, and the new one stands where they stood ----------------------
  # Rule 2 above. The corpus is git's own list minus this file; `.ai-flow/` is gitignored here, so the
  # archive is out of it by construction rather than by a filter that could be written wrongly.
  CORP94="$(cd "$ROOT" && git ls-files 2>/dev/null | grep -vxF "$SELF94")"
  GONE94="$(sw94 'steeringPath|claudeMdPath')"
  HERE94="$(sw94 'contextPaths')"
  a2_94=""
  [ "$(cnt94 "$CORP94")" -ge 1 ] || a2_94="$a2_94 [the corpus is empty — nothing was read]"
  [ "$(cnt94 "$GONE94")" -eq 0 ] || a2_94="$a2_94 [retired names survive in: $(printf '%s' "$GONE94" | tr '\n' ' ')]"
  # The floor is a floor, never a census: below it the sweep has plainly stopped reading, and a census
  # written here would be a second statement of the homes row the card already computes.
  [ "$(cnt94 "$HERE94")" -ge 4 ] || a2_94="$a2_94 [the presence control found the new name in $(cnt94 "$HERE94") files]"
  [ -z "$a2_94" ] && ok  "A2 the retired names are gone and the new one stands where they stood" \
                  || bad "A2 the retired names are gone and the new one stands where they stood:$a2_94"

  # ---- A3: an absent workspace entry is declared in both channels -----------------------------------
  # Three homes, all required: the run's own output at step 7, the report at step 10, and the template
  # that shapes that report. A line promised in the skill and absent from the template is a promise the
  # next editor of the template deletes without knowing it existed.
  a3_94=""
  [ -n "$S10_94" ] || a3_94="$a3_94 [step 10 could not be extracted]"
  [ -n "$TPL94" ]  || a3_94="$a3_94 [the report template could not be extracted]"
  [ "$(n94 'workspace' "$S7_94")" -ge 1 ] || a3_94="$a3_94 [step 7 never names the reserved entry]"
  # The alternatives tolerate an inline code span around the key, which is how this repository spells it
  # everywhere else. Tolerating the span does not weaken the leg: with no absent case stated at all, none
  # of the four alternatives matches, and the row is red exactly as before.
  [ "$(n94 'holds no .?workspace|holds none|without a .?workspace|no .?workspace.? entry' "$S7_94")" -ge 1 ] \
    || a3_94="$a3_94 [step 7 states no absent case]"
  [ "$(n94 'declare|what to declare' "$S7_94")" -ge 1 ] \
    || a3_94="$a3_94 [step 7's absent case names no remedy]"
  [ "$(n94 'contextPaths|context list|context files' "$S10_94")" -ge 1 ] \
    || a3_94="$a3_94 [step 10 records no context list]"
  [ "$(n94 'workspace' "$S10_94")" -ge 1 ] || a3_94="$a3_94 [step 10 owes no line for the absent case]"
  [ "$(n94 'workspace' "$TPL94")" -ge 1 ]  || a3_94="$a3_94 [the report template carries no such line]"
  [ -z "$a3_94" ] && ok  "A3 an absent workspace entry is declared in both channels" \
                  || bad "A3 an absent workspace entry is declared in both channels:$a3_94"

  # ---- A4: a present workspace entry writes no such line --------------------------------------------
  # A3's other half, and unprovable from A3 alone: prose stating the absent case is satisfied by prose
  # that ALSO writes the line when the entry is there, which is the one outcome "exactly when absent"
  # rules out. Asserted over the same region, by the same machinery, for the same reason A2's control is.
  a4_94=""
  [ -n "$S7_94" ] || a4_94="$a4_94 [step 7 could not be extracted]"
  [ "$(n94 'holds one|where it holds a|entry exists|neither line|no such line' "$S7_94")" -ge 1 ] \
    || a4_94="$a4_94 [step 7 never states that a present entry writes nothing]"
  [ -z "$a4_94" ] && ok  "A4 a present workspace entry writes no such line" \
                  || bad "A4 a present workspace entry writes no such line:$a4_94"
fi
