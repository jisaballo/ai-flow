#!/bin/bash
# Conformance harness for T-001 — layered project model (project.yml).
# Generated in the Conform phase from understand.md Verifiable Criteria.
# Dependency-free (grep-based) so it runs on any device; optional YAML lint if python3+pyyaml present.
# Exit 0 only when every section is green.

set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PASS=0
FAIL=0
ok()   { echo "  [ok]   $1"; PASS=$((PASS+1)); }
bad()  { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }

PY="template/.ai-flow/project.yml"

echo "== C1: template project.yml exists, valid, required keys =="
if [ -f "$PY" ]; then
  ok "project.yml exists"
  for k in name area_kind source_dirs commands steering; do
    grep -qE "^${k}:" "$PY" && ok "key '${k}' present" || bad "key '${k}' missing"
  done
  grep -qE "^[[:space:]]+test:" "$PY" && ok "commands.test present" || bad "commands.test missing"
  if command -v python3 >/dev/null 2>&1; then
    python3 -c "import yaml,sys; yaml.safe_load(open('$PY'))" 2>/dev/null \
      && ok "project.yml parses as YAML" || echo "  [skip] YAML lint (pyyaml unavailable or invalid — grep checks stand)"
  fi
else
  bad "project.yml missing ($PY)"
fi

echo "== C2: installer scaffolds project.yml on fresh install =="
grep -q "project.yml" install.sh && ok "install.sh references project.yml" || bad "install.sh does not scaffold project.yml"

echo "== C3: plan skill reads project.yml =="
grep -q "project.yml" global/skills/plan/SKILL.md && ok "plan/SKILL.md references project.yml" || bad "plan/SKILL.md missing project.yml"
grep -q "commands.test\|commands\.test\|commands:" global/skills/plan/SKILL.md && ok "plan/SKILL.md uses commands.test" || bad "plan/SKILL.md missing commands.test"

echo "== C4: verify skill reads project.yml =="
grep -q "project.yml" global/skills/verify/SKILL.md && ok "verify/SKILL.md references project.yml" || bad "verify/SKILL.md missing project.yml"
grep -q "source_dirs" global/skills/verify/SKILL.md && ok "verify/SKILL.md uses source_dirs" || bad "verify/SKILL.md missing source_dirs"

echo "== C5: skills state the absent-project.yml fallback =="
for s in plan verify understand; do
  grep -qiE "absent|fallback|if .*project.yml" "global/skills/$s/SKILL.md" \
    && ok "$s skill states fallback" || bad "$s skill missing fallback"
done

echo "== C7: docs describe the project layer =="
grep -rq "project.yml" docs/ && ok "docs mention project.yml" || bad "docs do not mention project.yml"

echo "== C8: discover capability (T-002) =="
test -f global/skills/discover/SKILL.md && ok "discover skill exists" || bad "global/skills/discover/SKILL.md missing"
test -f global/protocols/discover.md && ok "discover protocol exists" || bad "global/protocols/discover.md missing"
grep -qi "AskUserQuestion" global/protocols/discover.md 2>/dev/null && ok "discover protocol confirms uncertain fields" || bad "discover protocol missing AskUserQuestion flow"
grep -q "discover" install.sh && ok "install.sh wires discover" || bad "install.sh does not wire discover"
grep -qi "discover" global/CLAUDE.md && ok "global CLAUDE.md surfaces discover" || bad "global CLAUDE.md does not mention discover"
grep -rq "discover" docs/ && ok "docs mention discover" || bad "docs do not mention discover"

echo "== C10: drift-check capability =="
test -f global/hooks/drift-check.sh && ok "drift-check hook exists" || bad "drift-check hook missing"
grep -q "drift-check" global/hooks/settings.hooks.json && ok "drift-check wired in settings" || bad "drift-check not wired"
grep -q "source.path" install.sh && ok "install.sh records the clone path" || bad "install.sh does not record source.path"
grep -q "drift-check" global/hooks/README.md && ok "drift-check documented" || bad "drift-check not in hooks README"

echo "== C9: installer init/update + hooks auto-merge (T-003) =="
# --- structural ---
grep -qE '(init|update)\)' install.sh && ok "install.sh has init/update dispatch" || bad "no init/update dispatch"
grep -A3 '^PROTOCOLS=' install.sh | grep -q discover && ok "PROTOCOLS includes discover" || bad "PROTOCOLS missing discover"
grep -q "python3" install.sh && ok "install.sh uses python3 (hook merge)" || bad "no python3 hook merge"
# --- functional (sandboxed HOME + temp target; NEVER touches the real ~/.claude) ---
TH="$(mktemp -d)"; TT="$(mktemp -d)"; TW="$(mktemp -d)"
trap 'rm -rf "$TH" "$TT" "$TW"' EXIT
mkdir -p "$TT/.ai-flow/protocols"
echo "SENTINEL-KEEP-ME" > "$TT/.ai-flow/BACKLOG.md"
( cd "$TW" && HOME="$TH" bash "$ROOT/install.sh" update "$TT" </dev/null >/dev/null 2>&1 ) || true
grep -q "SENTINEL-KEEP-ME" "$TT/.ai-flow/BACKLOG.md" 2>/dev/null && ok "update preserves project data" || bad "update clobbered/missed project data"
test -f "$TH/.claude/ai-flow/protocols/discover.md" && ok "update delivers discover.md centrally" || bad "update did not deliver discover.md centrally"
( cd "$TW" && HOME="$TH" bash "$ROOT/install.sh" update "$TT" </dev/null >/dev/null 2>&1 ) || true
SJ="$TH/.claude/settings.json"
if [ -f "$SJ" ] && command -v python3 >/dev/null 2>&1; then
  python3 -c "import json; json.load(open('$SJ'))" 2>/dev/null && ok "settings.json is valid JSON" || bad "settings.json invalid JSON"
  cnt="$(grep -c "git-safety.py" "$SJ" 2>/dev/null || echo 0)"
  [ "$cnt" = "1" ] && ok "hook merge idempotent (1 git-safety entry)" || bad "hook merge not idempotent ($cnt git-safety entries)"
else
  bad "update did not create settings.json (expected hook auto-merge)"
fi
trap - EXIT
rm -rf "$TH" "$TT" "$TW"

echo "== C11: worktree-aware hooks =="
HK="$ROOT/global/hooks"
T11="$(mktemp -d)"
trap 'rm -rf "$T11"' EXIT
GIT="git -c user.email=t@t.t -c user.name=t -c commit.gpgsign=false"
PY3=1
command -v python3 >/dev/null 2>&1 || PY3=0

mkproj() {  # $1 = dir, $2 = initial branch name -> repo with one commit
  mkdir -p "$1"
  $GIT init -q "$1"
  $GIT -C "$1" symbolic-ref HEAD "refs/heads/$2"
  printf 'x\n' > "$1/app.txt"
  $GIT -C "$1" add -A >/dev/null 2>&1
  $GIT -C "$1" commit -q -m init
}
nlines() { seq 1 "$1" | sed 's/^/line /'; }
wguard() {  # $1 = cwd, $2 = file_path -> prints output, returns hook exit code
  printf '{"cwd":"%s","tool_input":{"file_path":"%s"}}' "$1" "$2" | python3 "$HK/understand-write-guard.py" 2>&1
}

# --- the read-only rail ---------------------------------------------------
if [ "$PY3" = 1 ]; then
  P1="$T11/p1"; mkproj "$P1" main
  W1="$T11/w1"; $GIT -C "$P1" worktree add -q -b wt1 "$W1" >/dev/null 2>&1
  mkdir -p "$W1/.ai-flow/artifacts/sample-task"
  printf '# Task state\n\nphase: **UNDERSTAND**\n' > "$W1/.ai-flow/artifacts/sample-task/state.md"

  out="$(wguard "$W1" "$W1/app.txt")"; rc=$?
  [ "$rc" = 2 ] && ok "write rail blocks code writes while the phase is UNDERSTAND" \
                || bad "write rail blocks code writes while the phase is UNDERSTAND (exit $rc)"
  case "$out" in
    *"artifacts/sample-task/state.md"*) ok "block message names the state file it read" ;;
    *) bad "block message names the state file it read" ;;
  esac
  out="$(wguard "$W1" "$W1/.ai-flow/artifacts/sample-task/notes.md")"; rc=$?
  [ "$rc" = 0 ] && ok "write rail still allows ledger writes" \
                || bad "write rail still allows ledger writes (exit $rc)"

  P2="$T11/p2"; mkproj "$P2" main
  mkdir -p "$P2/.ai-flow/artifacts/sample-task"
  printf 'Current phase: **EXECUTE**\n' > "$P2/.ai-flow/STATE.md"
  printf 'phase: **UNDERSTAND**\n'      > "$P2/.ai-flow/artifacts/sample-task/state.md"
  out="$(wguard "$P2" "$P2/app.txt")"; rc=$?
  [ "$rc" = 2 ] && ok "per-task state wins over the ledger phase" \
                || bad "per-task state wins over the ledger phase (exit $rc)"

  P3="$T11/p3"; mkproj "$P3" main
  mkdir -p "$P3/.ai-flow"
  printf 'Current phase: **UNDERSTAND**\n' > "$P3/.ai-flow/STATE.md"
  out="$(wguard "$P3" "$P3/app.txt")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *".ai-flow/STATE.md"*) ok "falls back to the ledger STATE when no per-task state exists" ;;
      *) bad "falls back to the ledger STATE when no per-task state exists (blocked, but does not name the ledger)" ;;
    esac
  else
    bad "falls back to the ledger STATE when no per-task state exists (exit $rc)"
  fi
else
  echo "  [skip] read-only rail checks (python3 unavailable)"
fi

# --- the diff brake ------------------------------------------------------
brake() { ( cd "$1" && printf '{}' | python3 "$HK/diff-size-guard.py" 2>&1 ); }

if [ "$PY3" = 1 ]; then
  P5="$T11/p5"; mkproj "$P5" main
  mkdir -p "$P5/.ai-flow"; printf 'Current phase: **EXECUTE**\n' > "$P5/.ai-flow/STATE.md"
  nlines 200 > "$P5/big.txt"
  out="$(brake "$P5")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *"step ceiling"*) ok "step ceiling fires on a large uncommitted change" ;;
      *) bad "step ceiling fires on a large uncommitted change (fires, but does not name the step ceiling)" ;;
    esac
  else
    bad "step ceiling fires on a large uncommitted change (exit $rc)"
  fi

  P6="$T11/p6"; mkproj "$P6" main
  mkdir -p "$P6/.ai-flow"; printf 'Current phase: **EXECUTE**\n' > "$P6/.ai-flow/STATE.md"
  $GIT -C "$P6" checkout -q -b feat
  nlines 500 > "$P6/feature.txt"
  $GIT -C "$P6" add app.txt feature.txt >/dev/null 2>&1
  $GIT -C "$P6" commit -q -m feature
  out="$(brake "$P6")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *"task ceiling"*) ok "task ceiling fires on a large committed branch" ;;
      *) bad "task ceiling fires on a large committed branch (fires, but does not name the task ceiling)" ;;
    esac
  else
    bad "task ceiling fires on a large committed branch (exit $rc)"
  fi

  P7="$T11/p7"; mkproj "$P7" main
  mkdir -p "$P7/.ai-flow"; printf 'Current phase: **EXECUTE**\n' > "$P7/.ai-flow/STATE.md"
  $GIT -C "$P7" checkout -q -b feat
  nlines 500 > "$P7/FooTest.kt"
  $GIT -C "$P7" add FooTest.kt >/dev/null 2>&1
  $GIT -C "$P7" commit -q -m tests
  nlines 200 > "$P7/bar_test.go"
  out="$(brake "$P7")"; rc=$?
  [ "$rc" = 0 ] && ok "non-JS test suites are excluded from both counts" \
                || bad "non-JS test suites are excluded from both counts (exit $rc)"

  P8="$T11/p8"; mkproj "$P8" wip
  mkdir -p "$P8/.ai-flow"; printf 'Current phase: **EXECUTE**\n' > "$P8/.ai-flow/STATE.md"
  nlines 500 > "$P8/orphan.txt"
  $GIT -C "$P8" add orphan.txt >/dev/null 2>&1
  $GIT -C "$P8" commit -q -m orphan
  out="$(brake "$P8")"; rc=$?
  [ "$rc" = 0 ] && ok "no base ref leaves the task ceiling out of play" \
                || bad "no base ref leaves the task ceiling out of play (exit $rc)"
  nlines 200 > "$P8/wip.txt"
  out="$(brake "$P8")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *"step ceiling"*) ok "no base ref leaves the step ceiling alone" ;;
      *) bad "no base ref leaves the step ceiling alone (fires, but does not name the step ceiling)" ;;
    esac
  else
    bad "no base ref leaves the step ceiling alone (exit $rc)"
  fi
else
  echo "  [skip] diff brake checks (python3 unavailable)"
fi

# --- the ledger guardian ------------------------------------------------
P9="$T11/p9"; mkproj "$P9" main
mkdir -p "$P9/.ai-flow"
printf 'a closed task shipped + archived\n' > "$P9/.ai-flow/STATE.md"
printf '# Backlog\n'                > "$P9/.ai-flow/BACKLOG.md"
W9="$T11/w9"; $GIT -C "$P9" worktree add -q -b wt9 "$W9" >/dev/null 2>&1
cp -R "$P9/.ai-flow" "$W9/.ai-flow"   # models what .worktreeinclude will copy
( cd "$W9" && bash "$HK/check-state-size.sh" >/dev/null 2>&1 ); rc=$?
[ "$rc" = 0 ] && ok "ledger guardian is silent in a linked worktree" \
              || bad "ledger guardian is silent in a linked worktree (exit $rc)"
( cd "$P9" && bash "$HK/check-state-size.sh" >/dev/null 2>&1 ); rc=$?
[ "$rc" = 2 ] && ok "guardian still blocks in the main copy" \
              || bad "guardian still blocks in the main copy (exit $rc)"

# --- a project with no git at all ---------------------------------------
NG="$T11/nogit"; mkdir -p "$NG/.ai-flow"
printf 'Current phase: **UNDERSTAND**\n' > "$NG/.ai-flow/STATE.md"
printf '# Backlog\n' > "$NG/.ai-flow/BACKLOG.md"
printf 'x\n' > "$NG/app.txt"
if [ "$PY3" = 1 ]; then
  out="$(wguard "$NG" "$NG/app.txt")"; rc=$?
  [ "$rc" = 2 ] && ok "write rail still applies with no git repository" \
                || bad "write rail still applies with no git repository (exit $rc)"
  out="$(brake "$NG")"; rc=$?
  [ "$rc" = 0 ] && ok "diff brake stays out of the way with no git repository" \
                || bad "diff brake stays out of the way with no git repository (exit $rc)"
fi
printf 'a closed task shipped + archived\n' > "$NG/.ai-flow/STATE.md"
( cd "$NG" && bash "$HK/check-state-size.sh" >/dev/null 2>&1 ); rc=$?
[ "$rc" = 2 ] && ok "ledger guardian still applies with no git repository" \
              || bad "ledger guardian still applies with no git repository (exit $rc)"

# --- the engine drift guard ---------------------------------------------
E11="$T11/engine"; mkproj "$E11" main
mkdir -p "$E11/global/hooks"; printf 'v1\n' > "$E11/global/hooks/x.sh"
$GIT -C "$E11" add global >/dev/null 2>&1; $GIT -C "$E11" commit -q -m engine
WE="$T11/engine-wt"; $GIT -C "$E11" worktree add -q -b eng "$WE" >/dev/null 2>&1
printf 'v2\n' > "$WE/global/hooks/x.sh"
$GIT -C "$WE" add global >/dev/null 2>&1; $GIT -C "$WE" commit -q -m engine-v2
TH11="$T11/home"; mkdir -p "$TH11/.claude/ai-flow" "$TH11/.claude/hooks"
printf '%s\n' "$E11" > "$TH11/.claude/ai-flow/source.path"
printf 'v2\n' > "$TH11/.claude/hooks/x.sh"   # installed matches the worktree's HEAD
( cd "$WE" && HOME="$TH11" bash "$HK/drift-check.sh" >/dev/null 2>&1 ); rc=$?
[ "$rc" = 0 ] && ok "drift guard compares against the working copy's HEAD" \
              || bad "drift guard compares against the working copy's HEAD (exit $rc)"
printf 'v3\n' > "$WE/global/hooks/x.sh"      # uncommitted engine change in the worktree
printf 'v9\n' > "$TH11/.claude/hooks/x.sh"   # installed matches nothing
( cd "$WE" && HOME="$TH11" bash "$HK/drift-check.sh" >/dev/null 2>&1 ); rc=$?
[ "$rc" = 0 ] && ok "drift guard is quiet on the working copy's WIP" \
              || bad "drift guard is quiet on the working copy's WIP (exit $rc)"

# --- gaps closed after the multi-agent review --------------------------------
# the guardian must survive a subdirectory cwd (git answers --git-dir absolute, --git-common-dir relative)
P10="$T11/p10"; mkproj "$P10" main
mkdir -p "$P10/.ai-flow" "$P10/sub"
printf 'a closed task shipped + archived\n' > "$P10/.ai-flow/STATE.md"
( cd "$P10/sub" && bash "$HK/check-state-size.sh" >/dev/null 2>&1 ); rc=$?
[ "$rc" = 2 ] && ok "guardian still blocks from a subdirectory of the main copy" \
              || bad "guardian still blocks from a subdirectory of the main copy (exit $rc)"
W10="$T11/w10"; $GIT -C "$P10" worktree add -q -b wt10 "$W10" >/dev/null 2>&1
cp -R "$P10/.ai-flow" "$W10/.ai-flow"; mkdir -p "$W10/sub"
( cd "$W10/sub" && bash "$HK/check-state-size.sh" >/dev/null 2>&1 ); rc=$?
[ "$rc" = 0 ] && ok "guardian stays silent from a subdirectory of a linked worktree" \
              || bad "guardian stays silent from a subdirectory of a linked worktree (exit $rc)"

if [ "$PY3" = 1 ]; then
  # a worktree nested inside its own primary must not be judged by the primary's ledger
  P11="$T11/p11"; mkproj "$P11" main
  mkdir -p "$P11/.ai-flow"
  printf 'Current phase: **UNDERSTAND**\n' > "$P11/.ai-flow/STATE.md"
  NEST="$P11/.claude/worktrees/w1"
  $GIT -C "$P11" worktree add -q -b nested "$NEST" >/dev/null 2>&1
  out="$(wguard "$NEST" "$NEST/app.txt")"; rc=$?
  [ "$rc" = 0 ] && ok "a nested worktree is not bound to the enclosing ledger" \
                || bad "a nested worktree is not bound to the enclosing ledger (exit $rc)"

  # several per-task states, or one that is not UNDERSTAND, hand the question back
  P12="$T11/p12"; mkproj "$P12" main
  mkdir -p "$P12/.ai-flow/artifacts/one" "$P12/.ai-flow/artifacts/two"
  printf 'Current phase: **EXECUTE**\n'  > "$P12/.ai-flow/STATE.md"
  printf 'phase: **UNDERSTAND**\n'       > "$P12/.ai-flow/artifacts/one/state.md"
  printf 'phase: **EXECUTE**\n'          > "$P12/.ai-flow/artifacts/two/state.md"
  out="$(wguard "$P12" "$P12/app.txt")"; rc=$?
  [ "$rc" = 0 ] && ok "several per-task states defer to the ledger phase" \
                || bad "several per-task states defer to the ledger phase (exit $rc)"
  P13="$T11/p13"; mkproj "$P13" main
  mkdir -p "$P13/.ai-flow/artifacts/one"
  printf 'Current phase: **UNDERSTAND**\n' > "$P13/.ai-flow/STATE.md"
  printf 'phase: **EXECUTE**\n'            > "$P13/.ai-flow/artifacts/one/state.md"
  out="$(wguard "$P13" "$P13/app.txt")"; rc=$?
  [ "$rc" = 0 ] && ok "a per-task state past UNDERSTAND lifts the rail" \
                || bad "a per-task state past UNDERSTAND lifts the rail (exit $rc)"

  # production files that merely end in "test" are not test files
  P14="$T11/p14"; mkproj "$P14" main
  mkdir -p "$P14/.ai-flow"; printf 'Current phase: **EXECUTE**\n' > "$P14/.ai-flow/STATE.md"
  nlines 200 > "$P14/Latest.cs"
  out="$(brake "$P14")"; rc=$?
  [ "$rc" = 2 ] && ok "a production file ending in test still counts" \
                || bad "a production file ending in test still counts (exit $rc)"

  # the task ceiling speaks once, not every turn
  out="$(brake "$P6")"; rc=$?
  [ "$rc" = 0 ] && ok "the task ceiling stays quiet once acknowledged" \
                || bad "the task ceiling stays quiet once acknowledged (exit $rc)"

  # the base ref that real projects use: the remote's default branch
  P15="$T11/p15"; mkproj "$P15" main
  mkdir -p "$P15/.ai-flow"; printf 'Current phase: **EXECUTE**\n' > "$P15/.ai-flow/STATE.md"
  base_sha="$($GIT -C "$P15" rev-parse HEAD)"
  $GIT -C "$P15" update-ref refs/remotes/origin/main "$base_sha"
  $GIT -C "$P15" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main
  $GIT -C "$P15" checkout -q -b feat
  nlines 500 > "$P15/feature.txt"
  $GIT -C "$P15" add feature.txt >/dev/null 2>&1; $GIT -C "$P15" commit -q -m feature
  out="$(brake "$P15")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *"origin/main"*) ok "the task ceiling measures against the remote default branch" ;;
      *) bad "the task ceiling measures against the remote default branch (fired against something else)" ;;
    esac
  else
    bad "the task ceiling measures against the remote default branch (exit $rc)"
  fi

  # a dangling origin/HEAD must fall back, not switch the ceiling off
  P16="$T11/p16"; mkproj "$P16" main
  mkdir -p "$P16/.ai-flow"; printf 'Current phase: **EXECUTE**\n' > "$P16/.ai-flow/STATE.md"
  $GIT -C "$P16" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/gone
  $GIT -C "$P16" checkout -q -b feat
  nlines 500 > "$P16/feature.txt"
  $GIT -C "$P16" add feature.txt >/dev/null 2>&1; $GIT -C "$P16" commit -q -m feature
  out="$(brake "$P16")"; rc=$?
  [ "$rc" = 2 ] && ok "a dangling remote default falls back instead of disabling the ceiling" \
                || bad "a dangling remote default falls back instead of disabling the ceiling (exit $rc)"
fi

# real drift is still reported: the installed engine matches no checkout
$GIT -C "$WE" add global >/dev/null 2>&1; $GIT -C "$WE" commit -q -m engine-v3
printf 'v9\n' > "$TH11/.claude/hooks/x.sh"
( cd "$WE" && HOME="$TH11" bash "$HK/drift-check.sh" >/dev/null 2>&1 ); rc=$?
[ "$rc" = 2 ] && ok "drift guard still reports an engine that matches no checkout" \
              || bad "drift guard still reports an engine that matches no checkout (exit $rc)"

rm -rf "$T11"
trap - EXIT

echo "== C12: worktree provisioning — data in, ledger out =="
# The semantic checks below read the TEMPLATE copy: that is the file install.sh delivers, so it is
# the one whose select/reject contract matters to an adopting project. The root copy exists only so
# this repo dogfoods its own mechanism, and the parity check keeps the two from drifting apart.
WTI="$ROOT/template/.worktreeinclude"
T12="$(mktemp -d)"
trap 'rm -rf "$T12"' EXIT
if [ -f "$WTI" ]; then
  # git stands in for the pattern engine the product uses: same gitignore specification,
  # no package dependency in a harness that is otherwise pure shell and git.
  # The scratch repo must carry NO .gitignore of its own. core.excludesFile is ADDITIVE, so
  # evaluating inside a checkout that already ignores .ai-flow/ reports every path under it as
  # ignored no matter what the pattern file says — the file becomes untestable. Isolation is the check.
  EV="$T12/eval"; mkdir -p "$EV"; ( cd "$EV" && $GIT init -q . >/dev/null 2>&1 )
  selects() { ( cd "$EV" && $GIT -c core.excludesFile="$WTI" check-ignore -q --no-index "$1" ); }

  miss=0
  for f in .ai-flow/project.yml .ai-flow/product.md .ai-flow/steering/payments.md \
           .ai-flow/codebase/CONCERNS.md .ai-flow/artifacts/current-task/plan.md; do
    selects "$f" || { miss=$((miss+1)); echo "         not selected: $f"; }
  done
  [ "$miss" = 0 ] && ok "worktreeinclude selects the project data" \
                  || bad "worktreeinclude selects the project data ($miss of 5 missing)"

  leak=0
  for f in .ai-flow/BACKLOG.md .ai-flow/STATE.md .ai-flow/decisions-global.md \
           .ai-flow/archive/CHANGELOG.md; do
    selects "$f" && { leak=$((leak+1)); echo "         ledger would travel: $f"; }
  done
  [ "$leak" = 0 ] && ok "worktreeinclude leaves the ledger behind" \
                  || bad "worktreeinclude leaves the ledger behind ($leak ledger paths selected)"

  # A pattern that names something git already tracks is inert: the product only ever
  # considers untracked-and-ignored paths as candidates to copy.
  inert=0
  while IFS= read -r pat; do
    case "$pat" in ''|'#'*) continue ;; esac
    if [ -n "$( cd "$ROOT" && $GIT ls-files -- "$pat" 2>/dev/null )" ]; then
      inert=$((inert+1)); echo "         names tracked files: $pat"
    fi
  done < "$WTI"
  [ "$inert" = 0 ] && ok "worktreeinclude names only ignored paths" \
                   || bad "worktreeinclude names only ignored paths ($inert inert patterns)"
else
  bad "worktreeinclude selects the project data (.worktreeinclude missing)"
  bad "worktreeinclude leaves the ledger behind (.worktreeinclude missing)"
  bad "worktreeinclude names only ignored paths (.worktreeinclude missing)"
fi

# The dogfooding root copies and the shipped template copies must not drift: the checks above prove
# the template's semantics, and these prove the root file the tool reads here says the same thing.
if cmp -s "$ROOT/.worktreeinclude" "$ROOT/template/.worktreeinclude"; then
  ok "root and template pattern files stay identical"
else
  bad "root and template pattern files stay identical (they have drifted)"
fi

# The sealed decision is the VALUE 'fresh', not merely the presence of a key: 'head' is the opposite
# choice this task deliberated and rejected, and it must not pass silently.
freshref() {  # $1 = settings.json path -> 0 when worktree.baseRef is exactly "fresh"
  [ -f "$1" ] || return 1
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); sys.exit(0 if d.get("worktree",{}).get("baseRef")=="fresh" else 1)' "$1"
  else
    grep -qE '"baseRef"[[:space:]]*:[[:space:]]*"fresh"' "$1"
  fi
}
if freshref "$ROOT/.claude/settings.json" && freshref "$ROOT/template/.claude/settings.json"; then
  ok "the recorded base ref is 'fresh' in both the root and the template settings"
else
  bad "the recorded base ref is 'fresh' in both the root and the template settings"
fi

# --- delivery to an adopting project (sandboxed HOME; never touches the real ~/.claude) ---
H12="$T12/home"; mkdir -p "$H12"
# The prompts must be ANSWERED, not closed: install.sh runs under `set -e`, and `read` at EOF returns
# non-zero, which aborts init at the first prompt. Feeding 'n' twice declines the two optional global
# steps and lets the project-file installers run to completion, so the exit status is meaningful.
# Output goes to a file rather than stdout on purpose: called inside a command substitution the
# function would run in a subshell and its exit status would never reach the caller.
runinit() {  # $1 = target dir -> output in $T12/init.out, exit status in RC
  ( cd "$T12" && printf 'n\nn\n' | HOME="$H12" bash "$ROOT/install.sh" init "$1" ) > "$T12/init.out" 2>&1
  RC=$?
}
treecksum() {  # $1 = dir -> one line per file: path + checksum, stable order
  ( cd "$1" && find . -type f | LC_ALL=C sort | while IFS= read -r f; do
      printf '%s %s\n' "$f" "$( cksum < "$f" )"; done )
}

# an existing pattern file is the project's own decision — the installer states its intent and stops
A12="$T12/adopt-existing"; mkdir -p "$A12/.ai-flow" "$A12/.claude"
printf 'SENTINEL-PATTERNS\n' > "$A12/.worktreeinclude"
printf 'SENTINEL-SETTINGS\n' > "$A12/.claude/settings.json"
printf '# Backlog\n' > "$A12/.ai-flow/BACKLOG.md"
before_w="$( cksum < "$A12/.worktreeinclude" )"; before_s="$( cksum < "$A12/.claude/settings.json" )"
runinit "$A12"; out12="$( cat "$T12/init.out" )"
after_w="$( cksum < "$A12/.worktreeinclude" )"; after_s="$( cksum < "$A12/.claude/settings.json" )"
if [ "$before_w" = "$after_w" ] && printf '%s' "$out12" | grep -q "skip] .worktreeinclude"; then
  ok "install never clobbers an existing worktreeinclude"
else
  bad "install never clobbers an existing worktreeinclude (content or skip notice missing)"
fi
if [ "$before_s" = "$after_s" ] && printf '%s' "$out12" | grep -q "action].*baseRef"; then
  ok "install never clobbers existing project settings"
else
  bad "install never clobbers existing project settings (content changed or the key was not named)"
fi

rc_existing="$RC"

# a project with neither file receives both
B12="$T12/adopt-fresh"; mkdir -p "$B12"
runinit "$B12"
rc_fresh="$RC"
[ "$rc_existing" = 0 ] && [ "$rc_fresh" = 0 ] \
  && ok "install runs to completion on both a fresh and an already-adopted project" \
  || bad "install runs to completion on both a fresh and an already-adopted project (exit $rc_existing / $rc_fresh)"
SB="$B12/.claude/settings.json"
if [ -f "$B12/.worktreeinclude" ] && [ -f "$SB" ] \
   && grep -q "baseRef" "$SB" \
   && freshref "$SB"; then
  ok "install creates project settings with the base ref"
else
  bad "install creates project settings with the base ref"
fi

# the standing promise of the update command: it delivers the engine centrally and writes into no project
C12="$T12/untouched"; mkdir -p "$C12/.ai-flow"
printf '# Backlog\n' > "$C12/.ai-flow/BACKLOG.md"
printf 'x\n' > "$C12/app.txt"
printf 'own patterns\n' > "$C12/.worktreeinclude"
before_tree="$( treecksum "$C12" )"
( cd "$T12" && HOME="$H12" bash "$ROOT/install.sh" update "$C12" </dev/null >/dev/null 2>&1 ) || true
after_tree="$( treecksum "$C12" )"
[ "$before_tree" = "$after_tree" ] && ok "update still touches no project" \
                                  || bad "update still touches no project (the project tree changed)"

echo "== C13: per-task state sheet + workstream roster =="
T13="$(mktemp -d)"
trap 'rm -rf "$T12" "$T13"' EXIT
TSTATE="template/.ai-flow/STATE.md"
BLG="global/protocols/backlog.md"

# --- the two shapes, written down ----------------------------------------
if grep -q '^## Workstreams' "$TSTATE" \
   && grep -qiE '^\|[^|]*workstream[^|]*\|[^|]*checkout[^|]*\|[^|]*branch[^|]*\|[^|]*task[^|]*\|' "$TSTATE" \
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
  printf '%s' "$sec" | grep -qi 'paused' \
    && ok "the protocol states a paused task keeps its sheet" \
    || bad "the protocol states a paused task keeps its sheet"
  printf '%s' "$sec" | grep -qi 'quick' \
    && ok "the protocol states a quick task gets no sheet" \
    || bad "the protocol states a quick task gets no sheet"
else
  bad "the protocol has a State Files section"
  bad "the protocol defines both state files and their writers (no section)"
  bad "the protocol mandates the sheet at activation (no section)"
  bad "the protocol states a paused task keeps its sheet (no section)"
  bad "the protocol states a quick task gets no sheet (no section)"
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
if grep -q 'artifacts/T-XXX/state.md' global/CLAUDE.md; then
  if [ -f "$twin" ]; then
    grep -q 'artifacts/T-XXX/state.md' "$twin" \
      && ok "both manual twins send step progress to the task sheet" \
      || bad "both manual twins send step progress to the task sheet (the live twin is stale)"
  else
    echo "  [skip] live CLAUDE.md twin absent — the shipped one names the task sheet"
    ok "the shipped manual sends step progress to the task sheet"
  fi
else
  bad "both manual twins send step progress to the task sheet"
fi

# --- the rail resolves its own task by branch ----------------------------
if [ "$PY3" = 1 ]; then
  ledger() {  # $1 = repo, $2 = phase -> the ledger STATE.md of a project that has not migrated
    mkdir -p "$1/.ai-flow"
    printf 'Current phase: **%s**\n' "$2" > "$1/.ai-flow/STATE.md"
  }
  sheet() {  # $1 = repo, $2 = task dir, $3 = branch line or "-", $4 = phase
    mkdir -p "$1/.ai-flow/artifacts/$2"
    { printf '# Task state\n\n'
      [ "$3" = "-" ] || printf 'branch: %s\n' "$3"
      printf 'phase: **%s**\n' "$4"
    } > "$1/.ai-flow/artifacts/$2/state.md"
  }

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
# One numbered step, flattened to a single line. What a step must SAY is a property of the step,
# not of where its prose happens to wrap: matching per physical line made re-wrapping unchanged
# text load-bearing, and scoped a fact to the whole section when it belongs to one move.
cerstep() { printf '%s\n' "$CER" | awk -v s="^$1\\\\. " -v e="^$(($1 + 1))\\\\. " '$0 ~ e {f=0} $0 ~ s {f=1} f' | tr '\n' ' '; }
pair() { # step, pattern A, pattern B, label
  printf '%s' "$(cerstep "$1")" | grep -qiE "$2" && printf '%s' "$(cerstep "$1")" | grep -qiE "$3" \
    && ok "$4" || bad "$4"
}

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
  pair 5 'never' 'git worktree add' "the ceremony creates the worktree with the native tooling"
  pair 6 'prune' 'own|owns' "the ceremony prunes the new checkout to the task it owns"
  pair 6 'BACKLOG|ledger' 'never copied|not copied|stays with|read-only' "the ceremony never copies the ledger into a worktree"
  pair 6 'copies' 'originals' "the pruning step names what it deletes"
else
  bad "the protocol defines the ceremony that opens a workstream"
  bad "a single open front has nothing to weigh and nothing to create (no section)"
  bad "a collision stops the opening until it is acknowledged in the sheet (no section)"
  bad "a front with no declaration reads as cannot-compare, not as clear (no section)"
  bad "opening stops on an unpublished default branch (no section)"
  bad "the ceremony creates the worktree with the native tooling (no section)"
  bad "the ceremony prunes the new checkout to the task it owns (no section)"
  bad "the ceremony never copies the ledger into a worktree (no section)"
  bad "the pruning step names what it deletes (no section)"
fi

# the ceremony lands beside the checklists it mirrors: the engine grows no protocol file.
# Named set, not a count: a failure has to say which file appeared.
EXPECTED_PROTOS="backlog.md codebase-mapping.md discover.md execute.md plan.md quick-path.md understand.md verify.md"
extra=""
for f in $(ls global/protocols); do
  case " $EXPECTED_PROTOS " in *" $f "*) ;; *) extra="$extra $f" ;; esac
done
[ -z "$extra" ] && ok "the engine gains no new protocol file" \
                || bad "the engine gains no new protocol file (unexpected:$extra)"

# the column the check reads, in the shipped roster and in the protocol's own skeleton.
# The migration region is bounded at the next heading: unbounded, it ran to EOF and read the
# ceremony's own text, which made this assertion incapable of failing.
ROSTER_RE='^\|[^|]*[Ww]orkstream[^|]*\|[^|]*[Cc]heckout[^|]*\|[^|]*[Bb]ranch[^|]*\|[^|]*[Tt]ask[^|]*\|[^|]*[Ee]pic[^|]*\|[^|]*[Aa]reas[^|]*\|'
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

# documented and reachable: the phase table routes activation and the lifecycle bullet names the
# ceremony — in the repo copy and in the live twin, which no drift check covers
ACT_RE='^\|[[:space:]]*Activate[^|]*\|[^|]*backlog\.md[^|]*\|'
ACT_BULLET_RE='\*\*ACTIVATE\*\*.*ceremony'
twin2="$HOME/.claude/CLAUDE.md"
if grep -qE "$ACT_RE" global/CLAUDE.md && grep -qE "$ACT_BULLET_RE" global/CLAUDE.md; then
  ok "the global instructions route activation to the backlog protocol"
  if [ -f "$twin2" ]; then
    grep -qE "$ACT_RE" "$twin2" && grep -qE "$ACT_BULLET_RE" "$twin2" \
      && ok "the live twin routes activation to the backlog protocol" \
      || bad "the live twin routes activation to the backlog protocol (stale — re-run ./install.sh)"
  else
    echo "  [skip] live CLAUDE.md twin absent — the shipped one routes activation"
  fi
else
  bad "the global instructions route activation to the backlog protocol"
  bad "the live twin routes activation to the backlog protocol (shipped copy is stale)"
fi

echo "== C14: the audit judges the branch, not the working tree =="
VP="global/protocols/verify.md"
VS="global/skills/verify/SKILL.md"
VW="global/workflows/verify-review.js"
BRAKE="global/hooks/diff-size-guard.py"

# The one definition every consumer reads: bounded at the next heading, fence-aware.
TD="$(awk '/^## The Task Diff/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^#+ /){f=0} f' "$VP" | tr '\n' ' ')"
# The bolded definition SENTENCE, cut at its closing marker. Scoped this tight because 'uncommitted'
# and 'untracked' both recur in the neighbouring paragraphs, so a section-wide grep stayed green when
# the sentence itself was inverted to "Uncommitted work is out of scope".
DEF="$(awk '
  /^\*\*The task diff is/ { b=$0; sub(/^\*\*/,"",b); if (index(b,"**")) { print substr(b,1,index(b,"**")-1); exit } f=1; next }
  f { b = b " " $0; if (index(b,"**")) { print substr(b,1,index(b,"**")-1); exit } }
' "$VP")"
# A numbered step, flattened: what a step must say is a property of the step, never of where its prose
# happens to wrap.
nstep() { awk -v s="^$2\\\\. " -v e="^$(($2 + 1))\\\\. " '$0 ~ e {f=0} $0 ~ s {f=1} f' "$1" | tr '\n' ' '; }
# One bullet inside one step. Two bounds, not one: a fact scoped to a whole step passes on a
# neighbouring bullet's words, and an extractor anchored on the whole file can be retargeted by an
# edit anywhere else in it.
sbullet() { # file, step, pattern
  awk -v s="^$2\\\\. " -v e="^$(($2 + 1))\\\\. " '$0 ~ e {f=0} $0 ~ s {f=1} f' "$1" \
    | awk -v p="$3" 'g && (/^[[:space:]]*[-*][[:space:]]/ || /^[0-9]+\./) {exit} $0 ~ p {g=1} g' | tr '\n' ' '
}
# Byte offset of a fixed string: for the facts that are an ORDER, which presence greps cannot see.
off() { printf '%s' "$1" | grep -obF "$2" | head -1 | cut -d: -f1; }

if [ -n "$DEF" ] \
   && printf '%s' "$DEF" | grep -qiE 'since its base|since the base' \
   && printf '%s' "$DEF" | grep -qiE 'commits included|including its commits' \
   && printf '%s' "$DEF" | grep -qi 'uncommitted' \
   && printf '%s' "$DEF" | grep -qi 'untracked' \
   && ! grep -qi 'working tree, uncommitted' "$VP"; then
  ok "the verify protocol defines the task diff (branch since base + uncommitted)"
else
  bad "the verify protocol defines the task diff (branch since base + uncommitted)"
fi

# the degradation rule is part of the definition, not only of the skill that implements it: without
# this, the protocol paragraph and the templates' fallback wording were deletable with a green suite
if printf '%s' "$TD" | grep -qi 'no base resolves' && printf '%s' "$TD" | grep -qi 'unavailable'; then
  ok "the definition carries the no-base degradation rule"
else
  bad "the definition carries the no-base degradation rule"
fi

# the reverse audit and the provenance grep stop naming a scope of their own. Both patterns are
# required, and the pointer is the marked-up section name matched case-sensitively: a
# case-insensitive "the task diff" collapses onto the bare mention that is already there today,
# which made this pair incapable of failing.
for n in 4 5; do
  S="$(nstep "$VP" "$n")"
  if printf '%s' "$S" | grep -qi 'task diff' \
     && printf '%s' "$S" | grep -q '\*\*The Task Diff\*\*'; then
    ok "verify protocol step $n points at the task diff definition"
  else
    bad "verify protocol step $n points at the task diff definition"
  fi
done

S5="$(nstep "$VS" 5)"
if printf '%s' "$S5" | grep -q 'origin/HEAD' \
   && printf '%s' "$S5" | grep -q 'rev-parse' \
   && printf '%s' "$S5" | grep -q 'main' \
   && printf '%s' "$S5" | grep -q 'master' \
   && printf '%s' "$S5" | grep -q 'merge-base'; then
  ok "verify skill resolves the base like the diff brake and diffs from merge-base"
else
  bad "verify skill resolves the base like the diff brake and diffs from merge-base"
fi

# which candidate WINS is the fact; three presence greps are satisfied in any order, so the order is
# asserted positionally, on the backticked forms so a substring elsewhere cannot stand in
o1="$(off "$S5" 'origin/HEAD')"; o2="$(off "$S5" '`main`')"; o3="$(off "$S5" '`master`')"
if [ -n "$o1" ] && [ -n "$o2" ] && [ -n "$o3" ] && [ "$o1" -lt "$o2" ] && [ "$o2" -lt "$o3" ]; then
  ok "the skill states the base precedence in the brake's order"
else
  bad "the skill states the base precedence in the brake's order (offsets: $o1/$o2/$o3)"
fi

# derived from the source of truth rather than restated beside it: change the hook's candidate list
# and this harness fails, which is the only thing that makes a knowingly duplicated rule safe
cands="$(sed -n "s/.*for cand in (\(.*\)):.*/\1/p" "$BRAKE" | tr -d "\"'" | tr ',' ' ')"
miss=""
for c in $cands; do printf '%s' "$S5" | grep -q "\`$c\`" || miss="$miss $c"; done
if [ -n "$cands" ] && [ -z "$miss" ]; then
  ok "the skill names every base candidate the diff brake actually tries"
else
  bad "the skill names every base candidate the diff brake actually tries (missing:$miss)"
fi

# THE operative command, asserted by shape and not by the word 'merge-base' — which a neighbouring
# bullet supplies, so the word alone stayed green both when a range operator was appended (dropping
# the uncommitted half) and when the command was reverted to plain `git diff HEAD`
MBB="$(sbullet "$VS" 5 'Capture it once')"
if printf '%s' "$MBB" | grep -qF 'MB="$(git merge-base <base> HEAD)"' \
   && ! printf '%s' "$MBB" | grep -qE 'merge-base[^`]*\.\.'; then
  ok "the skill captures the merge-base itself, with no range operator narrowing it"
else
  bad "the skill captures the merge-base itself, with no range operator narrowing it"
fi
DTB="$(sbullet "$VS" 5 'Otherwise')"
if printf '%s' "$DTB" | grep -qF 'git diff "$MB"' \
   && ! printf '%s' "$DTB" | grep -qE 'MB[^`]*\.\.'; then
  ok "the diff that becomes diffText runs from the captured base to the working tree"
else
  bad "the diff that becomes diffText runs from the captured base to the working tree"
fi

# the copy names its original, so a reader finds the brake instead of two rules that drifted apart
printf '%s' "$S5" | grep -q 'diff-size-guard' \
  && ok "the skill's base resolution cites the diff brake it copies" \
  || bad "the skill's base resolution cites the diff brake it copies"

CF="$(sbullet "$VS" 5 'changedFiles')"
if printf '%s' "$CF" | grep -qiE 'base-scoped|that same' \
   && printf '%s' "$CF" | grep -qi 'untracked' \
   && printf '%s' "$CF" | grep -q 'source_dirs'; then
  ok "changedFiles derives from the base-scoped diff plus untracked, scoped to source_dirs"
else
  bad "changedFiles derives from the base-scoped diff plus untracked, scoped to source_dirs"
fi

FB="$(sbullet "$VS" 5 'no base')"
if printf '%s' "$FB" | grep -q 'git diff HEAD' \
   && printf '%s' "$FB" | grep -qi 'unavailable'; then
  ok "no resolvable base falls back to the working tree and says so"
else
  bad "no resolvable base falls back to the working tree and says so"
fi

# the count the report must carry has to be measured somewhere, and written somewhere
printf '%s' "$S5" | grep -q 'rev-list' \
  && ok "the skill measures the commit count its report has to name" \
  || bad "the skill measures the commit count its report has to name"
# Resolved by content: inserting a step renumbers every step after it, and an assertion that dies to
# renumbering is testing the numbering. The fact is a property of the WRITE step, wherever it sits.
N_WRITE="$(grep -nE '^[0-9]+\. \*\*Write\*\* ' "$VS" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/')"
S8="$([ -n "$N_WRITE" ] && nstep "$VS" "$N_WRITE")"
if printf '%s' "$S8" | grep -q '\*\*Audited\*\*' && printf '%s' "$S8" | grep -qi 'commit'; then
  ok "the report writer carries the base and the commit count into verify.md"
else
  bad "the report writer carries the base and the commit count into verify.md"
fi

# the skill's own reverse audit names where its scope comes from: the gather is not what step 4 skips
RA="$(sbullet "$VS" 3 'Reverse audit')"
if printf '%s' "$RA" | grep -qi 'task diff' && printf '%s' "$RA" | grep -qiE 'step 5|gather'; then
  ok "the skill's reverse audit names the step its scope comes from"
else
  bad "the skill's reverse audit names the step its scope comes from"
fi

# both report templates, not only the one the multi-agent review path writes: the reverse audit and
# the provenance grep consume the task diff even when the review is skipped. Counted, and read off
# non-comment lines carrying the placeholders themselves — 'base' plus 'commit' were satisfied by a
# commented-out fallback line ("uncommitted" contains "commit"), so deleting the whole Audited line
# left the suite green.
TC="$(awk '
  /^```/ { if (inf) { if (seen) { total++; if (hb && hc && hf) good++ } seen=0; hb=0; hc=0; hf=0 } inf=1-inf; next }
  inf {
    if ($0 ~ /# Verify: T-XXX/) seen=1
    if ($0 ~ /^[[:space:]]*<!--/) next
    if ($0 ~ /\[base ref\]/) hb=1
    if ($0 ~ /commit\(s\)/) hc=1
    if (tolower($0) ~ /branch scope unavailable/) hf=1
  }
  END { print (good+0) "/" (total+0) }
' "$VP")"
[ "$TC" = "2/2" ] && ok "both verify.md templates carry the measured base and commit count" \
                  || bad "both verify.md templates carry the measured base and commit count ($TC)"

DH="$(grep 'DIFF' "$VW" | tr '\n' ' ')"
if printf '%s' "$DH" | grep -qiE 'branch|since|base' && ! printf '%s' "$DH" | grep -qi 'working tree'; then
  ok "the auditors' diff header names the branch scope, not the working tree"
else
  bad "the auditors' diff header names the branch scope, not the working tree"
fi

echo "== C15: closing a front is a serialised merge ceremony =="
BLG4="global/protocols/backlog.md"

# The ceremony, bounded at the next section, fence-aware — the opening's own idiom.
CLO="$(awk '/^## Closing a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG4")"
# One numbered move, flattened AND whitespace-squeezed. What a move must say is a property of the move,
# never of where its prose happens to wrap — and joining wrapped lines leaves their indentation behind,
# so a two-word fact split across a line break reads as 'never    before' and every single-space
# pattern misses it. Re-wrapping unchanged prose must never change a verdict.
clomove() { printf '%s\n' "$CLO" | awk -v n="$1" '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==n' | tr '\n' ' ' | tr -s ' '; }
# The move's own lead line — its identity. Classifying on the lead rather than on the body is what
# lets the order assertion see a MOVED move: a body pattern matches wherever its words landed.
clohead() { printf '%s\n' "$CLO" | grep -E "^$1\. " | head -1; }
mpair() { # move, pattern A, pattern B, label
  printf '%s' "$(clomove "$1")" | grep -qiE "$2" && printf '%s' "$(clomove "$1")" | grep -qiE "$3" \
    && ok "$4" || bad "$4"
}

if [ -n "$CLO" ]; then
  # The six moves, each identified by its own lead and read in sequence. The ORDER is the fact this
  # guards: a collection written after the merge changes the sequence while every presence grep in
  # this section stays green.
  seq=""
  for i in 1 2 3 4 5 6; do
    case "$(clohead "$i" | tr 'A-Z' 'a-z')" in
      *valid*)               seq="$seq V" ;;
      *collect*|*harvest*)   seq="$seq C" ;;
      *merge*)               seq="$seq M" ;;
      *record*|*ledger*)     seq="$seq L" ;;
      *dismantl*|*worktree*) seq="$seq D" ;;
      *roster*|*row*)        seq="$seq R" ;;
      *)                     seq="$seq ?" ;;
    esac
  done
  [ "$seq" = " V C M L D R" ] \
    && ok "the protocol defines the ceremony that closes a front" \
    || bad "the protocol defines the ceremony that closes a front (moves unnamed or out of order:$seq)"

  # One pattern, not two: 'outside version control' and a bare 'branch' both occur elsewhere in this
  # move, so an either-or pair passed with the fact itself deleted. The fact is the relation.
  printf '%s' "$(clomove 2)" \
    | grep -qiE '(does not|do not|never) (travel|reach)[^.]*branch|branch carries (none|nothing)|merge carries none' \
    && ok "the papers are collected before the merge, and never travel with the branch" \
    || bad "the papers are collected before the merge, and never travel with the branch"
  mpair 2 'worktree list' 'stop' \
    "an unlocatable front checkout stops the closing"
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
  if printf '%s' "$(clomove 5)" | grep -qiE 'no next task|has no next|last task' \
     && printf '%s' "$(clomove 6)" | grep -qiE 'no next task|has no next|last task'; then
    ok "a front with a next task keeps its checkout and its roster row"
  else
    bad "a front with a next task keeps its checkout and its roster row"
  fi

  mpair 5 'never before' 'destroy' \
    "dismantling the checkout before the collection destroys the task's papers"
  mpair 1 'valid' 'nothing merges|before .*merge|does not merge' \
    "the user validates the branch before anything merges"

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
  # take down. Without this the ceremony reads as a six-move ritual for every single archive.
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
  bad "the user validates the branch before anything merges (no section)"
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

# Step 7 of the checklist move 4 delegates to. The ceremony promises the roster row is removed only on
# the front's last task; the checklist used to order that removal unconditionally, and moves 5-6 were the
# only text carrying the condition — so the suite stayed green over a contradiction on the contract's
# central fact. This reads the callee, not just the caller.
ARC7="$(awk '/^### After ARCHIVE \(single task\)/{f=1;next} (f && /^#+ /){f=0} f' "$BLG4" | awk '/^8\./{f=0} /^7\./{f=1} f' | tr '\n' ' ' | tr -s ' ')"
EPI6="$(awk '/^### After Epic completion/{f=1;next} (f && /^#+ /){f=0} f' "$BLG4" | awk '/^7\./{f=0} /^6\./{f=1} f' | tr '\n' ' ' | tr -s ' ')"
if printf '%s' "$ARC7" | grep -qiE 'no next task' \
   && printf '%s' "$ARC7" | grep -qiE 'move 6|Closing a Workstream' \
   && ! printf '%s' "$ARC7" | grep -qiE '^7\. (Remove|Delete) ' \
   && printf '%s' "$EPI6" | grep -qiE 'move 6|only remover|Closing a Workstream' \
   && ! printf '%s' "$EPI6" | grep -qiE '^6\. (Remove|Delete) '; then
  ok "both checklists leave the roster row to the ceremony's last move"
else
  bad "both checklists leave the roster row to the ceremony's last move"
fi

# The two halves must name each other, and the heading every extractor above depends on must exist as a
# heading — a renamed section silently empties $CLO, and an empty $CLO is a different verdict than a wrong one.
OPN="$(awk '/^## Opening a Workstream/{f=1;next} (/^## /){f=0} f' "$BLG4" | tr '\n' ' ' | tr -s ' ')"
if grep -qE '^## Closing a Workstream' "$BLG4" && printf '%s' "$OPN" | grep -q 'Closing a Workstream'; then
  ok "the two halves of the workstream ceremony name each other"
else
  bad "the two halves of the workstream ceremony name each other"
fi

# The lifecycle route, in the repo copy and in the live twin that no drift check covers.
ARCH_BULLET_RE='\*\*ARCHIVE\*\*.*(closing ceremony|Closing a Workstream)'
# Two routes, not one: the lifecycle step AND the post-commit rule. Routing only the first leaves the
# rule the operator actually reads after committing pointing past moves 1-3 of the ceremony.
POST_ROUTE_RE='immediately\*\* run the closing ceremony'
manroutes() { grep -qE "$ARCH_BULLET_RE" "$1" && grep -qE "$POST_ROUTE_RE" "$1"; }
twin3="$HOME/.claude/CLAUDE.md"
if manroutes global/CLAUDE.md; then
  ok "the shipped manual routes ARCHIVE to the closing ceremony"
  if [ -f "$twin3" ]; then
    manroutes "$twin3" \
      && ok "the live twin routes ARCHIVE to the closing ceremony" \
      || bad "the live twin routes ARCHIVE to the closing ceremony (stale — re-run ./install.sh)"
  else
    echo "  [skip] live CLAUDE.md twin absent — the shipped one routes ARCHIVE"
  fi
else
  bad "the shipped manual routes ARCHIVE to the closing ceremony"
  bad "the live twin routes ARCHIVE to the closing ceremony (shipped copy is stale)"
fi

echo "== C16: a phase command resolves the task its own checkout owns =="
BLG5="global/protocols/backlog.md"
RAIL="global/hooks/understand-write-guard.py"
PHASE_SKILLS="understand plan verify"

# The owner block, bounded at the next heading of any depth: the ladder is ONE fact with ONE home, and
# a section-wide grep over State Files would pass on the neighbouring paragraph that already describes
# the branch field for the rail alone.
BLK="$(awk '/^### Resolving the task/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^#+ /){f=0} f' "$BLG5" | tr -s ' ')"
# One rung of the numbered ladder, flattened: what a rung must say is a property of the rung, never of
# where its prose happens to wrap, and never of a neighbouring rung's words.
rung() { printf '%s\n' "$BLK" | awk -v s="^$1\\\\. " -v e="^$(($1 + 1))\\\\. " '$0 ~ e {f=0} $0 ~ s {f=1} f' | tr '\n' ' '; }

if [ -n "$BLK" ]; then
  ok "the protocol names the ladder a reader follows to find its task"

  # Each rung carries its own fact. Order is proven by extraction, not by a presence grep: swapping two
  # rungs' contents leaves every phrase in the block and still fails here.
  r1="$(rung 1)"; r2="$(rung 2)"; r3="$(rung 3)"; r4="$(rung 4)"
  miss=""
  printf '%s' "$r1" | grep -qi 'branch currently checked out'  || miss="$miss rung1-branch"
  printf '%s' "$r1" | grep -qi 'exactly one'                   || miss="$miss rung1-unique"
  printf '%s' "$r2" | grep -qi 'no branch'                     || miss="$miss rung2-unclaimed"
  printf '%s' "$r2" | grep -qiE 'lone|alone|single|exactly one' || miss="$miss rung2-unique"
  printf '%s' "$r3" | grep -qi 'exactly one task'              || miss="$miss rung3-unambiguous"
  printf '%s' "$r4" | grep -qiE 'stop'                         || miss="$miss rung4-stop"
  printf '%s' "$r4" | grep -qi 'looked for'                    || miss="$miss rung4-names-what"
  [ -z "$miss" ] && ok "the ladder's rungs are stated in order, from the sheet that claims the branch to the stop" \
                 || bad "the ladder's rungs are stated in order, from the sheet that claims the branch to the stop (missing:$miss)"

  # The condition, not the mention: 'at least one' would keep every word of the rung and invert it.
  if printf '%s' "$r3" | grep -qi 'exactly one task' \
     && ! printf '%s' "$BLK" | grep -qiE 'at least one task|any task it names'; then
    ok "the shared state answers only where it names exactly one task"
  else
    bad "the shared state answers only where it names exactly one task"
  fi

  # Ambiguity and the stop must be joined in one rung. Held apart, the block can say both and still
  # leave a reader free to pick.
  if printf '%s' "$r3$r4" | grep -qiE 'several|more than one|two or more' \
     && printf '%s' "$r4" | grep -qi 'stop'; then
    ok "an ambiguous shared state stops the reader instead of choosing"
  else
    bad "an ambiguous shared state stops the reader instead of choosing"
  fi

  # The rail resolves with no branch checked out at all, and the block used to be silent about it —
  # a path in the implementation that no rung covered, in a document claiming every reader follows the
  # same four rungs. Scoped outside the rungs because it is a precondition of rung 1, not a rung.
  if printf '%s' "$BLK" | grep -qiE 'detached HEAD|no branch to match|with none' \
     && printf '%s' "$BLK" | grep -qi 'whatever branch it declares'; then
    ok "the block states the no-branch case, where the lone sheet answers whatever it declares"
  else
    bad "the block states the no-branch case, where the lone sheet answers whatever it declares"
  fi

  # The block owns the ladder for BOTH readers, so it must name the code half — otherwise the prose and
  # the implementation are two facts again, which is the drift this task exists to close.
  if printf '%s' "$BLK" | grep -q 'understand-write-guard.py' \
     && printf '%s' "$BLK" | grep -qiE 'rungs 1 and 2|first two rungs'; then
    ok "the block names the rail that shares its first two rungs"
  else
    bad "the block names the rail that shares its first two rungs"
  fi
else
  bad "the protocol names the ladder a reader follows to find its task"
  bad "the ladder's rungs are stated in order, from the sheet that claims the branch to the stop (no block)"
  bad "the shared state answers only where it names exactly one task (no block)"
  bad "an ambiguous shared state stops the reader instead of choosing (no block)"
  bad "the block names the rail that shares its first two rungs (no block)"
  bad "the block states the no-branch case, where the lone sheet answers whatever it declares (no block)"
fi

# D5: the pointer runs both ways, so editing the code half leads back to where the rule is written.
grep -q 'Resolving the task' "$RAIL" \
  && ok "the rail points back at the block that owns the ladder" \
  || bad "the rail points back at the block that owns the ladder"

for s in $PHASE_SKILLS; do
  f="global/skills/$s/SKILL.md"
  if [ ! -f "$f" ]; then
    bad "$s cites the ladder's owner (file missing: $f)"
    bad "$s does not restate the ladder (file missing)"
    bad "$s resolves its task before it touches the task's papers (file missing)"
    bad "$s says which task it resolved and what it read (file missing)"
    bad "$s does not name the shared state as its task source (file missing)"
    bad "$s cites the ladder from its protocol too (file missing)"
    continue
  fi
  c="$(cat "$f")"

  # Citing means naming the block AND the document that holds it: the phrase alone could be this
  # skill's own heading.
  if printf '%s' "$c" | grep -q 'Resolving the task' && printf '%s' "$c" | grep -q 'backlog.md'; then
    ok "$s cites the ladder's owner"
  else
    bad "$s cites the ladder's owner"
  fi

  # The anti-drift assertion. A skill may name the ordinary case (the sheet claiming this branch) —
  # that is the headline, not the ladder. What it may never do is re-spell the FALLBACK rungs, because
  # a second statement of those is the copy that drifts.
  if printf '%s' "$c" | grep -qi 'exactly one task' || printf '%s' "$c" | grep -qi 'declares no branch'; then
    bad "$s does not restate the ladder"
  else
    ok "$s does not restate the ladder"
  fi

  # Order, not presence: resolving after the first read of the task's papers is the bug itself.
  o_res="$(off "$c" 'Resolve the task')"
  o_art="$(off "$c" 'artifacts/T-XXX/')"
  if [ -n "$o_res" ] && [ -n "$o_art" ] && [ "$o_res" -lt "$o_art" ]; then
    ok "$s resolves its task before it touches the task's papers"
  else
    ok_res="${o_res:-none}"; ok_art="${o_art:-none}"
    bad "$s resolves its task before it touches the task's papers (resolve@$ok_res papers@$ok_art)"
  fi

  # Saying WHICH task and WHICH file: a report naming only the task cannot be checked against what it
  # should have read. Scoped to the resolving step, not the file: the audit command names the sheet in
  # its report line too, so the file-wide form let the two halves be satisfied by two different steps
  # and survived deleting the source from the step that resolves.
  res="$(nstep "$f" 2)"
  if printf '%s' "$res" | grep -qiE 'state (which|the) task|report (which|the) task|say (which|the) task' \
     && printf '%s' "$res" | grep -qiE 'the (sheet|source|file) it read'; then
    ok "$s says which task it resolved and what it read"
  else
    bad "$s says which task it resolved and what it read"
  fi

  # The shared-state rung belongs to the ladder's owner alone, so no command may name that file as
  # where its task comes from. Ran against the audit command only before — the other two could point
  # at the roster and stay green. Case-insensitive, and the loop's existence guard covers the read.
  if grep -niE 'task' "$f" | grep -qi 'STATE.md'; then
    bad "$s does not name the shared state as its task source"
  else
    ok "$s does not name the shared state as its task source"
  fi

  # M4: the protocol is the declared spec and the path a project without the skill installed follows,
  # so the rule has to be there too — not only in the front-end that reads it.
  pf="global/protocols/$s.md"
  if [ -f "$pf" ] && grep -q 'Resolving the task' "$pf"; then
    ok "$s cites the ladder from its protocol too"
  else
    bad "$s cites the ladder from its protocol too"
  fi
done


# D2's fold: one fact, one place. The report rides the line that already declares what the audit read.
VS16="global/skills/verify/SKILL.md"
n8="$(grep -nE '^[0-9]+\. \*\*Write\*\* ' "$VS16" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/')"
s8="$([ -n "$n8" ] && nstep "$VS16" "$n8")"
# NOT a bare 'resolved': step 8 already carries "when no base resolved", so the loose form passed on
# the BASE's resolution and never saw the task's. The line must name the task or the sheet it came from.
if printf '%s' "$s8" | grep -q 'Audited' \
   && printf '%s' "$s8" | grep -qiE 'the task it resolved|the sheet it read'; then
  ok "the audit's resolution report rides the line that already says what it read"
else
  bad "the audit's resolution report rides the line that already says what it read"
fi


echo "== C17: the manual describes the parallel model it implements =="
MAN="global/CLAUDE.md"
MANTWIN="${HOME:-}/.claude/CLAUDE.md"   # guarded: the suite runs under set -u and the twin is optional
C17_SKIPPED=0

# A section body, bounded by the next heading of any depth: a fact belongs to the section that governs
# it, and a file-wide grep finds the first line that happens to match anywhere in a 200-line manual.
msect() { awk -v h="$2" '$0 ~ h {f=1;next} (f && /^#+ /){exit} f' "$1"; }
# One bullet of that section, from its lead to the next bullet, flattened: what a bullet says is a
# property of the bullet, never of where its prose wraps or of the neighbouring bullet's words.
mbul() { msect "$1" "$2" | awk -v s="$3" '/^- /{ if(f) exit; f=($0 ~ s) } f' | tr -s ' \n' '  '; }
# A table row, by the command it names, inside the section that owns the table — same reason msect and
# mbul exist: a file-wide row grep retargets itself the day any earlier table happens to name the command.
mrow() { msect "$1" "$3" | grep -m1 -E "^\|[^|]*$2[^|]*\|" | tr -s ' '; }

# One fact, checked identically in both copies. The live twin carries the user's own language and
# sections, so every fact below is matched by what it says and never by the text around it. The remedy
# names the hand-merge because nothing distributes this file: the installer writes it only when absent
# and the drift guard excludes it as user-owned (global/hooks/drift-check.sh).
manfact() {
  local fn="$1" what="$2"
  "$fn" "$MAN" && ok "$what" || bad "$what"
  # Each copy is judged on itself. A verdict about the twin printed without opening the twin blames a
  # manual the reader may not own — and on a host without one it turns the documented skip into a failure.
  if [ -f "$MANTWIN" ]; then
    "$fn" "$MANTWIN" && ok "the live twin: $what" \
      || bad "the live twin: $what (port the edit by hand — nothing distributes ~/.claude/CLAUDE.md)"
  else
    echo "  [skip] live CLAUDE.md twin absent — the shipped copy carries the fact"
    C17_SKIPPED=$((C17_SKIPPED+1))
  fi
}

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

# Fact 3a — the commit gate names where it changes and who owns the change, and explains nothing itself.
# The negative half is the point: this epic has twice paid for one fact living in two documents, so the
# ceremony's reasoning appearing here is a failure even though every positive phrase is still present.
mf_commit_gate() {
  local s x
  s="$(msect "$1" '^### Commit Protocol' | tr -s ' \n' '  ')"
  [ -n "$s" ] || return 1
  # The exception's own statement, not the section around it. Scoped to the section, the citation checks
  # passed on text that predates the rule: the Post-Commit paragraph already said "run the closing
  # ceremony (read backlog protocol) ... in the coordinator", so the half of the criterion that demands a
  # pointer to the owner could not fail, and an exception stated with no pointer at all read green.
  x="$(msect "$1" '^### Commit Protocol' | grep -m1 -iE 'gate is the branch|not each commit|not per commit')"
  [ -n "$x" ] || return 1
  printf '%s' "$x" | grep -qiE 'worktree|front'          || return 1
  printf '%s' "$x" | grep -qi  'closing ceremony'        || return 1
  printf '%s' "$x" | grep -qiE 'backlog protocol|move 1' || return 1
  # The coordinator's rule is untouched, and saying so is what keeps the exception from reading global.
  printf '%s' "$x" | grep -qi  'coordinator'             || return 1
  # The owner's explanation stays with the owner — a section-wide check, because a copy of it anywhere
  # in the block is the drift this guards.
  printf '%s' "$s" | grep -qi  'disposable by construction' && return 1
  return 0
}
manfact mf_commit_gate "the commit gate names where it changes and cites the ceremony that owns the change"

# Fact 3b — the hard stop carries the same condition as the gate three sections above it. Asserted on its
# own, which is strictly stronger than "fails when the gate has the exception and the stop does not": the
# suite that asserts only the caller lets the callee contradict it, which is how one procedure ends
# up stated two ways in one document.
mf_commit_stop() {
  local b; b="$(mbul "$1" '^### Never' 'Commit without user validation')"
  [ -n "$b" ] || return 1
  # 'see Commit Protocol' alone is a cross-reference, not a condition: the stop would still read
  # unconditionally, which is the exact state this criterion exists to catch.
  printf '%s' "$b" | grep -qiE 'coordinator|in(side)? a front|gate is the branch' || return 1
}
manfact mf_commit_stop "the hard stop carries the same condition as the commit gate it repeats"

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

echo "== C18: a review leaves the working copy as it found it =="
VP="global/protocols/verify.md"
VS="global/skills/verify/SKILL.md"
VW="global/workflows/verify-review.js"
PP="global/protocols/plan.md"
RULE_SECTION="Mutation and the Working Copy"

# The rule's own section, bounded at the next heading and fence-aware — the same shape C14 uses for
# the task-diff definition, and for the same reason: a file-wide grep finds the citations, not the rule.
RULE="$(awk '/^## Mutation and the Working Copy/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^#+ /){f=0} f' "$VP" | tr '\n' ' ')"

# Fact 1a — the invariant itself. Asserted on the section, never on the file: every consumer names the
# section, so a file-wide grep for the citation stays green after the rule itself is deleted.
if [ -n "$RULE" ] && printf '%s' "$RULE" | grep -qi 'never modifies what it audits'; then
  ok "the verify protocol states the invariant (an audit never modifies what it audits)"
else
  bad "the verify protocol states the invariant (an audit never modifies what it audits)"
fi

# Fact 1b — the obligation, which is what the invariant is worth. An invariant with no duty attached
# reads as a preference: the change is taken back, and the run says the copy was left as found.
if [ -n "$RULE" ] \
   && printf '%s' "$RULE" | grep -qiE 'taken back|restored|puts? it back|put back' \
   && printf '%s' "$RULE" | grep -qiE 'left as it was found|byte-exact|byte-identical'; then
  ok "the rule obliges the change to be taken back and the copy proven as found"
else
  bad "the rule obliges the change to be taken back and the copy proven as found"
fi

# Fact 1c — serialisation. This is the half that answers the race, and it is the half a reader tempted
# by speed deletes first: parallel provers lose no work and still produce a verdict about a state that
# never existed.
if [ -n "$RULE" ] && printf '%s' "$RULE" | grep -qiE 'one actor at a time|one at a time|never in parallel|never beside'; then
  ok "the rule serialises proving to one actor at a time"
else
  bad "the rule serialises proving to one actor at a time"
fi

# Fact 1d — the failure mode is spoken, not silent. A run that cannot prove the copy clean says so;
# silence here is indistinguishable from a clean run, which is the defect the whole task exists for.
if [ -n "$RULE" ] \
   && printf '%s' "$RULE" | grep -qiE 'says so|declares|reports it' \
   && printf '%s' "$RULE" | grep -qiE 'rather than (staying )?silent|never silent|not stay silent'; then
  ok "the rule requires a run that cannot prove it clean to say so"
else
  bad "the rule requires a run that cannot prove it clean to say so"
fi

# The workflow's shared prompt header, bounded by the join that closes it: the four auditors and the
# refuter all inherit it, so a fact placed here is a fact every worker reads — and a fact asserted on
# the whole file would pass on the schema, the comments, or a dimension that no longer includes it.
CTX="$(awk "/^const ctx = \[/{f=1;next} /^\]\.join/{f=0} f" "$VW" | tr '\n' ' ')"

# Fact 2 — the three consumers cite the rule by the section that owns it. A consumer that names no
# section sends its reader nowhere, which is how a second, drifting copy gets written.
for pair in "$VS:the verify skill" "$PP:the plan protocol's Conform section"; do
  f="${pair%%:*}"; what="${pair#*:}"
  grep -qF "$RULE_SECTION" "$f" && ok "$what cites the rule's section" || bad "$what cites the rule's section"
done
# The workflow carries two citations — the shared header and the prover's own prompt — so a file-wide
# grep stays green after the auditors' half is deleted, which is the half that governs the four agents
# reading the same working copy. Each is asserted where its reader actually finds it.
{ [ -n "$CTX" ] && printf '%s' "$CTX" | grep -qF "$RULE_SECTION"; } \
  && ok "the review workflow cites the rule's section in the header every auditor reads" \
  || bad "the review workflow cites the rule's section in the header every auditor reads"

# Fact 2b — and none of them restates it. One fact in two documents is the drift this epic has already
# paid for twice; the invariant sentence is the canary, and it lives in exactly one engine file.
RULE_HOMES="$(grep -rlie 'never modifies what it audits' global/ 2>/dev/null | wc -l | tr -d ' ')"
[ "$RULE_HOMES" = "1" ] \
  && ok "the invariant is stated in exactly one engine file (found in $RULE_HOMES)" \
  || bad "the invariant is stated in exactly one engine file (found in $RULE_HOMES)"

# Fact 3a — the workers declare themselves read-only. Emergent mutation is what three tasks paid for,
# and nothing in this file has ever said not to.
if [ -n "$CTX" ] \
   && printf '%s' "$CTX" | grep -qiE 'read-only|read only' \
   && printf '%s' "$CTX" | grep -qiE 'do not (edit|modify|change|write)|never (edit|modify|change|write)'; then
  ok "the shared review header declares every worker read-only"
else
  bad "the shared review header declares every worker read-only"
fi

# Fact 3b — and every worker actually inherits that header. The declaration is worth exactly as much as
# its reach: dropping `ctx` from one dimension is a mutation that leaves the sentence in place.
CTX_USES="$(awk '/^const DIMENSIONS = \[/{f=1;next} /^\]$/{f=0} f' "$VW" | grep -cE '^[[:space:]]+ctx,')"
[ "$CTX_USES" = "4" ] \
  && ok "all four auditor prompts inherit the shared header (found $CTX_USES)" \
  || bad "all four auditor prompts inherit the shared header (found $CTX_USES)"
awk '/^function refutePrompt/{f=1} f&&/^}/{exit} f' "$VW" | grep -qE '^[[:space:]]+ctx,' \
  && ok "the refutation prompt inherits the shared header" \
  || bad "the refutation prompt inherits the shared header"

# Fact 4a — the mutation instinct becomes a structured proposal the worker hands over.
FSCHEMA="$(awk '/^const FINDINGS_SCHEMA = \{/{f=1} f&&/^\}$/{print;exit} f' "$VW" | tr '\n' ' ')"
if [ -n "$FSCHEMA" ] && printf '%s' "$FSCHEMA" | grep -q 'proposedMutation'; then
  ok "the findings schema carries a proposed mutation"
else
  bad "the findings schema carries a proposed mutation"
fi

# Fact 4b — and the header calls it a proposal the worker does not perform. A field alone invites the
# very act it was meant to replace.
if [ -n "$CTX" ] && printf '%s' "$CTX" | grep -q 'proposedMutation' \
   && printf '%s' "$CTX" | grep -qiE 'do not apply|never apply|without applying|do not run it'; then
  ok "the header describes the proposal as something the worker does not perform"
else
  bad "the header describes the proposal as something the worker does not perform"
fi

# Byte offset of a fixed string: for the facts that are an ORDER, which presence greps cannot see.
voff() { grep -obF "$2" "$1" | head -1 | cut -d: -f1; }

# Fact 5a — exactly one prover. Two of them is the race again, wearing the new name.
PROVERS="$(grep -cF "phase: 'Prove'" "$VW")"
[ "$PROVERS" = "1" ] \
  && ok "the workflow runs exactly one prover stage (found $PROVERS)" \
  || bad "the workflow runs exactly one prover stage (found $PROVERS)"
grep -qE "\{ title: 'Prove'" "$VW" \
  && ok "the workflow declares the prover phase in its meta" \
  || bad "the workflow declares the prover phase in its meta"

# Fact 5b — it runs after the refutation, not beside it. Presence cannot see an order, so this is an
# offset: a prover spawned inside the pipeline would still satisfy every check above.
O_REF="$(voff "$VW" "phase: 'Refute'")"; O_PRV="$(voff "$VW" "phase: 'Prove'")"
if [ -n "$O_REF" ] && [ -n "$O_PRV" ] && [ "$O_PRV" -gt "$O_REF" ]; then
  ok "the prover stage is sequenced after the refutation stage"
else
  bad "the prover stage is sequenced after the refutation stage"
fi

# The prover's own region, from its anchor to the end of the script.
PROVE="$(awk '/One prover, serialised/{f=1} f' "$VW")"

# The prover reads its own copy of the citation: it is the actor the rule appoints, and the header it
# does not inherit is the one that would otherwise have told it so.
# Scoped to the prompt array, never to the region: the comment introducing that region carries the
# citation too, and a human reading the source is not the reader this fact is about.
PROMPT="$(awk '/^  const provePrompt = \[/{f=1;next} /^  \]\.join/{f=0} f' "$VW" | tr '\n' ' ')"
{ [ -n "$PROMPT" ] && printf '%s' "$PROMPT" | grep -qF "$RULE_SECTION"; } \
  && ok "the prover's prompt cites the rule it works under" \
  || bad "the prover's prompt cites the rule it works under"

# Fact 5c — nothing in that region fans out. The whole point of moving the proof here is that exactly
# one worker touches the copy at a time.
if [ -n "$PROVE" ] && ! printf '%s' "$PROVE" | grep -q 'parallel('; then
  ok "the prover stage spawns no parallel work"
else
  bad "the prover stage spawns no parallel work"
fi

# Fact 6 — no proposal, no prover. Without the guard every review pays for a worker with nothing to do,
# and the promise that a clean review costs what it costs today is broken.
if [ -n "$PROVE" ] && printf '%s' "$PROVE" | grep -qE 'proposedMutation|proposals'; then
  # Anchored on a conditional over the proposals themselves, at line start. The loose form matched a
  # ternary inside the prompt text, so removing the guard entirely left the assertion green.
  G="$(printf '%s' "$PROVE" | grep -nE '^if \(.*proposals' | head -1 | cut -d: -f1)"
  A="$(printf '%s' "$PROVE" | grep -nF 'agent(' | head -1 | cut -d: -f1)"
  if [ -n "$G" ] && [ -n "$A" ] && [ "$G" -lt "$A" ]; then
    ok "the prover is guarded by the presence of a proposal"
  else
    bad "the prover is guarded by the presence of a proposal"
  fi
else
  bad "the prover is guarded by the presence of a proposal"
fi

# A numbered step of the skill, flattened. Not pinned to a literal number: inserting the bracket step
# renumbers everything after it, and an assertion that dies to renumbering tests the numbering.
vstep() { awk -v s="^$2\\\\. " -v e="^$(($2 + 1))\\\\. " '$0 ~ e {f=0} $0 ~ s {f=1} f' "$1" | tr '\n' ' '; }
N_INV="$(grep -nE '^[0-9]+\. \*\*Invoke the verify-review workflow' "$VS" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/')"
N_GATH="$(grep -nE '^[0-9]+\. \*\*Gather the task diff' "$VS" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/')"

# Fact 7a — the copy is taken before the review is invoked, and it covers what no diff reaches.
# Scoped to the bullet that carries the copy, never to the step: the step already collected untracked
# files for the diff long before this rule existed, so a step-wide grep for 'untracked' stayed green
# after the copy stopped taking them. The extractor's own anchor is the byte-exact fact — an edit that
# drops it returns an empty block, which is a red for the right reason.
S_COPY="$([ -n "$N_GATH" ] && sbullet "$VS" "$N_GATH" 'byte-exact copy')"
if [ -n "$N_GATH" ]; then
  if [ -n "$S_COPY" ] \
     && printf '%s' "$S_COPY" | grep -qF '/untracked/' \
     && printf '%s' "$S_COPY" | grep -qiE 'outside the repository|mktemp'; then
    ok "the verify skill takes a byte-exact copy, untracked files included, outside the repository"
  else
    bad "the verify skill takes a byte-exact copy, untracked files included, outside the repository"
  fi
else
  bad "the verify skill takes a byte-exact copy, untracked files included, outside the repository"
fi

# Fact 7b — the comparison happens after the invocation. This is the fact the whole task turns on, so it
# is an order and not a presence: a compare step written before the invocation proves nothing at all.
if [ -n "$N_INV" ]; then
  S_AFTER="$(vstep "$VS" "$((N_INV + 1))")"
  if printf '%s' "$S_AFTER" | grep -qiE 'compare' \
     && printf '%s' "$S_AFTER" | grep -qiE 'restore' \
     && printf '%s' "$S_AFTER" | grep -qiE 'byte-exact|byte-identical|copy taken'; then
    ok "the step after the invocation compares against the copy and restores from it"
  else
    bad "the step after the invocation compares against the copy and restores from it"
  fi
else
  bad "the step after the invocation compares against the copy and restores from it"
fi

# Fact 7c — the bracketing is a step, not a suggestion. Softening it back to a discipline is the exact
# regression this task exists to end, and every hedge below leaves the sentence otherwise intact.
if [ -n "$S_COPY" ] \
   && ! printf '%s' "$S_COPY" | grep -qiE 'optional|if you remember|when convenient|recommended'; then
  ok "the copy step is stated as a step, not as a recommendation"
else
  bad "the copy step is stated as a step, not as a recommendation"
fi

# Fact 7d — the writer records the verdict, with both branches. The slot existing in the template and
# nobody being told to fill it is the same silence this task exists to end: deleting the clause from the
# write step left the whole suite green.
N_WR="$(grep -nE '^[0-9]+\. \*\*Write\*\* ' "$VS" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/')"
S_WR="$([ -n "$N_WR" ] && vstep "$VS" "$N_WR")"
if printf '%s' "$S_WR" | grep -qiE 'left as found|tree verdict' \
   && printf '%s' "$S_WR" | grep -qiE 'what differed|restored'; then
  ok "the write step records the tree verdict, both branches"
else
  bad "the write step records the tree verdict, both branches"
fi

# Fact 7e — the copy is taken in a form that can actually put things back. A plain patch cannot represent
# a binary change, so a restore from one silently cannot restore it.
if printf '%s' "$S_COPY" | grep -qF -- '--binary'; then
  ok "the copy is taken in a form that can restore a binary change"
else
  bad "the copy is taken in a form that can restore a binary change"
fi

# Fact 7f — the comparison fails closed. Reached with no record, the destructive branch would discard the
# work against nothing; reached with a record it cannot replay, it would erase and then fail to put back.
if printf '%s' "$S_AFTER" | grep -qiE 'missing|absent' \
   && printf '%s' "$S_AFTER" | grep -qiE 'not\*{0,2} enter|never enter' \
   && printf '%s' "$S_AFTER" | grep -qF -- '--check' \
   && printf '%s' "$S_AFTER" | grep -qiE 'restore \*\*nothing\*\*|restore nothing'; then
  ok "the comparison fails closed: no record and no replayable record both stop before discarding"
else
  bad "the comparison fails closed: no record and no replayable record both stop before discarding"
fi

# Fact 7g — and it names the command it must never use. The same prohibition the prover carries; one fact
# stated at both actors is what keeps the two halves of this engine from contradicting each other.
if printf '%s' "$S_AFTER" | grep -qiE 'never restore with' && printf '%s' "$S_AFTER" | grep -qF 'git checkout -- .'; then
  ok "the restore names the destructive command it must never use"
else
  bad "the restore names the destructive command it must never use"
fi

# Fact 7h — both halves of the bracketing say they are unconditional. Made conditional on something having
# been proven, the whole mechanism stops catching the case it was built for: an auditor that broke its
# read-only contract on a review where nothing was proposed.
if printf '%s' "$S_AFTER" | grep -qiE 'whether or not|regardless of|even if' \
   && printf '%s' "$S_AFTER" | grep -qiE 'completed|died|proven'; then
  ok "the comparison states it runs whether or not anything was proven"
else
  bad "the comparison states it runs whether or not anything was proven"
fi
if printf '%s' "$S_COPY" | grep -qiE 'every review|including the ones that prove nothing'; then
  ok "the copy states it is taken on every review"
else
  bad "the copy states it is taken on every review"
fi

# Fact 4c — the field is OPTIONAL. Listed as required, every auditor must invent a mutation for every
# finding, and a fabricated proposal becomes a real file change in the prover's hands — while a grep for
# the field's name stays green either way.
if [ -n "$FSCHEMA" ] && ! printf '%s' "$FSCHEMA" | grep -oE "required: \[[^]]*\]" | grep -q 'proposedMutation'; then
  ok "the proposed mutation is optional, not required of every finding"
else
  bad "the proposed mutation is optional, not required of every finding"
fi

# Facts 5d-5g — the prover's procedure, asserted on the prompt body. The stage's SHAPE was guarded above
# (one of it, after the refutation, no fan-out, guarded by a proposal) and not one line of what makes the
# stage safe: every clause below could be dropped or inverted with the suite green.
if [ -n "$PROMPT" ] \
   && printf '%s' "$PROMPT" | grep -qiE 'one at a time' \
   && printf '%s' "$PROMPT" | grep -qiE 'put the file back|before the next|before you move'; then
  ok "the prover is ordered to prove one at a time and put each file back before the next"
else
  bad "the prover is ordered to prove one at a time and put each file back before the next"
fi

# The prohibition is the only guard against a restore that deletes the very work under review — and it is
# the same command the phase's own restore names. One fact, both actors: this is where the two halves of
# the engine were found contradicting each other.
if [ -n "$PROMPT" ] && printf '%s' "$PROMPT" | grep -qF 'git checkout -- .' \
   && printf '%s' "$PROMPT" | grep -qiE 'never restore|would delete|destructive'; then
  ok "the prover is forbidden the restore that discards the work under review"
else
  bad "the prover is forbidden the restore that discards the work under review"
fi

# A guessed outcome is worse than no outcome: it retires a real finding on an invented proof.
if [ -n "$PROMPT" ] && printf '%s' "$PROMPT" | grep -q 'unproven' \
   && printf '%s' "$PROMPT" | grep -qiE 'never guess|do not guess'; then
  ok "an unrunnable proposal is unproven, never a guessed outcome"
else
  bad "an unrunnable proposal is unproven, never a guessed outcome"
fi

# Containment is the workflow's job, not the prompt's. The proposal's path is free text from an agent, and
# the prover is the one agent with write access — a path outside the repository would also be invisible to
# the phase's comparison, which only ever looks inside it.
if [ -n "$PROVE" ] \
   && printf '%s' "$PROVE" | grep -qE 'const proposals = .*inScope' \
   && printf '%s' "$PROVE" | grep -qF "startsWith('/')" \
   && printf '%s' "$PROVE" | grep -qF "'..'" \
   && printf '%s' "$PROVE" | grep -q 'changedFiles'; then
  ok "proposal paths are contained before the prover's prompt is built"
else
  bad "proposal paths are contained before the prover's prompt is built"
fi

# Fact 8 — both report templates carry the verdict, and both branches of it. A slot with only the clean
# branch is the mutation that makes a dirty run unreportable while every other check stays green.
TPL_OK=1
for t in $(grep -n '^\*\*Audited\*\*' "$VP" | cut -d: -f1); do
  BLK="$(sed -n "${t},$((t + 4))p" "$VP" | tr '\n' ' ')"
  printf '%s' "$BLK" | grep -qiE 'left as (it was )?found|working copy unchanged' || TPL_OK=0
  printf '%s' "$BLK" | grep -qiE 'was not|otherwise|restored' || TPL_OK=0
done
[ -n "$(grep -c '^\*\*Audited\*\*' "$VP")" ] && [ "$(grep -c '^\*\*Audited\*\*' "$VP")" = "2" ] || TPL_OK=0
[ "$TPL_OK" = "1" ] \
  && ok "both report templates carry the tree verdict with both of its branches" \
  || bad "both report templates carry the tree verdict with both of its branches"

# Fact 9 — a difference reaches the user as a suspect verdict. Restoring quietly is the failure this
# criterion guards: the copy is clean again, and the audit was written against something else.
CONS="$(awk '/^### Consolidation into verify.md/{f=1;next} (f && /^#+ /){exit} f' "$VP" | tr '\n' ' ')"
# From the file, not from the flattened section: the bullet is a run of LINES, and $CONS has had its
# newlines squeezed out for the section-wide checks above.
CONS_WC="$(awk '/^### Consolidation into verify.md/{c=1;next} (c && /^#+ /){exit} c' "$VP" \
  | awk '/^- \*\*The working copy differs/{f=1;print;next} f && /^- /{exit} f' | tr '\n' ' ')"
if [ -n "$CONS_WC" ] \
   && printf '%s' "$CONS_WC" | grep -qiE 'restore|record' \
   && printf '%s' "$CONS_WC" | grep -qiE 'verdict \*\*suspect\*\*|verdict suspect' \
   && printf '%s' "$CONS_WC" | grep -qiE 'user decides'; then
  ok "a changed working copy is consolidated as a suspect verdict for the user to decide"
else
  bad "a changed working copy is consolidated as a suspect verdict for the user to decide"
fi

# Fact 10 — the template ships no copy of the rule. It carries project data only; a copy there would be
# a second home nothing keeps in step.
# Precondition, or the check is free: with the rule written nowhere, "the template does not carry it"
# passes on an empty repository and proves nothing.
if [ "$RULE_HOMES" -ge 1 ] 2>/dev/null && ! grep -rqie 'never modifies what it audits' template/ 2>/dev/null; then
  ok "the template ships no copy of the rule"
else
  bad "the template ships no copy of the rule"
fi

echo ""
echo "Result: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
