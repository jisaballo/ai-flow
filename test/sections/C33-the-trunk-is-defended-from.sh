# C32 is retired here, in the same change that removes the matcher it tested. Its rows are not dropped:
# every shape in both of its tables lives on in C33 and C34, migrated from matching a command's spelling
# to executing the operation and letting git compute the effect. The migration is recorded in the task's
# conformance manifest rather than left to be reconstructed from this diff.

echo "== C33: the trunk is defended from what git reports, not from what a command says =="
# A sandbox of this block's own. It used to read the one C11 opens, which is why this section could
# not be asked for on its own: under a filter C11 never runs and every path below collapses to "/".
BOX33="$(mkbox)" || fatal 'C33 fixtures'
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
  T33="$BOX33/c33"; mkdir -p "$T33"
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

  # --- the trunk the remote DECLARES, not the trunk that is called main ----
  # Every fixture above is built with `init` + `remote add`, which leaves refs/remotes/origin/HEAD
  # absent — so all of them exercise the FALLBACK. This one asks the remote, as a clone would.
  # mkpair33 already builds the pair and points the bare remote's HEAD at $2; what a DECLARED trunk adds
  # is the branch itself and the local refs/remotes/origin/HEAD that this hook reads. Four lines on top
  # of the canonical builder rather than a third copy of it.
  mkdecl33() {  # $1 = fixture name, $2 = the branch the remote declares -> mkpair33 + a local declaration
    mkpair33 "$1" "$2"
    git -C "$T33/$1/work" branch -q "$2" main
    free33 "$1" push -q origin "$2"
    free33 "$1" remote set-head origin -a >/dev/null 2>&1
  }
  # `remote set-head -a` is the only thing in this suite that writes refs/remotes/origin/HEAD, and it is
  # run with its output discarded. Every row below that means to exercise the DECLARED path needs it to
  # have worked, and the dangling row needs it to have worked and then gone stale — a row whose setup
  # silently no-ops falls back, defends main, and goes green having tested nothing it names.
  decl33() {  # $1 = fixture -> the ref refs/remotes/origin/HEAD names, or the empty string
    git -C "$T33/$1/work" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null
  }

  mkdecl33 decl develop
  if [ "$(decl33 decl)" = refs/remotes/origin/develop ]; then
    ok "the declared-trunk fixture really does declare one, so the rows resting on it are not vacuous"
  else
    bad "the declared-trunk fixture really does declare one, so the rows resting on it are not vacuous (origin/HEAD names [$(decl33 decl)])"
  fi
  git -C "$T33/decl/work" checkout -q develop
  printf 'x\n' >> "$T33/decl/work/f.txt"
  git -C "$T33/decl/work" commit -qam two
  free33 decl push -q origin develop
  git -C "$T33/decl/work" commit -q --amend -m two-rewritten
  git -C "$T33/decl/work" checkout -q main
  b33="$(ref33 decl develop)"
  out="$(run33 decl push --force origin develop)"; rc=$?; a33="$(ref33 decl develop)"
  case "$out" in *"rewriting refs/heads/develop"*) named=1 ;; *) named=0 ;; esac
  case "$out" in *"--no-verify"*) esc=1 ;; *) esc=0 ;; esac
  if [ "$rc" != 0 ] && [ "$b33" = "$a33" ] && [ "$named" = 1 ] && [ "$esc" = 1 ]; then
    ok "a rewrite of the branch the remote declares as its trunk is refused, naming the escape"
  else
    bad "a rewrite of the branch the remote declares as its trunk is refused, naming the escape (exit $rc, remote $b33 -> $a33, named=$named escape=$esc, said: $out)"
  fi

  # Git protects the branch a remote's HEAD points at from deletion on its own, so the exit code alone
  # would pass without this guard existing. The refusal's own wording is what makes this row ours.
  out="$(run33 decl push origin --delete develop)"; rc=$?
  case "$out" in *"deleting refs/heads/develop"*) named=1 ;; *) named=0 ;; esac
  if [ "$rc" != 0 ] && [ "$named" = 1 ] && [ "$(ref33 decl develop)" != none ]; then
    ok "a deletion of the branch the remote declares as its trunk is refused by this guard"
  else
    bad "a deletion of the branch the remote declares as its trunk is refused by this guard (exit $rc, named=$named, said: $out)"
  fi

  # The accepted loss, asserted from the permission side. Unasserted, a loss the operator chose becomes
  # a protection nobody chose, and nothing would ever say so.
  printf 'y\n' >> "$T33/decl/work/f.txt"
  git -C "$T33/decl/work" commit -qam three
  free33 decl push -q origin main
  git -C "$T33/decl/work" commit -q --amend -m three-rewritten
  b33="$(ref33 decl main)"
  out="$(run33 decl push --force origin main)"; rc=$?; a33="$(ref33 decl main)"
  if [ "$rc" = 0 ] && [ "$b33" != "$a33" ] && [ "$a33" != none ]; then
    ok "an old main beside a declared develop trunk is rewritable, and the remote moves"
  else
    bad "an old main beside a declared develop trunk is rewritable, and the remote moves (exit $rc, remote $b33 -> $a33, said: $out)"
  fi

  # A DANGLING declaration — symbolic-ref answers for a branch that is gone. Accepting it unverified
  # resolves a trunk that does not exist, and a guard defending nothing is silent about it.
  mkdecl33 dangle develop
  git -C "$T33/dangle/remote.git" symbolic-ref HEAD refs/heads/main
  free33 dangle push -q origin :develop
  git -C "$T33/dangle/work" update-ref -d refs/remotes/origin/develop 2>/dev/null
  diverge33 dangle
  if [ "$(decl33 dangle)" = refs/remotes/origin/develop ] \
     && ! git -C "$T33/dangle/work" rev-parse --verify --quiet refs/remotes/origin/develop >/dev/null 2>&1; then
    ok "the dangling fixture is dangling: origin/HEAD still names a ref that is gone"
  else
    bad "the dangling fixture is dangling: origin/HEAD still names a ref that is gone (names [$(decl33 dangle)])"
  fi
  b33="$(ref33 dangle main)"
  out="$(run33 dangle push --force origin main)"; rc=$?; a33="$(ref33 dangle main)"
  case "$out" in *"rewriting refs/heads/main"*) named=1 ;; *) named=0 ;; esac
  if [ "$rc" != 0 ] && [ "$b33" = "$a33" ] && [ "$named" = 1 ]; then
    ok "a dangling declaration falls back to the brake's candidates rather than defending nothing"
  else
    bad "a dangling declaration falls back to the brake's candidates rather than defending nothing (exit $rc, remote $b33 -> $a33, said: $out)"
  fi

  # Pushed by URL: what the hook receives is not a remote name and nothing local answers for it. The
  # fallback path, not an error.
  #
  # Built on a DECLARING origin on purpose. On a fixture whose origin declares nothing, this row passes
  # whether or not the hook ever looks at what it was handed — both the URL and `origin` resolve to the
  # candidates, so refusing `main` proves nothing about the argument. With origin declaring develop, a
  # hook that ignored its argument and asked origin would resolve develop, and the force-push over main
  # would be ALLOWED. Measured: with `rp` hardcoded to origin this row is the one that reddens.
  mkdecl33 byurl develop; diverge33 byurl
  b33="$(ref33 byurl main)"
  out="$(sh33 byurl "git push --force '$T33/byurl/remote.git' main")"; rc=$?; a33="$(ref33 byurl main)"
  case "$out" in *"rewriting refs/heads/main"*) named=1 ;; *) named=0 ;; esac
  if [ "$rc" != 0 ] && [ "$b33" = "$a33" ] && [ "$named" = 1 ]; then
    ok "a push addressed by URL falls back rather than failing to resolve"
  else
    bad "a push addressed by URL falls back rather than failing to resolve (exit $rc, remote $b33 -> $a33, said: $out)"
  fi

  # The remote the push is ADDRESSED to, against the remote that carries a declaration. Every other row
  # in this section uses one remote called origin, so none of them can tell a hook that resolves the
  # trunk from its argument apart from one that resolves it from the name `origin`. This is the fork
  # shape: origin is the fork and declares develop; upstream is the canonical repository and declares
  # nothing, so its trunk is main and must still be defended.
  mkdecl33 twohost develop
  git init -q --bare "$T33/twohost/upstream.git"
  git -C "$T33/twohost/work" remote add upstream "$T33/twohost/upstream.git"
  free33 twohost push -q upstream main
  printf 'z\n' >> "$T33/twohost/work/f.txt"
  git -C "$T33/twohost/work" commit -qam four
  free33 twohost push -q upstream main
  git -C "$T33/twohost/work" commit -q --amend -m four-rewritten
  b33="$(git -C "$T33/twohost/upstream.git" rev-parse -q --verify refs/heads/main 2>/dev/null || echo none)"
  out="$(run33 twohost push --force upstream main)"; rc=$?
  a33="$(git -C "$T33/twohost/upstream.git" rev-parse -q --verify refs/heads/main 2>/dev/null || echo none)"
  case "$out" in *"rewriting refs/heads/main"*) named=1 ;; *) named=0 ;; esac
  if [ "$rc" != 0 ] && [ "$b33" = "$a33" ] && [ "$named" = 1 ]; then
    ok "the trunk is resolved from the remote the push names, not from a remote called origin"
  else
    bad "the trunk is resolved from the remote the push names, not from a remote called origin (exit $rc, upstream $b33 -> $a33, named=$named, said: $out)"
  fi

  # A declaration of the WRONG SHAPE. symbolic-ref takes any well-formed refname, so origin/HEAD can be
  # made to name a ref outside its own namespace — the form people paste when repairing a missing
  # origin/HEAD. rev-parse verifies it, the namespace strip then no-ops, and an unguarded hook emits
  # refs/heads/refs/heads/main: a name git never reports, so every ref falls through and the real trunk
  # is undefended in silence. Existence and shape are two checks, and only one of them was there.
  mkpair33 badshape main
  git -C "$T33/badshape/work" symbolic-ref refs/remotes/origin/HEAD refs/heads/main
  diverge33 badshape
  b33="$(ref33 badshape main)"
  out="$(run33 badshape push --force origin main)"; rc=$?; a33="$(ref33 badshape main)"
  case "$out" in *"rewriting refs/heads/main"*) named=1 ;; *) named=0 ;; esac
  if [ "$rc" != 0 ] && [ "$b33" = "$a33" ] && [ "$named" = 1 ]; then
    ok "a declaration pointing outside the remote's own namespace falls back rather than defending nothing"
  else
    bad "a declaration pointing outside the remote's own namespace falls back rather than defending nothing (exit $rc, remote $b33 -> $a33, named=$named, said: $out)"
  fi

  # Derived from BOTH sources, on the idiom at :1743. Change either list and this row fails; a list
  # restated beside the original drifts, a list read out of it cannot.
  BRAKE33="$ROOT/global/hooks/diff-size-guard.py"
  bcand33="$(sed -n "s/.*for cand in (\(.*\)):.*/\1/p" "$BRAKE33" | tr -d "\"'" | tr -d ' ' | tr ',' ' ' | tr -s ' ')"
  hcand33="$(sed -n "s/^[[:space:]]*for cand in \(.*\); do.*/\1/p" "$GHK/pre-push" | tr -s ' ')"
  bcand33="${bcand33% }"; hcand33="${hcand33% }"
  if [ -n "$bcand33" ] && [ "$bcand33" = "$hcand33" ]; then
    ok "the push guard's fallback candidates are the brake's own, in the brake's order"
  else
    bad "the push guard's fallback candidates are the brake's own, in the brake's order (brake: [$bcand33], hook: [$hcand33])"
  fi
else
  echo "  [skip] trunk-defence checks (git unavailable)"
fi
