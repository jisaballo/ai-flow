echo "== C47: the distribution boundary goes both ways, and the manual it never publishes reports its own gaps =="
# Conformance rows. The engine publishes and never withdraws, and the one surface it deliberately never
# publishes is watched one rule at a time by hand. Every row below drives a real mechanism over a real
# fixture: a row that only reads the source would prove the text exists and never that anything reaches it.

T47="$(mkbox)" || fatal 'C47: the distribution boundary fixtures'

# --- the update withdraws -----------------------------------------------------
# GIVEN an engine installed into a sandbox home,
# WHEN a file the trunk does not publish is planted in a directory the engine owns outright and the
#      update runs again,
# THEN the file is gone and the run named it.
H47="$T47/home"; mkdir -p "$H47"
( cd "$ROOT" && HOME="$H47" bash "$ROOT/install.sh" update </dev/null >/dev/null 2>&1 ) || true

# The fixture is asserted usable before anything is concluded from it: an install that did not land
# leaves every directory empty, and a sweep over nothing reports a clean sweep for the wrong reason.
a47=""
for d47 in protocols ralph scripts; do
  [ -d "$H47/.claude/ai-flow/$d47" ] || a47="$a47 [the install did not create $d47, so nothing below is about a sweep]"
done
[ -f "$H47/.claude/ai-flow/protocols/backlog.md" ] || a47="$a47 [the install delivered no protocol, so the fixture is empty]"

GHOSTS47="protocols/codebase-mapping.md ralph/old-prompt.md scripts/retired.sh"
for g47 in $GHOSTS47; do printf 'retired\n' > "$H47/.claude/ai-flow/$g47"; done
OUT47="$( cd "$ROOT" && HOME="$H47" bash "$ROOT/install.sh" update </dev/null 2>&1 )" || true

b47=""
for g47 in $GHOSTS47; do
  [ -f "$H47/.claude/ai-flow/$g47" ] && b47="$b47 [$g47 survived the update]"
done
{ [ -z "$a47" ] && [ -z "$b47" ]; } \
  && ok "the update withdraws what the trunk no longer publishes" \
  || bad "the update withdraws what the trunk no longer publishes ($a47$b47)"

# The removal is named. A deletion the operator cannot see in the same output is indistinguishable from
# a file that was never there, which is the one condition the loss was accepted under.
c47=""
for g47 in $GHOSTS47; do
  case "$OUT47" in *"${g47##*/}"*) : ;; *) c47="$c47 [${g47##*/} was not named]" ;; esac
done
[ -z "$c47" ] && ok "every removal is named in the output" \
              || bad "every removal is named in the output ($c47)"

# A sweep that removes nothing reports a measured zero rather than staying silent: a silence says "none
# is possible here" where a zero says "measured, found nothing" — the engine's own distinction.
OUT47B="$( cd "$ROOT" && HOME="$H47" bash "$ROOT/install.sh" update </dev/null 2>&1 )" || true
d47=""
printf '%s' "$OUT47B" | grep -qiE 'retire|withdraw|sweep|remove' || d47=" [a sweep that removed nothing said nothing about sweeping]"
[ -z "$d47" ] && ok "a sweep that removes nothing reports a measured zero" \
              || bad "a sweep that removes nothing reports a measured zero ($d47)"

# --- the shared directories are out of reach ----------------------------------
# GIVEN files the operator owns in the directories the engine shares with their own tools,
# WHEN the update runs,
# THEN they survive. The engine sweeps only what it owns outright.
mkdir -p "$H47/.claude/skills/mine" "$H47/.claude/workflows"
printf 'mine\n' > "$H47/.claude/skills/mine/SKILL.md"
printf 'mine\n' > "$H47/.claude/workflows/mine.js"
printf 'mine\n' > "$H47/.claude/hooks/mine.sh"
( cd "$ROOT" && HOME="$H47" bash "$ROOT/install.sh" update </dev/null >/dev/null 2>&1 ) || true
e47=""
for p47 in skills/mine/SKILL.md workflows/mine.js hooks/mine.sh; do
  [ -f "$H47/.claude/$p47" ] || e47="$e47 [$p47 was swept from a shared directory]"
done
[ -z "$e47" ] && ok "the shared directories are never swept" \
              || bad "the shared directories are never swept ($e47)"

# A correction needs a guard as much as a feature does. An earlier form of the sweep discarded a failed
# removal, so the run's own verdict reported a clean sweep over a file still installed -- the false all-clear
# the drift guard exists to prevent, produced by the mechanism meant to repair it. Driven by an unwritable
# subdirectory, which is how a removal fails on a real machine; the exclusive directory itself stays
# writable so the fetches that run before the sweep are unaffected and the failure is the sweep's alone.
w47=""
mkdir -p "$H47/.claude/ai-flow/scripts/stuck"
printf 'retired\n' > "$H47/.claude/ai-flow/scripts/stuck/held.sh"
chmod 500 "$H47/.claude/ai-flow/scripts/stuck"
OUT47C="$( cd "$ROOT" && HOME="$H47" bash "$ROOT/install.sh" update </dev/null 2>&1 )" || true
chmod 700 "$H47/.claude/ai-flow/scripts/stuck"
[ -e "$H47/.claude/ai-flow/scripts/stuck/held.sh" ] \
  || w47=" [the fixture removal succeeded, so this row proves nothing about a failure]"
case "$OUT47C" in *"could not retire"*) : ;; *) w47="$w47 [a removal that failed was not reported]" ;; esac
case "$OUT47C" in *"nothing to withdraw"*) w47="$w47 [the run claimed a clean sweep over a file it could not remove]" ;; esac
rm -rf "$H47/.claude/ai-flow/scripts/stuck"
[ -z "$w47" ] && ok "a removal that fails is reported, and the run does not claim a clean sweep" \
              || bad "a removal that fails is reported, and the run does not claim a clean sweep ($w47)"

# `init` runs the same install units, so it sweeps as `update` does. The verdict was printed by `update`
# alone, which left the one path a first-time operator takes withdrawing files in silence -- and silence is
# the single condition the loss of a hand-placed file was not accepted under.
y47=""
Y47H="$T47/inithome"; Y47T="$T47/initproj"; mkdir -p "$Y47H/.claude/ai-flow/protocols" "$Y47T"
printf 'retired\n' > "$Y47H/.claude/ai-flow/protocols/codebase-mapping.md"
OUT47D="$( cd "$T47" && printf 'n\nn\n' | HOME="$Y47H" bash "$ROOT/install.sh" init "$Y47T" 2>&1 )" || true
case "$OUT47D" in *"Retirement sweep"*) : ;; *) y47=" [the init path swept and reported no verdict]" ;; esac
case "$OUT47D" in *codebase-mapping.md*) : ;; *) y47="$y47 [the file the init path removed was not named]" ;; esac
[ -z "$y47" ] && ok "the init path reports the sweep it runs" \
              || bad "the init path reports the sweep it runs ($y47)"

# --- the guard's third verdict ------------------------------------------------
# GIVEN an engine clone whose trunk no longer names a file the installed engine still holds,
# WHEN the drift guard runs,
# THEN it reports that file as orphaned and refuses.
E47="$T47/eng"; mkproj "$E47" main
mkdir -p "$E47/global/protocols" "$E47/docs"
printf 'v1\n' > "$E47/global/protocols/backlog.md"
# The operating document is committed into the fixture trunk as well. Without it the guard's docs arm is
# never executed by anything: its enumeration yields no document, its orphan loop short-circuits on the
# absent directory, and every claim about the manual being compared rests on the source text alone.
printf 'doc v1\n' > "$E47/docs/customization.md"
# A document the trunk holds and the engine does not publish, which is what separates the guard's question
# from the installer's. Without it the two could ask different questions and nothing would notice.
printf 'guide\n' > "$E47/docs/getting-started.md"
$GIT -C "$E47" add global docs >/dev/null 2>&1; $GIT -C "$E47" commit -q -m engine
G47="$T47/ghome"; mkdir -p "$G47/.claude/ai-flow/protocols" "$G47/.claude/ai-flow/docs" "$G47/.claude/hooks/git" "$G47/.claude/skills/mine"
printf '%s\n' "$E47" > "$G47/.claude/ai-flow/source.path"
printf 'v1\n' > "$G47/.claude/ai-flow/protocols/backlog.md"     # matches the trunk: not drift, not an orphan
printf 'doc v1\n' > "$G47/.claude/ai-flow/docs/customization.md"

# The clean arm first. A verdict that leans on a neighbouring failure is not a verdict, so the fixture is
# proven silent before an orphan is planted into it.
f47=""
out47="$( cd "$E47" && HOME="$G47" bash "$HK/drift-check.sh" 2>&1 <<<'{}' )"; rc47=$?
[ "$rc47" = 0 ] || f47="$f47 [the fixture was not clean before the orphan was planted (exit $rc47): $out47]"

printf 'retired\n' > "$G47/.claude/ai-flow/protocols/codebase-mapping.md"
out47="$( cd "$E47" && HOME="$G47" bash "$HK/drift-check.sh" 2>&1 <<<'{}' )"; rc47=$?
[ "$rc47" = 2 ] || f47="$f47 [an orphan did not refuse (exit $rc47)]"
case "$out47" in *orphan*) : ;; *) f47="$f47 [the report carries no orphan verdict]" ;; esac
case "$out47" in *codebase-mapping.md*) : ;; *) f47="$f47 [the orphan is not named]" ;; esac
[ -z "$f47" ] && ok "the guard reports an orphan the trunk no longer names" \
              || bad "the guard reports an orphan the trunk no longer names ($f47)"

# The remedy must be able to change what the check names. Before this task the update could not remove
# anything, so an orphan verdict pointing at it would have sent the operator to watch a failure persist.
g47r=""
printf '%s' "$out47" | grep -q 'install.sh' && : || g47r=" [the orphan remedy names no command]"
printf '%s' "$out47" | grep -q 'update' || g47r="$g47r [the orphan remedy does not name the update]"
# The narrowing is announced or it is silent, and a guard that checks part of what it installs while reading
# like it checked all of it is the false all-clear this one exists to prevent.
printf '%s' "$out47" | grep -qi 'orphaned file' || g47r="$g47r [the report never says what an orphan is]"
printf '%s' "$out47" | grep -qi 'shared' || g47r="$g47r [the report does not say which directories go unchecked]"
[ -z "$g47r" ] && ok "the orphan remedy names the command that can repair it" \
               || bad "the orphan remedy names the command that can repair it ($g47r)"

# The installer's own generated pass-through copies, and the directories shared with the operator, are
# never orphans. Twenty-one of the twenty-four files a naive sweep found on a real host were written by
# the installer itself; a guard that reports them is one the operator turns off.
rm -f "$G47/.claude/ai-flow/protocols/codebase-mapping.md"
printf 'chain\n' > "$G47/.claude/hooks/git/post-commit"
printf 'mine\n'  > "$G47/.claude/skills/mine/SKILL.md"
h47=""
out47="$( cd "$E47" && HOME="$G47" bash "$HK/drift-check.sh" 2>&1 <<<'{}' )"; rc47=$?
case "$out47" in *post-commit*) h47="$h47 [a generated pass-through copy was reported]" ;; esac
case "$out47" in *"skills/mine"*) h47="$h47 [a file in a shared directory was reported]" ;; esac
[ -z "$h47" ] && ok "the installer's own generated copies and the shared directories are never orphans" \
              || bad "the installer's own generated copies and the shared directories are never orphans ($h47)"

# The trunk carrying a document is not the question the sweep asks. The installer keeps only what its lists
# publish to a directory, so a document the trunk holds and the engine does not install is one the next update
# deletes -- and a guard judging on the trunk alone would report clean over exactly that file, vouching for it
# right up to the moment the update removes it.
x47=""
printf 'guide\n' > "$G47/.claude/ai-flow/docs/getting-started.md"
out47="$( cd "$E47" && HOME="$G47" bash "$HK/drift-check.sh" 2>&1 <<<'{}' )"; rc47=$?
[ "$rc47" = 2 ] || x47=" [a document the engine does not publish was not reported (exit $rc47)]"
case "$out47" in *getting-started.md*) : ;; *) x47="$x47 [the unpublished document is not named]" ;; esac
rm -f "$G47/.claude/ai-flow/docs/getting-started.md"
[ -z "$x47" ] && ok "the guard and the sweep ask one question about what is published" \
              || bad "the guard and the sweep ask one question about what is published ($x47)"

# The two readers cannot drift about which directories are exclusive (D8): every directory the guard
# treats as exclusive has an installer sweep, and every sweep the installer runs is a directory the
# guard treats as exclusive. Derived from both sources, never from a list restated in this file.
i47=""
GEX47="$(sed -n 's/.*AI_FLOW_EXCLUSIVE=\"\(.*\)\".*/\1/p' "$ROOT/global/hooks/drift-check.sh" | head -1)"
ISW47="$(sed -n 's/.*sweep_dir \"\$HOME\/\.claude\/ai-flow\/\([a-z]*\)\".*/\1/p' "$ROOT/install.sh" | sort -u | tr '\n' ' ')"
if [ -z "$GEX47" ] || [ -z "$ISW47" ]; then
  i47=" [the exclusive set did not extract from the guard, or the sweep set from the installer]"
else
  for x47 in $GEX47; do
    case " $ISW47 " in *" $x47 "*) ;; *) i47="$i47 [the guard calls $x47 exclusive and the installer never sweeps it]" ;; esac
  done
  for x47 in $ISW47; do
    case " $GEX47 " in *" $x47 "*) ;; *) i47="$i47 [the installer sweeps $x47 and the guard does not call it exclusive]" ;; esac
  done
  # The direction the two set comparisons above cannot see. Both are built from sweeps that already match
  # `~/.claude/ai-flow/<name>`, so a sweep aimed anywhere else -- at the shared skills directory, say -- is
  # invisible to them and the row stays green over a deletion nothing watches. Every call site is read here,
  # whatever it points at, and this is the leg that fails on one aimed outside.
  ALLSW47="$(grep -oE 'sweep_dir "[^"]+"' "$ROOT/install.sh" | sed -E 's/^sweep_dir "//; s/"$//' | sort -u)"
  [ -n "$ALLSW47" ] || i47="$i47 [no sweep call site extracted at all]"
  for x47 in $ALLSW47; do
    case "$x47" in
      '$HOME/.claude/ai-flow/'*) ;;
      *) i47="$i47 [a sweep is aimed at $x47, outside the directories the engine owns outright]" ;;
    esac
  done
fi
[ -z "$i47" ] && ok "the directories the guard calls exclusive are exactly the directories the installer sweeps" \
              || bad "the directories the guard calls exclusive are exactly the directories the installer sweeps ($i47)"

# --- the manual that is never published reports its own gaps ------------------
# The rule leads a manual declares, as a set. Bodies are never compared: the operator writes their copy
# in their own language, and a translated body is not a missing rule. A section the operator is meant to
# replace with their own is exempt, by name.
leads47() {  # $1 = manual -> one rule lead per line
  awk '
    /^## / { own = ($0 ~ /Engine Defaults/) }
    !own && /^- \*\*/ { line = $0; sub(/^- \*\*/, "", line); sub(/\*\*.*$/, "", line); print line }
  ' "$1"
}

# Non-vacuous first. An extractor that returns nothing passes every comparison it makes, which is the
# shape this harness already audits itself for.
j47=""
SHIP47="$(leads47 "$MAN")"
NSHIP47="$(printf '%s\n' "$SHIP47" | grep -c . || true)"
[ "$NSHIP47" -ge 20 ] || j47=" [the shipped manual yielded $NSHIP47 rule leads — the extractor is not reading the document]"
[ -z "$j47" ] && ok "the coverage extractor reads the shipped manual ($NSHIP47 rule leads)" \
              || bad "the coverage extractor reads the shipped manual ($j47)"

# The coverage itself. Derived, never enumerated: a hand-written check proves its own rule and says
# nothing about the rule nobody remembered.
# The comparison, as one function. The row that runs it over the real manuals and the row that proves it can
# detect an absence then execute the SAME code: a control that exercises a second copy of the logic proves
# the copy and says nothing about what ships.
missing_leads47() {  # $1 = declaring manual, $2 = manual to check -> the leads $1 declares that $2 lacks
  local ship twin l miss=""
  ship="$(leads47 "$1")"; twin="$(leads47 "$2")"
  while IFS= read -r l; do
    [ -n "$l" ] || continue
    printf '%s\n' "$twin" | grep -qxF "$l" || miss="$miss [$l]"
  done <<MLEOF
$ship
MLEOF
  printf '%s' "$miss"
}

# The detection direction, proven over a pair built for it and never over the host's own manuals. Run only
# against the real pair, this row passes on a machine whose copies happen to agree -- and would pass
# identically with the comparison neutered, which is a check nobody can tell from no check at all. The same
# fixture carries one-directionality: it is a property of the function, not of what this host happens to hold,
# and the earlier form failed on a fresh install whose twin carried no rule of its own.
t47=""
cp "$MAN" "$T47/ship-plus.md"
printf '\n- **A launcher nobody ported**: proves the comparison detects an absence\n' >> "$T47/ship-plus.md"
[ -n "$(missing_leads47 "$T47/ship-plus.md" "$MAN")" ] \
  || t47=" [a rule the second manual lacks was not detected]"
[ -z "$(missing_leads47 "$MAN" "$T47/ship-plus.md")" ] \
  || t47="$t47 [a rule the second manual carries and the first does not was reported]"
[ -z "$t47" ] && ok "the comparison runs in one direction only" \
              || bad "the comparison runs in one direction only ($t47)"

if [ -f "$MANTWIN" ]; then
  k47=""
  NTWIN47="$(leads47 "$MANTWIN" | grep -c . || true)"
  [ "$NTWIN47" -ge 1 ] || k47=" [the live twin yielded no rule leads — the comparison would be vacuous]"
  MISS47="$(missing_leads47 "$MAN" "$MANTWIN")"
  [ -z "$MISS47" ] || k47="$k47 $MISS47"
  [ -z "$k47" ] && ok "every rule the shipped manual declares reached the live twin" \
                || bad "every rule the shipped manual declares reached the live twin (re-run the installer — it refreshes ~/.claude/ai-flow/AGENTS.md unconditionally):$k47"
else
  echo "  [skip] no personal manual on this host — the shipped copy carries the rules"
fi

# The exemption, proven over a manual that has one. The shipped copy's own operator section carries no
# bold lead today, so a row asserting the exemption against it would pass with the exemption deleted.
m47=""
cp "$MAN" "$T47/man-with-own.md"
python3 - "$T47/man-with-own.md" <<'PY47'
import sys
p = sys.argv[1]
s = open(p).read()
s = s.replace("## Engine Defaults\n", "## Engine Defaults\n\n- **A rule of my own**: never distributed\n", 1)
open(p, "w").write(s)
PY47
printf '%s\n' "$(leads47 "$T47/man-with-own.md")" | grep -qxF 'A rule of my own' \
  && m47=" [a rule in the operator's own section was compared]"
[ -z "$m47" ] && ok "the operator's own section is exempt from the coverage comparison" \
              || bad "the operator's own section is exempt from the coverage comparison ($m47)"

# An absent twin is a skip, never a failure: a host without one turns a documented skip into red, and a
# red the operator cannot act on is the noise that ends with the guard switched off.
# Worded without the token C20's extractor keys on, and deliberately: this row is not a verdict about a
# stale personal manual, it is a verdict about the harness owning a skip path. Routing it to the hand
# edit would send the operator to port a rule when what is missing is a branch in this file.
# Keyed on this block's own wording and counted, not merely found: the phrase the earlier form looked for
# is carried by the twin helper and by five other verdicts, so the row was satisfied with its own skip branch
# deleted. Exactly one site may carry this sentence, and it is the one below.
# Assembled from two pieces so the line that searches does not itself carry what it searches for: written
# whole, the pattern matched its own grep and the count came back 2 with the skip branch present exactly once.
n47=""
n47p='no personal manual on this'; n47p="$n47p host"
n47c="$(grep -cF "$n47p" "$SECTION" || true)"
[ "$n47c" = 1 ] || n47=" [the skip branch for a host with no personal manual is absent, or stated in $n47c places]"
[ -z "$n47" ] && ok "a host with no personal manual gets a skip, never a failure" \
              || bad "a host with no personal manual gets a skip, never a failure ($n47)"

# --- the compaction line states what happens ---------------------------------
# The claim promised an automatism nothing implements: the hook set declares PreToolUse and Stop and no
# PreCompact. What replaces it is the re-read the session performs, stated as an obligation.
mf_compaction() {
  local b; b="$(mbul "$1" '^### Session Continuity' '^- [*][*]On compaction')"
  [ -n "$b" ] || return 1
  printf '%s' "$b" | grep -qiE 're-read|re-reads|read again'      || return 1
  printf '%s' "$b" | grep -qiE 'automatic'                        && return 1
  return 0
}
manfact mf_compaction "the compaction line states the re-read the session performs, not an automatism"

# --- the configuration manual is operated, so it is distributed ---------------
# GIVEN the engine installed into a sandbox home,
# WHEN the update runs,
# THEN the configuration manual is on disk where the engine keeps what it operates with.
o47=""
[ -f "$H47/.claude/ai-flow/docs/customization.md" ] || o47=" [the configuration manual was not installed]"
[ -z "$o47" ] && ok "the configuration manual is installed with the engine" \
              || bad "the configuration manual is installed with the engine ($o47)"

# The list and the tree are two declarations of one fact, and they were free to drift in the direction
# nothing watched — the same shape C37 asserts over the protocol list.
p47=""
DL47="$(sed -n 's/^DOCS="\(.*\)"$/\1/p' "$ROOT/install.sh")"
if [ -z "$DL47" ]; then
  p47=" [the installer declares no docs list]"
else
  for f47 in $DL47; do
    [ -f "$ROOT/docs/$f47" ] || p47="$p47 [the installer delivers docs/$f47, which is not in the tree]"
  done
fi
[ -z "$p47" ] && ok "the engine ships every document its docs list declares" \
              || bad "the engine ships every document its docs list declares ($p47)"

# The guard compares it like every other engine file: a file delivered and never compared is a file that
# drifts in silence, which is the defect this task exists to close in the other direction.
#
# RUN, never grepped. An earlier form of this row asserted two strings in the guard's source, and the one it
# matched was the inert arm -- `docs/*) echo ""`, which makes the file skip comparison. Deleting the arm that
# actually maps the manual to its destination left both greps green and the manual uncompared for good. Both
# verdicts are driven here instead, over the fixture that now carries a real operating document, and the
# clean arm above is what proves the fixture was silent before either was provoked.
q47=""
printf 'doc perturbed\n' > "$G47/.claude/ai-flow/docs/customization.md"
out47="$( cd "$E47" && HOME="$G47" bash "$HK/drift-check.sh" 2>&1 <<<'{}' )"; rc47=$?
[ "$rc47" = 2 ] || q47="$q47 [a changed operating document did not refuse (exit $rc47)]"
case "$out47" in *differs*) : ;; *) q47="$q47 [no differs verdict for the manual]" ;; esac
case "$out47" in *"ai-flow/docs/customization.md"*) : ;; *) q47="$q47 [the differing manual is not named]" ;; esac
rm -f "$G47/.claude/ai-flow/docs/customization.md"
out47="$( cd "$E47" && HOME="$G47" bash "$HK/drift-check.sh" 2>&1 <<<'{}' )"; rc47=$?
[ "$rc47" = 2 ] || q47="$q47 [a deleted operating document did not refuse (exit $rc47)]"
case "$out47" in *missing*) : ;; *) q47="$q47 [no missing verdict for the manual]" ;; esac
printf 'doc v1\n' > "$G47/.claude/ai-flow/docs/customization.md"     # back to matching, for whatever follows
[ -z "$q47" ] && ok "the guard compares the configuration manual as it compares every engine file" \
              || bad "the guard compares the configuration manual as it compares every engine file ($q47)"

# The guard names each operating document by name while the installer publishes a list. A second entry in
# that list would be delivered by the update and compared by nothing, in silence -- the exact shape this
# task exists to close, reintroduced one document later.
v47=""
if [ -z "$DL47" ]; then
  v47=" [no docs list to check the guard's arms against]"
else
  for f47 in $DL47; do
    grep -q "docs/$f47)" "$ROOT/global/hooks/drift-check.sh" \
      || v47="$v47 [the installer publishes docs/$f47 and the guard has no arm for it]"
  done
fi
[ -z "$v47" ] && ok "every document the installer publishes has an arm in the guard's map" \
              || bad "every document the installer publishes has an arm in the guard's map ($v47)"

# Delivery is not reachability. A manual on disk that no surface a session loads ever names is one the
# session has no reason to know exists: it answers from memory or sends the operator to a browser, which is
# the outcome the distribution was for. Tied to the list here so the two cannot drift apart -- a document
# dropped from the list with its pointer left behind fails as loudly as a pointer removed.
u47=""
if [ -z "$DL47" ]; then
  u47=" [no docs list to check reachability against]"
else
  for f47 in $DL47; do
    u47h="$(grep -rl "ai-flow/docs/$f47" "$ROOT/global/protocols" "$ROOT/global/skills" "$ROOT/global/CLAUDE.md" 2>/dev/null | wc -l | tr -d ' ')"
    [ "$u47h" -ge 1 ] || u47="$u47 [nothing a session loads names the installed docs/$f47]"
  done
fi
[ -z "$u47" ] && ok "a surface a session loads names the installed manual" \
              || bad "a surface a session loads names the installed manual ($u47)"

# The pointer names what the operator can open. A path inside the repository is a path an adopter who
# installed from the network does not have.
r47=""
PTR47="$(grep -n 'see .*customization' "$ROOT/install.sh" | head -1)"
[ -n "$PTR47" ] || r47=" [the installer points the operator at no configuration manual]"
if [ -n "$PTR47" ]; then
  case "$PTR47" in *'.claude/ai-flow/docs'*) : ;; *) r47="$r47 [the pointer still names a path inside the repository]" ;; esac
fi
[ -z "$r47" ] && ok "the installer points at the installed manual, not a repository path" \
              || bad "the installer points at the installed manual, not a repository path ($r47)"
