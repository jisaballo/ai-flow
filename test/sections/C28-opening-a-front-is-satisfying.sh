echo "== C28: opening a front is satisfying conditions, not using a brand =="
BLG25="global/protocols/backlog.md"
SEED25="global/scripts/seed-front.sh"

# Fence-aware section cut, then one numbered move flattened AND whitespace-squeezed. Joining wrapped
# lines leaves their indentation behind, so a two-word fact split across a break reads with a run of
# spaces in it and every single-space pattern misses it. Classifying on the move number rather than on
# a body pattern is what lets these assertions see a move that MOVED.
OPN25="$(awk '/^## Opening a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG25")"
CLO25="$(awk '/^## Closing a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG25")"
o25() { printf '%s\n' "$OPN25" | awk -v n="$1" '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==n' | tr '\n' ' ' | tr -s ' '; }
c25() { printf '%s\n' "$CLO25" | awk -v n="$1" '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==n' | tr '\n' ' ' | tr -s ' '; }

# --- the engine satisfies its own visibility condition -------------------
# Asked of git, never of the file: the question is whether the path is ignored, and git is what
# answers that — a grep for the line would pass on a commented-out pattern and fail on a broader one
# that already covers it.
if git -C "$ROOT" check-ignore -q ".claude/worktrees/probe/app.txt" 2>/dev/null; then
  ok "the engine's own checkout satisfies the visibility condition"
else
  bad "the engine's own checkout satisfies the visibility condition (.claude/worktrees/ is not ignored here)"
fi

# --- the seeding mechanism, executed ------------------------------------
# Every assertion below runs the shipped script against a fixture repository. Grepping the script for
# the message a refusal would print proves the message exists, never that anything reaches it.
if [ ! -x "$SEED25" ]; then
  bad "the seeder leaves the ledger behind from a project that ignores its own data directory (no executable $SEED25)"
  bad "the seeder leaves only the papers of the task it seeds (no executable $SEED25)"
  bad "the seeder reads the project data from the primary, not from the checkout it runs in (no executable $SEED25)"
  bad "the seeder refuses an unusable pattern file and copies nothing (no executable $SEED25)"
elif ! T25="$(mkbox)" || [ ! -d "$T25" ]; then
  # A sandbox that silently failed to exist degenerates every verdict below into "nothing went wrong".
  bad "the seeder leaves the ledger behind from a project that ignores its own data directory (no sandbox: mktemp -d failed)"
  bad "the seeder leaves only the papers of the task it seeds (no sandbox: mktemp -d failed)"
  bad "the seeder reads the project data from the primary, not from the checkout it runs in (no sandbox: mktemp -d failed)"
  bad "the seeder refuses an unusable pattern file and copies nothing (no sandbox: mktemp -d failed)"
else
  G25="git -c user.email=t@t.t -c user.name=t -c commit.gpgsign=false"
  SEED_ABS="$ROOT/$SEED25"

  # A primary in the layout the product documents: the data directory is IGNORED, which is the
  # precondition the pattern file needs — and the reason the pattern file must be evaluated somewhere
  # its own project's ignore rules cannot answer for it.
  mk25() {  # $1 = root dir -> a primary with data, a ledger, two foreign task folders, and a front
    mkdir -p "$1"
    $G25 init -q "$1"
    printf '/.ai-flow/\n' > "$1/.gitignore"
    printf 'x\n' > "$1/app.txt"
    cp "$ROOT/template/.worktreeinclude" "$1/.worktreeinclude"
    mkdir -p "$1/.ai-flow/steering" \
             "$1/.ai-flow/artifacts/foreign-one" "$1/.ai-flow/artifacts/foreign-two"
    printf 'name: fixture\n' > "$1/.ai-flow/project.yml"
    # A file BELOW a directory pattern. Without one, every seedable path is top-level and a mechanism
    # that flattens `.ai-flow/steering/` into `.ai-flow/` passes untouched — which is the defect the
    # shipped mechanism was written to replace.
    printf 'rule\n'          > "$1/.ai-flow/steering/auth.md"
    printf '# product\n'     > "$1/.ai-flow/product.md"
    printf '# backlog\n'     > "$1/.ai-flow/BACKLOG.md"
    printf '# state\n'       > "$1/.ai-flow/STATE.md"
    printf 'a\n' > "$1/.ai-flow/artifacts/foreign-one/state.md"
    printf 'b\n' > "$1/.ai-flow/artifacts/foreign-two/state.md"
    $G25 -C "$1" add -A >/dev/null 2>&1
    $G25 -C "$1" commit -q -m init
  }

  # 1) the ledger stays behind, from a project that ignores the very directory the patterns describe
  P25A="$T25/a"; mk25 "$P25A"
  $G25 -C "$P25A" worktree add -q -b you/t-300 "$T25/a-front" >/dev/null 2>&1
  ( cd "$P25A" && "$SEED_ABS" "$T25/a-front" own ) >/dev/null 2>&1
  l25=""
  [ -f "$T25/a-front/.ai-flow/project.yml" ] || l25="$l25 project.yml-missing"
  [ -f "$T25/a-front/.ai-flow/product.md" ]  || l25="$l25 product.md-missing"
  [ -e "$T25/a-front/.ai-flow/BACKLOG.md" ]  && l25="$l25 BACKLOG-leaked"
  [ -e "$T25/a-front/.ai-flow/STATE.md" ]    && l25="$l25 STATE-leaked"
  [ -z "$l25" ] \
    && ok "the seeder leaves the ledger behind from a project that ignores its own data directory" \
    || bad "the seeder leaves the ledger behind from a project that ignores its own data directory ($l25)"

  # 2) the front owns one task: the copy carried every open task's papers, and the prune is what
  #    leaves one. The fixture holds papers the front does NOT own, or nothing is being pruned.
  p25=""
  [ -d "$T25/a-front/.ai-flow/artifacts/own" ] || p25="$p25 own-folder-missing"
  [ -e "$T25/a-front/.ai-flow/artifacts/foreign-one" ] && p25="$p25 foreign-one-kept"
  [ -e "$T25/a-front/.ai-flow/artifacts/foreign-two" ] && p25="$p25 foreign-two-kept"
  [ -z "$p25" ] \
    && ok "the seeder leaves only the papers of the task it seeds" \
    || bad "the seeder leaves only the papers of the task it seeds ($p25)"

  # 3) run from inside the front, the source is the PRIMARY. The checkout it runs in has no data at
  #    all, so reading the toplevel of the current directory copies from an empty hand.
  P25B="$T25/b"; mk25 "$P25B"
  $G25 -C "$P25B" worktree add -q -b you/t-400 "$T25/b-front" >/dev/null 2>&1
  ( cd "$T25/b-front" && "$SEED_ABS" . own ) >/dev/null 2>&1
  if [ -f "$T25/b-front/.ai-flow/project.yml" ] && [ ! -e "$T25/b-front/.ai-flow/STATE.md" ]; then
    ok "the seeder reads the project data from the primary, not from the checkout it runs in"
  else
    bad "the seeder reads the project data from the primary, not from the checkout it runs in"
  fi

  # 4) an unusable pattern set is a refusal, not an empty selection. git reads an unreadable or empty
  #    pattern file as an empty set of patterns and answers "not selected" for everything — so a
  #    mechanism that concludes from it seeds nothing and reports success.
  P25C="$T25/c"; mk25 "$P25C"
  : > "$P25C/.worktreeinclude"
  $G25 -C "$P25C" worktree add -q -b you/t-500 "$T25/c-front" >/dev/null 2>&1
  ( cd "$P25C" && "$SEED_ABS" "$T25/c-front" own ) >/dev/null 2>&1; rc25=$?
  if [ "$rc25" != 0 ] && [ ! -e "$T25/c-front/.ai-flow" ]; then
    ok "the seeder refuses an unusable pattern file and copies nothing"
  else
    bad "the seeder refuses an unusable pattern file and copies nothing (exit $rc25)"
  fi

  # 5) papers the front already holds are its own work, not a copy. A front taking on its next task
  #    runs this move over a checkout it has been working, and the coordinator's copy of those papers
  #    is a snapshot from when the front opened: overwriting them, or pruning them as foreign, would
  #    destroy the only account of work in progress. Distinct content, so the check sees a REPLACED
  #    file and not merely a present one.
  P25D="$T25/d"; mk25 "$P25D"
  # The coordinator holds ITS OWN copy of the paused task's papers — a snapshot frozen when the front
  # opened. Without it here, nothing in the transfer could overwrite the front's version and the
  # overwrite leg below would pass on a mechanism that clobbers.
  mkdir -p "$P25D/.ai-flow/artifacts/paused"
  printf 'stale snapshot\n' > "$P25D/.ai-flow/artifacts/paused/state.md"
  $G25 -C "$P25D" worktree add -q -b you/t-700 "$T25/d-front" >/dev/null 2>&1
  mkdir -p "$T25/d-front/.ai-flow/artifacts/paused"
  printf 'live work\n' > "$T25/d-front/.ai-flow/artifacts/paused/state.md"
  printf 'name: edited-in-the-front\n' > "$T25/d-front/.ai-flow/project.yml"
  ( cd "$P25D" && "$SEED_ABS" "$T25/d-front" own paused ) >/dev/null 2>&1
  k25=""
  [ -f "$T25/d-front/.ai-flow/artifacts/paused/state.md" ] || k25="$k25 paused-task-pruned"
  grep -q 'live work' "$T25/d-front/.ai-flow/artifacts/paused/state.md" 2>/dev/null || k25="$k25 paused-task-overwritten"
  grep -q 'edited-in-the-front' "$T25/d-front/.ai-flow/project.yml" 2>/dev/null || k25="$k25 existing-file-overwritten"
  [ -d "$T25/d-front/.ai-flow/artifacts/own" ] || k25="$k25 own-folder-missing"
  [ -z "$k25" ] \
    && ok "the seeder keeps the papers the front already holds" \
    || bad "the seeder keeps the papers the front already holds ($k25)"

  # 6) a file BELOW a directory pattern arrives at its own path. The mechanism this replaced copied
  #    `.ai-flow/steering/` with a trailing slash, which lands the CONTENTS one level up: the flattened
  #    path is asserted absent, or the check passes on a mechanism that flattens and copies twice.
  f25=""
  [ -f "$T25/a-front/.ai-flow/steering/auth.md" ] || f25="$f25 nested-file-missing"
  [ -e "$T25/a-front/.ai-flow/auth.md" ]          && f25="$f25 flattened-into-the-parent"
  [ -z "$f25" ] \
    && ok "a file below a directory pattern arrives at its own path" \
    || bad "a file below a directory pattern arrives at its own path ($f25)"

  # 7) THE NATIVE PATH. There the front-end copies the artifacts directory wholesale at creation, so the
  #    checkout already holds every open task's papers before this runs — and the prune is the only thing
  #    that makes the data condition true. A keep-list inferred from what is already present cannot prune
  #    anything here, which is why the tasks that stay are declared instead.
  P25E="$T25/e"; mk25 "$P25E"
  $G25 -C "$P25E" worktree add -q -b you/t-800 "$T25/e-front" >/dev/null 2>&1
  mkdir -p "$T25/e-front/.ai-flow"
  cp -R "$P25E/.ai-flow/artifacts" "$T25/e-front/.ai-flow/artifacts"   # what the native tooling leaves
  ( cd "$P25E" && "$SEED_ABS" "$T25/e-front" own ) >/dev/null 2>&1
  n25=""
  [ -e "$T25/e-front/.ai-flow/artifacts/foreign-one" ] && n25="$n25 foreign-one-kept"
  [ -e "$T25/e-front/.ai-flow/artifacts/foreign-two" ] && n25="$n25 foreign-two-kept"
  [ -d "$T25/e-front/.ai-flow/artifacts/own" ]         || n25="$n25 own-folder-missing"
  [ -z "$n25" ] \
    && ok "the seeder prunes papers a creation-time copy left behind" \
    || bad "the seeder prunes papers a creation-time copy left behind ($n25)"

  # 8) TWO fronts. Every fixture above registers exactly one, which makes the destination the last entry
  #    of the worktree listing — the one case a membership test written as a pipeline ending in a loop
  #    gets right. Two open fronts is this project's own stated parallelism, so the front that is NOT
  #    last is the case that matters.
  P25F="$T25/f"; mk25 "$P25F"
  $G25 -C "$P25F" worktree add -q -b you/t-900 "$T25/f-first"  >/dev/null 2>&1
  $G25 -C "$P25F" worktree add -q -b you/t-901 "$T25/f-second" >/dev/null 2>&1
  out25f="$( cd "$P25F" && "$SEED_ABS" "$T25/f-first" own 2>&1 )"; rcf=$?
  if [ "$rcf" = 0 ] && [ -f "$T25/f-first/.ai-flow/project.yml" ]; then
    ok "the seeder seeds a front that is not the last entry of the worktree listing"
  else
    bad "the seeder seeds a front that is not the last entry of the worktree listing (exit $rcf: ${out25f#seed-front: })"
  fi

  # 9) every refusal explains itself. Each is read from the DIAGNOSTIC, not from the exit status alone:
  #    a script that refused for the wrong reason exits 1 just as correctly as one that refused for the
  #    right one, and the operator acts on the sentence.
  r25s=""
  chk25() {  # $1 = expected fragment, $2.. = arguments
    local want="$1"; shift
    local out rc=0
    out="$( cd "$P25F" && "$SEED_ABS" "$@" 2>&1 )" || rc=$?
    [ "$rc" != 0 ] || { r25s="$r25s [$want:exit-0]"; return; }
    case "$out" in *"$want"*) ;; *) r25s="$r25s [$want:said(${out#seed-front: })]" ;; esac
  }
  chk25 "usage"
  chk25 "not a directory"                "$T25/absent-path"        own
  chk25 "not a checkout of any"          "$T25"                    own
  chk25 "already holds the project"      "$P25F"                   own
  chk25 "not a registered worktree"      "$P25F/.git"              own
  chk25 "not a usable task id"           "$T25/f-second"           "../escape"
  # The refusal this task added to the evaluator, in the roll-call that claims to cover every one of
  # them. A directory passes the readability guard above — it is readable and it has a size — and then
  # git cannot use it as an exclude file, which is the unanswerable probe the evaluator dies on.
  #
  # The two enumeration refusals are deliberately NOT here: reaching them needs a git that fails on one
  # subcommand while succeeding at the others, and the second is unreachable behind the first — the
  # tracked listing is a strict subset of the work the ignored listing already completed. The refusal over a front that is working the task it is seeded
  # for is not here either, for the opposite reason: it needs a fixture with two divergent copies of the
  # same papers, so it is read where that fixture is built, diagnostic and all, and this roll-call would
  # only restate it. An inventory that omits without saying so is what stops being an inventory.
  P25J="$T25/j"; mk25 "$P25J"
  rm -f "$P25J/.worktreeinclude"; mkdir -p "$P25J/.worktreeinclude"
  $G25 -C "$P25J" worktree add -q -b you/t-j "$T25/j-front" >/dev/null 2>&1
  out25j="$( cd "$P25J" && "$SEED_ABS" "$T25/j-front" own 2>&1 )"; rcj=$?
  [ "$rcj" != 0 ] || r25s="$r25s [could-not-be-evaluated:exit-0]"
  case "$out25j" in
    *"could not be evaluated"*) ;;
    *) r25s="$r25s [could-not-be-evaluated:said(${out25j#seed-front: })]" ;;
  esac
  [ -z "$r25s" ] \
    && ok "every refusal of the seeder names its own reason" \
    || bad "every refusal of the seeder names its own reason ($r25s)"

  # 10) THE COST. A fork per candidate put a monorepo's dependency directory in the critical path of
  #     every opening — ~16ms each, measured, with the prune sitting unreached behind it. What is
  #     asserted is the INVARIANT and not a duration: the pattern file is evaluated a number of times
  #     that does not GROW with the size of the primary. A wall-clock threshold would assert the same
  #     thing flakily, and on a fast enough machine would pass on the mechanism this replaced.
  #
  #     Counted by putting a git on PATH that logs its arguments and execs the real one. The counts are
  #     both reported on failure, because "24 and 44" is the diagnosis and "not constant" is not.
  REAL25="$(command -v git)"
  mkdir -p "$T25/bin"
  { printf '#!/bin/bash\n'
    printf 'printf "%%s\\n" "$*" >> "$GITLOG"\n'
    printf 'exec %s "$@"\n' "$REAL25"; } > "$T25/bin/git"
  chmod +x "$T25/bin/git"

  # $1 = how many extra ignored files the primary holds -> echoes the number of pattern evaluations,
  # or a non-numeric marker naming which premise failed. The premise is asserted rather than assumed
  # because equality alone is satisfied by ABSENCE just as well as by constancy: a seeder that dies
  # before it ever evaluates logs nothing at either fixture size, and "nothing == nothing" reads as a
  # cost that does not grow. Proven, not supposed — a mutation that made `evaluate` return without
  # calling git turned six other cases in this block red and left this one printing ok.
  forks25() {
    local n="$1" r="$T25/n$1" i=0 rc=0 c
    mk25 "$r"
    while [ "$i" -lt "$n" ]; do printf 'y\n' > "$r/.ai-flow/pad$i.tmp"; i=$((i+1)); done
    $G25 -C "$r" worktree add -q -b "you/t-n$1" "$T25/n$1-front" >/dev/null 2>&1
    GITLOG="$T25/log$1"; : > "$GITLOG"
    ( cd "$r" && GITLOG="$GITLOG" PATH="$T25/bin:$PATH" "$SEED_ABS" "$T25/n$1-front" own ) \
      >/dev/null 2>&1 || rc=$?
    [ "$rc" = 0 ] || { printf 'seeder-exited-%s' "$rc"; return; }
    [ -f "$T25/n$1-front/.ai-flow/project.yml" ] || { printf 'seeded-no-data'; return; }
    # `grep -c` prints 0 AND exits 1 when it counts nothing, so a `|| echo 0` fallback appends a SECOND
    # zero and the value becomes the two-line string "0\n0" — equal to itself at every fixture size.
    # That is exactly how this assertion was hollow; the count must be one value or none.
    c="$(grep -c 'check-ignore' "$GITLOG" 2>/dev/null || true)"
    printf '%s' "${c:-0}"
  }
  e25a="$(forks25 20)"
  e25b="$(forks25 60)"
  # Three distinct verdicts, because "not constant" and "never happened" are different diagnoses and an
  # operator acts on the sentence. Equality is the criterion itself — a count that does not grow with the
  # candidate list is what makes the opening's cost independent of the repository — but it only means
  # that once the count is known to be a real count.
  g25=""
  case "$e25a$e25b" in
    *[!0-9]*) g25=" premise-failed(20:$e25a, 60:$e25b)" ;;
    *) [ "$e25a" -ge 1 ] || g25=" never-evaluated"
       [ -n "$g25" ] || [ "$e25a" = "$e25b" ] || g25=" grew($e25a at 20 padding files, $e25b at 60)" ;;
  esac
  [ -z "$g25" ] \
    && ok "the seeder evaluates the pattern file a number of times that does not grow with the primary" \
    || bad "the seeder evaluates the pattern file a number of times that does not grow with the primary ($g25)"

  # 11) SELECTION IS UNCHANGED, on the pattern form the fixture above cannot reach. Every pattern in the
  #     shipped file is anchored, so a mechanism that only ever looked at leading path segments would
  #     pass all of it. An unanchored pattern matches at ANY depth, and it is the case a prefix-derived
  #     pre-filter gets wrong — asserted here so choosing that design has to break something.
  P25G="$T25/g"; mk25 "$P25G"
  printf 'local.env\n' >> "$P25G/.worktreeinclude"
  # OUTSIDE every directory the anchored patterns name, which is the whole point: an unanchored pattern
  # matches at any depth ANYWHERE, so a mechanism that enumerated only under the directories the patterns
  # name would never see this path. Placed under `.ai-flow/` instead, the assertion passes on exactly that
  # mechanism and guards nothing — which is what it did until a mutation was aimed at it.
  printf '/vendor/\n' >> "$P25G/.gitignore"
  mkdir -p "$P25G/vendor/deep/deeper"
  printf 'secret\n' > "$P25G/vendor/deep/deeper/local.env"
  printf 'not-me\n' > "$P25G/vendor/deep/deeper/other.txt"
  $G25 -C "$P25G" add .gitignore >/dev/null 2>&1
  $G25 -C "$P25G" commit -q -m "ignore vendor"
  $G25 -C "$P25G" worktree add -q -b you/t-g "$T25/g-front" >/dev/null 2>&1
  ( cd "$P25G" && "$SEED_ABS" "$T25/g-front" own ) >/dev/null 2>&1
  u25=""
  [ -f "$T25/g-front/vendor/deep/deeper/local.env" ] || u25="$u25 unanchored-match-missed"
  [ -e "$T25/g-front/vendor/deep/deeper/other.txt" ] && u25="$u25 unselected-path-copied"
  [ -z "$u25" ] \
    && ok "an unanchored pattern reaches the paths it matches at any depth" \
    || bad "an unanchored pattern reaches the paths it matches at any depth ($u25)"

  # 12) A pattern file that matches NOTHING is the documented precondition failing: the data directory
  #     is neither ignored nor tracked, so nothing is eligible and the front is born with no project
  #     data — while the run reports success. Three legs, because the refusal is only right if all three
  #     hold: it refuses, it names both causes the operator must choose between, and it refuses AFTER the
  #     prune, since a front-end may have filled the checkout at creation whatever the patterns select.
  P25H="$T25/h"; mk25 "$P25H"
  : > "$P25H/.gitignore"                       # the data directory is no longer ignored...
  $G25 -C "$P25H" rm -r -q --cached .ai-flow >/dev/null 2>&1   # ...and not tracked either
  # `add -A` would put it straight back: once the directory stops being ignored, "everything" includes
  # it, and the fixture would quietly become the COMMITTED layout — which is the case below, not this
  # one. Only the emptied ignore file is staged.
  $G25 -C "$P25H" add .gitignore >/dev/null 2>&1; $G25 -C "$P25H" commit -q -m untrack
  $G25 -C "$P25H" worktree add -q -b you/t-h "$T25/h-front" >/dev/null 2>&1
  mkdir -p "$T25/h-front/.ai-flow/artifacts/foreign-one"       # what a front-end left at creation
  printf 'a\n' > "$T25/h-front/.ai-flow/artifacts/foreign-one/state.md"
  out25h="$( cd "$P25H" && "$SEED_ABS" "$T25/h-front" own 2>&1 )"; rch=$?
  z25=""
  # The premise, asserted rather than assumed. A fixture that drifted into one of the other two layouts
  # would make this verdict a statement about a case nobody meant to test — which is how it drifted once
  # already, when staging "everything" put the directory back under version control.
  git -C "$P25H" check-ignore -q .ai-flow/project.yml 2>/dev/null && z25="$z25 fixture-still-ignored"
  git -C "$P25H" ls-files --error-unmatch .ai-flow/project.yml >/dev/null 2>&1 && z25="$z25 fixture-still-tracked"
  [ "$rch" != 0 ] || z25="$z25 exit-0"
  case "$out25h" in *gitignore*)  ;; *) z25="$z25 does-not-name-the-eligibility-cause" ;; esac
  case "$out25h" in *stale*)      ;; *) z25="$z25 does-not-name-the-stale-patterns-cause" ;; esac
  [ -e "$T25/h-front/.ai-flow/artifacts/foreign-one" ] && z25="$z25 refused-before-the-prune"
  [ -z "$z25" ] \
    && ok "a pattern file that matches nothing anywhere is a refusal that names both causes, taken after the prune" \
    || bad "a pattern file that matches nothing anywhere is a refusal that names both causes, taken after the prune ($z25)"

  # 13) THE OTHER empty selection, and the reason the refusal above needs two legs. A project that COMMITS
  #     its project data has nothing eligible by construction — git carried the whole directory in — so
  #     selecting nothing among the ignored paths is the correct answer there and the prune is the only
  #     work left. The documents describe this layout; a refusal keyed on the ignored paths alone breaks
  #     it, which is what this assertion exists to catch.
  P25I="$T25/i"; mk25 "$P25I"
  : > "$P25I/.gitignore"
  $G25 -C "$P25I" add -A >/dev/null 2>&1; $G25 -C "$P25I" commit -q -m "commit the data directory"
  $G25 -C "$P25I" worktree add -q -b you/t-i "$T25/i-front" >/dev/null 2>&1
  out25i="$( cd "$P25I" && "$SEED_ABS" "$T25/i-front" own 2>&1 )"; rci=$?
  c25i=""
  [ "$rci" = 0 ] || c25i="$c25i refused(${out25i#seed-front: })"
  # "having copied nothing" is the other half of the criterion, and it is the half that says WHY this
  # layout is not the broken one: git already carried the data, so there is nothing left to copy. A
  # verdict that only checked the data is present would also pass on a mechanism that copied it again.
  case "$out25i" in *"0 file(s) copied"*) ;; *) c25i="$c25i copied-something(${out25i#seed-front: })" ;; esac
  [ -f "$T25/i-front/.ai-flow/project.yml" ] || c25i="$c25i data-missing"
  [ -e "$T25/i-front/.ai-flow/artifacts/foreign-one" ] && c25i="$c25i foreign-one-kept"
  [ -z "$c25i" ] \
    && ok "a project that commits its project data still seeds successfully" \
    || bad "a project that commits its project data still seeds successfully ($c25i)"

  # 14) THE REPLACEMENT. The papers of the task the front is seeded for come from the primary, because
  #     the caller naming that task is the one thing that asserts authority over it — the mirror of the
  #     closing collection, where the checkout the task was WORKED in holds the authoritative copy and
  #     the record-keeper's is a snapshot nobody should have edited. Here the front has worked nothing
  #     yet, so the authority sits on the other side.
  #
  #     Two ages, because the incident produces both. A create-time snapshot carries the primary's OWN
  #     dates — measured against the native tooling, which preserves them exactly — so it TIES with its
  #     origin and never reads as older: a guard that replaced only what is strictly older would leave
  #     the stale sheet exactly where it is. The second paper is the ordinary repair, where the
  #     coordinator wrote after the checkout was created.
  P25K="$T25/k"; mk25 "$P25K"
  mkdir -p "$P25K/.ai-flow/artifacts/own"
  printf 'current sheet\n'         > "$P25K/.ai-flow/artifacts/own/state.md"
  printf 'current understanding\n' > "$P25K/.ai-flow/artifacts/own/understand.md"
  $G25 -C "$P25K" worktree add -q -b you/t-k "$T25/k-front" >/dev/null 2>&1
  mkdir -p "$T25/k-front/.ai-flow/artifacts/own"
  printf 'stale sheet\n' > "$T25/k-front/.ai-flow/artifacts/own/state.md"
  touch -r "$P25K/.ai-flow/artifacts/own/state.md" "$T25/k-front/.ai-flow/artifacts/own/state.md"
  printf 'stale understanding\n' > "$T25/k-front/.ai-flow/artifacts/own/understand.md"
  touch -t 202001010000 "$T25/k-front/.ai-flow/artifacts/own/understand.md"
  # A task whose name EXTENDS the seeded one, declared so the prune spares it. Its paper is older than
  # the coordinator's, so a folder match written without the separator would replace it — and the
  # keep-list's promise, which is the half of the contract this change does not touch, would be gone.
  mkdir -p "$P25K/.ai-flow/artifacts/own-two" "$T25/k-front/.ai-flow/artifacts/own-two"
  printf 'coordinator own-two\n' > "$P25K/.ai-flow/artifacts/own-two/state.md"
  printf 'front own-two\n'       > "$T25/k-front/.ai-flow/artifacts/own-two/state.md"
  touch -t 202001010000 "$T25/k-front/.ai-flow/artifacts/own-two/state.md"
  out25k="$( cd "$P25K" && "$SEED_ABS" "$T25/k-front" own own-two 2>&1 )"; rck=$?
  v25=""
  [ "$rck" = 0 ] || v25="$v25 refused(${out25k#seed-front: })"
  grep -q 'current sheet' "$T25/k-front/.ai-flow/artifacts/own/state.md" 2>/dev/null \
    || v25="$v25 tie-not-replaced"
  grep -q 'current understanding' "$T25/k-front/.ai-flow/artifacts/own/understand.md" 2>/dev/null \
    || v25="$v25 older-copy-not-replaced"
  grep -q 'front own-two' "$T25/k-front/.ai-flow/artifacts/own-two/state.md" 2>/dev/null \
    || v25="$v25 a-task-whose-name-extends-the-seeded-one-was-replaced"
  # The account the run gives of itself. Two papers of the seeded-for task are replaced here and nothing
  # else is, so the number is a fact about this fixture and not a restatement of the code: a mechanism
  # that counted a replacement as a copy, or counted both, says something else.
  case "$out25k" in *"2 paper(s) replaced"*) ;; *) v25="$v25 miscounted(${out25k#seed-front: })" ;; esac
  [ -z "$v25" ] \
    && ok "the seeder replaces the seeded-for task's papers from the primary" \
    || bad "the seeder replaces the seeded-for task's papers from the primary ($v25)"

  # 16) THE HAZARD. A re-run against a front that has been WORKING the task it is seeded for: there the
  #     front's copy is the authoritative one by the very logic that authorises the replacement, and
  #     replacing destroys the only account of work in progress. The evidence is which copy was written
  #     last — no paper is parsed, so it holds for every paper and not only for the sheet.
  #
  #     Four legs. The papers stay; BOTH of them stay, including the one that is older than the
  #     coordinator's, because a folder half from the coordinator and half from the front is a state no
  #     reader can reason about; the run refuses instead of reporting a success it did not achieve; and
  #     it refuses AFTER the prune, like the pattern-file refusal above and for the same reason — a
  #     front-end may have filled the checkout at creation, and stopping earlier leaves foreign papers
  #     behind on the way out.
  P25L="$T25/l"; mk25 "$P25L"
  mkdir -p "$P25L/.ai-flow/artifacts/own"
  printf 'coordinator snapshot\n'      > "$P25L/.ai-flow/artifacts/own/state.md"
  printf 'coordinator understanding\n' > "$P25L/.ai-flow/artifacts/own/understand.md"
  # Named so the primary's path is NOT a substring of the front's: at `$T25/l-front` the leg below that
  # reads the diagnostic for the primary matches the FRONT's path instead and can never fail — proven by
  # deleting the primary from the sentence and watching all four legs stay green.
  $G25 -C "$P25L" worktree add -q -b you/t-l "$T25/front-l" >/dev/null 2>&1
  mkdir -p "$T25/front-l/.ai-flow/artifacts/own" "$T25/front-l/.ai-flow/artifacts/foreign-one"
  printf 'x\n' > "$T25/front-l/.ai-flow/artifacts/foreign-one/state.md"   # left by a creation-time copy
  printf 'live work\n' > "$T25/front-l/.ai-flow/artifacts/own/state.md"
  touch -t 203001010000 "$T25/front-l/.ai-flow/artifacts/own/state.md"
  printf 'front understanding\n' > "$T25/front-l/.ai-flow/artifacts/own/understand.md"
  touch -t 202001010000 "$T25/front-l/.ai-flow/artifacts/own/understand.md"
  out25l="$( cd "$P25L" && "$SEED_ABS" "$T25/front-l" own 2>&1 )"; rcl=$?
  w25=""
  grep -q 'live work' "$T25/front-l/.ai-flow/artifacts/own/state.md" 2>/dev/null \
    || w25="$w25 live-paper-replaced"
  grep -q 'front understanding' "$T25/front-l/.ai-flow/artifacts/own/understand.md" 2>/dev/null \
    || w25="$w25 replaced-half-the-folder"
  [ "$rcl" != 0 ] || w25="$w25 exit-0"
  [ -e "$T25/front-l/.ai-flow/artifacts/foreign-one" ] && w25="$w25 refused-before-the-prune"
  # ...and the copy happened too. Only the prune is pinned above, so a refusal taken before the copy loop
  # rather than before the prune would leave the front with no project data at all and stay green — and
  # "completes everything non-destructive" is the whole of what this refusal costs.
  [ -f "$T25/front-l/.ai-flow/project.yml" ] || w25="$w25 refused-before-the-copy"
  [ -z "$w25" ] \
    && ok "the seeder leaves the papers of a task the front is working" \
    || bad "the seeder leaves the papers of a task the front is working ($w25)"

  # 17) The refusal is read from the DIAGNOSTIC, because the operator acts on the sentence and this one
  #     asks them to choose: it must name the task whose papers it would not touch, both checkouts —
  #     the two copies it could not choose between — and the act that forces the refresh, which is the
  #     only way past it.
  y25=""
  case "$out25l" in *own*)        ;; *) y25="$y25 does-not-name-the-task" ;; esac
  case "$out25l" in *"$T25/front-l"*) ;; *) y25="$y25 does-not-name-the-front" ;; esac
  case "$out25l" in *"$P25L"*)    ;; *) y25="$y25 does-not-name-the-primary" ;; esac
  case "$out25l" in *delete*|*remove*) ;; *) y25="$y25 does-not-name-the-way-past-it" ;; esac
  # The paper that diverged, by path. Without this leg the whole list can be dropped from the sentence and
  # every other leg stays green — `own` alone is already matched twice over by the opening clause and by
  # the path in the remedy. The second half is what makes it a real reading of the list: the paper that is
  # OLDER than the coordinator's is untouched but not diverged, and naming it would send the operator to
  # look at a file that agrees with theirs.
  case "$out25l" in *"artifacts/own/state.md"*) ;; *) y25="$y25 does-not-name-the-diverged-paper" ;; esac
  case "$out25l" in *"artifacts/own/understand.md"*) y25="$y25 names-an-undiverged-paper" ;; esac
  [ -z "$y25" ] \
    && ok "the seeder refuses rather than choose between two live copies, and its sentence says so" \
    || bad "the seeder refuses rather than choose between two live copies, and its sentence says so ($y25 said:${out25l#seed-front: })"

  # 18) THE AGE OF A COPY. The guard above decides on which copy was written last, so a copy that stamps
  #     itself with the present destroys the evidence it will be read by: the seeder's own work would
  #     make an untouched front look newer than the coordinator, and the NEXT run would refuse a front
  #     that had done nothing. Both halves are asserted — the stamp on an ordinary copy and on a
  #     replaced paper — and then the consequence itself: two runs in a row over an unworked front.
  P25M="$T25/m"; mk25 "$P25M"
  mkdir -p "$P25M/.ai-flow/artifacts/own"
  printf 'sheet\n' > "$P25M/.ai-flow/artifacts/own/state.md"
  touch -t 202001010000 "$P25M/.ai-flow/artifacts/own/state.md" "$P25M/.ai-flow/project.yml"
  $G25 -C "$P25M" worktree add -q -b you/t-m "$T25/m-front" >/dev/null 2>&1
  ( cd "$P25M" && "$SEED_ABS" "$T25/m-front" own ) >/dev/null 2>&1; rcm=$?
  out25m="$( cd "$P25M" && "$SEED_ABS" "$T25/m-front" own 2>&1 )"; rcm2=$?
  a25=""
  [ "$rcm" = 0 ] || a25="$a25 first-run-refused"
  # The premise, asserted rather than assumed, which is this block's own convention: `-nt` answers false for
  # a destination that does not exist, so both negative legs below are satisfied by a run that copied
  # nothing at all — and the folder itself is no evidence, since the prune creates it either way.
  [ -f "$T25/m-front/.ai-flow/project.yml" ] || a25="$a25 nothing-copied"
  [ -f "$T25/m-front/.ai-flow/artifacts/own/state.md" ] || a25="$a25 paper-never-arrived"
  [ "$T25/m-front/.ai-flow/project.yml" -nt "$P25M/.ai-flow/project.yml" ] \
    && a25="$a25 ordinary-copy-stamped-with-the-present"
  [ "$T25/m-front/.ai-flow/artifacts/own/state.md" -nt "$P25M/.ai-flow/artifacts/own/state.md" ] \
    && a25="$a25 replaced-paper-stamped-with-the-present"
  [ "$rcm2" = 0 ] || a25="$a25 second-run-refused(${out25m#seed-front: })"
  [ -z "$a25" ] \
    && ok "a copy carries the age of what it copied, so a second run is not mistaken for work" \
    || bad "a copy carries the age of what it copied, so a second run is not mistaken for work ($a25)"

  # 19) THE OTHER EVIDENCE. The age test can only ever be taken over papers the COORDINATOR ALSO HAS —
  #     the candidate list is the primary's — so a paper the front wrote and the coordinator never held
  #     reaches it never. It is the strongest evidence there is: a create-time copy is a subset of what
  #     the primary held, so a file here the primary lacks was written in this checkout (or deleted in
  #     the other), and both are reasons to keep hands off. The fixture is built so the age rule says
  #     REPLACE and only this rule can stop it: the front's sheet is an untouched snapshot and the
  #     coordinator's is newer, exactly the ordinary repair — with one paper of the front's own beside it.
  #     Without this the folder is left half coordinator and half front, and the run reports success.
  P25N="$T25/n"; mk25 "$P25N"
  mkdir -p "$P25N/.ai-flow/artifacts/own"
  printf 'coordinator sheet, rewritten later\n' > "$P25N/.ai-flow/artifacts/own/state.md"
  $G25 -C "$P25N" worktree add -q -b you/t-n2 "$T25/front-n" >/dev/null 2>&1
  mkdir -p "$T25/front-n/.ai-flow/artifacts/own"
  printf 'the snapshot sheet\n' > "$T25/front-n/.ai-flow/artifacts/own/state.md"
  touch -t 202001010000 "$T25/front-n/.ai-flow/artifacts/own/state.md"
  printf 'the front wrote this\n' > "$T25/front-n/.ai-flow/artifacts/own/plan.md"
  out25n="$( cd "$P25N" && "$SEED_ABS" "$T25/front-n" own 2>&1 )"; rcn=$?
  q25=""
  [ "$rcn" != 0 ] || q25="$q25 exit-0"
  grep -q 'the snapshot sheet' "$T25/front-n/.ai-flow/artifacts/own/state.md" 2>/dev/null \
    || q25="$q25 replaced-anyway"
  case "$out25n" in *"artifacts/own/plan.md"*) ;; *) q25="$q25 does-not-name-the-paper-it-found" ;; esac
  [ -z "$q25" ] \
    && ok "a paper the coordinator never wrote is evidence the front worked the task" \
    || bad "a paper the coordinator never wrote is evidence the front worked the task ($q25 said:${out25n#seed-front: })"

  # 20) The other half of the same fixture: what the primary does not have, this run cannot remove. It
  #     fails in the opposite direction from everything above — green from the start and it must stay
  #     green — and what it exists to catch is a replacement written as a MIRROR of the primary's folder,
  #     which would take the front's own work with it and satisfy every other leg here.
  grep -q 'the front wrote this' "$T25/front-n/.ai-flow/artifacts/own/plan.md" 2>/dev/null \
    && ok "the replacement never deletes a paper only the front holds" \
    || bad "the replacement never deletes a paper only the front holds"

  # 21) CONTAINMENT. Nothing this mechanism does may write outside the checkout it was given. Until the
  #     exception above there was no way it could — an existing destination path was skipped, never
  #     written — and `cp` onto a symlink writes into the LINK'S TARGET, which is as easily a path in
  #     another checkout as one in this one. The fixture is the replacement's ordinary case, with the
  #     destination paper replaced by a link pointing out of the front.
  P25O="$T25/o"; mk25 "$P25O"
  mkdir -p "$P25O/.ai-flow/artifacts/own"
  printf 'coordinator sheet\n' > "$P25O/.ai-flow/artifacts/own/state.md"
  $G25 -C "$P25O" worktree add -q -b you/t-o "$T25/front-o" >/dev/null 2>&1
  mkdir -p "$T25/front-o/.ai-flow/artifacts/own"
  printf 'a file outside both checkouts\n' > "$T25/outside.txt"
  touch -t 202001010000 "$T25/outside.txt"
  ln -s "$T25/outside.txt" "$T25/front-o/.ai-flow/artifacts/own/state.md"
  ( cd "$P25O" && "$SEED_ABS" "$T25/front-o" own ) >/dev/null 2>&1
  s25=""
  grep -q 'a file outside both checkouts' "$T25/outside.txt" 2>/dev/null || s25="$s25 wrote-outside-the-checkout"
  [ -L "$T25/front-o/.ai-flow/artifacts/own/state.md" ] && s25="$s25 link-still-in-place"
  grep -q 'coordinator sheet' "$T25/front-o/.ai-flow/artifacts/own/state.md" 2>/dev/null \
    || s25="$s25 paper-not-replaced"
  [ -z "$s25" ] \
    && ok "the replacement replaces the entry, it never writes through a link out of the checkout" \
    || bad "the replacement replaces the entry, it never writes through a link out of the checkout ($s25)"
  rm -rf "$T25"
fi

# --- the mechanism is distributed, and the drift guard can see it --------
# Executed, not grepped: the drift guard maps an engine path to its installed location by prefix and
# returns "" for anything it does not recognise — a silent skip. What proves the mapping exists is the
# guard REPORTING the installed copy missing, which it cannot do for a path it skips.
if ! T25D="$(mkbox)" || [ ! -d "$T25D" ]; then
  bad "the seeder is distributed by the installer and mapped by the drift guard (no sandbox: mktemp -d failed)"
else
  i25=""
  # Executed, because a bare grep of the installer is satisfied by the manifest variable alone: deleting
  # the copy loop leaves the name in the file and ships the mechanism uninstalled.
  IH25="$T25D/home-install"; IT25="$T25D/target"; mkdir -p "$IH25" "$IT25"
  ( cd "$T25D" && HOME="$IH25" bash "$ROOT/install.sh" update "$IT25" </dev/null >/dev/null 2>&1 ) || true
  [ -x "$IH25/.claude/ai-flow/scripts/seed-front.sh" ] || i25="$i25 installer-does-not-deliver-it"
  G25D="git -c user.email=t@t.t -c user.name=t -c commit.gpgsign=false"
  CL25="$T25D/clone"; mkdir -p "$CL25/global/scripts"
  $G25D init -q "$CL25"
  printf '#!/bin/bash\necho seeded\n' > "$CL25/global/scripts/seed-front.sh"
  $G25D -C "$CL25" add -A >/dev/null 2>&1
  $G25D -C "$CL25" commit -q -m engine
  mkdir -p "$T25D/home/.claude/ai-flow"
  printf '%s\n' "$CL25" > "$T25D/home/.claude/ai-flow/source.path"
  out25="$( cd "$T25D" && HOME="$T25D/home" bash "$ROOT/global/hooks/drift-check.sh" 2>&1 <<<'{}' )"
  case "$out25" in
    *"scripts/seed-front.sh"*) ;;
    *) i25="$i25 drift-guard-skips-the-prefix" ;;
  esac
  [ -z "$i25" ] \
    && ok "the seeder is distributed by the installer and mapped by the drift guard" \
    || bad "the seeder is distributed by the installer and mapped by the drift guard ($i25)"
  rm -rf "$T25D"
fi
