echo "== C35: the rail reports whether the protection is here, and judges nothing else =="
# A sandbox of this block's own. It used to read the one C11 opens, which is why this section could
# not be asked for on its own: under a filter C11 never runs and every path below collapses to "/".
BOX35="$(mkbox)" || fatal 'C35 fixtures'
# The rail's new job, and the whole reason this section is short where the matcher it replaces needed
# forty-six rows: the rail no longer decides anything about a command. Its trigger is a crude text test
# and is allowed to be one, because a shape it misses is a reminder that does not fire in a repository
# git's own hooks are not guarding either way. What it must never do again is refuse work.
if [ "$PY3" = 1 ] && command -v git >/dev/null 2>&1; then
  GS35="$HK/git-safety.py"
  T35="$BOX35/c35"; mkdir -p "$T35"
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
