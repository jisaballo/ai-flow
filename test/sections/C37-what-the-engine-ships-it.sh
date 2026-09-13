# C37 — a capability the engine installs but names no way to start is indistinguishable from a dead one.
# Generated in the Conform phase from understand.md's Verifiable Criteria A1-A6.
#
# The task arrived asserting both capabilities were dead. Measurement falsified half of it: the unattended
# loop had run and produced a merged commit, and its silence began the day it was centralised and its only
# documented launcher was left pointing at the old path. So these rows guard TWO OPPOSITE outcomes — the
# analysis capability must be gone, and the loop must still be here. A6 is FROZEN and green from the start:
# the mutation that kills it is this task over-reaching into the retirement it was told not to make.
#
# Every verdict is derived from a COUNT, never from a `grep -v` inside an `if`. The hazard is NOT BSD
# grep, which exits 1 on empty input: it is the search tool a session substitutes into its shell, which
# exits 0 — so the shape is safe here and unsafe in a command an agent types.
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
  EXPECT37="backlog.md context.md discover.md execute.md lifecycle.md plan.md quick-path.md understand.md verify.md"
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
  H6_37="$(mkbox)" || fatal 'C37 fixtures'; T6_37="$(mkbox)" || fatal 'C37 fixtures'; W6_37="$(mkbox)" || fatal 'C37 fixtures'
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
