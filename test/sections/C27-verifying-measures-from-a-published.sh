echo "== C27: verifying measures from a published trunk =="
VP27="global/protocols/verify.md"
VS27="global/skills/verify/SKILL.md"
EP27="global/protocols/execute.md"

# Steps resolved by CONTENT, not by number: moving a step renumbers every step after it, and an
# assertion that dies to renumbering tests the numbering rather than the fact. Same reason as C14's.
vsn27() { grep -nE "^[0-9]+\. \*\*$1" "$VS27" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/'; }
NG27="$(vsn27 'Gather the task diff')"
NA27="$(vsn27 'Criterion audit')"

# The one definition every consumer reads, bounded at the next heading and fence-aware, then stripped
# of emphasis and rewrapped: an extractor that can pass or fail on where a line wraps or on a pair of
# asterisks is asserting typography, not content.
TD27="$(awk '/^## The Task Diff/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^#+ /){f=0} f' "$VP27" \
        | tr -d '*`' | tr -s ' \n' '  ')"



echo "== The paper trail names the model the engine runs =="

# A1 — the front door. Two claims read as a pair: the roster carries its own name, and activation writes
# the task's own sheet. The stale wording is asserted ABSENT in the same breath, because a README that
# gains the new sentence while keeping the old one teaches both and the reader cannot tell which won.
# Each half is scoped to the line that carries its claim. File-wide greps let the structure block's
# comment answer for the activation row and vice versa, so the criterion's two halves could both be
# satisfied by one edit in one place.
RD24="README.md"
LC24="global/protocols/lifecycle.md"


# Terminated at the next heading. Without one the window runs to end of file, so "scoped to the section"
# is a claim the extractor does not keep — true only for as long as this happens to be the last section.
AS24="$(awk '/^### Allowed structure/{f=1;next} f && /^#{2,3} /{exit} f' "$BLG24")"

QP24="global/protocols/quick-path.md"

# P1/P2 — restored from the harness this task retired. It carried the only assertions that the generic core
# stays generic: an origin-project identifier or the author's home path reaching global/ is the one defect
# that breaks the product's central promise for every adopter at once, and the migration that kept four of
# its anchors had missed these because they live inside a loop rather than on a literal check line.
# `\bisn\b` rather than a bare `isn`, which matches "isn't" — a guard that fires on ordinary prose is a
# guard the next person deletes.
PUR24='\bisn\b|residents|gate-manager|zoomin|esp32|firestore|ionic|angular|haiku|/architect|/ngrx|/data-access|/frontend-design'
p1=""
# `context` added when that protocol was born. `discover` was already outside this hand list before
# that, and is left alone: pre-existing ground, mentioned in the task's papers and not fixed here.
for f in backlog context execute lifecycle plan quick-path understand verify; do
  grep -qiE "$PUR24" "global/protocols/$f.md"                     && p1="$p1 $f:identifier"
  grep -qiE 'E-099|T-7[0-9][0-9]|T-9[0-9][0-9]' "global/protocols/$f.md" && p1="$p1 $f:foreign-task-id"
done
[ -z "$p1" ] \
  && ok "the swept phase protocols carry no origin-project identifier" \
  || bad "the swept phase protocols carry no origin-project identifier (found:$p1)"

P2OUT="$(purity_sweep . global)"; P2RC=$?
p2="$(printf '%s' "$P2OUT" | grep -c . | tr -d ' ')"
if [ "$P2RC" -ne 0 ]; then
  bad "the shipped engine carries no private project name and no author home path (the sweep could not run: not a repository, or it selected no file)"
elif [ "$p2" = "0" ]; then
  ok "the shipped engine carries no private project name and no author home path"
else
  bad "the shipped engine carries no private project name and no author home path ($p2 line(s))"
fi
