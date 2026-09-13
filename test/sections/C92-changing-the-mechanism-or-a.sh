# ---------------------------------------------------------------------------------------------------
# C92 -- changing the mechanism or a context file's structure is a declared act, and a hook rails it.
#
# ============================== THIS BLOCK IS PARTIAL. READ THIS FIRST. ==============================
# What it measures WELL: the guard's behaviour. Thirteen mutations of context-structure-guard.py were run
# against this block and every one turned a row red naming its own claim -- the fence and nano branches,
# the Write/content branch, replace_all, the judged set and its exclusion, tool_name jurisdiction, the
# ladder's single implementation, the unlistable ledger, the key spent late at all five refusals, the
# mechanism arm's two directions, and the two readers' agreement. Trust those rows.
#
# What it measures BADLY: ITSELF. Four verify rounds found the same defect five times -- a leg satisfied
# by something other than the fact it names -- and the fifth instance sat inside the fix for the fourth.
# The cause is structural: the self-judging rows (S1, S4, O2, O3) assert over this file's own text, so a
# leg written carelessly answers itself. Known hollow or weak TODAY, confirmed by mutation, left in place
# deliberately rather than patched a fifth time:
#
#   * S1's probe-invocation leg is single-quoted and unescaped, and the slice it greps contains that very
#     line -- so it matches itself and is green whether or not the probe ever runs. Nothing else binds
#     O2's tool_name evidence to a real `hookcall`.
#   * The three `sed` region-excisions (S1 x2, O3 x1) FAIL GREEN when an end anchor drifts: nothing
#     asserts the excised region was bounded, so an anchor that stops matching silently empties the sweep.
#   * S1's sweep is keyed on two variable NAMES, not on the shape its message claims -- blind to the
#     multi-line pipeline idiom and to any slice under a third name.
#   * S5's five keyed legs inherit their key from A6 thirty-odd lines above and never re-declare it.
#
# A leg here going green is therefore evidence about the guard and NOT evidence about this block. Repairing
# it needs a different approach to self-judging assertions than "write another grep", which is what the
# fifth attempt would have been; it left this task at the close and lives in the Icebox.
# =====================================================================================================
#
# Generated in the Conform phase from understand.md's Verifiable Criteria; every row is RED until the
# rail and the two keys' writers exist. Three properties shape the block. First, the failure this rail
# can introduce is SILENCE -- a guard that stood aside and a guard that judged and passed look identical
# from outside -- so every OPENING row is paired with a refusing control that no absent mechanism can
# satisfy. Second, the payload rows feed the shape production actually sends: `tool_input` carrying the
# tool's own fields, siblings included, never a fixture trimmed to whatever the guard happens to read.
# Third, the prose rows use the suite's canonical adjacency predicate `insent()` and add no fourth
# spelling of it -- except where the claim is a path, whose dots split a sentence and which is therefore
# matched with a literal grep.
echo ""
echo "== C92: changing the mechanism or a context file's structure is a declared act =="

T92="$(mkbox)" || fatal 'C92 fixtures'

GUARD92="$HK/context-structure-guard.py"
REG92="$HK/settings.hooks.json"
RDM92="$HK/README.md"
BLG92="$ROOT/global/protocols/backlog.md"
PLN92="$ROOT/global/protocols/plan.md"
EXE92="$ROOT/global/protocols/execute.md"
INST92='~/.claude/ai-flow/scripts/context-check.sh'   # the path the measure installs to, the one form that runs

# This block owns no invocation helper of its own: `hookcall` and `hookraw` sit in the shared preamble
# beside `mkproj` and `insent`, and C92 was the third near-copy of that pair. O2 below asserts this block
# reaches the hook through them and never by hand.

# This block's own text, read ONCE. It was read twice -- `SELFB92` for O2 inside the fence, `SELF92` for
# O3/S1/S4 after it -- from the identical `sed` range, and the duplicate was not a tidiness question: both
# definition lines sit INSIDE the region the slice holds, so S1's "the slices must still be slices" leg had
# two matches and needed one. Either could be broken and the sibling kept the row green, in the row whose
# whole name is that no leg is satisfied by its own source text. Hoisted above the fence because O2 needs
# it inside and the others need it after.
SELF92="$(sed -n '/^# C92 -- changing the mechanism/,$p' "$SECTION")"

if [ "$PY3" = 0 ]; then
  echo "  [skip] C92 rail checks (python3 unavailable)"
elif [ ! -f "$GUARD92" ]; then
  bad "A1 the guard lets content through (no $GUARD92)"
  bad "A2 a structural write with no key is refused, and the refusal names both keys (no hook)"
  bad "A3 the sanctioned moment opens the rail (no hook)"
  bad "A4 the declared decision opens the rail (no hook)"
  bad "A5 the mechanism's own two files have no content half (no hook)"
  bad "A6 creating a context file is the strongest structural act (no hook)"
  bad "A7 no task resolved means no rail (no hook)"
  bad "A8 unreadable input is a refusal that names the file (no hook)"
  bad "O1 the refusal text is REACHED, and it names both keys (no hook)"
  bad "O2 every leg feeds the payload shape production sends (no hook)"
  bad "P1-P8 a malformed payload never tracebacks, and the control still refuses (no hook)"
  # The eight rows added after this list was written, and left out of it. Every one lives in the branch
  # below and so reported NOTHING at all when the hook was absent -- not a failure, an absence, which is
  # the one state a suite must never have: the run is shorter and says nothing about why. It was contained
  # only because the eleven above still fail, and "contained" is not a property worth relying on in the
  # list whose whole job is to say what could not be checked.
  bad "R2 a Write against an existing context file is judged on its content (no hook)"
  bad "R3 every structural subject is refused, not only a title added (no hook)"
  bad "R4 the judged set has a negative control (no hook)"
  bad "R5 the guard stands aside on any tool but Edit and Write (no hook)"
  bad "R6 every payload field the verdict needs has its unusable form (no hook)"
  bad "S2 every branch the guard's verdict depends on has a fixture (no hook)"
  bad "S3 the guard's reader and the measure's reader agree (no hook)"
  bad "S5 a key opens a verdict, never the absence of one (no hook)"
else
  # The fixture: a project whose own .ai-flow/ holds a member of the measure's default set, and one task
  # sheet claiming the branch the repo is on.
  P92="$T92/proj"; mkproj "$P92" main
  mkdir -p "$P92/.ai-flow/artifacts/T-XXX" "$P92/.ai-flow/steering" "$P92/global/protocols" "$P92/scripts"
  SHEET92="$P92/.ai-flow/artifacts/T-XXX/state.md"
  DG92="$P92/.ai-flow/decisions-global.md"
  setsheet92() { printf 'phase: **%s**\nbranch: main\n%s' "$1" "${2:-}" > "$SHEET92"; }
  setdg92_at() {  # the judged-file shape, written wherever a row needs it
    printf '# Global Decisions\n\n## Nano\n\n- **Alpha** - one decision\n\n## Alpha\n\nsomething decided here\n' > "$1"
  }
  setdg92() { setdg92_at "$DG92"; }
  setsheet92 EXECUTE; setdg92

  # The two writes every opening row is measured against. CONTENT rewords a rule inside a section;
  # STRUCTURAL adds a heading. They differ in nothing else, which is what makes the pair a measurement
  # rather than two unrelated fixtures.
  CONTENT92='"old_string":"something decided here","new_string":"something else decided here"'
  STRUCT92='"old_string":"## Alpha","new_string":"## Beta\n\nplaceholder\n\n## Alpha"'

  # A1 -- content passes, and it passes with NEITHER key on the sheet. A row that only passed while a key
  # was present would be testing the key, not the content/structure boundary this rail is built on.
  out92="$(hookcall "$GUARD92" "$P92" "$DG92" Edit ",$CONTENT92")"; rc92=$?
  a1_92=""
  [ "$rc92" = 0 ] || a1_92="$a1_92 (exit $rc92)"
  [ -z "$out92" ] || a1_92="$a1_92 (it said: $(printf '%s' "$out92" | head -1))"
  [ -z "$a1_92" ] && ok "A1 the guard lets content through" \
                  || bad "A1 the guard lets content through:$a1_92"

  # A2 -- the same file, the same tool, one heading added: refused, and the refusal carries all three
  # things a reader needs. Each asserted separately; a refusal naming one key sends the reader to a door
  # that may be shut.
  out92="$(hookcall "$GUARD92" "$P92" "$DG92" Edit ",$STRUCT92")"; rc92=$?
  a2_92=""
  [ "$rc92" = 2 ] || a2_92="$a2_92 (exit $rc92)"
  printf '%s' "$out92" | grep -qF 'decisions-global.md' || a2_92="$a2_92 (the file is not named)"
  printf '%s' "$out92" | grep -qF 'Beta'                || a2_92="$a2_92 (what changed is not named)"
  printf '%s' "$out92" | grep -qF 'ARCHIVE'             || a2_92="$a2_92 (key 1 is not named)"
  printf '%s' "$out92" | grep -qF 'structure: context'  || a2_92="$a2_92 (key 2 is not named)"
  [ -z "$a2_92" ] && ok "A2 a structural write with no key is refused, and the refusal names both keys" \
                  || bad "A2 a structural write with no key is refused, and the refusal names both keys:$a2_92"
  REFUSAL92="$out92"   # O1's evidence: a text that was REACHED, not one grepped out of the source

  # A3 / A4 -- each key opens the rail over the write A2 just refused, changing the SHEET and nothing
  # else. Paired with A2 by construction: an opening row on its own is satisfied by a guard that never
  # refuses anything.
  setsheet92 ARCHIVE
  out92="$(hookcall "$GUARD92" "$P92" "$DG92" Edit ",$STRUCT92")"; rc92=$?
  [ "$rc92" = 0 ] && ok "A3 the sanctioned moment opens the rail" \
                  || bad "A3 the sanctioned moment opens the rail (exit $rc92: $(printf '%s' "$out92" | head -1))"

  setsheet92 EXECUTE 'structure: context
'
  out92="$(hookcall "$GUARD92" "$P92" "$DG92" Edit ",$STRUCT92")"; rc92=$?
  [ "$rc92" = 0 ] && ok "A4 the declared decision opens the rail" \
                  || bad "A4 the declared decision opens the rail (exit $rc92: $(printf '%s' "$out92" | head -1))"
  setsheet92 EXECUTE

  # A5 -- the mechanism's own two files have no content half, so the write that changes NOTHING
  # structural is still refused. Both asserted; one row covering "either" lets one of them fall out.
  a5_92=""
  printf 'x\n' > "$P92/global/protocols/context.md"
  printf 'x\n' > "$P92/scripts/context-check.sh"
  for f92 in "$P92/global/protocols/context.md" "$P92/scripts/context-check.sh"; do
    out92="$(hookcall "$GUARD92" "$P92" "$f92" Write ',"content":"x\n"')"; rc92=$?
    [ "$rc92" = 2 ] || a5_92="$a5_92 [${f92##*/} exit $rc92]"
    printf '%s' "$out92" | grep -qF 'structure: context' || a5_92="$a5_92 [${f92##*/} names no key]"
  done
  # And the OPENING half, which nothing held. A3/A4 exist because an opening row alone is satisfied by a
  # guard that never refuses; this is the exact converse -- a refusing row alone is satisfied by a guard
  # that refuses ALWAYS. Deleting `if keyed: sys.exit(0)` from the is_mechanism arm left every row in this
  # block green while making the rulebook and the measure permanently unwritable, which is the branch this
  # engine's own close edits `protocols/context.md` through. Both files separately, for A5's own reason.
  setsheet92 ARCHIVE
  for f92 in "$P92/global/protocols/context.md" "$P92/scripts/context-check.sh"; do
    out92="$(hookcall "$GUARD92" "$P92" "$f92" Write ',"content":"x\n"')"; rc92=$?
    [ "$rc92" = 0 ] || a5_92="$a5_92 [${f92##*/} is refused at key 1 (exit $rc92), so the mechanism is unwritable by anyone]"
  done
  setsheet92 EXECUTE
  [ -z "$a5_92" ] && ok "A5 the mechanism's own two files have no content half" \
                  || bad "A5 the mechanism's own two files have no content half:$a5_92"

  # A6 -- creation, and its other half: the moment the engine itself creates a steering file is the
  # archive checklist's first step, so key 1 must open it or the rail refuses the close it was built to
  # serve.
  NEW92="$P92/.ai-flow/steering/newdomain.md"
  a6_92=""
  out92="$(hookcall "$GUARD92" "$P92" "$NEW92" Write ',"content":"# New\n\n## Nano\n\n- **A** - x\n\n## A\n\nrule\n"')"; rc92=$?
  [ "$rc92" = 2 ] || a6_92="$a6_92 [creating with no key exits $rc92]"
  setsheet92 ARCHIVE
  out92="$(hookcall "$GUARD92" "$P92" "$NEW92" Write ',"content":"# New\n\n## Nano\n\n- **A** - x\n\n## A\n\nrule\n"')"; rc92=$?
  [ "$rc92" = 0 ] || a6_92="$a6_92 [creating inside the checklist's own window exits $rc92]"
  [ -z "$a6_92" ] && ok "A6 creating a context file is the strongest structural act" \
                  || bad "A6 creating a context file is the strongest structural act:$a6_92"

  # S5 -- a key opens a VERDICT, never the absence of one. The leg above used to pass at a key
  # short-circuit sitting before existence was ever tested, so it said nothing about the creation branch:
  # a keyed run left by the same exit whether or not it reached it, and no exit code could tell the two
  # apart. That is why the criterion as minted was undeliverable and this row replaces it. The key is now
  # spent at the verdict, which makes the branch observable through the one case where reaching it
  # changes the answer -- a key present and the judged file unreadable, which exited 0 before. PAIRED
  # with the same fixture readable, or the row is satisfied by a guard that refuses everything.
  s5_92=""
  printf '# New\n\n## Nano\n\n- **A** - x\n\n## A\n\nrule\n' > "$NEW92"
  chmod 000 "$NEW92" 2>/dev/null
  if [ -r "$NEW92" ]; then
    echo "  [skip] S5 a key over an unreadable file (this user reads a 000 file)"
  else
    out92="$(hookcall "$GUARD92" "$P92" "$NEW92" Write ',"content":"# New\n"')"; rc92=$?
    [ "$rc92" = 2 ] || s5_92="$s5_92 [a key waves through a file the guard cannot read: exit $rc92]"
    printf '%s' "$out92" | grep -qF 'newdomain.md' || s5_92="$s5_92 [the unreadable file is not named]"
  fi
  chmod u+rw "$NEW92" 2>/dev/null
  out92="$(hookcall "$GUARD92" "$P92" "$NEW92" Write ',"content":"# New\n\n## Nano\n\n- **B** - y\n\n## B\n\nrule\n"')"; rc92=$?
  [ "$rc92" = 0 ] || s5_92="$s5_92 [the same fixture readable exits $rc92, so the row above is a guard that refuses everything]"
  rm -f "$NEW92"
  # The other FOUR key-spending refusals. One of five sites carried a keyed fixture -- the before_text
  # read above -- and the three payload sites and the stat site all ran at EXECUTE, this row's own
  # `setsheet92 EXECUTE` being what put them there. So a key short-circuit reinserted anywhere between
  # the file read and the payload branch restored D12's defect for content, old_string and replace_all
  # with no row going red, and this row's title was asserted for one input class of five. The fixtures
  # are R6's and A8's; only the sheet changes, which is A3/A4's construction against A2.
  s5keyed92() {  # $1 = label, $2 = extra tool_input JSON, $3 = tool
    local out rc
    out="$(hookcall "$GUARD92" "$P92" "$DG92" "$3" ",$2")"; rc=$?
    [ "$rc" = 2 ] || s5_92="$s5_92 [with a key, $1 exits $rc -- the key opened the absence of a verdict]"
    printf '%s' "$out" | grep -qF 'decisions-global.md' || s5_92="$s5_92 [with a key, $1 does not name the file]"
  }
  s5keyed92 "a non-string content"      '"content":7'                                              Write
  s5keyed92 "a non-boolean replace_all" '"old_string":"a","new_string":"b","replace_all":"yes"'     Edit
  s5keyed92 "an absent new_string"      '"old_string":"something decided here"'                    Edit
  # And the stat site: a path that cannot be resolved but lexically sits in the judged set.
  ln -s s5-loop-b.md "$P92/.ai-flow/steering/s5-loop-a.md" 2>/dev/null
  ln -s s5-loop-a.md "$P92/.ai-flow/steering/s5-loop-b.md" 2>/dev/null
  out92="$(hookcall "$GUARD92" "$P92" "$P92/.ai-flow/steering/s5-loop-a.md" Edit ",$STRUCT92")"; rc92=$?
  [ "$rc92" = 2 ] || s5_92="$s5_92 [with a key, an unresolvable path inside the judged set exits $rc92]"
  rm -f "$P92/.ai-flow/steering/s5-loop-a.md" "$P92/.ai-flow/steering/s5-loop-b.md"
  setsheet92 EXECUTE
  [ -z "$s5_92" ] && ok "S5 a key opens a verdict, never the absence of one" \
                  || bad "S5 a key opens a verdict, never the absence of one ($s5_92)"

  # A7 -- the deliberate hole, measured on a fixture that OTHERWISE REFUSES. Without that pairing the row
  # cannot tell silence-by-design from a guard that is simply broken.
  mv "$SHEET92" "$SHEET92.parked"
  out92="$(hookcall "$GUARD92" "$P92" "$DG92" Edit ",$STRUCT92")"; rc92=$?
  [ "$rc92" = 0 ] && ok "A7 no task resolved means no rail" \
                  || bad "A7 no task resolved means no rail (exit $rc92)"
  mv "$SHEET92.parked" "$SHEET92"

  # A8 -- three unreadable inputs, each a refusal that NAMES what could not be read. Never exit 0: an
  # input nobody could read has not been found clean, and the two must not leave by the same exit.
  a8_92=""
  chmod 000 "$SHEET92" 2>/dev/null
  if [ -r "$SHEET92" ]; then
    echo "  [skip] A8 unreadable sheet (this user reads a 000 file)"
  else
    out92="$(hookcall "$GUARD92" "$P92" "$DG92" Edit ",$STRUCT92")"; rc92=$?
    [ "$rc92" = 2 ] || a8_92="$a8_92 [an unreadable sheet exits $rc92]"
    printf '%s' "$out92" | grep -qF 'state.md' || a8_92="$a8_92 [the unreadable sheet is not named]"
  fi
  chmod u+rw "$SHEET92" 2>/dev/null
  chmod 000 "$DG92" 2>/dev/null
  if [ -r "$DG92" ]; then
    echo "  [skip] A8 unreadable target (this user reads a 000 file)"
  else
    out92="$(hookcall "$GUARD92" "$P92" "$DG92" Edit ",$STRUCT92")"; rc92=$?
    [ "$rc92" = 2 ] || a8_92="$a8_92 [an unreadable target exits $rc92]"
    printf '%s' "$out92" | grep -qF 'decisions-global.md' || a8_92="$a8_92 [the unreadable target is not named]"
  fi
  chmod u+rw "$DG92" 2>/dev/null
  # The mirror of the sibling rail's bug: a path that cannot be resolved but LEXICALLY sits in the judged
  # set. Where that rail judges what is outside a directory this one judges what is inside, so the same
  # code that correctly passes there is a silent hole here.
  ln -s loop-b.md "$P92/.ai-flow/steering/loop-a.md" 2>/dev/null
  ln -s loop-a.md "$P92/.ai-flow/steering/loop-b.md" 2>/dev/null
  out92="$(hookcall "$GUARD92" "$P92" "$P92/.ai-flow/steering/loop-a.md" Edit ",$STRUCT92")"; rc92=$?
  [ "$rc92" = 2 ] || a8_92="$a8_92 [an unresolvable path inside the judged set exits $rc92, where it must refuse]"
  rm -f "$P92/.ai-flow/steering/loop-a.md" "$P92/.ai-flow/steering/loop-b.md"
  # The ledger directory itself unlistable -- the state the ladder reads from, rather than any one file
  # in it. `Path.glob` swallows that fault inside its own walk and answers with an empty match, so the
  # rail read it as a checkout with no task open, which is a PASSING exit; the `except OSError` written
  # around the glob was unreachable for the very fault it named, and looked like the remedy.
  chmod 000 "$P92/.ai-flow/artifacts" 2>/dev/null
  if [ -r "$P92/.ai-flow/artifacts" ]; then
    echo "  [skip] A8 unlistable ledger (this user lists a 000 directory)"
  else
    out92="$(hookcall "$GUARD92" "$P92" "$DG92" Edit ",$STRUCT92")"; rc92=$?
    [ "$rc92" = 2 ] || a8_92="$a8_92 [an unlistable ledger exits $rc92, a passing exit over a state nobody read]"
    printf '%s' "$out92" | grep -qF 'artifacts' || a8_92="$a8_92 [the unlistable ledger is not named]"
  fi
  chmod u+rwx "$P92/.ai-flow/artifacts" 2>/dev/null
  # The refusal SENTENCE, which nothing held. Two claims and both were false: the template read "whether
  # this write changes {what}" while six of seven callers passed a clause that itself began "this write
  # changes", printing "whether this write changes this write changes a context file's structure is
  # unknown"; and the one fixed remedy named `chmod` at the three payload call sites, where the file had
  # opened perfectly well and the payload was what the guard could not use. Advice that reads as a
  # diagnosis and is a wrong one.
  out92="$(hookcall "$GUARD92" "$P92" "$DG92" Edit ',"old_string":"## Alpha"')"; rc92=$?
  [ "$rc92" = 2 ] || a8_92="$a8_92 [a payload with no new_string exits $rc92]"
  printf '%s' "$out92" | grep -qF 'decisions-global.md' || a8_92="$a8_92 [the payload fault does not name the file]"
  # A COUNT of the clause, not a search for one spelling of the doubling. The first build of this leg
  # grepped for the literal `this write changes this write`, which is what the OLD template produced
  # from the OLD callers; restoring the template alone produces `this write changes whether this write
  # changes` and the leg stayed green. A leg that only catches the exact text someone already wrote
  # catches nothing anybody will write next.
  D92="$(printf '%s' "$out92" | grep -oF 'this write changes' | grep -c .)"
  [ "${D92:-0}" -le 1 ] || a8_92="$a8_92 [the refusal repeats its own clause $D92 times]"
  printf '%s' "$out92" | grep -qi 'chmod' \
    && a8_92="$a8_92 [a payload fault is answered with a file-permission remedy]"
  [ -z "$a8_92" ] && ok "A8 unreadable input is a refusal that names the file" \
                  || bad "A8 unreadable input is a refusal that names the file:$a8_92"

  # O1 -- the refusal text was REACHED. A grep of the hook's source would pass over a branch no input can
  # arrive at, which is the whole failure this row is written against; REFUSAL92 is A2's own output.
  o1_92=""
  [ -n "$REFUSAL92" ] || o1_92="$o1_92 [no refusal was produced]"
  printf '%s' "$REFUSAL92" | grep -qF 'ARCHIVE'            || o1_92="$o1_92 [key 1 absent from the reached text]"
  printf '%s' "$REFUSAL92" | grep -qF 'structure: context' || o1_92="$o1_92 [key 2 absent from the reached text]"
  printf '%s' "$REFUSAL92" | grep -qF "$SHEET92"           && o1_92="$o1_92 [the sheet is named by absolute path, which is not what the operator reads]"
  [ -z "$o1_92" ] && ok "O1 the refusal text is REACHED, and it names both keys" \
                  || bad "O1 the refusal text is REACHED, and it names both keys:$o1_92"

  # P1-P8 -- a malformed payload never tracebacks. Exit 1 is the uncaught raise, which PreToolUse treats
  # as a NON-BLOCKING error: the write goes through with a stack trace printed over it, which is the one
  # outcome that is worse than either verdict.
  p_92=""
  pmal92() {  # $1 = what the shape is, $2 = the payload
    hookraw "$GUARD92" "$2" >/dev/null 2>&1; local rc=$?
    case "$rc" in 0|2) ;; *) p_92="$p_92 [$1 exits $rc]" ;; esac
  }
  pmal92 "not JSON at all"          'not json'
  pmal92 "a non-object payload"     '[1,2,3]'
  pmal92 "no tool_input"            "{\"cwd\":\"$P92\",\"tool_name\":\"Edit\"}"
  pmal92 "tool_input of a bad type" "{\"cwd\":\"$P92\",\"tool_name\":\"Edit\",\"tool_input\":7}"
  pmal92 "file_path of a bad type"  "{\"cwd\":\"$P92\",\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":7}}"
  pmal92 "cwd of a bad type"        "{\"cwd\":9,\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$DG92\"}}"
  # An Edit whose old_string is empty: a usable TYPE carrying an unusable value. There is no occurrence
  # to splice, so no "after" exists, and answering anything about it answers about a write nobody made.
  out92="$(hookcall "$GUARD92" "$P92" "$DG92" Edit ',"old_string":"","new_string":"x"')"; rc92=$?
  [ "$rc92" = 2 ] || p_92="$p_92 [an empty old_string exits $rc92, where the verdict has no input]"
  # The control, and the seven above are worth nothing without it: a guard that exited 0 on every input
  # would satisfy all of them. The same fixture, well-formed, must still refuse.
  out92="$(hookcall "$GUARD92" "$P92" "$DG92" Edit ",$STRUCT92")"; rc92=$?
  [ "$rc92" = 2 ] || p_92="$p_92 [the well-formed control exits $rc92, so the seven rows above prove nothing]"
  [ -z "$p_92" ] && ok "P1-P8 a malformed payload never tracebacks, and the control still refuses" \
                 || bad "P1-P8 a malformed payload never tracebacks, and the control still refuses:$p_92"

  # O2 -- every leg feeds the shape production sends. The direction is unchanged and it is what the
  # frozen row states: the number of hand-rolled payloads in this block that bypass the shared helper
  # must be ZERO. What changed is where the helper lives -- `hookcall`/`hookraw` are in the shared
  # preamble now, so the count that used to say "exactly two sites" says "no site of its own" instead.
  # Both halves are asserted, because either alone is satisfied by the defect: a block that reaches the
  # hook directly, and a block that builds its own payload object and hands it to the shared helper.
  o2_92=""
  N92="$(printf '%s\n' "$SELF92" | grep -c 'python3 "\$GUARD92"')"
  [ "$N92" = 0 ] || o2_92="$o2_92 [$N92 site(s) reach the hook directly instead of through the shared helper]"
  # The character class is load-bearing and not decoration: written bare, this pattern's own text is an
  # instance of it and the leg fails over itself. Same rule the block header states for the skip markers.
  H92="$(printf '%s\n' "$SELF92" | grep -c "printf '[{]")"
  [ "$H92" = 0 ] || o2_92="$o2_92 [$H92 hand-rolled payload(s), which is how a leg comes to pass against a fixture trimmed to whatever the guard happens to read]"
  # And the helper it now depends on must still carry the field this row exists for: a shared helper that
  # stopped emitting `tool_name` would leave every leg in this block feeding a shape production never sends.
  # Asked BEHAVIOURALLY, by pointing the helper at a probe that prints back what it was handed. The
  # previous form greped this suite file for the field name, and that grep's own source line contained the
  # field name -- so the leg was green whatever the helper emitted, which two mutations demonstrated:
  # renaming and then deleting the field each turned eleven other rows red while this one stayed green.
  # A leg that cannot fail is the defect this whole block exists to catch, one level up.
  PROBE92="$T92/echo-payload.py"
  printf 'import sys\nsys.stdout.write(sys.stdin.read())\n' > "$PROBE92"
  SEEN92="$(hookcall "$PROBE92" "$P92" "$DG92" Edit ",$STRUCT92")"
  printf '%s' "$SEEN92" | grep -q '"tool_name":"Edit"' \
    || o2_92="$o2_92 [the shared helper does not emit tool_name -- it built: $SEEN92]"
  # And the evidence above must STAY behavioural. `S1` asserts that from the outside, over this block's
  # text; this leg asserts it from the inside, over the value: what was just matched has to be a payload
  # the helper actually built, which is a thing no source slice can be. A slice is a copy of this file
  # and therefore always contains the field name; a payload is empty unless `hookcall` ran.
  [ -n "$SEEN92" ] && [ "$SEEN92" != "$SELF92" ] \
    || o2_92="$o2_92 [the tool_name evidence is not a captured payload, so the leg reads its own source]"

  # ---- R2-R6: what Verify proved the block was not measuring -----------------------------------
  # Three of these are keyed to a mutation the Verify prover RAN and the suite survived. Each therefore
  # has a known falsification, and a row that does not go red under its own mutation is not delivered
  # whatever its assertions say.

  # R2 -- the OTHER producer. Every row above that reaches the signature comparison is an Edit: the two
  # Write rows refuse earlier, one at the mechanism arm and one at the non-existence arm, so
  # `after_text = tool_input.get('content')` was dead under the suite. A Write is a full replacement --
  # the one shape that can drop the index, reorder every section and rewrite every title in one call.
  # Falsification: replacing the Write branch with `after_text = before_text` must turn this red.
  r2_92=""
  W_STRUCT92='"content":"# Global Decisions\n\n## Nano\n\n- **Alpha** - one decision\n\n## Beta\n\nplaceholder\n\n## Alpha\n\nsomething decided here\n"'
  W_CONTENT92='"content":"# Global Decisions\n\n## Nano\n\n- **Alpha** - one decision\n\n## Alpha\n\nsomething else decided here\n"'
  out92="$(hookcall "$GUARD92" "$P92" "$DG92" Write ",$W_STRUCT92")"; rc92=$?
  [ "$rc92" = 2 ] || r2_92="$r2_92 [a structural Write on an existing context file exits $rc92, not 2]"
  printf '%s' "$out92" | grep -qF 'Beta' || r2_92="$r2_92 [the Write refusal does not name what changed]"
  # The control is what makes the row a measurement rather than a guard that refuses every Write.
  out92="$(hookcall "$GUARD92" "$P92" "$DG92" Write ",$W_CONTENT92")"; rc92=$?
  [ "$rc92" = 0 ] || r2_92="$r2_92 [a content-only Write exits $rc92, so the Write arm refuses on presence rather than on signature]"
  [ -z "$r2_92" ] && ok "R2 a Write against an existing context file is judged on its content" \
                  || bad "R2 a Write against an existing context file is judged on its content ($r2_92)"

  # R3 -- every structural SUBJECT, not only "a title added". The criterion names three; the block
  # exercised one, so the nano half of signature() and four of five describe() branches were unreachable.
  # Falsification: `signature()` returning `titles, None` must turn this red.
  r3_92=""
  r3case92() {  # $1 = label, $2 = old_string, $3 = new_string
    local out rc
    out="$(hookcall "$GUARD92" "$P92" "$DG92" Edit ",\"old_string\":\"$2\",\"new_string\":\"$3\"")"; rc=$?
    [ "$rc" = 2 ] || r3_92="$r3_92 [$1 exits $rc, not 2]"
  }
  r3case92 "a section removed"        '## Alpha\n\nsomething decided here\n' ''
  r3case92 "a nano bullet altered"    '- **Alpha** - one decision'          '- **Alpha** - two decisions'
  # The continuation join is what the nano half of the reader exists for, and nothing reached it.
  setdg92cont() {
    printf '# Global Decisions\n\n## Nano\n\n- **Alpha** - one decision\n  continued here\n\n## Alpha\n\nsomething decided here\n' > "$DG92"
  }
  setdg92cont
  r3case92 "a nano continuation line altered" '  continued here' '  continued elsewhere'
  setdg92
  # Reordering: same titles, different order -- the case a set comparison would wave through and an
  # ORDERED comparison catches. Built as a whole-file Write because a reorder is not a local splice.
  out92="$(hookcall "$GUARD92" "$P92" "$DG92" Write ',"content":"# Global Decisions\n\n## Nano\n\n- **Alpha** - one decision\n\n## Beta\n\nb\n\n## Alpha\n\nsomething decided here\n"')"; rc92=$?
  [ "$rc92" = 2 ] || r3_92="$r3_92 [adding a section by Write exits $rc92, not 2]"
  printf '# Global Decisions\n\n## Nano\n\n- **Alpha** - one decision\n\n## Alpha\n\na\n\n## Beta\n\nb\n' > "$DG92"
  out92="$(hookcall "$GUARD92" "$P92" "$DG92" Write ',"content":"# Global Decisions\n\n## Nano\n\n- **Alpha** - one decision\n\n## Beta\n\nb\n\n## Alpha\n\na\n"')"; rc92=$?
  [ "$rc92" = 2 ] || r3_92="$r3_92 [two sections TRANSPOSED exits $rc92, so the comparison is a set and not an order]"
  printf '%s' "$out92" | grep -qiF 'reorder' || r3_92="$r3_92 [a reorder is not described as one]"
  setdg92
  [ -z "$r3_92" ] && ok "R3 every structural subject is refused, not only a title added" \
                  || bad "R3 every structural subject is refused, not only a title added ($r3_92)"

  # R4 -- the negative control the block had none of. The failure direction here is OVER-refusal, which
  # does not go quiet: it blocks ordinary writes in every adopting project during every task that has
  # declared nothing -- including the writes the guard's own refusal text promises are allowed.
  # Falsification: widening DATA_FILES, or deleting the STEERING_EXCLUDED clause, must turn this red.
  r4_92=""
  mkdir -p "$P92/.ai-flow/steering/sub" "$P92/template/.ai-flow" "$P92/docs/context"
  for np92 in ".ai-flow/BACKLOG.md" ".ai-flow/STATE.md" ".ai-flow/artifacts/T-XXX/notes.md" \
              ".ai-flow/steering/pencil-design.md" ".ai-flow/steering/sub/x.md" \
              "template/.ai-flow/decisions-global.md" "docs/context/context.md" "app.txt"; do
    # The body must be one the structural edit ACTUALLY applies to. Written as 'x' first, every control
    # here exited 0 because `old_string` matched nothing -- the guard's own "the tool refuses this edit
    # anyway" arm -- so the row passed for a reason that had nothing to do with jurisdiction, and stayed
    # green under a mutation that widened the judged set. A control that cannot fail is not a control.
    setdg92_at "$P92/$np92"
    out92="$(hookcall "$GUARD92" "$P92" "$P92/$np92" Edit ",$STRUCT92")"; rc92=$?
    [ "$rc92" = 0 ] || r4_92="$r4_92 [$np92 is judged (exit $rc92) and is not this rail's]"
    [ -z "$out92" ] || r4_92="$r4_92 [$np92 drew output where the rail must be silent]"
  done
  # And the refusing side must cover BOTH members of the judged set -- only one was ever exercised.
  printf '# Product\n\n## Nano\n\n- **Alpha** - x\n\n## Alpha\n\nrule\n' > "$P92/.ai-flow/product.md"
  out92="$(hookcall "$GUARD92" "$P92" "$P92/.ai-flow/product.md" Edit ',"old_string":"## Alpha","new_string":"## Beta\n\nb\n\n## Alpha"')"; rc92=$?
  [ "$rc92" = 2 ] || r4_92="$r4_92 [product.md, the other member of the judged set, exits $rc92 and is not judged]"
  [ -z "$r4_92" ] && ok "R4 the judged set has a negative control" \
                  || bad "R4 the judged set has a negative control ($r4_92)"

  # R5 -- jurisdiction. The guard carries the tool_name check with the sibling's justification verbatim,
  # and nothing asserted it: deleting it left the suite green. The direction matters -- with the check
  # gone a Read payload falls into the Edit branch, finds no old_string, and REFUSES, so the rail would
  # block reads of the very files it protects.
  r5_92=""
  for t92 in MultiEdit NotebookEdit Read Bash; do
    out92="$(hookcall "$GUARD92" "$P92" "$DG92" "$t92" ",$STRUCT92")"; rc92=$?
    [ "$rc92" = 0 ] || r5_92="$r5_92 [$t92 exits $rc92 where the rail must stand aside]"
  done
  # The control, without which a guard that exited 0 on everything satisfies the four above.
  out92="$(hookcall "$GUARD92" "$P92" "$DG92" Edit ",$STRUCT92")"; rc92=$?
  [ "$rc92" = 2 ] || r5_92="$r5_92 [the Edit control exits $rc92, so the four rows above prove nothing]"
  [ -z "$r5_92" ] && ok "R5 the guard stands aside on any tool but Edit and Write" \
                  || bad "R5 the guard stands aside on any tool but Edit and Write ($r5_92)"

  # R6 -- every payload field the verdict needs, in its unusable form. P1-P8 accepts "0 or 2" by its own
  # frozen direction, which is the right bar for "never tracebacks" and the wrong one for "refuses and
  # names it": only the empty old_string leg asserted the refusal. These three are exit 2 AND named.
  r6_92=""
  r6case92() {  # $1 = label, $2 = extra tool_input JSON, $3 = tool
    local out rc
    out="$(hookcall "$GUARD92" "$P92" "$DG92" "$3" ",$2")"; rc=$?
    [ "$rc" = 2 ] || r6_92="$r6_92 [$1 exits $rc, where the verdict has no input]"
    printf '%s' "$out" | grep -qF 'decisions-global.md' || r6_92="$r6_92 [$1 does not name the file]"
  }
  r6case92 "a non-string content"     '"content":7'                                  Write
  r6case92 "a non-boolean replace_all" '"old_string":"a","new_string":"b","replace_all":"yes"' Edit
  r6case92 "an absent new_string"     '"old_string":"something decided here"'        Edit
  [ -z "$r6_92" ] && ok "R6 every payload field the verdict needs has its unusable form" \
                  || bad "R6 every payload field the verdict needs has its unusable form ($r6_92)"

  # S2 -- every branch the verdict depends on has a fixture. Four branches were carrying no input at all,
  # and each was proven unguarded by a mutation the suite survived: the rung-3 stop, the fence skip, the
  # HTML-comment strip, and the `replace_all` splice. A branch asserted by nothing can be deleted, and
  # three of these four were asserted only by a grep of the source that calls them.
  s2_92=""

  # (a) The rung-3 stop. This rail resolves rungs 1 and 2 ONLY: a checkout whose branch no per-task sheet
  # claims gets silence, because STATE.md is a roster and carries neither key. The fixture is a project
  # with a roster naming a task and NO sheet for it -- today silence; with the stop removed the ladder
  # reaches the roster, resolves a task, and refuses over a sheet it cannot read.
  R3P92="$T92/rung3"; mkproj "$R3P92" main
  mkdir -p "$R3P92/.ai-flow/artifacts"
  printf '# Session State\n\n| Workstream | Checkout | Task |\n|---|---|---|\n| coordinator | . | T-ZZZ |\n' \
    > "$R3P92/.ai-flow/STATE.md"
  setdg92_at "$R3P92/.ai-flow/decisions-global.md"
  out92="$(hookcall "$GUARD92" "$R3P92" "$R3P92/.ai-flow/decisions-global.md" Edit ",$STRUCT92")"; rc92=$?
  [ "$rc92" = 0 ] || s2_92="$s2_92 [a roster with no per-task sheet exits $rc92, so the rail did not stop at rung 2]"
  [ -z "$out92" ] || s2_92="$s2_92 [the rail spoke where it must be silent: $out92]"

  # (b) and (c) -- the two stripping paths. The guard reads a context file the way the measure reads it:
  # a `## ` line inside a fenced block is not a section, and neither is one inside an HTML comment. Each
  # fixture edits ONLY the disguised heading, so the signature is unchanged and the write must pass. Drop
  # either stripping path and that same edit becomes a title change, which is the falsification.
  FEN92="$P92/.ai-flow/steering/fenced.md"
  printf '# F\n\n## Nano\n\n- **A** - one\n\n## Real\n\n```\n## Inside\n```\n' > "$FEN92"
  out92="$(hookcall "$GUARD92" "$P92" "$FEN92" Edit ',"old_string":"## Inside","new_string":"## Elsewhere"')"; rc92=$?
  [ "$rc92" = 0 ] || s2_92="$s2_92 [a heading inside a fenced block is counted as a section (exit $rc92)]"
  CMT92="$P92/.ai-flow/steering/commented.md"
  printf '# C\n\n## Nano\n\n- **A** - one\n\n## Real\n\n<!--\n## Hidden\n-->\n' > "$CMT92"
  out92="$(hookcall "$GUARD92" "$P92" "$CMT92" Edit ',"old_string":"## Hidden","new_string":"## Shown"')"; rc92=$?
  [ "$rc92" = 0 ] || s2_92="$s2_92 [a heading inside an HTML comment is counted as a section (exit $rc92)]"

  # (d) The `replace_all` splice. The fixture is built so the two answers DIFFER: the first occurrence is
  # body text and the second is a heading, so honouring the flag changes a title and ignoring it does not.
  # A guard that splices one occurrence regardless exits 0 here, which is the falsification -- and the
  # existing rows could not catch it, since they test the unusable TYPE of the field and never its value.
  RPL92="$P92/.ai-flow/steering/repeated.md"
  printf '# R\n\n## Nano\n\n- **A** - one\n\n## Alpha\n\nMARK here\n\n## MARK\n\ntail\n' > "$RPL92"
  out92="$(hookcall "$GUARD92" "$P92" "$RPL92" Edit ',"old_string":"MARK","new_string":"Zed","replace_all":true')"; rc92=$?
  [ "$rc92" = 2 ] || s2_92="$s2_92 [replace_all:true exits $rc92 -- the second occurrence, which is a heading, was not spliced]"
  # Its pair: the same two occurrences with the flag absent. The tool refuses a multi-hit edit itself, so
  # the guard has no write to judge and must stand aside -- the direction the spec states and nothing held.
  out92="$(hookcall "$GUARD92" "$P92" "$RPL92" Edit ',"old_string":"MARK","new_string":"Zed"')"; rc92=$?
  [ "$rc92" = 0 ] || s2_92="$s2_92 [a multi-hit edit with no replace_all exits $rc92 instead of standing aside]"

  [ -z "$s2_92" ] && ok "S2 every branch the guard's verdict depends on has a fixture" \
                  || bad "S2 every branch the guard's verdict depends on has a fixture ($s2_92)"
  [ -z "$o2_92" ] && ok "O2 every leg feeds the payload shape production sends" \
                  || bad "O2 every leg feeds the payload shape production sends ($o2_92)"

  # S3 -- `signature()` and the measure's own reader are MEASURED to agree. The README promises the
  # question is "asked the way the measure asks it", and until now nothing asked both: the guard carries
  # a second document reader, and a second reader that drifts refuses writes the measure calls clean and
  # passes writes it calls broken. One fixture carrying every shape the two both claim to handle -- a
  # fenced block and an HTML comment each holding a decoy heading, an inline comment mid-line, and a nano
  # bullet with a continuation line -- fed to each, and the section lists compared.
  MSR92="$ROOT/global/scripts/context-check.sh"
  s3_92=""
  FIX92="$T92/parity.md"
  cat > "$FIX92" <<'PARITY92'
# Title

## Alpha

body text

```
## Fenced Decoy
```

<!--
## Commented Decoy
-->

## Beta

body <!-- ## Inline Decoy --> text

##   Gamma

the trimmed title. Both readers trim -- the guard with `.strip()`, the measure with two `sub()` calls --
and until this section existed every title in this fixture was already tight, so the trimming half of the
parity was assumed rather than compared and dropping either side left the row green.

## Nano

- **Alpha** - what alpha says
  and its continuation
- **Beta** - what beta says
PARITY92
  # The measure's reader is its own awk program, taken from the shipped script rather than retyped --
  # a copy here would be a THIRD reader, which is the defect this row exists to measure.
  AWK92="$(sed -n "/^AWK_READ='/,/^}'\$/p" "$MSR92" | sed "1s/^AWK_READ='//; \$s/'\$//")"
  if [ -z "$AWK92" ]; then
    s3_92="$s3_92 [the measure's reader could not be lifted from $MSR92]"
  else
    M3="$(awk "$AWK92" "$FIX92" | sed -n 's/^SEC [0-9]* //p')"
    MN3="$(awk "$AWK92" "$FIX92" | grep -c '^NANOLINE ')"
    # The guard's reader, called directly. Its module runs `main()` at import, which would consume this
    # process's stdin, so the call is stripped -- the one line that is not the subject of the question.
    G3="$(python3 - "$GUARD92" "$FIX92" <<'PY' 2>&1
import sys, os
src = open(sys.argv[1], encoding='utf-8').read().replace('\nmain()\n', '\n')
sys.path.insert(0, os.path.dirname(os.path.abspath(sys.argv[1])))
ns = {'__name__': 'parity_probe'}
exec(compile(src, sys.argv[1], 'exec'), ns)
titles, nano = ns['signature'](open(sys.argv[2], encoding='utf-8').read())
for t in titles:
    print(t)
print('NANOLINES', -1 if nano is None else len(nano))
PY
)"
    GN3="$(printf '%s\n' "$G3" | sed -n 's/^NANOLINES //p')"
    GT3="$(printf '%s\n' "$G3" | grep -v '^NANOLINES ')"
    [ "$GT3" = "$M3" ] \
      || s3_92="$s3_92 [the two readers disagree on the sections: the guard says '$(printf '%s' "$GT3" | tr '\n' '/')' and the measure says '$(printf '%s' "$M3" | tr '\n' '/')']"
    [ "$GN3" = "$MN3" ] \
      || s3_92="$s3_92 [they disagree on the nano block: the guard counts ${GN3:-none} lines and the measure counts $MN3]"
    # A positive control, or the two legs above are satisfied by a fixture that exercises nothing: the
    # decoys must actually have been skipped rather than never looked at.
    [ "$M3" = "$(printf 'Alpha\nBeta\nGamma')" ] \
      || s3_92="$s3_92 [the measure reads '$(printf '%s' "$M3" | tr '\n' '/')' on a fixture whose only real sections are Alpha, Beta and Gamma]"
  fi
  [ -z "$s3_92" ] && ok "S3 the guard's reader and the measure's reader agree" \
                  || bad "S3 the guard's reader and the measure's reader agree ($s3_92)"
fi
# A10 -- registration, catalogue and delivery. The matcher is asserted as the EXISTING Edit|Write group:
# a hook given a group of its own would satisfy a presence grep while running on a jurisdiction nobody
# declared. The catalogue row's EVENT is asserted as a CELL and not as a substring of the whole row --
# a row whose prose merely says "PreToolUse" somewhere passes a row-wide grep while its event column
# says something else entirely.
a10_92=""
grep -qE '^HOOKS=.*context-structure-guard\.py' "$ROOT/install.sh" \
  || a10_92="$a10_92 [install.sh HOOKS= does not name it, so a fresh install ships without the rail]"
if [ "$PY3" = 1 ]; then
  M92="$(python3 - "$REG92" <<'PY' 2>/dev/null
import json, sys
try:
    groups = json.load(open(sys.argv[1]))['PreToolUse']
except Exception:
    sys.exit(0)
for g in groups:
    cmds = ' '.join(h.get('command', '') for h in g.get('hooks', []) if isinstance(h, dict))
    if 'context-structure-guard.py' in cmds:
        print(g.get('matcher', ''))
PY
)"
  [ -n "$M92" ] || a10_92="$a10_92 [no PreToolUse group registers the guard]"
  [ -z "$M92" ] || [ "$M92" = "Edit|Write" ] || a10_92="$a10_92 [its matcher is '$M92', not Edit|Write]"
else
  echo "  [skip] A10 matcher shape (python3 unavailable)"
fi
ROW92="$(grep -m1 '^| .context-structure-guard.py.' "$RDM92")"
if [ -z "$ROW92" ]; then
  a10_92="$a10_92 [no catalogue row]"
else
  EVT92="$(printf '%s' "$ROW92" | awk -F'|' '{print $3}' | tr -d '*`' | tr -s ' ')"
  printf '%s' "$EVT92" | grep -qF 'PreToolUse' \
    || a10_92="$a10_92 [the row's event cell is '$EVT92', which does not name PreToolUse]"
fi
[ -z "$a10_92" ] && ok "A10 the guard is registered on Edit|Write, catalogued with its event, and installed" \
                 || bad "A10 the guard is registered on Edit|Write, catalogued with its event, and installed ($a10_92)"

# The archive checklist, read as a region: its preamble is what the two prose rows below judge, and its
# numbered moves are what the path row judges.
CHK92="$(sed -n '/^### After ARCHIVE (single task)/,/^## /p' "$BLG92")"
PRE92="$(printf '%s\n' "$CHK92" | sed -n '/^### After ARCHIVE/,/^1\. /p')"

# A9 -- key 1 has a writer. Without this the rail refuses the engine's own close on every task carrying a
# global decision, which is the defect the Understand phase measured rather than assumed.
# Bound to the LITERAL the reader parses, not to three loose words: the guard reads key 1 through
# PHASE_RE -- a line labelled `phase:` whose value is ARCHIVE -- and 'archiv' alone is satisfied by
# "archive checklist" or by the section heading itself, so the preamble could instruct a write the guard
# cannot read with this row green. That is the defect this task exists to repair one level up.
a9_92=""
[ "$(insent "$PRE92" 'sheet' 'archiv' 'before')" = 1 ] \
  || a9_92="$a9_92 [the preamble states no write to the sheet before the first move]"
# The ordering claim above is three loose words, and `insent` is case-INSENSITIVE by design -- so
# 'archiv' is satisfied by "archive checklist" and even 'ARCHIVE' would match "archiving". The literal
# the reader parses is therefore asserted separately and case-SENSITIVELY: PHASE_RE reads a line labelled
# `phase:` whose value is ARCHIVE, and without this leg the preamble could instruct a write the guard
# cannot read with the row green -- which is the defect this task exists to repair one level up.
printf '%s' "$PRE92" | grep -q 'phase: \*\*ARCHIVE\*\*' \
  || a9_92="$a9_92 [the preamble does not carry the literal \`phase: **ARCHIVE**\` the guard actually parses]"
[ -z "$a9_92" ] \
  && ok "A9 the close writes key 1 before the first move that needs it" \
  || bad "A9 the close writes key 1 before the first move that needs it ($a9_92)"

# A11 / O4 -- the three writing moves cite a measure that can actually be run. The bare relative form
# resolves nowhere from a project root, and it is given as the `Verify` of three moves; the file's own
# precedent for a delivered ceremony script is the installed absolute path.
a11_92=""
for n92 in 1 2 3; do
  # awk, not a sed range: `/start/,/end/` ends ON the end line, so each move carried the NEXT move's
  # text -- and a sed range re-matches, so it also swallowed items from the epic checklist's own
  # numbered lists further down the section. Both made the positive leg satisfiable by a neighbour.
  # Demonstrated before it was fixed: with move 1's citation removed, the row still returned green.
  ITM92="$(printf '%s\n' "$CHK92" | awk -v n="$n92" '
    $0 ~ "^" n "\\. " { if (!seen) { f=1; seen=1 } }
    f && $0 ~ /^[0-9]+\. / && $0 !~ "^" n "\\. " { exit }
    f { print }')"
  printf '%s' "$ITM92" | grep -qF "$INST92" \
    || a11_92="$a11_92 [move $n92 does not cite the installed path]"
  printf '%s' "$ITM92" | grep -qE '`scripts/context-check\.sh`' \
    && a11_92="$a11_92 [move $n92 still carries the bare relative form, which resolves nowhere]"
done
[ -z "$a11_92" ] && ok "A11 the three writing moves cite a measure that can actually be run" \
                 || bad "A11 the three writing moves cite a measure that can actually be run ($a11_92)"

# A12 -- key 2 has a writer at every autonomy level. The reader is asserted by A4 above; without these two
# the key is a state the rail opens on and nothing in the engine ever writes, which is exactly the defect
# key 1 arrived with.
a12_92=""
DREG92="$(sed -n '/^## Decision Register/,/^## Mechanics/p' "$PLN92")"
[ "$(insent "$DREG92" 'structure: context' 'sheet')" = 1 ] \
  || a12_92="$a12_92 [the plan protocol's Decision Register states no marker that writes the sheet line]"
ASK92="$(sed -n '/^### Ask First/,/^## /p' "$EXE92")"
[ "$(insent "$ASK92" 'structure: context' 'Auto')" = 1 ] \
  || a12_92="$a12_92 [the execute protocol's approval tier states no go-ahead for the Auto path]"
[ -z "$a12_92" ] && ok "A12 key 2 has a writer at every autonomy level" \
                 || bad "A12 key 2 has a writer at every autonomy level ($a12_92)"

# O3 -- the block adds no fourth spelling of the adjacency predicate. Asserted over this block's own
# text: the canonical helper is used, and the bridge idiom the suite is trying to retire is absent here.
# `SELF92` is the one read, taken above the fence.
o3_92=""
# The slice with THIS ROW'S OWN REGION CUT OUT, which is what the frozen direction asks for: "O3's
# presence leg reads a slice that does not contain it". The count-above-one that stood here instead was a
# mitigation, not the direction -- it survives a block using the predicate once somewhere else, and it
# left the leg reading text that contains the leg. Excised, the question becomes a plain presence one
# again and the answer means what it says.
O3SLICE92="$(printf '%s\n' "$SELF92" | sed '/^# O3 -- the block adds no fourth spelling/,/^# S1 -- no leg of this block/d')"
printf '%s\n' "$O3SLICE92" | grep -qF 'insent "$' \
  || o3_92="$o3_92 [the canonical predicate is used nowhere in this block outside the legs that judge it]"
printf '%s' "$O3SLICE92" | grep -qE '\[\^\.\]\{0,[0-9]+\}' && o3_92="$o3_92 [a fourth spelling of the predicate was added]"
[ -z "$o3_92" ] && ok "O3 the new legs use the suite's canonical adjacency predicate" \
                || bad "O3 the new legs use the suite's canonical adjacency predicate ($o3_92)"

# S1 -- no leg of this block is satisfied by its own source text. The block's two self-judging rows read
# a slice of this file, and a leg that greps the WHOLE file for a string its own line contains is green
# whatever the code does. That is not a hypothetical: it is how the `tool_name` leg passed while two
# separate mutations showed the helper emitting nothing of the kind. The direction is a COUNT of the one
# shape that produces it -- a grep whose subject is this suite file entire. Zero, and the self-slices
# reach the file through `sed` with an explicit range instead.
s1_92=""
# Leg one, WIDENED to BOTH shapes. The defect is not `grep … "$ROOT/test/validate.sh"`; it is any leg
# whose subject is text containing that leg, and the form that actually produced it fed the slice in
# through a PIPE -- `printf '%s\n' "$SELFB92" | grep -q '"tool_name"'` -- where the file-path count never
# looked. A count reaching one of two shapes, under a comment claiming both, is this task's own defect
# class inside the fix for it; caught by testing the pattern against the original defect's own text
# rather than by reading it. Now: the file by path, AND the slice piped into a grep.
# Three regions read the slice for a living and are excluded BY REGION, which is what the direction asks:
# O2's two counts above, and O3 and S1 themselves. What the sweep protects is every OTHER leg, present or
# added later, and a new self-reading leg outside those three is what it exists to catch.
S1REG92="$(printf '%s\n' "$SELF92" \
  | sed '/^  # O2 -- every leg feeds the shape production sends/,/^  # And the helper it now depends on/d' \
  | sed '/^# O3 -- the block adds no fourth spelling/,/^# S4 -- the suite builds/d')"
W92="$(printf '%s\n' "$S1REG92" | grep -cE 'grep [^|]*"\$ROOT/test/validate\.sh"|\$SELFB?92" *\| *grep')"
[ "${W92:-0}" = 0 ] || s1_92="$s1_92 [$W92 leg(s) outside the three rows that judge this block take its own text as their subject, which is how a leg comes to be satisfied by its own line]"
# Leg two, the frozen sub-assertion the delivered row replaced with a presence grep: O2's `tool_name`
# evidence must come from a payload READ BACK through the helper, not from any slice. A grep for the probe
# would be a presence test over text this slice contains; what cannot be faked by a copy of this file is
# that the leg's subject is the captured value, so that is what is asserted -- the probe must be invoked,
# and the matched subject must be `$SEEN92`.
printf '%s' "$SELF92" | grep -q 'SEEN92="$(hookcall "$PROBE92"' \
  || s1_92="$s1_92 [O2's tool_name evidence is no longer read back through the helper]"
printf '%s' "$SELF92" | grep -q "printf '%s' \"\$SEEN92\" | grep -q '\"tool_name\"" \
  || s1_92="$s1_92 [O2's tool_name leg no longer reads the captured payload, so its subject may be a source slice]"
# And the slice must still be the slice. A grep for the `sed` range is a presence test over text that
# CONTAINS it -- the defect wearing the other tool's name, and the reason the range was readable while
# being wrong. What a copy of this file cannot satisfy is an equality on what the slice evaluated to.
[ "$(printf '%s\n' "$SELF92" | head -1)" = "# C92 -- changing the mechanism or a context file's structure is a declared act, and a hook rails it." ] \
  || s1_92="$s1_92 [the self-slice does not start at this block's own header, so what every self-judging leg judges is unknown]"
[ -z "$s1_92" ] && ok "S1 no leg of this block is satisfied by its own source text" \
               || bad "S1 no leg of this block is satisfied by its own source text ($s1_92)"

# S4 -- the suite builds a hook file_path payload in ONE place, which is what `hookcall`'s preamble has
# claimed while three spellings of the contract sat in the file. A COUNT over everything ABOVE this
# block, which is where every helper lives: a leg reading this file entire would be satisfiable by its
# own line, the shape S1 forbids. What this count cannot see -- a fourth builder written inside C92 --
# is O2's subject, and the two rows are the whole of the direction between them.
s4_92=""
ABOVE92="$(suite_src_others)"
B92="$(printf '%s\n' "$ABOVE92" | grep -cE 'printf .*"tool_input":\{"file_path"')"
[ "${B92:-0}" = 1 ] \
  || s4_92="$s4_92 [$B92 place(s) build a file_path payload, and the preamble claims one]"
# And the claim itself: a count that is right over a preamble promising something else is a pair that
# will be read as agreeing when it is not.
[ "$(insent "$ABOVE92" 'payload' 'ONE place')" = 1 ] \
  || s4_92="$s4_92 [the preamble no longer claims one place, so the count above measures nothing stated]"
[ -z "$s4_92" ] && ok "S4 the suite has one payload-helper pair" \
               || bad "S4 the suite has one payload-helper pair ($s4_92)"

# R8 -- the engine states the hole the rail ACTUALLY keeps. The papers promised one hole, "no task open
# at all"; the rail stops at rung 2, so the delivered hole is "no per-task sheet claims this checkout's
# branch" -- which swallows two populations with a task genuinely open: a project that never migrated its
# ledger, and a coordinator running worktree fronts. The second is this checklist's own checkout. BOTH
# directions, because stating the true hole while leaving the old over-claim standing is the case a
# presence-only row waves through, and the over-claim is the sentence a reader would act on.
CTX92="$ROOT/global/protocols/context.md"
r8_92=""
[ "$(insent "$PRE92" 'claims' 'branch' 'silent|never refused|not refused')" = 1 ] \
  || r8_92="$r8_92 [the checklist preamble does not state the hole the rail actually keeps]"
# The topology, BOUND TO THE HOLE rather than greped as a word. `grep -qiE 'worktree|coordinator'` was
# answered by the region's own opening sentence -- "it runs in the coordinator" -- which is context in
# this task's diff and predates it entirely, so the leg was GREEN ON THE BASE COMMIT, before the hole it
# guards was written, and the topology sentence it means could be deleted with the row still green. One
# sentence must carry the topology AND the blindness, which no sentence about who runs the ceremony can.
[ "$(insent "$PRE92" 'worktree' 'claims|claim' 'never refused|not refused|silent|never asks')" = 1 ] \
  || r8_92="$r8_92 [no single sentence names the worktree topology together with the rail being blind in it]"
# The over-claim, unqualified, must be gone: "the rail refuses the engine's own close" is false wherever
# no per-task sheet claims the coordinator's branch.
printf '%s' "$PRE92" | grep -qE 'Without[^.]*this write the rail refuses the engine' \
  && r8_92="$r8_92 [the unqualified over-claim is still there, and it is untrue in a worktree topology]"
[ "$(insent "$(cat "$CTX92")" 'rail' 'claims|per-task sheet' 'stands alone|nothing performing')" = 1 ] \
  || r8_92="$r8_92 [the rulebook does not say the rule stands alone where the rail cannot see the checkout]"
[ -z "$r8_92" ] && ok "R8 the engine states the hole the rail actually keeps" \
               || bad "R8 the engine states the hole the rail actually keeps ($r8_92)"

# R9 -- the sheet field has a home and a writer. A machine-read field introduced with no home in the
# document that owns the sheet is a field nobody can look up; a writer stated only in a template comment
# is a writer the close does not carry. Regions cut to the section, the rule A12 already follows.
SF92="$(sed -n '/^## State Files/,/^## Task Entry Format/p' "$BLG92")"
PP92="$(sed -n '/^### The phase precondition/,/^### Who writes what/p' "$BLG92")"
r9_92=""
[ "$(insent "$SF92" 'structure: context' 'sheet|machine-read')" = 1 ] \
  || r9_92="$r9_92 [the document that owns the sheet does not document the field]"
[ "$(insent "$SF92" 'structure: context' 'task-scoped|per task|rest of the task')" = 1 ] \
  || r9_92="$r9_92 [the field's SCOPE is undocumented, which is the half that surprises a reader]"
[ "$(insent "$PP92" 'structure: context' 'EXECUTE|Conform|approval')" = 1 ] \
  || r9_92="$r9_92 [the close that performs the write does not state it -- the writer lives only in a template comment]"
[ -z "$r9_92" ] && ok "R9 the sheet field has a home and a writer" \
               || bad "R9 the sheet field has a home and a writer ($r9_92)"

# R10 -- the rulebook cites a measure that can be run, and key 1 does not outlive the close. Both
# directions on the citation, as A11 has them: the installed path present AND the bare relative form
# absent, because a file carrying both passes a presence-only leg.
r10_92=""
grep -qF "$INST92" "$CTX92" \
  || r10_92="$r10_92 [the rulebook does not cite the measure by the path it installs to]"
grep -qE '`scripts/context-check\.sh' "$CTX92" \
  && r10_92="$r10_92 [the rulebook still carries the bare relative form, which resolves nowhere from a project root]"
# The window and the direction it fails in, stated in both homes rather than left to be discovered by an
# interrupted close. Three legs per home, because the two that came before asserted the state as
# delivered -- that the papers say the close fails OPEN -- and so went green BECAUSE the defect was
# written down, which is the test fix this suite's own manifest forbids. The direction is spelled out
# here instead: the position is narrowed to the move that needs it, so a close stopped anywhere else
# strands nothing.
#   1. the narrowing itself, and it must be per-move -- 'cleared at move 7' carries both 'cleared' and
#      'move', so 'each' is what separates a window from a whole ceremony;
#   2. the direction WITH its consequence, never the bare word: "fails **open** rather than closed"
#      satisfies a leg that asks only for 'closed', which is how a leg comes to pass over its opposite;
#   3. the old claim gone, the second direction A11's citation legs already carry -- a paper stating the
#      narrowing while leaving the fail-open sentence standing is the case a presence-only leg waves
#      through, and that sentence is the one a reader would act on.
for h92 in "checklist:$PRE92" "rulebook:$(cat "$CTX92")"; do
  HN92="${h92%%:*}"; HB92="${h92#*:}"
  [ "$(insent "$HB92" 'cleared|narrowed' 'each' 'move')" = 1 ] \
    || r10_92="$r10_92 [the $HN92 does not state the position is cleared or narrowed to each move that needs it]"
  [ "$(insent "$HB92" 'interrupted|halted|stopped' 'closed' 'strands nothing|at most')" = 1 ] \
    || r10_92="$r10_92 [the $HN92 does not say an interrupted close fails closed and strands nothing]"
  [ "$(insent "$HB92" 'interrupted|halted|stopped' 'fails? +\**open')" = 0 ] \
    || r10_92="$r10_92 [the $HN92 still says an interrupted close fails open]"
done
[ -z "$r10_92" ] && ok "R10 the rulebook cites a runnable measure, and key 1 does not outlive the close" \
                || bad "R10 the rulebook cites a runnable measure, and key 1 does not outlive the close ($r10_92)"

# R7 -- A9 and A11 go red when the claim they guard is REMOVED. Asserted by falsification and not by
# reading, because both rows were green over a claim that was not there: A9 matched three loose words
# with a case-insensitive predicate, so 'archiv' was satisfied by "archive checklist"; A11's sed range
# ended ON the following move and re-matched later numbered lists, so moves 1 and 2 were satisfiable by
# a neighbour -- demonstrated at Verify, where the row stayed green with move 1's citation removed.
# A row whose subject can be deleted with it green is not a guard, so the deletion is what this row runs.
r7_92=""
M7="$T92/falsify"; mkdir -p "$M7"
# (a) the phase literal removed from the preamble -- a write the guard's PHASE_RE could not read.
# The substitution targets the LITERAL, not the sentence carrying it: a mutation keyed on the prose is
# one the next rewording turns into a silent no-op, and a no-op mutation leaves this row asserting that
# an unchanged file still carries what it always carried. That is not hypothetical -- narrowing the
# window reworded this preamble and the old pattern stopped matching.
sed 's|`phase: \*\*ARCHIVE\*\*`|the archiving note|g' "$BLG92" > "$M7/no-phase.md"
PRE7="$(sed -n '/^### After ARCHIVE (single task)/,/^## /p' "$M7/no-phase.md" | sed -n '/^### After ARCHIVE/,/^1\. /p')"
if [ -z "$PRE7" ]; then
  r7_92="$r7_92 [the A9 falsification could not be built]"
elif printf '%s' "$PRE7" | grep -q 'phase: \*\*ARCHIVE\*\*'; then
  r7_92="$r7_92 [A9 is green over a preamble that no longer carries the literal the guard parses]"
fi
# (b) move 1's citation removed -- the exact defect A11 exists to catch
awk '/^1\. \*\*Steering update\*\*/{gsub(/`~\/\.claude\/ai-flow\/scripts\/context-check\.sh`/,"`the measure`")}1' \
  "$BLG92" > "$M7/no-cite.md"
CHK7="$(sed -n '/^### After ARCHIVE (single task)/,/^## /p' "$M7/no-cite.md")"
ITM7="$(printf '%s\n' "$CHK7" | awk -v n=1 '
  $0 ~ "^" n "\\. " { if (!seen) { f=1; seen=1 } }
  f && $0 ~ /^[0-9]+\. / && $0 !~ "^" n "\\. " { exit }
  f { print }')"
if [ -z "$ITM7" ]; then
  r7_92="$r7_92 [the A11 falsification could not be built]"
elif printf '%s' "$ITM7" | grep -qF "$INST92"; then
  r7_92="$r7_92 [A11 is green over a move 1 that no longer cites the installed path -- its region still reaches a neighbour]"
fi
# The positive control: the SAME extractor over the real file must still find the citation, or the two
# legs above would be satisfied by an extractor that reads nothing at all.
CHK7R="$(sed -n '/^### After ARCHIVE (single task)/,/^## /p' "$BLG92")"
ITM7R="$(printf '%s\n' "$CHK7R" | awk -v n=1 '
  $0 ~ "^" n "\\. " { if (!seen) { f=1; seen=1 } }
  f && $0 ~ /^[0-9]+\. / && $0 !~ "^" n "\\. " { exit }
  f { print }')"
printf '%s' "$ITM7R" | grep -qF "$INST92" \
  || r7_92="$r7_92 [the extractor finds nothing on the real file, so both falsifications above prove nothing]"
[ -z "$r7_92" ] && ok "R7 A9 and A11 fail when the claim they guard is removed" \
               || bad "R7 A9 and A11 fail when the claim they guard is removed ($r7_92)"

# R1 -- the ladder has ONE implementation. A COUNT, never a presence: a presence grep is green with
# three copies of `ledger_root`, which is the state this row exists to end. The shared module is the
# authority in code, as the backlog protocol's State Files is the authority in prose, and the sibling
# rail's docstring claim to be that authority is true again only while this row is green.
r1_92=""
for fn92 in ledger_root current_branch sheet_branch; do
  n="$(grep -lE "^def ${fn92}\\(" "$ROOT"/global/hooks/*.py 2>/dev/null | wc -l | tr -d ' ')"
  [ "$n" = 1 ] || r1_92="$r1_92 [${fn92}() is defined in $n hook files, not 1]"
done
# Both rails must reach it through the shared module rather than carrying their own.
for h92 in understand-write-guard context-structure-guard; do
  grep -q '^from _aiflow_state import' "$ROOT/global/hooks/$h92.py" \
    || r1_92="$r1_92 [$h92 does not import the shared ladder]"
done
# The one real difference between the two callers is an ARGUMENT, and each rail passes the one its own
# jurisdiction requires -- the phase rail takes the roster, the structure rail cannot.
grep -q 'fall_to_ledger=True' "$ROOT/global/hooks/understand-write-guard.py" \
  || r1_92="$r1_92 [the phase rail no longer takes rung 3, which is the only state an unmigrated project has]"
grep -q 'fall_to_ledger=False' "$ROOT/global/hooks/context-structure-guard.py" \
  || r1_92="$r1_92 [the structure rail no longer stops at rung 2, so it would refuse over a roster carrying neither key]"
# It ships, or the installed rails import a module that is not there and every write tracebacks.
grep -qE '^HOOKS=.*_aiflow_state\.py' "$ROOT/install.sh" \
  || r1_92="$r1_92 [install.sh does not deliver the shared module, so a fresh install breaks both rails]"
[ -z "$r1_92" ] && ok "R1 the ladder has one implementation" \
               || bad "R1 the ladder has one implementation ($r1_92)"

rm -rf "$T92"
