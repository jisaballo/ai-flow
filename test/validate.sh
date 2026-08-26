#!/bin/bash
# Conformance harness for T-001 — layered project model (project.yml).
# Generated in the Conform phase from understand.md Verifiable Criteria.
# Dependency-free (grep-based) so it runs on any device; optional YAML lint if python3+pyyaml present.
# Exit 0 only when every section is green.

set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Git's global configuration is sandboxed for the whole run, and this is a guard rather than tidiness.
# The installer this suite exercises writes `core.hooksPath` with `git config --global`; a sandbox that
# only redirects HOME does not contain that, because git writes its global config to
# $XDG_CONFIG_HOME/git/config when that file exists. On a developer who sets XDG_CONFIG_HOME, running
# this suite rewrote their real global hook path. Both variables are set here, at the top, so no call
# site can be added later that escapes it.
GITSANDBOX="$(mktemp -d)"
mkdir -p "$GITSANDBOX/git"
: > "$GITSANDBOX/gitconfig"
export GIT_CONFIG_GLOBAL="$GITSANDBOX/gitconfig"
export XDG_CONFIG_HOME="$GITSANDBOX"
trap 'rm -rf "$GITSANDBOX"' EXIT

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
# The map is the one protocol a reader is sent to rather than one a phase command reads, so its delivery
# is asserted on the run itself and not inferred from the declared set agreeing with the tree: those two
# can agree perfectly about a file the installer never writes.
test -f "$TH/.claude/ai-flow/protocols/lifecycle.md" && ok "update delivers the lifecycle map centrally" || bad "update did not deliver the lifecycle map centrally"
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

  # --- the declaration, not the shape found anywhere in the document ------
  # The sheet is a prose document: it carries decisions and a resume block, and a task that discusses
  # its own phases reproduces the field's syntax as a matter of course. Scanning the whole text reads
  # the mention and raises the rail over a task nobody is understanding.
  PDECL="$T11/pdecl"; mkproj "$PDECL" main
  mkdir -p "$PDECL/.ai-flow/artifacts/prose"
  printf '# Task state\n\nbranch: main\nphase: **EXECUTE**\n\n## Decisions\n\n- the precondition passed: the sheet declared phase: **UNDERSTAND** at the time\n' \
    > "$PDECL/.ai-flow/artifacts/prose/state.md"
  out="$(wguard "$PDECL" "$PDECL/app.txt")"; rc=$?
  [ "$rc" = 0 ] && ok "prose that mentions the phase field is not the declaration" \
                || bad "prose that mentions the phase field is not the declaration (exit $rc)"

  # The arm that separates "the first declaration decides" from "any line that starts with the field":
  # a quoted example at margin zero survives an anchored pattern and would still raise the rail.
  printf '# Task state\n\nbranch: main\nphase: **EXECUTE**\n\n## Decisions\n\n```\nphase: **UNDERSTAND**\n```\n' \
    > "$PDECL/.ai-flow/artifacts/prose/state.md"
  out="$(wguard "$PDECL" "$PDECL/app.txt")"; rc=$?
  [ "$rc" = 0 ] && ok "a declaration quoted below the first one is not read" \
                || bad "a declaration quoted below the first one is not read (exit $rc)"

  # The accepted form carries its colon, exactly as the branch field does. Asserted because the
  # narrowing is silent: without this, the form nothing documents keeps working by accident.
  printf '# Task state\n\nbranch: main\nphase **UNDERSTAND**\n' > "$PDECL/.ai-flow/artifacts/prose/state.md"
  out="$(wguard "$PDECL" "$PDECL/app.txt")"; rc=$?
  [ "$rc" = 0 ] && ok "a phase written without its colon is not a declaration" \
                || bad "a phase written without its colon is not a declaration (exit $rc)"

  # --- the file judged is the one the session names ------------------------
  # Every other path in the guard is resolved against the working directory the payload declares; the
  # written path was resolved against the guard's own. From a foreign directory a relative path lands
  # outside the project and the write is waved through; from a subdirectory a ledger write is blocked
  # and the message names a file that does not exist.
  PREL="$T11/prel"; mkproj "$PREL" main
  mkdir -p "$PREL/.ai-flow/artifacts/rel" "$PREL/sub" "$T11/foreign"
  printf 'branch: main\nphase: **UNDERSTAND**\n' > "$PREL/.ai-flow/artifacts/rel/state.md"
  out="$( cd "$T11/foreign" && wguard "$PREL" "app.txt" )"; rc=$?
  [ "$rc" = 2 ] && ok "a relative code write is judged against the session's directory" \
                || bad "a relative code write is judged against the session's directory (exit $rc)"
  case "$out" in
    *"'app.txt'"*) ok "the block names the path the session would have written" ;;
    *) bad "the block names the path the session would have written" ;;
  esac
  out="$( cd "$PREL/sub" && wguard "$PREL" ".ai-flow/artifacts/rel/notes.md" )"; rc=$?
  [ "$rc" = 0 ] && ok "a relative ledger write is allowed from a foreign working directory" \
                || bad "a relative ledger write is allowed from a foreign working directory (exit $rc)"

  # --- the protective direction of "the first declaration wins" -----------
  # Three arms above prove the rail LIFTS where it used to block. This one proves it still blocks, and it
  # is the arm that separates "the first declaration decides" from "the declaration decides if it is the
  # only one": a reader keyed on uniqueness passes every other assertion in this file, because every
  # blocking fixture declares exactly one phase — and then goes silent on the ordinary shape of a real
  # sheet, a task under investigation whose own decisions reproduce the field's syntax. That is this
  # task's defect inverted, a leak where the original was a false block.
  printf '# Task state\n\nbranch: main\nphase: **UNDERSTAND**\n\n## Decisions\n\n- the phase: **EXECUTE** line is what the close will write\n\n```\nphase: **EXECUTE**\n```\n' \
    > "$PDECL/.ai-flow/artifacts/prose/state.md"
  out="$(wguard "$PDECL" "$PDECL/app.txt")"; rc=$?
  [ "$rc" = 2 ] && ok "a first declaration of UNDERSTAND still raises the rail past later declarations" \
                || bad "a first declaration of UNDERSTAND still raises the rail past later declarations (exit $rc)"
  case "$out" in
    *"artifacts/prose/state.md"*) ok "the rail names the sheet it read, not the line it matched" ;;
    *) bad "the rail names the sheet it read, not the line it matched" ;;
  esac

  # --- what the accepted form does and does not require --------------------
  # The rule says the label and its colon are load-bearing and the asterisks and case are house style.
  # Both directions asserted, because both were unpinned: the pattern's tolerance could be narrowed and
  # the prose's claim widened, each with the suite green.
  printf '# Task state\n\nbranch: main\nphase: understand\n' > "$PDECL/.ai-flow/artifacts/prose/state.md"
  out="$(wguard "$PDECL" "$PDECL/app.txt")"; rc=$?
  [ "$rc" = 2 ] && ok "the case of the phase name is not load-bearing" \
                || bad "the case of the phase name is not load-bearing (exit $rc)"
  printf '# Task state\n\nbranch: main\nphase: UNDERSTAND\n' > "$PDECL/.ai-flow/artifacts/prose/state.md"
  out="$(wguard "$PDECL" "$PDECL/app.txt")"; rc=$?
  [ "$rc" = 2 ] && ok "the emphasis around the phase name is not load-bearing" \
                || bad "the emphasis around the phase name is not load-bearing (exit $rc)"

  # The Spanish legacy label sat inside the alternation this task rewrote and no fixture had ever
  # written it, in this diff or before it — the protocol now advertises it, so it is exercised.
  PES="$T11/pes"; mkproj "$PES" main
  mkdir -p "$PES/.ai-flow"
  printf 'Fase actual: **UNDERSTAND**\n' > "$PES/.ai-flow/STATE.md"
  out="$(wguard "$PES" "$PES/app.txt")"; rc=$?
  [ "$rc" = 2 ] && ok "the Spanish legacy label declares a phase like the other two" \
                || bad "the Spanish legacy label declares a phase like the other two (exit $rc)"

  # A path the guard cannot resolve is not a repo file it can judge. `resolve()` raises on a symlink
  # loop, which `relative_to`'s ValueError never covered: uncaught, an ordinary write became a traceback
  # with the rail down. Exit 0 is the answer; exit 1 is the defect.
  PLOOP="$T11/ploop"; mkproj "$PLOOP" main
  mkdir -p "$PLOOP/.ai-flow/artifacts/loop"
  printf 'branch: main\nphase: **UNDERSTAND**\n' > "$PLOOP/.ai-flow/artifacts/loop/state.md"
  ln -s b "$PLOOP/a" 2>/dev/null; ln -s a "$PLOOP/b" 2>/dev/null
  out="$(wguard "$PLOOP" "$PLOOP/a/x.py")"; rc=$?
  if [ "$rc" = 0 ]; then
    ok "an unresolvable path answers like any file the guard cannot judge"
  else
    bad "an unresolvable path answers like any file the guard cannot judge (exit $rc)"
  fi
  case "$out" in
    *Traceback*) bad "the guard spills no traceback on an unresolvable path" ;;
    *) ok "the guard spills no traceback on an unresolvable path" ;;
  esac

  # --- a payload whose fields are not the shape the guard expects ----------
  # The guard reads three fields and assumed the type of every one: `tool_input`, the `file_path`
  # inside it, and `cwd`. Each assumption was a traceback with the rail down — a non-blocking exit, so
  # the write it was meant to judge went through anyway, on every Edit and Write. Exit 0 is the answer
  # the file already gives everywhere it cannot judge: a field it cannot read is a write it cannot
  # judge. The helper below exists because the well-formed one above cannot express a malformed payload.
  wraw() {  # $1 = raw payload -> prints output, returns the hook's exit code
    printf '%s' "$1" | python3 "$HK/understand-write-guard.py" 2>&1
  }
  malformed() {  # $1 = label, $2 = raw payload -> asserts the pair: waved through, and nothing said
    out="$(wraw "$2")"; rc=$?
    # Silence, not merely the absence of a crash: a guard that stands aside with a diagnostic is chatter
    # on every Edit and Write, which is the noise the silent stand-aside was chosen over in the first
    # place. A traceback is named separately in the failure label so a crash still reads as a crash.
    if [ "$rc" = 0 ] && [ -z "$out" ]; then
      ok "$1"
    else
      case "$out" in
        *Traceback*) bad "$1 (exit $rc, traceback)" ;;
        *)           bad "$1 (exit $rc, said: $out)" ;;
      esac
    fi
  }

  PBAD="$T11/pbad"; mkproj "$PBAD" main
  mkdir -p "$PBAD/.ai-flow/artifacts/bad"
  printf 'branch: main\nphase: **UNDERSTAND**\n' > "$PBAD/.ai-flow/artifacts/bad/state.md"

  # The oldest arm of the promise at the top of that function, and the one nothing had ever sent: every
  # fixture in this file was a JSON object, so the check could be deleted and the suite would not notice.
  malformed "a top-level payload that is not an object is waved through without a traceback" \
    '["x"]'
  malformed "a tool_input that is not an object is waved through without a traceback" \
    "{\"cwd\":\"$PBAD\",\"tool_input\":\"oops\"}"
  malformed "a cwd that is not a string is waved through without a traceback" \
    "{\"cwd\":123,\"tool_input\":{\"file_path\":\"$PBAD/app.txt\"}}"
  malformed "a file_path that is not a string is waved through without a traceback" \
    "{\"cwd\":\"$PBAD\",\"tool_input\":{\"file_path\":7}}"
  # The other half of the same test, fused into one condition and only half asserted. Dropping it is not
  # a traceback but a block naming nothing: an empty path resolves to the project root, whose relative
  # form has no first part to compare against the ledger directory.
  malformed "an empty file_path is waved through and blocks nothing" \
    "{\"cwd\":\"$PBAD\",\"tool_input\":{\"file_path\":\"\"}}"

  # The other arm of the directory check, and the one that keeps the rail alive. Nothing pinned it —
  # every fixture in this file declares a directory — so the check could be widened to stand aside on a
  # field that is merely absent, and the rail would go silent for that whole shape with the suite green.
  out="$( cd "$PBAD" && wraw "{\"tool_input\":{\"file_path\":\"app.txt\"}}" )"; rc=$?
  [ "$rc" = 2 ] && ok "a payload declaring no directory is judged against the one the hook runs in" \
                || bad "a payload declaring no directory is judged against the one the hook runs in (exit $rc)"

  # The control, and it sits in the same project as the three above on purpose. Without it all three
  # are satisfied by a guard that exits 0 unconditionally, and their verdict would be borrowed from a
  # section elsewhere in this file — which is no verdict at all. Green before the fix by design: what
  # establishes it is the mutation that makes the guard wave everything through, not a red baseline.
  out="$(wguard "$PBAD" "$PBAD/app.txt")"; rc=$?
  [ "$rc" = 2 ] && ok "the same project still blocks a well-formed code write" \
                || bad "the same project still blocks a well-formed code write (exit $rc)"
  # The contract promises the block AND the naming over this same project. Asserting the naming only
  # against a fixture elsewhere in this file is the borrowed verdict the paragraph above rejects.
  case "$out" in
    *"artifacts/bad/state.md"*) ok "and that block names the sheet it read, in this same fixture" ;;
    *) bad "and that block names the sheet it read, in this same fixture" ;;
  esac
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
# A state file a reader would recognise as a real ledger, carrying the one thing the invariant forbids:
# a closed-epic narrative outside the sanctioned sections. The previous fixture was the bare string the
# retired phrase list happened to match, so the five rows below could keep passing while proving nothing
# about detection — two of them expect exit 0 and would have passed on a file that triggers nothing.
mkviolstate() {  # $1 = the project's .ai-flow directory
  {
    printf '# Session State\n\n## Workstreams\n\n'
    printf '| Workstream | Checkout | Task | Epic | Areas | Tool | Opened |\n'
    printf '|---|---|---|---|---|---|---|\n'
    printf '| coordinator | . | T-100 | E-009 | auth | - | 2026-08-01 |\n\n'
    printf '## Notes\n\n'
    printf '**Epic E-007 (payments overhaul) CLOSED 2026-07-30.** Sealed decisions: `archive/E-007-payments.md`.\n\n'
    printf '## Quick Tasks Completed\n\n| Date | Description | Commit |\n|------|-------------|--------|\n'
  } > "$1/STATE.md"
}
P9="$T11/p9"; mkproj "$P9" main
mkdir -p "$P9/.ai-flow"
mkviolstate "$P9/.ai-flow"
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
mkviolstate "$NG/.ai-flow"
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
( cd "$WE" && HOME="$TH11" bash "$HK/drift-check.sh" >/dev/null 2>&1 <<<'{}' ); rc=$?
[ "$rc" = 0 ] && ok "drift guard compares against the working copy's HEAD" \
              || bad "drift guard compares against the working copy's HEAD (exit $rc)"
printf 'v3\n' > "$WE/global/hooks/x.sh"      # uncommitted engine change in the worktree
printf 'v9\n' > "$TH11/.claude/hooks/x.sh"   # installed matches nothing
( cd "$WE" && HOME="$TH11" bash "$HK/drift-check.sh" >/dev/null 2>&1 <<<'{}' ); rc=$?
[ "$rc" = 0 ] && ok "drift guard is quiet on the working copy's WIP" \
              || bad "drift guard is quiet on the working copy's WIP (exit $rc)"

# --- gaps closed after the multi-agent review --------------------------------
# the guardian must survive a subdirectory cwd (git answers --git-dir absolute, --git-common-dir relative)
P10="$T11/p10"; mkproj "$P10" main
mkdir -p "$P10/.ai-flow" "$P10/sub"
mkviolstate "$P10/.ai-flow"
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
( cd "$WE" && HOME="$TH11" bash "$HK/drift-check.sh" >/dev/null 2>&1 <<<'{}' ); rc=$?
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

# git stands in for the pattern engine the product uses: same gitignore specification, no package
# dependency in a harness that is otherwise pure shell and git. Anchoring and negation are git's to
# resolve — a harness that re-implements either gets a different answer than the product does.
#
# THREE answers, never two. check-ignore reports a verdict with 0 (this path is selected) and 1 (it is
# not), and a failure with anything above. Collapsing the failure into "not selected" makes every
# verdict built on it vacuous: a git that cannot run then reads as "the ledger stays behind", which is
# the very answer the guard exists to earn rather than assume.
#
# The evaluator must be a repository with NO .gitignore of its own. core.excludesFile is ADDITIVE, so
# evaluating inside a checkout that already ignores .ai-flow/ reports every path under it as ignored no
# matter what the pattern file says, and the file becomes untestable. Isolation is the check.
#
# The caller establishes that the pattern file exists: a missing one is not a probe failure to git,
# which reads it as an empty set of patterns and answers "not selected" for everything.
wti_probe() {  # $1 = evaluator repo, $2 = pattern file, $3 = path -> 0 selected, 1 not, 2 unanswerable
  # The pattern set is asserted readable and non-empty before anything is concluded from it — the same
  # law the path list below carries, applied to the other input. git does not report an unreadable or
  # empty pattern file as a failure: it reads it as an empty set of patterns and answers "not selected"
  # for every path, so "the ledger stays behind" comes back established from a file nobody read.
  # Existence is not readability, and neither is content.
  { [ -r "$2" ] && [ -s "$2" ]; } || return 2
  ( cd "$1" 2>/dev/null || exit 2
    $GIT -c core.excludesFile="$2" check-ignore -q --no-index "$3" ) >/dev/null 2>&1
  case $? in 0) return 0 ;; 1) return 1 ;; *) return 2 ;; esac
}

# The classification is a function because an assertion can execute a function and cannot execute a
# shape inlined in a verdict. Grepping the harness for the message a verdict would print proves the
# message exists, never that any path reaches it — and the arm that counts the probe's third answer is
# exactly such a path. `want` is which answer the caller expects for these paths: `in` for the project
# data that must travel, `out` for the ledger that must not.
wti_classify() {  # $1 = evaluator, $2 = pattern file, $3 = in|out, $4.. = paths
                  # -> echoes "clean" | "unanswered N" | "wrong N"; diagnostics to stderr
  local ev="$1" pf="$2" want="$3"; shift 3
  local wrong=0 un=0 p rc
  for p in "$@"; do
    wti_probe "$ev" "$pf" "$p"; rc=$?
    if [ "$rc" = 2 ]; then
      un=$((un+1)); echo "         unanswered: $p" >&2
    elif [ "$want" = in ] && [ "$rc" != 0 ]; then
      wrong=$((wrong+1)); echo "         not selected: $p" >&2
    elif [ "$want" = out ] && [ "$rc" = 0 ]; then
      wrong=$((wrong+1)); echo "         ledger would travel: $p" >&2
    fi
  done
  if   [ "$un" != 0 ];    then printf 'unanswered %s\n' "$un"
  elif [ "$wrong" != 0 ]; then printf 'wrong %s\n' "$wrong"
  else printf 'clean\n'; fi
}

# Does this pattern file select any path git already tracks? Asked of the PATHS, never of the patterns:
# a gitignore pattern is not a pathspec, and reading it as one silently changes the question. `/x` is a
# legal anchored pattern and an illegal pathspec, `!x` names nothing at all — both answer empty, and an
# empty answer read as a clean verdict is how a real mistake passes. Handing the file to git instead
# also settles negation without a rule of our own: a negation only ever subtracts from the travel set,
# so it can never be the reason a tracked path is selected.
#
# The path list is asserted non-empty before anything is concluded from it — a guard whose extractor
# returned nothing otherwise passes every check it makes.
wti_tracked_leak() {  # $1 = evaluator repo, $2 = pattern file -> 0 a tracked path is selected, 1 none, 2 unanswerable
  local list
  list="$( $GIT -C "$ROOT" ls-files 2>/dev/null )" || return 2
  [ -n "$list" ] || return 2
  printf '%s\n' "$list" \
    | ( cd "$1" 2>/dev/null || exit 2
        $GIT -c core.excludesFile="$2" check-ignore -q --no-index --stdin ) >/dev/null 2>&1
  case $? in 0) return 0 ;; 1) return 1 ;; *) return 2 ;; esac
}

if [ -r "$WTI" ] && [ -s "$WTI" ]; then
  EV="$T12/eval"; mkdir -p "$EV"; ( cd "$EV" && $GIT init -q . >/dev/null 2>&1 )

  # Each verdict acts on the probe's third answer itself rather than leaning on its neighbour going
  # red at the same time. The classification is executed through wti_classify, so an assertion can
  # reach the arm that counts that answer instead of grepping for the message it would print.
  r12="$(wti_classify "$EV" "$WTI" in .ai-flow/project.yml .ai-flow/product.md \
         .ai-flow/steering/payments.md \
         .ai-flow/artifacts/current-task/plan.md)"
  case "$r12" in
    clean)       ok  "worktreeinclude selects the project data" ;;
    unanswered*) bad "worktreeinclude selects the project data (the probe could not answer for ${r12#unanswered } of 4 paths)" ;;
    *)           bad "worktreeinclude selects the project data (${r12#wrong } of 4 missing)" ;;
  esac

  r12l="$(wti_classify "$EV" "$WTI" out .ai-flow/BACKLOG.md .ai-flow/STATE.md \
          .ai-flow/decisions-global.md .ai-flow/archive/CHANGELOG.md)"
  case "$r12l" in
    clean)       ok  "worktreeinclude leaves the ledger behind" ;;
    unanswered*) bad "worktreeinclude leaves the ledger behind (the probe could not answer for ${r12l#unanswered } of 4 paths)" ;;
    *)           bad "worktreeinclude leaves the ledger behind (${r12l#wrong } ledger paths selected)" ;;
  esac

  # A pattern that names something git already tracks is inert: the product only ever considers
  # untracked-and-ignored paths as candidates to copy, so the author's intent silently does nothing.
  wti_tracked_leak "$EV" "$WTI"
  case $? in
    1) ok "worktreeinclude names only ignored paths" ;;
    0) bad "worktreeinclude names only ignored paths (a versioned path is selected)"
       # The diagnostic answers the same three ways the verdict does: a path the probe could not
       # judge is not a path that came back clean, and printing nothing for it would name the
       # offenders as though the list were complete.
       $GIT -C "$ROOT" ls-files | while IFS= read -r f; do
         wti_probe "$EV" "$WTI" "$f"
         case $? in
           0) echo "         names a tracked file: $f" ;;
           2) echo "         unanswered while naming offenders: $f" ;;
         esac
       done ;;
    *) bad "worktreeinclude names only ignored paths (the probe could not answer)" ;;
  esac
else
  bad "worktreeinclude selects the project data (.worktreeinclude missing, unreadable or empty)"
  bad "worktreeinclude leaves the ledger behind (.worktreeinclude missing, unreadable or empty)"
  bad "worktreeinclude names only ignored paths (.worktreeinclude missing, unreadable or empty)"
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

# One fact with two halves, and each copy judged on both of them: the manual names the task's own
# sheet, AND it no longer routes step progress to the roster. The shipped copy gets the negative half
# from the sweep above. The live twin was getting the positive half alone — so a manual that names the
# new path while still carrying the old line passed, and the copy that governs real sessions is the one
# no tool can repair: the installer writes it only when absent and the drift guard excludes it as
# user-owned (global/hooks/drift-check.sh). Half a fact about that file is the half that matters least.
manstate() {  # $1 = a manual -> 0 when it routes step progress to the task's own sheet and nowhere else
  grep -q 'artifacts/T-XXX/state.md' "$1" \
    && ! grep -q 'Update STATE.md with step progress' "$1"
}
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
  pair 6 'prune' 'own|owns' "the ceremony prunes the new checkout to the task it owns"
  pair 6 'BACKLOG|ledger' 'never copied|not copied|stays with|read-only' "the ceremony never copies the ledger into a worktree"
  pair 6 'copies' 'originals' "the pruning step names what it deletes"
else
  bad "the protocol defines the ceremony that opens a workstream"
  bad "a single open front has nothing to weigh and nothing to create (no section)"
  bad "a collision stops the opening until it is acknowledged in the sheet (no section)"
  bad "a front with no declaration reads as cannot-compare, not as clear (no section)"
  bad "opening stops on an unpublished default branch (no section)"
  bad "the ceremony prunes the new checkout to the task it owns (no section)"
  bad "the ceremony never copies the ledger into a worktree (no section)"
  bad "the pruning step names what it deletes (no section)"
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

echo "== C14: the audit judges the branch, not the working tree =="
VP="global/protocols/verify.md"
VS="global/skills/verify/SKILL.md"
VW="global/workflows/verify-review.js"
BRAKE="global/hooks/diff-size-guard.py"

# The two steps this block reaches into, resolved by CONTENT. Moving a step renumbers every step after
# it, and an assertion that dies to renumbering is testing the numbering, not the fact: what each check
# below asserts is a property of the step that carries it, wherever that step sits. Same shape as the
# WRITE-step resolution further down, and the reason it exists.
vsn() { grep -nE "^[0-9]+\. \*\*$1" "$VS" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/'; }
NG14="$(vsn 'Gather the task diff')"
NA14="$(vsn 'Criterion audit')"

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

S5="$([ -n "$NG14" ] && nstep "$VS" "$NG14")"
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
MBB="$([ -n "$NG14" ] && sbullet "$VS" "$NG14" 'Capture it once')"
if printf '%s' "$MBB" | grep -qF 'MB="$(git merge-base <base> HEAD)"' \
   && ! printf '%s' "$MBB" | grep -qE 'merge-base[^`]*\.\.'; then
  ok "the skill captures the merge-base itself, with no range operator narrowing it"
else
  bad "the skill captures the merge-base itself, with no range operator narrowing it"
fi
DTB="$([ -n "$NG14" ] && sbullet "$VS" "$NG14" 'Otherwise')"
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

# The protocol states the same resolution in prose, and nothing watched it. The skill's copy above is
# derived from the brake; this paragraph was the one statement of the three that could drift in silence.
# It keeps stating the rule in full rather than being reduced to a pointer, because the protocol is what
# a run follows when the skill is not installed -- so the fix is a watcher, not a deletion.
#
# Cut TIGHT, from the bolded opening to the blank line that closes it. The degradation sentence later in
# the same section also carries `main` and `master`, so a section-wide grep is satisfied by the wrong
# paragraph -- the same hazard the DEF extractor above exists for.
BP="$(awk '/^\*\*The base is resolved/{f=1} f{print} f && /^$/{exit}' "$VP" | tr '\n' ' ')"
[ -n "$BP" ] \
  && ok "the base paragraph extracted" \
  || bad "the base paragraph extracted (was the opening bold renamed?)"

# When the paragraph does not extract, the three rows below have not read their facts -- and reporting
# those facts as ABSENT sends a reader hunting for prose that is still on disk. One renaming is one
# report: each row names the extraction as its reason and makes no claim about a fact it never saw.
NOBP=" (not judged: the paragraph did not extract)"

# Derived from the brake's own source, exactly as the skill's row is: change the hook's candidate list
# and this row fails. A list restated beside the original drifts; a list read out of it cannot.
missp=""
for c in $cands; do printf '%s' "$BP" | grep -q "\`$c\`" || missp="$missp $c"; done
if [ -z "$BP" ]; then
  bad "the verify protocol's base paragraph names every candidate the diff brake actually tries$NOBP"
elif [ -n "$cands" ] && [ -z "$missp" ]; then
  ok "the verify protocol's base paragraph names every candidate the diff brake actually tries"
else
  bad "the verify protocol's base paragraph names every candidate the diff brake actually tries (missing:$missp)"
fi

# Which candidate WINS is the fact, and presence greps are satisfied in any order.
bo1="$(off "$BP" 'origin/HEAD')"; bo2="$(off "$BP" '`main`')"; bo3="$(off "$BP" '`master`')"
if [ -z "$BP" ]; then
  bad "the protocol states the base precedence in the brake's order$NOBP"
elif [ -n "$bo1" ] && [ -n "$bo2" ] && [ -n "$bo3" ] && [ "$bo1" -lt "$bo2" ] && [ "$bo2" -lt "$bo3" ]; then
  ok "the protocol states the base precedence in the brake's order"
else
  bad "the protocol states the base precedence in the brake's order (offsets: $bo1/$bo2/$bo3)"
fi

if [ -z "$BP" ]; then
  bad "the protocol's base resolution cites the diff brake it copies$NOBP"
elif printf '%s' "$BP" | grep -q 'diff-size-guard'; then
  ok "the protocol's base resolution cites the diff brake it copies"
else
  bad "the protocol's base resolution cites the diff brake it copies"
fi

CF="$([ -n "$NG14" ] && sbullet "$VS" "$NG14" 'changedFiles')"
if printf '%s' "$CF" | grep -qiE 'base-scoped|that same' \
   && printf '%s' "$CF" | grep -qi 'untracked' \
   && printf '%s' "$CF" | grep -q 'source_dirs'; then
  ok "changedFiles derives from the base-scoped diff plus untracked, scoped to source_dirs"
else
  bad "changedFiles derives from the base-scoped diff plus untracked, scoped to source_dirs"
fi

FB="$([ -n "$NG14" ] && sbullet "$VS" "$NG14" 'no base')"
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

# The skill's own reverse audit names where its scope comes from — and that step has already run.
# This assertion used to demand the opposite: it required the bullet to point FORWARD at the gather,
# so it was green precisely because the consumer read a diff nobody had gathered yet. Kept as an order
# over step INDEXES, which is a different mutation from the byte-offset order asserted later: a step
# renumbered without being moved kills one and not the other.
RA="$([ -n "$NA14" ] && sbullet "$VS" "$NA14" 'Reverse audit')"
if printf '%s' "$RA" | grep -qi 'task diff' \
   && [ -n "$NG14" ] && [ -n "$NA14" ] && [ "$NG14" -lt "$NA14" ]; then
  ok "the skill's reverse audit reads a task diff an earlier step already gathered"
else
  bad "the skill's reverse audit reads a task diff an earlier step already gathered"
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
  # The seven moves, each identified by its own lead and read in sequence. The ORDER is the fact this
  # guards: a collection written after the merge changes the sequence while every presence grep in
  # this section stays green. Distribution sits between the record and the tail: earlier it could block
  # the ledger, later it would trail a tail that runs only on a front's last task.
  seq=""
  for i in 1 2 3 4 5 6 7; do
    case "$(clohead "$i" | tr 'A-Z' 'a-z')" in
      *valid*)               seq="$seq V" ;;
      *collect*|*harvest*)   seq="$seq C" ;;
      *merge*)               seq="$seq M" ;;
      *record*|*ledger*)     seq="$seq L" ;;
      *distribut*|*effect*)  seq="$seq X" ;;
      *dismantl*|*worktree*) seq="$seq D" ;;
      *roster*|*row*)        seq="$seq R" ;;
      *)                     seq="$seq ?" ;;
    esac
  done
  [ "$seq" = " V C M L X D R" ] \
    && ok "the protocol defines the ceremony that closes a front" \
    || bad "the protocol defines the ceremony that closes a front (moves unnamed or out of order:$seq)"

  # One pattern, not two: 'outside version control' and a bare 'branch' both occur elsewhere in this
  # move, so an either-or pair passed with the fact itself deleted. The fact is the relation.
  printf '%s' "$(clomove 2)" \
    | grep -qiE '(does not|do not|never) (travel|reach)[^.]*branch|branch carries (none|nothing)|merge carries none' \
    && ok "the papers are collected before the merge, and never travel with the branch" \
    || bad "the papers are collected before the merge, and never travel with the branch"
  # Was an either-or pair, and a rationale clause added to this move using the word 'stops' made it
  # passable with the stop rule deleted — a working guard disabled without its line being touched. Both
  # halves occur elsewhere in the move on their own, so what is asserted is the RELATION: the absence of
  # that path is what halts the ceremony.
  printf '%s' "$(clomove 2)" \
    | grep -qiE 'listing does not name that path[^.]*stop|does not name that path, stop' \
    && ok "an unlocatable front checkout stops the closing" \
    || bad "an unlocatable front checkout stops the closing"
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
  if printf '%s' "$(clomove 6)" | grep -qiE 'no next task|has no next|last task' \
     && printf '%s' "$(clomove 7)" | grep -qiE 'no next task|has no next|last task'; then
    ok "a front with a next task keeps its checkout and its roster row"
  else
    bad "a front with a next task keeps its checkout and its roster row"
  fi

  mpair 6 'never before' 'destroy' \
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
  # take down. Without this the ceremony reads as a seven-move ritual for every single archive.
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
# The NUMBER, not just a reference to the ceremony. Read as an alternation it was blind to the fact it
# claims: both citations name "move N of `## Closing a Workstream`", so a half-renumber left pointing at
# the wrong move still matched the section title and read green.
if printf '%s' "$ARC7" | grep -qiE 'no next task' \
   && printf '%s' "$ARC7" | grep -qiE 'move 7' \
   && printf '%s' "$ARC7" | grep -qiE 'Closing a Workstream' \
   && ! printf '%s' "$ARC7" | grep -qiE '^7\. (Remove|Delete) ' \
   && printf '%s' "$EPI6" | grep -qiE 'move 7' \
   && printf '%s' "$EPI6" | grep -qiE 'only remover|Closing a Workstream' \
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

# The post-commit route, in the repo copy and in the live twin that no drift check covers. The other
# half of this pair — the phase step naming the closing ceremony — left the manual with the phase
# descriptions and is asserted on the map instead, by the archive row of the paper-trail block. Narrowing
# this check is therefore not a coverage loss but a relocation: the fact moved from a file nothing
# distributes to one the installer delivers and the drift guard compares.
# What stays here is the rule the operator actually reads after committing; routing the phase step alone
# would leave that rule pointing past moves 1-3 of the ceremony.
POST_ROUTE_RE='immediately\*\* run the closing ceremony'
manroutes() { grep -qE "$POST_ROUTE_RE" "$1"; }
twin3="$HOME/.claude/CLAUDE.md"
if manroutes global/CLAUDE.md; then
  ok "the shipped manual routes the post-commit rule to the closing ceremony"
  if [ -f "$twin3" ]; then
    manroutes "$twin3" \
      && ok "the live twin routes the post-commit rule to the closing ceremony" \
      || bad "the live twin routes the post-commit rule to the closing ceremony (stale — port the edit by hand, nothing distributes ~/.claude/CLAUDE.md)"
  else
    echo "  [skip] live CLAUDE.md twin absent — the shipped one routes the post-commit rule"
  fi
else
  bad "the shipped manual routes the post-commit rule to the closing ceremony"
  bad "the live twin routes the post-commit rule to the closing ceremony (shipped copy is stale)"
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

# Fact 3c — the refutation's reach, in both directions. HIGH is what blocks the archive gate and the
# refutation is what keeps a false one from blocking it; MEDIUM neither blocks nor gets fixed, so a skeptic
# spent on it buys a cleaner list and nothing else. A grep for the surviving level stays green after the
# dropped one is put back, and putting it back is the direction that costs money, so both are asserted.
REFUTE_SET="$(grep -E '^const REFUTE = ' "$VW")"
r3c=""
[ -n "$REFUTE_SET" ] || r3c="$r3c declaration-absent"
printf '%s' "$REFUTE_SET" | grep -q "'high'"   || r3c="$r3c high-missing"
printf '%s' "$REFUTE_SET" | grep -q "'medium'" && r3c="$r3c medium-present"
[ -z "$r3c" ] \
  && ok "the refutation reaches HIGH and nothing else" \
  || bad "the refutation reaches HIGH and nothing else (missing:$r3c)"

# Fact 3d — and what it does not reach is not folded in beside what it cleared. A MEDIUM sitting inside the
# confirmed set reads as though a skeptic had passed it, which is the overclaim this stage exists to remove;
# it arrives in its own set, marked unadjudicated, for the phase to decide.
r3d=""
grep -qE '^const adjudicated = all\.filter\(\(f\) => f\.adjudicated\)' "$VW" || r3d="$r3d no-adjudicated-set"
grep -qE '^const unverified = all\.filter\(\(f\) => !f\.adjudicated\)' "$VW" || r3d="$r3d no-unverified-set"
grep -qE '^const confirmed = adjudicated\.' "$VW" || r3d="$r3d confirmed-not-from-adjudicated"
grep -qE '^  unverified,' "$VW" || r3d="$r3d not-returned"
[ -z "$r3d" ] \
  && ok "what the refutation never read is returned unadjudicated, not beside what it cleared" \
  || bad "what the refutation never read is returned unadjudicated, not beside what it cleared (missing:$r3d)"

# Fact 3e — the phase that consumes the review adjudicates what the review did not. Dropping the skeptic
# from MEDIUM is a saving only while something still decides those findings: left as a list nobody acts on,
# the level yields neither a gate nor a fix and four auditors are paid to fill it. The phase already holds
# the diff and the criteria, so the decision is made where the context already is.
TRIAGE="$(awk '/Triaging the Unadjudicated/{f=1} f' "$VS" | tr '\n' ' ')"
t3e=""
[ -n "$TRIAGE" ] || t3e="$t3e section-absent"
printf '%s' "$TRIAGE" | grep -qiE 'fix now|fix it now'     || t3e="$t3e no-fix-outcome"
printf '%s' "$TRIAGE" | grep -qiE 'icebox|backlog'         || t3e="$t3e no-defer-outcome"
printf '%s' "$TRIAGE" | grep -qiE 'discard|false positive' || t3e="$t3e no-discard-outcome"
[ -z "$t3e" ] \
  && ok "the verify phase triages the unadjudicated findings it is handed" \
  || bad "the verify phase triages the unadjudicated findings it is handed (missing:$t3e)"

# Fact 3f — the prover spends only on what a skeptic has already read. Proving is the most expensive
# adjudication in the run: it applies a change and runs the whole suite, one proposal at a time. A proposal
# carried by a finding nobody adjudicated is that cost spent on a guess, and an unadjudicated finding keeps
# its proposal as data for the triage instead. Asserted on the set the filter reads, because `all` and
# `unverified` would each satisfy a grep for the field's name.
grep -qE '^const proposals = confirmed\.filter' "$VW" \
  && ok "the prover's proposals come only from adjudicated survivors" \
  || bad "the prover's proposals come only from adjudicated survivors"

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
N_COPY="$(grep -nE '^[0-9]+\. \*\*Take the byte-exact copy' "$VS" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/')"

# Fact 7a — the copy is taken before the review is invoked, and it covers what no diff reaches.
# Resolved as its own step. It used to be a bullet of the gather, and was scoped to the bullet for a
# reason that no longer exists: the gather collected untracked files for the diff in that same step, so
# a step-wide grep for 'untracked' stayed green after the copy stopped taking them. The gather is a
# different step now and the copy step contains nothing but the copy, so the step IS the tight scope —
# and the `/untracked/` anchor below is the copy's own destination directory, never the git command.
S_COPY="$([ -n "$N_COPY" ] && vstep "$VS" "$N_COPY")"
if [ -n "$N_COPY" ]; then
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
# The paragraph is the boundary, not a fixed line count: a slot that grew by one sentence pushed the
# verdict out of a five-line window and failed this on where the prose wraps rather than on the fact.
for t in $(grep -n '^\*\*Audited\*\*' "$VP" | cut -d: -f1); do
  BLK="$(awk -v s="$t" 'NR>=s{ if (NR>s && $0 ~ /^[[:space:]]*$/) exit; buf=buf" "$0 } END{print buf}' "$VP")"
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

echo "== C19: putting the work into effect is a move of the close =="
BLG6="global/protocols/backlog.md"
PY19="template/.ai-flow/project.yml"
# The ceremony, bounded at the next section, fence-aware. Re-declared rather than inherited from C15:
# a criterion that reads another's extractor changes verdict when that one is re-scoped.
CLO6="$(awk '/^## Closing a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG6")"
# One numbered move, flattened AND whitespace-squeezed. What a move must say is a property of the move,
# never of where its prose happens to wrap, and never of a neighbouring move's words — a section-wide
# grep here would pass on the record move above it and on the dismantle move below.
dmove() { printf '%s\n' "$CLO6" | awk -v n="$1" '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==n' | tr '\n' ' ' | tr -s ' '; }
D5="$(dmove 5)"

if [ -n "$D5" ]; then
  # Where it runs and what it distributes. Running it from a front repoints the installed engine's
  # source at a checkout the next move deletes, which silences the drift guard for good — so the
  # checkout is half the fact and the trunk is the other half.
  printf '%s' "$D5" | grep -qi 'coordinator' \
    && printf '%s' "$D5" | grep -qiE 'trunk|merged' \
    && ok "the distribution runs in the coordinator, from the merged trunk" \
    || bad "the distribution runs in the coordinator, from the merged trunk"

  # The generic core may name no project's command. Positive scoped to the move, negative over the
  # whole protocol: a project-specific command smuggled into any other section is the same breach.
  if printf '%s' "$D5" | grep -qiE 'project layer|project\.yml' \
     && printf '%s' "$D5" | grep -qi 'commands' \
     && ! grep -qiE 'install\.sh|\./install' "$BLG6"; then
    ok "the distribution move reads the project layer and names no project's command"
  else
    bad "the distribution move reads the project layer and names no project's command"
  fi

  # Silence and a clean result read identically in a report — the rule this engine already carries for an
  # audit that cannot prove what it claims, applied here to a project that
  # declares nothing. Both halves: the condition AND the obligation to say it out loud.
  printf '%s' "$D5" | grep -qiE 'declares (no|none|nothing)|no distribution command|no such command|absent' \
    && printf '%s' "$D5" | grep -qiE 'say so|says so|state[sd]? the no-op|stated no-op|out loud|never silen' \
    && ok "an undeclared distribution command is a stated no-op" \
    || bad "an undeclared distribution command is a stated no-op"

  # A command that reports success without writing anything is the failure this move exists to catch,
  # so ordering the run is not enough: the move must demand the result be shown, and demand it be
  # named unproven when the project has no check.
  # The second half is pinned to words only that branch owns. Accepting a bare 'cannot' let the whole
  # branch be deleted and still pass, on the 'cannot be shown' of the stop sentence two clauses later —
  # a neighbour's word answering for a fact it does not carry.
  printf '%s' "$D5" | grep -qiE 'shows?|prove[sn]?|proof|demonstrat' \
    && printf '%s' "$D5" | grep -qiE 'no check|unproven' \
    && ok "the distribution move proves it took effect, or says it cannot" \
    || bad "the distribution move proves it took effect, or says it cannot"

  # What carries an interrupted distribution. The record is already written by then, so the only thing
  # left saying work remains is the front's row — which is why the move sits before the tail.
  printf '%s' "$D5" | grep -qiE 'stops?|stop there|halt' \
    && printf '%s' "$D5" | grep -qiE 'roster row|row (is )?still|row in place' \
    && ok "an unprovable distribution stops the ceremony with the roster row in place" \
    || bad "an unprovable distribution stops the ceremony with the roster row in place"

  # The condition belongs to the tail and NOT here: a quick task's close and a front's non-final close
  # both distribute. The positive half is load-bearing — a bare negative passes on a deleted sentence.
  if printf '%s' "$D5" | grep -qiE 'every (task )?close|each (task )?close|always' \
     && ! printf '%s' "$D5" | grep -qiE 'no next task|has no next|last task' \
     && printf '%s' "$(dmove 6)" | grep -qiE 'no next task|has no next|last task' \
     && printf '%s' "$(dmove 7)" | grep -qiE 'no next task|has no next|last task'; then
    ok "the distribution move runs at every close, unlike the tail"
  else
    bad "the distribution move runs at every close, unlike the tail"
  fi
else
  bad "the distribution runs in the coordinator, from the merged trunk (no fifth move)"
  bad "the distribution move reads the project layer and names no project's command (no fifth move)"
  bad "an undeclared distribution command is a stated no-op (no fifth move)"
  bad "the distribution move proves it took effect, or says it cannot (no fifth move)"
  bad "an unprovable distribution stops the ceremony with the roster row in place (no fifth move)"
  bad "the distribution move runs at every close, unlike the tail (no fifth move)"
fi

# The declaration point, in the shipped template. Bounded at the first unindented line — a key OR a
# comment: bounding at the next key alone swallows the steering block's comments above it, and then a
# note written anywhere below the map answers for the map. Which also fixes the form of the note: to be
# read here it must sit inside the mapping, indented, where a reader of commands actually meets it.
CMDS6="$(awk '/^commands:/{f=1;next} (f && /^[^[:space:]]/){f=0} f' "$PY19")"
if [ -n "$CMDS6" ]; then
  # Live with a value, every adopting project inherits a command that is not theirs and the close runs
  # it — so "commented out" is the fact, not a formatting preference.
  if printf '%s' "$CMDS6" | grep -qi 'distribute' \
     && printf '%s' "$CMDS6" | grep -qi 'optional' \
     && printf '%s' "$CMDS6" | grep -qiE 'no-op|nothing to distribute' \
     && ! printf '%s' "$CMDS6" | grep -qE '^[[:space:]]*distribute:'; then
    ok "the shipped template documents the distribution command as optional, and declares none"
  else
    bad "the shipped template documents the distribution command as optional, and declares none"
  fi
else
  bad "the shipped template documents the distribution command as optional, and declares none (no commands block)"
fi

# Fix the JOIN, not each half. The move names a key and the template documents one; nothing compared
# them, so the two deliverables of this task were connected by no check at all — a mutation renaming the
# template's key killed only the template-side assertion. The key is READ from the protocol and looked
# for everywhere it must also appear, so renaming it on any side goes red.
KEY6="$(printf '%s' "$D5" | grep -oE 'commands\.[a-z_]+' | head -1 | cut -d. -f2)"
if [ -n "$KEY6" ]; then
  ok "the distribution move names the key it reads, not just the map (commands.$KEY6)"
  # As a KEY, never as a word: both the template's comment and the doc's list the candidate verbs in
  # prose ("publish, deploy, regenerate"), so a bare word match answered from a neighbouring sentence —
  # renaming the key on the protocol side alone stayed green on the word it happened to pick.
  keyed() { printf '%s' "$1" | grep -qE "(^|[[:space:]#])${KEY6}:"; }
  keyed "$CMDS6" \
    && ok "the shipped template documents the same key the move reads" \
    || bad "the shipped template documents the same key the move reads"
  # The doc restates the schema for a human reader — pre-existing, and therefore a second home that can
  # go stale. Pinned to the same key so it cannot.
  keyed "$(awk '/^```yaml/{f=1;next} /^```/{f=0} f' docs/customization.md)" \
    && ok "the schema the docs show carries the same key" \
    || bad "the schema the docs show carries the same key"
else
  bad "the distribution move names the key it reads, not just the map"
  bad "the shipped template documents the same key the move reads (no key named)"
  bad "the schema the docs show carries the same key (no key named)"
fi

# The preamble's move numbers, derived rather than spelled. Reverting them to the pre-insertion pair left
# the whole suite green, so the preamble could call the unconditional move part of the conditional tail.
# The tail is not a literal here: it is whichever moves carry the condition, read from the moves.
CLOI6="$(printf '%s\n' "$CLO6" | awk '/^1\. /{exit} {print}' | tr '\n' ' ' | tr -s ' ')"
TAIL6=""; DIS6=""; MRG6=""
for i in 1 2 3 4 5 6 7; do
  m="$(dmove "$i")"
  printf '%s' "$m" | grep -qiE 'no next task|has no next|last task' && TAIL6="$TAIL6 $i"
  printf '%s' "$m" | grep -qi 'dismantl' && DIS6="$i"
  printf '%s' "$m" | grep -qi 'merge lands' && MRG6="$i"
done
set -- $TAIL6
if [ -n "$CLOI6" ] && [ "$#" -eq 2 ] && [ -n "$DIS6" ] && [ -n "$MRG6" ]; then
  printf '%s' "$CLOI6" | grep -qF "moves $1 and $2" \
    && ok "the preamble names the tail by the moves that actually carry the condition" \
    || bad "the preamble names the tail by the moves that actually carry the condition (moves $1 and $2)"
  # The escape hatch carries three moves, not two: two need no second checkout and one needs no merge,
  # because a task worked in the coordinator has no branch to land. Both numbers stay derived for the
  # reason the comment above gives — a move inserted anywhere renumbers the rest, and a spelled number
  # would then point at whichever move happens to sit there.
  printf '%s' "$CLOI6" | grep -qF "moves 2, $MRG6 and $DIS6" \
    && ok "the single-front escape hatch names the merge and dismantle moves by their real numbers" \
    || bad "the single-front escape hatch names the merge and dismantle moves by their real numbers (moves 2, $MRG6 and $DIS6)"
else
  bad "the preamble names the tail by the moves that actually carry the condition (nothing to compare)"
  bad "the single-front escape hatch names the merge and dismantle moves by their real numbers (nothing to compare)"
fi

# A wider negative for "names no project's command". The old one grepped a single string, so appending
# "For this repo that command is \`npm run deploy\`" to the move read green while contradicting the
# sentence before it. Still a denylist — prose cannot be proven free of commands — but one that costs an
# author real effort to slip past, and the honest limit is stated rather than implied.
if printf '%s' "$D5" | grep -qiE '(^|[^a-z])(npm|yarn|pnpm|make|cargo|pip|docker|gradle|mvn|bash|sh)[[:space:]]|\./|install\.sh'; then
  bad "the move names no concrete command of any project"
else
  ok "the move names no concrete command of any project"
fi

# The installer's own report, in update mode. Functional and sandboxed: a fake HOME and a path that
# must not exist afterwards. Structural greps cannot see a mkdir that runs before the dispatch.
TH19="$(mktemp -d)"; TW19="$(mktemp -d)"
# A trap is global state, and setting one REPLACES what an earlier section installed: this block used to
# drop T12/T13 from the teardown, so two sandboxes leaked on every run, clean or interrupted. Carry the
# live trap's paths, and hand it back below rather than clearing it.
trap 'rm -rf "$TH19" "$TW19" "$T12" "$T13"' EXIT
GHOST19="$TW19/never-written"
OUT19="$( cd "$TW19" && HOME="$TH19" bash "$ROOT/install.sh" update "$GHOST19" </dev/null 2>&1 )" || true
if [ ! -e "$GHOST19" ] && ! printf '%s' "$OUT19" | grep -qF "$GHOST19"; then
  ok "update creates no project target and prints none"
else
  bad "update creates no project target and prints none"
fi
# And it names what it does write, or the line above is satisfied by printing no target at all.
printf '%s' "$OUT19" | grep -qE 'Target:.*\.claude' \
  && ok "update names the toolchain it actually writes" \
  || bad "update names the toolchain it actually writes"
rm -rf "$TH19" "$TW19"
trap 'rm -rf "$T12" "$T13"' EXIT   # handed back to the section that owned it

# The teardown is a fact of this block, not a courtesy: the leak above went unnoticed because nothing
# ever looked. A probe is cheaper than the next reviewer finding it by hand.
{ [ ! -d "$TH19" ] && [ ! -d "$TW19" ] && [ -d "$T12" ]; } \
  && ok "the sandbox is torn down and the live cleanup trap survives this block" \
  || bad "the sandbox is torn down and the live cleanup trap survives this block"

echo "== C20: the remedy for a user-owned file names the hand-merge =="
# ~/.claude/CLAUDE.md is user-owned by construction: the installer writes it only when absent
# (install_global_claude) and the drift guard excludes it from comparison as user-owned
# (global/hooks/drift-check.sh). Nothing distributes it, so the only action that changes it is a hand
# edit. A check that finds the live copy stale and sends the operator anywhere else is worse than one
# that prints nothing: they act, the file does not change, and the failure persists.
SELF20="test/validate.sh"
# The guard skips THIS block and nothing else. An earlier form stopped the scan at C20's own heading,
# which is not the same thing: this harness is append-only, so "everything before C20" excluded the very
# region where the next hand-written verdict will be added — C21 below was already outside it, and a
# fifth mis-worded verdict appended later would leave the count at four and every assertion green. The
# self-exclusion has to be a hole of one block, not a horizon. Second half of the predicate: a verdict
# naming the shipped copy is a different fault with a different remedy (edit the repo), not ours to judge.
LIVEMSG20="$(awk '/^echo "== /{mine = ($0 ~ /^echo "== C20:/)} !mine && /bad "/ && /live twin/ && !/shipped copy/' "$SELF20")"
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

echo "== C21: a failed download leaves nothing behind =="
# fetch_file detects a bad transfer already (curl -f, and exit 18 on a truncated one) — what it lacks is
# a consequence at the destination: the bytes are written straight to the final path, so the detection
# arrives after the damage. Where a never-overwrite rule then preserves what it finds (the global
# manual, and every project data file), a partial write becomes permanent.
if ! command -v curl >/dev/null 2>&1; then
  echo "  [skip] C21 needs curl to exercise the download path"
else
TH21="$(mktemp -d)"; TH21B="$(mktemp -d)"; TH21C="$(mktemp -d)"; TH21D="$(mktemp -d)"; TH21E="$(mktemp -d)"; TW21="$(mktemp -d)"
# The trap carries the sandboxes still live from earlier blocks: replacing it instead of extending it
# leaked two sandboxes per run once already, so it is extended here and handed back below, not cleared.
trap 'rm -rf "$TH21" "$TH21B" "$TH21C" "$TH21D" "$TH21E" "$TW21" "$T12" "$T13"' EXIT
PROTO21="ai-flow/protocols/understand.md"

# Run A — a source that cannot be read, and a destination that does not exist yet.
if OUT21A="$( AI_FLOW_MODE=remote AI_FLOW_REPO_URL="file://$TW21/absent" \
              HOME="$TH21" bash "$ROOT/install.sh" update </dev/null 2>&1 )"; then
  ST21A=0
else
  ST21A=$?
fi
if [ ! -e "$TH21/.claude/$PROTO21" ]; then
  ok "a failed download creates no destination file"
else
  bad "a failed download creates no destination file"
fi
# It must also say which file it was. A run that aborts mutely leaves the operator to guess, which is
# the same silence the reworded verdicts above exist to remove.
if printf '%s' "$OUT21A" | grep -qF 'global/protocols/understand.md' \
   && printf '%s' "$OUT21A" | grep -qiE 'download failed|could not fetch'; then
  ok "a failed download names the file it could not fetch"
else
  bad "a failed download names the file it could not fetch"
fi

# The failure must also STOP the run, and this was measured: turning each failure branch's non-zero
# return into a zero one left the suite at 243/0, while the installer went on to announce eight
# protocols installed over an empty directory. Reporting a failure and then narrating success is a
# worse lie than the silence this block already forbids, and nothing held it but a shell option.
if [ "$ST21A" -ne 0 ]; then
  ok "a failed download stops the run"
else
  bad "a failed download stops the run (exited 0)"
fi
if ! printf '%s' "$OUT21A" | grep -qE 'Engine protocols installed|Update complete'; then
  ok "a failed download is never followed by a success report"
else
  bad "a failed download is never followed by a success report"
fi

# Run B — the same failure over a destination that already holds a good file. This is the never-overwrite
# path: what survives here is what the operator keeps forever.
mkdir -p "$TH21B/.claude/ai-flow/protocols"
printf 'sentinel-kept-intact\n' > "$TH21B/.claude/$PROTO21"
( AI_FLOW_MODE=remote AI_FLOW_REPO_URL="file://$TW21/absent" \
  HOME="$TH21B" bash "$ROOT/install.sh" update </dev/null >/dev/null 2>&1 ) || true
if [ "$(cat "$TH21B/.claude/$PROTO21" 2>/dev/null || true)" = "sentinel-kept-intact" ]; then
  ok "a failed download leaves an existing file byte-identical"
else
  bad "a failed download leaves an existing file byte-identical"
fi

# Run C — a readable source, to prove the base given is the base used and not the clone beside it. The
# run is expected to abort once it reaches a file this stub source does not carry; the protocol it did
# fetch is what the assertion reads.
mkdir -p "$TW21/stub/global/protocols"
printf 'sentinel-from-the-given-base\n' > "$TW21/stub/global/protocols/understand.md"
( AI_FLOW_MODE=remote AI_FLOW_REPO_URL="file://$TW21/stub" \
  HOME="$TH21C" bash "$ROOT/install.sh" update </dev/null >/dev/null 2>&1 ) || true
if grep -qF 'sentinel-from-the-given-base' "$TH21C/.claude/$PROTO21" 2>/dev/null; then
  ok "the installer fetches from the base it is given, not the clone beside it"
else
  bad "the installer fetches from the base it is given, not the clone beside it"
fi

# Run E — the case that actually guards the mechanism, and it was added because its absence was measured:
# with only the runs above, writing the download straight to its final path killed no assertion at all.
# Those reds came from the seam being missing, not from the temp-and-move. A source that EXISTS and is
# empty is the discriminating case: the transfer succeeds, so a direct write lands nothing over a good
# file, and a missing non-empty check moves nothing over it. Both are observable here and nowhere above.
mkdir -p "$TW21/hollow/global/protocols"
: > "$TW21/hollow/global/protocols/understand.md"
mkdir -p "$TH21E/.claude/ai-flow/protocols"
printf 'sentinel-survives-an-empty-transfer\n' > "$TH21E/.claude/$PROTO21"
OUT21E="$( AI_FLOW_MODE=remote AI_FLOW_REPO_URL="file://$TW21/hollow" \
           HOME="$TH21E" bash "$ROOT/install.sh" update </dev/null 2>&1 )" || true
if [ "$(cat "$TH21E/.claude/$PROTO21" 2>/dev/null || true)" = "sentinel-survives-an-empty-transfer" ]; then
  ok "a transfer that succeeds but delivers nothing never reaches the destination"
else
  bad "a transfer that succeeds but delivers nothing never reaches the destination"
fi
# And it must be reported. Without this, dropping the non-empty check turns the run into a silent success
# that installs an empty engine file — a failure mode with no symptom until a phase reads the blank.
if printf '%s' "$OUT21E" | grep -qiE 'download failed|could not fetch'; then
  ok "a transfer that delivers nothing is reported, not passed over in silence"
else
  bad "a transfer that delivers nothing is reported, not passed over in silence"
fi

# The abandoned temporary file must not be left beside the destination either: litter in the engine
# directory outlives the run that made it, and the next reader cannot tell it from an installed file.
# Every sandbox whose run reaches a branch that creates a temporary file, not just the first: the
# curl-failure branch and the empty-result branch each remove their own file, and one glob over one
# sandbox only ever exercised the first of them.
LITTER20=""
for h in "$TH21" "$TH21B" "$TH21E"; do
  ls "$h/.claude/ai-flow/protocols/".aiflow-fetch.* >/dev/null 2>&1 && LITTER20="$LITTER20 $h"
done
if [ -z "$LITTER20" ]; then
  ok "no failure branch leaves a temporary file beside the destination"
else
  bad "no failure branch leaves a temporary file beside the destination (left in:$LITTER20)"
fi

# The default download base, which run D below cannot observe: with nothing set the installer resolves
# MODE to local and never reads the base at all, so that run proves the mode default and only the mode.
# A typo or a bad merge in the substitution would ship an installer fetching from the wrong host with the
# suite still green. Checked against the base the docs publish, so the two cannot drift apart, and with
# no network involved.
DEFBASE20="$(sed -n 's/^REPO_URL="\${AI_FLOW_REPO_URL:-\(.*\)}"$/\1/p' "$ROOT/install.sh")"
if [ -n "$DEFBASE20" ] && grep -qF "$DEFBASE20" "$ROOT/README.md"; then
  ok "the default download base is the one the docs publish"
else
  bad "the default download base is the one the docs publish (resolved '$DEFBASE20')"
fi

# Run D — nothing set. The seam exists for the tests above; it must not have moved the default, so this
# run has to behave exactly as every other install in this suite does.
( cd "$ROOT" && env -u AI_FLOW_MODE -u AI_FLOW_REPO_URL HOME="$TH21D" \
  bash "$ROOT/install.sh" update </dev/null >/dev/null 2>&1 ) || true
if [ -s "$TH21D/.claude/$PROTO21" ] \
   && cmp -s "$TH21D/.claude/$PROTO21" "$ROOT/global/protocols/understand.md"; then
  ok "an unset environment leaves the installer's own resolution untouched"
else
  bad "an unset environment leaves the installer's own resolution untouched"
fi

rm -rf "$TH21" "$TH21B" "$TH21C" "$TH21D" "$TH21E" "$TW21"
trap 'rm -rf "$T12" "$T13"' EXIT   # handed back to the section that owned it
{ [ ! -d "$TH21" ] && [ ! -d "$TW21" ] && [ -d "$T12" ]; } \
  && ok "the sandbox is torn down and the live cleanup trap survives this block" \
  || bad "the sandbox is torn down and the live cleanup trap survives this block"
fi

echo "== C22: a phase refuses to run on a task that is not in that phase =="
PB22="global/protocols/backlog.md"
US22="global/skills/understand/SKILL.md"
PS22="global/skills/plan/SKILL.md"
VS22="global/skills/verify/SKILL.md"
VP22="global/protocols/verify.md"
HARNESS22="test/validate.sh"
PRECOND22="The phase precondition"
C22_SKILLS="understand plan verify"

# The rule's own block, bounded at the next heading of any depth and fence-aware — the shape C14 and
# C18 use for the task-diff definition and the mutation rule, and for the same reason: a file-wide grep
# finds the citations, never the rule itself.
PBLK22="$(awk -v h="^### $PRECOND22" '$0 ~ h {f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^#+ /){f=0} f' "$PB22")"
# One bolded clause of that block, from its lead to the next lead, flattened. Five facts share this
# block: a block-wide grep would let any one of them stand in for any other, which is the failure this
# harness has now caught eight times.
pclause22() { printf '%s\n' "$PBLK22" | awk -v s="$1" '/^- \*\*/{ if(g) exit; g=($0 ~ s) } g' | tr '\n' ' '; }
# Byte offset of a fixed string: for the facts that are an ORDER, which presence greps cannot see.
# Defined here rather than reused from C14 so this block stands on its own.
poff22() { printf '%s' "$1" | grep -obF "$2" | head -1 | cut -d: -f1; }

# --- the rule has exactly one home -----------------------------------------
# A5a. Counted, not merely found: the whole anti-drift design is that a second statement cannot exist.
# Anchored at line start: a citation names the heading inline ("see `### The phase precondition`"),
# which is how every other cross-reference in the engine is written, so an unanchored count reads each
# of the three citers as a fourth home. A real second home carries the heading itself, at line start.
HOMES22="$(grep -rl "^### $PRECOND22" global/ 2>/dev/null | wc -l | tr -d ' ')"
# The shipped template and the docs are the other two places a rule gets copied into, and a copy there
# is as much a second home as one in global/ — the count above would never see it.
ELSEWHERE22="$(grep -rl "^### $PRECOND22" template/ docs/ 2>/dev/null | wc -l | tr -d ' ')"
if [ "$HOMES22" -eq 1 ] && [ "$ELSEWHERE22" -eq 0 ] && [ -n "$PBLK22" ]; then
  ok "the phase precondition is stated in exactly one document"
else
  bad "the phase precondition is stated in exactly one document (global/: $HOMES22, elsewhere: $ELSEWHERE22)"
fi

# --- the accepted position of each command --------------------------------
ACC22="$(pclause22 'Accepted position')"
if [ -n "$ACC22" ] && printf '%s' "$ACC22" | grep -qiE 'not later than|no later than'; then
  ok "the accepted positions leave understand open below"
else
  bad "the accepted positions leave understand open below"
fi
if [ -n "$ACC22" ] && printf '%s' "$ACC22" | grep -q 'UNDERSTAND or PLAN'; then
  ok "the accepted positions name plan's own two"
else
  bad "the accepted positions name plan's own two"
fi
if [ -n "$ACC22" ] && printf '%s' "$ACC22" | grep -q 'EXECUTE or VERIFY'; then
  ok "the accepted positions name verify's own two"
else
  bad "the accepted positions name verify's own two"
fi

# --- the material leg -----------------------------------------------------
MAT22="$(pclause22 'material')"
if [ -n "$MAT22" ] && printf '%s' "$MAT22" | grep -q 'understand.md'; then
  ok "the material leg names what plan feeds on"
else
  bad "the material leg names what plan feeds on"
fi
# NOT a bare 'plan.md': the clause names both artifacts, so the loose form passed on the other leg's
# word. What verify needs is the table, and a plan without one is the hollow audit's own case.
if [ -n "$MAT22" ] && printf '%s' "$MAT22" | grep -qi 'Criteria Coverage'; then
  ok "the material leg names the table verify inherits, not merely the file"
else
  bad "the material leg names the table verify inherits, not merely the file"
fi
if [ -n "$MAT22" ] && printf '%s' "$MAT22" | grep -qiE 'understand [^.]*none|no material|none of its own'; then
  ok "the material leg says understand has none"
else
  bad "the material leg says understand has none"
fi

# --- what a disagreement produces ----------------------------------------
DIS22="$(pclause22 'disagree')"
if [ -n "$DIS22" ] && printf '%s' "$DIS22" | grep -qiE 'declares|declared'; then
  ok "a disagreement names the phase the sheet declares"
else
  bad "a disagreement names the phase the sheet declares"
fi
if [ -n "$DIS22" ] && printf '%s' "$DIS22" | grep -qiE 'asked for|requested|was asked'; then
  ok "a disagreement names the phase that was asked for"
else
  bad "a disagreement names the phase that was asked for"
fi
if [ -n "$DIS22" ] && printf '%s' "$DIS22" | grep -qiE 'missing|absent|cannot find'; then
  ok "a disagreement names the material that is missing"
else
  bad "a disagreement names the material that is missing"
fi
# B1. The stop is the half that costs something: a warning printed and then walked past is the defect
# with a note attached, which is what the user's own counter-case bought this requirement for.
if [ -n "$DIS22" ] && printf '%s' "$DIS22" | grep -qiE 'no artifact|nothing is written|before .*artifact' \
   && printf '%s' "$DIS22" | grep -qiE 'confirm|the operator'; then
  ok "a disagreement writes no artifact until the operator answers"
else
  bad "a disagreement writes no artifact until the operator answers"
fi

# --- what a confirmed run does and does not do ---------------------------
CONF22="$(pclause22 'confirmed')"
# A2 and B2 are two facts, not one: the sheet holding still is the state, and the report saying so is
# the record. A mutant that keeps the sheet and stays silent about it kills only the second.
if [ -n "$CONF22" ] && printf '%s' "$CONF22" | grep -qiE 'unchanged|untouched|not moved|does not move'; then
  ok "a confirmed out-of-phase run leaves the position line where it is"
else
  bad "a confirmed out-of-phase run leaves the position line where it is"
fi
if [ -n "$CONF22" ] && printf '%s' "$CONF22" | grep -qi 'out of phase' \
   && printf '%s' "$CONF22" | grep -qiE 'report|says'; then
  ok "a confirmed out-of-phase run says so in its report"
else
  bad "a confirmed out-of-phase run says so in its report"
fi

# --- what a clean pass does ---------------------------------------------
CLEAN22="$(pclause22 'clean pass')"
if [ -n "$CLEAN22" ] && printf '%s' "$CLEAN22" | grep -qiE 'writes its own phase|records its own phase'; then
  ok "a clean pass has the command record its own phase"
else
  bad "a clean pass has the command record its own phase"
fi
# The "before" is the half that carries the weight: written at exit instead of at entry, the read-only
# rail engages after the work it exists to restrain, and the understand protocol's line now depends on
# it. A presence grep for the verb cannot see position, and this block already owns the order idiom.
if [ -n "$CLEAN22" ] && printf '%s' "$CLEAN22" | grep -qiE '(own phase|sheet)[^.]*before'; then
  ok "the phase is recorded before the phase's work, not after it"
else
  bad "the phase is recorded before the phase's work, not after it"
fi
# The handover, and its reason. Without the reason the clause reads as a preference and the next editor
# deletes it: the phase after plan has no command of its own, so nothing else can write it.
if [ -n "$CLEAN22" ] && printf '%s' "$CLEAN22" | grep -q 'EXECUTE' \
   && printf '%s' "$CLEAN22" | grep -qiE 'no command|has no command of its own'; then
  ok "the handover to EXECUTE carries the reason it exists"
else
  bad "the handover to EXECUTE carries the reason it exists"
fi

# --- the three commands obey it, and restate none of it ------------------
for s in $C22_SKILLS; do
  f="global/skills/$s/SKILL.md"
  if [ ! -f "$f" ]; then
    bad "$s cites the phase precondition (file missing: $f)"
    bad "$s does not restate the accepted positions (file missing)"
    bad "$s records its own phase once both legs pass (file missing)"
    continue
  fi
  c="$(cat "$f")"

  # Citing means naming the block AND the document that holds it — the phrase alone could be a heading
  # of the skill's own.
  if printf '%s' "$c" | grep -q "$PRECOND22" && printf '%s' "$c" | grep -q 'backlog.md'; then
    ok "$s cites the phase precondition's owner"
  else
    bad "$s cites the phase precondition's owner"
  fi

  # The anti-drift assertion, the same one the ladder already earned: a skill may name its own phase,
  # never re-spell the accepted SETS, because a second statement of those is the copy that drifts.
  if printf '%s' "$c" | grep -q 'UNDERSTAND or PLAN' \
     || printf '%s' "$c" | grep -q 'EXECUTE or VERIFY' \
     || printf '%s' "$c" | grep -qiE 'not later than|no later than'; then
    bad "$s does not restate the accepted positions"
  else
    ok "$s does not restate the accepted positions"
  fi

  # A3b — the write, per command. The rule having a writer is the whole reason the check can refuse on
  # this field at all; a rule stating it while no command does it is an alarm with no owner.
  # NOT a loose 'writes .*phase': the read-only rail's own sentence ("blocks code writes while the
  # phase is UNDERSTAND") satisfied that, so the assertion was green on a neighbour's word before a
  # line of the fix existed. The possessive is the fact — it is the command's OWN phase it records.
  if printf '%s' "$c" | grep -qiE 'writes? its own phase|records? its own phase'; then
    ok "$s records its own phase once both legs pass"
  else
    bad "$s records its own phase once both legs pass"
  fi

  # The skill's step 2 carries THREE obligations and only the write was asserted, so the stop and the
  # no-move could each be deleted from any one command with the suite green. Scoped to step 2, because
  # the operative instruction the command reads at runtime is this one — the protocol states the rule,
  # the command performs it.
  s2="$(vstep "$f" 2)"
  if [ -n "$s2" ] && printf '%s' "$s2" | grep -qiE 'disagreement' \
     && printf '%s' "$s2" | grep -qiE 'report and wait|reports? and waits?'; then
    ok "$s stops and waits on a disagreement"
  else
    bad "$s stops and waits on a disagreement"
  fi
  if [ -n "$s2" ] && printf '%s' "$s2" | grep -qiE 'without moving the line|without moving the phase'; then
    ok "$s runs an authorised override without moving the line"
  else
    bad "$s runs an authorised override without moving the line"
  fi
  # F2's per-command half: the write is at entry, not at exit.
  if [ -n "$s2" ] && printf '%s' "$s2" | grep -qiE '(own phase|sheet)[^.;]*before'; then
    ok "$s records the phase before doing the phase's work"
  else
    bad "$s records the phase before doing the phase's work"
  fi
done

# --- F1b: the rule must reach the layer that is the documented manual fallback -------------
# The sibling ladder is cited in BOTH layers — each protocol head and each command. This one was cited
# only in the commands, so a run that reaches the protocol because the command is not installed
# performed no check at all, and verify.md's own report template demanded a fact its procedure could not
# produce. Same discipline: cite, restate nothing.
for pr in understand plan verify; do
  pf="global/protocols/$pr.md"
  if [ ! -f "$pf" ]; then
    bad "the $pr protocol cites the phase precondition (file missing)"
    bad "the $pr protocol does not restate the accepted positions (file missing)"
    continue
  fi
  pc="$(cat "$pf")"
  if printf '%s' "$pc" | grep -q "$PRECOND22"; then
    ok "the $pr protocol cites the phase precondition"
  else
    bad "the $pr protocol cites the phase precondition"
  fi
  if printf '%s' "$pc" | grep -q 'UNDERSTAND or PLAN' \
     || printf '%s' "$pc" | grep -q 'EXECUTE or VERIFY' \
     || printf '%s' "$pc" | grep -qiE 'not later than|no later than'; then
    bad "the $pr protocol does not restate the accepted positions"
  else
    ok "the $pr protocol does not restate the accepted positions"
  fi
done

# F10 — the rewritten line names its mover. A passive sentence with no owner is what this task found;
# leaving the repair unasserted lets it revert to passive with the suite green.
if grep -qE 'write-guard hook stops restricting once the `plan` command writes' "global/protocols/understand.md"; then
  ok "the read-only rail's release names the command that performs it"
else
  bad "the read-only rail's release names the command that performs it"
fi

# A4b — the handover lands in the command that performs it, not only in the rule that describes it.
# Scoped to the step that performs it: two file-wide greps for 'EXECUTE' and an advance verb are
# satisfied by any two unrelated lines, which is the shape of a guard that reports on nothing.
# Reuses `vstep` rather than carrying a third copy of the same extractor: the copy written here escaped
# its step boundary with two backslashes where the other two use four, so its `\.` reached awk as a bare
# dot and the boundary matched any character. It happened to work; it was one edit from not.
N_CONF22="$(grep -nE '^[0-9]+\. \*\*Conform\*\*' "$PS22" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/')"
CONFS22="$([ -n "$N_CONF22" ] && vstep "$PS22" "$N_CONF22")"
if [ -n "$CONFS22" ] && printf '%s' "$CONFS22" | grep -q 'EXECUTE' \
   && printf '%s' "$CONFS22" | grep -qiE 'hands? over|advances?'; then
  ok "the plan command carries the handover to EXECUTE, in the step that closes"
else
  bad "the plan command carries the handover to EXECUTE, in the step that closes"
fi

# O4 — declared, never claimed. understand's phase leg cannot fail from below and it has no material
# leg at all; saying so is what stops a later reader from reading its silence as coverage.
if grep -qiE 'no material|nothing to require|none of its own' "$US22"; then
  ok "understand declares it has no material leg"
else
  bad "understand declares it has no material leg"
fi
if grep -qiE 'cannot fail from below|nothing earlier|no earlier phase' "$US22"; then
  ok "understand declares its phase leg cannot fail from below"
else
  bad "understand declares its phase leg cannot fail from below"
fi

# --- the gather runs before anything judges what it gathers --------------
C_VS22="$(cat "$VS22")"
O_GATH22="$(poff22 "$C_VS22" 'Gather the task diff')"
O_AUD22="$(poff22 "$C_VS22" 'Criterion audit')"
O_COPY22="$(poff22 "$C_VS22" 'byte-exact copy')"
O_REV22="$(poff22 "$C_VS22" 'Invoke the verify-review workflow')"

# A7. The defect itself, stated as an order: the consumer sat ahead of the gather, so what it judged was
# whatever the session happened to hold. Presence greps cannot see this, which is why the harness kept
# it green while asserting the consumer pointed FORWARD at a step that had not run.
if [ -n "$O_GATH22" ] && [ -n "$O_AUD22" ] && [ "$O_GATH22" -lt "$O_AUD22" ]; then
  ok "the gather runs before the criterion audit that reads it"
else
  bad "the gather runs before the criterion audit that reads it"
fi
# A7b — and the consumer stops pointing forward. The old assertion demanded exactly this forward
# reference, so leaving it in place would keep the defect green under a new name.
RA22="$(printf '%s\n' "$C_VS22" | awk '/Reverse audit/{f=1} f{print; if(/^[[:space:]]*$/) exit}' | tr '\n' ' ')"
if [ -n "$RA22" ] && ! printf '%s' "$RA22" | grep -qiE 'as step [0-9]+ gathers|which is not part of what step'; then
  ok "the reverse audit no longer points forward at an ungathered diff"
else
  bad "the reverse audit no longer points forward at an ungathered diff"
fi

# A8. The copy brackets the REVIEW, not the audit. Moved up with the gather it would span the audit's
# own command re-runs, and a file a test creates would then be restored away — work destroyed to fix a
# report.
if [ -n "$O_AUD22" ] && [ -n "$O_COPY22" ] && [ "$O_AUD22" -lt "$O_COPY22" ]; then
  ok "the byte-exact copy is taken after the criterion audit's command re-runs"
else
  bad "the byte-exact copy is taken after the criterion audit's command re-runs"
fi
if [ -n "$O_COPY22" ] && [ -n "$O_REV22" ] && [ "$O_COPY22" -lt "$O_REV22" ]; then
  ok "the byte-exact copy is taken before the review is invoked"
else
  bad "the byte-exact copy is taken before the review is invoked"
fi

# O2 — every step reference inside the command resolves to a step that exists. Counted first: an
# extractor that finds no references passes every check it makes.
REFS22="$(printf '%s\n' "$C_VS22" | grep -oE 'step [0-9]+' | grep -oE '[0-9]+' | sort -u)"
NREFS22="$(printf '%s\n' "$REFS22" | grep -c '[0-9]' || true)"
DANGLING22=""
for n in $REFS22; do
  printf '%s\n' "$C_VS22" | grep -qE "^$n\. " || DANGLING22="$DANGLING22 $n"
done
if [ "$NREFS22" -ge 3 ] && [ -z "$DANGLING22" ]; then
  ok "every step reference inside the verify command resolves to a step that exists"
else
  bad "every step reference inside the verify command resolves to a step that exists (dangling:$DANGLING22)"
fi

# O2's SECOND conjunct — the criterion says a reference resolves to a step that exists *and carries the
# fact cited*. Only the first was implemented. With eleven steps almost every wrong number is still an
# existing one, and pointing at the wrong-but-existing step is exactly how a renumbering fails.
vsn22() { grep -nE "^[0-9]+\. \*\*$1" "$VS22" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/'; }
J_GATH22="$(vsn22 'Gather the task diff')"
J_COPY22="$(vsn22 'Take the byte-exact copy')"
J_CMP22="$(vsn22 'Compare the working copy')"
J_WR22="$(vsn22 'Write')"
JOINS22=0
JBAD22=""
join22() { # phrase-anchored pattern, expected index, label
  local got
  got="$(printf '%s\n' "$C_VS22" | grep -oE "$1" | grep -oE '[0-9]+' | head -1)"
  if [ -n "$got" ]; then
    JOINS22=$((JOINS22 + 1))
    [ "$got" = "$2" ] || JBAD22="$JBAD22 $3(cites=$got,is=$2)"
  else
    JBAD22="$JBAD22 $3(phrase-absent)"
  fi
}
join22 'step [0-9]+ writes both into the report'  "$J_WR22"   'gather-to-write'
join22 'task diff step [0-9]+ gathered'           "$J_GATH22" 'audit-to-gather'
join22 'path step [0-9]+ can recompute'           "$J_CMP22"  'copy-to-compare'
join22 'record step [0-9]+ compares against'      "$J_CMP22"  'copy-to-compare-2'
join22 'copy taken in step [0-9]+'                "$J_COPY22" 'compare-to-copy'
join22 'step [0-9]+.s comparison'                 "$J_CMP22"  'consolidate-to-compare'
join22 'what step [0-9]+ noted'                   "$J_GATH22" 'write-to-gather'
join22 'tree verdict from step [0-9]+'            "$J_CMP22"  'write-to-compare'
# Counted against the class: a guard whose phrases all stop matching asserts nothing about the numbers.
if [ "$JOINS22" -eq 8 ] && [ -z "$JBAD22" ]; then
  ok "every step reference cites the step that carries the fact"
else
  bad "every step reference cites the step that carries the fact ($JOINS22/8 phrases;$JBAD22)"
fi

# The spec's own edge case: with the gather ahead of the audit, the skip decision governs only the
# review. The four offsets asserted above all survive moving the skip decision ABOVE the gather, which
# puts the gather straight back inside what a skipped review appears to skip — the exact confusion the
# old forward-reference parenthetical existed to paper over.
O_SKIP22="$(poff22 "$C_VS22" 'Decide whether to skip')"
if [ -n "$O_GATH22" ] && [ -n "$O_SKIP22" ] && [ "$O_GATH22" -lt "$O_SKIP22" ]; then
  ok "the gather sits outside what a skipped review skips"
else
  bad "the gather sits outside what a skipped review skips"
fi

# O3 — positive form, not a denylist: what bounds these extractors is that they resolve the step by
# content. Counted against the class so a guard whose extractor finds nothing cannot pass.
# `vstep` is in the class too: it is the extractor this change actually re-scoped onto the copy step, so
# a guard naming only the other two misses the one call site the change created. The reach of a rule is
# measured against the call sites that exist, never against the ones that existed when it was written.
INV22="$(grep -oE '(nstep|sbullet|vstep) "\$VS[0-9]*"' "$HARNESS22" | wc -l | tr -d ' ')"
LIT22="$(grep -oE '(nstep|sbullet|vstep) "\$VS[0-9]*" [0-9]' "$HARNESS22" | wc -l | tr -d ' ')"
if [ "$INV22" -ge 6 ] && [ "$LIT22" -eq 0 ]; then
  ok "no assertion reaches a step of the verify command by a hardcoded number"
else
  bad "no assertion reaches a step of the verify command by a hardcoded number ($LIT22 of $INV22 literal)"
fi

# O5 — both report templates, counted. One template carrying the note and the other silent is the
# same half-fix the twin-manual verdicts were: the reader opens whichever one their path reaches.
AUDP22="$(awk '/^\*\*Audited\*\*/{f=1;buf=""} f{buf=buf" "$0} (f && /^[[:space:]]*$/){print buf; f=0} END{if(f) print buf}' "$VP22")"
AUDT22="$(printf '%s\n' "$AUDP22" | grep -c 'Audited' || true)"
AUDW22="$(printf '%s\n' "$AUDP22" | grep -ci 'out of phase' || true)"
if [ "$AUDT22" -eq 2 ] && [ "$AUDW22" -eq 2 ]; then
  ok "both report templates carry the out-of-phase note"
else
  bad "both report templates carry the out-of-phase note ($AUDW22 of $AUDT22)"
fi

# The writers table names who writes the phase field — the field a mechanism now refuses on, which is
# exactly the kind of datum that keeps firing while nothing is obliged to act on it.
if grep -nE '^\| \*\*During the phases\*\*' "$PB22" | head -1 | grep -qiE 'command|written by'; then
  ok "the writers table names the phase field's writer"
else
  bad "the writers table names the phase field's writer"
fi

echo "== C23: a checkout holds one claim to its branch, and the close deletes what it archived =="
BLG23="global/protocols/backlog.md"
# Extractors re-declared rather than inherited: a criterion reading another's extractor changes verdict
# when that one is re-scoped. Each is asserted non-empty before any verdict is trusted — an assertion
# that fails because its extractor found nothing passes on anything once the file is edited.
sec23() {  # a "### " section, fence-aware: the skeletons it quotes start lines with "## "
  awk -v h="$1" '$0 ~ h {f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^#+ /){f=0} f' "$BLG23" \
    | tr '\n' ' ' | tr -s ' '
}
item23() {  # one numbered item of a section, flattened: what an item must say is a property of that
            # item, never of a neighbour's words nor of where its prose happens to wrap
  printf '%s\n' "$2" | awk -v s="^$1\\. " -v e="^$(($1 + 1))\\. " '$0 ~ e {f=0} $0 ~ s {f=1} f' \
    | tr '\n' ' ' | tr -s ' '
}
raw23() { awk -v h="$1" '$0 ~ h {f=1;next} /^```/{c=1-c; next} (c==0 && /^#+ /){f=0} f' "$BLG23"; }

SHEET23="$(sec23 '^### .artifacts/T-XXX/state.md.')"
LADDER23="$(raw23 '^### Resolving the task')"
RUNG23="$(item23 4 "$LADDER23")"
OPEN23="$(raw23 '^## Opening a Workstream')"
MOVE23="$(item23 7 "$OPEN23")"
ARCH23="$(raw23 '^### After ARCHIVE')"
STEP23="$(item23 4 "$ARCH23")"
INV23="$(sec23 '^### Invariants')"

# A1 — the rule lands where the sheet's shape is defined, in three parts that can each be deleted
# alone: the invariant, the obligation that keeps it, and the form a released claim takes.
if [ -n "$SHEET23" ]; then
  printf '%s' "$SHEET23" | grep -qiE 'at most one|only one|exactly one' \
    && printf '%s' "$SHEET23" | grep -qi 'claim' \
    && ok "the sheet's section states a checkout holds at most one claim to its branch" \
    || bad "the sheet's section states a checkout holds at most one claim to its branch"
  printf '%s' "$SHEET23" | grep -qiE 'releas[a-z]* every other claim' \
    && ok "the sheet's section obliges a new claim to release every other claim there" \
    || bad "the sheet's section obliges a new claim to release every other claim there"
  printf '%s' "$SHEET23" | grep -q 'released-branch' \
    && printf '%s' "$SHEET23" | grep -qiE 'anchor|start of the line' \
    && ok "the sheet's section names the released form and why it is not read as a claim" \
    || bad "the sheet's section names the released form and why it is not read as a claim"
else
  bad "the sheet's section states a checkout holds at most one claim to its branch (no section)"
  bad "the sheet's section obliges a new claim to release every other claim there (no section)"
  bad "the sheet's section names the released form and why it is not read as a claim (no section)"
fi

# A2 — the writer for the datum rung 1 reads. Scoped to the move that writes the sheet: a
# section-wide grep would pass on the pruning move above it, which releases nothing.
if [ -n "$MOVE23" ]; then
  printf '%s' "$MOVE23" | grep -qiE 'releas[a-z]* every other claim' \
    && ok "the move that writes a task's sheet releases every other claim to that branch" \
    || bad "the move that writes a task's sheet releases every other claim to that branch"
else
  bad "the move that writes a task's sheet releases every other claim to that branch (no move)"
fi

# A6 — the rung today credits the opening ceremony alone, which is what sent this task's own capture
# down a false trail. It must name the rule that actually prevents the situation.
if [ -n "$RUNG23" ]; then
  printf '%s' "$RUNG23" | grep -qiE 'one claim|at most one|releas' \
    && ok "the last rung names what prevents two claims to one branch" \
    || bad "the last rung names what prevents two claims to one branch"
else
  bad "the last rung names what prevents two claims to one branch (no rung)"
fi

# A3 — three conjuncts, three assertions. A criterion with two conjuncts can ship with one of them
# implemented, so reach, safety and ordering are each asserted where they can each be deleted alone.
if [ -n "$STEP23" ]; then
  printf '%s' "$STEP23" | grep -qiE 'every checkout|each checkout|wherever|both checkouts' \
    && ok "the archive step deletes the papers in every checkout that holds them" \
    || bad "the archive step deletes the papers in every checkout that holds them"
  printf '%s' "$STEP23" | grep -qiE 'record is written|already written|archive holds|summary' \
    && ok "the archive step names the written record as what makes the deletion safe" \
    || bad "the archive step names the written record as what makes the deletion safe"
  printf '%s' "$STEP23" | grep -qiE 'never before the collection|not before the collection|never at collection' \
    && ok "the archive step forbids deleting before the collection" \
    || bad "the archive step forbids deleting before the collection"
else
  bad "the archive step deletes the papers in every checkout that holds them (no step)"
  bad "the archive step names the written record as what makes the deletion safe (no step)"
  bad "the archive step forbids deleting before the collection (no step)"
fi

# A7 — the invariant the widened deletion makes true. Unqualified, it reads as a property of the one
# checkout that keeps the record, which is exactly the reading that left every other copy behind.
if [ -n "$INV23" ]; then
  printf '%s' "$INV23" | grep -qiE 'every checkout|each checkout|in any checkout' \
    && ok "the artifacts invariant holds in every checkout" \
    || bad "the artifacts invariant holds in every checkout"
else
  bad "the artifacts invariant holds in every checkout (no section)"
fi

# O2's machine half — the hook README enumerates why a sheet declares no branch, and this change adds
# a second reason. A positive requirement, not a denylist: the row must name the released claim.
ROW23="$(grep -m1 '^| .understand-write-guard.py.' global/hooks/README.md)"
if [ -n "$ROW23" ] \
   && printf '%s' "$ROW23" | grep -q 'released-branch' \
   && printf '%s' "$ROW23" | grep -qi 'claim was released'; then
  ok "the rail's own documentation names the released claim as a reason a sheet declares no branch"
else
  bad "the rail's own documentation names the released claim as a reason a sheet declares no branch"
fi

# The two corrections this change made to statements it falsified elsewhere. Both were shipped by the
# change and neither was asserted: the review reproduced it — reverting either left the whole suite
# green while the document contradicted itself. A correction nothing guards is a correction with a
# half-life.
R2_23="$(item23 2 "$LADDER23")"
if [ -n "$R2_23" ]; then
  printf '%s' "$R2_23" | grep -qiE 'releas' \
    && printf '%s' "$R2_23" | grep -qiE 'alone among|among the sheets' \
    && ok "rung 2 admits the released claim and scopes 'alone' to the sheets declaring no branch" \
    || bad "rung 2 admits the released claim and scopes 'alone' to the sheets declaring no branch"
else
  bad "rung 2 admits the released claim and scopes 'alone' to the sheets declaring no branch (no rung)"
fi

PRE23="$(awk '/^### After ARCHIVE/{f=1;next} /^[0-9]+\. /{f=0} f' "$BLG23" | tr '\n' ' ' | tr -s ' ')"
if [ -n "$PRE23" ]; then
  printf '%s' "$PRE23" | grep -qiE 'except step 4|reaches into the checkout' \
    && ok "the checklist preamble carves out the step that leaves the coordinator" \
    || bad "the checklist preamble carves out the step that leaves the coordinator"
else
  bad "the checklist preamble carves out the step that leaves the coordinator (no preamble)"
fi

# The index a reader consults for what happens to the sheet at archive. The review's prover added this
# very assertion and watched it fail against the shipped row: proven unguarded before it was written.
WRT23="$(sec23 '^### Who writes what, when')"
if [ -n "$WRT23" ]; then
  printf '%s\n' "$WRT23" | grep -oE '\| \*\*Archive\*\*[^|]*\|[^|]*\|[^|]*\|' | grep -qiE 'every checkout|each checkout' \
    && ok "the writers table's archive row scopes the deletion to every checkout" \
    || bad "the writers table's archive row scopes the deletion to every checkout"
else
  bad "the writers table's archive row scopes the deletion to every checkout (no section)"
fi

echo "== C24: a machine-read field is read where it is declared =="
RAIL24="global/hooks/understand-write-guard.py"
BLG24="global/protocols/backlog.md"

# The paragraph that carries the rule, not the subsection around it: a section-wide grep passes on a
# neighbour's words, and the neighbours here are the claim rules that talk about lines and fields too.
# Emphasis marks fall wherever the prose needs them, so a phrase asserted raw can be cut in half by a
# pair of asterisks — the same way the message below is cut by its concatenation boundary. What is
# asserted is what the rule says, never where its typography lands.
PH24="$(awk 'BEGIN{RS=""} /machine-read/{print; exit}' "$BLG24" | tr -s ' \n' '  ' | tr -d '*')"
if [ -n "$PH24" ]; then
  ok "the section that owns the state-file rules states what is machine-read"
  miss24=""
  printf '%s' "$PH24" | grep -qiE 'first line|first such line|first declaration' || miss24="$miss24 first"
  printf '%s' "$PH24" | grep -qiE 'no other|nowhere else|not read|prose'         || miss24="$miss24 rest-is-prose"
  printf '%s' "$PH24" | grep -qi  'colon'                                        || miss24="$miss24 colon"
  printf '%s' "$PH24" | grep -qiE 'roster|STATE.md|never migrated|legacy'        || miss24="$miss24 legacy-label"
  printf '%s' "$PH24" | grep -qiE 'Fase actual'                                  || miss24="$miss24 spanish-label"
  # The sentence that authorises this task's accepted loss: without it the narrowing is a silent one
  # nobody wrote down, which is the accidental silence the standing law forbids. Its four neighbours all
  # stayed green when it was deleted, which is how it got here.
  printf '%s' "$PH24" | grep -qiE 'declares no phase|no phase at all'            || miss24="$miss24 no-phase-consequence"
  # What the form requires versus what it merely prefers. Both directions were unpinned: the pattern's
  # tolerance could be narrowed and the prose's claim widened, each with the suite green.
  printf '%s' "$PH24" | grep -qiE 'load-bearing'                                 || miss24="$miss24 load-bearing"
  printf '%s' "$PH24" | grep -qiE 'house style|not the contract'                  || miss24="$miss24 house-style"
  [ -z "$miss24" ] && ok "the rule states the declaration is the first such line, with its colon, and that nothing else is read" \
                   || bad "the rule states the declaration is the first such line, with its colon, and that nothing else is read (missing:$miss24)"
else
  bad "the section that owns the state-file rules states what is machine-read"
  bad "the rule states the declaration is the first such line, with its colon, and that nothing else is read (no paragraph)"
fi

# The remedy must change the thing the check names. A positive requirement, not a denylist: the message
# names the command that records the phase — every rewording that still sends the operator to the hand
# edit fails the second arm, and one that names nothing fails the first.
# The message is an f-string split across source lines, so the phrase a check looks for is cut by the
# concatenation boundary: matched raw, every arm below would pass on finding nothing. Normalised to the
# prose the operator actually reads before anything is asserted about it.
MSG24="$(sed -n '/^    print($/,/^    )$/p' "$RAIL24" | tr '\n' ' ' | sed 's/f"//g; s/"//g' | tr -s ' ')"
# The remedy the operator is sent to FIRST is the one the check is about, so it is extracted rather than
# searched for: from the trigger to the end of that sentence. Bare `plan` was matched before, which is a
# substring of planning, plan.md and the plan protocol — a message naming no command at all passed.
REM24="${MSG24#*truly needed}"; REM24="${REM24%%. *}"
if [ -n "$MSG24" ] && [ -n "$REM24" ]; then
  if printf '%s' "$REM24" | grep -q 'run the `plan` command' \
     && printf '%s' "$REM24" | grep -qiE 'records the phase|writes the phase'; then
    ok "the block message names the command that moves the phase"
  else
    bad "the block message names the command that moves the phase"
  fi
  # The class, not four phrasings. Scoped to the primary remedy: the wrong-sheet clause below it names a
  # hand correction on purpose, and a ban over the whole message would forbid the case the user asked for.
  # A denylist of exact wordings passed a rewrite that routed the operator to a hand edit verbatim.
  if printf '%s' "$REM24" | grep -qiE 'yourself|manually|by hand|(edit|set|change|update)[^.]{0,20}the phase'; then
    bad "the primary remedy is a command, not an edit the operator makes"
  else
    ok "the primary remedy is a command, not an edit the operator makes"
  fi
  # And the case where the sheet itself is wrong: there the command is the wrong action, and a message
  # that names no route for it sends the operator to do the wrong thing — the defect this epic already
  # closed once, in a smaller form.
  if printf '%s' "$MSG24" | grep -qiE 'not the task you are working' \
     && printf '%s' "$MSG24" | grep -q 'branch:'; then
    ok "the block message names what to do when the sheet it read is the wrong one"
  else
    bad "the block message names what to do when the sheet it read is the wrong one"
  fi
else
  bad "the block message names the command that moves the phase (no message)"
  bad "the primary remedy is a command, not an edit the operator makes (no message)"
  bad "the block message names what to do when the sheet it read is the wrong one (no message)"
fi

# The paragraph that settles which layer wins. It is its own paragraph, so the extractor above cannot
# reach it, and a rule whose authority is unstated is a rule an editor may read as a description.
AUTH24="$(awk 'BEGIN{RS=""} /is the authority/{print; exit}' "$BLG24" | tr -s ' \n' '  ' | tr -d '*')"
if [ -n "$AUTH24" ] \
   && printf '%s' "$AUTH24" | grep -qiE 'note about the enforcer|the enforcer' \
   && printf '%s' "$AUTH24" | grep -qiE 'the pattern is the thing to correct|the rule is what'; then
  ok "the rule is stated as the authority and the pattern as the enforcer's note"
else
  bad "the rule is stated as the authority and the pattern as the enforcer's note"
fi

# The operator-facing catalog row is the layer someone reads when the rail is down and the sheet looks
# right. It spells out the branch ladder in full; the reading rule was the one thing it did not carry.
ROW24="$(grep -m1 '^| .understand-write-guard.py.' global/hooks/README.md | tr -d '*`' | tr -s ' ')"
if [ -n "$ROW24" ] \
   && printf '%s' "$ROW24" | grep -qiE 'first line|first .{0,12}line' \
   && printf '%s' "$ROW24" | grep -qiE 'no other line|any other form'; then
  ok "the guard's catalog row carries the reading rule, not only where the phase is read from"
else
  bad "the guard's catalog row carries the reading rule, not only where the phase is read from"
fi

# The guard's own comment enumerates why a sheet declares no branch, and a released claim is the second
# reason. The README row already carries it; the comment gave one reason where there are two.
CMT24="$(awk 'BEGIN{RS=""} /claiming no branch/{print; exit}' "$RAIL24" | tr -s ' \n' '  ')"
if [ -n "$CMT24" ] \
   && printf '%s' "$CMT24" | grep -qiE 'before the field|predates the field' \
   && printf '%s' "$CMT24" | grep -qiE 'released|took on another'; then
  ok "the guard's comment names both reasons a sheet declares no branch"
else
  bad "the guard's comment names both reasons a sheet declares no branch"
fi

echo "== C25: a guard tells a failed probe from a clean answer =="
# Three guards of this harness reported success in the situations they were written to catch. Each
# assertion below states the fact it establishes; a guard whose probe cannot answer must fail naming
# the probe, because in a report a clean verdict and an unanswered question read identically.
T25="$(mktemp -d)"
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
SELF25="$ROOT/test/validate.sh"
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
BLOCK25="$(awk '/^echo "== C12:/{f=1} f && /^# --- delivery to an adopting project/{exit} f' "$SELF25")"
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
TWINBLK25="$(awk '/^manstate\(\)/{f=1} f && /^# --- the rail resolves/{exit} f' "$SELF25")"
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

echo "== C26: the claim line's form is written where it is read and pinned where it is checked =="
# The sibling of the phase declaration, and the same defect one field over: the reader was already
# correct and nothing stopped it being reverted with the suite green. These two fixtures discriminate
# by construction — each names a different file, and returns a different exit code, under the reading
# it forbids than under the reading the rule states.
if [ "$PY3" = 1 ]; then
  # A later mention is not the declaration. The claiming sheet names another branch and its prose
  # quotes this one; a whole-file reader resolves that sheet (phase EXECUTE, no block), a
  # first-line reader falls to the lone unclaimed sheet (phase UNDERSTAND, blocked and named).
  F26A="$T25/f26a"; mkproj "$F26A" main
  mkdir -p "$F26A/.ai-flow/artifacts/elsewhere" "$F26A/.ai-flow/artifacts/lone"
  # The later mention must itself begin with the label, or no reader would match it and the fixture
  # discriminates nothing: a mention inside a sentence is invisible to a whole-file reader too. A
  # fenced block showing the form is the shape a real sheet grows — the phase fixtures above use it.
  { printf '# Task state\n\nbranch: other\nphase: **EXECUTE**\n\n## Decisions\n\n'
    printf -- '- the claim released here is quoted below, and quoting is not claiming:\n\n'
    printf '```\nbranch: main\n```\n'
  } > "$F26A/.ai-flow/artifacts/elsewhere/state.md"
  printf '# Task state\n\nphase: **UNDERSTAND**\n' > "$F26A/.ai-flow/artifacts/lone/state.md"
  out="$(wguard "$F26A" "$F26A/app.txt")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *"artifacts/lone/state.md"*) ok "a later mention of the claim field is not the declaration" ;;
      *) bad "a later mention of the claim field is not the declaration (blocked, but named another file)" ;;
    esac
  else
    bad "a later mention of the claim field is not the declaration (exit $rc)"
  fi

  # An annotated value declares no claim. Beside a second unclaimed sheet the strict reading has no
  # lone one to fall back on, so it reaches the ledger; a first-token reading would claim the branch
  # and answer with a sheet whose phase raises no rail at all.
  F26B="$T25/f26b"; mkproj "$F26B" main
  mkdir -p "$F26B/.ai-flow/artifacts/annotated" "$F26B/.ai-flow/artifacts/second"
  printf 'Current phase: **UNDERSTAND**\n' > "$F26B/.ai-flow/STATE.md"
  printf '# Task state\n\nbranch: main (paused)\nphase: **EXECUTE**\n' > "$F26B/.ai-flow/artifacts/annotated/state.md"
  printf '# Task state\n\nphase: **EXECUTE**\n' > "$F26B/.ai-flow/artifacts/second/state.md"
  out="$(wguard "$F26B" "$F26B/app.txt")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *".ai-flow/STATE.md"*) ok "an annotated value declares no claim" ;;
      *) bad "an annotated value declares no claim (blocked, but named another file)" ;;
    esac
  else
    bad "an annotated value declares no claim (exit $rc)"
  fi
  # The colon is declared load-bearing by the prose, so it is load-bearing in the reader too. Same
  # shape as the fixture above: beside a second unclaimed sheet a colonless line leaves no lone sheet
  # to fall back on, so the ledger answers; a reader that treated the colon as optional would claim
  # the branch and answer with a sheet whose phase raises no rail.
  F26C="$T25/f26c"; mkproj "$F26C" main
  mkdir -p "$F26C/.ai-flow/artifacts/nocolon" "$F26C/.ai-flow/artifacts/other2"
  printf 'Current phase: **UNDERSTAND**\n' > "$F26C/.ai-flow/STATE.md"
  printf '# Task state\n\nbranch main\nphase: **EXECUTE**\n' > "$F26C/.ai-flow/artifacts/nocolon/state.md"
  printf '# Task state\n\nphase: **EXECUTE**\n' > "$F26C/.ai-flow/artifacts/other2/state.md"
  out="$(wguard "$F26C" "$F26C/app.txt")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *".ai-flow/STATE.md"*) ok "a claim written without its colon declares no claim" ;;
      *) bad "a claim written without its colon declares no claim (blocked, but named another file)" ;;
    esac
  else
    bad "a claim written without its colon declares no claim (exit $rc)"
  fi
else
  echo "  [skip] C26 needs python3 to run the rail"
fi

# --- the rule states it where a reader with no parser looks ---------------
# T-020's law: a rule stated as one reader's implementation detail is not stated. The claim block is
# where a person looks, fourteen lines below the paragraph that does this for the phase field.
# Normalised before anything is asserted about it: emphasis marks and a wrapped source line both cut
# the phrase a check looks for, and in both directions — a requirement that is met reports failure, a
# veto that finds nothing reports success. What is asserted here is content, never typography.
# Bounded to the paragraph itself, not to the whole section: an extractor spanning its neighbours
# lets a phrase from an adjacent paragraph satisfy a check about this one. And a phrase from EVERY
# sentence is pinned — pinning three keywords inside two sentences leaves the rest deletable with the
# suite green, which is a rule half-stated reported as stated.
CLAIM26="$(awk '/line is machine-read on the same terms/{f=1} f && /^$/{exit} f' \
  "$ROOT/global/protocols/backlog.md" | tr -d '*`' | tr -s ' \n' '  ')"
miss26=""
[ -n "$CLAIM26" ] || miss26="$miss26 paragraph-absent"
printf '%s' "$CLAIM26" | grep -qi 'machine-read'                     || miss26="$miss26 machine-read"
printf '%s' "$CLAIM26" | grep -qiE 'first line that declares'        || miss26="$miss26 first-line"
printf '%s' "$CLAIM26" | grep -qi 'colon'                            || miss26="$miss26 colon"
printf '%s' "$CLAIM26" | grep -qiE 'single token|one token'           || miss26="$miss26 single-token"
printf '%s' "$CLAIM26" | grep -qi 'branch: main (paused)'             || miss26="$miss26 annotated-example"
printf '%s' "$CLAIM26" | grep -qi 'no other line is read'             || miss26="$miss26 no-other-line"
printf '%s' "$CLAIM26" | grep -qiE 'any other form declares no branch' || miss26="$miss26 any-other-form"
[ -z "$miss26" ] \
  && ok "the claim block states what is load-bearing about the line" \
  || bad "the claim block states what is load-bearing about the line (missing:$miss26)"

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

# A1 — the rule itself, in the section that owns the base. Asserted on a non-empty extractor first:
# a section that failed to extract satisfies no requirement and would otherwise report as a clean miss.
m27=""
[ -n "$TD27" ] || m27="$m27 section-absent"
printf '%s' "$TD27" | grep -qiE 'published trunk'                  || m27="$m27 published-trunk"
printf '%s' "$TD27" | grep -qiE 'publishing precedes verifying'    || m27="$m27 rule"
printf '%s' "$TD27" | grep -qiE 'removes the overlap'              || m27="$m27 remedy"
[ -z "$m27" ] \
  && ok "the task-diff definition states that verifying measures from a published trunk" \
  || bad "the task-diff definition states that verifying measures from a published trunk (missing:$m27)"

# A3 — the behaviour on a trunk that is behind, both halves. A guard that only reads the naming half
# passes on a rule that names the lag and then refuses to run, which is the outcome the user rejected.
n27=""
[ -n "$TD27" ] || n27="$n27 section-absent"
printf '%s' "$TD27" | grep -qiE 'ahead of its remote'                     || n27="$n27 count"
printf '%s' "$TD27" | grep -qiE 'publish'                                 || n27="$n27 remedy"
printf '%s' "$TD27" | grep -qiE 'continues|never refuses|does not refuse' || n27="$n27 continues"
[ -z "$n27" ] \
  && ok "a lagging trunk is named with its count and its remedy, and the audit continues" \
  || bad "a lagging trunk is named with its count and its remedy, and the audit continues (missing:$n27)"

# A4 — the silence AND what triggers it. A bare 'no lag' substring is satisfied by a silence attached
# to any condition at all: the review rewrote the trigger to its opposite — collapsing "no lag is
# possible here" into "measured, found nothing", the distinction the manifest calls load-bearing — and
# this stayed green. The sentence carrying the silence is extracted and the triggers read inside it.
S4_27="$(printf '%s' "$TD27" | grep -o 'no lag[^.]*\.' | head -1)"
q27=""
[ -n "$S4_27" ] || q27="$q27 sentence-absent"
printf '%s' "$S4_27" | grep -qi 'trunk is current'  || q27="$q27 trunk-current"
printf '%s' "$S4_27" | grep -qi 'no remote'         || q27="$q27 no-remote"
printf '%s' "$S4_27" | grep -qi 'no local branch'   || q27="$q27 no-local-branch"
printf '%s' "$S4_27" | grep -qi 'no base resolved'  || q27="$q27 no-base"
[ -z "$q27" ] \
  && ok "the silences name what triggers each of them" \
  || bad "the silences name what triggers each of them (missing:$q27)"

# A2 — the measurement lives where the base is already resolved, and is therefore made before anything
# is judged. Two facts: the command is there, and the gather step precedes the audit step. The order is
# over step INDEXES, which a renumbering-without-moving cannot fake.
G27="$([ -n "$NG27" ] && nstep "$VS27" "$NG27")"
o27=""
[ -n "$G27" ] || o27="$o27 step-absent"
# The range is what discriminates. The step already runs rev-list and already names
# refs/remotes/origin (that is how the base is resolved), so presence greps for either would be
# satisfied by the text as it stands today and would report a lag nobody computes.
printf '%s' "$G27" | grep -qE 'refs/remotes/origin/[^ ]*\.\.refs/heads/' || o27="$o27 lag-range"
printf '%s' "$G27" | grep -qF 'rev-list'                                  || o27="$o27 rev-list"
{ [ -n "$NG27" ] && [ -n "$NA27" ] && [ "$NG27" -lt "$NA27" ]; } || o27="$o27 order"
# The commands are half the step; what to do with the number is the other half, and the review deleted
# every branch of it with all six assertions still green. Each outcome is required by name.
printf '%s' "$G27" | grep -qF 'rev-parse --verify'                        || o27="$o27 ref-check"
printf '%s' "$G27" | grep -qiE 'continues|never refuses'                  || o27="$o27 continue-branch"
printf '%s' "$G27" | grep -qi 'no lag line'                               || o27="$o27 silence-branch"
printf '%s' "$G27" | grep -qi 'branch under audit'                        || o27="$o27 own-work-branch"
[ -z "$o27" ] \
  && ok "the skill determines the trunk's lag where it resolves the base" \
  || bad "the skill determines the trunk's lag where it resolves the base (missing:$o27)"

# A6 — counted, not merely present: a template check that finds its fact once cannot tell one template
# carrying it from two. Read off non-comment lines, the shape C14 arrived at after a commented-out
# fallback line satisfied the same check.
TL27="$(awk '
  /^```/ {
    if (inf) {
      if (seen) { gsub(/[[:space:]]+/, " ", s); total++; if (tolower(s) ~ /ahead of its remote/) good++ }
      seen=0; s=""
    }
    inf=1-inf; next
  }
  inf {
    if ($0 ~ /# Verify: T-XXX/) seen=1
    if ($0 ~ /^[[:space:]]*<!--/) next
    s = s " " $0
  }
  END { print (good+0) "/" (total+0) }
' "$VP27")"
[ "$TL27" = "2/2" ] \
  && ok "both verify.md templates record the trunk's lag beside the base" \
  || bad "both verify.md templates record the trunk's lag beside the base ($TL27)"

# A5 — the sentence the branch-scoped task diff falsified, repaired. Positive requirement first,
# because what bounds a statement is the form it must carry; the one negative is aimed at the exact
# claim that went false, not at a list of wordings that might.
PR27="$(awk '/^## Code Comments & Provenance/{f=1;next} /^## /{f=0} f' "$EP27" | tr -d '*`' | tr -s ' \n' '  ')"
p27=""
[ -n "$PR27" ] || p27="$p27 section-absent"
printf '%s' "$PR27" | grep -qiE 'task diff'                     || p27="$p27 scope"
printf '%s' "$PR27" | grep -qiE 'publish'                       || p27="$p27 publishing"
printf '%s' "$PR27" | grep -qiE 'until it is published|unpublished' || p27="$p27 condition"
printf '%s' "$PR27" | grep -qiE 'on new work only'              && p27="$p27 stale-claim"
[ -z "$p27" ] \
  && ok "the provenance rule states the reach the grep actually has" \
  || bad "the provenance rule states the reach the grep actually has (missing:$p27)"


# A7 — the ordinary run, which the contract singles out as the one that must not change. Counted over
# both templates for the same reason A6 is: one template carrying the escape and the other silent is
# the half-fix, and a slot enumerating only the branch where the notice fires prints "0 commit(s)
# ahead — publish them" on every clean run.
TC27="$(awk '
  /^```/ {
    if (inf) {
      if (seen) { gsub(/[[:space:]]+/, " ", s); total++; if (tolower(s) ~ /trunk is current/) good++ }
      seen=0; s=""
    }
    inf=1-inf; next
  }
  inf {
    if ($0 ~ /# Verify: T-XXX/) seen=1
    if ($0 ~ /^[[:space:]]*<!--/) next
    s = s " " $0
  }
  END { print (good+0) "/" (total+0) }
' "$VP27")"
[ "$TC27" = "2/2" ] \
  && ok "both templates write no lag line where the trunk is current" \
  || bad "both templates write no lag line where the trunk is current ($TC27)"

# A8 — the report writer's own enumeration of what the Audited line carries. It was repaired because
# this change falsified it, and a repair nothing asserts is revertible with the suite green.
NW27="$(vsn27 'Write')"
W27="$([ -n "$NW27" ] && nstep "$VS27" "$NW27")"
w27=""
[ -n "$W27" ] || w27="$w27 step-absent"
printf '%s' "$W27" | grep -qi 'ahead of its remote' || w27="$w27 lag"
printf '%s' "$W27" | grep -qi 'no lag line'         || w27="$w27 silence"
printf '%s' "$W27" | grep -qi 'trunk is current'    || w27="$w27 trunk-current"
[ -z "$w27" ] \
  && ok "the report writer enumerates the lag and its silences" \
  || bad "the report writer enumerates the lag and its silences (missing:$w27)"

# A9 — the two cases where the remedy would harm rather than help: the branch under audit IS the trunk,
# so publishing pushes work the audit is judging and empties the next run's scope; and a diverged trunk,
# where the push is refused outright. A remedy that cannot succeed is the defect this task exists to fix.
r27=""
[ -n "$TD27" ] || r27="$r27 section-absent"
printf '%s' "$TD27" | grep -qi 'branch under audit'        || r27="$r27 own-trunk-case"
printf '%s' "$TD27" | grep -qi 'never the task'            || r27="$r27 ownership-limit"
printf '%s' "$TD27" | grep -qi 'diverged'                  || r27="$r27 diverged"
[ -z "$r27" ] \
  && ok "the remedy excludes the task's own commits and a diverged trunk" \
  || bad "the remedy excludes the task's own commits and a diverged trunk (missing:$r27)"


echo "== The paper trail names the model the engine runs =="

# A1 — the front door. Two claims read as a pair: the roster carries its own name, and activation writes
# the task's own sheet. The stale wording is asserted ABSENT in the same breath, because a README that
# gains the new sentence while keeping the old one teaches both and the reader cannot tell which won.
# Each half is scoped to the line that carries its claim. File-wide greps let the structure block's
# comment answer for the activation row and vice versa, so the criterion's two halves could both be
# satisfied by one edit in one place.
RD24="README.md"
LC24="global/protocols/lifecycle.md"

# The two halves now live in two files, and that is the point of the split rather than an accident of it:
# the front door keeps the claim its own structure line makes, and the claim about what activation writes
# follows the phase description to the one document that describes phases. Scoped to the ACTIVATE section
# and terminated at the next heading of ANY depth — the sibling A3 extractor exits on `## ` alone, which
# is correct only because ARCHIVE is the last phase and is not correct here.
ACT24="$(awk '/^### 3\. ACTIVATE/{f=1;next} f && /^#+ /{exit} f' "$LC24" 2>/dev/null)"
RST24="$(grep '── STATE.md' "$RD24")"
a1=""
[ -n "$ACT24" ] || a1="$a1 activate-section-absent"
[ -n "$RST24" ] || a1="$a1 structure-line-absent"
printf '%s' "$RST24" | grep -qi 'roster of open workstreams' || a1="$a1 roster-name"
printf '%s' "$ACT24" | grep -q  'artifacts/T-XXX/state.md'   || a1="$a1 task-sheet"
printf '%s' "$ACT24" | grep -qi 'roster'                     || a1="$a1 roster-row"
printf '%s' "$RST24" | grep -qi 'Current session context'    && a1="$a1 stale-session-context"
printf '%s' "$ACT24" | grep -qi 'as the active task'         && a1="$a1 stale-activation"
[ -z "$a1" ] \
  && ok "the front door names the roster and the map names the task's own sheet" \
  || bad "the front door names the roster and the map names the task's own sheet (missing:$a1)"


# A2 — the audit runs four auditors. The count is asserted by naming all four, not by matching a numeral:
# a document that says "four" and lists three is the same defect with the arithmetic corrected. The stale
# count is asserted absent for the reason A1 gives.
a2=""
grep -q  'Business Contract'         "$LC24" || a2="$a2 contract"
grep -q  'Test Coverage'             "$LC24" || a2="$a2 coverage"
grep -qi 'Security & Error Handling' "$LC24" || a2="$a2 security"
grep -q  'Architecture Boundaries'   "$LC24" || a2="$a2 architecture"
grep -qiE '(3|three) review agents'  "$LC24" && a2="$a2 stale-count"
[ -z "$a2" ] \
  && ok "the lifecycle names all four auditors of the review" \
  || bad "the lifecycle names all four auditors of the review (missing:$a2)"

# A3 — archiving is a ceremony, and the move that puts the work into effect is the one a reader most needs:
# a close that ends before distribution leaves the engine committed and not installed — the work is in the
# trunk and does not exist for the sessions it governs. Scoped to the archive section so a mention anywhere
# else cannot answer for it.
ARC24="$(awk '/^### 9\. ARCHIVE/{f=1} f && /^## /{exit} f' "$LC24")"
a3=""
[ -n "$ARC24" ] || a3="$a3 section-absent"
printf '%s' "$ARC24" | grep -qi 'ceremony'         || a3="$a3 ceremony"
printf '%s' "$ARC24" | grep -qi 'distribut'        || a3="$a3 distribution"
printf '%s' "$ARC24" | grep -qi 'backlog protocol' || a3="$a3 authority"
[ -z "$a3" ] \
  && ok "the lifecycle archive is a ceremony and names the distribution move" \
  || bad "the lifecycle archive is a ceremony and names the distribution move (missing:$a3)"

# A4 — the direction that must still hold. Every other assertion here checks that a document gained the
# right sentence; this one checks that NO document anywhere claims a single active task without naming the
# front it is scoped to. A guard written only in the lifting direction goes silent the moment the claim
# reappears in a file the fix never opened.
#
# The pattern matches the CURRENT wording's regression shapes, not the wording that was repaired. Written
# against the repaired text it would have been blind to every way the claim can come back — "One active
# task at a time", "Only one task is active at a time", or simply the workstream qualifier deleted — and a
# guard nothing can trip is indistinguishable from one that holds. The signal is ACTIVENESS, never a count:
# "names exactly one task", "ONE task per run" and "the single-task archive checklist" are legitimate and
# must stay unflagged, which is why singularity alone is not enough to select a line.
a4="$(grep -rniE '(one|a single|only one)[[:space:]]+active[[:space:]]+task|(one|a single|only one)[[:space:]]+task[^.]{0,30}(active|at a time)|single[- ]task focus|single focus of the session|task at a time' \
        README.md docs/ global/ 2>/dev/null | grep -cviE 'workstream|per front|each front')"
[ "$a4" = "0" ] \
  && ok "no document claims a single active task without naming the workstream" \
  || bad "no document claims a single active task without naming the workstream ($a4 line(s))"

# A5 — the hook's remedy. It runs on the coordinator, so a message sending the operator to trim the roster
# "down to the active task only" instructs them to destroy the rows of every other open front. The
# assertion is on the text alone: the exit codes are covered five times over and must not move.
# Scoped to the remedy line itself, and the absence half asks what the trim TARGET is rather than pinning
# one historic phrase: a reworded destructive remedy ("down to the current task", "down to the open task")
# passed a check that only knew the words "active task only".
HK24="global/hooks/check-state-size.sh"
TRM24="$(grep -i 'trim STATE.md down to' "$HK24")"
a5=""
[ -n "$TRM24" ] || a5="$a5 remedy-absent"
printf '%s' "$TRM24" | grep -qi 'down to the roster'   || a5="$a5 roster"
printf '%s' "$TRM24" | grep -qiE 'down to the (active|current|open|single|one)' && a5="$a5 destructive-target"
[ -z "$a5" ] \
  && ok "the state-size hook trims to the roster, not to the active task" \
  || bad "the state-size hook trims to the roster, not to the active task (missing:$a5)"

BLG24="global/protocols/backlog.md"
# Terminated at the next heading. Without one the window runs to end of file, so "scoped to the section"
# is a claim the extractor does not keep — true only for as long as this happens to be the last section.
AS24="$(awk '/^### Allowed structure/{f=1;next} f && /^#{2,3} /{exit} f' "$BLG24")"

# A6 — the structure a project is allowed to have. Listing the phase protocols inside .ai-flow/ tells the
# reader to look for the engine where the engine is not, and tells an adopter their project owns files it
# must never edit. Both halves asserted: the stale subtree gone, and the central path named in its place.
a6=""
[ -n "$AS24" ] || a6="$a6 section-absent"
printf '%s' "$AS24" | grep -q 'state.md'                 || a6="$a6 task-sheet"
printf '%s' "$AS24" | grep -q -- '── protocols/'         && a6="$a6 stale-subtree"
printf '%s' "$AS24" | grep -q 'claude/ai-flow/protocols' || a6="$a6 central-engine"
[ -z "$a6" ] \
  && ok "the allowed structure puts the phase protocols in the central engine" \
  || bad "the allowed structure puts the phase protocols in the central engine (missing:$a6)"

# A7 — the ordinary case of the closing ceremony. Two moves need no second checkout and a third needs no
# merge, because a task worked in the coordinator has no branch to land. Naming two of the three reads as
# though the merge always had work to do, which turns the ordinary close into a ritual with a dead move.
CLO24="$(awk '/^## Closing a Workstream/{f=1;next} f && /^## /{exit} f' "$BLG24")"
PRE24="$(printf '%s\n' "$CLO24" | awk '/^1\. /{exit} {print}' | tr '\n' ' ' | tr -s ' ')"
a7=""
[ -n "$PRE24" ] || a7="$a7 preamble-absent"
printf '%s' "$PRE24" | grep -qiE 'no branch to merge|nothing to merge' || a7="$a7 merge-reason"
printf '%s' "$PRE24" | grep -qi 'moves 2 and 6'                       && a7="$a7 stale-move-list"
[ -z "$a7" ] \
  && ok "a single open front has no branch to merge either" \
  || bad "a single open front has no branch to merge either (missing:$a7)"

QP24="global/protocols/quick-path.md"

# A8 — a quick task's only written trace. The protocol said the row exists and never said whose hand
# writes it or when: a linked checkout that writes it puts the ledger in a worktree the close deletes.
# Scoped to the Tracking section: the file names BACKLOG.md twice for unrelated reasons, so a check over
# the whole document answers "the authority is named" from a line about backlog entries and T-XXX IDs.
TRK24="$(awk '/^## Tracking/{f=1;next} f && /^## /{exit} f' "$QP24")"
a8=""
[ -n "$TRK24" ] || a8="$a8 section-absent"
printf '%s' "$TRK24" | grep -qi 'coordinator'                            || a8="$a8 writer"
printf '%s' "$TRK24" | grep -qiE 'closing ceremony|ceremony that closes' || a8="$a8 moment"
printf '%s' "$TRK24" | grep -qi 'backlog protocol'                       || a8="$a8 authority"
[ -z "$a8" ] \
  && ok "the quick close names the coordinator and the ceremony that writes its row" \
  || bad "the quick close names the coordinator and the ceremony that writes its row (missing:$a8)"

# A9 — the skeleton mirrors the roster, so it must mirror its heading level too: copied as written, the
# table lands nested under whatever section precedes it and stops being the roster's own.
a9=""
grep -q '^## Quick Tasks Completed'  "$QP24" || a9="$a9 level"
grep -q '^### Quick Tasks Completed' "$QP24" && a9="$a9 stale-level"
[ -z "$a9" ] \
  && ok "the quick-path skeleton heads Quick Tasks at the roster's own level" \
  || bad "the quick-path skeleton heads Quick Tasks at the roster's own level (missing:$a9)"

# A10 — carried over from a harness nothing ran. Four sections were asserted only there, so deleting it
# would have retired the one thing standing between them and a silent removal.
VP24="global/protocols/verify.md"
UP24="global/protocols/understand.md"
a10=""
grep -q  'Business Contract'     "$VP24" || a10="$a10 verify-contract-auditor"
grep -qi 'Skills Feedback'       "$VP24" || a10="$a10 verify-skills-feedback"
grep -q  'Investigation Closure' "$UP24" || a10="$a10 understand-closure"
grep -q  'EARS'                  "$UP24" || a10="$a10 understand-ears"
[ -z "$a10" ] \
  && ok "the retired harness's own anchors survive it" \
  || bad "the retired harness's own anchors survive it (missing:$a10)"

# A11 — the two repairs that had no guard at all. The identical falsehood is a hard failure for the front
# door under A1, so leaving these unasserted made the same claim policed in one document and free in
# another — and an unguarded prose repair is revertible with the suite green.
CU24="docs/customization.md"
a11=""
CON24="$(grep -i '| .continue. / .continua. |' "$CU24")"
EPH24="$(grep -i '`.ai-flow/STATE.md`' "$CU24")"
[ -n "$CON24" ] || a11="$a11 continue-row-absent"
[ -n "$EPH24" ] || a11="$a11 ephemeral-line-absent"
printf '%s' "$CON24" | grep -qiE 'own sheet|this checkout owns' || a11="$a11 continue-reads-sheet"
printf '%s' "$CON24" | grep -qi 'Resume from STATE.md'          && a11="$a11 stale-continue"
printf '%s' "$EPH24" | grep -qi 'roster'                        || a11="$a11 roster"
printf '%s' "$EPH24" | grep -qi 'session state'                 && a11="$a11 stale-session-state"
[ -z "$a11" ] \
  && ok "the customization guide names the sheet and the roster" \
  || bad "the customization guide names the sheet and the roster (missing:$a11)"

# A12 — the stale-install shape, in the direction that must hold. A6 declares a project directory holding
# the phase protocols invalid; a newcomer document that promises the installer creates one teaches the
# adopter to expect exactly what A6 calls stale. Counted across every document a newcomer reads, because
# the claim is not confined to the file this task happened to open.
a12="$(grep -rniE '\.ai-flow/[^ ]* (directory )?with protocols|\.ai-flow/ (directory )?(with|contains|holds) .*protocol' \
        README.md docs/ 2>/dev/null | wc -l | tr -d ' ')"
[ "$a12" = "0" ] \
  && ok "no newcomer document says the project's .ai-flow/ holds the phase protocols" \
  || bad "no newcomer document says the project's .ai-flow/ holds the phase protocols ($a12 line(s))"

# A13 — the refutation's reach. The engine refutes HIGH and hands MEDIUM and LOW to the phase
# unadjudicated; a document claiming every finding is refuted promises a guarantee the run does not make,
# and one still naming MEDIUM describes a stage that no longer exists — the same class of falsehood,
# reached by drift rather than by edit.
REF24="$(grep -ni 'refut' "$LC24")"
a13=""
[ -n "$REF24" ] || a13="$a13 refutation-absent"
printf '%s' "$REF24" | grep -qi 'HIGH'                          || a13="$a13 scope"
printf '%s' "$REF24" | grep -qiE 'HIGH and MEDIUM|HIGH/MEDIUM'  && a13="$a13 stale-medium"
printf '%s' "$REF24" | grep -qiE 'every (surviving )?finding'   && a13="$a13 overclaim"
[ -z "$a13" ] \
  && ok "the lifecycle states which findings are adversarially refuted" \
  || bad "the lifecycle states which findings are adversarially refuted (missing:$a13)"

# A14 — the ceremony as the newcomer reads it. Three claims the protocol makes and the summary dropped:
# move 1 has no branch to approve in the coordinator, the last two moves run only when the front has no
# next task, and the single-front clause must not spell move numbers — the sibling guard derives them
# precisely because a move inserted anywhere renumbers the rest, and the copy a newcomer reads had them
# hardcoded with nothing reading them.
a14=""
[ -n "$ARC24" ] || a14="$a14 section-absent"
printf '%s' "$ARC24" | grep -qiE 'no branch to approve|per-commit'   || a14="$a14 move1-coordinator"
printf '%s' "$ARC24" | grep -qiE 'no next task|has no next'          || a14="$a14 tail-conditional"
printf '%s' "$ARC24" | grep -qiE 'moves? [0-9], |moves? [0-9] and'   && a14="$a14 hardcoded-numbers"
[ -z "$a14" ] \
  && ok "the lifecycle ceremony carries its conditions and spells no move numbers" \
  || bad "the lifecycle ceremony carries its conditions and spells no move numbers (missing:$a14)"

# P1/P2 — restored from the harness this task retired. It carried the only assertions that the generic core
# stays generic: an origin-project identifier or the author's home path reaching global/ is the one defect
# that breaks the product's central promise for every adopter at once, and the migration that kept four of
# its anchors had missed these because they live inside a loop rather than on a literal check line.
# `\bisn\b` rather than a bare `isn`, which matches "isn't" — a guard that fires on ordinary prose is a
# guard the next person deletes.
PUR24='\bisn\b|residents|gate-manager|zoomin|esp32|firestore|ionic|angular|haiku|/architect|/ngrx|/data-access|/frontend-design'
p1=""
for f in backlog execute lifecycle plan quick-path understand verify; do
  grep -qiE "$PUR24" "global/protocols/$f.md"                     && p1="$p1 $f:identifier"
  grep -qiE 'E-099|T-7[0-9][0-9]|T-9[0-9][0-9]' "global/protocols/$f.md" && p1="$p1 $f:foreign-task-id"
done
[ -z "$p1" ] \
  && ok "the swept phase protocols carry no origin-project identifier" \
  || bad "the swept phase protocols carry no origin-project identifier (found:$p1)"

# What ships is what the installer fetches out of version control, which is what git can name: tracked
# files, plus untracked ones git is not ignoring. A recursive walk of the directory reads more than
# that. Running the hooks in place leaves Python bytecode under `global/hooks/__pycache__/`, and that
# bytecode carries the absolute path it was compiled from -- so an ignored directory the installer
# never distributes turned this row red, accusing the shipped engine of carrying an author home path
# it does not carry. Neither probe the working-copy comparison uses reaches an ignored file, so the run
# reported the tree left as found while this verdict had already changed. The failure was also
# intermittent: the system grep announces a binary match and the row fails, ugrep suppresses it and the
# row passes, so the same tree answered differently on different machines.
purity_sweep() { # repo root, subpath -- one `file:line:text` per hit among the files that could ship
  local root="$1" sub="$2" list
  # Reading the file list from git buys precision and brings git's own failure modes with it. A tree
  # that is not a repository, or a git that cannot answer, yields an empty list -- and an empty list
  # grepped for a leak finds none, so the row would report a clean engine on the strength of having
  # read nothing. The walk this replaced could not fail that way, so the guard is part of the
  # replacement: every input a verdict concludes from is proven usable before it is concluded from.
  # Non-zero here means "could not run", which the caller reports as such and never as a pass.
  git -C "$root" rev-parse --git-dir >/dev/null 2>&1 || return 2
  list="$(git -C "$root" ls-files --cached --others --exclude-standard -- "$sub" 2>/dev/null)" || return 2
  # Selecting nothing is the same defect wearing a mistyped path: the seeder's empty-selection case.
  [ -n "$list" ] || return 2
  # `-H` because grep omits the filename when it is handed exactly one file, and a hit that cannot say
  # which file carries it is a hit nobody can act on.
  # The subshell's own status is grep's, and grep answers 1 for "found nothing" -- which is the passing
  # case here, not a failure. So the only status this function forwards is the one that means the files
  # could not be reached; everything else is a completed sweep whose hits are its output.
  ( cd "$root" 2>/dev/null || exit 9
    printf '%s\n' "$list" | tr '\n' '\0' \
      | xargs -0 grep -HniEI 'residents|gate-manager|zoomin|esp32|/Users/[a-z]' 2>/dev/null )
  [ $? -eq 9 ] && return 2
  return 0
}
P2OUT="$(purity_sweep . global)"; P2RC=$?
p2="$(printf '%s' "$P2OUT" | grep -c . | tr -d ' ')"
if [ "$P2RC" -ne 0 ]; then
  bad "the shipped engine carries no private project name and no author home path (the sweep could not run: not a repository, or it selected no file)"
elif [ "$p2" = "0" ]; then
  ok "the shipped engine carries no private project name and no author home path"
else
  bad "the shipped engine carries no private project name and no author home path ($p2 line(s))"
fi

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

# --- the creation move states conditions, not a brand ---------------------
M5_25="$(o25 5)"
if [ -n "$M5_25" ]; then
  # WHEN the creation move is read, THEN each of the four conditions is stated as a condition on the
  # checkout. Named individually so a failure says WHICH one is missing: a single verdict over four
  # facts cannot be acted on.
  c25a=""
  printf '%s' "$M5_25" | grep -qiE 'published default branch|published base'          || c25a="$c25a base"
  # Both halves, because the retired prohibition already contained the words "the project's data" —
  # an assertion satisfied by the sentence it exists to replace passes for a reason unrelated to the
  # condition it names. `the project declares` was dropped from the first half for that same reason
  # once the move gained a preamble about the tool the project declares: a phrase loose enough to be
  # answered by a neighbouring sentence stops being an assertion about this condition at all.
  { printf '%s' "$M5_25" | grep -qiE 'declares travels' \
    && printf '%s' "$M5_25" | grep -qiE 'only the papers|papers it owns'; }   || c25a="$c25a data"
  printf '%s' "$M5_25" | grep -qiE 'audit'                                            || c25a="$c25a visibility"
  printf '%s' "$M5_25" | grep -qiE 'whatever created (it|the checkout)'                || c25a="$c25a ownership"
  [ -z "$c25a" ] \
    && ok "the creation move states the four conditions a checkout must satisfy" \
    || bad "the creation move states the four conditions a checkout must satisfy (not stated:$c25a)"

  # The positive form is what bounds this, never a list of tool names to forbid: naming the one brand
  # that caused the defect leaves every other brand free to be prescribed next.
  c25b=""
  # The floor half only. `default` was welded to it in one phrase, and the weld was the defect: read as
  # a default, the native path came first and the question of which tool manages the project was never
  # formed. The claim that the project's tool is the default is asserted where it now lives, in the
  # block below, and the phrase that welded the two is forbidden as a class there. Anchored to its
  # SUBJECT for the same reason `default` was: the move now says elsewhere that the ceremony "falls
  # back to the floor", so a bare `the floor` is answered by that sentence and survives the removal of
  # the claim it exists to pin — proven by mutation, which is how this wording was arrived at.
  printf '%s' "$M5_25" | grep -qiE 'native path[^.]{0,200}is \*{0,2}the floor' || c25b="$c25b native-is-the-floor"
  printf '%s' "$M5_25" | grep -qiE 'no particular|any tool|whatever tool|any front.end' || c25b="$c25b tool-agnostic"
  [ -z "$c25b" ] \
    && ok "the creation move requires no particular front-end and names the native path as the floor" \
    || bad "the creation move requires no particular front-end and names the native path as the floor (missing:$c25b)"

  # A condition with no remedy sends the operator to a stop they cannot clear.
  printf '%s' "$M5_25" | grep -qiE 'nested|inside the primary' \
    && printf '%s' "$M5_25" | grep -qiE 'ignore' \
    && ok "the visibility condition names the remedy for a nested checkout" \
    || bad "the visibility condition names the remedy for a nested checkout"
else
  bad "the creation move states the four conditions a checkout must satisfy (move not found)"
  bad "the creation move requires no particular front-end and names the native path as the floor (move not found)"
  bad "the visibility condition names the remedy for a nested checkout (move not found)"
fi

# --- the dismantling move ------------------------------------------------
M6C_25="$(c25 6)"
if [ -n "$M6C_25" ]; then
  printf '%s' "$M6C_25" | grep -qiE 'whatever created (it|the checkout)' \
    && printf '%s' "$M6C_25" | grep -qiE 'worktree list' \
    && ok "the dismantling move requires removal by whatever created the checkout" \
    || bad "the dismantling move requires removal by whatever created the checkout"

  printf '%s' "$M6C_25" | grep -qiE 'this session|same session|session that created' \
    && ok "the dismantling move states the native tool's session limit" \
    || bad "the dismantling move states the native tool's session limit"
else
  bad "the dismantling move requires removal by whatever created the checkout (move not found)"
  bad "the dismantling move states the native tool's session limit (move not found)"
fi

# The condition move 7 now waits on. Its sibling in move 6 is asserted above; a correction nothing
# asserts can be reverted with the suite green, and this one was added by the same change.
printf '%s' "$(c25 7)" | grep -qiE 'worktree list' \
  && ok "the roster row waits on the repository's worktree listing" \
  || bad "the roster row waits on the repository's worktree listing"

# --- the retired rationale, guarded as a class ---------------------------
# Written against the text that will exist, not against the sentence being deleted: what must never
# come back is the CLAIM that nesting misbinds the guards, in any wording. The engine's own guards
# handle nesting on purpose, and one of them says so in its docstring.
r25="$(grep -rniE 'nest(ed|ing)' global docs template 2>/dev/null \
       | grep -iE 'guardrail|guard rail|bind' | grep -viE 'understand-write-guard\.py' | wc -l | tr -d ' ')"
[ "$r25" = "0" ] \
  && ok "no document claims a nested checkout misbinds the guardrail hooks" \
  || bad "no document claims a nested checkout misbinds the guardrail hooks ($r25 line(s))"

# --- the ceremony points at the shipped mechanism ------------------------
# The operator's guide naming it is not the same fact: this is the sentence an agent running the
# ceremony reads, and it is the only thing that tells a non-native front-end how to meet the data
# condition.
printf '%s' "$(o25 6)" | grep -q 'seed-front.sh' \
  && ok "the seed-and-prune move names the mechanism the engine ships" \
  || bad "the seed-and-prune move names the mechanism the engine ships"

# The move's copy contract, which is no longer unconditional. Two legs, and the negative one is the
# load-bearing half: the exception can be stated in a sentence appended below the promise it
# contradicts, and a reader — or an agent running the ceremony — then meets both. What must be gone is
# the CLAIM that nothing the checkout holds is ever replaced, in any wording.
x25=""
# Anchored to what the exception SAYS and not to the words that name it: the move already called the
# task "the one it is seeded for" before this change, so a looser pattern is answered by the sentence
# that was there all along and pins nothing.
printf '%s' "$(o25 6)" | grep -qiE 'replaced from|replaces? (them|the front)|come from the (coordinator|primary)' \
  || x25="$x25 no-exception"
printf '%s' "$(o25 6)" | grep -qiE 'stops|refus'                  || x25="$x25 no-stop-on-live-work"
printf '%s' "$(o25 6)" | grep -qiE 'never overwrites a file the checkout already holds' \
  && x25="$x25 unconditional-promise-still-there"
[ -z "$x25" ] \
  && ok "the seed-and-prune move states the exception and its guard" \
  || bad "the seed-and-prune move states the exception and its guard ($x25)"

# Where the sheet is written is what decides whether it reaches the front at all: the seeding move ran
# before it existed, so a sheet written anywhere else never arrives. Asserted on move 7, which is the
# move that writes it.
printf '%s' "$(o25 7)" | grep -qiE "in the front's (own )?checkout|where the task is worked|in that checkout" \
  && ok "the opening writes the task's sheet where the task is worked" \
  || bad "the opening writes the task's sheet where the task is worked"

# --- the operator's document ---------------------------------------------
DOC25="docs/customization.md"
d25=""
grep -qiE 'published default branch|published base' "$DOC25" 2>/dev/null || d25="$d25 base"
grep -qiE 'only the papers|papers it owns|own papers'  "$DOC25" 2>/dev/null || d25="$d25 data"
grep -qiE 'audit'                                      "$DOC25" 2>/dev/null || d25="$d25 visibility"
grep -qiE 'whatever created (it|the checkout)'          "$DOC25" 2>/dev/null || d25="$d25 ownership"
grep -q  'seed-front.sh'                               "$DOC25" 2>/dev/null || d25="$d25 seeding-step"
# The step now REFUSES where nothing is declared to travel, and this passage is where the operator meets
# that precondition. Left as it was, the document says a working copy in that layout is simply born
# without the data — which reads as "carry on" against a mechanism that stops.
#
# Anchored to the PASSAGE, not to the file. A bare grep for the word passes on the fallback paragraph
# further down, which stops the opening for an unrelated reason — an assertion a neighbouring sentence
# can answer is not an assertion about this precondition at all.
PRE25="$(awk '/The precondition, stated plainly/{f=1} f&&/^$/{exit} f' "$DOC25" 2>/dev/null)"
printf '%s' "$PRE25" | grep -qiE 'refus'               || d25="$d25 the-refusal"
# Both branches, because the mechanism now distinguishes two empty selections and only one is a defect.
# A passage carrying the refusal alone tells the reader who commits their data directory that their
# layout is the broken one.
printf '%s' "$PRE25" | grep -qiE 'seeds successfully|still seeds' || d25="$d25 the-committed-layout"
# The exception the mechanism now carries, in the document that promises the operator the opposite.
# Both halves: the passage that lists the conditions and the paragraph that describes the step each
# said "never overwrites", and a reader who meets only the surviving one is told the wrong contract.
grep -qiE 'papers of the task it is seeded for|papers of the task you name' "$DOC25" 2>/dev/null \
  || d25="$d25 the-exception"
grep -qiE 'never overwrites (a file that is already there|what is already there)' "$DOC25" 2>/dev/null \
  && d25="$d25 unconditional-promise-still-there"
# Anchored to the CONDITIONS LIST, not to the file. The exception is stated twice in this document and a
# file-wide grep is answered by either — so the passage an operator walks per tool, deciding what their
# front-end leaves them to do by hand, can point at an exception it never states and still pass.
COND25="$(awk '/^2\. \*\*Data\*\*/{f=1} f&&/^$/{exit} f' "$DOC25" 2>/dev/null)"
printf '%s' "$COND25" | grep -qiE 'seeded for|task you name' || d25="$d25 the-exception-in-the-conditions-list"
printf '%s' "$COND25" | grep -qiE 'refus'                    || d25="$d25 the-refusal-in-the-conditions-list"
[ -z "$d25" ] \
  && ok "the operator's document carries the conditions and the seeding step" \
  || bad "the operator's document carries the conditions and the seeding step (missing:$d25)"

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
elif ! T25="$(mktemp -d 2>/dev/null)" || [ ! -d "$T25" ]; then
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
if ! T25D="$(mktemp -d 2>/dev/null)" || [ ! -d "$T25D" ]; then
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

echo "== C29: opening a front starts from the surface the operator works in =="
BLG31="global/protocols/backlog.md"
PY31="template/.ai-flow/project.yml"
TST31="template/.ai-flow/STATE.md"
DOC31="docs/customization.md"

# Same extractor as the block above, and for the same reasons: fence-aware section cut, one numbered
# move flattened and whitespace-squeezed, classified on the move NUMBER so a move that moved is still
# seen. Defined here rather than borrowed, so this block survives being reordered.
OPN31="$(awk '/^## Opening a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG31")"
CLO31="$(awk '/^## Closing a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG31")"
o31() { printf '%s\n' "$OPN31" | awk -v n="$1" '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==n' | tr '\n' ' ' | tr -s ' '; }
c31() { printf '%s\n' "$CLO31" | awk -v n="$1" '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==n' | tr '\n' ' ' | tr -s ' '; }

M5_31="$(o31 5)"
M5RAW31="$(printf '%s\n' "$OPN31" | awk '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==5')"
# The move's PREAMBLE — everything ahead of the first condition. The identification has to be the move's
# first act, and a sentence about it buried after the four conditions is a different claim: it would read
# as something to do once the checkout exists, which is exactly the order that produced the incident.
HEAD31="$(printf '%s' "$M5_31" | sed 's/ - \*\*base\*\*.*//')"

# One condition bullet, by its own label. Every facet of the asymmetry is asserted INSIDE the bullet it
# belongs to: read over the whole move, `by hand` is answered by the sentence introducing the list and
# `every path` by the data bullet and the floor paragraph, so three of the four attributions could be
# deleted with the guard green. A facet a neighbouring sentence can satisfy reports the list as present
# while it is missing — the discipline this block already applies to the docs side.
b31() {  # $1 = condition label -> that bullet's text, flattened
  printf '%s\n' "$M5RAW31" | awk -v lab="- **$1**" '
    !f && index($0, lab) { f = 1; print; next }
    f && ($0 ~ /^[[:space:]]*$/ || $0 ~ /^   - \*\*/) { exit }
    f { print }' | tr '\n' ' ' | tr -s ' '
}

if [ -n "$M5_31" ]; then
  # A1 — the first act. The truncation is asserted before anything is concluded from it: `sed` reports
  # nothing when its pattern is absent, so a relabelled or reordered first condition would leave HEAD31
  # equal to the whole move and quietly turn this from an assertion about ORDER into one about presence —
  # satisfied by a sentence sitting after the conditions, which is the order that produced the incident.
  a1=""
  [ "$HEAD31" != "$M5_31" ] || a1="$a1 preamble-boundary-not-found"
  printf '%s' "$HEAD31" | grep -qE '\*\*(base|data|visibility|ownership)\*\*' && a1="$a1 preamble-cut-too-late"
  printf '%s' "$HEAD31" | grep -qiE 'identif'                            || a1="$a1 no-identification"
  printf '%s' "$HEAD31" | grep -qiE 'front_tool|the project (declares|is managed in)' || a1="$a1 nothing-to-read-it-from"
  [ -z "$a1" ] \
    && ok "the creation move identifies the project's tool before it creates anything" \
    || bad "the creation move identifies the project's tool before it creates anything (missing:$a1)"

  # A2a — the half of the split claim that says WHICH path comes first. Written as an ordered
  # co-occurrence inside one sentence rather than as a fixed phrase: what must hold is that the SUBJECT
  # of "the default" is the project's tool, and a bare word match is answered by any neighbouring
  # sentence that happens to carry it — including the base condition's own "published default branch".
  printf '%s' "$M5_31" | grep -qiE "(the (project'?s )?(declared )?tool|the tool the project (declares|is managed in))[^.]{0,120}is the default" \
    && ok "the creation move names the project's tool as the default" \
    || bad "the creation move names the project's tool as the default"

  # A2b — the weld itself, as a class and across every layer that could restate it. The floor half stays
  # asserted in the block above; what must never come back is the two claims sharing one predicate,
  # because that is the reading that stopped the question from being formed.
  w31="$(grep -rniE 'default and the floor' global docs template 2>/dev/null | wc -l | tr -d ' ')"
  [ "$w31" = "0" ] \
    && ok "no document welds the default and the floor into one claim" \
    || bad "no document welds the default and the floor into one claim ($w31 line(s))"

  # A5 — the undeclared case. A silence and a declaration read identically in a report, so the move has
  # to say it is falling back rather than simply doing it.
  a5=""
  printf '%s' "$M5_31" | grep -qiE 'declares (no|none|nothing)|no tool is declared|undeclared' || a5="$a5 case-not-named"
  printf '%s' "$M5_31" | grep -qiE '(declares (no|none|nothing)|undeclared)[^.]{0,200}(say|states|named|names)' || a5="$a5 not-stated"
  [ -z "$a5" ] \
    && ok "an undeclared front tool is a stated fallback, not a silent default" \
    || bad "an undeclared front tool is a stated fallback, not a silent default (missing:$a5)"

  # A3 — the asymmetry, asserted inside each condition it attributes. Facets named individually: a single
  # verdict over four facts cannot be acted on, and this is the list an operator reads to know what they
  # are paying for. An empty cut is its own failure, never a silently satisfied facet.
  a3=""
  for cond31 in base data visibility ownership; do
    [ -n "$(b31 "$cond31")" ] || a3="$a3 no-$cond31-bullet"
  done
  printf '%s' "$(b31 base)"       | grep -qiE 'worktree\.baseRef'            || a3="$a3 base-native-mechanism"
  printf '%s' "$(b31 base)"       | grep -qiE 'by hand'                      || a3="$a3 base-by-hand"
  printf '%s' "$(b31 data)"       | grep -qiE 'worktreeinclude'              || a3="$a3 data-native-mechanism"
  printf '%s' "$(b31 data)"       | grep -qiE 'by hand'                      || a3="$a3 data-by-hand"
  printf '%s' "$(b31 visibility)" | grep -qiE 'per.tool|tool by tool|depends on the tool' || a3="$a3 visibility-per-tool"
  printf '%s' "$(b31 ownership)"  | grep -qiE 'every path|on any path'       || a3="$a3 ownership-universal"
  printf '%s' "$M5_31"            | grep -qiE 'without help'                 || a3="$a3 native-gets-free"
  # The attribution rule itself, added because a field measurement falsified the absolute this list used
  # to state: a tool whose help never mentions the pattern file was found transferring exactly what it
  # selects. What a tool brings is a fact about the checkout, not about the documentation — and a
  # correction needs a guard as much as a feature does, or it is revertible with the suite green.
  printf '%s' "$M5_31" | grep -qiE 'read from the checkout' || a3="$a3 attribution-read-from-the-checkout"
  printf '%s' "$(b31 data)" | grep -qiE 'per.tool and per.version|per.version' || a3="$a3 data-not-absolute"
  [ -z "$a3" ] \
    && ok "the creation move says which conditions a non-native tool takes on by hand" \
    || bad "the creation move says which conditions a non-native tool takes on by hand (missing:$a3)"

  # A4 — the acknowledgement. The consequence the four conditions cannot express is the operator's own
  # view of the front, and an obligation with no written trace is the visibility condition's own defect
  # repeated: nothing reads it, nothing acts on it.
  # The gate is the half that matters, and the three facets below could all be met by a note written
  # after the checkout exists. What the criterion says is that the opening does not continue until the
  # line is on the sheet, so the halt and the resumption are pinned too — the wording move 3 already
  # uses for the collision this one is modelled on.
  a4=""
  printf '%s' "$M5_31" | grep -qiE 'fall(s|ing)? back|falls back'          || a4="$a4 fallback-not-named"
  printf '%s' "$M5_31" | grep -qiE 'acknowledg'                            || a4="$a4 no-acknowledgement"
  printf '%s' "$M5_31" | grep -qiE "task'?s (own )?sheet"                  || a4="$a4 no-home-for-it"
  printf '%s' "$M5_31" | grep -qiE 'resumes only once|does not continue until|only once that is' || a4="$a4 not-a-gate"
  [ -z "$a4" ] \
    && ok "falling back to the native path is acknowledged in writing on the task's sheet" \
    || bad "falling back to the native path is acknowledged in writing on the task's sheet (missing:$a4)"

  # A6 — the JOIN, not each half. The move names a key, the template documents one and the guide shows
  # one; nothing compared them, and that is the hole a rename walks through. The key is READ from the
  # protocol and looked for everywhere it must also appear.
  KEY31="$(printf '%s' "$M5_31" | grep -oE '`[a-z_]+` in `project\.yml`' | head -1 | tr -d '`' | awk '{print $1}')"
  if [ -n "$KEY31" ]; then
    ok "the creation move names the key it reads ($KEY31)"
    # As a KEY, never as a word: the guide and the template both discuss tools in prose, so a bare word
    # match is answered by a neighbouring sentence.
    keyed31() { printf '%s' "$1" | grep -qE "(^|[[:space:]#])${KEY31}:"; }
    # The key's own comment BLOCK — the run of consecutive comment lines it closes. A fixed -B window is
    # a line count masquerading as a structure: the block is five lines today and any edit to the prose
    # moves the facts out of the window while leaving them exactly where a reader finds them.
    BLK31="$(awk -v key="${KEY31}:" '
      /^#/ { buf = buf $0 "\n"; if (index($0, key)) { printf "%s", buf; exit } next }
      { buf = "" }' "$PY31")"
    if keyed31 "$(cat "$PY31")" \
       && printf '%s' "$BLK31" | grep -qi 'optional' \
       && ! grep -qE "^[[:space:]]*${KEY31}:" "$PY31"; then
      ok "the shipped template documents the same key as optional and declares none"
    else
      bad "the shipped template documents the same key as optional and declares none"
    fi
    keyed31 "$(awk '/^```yaml/{f=1;next} /^```/{f=0} f' "$DOC31")" \
      && ok "the schema the docs show carries the same key" \
      || bad "the schema the docs show carries the same key"
    # The LEVEL, not only the spelling. It holds a name and not a command, and an adopter who writes it
    # under `commands:` gets a file the ceremony reads as declaring nothing — the join pinned the word
    # and left the one thing a reader actually gets wrong unpinned.
    l31=""
    grep -qE "^#[[:space:]]*${KEY31}:" "$PY31"                    || l31="$l31 template-not-top-level"
    # Read from the comment BLOCK around the key, not from the key's own line: the two facts live on
    # different lines by construction, and a same-line grep asks for a sentence nobody would write.
    printf '%s' "$BLK31" | grep -qiE 'top.level'                   || l31="$l31 template-says-nothing"
    printf '%s' "$(awk '/^```yaml/{f=1;next} /^```/{f=0} f' "$DOC31")" | grep -qiE "${KEY31}[^#]*#.*top.level" \
      || l31="$l31 docs-says-nothing"
    [ -z "$l31" ] \
      && ok "both homes say the key is top-level, not a command" \
      || bad "both homes say the key is top-level, not a command (missing:$l31)"
    # A re-derive writes project.yml from scratch and knows only the required keys, so an optional one
    # this task added is deleted with nothing said. The protocol that writes the file is where that is
    # prevented; the ceremony that reads the key would otherwise report the project as declaring none.
    grep -qE "${KEY31}" global/protocols/discover.md \
      && ok "the protocol that rewrites the project sheet carries the optional key over" \
      || bad "the protocol that rewrites the project sheet carries the optional key over"
  else
    bad "the creation move names the key it reads"
    bad "the shipped template documents the same key as optional and declares none (no key named)"
    bad "the schema the docs show carries the same key (no key named)"
  fi

  # O1's machine half — the operator's guide is a second home for the same rules and can go stale.
  # Scoped to the section it is about, then to each item inside it — a file-wide grep over the guide is
  # answered from anywhere, and this same task added a schema comment a hundred lines above that carries
  # `identif` and would answer for the paragraph the facet exists to pin. The reference pattern for a
  # second-home check in this suite cuts the region first (the distribution join does exactly that with
  # the guide's fenced block), and the asymmetry facets are asserted per numbered item for the reason
  # the protocol side is: `by hand` is answered by the paragraph above the list and `every path` by the
  # data item, so the base and ownership attributions were pinned by nothing.
  SEC31="$(awk '/^### Parallel workstreams/{f=1} (f && /^## /){f=0} f' "$DOC31")"
  i31() {  # $1 = list item number -> that numbered item's text, flattened
    printf '%s\n' "$SEC31" | awk -v n="$1" '
      $0 ~ "^"n"\\. \\*\\*" { f = 1; print; next }
      f && ($0 ~ /^[0-9]+\. \*\*/ || $0 ~ /^[[:space:]]*$/) { exit }
      f { print }' | tr '\n' ' ' | tr -s ' '
  }
  d31=""
  [ -n "$SEC31" ] || d31="$d31 section-not-found"
  for n31 in 1 2 3 4; do [ -n "$(i31 "$n31")" ] || d31="$d31 no-item-$n31"; done
  printf '%s' "$SEC31" | grep -qiE 'identif[^.]{0,120}tool this project is managed in' || d31="$d31 first-step"
  printf '%s' "$(i31 1)" | grep -qiE 'by hand'    || d31="$d31 base-by-hand"
  printf '%s' "$(i31 2)" | grep -qiE 'by hand'    || d31="$d31 data-by-hand"
  printf '%s' "$(i31 3)" | grep -qiE 'per.tool'   || d31="$d31 visibility-per-tool"
  printf '%s' "$(i31 4)" | grep -qiE 'every path' || d31="$d31 ownership-universal"
  printf '%s' "$SEC31" | grep -qiE 'acknowledg'   || d31="$d31 acknowledgement"
  printf '%s' "$SEC31" | grep -qiE 'read from the checkout' || d31="$d31 attribution-read-from-the-checkout"
  [ -z "$d31" ] \
    && ok "the operator's document carries the first step, the asymmetry and the acknowledgement" \
    || bad "the operator's document carries the first step, the asymmetry and the acknowledgement (missing:$d31)"
else
  for m in \
    "the creation move identifies the project's tool before it creates anything" \
    "the creation move names the project's tool as the default" \
    "an undeclared front tool is a stated fallback, not a silent default" \
    "the creation move says which conditions a non-native tool takes on by hand" \
    "falling back to the native path is acknowledged in writing on the task's sheet" \
    "the creation move names the key it reads" \
    "the shipped template documents the same key as optional and declares none" \
    "the schema the docs show carries the same key" \
    "the operator's document carries the first step, the asymmetry and the acknowledgement"; do
    bad "$m (creation move not found)"
  done
  bad "no document welds the default and the floor into one claim (creation move not found)"
fi

# --- what created the front, recorded and read ---------------------------
# The roster is the front-scoped paper — the same reason the declared areas live there — and it is still
# present when the dismantling move runs, because the row is removed after it and not before.
r31=""
grep -qiE '^\|[^|]*workstream[^|]*\|.*\|[^|]*tool[^|]*\|' "$TST31" 2>/dev/null || r31="$r31 template-column"
# A header row alone is not a table: a delimiter row of the old width renders the column away, and the
# example row is what tells an operator the cell takes a value at all.
# Scoped to the Workstreams table: the file carries a second one (Quick Tasks) of a different width, so
# a check that measures every pipe-line in the file compares two tables and calls the pair ragged.
WSTBL31="$(awk '/^## Workstreams/{f=1;next} (f && /^## /){f=0} (f && /^\|/)' "$TST31" 2>/dev/null)"
[ "$(printf '%s\n' "$WSTBL31" | grep -c '^|')" -ge 3 ] || r31="$r31 template-no-example-row"
[ "$(printf '%s\n' "$WSTBL31" | awk -F'|' '{print NF}' | sort -u | wc -l | tr -d ' ')" = 1 ] || r31="$r31 template-ragged-table"
printf '%s\n' "$(awk '/^## State Files/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG31")" \
  | grep -qiE '^\|[^|]*workstream[^|]*\|.*\|[^|]*tool[^|]*\|' || r31="$r31 protocol-column"
# Anchored to the ROW, in the ordered-co-occurrence shape used for the default claim: move 7 describes
# two papers, and `tool` anywhere in it is satisfied by a sentence putting the creator on the SHEET —
# which would leave the closing move, that reads it from the row, with nothing. A writer and a reader
# disagreeing about which paper holds the datum is the one thing this join exists to catch.
printf '%s' "$(o31 7)" | grep -qiE 'row carries[^.]{0,200}(what created|the tool)' || r31="$r31 no-writer"
[ -z "$r31" ] \
  && ok "the roster records what created each front, on both sides and with a writer" \
  || bad "the roster records what created each front, on both sides and with a writer (missing:$r31)"

# A row that predates the column is not broken, and the clause that says so is what keeps a migration
# from reading as a defect — the shape the Areas column already established.
grep -qiE 'predates the \*\*tool\*\* column|predates the tool column' "$BLG31" \
  && ok "a roster that predates the tool column is not broken" \
  || bad "a roster that predates the tool column is not broken"

# A8 — the reader. Ownership had no reader at all: the move said "whatever created it" and nothing
# recorded what that was.
printf '%s' "$(c31 6)" | grep -qiE 'roster' \
  && ok "the dismantling move reads the creator from the roster row" \
  || bad "the dismantling move reads the creator from the roster row"

# B3 (regression) — the ordinary opening must not get heavier. The preamble says which moves have
# nothing to do with one front open; the creation move has to stay inside that set, or a project with a
# single front is now told to identify a tool for a checkout nobody is creating.
PRE31="$(printf '%s\n' "$OPN31" | awk '/^1\. /{exit} {print}' | tr '\n' ' ' | tr -s ' ')"
# The set is a RANGE in the prose ("steps 3 to 6"), so the membership test reads the range rather than
# hunting for a literal digit: asking for '5' in the characters of "3 to 6" answers no on a sentence
# that says yes, and the check would then demand a change to a preamble that is already correct.
covers31() {  # 0 when the preamble's "nothing to do" set contains move 5
  printf '%s' "$1" | grep -qiE 'nothing to do' || return 1
  printf '%s' "$1" | awk '
    { n = 0
      while (match($0, /[0-9]+ (to|-|through) [0-9]+/)) {
        s = substr($0, RSTART, RLENGTH); $0 = substr($0, RSTART + RLENGTH)
        split(s, p, /[^0-9]+/); if (p[1] <= 5 && 5 <= p[2]) n = 1
      }
      exit n ? 0 : 1 }'
}
if covers31 "$PRE31"; then
  ok "the single-front reduction still covers the creation move"
else
  bad "the single-front reduction still covers the creation move"
fi

# --- the installer names the ignore line the native path needs -----------
# Executed, not grepped: a message found in the source proves the message exists, never that anything
# reaches it. The prompts are answered rather than closed, for the reason the block above records.
if ! T31="$(mktemp -d 2>/dev/null)" || [ ! -d "$T31" ]; then
  bad "install names the ignore line the native worktree path needs (no sandbox: mktemp -d failed)"
else
  H31="$T31/home"; A31="$T31/adopt"; mkdir -p "$H31" "$A31"
  ( cd "$T31" && printf 'n\nn\n' | HOME="$H31" bash "$ROOT/install.sh" init "$A31" ) > "$T31/init.out" 2>&1 || true
  # Both halves of "names and does not write". The negative half is the load-bearing one: a project's
  # ignore rules are the project's own, and an installer that edits them has taken a decision nobody
  # delegated. Asserted on the filesystem, because the notice's own wording cannot prove abstention.
  if grep -q '\.claude/worktrees/' "$T31/init.out" && [ ! -e "$A31/.gitignore" ]; then
    ok "install names the ignore line the native worktree path needs and writes none"
  else
    bad "install names the ignore line the native worktree path needs and writes none"
  fi
  rm -rf "$T31"
fi

echo "== C30: the rule that governs the engine is versioned and loads itself =="
# The defect pinned here: the governing test lived inside a path the repository ignores, so no
# gitignore-respecting search reached it and nothing in the flow read it. Its home is now the file every
# session in this project loads on its own, which is what satisfies its read trigger without a step.
MAN30="CLAUDE.md"
NG30="multi-agent portability"

# The whole test, not a summary of it: each key is a distinct load-bearing part. The verdict names the
# parts that are absent, because a single boolean would say the file is wrong without saying which half
# of the rule went missing — and half a governing rule reads as a complete one.
if [ -f "$MAN30" ]; then
  miss30=""
  for k in \
    "before proposing ANY change to the engine" \
    "demanding requirements discipline" \
    "Rigor is kept" \
    "Weight is cut" \
    "working alone forgets" \
    "Cost ladder" \
    "derived check" \
    "enterprise coordination" \
    "multi-agent portability"
  do
    grep -qF "$k" "$MAN30" || miss30="$miss30 [$k]"
  done
  [ -z "$miss30" ] \
    && ok "the root manual carries the governing test whole" \
    || bad "the root manual carries the governing test whole (absent:$miss30)"
else
  bad "the root manual carries the governing test whole ($MAN30 is not there)"
fi

# Asked of git, because the search that failed is the one that respects .gitignore. git grep answers for
# the index, so a file merely present on disk is still invisible to it — which is exactly the state this
# refuses. The verdict reads a count and never the pipeline's status: git grep exits 1 when it matches
# nothing, an ordinary answer, and a status-derived verdict cannot tell that from git failing to run.
#
# This file is excluded from the search, and the exclusion is the assertion. Naming the thesis in order
# to look for it puts it in a versioned file, so without this the guard passes on its own text — green
# from the moment it is written and forever after, whatever the project's manual says.
n30="$($GIT grep -lF "demanding requirements discipline" -- . ':(exclude)test/validate.sh' 2>/dev/null | wc -l | tr -d ' ')"
case "${n30:-0}" in
  0) bad "the governing test is reachable by a versioned search (no versioned file carries the thesis)" ;;
  *) ok  "the governing test is reachable by a versioned search ($n30 file(s))" ;;
esac

# Scoped to the section the task names, not to the file. The thesis appearing anywhere in a long README
# would satisfy a file-wide grep while the front door itself still said nothing.
why30="$(sed -n '/^## Why ai-flow?/,/^## /p' README.md)"
if printf '%s' "$why30" | grep -q .; then
  miss30w=""
  for k in "demanding requirements discipline" "enterprise coordination" "multi-agent portability"; do
    printf '%s\n' "$why30" | grep -qF "$k" || miss30w="$miss30w [$k]"
  done
  [ -z "$miss30w" ] \
    && ok "the front door states the thesis and both refusals" \
    || bad "the front door states the thesis and both refusals (absent:$miss30w)"
else
  bad "the front door states the thesis and both refusals (no '## Why ai-flow?' section in README.md)"
fi

# Narrowed on purpose: the decision log is legitimately named by a directory tree and an installer note
# in files this task does not touch, so a repo-wide ban would go red on content that is not the defect.
# What is refused is a refusal that defers its reason to a file nobody else can open. Counted rather than
# piped into a verdict: grep on empty input reports success on this platform, so a status-derived verdict
# would read the same whether or not a citation was there.
cit30="$($GIT grep -nF "$NG30" -- "$MAN30" README.md 2>/dev/null | grep -cF "decisions-global")"
[ "${cit30:-0}" = 0 ] \
  && ok "no refusal defers its reason to the unversioned decision log" \
  || bad "no refusal defers its reason to the unversioned decision log ($cit30 line(s) cite it)"

# The positive half. A refusal stated without its reason is the one that gets re-argued a year later, so
# both public files have to carry it — asked of each separately, because one carrying it is not the two.
why30r=""
for f in "$MAN30" README.md; do
  if [ -f "$f" ]; then
    grep -qF "dilute" "$f" || why30r="$why30r [$f]"
  else
    why30r="$why30r [$f absent]"
  fi
done
[ -z "$why30r" ] \
  && ok "each refusal carries its reason" \
  || bad "each refusal carries its reason (missing in:$why30r)"

# The cost ladder is a rule for the maintainer, not a selling point, and it stays out of the front door
# deliberately. A negative criterion is vacuously true before the change lands, so this one was sized by
# inserting the phrase and watching this verdict go red, then restoring the file byte-exact against a
# hash taken first. Without that, a guard over an absence is green from birth and proves nothing.
lad30="$(grep -cE "Cost ladder|derived check" README.md)"
[ "${lad30:-0}" = 0 ] \
  && ok "the cost ladder stays out of the front door" \
  || bad "the cost ladder stays out of the front door ($lad30 line(s))"

echo "== C31: the Bash rail judges the fields it can read =="
# The first behavioural coverage this rail has ever had. Until now the only assertions naming it counted
# its entry in settings.json, which is installer structure — so there was no positive control anywhere in
# this file to borrow, and A4 builds one here, in the same fixture as the payload checks. That control is
# load-bearing rather than decorative: "exit 0, no traceback" is satisfied by a rail that exits 0
# unconditionally, and going quiet, not crashing, is this rail's real failure mode.
#
# Scope: the payload the rail reads, and nothing about how it matches a command. The matcher is a task of
# its own; three audit passes established that judging a shell command by pattern needs more than this
# section can hold, and the evidence went back to the backlog with it.
if [ "$PY3" = 1 ]; then
  GS="$HK/git-safety.py"
  graw() {  # $1 = raw payload -> prints combined output, returns the hook's exit code
    printf '%s' "$1" | python3 "$GS" 2>&1
  }
  gcmd() {  # $1 = command string -> same, wrapped in a well-formed payload
    python3 -c 'import json,sys; print(json.dumps({"tool_input":{"command":sys.argv[1]}}))' "$1" \
      | python3 "$GS" 2>&1
  }

  # --- Step 1: a field the rail cannot read is a command it cannot judge ----
  # Each check below drives several payload shapes and reports ONE verdict, naming the shapes that
  # failed. Silence, not merely the absence of a crash: a rail that stands aside with a diagnostic is
  # chatter on every Bash command, and a traceback is named separately so a crash still reads as a crash.
  waved() {  # $1 = label, $2.. = raw payloads -> one verdict for the whole set
    label="$1"; shift; whyw=""
    for p in "$@"; do
      out="$(graw "$p")"; rc=$?
      if [ "$rc" != 0 ] || [ -n "$out" ]; then
        case "$out" in
          *Traceback*) whyw="$whyw [$p -> exit $rc, traceback]" ;;
          *)           whyw="$whyw [$p -> exit $rc, said: $out]" ;;
        esac
      fi
    done
    [ -z "$whyw" ] && ok "$label" || bad "$label ($whyw)"
  }

  # The oldest arm of the promise and the one nothing had ever sent: this rail has no dict check at all,
  # so every one of these is a traceback today. `null` and `true` were in nobody's report — the reach of
  # the hardening is measured from what the code reads, not from what was noticed.
  waved "a top-level payload that is not an object is waved through in silence" \
    '["x"]' '"oops"' '7' 'null' 'true'

  # A truthy non-object only: a falsy one (`null`, `[]`, `""`, `0`) already survives through `or {}` and
  # must keep surviving. The line is drawn at the type, not at emptiness.
  waved "a tool_input that is not an object is waved through in silence" \
    '{"tool_input":"oops"}' '{"tool_input":["a"]}' '{"tool_input":7}'

  # Truthy non-strings, which reach the first regex and raise there rather than at the read. `true` is
  # in the set because a bool is not a str and nothing else in this file would have noticed.
  waved "a command that is not a string is waved through in silence" \
    '{"tool_input":{"command":123}}' '{"tool_input":{"command":["git","push"]}}' \
    '{"tool_input":{"command":{"a":1}}}' '{"tool_input":{"command":true}}'

  # The control, and it is the load-bearing assertion of this whole group: without it the three checks
  # above are all satisfied by a rail that exits 0 unconditionally, and their verdict would be borrowed
  # from elsewhere in this file, which is no verdict at all.
  #
  # What it controls for changed with the rail's job. It used to drive a hard force-push, because the
  # rail judged commands; the rail no longer judges any command, so that fixture would now be green for
  # a reason unrelated to what it is named for. The control is the same shape against the new job: a
  # repository with no protection in place, where the rail must refuse and say so. It is driven from a
  # fixture whose state is known rather than from whatever repository this suite happens to run in.
  # A sandboxed HOME as well as a fixture repository: the rail resolves the engine's hook directory from
  # HOME, so a control that leaves it real reads the state of the machine running the suite and inverts
  # once the installer has been run there. The engine copies here are throwaway and executable, so the
  # fixture reaches the question it means to ask instead of stopping at "no engine hooks installed".
  C31H="$T11/c31home"; mkdir -p "$C31H/.claude/hooks/git"
  printf '#!/bin/sh\nexit 0\n' > "$C31H/.claude/hooks/git/pre-push"
  printf '#!/bin/sh\nexit 0\n' > "$C31H/.claude/hooks/git/pre-commit"
  chmod 755 "$C31H/.claude/hooks/git/pre-push" "$C31H/.claude/hooks/git/pre-commit"
  C31R="$T11/c31rail"; mkproj "$C31R" main
  out="$(printf '{"cwd":"%s","tool_input":{"command":"git push origin main"}}' "$C31R" | HOME="$C31H" python3 "$GS" 2>&1)"; rc=$?
  case "$out" in *"not active in this repository"*) said=1 ;; *) said=0 ;; esac
  { [ "$rc" = 2 ] && [ "$said" = 1 ]; } \
    && ok "the same fixture still refuses where the protection is not in place" \
    || bad "the same fixture still refuses where the protection is not in place (exit $rc, said: $out)"
else
  echo "  [skip] Bash rail checks (python3 unavailable)"
fi

# C32 is retired here, in the same change that removes the matcher it tested. Its rows are not dropped:
# every shape in both of its tables lives on in C33 and C34, migrated from matching a command's spelling
# to executing the operation and letting git compute the effect. The migration is recorded in the task's
# conformance manifest rather than left to be reconstructed from this diff.

echo "== C33: the trunk is defended from what git reports, not from what a command says =="
# The whole section drives REAL operations against a real bare remote rather than feeding strings to a
# matcher. That is the point and not a stylistic preference: a shape stops being a spelling somebody had
# to think of and becomes an operation whose effect git computes, so the coverage no longer depends on
# anyone having imagined the wrapping.
#
# Two traps are designed against here, both met during this work rather than anticipated:
#
#   * A fixture that never lets an operation land measures a stale remote. An early measurement reported
#     an ordinary advance for what was a rewrite, because its hook refused everything and the remote
#     therefore never moved. Every allow-side row below asserts the remote actually changed.
#   * Git protects the branch a remote's HEAD points at from deletion all by itself. A deletion row
#     driven against such a remote would pass without this guard existing. The deletion fixture points
#     its remote's HEAD elsewhere, and a control proves the deletion really does succeed once the guard
#     is out of the way.
if command -v git >/dev/null 2>&1; then
  GHK="$ROOT/global/hooks/git"
  T33="$T11/c33"; mkdir -p "$T33"
  NOHOOK="$T33/nohook"; mkdir -p "$NOHOOK"   # an empty hook path: setup work bypasses the guard

  mkpair33() {  # $1 = fixture name, $2 = the branch the remote's HEAD names -> remote.git + work
    d33="$T33/$1"; rm -rf "$d33"; mkdir -p "$d33"
    git init -q --bare "$d33/remote.git"
    git -C "$d33/remote.git" symbolic-ref HEAD "refs/heads/$2"
    git init -q "$d33/work"
    git -C "$d33/work" symbolic-ref HEAD refs/heads/main
    git -C "$d33/work" config user.email t@t.t
    git -C "$d33/work" config user.name t
    git -C "$d33/work" config commit.gpgsign false
    git -C "$d33/work" config push.default current
    printf 'a\n' > "$d33/work/f.txt"
    git -C "$d33/work" add -A >/dev/null 2>&1
    git -C "$d33/work" commit -q -m one
    git -C "$d33/work" remote add origin "$d33/remote.git"
    git -C "$d33/work" -c core.hooksPath="$NOHOOK" push -q origin main
    git -C "$d33/work" config core.hooksPath "$GHK"
  }
  free33()  { git -C "$T33/$1/work" -c core.hooksPath="$NOHOOK" "${@:2}"; }  # the guard stood down
  ref33()   { git -C "$T33/$1/remote.git" rev-parse -q --verify "refs/heads/$2" 2>/dev/null || echo none; }
  run33()   { ( cd "$T33/$1/work" && shift && git "$@" 2>&1 ); }
  sh33()    { ( cd "$T33/$1/work" && bash -c "$2" 2>&1 ); }
  rewritable33() {  # $1 = fixture, $2 = branch -> exists on the remote AND diverges from it locally
    git -C "$T33/$1/work" checkout -q -B "$2" main
    printf 'x\n' >> "$T33/$1/work/f.txt"
    git -C "$T33/$1/work" commit -qam "$2"
    free33 "$1" push -q origin "$2"
    git -C "$T33/$1/work" commit -q --amend -m "$2 rewritten"
    git -C "$T33/$1/work" checkout -q main
  }
  diverge33() {  # $1 = fixture -> remote trunk at one commit, local trunk at a different one
    printf 'b\n' >> "$T33/$1/work/f.txt"
    git -C "$T33/$1/work" commit -qam two
    free33 "$1" push -q origin main
    git -C "$T33/$1/work" commit -q --amend -m two-rewritten
  }

  # --- row 1: a rewrite, refused, with the remote proven untouched ---------
  mkpair33 rw main; diverge33 rw
  b33="$(ref33 rw main)"; out="$(run33 rw push --force origin main)"; rc=$?; a33="$(ref33 rw main)"
  case "$out" in *"rewriting refs/heads/main"*) named=1 ;; *) named=0 ;; esac
  if [ "$rc" != 0 ] && [ "$b33" = "$a33" ] && [ "$named" = 1 ]; then
    ok "a rewrite of the trunk on the remote is refused"
  else
    bad "a rewrite of the trunk on the remote is refused (exit $rc, remote $b33 -> $a33, said: $out)"
  fi

  # --- row 5: the lease is not an exemption --------------------------------
  # The refusal's own wording is asserted, not merely its exit code: a stale lease makes git refuse on
  # its own, and a row reading only the code would pass without this guard existing.
  out="$(run33 rw push --force-with-lease origin main)"; rc=$?; a33="$(ref33 rw main)"
  case "$out" in *"rewriting refs/heads/main"*) named=1 ;; *) named=0 ;; esac
  if [ "$rc" != 0 ] && [ "$b33" = "$a33" ] && [ "$named" = 1 ]; then
    ok "a lease does not exempt a rewrite of the trunk"
  else
    bad "a lease does not exempt a rewrite of the trunk (exit $rc, remote $b33 -> $a33, said: $out)"
  fi

  # --- row 6: an operation that sends every ref still has the trunk judged --
  why33=""
  for wide in "push --mirror origin" "push --all --force origin" "push --branches --force origin"; do
    out="$(run33 rw $wide)"; rc=$?; a33="$(ref33 rw main)"
    { [ "$rc" != 0 ] && [ "$b33" = "$a33" ]; } || why33="$why33 [$wide -> exit $rc, remote $b33 -> $a33]"
  done
  [ -z "$why33" ] && ok "a push that sends every ref still has the trunk judged among them" \
                  || bad "a push that sends every ref still has the trunk judged among them ($why33)"

  # --- row 2: a deletion, on a remote where git itself would allow it ------
  mkpair33 del keep
  git -C "$T33/del/work" branch -q keep
  free33 del push -q origin keep
  why33=""
  for spell in "push origin --delete main" "push origin :main" "push origin -d main" "push origin +:main"; do
    out="$(run33 del $spell)"; rc=$?
    { [ "$rc" != 0 ] && [ "$(ref33 del main)" != none ]; } || why33="$why33 [$spell -> exit $rc]"
    case "$out" in *"deleting refs/heads/main"*) ;; *) why33="$why33 [$spell -> not named: $out]" ;; esac
  done
  [ -z "$why33" ] && ok "a deletion of the trunk on the remote is refused" \
                  || bad "a deletion of the trunk on the remote is refused ($why33)"
  # The control for that row: with the guard stood down the same deletion really does succeed, so the
  # refusals above are this hook's and not git's own protection of a remote's HEAD branch.
  free33 del push -q origin :main >/dev/null 2>&1
  [ "$(ref33 del main)" = none ] && ok "the deletion the guard refused is one git itself would allow" \
    || bad "the deletion the guard refused is one git itself would allow (it survived the unguarded attempt too)"

  # --- row 3: an ordinary advance, allowed, with the remote proven to move --
  mkpair33 ff main
  b33="$(ref33 ff main)"
  printf 'c\n' >> "$T33/ff/work/f.txt"; git -C "$T33/ff/work" commit -qam three
  out="$(run33 ff push origin main)"; rc=$?; a33="$(ref33 ff main)"
  if [ "$rc" = 0 ] && [ "$b33" != "$a33" ] && [ "$a33" != none ]; then
    ok "an ordinary advance of the trunk is allowed"
  else
    bad "an ordinary advance of the trunk is allowed (exit $rc, remote $b33 -> $a33, said: $out)"
  fi

  # --- creating the trunk on a remote that does not have it yet ------------
  # The only arm that lets a first push of the trunk through, and nothing drove it: deleting the arm
  # blocks every initial push to a new remote and the suite stayed green. A create destroys nothing,
  # which is why it is allowed and why it must be witnessed.
  # A second remote that has never seen the trunk. Emptying the first one is not the way: its HEAD names
  # the trunk, and git refuses to remove the branch a remote's HEAD points at — the fixture would then
  # be measuring git's protection rather than building the state it needs.
  mkpair33 fresh main
  git init -q --bare "$T33/fresh/empty.git"
  git -C "$T33/fresh/work" remote add blank "$T33/fresh/empty.git"
  b33="$(git -C "$T33/fresh/empty.git" rev-parse -q --verify refs/heads/main 2>/dev/null || echo none)"
  out="$(run33 fresh push blank main)"; rc=$?
  a33="$(git -C "$T33/fresh/empty.git" rev-parse -q --verify refs/heads/main 2>/dev/null || echo none)"
  if [ "$b33" = none ] && [ "$rc" = 0 ] && [ "$a33" != none ]; then
    ok "creating the trunk on a remote that lacks it is allowed"
  else
    bad "creating the trunk on a remote that lacks it is allowed (before=$b33 exit=$rc after=$a33, said: $out)"
  fi

  # --- row 4: every other ref, whatever its shape --------------------------
  mkpair33 other main
  why33=""
  for br in feat release/2.0 fix/main-nav docs/maintenance feature/main-menu; do
    rewritable33 other "$br"
    out="$(run33 other push --force origin "$br")"; rc=$?
    [ "$rc" = 0 ] || why33="$why33 [$br -> exit $rc, said: $out]"
  done
  # A tag, moved rather than created, for the same reason the branches are rewritten above.
  git -C "$T33/other/work" tag -f v1 main >/dev/null 2>&1
  free33 other push -q --force origin v1
  printf 'y\n' >> "$T33/other/work/f.txt"
  git -C "$T33/other/work" commit -qam tagmove
  git -C "$T33/other/work" tag -f v1 >/dev/null 2>&1
  out="$(run33 other push --force origin v1)"; rc=$?
  [ "$rc" = 0 ] || why33="$why33 [tag v1 -> exit $rc, said: $out]"
  [ -z "$why33" ] && ok "a push to any other ref is allowed whatever its shape" \
                  || bad "a push to any other ref is allowed whatever its shape ($why33)"

  # --- row 22: a ref that merely ends in the trunk's word ------------------
  # The withdrawn rule read the trunk from a ref's trailing segment. Git accepts these as ordinary
  # branches and reports them whole, so that rule refused work while protecting nothing extra.
  # Each branch is landed and then rewritten, never merely created: a create is allowed by an arm of
  # its own, so a row that only creates never reaches the test it claims to guard. Written after the
  # mutation round proved exactly that — this row and the one above survived the two mutations they
  # exist to catch, and the fault was here, not in the hook.
  why33=""
  for br in hotfix/main team/master archive/2019/main; do
    rewritable33 other "$br"
    out="$(run33 other push --force origin "$br")"; rc=$?
    [ "$rc" = 0 ] || why33="$why33 [$br -> exit $rc, said: $out]"
  done
  # The same question from its other side: an operation reaching only remote-tracking refs, which never
  # touches the remote's trunk.
  out="$(run33 other push --mirror origin)"; rc=$?
  [ "$rc" = 0 ] || why33="$why33 [remote-tracking-only mirror -> exit $rc, said: $out]"
  [ -z "$why33" ] && ok "a ref that merely ends in the trunk's word is not the trunk" \
                  || bad "a ref that merely ends in the trunk's word is not the trunk ($why33)"

  # --- row 7: the verdict does not depend on how the command was written ---
  # Built as a PRODUCT over wrapper and quoting rather than as a list of composed rows: the shapes that
  # defeated every earlier version of this protection were the ones no list contained. Both halves are
  # here because either alone is satisfied by one direction of behaviour — refuse-everything kills the
  # harmless half, allow-everything kills the dangerous half, and no single reading satisfies both.
  mkpair33 prod main; diverge33 prod
  WRAP33=('%C' 'env GIT_TRACE=0 %C' '( %C )' 'for i in 1; do %C; done' 'true && %C' 'x=1; %C' 'if true; then %C; fi')
  b33="$(ref33 prod main)"; why33=""; nd33=0
  for w in "${WRAP33[@]}"; do
    for q in 'main' "'main'" '"main"'; do
      cmd="${w//%C/git push --force origin $q}"
      out="$(sh33 prod "$cmd")"; rc=$?; nd33=$((nd33+1))
      case "$out" in *"BLOCKED:"*) mine=1 ;; *) mine=0 ;; esac
      { [ "$rc" != 0 ] && [ "$mine" = 1 ] && [ "$b33" = "$(ref33 prod main)" ]; } \
        || why33="$why33 [$cmd -> exit $rc, guard spoke: $mine]"
    done
  done
  for extra in "git -c alias.p=push p --force origin main" \
               "git -c remote.origin.push=+refs/heads/main:refs/heads/main push origin" \
               "git push --force origin HEAD:main" \
               "git push origin +HEAD:refs/heads/main"; do
    out="$(sh33 prod "$extra")"; rc=$?; nd33=$((nd33+1))
    case "$out" in *"BLOCKED:"*) mine=1 ;; *) mine=0 ;; esac
    { [ "$rc" != 0 ] && [ "$mine" = 1 ] && [ "$b33" = "$(ref33 prod main)" ]; } \
      || why33="$why33 [$extra -> exit $rc, guard spoke: $mine]"
  done
  nh33=0
  i33=0
  for w in "${WRAP33[@]}"; do
    for q in "p$i33" "'p$i33'" "\"p$i33\""; do
      br="p$i33"; i33=$((i33+1))
      git -C "$T33/prod/work" branch -q "$br" 2>/dev/null
      cmd="${w//%C/git push --force origin $q}"
      out="$(sh33 prod "$cmd")"; rc=$?; nh33=$((nh33+1))
      [ "$rc" = 0 ] || why33="$why33 [harmless: $cmd -> exit $rc, said: $out]"
    done
  done
  [ -z "$why33" ] && ok "every generated wrapping of one push reaches the same verdict" \
    || bad "every generated wrapping of one push reaches the same verdict ($why33)"
  echo "         ($nd33 dangerous forms refused, $nh33 harmless forms allowed)"

  # --- rows 8 and 9: the inherited tables, executed rather than matched ----
  # A second trunk-named branch, because several inherited shapes name it and the remote must hold one
  # for the operation to be a rewrite rather than a create.
  mkpair33 inh main; diverge33 inh
  # It has to be behind on the remote, not level with it: a branch the remote already holds at the same
  # commit is up to date, the operation is a no-op, and the row would pass without the hook running at
  # all. Landed at the commit the remote holds and then moved onto the rewritten one.
  # A source branch for the refspec shapes that name one. Without it git errors before the hook is
  # ever consulted, and the row reads as a refusal that this guard never made.
  git -C "$T33/inh/work" branch -q feature main
  git -C "$T33/inh/work" branch -q master "$(ref33 inh main)"
  free33 inh push -q origin master
  git -C "$T33/inh/work" branch -qf master main
  b33="$(ref33 inh main)"; why33=""
  while IFS= read -r shape; do
    [ -n "$shape" ] || continue
    out="$(sh33 inh "$shape")"; rc=$?
    case "$out" in *"BLOCKED:"*) mine=1 ;; *) mine=0 ;; esac
    { [ "$rc" != 0 ] && [ "$mine" = 1 ] && [ "$b33" = "$(ref33 inh main)" ]; } \
      || why33="$why33 [$shape -> exit $rc, guard spoke: $mine, said: $out]"
  done <<'SHAPES'
git push --force origin main
git push -f origin main
git push origin +master
git push origin :refs/heads/main
git push origin --delete master
git push origin +feature:main
git -c remote.origin.push=:main push origin
git -c remote.origin.push=:refs/heads/main push origin
git -c "remote.origin.push=+refs/heads/main" push origin
git -c remote.origin.push="+refs/heads/main" push origin
git -c remote.origin.push='+refs/heads/main' push origin
cd .. && git -C work push --force origin main
cd .. && git --git-dir=work/.git --work-tree=work push --force origin main
( git push -fu origin main )
for i in 1 2; do git push -fu origin main; done
echo 'git push -fu origin main' | bash
echo main | xargs -I{} git push -fu origin {}
cd /tmp && git -C "$OLDPWD" push -fu origin main
git -c core.pager=cat push -f origin
git -c user.email=t@t.t push --force origin
git push -uf origin main
git push -fu origin main
git push -qf origin main
git push -fq origin main
git push origin +main
git push origin +HEAD:main
git push origin +refs/heads/main
git push origin +HEAD:refs/heads/main
git push origin +main:main
git push origin "+main"
git push origin '+main'
git push --force-with-lease origin +main
git push --force-with-lease origin +HEAD:main
git push --all --force origin
git push --branches --force origin
git push --all -f origin
git push --mirror origin
git -c remote.origin.push=+refs/heads/main:refs/heads/main push origin
git -c remote.origin.push=+main push origin
git -c remote.origin.push=refs/heads/main:refs/heads/main push --force origin
git -c remote.origin.push=refs/heads/main push -f origin
git -c 'remote.origin.push=+refs/heads/main' push origin
git -c core.pager=cat push --force origin main
env GIT_TRACE=0 git push --force origin main
time git push --force origin main
( git push --force origin main )
for i in 1 2; do git push --force origin main; done
echo 'git push --force origin main' | bash
echo main | xargs -I{} git push --force origin {}
SHAPES
  [ -z "$why33" ] && ok "every recorded dangerous shape is still refused" \
                  || bad "every recorded dangerous shape is still refused ($why33)"

  mkpair33 inha main
  for br in feature release/2.0 fix/main-nav docs/maintenance gone1 gone2 gone3; do
    git -C "$T33/inha/work" branch -q "$br"
  done
  free33 inha push -q origin gone1 gone2 gone3
  why33=""
  while IFS= read -r shape; do
    [ -n "$shape" ] || continue
    out="$(sh33 inha "$shape")"; rc=$?
    [ "$rc" = 0 ] || why33="$why33 [$shape -> exit $rc, said: $out]"
  done <<'SHAPES'
git push --force origin main:feature
git push origin +main:feature
git push --force origin HEAD:feature
git push --force origin fix/main-nav
git push --force origin docs/maintenance
git push --force origin feature
git push origin +feature
git push --all origin
git push --branches origin
git push --all --force-with-lease origin
git -c user.email=t@t.t push --force origin feature
git push origin --delete gone1
git push origin :gone2
git push origin -d gone3
git push origin -d release/2.0
git -c core.pager=cat push --force origin feature
git -c user.email=t@t.t push --force origin feature
git branch -D docs/maintenance
SHAPES
  # The nested names need a fixture of their own: git cannot hold a branch and a directory of the same
  # name at once, so `feature` and `feature/main-menu` cannot both be real branches in one repository.
  # The table this set descends from never met that constraint, because it fed strings to a matcher
  # instead of pushing anything — the first thing executing found that matching could not.
  mkpair33 inhb main
  for br in feature/main-menu feature/domain-model; do git -C "$T33/inhb/work" branch -q "$br"; done
  while IFS= read -r shape; do
    [ -n "$shape" ] || continue
    out="$(sh33 inhb "$shape")"; rc=$?
    [ "$rc" = 0 ] || why33="$why33 [$shape -> exit $rc, said: $out]"
  done <<'SHAPES'
git push --force origin feature/main-menu
git push origin +feature/main-menu
git push --force origin feature/domain-model
git push origin --delete feature/main-menu
git push origin :feature/domain-model
SHAPES
  [ -z "$why33" ] && ok "every recorded allowed shape is still allowed" \
                  || bad "every recorded allowed shape is still allowed ($why33)"

  # --- a repository whose object names are not forty characters long -------
  # An absent object is reported as an all-zero name whose length is the repository's hash length. The
  # first version of this hook compared against a forty-character constant, so under SHA-256 every one
  # of those tests answered "not absent": a creation read as a rewrite and a deletion as an update.
  # Skipped rather than faked where the git in use cannot make such a repository.
  if git init -q --object-format=sha256 "$T33/sha256probe" 2>/dev/null; then
    rm -rf "$T33/sha256probe"
    d33="$T33/sha256"; rm -rf "$d33"; mkdir -p "$d33"
    git init -q --bare --object-format=sha256 "$d33/remote.git"
    git -C "$d33/remote.git" symbolic-ref HEAD refs/heads/main
    git init -q --object-format=sha256 "$d33/work"
    git -C "$d33/work" symbolic-ref HEAD refs/heads/main
    git -C "$d33/work" config user.email t@t.t
    git -C "$d33/work" config user.name t
    git -C "$d33/work" config commit.gpgsign false
    printf 'a\n' > "$d33/work/f.txt"
    git -C "$d33/work" add -A >/dev/null 2>&1
    git -C "$d33/work" commit -q -m one
    git -C "$d33/work" remote add origin "$d33/remote.git"
    git -C "$d33/work" config core.hooksPath "$GHK"
    why33=""
    # a create, which must be allowed — the arm the fixed-length constant broke first
    out="$( ( cd "$d33/work" && git push origin main 2>&1 ) )"; rc=$?
    [ "$rc" = 0 ] || why33="$why33 [create -> exit $rc, said: $out]"
    # and a rewrite, which must still be refused
    printf 'b\n' >> "$d33/work/f.txt"; git -C "$d33/work" commit -qam two
    git -C "$d33/work" -c core.hooksPath="$NOHOOK" push -q origin main
    git -C "$d33/work" commit -q --amend -m two-rewritten
    out="$( ( cd "$d33/work" && git push --force origin main 2>&1 ) )"; rc=$?
    case "$out" in *"rewriting refs/heads/main"*) ;; *) why33="$why33 [rewrite -> exit $rc, said: $out]" ;; esac
    [ "$rc" != 0 ] || why33="$why33 [rewrite was allowed]"
    [ -z "$why33" ] && ok "object names longer than forty characters are read as absent when they are" \
                    || bad "object names longer than forty characters are read as absent when they are ($why33)"
  else
    echo "  [skip] non-SHA-1 object names (this git cannot create such a repository)"
  fi

  # --- the engine's hook standing where a repository's own would be --------
  # A real arrangement — it is what a per-repository install produces — and nothing drove it. What this
  # row proves is that the guard still reaches its verdict from there.
  #
  # What it does NOT prove, declared rather than faked: that the hand-back refuses to hand over to
  # itself. That arm only decides once a push is ALLOWED and the chaining code is reached, and its
  # failure mode is unbounded recursion — a fixture that drives it would spawn processes without end
  # inside this suite, and killing the parent would not stop the children. A check that cannot be made
  # to fail safely has not been proven, and saying so costs less than a fork bomb in a conformance run.
  mkpair33 selfch main
  mkdir -p "$T33/selfch/work/.git/hooks"
  cp "$GHK/pre-push" "$T33/selfch/work/.git/hooks/pre-push"
  chmod 755 "$T33/selfch/work/.git/hooks/pre-push"
  git -C "$T33/selfch/work" config core.hooksPath "$T33/selfch/work/.git/hooks"
  diverge33 selfch
  b33="$(ref33 selfch main)"
  out="$(run33 selfch push --force origin main)"; rc=$?
  if [ "$rc" != 0 ] && [ "$b33" = "$(ref33 selfch main)" ]; then
    ok "the guard still reaches its verdict when it is the repository's own hook"
  else
    bad "the guard still reaches its verdict when it is the repository's own hook (exit $rc, said: $out)"
  fi

  # --- what a chained hook is handed --------------------------------------
  # The engine holds standard input so it can be read twice. Nothing asserted that what reaches the
  # repository's own hook is the ref lines git sent rather than an empty stream — and an empty stream
  # is a hook that allows everything while appearing to run.
  mkpair33 handed main
  mkdir -p "$T33/handed/work/.git/hooks"
  printf '#!/bin/sh\nn=0\nwhile read -r a b c d; do n=$((n+1)); echo "$c" >> "$(git rev-parse --git-common-dir)/refs-seen"; done\necho "$n" > "$(git rev-parse --git-common-dir)/refs-count"\nexit 0\n' \
    > "$T33/handed/work/.git/hooks/pre-push"
  chmod 755 "$T33/handed/work/.git/hooks/pre-push"
  printf 'z\n' >> "$T33/handed/work/f.txt"; git -C "$T33/handed/work" commit -qam handed
  run33 handed push origin main >/dev/null 2>&1
  seen="$(cat "$T33/handed/work/.git/refs-seen" 2>/dev/null || echo none)"
  cnt="$(cat "$T33/handed/work/.git/refs-count" 2>/dev/null || echo 0)"
  if [ "$cnt" = "1" ] && [ "$seen" = "refs/heads/main" ]; then
    ok "a chained hook is handed the ref lines git sent, not an empty stream"
  else
    bad "a chained hook is handed the ref lines git sent, not an empty stream (count=$cnt seen=$seen)"
  fi

  # --- row 10: a repository that already had a hook of its own -------------
  # Two things at once, and both matter: the engine's hook must reach the repository's own copy, and it
  # must reach it exactly once. Resolving "this repository's own hook" through the redirected path hands
  # the hook itself back and recurses without end — measured, so the counter here is the guard against a
  # regression that has already happened once.
  mkpair33 chain main
  mkdir -p "$T33/chain/work/.git/hooks"
  cat > "$T33/chain/work/.git/hooks/pre-push" <<'OWN'
#!/bin/sh
echo x >> "$(git rev-parse --git-common-dir)/own-hook-ran"
echo "the repository's own hook refuses this" >&2
exit 9
OWN
  chmod +x "$T33/chain/work/.git/hooks/pre-push"
  printf 'd\n' >> "$T33/chain/work/f.txt"; git -C "$T33/chain/work" commit -qam four
  out="$(run33 chain push origin main)"; rc=$?
  runs="$(wc -l < "$T33/chain/work/.git/own-hook-ran" 2>/dev/null | tr -d ' ')"
  case "$out" in *"own hook refuses"*) heard=1 ;; *) heard=0 ;; esac
  if [ "$rc" != 0 ] && [ "$runs" = "1" ] && [ "$heard" = 1 ]; then
    ok "a repository's own hook is run once and its refusal stands"
  else
    bad "a repository's own hook is run once and its refusal stands (exit $rc, own hook ran ${runs:-0}x, heard=$heard, said: $out)"
  fi
else
  echo "  [skip] trunk-defence checks (git unavailable)"
fi

echo "== C34: a commit is judged by what it would record =="
# The staging protection's substrate. What decides is the index — the paths a commit would actually
# record — so a name that appears only in the message, or only in the working tree, is not a staging.
# Three of the nine false refusals measured against the guard this replaces came from exactly there.
#
# The shell wrappings the inherited table enumerated collapse to almost nothing here, and that is the
# point rather than a gap: the index does not vary with how the command that filled it was written. What
# remains worth driving is the small product below, which proves that.
if command -v git >/dev/null 2>&1; then
  GHK34="$ROOT/global/hooks/git"
  T34="$T11/c34"; mkdir -p "$T34"
  NOHOOK34="$T34/nohook"; mkdir -p "$NOHOOK34"

  mkrepo34() {  # $1 = fixture name -> a repository with one commit and the guard active
    d34="$T34/$1"; rm -rf "$d34"; mkdir -p "$d34"
    git init -q "$d34"
    git -C "$d34" symbolic-ref HEAD refs/heads/main
    git -C "$d34" config user.email t@t.t
    git -C "$d34" config user.name t
    git -C "$d34" config commit.gpgsign false
    printf 'a\n' > "$d34/app.txt"
    git -C "$d34" -c core.hooksPath="$NOHOOK34" add -A >/dev/null 2>&1
    git -C "$d34" -c core.hooksPath="$NOHOOK34" commit -q -m init
    git -C "$d34" config core.hooksPath "$GHK34"
  }
  head34() { git -C "$T34/$1" rev-parse HEAD 2>/dev/null || echo none; }
  sh34()   { ( cd "$T34/$1" && bash -c "$2" 2>&1 ); }

  # --- row 11: what the commit would record ------------------------------
  mkrepo34 secret
  why34=""
  for f in ".env" ".env.local" "config/.env" "certs/server.pem" "keys/store.p12" \
           "keys/bundle.pfx" "keys/app.jks" "keys/app.keystore" "id_rsa" "home/.ssh/id_ed25519" \
           "svc/service-account-abc123.json" "svc/service_account.json"; do
    mkdir -p "$(dirname "$T34/secret/$f")" 2>/dev/null
    printf 'K=1\n' > "$T34/secret/$f"
    git -C "$T34/secret" -c core.hooksPath="$NOHOOK34" add -A >/dev/null 2>&1
    b34="$(head34 secret)"
    out="$(sh34 secret "git commit -m recorded")"; rc=$?
    { [ "$rc" != 0 ] && [ "$b34" = "$(head34 secret)" ]; } || why34="$why34 [$f -> exit $rc]"
    case "$out" in *"would record a secret"*) ;; *) why34="$why34 [$f -> not named: $out]" ;; esac
    git -C "$T34/secret" -c core.hooksPath="$NOHOOK34" rm -q -f --cached "$f" >/dev/null 2>&1
    rm -f "$T34/secret/$f"
  done
  [ -z "$why34" ] && ok "a commit that would record a secret is refused" \
                  || bad "a commit that would record a secret is refused ($why34)"

  # --- row 12: named but not recorded -------------------------------------
  # The row this whole task exists for. Each leg is a shape the guard being replaced refuses today.
  mkrepo34 named
  why34=""
  printf 'x\n' >> "$T34/named/app.txt"
  git -C "$T34/named" -c core.hooksPath="$NOHOOK34" add -A >/dev/null 2>&1
  b34="$(head34 named)"
  out="$(sh34 named "git commit -m 'docs: never commit .env or server.pem'")"; rc=$?
  { [ "$rc" = 0 ] && [ "$b34" != "$(head34 named)" ]; } || why34="$why34 [message names it -> exit $rc, said: $out]"
  # present in the working tree, deliberately not staged
  printf 'K=1\n' > "$T34/named/.env"
  printf 'y\n' >> "$T34/named/app.txt"
  git -C "$T34/named" -c core.hooksPath="$NOHOOK34" add app.txt >/dev/null 2>&1
  b34="$(head34 named)"
  out="$(sh34 named "git commit -m unrelated")"; rc=$?
  { [ "$rc" = 0 ] && [ "$b34" != "$(head34 named)" ]; } || why34="$why34 [unstaged secret -> exit $rc, said: $out]"
  rm -f "$T34/named/.env"
  # the example forms, which exist to be committed
  for f in ".env.example" ".env.template" ".env.sample" ".env.dist" ".env.local.example"; do
    printf 'K=\n' > "$T34/named/$f"
    git -C "$T34/named" -c core.hooksPath="$NOHOOK34" add -A >/dev/null 2>&1
    b34="$(head34 named)"
    out="$(sh34 named "git commit -m example")"; rc=$?
    { [ "$rc" = 0 ] && [ "$b34" != "$(head34 named)" ]; } || why34="$why34 [$f -> exit $rc, said: $out]"
  done
  # removing a secret committed by mistake must stay possible
  git -C "$T34/named" -c core.hooksPath="$NOHOOK34" -c core.excludesFile=/dev/null add -f -A >/dev/null 2>&1
  printf 'K=1\n' > "$T34/named/.env"
  git -C "$T34/named" -c core.hooksPath="$NOHOOK34" add -f .env >/dev/null 2>&1
  git -C "$T34/named" -c core.hooksPath="$NOHOOK34" commit -q -m "mistake"
  git -C "$T34/named" -c core.hooksPath="$NOHOOK34" rm -q -f .env >/dev/null 2>&1
  b34="$(head34 named)"
  out="$(sh34 named "git commit -m 'remove the secret'")"; rc=$?
  { [ "$rc" = 0 ] && [ "$b34" != "$(head34 named)" ]; } || why34="$why34 [removing a committed secret -> exit $rc, said: $out]"
  [ -z "$why34" ] && ok "a secret named but not recorded does not refuse the commit" \
                  || bad "a secret named but not recorded does not refuse the commit ($why34)"

  # --- the classification's negative direction ----------------------------
  # Every fixture above hands it a path that IS a secret, so a classification that answered "yes" to
  # everything would read as correct. These are the near misses: the words appear and the path is
  # ordinary.
  mkrepo34 benign
  why34=""
  for f in "environment.ts" "docs/pem-format.md" "src/keystore-adapter.java" "id_rsa_helper.py" \
           "config/environment.md" "service-accounts.md" "lib/pembroke.txt"; do
    mkdir -p "$(dirname "$T34/benign/$f")" 2>/dev/null
    printf 'x\n' > "$T34/benign/$f"
    git -C "$T34/benign" -c core.hooksPath="$NOHOOK34" add -A >/dev/null 2>&1
    b34="$(head34 benign)"
    out="$(sh34 benign "git commit -m ordinary")"; rc=$?
    { [ "$rc" = 0 ] && [ "$b34" != "$(head34 benign)" ]; } || why34="$why34 [$f -> exit $rc, said: $out]"
  done
  # And the case folding, which nothing exercised in either direction.
  mkdir -p "$T34/benign/CERTS"
  printf 'K=1\n' > "$T34/benign/CERTS/SERVER.PEM"
  git -C "$T34/benign" -c core.hooksPath="$NOHOOK34" add -A >/dev/null 2>&1
  b34="$(head34 benign)"
  out="$(sh34 benign "git commit -m upper")"; rc=$?
  case "$out" in *"would record a secret"*) refused=1 ;; *) refused=0 ;; esac
  { [ "$rc" != 0 ] && [ "$refused" = 1 ] && [ "$b34" = "$(head34 benign)" ]; } \
    || why34="$why34 [an upper-case secret slipped through -> exit $rc, refused=$refused, said: $out]"
  [ -z "$why34" ] && ok "an ordinary path that merely reads like a secret is committed, and case does not hide one" \
                  || bad "an ordinary path that merely reads like a secret is committed, and case does not hide one ($why34)"

  # --- row 13: the recorded shapes, staged for real -----------------------
  # The wrappings the inherited table carried are driven as a product here. They must all reach the same
  # verdict, because the index they fill is the same whichever way it was filled — including the form
  # that stages at commit time, which was measured to have a complete index by the time the hook runs.
  mkrepo34 shapes
  why34=""; ns34=0
  for w in '%C' 'env GIT_TRACE=0 %C' '( %C )' 'true && %C' 'x=1; %C'; do
    printf 'K=1\n' > "$T34/shapes/.env"
    git -C "$T34/shapes" -c core.hooksPath="$NOHOOK34" add -A >/dev/null 2>&1
    b34="$(head34 shapes)"
    cmd="${w//%C/git commit -m staged}"
    out="$(sh34 shapes "$cmd")"; rc=$?; ns34=$((ns34+1))
    { [ "$rc" != 0 ] && [ "$b34" = "$(head34 shapes)" ]; } || why34="$why34 [$cmd -> exit $rc]"
    git -C "$T34/shapes" -c core.hooksPath="$NOHOOK34" rm -q -f --cached .env >/dev/null 2>&1
  done
  # the form that stages tracked changes at commit time
  printf 'K=1\n' > "$T34/shapes/.env"
  git -C "$T34/shapes" -c core.hooksPath="$NOHOOK34" add -A >/dev/null 2>&1
  git -C "$T34/shapes" -c core.hooksPath="$NOHOOK34" commit -q -m "carry it in"
  printf 'K=2\n' > "$T34/shapes/.env"
  b34="$(head34 shapes)"
  out="$(sh34 shapes "git commit -am touched")"; rc=$?; ns34=$((ns34+1))
  { [ "$rc" != 0 ] && [ "$b34" = "$(head34 shapes)" ]; } || why34="$why34 [commit -a -> exit $rc]"
  # and amending, which is the form where the question changes: what a commit records is what it adds
  # over the commit it replaces, so an amend that ADDS a secret is refused...
  git -C "$T34/shapes" -c core.hooksPath="$NOHOOK34" rm -q -f --cached .env >/dev/null 2>&1
  git -C "$T34/shapes" -c core.hooksPath="$NOHOOK34" commit -q -m "clean again"
  printf 'K=3\n' > "$T34/shapes/.env"
  git -C "$T34/shapes" -c core.hooksPath="$NOHOOK34" add -A >/dev/null 2>&1
  b34="$(head34 shapes)"
  out="$(sh34 shapes "git commit --amend --no-edit")"; rc=$?; ns34=$((ns34+1))
  { [ "$rc" != 0 ] && [ "$b34" = "$(head34 shapes)" ]; } || why34="$why34 [amend adding a secret -> exit $rc]"
  [ -z "$why34" ] && ok "every recorded staging shape is still refused" \
                  || bad "every recorded staging shape is still refused ($why34)"

  # ...while an amend that merely carries a secret already in the history forward is NOT judged, and
  # that is a decision rather than a gap. What a commit records is what it adds; a secret already in
  # HEAD was recorded when this guard was bypassed or absent, and judging the whole tree instead would
  # refuse every commit in a repository that already contains one — trapping it in exactly the state
  # the guard exists to prevent, which is the same reason a deletion is not judged either.
  git -C "$T34/shapes" -c core.hooksPath="$NOHOOK34" commit -q --amend --no-edit
  printf 'unrelated\n' >> "$T34/shapes/app.txt"
  git -C "$T34/shapes" -c core.hooksPath="$NOHOOK34" add app.txt >/dev/null 2>&1
  b34="$(head34 shapes)"
  out="$(sh34 shapes "git commit --amend --no-edit")"; rc=$?
  if [ "$rc" = 0 ] && [ "$b34" != "$(head34 shapes)" ]; then
    ok "a secret already in the history is not re-judged when a commit is amended, as declared"
  else
    bad "a secret already in the history is not re-judged when a commit is amended, as declared (exit $rc, said: $out)"
  fi

  # --- row 14: the harmless side of the same product ----------------------
  # Without this the row above is satisfied by a guard that refuses every commit.
  mkrepo34 harmless
  why34=""; nh34=0
  for w in '%C' 'env GIT_TRACE=0 %C' '( %C )' 'true && %C' 'x=1; %C'; do
    printf 'ok\n' >> "$T34/harmless/app.txt"
    git -C "$T34/harmless" -c core.hooksPath="$NOHOOK34" add -A >/dev/null 2>&1
    b34="$(head34 harmless)"
    cmd="${w//%C/git commit -m ordinary}"
    out="$(sh34 harmless "$cmd")"; rc=$?; nh34=$((nh34+1))
    { [ "$rc" = 0 ] && [ "$b34" != "$(head34 harmless)" ]; } || why34="$why34 [$cmd -> exit $rc, said: $out]"
  done
  printf 'ok\n' >> "$T34/harmless/app.txt"
  b34="$(head34 harmless)"
  out="$(sh34 harmless "git commit -am ordinary")"; rc=$?; nh34=$((nh34+1))
  { [ "$rc" = 0 ] && [ "$b34" != "$(head34 harmless)" ]; } || why34="$why34 [commit -a -> exit $rc, said: $out]"
  [ -z "$why34" ] && ok "every recorded harmless staging shape is still allowed" \
                  || bad "every recorded harmless staging shape is still allowed ($why34)"
  echo "         ($ns34 recording forms refused, $nh34 harmless forms allowed)"

  # --- the repository's own commit hook, on the terms the push guard uses --
  mkrepo34 chain34
  mkdir -p "$T34/chain34/.git/hooks"
  cat > "$T34/chain34/.git/hooks/pre-commit" <<'OWN34'
#!/bin/sh
echo x >> "$(git rev-parse --git-common-dir)/own-commit-hook-ran"
echo "the repository's own commit hook refuses this" >&2
exit 9
OWN34
  chmod +x "$T34/chain34/.git/hooks/pre-commit"
  printf 'z\n' >> "$T34/chain34/app.txt"
  git -C "$T34/chain34" -c core.hooksPath="$NOHOOK34" add -A >/dev/null 2>&1
  b34="$(head34 chain34)"
  out="$(sh34 chain34 "git commit -m chained")"; rc=$?
  runs34="$(wc -l < "$T34/chain34/.git/own-commit-hook-ran" 2>/dev/null | tr -d ' ')"
  case "$out" in *"own commit hook refuses"*) heard34=1 ;; *) heard34=0 ;; esac
  if [ "$rc" != 0 ] && [ "$runs34" = "1" ] && [ "$heard34" = 1 ] && [ "$b34" = "$(head34 chain34)" ]; then
    ok "a repository's own commit hook is run once and its refusal stands"
  else
    bad "a repository's own commit hook is run once and its refusal stands (exit $rc, ran ${runs34:-0}x, heard=$heard34, said: $out)"
  fi
else
  echo "  [skip] commit-recording checks (git unavailable)"
fi

echo "== C35: the rail reports whether the protection is here, and judges nothing else =="
# The rail's new job, and the whole reason this section is short where the matcher it replaces needed
# forty-six rows: the rail no longer decides anything about a command. Its trigger is a crude text test
# and is allowed to be one, because a shape it misses is a reminder that does not fire in a repository
# git's own hooks are not guarding either way. What it must never do again is refuse work.
if [ "$PY3" = 1 ] && command -v git >/dev/null 2>&1; then
  GS35="$HK/git-safety.py"
  T35="$T11/c35"; mkdir -p "$T35"
  ENG35="$T35/enginehooks"; mkdir -p "$ENG35"
  printf '#!/bin/sh\nexit 0\n' > "$ENG35/pre-push"; chmod 755 "$ENG35/pre-push"
  printf '#!/bin/sh\nexit 0\n' > "$ENG35/pre-commit"; chmod 755 "$ENG35/pre-commit"

  rail35() {  # $1 = declared cwd, $2 = command -> combined output, returns the rail's exit code
    printf '%s' "$(python3 -c 'import json,sys; print(json.dumps({"cwd": sys.argv[1], "tool_input": {"command": sys.argv[2]}}))' "$1" "$2")" \
      | ( cd "$3" && HOME="$T35/home" python3 "$GS35" 2>&1 )
  }
  # A sandboxed HOME whose engine hooks are the throwaway pair above, so the section never depends on
  # what is installed on the machine running it.
  mkdir -p "$T35/home/.claude/hooks/git"
  cp "$ENG35/pre-push" "$ENG35/pre-commit" "$T35/home/.claude/hooks/git/"

  UNPROT="$T35/unprotected"; mkproj "$UNPROT" main
  PROT="$T35/protected";     mkproj "$PROT" main
  git -C "$PROT" config core.hooksPath "$T35/home/.claude/hooks/git"
  DISP="$T35/displaced";     mkproj "$DISP" main
  mkdir -p "$DISP/.myhooks";  git -C "$DISP" config core.hooksPath .myhooks
  ACKED="$T35/acknowledged";  mkproj "$ACKED" main
  git -C "$ACKED" config aiflow.protection acknowledged
  PLAIN="$T35/notarepo";      mkdir -p "$PLAIN"
  # Present but not runnable. This is the quietest way the protection fails — git skips a hook without
  # its executable bit with a hint and nothing else — and no fixture here could reach it until a
  # mutation that reads presence instead of runnability survived for want of a witness.
  INERT="$T35/inert";         mkproj "$INERT" main
  cp "$ENG35/pre-push" "$ENG35/pre-commit" "$INERT/.git/hooks/"
  chmod 644 "$INERT/.git/hooks/pre-push" "$INERT/.git/hooks/pre-commit"
  # A repository with no working tree: nothing is recorded or published from one, so reporting on it
  # would be a nag with no subject. Found the same way.
  BARE="$T35/bare.git";       git init -q --bare "$BARE"

  # --- the reported defect, entire ----------------------------------------
  # The nine shapes measured as refused by the matcher, plus the six that refused this task's own work
  # while it was being understood. Driven from a PROTECTED fixture, and the scoping is the honest claim
  # rather than a convenience: what this change delivers is that in a repository where the protection is
  # in place — every repository, once the installer has run — no command is refused for what its text
  # says. In a repository where it is NOT in place the crude trigger will fire on some of these, and
  # that firing is the reminder itself. Because nothing is refused here whatever the trigger does, this
  # row cannot test the trigger; the row below owns that, through its leg for a command that records
  # nothing.
  why35=""; n35=0
  while IFS= read -r shape; do
    [ -n "$shape" ] || continue
    out="$(rail35 "$PROT" "$shape" "$PROT")"; rc=$?; n35=$((n35+1))
    [ "$rc" = 0 ] || why35="$why35 [$shape -> exit $rc, said: $out]"
  done <<'SHAPES'
echo "git push --force origin main"
git commit -m "docs: forbid git push --force origin main"
grep -n 'push --force origin main' notes.md
kubectl push --force origin main
npm run push -- -f --branch main
echo "git add .env" >> notes.md
git commit -m "add .env to gitignore"
grep -rn "git add .env" docs/
python3 -c 'print("git push --force origin main")'
EXAMPLE='git push --force origin main'; echo "$EXAMPLE" >> notes.md
cat > notes.md <<'EOF'
Forbidden: git push --force origin main
EOF
echo 'clean' # push
rm -rf build && echo 'push to main later'
git status && echo 'do not add .env'
echo 'never commit .env' >> /repos/git/README.md
SHAPES
  [ -z "$why35" ] && ok "no command that fails to invoke git is refused" \
                  || bad "no command that fails to invoke git is refused ($why35)"

  # --- the new job, in all five states it can report ----------------------
  why35=""
  out="$(rail35 "$UNPROT" "git push origin main" "$UNPROT")"; rc=$?
  case "$out" in *"core.hooksPath"*) named=1 ;; *) named=0 ;; esac
  case "$out" in *"aiflow.protection"*) ;; *) named=0 ;; esac
  { [ "$rc" = 2 ] && [ "$named" = 1 ]; } || why35="$why35 [absent -> exit $rc, said: $out]"
  out="$(rail35 "$DISP" "git commit -m x" "$DISP")"; rc=$?
  case "$out" in *".myhooks"*) ;; *) why35="$why35 [displaced -> does not name what displaced it: $out]" ;; esac
  [ "$rc" = 2 ] || why35="$why35 [displaced -> exit $rc]"
  out="$(rail35 "$PROT" "git push origin main" "$PROT")"; rc=$?
  { [ "$rc" = 0 ] && [ -z "$out" ]; } || why35="$why35 [active -> exit $rc, said: $out]"
  out="$(rail35 "$ACKED" "git push origin main" "$ACKED")"; rc=$?
  { [ "$rc" = 0 ] && [ -z "$out" ]; } || why35="$why35 [acknowledged -> exit $rc, said: $out]"
  out="$(rail35 "$PLAIN" "git push origin main" "$PLAIN")"; rc=$?
  { [ "$rc" = 0 ] && [ -z "$out" ]; } || why35="$why35 [not a repository -> exit $rc, said: $out]"
  out="$(rail35 "$BARE" "git push origin main" "$BARE")"; rc=$?
  { [ "$rc" = 0 ] && [ -z "$out" ]; } || why35="$why35 [a repository with no working tree -> exit $rc, said: $out]"
  out="$(rail35 "$INERT" "git push origin main" "$INERT")"; rc=$?
  { [ "$rc" = 2 ]; } || why35="$why35 [hooks present but not runnable -> exit $rc, said: $out]"
  out="$(rail35 "$UNPROT" "git status" "$UNPROT")"; rc=$?
  { [ "$rc" = 0 ] && [ -z "$out" ]; } || why35="$why35 [a command that records nothing -> exit $rc, said: $out]"
  [ -z "$why35" ] && ok "a repository without the protection is told, and told how" \
                  || bad "a repository without the protection is told, and told how ($why35)"

  # --- engine hooks present but not runnable ------------------------------
  # The configured-path branch used to ask only whether the engine's copies existed, while the branch
  # for a repository's own copies asked whether they could run. With the two files at mode 644 the rail
  # called the protection active while git ran neither hook. Nothing reached that state until a mutation
  # survived for want of a witness.
  DEADH="$T35/deadhome"; mkdir -p "$DEADH/.claude/hooks/git"
  cp "$ENG35/pre-push" "$ENG35/pre-commit" "$DEADH/.claude/hooks/git/"
  chmod 644 "$DEADH/.claude/hooks/git/pre-push" "$DEADH/.claude/hooks/git/pre-commit"
  DEADR="$T35/deadrepo"; mkproj "$DEADR" main
  git -C "$DEADR" config core.hooksPath "$DEADH/.claude/hooks/git"
  out="$(printf '{"cwd":"%s","tool_input":{"command":"git push origin main"}}' "$DEADR" \
        | ( cd "$DEADR" && HOME="$DEADH" python3 "$GS35" 2>&1 ))"; rc=$?
  [ "$rc" = 2 ] && ok "hooks the hook path names but git cannot run are not called active" \
                || bad "hooks the hook path names but git cannot run are not called active (exit $rc, said: $out)"

  # --- an unusable declared directory means silence, not a guess ----------
  # Both halves of what the rail must not do met on one line: it substituted its own process directory
  # and refused over a repository the session never named. Three shapes, and the fixture stands in an
  # UNPROTECTED repository so a rail that guessed would have something to refuse about.
  why35=""
  for payload in '{"tool_input":{"command":"git push origin main"}}' \
                 '{"cwd":123,"tool_input":{"command":"git push origin main"}}' \
                 '{"cwd":"/no/such/directory/here","tool_input":{"command":"git push origin main"}}'; do
    out="$(printf '%s' "$payload" | ( cd "$UNPROT" && HOME="$T35/home" python3 "$GS35" 2>&1 ))"; rc=$?
    { [ "$rc" = 0 ] && [ -z "$out" ]; } || why35="$why35 [$payload -> exit $rc, said: $out]"
  done
  [ -z "$why35" ] && ok "a declared directory the rail cannot use means silence, not its own directory" \
                  || bad "a declared directory the rail cannot use means silence, not its own directory ($why35)"

  # --- the state where the engine itself is not installed ------------------
  # Its own report names the installer rather than the hook path, and no fixture reached it: the rail
  # would have stopped distinguishing "nothing to point at" from "pointed elsewhere" unnoticed.
  NOENG="$T35/noenginehome"; mkdir -p "$NOENG/.claude/hooks"
  out="$(printf '{"cwd":"%s","tool_input":{"command":"git push origin main"}}' "$UNPROT" \
        | ( cd "$UNPROT" && HOME="$NOENG" python3 "$GS35" 2>&1 ))"; rc=$?
  case "$out" in *"install.sh update"*) named=1 ;; *) named=0 ;; esac
  { [ "$rc" = 2 ] && [ "$named" = 1 ]; } \
    && ok "an engine whose git hooks are not installed says so, and names the installer" \
    || bad "an engine whose git hooks are not installed says so, and names the installer (exit $rc, said: $out)"

  # --- a relative hook path, in the direction that resolves ----------------
  # Only the failing direction was driven. A relative value is resolved by git against the top of the
  # working tree, so the rail must resolve it the same way; reading it against anything else calls an
  # active protection displaced. The engine directory here IS the repository's own `.myhooks`, reached
  # through a link, so the relative value and the engine path are the same place by two names — which
  # is the only arrangement in which this branch decides anything.
  RELR="$T35/relative"; mkproj "$RELR" main
  mkdir -p "$RELR/.myhooks"
  cp "$ENG35/pre-push" "$ENG35/pre-commit" "$RELR/.myhooks/"
  git -C "$RELR" config core.hooksPath .myhooks
  RELH="$T35/relhome"; mkdir -p "$RELH/.claude/hooks"
  if ln -s "$RELR/.myhooks" "$RELH/.claude/hooks/git" 2>/dev/null; then
    out="$(printf '{"cwd":"%s","tool_input":{"command":"git push origin main"}}' "$RELR" \
          | ( cd / && HOME="$RELH" python3 "$GS35" 2>&1 ))"; rc=$?
    { [ "$rc" = 0 ] && [ -z "$out" ]; } \
      && ok "a relative hook path is resolved against the working tree, not the caller's directory" \
      || bad "a relative hook path is resolved against the working tree, not the caller's directory (exit $rc, said: $out)"
  else
    echo "  [skip] relative hook path (symbolic links unavailable)"
  fi

  # --- the acknowledgement belongs to one repository ----------------------
  # The refusal that offers it says "this repository only". Read across every scope, a single global
  # setting would silence the reminder machine-wide — an accepted gap becoming a silent one, which is
  # the distinction the key exists to make.
  GACK="$T35/gackhome"; mkdir -p "$GACK/.claude/hooks/git"
  cp "$ENG35/pre-push" "$ENG35/pre-commit" "$GACK/.claude/hooks/git/"
  printf '[aiflow]\n\tprotection = acknowledged\n' > "$GACK/.gitconfig"
  out="$(printf '{"cwd":"%s","tool_input":{"command":"git push origin main"}}' "$UNPROT" \
        | ( cd "$UNPROT" && HOME="$GACK" GIT_CONFIG_GLOBAL="$GACK/.gitconfig" python3 "$GS35" 2>&1 ))"; rc=$?
  [ "$rc" = 2 ] && ok "an acknowledgement set machine-wide does not silence an unacknowledged repository" \
                || bad "an acknowledgement set machine-wide does not silence an unacknowledged repository (exit $rc, said: $out)"

  # --- the three classes the previous change introduced -------------------
  why35=""
  for shape in "git push origin main && chmod +x a.sh" \
               "git push origin main; echo '+added' >> notes.log" \
               "git push origin main && grep +3 report.txt" \
               "echo 'a+b' && git push origin main" \
               "git commit -m 'fix: 1+1' && git push origin main" \
               "git push origin main # 1+1" \
               "git branch -D main"; do
    out="$(rail35 "$PROT" "$shape" "$PROT")"; rc=$?
    [ "$rc" = 0 ] || why35="$why35 [$shape -> exit $rc, said: $out]"
  done
  [ -z "$why35" ] && ok "a plus sign beside a push is not read as an order to force" \
                  || bad "a plus sign beside a push is not read as an order to force ($why35)"

  # --- the declared directory, not the process's own ----------------------
  # Both legs, and the second is the one that matters: standing in a protected repository while the
  # session declares an unprotected one must still refuse. A rail reading its own directory answers
  # about the wrong repository, and this pair is what makes that impossible.
  why35=""
  out="$(rail35 "$UNPROT" "git push origin main" "$PROT")"; rc=$?
  [ "$rc" = 2 ] || why35="$why35 [declared unprotected, standing in protected -> exit $rc]"
  out="$(rail35 "$PROT" "git push origin main" "$UNPROT")"; rc=$?
  [ "$rc" = 0 ] || why35="$why35 [declared protected, standing in unprotected -> exit $rc, said: $out]"
  [ -z "$why35" ] && ok "the rail judges the directory the session declares" \
                  || bad "the rail judges the directory the session declares ($why35)"

  # --- the installer -------------------------------------------------------
  # A sandboxed HOME and a sandboxed git configuration; the machine's own global config is never read
  # or written by this section.
  IH="$T35/ihome"; IT="$T35/itarget"; IW="$T35/iwork"
  mkdir -p "$IH" "$IT/.ai-flow" "$IW"
  printf '[user]\n\tname = t\n' > "$IH/.gitconfig"
  git config --file "$IH/.gitconfig" core.hooksPath "/somewhere/of/my/own"
  ( cd "$IW" && HOME="$IH" GIT_CONFIG_GLOBAL="$IH/.gitconfig" bash "$ROOT/install.sh" update "$IT" </dev/null >"$T35/ilog" 2>&1 ) || true
  keptv="$(git config --file "$IH/.gitconfig" --get core.hooksPath)"
  if [ "$keptv" = "/somewhere/of/my/own" ] && grep -q "already set" "$T35/ilog"; then
    ok "an existing global hook path is reported and left alone"
  else
    bad "an existing global hook path is reported and left alone (value now '$keptv')"
  fi

  why35=""
  for h in pre-push pre-commit; do
    [ -f "$IH/.claude/hooks/git/$h" ] || why35="$why35 [$h not installed]"
    [ -x "$IH/.claude/hooks/git/$h" ] || why35="$why35 [$h installed without its executable bit]"
  done
  # The same on the path that has no executable bit to carry: a copy stripped of it must be repaired by
  # the installer, which is the only thing standing between a download and a hook git silently skips.
  chmod 644 "$IH/.claude/hooks/git/pre-push" 2>/dev/null || true
  ( cd "$IW" && HOME="$IH" GIT_CONFIG_GLOBAL="$IH/.gitconfig" bash "$ROOT/install.sh" update "$IT" </dev/null >/dev/null 2>&1 ) || true
  [ -x "$IH/.claude/hooks/git/pre-push" ] || why35="$why35 [a copy arriving without the bit keeps arriving without it]"
  [ -z "$why35" ] && ok "the installed git hooks are executable however they arrived" \
                  || bad "the installed git hooks are executable however they arrived ($why35)"

  # --- the installer's success path, which nothing exercised ---------------
  # Only the "a hook path is already set" arm was covered. Deleting the line that actually points git at
  # the hooks — leaving the reassuring [ok] echo in place — left the suite green, so the installer could
  # stop installing the protection while still claiming to have installed it.
  IH2="$T35/ihome2"; IT2="$T35/itarget2"; IW2="$T35/iwork2"
  mkdir -p "$IH2" "$IT2/.ai-flow" "$IW2"
  printf '[user]\n\tname = t\n' > "$IH2/.gitconfig"
  ( cd "$IW2" && HOME="$IH2" GIT_CONFIG_GLOBAL="$IH2/.gitconfig" bash "$ROOT/install.sh" update "$IT2" </dev/null >/dev/null 2>&1 ) || true
  setv="$(git config --file "$IH2/.gitconfig" --get core.hooksPath)"
  [ "$setv" = "$IH2/.claude/hooks/git" ] \
    && ok "the installer points git at the engine's hooks when nothing else claims the path" \
    || bad "the installer points git at the engine's hooks when nothing else claims the path (value '$setv')"

  # --- the engine adds two guards and takes nothing away -------------------
  # Pointing the hook path at a directory replaces where git looks for EVERY hook, so without a
  # pass-through a repository's own commit-msg simply stops running. Proven the other way round first:
  # an added assertion driving exactly this went red before the pass-through existed.
  why35=""
  for h in commit-msg post-commit prepare-commit-msg post-checkout; do
    [ -x "$IH2/.claude/hooks/git/$h" ] || why35="$why35 [$h not installed as a pass-through]"
  done
  CH35="$T35/chainrepo"; mkproj "$CH35" main
  git -C "$CH35" config core.hooksPath "$IH2/.claude/hooks/git"
  mkdir -p "$CH35/.git/hooks"
  printf '#!/bin/sh\necho ran >> "$(git rev-parse --git-common-dir)/own-msg-ran"\nexit 0\n' > "$CH35/.git/hooks/commit-msg"
  chmod 755 "$CH35/.git/hooks/commit-msg"
  printf 'x\n' >> "$CH35/app.txt"
  $GIT -C "$CH35" add -A >/dev/null 2>&1
  $GIT -C "$CH35" commit -q -m chained >/dev/null 2>&1
  [ -f "$CH35/.git/own-msg-ran" ] || why35="$why35 [the repository's own commit-msg never ran]"
  # And the other direction: a refusal from the repository's own hook must reach git.
  printf '#!/bin/sh\nexit 9\n' > "$CH35/.git/hooks/commit-msg"
  chmod 755 "$CH35/.git/hooks/commit-msg"
  b35="$($GIT -C "$CH35" rev-parse HEAD)"
  printf 'y\n' >> "$CH35/app.txt"
  $GIT -C "$CH35" add -A >/dev/null 2>&1
  $GIT -C "$CH35" commit -q -m refused >/dev/null 2>&1
  [ "$b35" = "$($GIT -C "$CH35" rev-parse HEAD)" ] || why35="$why35 [the repository's own refusal did not reach git]"
  [ -z "$why35" ] && ok "a repository keeps every hook of its own that the engine does not guard" \
                  || bad "a repository keeps every hook of its own that the engine does not guard ($why35)"

  # --- the suite's own containment ----------------------------------------
  # This section runs an installer that writes git's global configuration. Nothing asserted where that
  # write lands, and a HOME-only sandbox does not contain it: git writes the global config to
  # $XDG_CONFIG_HOME/git/config when that file exists, so on a developer who sets that variable the
  # suite rewrote their real global hook path. The row guards the containment rather than trusting it.
  why35=""
  [ -n "${GIT_CONFIG_GLOBAL:-}" ] || why35="$why35 [no global config sandbox is in effect]"
  case "${GIT_CONFIG_GLOBAL:-}" in
    "$HOME"/*) why35="$why35 [the global config sandbox points inside the real HOME: $GIT_CONFIG_GLOBAL]" ;;
  esac
  case "${XDG_CONFIG_HOME:-}" in
    ""|"$HOME"/*) why35="$why35 [XDG_CONFIG_HOME is unset or inside the real HOME, so git can still escape]" ;;
  esac
  [ -z "$why35" ] && ok "the suite cannot write git configuration outside its own sandbox" \
                  || bad "the suite cannot write git configuration outside its own sandbox ($why35)"

  # --- the drift guard, which must cover them with no change to itself -----
  why35=""
  for h in pre-push pre-commit _chain; do
    grep -q "global/hooks/\*" "$HK/drift-check.sh" || why35="$why35 [the guard has no prefix map for the hooks directory]"
    git -C "$ROOT" ls-files --error-unmatch "global/hooks/git/$h" >/dev/null 2>&1 \
      || why35="$why35 [global/hooks/git/$h is not tracked, so the guard's listing never reaches it]"
    git -C "$ROOT" ls-files -s "global/hooks/git/$h" | grep -q '^100755' \
      || why35="$why35 [global/hooks/git/$h is tracked without its executable bit]"
  done
  [ -z "$why35" ] && ok "the drift guard sees the new hooks" \
                  || bad "the drift guard sees the new hooks ($why35)"
  echo "         ($n35 shapes that name the operation without invoking it, all allowed)"
else
  echo "  [skip] protection-reporting checks (python3 or git unavailable)"
fi


# C36 — the scoping pass measures the frame before the suspect, and the phase says what it never delegates.
# Generated in the Conform phase from understand.md's Verifiable Criteria A1-A9; A10 was added in Verify,
# after inspection alone had already missed the clause it guards once, in the very task that introduced it.
#
# Every verdict is derived from a COUNT inside an extracted region, never from a `grep -v` inside an `if`:
# on BSD grep an empty input exits 0, so the pipeline shape reports the same verdict either way.
#
# THE ROWS BELOW WERE SIZED BY MUTATION, not by reading, and seven of them were rewritten because the
# first draft survived the mutation it existed to catch. What each row pins is therefore the IMPERATIVE or
# the PROHIBITION, never a load-bearing noun: `named suspect` is present whether the prose forbids
# inspecting it or orders it, and `survived` was present in a neighbouring sentence, so deleting the whole
# directive left the row green. A row that pins a word its own rule shares with the rule's negation cannot
# tell a pass from a fail.
echo "== C36: the first measurement can break the question, and the convergence is never delegated =="
UND36="global/protocols/understand.md"
SKL36="global/skills/understand/SKILL.md"

# `-r` and `-s`, not `-f`: a mode-000 or truncated protocol satisfies `-f`, and the rows would then report
# nine deletions of prose that is in fact present. The engine's own rule is that a check which cannot run
# says so, rather than answering as if it had.
if [ -r "$UND36" ] && [ -r "$SKL36" ] && [ -s "$UND36" ] && [ -s "$SKL36" ]; then
  UNDT36="$(cat "$UND36")"
  SKLT36="$(cat "$SKL36")"
  # The investigation block, extracted by its own heading. `/^## Investigation$/` is anchored so the
  # `## Investigation Closure` gate further down does NOT re-open the region — which is exactly why the
  # gate needs its own row (A6 leg 3) rather than being covered by this one.
  INV36="$(awk '/^## Investigation$/{f=1;next} /^## /{f=0} f' "$UND36")"
  # The closure gate, its own region, because the clause it carries is the operative one.
  CLO36="$(awk '/^## Investigation Closure/{f=1;next} /^## /{f=0} f' "$UND36")"
  # The epic cap's home section, so relocating the sentence out of it cannot keep the row green.
  EPI36="$(awk '/^## Epic-Scoped Understanding$/{f=1;next} /^## /{f=0} f' "$UND36")"
  # The artifact template, extracted by its fence rather than by line number so an insertion above it
  # cannot silently move the region out from under these rows.
  TPL36="$(awk '/^## Output: understand.md$/{f=1} f && /^```markdown$/{g=1;next} g && /^```$/{exit} g' "$UND36")"

  n36() { printf '%s' "$1" | grep -ciE "$2" | tr -d ' '; }

  # Every extracted region is asserted non-empty by its own row, the house style of C24: a renamed heading
  # must fail as a renamed heading, not as six simultaneous reports that the prose was deleted.
  r36=""
  [ -n "$INV36" ] || r36="$r36 [the investigation block did not extract — heading renamed?]"
  [ -n "$CLO36" ] || r36="$r36 [the closure gate did not extract]"
  [ -n "$EPI36" ] || r36="$r36 [the epic-scoped section did not extract]"
  [ -n "$TPL36" ] || r36="$r36 [the artifact template did not extract — fence changed?]"
  [ -z "$r36" ] && ok "C36's four regions all extract" || bad "C36's four regions all extract ($r36)"

  # A1 — the altitude rule, pinned by the obligation and not by its subject.
  c1_36=""
  [ "$(n36 "$INV36" 'must be able to falsif(y|ies|ying) the framing')" -ge 1 ] || c1_36="$c1_36 [nothing requires the first measurement to be able to falsify the framing]"
  [ -z "$c1_36" ] && ok "A1 the scoping pass requires a first measurement that can falsify the framing of the question" \
                  || bad "A1 the scoping pass requires a first measurement that can falsify the framing of the question ($c1_36)"

  # A2 — the PROHIBITION, not the noun. `named suspect` is present whether the prose forbids inspecting it
  # first or orders it; deleting two words inverted the rule and the first draft of this row stayed green.
  c2_36=""
  [ "$(n36 "$INV36" 'measure the whole')" -ge 1 ] || c2_36="$c2_36 [the whole is never named as what the first measurement covers]"
  [ "$(n36 "$INV36" 'do not inspect the named suspect')" -ge 1 ] || c2_36="$c2_36 [inspecting the suspect the task named is not refused]"
  [ -z "$c2_36" ] && ok "A2 a task arriving with a diagnosis attached is measured whole before its named part" \
                  || bad "A2 a task arriving with a diagnosis attached is measured whole before its named part ($c2_36)"

  # A3 — the rule as a rule. Its two load-bearing words in one region were satisfiable by disjoint
  # sentences: the headline could go while a neighbouring sentence carried both words and stated nothing.
  c3_36=""
  [ "$(n36 "$INV36" 'convergence is never delegated')" -ge 1 ] || c3_36="$c3_36 [the phase does not state that the convergence is never delegated]"
  [ "$(n36 "$INV36" 'answers the question it was given')" -ge 1 ] || c3_36="$c3_36 [the reason — an agent answers the question it was given — is gone]"
  [ -z "$c3_36" ] && ok "A3 the phase states that the convergence is never delegated" \
                  || bad "A3 the phase states that the convergence is never delegated ($c3_36)"

  # A4 — the IMPERATIVE. `survived` also occurs in the provenance bullet, so the first draft of this row
  # stayed green with the entire directive sentence deleted: it had zero discriminating power.
  c4_36=""
  [ "$(n36 "$INV36" 'delegate a fan-out whose question has survived')" -ge 1 ] || c4_36="$c4_36 [nothing requires a question to have survived measurement before a fan-out]"
  [ "$(n36 "$INV36" 'while the question is still moving, investigate inline')" -ge 1 ] || c4_36="$c4_36 [the unripe question is not directed inline]"
  [ -z "$c4_36" ] && ok "A4 a fan-out waits for a question that survived one round of measurement" \
                  || bad "A4 a fan-out waits for a question that survived one round of measurement ($c4_36)"

  # A5 — the repair, in both directions, and the false framing pinned by SHAPE rather than by one literal:
  # `costs a few minutes` reintroduced it verbatim in meaning past a leg that pinned the exact sentence.
  # The token axis is refused HERE, over the protocol, because that is where the decision applies — the
  # skill never had a cost clause to repair. A later task that means to revisit that decision changes this
  # row deliberately; that is the point of pinning a decision rather than a wording.
  c5_36=""
  [ "$(n36 "$UNDT36" 'costs? (a few |several |some )?minutes')" -eq 0 ] || c5_36="$c5_36 [an investigation agent is priced in minutes again]"
  [ "$(n36 "$INV36" 'not a price paid for prudence')" -ge 1 ] || c5_36="$c5_36 [the sentence that denies the prudence framing is gone]"
  [ "$(n36 "$UNDT36" 'tok/turn|cheaper per turn|[0-9]x cheaper|subagents? (are|run) .{0,20}cheaper')" -eq 0 ] || c5_36="$c5_36 [a token-measured licence to delegate was minted, which this task's decision refused]"
  [ "$(n36 "$INV36" 'invalidates the plan')" -ge 1 ] || c5_36="$c5_36 [the true half went out with the false one: nothing says an unresolved area invalidates the plan]"
  [ -z "$c5_36" ] && ok "A5 no investigation agent is priced as a cost accepted for prudence, and the true half survived" \
                  || bad "A5 no investigation agent is priced as a cost accepted for prudence, and the true half survived ($c5_36)"

  # A6 — provenance, in the doctrine AND in the gate. The gate is the third copy of this clause and the one
  # that blocks the write: two auditors found it independently, and the region above cannot see it.
  c6_36=""
  [ "$(n36 "$INV36" 'first-hand')" -ge 1 ] || c6_36="$c6_36 [a fact read first-hand is not distinguished from a finding an agent reported]"
  [ "$(n36 "$INV36" 'lead, not evidence')" -ge 1 ] || c6_36="$c6_36 [nothing says what an answer to an unripe question is worth]"
  [ "$(n36 "$UNDT36" 'evidence \(file:line or agent finding\)')" -eq 0 ] || c6_36="$c6_36 [the collapsed form is still stated somewhere in the document]"
  [ "$(n36 "$CLO36" 'provenance')" -ge 1 ] || c6_36="$c6_36 [the closure gate accepts evidence without naming its provenance]"
  [ -z "$c6_36" ] && ok "A6 what closes an unknown names whether it was read first-hand or reported by an agent" \
                  || bad "A6 what closes an unknown names whether it was read first-hand or reported by an agent ($c6_36)"

  # A7 — the skill is an independent copy, so it carries both rules, each pinned separately: an alternation
  # accepted half the altitude rule. Leg 3 pins only the repaired sentence's own wording — the measured
  # framing is TRUE and forbidding it here would freeze out a correct future edit rather than guard a rule.
  c7_36=""
  [ "$(n36 "$SKLT36" 'falsif(y|ies|ying) the framing')" -ge 1 ] || c7_36="$c7_36 [the skill mandates the pass without the rule governing its first measurement]"
  [ "$(n36 "$SKLT36" 'measure the whole')" -ge 1 ] || c7_36="$c7_36 [the skill does not say to measure the whole]"
  [ "$(n36 "$SKLT36" 'convergence is never delegated')" -ge 1 ] || c7_36="$c7_36 [the skill carries the delegation trigger with no counterweight]"
  [ "$(n36 "$SKLT36" 'costs? (a few |several )?minutes')" -eq 0 ] || c7_36="$c7_36 [the skill acquired a copy of the repaired sentence]"
  [ -z "$c7_36" ] && ok "A7 the phase skill carries both rules and prices no agent" \
                  || bad "A7 the phase skill carries both rules and prices no agent ($c7_36)"

  # A8 — the trace field, each leg pinned to the region that carries it. The first draft rested the whole
  # conditionality claim on the two words `not written` grepped over the entire document, with two of its
  # three alternatives matching nothing at all.
  c8_36=""
  [ "$(n36 "$TPL36" '^## Altitude')" -ge 1 ] || c8_36="$c8_36 [the artifact template records no first measurement]"
  [ "$(n36 "$TPL36" 'could have falsified')" -ge 1 ] || c8_36="$c8_36 [the field does not ask what the measurement could have falsified]"
  [ "$(n36 "$TPL36" 'omitted otherwise')" -ge 1 ] || c8_36="$c8_36 [the template does not mark the field conditional]"
  [ "$(n36 "$INV36" 'the field is not written')" -ge 1 ] || c8_36="$c8_36 [the scoping pass never says the field is left out where no diagnosis arrived]"
  [ "$(n36 "$TPL36" 'EARS')" -ge 1 ] || c8_36="$c8_36 [the criteria format anchor left the template — the only assertion for it matched a heading outside the fence]"
  [ -z "$c8_36" ] && ok "A8 the artifact template carries the first measurement, and only where a diagnosis arrived attached" \
                  || bad "A8 the artifact template carries the first measurement, and only where a diagnosis arrived attached ($c8_36)"

  # A9 — FROZEN ROW, green from the start, and the only row here whose whole value is that a mutation kills
  # it. Both legs are proven: softening either sentence kills it. Each is pinned to the section that must
  # carry it, and the criterion says "removed OR QUALIFIED" — so the qualification is pinned too, which the
  # first draft could not see: `no broad Explore agents unless the Scope Contract is stale` passed it.
  c9_36=""
  [ "$(n36 "$EPI36" 'do NOT relaunch broad Explore agents')" -ge 1 ] || c9_36="$c9_36 [the epic-scoped prohibition is gone from its own section]"
  [ "$(n36 "$INV36" 'no broad Explore agents')" -ge 1 ] || c9_36="$c9_36 [the skip rules no longer carry the cap]"
  [ "$(n36 "$UNDT36" 'broad Explore agents,? (unless|except|save where|other than)')" -eq 0 ] || c9_36="$c9_36 [the cap acquired an exception, which is the reading this task must not license]"
  [ -z "$c9_36" ] && ok "A9 the cap on broad helpers in an epic's later tasks is intact" \
                  || bad "A9 the cap on broad helpers in an epic's later tasks is intact ($c9_36)"

  # A10 — a genuine cross-document comparison, which the first draft's label claimed and its legs never
  # made: both legs read the skill alone. What it pins is that the two copies of one clause agree, so a
  # repair applied to one and not the other goes red. This is T-041's hazard, guarded rather than trusted.
  c10_36=""
  ph36="$(n36 "$INV36" 'first-hand')"; sh36="$(n36 "$SKLT36" 'first-hand')"
  [ "$ph36" -eq 0 ] || [ "$sh36" -ge 1 ] || c10_36="$c10_36 [the protocol names provenance and the skill does not]"
  [ "$sh36" -eq 0 ] || [ "$ph36" -ge 1 ] || c10_36="$c10_36 [the skill names provenance and the protocol does not]"
  [ "$(n36 "$SKLT36" 'lead, not evidence')" -ge 1 ] || c10_36="$c10_36 [the skill does not say what an answer to an unripe question is worth]"
  [ -z "$c10_36" ] && ok "A10 the skill and the protocol agree on what closes an unknown" \
                   || bad "A10 the skill and the protocol agree on what closes an unknown ($c10_36)"
else
  bad "C36 cannot run: the understand protocol or its phase skill is missing, unreadable or empty"
fi

# C37 — a capability the engine installs but names no way to start is indistinguishable from a dead one.
# Generated in the Conform phase from understand.md's Verifiable Criteria A1-A6.
#
# The task arrived asserting both capabilities were dead. Measurement falsified half of it: the unattended
# loop had run and produced a merged commit, and its silence began the day it was centralised and its only
# documented launcher was left pointing at the old path. So these rows guard TWO OPPOSITE outcomes — the
# analysis capability must be gone, and the loop must still be here. A6 is FROZEN and green from the start:
# the mutation that kills it is this task over-reaching into the retirement it was told not to make.
#
# Every verdict is derived from a COUNT, never from a `grep -v` inside an `if`: on BSD grep an empty input
# exits 0, so that shape reports the same verdict either way.
echo "== C37: what the engine ships, it can say how to start ==" 
MAN37="global/CLAUDE.md"
INS37="install.sh"
WTI37=".worktreeinclude"
WTT37="template/.worktreeinclude"
DRF37="global/hooks/drift-check.sh"

if [ -r "$MAN37" ] && [ -s "$MAN37" ] && [ -r "$INS37" ] && [ -s "$INS37" ] \
   && [ -r "$WTI37" ] && [ -s "$WTI37" ] && [ -r "$WTT37" ] && [ -s "$WTT37" ] \
   && [ -r "$DRF37" ] && [ -s "$DRF37" ] && [ -d global/protocols ]; then
  MANT37="$(cat "$MAN37")"
  INST37="$(cat "$INS37")"

  n37() { printf '%s' "$1" | grep -ciE "$2" | tr -d ' '; }

  # The Quick Commands block, extracted by its own heading, so a launcher mentioned in a comment three
  # sections away cannot answer for a line the reader of that block would actually find.
  QC37="$(awk '/^### Quick Commands$/{f=1;next} /^### /{f=0} f' "$MAN37")"
  # EVERY line that creates directories in a target, not the first: `head -1` truncated the input before
  # the count was taken, so a second `mkdir` elsewhere in install_data() was invisible and the analysis
  # directory could come back with A5 green. Measured, not reasoned.
  MKD37="$(grep -E 'mkdir -p "\$TARGET/\.ai-flow"' "$INS37")"

  r37=""
  [ -n "$QC37" ] || r37="$r37 [the Quick Commands block did not extract — heading renamed?]"
  [ -n "$MKD37" ] || r37="$r37 [the installer's data-skeleton line did not extract]"
  [ -z "$r37" ] && ok "C37's two regions all extract" || bad "C37's two regions all extract ($r37)"

  # A1 — the protocol set, asserted in BOTH directions. The check this replaces (C-era EXPECTED_PROTOS)
  # reported a protocol that was EXTRA and was blind to one that was MISSING, so a deletion — including
  # this task's own — passed it green. Read before being retired: everything it covered is the `extra`
  # leg below, and the `missing` leg is what it never had.
  EXPECT37="backlog.md discover.md execute.md lifecycle.md plan.md quick-path.md understand.md verify.md"
  ACTUAL37="$(ls global/protocols 2>/dev/null | sort | tr '\n' ' ')"
  c1_37=""
  # The extractor proves it found the class before any verdict is drawn from it: an empty listing would
  # otherwise satisfy the `extra` leg and report a clean engine.
  if [ -z "$ACTUAL37" ]; then
    c1_37="$c1_37 [the protocol directory listed nothing]"
  else
    x37=""; m37=""
    for f37 in $ACTUAL37; do
      case " $EXPECT37 " in *" $f37 "*) ;; *) x37="$x37 $f37" ;; esac
    done
    for f37 in $EXPECT37; do
      case " $ACTUAL37 " in *" $f37 "*) ;; *) m37="$m37 $f37" ;; esac
    done
    [ -z "$x37" ] || c1_37="$c1_37 [extra:$x37]"
    [ -z "$m37" ] || c1_37="$c1_37 [missing:$m37]"
    # The directory and the installer's own list are two declarations of one fact, and they were free to
    # drift in the direction nothing watched: dropping a name from PROTOCOLS left the file in the tree,
    # this row green, and the phase never installed again. Derived from data already read — no fixture.
    PL37="$(sed -n 's/^PROTOCOLS="\(.*\)"$/\1/p' "$INS37")"
    if [ -z "$PL37" ]; then
      c1_37="$c1_37 [the installer's protocol list did not extract]"
    else
      for f37 in $PL37; do
        case " $ACTUAL37 " in *" $f37.md "*) ;; *) c1_37="$c1_37 [the installer delivers $f37.md, which is not in the tree]" ;; esac
      done
      for f37 in $ACTUAL37; do
        case " $PL37 " in *" ${f37%.md} "*) ;; *) c1_37="$c1_37 [$f37 ships in the tree and no install delivers it]" ;; esac
      done
    fi
  fi
  [ -z "$c1_37" ] && ok "A1 the engine ships exactly the protocol set it declares" \
                  || bad "A1 the engine ships exactly the protocol set it declares ($c1_37)"

  # A2 — the analysis capability is named nowhere the engine ships. The ledger under .ai-flow/ is the
  # project's own record and is not shipped; test/ is excluded because this very row names the tokens.
  # Bare `codebase` is deliberately NOT a token: the word is ordinary English throughout the protocols
  # ("parts of the codebase a front declared"), and a row that pins it cannot tell a pass from a fail.
  c2_37=""
  # Each path of the surface is asserted to exist before anything is concluded from the scan: `find`
  # sends the error for a missing one to /dev/null, the remaining paths still yield files, and the row
  # would then report "named nowhere" after silently never looking at a whole shipped directory.
  for sp37 in global template docs README.md install.sh; do
    [ -e "$sp37" ] || c2_37="$c2_37 [the shipped surface is missing $sp37 — the scan was narrower than it claims]"
  done
  # A content grep cannot see an empty directory, and the shipped one held only a .gitkeep.
  [ ! -d template/.ai-flow/codebase ] || c2_37="$c2_37 [the shipped analysis directory is back]"
  SURF37="$(find global template docs README.md install.sh -type f 2>/dev/null | sort)"
  if [ -z "$SURF37" ]; then
    c2_37="$c2_37 [the shipped surface listed no file]"
  else
    hits37="$(printf '%s\n' "$SURF37" | tr '\n' '\0' | xargs -0 grep -lE 'codebase-mapping|map codebase|Codebase Mapping|codebase/|CONCERNS\.md|TESTING\.md|DRIFT\.md' 2>/dev/null | sort | tr '\n' ' ')"
    [ -z "$hits37" ] || c2_37="$c2_37 [named in:$hits37]"
  fi
  [ -z "$c2_37" ] && ok "A2 the analysis capability is named nowhere the engine ships" \
                  || bad "A2 the analysis capability is named nowhere the engine ships ($c2_37)"

  # A3 — the manual names how the unattended loop is started. Two legs: the launcher's installed path
  # somewhere in the manual, AND a mention inside the block a reader looking for commands would read.
  # One leg alone passes on a stray path in a directory table, which is what the manual had before.
  c3_37=""
  [ "$(n37 "$MANT37" 'ai-flow/ralph/ralph\.sh')" -ge 1 ] || c3_37="$c3_37 [the manual names no path that starts the loop]"
  [ "$(n37 "$QC37" 'ralph')" -ge 1 ] || c3_37="$c3_37 [the commands block does not name the loop]"
  [ -z "$c3_37" ] && ok "A3 the manual names how the unattended loop is started" \
                  || bad "A3 the manual names how the unattended loop is started ($c3_37)"

  # A4 — the pattern files carry the four data paths and no analysis path, in both directions and in both
  # copies. Absence alone is satisfied by emptying the file; presence alone by leaving the retired line in.
  c4_37=""
  for pf37 in "$WTI37" "$WTT37"; do
    pt37="$(cat "$pf37")"
    for want37 in '^\.ai-flow/project\.yml$' '^\.ai-flow/product\.md$' '^\.ai-flow/steering/$' '^\.ai-flow/artifacts/$'; do
      [ "$(n37 "$pt37" "$want37")" -ge 1 ] || c4_37="$c4_37 [$pf37 lost $want37]"
    done
    [ "$(n37 "$pt37" 'codebase')" -eq 0 ] || c4_37="$c4_37 [$pf37 still names the analysis path]"
  done
  [ -z "$c4_37" ] && ok "A4 the pattern file carries the four data paths and no analysis path" \
                  || bad "A4 the pattern file carries the four data paths and no analysis path ($c4_37)"

  # A5 — the installer creates no analysis directory. Both legs on the SAME extracted line, so the row
  # cannot go green because the line vanished: the three surviving directories must still be named there.
  c5_37=""
  for want37 in steering artifacts archive; do
    [ "$(n37 "$MKD37" "$want37")" -ge 1 ] || c5_37="$c5_37 [the data skeleton no longer creates $want37]"
  done
  [ "$(n37 "$MKD37" 'codebase')" -eq 0 ] || c5_37="$c5_37 [the data skeleton still creates an analysis directory]"
  [ -z "$c5_37" ] && ok "A5 the installer creates no analysis directory" \
                  || bad "A5 the installer creates no analysis directory ($c5_37)"

  # A6 — FROZEN ROW, green before this task's work and after it. What it guards is the half of the ticket
  # that measurement refuted: the loop stays distributed and stays under drift comparison.
  #
  # THE SOURCE LEGS ALONE WERE HOLLOW AND A MUTATION PROVED IT. Deleting the three lines that actually
  # deliver the loop — the `for f in $RALPH; do fetch_file ...` at install.sh:286-288 — left every count
  # below at >=1 and the whole suite green, because the filenames survive on the `RALPH=` line and
  # `ai-flow/ralph` survives on the mkdir, the chmod and the reassuring `[ok] ... installed` echo. That is
  # verbatim the defect C35 records: an installer that stops installing the protection while still
  # claiming to. The executed leg below is the fix — it asks the filesystem the installer wrote to,
  # not the text of the installer.
  c6_37=""
  for f37 in ralph.sh ralph-prompt.md review-prompt.md; do
    [ -s "global/ralph/$f37" ] || c6_37="$c6_37 [global/ralph/$f37 is gone or empty]"
    [ "$(n37 "$INST37" "$f37")" -ge 1 ] || c6_37="$c6_37 [the installer no longer distributes $f37]"
  done
  [ "$(n37 "$INST37" 'ai-flow/ralph')" -ge 1 ] || c6_37="$c6_37 [the installer names no destination for the loop]"
  # The executed leg runs its OWN install rather than borrowing another section's sandbox. The first
  # draft read C9's `$TH` and went red because C9 deletes that directory the moment it is done — the
  # coupling to another section's ordering and cleanup is exactly the fragility this row exists to catch,
  # so the row owns its sandbox. HOME and GIT_CONFIG_GLOBAL are both redirected: the installer writes a
  # global git config, and an assertion must never reach the operator's real one.
  H6_37="$(mktemp -d)"; T6_37="$(mktemp -d)"; W6_37="$(mktemp -d)"
  ( cd "$W6_37" && HOME="$H6_37" GIT_CONFIG_GLOBAL="$H6_37/.gitconfig" \
      bash "$ROOT/install.sh" update "$T6_37" </dev/null >/dev/null 2>&1 ) || true
  if [ -d "$H6_37/.claude" ]; then
    for f37 in ralph.sh ralph-prompt.md review-prompt.md; do
      [ -s "$H6_37/.claude/ai-flow/ralph/$f37" ] || c6_37="$c6_37 [an install delivered no $f37]"
    done
    [ -x "$H6_37/.claude/ai-flow/ralph/ralph.sh" ] || c6_37="$c6_37 [the delivered launcher is not executable]"
  else
    c6_37="$c6_37 [the sandboxed install produced no engine — the delivery could not be checked]"
  fi
  rm -rf "$H6_37" "$T6_37" "$W6_37"
  [ "$(grep -cE 'global/ralph/\*' "$DRF37" | tr -d ' ')" -ge 1 ] || c6_37="$c6_37 [the drift guard no longer maps the loop]"
  [ -z "$c6_37" ] && ok "A6 the unattended loop is still distributed and still watched" \
                  || bad "A6 the unattended loop is still distributed and still watched ($c6_37)"
else
  bad "C37 cannot run: the manual, the installer, a pattern file, the drift guard or the protocol directory is missing, unreadable or empty"
fi

# C38 — a guard whose signal only its own fixtures produce is a guard over nothing.
# The signal here was taken from three narratives a real ledger had accumulated, not from the engine's
# prose: no ceremony emits either signal and no move owns the notes section, so the guard is a backstop
# over what an operator writes, never a check on an output the engine promises.
# Generated in the Conform phase from understand.md's Verifiable Criteria A1-A6.
#
# The ledger guardian searched for three literal phrases (`shipped + archived`, `CLOSED (party)`, `shipped (`)
# that occur NOWHERE in this engine except the hook itself and the fixtures written to satisfy it — so the
# only producer of the detected input was the test that tests the detector. Meanwhile the live roster held
# three closed-epic narratives, which is precisely what its own invariant forbids, and the hook counted 0.
#
# Two rows here assert SILENCE and are green from the start, which is stated rather than hidden: A2 and A4
# cannot be red at Conform, because today's detector is silent on everything. What sizes them is the
# mutation recorded in the baseline manifest — remove the section scoping and A3 must go red, remove the
# near-miss discrimination and A4 must go red. Their green is provisional until that is shown.
#
# A3 IS red at Conform, and honestly so: its fixture is a completed-quick-task row reading
# "first release shipped (v1)", which the phrase list matches — a real false positive of the code being
# replaced, not a contrivance. The sanctioned table must never be counted.
#
# Every verdict is derived from an exact exit code or a COUNT, never from a `grep -v` inside an `if`: on
# BSD grep an empty input exits 0, so that shape reports the same verdict either way.
echo "== C38: the ledger guardian judges the narrative a ledger accumulates =="
HK38="global/hooks/check-state-size.sh"
BLG38="global/protocols/backlog.md"

if ! T38="$(mktemp -d 2>/dev/null)" || [ ! -d "$T38" ]; then
  bad "a closed-epic narrative in the notes blocks the turn close (no sandbox: mktemp -d failed)"
  bad "a roster with nothing but its own notes passes (no sandbox: mktemp -d failed)"
  bad "the completed-quick-task table is never counted as a violation (no sandbox: mktemp -d failed)"
  bad "a note naming another ledger's still-open epic does not fire (no sandbox: mktemp -d failed)"
  bad "the coordinator blocks and the linked worktree stays silent on the same file (no sandbox: mktemp -d failed)"
elif [ ! -r "$HK38" ] || [ ! -s "$HK38" ] || [ ! -r "$BLG38" ] || [ ! -s "$BLG38" ]; then
  bad "a closed-epic narrative in the notes blocks the turn close (hook or protocol unreadable)"
  bad "a roster with nothing but its own notes passes (hook or protocol unreadable)"
  bad "the completed-quick-task table is never counted as a violation (hook or protocol unreadable)"
  bad "a note naming another ledger's still-open epic does not fire (hook or protocol unreadable)"
  bad "the coordinator blocks and the linked worktree stays silent on the same file (hook or protocol unreadable)"
  rm -rf "$T38"   # mktemp had already succeeded on this branch; without this the sandbox leaks
else
  # A state file a reader would recognise as a real ledger: the roster, the notes section, and the
  # sanctioned completed-quick-task table. The old fixture was the bare string the phrase list matched,
  # which is why five rows could keep passing while proving nothing about detection.
  # $4 places the narrative: `notes` (default) inside the notes section, `tail` appended after the
  # quick-task table, `subhead` under a `### ` heading after that table. The last two exist because a
  # region-based exemption was blind to both and shipped that way until Verify reproduced it: the
  # position of the violation is a parameter, never an assumption.
  # $5 is an extra roster row, for the sanctioned table the guard must not read.
  mkstate38() {  # $1 = dir, $2 = notes body ("" for none), $3 = quick-task row, $4 = position, $5 = extra roster row
    mkdir -p "$1/.ai-flow"
    {
      printf '# Session State\n\n## Workstreams\n\n'
      printf '| Workstream | Checkout | Task | Epic | Areas | Tool | Opened |\n'
      printf '|---|---|---|---|---|---|---|\n'
      printf '| coordinator | . | T-100 | E-009 | auth | - | 2026-08-01 |\n'
      [ -n "${5:-}" ] && printf '%s\n' "${5:-}"
      printf '\n## Notes\n\nCross-workstream context only - nothing that belongs to a single task.\n\n'
      [ -n "${2:-}" ] && [ "${4:-notes}" = notes ] && printf '%s\n\n' "$2"
      printf '## Quick Tasks Completed\n\n| Date | Description | Commit |\n|------|-------------|--------|\n'
      printf '%s\n' "$3"
      [ -n "${2:-}" ] && [ "${4:-notes}" = tail ] && printf '\n%s\n' "$2"
      [ -n "${2:-}" ] && [ "${4:-notes}" = subhead ] && printf '\n### Leftovers\n\n%s\n' "$2"
    } > "$1/.ai-flow/STATE.md"
    printf '# Backlog\n' > "$1/.ai-flow/BACKLOG.md"
  }

  # Carries BOTH signals: a close declaration beside an epic identifier, and a path into the archive.
  VIOL38='**Epic E-007 (payments overhaul) CLOSED 2026-07-30.** Sealed decisions and per-task detail: `archive/E-007-payments.md`.'
  # One signal each, so neither alternative of the pattern can be deleted with every row still green:
  # every fixture carrying both at once is what made half the detector removable undetected.
  ONLYC38='**Epic E-007 (payments overhaul) CLOSED 2026-07-30.** Sealed decisions live in the epic file.'
  ONLYA38='**Epic E-007, the payments overhaul.** Sealed decisions: `archive/E-007-payments.md`.'
  # The near miss, taken from the live roster: it says "not archived", names an epic, declares no closure
  # and cites no archive path. A naive search for "archiv" takes it; the discriminator must not.
  NEAR38='Still open in the other project (unrelated, tracked there): epic E-124 is task-complete but not archived.'
  QOK38='| 2026-07-02 | narrowed the refutation to HIGH | `abc1234` |'
  # A legitimate quick-task description that happens to contain one of the retired phrases.
  # Carries BOTH a retired phrase (which is why this row is red at Conform, against the code being
  # replaced) and a live signal — so once the phrase list is gone the row still discriminates: drop the
  # sanctioned table from the scoping and this fixture fires.
  QBAD38='| 2026-07-02 | first release shipped (v1) after epic E-007 CLOSED | `abc1234` |'

  # A1 — the violation the invariant names must stop the turn.
  P38A="$T38/a"; mkproj "$P38A" main >/dev/null 2>&1; mkstate38 "$P38A" "$VIOL38" "$QOK38"
  ( cd "$P38A" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); r38a=$?
  [ "$r38a" = 2 ] \
    && ok "a closed-epic narrative in the notes blocks the turn close" \
    || bad "a closed-epic narrative in the notes blocks the turn close (exit $r38a)"

  # A2 — the other direction. Green at Conform and provisional: see the manifest's mutation.
  P38B="$T38/b"; mkproj "$P38B" main >/dev/null 2>&1; mkstate38 "$P38B" "" "$QOK38"
  ( cd "$P38B" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); r38b=$?
  [ "$r38b" = 0 ] \
    && ok "a roster with nothing but its own notes passes" \
    || bad "a roster with nothing but its own notes passes (exit $r38b)"

  # A3 — the sanctioned table is outside what the guard polices, whatever its rows happen to say.
  P38C="$T38/c"; mkproj "$P38C" main >/dev/null 2>&1; mkstate38 "$P38C" "" "$QBAD38"
  ( cd "$P38C" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); r38c=$?
  [ "$r38c" = 0 ] \
    && ok "the completed-quick-task table is never counted as a violation" \
    || bad "the completed-quick-task table is never counted as a violation (exit $r38c)"

  # A4 — the near miss. Cross-front context is what the notes section is FOR.
  P38D="$T38/d"; mkproj "$P38D" main >/dev/null 2>&1; mkstate38 "$P38D" "$NEAR38" "$QOK38"
  ( cd "$P38D" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); r38d=$?
  [ "$r38d" = 0 ] \
    && ok "a note naming another ledger's still-open epic does not fire" \
    || bad "a note naming another ledger's still-open epic does not fire (exit $r38d)"

  # A5 — the scoping the five older rows exist for, re-asserted over a file that TRIGGERS. Both legs, so
  # neither can carry the other: a silent worktree proves nothing while the coordinator is silent too.
  P38E="$T38/e"; mkproj "$P38E" main >/dev/null 2>&1; mkstate38 "$P38E" "$VIOL38" "$QOK38"
  mkdir -p "$P38E/sub"
  W38E="$T38/e-wt"; $GIT -C "$P38E" worktree add -q -b wt38 "$W38E" >/dev/null 2>&1
  cp -R "$P38E/.ai-flow" "$W38E/.ai-flow"
  r38e=""
  ( cd "$P38E/sub" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); x38=$?
  [ "$x38" = 2 ] || r38e="$r38e [a subdirectory of the coordinator did not block: exit $x38]"
  ( cd "$W38E" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); x38=$?
  [ "$x38" = 0 ] || r38e="$r38e [the linked worktree was judged on the coordinator's ledger: exit $x38]"
  [ -z "$r38e" ] \
    && ok "the coordinator blocks and the linked worktree stays silent on the same file" \
    || bad "the coordinator blocks and the linked worktree stays silent on the same file:$r38e"

  # A7/A8 — the position of the narrative is not the guard's business. Both were exit 0 under the
  # region-based exemption that shipped into Verify: the quick-task section is LAST in both shipped roster
  # shapes, so exempting to the next `## ` heading exempted to end of file, and `^## ` never matched `### `.
  for pos38 in tail subhead; do
    P38F="$T38/f-$pos38"; mkproj "$P38F" main >/dev/null 2>&1
    mkstate38 "$P38F" "$VIOL38" "$QOK38" "$pos38"
    ( cd "$P38F" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); r38f=$?
    [ "$r38f" = 2 ] \
      && ok "a closed-epic narrative is caught with the narrative in the $pos38 position" \
      || bad "a closed-epic narrative is caught with the narrative in the $pos38 position (exit $r38f)"
  done

  # A9/A10 — each signal alone. Deleting either alternative of the pattern must now cost a row.
  P38G="$T38/g"; mkproj "$P38G" main >/dev/null 2>&1; mkstate38 "$P38G" "$ONLYC38" "$QOK38"
  ( cd "$P38G" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); r38g=$?
  [ "$r38g" = 2 ] \
    && ok "a closure declared beside an identifier is caught with no archive path present" \
    || bad "a closure declared beside an identifier is caught with no archive path present (exit $r38g)"

  P38H="$T38/h"; mkproj "$P38H" main >/dev/null 2>&1; mkstate38 "$P38H" "$ONLYA38" "$QOK38"
  ( cd "$P38H" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); r38h=$?
  [ "$r38h" = 2 ] \
    && ok "a path into the archive is caught with no closure declared" \
    || bad "a path into the archive is caught with no closure declared (exit $r38h)"

  # A12 — the one state file guaranteed to exist in every adopting project. Every other fixture here is a
  # hand-authored lookalike, and a false positive on the shipped template would block the turn close in
  # every adopting project on day one. No fixture to write: the artifact is in the repository.
  P38T="$T38/t"; mkproj "$P38T" main >/dev/null 2>&1; mkdir -p "$P38T/.ai-flow"
  cp "$ROOT/template/.ai-flow/STATE.md" "$P38T/.ai-flow/STATE.md"
  printf '# Backlog\n' > "$P38T/.ai-flow/BACKLOG.md"
  ( cd "$P38T" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); r38t=$?
  [ "$r38t" = 0 ] \
    && ok "the state file the engine ships passes its own ledger guardian" \
    || bad "the state file the engine ships passes its own ledger guardian (exit $r38t)"
  # And the same file with a closed-epic narrative appended is caught — the pair, so a guard that has gone
  # silent everywhere cannot answer for the row above.
  printf '\n%s\n' "$VIOL38" >> "$P38T/.ai-flow/STATE.md"
  ( cd "$P38T" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); r38u=$?
  [ "$r38u" = 2 ] \
    && ok "the shipped state file with a closed-epic narrative appended is caught" \
    || bad "the shipped state file with a closed-epic narrative appended is caught (exit $r38u)"

  # A11 — the roster is the other sanctioned section, and an ordinary area declaration in this very
  # engine names a path inside the archive. A guard that reads it blocks the turn on the line the
  # invariant sanctions, with a message telling the operator to trim the roster it just flagged.
  P38I="$T38/i"; mkproj "$P38I" main >/dev/null 2>&1
  mkstate38 "$P38I" "" "$QOK38" notes '| ws-b | ../p-wt-b | you/t-101-x | T-101 | E-009 | archive/EPICS.md, protocols | git | 2026-08-02 |'
  ( cd "$P38I" && bash "$ROOT/$HK38" >/dev/null 2>&1 ); r38i=$?
  [ "$r38i" = 0 ] \
    && ok "a front declaring an area inside the archive does not make the roster a violation" \
    || bad "a front declaring an area inside the archive does not make the roster a violation (exit $r38i)"

  rm -rf "$T38"
fi

# A6 — the invariant and the template it ships must not disagree. Pinned by the POSITIVE form the rule
# has to carry (it names the section it exempts), never by the absence of the wording it used to have:
# a rule reworded into a different unqualified prohibition would pass a check that only knew the old words.
INV38="$(awk '/^### Invariants \(always true\)/{f=1;next} f && /^#{2,3} /{exit} f' "$BLG38" 2>/dev/null)"
# The invariant is a bullet, not a line: it wraps across several physical lines, and reading only the
# first one asserts about where the typography falls rather than about what the rule says. The region is
# the bullet — from the entry naming the shared state file to the next entry or the end — joined into one
# line before anything is asserted about it, with runs of whitespace squeezed — joining alone is not
# normalising: the continuation indent survives the join, so a phrase broken across two lines comes back
# with two spaces in the middle and a single-spaced pattern misses it. Scoped to that bullet and not to the
# whole block, so a neighbouring invariant carrying the word cannot answer for this one.
S38="$(printf '%s\n' "$INV38" | awk '
  /^- / { if (f) exit; if ($0 ~ /STATE\.md/) { f=1; print; next } ; next }
  f { print }
' | tr '\n' ' ' | tr -s ' ')"
a38=""
[ -n "$INV38" ] || a38="$a38 [the invariants section is absent or empty]"
[ -n "$S38" ]   || a38="$a38 [no invariant names the shared state file]"
printf '%s' "$S38" | grep -q 'Quick Tasks Completed' || a38="$a38 [the invariant does not name the record it exempts]"
# The exemption alone is half a rule: an invariant that named the exempt record and forbade nothing would
# satisfy a check that only looked for the exemption. Both halves, or the narrowing could be widened into a
# permission with this row green.
printf '%s' "$S38" | grep -qE 'no historical narrative|no history' || a38="$a38 [the invariant no longer forbids narrative outside it]"
# O3's other half: the remedy must say where the narrative belongs, not only where it must not go.
REM38="$(grep -i 'trim STATE.md down to' "$HK38" 2>/dev/null)"
printf '%s' "$REM38" | grep -q 'archive/' || a38="$a38 [the remedy does not name the archive as the destination]"
[ -z "$a38" ] \
  && ok "the roster invariant forbids narrative and names the record it exempts, and the remedy names the archive" \
  || bad "the roster invariant forbids narrative and names the record it exempts, and the remedy names the archive:$a38"



echo "== C39: the drift guard speaks once per request, and its detached-workspace remedy names what it destroys =="
# Conformance rows for the engine drift guard's continuation handling and its front-variant message.
# The guard is exercised, never grepped: every verdict below is this hook's own exit code or its own
# stderr, produced over a fixture where the installed engine genuinely matches no checkout.
T39="$(mktemp -d 2>/dev/null)"
if [ -z "$T39" ] || [ ! -d "$T39" ]; then
  bad "C39 cannot run: mktemp -d failed"
else
  # A trap is global state and setting one REPLACES what an earlier section installed — the rule this
  # file states at C19 and follows at C25. Carry the live paths, and hand the trap back below rather
  # than clearing it: this is the last block, so a cleared trap leaks every earlier sandbox on every run.
  trap 'rm -rf "$T12" "$T13" "$T25" "$T39"' EXIT
  # A clone with an engine, plus a linked worktree of it — the shape that makes the guard's SRC2
  # branch reachable, which is the only branch where the front remedy is ever printed.
  E39="$T39/engine"; mkdir -p "$E39/global/hooks"
  $GIT init -q "$E39" 2>/dev/null
  printf 'v1\n' > "$E39/global/hooks/x.sh"
  $GIT -C "$E39" add global >/dev/null 2>&1; $GIT -C "$E39" commit -q -m engine >/dev/null 2>&1
  W39="$T39/engine-wt"; $GIT -C "$E39" worktree add -q -b eng39 "$W39" >/dev/null 2>&1
  H39="$T39/home"; mkdir -p "$H39/.claude/ai-flow" "$H39/.claude/hooks"
  printf '%s\n' "$E39" > "$H39/.claude/ai-flow/source.path"
  printf 'v9\n' > "$H39/.claude/hooks/x.sh"      # installed matches no checkout -> real drift

  # Delivered through a real pipe, which is the shape a harness uses. A here-string is a temp file and
  # a file is not a pipe: reading one proves nothing about the other, and the read under test is the
  # part that differs between them.
  drift39() {  # $1 = payload; sets out39 / RC39
    out39="$( printf '%s' "$1" | ( cd "$W39" && HOME="$H39" bash "$HK/drift-check.sh" 2>&1 ) )"; RC39=$?
  }

  # A2 first: the fixture must actually be in the state the other rows conclude from. A row asserting
  # silence over a fixture that was never drifted passes for a reason that has nothing to do with the fix.
  drift39 '{}'
  [ "$RC39" = 2 ] && ok "the drift guard still refuses a fresh stop over a drifted engine" \
                  || bad "the drift guard still refuses a fresh stop over a drifted engine (exit $RC39)"

  # The payload production actually sends. Every other row here carries the field ABSENT or true, and
  # absent is a different branch of the decision from present-and-false: with only those, a guard that
  # keyed on the field's NAME and ignored its value would satisfy the whole section while being silenced
  # on every real stop forever. The harness always sends the field, and on a fresh stop it sends false.
  drift39 '{"session_id":"s","transcript_path":"/t","stop_hook_active":false}'
  a2b39=""
  [ "$RC39" = 2 ] || a2b39="$a2b39 [exit $RC39, expected 2]"
  printf '%s' "$out39" | grep -q 'engine drift' || a2b39="$a2b39 [no report was printed]"
  [ -z "$a2b39" ] && ok "the guard refuses when the harness says the stop is a fresh one" \
                  || bad "the guard refuses when the harness says the stop is a fresh one:$a2b39"

  # A1 — the continuation the harness is already re-delivering
  drift39 '{"stop_hook_active":true}'
  a1_39=""
  [ "$RC39" = 0 ] || a1_39="$a1_39 [exit $RC39, expected 0]"
  [ -z "$out39" ] || a1_39="$a1_39 [it still printed a report]"
  [ -z "$a1_39" ] && ok "the drift guard is silent on a stop the harness is re-delivering" \
                  || bad "the drift guard is silent on a stop the harness is re-delivering:$a1_39"

  # The same continuation with a space after the colon — the form any serializer emits by default, and
  # the one a text match tuned to the compact shape silently stops recognising.
  drift39 '{"stop_hook_active": true}'
  [ "$RC39" = 0 ] && ok "the continuation is recognised whatever spacing the payload uses" \
                  || bad "the continuation is recognised whatever spacing the payload uses (exit $RC39)"

  # Malformed input is absent input, and absent reports. A guard deciding by the characters of its
  # payload reads a truncated write, or the field quoted inside another value, as an instruction to go
  # quiet — a false all-clear over an engine that really is undistributed.
  m39=""
  drift39 '{"stop_hook_active":true'
  [ "$RC39" = 2 ] || m39="$m39 [a truncated payload silenced it: exit $RC39]"
  drift39 'error: stop_hook_active: true'
  [ "$RC39" = 2 ] || m39="$m39 [a non-JSON blob silenced it: exit $RC39]"
  drift39 '{"msg":"stop_hook_active true","stop_hook_active":false}'
  [ "$RC39" = 2 ] || m39="$m39 [the field inside another value silenced it: exit $RC39]"
  [ -z "$m39" ] && ok "a payload that is not a well-formed object carrying the field is treated as absent" \
                || bad "a payload that is not a well-formed object carrying the field is treated as absent:$m39"

  # A3 — a payload that never arrives must not become a hung session, AND must not become a silent
  # pass. The wall clock is only half the row: a sentinel written unconditionally proves the process
  # returned and nothing about what it returned, so the exit code is what gets recorded and asserted.
  F39="$T39/fifo"; RCF39="$T39/rc"
  if mkfifo "$F39" 2>/dev/null; then
    ( exec 9>"$F39"; sleep 8 ) &
    holder39=$!
    ( cd "$W39" && HOME="$H39" bash "$HK/drift-check.sh" >/dev/null 2>&1 <"$F39"; echo "$?" > "$RCF39" ) &
    w39=0
    while [ ! -s "$RCF39" ] && [ "$w39" -lt 5 ]; do sleep 1; w39=$((w39+1)); done
    a3_39=""
    if [ ! -s "$RCF39" ]; then
      a3_39="$a3_39 [still waiting after ${w39}s]"
    else
      [ "$(cat "$RCF39")" = 2 ] || a3_39="$a3_39 [it returned $(cat "$RCF39"), not a refusal — a stall was replaced by a false all-clear]"
    fi
    [ -z "$a3_39" ] && ok "the drift guard returns its verdict when the payload never arrives" \
                    || bad "the drift guard returns its verdict when the payload never arrives:$a3_39"
    kill "$holder39" 2>/dev/null; wait 2>/dev/null
  else
    bad "the drift guard returns its verdict when the payload never arrives (no sandbox: mkfifo failed)"
  fi

  # The plain no-stdin case, which is not the same as the one above: here EOF is immediate and the
  # guard must still refuse rather than read the silence as a continuation.
  out39="$( cd "$W39" && HOME="$H39" bash "$HK/drift-check.sh" 2>&1 </dev/null )"; RC39=$?
  n39=""
  [ "$RC39" = 2 ] || n39="$n39 [exit $RC39, expected 2]"
  printf '%s' "$out39" | grep -q 'engine drift' || n39="$n39 [no report was printed]"
  [ -z "$n39" ] && ok "an empty payload is absent input and still refuses" \
                || bad "an empty payload is absent input and still refuses:$n39"

  # A4 — the front remedy is printed only from a linked checkout, and must name the permanent silence.
  drift39 '{}'
  a4_39=""
  printf '%s' "$out39" | grep -q "the checkout this session is in" \
    || a4_39="$a4_39 [the fixture never reached the front branch, so this row proves nothing]"
  # Word-presence alone certifies a mention, not the act: a message that kept offering the front
  # install as an annotated option, with "source.path" and "silent" dropped into the comment beside
  # it, satisfied every keyword this row first asked for. What separates the repair from that is
  # structure and cause, so both are what is asserted -- the consequence stands on its own lines
  # ahead of the command, and the silence is tied to the thing that produces it.
  cmdline39="$(printf '%s\n' "$out39" | grep -n "install\.sh' update" | tail -1 | cut -d: -f1)"
  srcline39="$(printf '%s\n' "$out39" | grep -n 'source\.path' | head -1 | cut -d: -f1)"
  if [ -z "$srcline39" ]; then
    a4_39="$a4_39 [the message does not say the guard's own source gets repointed]"
  elif [ -z "$cmdline39" ] || [ "$srcline39" -ge "$cmdline39" ]; then
    a4_39="$a4_39 [the consequence does not stand ahead of the command it qualifies]"
  fi
  # The command is a last resort, not an entry in a list: an annotation riding on its own line is how
  # it reads as the second column of a choice.
  printf '%s\n' "$out39" | grep "install\.sh' update" | grep -q '#' \
    && a4_39="$a4_39 [the command is still annotated as an option rather than named as a last resort]"
  printf '%s' "$out39" | grep -qiE 'silen(t|ce)' \
    || a4_39="$a4_39 [the message does not name the silence it costs]"
  # A hedge is not a consequence. The silence has a cause -- the closing dismantles the checkout -- and
  # a message that says only "it may go silent" has told the operator nothing they can act on.
  printf '%s' "$out39" | grep -qiE 'dismantl|closes|close ' \
    || a4_39="$a4_39 [the silence is not tied to the checkout being dismantled]"
  printf '%s' "$out39" | grep -q "reverts this checkout's engine commits" \
    && a4_39="$a4_39 [the old sentence still prices the choice by which commits get installed]"
  [ -z "$a4_39" ] && ok "the front remedy names the permanent silence it costs" \
                  || bad "the front remedy names the permanent silence it costs:$a4_39"

  # The ordinary remedy was promised untouched, and nothing asserted it. A4 cannot: its command probe
  # takes the LAST match, so deleting the clone line above leaves every one of its arms satisfied.
  o39=""
  cloneline39="$(printf '%s\n' "$out39" | grep -n "bash '$E39/install.sh' update" | head -1 | cut -d: -f1)"
  [ -n "$cloneline39" ] || o39="$o39 [the clone remedy is gone]"
  [ -n "$cloneline39" ] && [ -n "$cmdline39" ] && [ "$cloneline39" -ge "$cmdline39" ] \
    && o39="$o39 [the clone remedy no longer stands first]"
  [ -z "$o39" ] && ok "the ordinary remedy is still offered, and still first" \
                || bad "the ordinary remedy is still offered, and still first:$o39"

  rm -rf "$T39"
  trap 'rm -rf "$T12" "$T13" "$T25"' EXIT   # handed back to the section that owned it
fi

echo "== C40: the position a task is opened at is named, and it is not a phase =="
# The rail is raised while a sheet declares UNDERSTAND, and lowered by the phase commands that own the
# field. What nothing owned was the value activation writes: measured over 41 sheets it took four
# (UNDERSTAND 26, ACTIVATE 13, EXECUTE 3, ACTIVATED 1), so the rail stood up on some tasks and stayed
# down on others, decided by nothing. Both halves of that are guarded here, and the value is read from
# the protocol rather than restated: a test carrying its own copy would let the prose drift back with
# the suite green — a guard that certifies the state it exists to prevent.
B40="global/protocols/backlog.md"
# Not anchored at line start: a restatement appended mid-paragraph is a second home, and an anchored
# count is blind to precisely the copy someone would write by accident.
DECL40='\*\*The first position is `[A-Z]+`\.\*\*'
# The lifecycle's own phase vocabulary. The row's name claims the position is not a phase, and a check
# that rejects only UNDERSTAND leaves the other wrong answer open: a first position of EXECUTE passes
# every arm below while satisfying the audit's accepted positions, so `verify` would run clean on a task
# nobody planned. The claim the section makes is the claim that gets pinned.
PHASES40='UNDERSTAND|PLAN|CONFORM|EXECUTE|VERIFY|ARCHIVE'

# --- the value has exactly one home, inside the section that owns it -------
# Counted, not merely found: two statements are how the template and the ceremony come to disagree, and
# a presence grep cannot see the second one. Counted twice over — once across global/, once inside the
# section move 7 points at — so the pointer in move 7 is verified rather than assumed. The shipped
# template and the docs are counted too: a copy there is as much a second home as one in global/.
# Fence-aware, the shape C22 uses for the precondition block: this section embeds the ledger and sheet
# templates in code fences, and those carry markdown headings of their own — a naive bound ends the
# section at the first `## Workstreams` inside a fence and reads the declaration as living outside it.
SF40="$(awk '/^## State Files/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$B40")"
ALL40="$(grep -rhoE "$DECL40" global/ 2>/dev/null | wc -l | tr -d ' ')"
IN40="$(printf '%s\n' "$SF40" | grep -oE "$DECL40" | wc -l | tr -d ' ')"
ELSEWHERE40="$(grep -rhoE "$DECL40" template/ docs/ 2>/dev/null | wc -l | tr -d ' ')"
POS40="$(grep -rhoE "$DECL40" global/ 2>/dev/null | head -1 | sed -E 's/.*`([A-Z]+)`.*/\1/')"
a1_40=""
[ "$ALL40" = "1" ] || a1_40="$a1_40 [declared $ALL40 times in global/, want exactly 1]"
[ "$IN40" = "1" ] || a1_40="$a1_40 [declared $IN40 times inside ## State Files, where move 7 points]"
[ "$ELSEWHERE40" = "0" ] || a1_40="$a1_40 [declared $ELSEWHERE40 times outside global/]"
[ -n "$POS40" ] || a1_40="$a1_40 [no position named]"
printf '%s' "$POS40" | grep -qxE "$PHASES40" \
  && a1_40="$a1_40 [the position is a phase ($POS40); activation writes no phase]"
[ -z "$a1_40" ] && ok "the opening ceremony names exactly one first position, and it is not a phase" \
                || bad "the opening ceremony names exactly one first position, and it is not a phase:$a1_40"

# --- the sites that write or judge the position point at that home --------
# Move 7 and the Activation row are what a session reads at activation; the accepted-positions clause is
# what judges the value afterwards, and it is Step 2's whole deliverable — unasserted, it could revert to
# calling the position undefined with the suite green. Flattened with the whitespace squeezed, not merely
# with newlines swapped: these are wrapped markdown paragraphs, so a naive swap keeps the continuation
# indent inside the text and a phrase straddling a line break stops matching. An assertion whose verdict
# depends on where a paragraph happens to wrap cannot tell a pass from a fail.
flat40() { tr '\n' ' ' | tr -s ' '; }
M40="$(awk '/^7\. \*\*Write the roster row/{f=1} f&&/^## /{exit} f' "$B40" | flat40)"
R40="$(grep -E '^\| \*\*Activation\*\*' "$B40" | flat40)"
A40="$(awk '/^- \*\*Accepted positions\.\*\*/{f=1} f&&/^- \*\*The material leg/{exit} f' "$B40" | flat40)"
a2_40=""
[ -n "$M40" ] || a2_40="$a2_40 [move 7 not found]"
[ -n "$R40" ] || a2_40="$a2_40 [the Activation row not found]"
[ -n "$A40" ] || a2_40="$a2_40 [the accepted-positions clause not found]"
for pair40 in "move-7:$M40" "activation-row:$R40" "accepted-positions:$A40"; do
  who40="${pair40%%:*}"; txt40="${pair40#*:}"
  printf '%s' "$txt40" | grep -qF 'first position' \
    || a2_40="$a2_40 [$who40 does not point at the first position rule]"
done
# The two writing sites must name no value of their own. The forbidden set is derived from the value that
# was read, not hard-coded: the most likely restatement is move 7 adding "it is ACTIVATE", which a list
# of phase names alone cannot see.
for pair40 in "move-7:$M40" "activation-row:$R40"; do
  who40="${pair40%%:*}"; txt40="${pair40#*:}"
  printf '%s' "$txt40" | grep -qE "\b(${POS40:-__none__}|$PHASES40)\b" \
    && a2_40="$a2_40 [$who40 names a position of its own instead of citing the rule]"
done
# The clause that judges the value legitimately names phases (`plan` runs on UNDERSTAND or PLAN), so the
# arm it gets is the false claim this task retired, not a token ban.
printf '%s' "$A40" | grep -qiF 'undefined' \
  && a2_40="$a2_40 [the accepted-positions clause still calls the first position undefined]"
# The template is the block a reader copies from, and it is the third site the criterion names. It is
# asserted positively — it must carry the position — because it also carries an in-flight illustration on
# purpose, so a token ban would either fail on that or pass on nothing.
# Bounded to the text ABOVE the declaration, not to the whole subsection: the declaration states the
# write in its own prose, so a check over the section as a whole is satisfied by the very paragraph it
# is meant to be independent of — delete the template's line and it still passes. What must carry the
# position is the block a reader copies and the note beside it, which is everything before the rule.
T40BLK="$(awk '/^### `artifacts\/T-XXX\/state.md`/{f=1;next} f&&index($0,"**The first position is")>0{exit} f&&/^### /{exit} f' "$B40" | flat40)"
[ -n "$T40BLK" ] || a2_40="$a2_40 [the sheet a reader copies from not found]"
[ -n "$POS40" ] && { printf '%s' "$T40BLK" | grep -qF "phase: **$POS40**" \
  || a2_40="$a2_40 [the sheet a reader copies from never shows the first position]"; }
[ -z "$a2_40" ] && ok "the ceremony's writing sites cite the first position instead of restating one" \
                || bad "the ceremony's writing sites cite the first position instead of restating one:$a2_40"

# --- the named position leaves the rail down, and UNDERSTAND still raises it -
# Derived from the declaration above: this is the assertion that makes the prose load-bearing. The
# UNDERSTAND arm is not decoration — a fixture that only proves "exit 0" is satisfied by a hook that
# never blocks anything, so both verdicts are taken from the same fixture. A missing interpreter is a
# skip, the way every sibling section treats it: reporting it as a failure blames the protocol for the
# machine. The sandbox is guarded and registered on the trap, the convention this file states and keeps.
if [ -z "$POS40" ]; then
  bad "the position the ceremony writes leaves the read-only rail down [no position to derive from]"
elif [ "$PY3" != 1 ]; then
  echo "  [skip] the read-only rail fixture (python3 unavailable)"
elif ! T40="$(mktemp -d 2>/dev/null)" || [ ! -d "$T40" ]; then
  bad "the position the ceremony writes leaves the read-only rail down (no sandbox: mktemp -d failed)"
else
  trap 'rm -rf "$T12" "$T13" "$T25" "$T40"' EXIT
  P40="$T40/p"; mkproj "$P40" main
  mkdir -p "$P40/.ai-flow/artifacts/opened"
  a3_40=""
  [ -d "$P40/.git" ] || a3_40="$a3_40 [the fixture repository was never built]"
  printf 'branch: main\nphase: **%s**\n' "$POS40" > "$P40/.ai-flow/artifacts/opened/state.md"
  out_open40="$(wguard "$P40" "$P40/app.txt" 2>&1)"; rc_open40=$?
  printf 'branch: main\nphase: **UNDERSTAND**\n'   > "$P40/.ai-flow/artifacts/opened/state.md"
  out_und40="$(wguard "$P40" "$P40/app.txt" 2>&1)"; rc_und40=$?
  [ "$rc_open40" = 0 ] || a3_40="$a3_40 [a sheet at $POS40 refused a code write (exit $rc_open40)]"
  # Exit 1 is the hook erroring, not refusing, and a discarded diagnostic reports the two identically.
  [ "$rc_und40" = 2 ] || a3_40="$a3_40 [the same sheet at UNDERSTAND did not refuse (exit $rc_und40: $(printf '%s' "$out_und40" | tr '\n' ' ' | cut -c1-120))]"
  case "$out_und40" in
    *"artifacts/opened/state.md"*) : ;;
    *) a3_40="$a3_40 [the refusal does not name the sheet it read]" ;;
  esac
  [ -z "$a3_40" ] && ok "the position the ceremony writes leaves the read-only rail down" \
                  || bad "the position the ceremony writes leaves the read-only rail down:$a3_40"
  rm -rf "$T40"
  trap 'rm -rf "$T12" "$T13" "$T25"' EXIT   # handed back to the section that owned it
fi

echo "== C41: a front is located by the one field a chain of tasks does not change =="
BLG41="global/protocols/backlog.md"
TPL41="template/.ai-flow/STATE.md"

# Extractors re-declared rather than inherited: a criterion reading another section's extractor changes
# verdict when that one is re-scoped. Each is asserted non-empty before any verdict is trusted — an
# assertion that fails because its extractor found nothing passes on anything once the file is edited.
CLO41="$(awk '/^## Closing a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG41")"
OPN41="$(awk '/^## Opening a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG41")"
c41() { printf '%s\n' "$CLO41" | awk -v n="$1" '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==n' | tr '\n' ' ' | tr -s ' '; }
o41() { printf '%s\n' "$OPN41" | awk -v n="$1" '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==n' | tr '\n' ' ' | tr -s ' '; }
sec41() { awk -v h="$1" '$0 ~ h {f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^#+ /){f=0} f' "$BLG41" | tr '\n' ' ' | tr -s ' '; }
# The checklist's items one at a time. The deletion step is item 4 and its neighbours talk about the same
# papers in the same words, so a section-wide grep passes on a neighbour's sentence.
ARCH41="$(awk '/^### After ARCHIVE/{f=1;next} /^#+ /{if(f) exit} f' "$BLG41")"
a41() { printf '%s\n' "$ARCH41" | awk -v s="^$1\. " -v e="^$(($1 + 1))\. " '$0 ~ e {f=0} $0 ~ s {f=1} f' | tr '\n' ' ' | tr -s ' '; }

M2_41="$(c41 2)"
if [ -n "$M2_41" ]; then
  # The field AND the absence of the one it replaces, as a pair: the new spelling can be added beside the
  # old one and read as done, while what makes the locator stable is that only one field is named.
  m41a=""
  printf '%s' "$M2_41" | grep -qiE 'checkout path|path on that front|by the checkout' || m41a="$m41a the-path-is-not-the-key"
  printf '%s' "$M2_41" | grep -qiE 'matched by the branch|by the branch on'           && m41a="$m41a the-branch-is-still-a-key"
  [ -z "$m41a" ] && ok "the collection move locates the front by the checkout path on its roster row" \
                 || bad "the collection move locates the front by the checkout path on its roster row (:$m41a)"

  # The rationale, guarded because this epic has already watched an unguarded one go: a reason nothing
  # asserts is deletable with the suite green, and this one is the whole reason the field changed.
  printf '%s' "$M2_41" | grep -qiE 'does not (move|change)|no chain of tasks|never moves|outlives' \
    && ok "the field the locator keys on is the one no chain of tasks changes" \
    || bad "the field the locator keys on is the one no chain of tasks changes"

  # One anchored pattern, not three presences. As three, each leg was satisfiable by unrelated text in
  # this same move: the listing by the locator sentence, the halt by any word containing 'stop', the path
  # by m41a's own leg three lines above. The fact is that the absence OF THAT PATH is what halts it.
  printf '%s' "$M2_41" | grep -qiE 'listing does not name that path[^.]*stop|does not name that path, stop' \
    && ok "an unlocatable front still stops the closing, on the absence of that path" \
    || bad "an unlocatable front still stops the closing, on the absence of that path"

  # The hole the removed column opens. The merge needs a branch and the roster was the only field that
  # could have been read for it, so the ceremony must name a source or the removal strands a consumer.
  FLAT41="$(printf '%s' "$CLO41" | tr '\n' ' ' | tr -s ' ')"
  m41c=""
  printf '%s' "$FLAT41" | grep -qiE "branch[^.]*(read|comes) from[^.]*(checkout|git)|git[^.]*that checkout" \
    || m41c="$m41c no-source-named"
  printf '%s' "$FLAT41" | grep -qiE 'never from the roster|not from the roster|never the roster' \
    || m41c="$m41c roster-not-excluded"
  [ -z "$m41c" ] && ok "the branch the merge needs is read from the located checkout, never from the roster" \
                 || bad "the branch the merge needs is read from the located checkout, never from the roster (:$m41c)"
else
  bad "the collection move locates the front by the checkout path on its roster row (move not found)"
  bad "the field the locator keys on is the one no chain of tasks changes (move not found)"
  bad "an unlocatable front still stops the closing, on the absence of that path (move not found)"
  bad "the branch the merge needs is read from the located checkout, never from the roster (move not found)"
fi

A4_41="$(a41 4)"
if [ -n "$A4_41" ]; then
  # One home for the rule. This step both delegates to the collection move and restates its field, so
  # the restatement is the second copy — and a second copy is what the repository's own rule refuses.
  m41d=""
  printf '%s' "$A4_41" | grep -qiE 'the way move 2|as move 2|the way the collection move' || m41d="$m41d no-delegation"
  # Not the literal phrase this diff deleted: a restatement in different words ("keyed on the path its
  # roster row records") would pass while the rule has two homes again, which is what the label denies.
  printf '%s' "$A4_41" | grep -qiE 'worktree listing|checkout path|roster row'             && m41d="$m41d restates-the-rule"
  [ -z "$m41d" ] && ok "the deletion step locates the front the way the collection move does, and states it once" \
                 || bad "the deletion step locates the front the way the collection move does, and states it once (:$m41d)"
else
  bad "the deletion step locates the front the way the collection move does, and states it once (no step)"
fi

# Scoped to the Checkout paragraph, NOT to the roster section: over the whole section a readers leg is
# carried by the pre-existing Tool sentence ("read by the closing ceremony's dismantling move"), which is
# a different column and a different reader — it was already green before this change, so the half of the
# criterion that matters ("and name what reads it") was inert. Bounded at the sibling that follows.
CHK41="$(awk '/^\*\*Checkout\*\*/{f=1} f&&/^\*\*Areas\*\*/{exit} f' "$BLG41" | tr '\n' ' ' | tr -s ' ')"
if [ -n "$CHK41" ]; then
  # All four readers, because the count is the fact: a definition naming half the readership is what the
  # next person prices a change to this column from, and two of the four unlisted sites act destructively.
  m41e=""
  printf '%s' "$CHK41" | grep -qE '\*\*Checkout\*\*'                     || m41e="$m41e undefined"
  printf '%s' "$CHK41" | grep -qiE 'four'                                 || m41e="$m41e reader-count-unstated"
  printf '%s' "$CHK41" | grep -qiE 'collection move'                      || m41e="$m41e collection-unnamed"
  printf '%s' "$CHK41" | grep -qiE 'dismantl'                             || m41e="$m41e dismantling-unnamed"
  printf '%s' "$CHK41" | grep -qiE 'last move'                            || m41e="$m41e last-move-unnamed"
  printf '%s' "$CHK41" | grep -qiE 'deletion step|archive checklist'      || m41e="$m41e deletion-unnamed"
  [ -z "$m41e" ] && ok "the checkout column is defined where it lives, and names all four sites that read it" \
                 || bad "the checkout column is defined where it lives, and names all four sites that read it (:$m41e)"

  # The mechanism the whole re-key rests on, and it was deletable from both its sites with the suite fully
  # green — proven by mutation, not suspected. Three legs because the rule has three parts and each was
  # separately absent from the text this replaces: resolution, the base a relative row resolves against,
  # and the empty-equals-empty case that would read an unresolvable path as a match.
  m41h=""
  printf '%s' "$CHK41" | grep -qiE 'resolved|resolve'                        || m41h="$m41h no-resolution-rule"
  printf '%s' "$CHK41" | grep -qiE "coordinator's own checkout root|against the coordinator" || m41h="$m41h no-resolution-base"
  printf '%s' "$CHK41" | grep -qiE 'does not resolve is not a match'         || m41h="$m41h unresolvable-reads-as-located"
  [ -z "$m41h" ] && ok "the column says how it is compared: resolved, against the coordinator's root, and an unresolvable path is no match" \
                 || bad "the column says how it is compared: resolved, against the coordinator's root, and an unresolvable path is no match (:$m41h)"
else
  bad "the checkout column is defined where it lives, and names all four sites that read it (no paragraph)"
  bad "the column says how it is compared: resolved, against the coordinator's root, and an unresolvable path is no match (no paragraph)"
fi

# All three places a branch column is declared: the protocol's skeleton, the skeleton adopters receive,
# and the move that writes a row. Pinned together because two of them passing is not the fact — a column
# the opening still writes comes back into every roster the next time a front opens.
m41f=""
# Case-insensitive and space-tolerant: every other roster pattern in this suite is written that way, and
# the sweep that priced this task's blast radius missed two assertions for exactly this reason.
grep -qiE '^\| *workstream *\|.*\| *branch *\|' "$BLG41" && m41f="$m41f skeleton"
grep -qiE '^\| *workstream *\|.*\| *branch *\|' "$TPL41" && m41f="$m41f shipped-template"
M7_41="$(o41 7)"
CARRIES41="$(printf '%s' "$M7_41" | sed -n 's/.*[Tt]he row carries \([^.]*\)\..*/\1/p')"
if [ -z "$CARRIES41" ]; then
  m41f="$m41f row-carries-clause-not-found"
else
  printf '%s' "$CARRIES41" | grep -qi 'branch' && m41f="$m41f the-opening-still-writes-it"
fi
[ -z "$m41f" ] && ok "no roster declares a branch column — not the skeleton, not the shipped template, not the move that writes the row" \
               || bad "no roster declares a branch column — not the skeleton, not the shipped template, not the move that writes the row (still declared:$m41f)"

# Counted, not matched. Every other roster assertion in this suite reads the HEADER row alone, and the
# ledger guardian drops table lines by design (`awk '!/^\|/'`), so a stale separator group or a leftover
# cell ships a malformed roster into every adopting project with the suite at zero failures. Column-shape
# edits are the class of change this area attracts, and the first pass of this very task got the separator
# wrong — six hand-edited rows across two shipped files is where a count earns its keep.
rostercols41() {  # $1 = file -> the cell count of every line of the roster table, one per line
  awk -F'|' '/^\| *[Ww]orkstream *\|/{f=1} f&&!/^\|/{exit} f{print NF-2}' "$1"
}
m41i=""
for f41 in "$BLG41" "$TPL41"; do
  counts41="$(rostercols41 "$f41")"
  if [ -z "$counts41" ]; then
    m41i="$m41i ${f41##*/}=no-table"
  elif [ "$(printf '%s\n' "$counts41" | sort -u | wc -l | tr -d ' ')" != 1 ]; then
    m41i="$m41i ${f41##*/}=($(printf '%s\n' "$counts41" | tr '\n' ',' | sed 's/,$//'))"
  fi
done
[ -z "$m41i" ] && ok "every line of a shipped roster agrees with its header on the column count" \
              || bad "every line of a shipped roster agrees with its header on the column count (counts:$m41i)"

MIG41="$(sec41 '^### Migrating an existing ledger')"
if [ -n "$MIG41" ]; then
  # The paragraph that keeps an adopter's extra column from reading as a defect, in the shape of the two
  # already beside it. Without it the removal looks like a break in every ledger written before it.
  m41g=""
  printf '%s' "$MIG41" | grep -qiE 'branch[^ ]* column'          || m41g="$m41g column-unmentioned"
  printf '%s' "$MIG41" | grep -qiE 'not broken|nothing (consults|reads) it' || m41g="$m41g verdict-unstated"
  [ -z "$m41g" ] && ok "a roster that still carries the branch column is not broken" \
                 || bad "a roster that still carries the branch column is not broken (:$m41g)"
else
  bad "a roster that still carries the branch column is not broken (no section)"
fi

echo "== C42: one cause for several sheets, and a prune whose reason covers both layouts =="
BLG42="global/protocols/backlog.md"
RAIL42="global/hooks/understand-write-guard.py"
DOC42="docs/customization.md"

# The rejected attribution, as a CLASS and not as the one token the change happened to delete: any of
# these causes standing within a sentence of "several sheets" is the contradiction returning, whatever
# verb it is spelled with. A single-token negative was tried first and was shown to pass on "copied as a
# whole at creation" — the same claim, in the file the protocol declares the winner on disagreement.
NEG42='(travel|copied|carried|arriv|snapshot|wholesale|as a whole|at creation)[^.]{0,120}sever[a-z]* (state )?sheets|sever[a-z]* (state )?sheets[^.]{0,120}(travel|copied|carried|arriv|snapshot|wholesale|as a whole|at creation)'
# The producer that survives a correct ceremony, bound to what it produces. Loose, the phrase occurs in
# this protocol for other reasons and the paragraph could keep the wrong cause while gaining the right
# words.
POS42='sever[a-z]* (state )?sheets[^.]{0,160}next task|next task[^.]{0,160}sever[a-z]* (state )?sheets'

# The ladder's OPENING PARAGRAPH, not its section: the producer this criterion requires is also named
# further down in rung 4, so a section-wide grep is satisfied by text that predates the change.
# Each non-blank line ONCE. An earlier form ended with a bare truth pattern and no action, so awk's
# default print fired beside the explicit one and every line came out twice — and after the flattening
# below that fabricates a junction from the end of a line to the start of the SAME line, which the
# bounded windows above can be satisfied by. The duplication check is what says it cannot come back.
RAW42="$(awk '/^### Resolving the task/{f=1;next} f && NF==0 && seen {exit} f && NF {seen=1; print}' "$BLG42")"
OPEN42="$(printf '%s\n' "$RAW42" | tr '\n' ' ' | tr -s ' ')"
DUP42="$(printf '%s\n' "$RAW42" | sort | uniq -d | wc -l | tr -d ' ')"

# Rung 4 of the same ladder — the sentence the opening's correction is anchored to.
RUNG4_42="$(awk '/^### Resolving the task/{f=1;next} f&&/^### /{exit} f' "$BLG42" | awk '/^4\. /{f=1} f' | tr '\n' ' ' | tr -s ' ')"

OPN42="$(awk '/^## Opening a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG42")"
o42() { printf '%s\n' "$OPN42" | awk -v n="$1" '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==n' | tr '\n' ' ' | tr -s ' '; }
M6_42="$(o42 6)"
# Cut before the third-layout sentence. That sentence contains both `ignored` and `tracked`, so over the
# whole move it lent its words to the two layout legs below and the clause they exist to pin was
# deletable with the suite green — proven by mutation, not suspected. It gets its own assertion instead.
M6CUT42="${M6_42%%A data directory neither*}"
# The adopter's copy of the same rationale. Guarded because the whole point of pairing the two documents
# is that they not drift, and the copy was reachable by nothing but a negative sweep.
DOCD42="$(awk '/^2\. \*\*Data\*\*/{f=1;next} /^3\. /{f=0} f' "$DOC42" | tr '\n' ' ' | tr -s ' ')"
# The rail's own account, in the file the protocol declares authoritative on disagreement.
RAILD42="$(awk '/def phase_source/{f=1} f&&/per_task = /{exit} f' "$RAIL42" | tr '\n' ' ' | tr -s ' ')"

if [ "$DUP42" = 0 ] && [ -n "$RAW42" ]; then
  ok "the paragraph extractor reads each line once"
else
  bad "the paragraph extractor reads each line once ($DUP42 duplicated line(s), $( printf '%s\n' "$RAW42" | grep -c . ) line(s) read)"
fi

if [ -n "$OPEN42" ] && [ "$DUP42" = 0 ]; then
  m42a=""
  printf '%s' "$OPEN42" | grep -qiE "$POS42"                            || m42a="$m42a producer-not-bound-to-several-sheets"
  printf '%s' "$OPEN42" | grep -qiE 'writes that line|recognises its own task' \
    || m42a="$m42a purpose-of-the-claim-traded-away"
  printf '%s' "$OPEN42" | grep -qiE "$NEG42"                            && m42a="$m42a rejected-cause-still-credited"
  # The opening is corrected TO AGREE with rung 4, so the sentence it agrees with has to still be there:
  # delete the anchor and the opening states a cause nothing in the section corroborates, which is the
  # single-statement property this criterion is really about.
  printf '%s' "$RUNG4_42" | grep -qiE 'front taking on its next task|takes on its next task' \
    || m42a="$m42a rung-4-anchor-gone"
  [ -z "$m42a" ] && ok "the ladder credits the producer that survives a correct ceremony" \
                 || bad "the ladder credits the producer that survives a correct ceremony (:$m42a)"
else
  bad "the ladder credits the producer that survives a correct ceremony (extractor read nothing usable)"
fi

# The same statement in the file that wins if the two ever read differently. Asserted POSITIVELY and not
# only swept: the corrected sentence was deletable from the docstring outright with the suite green, so
# the propagation half of this change had no guard at all.
if [ -n "$RAILD42" ]; then
  m42r=""
  printf '%s' "$RAILD42" | grep -qiE "$POS42" || m42r="$m42r producer-unstated"
  printf '%s' "$RAILD42" | grep -qiE "$NEG42" && m42r="$m42r rejected-cause-credited"
  [ -z "$m42r" ] && ok "the rail states the same cause as the ladder it implements" \
                 || bad "the rail states the same cause as the ladder it implements (:$m42r)"
else
  bad "the rail states the same cause as the ladder it implements (docstring not found)"
fi

# The attribution swept across every shipped document, hook and skill. One place stating it correctly is
# worth nothing while a second states it wrongly. Flattened per file, because the two halves of the
# sentence sit on different lines in the protocol and a per-line grep reports the file clean.
#
# The set is COUNTED, and membership is required for the two files that carried the attribution — not for
# the whole set, which is a glob and would be a second list to keep current. What the count and those two
# buy is the case a mistyped glob produces: selects nothing, finds nothing, reports success — the
# empty-selection defect this suite already knows from the seeder. test/ is outside the set, or this
# block's own patterns would match themselves.
s42=""; n42=0; have42=""
for f42 in global/protocols/*.md global/hooks/*.py global/hooks/*.sh global/hooks/git/* global/skills/*/SKILL.md docs/*.md global/CLAUDE.md README.md; do
  [ -f "$f42" ] || continue
  n42=$((n42+1))
  case "$f42" in
    global/protocols/backlog.md)            have42="$have42 protocol" ;;
    global/hooks/understand-write-guard.py) have42="$have42 rail" ;;
  esac
  if tr '\n' ' ' < "$f42" | tr -s ' ' | grep -qiE "$NEG42"; then s42="$s42 ${f42##*/}"; fi
done
case "$have42" in
  *protocol*rail*|*rail*protocol*) ;;
  *) s42="$s42 SET-INCOMPLETE(scanned=$n42)" ;;
esac
[ -z "$s42" ] && ok "no shipped document credits a creation-time cause for several sheets" \
             || bad "no shipped document credits a creation-time cause for several sheets (:$s42)"

if [ -n "$M6CUT42" ] && [ "$M6CUT42" != "$M6_42" ]; then
  # Each layout bound to the mechanism claim that distinguishes it, not named by a bare word: the words
  # alone were carried by a neighbouring sentence, so the pair could be deleted whole with this green.
  m42c=""
  printf '%s' "$M6CUT42" | grep -qiE 'ignor[a-z]*[^.]{0,140}pattern file' \
    || m42c="$m42c ignored-layout-not-bound-to-the-pattern-file"
  printf '%s' "$M6CUT42" | grep -qiE 'commit[a-z]*[^.]{0,140}(git carried|selects nothing)' \
    || m42c="$m42c committed-layout-not-bound-to-its-cause"
  printf '%s' "$M6CUT42" | grep -qiE 'prun[a-z]*[^.]{0,200}(both|either|each)[^.]{0,20}layout' \
    || m42c="$m42c prune-not-required-on-both-layouts"
  [ -z "$m42c" ] && ok "the seed-and-prune move names both layouts and the prune required on each" \
                 || bad "the seed-and-prune move names both layouts and the prune required on each (:$m42c)"
else
  bad "the seed-and-prune move names both layouts and the prune required on each (move not found, or the third-layout sentence is absent so the cut could not be made)"
fi

# The edge case, guarded on its own so the two sentences stop propping each other up: a data directory
# neither ignored nor tracked is the documented precondition failing and not a third layout.
if [ -n "$M6_42" ]; then
  printf '%s' "$M6_42" | grep -qiE 'neither ignored nor tracked[^.]{0,140}third layout|third layout[^.]{0,140}precondition' \
    && ok "a workspace neither ignored nor tracked is named as the precondition failing, not a third layout" \
    || bad "a workspace neither ignored nor tracked is named as the precondition failing, not a third layout"
else
  bad "a workspace neither ignored nor tracked is named as the precondition failing, not a third layout (no move)"
fi

# The adopter's copy of the two-layout rationale. The pair is the point: a rule stated in the protocol and
# not in the guide an adopter actually reads is a rule half the readership never sees.
if [ -n "$DOCD42" ]; then
  m42d=""
  printf '%s' "$DOCD42" | grep -qiE 'ignore[^.]{0,140}pattern' \
    || m42d="$m42d ignored-layout-not-bound-to-the-patterns"
  printf '%s' "$DOCD42" | grep -qiE 'commit[^.]{0,140}(git carried|select nothing|selects nothing)' \
    || m42d="$m42d committed-layout-not-bound-to-its-cause"
  [ -z "$m42d" ] && ok "the adopter guide carries the same two-layout rationale as the ceremony" \
                 || bad "the adopter guide carries the same two-layout rationale as the ceremony (:$m42d)"
else
  bad "the adopter guide carries the same two-layout rationale as the ceremony (data condition not found)"
fi

echo "== C43: the lifecycle map has one home, and the home is one an adopter receives =="
MAP43="global/protocols/lifecycle.md"
# The nine phases, named once. Every check below derives its patterns from this list rather than
# restating them, so a phase renamed in the engine cannot leave a guard quietly matching nothing.
PH43='CAPTURE|PRIORITIZE|ACTIVATE|UNDERSTAND|PLAN|CONFORM|EXECUTE|VERIFY|ARCHIVE'

# --- the map has exactly one home ------------------------------------------
# A1. Counted, not merely found — the same shape the phase precondition's home guard uses, and for the
# same reason: the whole anti-drift design is that a second statement cannot exist, and a check that
# only asks whether the rule is present anywhere is satisfied by every copy at once. Anchored at line
# start on the first phase's own heading: a document that CITES the map names it inline ("see the
# lifecycle protocol"), which is how every cross-reference in this engine is written, and an unanchored
# count would read each citer as another home. A real second home carries the phase headings itself.
HOME43="$(grep -rliE '^#{2,4} *(1\. *)?CAPTURE\b' global/ 2>/dev/null | wc -l | tr -d ' ')"
ELSE43="$(grep -rliE '^#{2,4} *(1\. *)?CAPTURE\b' template/ docs/ README.md 2>/dev/null | wc -l | tr -d ' ')"
if [ "$HOME43" -eq 1 ] && [ "$ELSE43" -eq 0 ] && [ -f "$MAP43" ]; then
  ok "the lifecycle map is stated in exactly one document, and it is a distributed one"
else
  bad "the lifecycle map is stated in exactly one document, and it is a distributed one (global/: $HOME43, elsewhere: $ELSE43, map present: $([ -f "$MAP43" ] && echo yes || echo no))"
fi

# A2. The direction the count cannot see. A home is recognised by the first phase's heading; a copy that
# describes the phases under any other wording is a second description the count reports as zero. What
# selects one here is a map element LEADING a heading, a table row or a numbered item — the shape a
# description has and a mention does not.
#
# THREE dimensions, not one, and each judged on itself. The map is the phase chain, the execution paths
# AND the autonomy levels, and a guard keyed on phase names alone let two thirds of it be copied back
# with the suite green — proven, not suspected: the pre-change paths and autonomy tables were appended
# to the front door and every row of this block stayed green. That is the drift this task exists to end,
# re-openable in the dimension the one live drift actually sat in, since it was the Supervised row that
# had lost `>5 files` and `architectural decisions` in two copies.
#
# The paths and autonomy legs select TABLE ROWS only, never headings: `### Full path (most tasks)` heads
# a worked transcript in the adopter guide, which is an example and not the criteria, and every copy this
# task removed stated those two dimensions as a table.
PATH43='Full|Quick'
AUTO43='Auto|Guided|Supervised'
# A route row is excluded — the manual MUST keep one — and the exclusion is the narrowest shape that
# describes a route: a two-cell row whose second cell is nothing but a protocol path. The first form of
# it dropped any line containing `protocols/` anywhere, which forgives a restored description that
# happens to cite one (`| **Activate** | Run the opening ceremony (see protocols/backlog.md) |`) —
# the likeliest shape a re-add takes, since a copy written today would cite its source.
ROUTE43='^\|[^|]*\|[[:space:]]*`?[~./A-Za-z0-9_-]*protocols/[a-z-]+\.md`?[[:space:]]*\|[[:space:]]*$'
# Every document a reader meets outside the map itself, the sibling protocols included: a copy grown in
# one of those ships to every adopter and is drift-guarded into being permanent. The map is excluded by
# name rather than by directory, so a second protocol carrying the map is caught rather than exempted.
SET43="README.md $(ls docs/*.md 2>/dev/null) global/CLAUDE.md global/hooks/README.md template/CLAUDE.md $(ls template/.ai-flow/*.md 2>/dev/null) $(ls global/protocols/*.md 2>/dev/null | grep -v 'lifecycle\.md')"
mapcount43() {  # $1 = file, $2 = lead alternation, $3 = 'rows-only' to skip headings and list items
  if [ "${3:-}" = "rows-only" ]; then
    grep -icE "^\| *\*{0,2}($2)\b" "$1" 2>/dev/null | tr -d ' '
  else
    # Three shapes, because a phase name leading a line is not yet a phase being described, and the
    # looser pattern this replaces reported four sibling protocols: a document TITLED `# Plan Phase
    # Protocol`, a section called `## Verify vs Done`, a checklist item `3. **Verify** that ...` and a
    # three-column table row about who writes what. Each shape below is the one an actual copy took —
    # a NUMBERED phase heading (`### 1. CAPTURE`), a TWO-cell table row (`| **Capture** | Add task ... |`),
    # or a numbered item whose bold lead is closed by a colon (`1. **CAPTURE**: Add task ...`). The three
    # copies this task removed used one each, which is why all three are here and none is a guess.
    grep -iE "^(#{1,6} *[0-9]+\. *\*{0,2}($2)\b|\| *\*{0,2}($2)\*{0,2} *\|[^|]*\|[[:space:]]*$|[0-9]+\. *\*{0,2}($2)\*{0,2}:)" "$1" 2>/dev/null \
      | grep -cvE "$ROUTE43" || true
  fi
}
who43=""
for f43 in $SET43; do
  [ -f "$f43" ] || continue
  np43="$(mapcount43 "$f43" "$PH43")"
  nx43="$(mapcount43 "$f43" "$PATH43" rows-only)"
  na43="$(mapcount43 "$f43" "$AUTO43" rows-only)"
  # Three is the threshold for the phase chain — one or two leads is a document explaining a phase it
  # owns. The paths table has only two rows and the autonomy table three, so those tie at two: a single
  # `| **Quick** |` row is a mention, both of them together is the table.
  [ "$np43" -ge 3 ] && who43="$who43 ${f43##*/}:phases=$np43"
  [ "$nx43" -ge 2 ] && who43="$who43 ${f43##*/}:paths=$nx43"
  [ "$na43" -ge 2 ] && who43="$who43 ${f43##*/}:autonomy=$na43"
done
[ -z "$who43" ] \
  && ok "no document outside the map carries the phase chain, the paths table or the autonomy table" \
  || bad "no document outside the map carries the phase chain, the paths table or the autonomy table (:$who43)"

# A2b — the live twin, judged on the same three counts and named separately. It is the copy that governs
# real sessions and the only one nothing distributes: the installer writes it solely when absent and the
# drift guard excludes it as user-owned, so a description removed from the shipped manual survives here
# until somebody ports the edit. The other twin legs in this suite cannot report it — they ask whether
# the manual ROUTES, and a twin still carrying the whole map routes perfectly well. Without this row the
# hand-merge is an intention with nothing behind it, which is the shape of drift this task exists to end.
TWIN43="${HOME:-}/.claude/CLAUDE.md"
if [ -f "$TWIN43" ]; then
  t43=""
  [ "$(mapcount43 "$TWIN43" "$PH43")" -ge 3 ]              && t43="$t43 phases"
  [ "$(mapcount43 "$TWIN43" "$PATH43" rows-only)" -ge 2 ]  && t43="$t43 paths"
  [ "$(mapcount43 "$TWIN43" "$AUTO43" rows-only)" -ge 2 ]  && t43="$t43 autonomy"
  [ -z "$t43" ] \
    && ok "the live twin carries no copy of the map either" \
    || bad "the live twin carries no copy of the map either (:$t43 — port the edit by hand, nothing distributes ~/.claude/CLAUDE.md)"
else
  echo "  [skip] live CLAUDE.md twin absent — the shipped manual carries the count"
fi

# A2c — the route itself, which every removal above depends on and nothing guarded. The map is only
# reachable because the manual's phase table names it: delete that one row and the protocol still ships,
# is still drift-guarded and still counts as the single home, while no document the engine loads points
# a session at it. Proven by mutation rather than argued — the row was deleted and the suite stayed at
# 548/0. Asserted on both copies, because the twin is the one that governs real sessions.
manmap43() { grep -qE '^\|[^|]*\|[^|]*protocols/lifecycle\.md[^|]*\|' "$1"; }
if manmap43 global/CLAUDE.md; then
  ok "the manual's phase table routes a session to the map"
  if [ -f "$TWIN43" ]; then
    manmap43 "$TWIN43" \
      && ok "the live twin routes a session to the map" \
      || bad "the live twin routes a session to the map (port the edit by hand, nothing distributes ~/.claude/CLAUDE.md)"
  else
    echo "  [skip] live CLAUDE.md twin absent — the shipped manual carries the route"
  fi
else
  bad "the manual's phase table routes a session to the map"
  bad "the live twin routes a session to the map (shipped copy is stale)"
fi

# --- the map is whole -------------------------------------------------------
# A5. Every dimension the map claims, present. This matters here in a way it would not in a document
# with siblings: the map is now the ONLY copy, so a section deleted from it is a section the engine no
# longer has anywhere. Every other row in this block guards against the map being COPIED; this is the
# one that guards against it being emptied, and without it the single-home design converts an edit
# slip into an unrecoverable loss. Counted rather than spot-checked — a check naming three phases
# passes on a document that lost the other six.
np5="$(grep -cE '^### [0-9]+\. ' "$MAP43" 2>/dev/null || true)"
a5=""
[ "$np5" = "9" ] || a5="$a5 phase-sections=$np5(want 9)"
grep -qE '^## Execution Paths'  "$MAP43" 2>/dev/null || a5="$a5 paths-section"
grep -qE '^## Autonomy Levels'  "$MAP43" 2>/dev/null || a5="$a5 autonomy-section"
grep -qiE '^\| *\*{0,2}Full\b'  "$MAP43" 2>/dev/null || a5="$a5 full-row"
grep -qiE '^\| *\*{0,2}Quick\b' "$MAP43" 2>/dev/null || a5="$a5 quick-row"
for lv5 in Auto Guided Supervised; do
  grep -qiE "^\| *\*{0,2}$lv5\b" "$MAP43" 2>/dev/null || a5="$a5 ${lv5}-row"
done
[ -z "$a5" ] \
  && ok "the map carries all nine phases, both paths and all three autonomy levels" \
  || bad "the map carries all nine phases, both paths and all three autonomy levels (missing:$a5)"

# --- the map is delivered, not merely written ------------------------------
# A3. The front door sends a reader to the map, and sends them to the copy that ships. A link into
# `docs/` would point at a file no install produces, which is the whole defect this task removes.
if grep -qF "$MAP43" README.md 2>/dev/null; then
  ok "the front door points at the map an adopter receives"
else
  bad "the front door points at the map an adopter receives"
fi

# --- the drift that misclassified a real task ------------------------------
# A4. The Supervised row, scoped to the section that owns the autonomy table. Both triggers, separately:
# the two renderings that drifted kept "schema changes" and lost exactly these, and losing one of the two
# is the same defect as losing both. This is the one criterion here with a live failure behind it — the
# task that wrote this guard was classified by the leg the other copies had already dropped.
AUT43="$(awk '/^## Autonomy Levels/{f=1;next} f && /^## /{exit} f' "$MAP43" 2>/dev/null)"
SUP43="$(printf '%s' "$AUT43" | grep -m1 -iE '^\| *\*{0,2}Supervised')"
a43=""
[ -n "$AUT43" ] || a43="$a43 section-absent"
[ -n "$SUP43" ] || a43="$a43 supervised-row-absent"
printf '%s' "$SUP43" | grep -qiE '> *5 files|more than five files' || a43="$a43 file-count-trigger"
printf '%s' "$SUP43" | grep -qi  'architectural'                   || a43="$a43 architecture-trigger"
[ -z "$a43" ] \
  && ok "the map's Supervised row keeps both triggers the other copies dropped" \
  || bad "the map's Supervised row keeps both triggers the other copies dropped (missing:$a43)"

echo "== C44: the audit's base rule is watched everywhere it is stated, and the purity sweep reads only what ships =="

# --- the purity sweep reads what ships, not what the disk holds -------------
# GIVEN an engine tree that carries both a file which will be distributed and a file git ignores,
# WHEN the purity sweep runs,
# THEN it reports the first and never the second.
#
# The fixture is a throwaway repository, never this one: a sweep proven by littering the tree it audits
# is the mutation the engine's own rule forbids, and an ignored file left behind would silently change
# the next run's verdict — which is the very defect this pair exists to close.
# Extended, never replaced -- the rule this file states at C21 and again at C25. The trap live at this
# point carries $T12, $T13 and $T25; a trap that named only $T44 would silently drop all three and leak
# them on every run, which is exactly what it did until this row's own review measured five surviving
# directories. And the sandbox is guarded: `mktemp -d` can fail, and `rm -rf "$T44"` with $T44 empty is
# a delete against the filesystem root.
if ! T44="$(mktemp -d 2>/dev/null)" || [ ! -d "$T44" ]; then
  T44=""
  bad "the purity sweep ignores what git ignores (no sandbox: mktemp -d failed)"
  bad "the purity sweep still catches a real leak in a file that ships (no sandbox: mktemp -d failed)"
  bad "the sweep refuses to answer when it cannot read, instead of answering clean (no sandbox: mktemp -d failed)"
else
trap 'rm -rf "$T12" "$T13" "$T25" "$T44"' EXIT
mkdir -p "$T44/global/hooks/__pycache__"
printf '__pycache__/\n' > "$T44/.gitignore"
# The file that ships, carrying the leak the sweep must still catch.
printf 'HOME_HINT = "/Users/someone/projects/thing"\n' > "$T44/global/hooks/real.py"
# The byte-compiled twin, carrying the identical string. `install.sh` fetches named files and never
# this one, so it is not the shipped engine and must not be read as if it were.
printf 'X/Users/someone/projects/thing/global/hooks/real.py\n' > "$T44/global/hooks/__pycache__/real.cpython-310.pyc"
git -C "$T44" init -q 2>/dev/null
git -C "$T44" add -A >/dev/null 2>&1
git -C "$T44" -c user.email=t@t -c user.name=t commit -qm base >/dev/null 2>&1
# The sweep's contract is tracked files PLUS untracked ones git is not ignoring, and a fixture that
# commits everything exercises only the first half -- so this one arrives after the commit and stays
# untracked. Without it, dropping `--others` from the sweep would leave every row green.
printf 'NOTE = "/Users/someone/projects/thing"\n' > "$T44/global/hooks/fresh.py"
# The fixture proves itself before anything concludes from it: `git init` can fail, and a sandbox that
# was never built produces no hits, which reads exactly like a clean sweep.
FIX44=""
git -C "$T44" rev-parse --git-dir >/dev/null 2>&1 || FIX44="$FIX44 fixture-is-not-a-repository"
[ -f "$T44/global/hooks/real.py" ] || FIX44="$FIX44 fixture-missing-the-tracked-file"
[ -f "$T44/global/hooks/__pycache__/real.cpython-310.pyc" ] || FIX44="$FIX44 fixture-missing-the-ignored-file"
[ -f "$T44/global/hooks/fresh.py" ] || FIX44="$FIX44 fixture-missing-the-untracked-file"

# `purity_sweep <repo-root> <subpath>` prints one `file:line:text` per hit over the files that could
# actually ship — tracked, plus untracked that git does not ignore. It is defined beside the live sweep
# it serves; the absence branch below is what keeps these rows from passing vacuously if it is ever
# deleted or renamed, since an absent function returns no output and no output names no ignored file.
if command -v purity_sweep >/dev/null 2>&1 || type purity_sweep 2>/dev/null | grep -q function; then
  OUT44="$(purity_sweep "$T44" global 2>/dev/null)"; RC44=$?
  # A sweep that refused to run also returns no output, and no output names no ignored file -- so the
  # row below would read a refusal as a pass. The status separates the two.
  [ "$RC44" -eq 0 ] || SWEEP44_ABSENT=1
else
  OUT44=""
  SWEEP44_ABSENT=1
fi

r44a="$FIX44"
[ -n "${SWEEP44_ABSENT:-}" ] && r44a="$r44a sweep-absent-or-refused"
printf '%s' "$OUT44" | grep -q '__pycache__' && r44a="$r44a reads-an-ignored-file"
[ -z "$r44a" ] \
  && ok "the purity sweep ignores what git ignores" \
  || bad "the purity sweep ignores what git ignores (missing:$r44a)"

# The other direction, and it is the one that costs money to get wrong: a sweep narrowed until it reads
# nothing passes the row above for the wrong reason. Asserted on the file's name in the output, not on a
# count, so a sweep that reports a hit in some other file cannot stand in for this one.
r44b="$FIX44"
[ -n "${SWEEP44_ABSENT:-}" ] && r44b="$r44b sweep-absent-or-refused"
printf '%s' "$OUT44" | grep -q 'real\.py'  || r44b="$r44b misses-a-tracked-file-that-ships"
printf '%s' "$OUT44" | grep -q 'fresh\.py' || r44b="$r44b misses-an-untracked-file-that-ships"
[ -z "$r44b" ] \
  && ok "the purity sweep still catches a real leak in a file that ships" \
  || bad "the purity sweep still catches a real leak in a file that ships (missing:$r44b)"

# --- the working-copy comparison states its own reach -----------------------
# GIVEN the step that compares the working copy against the snapshot,
# WHEN it reports the tree left as found,
# THEN the step says what that verdict does not cover — files git ignores, which neither probe reaches.
#
# Scoped to the compare bullet of the snapshot-comparison step, resolved by content rather than by
# number: the word `ignore` appears elsewhere in the skill (`--exclude-standard` prose, the untracked
# listing), so a file-wide grep would be green before the clause is written.
VS44="global/skills/verify/SKILL.md"
NC44="$(grep -nE '^[0-9]+\. \*\*Compare the working copy' "$VS44" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/')"
# The COMPARE BULLET, not the whole step. An earlier form of this row sliced from step 8 to step 9 and
# so read the Precondition, Identical and Different bullets too -- any of which can feed a vocabulary
# leg in a future edit. `sbullet` is the helper this file already uses for exactly that reason.
CMP44="$([ -n "$NC44" ] && sbullet "$VS44" "$NC44" 'Compare[.]')"
# The FACT, not two vocabulary hits. Both legs of the earlier form were satisfied by the bullet's own
# opening clause -- `not ignoring` fed one and `reach of` fed the other -- so the sentence that carries
# the criterion was deletable with the suite green, and prose asserting the OPPOSITE passed as well.
# Leg 1 binds an ignored file to being outside the probes, within one sentence. Leg 2 is what kills the
# inversion: a passage claiming the probes cover everything cannot state this consequence.
r44c=""
[ -n "$CMP44" ] || r44c="$r44c compare-bullet-did-not-extract"
printf '%s' "$CMP44" | grep -qE 'ignore[sd]?[^.]{0,40}outside' || r44c="$r44c ignored-not-bound-to-outside"
printf '%s' "$CMP44" | grep -qE 'verdict about that reach|never about the whole directory' || r44c="$r44c consequence-not-stated"
[ -z "$r44c" ] \
  && ok "the comparison names the reach it does not cover" \
  || bad "the comparison names the reach it does not cover (missing:$r44c)"

# --- the refusal that makes the git-scoped narrowing safe -------------------
# Added at Verify: the review proved this uncovered by flipping the sweep's `return 2` to `return 0`
# with the suite green, so a sweep that concludes from nothing could be reintroduced in silence. Both
# refusals, because they are different branches -- a selection naming no file, and a tree that is not a
# repository at all -- and the second is the one that turns a missing `.git` into a clean purity verdict.
r44d=""
purity_sweep "$T44" nosuchpath >/dev/null 2>&1 && r44d="$r44d empty-selection-read-as-clean"
if ! NR44="$(mktemp -d 2>/dev/null)" || [ ! -d "$NR44" ]; then
  r44d="$r44d no-sandbox-for-the-non-repository-leg"
else
  mkdir -p "$NR44/global"; printf 'x\n' > "$NR44/global/f.txt"
  purity_sweep "$NR44" global >/dev/null 2>&1 && r44d="$r44d non-repository-read-as-clean"
  rm -rf "$NR44"
fi
[ -z "$r44d" ] \
  && ok "the sweep refuses to answer when it cannot read, instead of answering clean" \
  || bad "the sweep refuses to answer when it cannot read, instead of answering clean (missing:$r44d)"
fi

echo ""
echo "Result: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
