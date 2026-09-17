echo "== C13: per-task state sheet + workstream roster =="
T13="$(mkbox)" || fatal 'C13 fixtures'
TSTATE="template/.ai-flow/STATE.md"
BLG="global/protocols/backlog.md"

# fence-aware extraction: the section quotes markdown skeletons whose lines start with "## "
sec="$(awk '/^## State Files/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG")"
if [ -n "$sec" ]; then
  # The skeleton's own front example is the naming rule's first reader, and the bare-letter form it used
  # to carry ("ws-b" at "../proj-wt-b") is a name that says nothing at a glance. What is read is what the
  # rule states and nothing else: NEITHER durable cell carries a task identifier ("no task identifier in
  # either" — so the path is read too, not only the name), and the name is a subject rather than a
  # positional label, which is a word and not an initial. What is deliberately NOT read is whether the
  # path contains the name: the rule never says the roster name is the path's basename, and an earlier
  # form of this check required exactly that — it failed a skeleton that obeyed the prose
  # (`digest-emails` at `../proj-wt-email-digest`) while passing `b` at `../proj-wt-b`, the very letter
  # form the rule exists to retire, because a single character is a substring of almost any path.
  # The id pattern tolerates both spellings a front has actually worn (`t-028-…`, `ai-flow-T-013`) and is
  # anchored at a token boundary so an ordinary subject carrying digits (`sunset-2026`) is not read as one.
  # The row read is the first table row that is neither the header, the separator, nor the coordinator's —
  # the coordinator names its own checkout and is not a front, so the rule does not reach it.
  frow="$(printf '%s\n' "$sec" | awk -F'|' '/^\|/ && $2 !~ /Workstream/ && $2 !~ /^[[:space:]]*-+[[:space:]]*$/ && $2 !~ /coordinator/ {print $2 "|" $3; exit}')"
  fname="$(printf '%s' "$frow" | cut -d'|' -f1 | tr -d '[:space:]')"
  fpath="$(printf '%s' "$frow" | cut -d'|' -f2 | tr -d '[:space:]')"
  if [ -n "$fname" ] && [ -n "$fpath" ] \
     && ! printf '%s\n%s\n' "$fname" "$fpath" | grep -qiE '(^|[^a-z0-9])[te]-?[0-9]{3}' \
     && printf '%s' "$fname" | grep -qiE '(^|-)[a-z]{3,}(-|$)'; then
    ok "the roster skeleton names its front by subject"
  else
    bad "the roster skeleton names its front by subject"
  fi
else
  bad "the roster skeleton names its front by subject (no section)"
fi

# --- the rail resolves its own task by branch ----------------------------
if [ "$PY3" = 1 ]; then

  # the sheet naming this branch wins over a sibling and over the ledger
  Q1="$T13/q1"; mkproj "$Q1" main
  ledger "$Q1" EXECUTE
  sheet "$Q1" mine  main  UNDERSTAND
  sheet "$Q1" other other EXECUTE
  out="$(wguard "$Q1" "$Q1/app.txt")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *"artifacts/mine/state.md"*) ok "the rail reads the sheet that names the current branch" ;;
      *) bad "the rail reads the sheet that names the current branch (blocked, but named another file)" ;;
    esac
  else
    bad "the rail reads the sheet that names the current branch (exit $rc)"
  fi

  # a sheet that does not name this branch is ignored, ledger included
  Q2="$T13/q2"; mkproj "$Q2" main
  ledger "$Q2" UNDERSTAND
  sheet "$Q2" mine  main  EXECUTE
  sheet "$Q2" other other UNDERSTAND
  out="$(wguard "$Q2" "$Q2/app.txt")"; rc=$?
  [ "$rc" = 0 ] && ok "a matching sheet wins over a non-matching sibling" \
                || bad "a matching sheet wins over a non-matching sibling (exit $rc)"

  # a sheet with no branch field never counts as a match: the sheet that names this branch wins,
  # and omission read as a wildcard would make the pair ambiguous and block here instead
  Q3="$T13/q3"; mkproj "$Q3" main
  ledger "$Q3" UNDERSTAND
  sheet "$Q3" fieldless -    UNDERSTAND
  sheet "$Q3" mine      main EXECUTE
  out="$(wguard "$Q3" "$Q3/app.txt")"; rc=$?
  [ "$rc" = 0 ] && ok "a sheet without a branch field is not a match" \
                || bad "a sheet without a branch field is not a match (exit $rc)"

  # ...but a lone sheet that names no branch is still this checkout's: a project written before
  # the field keeps the rail it always had
  Q3B="$T13/q3b"; mkproj "$Q3B" main
  ledger "$Q3B" EXECUTE
  sheet "$Q3B" legacy - UNDERSTAND
  out="$(wguard "$Q3B" "$Q3B/app.txt")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *"artifacts/legacy/state.md"*) ok "a lone sheet naming no branch still governs the rail" ;;
      *) bad "a lone sheet naming no branch still governs the rail (blocked, but named another file)" ;;
    esac
  else
    bad "a lone sheet naming no branch still governs the rail (exit $rc)"
  fi

  # A released claim is not a claim. A sheet that once owned this branch and gave the claim up keeps
  # the fact in a field the rail's pattern cannot reach, so the live sheet beside it resolves alone.
  # The fixture discriminates: were the released line read as a claim, the pair would be ambiguous and
  # the question would go to the ledger, which sits at UNDERSTAND here and would block.
  rsheet() {  # $1 = repo, $2 = task dir, $3 = released branch, $4 = phase
    mkdir -p "$1/.ai-flow/artifacts/$2"
    { printf '# Task state\n\n'
      printf 'released-branch: %s\n' "$3"
      printf 'phase: **%s**\n' "$4"
    } > "$1/.ai-flow/artifacts/$2/state.md"
  }

  Q10="$T13/q10"; mkproj "$Q10" main
  ledger "$Q10" UNDERSTAND
  rsheet "$Q10" paused main UNDERSTAND
  sheet  "$Q10" active main EXECUTE
  out="$(wguard "$Q10" "$Q10/app.txt")"; rc=$?
  [ "$rc" = 0 ] && ok "a released claim beside a live one does not contest it" \
                || bad "a released claim beside a live one does not contest it (exit $rc)"

  # ...and a released claim left alone is still this checkout's own task: releasing the claim must not
  # cost a lone paused task the rail it had, which is the pre-field behaviour this change cannot regress.
  Q11="$T13/q11"; mkproj "$Q11" main
  ledger "$Q11" EXECUTE
  rsheet "$Q11" lonely main UNDERSTAND
  out="$(wguard "$Q11" "$Q11/app.txt")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *"artifacts/lonely/state.md"*) ok "a lone released claim still governs the rail" ;;
      *) bad "a lone released claim still governs the rail (blocked, but named another file)" ;;
    esac
  else
    bad "a lone released claim still governs the rail (exit $rc)"
  fi

  # Two released claims and none live — the ordinary result of two paused tasks once the released form
  # exists. Neither is alone among the sheets declaring no branch, so the question goes to the ledger:
  # the spec calls this acceptable, and an outcome declared acceptable is asserted, never assumed.
  Q12="$T13/q12"; mkproj "$Q12" main
  ledger "$Q12" UNDERSTAND
  rsheet "$Q12" pausedA main UNDERSTAND
  rsheet "$Q12" pausedB main EXECUTE
  out="$(wguard "$Q12" "$Q12/app.txt")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *".ai-flow/STATE.md"*) ok "two released claims and none live defer to the ledger" ;;
      *) bad "two released claims and none live defer to the ledger (named another file)" ;;
    esac
  else
    bad "two released claims and none live defer to the ledger (exit $rc)"
  fi


  # the lone sheet of ANOTHER workstream never governs this checkout: the coordinator holding the
  # worktree's task sheet must not be judged by a phase it is not working
  Q4="$T13/q4"; mkproj "$Q4" main
  ledger "$Q4" EXECUTE
  sheet "$Q4" only you/t-b UNDERSTAND
  out="$(wguard "$Q4" "$Q4/app.txt")"; rc=$?
  [ "$rc" = 0 ] && ok "a lone sheet naming another branch does not govern this checkout" \
                || bad "a lone sheet naming another branch does not govern this checkout (exit $rc)"

  Q5="$T13/q5"; mkproj "$Q5" main
  ledger "$Q5" UNDERSTAND
  sheet "$Q5" one nope1 EXECUTE
  sheet "$Q5" two nope2 EXECUTE
  out="$(wguard "$Q5" "$Q5/app.txt")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *".ai-flow/STATE.md"*) ok "no branch match and several sheets fall back to the ledger" ;;
      *) bad "no branch match and several sheets fall back to the ledger (named another file)" ;;
    esac
  else
    bad "no branch match and several sheets fall back to the ledger (exit $rc)"
  fi

  # a resolved phase past UNDERSTAND lifts the rail
  Q6="$T13/q6"; mkproj "$Q6" main
  ledger "$Q6" UNDERSTAND
  sheet "$Q6" mine main EXECUTE
  out="$(wguard "$Q6" "$Q6/app.txt")"; rc=$?
  [ "$rc" = 0 ] && ok "a resolved phase past UNDERSTAND lifts the rail" \
                || bad "a resolved phase past UNDERSTAND lifts the rail (exit $rc)"

  # a migrated roster carries no phase, so falling back to it leaves the rail off — silence by
  # design, asserted here rather than assumed
  Q8="$T13/q8"; mkproj "$Q8" main
  mkdir -p "$Q8/.ai-flow"
  cp "$ROOT/template/.ai-flow/STATE.md" "$Q8/.ai-flow/STATE.md"
  sheet "$Q8" other other UNDERSTAND
  out="$(wguard "$Q8" "$Q8/app.txt")"; rc=$?
  [ "$rc" = 0 ] && ok "a migrated roster leaves no phase to read: the rail is off, not misread" \
                || bad "a migrated roster leaves no phase to read: the rail is off, not misread (exit $rc)"

  # two sheets claiming the same branch is ambiguous: no unique owner, so the question goes to the
  # ledger — which in an unmigrated project still answers
  Q9="$T13/q9"; mkproj "$Q9" main
  ledger "$Q9" UNDERSTAND
  sheet "$Q9" paused main EXECUTE
  sheet "$Q9" active main UNDERSTAND
  out="$(wguard "$Q9" "$Q9/app.txt")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *".ai-flow/STATE.md"*) ok "two sheets claiming one branch defer to the ledger" ;;
      *) bad "two sheets claiming one branch defer to the ledger (named another file)" ;;
    esac
  else
    bad "two sheets claiming one branch defer to the ledger (exit $rc)"
  fi

  # end to end, the shape this task exists for: a linked worktree with no ledger of its own, holding
  # copies of every task's sheet, is judged by the one naming its branch
  QP="$T13/qp"; mkproj "$QP" main
  QW="$T13/qw"; $GIT -C "$QP" worktree add -q -b you/t-b "$QW" >/dev/null 2>&1
  sheet "$QW" mine  you/t-b UNDERSTAND
  sheet "$QW" other main    EXECUTE
  out="$(wguard "$QW" "$QW/app.txt")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *"artifacts/mine/state.md"*) ok "a worktree with no ledger is judged by the sheet naming its branch" ;;
      *) bad "a worktree with no ledger is judged by the sheet naming its branch (blocked, but named another file)" ;;
    esac
  else
    bad "a worktree with no ledger is judged by the sheet naming its branch (exit $rc)"
  fi

  # a detached HEAD has no branch to match: the fallback still answers
  Q7="$T13/q7"; mkproj "$Q7" main
  sheet "$Q7" only main UNDERSTAND
  $GIT -C "$Q7" checkout -q --detach >/dev/null 2>&1
  out="$(wguard "$Q7" "$Q7/app.txt")"; rc=$?
  [ "$rc" = 2 ] && ok "a detached HEAD falls back instead of going silent" \
                || bad "a detached HEAD falls back instead of going silent (exit $rc)"
else
  echo "  [skip] branch-resolution checks (python3 unavailable)"
fi

# --- opening a workstream is a ceremony ----------------------------------
BLG3="global/protocols/backlog.md"
# fence-aware, same idiom as the State Files extraction: skeletons quoted inside the section
# start their lines with "## " and must not be read as the end of it.
CER="$(awk '/^## Opening a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG3")"
cerline() { printf '%s' "$CER" | grep -niEm1 "$1" | cut -d: -f1; }

# The one-directional protocol check that stood here is retired, absorbed whole by C37's A1. It was read
# before being retired rather than matched by shape: what it covered was a protocol that had APPEARED,
# which is A1's `extra` leg; a protocol that had DISAPPEARED it could not see, and that is the leg A1 adds.
