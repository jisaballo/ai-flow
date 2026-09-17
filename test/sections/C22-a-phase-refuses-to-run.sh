echo "== C22: a phase refuses to run on a task that is not in that phase =="
PB22="global/protocols/backlog.md"
US22="global/skills/understand/SKILL.md"
PS22="global/skills/plan/SKILL.md"
VS22="global/skills/verify/SKILL.md"
VP22="global/protocols/verify.md"
PRECOND22="The phase precondition"
C22_SKILLS="understand plan execute verify"

# The rule's own block, bounded at the next heading of any depth and fence-aware — the shape C14 and
# C18 use for the task-diff definition and the mutation rule, and for the same reason: a file-wide grep
# finds the citations, never the rule itself.
PBLK22="$(awk -v h="^### $PRECOND22" '$0 ~ h {f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^#+ /){f=0} f' "$PB22")"
# One bolded clause of that block, from its lead to the next lead, flattened. Five facts share this
# block: a block-wide grep would let any one of them stand in for any other, which is the failure this
# harness has now caught eight times.
pclause22() { printf '%s\n' "$PBLK22" | awk -v s="$1" '/^- \*\*/{ if(g) exit; g=($0 ~ s) } g' | tr '\n' ' '; }
# Byte offset of a fixed string: for the facts that are an ORDER, which presence greps cannot see.
# Defined here rather than reused from C14 so this block stands on its own.
poff22() { printf '%s' "$1" | grep -obF "$2" | head -1 | cut -d: -f1; }


# Every line naming two or more of the accepted positions as a set -- which is what restating them looks
# like, in any wording. $1 = a document's text.
#
# This replaces a pair of literal pins (`UNDERSTAND or PLAN`, `EXECUTE or VERIFY`). Those were an ABSENCE
# keyed on a phrase: red when the precondition reworded its own enumeration and still said the same thing,
# green when a skill restated the set in words nobody had listed -- which is the drift the rows exist to
# catch, walking past them. The claim was never about those two spellings; it is that a second document
# enumerates the set at all. Counting DISTINCT positions per line asks that question directly, so
# `PLAN and EXECUTE`, `VERIFY, EXECUTE` and `either UNDERSTAND or else PLAN` are all caught without anyone
# having to have thought of them.
#
# Per LINE and not per document, because every one of these files names its own phase many times over and
# a document-wide count would report all of them. A line is the unit at which two positions sit together
# as a set.
enum22() {
  printf '%s\n' "$1" | awk '
    { n = 0; delete seen; s = $0
      while (match(s, /(ACTIVATE|UNDERSTAND|PLAN|EXECUTE|VERIFY)/)) {
        w = substr(s, RSTART, RLENGTH)
        if (!(w in seen)) { seen[w] = 1; n++ }
        s = substr(s, RSTART + RLENGTH)
      }
      if (n >= 2) printf "L%d ", NR
    }'
}

# --- the gather runs before anything judges what it gathers --------------
C_VS22="$(cat "$VS22")"
O_GATH22="$(poff22 "$C_VS22" 'Gather the task diff')"
O_AUD22="$(poff22 "$C_VS22" 'Criterion audit')"
O_COPY22="$(poff22 "$C_VS22" 'byte-exact copy')"
O_REV22="$(poff22 "$C_VS22" 'Invoke the verify-review workflow')"

# O3 — positive form, not a denylist: what bounds these extractors is that they resolve the step by
# content. Counted against the class so a guard whose extractor finds nothing cannot pass.
# `vstep` is in the class too: it is the extractor this change actually re-scoped onto the copy step, so
# a guard naming only the other two misses the one call site the change created. The reach of a rule is
# measured against the call sites that exist, never against the ones that existed when it was written.
INV22="$(grep -oE '(nstep|sbullet|vstep) "\$VS[0-9]*"' $SUITE_SRC | wc -l | tr -d ' ')"
LIT22="$(grep -oE '(nstep|sbullet|vstep) "\$VS[0-9]*" [0-9]' $SUITE_SRC | wc -l | tr -d ' ')"
if [ "$INV22" -ge 6 ] && [ "$LIT22" -eq 0 ]; then
  ok "no assertion reaches a step of the verify command by a hardcoded number"
else
  bad "no assertion reaches a step of the verify command by a hardcoded number ($LIT22 of $INV22 literal)"
fi
