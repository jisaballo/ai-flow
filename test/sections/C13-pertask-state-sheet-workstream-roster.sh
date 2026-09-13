echo "== C13: per-task state sheet + workstream roster =="
T13="$(mkbox)" || fatal 'C13 fixtures'
trap 'rm -rf "$T12" "$T13"' EXIT
TSTATE="template/.ai-flow/STATE.md"
BLG="global/protocols/backlog.md"

# --- the two shapes, written down ----------------------------------------
if grep -q '^## Workstreams' "$TSTATE" \
   && grep -qiE '^\|[^|]*workstream[^|]*\|[^|]*checkout[^|]*\|[^|]*task[^|]*\|' "$TSTATE" \
   && grep -q '^## Quick Tasks Completed' "$TSTATE"; then
  ok "the shipped session file is a workstream roster"
else
  bad "the shipped session file is a workstream roster"
fi
if grep -qiE '^[[:space:]]*(phase|step|autonomy|decisions)[[:space:]]*:' "$TSTATE" \
   || grep -q '^## Current Task' "$TSTATE"; then
  bad "the roster carries no per-task field"
else
  ok "the roster carries no per-task field"
fi

# fence-aware extraction: the section quotes markdown skeletons whose lines start with "## "
sec="$(awk '/^## State Files/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG")"
if [ -n "$sec" ]; then
  ok "the protocol has a State Files section"
  miss=""
  printf '%s' "$sec" | grep -q 'artifacts/T-XXX/state.md'        || miss="$miss sheet-path"
  printf '%s' "$sec" | grep -q '## Workstreams'                  || miss="$miss roster-skeleton"
  printf '%s' "$sec" | grep -q 'phase: \*\*'                     || miss="$miss phase-line-form"
  printf '%s' "$sec" | grep -qE '^[[:space:]]*branch:'           || miss="$miss branch-field"
  printf '%s' "$sec" | grep -qi 'coordinator'                    || miss="$miss coordinator-writer"
  printf '%s' "$sec" | grep -qi 'ceremon'                        || miss="$miss ceremony-timing"
  printf '%s' "$sec" | grep -qi 'migrat'                         || miss="$miss migration-note"
  [ -z "$miss" ] && ok "the protocol defines both state files and their writers" \
                 || bad "the protocol defines both state files and their writers (missing:$miss)"
  printf '%s' "$sec" | grep -qi 'activation' \
    && ok "the protocol mandates the sheet at activation" \
    || bad "the protocol mandates the sheet at activation"
  # A4 -- CONTROL. The sheet skeleton shall declare an `autonomy:` line. Green from the start by
  # construction rather than by achievement: the field is already there, and what was missing is any
  # assertion over it -- the battery above pins the sheet path, `phase:` and `branch:`, and `autonomy:`
  # was asserted only NEGATIVELY, at the roster leg, as a field the roster must not carry. So the field
  # three commands are about to depend on could be deleted from the skeleton with the suite green. Its
  # own row rather than another entry in `miss`, so it can be mutated on its own.
  printf '%s' "$sec" | grep -qE '^[[:space:]]*autonomy:' \
    && ok "A4 control: the sheet skeleton declares the autonomy line the commands read" \
    || bad "A4 control: the sheet skeleton declares the autonomy line the commands read"
  printf '%s' "$sec" | grep -qi 'paused' \
    && ok "the protocol states a paused task keeps its sheet" \
    || bad "the protocol states a paused task keeps its sheet"
  printf '%s' "$sec" | grep -qi 'quick' \
    && ok "the protocol states a quick task gets no sheet" \
    || bad "the protocol states a quick task gets no sheet"

  # The Tool column, on the same terms the Checkout paragraph is held to: the COUNT is the fact, because
  # a definition naming half the readership is what the next person prices a change to this column from.
  # It named one reader while a second had just been added — the archive checklist's label rewrite, which
  # runs in the coordinator and has nothing but this column to learn the front's tool from.
  tsec="$(printf '%s\n' "$sec" | awk '/^\*\*Tool\*\*/{f=1} f&&/^## Workstreams/{exit} f' | tr '\n' ' ' | tr -s ' ')"
  m37t=""
  printf '%s' "$tsec" | grep -qE '\*\*Tool\*\*'                  || m37t="$m37t undefined"
  printf '%s' "$tsec" | grep -qiE '\btwo\b'                        || m37t="$m37t reader-count-unstated"
  printf '%s' "$tsec" | grep -qiE 'dismantl'                       || m37t="$m37t dismantling-unnamed"
  printf '%s' "$tsec" | grep -qiE 'step 8|archive checklist'       || m37t="$m37t label-rewrite-unnamed"
  [ -z "$m37t" ] && ok "the tool column is defined where it lives, and names both sites that read it" \
                 || bad "the tool column is defined where it lives, and names both sites that read it (:$m37t)"

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
  bad "the protocol has a State Files section"
  bad "the protocol defines both state files and their writers (no section)"
  bad "the protocol mandates the sheet at activation (no section)"
  bad "the protocol states a paused task keeps its sheet (no section)"
  bad "the protocol states a quick task gets no sheet (no section)"
  bad "the roster skeleton names its front by subject (no section)"
  bad "the tool column is defined where it lives, and names both sites that read it (no section)"
fi

if grep -q 'index of open workstreams' "$BLG" \
   && ! grep -q 'STATE.md contains only current task context' "$BLG" \
   && awk '/^### Allowed structure/{f=1} f' "$BLG" | grep -q 'state.md'; then
  ok "the invariants and the allowed structure name the new shape"
else
  bad "the invariants and the allowed structure name the new shape"
fi

# --- no engine line routes per-task state to the roster ------------------
QP="global/protocols/quick-path.md"
if ! grep -q '\*\*Inline plan\*\* in STATE.md' "$QP" \
   && ! grep -qx '\- STATE.md updated' "$QP" \
   && grep -qi 'no state' "$QP"; then
  ok "the quick path writes no state into the ledger"
else
  bad "the quick path writes no state into the ledger"
fi

sweep=""
grep -q 'Update STATE.md with step progress' global/CLAUDE.md          && sweep="$sweep manual-step-progress"
grep -q 'While STATE.md marks the current phase' global/protocols/understand.md && sweep="$sweep understand-rail"
grep -q 'CLAUDE.md, STATE.md, understand.md' global/protocols/execute.md && sweep="$sweep execute-agent-input"
head -12 global/hooks/understand-write-guard.py | grep -qi 'branch'    || sweep="$sweep hook-docstring"
grep -qi 'branch' global/hooks/README.md                               || sweep="$sweep hooks-readme"
[ -z "$sweep" ] && ok "no engine file routes per-task state to the ledger" \
               || bad "no engine file routes per-task state to the ledger (stale:$sweep)"

twin="$HOME/.claude/CLAUDE.md"
if manstate global/CLAUDE.md; then
  ok "the shipped manual sends step progress to the task sheet"
  # Each copy is judged on itself, and only when it is there to open: a verdict about a manual the
  # host does not own blames a reader for a file they never had.
  if [ -f "$twin" ]; then
    manstate "$twin" \
      && ok "the live twin sends step progress to the task sheet" \
      || bad "the live twin sends step progress to the task sheet (stale — port the edit by hand, nothing distributes ~/.claude/CLAUDE.md)"
  else
    echo "  [skip] live CLAUDE.md twin absent — the shipped one names the task sheet"
  fi
else
  bad "the shipped manual sends step progress to the task sheet"
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

if [ -n "$CER" ]; then
  # the seven moves, present AND in the only order that is safe: nothing is created before the
  # comparison has a verdict, and nothing is pruned before there is a checkout to prune.
  miss=""
  n1="$(cerline 'mint')";    [ -n "$n1" ] || miss="$miss mint"
  n2="$(cerline 'areas')";   [ -n "$n2" ] || miss="$miss areas"
  n3="$(cerline 'overlap|compare')"; [ -n "$n3" ] || miss="$miss compare"
  n4="$(cerline 'publish')"; [ -n "$n4" ] || miss="$miss publish"
  n5="$(cerline 'worktree tooling|create the linked worktree')"; [ -n "$n5" ] || miss="$miss create"
  n6="$(cerline 'prune')";   [ -n "$n6" ] || miss="$miss prune"
  n7="$(cerline 'roster row')"; [ -n "$n7" ] || miss="$miss roster-row"
  if [ -n "$miss" ]; then
    bad "the protocol defines the ceremony that opens a workstream (steps not found:$miss)"
  elif [ "$n1" -lt "$n2" ] && [ "$n2" -lt "$n3" ] && [ "$n3" -lt "$n4" ] \
     && [ "$n4" -lt "$n5" ] && [ "$n5" -lt "$n6" ] && [ "$n6" -lt "$n7" ]; then
    ok "the protocol defines the ceremony that opens a workstream"
  else
    bad "the protocol defines the ceremony that opens a workstream (steps out of order)"
  fi

  # the ordinary case must survive: one front open means there is nothing to weigh and no
  # checkout to create. Without this the ceremony reads as a six-step ritual for every activation.
  printf '%s' "$CER" | tr '\n' ' ' | grep -qiE 'single front|one front open' \
    && printf '%s' "$CER" | tr '\n' ' ' | grep -qiE 'nothing to do|no other front' \
    && ok "a single open front has nothing to weigh and nothing to create" \
    || bad "a single open front has nothing to weigh and nothing to create"

  pair 3 'acknowledg' 'sheet|state\.md' "a collision stops the opening until it is acknowledged in the sheet"
  pair 3 'cannot compare' 'never|not .*clear'  "a front with no declaration reads as cannot-compare, not as clear"
  pair 4 'publish' 'stop|before anything is created' "opening stops on an unpublished default branch"
  pair 6 'prune' 'own|owns' "the ceremony prunes the new checkout to the task it owns"
  pair 6 'BACKLOG|ledger' 'never copied|not copied|stays with|read-only' "the ceremony never copies the ledger into a worktree"
  pair 6 'copies' 'originals' "the pruning step names what it deletes"

  # The naming rule. Move 5 settled which tool creates the checkout and the four conditions it must
  # satisfy, and said nothing about the one job the checkout does at a glance — so the name came from
  # whatever the tool asked for at creation. Measured across the nine named fronts this operator has
  # opened: three competing conventions, and four of the six named for a task outlived that task.
  # Each pair reads a DIFFERENT clause on purpose: a pair whose two patterns are fed by one sentence
  # dies only when that sentence goes, and approves any prose that keeps its vocabulary.
  pair 5 'chosen once|never rewritten' 'mutable label' "the ceremony says what a front is called"
  pair 5 'subject' 'no task identifier|no task id' "a front's durable name carries its subject and no task id"
  # The branch is the field the ticket wanted to bundle with the path and the one field that cannot be:
  # it changes with every task in a front's chain, which is why the roster was never keyed on it.
  pair 5 'never the branch' 'task-scoped' "the naming rule leaves the branch task-scoped"
  # The floor, said out loud. A silence here reads as a missing step rather than as a deliberate one.
  pair 5 'offers no|offers none' 'roster is the glance' "with no mutable label the roster is the glance"
  # WHICH two fields are durable is the rule's load-bearing content, and it was deletable with every
  # assertion above green: strike the clause naming them and the sentence still says two fields are
  # chosen once and carry the subject, while no longer saying which two. The roster-row half is the
  # column where a task id was actually found sitting.
  pair 5 'checkout.s own path' 'name on its roster row' "the durable identity names both of its surfaces"
  # The forward citation, by NUMBER. The suite already treats an unpinned numeric cross-reference as a
  # defect one section down — a half-renumber leaves a citation pointing at the wrong move while the
  # section title still matches — and this rule mints two such citations, one in each direction.
  pair 5 'step 8' 'After ARCHIVE' "the label rewrite cites the step that performs it"
else
  bad "the protocol defines the ceremony that opens a workstream"
  bad "a single open front has nothing to weigh and nothing to create (no section)"
  bad "a collision stops the opening until it is acknowledged in the sheet (no section)"
  bad "a front with no declaration reads as cannot-compare, not as clear (no section)"
  bad "opening stops on an unpublished default branch (no section)"
  bad "the ceremony prunes the new checkout to the task it owns (no section)"
  bad "the ceremony never copies the ledger into a worktree (no section)"
  bad "the pruning step names what it deletes (no section)"
  bad "the ceremony says what a front is called (no section)"
  bad "a front's durable name carries its subject and no task id (no section)"
  bad "the naming rule leaves the branch task-scoped (no section)"
  bad "with no mutable label the roster is the glance (no section)"
  bad "the durable identity names both of its surfaces (no section)"
  bad "the label rewrite cites the step that performs it (no section)"
fi

# The one-directional protocol check that stood here is retired, absorbed whole by C37's A1. It was read
# before being retired rather than matched by shape: what it covered was a protocol that had APPEARED,
# which is A1's `extra` leg; a protocol that had DISAPPEARED it could not see, and that is the leg A1 adds.

# the column the check reads, in the shipped roster and in the protocol's own skeleton.
# The migration region is bounded at the next heading: unbounded, it ran to EOF and read the
# ceremony's own text, which made this assertion incapable of failing.
ROSTER_RE='^\|[^|]*[Ww]orkstream[^|]*\|[^|]*[Cc]heckout[^|]*\|[^|]*[Tt]ask[^|]*\|[^|]*[Ee]pic[^|]*\|[^|]*[Aa]reas[^|]*\|'
if grep -qE "$ROSTER_RE" "template/.ai-flow/STATE.md" \
   && grep -qE "$ROSTER_RE" "$BLG3" \
   && awk '/^### Migrating an existing ledger/{f=1;next} /^#+ /{f=0} f' "$BLG3" | grep -qi 'areas'; then
  ok "the shipped roster declares each front's areas"
else
  bad "the shipped roster declares each front's areas"
fi

# a linked worktree reaches its epic's frozen boundaries without owning them, and knows what to
# do when it cannot reach them at all
UND="global/protocols/understand.md"
if grep -iE 'Scope Contract' "$UND" | grep -qiE 'worktree list|main checkout|coordinator' \
   && grep -iE 'Scope Contract' "$UND" | grep -qiE 'read-only'; then
  ok "a linked worktree reads its epic contract from the coordinator, read-only"
else
  bad "a linked worktree reads its epic contract from the coordinator, read-only"
fi
awk '/^## Epic-Scoped Understanding/{f=1;next} /^## /{f=0} f' "$UND" | tr '\n' ' ' \
  | grep -qiE 'cannot be reached|unreadable|cannot read' \
  && ok "an unreachable contract blocks the Understand instead of vanishing" \
  || bad "an unreachable contract blocks the Understand instead of vanishing"

# documented and reachable, and now in two files on purpose. The manual owes the ROUTE — its phase table
# sends activation to the backlog protocol — and it owes that route in the repo copy and in the live twin
# that no drift check covers. The bullet that also NAMED the ceremony left with the phase descriptions;
# the map owes that half, and owes it in the one document that describes phases. Asserting the route
# against the manual and the naming against the map is the split itself: a manual that routes and a map
# that describes cannot both go stale from one edit in one place.
ACT_RE='^\|[[:space:]]*Activate[^|]*\|[^|]*backlog\.md[^|]*\|'
LC_MAP='global/protocols/lifecycle.md'
# Scoped to the ACTIVATE section and terminated at the next heading of any depth: a file-wide grep for
# the ceremony finds the ARCHIVE phase's own mention and reports activation documented on its strength.
ACT_CEREMONY="$(awk '/^### 3\. ACTIVATE/{f=1;next} f && /^#+ /{exit} f' "$LC_MAP" 2>/dev/null)"
twin2="$HOME/.claude/CLAUDE.md"
if grep -qE "$ACT_RE" global/CLAUDE.md; then
  ok "the global instructions route activation to the backlog protocol"
  if [ -f "$twin2" ]; then
    grep -qE "$ACT_RE" "$twin2" \
      && ok "the live twin routes activation to the backlog protocol" \
      || bad "the live twin routes activation to the backlog protocol (stale — port the edit by hand, nothing distributes ~/.claude/CLAUDE.md)"
  else
    echo "  [skip] live CLAUDE.md twin absent — the shipped one routes activation"
  fi
else
  bad "the global instructions route activation to the backlog protocol"
  bad "the live twin routes activation to the backlog protocol (shipped copy is stale)"
fi
if [ -n "$ACT_CEREMONY" ] && printf '%s' "$ACT_CEREMONY" | grep -qi 'opening ceremony'; then
  ok "the map names the ceremony activation runs"
else
  bad "the map names the ceremony activation runs"
fi
