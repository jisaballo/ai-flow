echo "== C17: the manual describes the parallel model it implements =="
C17_SKIPPED=0

# A table row, by the command it names, inside the section that owns the table — same reason msect and
# mbul exist: a file-wide row grep retargets itself the day any earlier table happens to name the command.
mrow() { msect "$1" "$3" | grep -m1 -E "^\|[^|]*$2[^|]*\|" | tr -s ' '; }


# Fact 1 — the limit is per front, and the ceiling is a number a reader can act on. Scoped to the bullet
# whose bold lead names the limit: the guard bullet below it also says "active task" and would pass a
# section-wide grep for it. Absence of the qualifier IS the un-edited form, so this dies on a revert.
mf_limit() {
  # Bracketed, never backslash-escaped: awk eats \* out of a -v regex, which silently turns the lead
  # pattern into a malformed quantifier that matches nothing — a stub that fails for the wrong reason.
  local b; b="$(mbul "$1" '^## Working Rules' '^- [*][*][^*]*[Aa]ctive task')"
  [ -n "$b" ] || return 1
  printf '%s' "$b" | grep -qiE 'per workstream|per front'   || return 1
  # Both numbers: "2 fronts" alone drops the ceiling, and a ceiling alone drops what is normal.
  printf '%s' "$b" | grep -qiE '\b2\b|\btwo\b'              || return 1
  printf '%s' "$b" | grep -qiE '\b3\b|\bthree\b'            || return 1
  # "no longer stated unqualified" is a property of the document, not of this bullet: a second,
  # unqualified restatement placed anywhere else passes a positive-only check on the first match.
  awk 'tolower($0) ~ /(one|1) active task/ && tolower($0) !~ /per (workstream|front)/ {f=1} END{exit !f}' "$1" \
    && return 1
  return 0
}
manfact mf_limit "the manual scopes the active-task limit to a front and names the ceiling"

# Fact 2 — the off-plan guard offers three ways out, and the second one is described as it works today.
# Each way out is asserted separately: adding the third while dropping one of the other two is a mutation
# that leaves the word "parallel" in place and must still die.
mf_guard() {
  local b; b="$(mbul "$1" '^## Working Rules' 'Scope & Session Guard')"
  [ -n "$b" ] || return 1
  printf '%s' "$b" | grep -qiE 'parallel workstream|parallel front'  || return 1
  printf '%s' "$b" | grep -qi  'BACKLOG.md'                          || return 1
  printf '%s' "$b" | grep -qiE 'switch task'                         || return 1
  # The procedure, not just the option: an option with nowhere to go is not a way out.
  printf '%s' "$b" | grep -qi  'opening ceremony'                    || return 1
  printf '%s' "$b" | grep -qi  'closing ceremony'                    || return 1
  # The roster row has exactly one owner — the closing ceremony's last move — so the hand-pruning
  # this line used to prescribe is gone.
  printf '%s' "$b" | grep -qi  'prune STATE.md'                      && return 1
  return 0
}
manfact mf_guard "the off-plan guard offers a parallel front as a third way out, and routes the other two to their ceremonies"

# Fact 3a — the section routes and states no commit rule of its own. It used to state the gate, with an
# exception for the worktree; there is no exception now, because commits are free in every checkout and
# the single approval sits at the close. What the section owes is a pointer per fact and nothing else.
#
# The NEGATIVE half is the point, and it is the half this epic has twice paid for: a rule living in two
# documents, one of which nothing distributes. The four owners are named individually because a section
# that routes three facts and quietly keeps the fourth is the exact shape the relocation was for.
mf_commit_gate() {
  local s
  s="$(msect "$1" '^### Commit Protocol' | tr -s ' \n' '  ')"
  [ -n "$s" ] || return 1
  printf '%s' "$s" | grep -qi 'backlog.md'    || return 1
  printf '%s' "$s" | grep -qi 'execute.md'    || return 1
  printf '%s' "$s" | grep -qi 'lifecycle.md'  || return 1
  printf '%s' "$s" | grep -qi 'quick-path.md' || return 1
  # The section's own former sentences. A manual that grows one of them back has two homes again, and the
  # drift is silent by construction: nothing distributes this file, so the two copies never meet.
  #
  # FILE-WIDE, not section-scoped, and that reach is the point (IB-032): a negative bounded to the section
  # is green the day one of these sentences reappears four headings away, which is exactly how this manual
  # came to state two of its six commit facts outside the section that claims to route them. Measured
  # before widening -- zero hits in the shipped copy and zero in the live twin -- because `manfact` judges
  # both, so a phrase that clears on ordinary English would redden a user's own manual with no remedy.
  # BOTH facts IB-032 named, not only the section's own retired sentences. The four below are what this
  # section used to say; `commits ... are free per step` is the OTHER fact the entry found stated outside
  # the section that routes it, and until now nothing read for it. Measured before widening -- zero hits
  # in the shipped copy and zero in the live twin.
  tr -s ' \n' '  ' < "$1" \
    | grep -qiE 'do not commit until|only commit when|stays uncommitted|still ask first|commits( themselves)? are free|free per step' \
    && return 1
  # WHY the rule cannot live here, kept with the route. Without it the section reads as a plain index and
  # the next editor puts a rule back for convenience, which is how it got here the first time.
  printf '%s' "$s" | grep -qiE 'nothing distributes|never updates|not distributed|only when absent' || return 1
  return 0
}
manfact mf_commit_gate "the manual routes each commit fact to its owner, states none itself, and says why"

# Fact 3b — the hard stop is about PUBLISHING, and it names the approval that lifts it. Asserted on its
# own, which is strictly stronger than "fails when the routed section and the stop disagree": the suite
# that asserts only the caller lets the callee contradict it, which is how one procedure ends up stated
# two ways in one document.
#
# The subject is the leg that matters. Committing is now free per step, so a stop still forbidding it
# forbids what the engine's own loop prescribes — a manual contradicting the protocol it routes to, which
# is worse than the drift the route was built to remove.
mf_commit_stop() {
  local b; b="$(mbul "$1" '^### Never' 'without user validation')"
  [ -n "$b" ] || return 1
  printf '%s' "$b" | grep -qiE 'publish|push'                            || return 1
  printf '%s' "$b" | grep -qi  'commit without user validation'          && return 1
  # A cross-reference is not an approval: without naming where the approval is given, the stop reads as
  # absolute and the reader has no way to discover what lifts it.
  printf '%s' "$b" | grep -qiE 'closing ceremony|move 1|backlog protocol' || return 1
  return 0
}
manfact mf_commit_stop "the hard stop forbids publishing without validation and names the approval that lifts it"

# Fact 4 — both resume entries resolve the task by the one written ladder, and neither reproduces a rung.
# A second statement of the rungs is a copy that drifts, which is the whole reason the ladder has one home.
mf_resume() {
  local r b both
  r="$(mrow "$1" 'continue' '^### Phase Orchestration')"
  b="$(mbul "$1" '^### Session Continuity' 'On start')"
  [ -n "$r" ] && [ -n "$b" ] || return 1
  printf '%s' "$r" | grep -qiE 'Resolving the task|ladder'  || return 1
  printf '%s' "$b" | grep -qiE 'Resolving the task|ladder'  || return 1
  # Both entries name the owner. A citation without its document is a pointer to nowhere, and the reader
  # who lands on the table has no route to the rungs — the whole reason the ladder was given one home.
  printf '%s' "$r" | grep -qi  'backlog protocol'           || return 1
  printf '%s' "$b" | grep -qi  'backlog protocol'           || return 1
  both="$r $b"
  printf '%s' "$both" | grep -qiE 'checked out|lone sheet|exactly one task' && return 1
  return 0
}
manfact mf_resume "both resume entries resolve the task by the written ladder, and restate no rung"

[ "$C17_SKIPPED" -eq 0 ] || echo "  [note] $C17_SKIPPED twin half/halves not evaluated (no live CLAUDE.md twin on this host) — a green run does not prove the two copies agree"
