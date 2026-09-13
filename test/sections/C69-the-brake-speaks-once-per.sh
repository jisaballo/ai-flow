echo "== C69: the brake speaks once per oversized step, counts what was added, and says what it measured =="
# Generated in the Conform phase from understand.md's Verifiable Criteria. The failure this change can
# introduce is SILENCE, and silence is invisible -- so A2, A3, A8 and A9 are each written as a way the
# new record could go quiet and still look healthy, and each carries a positive leg that no absent
# mechanism can satisfy. A2 and A9 in particular assert the record's SCOPE and not merely that the brake
# spoke: the unfixed hook keeps no step record at all, so a row asserting only the speaking would be
# green today against a mechanism that does not exist.

T69="$(mkbox)" || fatal 'C69 fixtures'
trap 'chmod -R u+rwX "$T12" "$T13" "$T25" "$T44" "$T45" "$T45R" "$T47" "$T55" "$T69" 2>/dev/null; rm -rf "$T12" "$T13" "$T25" "$T44" "$T45" "$T45R" "$T47" "$T55" "$T69"' EXIT   # extended, never replaced

# The note's own event, with stderr kept apart: at exit 0 anything on stderr is discarded, so a row that
# merged the streams could not tell a delivered note from a hook complaining.
note69() { ( cd "$1" && printf '{"hook_event_name":"UserPromptSubmit"}' | python3 "$HK/diff-size-guard.py" 2>"$T69/note-err" ); }

# A repo with a ledger and no base ref: `wip` has no main/master and no remote, so the task ceiling is
# out of play and a row about the STEP ceiling measures the step ceiling alone.
mkstep69() {  # $1 = dir
  mkdir -p "$1"
  $GIT init -q "$1"
  $GIT -C "$1" symbolic-ref HEAD refs/heads/wip
  mkdir -p "$1/.ai-flow"; printf 'Current phase: **EXECUTE**\n' > "$1/.ai-flow/STATE.md"
  printf 'x\n' > "$1/app.txt"
  $GIT -C "$1" add -A >/dev/null 2>&1
  $GIT -C "$1" commit -q -m init
}

if [ "$PY3" = 1 ]; then
  # --- A1: an acknowledged step ceiling stays silent until another step's worth ---------------------
  # Three legs pulling two ways. The control is what keeps the row from being satisfied by a brake that
  # stopped speaking anywhere at all -- which is exactly the defect the row's own remedy can introduce.
  S1="$T69/a1"; mkstep69 "$S1"
  nlines 200 > "$S1/big.txt"
  a1_69=""
  o="$(brake "$S1")"; rc=$?
  { [ "$rc" = 2 ] && printf '%s' "$o" | grep -q 'step ceiling'; } \
    || a1_69="$a1_69 [CONTROL: the step ceiling did not fire on a 200-line uncommitted change (exit $rc)]"
  o="$(brake "$S1")"; rc=$?
  [ "$rc" = 0 ] || a1_69="$a1_69 [the same unchanged step was refused a second time -- this is the 80 measured blocks (exit $rc)]"
  nlines 200 >> "$S1/big.txt"
  o="$(brake "$S1")"; rc=$?
  { [ "$rc" = 2 ] && printf '%s' "$o" | grep -q 'step ceiling'; } \
    || a1_69="$a1_69 [the step grew another step's worth and the brake stayed silent (exit $rc)]"
  [ -z "$a1_69" ] && ok "A1 an acknowledged step ceiling stays silent until the step grows another step's worth" \
                  || bad "A1 an acknowledged step ceiling stays silent until the step grows another step's worth ($a1_69)"

  # --- A2: a commit re-arms the step ceiling, whatever it recorded ----------------------------------
  # The row that kills the backlog entry's LITERAL remedy. Giving the step arm the task arm's record
  # unscoped disarms it for good: `outgrown` assumes a monotonic measure and the step total resets to 0
  # at every commit, so a 300-line step after a 200-line one asks 300 > 350 and loses. The speaking leg
  # alone is green against TODAY's hook, which keeps no step record at all -- so the scope is asserted.
  S2="$T69/a2"; mkstep69 "$S2"
  nlines 200 > "$S2/big.txt"
  a2_69=""
  o="$(brake "$S2")"; rc=$?
  [ "$rc" = 2 ] || a2_69="$a2_69 [CONTROL: the first oversized step was not refused (exit $rc)]"
  $GIT -C "$S2" add -A >/dev/null 2>&1; $GIT -C "$S2" commit -q -m step1
  nlines 300 > "$S2/next.txt"
  o="$(brake "$S2")"; rc=$?
  { [ "$rc" = 2 ] && printf '%s' "$o" | grep -q 'step ceiling'; } \
    || a2_69="$a2_69 [a commit landed and the next 300-line step was silent -- the brake is disarmed (exit $rc)]"
  ACK2="$S2/.git/ai-flow-diff-guard-ack"
  H2="$($GIT -C "$S2" rev-parse HEAD 2>/dev/null)"
  grep -q "step:$H2" "$ACK2" 2>/dev/null \
    || a2_69="$a2_69 [the step record is not scoped to the commit the checkout is on, so nothing makes it expire]"
  # Scoping the key is half the fact; DROPPING the expired one is the other half, and understand.md's
  # Edge Cases carry it as its own sentence ("the file is rewritten with current-scope entries only, or
  # it grows one line per commit for the life of the checkout"). Asserted here rather than left to A8,
  # which covers only the unscoped pre-change line: `in_scope` can be narrowed to a bare prefix test
  # with every other row still green while the file grows without bound.
  [ "$(grep -c '	step:' "$ACK2" 2>/dev/null)" = 1 ] \
    || a2_69="$a2_69 [the step key from the previous commit survived the rewrite -- expired entries accumulate]"
  [ -z "$a2_69" ] && ok "A2 a commit re-arms the step ceiling whatever total it recorded" \
                  || bad "A2 a commit re-arms the step ceiling whatever total it recorded ($a2_69)"

  # --- A3: a changed open-task set re-arms the task ceiling and the file note -----------------------
  # Both speakers that outlive a commit, in one row, because one rule governs both (IB-013's own closing
  # instruction). The task set is changed with an EMPTY directory: git sees nothing, so neither total
  # moves and the row proves re-arming and nothing else.
  a3_69=""
  S3="$T69/a3"; mkproj "$S3" main
  mkdir -p "$S3/.ai-flow"; printf 'Current phase: **EXECUTE**\n' > "$S3/.ai-flow/STATE.md"
  $GIT -C "$S3" checkout -q -b feat
  nlines 500 > "$S3/feature.txt"
  $GIT -C "$S3" add -A >/dev/null 2>&1; $GIT -C "$S3" commit -q -m feature
  o="$(brake "$S3")"; rc=$?
  { [ "$rc" = 2 ] && printf '%s' "$o" | grep -q 'task ceiling'; } \
    || a3_69="$a3_69 [CONTROL: the task ceiling did not fire on a 500-line branch (exit $rc)]"
  o="$(brake "$S3")"; rc=$?
  [ "$rc" = 0 ] || a3_69="$a3_69 [CONTROL: the task ceiling repeated on an unchanged branch (exit $rc)]"
  mkdir -p "$S3/.ai-flow/artifacts/alpha"
  o="$(brake "$S3")"; rc=$?
  { [ "$rc" = 2 ] && printf '%s' "$o" | grep -q 'task ceiling'; } \
    || a3_69="$a3_69 [the checkout's open task set changed and the task ceiling stayed silent (exit $rc)]"

  S3N="$T69/a3n"; mkbig "$S3N" mod.py 60
  printf 'name: a3n\nlarge_file_lines: 50\n' > "$S3N/.ai-flow/project.yml"
  nlines 5 >> "$S3N/mod.py"
  o="$(note69 "$S3N")"; rc=$?
  { [ "$rc" = 0 ] && printf '%s' "$o" | grep -q 'mod.py'; } \
    || a3_69="$a3_69 [CONTROL: the file note did not speak for a grown large file (exit $rc)]"
  o="$(note69 "$S3N")"; rc=$?
  printf '%s' "$o" | grep -q 'systemMessage' \
    && a3_69="$a3_69 [CONTROL: the file note repeated for an unchanged file]"
  mkdir -p "$S3N/.ai-flow/artifacts/alpha"
  o="$(note69 "$S3N")"; rc=$?
  printf '%s' "$o" | grep -q 'mod.py' \
    || a3_69="$a3_69 [the checkout's open task set changed and the file note stayed silent]"
  [ -z "$a3_69" ] && ok "A3 a changed open-task set re-arms the task ceiling and the file note" \
                  || bad "A3 a changed open-task set re-arms the task ceiling and the file note ($a3_69)"

  # --- A4: added lines only, in both ceilings -------------------------------------------------------
  # 100 added against 300 deleted. Counted as added+deleted it is 400 and refuses; counted as the brake
  # is meant to count it is 100 and says nothing. This is the DIRECTION fix: two of this repository's own
  # commits removed 250 and 37 net lines and were counted at 398 and 417.
  S4="$T69/a4"; mkstep69 "$S4"
  nlines 400 > "$S4/mod.txt"
  $GIT -C "$S4" add -A >/dev/null 2>&1; $GIT -C "$S4" commit -q -m base
  { nlines 100; seq 401 500 | sed 's/^/added /'; } > "$S4/mod.txt"
  a4_69=""
  o="$(brake "$S4")"; rc=$?
  [ "$rc" = 0 ] || a4_69="$a4_69 [a change of 100 added and 300 deleted lines was refused -- deletions are still counted as growth (exit $rc)]"
  # The control's added lines must not repeat content the file already held. `nlines 200` did, and git's
  # diff matched the appended block against the very lines the edit above had deleted -- 200 added and
  # 200 deleted instead of 300 and 300, which is under the re-speaking threshold. The row then reported a
  # control failure that was an artefact of its own fixture. Invisible until the step ceiling learned to
  # acknowledge, because before that it fired without consulting any total.
  seq 601 800 | sed 's/^/fresh /' >> "$S4/mod.txt"
  o="$(brake "$S4")"; rc=$?
  [ "$rc" = 2 ] || a4_69="$a4_69 [CONTROL: 300 genuinely added lines no longer reach the step ceiling (exit $rc)]"
  [ -z "$a4_69" ] && ok "A4 the ceilings count added lines only" \
                  || bad "A4 the ceilings count added lines only ($a4_69)"

  # --- A5: the ledger and the lockfiles are excluded, and the shipped template is not ---------------
  # The exclusion is anchored at the repository root, which is the only thing that keeps THIS repository's
  # own `template/.ai-flow/` counting as the production code it is.
  a5_69=""
  S5="$T69/a5"; mkstep69 "$S5"
  mkdir -p "$S5/.ai-flow/artifacts/alpha"
  nlines 200 > "$S5/.ai-flow/artifacts/alpha/understand.md"
  nlines 200 > "$S5/package-lock.json"
  o="$(brake "$S5")"; rc=$?
  [ "$rc" = 0 ] || a5_69="$a5_69 [the task papers and a lockfile were counted as production code (exit $rc)]"
  S5T="$T69/a5t"; mkstep69 "$S5T"
  mkdir -p "$S5T/template/.ai-flow"
  nlines 200 > "$S5T/template/.ai-flow/project.yml"
  o="$(brake "$S5T")"; rc=$?
  [ "$rc" = 2 ] || a5_69="$a5_69 [the exclusion is not anchored at the root and swallowed a shipped template/.ai-flow/ (exit $rc)]"
  [ -z "$a5_69" ] && ok "A5 the ledger and the lockfiles are excluded, the shipped template is not" \
                  || bad "A5 the ledger and the lockfiles are excluded, the shipped template is not ($a5_69)"

  # --- A6 / A7: the one message a whole task gets says what it measured -----------------------------
  # A remote-tracking base, built by hand: `symbolic-ref refs/remotes/origin/HEAD` is what the hook reads,
  # and it is the shape that produced the single task-ceiling firing in 126 transcripts -- printing
  # `refs/remotes/origin/main` and ordering a split.
  S6="$T69/a6"; mkproj "$S6" main
  mkdir -p "$S6/.ai-flow"; printf 'Current phase: **EXECUTE**\n' > "$S6/.ai-flow/STATE.md"
  $GIT -C "$S6" update-ref refs/remotes/origin/main "$($GIT -C "$S6" rev-parse HEAD)"
  $GIT -C "$S6" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main
  $GIT -C "$S6" checkout -q -b feat
  nlines 500 > "$S6/feature.txt"
  $GIT -C "$S6" add -A >/dev/null 2>&1; $GIT -C "$S6" commit -q -m feature
  o6="$(brake "$S6")"; rc6=$?

  a6_69=""
  { [ "$rc6" = 2 ] && printf '%s' "$o6" | grep -q 'task ceiling'; } \
    || a6_69="$a6_69 [CONTROL: the task ceiling did not fire against a remote-tracking base (exit $rc6)]"
  printf '%s' "$o6" | grep -q 'not yet published' \
    || a6_69="$a6_69 [the notice does not name the total as work not yet published]"
  printf '%s' "$o6" | grep -q 'split into a follow-up task' \
    && a6_69="$a6_69 [the notice still orders a split the operator often cannot perform]"
  [ -z "$a6_69" ] && ok "A6 a remote-tracking base names work not yet published and orders no split" \
                  || bad "A6 a remote-tracking base names work not yet published and orders no split ($a6_69)"

  a7_69=""
  printf '%s' "$o6" | grep -q 'origin/main' \
    || a7_69="$a7_69 [the notice does not name the base at all]"
  printf '%s' "$o6" | grep -q 'refs/remotes/' \
    && a7_69="$a7_69 [the notice prints the base as a refs/remotes/ path]"
  [ -z "$a7_69" ] && ok "A7 the notice names the base in short form" \
                  || bad "A7 the notice names the base in short form ($a7_69)"

  # --- A8: a record written before this change is ignored, and not carried forward ------------------
  # The live record in THIS checkout is one such line -- `593<TAB>`, written 2026-08-23, which has held
  # the task ceiling silent for any task under 743 LOC ever since. Ignored, never migrated: a stale entry
  # that survives the rewrite grows the file one line per commit for the life of the checkout.
  S8="$T69/a8"; mkproj "$S8" main
  mkdir -p "$S8/.ai-flow"; printf 'Current phase: **EXECUTE**\n' > "$S8/.ai-flow/STATE.md"
  $GIT -C "$S8" checkout -q -b feat
  nlines 500 > "$S8/feature.txt"
  $GIT -C "$S8" add -A >/dev/null 2>&1; $GIT -C "$S8" commit -q -m feature
  printf '450\t\n' > "$S8/.git/ai-flow-diff-guard-ack"
  a8_69=""
  o="$(brake "$S8")"; rc=$?
  { [ "$rc" = 2 ] && printf '%s' "$o" | grep -q 'task ceiling'; } \
    || a8_69="$a8_69 [a record written before this change still silences the task ceiling (exit $rc)]"
  grep -q '^450	' "$S8/.git/ai-flow-diff-guard-ack" 2>/dev/null \
    && a8_69="$a8_69 [the stale entry was carried forward into the rewritten record]"
  [ -z "$a8_69" ] && ok "A8 a record written before this change is ignored and dropped" \
                  || bad "A8 a record written before this change is ignored and dropped ($a8_69)"

  # --- A9: a checkout with no commit still refuses --------------------------------------------------
  # There is no HEAD to scope the step record to. Measured this phase: plain `rev-parse HEAD` here exits
  # 128 and prints the literal string `HEAD` on stdout, which the hook's git helper -- which returns
  # stdout and ignores the status -- would hand back as a usable scope. The fallback must be reached by
  # the VERIFIED form, and the record must land under it: the speaking leg alone is green today.
  S9="$T69/a9"
  mkdir -p "$S9/.ai-flow"
  $GIT init -q "$S9"
  $GIT -C "$S9" symbolic-ref HEAD refs/heads/wip
  printf 'Current phase: **EXECUTE**\n' > "$S9/.ai-flow/STATE.md"
  nlines 200 > "$S9/big.txt"
  a9_69=""
  o="$(brake "$S9")"; rc=$?
  { [ "$rc" = 2 ] && printf '%s' "$o" | grep -q 'step ceiling'; } \
    || a9_69="$a9_69 [a checkout with no commit crashed or stayed silent on a 200-line change (exit $rc)]"
  grep -q '	step:' "$S9/.git/ai-flow-diff-guard-ack" 2>/dev/null \
    || a9_69="$a9_69 [no step record was written, so the fallback scope does not exist and the ceiling cannot acknowledge]"
  printf '%s' "$o" | grep -q 'Traceback' \
    && a9_69="$a9_69 [the hook raised]"
  [ -z "$a9_69" ] && ok "A9 a checkout with no commit still refuses an oversized change" \
                  || bad "A9 a checkout with no commit still refuses an oversized change ($a9_69)"

  # --- A10: the step ceiling re-arms when its measure FALLS, with no commit to do it ----------------
  # The step total is the one measure of the three that is not monotonic, and `outgrown` is written for
  # measures that only climb. A commit is the fall this task already handles, by keying the record on
  # HEAD -- but a stash, a revert or an abandoned edit lowers it on the SAME commit, where the key does
  # not move. Without the falling clause a 400-line step acknowledged at 400 silences every later step
  # under 550 with nothing left to re-arm it, which is the silence the block header warns about,
  # arriving by the one door the other rows do not cover.
  S10="$T69/a10"; mkstep69 "$S10"
  nlines 400 > "$S10/big.txt"
  a10_69=""
  o="$(brake "$S10")"; rc=$?
  [ "$rc" = 2 ] || a10_69="$a10_69 [CONTROL: the 400-line step was not refused (exit $rc)]"
  o="$(brake "$S10")"; rc=$?
  [ "$rc" = 0 ] || a10_69="$a10_69 [CONTROL: the acknowledged 400-line step was refused a second time (exit $rc)]"
  # Distinct content, for A4's reason: lines that repeat what the file held get matched against the
  # deletion and the change measures smaller than the row means.
  seq 1 200 | sed 's/^/fresh /' > "$S10/big.txt"
  o="$(brake "$S10")"; rc=$?
  { [ "$rc" = 2 ] && printf '%s' "$o" | grep -q 'step ceiling'; } \
    || a10_69="$a10_69 [a 400-line step was abandoned and a new 200-line one written on the same commit, and the brake stayed silent (exit $rc)]"
  [ -z "$a10_69" ] && ok "A10 a step total that falls re-arms the ceiling without waiting for a commit" \
                   || bad "A10 a step total that falls re-arms the ceiling without waiting for a commit ($a10_69)"

  # --- A11: the local-base tail keeps its own wording ------------------------------------------------
  # A6 asserts the remote-tracking tail positively and asserts the local tail's literal ABSENT there.
  # That is a positive leg for the new half and none for the retained one: the `else` arm -- what every
  # checkout without a remote-tracking base still reads -- could be deleted or folded into the remote
  # wording with the whole suite green. S11's base is a local `main`, which is the arm A6 cannot reach.
  S11="$T69/a11"; mkproj "$S11" main
  mkdir -p "$S11/.ai-flow"; printf 'Current phase: **EXECUTE**\n' > "$S11/.ai-flow/STATE.md"
  $GIT -C "$S11" checkout -q -b feat
  nlines 500 > "$S11/feature.txt"
  $GIT -C "$S11" add -A >/dev/null 2>&1; $GIT -C "$S11" commit -q -m feature
  o11="$(brake "$S11")"; rc=$?
  a11_69=""
  { [ "$rc" = 2 ] && printf '%s' "$o11" | grep -q 'task ceiling'; } \
    || a11_69="$a11_69 [CONTROL: the task ceiling did not fire against a local base (exit $rc)]"
  printf '%s' "$o11" | grep -q 'split into a follow-up task' \
    || a11_69="$a11_69 [the local-base tail lost its own wording -- it is honest there, and nothing else asserts it]"
  printf '%s' "$o11" | grep -q 'not yet published' \
    && a11_69="$a11_69 [a local base claims work not yet published, which the measure does not support there]"
  [ -z "$a11_69" ] && ok "A11 a local base keeps the wording that is honest there" \
                   || bad "A11 a local base keeps the wording that is honest there ($a11_69)"

  # --- O1: the brake never answers WHICH task it is on ----------------------------------------------
  # Read as an inspection criterion in the plan, kept as a row because it is cheap. Green from the
  # start, on purpose: it pins behaviour this change must not CREATE. The task-resolution ladder has ONE
  # implementation (`understand-write-guard.py`), and a second copy of it inside a hook that shares no
  # module is a copy that drifts -- which is the whole reason the record is keyed on a fingerprint of the
  # open task folders and never on which task is active.
  o1_69=""
  grep -q 'state\.md' "$HK/diff-size-guard.py" && o1_69="$o1_69 [the brake reads a task state sheet]"
  grep -q "branch:" "$HK/diff-size-guard.py" && o1_69="$o1_69 [the brake matches a branch: claim -- the ladder has a second implementation]"
  [ -z "$o1_69" ] && ok "O1 the brake asks whether the task set changed, never which task this is" \
                  || bad "O1 the brake asks whether the task set changed, never which task this is ($o1_69)"
else
  echo "  [skip] C69 diff brake checks (python3 unavailable)"
fi

# --- O2 / O3: the prose homes the change falsifies ---------------------------------------------------
# Three of the five files this task touches are prose whose claims the change makes false. Sweeping for
# them is half the job; guarding the repairs is the other half.
#
# Each home is EXTRACTED before it is read, never grepped whole. `execute.md` already carries the phrase
# "the added lines" in an unrelated rule about provenance, and a whole-file sweep would have reported the
# guardrail section as repaired while it still said added-plus-deleted -- a green row over an untouched
# claim, which is the one failure a home guard must not have.
DG69="$(awk '/^## Diff Size Guardrail/{f=1;next} f && /^## /{exit} f' "$ROOT/global/protocols/execute.md" 2>/dev/null)"
# One variable per HOME, never one per file: while lifecycle.md carried two guardrail lines, a `grep`
# over the file concatenated them and a loop reading the concatenation was green while either line alone
# reverted to the wording this task replaced. Both of those copies are citations now and the map is no
# longer a home, so the principle is what remains: each home is selected by its own subject, the way DG69
# above is cut to its own section.
RD69="$(grep -F 'diff-size-guard.py' "$ROOT/global/hooks/README.md" 2>/dev/null)"

o2_69=""
[ -n "$DG69" ] || o2_69="$o2_69 [execute.md's Diff Size Guardrail section did not extract -- heading renamed?]"
[ -n "$RD69" ] || o2_69="$o2_69 [the hooks README carries no row for the brake]"
for pair69 in "execute.md:$DG69" "README.md:$RD69"; do
  n69="${pair69%%:*}"; t69="${pair69#*:}"
  [ -n "$t69" ] || continue
  printf '%s' "$t69" | grep -qiE 'added lines|lines added|added-only' || o2_69="$o2_69 $n69(added-only)"
  printf '%s' "$t69" | grep -qiE 'lock(file|-file)|package-lock'      || o2_69="$o2_69 $n69(lockfiles)"
  printf '%s' "$t69" | grep -qF '.ai-flow'                            || o2_69="$o2_69 $n69(ledger-exclusion)"
done
# The word `lockfile` is not the fact -- the six NAMES are, and they are the hook's to own. Derived from
# `LOCKFILES` in the source, the way A7 above derives THRESHOLD_KEY and FILE_THRESHOLD: add `bun.lockb`
# there and this names every prose home that lags, where a presence grep would stay green over two
# enumerations gone wrong. lifecycle.md is not read here at all any more: both of its copies were routed
# away to a citation, and C73 A1 is what now keeps the two ceilings out of the map.
LOCK69="$(sed -n '/^LOCKFILES = {/,/^}/p' "$HK/diff-size-guard.py" | grep -oE "'[^']+'" | tr -d "'")"
[ -n "$LOCK69" ] || o2_69="$o2_69 [LOCKFILES did not extract from the hook -- the derived leg checked nothing]"
for n69 in $LOCK69; do
  printf '%s' "$DG69" | grep -qF "$n69" || o2_69="$o2_69 execute.md($n69)"
  printf '%s' "$RD69" | grep -qF "$n69" || o2_69="$o2_69 README.md($n69)"
done
# The README row alone additionally states the scope each record is kept at -- the fact IB-013 was
# retired for, and the one a reader cannot derive from the two limits.
printf '%s' "$RD69" | grep -qiE 'task set|open task' || o2_69="$o2_69 README(record-scope)"
[ -z "$o2_69" ] && ok "O2 the two prose homes state added-lines-only and both new exclusions" \
                || bad "O2 the two prose homes state added-lines-only and both new exclusions (missing:$o2_69)"

# O3 is a NEGATIVE home check, and it is the one row that guards the DECISION rather than the code: the
# lockfile list is fixed in the hook precisely so the project layer's two documentation homes stay out of
# this task. Green from the start, on purpose -- like C48's and C49's own negatives, it pins behaviour
# this change must not create, and it is the only thing that would notice the fixed list quietly becoming
# a configurable key.
o3_69=""
for h69 in "$ROOT/template/.ai-flow/project.yml" "$ROOT/docs/customization.md"; do
  grep -qiE 'lock(file|-file)|package-lock' "$h69" \
    && o3_69="$o3_69 ${h69##*/}[the exclusions leaked into the project layer -- the list was to stay fixed in the hook]"
done
[ -z "$o3_69" ] && ok "O3 the project layer's two documentation homes are untouched by this task" \
                || bad "O3 the project layer's two documentation homes are untouched by this task ($o3_69)"
