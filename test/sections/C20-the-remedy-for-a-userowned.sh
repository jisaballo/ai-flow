echo "== C20: the remedy for a user-owned file names the hand-merge =="
# ~/.claude/CLAUDE.md is user-owned by construction: the installer writes it only when absent
# (install_global_claude) and the drift guard excludes it from comparison as user-owned
# (global/hooks/drift-check.sh). Nothing distributes it, so the only action that changes it is a hand
# edit. A check that finds the live copy stale and sends the operator anywhere else is worse than one
# that prints nothing: they act, the file does not change, and the failure persists.
# The guard skips THIS block and nothing else. An earlier form stopped the scan at C20's own heading,
# which is not the same thing: this harness is append-only, so "everything before C20" excluded the very
# region where the next hand-written verdict will be added — C21 below was already outside it, and a
# fifth mis-worded verdict appended later would leave the count at four and every assertion green. The
# self-exclusion has to be a hole of one block, not a horizon. Second half of the predicate: a verdict
# naming the shipped copy is a different fault with a different remedy (edit the repo), not ours to judge.
LIVEMSG20="$(awk '/^echo "== /{mine = ($0 ~ /^echo "== C20:/)} !mine && /bad "/ && /live twin/ && !/shipped copy/' $SUITE_SRC)"
LIVEN20="$(printf '%s' "$LIVEMSG20" | grep -c 'bad "' || true)"

# Counted first, and the count is an assertion rather than a comment: a guard whose extractor returns
# nothing passes every other check it makes, which is the vacuous shape this file is being audited for.
# Four is what exists — two in C13, one in C15, one in C17's helper.
if [ "$LIVEN20" -ge 4 ]; then
  ok "the guard found every live-manual verdict it must judge ($LIVEN20)"
else
  bad "the guard found every live-manual verdict it must judge (found $LIVEN20, expected at least 4)"
fi

# Each verdict must route to the hand edit. Absence of the remedy IS the un-fixed form, so this dies on
# a revert of any one of the three.
NOHAND20="$(printf '%s\n' "$LIVEMSG20" | grep -vE 'by hand|hand-merge' || true)"
if [ -n "$LIVEMSG20" ] && [ -z "$NOHAND20" ]; then
  ok "every verdict about the live manual routes to the hand edit"
else
  bad "every verdict about the live manual routes to the hand edit ($(printf '%s\n' "$NOHAND20" | grep -c 'bad "' || true) do not)"
fi

# And none may send the operator to the installer. Banning the script's name alone is NOT enough, and
# this was measured rather than assumed: a verdict reading "port the edit by hand, or re-run the
# installer" satisfies the hand-edit check above and never writes the script's name, so it passed every
# assertion here while misdirecting exactly as the original wording did. The installer cannot change
# this file at all, so the whole word is what is forbidden — the correct remedy never needs it.
CITES20="$(printf '%s\n' "$LIVEMSG20" | grep -iE 'install' || true)"
if [ -z "$CITES20" ]; then
  ok "no verdict about the live manual sends the operator to the installer"
else
  bad "no verdict about the live manual sends the operator to the installer ($(printf '%s\n' "$CITES20" | grep -c 'bad "' || true) do)"
fi

# Third, positive half: the remedy must name the file the operator has to open. Measured, again — with
# only the two checks above, a verdict reading "port the edit by hand, or re-run the setup script"
# satisfied both while sending the operator to a script that cannot touch this file. Naming the target
# is also what makes the remedy actionable: "by hand" alone does not say which of two manuals. The ban
# above cannot enumerate every way to misdirect in English; this is what bounds the wording instead.
NOTARGET20="$(printf '%s\n' "$LIVEMSG20" | grep -vF 'nothing distributes ~/.claude/CLAUDE.md' || true)"
if [ -n "$LIVEMSG20" ] && [ -z "$NOTARGET20" ]; then
  ok "every verdict about the live manual names the file to open"
else
  bad "every verdict about the live manual names the file to open ($(printf '%s\n' "$NOTARGET20" | grep -c 'bad "' || true) do not)"
fi
