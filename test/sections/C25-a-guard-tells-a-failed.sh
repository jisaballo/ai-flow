echo "== C25: a guard tells a failed probe from a clean answer =="
# Three guards of this harness reported success in the situations they were written to catch. Each
# assertion below states the fact it establishes; a guard whose probe cannot answer must fail naming
# the probe, because in a report a clean verdict and an unanswered question read identically.
T25="$(mkbox)" || fatal 'C25 fixtures'
trap 'rm -rf "$T12" "$T13" "$T25"' EXIT   # extended, never replaced — see C21's note on the leak

# --- the probe answers three ways ----------------------------------------
# 0 = the pattern file selects this path, 1 = it does not, 2 = the probe could not answer.
# check-ignore answers 0 and 1 on a verdict and 128/129 on a fatal error; collapsing the fatal into
# "not selected" is the defect — a git that cannot run reads as "the ledger stays behind".
if declare -f wti_probe >/dev/null 2>&1; then
  mkdir -p "$T25/ev"; ( cd "$T25/ev" && $GIT init -q . )
  printf '.ai-flow/product.md\n' > "$T25/pat"
  wti_probe "$T25/ev" "$T25/pat" ".ai-flow/product.md"; a25=$?
  wti_probe "$T25/ev" "$T25/pat" ".ai-flow/BACKLOG.md"; b25=$?
  wti_probe "$T25/absent" "$T25/pat" ".ai-flow/product.md"; c25=$?
  # A pattern file that is present but says nothing is not a verdict either: git reads it as an empty
  # pattern set and answers "not selected" for every path, so a clean answer would come back
  # established from a file nobody read.
  : > "$T25/pat-empty"
  wti_probe "$T25/ev" "$T25/pat-empty" ".ai-flow/product.md"; d25e=$?
  [ "$a25" = 0 ] && [ "$b25" = 1 ] && [ "$c25" = 2 ] && [ "$d25e" = 2 ] \
    && ok "the probe tells selected from not-selected from unanswerable" \
    || bad "the probe tells selected from not-selected from unanswerable (got $a25/$b25/$c25/$d25e, want 0/1/2/2)"
else
  bad "the probe tells selected from not-selected from unanswerable (no three-valued probe exists)"
fi

# --- both verdicts that read the probe act on the third answer ------------
# The leak verdict is the guard this task names; the data verdict beside it is what covers the leak
# today, and a verdict that collapses the third answer misattributes its own failure — it reports
# "the project data is not selected" when the truth is "git did not answer".
# Executed, never grepped. The message a verdict would print can be found in the file while nothing
# reaches it: the arm that counts the probe's third answer is such a path, and deleting it leaves the
# message in place and the suite green. So the classification runs, and it runs in BOTH directions —
# every arm asserted by the answer it must give and by the answer it must not.
if declare -f wti_classify >/dev/null 2>&1; then
  mkdir -p "$T25/ev3" "$T25/notrepo"; ( cd "$T25/ev3" && $GIT init -q . )
  printf '.ai-flow/product.md\n' > "$T25/pat3"
  cls25=""
  # The classifier's diagnostics name a real offender; a fixture that is MEANT to answer wrong is not
  # one, so these calls are read for their answer and their stderr is dropped.
  wti_classify_q() { wti_classify "$@" 2>/dev/null; }
  add25() { [ "$1" = "$2" ] || cls25="$cls25 [want=$2 got=$1: $3]"; }
  add25 "$(wti_classify_q "$T25/ev3" "$T25/pat3" out .ai-flow/BACKLOG.md)"  "clean"        "a path no pattern selects is not a leak"
  add25 "$(wti_classify_q "$T25/ev3" "$T25/pat3" out .ai-flow/product.md)"  "wrong 1"      "a selected ledger path is a leak"
  add25 "$(wti_classify_q "$T25/ev3" "$T25/pat3" in  .ai-flow/product.md)"  "clean"        "a selected data path is what was wanted"
  add25 "$(wti_classify_q "$T25/ev3" "$T25/pat3" in  .ai-flow/BACKLOG.md)"  "wrong 1"      "an unselected data path is a miss"
  add25 "$(wti_classify_q "$T25/notrepo" "$T25/pat3" out .ai-flow/BACKLOG.md)" "unanswered 1" "git fatal inside a real directory is unanswerable"
  add25 "$(wti_classify_q "$T25/absent"  "$T25/pat3" in  .ai-flow/product.md)" "unanswered 1" "an evaluator that is not there is unanswerable"
  [ -z "$cls25" ] \
    && ok "every verdict reading the probe reports an unanswered question instead of a clean one" \
    || bad "every verdict reading the probe reports an unanswered question instead of a clean one ($cls25 )"
else
  bad "every verdict reading the probe reports an unanswered question instead of a clean one (no classifier to execute)"
fi

# The classification above is executed; where each verdict SENDS it is a second fact, and the two are
# complements rather than substitutes. Executing the classifier catches the deletion of the arm that
# counts the third answer; only reading the block catches a verdict that receives that answer and
# announces success anyway. Each verdict is named, because a count survives the loss of any one.
BLOCK25="$(awk '/^echo "== C12:/{f=1} f && /^# --- delivery to an adopting project/{exit} f' $SUITE_SRC)"
route25=""
for v25 in "selects the project data" "leaves the ledger behind" "names only ignored paths"; do
  printf '%s\n' "$BLOCK25" \
    | grep -qE "bad \"worktreeinclude $v25 \(the probe could not answer" \
    || route25="$route25 [$v25]"
done
[ -z "$route25" ] \
  && ok "every verdict sends an unanswered probe to a failure, not to a pass" \
  || bad "every verdict sends an unanswered probe to a failure, not to a pass (missing:$route25)"

# --- a pattern is judged under the specification its own file declares ----
# The file declares gitignore syntax, and git resolves anchoring and negation; reading each pattern
# as a pathspec does not. An anchored pattern naming a versioned path answers `fatal:` on stderr —
# which the guard silenced — leaving an empty result that read as a clean verdict. A negation only
# subtracts from the travel set, so it is correctly never a leak; git decides that, not the harness.
if declare -f wti_tracked_leak >/dev/null 2>&1; then
  mkdir -p "$T25/ev2"; ( cd "$T25/ev2" && $GIT init -q . )
  printf '/install.sh\n' > "$T25/anchored"
  printf '!install.sh\n' > "$T25/negated"
  wti_tracked_leak "$T25/ev2" "$T25/anchored"; d25=$?
  wti_tracked_leak "$T25/ev2" "$T25/negated";  e25=$?
  wti_tracked_leak "$T25/absent" "$T25/anchored"; g25=$?
  # The production pattern file is deliberately NOT in this set: C12 owns the verdict about it, and
  # judging it here would report a real regression in that file as a broken mechanism.
  [ "$d25" = 0 ] && [ "$e25" = 1 ] && [ "$g25" = 2 ] \
    && ok "an anchored pattern naming a versioned path is reported and a negation is not" \
    || bad "an anchored pattern naming a versioned path is reported and a negation is not (got $d25/$e25/$g25, want 0/1/2)"
else
  bad "an anchored pattern naming a versioned path is reported and a negation is not (patterns are still read as pathspecs)"
fi

# --- both copies of the manual are judged on the same pair ----------------
# The distributed copy is judged on two halves: it names the task's own sheet, and it no longer
# routes step progress to the roster. The personal copy — the only one no tool can repair — was
# judged on the first half alone, so a manual holding both wordings passed.
if declare -f manstate >/dev/null 2>&1; then
  cp global/CLAUDE.md "$T25/man-current"
  cp global/CLAUDE.md "$T25/man-stale"
  printf -- '- Update STATE.md with step progress\n' >> "$T25/man-stale"
  # A third fixture, and it is what makes the conjunction's FIRST half lethal: the two above both
  # name the task sheet, so between them they discriminate the negative half only — drop the positive
  # grep and both still answer as expected. Each half of a pair needs a fixture that dies on it alone.
  sed 's#artifacts/T-XXX/state.md#artifacts/somewhere-else.md#g' global/CLAUDE.md > "$T25/man-nopath"
  if manstate "$T25/man-current" && ! manstate "$T25/man-stale" && ! manstate "$T25/man-nopath"; then
    ok "a manual holding both wordings fails the pair and one holding only the new passes it"
  else
    bad "a manual holding both wordings fails the pair and one holding only the new passes it"
  fi
else
  bad "a manual holding both wordings fails the pair (no two-sided predicate exists)"
fi

# --- with no personal manual, the verdict claims only what it opened ------
# A verdict about a file the host does not have is a verdict about nothing. The skip stays a skip,
# and the pair is never reported as established on the strength of one copy.
TWINBLK25="$(awk '/^twin="\$HOME/{f=1} f && /^# --- the rail resolves/{exit} f' $SUITE_SRC)"
# The branch that runs on a host with no personal manual. It must announce the skip and carry no
# verdict at all: a verdict there would be a claim about a file nobody opened, and counting it would
# let a green run read as proof that the two copies agree.
ELSE25="$(printf '%s\n' "$TWINBLK25" | awk '/^  else$/{f=1;next} f && /^  fi$/{exit} f')"
if printf '%s\n' "$TWINBLK25" | grep -q 'if \[ -f "$twin" \]' \
   && printf '%s' "$ELSE25" | grep -q 'skip' \
   && ! printf '%s' "$ELSE25" | grep -qE 'ok "|bad "'; then
  ok "with no personal manual the verdict claims the distributed copy only"
else
  bad "with no personal manual the verdict claims the distributed copy only"
fi
