echo "== C15: closing a front is a serialised merge ceremony =="
BLG4="global/protocols/backlog.md"

# The ceremony, bounded at the next section, fence-aware — the opening's own idiom.
CLO="$(awk '/^## Closing a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG4")"
# One numbered move, flattened AND whitespace-squeezed. What a move must say is a property of the move,
# never of where its prose happens to wrap — and joining wrapped lines leaves their indentation behind,
# so a two-word fact split across a line break reads as 'never    before' and every single-space
# pattern misses it. Re-wrapping unchanged prose must never change a verdict.
clomove() { printf '%s\n' "$CLO" | awk -v n="$1" '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==n' | tr '\n' ' ' | tr -s ' '; }
mpair() { # move, pattern A, pattern B, label
  printf '%s' "$(clomove "$1")" | grep -qiE "$2" && printf '%s' "$(clomove "$1")" | grep -qiE "$3" \
    && ok "$4" || bad "$4"
}

if [ -n "$CLO" ]; then
  # The eight moves, each identified by its own lead and read in sequence. The ORDER is the fact this
  # guards: a collection written after the merge changes the sequence while every presence grep in
  # this section stays green. Distribution sits between the record and the publish: earlier it could
  # block the ledger, later it would trail a tail that runs only on a front's last task. The publish
  # then sits between the distribution and that tail, for the same two reasons in the same order.
  # The count is READ from the protocol, never enumerated here: a literal list stops at its last index,
  # so a move appended after the roster row is never looked at and the order check stays green over a
  # ceremony that grew. The expected sequence below still encodes the ceremony this engine ships; what
  # is derived is how far to look, which is the half a hardcoded range cannot see past.
  nclo="$(printf '%s\n' "$CLO" | grep -cE '^[0-9]+\. ')"
  seq=""
  i=1
  while [ "$i" -le "$nclo" ]; do
    case "$(clohead "$i" "$CLO" | tr 'A-Z' 'a-z')" in
      *valid*)               seq="$seq V" ;;
      *collect*|*harvest*)   seq="$seq C" ;;
      *merge*)               seq="$seq M" ;;
      *distribut*|*effect*)  seq="$seq X" ;;
      *record*|*ledger*)     seq="$seq L" ;;
      # Before the record arm, and the ordering is load-bearing: a publishing move whose lead sentence
      # happened to say "the record" would be filed as the ledger and the sequence would read green with
      # the new move classified as an old one. The heads are kept free of each other's words as well.
      *publish*)             seq="$seq P" ;;
      # The papers' own move. Ahead of the dismantling arm for the reason the publish arm gives above:
      # this head speaks of a checkout, and the arm that owns that word would swallow it whole.
      *delet*)               seq="$seq K" ;;
      *dismantl*|*worktree*) seq="$seq D" ;;
      *roster*|*row*)        seq="$seq R" ;;
      *)                     seq="$seq ?" ;;
    esac
    i=$((i+1))
  done
  [ "$seq" = " V C M L X P K D R" ] \
    && ok "the protocol defines the ceremony that closes a front" \
    || bad "the protocol defines the ceremony that closes a front (moves unnamed or out of order:$seq)"

  # One pattern, not two: 'outside version control' and a bare 'branch' both occur elsewhere in this
  # move, so an either-or pair passed with the fact itself deleted. The fact is the relation.
  printf '%s' "$(clomove 2)" \
    | grep -qiE '(does not|do not|never) (travel|reach)[^.]*branch|branch carries (none|nothing)|merge carries none' \
    && ok "the papers are collected before the merge, and never travel with the branch" \
    || bad "the papers are collected before the merge, and never travel with the branch"
  # Was an either-or pair, and a rationale clause added to this move using the word 'stops' made it
  # passable with the stop rule deleted — a working guard disabled without its line being touched. Both
  # halves occur elsewhere in the move on their own, so what is asserted is the RELATION: the absence of
  # that path is what halts the ceremony.
  printf '%s' "$(clomove 2)" \
    | grep -qiE 'listing does not name that path[^.]*stop|does not name that path, stop' \
    && ok "an unlocatable front checkout stops the closing" \
    || bad "an unlocatable front checkout stops the closing"
  mpair 3 'stays open|remains open|front stays|front remains' 'not written|unwritten|never written' \
    "a merge that cannot complete leaves the front open and the ledger unwritten"

  M2="$(clomove 2)"
  if printf '%s' "$M2" | grep -qiE 'sanctioned|only exception|single exception' \
     && printf '%s' "$M2" | grep -qi 'overwrit' \
     && printf '%s' "$M2" | grep -qiE 'where the task was worked|worked there|authoritative'; then
    ok "the collection is the sanctioned exception to never overwriting a task's papers"
  else
    bad "the collection is the sanctioned exception to never overwriting a task's papers"
  fi

  # The condition belongs to BOTH tail moves. Stated once in a preamble it reads as a caveat; carried
  # by each move it is what the operator reads at the moment of acting.
  #
  # The tail is the LAST TWO moves, derived from the count already read above — never the literal 6 and 7.
  # Keyed on the literals, inserting the publishing move shifted the tail underneath them: one leg went
  # red for the right reason while the other landed on the dismantling move and passed for the wrong one,
  # which is a guard reporting on a move it was not written about.
  if printf '%s' "$(clomove $((nclo-1)))" | grep -qiE 'no next task|has no next|last task' \
     && printf '%s' "$(clomove "$nclo")" | grep -qiE 'no next task|has no next|last task'; then
    ok "a front with a next task keeps its checkout and its roster row"
  else
    bad "a front with a next task keeps its checkout and its roster row"
  fi

  # Located by the move's own ACT, not by its number: the assertion is about dismantling, and a number
  # is only ever a proxy for it that stops being true at the next insertion.
  ndis="$(printf '%s\n' "$CLO" | awk '/^[0-9]+\. /{h=tolower($0); if (h ~ /dismantl/) {print $0+0; exit}}')"
  if [ -n "$ndis" ]; then
    mpair "$ndis" 'never before' 'destroy' \
      "dismantling the checkout before the collection destroys the task's papers"
  else
    bad "dismantling the checkout before the collection destroys the task's papers (no dismantling move)"
  fi
  # One approval, and it covers the task's work in either kind of checkout — not the branch alone, which
  # is what this leg asserted while the coordinator still had a per-commit gate of its own.
  mpair 1 'validates the work|approves' 'nothing merges|before .*merge|does not merge' \
    "the user validates the task's work before anything merges"

  M4="$(clomove 4)"
  if printf '%s' "$M4" | grep -qi 'quick' \
     && printf '%s' "$M4" | grep -qi 'coordinator' \
     && printf '%s' "$M4" | grep -qiE 'nothing to collect|no papers' \
     && printf '%s' "$M4" | grep -qi 'archive checklist' \
     && printf '%s' "$M4" | grep -qiE 'epic[- ]completion|epic close'; then
    ok "a quick task collects nothing and its row is written in the coordinator"
  else
    bad "a quick task collects nothing and its row is written in the coordinator"
  fi

  # The task's headline claim, and the only thing standing in for the lock this ceremony deliberately
  # does not have. Scoped to the preamble: the section's text before the first move.
  CLOI="$(printf '%s\n' "$CLO" | awk '/^1\. /{exit} {print}' | tr '\n' ' ' | tr -s ' ')"
  printf '%s' "$CLOI" | grep -qi 'only the coordinator runs it' \
    && printf '%s' "$CLOI" | grep -qiE 'one front at a time|one at a time' \
    && ok "the ceremony has a single runner and merges one front at a time" \
    || bad "the ceremony has a single runner and merges one front at a time"

  # The ordinary case must survive: one front open means there is nothing to fetch and no checkout to
  # take down. Without this the ceremony reads as a seven-move ritual for every single archive.
  printf '%s' "$CLO" | tr '\n' ' ' | tr -s ' ' | grep -qiE 'single front|one front open' \
    && printf '%s' "$CLO" | tr '\n' ' ' | tr -s ' ' | grep -qiE 'nothing to do|nothing to collect' \
    && ok "a single open front has nothing to collect and nothing to dismantle" \
    || bad "a single open front has nothing to collect and nothing to dismantle"
else
  bad "the protocol defines the ceremony that closes a front"
  bad "the papers are collected before the merge, and never travel with the branch (no section)"
  bad "an unlocatable front checkout stops the closing (no section)"
  bad "a merge that cannot complete leaves the front open and the ledger unwritten (no section)"
  bad "the collection is the sanctioned exception to never overwriting a task's papers (no section)"
  bad "a front with a next task keeps its checkout and its roster row (no section)"
  bad "dismantling the checkout before the collection destroys the task's papers (no section)"
  bad "the user validates the task's work before anything merges (no section)"
  bad "a quick task collects nothing and its row is written in the coordinator (no section)"
  bad "a single open front has nothing to collect and nothing to dismantle (no section)"
  bad "the ceremony has a single runner and merges one front at a time (no section)"
fi

# --- the checklists the ceremony invokes ---------------------------------
# Step 3 of the epic close, flattened. The negative half is the fact: a sweep that returns turns the
# audit back into a delete, and every positive pattern here would still match.
EPI3="$(awk '/^### After Epic completion/{f=1;next} (f && /^#+ /){f=0} f' "$BLG4" | awk '/^4\./{f=0} /^3\./{f=1} f' | tr '\n' ' ' | tr -s ' ')"
if printf '%s' "$EPI3" | grep -qiE 'verify|audit' \
   && printf '%s' "$EPI3" | grep -qiE 'name it and stop|name it .*stop|stop:' \
   && ! printf '%s' "$EPI3" | grep -qE '\*\*Delete\*\*' \
   && ! printf '%s' "$EPI3" | grep -qiE 'for ALL tasks|all tasks in the epic' \
   && ! printf '%s' "$EPI3" | grep -qiE '(delete|remove|purge|sweep) (them|every|each|all)|in a single sweep'; then
  ok "epic close audits the task folders and never deletes by lot"
else
  bad "epic close audits the task folders and never deletes by lot"
fi

# The single-task checklist's own preamble — before its numbered steps, so a "coordinator only" that
# already lives inside step 7 cannot satisfy it.
ARCP="$(awk '/^### After ARCHIVE \(single task\)/{f=1;next} /^1\./{f=0} (f && /^#+ /){f=0} f' "$BLG4" | tr '\n' ' ' | tr -s ' ')"
if printf '%s' "$ARCP" | grep -qi 'coordinator' \
   && printf '%s' "$ARCP" | grep -qiE 'closing ceremony|Closing a Workstream'; then
  ok "the per-task archive checklist names the coordinator as where it runs"
else
  bad "the per-task archive checklist names the coordinator as where it runs"
fi

# The roster step of the checklist move 4 delegates to. The ceremony promises the roster row is removed
# only on the front's last task; the checklist used to order that removal unconditionally, and the two
# steps before it were the only text carrying the condition — so the suite stayed green over a
# contradiction on the contract's central fact. This reads the callee, not just the caller.
#
# It is the LAST step, and its number moves whenever a move is inserted above it — which is what the
# Icebox write-back did, and what the deletion leaving the checklist does again. So it is located by the
# ACT it performs and never by a literal: a renumber that leaves a literal behind does not fail here, it
# silently extracts the wrong step. Absent the act, `step_no` names it and $ARC7 is empty, which every
# leg below already reports as a different verdict than a wrong one.
#
# The move the citations must NAME is read from the ceremony, not written down here. Spelled as a literal,
# this leg is wrong the moment a move is inserted anywhere above the roster row — and wrong in the
# direction that passes: it would go on demanding the number the prose used to carry.
ARCS7="$(awk '/^### After ARCHIVE \(single task\)/{f=1;next} (f && /^#+ /){f=0} f' "$BLG4")"
NROW7="$(step_no 'workstream row|roster row' "$ARCS7")" || NROW7=""
ARC7=""
[ -n "$NROW7" ] && ARC7="$(printf '%s\n' "$ARCS7" | awk -v n="$NROW7" '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==n' | tr '\n' ' ' | tr -s ' ')"
EPI6="$(awk '/^### After Epic completion/{f=1;next} (f && /^#+ /){f=0} f' "$BLG4" | awk '/^7\./{f=0} /^6\./{f=1} f' | tr '\n' ' ' | tr -s ' ')"
# The NUMBER, not just a reference to the ceremony. Read as an alternation it was blind to the fact it
# claims: both citations name "move N of `## Closing a Workstream`", so a half-renumber left pointing at
# the wrong move still matched the section title and read green.
NCLO4="$(awk '/^## Closing a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG4" | grep -cE '^[0-9]+\. ')"
if printf '%s' "$ARC7" | grep -qiE 'no next task' \
   && printf '%s' "$ARC7" | grep -qiE "move $NCLO4" \
   && printf '%s' "$ARC7" | grep -qiE 'Closing a Workstream' \
   && ! printf '%s' "$ARC7" | grep -qiE "^$NROW7\. (Remove|Delete) " \
   && printf '%s' "$EPI6" | grep -qiE "move $NCLO4" \
   && printf '%s' "$EPI6" | grep -qiE 'only remover|Closing a Workstream' \
   && ! printf '%s' "$EPI6" | grep -qiE '^6\. (Remove|Delete) '; then
  ok "both checklists leave the roster row to the ceremony's last move"
else
  bad "both checklists leave the roster row to the ceremony's last move"
fi

# One act, two fields. Step 7 is the ONLY place the continuing case is stated — the ceremony's own move 7
# speaks of removal alone — so this is where the tool's mutable label has to ride along with the task
# field, or the label is left to a second act nobody would ever run. The coupling leg is an ORDERED
# co-occurrence and not a second bare word: two independent greps prove only that both phrases appear
# somewhere in the step, and prose that explicitly DECOUPLES them ("a separate later act rewrites the
# front's mutable label") keeps both and stays green — which is the exact failure the clause was added to
# prevent, measured by mutation rather than suspected. The third leg pins the back-citation by number,
# the counterpart of the forward one asserted on move 5.
if printf '%s' "$ARC7" | grep -qiE 'task field advanced' \
   && printf '%s' "$ARC7" | grep -qiE 'same act[^.]{0,80}mutable label' \
   && printf '%s' "$ARC7" | grep -qiE 'move 5'; then
  ok "the act that advances the task also rewrites the label"
else
  bad "the act that advances the task also rewrites the label"
fi

# The two halves must name each other, and the heading every extractor above depends on must exist as a
# heading — a renamed section silently empties $CLO, and an empty $CLO is a different verdict than a wrong one.
OPN="$(awk '/^## Opening a Workstream/{f=1;next} (/^## /){f=0} f' "$BLG4" | tr '\n' ' ' | tr -s ' ')"
if grep -qE '^## Closing a Workstream' "$BLG4" && printf '%s' "$OPN" | grep -q 'Closing a Workstream'; then
  ok "the two halves of the workstream ceremony name each other"
else
  bad "the two halves of the workstream ceremony name each other"
fi

# The post-commit route, in the repo copy and in the live twin that no drift check covers. The other
# half of this pair — the phase step naming the closing ceremony — left the manual with the phase
# descriptions and is asserted on the map instead, by the archive row of the paper-trail block. Narrowing
# this check is therefore not a coverage loss but a relocation: the fact moved from a file nothing
# distributes to one the installer delivers and the drift guard compares.
# The RULE itself has now left this file too, and is stated in the closing protocol with the ceremony it
# triggers. So what the manual owes here is the pointer, and the pointer is what both copies are judged
# on; the rule's own text is guarded where it now lives. Narrowing this to a route is not a coverage loss
# — it is the same relocation this pair already absorbed once, one step further.
#
# Scoped to the section and RELATIONAL: the manual names what follows a task's last commit AND names the
# owner it routes to. A bare mention of either is satisfied by any neighbouring bullet in a section that
# is now nothing but routes.
POST_ROUTE_RE='(after|follows)[^.]{0,60}last commit|last commit[^.]{0,80}(ceremony|immediately)'
# The section extractor is INLINE and not `msect`, which is defined two hundred lines below this leg and
# would be an unset command here: the call would fail, the section would read empty, and the row would
# report a stale manual on a manual it never opened.
manroutes() {
  local sec
  sec="$(awk '/^### Commit Protocol/{f=1;next} (f && /^#+ /){exit} f' "$1" | tr -s ' \n' '  ')"
  [ -n "$sec" ] || return 1
  printf '%s' "$sec" | grep -qiE "$POST_ROUTE_RE" || return 1
  printf '%s' "$sec" | grep -qi 'backlog.md'      || return 1
  return 0
}
twin3="$HOME/.claude/CLAUDE.md"
if manroutes global/CLAUDE.md; then
  ok "the shipped manual routes the post-commit rule to the closing ceremony"
  if [ -f "$twin3" ]; then
    manroutes "$twin3" \
      && ok "the live twin routes the post-commit rule to the closing ceremony" \
      || bad "the live twin routes the post-commit rule to the closing ceremony (stale — port the edit by hand, nothing distributes ~/.claude/CLAUDE.md)"
  else
    echo "  [skip] live CLAUDE.md twin absent — the shipped one routes the post-commit rule"
  fi
else
  bad "the shipped manual routes the post-commit rule to the closing ceremony"
  bad "the live twin routes the post-commit rule to the closing ceremony (shipped copy is stale)"
fi
