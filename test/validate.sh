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

echo ""
echo "Result: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
