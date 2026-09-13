echo "== C12: worktree provisioning — data in, ledger out =="
# The semantic checks below read the TEMPLATE copy: that is the file install.sh delivers, so it is
# the one whose select/reject contract matters to an adopting project. The root copy exists only so
# this repo dogfoods its own mechanism, and the parity check keeps the two from drifting apart.
WTI="$ROOT/template/.worktreeinclude"
T12="$(mkbox)" || fatal 'C12 fixtures'
trap 'rm -rf "$T12"' EXIT




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
