echo "== C70: two remembered rules become a refusal at the act and a report at the close =="
# Generated in the Conform phase from understand.md's Verifiable Criteria. Two properties shape every
# row below. First, the failure both rails can introduce is SILENCE -- a guard that stands aside and an
# audit leg nobody performs look exactly like a clean run -- so each row carries a positive leg that no
# absent mechanism can satisfy. Second, the marker rows DERIVE their fixtures from the protocol's own
# single declaration (D3) rather than spelling any marker out here: that is what keeps this suite
# committable with rail (b) live, since `test/` is a directory the brake recognises as tests and a
# literal marker added here would be reported against this task's own diff.

T70="$(mkbox)" || fatal 'C70 fixtures'

GUARD70="$HK/artifact-write-guard.py"
VFY70="$ROOT/global/protocols/verify.md"
SKL70="$ROOT/global/skills/verify/SKILL.md"
EXE70="$ROOT/global/protocols/execute.md"
RDM70="$HK/README.md"
REG70="$HK/settings.hooks.json"
MAN70="$ROOT/global/CLAUDE.md"

# The payload shape the guard is registered for. `tool_name` is carried on every row because D1 makes it
# load-bearing: the guard's jurisdiction is its own, not the matcher's alone.
aguard() {  # $1 = cwd, $2 = file_path, $3 = tool_name (default Write) -> output, returns the exit code
  hookcall "$GUARD70" "$1" "$2" "${3:-Write}"
}

if [ "$PY3" = 0 ]; then
  echo "  [skip] C70 rail (a) checks (python3 unavailable)"
elif [ ! -f "$GUARD70" ]; then
  bad "A1 the artifact guard refuses a Write over an existing understand/plan/verify/discoveries (no $GUARD70)"
  bad "A2 the artifact guard allows a Write that creates a guarded name (no hook)"
  bad "A3 the artifact guard judges four names and nothing else (no hook)"
  bad "A4 the artifact guard refuses an input it cannot read, and names it (no hook)"
  bad "A5 the artifact guard is silent outside an ai-flow project (no hook)"
  bad "D1 the artifact guard stands aside on any tool but Write (no hook)"
  bad "O2 the artifact guard's refusal names the file and never its contents (no hook)"
else
  P70="$T70/proj"; mkproj "$P70" main
  mkdir -p "$P70/.ai-flow/artifacts/T-XXX" "$P70/.ai-flow/artifacts/T-XXX/conformance-baseline"
  SECRET70='the-artifact-body-that-must-never-be-echoed'
  for n70 in understand plan verify discoveries; do
    printf '%s\n' "$SECRET70" > "$P70/.ai-flow/artifacts/T-XXX/$n70.md"
  done
  printf 'phase: **EXECUTE**\n' > "$P70/.ai-flow/artifacts/T-XXX/state.md"
  printf 'x\n' > "$P70/.ai-flow/artifacts/T-XXX/conformance-baseline/manifest.md"

  # A1 -- all four names, each refused and each NAMED. One row per name would let three pass while the
  # fourth was never in the list, which is the defect a single presence row cannot see.
  a1_70=""
  for n70 in understand plan verify discoveries; do
    out70="$(aguard "$P70" "$P70/.ai-flow/artifacts/T-XXX/$n70.md")"; rc70=$?
    [ "$rc70" = 2 ] || a1_70="$a1_70 $n70.md(exit $rc70)"
    printf '%s' "$out70" | grep -qF "$n70.md" || a1_70="$a1_70 $n70.md(unnamed)"
    printf '%s' "$out70" | grep -qiE 'amend|enmend' || a1_70="$a1_70 $n70.md(no-remedy)"
  done
  [ -z "$a1_70" ] && ok "A1 the artifact guard refuses a Write over an existing understand/plan/verify/discoveries" \
                  || bad "A1 the artifact guard refuses a Write over an existing understand/plan/verify/discoveries ($a1_70)"

  # A2 -- the rail is about replacement, not creation.
  a2_70=""
  for n70 in understand plan verify discoveries; do
    out70="$(aguard "$P70" "$P70/.ai-flow/artifacts/T-NEW/$n70.md")"; rc70=$?
    [ "$rc70" = 0 ] && [ -z "$out70" ] || a2_70="$a2_70 $n70.md(exit $rc70${out70:+, said: $out70})"
  done
  [ -z "$a2_70" ] && ok "A2 the artifact guard allows a Write that creates a guarded name" \
                  || bad "A2 the artifact guard allows a Write that creates a guarded name ($a2_70)"

  # A3 -- the five paths that must stay unjudged, each of them existing so that only the NAME can be
  # what spares it. state.md is the one the decision turns on (D6).
  a3_70=""
  printf 'x\n' > "$P70/other.md"
  for p70 in "$P70/.ai-flow/artifacts/T-XXX/state.md" \
             "$P70/.ai-flow/artifacts/T-XXX/conformance-baseline/manifest.md" \
             "$P70/.ai-flow/STATE.md" \
             "$P70/other.md" \
             "$T70/outside.md"; do
    printf 'x\n' > "$p70" 2>/dev/null
    out70="$(aguard "$P70" "$p70")"; rc70=$?
    [ "$rc70" = 0 ] && [ -z "$out70" ] || a3_70="$a3_70 ${p70#$P70/}(exit $rc70${out70:+, said: $out70})"
  done
  [ -z "$a3_70" ] && ok "A3 the artifact guard judges four names and nothing else" \
                  || bad "A3 the artifact guard judges four names and nothing else ($a3_70)"

  # A4 -- unreadable is a refusal that names the file, never a pass. `Path.exists()` answers False on a
  # PermissionError, so a guard built on it reports "does not exist" and waves the replacement through:
  # this row is the one that separates the two, and it is why the existence test must raise rather than
  # answer. Skipped where the runner can read anything, which is the one host where chmod proves nothing.
  U70="$T70/unreadable"; mkproj "$U70" main
  mkdir -p "$U70/.ai-flow/artifacts/T-XXX"
  printf 'x\n' > "$U70/.ai-flow/artifacts/T-XXX/plan.md"
  chmod 000 "$U70/.ai-flow/artifacts/T-XXX" 2>/dev/null
  if [ -r "$U70/.ai-flow/artifacts/T-XXX/plan.md" ]; then
    echo "  [skip] A4 the artifact guard refuses an input it cannot read (this runner reads anything)"
  else
    out70="$(aguard "$U70" "$U70/.ai-flow/artifacts/T-XXX/plan.md")"; rc70=$?
    if [ "$rc70" = 2 ] && printf '%s' "$out70" | grep -qF 'plan.md'; then
      ok "A4 the artifact guard refuses an input it cannot read, and names it"
    else
      bad "A4 the artifact guard refuses an input it cannot read, and names it (exit $rc70, said: $out70)"
    fi
  fi
  chmod u+rwX "$U70/.ai-flow/artifacts/T-XXX" 2>/dev/null

  # A5 -- the designed silence every hook here has, so the guard is safe to install globally.
  N70="$T70/noflow"; mkproj "$N70" main
  printf 'x\n' > "$N70/.ai-flow-not-a-ledger"
  out70="$(aguard "$N70" "$N70/.ai-flow/artifacts/T-XXX/plan.md")"; rc70=$?
  { [ "$rc70" = 0 ] && [ -z "$out70" ]; } \
    && ok "A5 the artifact guard is silent outside an ai-flow project" \
    || bad "A5 the artifact guard is silent outside an ai-flow project (exit $rc70${out70:+, said: $out70})"

  # D1 -- jurisdiction in the guard's own code, not in the registration alone. The README asks each
  # adopter to merge the matcher by hand into their settings, and a hand-merge into the existing
  # Edit|Write group is how it widens; this row is what makes that harmless.
  d1_70=""
  for t70 in Edit MultiEdit NotebookEdit Read Bash; do
    out70="$(aguard "$P70" "$P70/.ai-flow/artifacts/T-XXX/plan.md" "$t70")"; rc70=$?
    [ "$rc70" = 0 ] && [ -z "$out70" ] || d1_70="$d1_70 $t70(exit $rc70${out70:+, said: $out70})"
  done
  [ -z "$d1_70" ] && ok "D1 the artifact guard stands aside on any tool but Write" \
                  || bad "D1 the artifact guard stands aside on any tool but Write ($d1_70)"

  # O2 -- the safety property the secret guard's row states: a refusal that echoes what it caught has
  # copied it into the scrollback, the CI log and the transcript.
  out70="$(aguard "$P70" "$P70/.ai-flow/artifacts/T-XXX/understand.md")"
  printf '%s' "$out70" | grep -qF "$SECRET70" \
    && bad "O2 the artifact guard's refusal names the file and never its contents (it echoed the body)" \
    || ok "O2 the artifact guard's refusal names the file and never its contents"

  # --- a payload whose fields are not the shape the guard expects ----------
  # Six branches of this guard read a field and could have assumed its type. The sibling rail paid for
  # every one of them: an uncaught raise leaves a PreToolUse hook on exit 1, which does NOT block, so the
  # write went through with a stack trace printed over it. Deleting any of the six left the suite green
  # here, because every fixture above sends a well-formed object. Silence is asserted, not merely the
  # absence of a crash -- a guard that stands aside with a diagnostic is chatter on every Write.
  araw() {  # $1 = raw payload -> prints output, returns the hook's exit code
    printf '%s' "$1" | python3 "$GUARD70" 2>&1
  }
  amalformed() {  # $1 = label, $2 = raw payload -> asserts the pair: waved through, and nothing said
    out70="$(araw "$2")"; rc70=$?
    if [ "$rc70" = 0 ] && [ -z "$out70" ]; then
      ok "$1"
    else
      case "$out70" in
        *Traceback*) bad "$1 (exit $rc70, traceback)" ;;
        *)           bad "$1 (exit $rc70, said: $out70)" ;;
      esac
    fi
  }
  AG70="$P70/.ai-flow/artifacts/T-XXX/plan.md"   # exists, so only the malformation can be what spares it
  amalformed "P1 a top-level payload that is not an object is waved through without a traceback" \
    '["x"]'
  amalformed "P2 a payload that is not JSON at all is waved through without a traceback" \
    'not json'
  amalformed "P3 a tool_input that is not an object is waved through without a traceback" \
    "{\"cwd\":\"$P70\",\"tool_name\":\"Write\",\"tool_input\":\"oops\"}"
  amalformed "P4 a cwd that is not a string is waved through without a traceback" \
    "{\"cwd\":123,\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$AG70\"}}"
  amalformed "P5 a file_path that is not a string is waved through without a traceback" \
    "{\"cwd\":\"$P70\",\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":7}}"
  amalformed "P6 an empty file_path is waved through and blocks nothing" \
    "{\"cwd\":\"$P70\",\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"\"}}"
  # The control, and the six above are worth nothing without it: a guard that exited 0 on every input
  # would satisfy all six. The same fixture, well-formed, must still refuse.
  out70="$(araw "{\"cwd\":\"$P70\",\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$AG70\"}}")"; rc70=$?
  [ "$rc70" = 2 ] && ok "P7 the malformed-payload fixture still refuses a well-formed Write over an existing artifact" \
                  || bad "P7 the malformed-payload fixture still refuses a well-formed Write over an existing artifact (exit $rc70)"
  # The other arm of the directory read: a payload declaring NO cwd falls back to the process's own,
  # which is the session's on every real invocation. Nothing pinned it -- every other fixture declares
  # one -- so the fallback could be widened into a stand-aside and the rail would go silent, suite green.
  out70="$( cd "$P70" && araw "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\".ai-flow/artifacts/T-XXX/plan.md\"}}" )"; rc70=$?
  [ "$rc70" = 2 ] && ok "P8 a payload declaring no directory is judged against the one the hook runs in" \
                  || bad "P8 a payload declaring no directory is judged against the one the hook runs in (exit $rc70)"
fi

# A6 -- registration and installation. The matcher is asserted as a GROUP of its own naming Write and
# not Edit: a hook appended to the existing Edit|Write group would satisfy a presence grep and break the
# jurisdiction the row above only makes survivable.
a6_70=""
grep -qE '^HOOKS=.*artifact-write-guard\.py' "$ROOT/install.sh" \
  || a6_70="$a6_70 [install.sh HOOKS= does not name it, so a fresh install ships without the rail]"
if [ "$PY3" = 1 ]; then
  M70="$(python3 - "$REG70" <<'PY' 2>/dev/null
import json, sys
try:
    groups = json.load(open(sys.argv[1]))['PreToolUse']
except Exception:
    sys.exit(0)
for g in groups:
    cmds = ' '.join(h.get('command', '') for h in g.get('hooks', []) if isinstance(h, dict))
    if 'artifact-write-guard.py' in cmds:
        print(g.get('matcher', ''))
PY
)"
  [ -n "$M70" ] || a6_70="$a6_70 [no PreToolUse group registers the guard]"
  [ "$M70" = "Write" ] || [ -z "$M70" ] || a6_70="$a6_70 [its matcher is '$M70', not Write alone]"
else
  echo "  [skip] A6 matcher shape (python3 unavailable)"
fi
[ -z "$a6_70" ] && ok "A6 the artifact guard is registered on Write alone and installed with its siblings" \
                || bad "A6 the artifact guard is registered on Write alone and installed with its siblings ($a6_70)"

# O1 -- the catalog row, extracted the way ROW23 and ROW24 extract their sibling's. It is the layer
# someone reads when the rail is down, so its four claims are asserted individually.
ROW70="$(grep -m1 '^| .artifact-write-guard.py.' "$RDM70" | tr -d '*`' | tr -s ' ')"
o1_70=""
[ -n "$ROW70" ] || o1_70="$o1_70 [no row]"
if [ -n "$ROW70" ]; then
  printf '%s' "$ROW70" | grep -qF 'PreToolUse' || o1_70="$o1_70 (event)"
  for n70 in understand plan verify discoveries; do
    printf '%s' "$ROW70" | grep -qF "$n70" || o1_70="$o1_70 (jurisdiction:$n70)"
  done
  printf '%s' "$ROW70" | grep -qF 'state.md' || o1_70="$o1_70 (the one name it deliberately omits)"
  printf '%s' "$ROW70" | grep -qiE 'no-op|silent|without an .ai-flow' || o1_70="$o1_70 (silences)"
  printf '%s' "$ROW70" | grep -qiE 'cannot be read|unreadable' || o1_70="$o1_70 (the unreadable refusal)"
  printf '%s' "$ROW70" | grep -qiE 'never .{0,20}contents|never echoes' || o1_70="$o1_70 (never echoes contents)"
  printf '%s' "$ROW70" | grep -qiE 'shell|Bash' || o1_70="$o1_70 (invisible to the shell -- the limit a reader must not have to find in the papers)"
fi
[ -z "$o1_70" ] && ok "O1 the artifact guard's catalog row names its jurisdiction, its silences and its refusals" \
                || bad "O1 the artifact guard's catalog row names its jurisdiction, its silences and its refusals ($o1_70)"

# --- rail (b): one declaration, two readers, and a fixture derived from the declaration --------------
# The alternation is extracted from the protocol's own leg. Everything below is built from what this
# returns, so a marker added there arrives in the fixture, in the self-instance row and in the skill row
# at once -- and a leg that never lands leaves ALT70 empty, which is a failure and not a green run over
# nothing.
ALT70="$(grep -oE "grep -E '\([^)]*\)'" "$VFY70" 2>/dev/null | head -1 | sed -e 's/^grep -E .(//' -e 's/).$//')"
# The line-numbering stage of the same command, lifted the same way and RUN rather than read. The
# criterion asks the audit to print `file:line`; the only way to know the DOCUMENTED command can is to
# execute the documented command -- a row that rebuilds the pipeline locally proves its reconstruction.
AWK70="$(grep -oE "awk '[^']*'" "$VFY70" 2>/dev/null | head -1 | sed -e 's/^awk .//' -e 's/.$//')"
if [ -z "$ALT70" ]; then
  bad "A7 the skip-marker leg reports a disabled test with its file and line (no marker declaration in verify.md)"
  bad "A10 the marker set has exactly one declaration and the skill routes to it (nothing declared)"
  bad "O3 no skip-marker pattern is an instance of itself (nothing declared)"
  bad "A8 the verify command performs the skip-marker leg the protocol declares (nothing declared)"
else
  # The literal each pattern is meant to catch, recovered from the pattern: drop the escapes and open the
  # single-character classes the self-instance property is written with. No marker text is spelled here.
  # `\b` is a zero-width assertion, so it is dropped before the escapes are: leaving it in would derive
  # `bxit(` as the literal and the positive leg would test a marker nobody wrote.
  LITS70="$(printf '%s' "$ALT70" | tr '|' '\n' | sed -E 's/\\b//g' | tr -d '\\' | sed -E 's/\[(.)\]/\1/g')"
  n70=0; for l70 in $LITS70; do n70=$((n70+1)); done
  # A11 -- the set's CONTENTS, which every other rail-(b) row leaves unguarded: they all derive their
  # fixture FROM the declaration, so a marker deleted there is simply never tested and the suite stays
  # green. Measured: removing one left 979 passed, 0 failed. A note is not a row, and the whole weight of
  # the leg rests on this set -- a floor rather than an equality, because the set growing is the one
  # direction that needs no permission.
  [ "$n70" -ge 10 ] \
    && ok "A11 the declaration still carries the whole marker set" \
    || bad "A11 the declaration still carries the whole marker set ($n70 markers; understand.md names ten)"

  # A7 -- a fixture whose test file adds every marker and whose production file adds one, so the row
  # proves the TEST_RE restriction as well as the detection. The command asserted is the protocol's own.
  D70="$T70/diffbox"; mkproj "$D70" main
  mkdir -p "$D70/test"
  : > "$D70/test/thing.spec.ts"
  # Each marker on its own, indented: four of the ten now take a word boundary, so a literal glued to a
  # preceding word would no longer sit at a boundary, and the positive leg would test nothing. Written
  # without naming the marker: this file IS a test file to the brake, so prose about the set is read by
  # the set. The answer is to reword, never to exempt the path -- an exempt path is a file in which a
  # real violation passes unseen, which is the lesson git/pre-commit already paid for.
  for l70 in $LITS70; do printf '  %s\n' "$l70" >> "$D70/test/thing.spec.ts"; done
  # Two ORDINARY lines, in the same test file. These are the whole reason the boundaries are there, and
  # they are written literally because under the declared set they are NOT markers -- which is exactly
  # what makes them load-bearing: drop the boundaries and this row reddens instead of the next verify.
  printf '  sys.exit(0)\n  const y = benefit(x)\n' >> "$D70/test/thing.spec.ts"
  for l70 in $LITS70; do printf '  %s\n' "$l70" >> "$D70/app.ts"; break; done
  $GIT -C "$D70" add -A >/dev/null 2>&1
  $GIT -C "$D70" commit -q -m work
  # Which of the diff's files the leg is entitled to read, decided by the brake's own pattern rather
  # than by a second list here. Extracted from the hook the way LOCK69 extracts LOCKFILES: the module
  # calls main() unguarded and cannot be imported, so the declaration is lifted and exec'd alone.
  # Paths as ARGUMENTS, not on stdin: a heredoc feeding the program takes stdin with it, so the version
  # that piped the file list in had python read the list as its own source and the filter selected
  # nothing. It failed loudly only because the row carries a positive leg for the extraction itself.
  tfiles70() {  # $@ = paths -> the ones the brake calls tests
    python3 -c "
import re, sys
src = open(sys.argv[1], encoding=\"utf-8\").read()
block = re.search(r\"^TEST_RE = re\\.compile\\(.*?^\\)\$\", src, re.S | re.M)
if not block:
    sys.exit(\"TEST_RE did not extract\")
ns = {\"re\": re}
exec(block.group(0), ns)
for path in sys.argv[2:]:
    if path and ns[\"TEST_RE\"].search(path):
        print(path)
" "$HK/diff-size-guard.py" "$@"
  }
  a7_70=""
  [ -n "$AWK70" ] || a7_70="$a7_70 [the documented command carries no line-numbering stage, so it cannot report file:line]"
  ALLF70="$($GIT -C "$D70" diff --name-only HEAD~1 HEAD)"
  TSTF70="$(tfiles70 $ALLF70)"
  [ -n "$TSTF70" ] || a7_70="$a7_70 [the brake's TEST_RE did not extract, so the restriction checked nothing]"
  # The DOCUMENTED command, executed: the brake's file set as the pathspec, the protocol's own awk stage,
  # the protocol's own marker set. Nothing here is rebuilt -- a row that reconstructs the pipeline proves
  # its reconstruction, which is how a leg whose published form had no pathspec at all stayed green.
  HITS70="$($GIT -C "$D70" diff -U0 HEAD~1 HEAD -- $TSTF70 \
            | awk "$AWK70" | grep -E "$ALT70" 2>/dev/null)"
  # The same command with the pathspec REMOVED. It is the control for the restriction: without it the
  # negative half below cannot tell a working pathspec from a fixture that never had a hit to suppress.
  WIDE70="$($GIT -C "$D70" diff -U0 HEAD~1 HEAD \
            | awk "$AWK70" | grep -E "$ALT70" 2>/dev/null)"
  for l70 in $LITS70; do
    printf '%s' "$HITS70" | grep -qF "$l70" || a7_70="$a7_70 [$l70 not caught]"
  done
  # file AND line, from the command itself -- not a count, and not a diff offset dressed up as a line.
  printf '%s' "$HITS70" | grep -qE '^test/thing\.spec\.ts:[0-9][0-9]*:' \
    || a7_70="$a7_70 [the hits carry no file:line]"
  # The negative half the fixture's production file exists for, now attributed BY NAME rather than by a
  # count: the same marker in a file the brake does not call a test is reported without the pathspec and
  # must not be reported with it.
  printf '%s' "$ALLF70" | grep -qF 'app.ts' \
    || a7_70="$a7_70 [the fixture lost its non-test file, so the restriction was never put to the test]"
  printf '%s' "$TSTF70" | grep -qF 'app.ts' \
    && a7_70="$a7_70 [the brake counts app.ts as a test file -- the fixture's negative half proves nothing]"
  printf '%s' "$WIDE70" | grep -qF 'app.ts' \
    || a7_70="$a7_70 [the unrestricted form reports no non-test file either, so this fixture cannot show a pathspec working]"
  printf '%s' "$HITS70" | grep -qF 'app.ts' \
    && a7_70="$a7_70 [the documented command reports a non-test file: the restriction is not in it]"
  # Precision, and the reason four patterns take a word boundary. An ordinary exit() and an ordinary call
  # whose tail happens to spell a focus marker are not disabled tests, and a blocking gate that says
  # they are is a gate that gets routed around -- this engine's own suite offered ten such lines and
  # not one true positive.
  printf '%s' "$HITS70" | grep -qF 'sys.exit(' \
    && a7_70="$a7_70 [an ordinary exit() in a test file is reported as a disabled test]"
  printf '%s' "$HITS70" | grep -qF 'benefit(' \
    && a7_70="$a7_70 [an ordinary call whose tail spells a focus marker is reported as a disabled test]"
  # And the restriction must be IN the published command, not merely beside it in prose. A pathspec the
  # document only describes is an adjective; this is the leg that would have caught that. Both legs are
  # bound to the LINE that makes the claim -- the diff invocation, and the assignment that fills its
  # pathspec -- never to the word appearing somewhere in the file: a leg keyed on a word is satisfied by
  # any prose that happens to use it, which is the shape this protocol says to distrust first.
  DIFFL70="$(grep -F 'git diff <merge-base> -U0' "$VFY70" | head -1)"
  TSETL70="$(grep -F 'TESTS="$(' "$VFY70" | head -1)"
  [ -n "$DIFFL70" ] || a7_70="$a7_70 [the published command has no -U0 diff stage, so it cannot carry hunk headers]"
  printf '%s' "$DIFFL70" | grep -qF -- '-- $TESTS' \
    || a7_70="$a7_70 [the published diff stage carries no pathspec, so it reads files the leg is not entitled to]"
  [ -n "$TSETL70" ] || a7_70="$a7_70 [the published command never builds the file set its pathspec names]"
  printf '%s' "$TSETL70" | grep -qF 'TEST_RE' \
    || a7_70="$a7_70 [the pathspec is not derived from the brake's TEST_RE, so what counts as a test is stated twice]"
  [ -z "$a7_70" ] && ok "A7 the skip-marker leg reports a disabled test with its file and line" \
                  || bad "A7 the skip-marker leg reports a disabled test with its file and line ($a7_70)"

  # O3 -- the property that keeps the protocol, the skill and this suite committable with the leg live.
  o3_70=""
  for p70 in $(printf '%s' "$ALT70" | tr '|' '\n'); do
    printf '%s' "$p70" | grep -qE "$p70" 2>/dev/null && o3_70="$o3_70 [$p70 matches itself]"
  done
  [ -z "$o3_70" ] && ok "O3 no skip-marker pattern is an instance of itself" \
                  || bad "O3 no skip-marker pattern is an instance of itself ($o3_70)"

  # A10 -- one declaration (D3). The skill must name the leg and route, and restate no marker: a second
  # copy of eleven patterns is the drift this criterion exists to make impossible.
  a10_70=""
  for p70 in $(printf '%s' "$ALT70" | tr '|' '\n'); do
    grep -qF "$p70" "$SKL70" && a10_70="$a10_70 [the skill restates $p70]"
  done
  grep -qF "$ALT70" "$SKL70" && a10_70="$a10_70 [the skill carries the whole alternation]"
  [ -z "$a10_70" ] && ok "A10 the marker set has exactly one declaration and the skill routes to it" \
                   || bad "A10 the marker set has exactly one declaration and the skill routes to it ($a10_70)"

  # A8 -- the leg is stated in the protocol AND performed by the command. This is the discovery this task
  # was handed: the skill does not carry the provenance grep beside which the leg sits, so a leg stated
  # only in the protocol is a leg that runs on the fallback path alone.
  # EVERY leg below is bound to the BULLET's own text, never to the step that contains it. Asserted over
  # the step, all three passed on the pre-change file: awk ranges include their terminator, so step 5's
  # "Skip it for" supplied `skip`; step 4 already said "checks from the protocol"; and its own opening
  # sentence already carried the tick. The row was green with the bullet deleted -- a conformance row
  # answered entirely by text that was already there is the defect this task exists to make visible.
  STEP70="$(awk '/^4\. \*\*Criterion audit/,/^5\. /' "$SKL70")"
  BUL70="$(printf '%s\n' "$STEP70" | grep -F 'Skip-marker grep')"
  a8_70=""
  if [ -z "$BUL70" ]; then
    a8_70="$a8_70 [the criterion audit step carries no skip-marker bullet]"
  else
    printf '%s' "$BUL70" | grep -qiE 'switches a test off|disabl' \
      || a8_70="$a8_70 [the bullet does not say what the leg looks for]"
    printf '%s' "$BUL70" | grep -qiE 'test file|counts as a test' \
      || a8_70="$a8_70 [the bullet does not carry the test-file restriction]"
    printf '%s' "$BUL70" | grep -qF '~/.claude/ai-flow/protocols/verify.md' \
      || a8_70="$a8_70 [it routes to no INSTALLED path, so an adopter following it reaches nothing]"
    printf '%s' "$BUL70" | grep -qF '❌' || a8_70="$a8_70 [it does not say a hit holds the gate]"
  fi
  [ -z "$a8_70" ] && ok "A8 the verify command performs the skip-marker leg the protocol declares" \
                  || bad "A8 the verify command performs the skip-marker leg the protocol declares ($a8_70)"
fi

# A9 -- the one sanctioned overwrite the rail collides with (D5). A negative check with a positive leg:
# the parenthetical must be gone AND the step must say what a replan does instead.
RG70="$(awk '/^## Replan Gate/{f=1;next} f&&/^## /{exit} f' "$EXE70" | grep -F 'plan.md')"
a9_70=""
printf '%s' "$RG70" | grep -qiE 'authorized overwrite|authorised overwrite' \
  && a9_70="$a9_70 [the Replan Gate still calls it an authorized overwrite]"
printf '%s' "$RG70" | grep -qiE 'Artifact Check does not apply' \
  && a9_70="$a9_70 [it still exempts replans from the Artifact Check]"
printf '%s' "$RG70" | grep -qiE 'amend' \
  || a9_70="$a9_70 [it does not say a replan amends the plan artifact]"
[ -z "$a9_70" ] && ok "A9 a replan amends the plan artifact and no document says otherwise" \
                || bad "A9 a replan amends the plan artifact and no document says otherwise ($a9_70)"

# The step with no criterion, justified in plan.md as technical necessity: the strictest rule in the
# engine is silent on the shape rail (b) catches, so the audit would report what Execute permits.
FC70="$(awk '/^### Conformance Contracts Exception/,/^## /{print}' "$EXE70")"
printf '%s' "$FC70" | grep -qiE 'switch(ing)? .{0,12}off|disabl|skip' \
  && ok "the frozen-contract list names switching a stub off" \
  || bad "the frozen-contract list names switching a stub off"

# O4 -- the prose stops carrying the two rules alone. Each home must name the mechanism that now
# enforces it, and each must state which installs the route reaches: the manual is now refreshed
# unconditionally on every init and update and drift-compared like any other engine file, so a route
# that says it reaches every install is now a true promise, not a false one.
ACB70="$(awk '/^### Artifact Check Before Create/{f=1;next} f&&/^### /{exit} f' "$MAN70")"
NVR70="$(awk '/^### Never \(hard stops\)/,/^## /{print}' "$MAN70")"
o4_70=""
printf '%s' "$ACB70" | grep -qF 'artifact-write-guard' || o4_70="$o4_70 [the Artifact Check block names no mechanism]"
printf '%s' "$ACB70" | grep -qF 'state.md' || o4_70="$o4_70 [it does not say what the rail leaves to the habit]"
printf '%s' "$NVR70" | grep -qiE 'verify|audit' || o4_70="$o4_70 [the skip-tests bullet routes nowhere]"
printf '%s' "$NVR70" | grep -qF 'artifact-write-guard' || o4_70="$o4_70 [the overwrite bullet routes nowhere]"
printf '%s' "$ACB70$NVR70" | tr -s ' \n' '  ' | grep -qiE 'manual now reaches every install|every adopter|refreshed (on both|unconditionally)' \
  || o4_70="$o4_70 [neither route states which installs it reaches]"
[ -z "$o4_70" ] && ok "O4 the manual routes both rules to their mechanisms and states which installs it reaches" \
                || bad "O4 the manual routes both rules to their mechanisms and states which installs it reaches ($o4_70)"
