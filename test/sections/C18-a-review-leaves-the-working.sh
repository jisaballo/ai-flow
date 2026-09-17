echo "== C18: a review leaves the working copy as it found it =="
PP="global/protocols/plan.md"
RULE_SECTION="Mutation and the Working Copy"

# The rule's own section, bounded at the next heading and fence-aware — the same shape C14 uses for
# the task-diff definition, and for the same reason: a file-wide grep finds the citations, not the rule.
#
# Extracted ONCE, in line-preserving form, because this file has two consumers of the region and only one
# of them wants it flattened: Facts 1a-1f read `$RULE`, Fact 10 reads `rulelines18` five hundred lines
# below. A second awk stating the same start anchor, fence toggle and terminating-heading rule is two
# statements of one boundary, and an edit to either would leave the two legs judging different regions.
RULE_LINES="$(awk '/^## Mutation and the Working Copy/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^#+ /){f=0} f' "$VP")"
# `printf '%s'` and not `'%s\n'`: an empty region must flatten to the empty string, or every `[ -n "$RULE" ]`
# below reads a lone space as a region that was found.
RULE="$(printf '%s' "$RULE_LINES" | tr '\n' ' ')"

# The workflow's shared prompt header, bounded by the join that closes it: the five auditors and the
# refuter all inherit it, so a fact placed here is a fact every worker reads — and a fact asserted on
# the whole file would pass on the schema, the comments, or a dimension that no longer includes it.
CTX="$(awk "/^const ctx = \[/{f=1;next} /^\]\.join/{f=0} f" "$VW" | tr '\n' ' ')"

# Fact 3k — and the remedy this task DECLINED stays declined. The Scope Contract that produced this work
# named a read-only agent type on the auditor calls as the fix; measured, no available read-only type
# removes the ability to RUN a command, and the incident was an account of a run — so the named fix would
# not have prevented a word of it, and the one type that is read-only declares in its own definition that
# it does not audit. Asserting the ABSENCE is what makes that refusal durable: a paragraph explaining why
# it was declined is deletable with the suite green, and the next reader meets a plausible fix with no
# record of its measure.
#
# Scoped to the option objects of the review's own agent calls, and widened past one spelling: the
# refusal is about a capability restriction, which four different keys express, and a count over the
# whole file would forbid the file from ever explaining the refusal in a comment — which is the one place
# the next reader would look. Derived from a count, never a `grep -v` inside an `if`. The hazard is NOT
# BSD grep, which exits 1 on empty input: it is the search tool a session substitutes into its shell,
# which exits 0. This file is run as a child script and gets the system grep; a command an agent types
# does not, which is the surface where the shape has actually cost a verdict.
RESTRICT_N="$(grep -oE 'agent\([^)]*\{[^}]*\}' "$VW" | grep -cE 'agentType|allowedTools|disallowedTools|subagent_type|tools[[:space:]]*:' | tr -d ' ')"
[ "$RESTRICT_N" = "0" ] \
  && ok "no review agent call carries a capability restriction (found $RESTRICT_N)" \
  || bad "no review agent call carries a capability restriction (found $RESTRICT_N)"

# Fact 4a — the mutation instinct becomes a structured proposal the worker hands over.
FSCHEMA="$(awk '/^const FINDINGS_SCHEMA = \{/{f=1} f&&/^\}$/{print;exit} f' "$VW" | tr '\n' ' ')"
if [ -n "$FSCHEMA" ] && printf '%s' "$FSCHEMA" | grep -q 'proposedMutation'; then
  ok "the findings schema carries a proposed mutation"
else
  bad "the findings schema carries a proposed mutation"
fi

# Byte offset of a fixed string: for the facts that are an ORDER, which presence greps cannot see.
voff() { grep -obF "$2" "$1" | head -1 | cut -d: -f1; }

# The prover's own region, from its anchor to the end of the script.
PROVE="$(awk '/One prover, serialised/{f=1} f' "$VW")"

N_INV="$(grep -nE '^[0-9]+\. \*\*Invoke the verify-review workflow' "$VS" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/')"
N_COPY="$(grep -nE '^[0-9]+\. \*\*Take the byte-exact copy' "$VS" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/')"

# Fact 4c — the field is OPTIONAL. Listed as required, every auditor must invent a mutation for every
# finding, and a fabricated proposal becomes a real file change in the prover's hands — while a grep for
# the field's name stays green either way.
if [ -n "$FSCHEMA" ] && ! printf '%s' "$FSCHEMA" | grep -oE "required: \[[^]]*\]" | grep -q 'proposedMutation'; then
  ok "the proposed mutation is optional, not required of every finding"
else
  bad "the proposed mutation is optional, not required of every finding"
fi

# Fact 10 — the template ships no copy of the rule. It carries project data only; a copy there would be
# a second home nothing keeps in step.
#
# The key is DERIVED FROM THE RULE, never written here. This leg used to grep template/ for the literal
# `never modifies what it audits`, and as an absence keyed on a phrase it failed both ways: reword the
# rule in global/ and the leg went on searching for words the engine no longer used, so a copy carrying
# the NEW wording passed unseen; and the pin was the whole check, so nothing else would have noticed.
# Taking the lines out of the rule's own extracted region instead means a reword re-keys the search in
# the same edit that performs it -- which is what keying on the claim rather than the word means here.
#
# Long lines only. A short one ("It carries project data only.") is a sentence any document might share by
# coincidence, and a coincidence reported as a second home is a false red that teaches people to ignore
# the row.
rulelines18() { # -> the rule's own lines, one per line, long enough to be distinctive
  printf '%s\n' "$RULE_LINES" \
    | sed 's/^[[:space:]]*[-*][[:space:]]*//; s/\*\*//g; s/`//g' \
    | awk 'NF >= 8'
}
copyin18() { # $1 = directory -> every rule line that also appears there
  local dir="$1" ln
  rulelines18 | while IFS= read -r ln; do
    [ -n "$ln" ] || continue
    # `-e`, or a rule line that happens to begin with a dash is read as options rather than as the needle.
    grep -rqF -e "$ln" "$dir" 2>/dev/null && printf '%s\n' "$ln"
  done
}
# The precondition is the rule's own region, and deliberately NOT $RULE_HOMES. That count is a grep of
# global/ for one literal spelling of the invariant, and leaning on it here left this leg phrase-coupled
# through the back door after its search terms had been freed of the phrase: the reword battery turned the
# row red reporting `homes=0` while the template shipped no copy, which is the false red the re-key existed
# to remove. The region being non-empty and carrying distinctive lines is the whole precondition this leg
# needs -- it is what makes the comparison meaningful, and it survives any rewording of what it extracts.
n18f10="$(rulelines18 | grep -c . | tr -d ' ')"
r18f10=""
if [ "${n18f10:-0}" -ge 1 ]; then
  # The presence control, on the same machinery: a fixture directory carrying one of the rule's own lines
  # must be reported. Without it, an extraction that quietly yielded nothing would report the template
  # clean for the one reason the row can never afford -- that it stopped being able to look.
  CTL18="$(mkbox)" || fatal 'C18 fact10 fixture'
  rulelines18 | head -1 > "$CTL18/planted.md"
  if [ -z "$(copyin18 "$CTL18")" ]; then
    r18f10=" [the extractor did not find a planted copy of the rule: it is not measuring]"
  elif [ ! -d template ] || [ -z "$(find template -type f 2>/dev/null | head -1)" ]; then
    # The haystack, asserted before an absence is read out of it. The control above certifies the NEEDLES
    # and plants into a throwaway sandbox; neither says anything about the directory the verdict is taken
    # from. `grep -r` on a missing or unreadable path exits 2 with its message discarded, so `copyin18`
    # returns nothing and this row would go green having searched no file at all -- an absence verdict over
    # a corpus that was never there, which is the one way this leg can never afford to pass.
    r18f10=" [no template/ to search: the absence would be read from nothing]"
  else
    FOUND18="$(copyin18 template/ | head -1)"
    [ -n "$FOUND18" ] && r18f10=" [template/ carries a line of the rule: ${FOUND18%% *}...]"
  fi
  rm -rf "$CTL18"
else
  r18f10=" [the rule section yielded no distinctive line to compare against]"
fi
[ -z "$r18f10" ] \
  && ok "the template ships no copy of the rule" \
  || bad "the template ships no copy of the rule ($r18f10)"
