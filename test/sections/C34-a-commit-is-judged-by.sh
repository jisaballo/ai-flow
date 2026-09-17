echo "== C34: a commit is judged by what it would record =="
# A sandbox of this block's own. It used to read the one C11 opens, which is why this section could
# not be asked for on its own: under a filter C11 never runs and every path below collapses to "/".
BOX34="$(mkbox)" || fatal 'C34 fixtures'
# The staging protection's substrate. What decides is the index — the paths a commit would actually
# record — so a name that appears only in the message, or only in the working tree, is not a staging.
# Three of the nine false refusals measured against the guard this replaces came from exactly there.
#
# The shell wrappings the inherited table enumerated collapse to almost nothing here, and that is the
# point rather than a gap: the index does not vary with how the command that filled it was written. What
# remains worth driving is the small product below, which proves that.
if command -v git >/dev/null 2>&1; then
  GHK34="$ROOT/global/hooks/git"
  T34="$BOX34/c34"; mkdir -p "$T34"
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

  # --- the lines a commit would ADD ---------------------------------------
  # Every literal below is built at a boundary the shapes cannot cross, so this file stays committable
  # with the guard active — the precedent is at :4023,4052. The shapes are never echoed on failure
  # either: a guard that prints the secret it caught has copied it into the scrollback.
  PK34="$(printf -- '-----BEGIN RSA PRIVATE%s' ' KEY-----')"
  AWS34="$(printf 'AKIA%s' 'ABCDEFGHIJKLMNOP')"
  GH34="$(printf 'ghp%s' '_0123456789abcdef0123456789abcdef0123')"
  SL34="$(printf 'xoxb%s' '-000000000000-000000000000-abcdefghijklmnopqrstuvwx')"
  ST34="$(printf 'sk_live%s' '_0123456789abcdef01234567')"
  GO34="$(printf 'AIza%s' '0123456789abcdefghij0123456789abcde')"

  mkrepo34 content
  why34=""; i34=0
  mkdir -p "$T34/content/src"
  # Each shape carries the phrase its refusal must name. The two-pattern split and the second `adds`
  # call exist for exactly one reason — the refusal says WHICH kind was found — and a row that reads
  # only `BLOCKED:` is satisfied by one pattern and one message, so the whole structure could be folded
  # away with the suite green.
  for pair34 in "$PK34|a private-key header" "$AWS34|a provider token" "$GH34|a provider token" \
                "$SL34|a provider token" "$ST34|a provider token" "$GO34|a provider token"; do
    s34="${pair34%%|*}"; kind34="${pair34#*|}"
    i34=$((i34+1))
    printf 'const t = "%s";\n' "$s34" > "$T34/content/src/app.ts"
    git -C "$T34/content" -c core.hooksPath="$NOHOOK34" add -A >/dev/null 2>&1
    b34="$(head34 content)"
    out="$(sh34 content "git commit -m pasted")"; rc=$?
    { [ "$rc" != 0 ] && [ "$b34" = "$(head34 content)" ]; } || why34="$why34 [shape $i34 -> exit $rc]"
    # The refusal must be this guard's AND must name the file. Asserting the path alone is satisfied by
    # git's own "create mode ... src/app.ts" on a commit that went through.
    case "$out" in *"BLOCKED:"*) ;; *) why34="$why34 [shape $i34 -> guard did not speak]" ;; esac
    case "$out" in *"BLOCKED:"*"src/app.ts"*) ;; *) why34="$why34 [shape $i34 -> file not named in the refusal]" ;; esac
    case "$out" in *"--no-verify"*) ;; *) why34="$why34 [shape $i34 -> escape not named]" ;; esac
    case "$out" in *"$kind34"*) ;; *) why34="$why34 [shape $i34 -> kind not named]" ;; esac
    # The one thing the refusal must NOT carry. Stated in the hook, in the README and in the task's
    # decisions, and asserted nowhere until here: a guard that echoes the secret it caught has copied it
    # into the scrollback, the CI log and the transcript. The index is reported, never the shape.
    case "$out" in *"$s34"*) why34="$why34 [shape $i34 -> the refusal echoed what it caught]" ;; esac
    git -C "$T34/content" -c core.hooksPath="$NOHOOK34" rm -q -f --cached src/app.ts >/dev/null 2>&1
    rm -f "$T34/content/src/app.ts"
  done
  [ -z "$why34" ] && ok "a commit that would add a private-key header or a provider token is refused, and names the file" \
                  || bad "a commit that would add a private-key header or a provider token is refused, and names the file ($why34)"

  # The negative direction. Without it the row above is satisfied by a guard that refuses everything,
  # and a guard that refuses everything is one people learn to bypass.
  mkrepo34 nearmiss
  why34=""; i34=0
  # The last two are the placeholders an open-ended tail refuses: `xox[baprs]-[0-9A-Za-z-]{10,}` matched
  # the first and `sk_live_[0-9A-Za-z]{16,}` the second. These guards run on the operator's every
  # commit, so a sample token in a README cost them a --no-verify — the guard-people-learn-to-ignore
  # this design refused entropy scanning to avoid, reached from the other side.
  for s34 in "AKIA" "$(printf 'sk_live%s' '_short')" "a private key belongs in the keychain" \
             "$(printf 'ghp%s' '_tooshort')" "AIza" "-----BEGIN CERTIFICATE-----" \
             "$(printf 'xoxb%s' '-your-token-here')" "$(printf 'sk_live%s' '_xxxxxxxxxxxxxxxx')"; do
    i34=$((i34+1))
    printf 'note: %s\n' "$s34" > "$T34/nearmiss/notes.md"
    git -C "$T34/nearmiss" -c core.hooksPath="$NOHOOK34" add -A >/dev/null 2>&1
    b34="$(head34 nearmiss)"
    out="$(sh34 nearmiss "git commit -m ordinary")"; rc=$?
    { [ "$rc" = 0 ] && [ "$b34" != "$(head34 nearmiss)" ]; } || why34="$why34 [near miss $i34 -> exit $rc, said: $out]"
  done
  [ -z "$why34" ] && ok "content that merely reads like a secret is committed" \
                  || bad "content that merely reads like a secret is committed ($why34)"

  # Only added lines are read, for the same reason a deleted path is not judged: refusing the removal
  # traps the repository in the state the guard exists to prevent.
  mkrepo34 removal
  mkdir -p "$T34/removal/src"
  printf 'const t = "%s";\n' "$PK34" > "$T34/removal/src/app.ts"
  git -C "$T34/removal" -c core.hooksPath="$NOHOOK34" add -A >/dev/null 2>&1
  git -C "$T34/removal" -c core.hooksPath="$NOHOOK34" commit -q -m mistake
  printf 'const t = "";\n' > "$T34/removal/src/app.ts"
  git -C "$T34/removal" -c core.hooksPath="$NOHOOK34" add -A >/dev/null 2>&1
  b34="$(head34 removal)"
  out="$(sh34 removal "git commit -m 'remove the key'")"; rc=$?
  if [ "$rc" = 0 ] && [ "$b34" != "$(head34 removal)" ]; then
    ok "a staged change that only removes such content still commits"
  else
    bad "a staged change that only removes such content still commits (exit $rc, said: $out)"
  fi

  # --- the ways the read used to come back empty and be read as CLEAN -----
  # A pipeline whose only answer is grep's exit status has no way to say "I could not look", so each of
  # these was a silent exemption: the commit went through, the guard printed nothing, and the suite was
  # green. Each row stages the same private-key literal and differs only in how the diff is disabled.
  #
  # Worth naming: the suite sandboxes global git config for the whole run, so the driver case below is
  # set per-repository here. In the wild it lives in the operator's own ~/.gitconfig, outside every
  # repository this guard defends, which is what made it total rather than occasional.
  why34=""
  undiffable34() {  # $1 = fixture, $2 = a shell line run in it before staging
    mkrepo34 "$1"
    mkdir -p "$T34/$1/src"
    ( cd "$T34/$1" && eval "$2" ) >/dev/null 2>&1
    printf 'const t = "%s";\n' "$PK34" > "$T34/$1/src/app.ts"
    git -C "$T34/$1" -c core.hooksPath="$NOHOOK34" add -A >/dev/null 2>&1
    b34="$(head34 "$1")"
    out="$(sh34 "$1" "git commit -m pasted")"; rc=$?
    { [ "$rc" != 0 ] && [ "$b34" = "$(head34 "$1")" ]; } || why34="$why34 [$1 -> exit $rc, said: $out]"
  }
  undiffable34 attrs   "printf '*.ts -diff\n' > .gitattributes"
  undiffable34 binattr "printf '*.ts binary\n' > .gitattributes"
  undiffable34 extdiff "git config diff.external /usr/bin/true"
  undiffable34 textcv  "printf '*.ts diff=none\n' > .gitattributes; git config diff.none.textconv /usr/bin/true"
  [ -z "$why34" ] && ok "a secret is still found where the repository or the operator has disabled the diff" \
                  || bad "a secret is still found where the repository or the operator has disabled the diff ($why34)"

  # A staged path beginning with `:` is parsed as pathspec magic, matches nothing, and exits 0 with no
  # error at all — so the file was exempt and nothing said so. Note the sibling that is NOT broken and
  # therefore is not asserted as one: git matches a pathspec like src/cfg[1].js literally, so glob
  # metacharacters in a name were never the defect.
  mkrepo34 magic
  printf 'const t = "%s";\n' "$PK34" > "$T34/magic/:pasted.txt"
  git -C "$T34/magic" -c core.hooksPath="$NOHOOK34" add -A >/dev/null 2>&1
  b34="$(head34 magic)"
  out="$(sh34 magic "git commit -m pasted")"; rc=$?
  if [ "$rc" != 0 ] && [ "$b34" = "$(head34 magic)" ]; then
    ok "a staged path that git would read as pathspec magic is judged, not skipped"
  else
    bad "a staged path that git would read as pathspec magic is judged, not skipped (exit $rc, said: $out)"
  fi

  # The `+++ b/path` filter's own row. Without it the file header is read as an added line, so a path
  # that merely CARRIES a shape is refused for content it does not have — a false refusal, which is the
  # one direction this guard is built never to fail in. Nothing else in the block stages such a path, so
  # the filter could be deleted outright and the suite would stay green.
  mkrepo34 pathshape
  mkdir -p "$T34/pathshape/docs"
  printf 'nothing here\n' > "$T34/pathshape/docs/$AWS34.md"
  git -C "$T34/pathshape" -c core.hooksPath="$NOHOOK34" add -A >/dev/null 2>&1
  b34="$(head34 pathshape)"
  out="$(sh34 pathshape "git commit -m ordinary")"; rc=$?
  if [ "$rc" = 0 ] && [ "$b34" != "$(head34 pathshape)" ]; then
    ok "a harmless file whose own path carries a token shape is committed"
  else
    bad "a harmless file whose own path carries a token shape is committed (exit $rc, said: $out)"
  fi

  # The row that makes the guard usable in the repository that ships it: a by-content check whose own
  # source or whose own fixtures it refuses is a machine that cannot commit its own repair.
  mkrepo34 selfsrc
  mkdir -p "$T34/selfsrc/hooks"
  cp "$GHK34/pre-commit" "$T34/selfsrc/hooks/pre-commit"
  cp "$GHK34/pre-push" "$T34/selfsrc/hooks/pre-push"
  # THE WHOLE suite, not the runner alone. The near-miss shapes this row exists to prove committable
  # live in the section files; staging `test/validate.sh` by itself would stage forty-two lines that
  # cannot hold one, and the row would go on claiming a subject it no longer carries.
  # Derived from the list the loop below reads, never sized to the corpus as it stood: a literal floor
  # here is a floor over a corpus this suite may legitimately shrink. The relation is also strictly
  # stronger than any floor -- it catches a fixture that staged 78 of 79.
  nsrc34="$(printf '%s\n' $SUITE_SRC | grep -c .)"
  n34=0
  for f34 in $SUITE_SRC; do
    r34="${f34#$ROOT/}"
    mkdir -p "$T34/selfsrc/$(dirname "$r34")"
    cp "$f34" "$T34/selfsrc/$r34" && n34=$((n34 + 1))
  done
  git -C "$T34/selfsrc" -c core.hooksPath="$NOHOOK34" add -A >/dev/null 2>&1
  b34="$(head34 selfsrc)"
  out="$(sh34 selfsrc "git commit -m 'the guard and its suite'")"; rc=$?
  # The count is an assertion, not a comment: a fixture that copied nothing would commit clean and this
  # row would report that as a pass -- the vacuous shape it is here to refuse.
  if [ "$nsrc34" -lt 1 ] || [ "$n34" -ne "$nsrc34" ]; then
    bad "the commit guard's own source and the suite that drives it commit with the guard active (only $n34 suite file(s) staged)"
  elif [ "$rc" = 0 ] && [ "$b34" != "$(head34 selfsrc)" ]; then
    ok "the commit guard's own source and the suite that drives it commit with the guard active"
  else
    bad "the commit guard's own source and the suite that drives it commit with the guard active (exit $rc, said: $out)"
  fi
else
  echo "  [skip] commit-recording checks (git unavailable)"
fi
