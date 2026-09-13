# C53 — the Icebox gains an exit the engine itself runs, and every surviving entry gets a body of its own.
# Generated in the Conform phase from understand.md's Verifiable Criteria (A1-A15; O1-O4 are inspection).
#
# Every verdict is derived from a COUNT inside an extracted region, never from a `grep -v` inside an `if`.
#
# TWO SHAPES CARRY THIS SECTION, and each answers a defect this engine has already paid for.
#
#   * PAIRING. Four rows pin the retired prose to zero as well as the new prose to one. Presence alone is
#     satisfied by leaving the old sentence beside the new one — and because this task OVERRULES rules
#     rather than extending them, that failure would leave the engine stating a prohibition and its repeal
#     at the same time. Absence alone is satisfied by deleting the passage and writing nothing. The
#     absence halves pin the OLD prose's own operative words — `No T-ID`, `make the file SMALLER`,
#     `not built yet`, `happens only at the epic-close` — each read at its line number before this section
#     was written, and none of them a phrase the correct new prose has any reason to carry.
#
#   * POSITION AND STRUCTURE OVER VOCABULARY. A1 and A10 are derived from where things sit, not from what
#     they are called. The write-back must precede the move that deletes the papers it publishes from, and
#     the checklist's numbered steps must be the steps its own citations name. A row keyed on the words
#     would pass a checklist whose renumber left every citation pointing one step off — which is precisely
#     what this task's diff creates, and the reason the renumber is verified before anything lands on it.
#
# A15 IS FROZEN AND GREEN FROM THE START. Its subject is the quick path, which the operator decided to
# leave untouched. What it catches is scope creep in the one direction nothing else looks: an edit that
# helpfully gave that path a write-back of its own would leave every other row here green.
echo "== C53: the Icebox has an exit the engine runs, and an entry has a body of its own =="
BK72="global/protocols/backlog.md"
UN72="global/protocols/understand.md"
QK72="global/protocols/quick-path.md"
CL72="global/CLAUDE.md"
IN72="install.sh"
WT72=".worktreeinclude"
WTT72="template/.worktreeinclude"

# `-r` and `-s`, not `-f`: a mode-000 or truncated file satisfies `-f`, and the rows would then report a
# dozen deletions of prose that is in fact present.
c53_readable=1
for f72 in "$BK72" "$UN72" "$QK72" "$CL72" "$IN72" "$WT72" "$WTT72"; do
  { [ -r "$f72" ] && [ -s "$f72" ]; } || c53_readable=0
done

if [ "$c53_readable" -eq 0 ]; then
  bad "C53's seven files are all readable and non-empty"
else
  # The single-task archive checklist. Terminated at the next heading of any level, so the region is the
  # checklist and not everything after it — the sibling sections below it are what the epic-close rows read.
  ARC72="$(awk '/^### After ARCHIVE \(single task\)/{f=1;next} f && /^#{2,4} /{exit} f' "$BK72")"
  # The write-back move alone, from its own numbered step to the next one. Its rows must not be satisfiable
  # by prose belonging to a neighbouring move: `Steering update` and `product.md write-back` sit next to it
  # and are write-backs too, so a region of the whole checklist would answer for the wrong move.
  WB72="$(printf '%s\n' "$ARC72" | awk '/Icebox write-back/{f=1} f && /^[0-9]+\. / && !/Icebox write-back/{exit} f')"
  # Flattened, for the legs that are ORDERED CO-OCCURRENCES rather than two independent words. A wrapped
  # markdown sentence spans lines, so a line-scoped grep for "regenerated ... same edit" would answer no
  # to correct prose. Two independent greps instead would pass prose that decouples the two halves, which
  # is the failure C51's own coupling leg was added for after a mutation proved it.
  WB72F="$(printf '%s\n' "$WB72" | tr '\n' ' ' | tr -s ' ')"
  # The Icebox section. Terminated on the first line starting with `#` because the prose below it opens a
  # fenced block whose own headings would otherwise re-open the region.
  ICE72="$(awk '/^### Icebox \(discoveries\)/{f=1;next} /^#/{f=0} f' "$BK72")"
  ICE72F="$(printf '%s\n' "$ICE72" | tr '\n' ' ' | tr -s ' ')"
  EPC72="$(awk '/^### After Epic completion/{f=1;next} f && /^#{2,4} /{exit} f' "$BK72")"
  SZB72="$(awk '/^## BACKLOG\.md Size Budget/{f=1;next} f && /^#{2,3} /{exit} f' "$BK72" | tr '\n' ' ' | tr -s ' ')"
  TRI72="$(awk '/^## Discovery Triage/{f=1;next} /^## /{f=0} f' "$UN72" | tr '\n' ' ' | tr -s ' ')"
  # The installer's data skeleton, by the line that creates it. Read as a line and not as the whole file so
  # the row cannot go green on the word `icebox` appearing in an echo three functions away.
  MKD72="$(grep -E 'mkdir -p "\$TARGET/\.ai-flow"' "$IN72")"
  QKP72="$(cat "$QK72")"

  n72() { printf '%s' "$1" | grep -ciE "$2" | tr -d ' '; }
  # Files under global/ carrying a pattern. The absence legs must reach zero across the whole engine, not
  # merely inside one region: a retired prohibition moved one section over is a prohibition that still runs.
  g72() { grep -rIloE "$1" global/ 2>/dev/null | wc -l | tr -d ' '; }

  # Every extracted region is asserted non-empty by its own row, the house style: a renamed heading must
  # fail as a renamed heading, not as fifteen simultaneous reports that the prose was deleted.
  r72=""
  [ -n "$ARC72" ] || r72="$r72 [the single-task archive checklist did not extract — heading renamed?]"
  [ -n "$WB72" ]  || r72="$r72 [no numbered move names the Icebox write-back]"
  [ -n "$ICE72" ] || r72="$r72 [the Icebox section did not extract]"
  [ -n "$EPC72" ] || r72="$r72 [the epic-completion checklist did not extract]"
  [ -n "$SZB72" ] || r72="$r72 [the size-budget section did not extract]"
  [ -n "$TRI72" ] || r72="$r72 [the Discovery Triage section did not extract]"
  [ -n "$MKD72" ] || r72="$r72 [the installer's data skeleton line did not extract]"
  [ -z "$r72" ] && ok "C53's seven regions all extract" || bad "C53's seven regions all extract ($r72)"

  # A1 — THE POSITION, which is the whole reason this move sits where it does: it publishes FROM the papers
  # that a later move deletes, so ordered after that move it has no source to read. Derived from the first
  # line each appears on inside the checklist, so swapping the two fails and deleting either fails for its
  # own reason. A count-only row would pass both mutations. Both patterns name the ACT, not a step number:
  # this task renumbers the checklist, and a row keyed on the numbers would have to be rewritten by the very
  # change it is meant to judge.
  # The two acts no longer share a section: the write-back is a step of this checklist, which move 4 runs,
  # and the deletion is a move of the ceremony. So the comparison is between the MOVE that runs the
  # checklist and the move that deletes — read from the ceremony, both by their act. Comparing line numbers
  # inside the checklist would now find only one of the two and report the other as deleted prose.
  CLOA72="$(awk '/^## Closing a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BK72")"
  a1wb72="$(printf '%s\n' "$ARC72" | grep -niE 'Icebox write-back' | head -1 | cut -d: -f1)"
  a1rec72="$(step_no 'record is written' "$CLOA72")" || a1rec72=""
  a1del72="$(step_no 'delet' "$CLOA72")"             || a1del72=""
  c1_72=""
  [ -n "$a1wb72" ]  || c1_72="$c1_72 [the checklist carries no Icebox write-back move]"
  [ -n "$a1rec72" ] || c1_72="$c1_72 [the ceremony carries no move that writes the record, so the checklist runs nowhere]"
  [ -n "$a1del72" ] || c1_72="$c1_72 [the move that deletes the task's papers did not match]"
  if [ -n "$a1rec72" ] && [ -n "$a1del72" ] && [ "$a1rec72" -ge "$a1del72" ]; then
    c1_72="$c1_72 [the checklist's own move is ordered at or after the deletion of the papers it publishes from]"
  fi
  [ -z "$c1_72" ] && ok "A1 the write-back runs before the papers it publishes from are deleted" \
                  || bad "A1 the write-back runs before the papers it publishes from are deleted ($c1_72)"

  # A2 — both halves are shown, and nothing is written before they are approved. The refusal leg is an
  # ordered co-occurrence: two bare words would be satisfied by prose that shows the halves and then writes
  # regardless, which is the whole failure the operator's approval exists to prevent.
  c2_72=""
  [ "$(n72 "$WB72F" 'addition')" -ge 1 ]  || c2_72="$c2_72 [the additions half is not named]"
  [ "$(n72 "$WB72F" 'amendment')" -ge 1 ] || c2_72="$c2_72 [the amendments half is not named]"
  [ "$(n72 "$WB72F" 'both halves|shown to the (user|operator)|put in front of')" -ge 1 ] \
    || c2_72="$c2_72 [the move never says the halves are shown to anyone]"
  [ "$(n72 "$WB72F" '(nothing|none of it) is written[^.]*(approv|until)|writes nothing (until|before)')" -ge 1 ] \
    || c2_72="$c2_72 [nothing forbids writing before the operator approves]"
  [ -z "$c2_72" ] && ok "A2 both halves are shown and nothing is written before they are approved" \
                  || bad "A2 both halves are shown and nothing is written before they are approved ($c2_72)"

  # A3 — the body moves, and the line is regenerated FROM it in the same edit. The second leg is ordered on
  # purpose: prose promising a regenerated line in some later act is the drift this rule exists to close,
  # and it satisfies two independent greps. The third leg pins the destination the body moves to, so a move
  # that copies the essay into the index instead fails here rather than reading as a wording choice.
  c3_72=""
  [ "$(n72 "$WB72F" 'moved verbatim|verbatim, not (authored|written) again')" -ge 1 ] \
    || c3_72="$c3_72 [the body is not moved verbatim, so the essay would be authored a second time]"
  [ "$(n72 "$WB72F" 'regenerated[^.]*same edit|same edit[^.]*regenerated')" -ge 1 ] \
    || c3_72="$c3_72 [the index line is not regenerated from the body in the same edit]"
  [ "$(n72 "$WB72F" 'icebox/IB-[X0-9]+\.md')" -ge 1 ] \
    || c3_72="$c3_72 [the body's own file is not named]"
  [ -z "$c3_72" ] && ok "A3 the body moves verbatim and its index line is regenerated in the same edit" \
                  || bad "A3 the body moves verbatim and its index line is regenerated in the same edit ($c3_72)"

  # A4 — the identifier is minted where the ledger already has a single writer. Ordered co-occurrence: the
  # word `coordinator` appears all over this protocol, and `minted` without it would pass a rule that lets
  # a front issue its own numbers, which is the race the opening ceremony spends a whole move avoiding.
  [ "$(n72 "$WB72F" 'minted[^.]*coordinator')" -ge 1 ] \
    && ok "A4 the identifier is minted where the ledger has one writer" \
    || bad "A4 the identifier is minted where the ledger has one writer ([the move does not say the coordinator mints it])"

  # A5 — retirement, three legs. Each is a separate promise and each is separately deletable: where the body
  # goes, that the number is burned, and that the reason survives with it. A dead entry whose reason went
  # with it is indistinguishable from an entry nobody read, which is B1's rule one level up.
  c5_72=""
  [ "$(n72 "$WB72F" 'archive/icebox')" -ge 1 ]                 || c5_72="$c5_72 [retirement names no destination]"
  [ "$(n72 "$WB72F" 'never reused|not reused|burned')" -ge 1 ]  || c5_72="$c5_72 [the number is not said to be unreusable]"
  [ "$(n72 "$WB72F" 'reason it died|keeps the reason|with its reason')" -ge 1 ] \
    || c5_72="$c5_72 [a retired entry does not keep the reason it died]"
  [ -z "$c5_72" ] && ok "A5 retirement burns the number and keeps the reason" \
                  || bad "A5 retirement burns the number and keeps the reason ($c5_72)"

  # A6 (paired) — the section admits an identifier and a body file, still refuses a priority, and says why
  # the trade was made. The absence half pins the retired prohibition's own opening words across the whole
  # engine: `No T-ID` is a phrase the new prose has no reason to carry, and leaving it beside the admission
  # is the one mutation the presence legs cannot see. The third leg is the REASON, which this engine treats
  # as part of the rule: without it the next reader re-argues a trade nobody recorded.
  c6_72=""
  [ "$(n72 "$ICE72" 'IB-[X0-9]')" -ge 1 ]                        || c6_72="$c6_72 [the section does not name the identifier form]"
  [ "$(n72 "$ICE72" 'no priority|never a priority')" -ge 1 ]      || c6_72="$c6_72 [the section stopped refusing a priority]"
  [ "$(n72 "$ICE72F" 'cited by (its )?name|cross-referen')" -ge 1 ] || c6_72="$c6_72 [the trade is stated without the reason it was made]"
  [ "$(g72 'No T-ID')" -eq 0 ]                                   || c6_72="$c6_72 [the retired prohibition is still stated somewhere under global/]"
  [ -z "$c6_72" ] && ok "A6 the section admits an identifier and a body, still refuses a priority, and says why" \
                  || bad "A6 the section admits an identifier and a body, still refuses a priority, and says why ($c6_72)"

  # A7 (paired) — the epic-close review is a confirmation sweep and no longer the route out. The absence half
  # is engine-wide because the claim it retires is stated twice, in two protocols, and a sweep announced in
  # one while the other still calls itself the only door leaves the engine with two answers.
  c7_72=""
  [ "$(n72 "$EPC72" 'sweep|confirm')" -ge 1 ] || c7_72="$c7_72 [the epic-close review is not stated as a sweep]"
  [ "$(g72 'happens only at the epic-close|happens only there')" -eq 0 ] \
    || c7_72="$c7_72 [a protocol still calls the epic-close review the only route out]"
  [ -z "$c7_72" ] && ok "A7 the epic-close review is a confirmation sweep, not the only route out" \
                  || bad "A7 the epic-close review is a confirmation sweep, not the only route out ($c7_72)"

  # A8 (paired) — the size rule governs CLOSED work, and admits a close that publishes pending work. Without
  # the absence half the engine would carry an absolute and its exception at once, and the reader who obeys
  # the absolute drops findings; without the presence half the rule simply loses its teeth.
  c8_72=""
  [ "$(n72 "$SZB72" 'closed')" -ge 1 ] || c8_72="$c8_72 [the rule no longer says what it is about]"
  [ "$(n72 "$SZB72" 'publish[^.]*close|close that publishes|pending work[^.]*close')" -ge 1 ] \
    || c8_72="$c8_72 [a close that publishes pending work is not admitted]"
  [ "$(g72 'make the file SMALLER')" -eq 0 ] || c8_72="$c8_72 [the retired absolute is still stated]"
  [ -z "$c8_72" ] && ok "A8 the size rule governs closed work and admits a close that publishes" \
                  || bad "A8 the size rule governs closed work and admits a close that publishes ($c8_72)"

  # A9 (paired) — a staged finding has a destination named in the triage that routes it there. The absence
  # half pins the sentence this task exists to replace, and it is engine-wide: the admission that the
  # publishing half did not exist was deliberate prose, and prose that outlives its truth is worse than none.
  c9_72=""
  [ "$(n72 "$TRI72" 'write-back')" -ge 1 ] || c9_72="$c9_72 [the triage does not route a staged finding to the write-back]"
  [ "$(g72 'not built yet')" -eq 0 ]       || c9_72="$c9_72 [a protocol still says the destination is not built]"
  [ -z "$c9_72" ] && ok "A9 a staged finding is routed to the write-back, not to nowhere" \
                  || bad "A9 a staged finding is routed to the write-back, not to nowhere ($c9_72)"

  # A10 — the checklist is the checklist its own citations name. Structural, and it is the row that guards
  # this task's most silent failure: inserting a numbered move renumbers every step after it, and a citation
  # left behind points at a real step that performs something else. Nothing else in the suite would notice —
  # one existing row extracts a step by its literal number and would simply read the wrong text.
  c10_72=""
  steps72="$(printf '%s\n' "$ARC72" | grep -cE '^[0-9]+\. ' | tr -d ' ')"
  # The COUNT stays a literal, and it is the only thing here that does. Every position below is derived
  # from its step's own act, so a renumber moves them together; what a derived count would give up is the
  # one reading nothing else notices — a step appearing or vanishing, which is precisely the event that
  # renumbers the rest. Deriving both would leave the pair agreeing with each other about anything.
  [ "$steps72" -eq 8 ] || c10_72="$c10_72 [the checklist has $steps72 numbered steps, not the eight its citations are written against]"
  # The acts, and the numbers they currently occupy. A literal here is the failure IB-001 records: after a
  # renumber the leg lands on a different step and passes for the wrong reason, with its own name still
  # claiming the step it no longer reads.
  nrow72="$(step_no 'workstream row|roster row' "$ARC72")" || nrow72=""
  nsum72="$(step_no 'summary' "$ARC72")"                   || nsum72=""
  nice72="$(step_no 'icebox write-back' "$ARC72")"         || nice72=""
  if [ -z "$nrow72" ] || [ -z "$nsum72" ] || [ -z "$nice72" ]; then
    c10_72="$c10_72 [a step the citations depend on performs no act this leg can find]"
  else
    # The relations the prose depends on, not the numbers it happens to have. The roster step is cited as
    # the last one and the write-back's own reason is that it publishes from papers a later step destroys,
    # so it must precede the summary that records them.
    [ "$nrow72" -eq "$steps72" ] || c10_72="$c10_72 [the roster step is $nrow72 of $steps72, so it is not the last step its citations name]"
    [ "$nice72" -lt "$nsum72" ]  || c10_72="$c10_72 [the Icebox write-back does not precede the summary, so it publishes from papers already recorded]"
    # Every citation that sends a reader to a step must name the number that step actually holds. Derived
    # on both sides: the old form spelled the wrong number as a literal, so it went stale the moment the
    # step it forbade became the step the label rewrite legitimately sits on.
    # Every citation, in every engine file that carries one, and with a FLOOR. Three things the form that
    # stood here got wrong, and each of them answered "0 strays":
    #  - it swept `$BK72` alone, so understand.md's own `Icebox write-back`, step N was never read;
    #  - it was line-oriented, so a citation the file wraps was invisible;
    #  - it bridged with `[^.]{0,80}`, a bounded repeat over a negated class -- which the stricter of the
    #    two search engines a machine may carry REFUSES outright ("exceeds complexity limits"), on stderr,
    #    exit 2, no output. That refusal is what this machine actually does, so the leg has been passing
    #    here without ever examining a citation. An extraction that fails yields nothing, and nothing
    #    satisfies every absence leg: the floor below is what makes the difference reportable.
    # Sentences, not a bridge: flatten, split on the period, keep the sentences that name the term. A
    # period inside a filename splits a sentence here, exactly as it does for `insent`.
    for pair72 in "label:$nrow72" "write-back:$nice72"; do
      w72="${pair72%:*}"; n72e="${pair72##*:}"
      found72=0; stray72=0
      for f72 in "$BK72" "$UN72"; do
        [ -r "$f72" ] || continue
        while IFS= read -r c72; do
          [ -n "$c72" ] || continue
          found72=$((found72+1))
          [ "$c72" = "step $n72e" ] || stray72=$((stray72+1))
        done <<EOF
$(tr '\n' ' ' < "$f72" | tr -s ' ' | tr '.' '\n' | grep -i -- "$w72" | grep -oiE 'step [0-9]+' | tr 'A-Z' 'a-z')
EOF
      done
      [ "$found72" -ge 1 ] \
        || c10_72="$c10_72 [no citation of the $w72 step was found in any engine file, so this leg judged nothing]"
      [ "$stray72" -eq 0 ] \
        || c10_72="$c10_72 [$stray72 citation(s) send the reader to a step that is not $n72e for: $w72]"
    done
  fi
  [ -z "$c10_72" ] && ok "A10 no citation names a step the checklist no longer has" \
                   || bad "A10 no citation names a step the checklist no longer has ($c10_72)"

  # A11 — the icebox stays with the coordinator. Both halves, in both copies: no listed path (the ledger
  # would then travel to a front and go stale against the one the coordinator keeps writing), and the file
  # names it among what stays, so the next reader does not add the line this row exists to keep out. The
  # first leg reads only NON-comment lines: the second leg requires the word in a comment, so a file-wide
  # count would have the two legs contradict each other.
  c11_72=""
  for pf72 in "$WT72" "$WTT72"; do
    [ "$(grep -cE '^[[:space:]]*[^#[:space:]].*icebox' "$pf72" | tr -d ' ')" -eq 0 ] \
      || c11_72="$c11_72 [$pf72 lists an icebox path — the ledger would travel]"
    [ "$(grep -ciE '^#.*icebox' "$pf72" | tr -d ' ')" -ge 1 ] \
      || c11_72="$c11_72 [$pf72 does not name the icebox among what stays]"
  done
  [ -z "$c11_72" ] && ok "A11 the icebox stays with the coordinator, in both pattern files" \
                   || bad "A11 the icebox stays with the coordinator, in both pattern files ($c11_72)"

  # A12 — a fresh install creates both halves of the pair. THE LEG THAT COUNTS IS EXECUTED: it asks the
  # filesystem the installer wrote to, not the text of the installer. C37 A6 records why in this same file —
  # deleting the three lines that actually installed a capability left every text leg green, because the
  # filenames survived on an assignment, a mkdir and a reassuring echo. The text leg is kept beside it for
  # one reason: without it, directories created by some other hand would answer for the skeleton.
  T72="$(mkbox)" || fatal 'C53 fixtures'
  H72="$T72/home"; A72="$T72/adopt"; mkdir -p "$H72"
  ( cd "$T72" && printf 'n\nn\n' | HOME="$H72" bash "$ROOT/install.sh" init "$A72" ) > "$T72/init.out" 2>&1
  rc72=$?
  c12_72=""
  [ "$rc72" -eq 0 ]                     || c12_72="$c12_72 [the fresh install exited $rc72]"
  [ -d "$A72/.ai-flow/icebox" ]         || c12_72="$c12_72 [no icebox directory was created]"
  [ -d "$A72/.ai-flow/archive/icebox" ] || c12_72="$c12_72 [no retired half was created]"
  [ "$(n72 "$MKD72" 'icebox')" -ge 1 ]  || c12_72="$c12_72 [the data skeleton does not name it, so anything found above came from another hand]"
  rm -rf "$T72"
  [ -z "$c12_72" ] && ok "A12 a fresh install creates both halves of the pair" \
                   || bad "A12 a fresh install creates both halves of the pair ($c12_72)"

  # A13 — the move creates its directory rather than assuming it. The installer's skeleton runs on a FRESH
  # install alone, so every project that adopted ai-flow earlier and merely updates reaches its first
  # write-back with no directory there. Ordered co-occurrence, because `creates` and `absent` as two bare
  # words are satisfied by any sentence in the move that happens to use both.
  [ "$(n72 "$WB72F" 'creates? (it|the directory)[^.]*(absent|does not exist)|(absent|does not exist)[^.]*creates? it')" -ge 1 ] \
    && ok "A13 the move creates its directory rather than assuming it" \
    || bad "A13 the move creates its directory rather than assuming it ([an existing project's first write-back would write into a directory that is not there])"

  # A14 — the always-loaded manual names the directory. Asserted on the table ROW, keyed on its first cell:
  # a file-wide grep would be satisfied by the word appearing in any sentence, and the table is what a
  # session actually consults. The live twin is checked and reported STALE rather than failed when absent —
  # nothing distributes that file, so its absence is a machine without it, not a defect in this change.
  PAP72="$(grep -F '| `icebox/` |' "$CL72")"
  c14_72=""
  [ -n "$PAP72" ]                                  || c14_72="$c14_72 [the manual's data table has no icebox row]"
  [ "$(n72 "$PAP72" 'body|entr|bodies')" -ge 1 ]   || c14_72="$c14_72 [the row names the directory without saying what lives in it]"
  twin72="$HOME/.claude/CLAUDE.md"
  if [ -r "$twin72" ] && [ -s "$twin72" ]; then
    grep -qF '| `icebox/` |' "$twin72" \
      || c14_72="$c14_72 [the live twin is stale — port the row by hand, nothing distributes ~/.claude/CLAUDE.md]"
  else
    echo "  [skip] live CLAUDE.md twin absent — the shipped copy is what this row judged"
  fi
  [ -z "$c14_72" ] && ok "A14 the manual names the directory, shipped copy and live twin" \
                   || bad "A14 the manual names the directory, shipped copy and live twin ($c14_72)"

  # A15 — FROZEN ROW, green before this task's work and after it. The operator decided the quick path keeps
  # its own rule: the operator present is its mechanism, and adding a publication ceremony to the one path
  # whose value is having none was refused. The count-equality leg is C51 A7's idiom, and the reason it is a
  # comparison rather than a zero is that the sentence FORBIDDING the ledger there has to name the ledger.
  qk_ice72="$(printf '%s\n' "$QKP72" | grep -cE 'Icebox' | tr -d ' ')"
  qk_neg72="$(printf '%s\n' "$QKP72" | grep -E 'Icebox' | grep -ciE 'never writes|never reaches|nothing reaches|never to BACKLOG|does not write' | tr -d ' ')"
  c15_72=""
  [ "$(n72 "$QKP72" 'surfac|put in front of')" -ge 1 ] || c15_72="$c15_72 [a survivor is no longer surfaced to the operator]"
  [ "$qk_ice72" -eq "$qk_neg72" ] || c15_72="$c15_72 [the shared list is named here outside a refusal — this path was to be left alone]"
  [ -z "$c15_72" ] && ok "A15 the quick path's own rule is untouched" \
                   || bad "A15 the quick path's own rule is untouched ($c15_72)"
fi
