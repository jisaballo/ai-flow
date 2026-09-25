echo "== C105: the vocabulary rewrite retires \"front\" from the ceremonies, and only from them =="
BLG105="global/protocols/backlog.md"

# The span this task's diff covers: State Files through end of file (both ceremonies and the Directory
# Hygiene checklists they delegate to are all downstream of that heading). No fence-awareness here on
# purpose -- unlike the section-scoped extractors elsewhere in this suite, this leg's claim is about every
# byte of the span, skeletons and examples included, so narrowing to prose-only would blind it to exactly
# the kind of leftover a quoted example could still carry.
SPAN105="$(awk '/^## State Files/{f=1} f{print}' "$BLG105")"

if [ -z "$SPAN105" ]; then
  bad "no leftover \"front\" denoting the checkout or the roster-row entity remains in the span (no ## State Files heading found)"
  bad "\"front-end\", the idiom, the script's filename and the schema key survive the rewrite untouched (no ## State Files heading found)"
else
  # The four things in this span this rewrite must NOT touch, read first-hand at Understand: "front-end"
  # names the tool that created a checkout (Claude Code, Orca, git directly); "in front of" is the ordinary
  # idiom; "seed-front.sh" is Concern 2's own filename, deferred and unrenamed; "front_tool" is a literal
  # project.yml schema key, not prose. Blanked out before the retirement check runs, so none can hide a
  # real leftover behind it and none can be mistaken for one — and each replacement is spelled without the
  # letters f-r-o-n-t together, so the placeholder itself cannot re-trigger the very check it is exempting.
  CLEANED105="$(printf '%s' "$SPAN105" | sed -E 's/front-end/EXEMPT-TOOL/gi; s/in front of/EXEMPT-IDIOM/gi; s/seed-front\.sh/EXEMPT-SCRIPTNAME/gi; s/front_tool/EXEMPT-SCHEMAKEY/gi')"

  # THE RETIREMENT. Word-boundary and case-insensitive, over the CLEANED text: "front", "fronts", and the
  # possessive "front's" are the three inflections this task's own Understand phase priced across the
  # span. A bare grep over the uncleaned span would also fire on every "front-end" and "in front of" --
  # which is why those two are blanked out first rather than excluded by a second pass afterwards, where a
  # pattern written to skip them could just as easily skip a real leftover sitting next to one.
  n105="$(printf '%s' "$CLEANED105" | grep -ciE "\bfronts?\b|\bfront's\b")"
  [ "$n105" = 0 ] \
    && ok "no leftover \"front\" denoting the checkout or the roster-row entity remains in the span" \
    || bad "no leftover \"front\" denoting the checkout or the roster-row entity remains in the span ($n105 left)"

  # THE COMPANION. A rewrite broad enough to also catch "front-end", the idiom, the script's filename or
  # the schema key passes the leg above for the wrong reason -- everything got renamed, including what
  # should not have. Asserted on the RAW span, not the cleaned one, so a mutation that deleted one of them
  # outright (rather than renaming it) is caught here instead of silently vanishing into the blank-out step.
  # Counted, not merely checked for presence: a bare existential match is satisfied the moment ONE of
  # several named sites survives, so a rewrite that silently renamed the other two "front-end" mentions
  # (say, into "worktree tooling") would still pass this leg on the one it missed. The floors are what
  # Understand measured this pass: three "front-end" sites, two "seed-front.sh" mentions, one "front_tool"
  # schema key, one "in front of" idiom.
  m105=""
  n105fe="$(printf '%s' "$SPAN105" | grep -cio 'front-end')"
  n105sf="$(printf '%s' "$SPAN105" | grep -cio 'seed-front\.sh')"
  n105ft="$(printf '%s' "$SPAN105" | grep -cio 'front_tool')"
  n105io="$(printf '%s' "$SPAN105" | grep -cio 'in front of')"
  [ "$n105fe" -ge 3 ] || m105="$m105 front-end-count:$n105fe(want>=3)"
  [ "$n105io" -ge 1 ] || m105="$m105 in-front-of-count:$n105io(want>=1)"
  [ "$n105sf" -ge 2 ] || m105="$m105 seed-front.sh-count:$n105sf(want>=2)"
  [ "$n105ft" -ge 1 ] || m105="$m105 front_tool-count:$n105ft(want>=1)"
  [ -z "$m105" ] \
    && ok "\"front-end\", the idiom, the script's filename and the schema key survive the rewrite untouched, at their full counts" \
    || bad "\"front-end\", the idiom, the script's filename and the schema key survive the rewrite untouched, at their full counts ($m105)"

  # THE DISTINCTION. The retirement leg above only catches the retiring word; it says nothing about
  # whether the two words this task minted in its place stay on their own sides. understand.md's own
  # Business Frame and plan.md's Contract both name the one distinction the rename must not lose: the
  # coordinator is never a linked worktree. Flattened to one line so a wrapped sentence is not split by
  # its own line break, then read one sentence (period-delimited) at a time so a legitimate sentence
  # mentioning both words for a *contrast* -- "The coordinator pulls; a linked worktree still never
  # writes here." -- is not mistaken for one that *equates* them. A single leading/trailing word boundary
  # is used rather than one on every term: this engine's own grep chokes on three word-boundaried terms
  # separated by wildcards in one pattern (confirmed empirically), and a check that cannot run is not a
  # check.
  FLAT105="$(printf '%s' "$SPAN105" | tr '\n' ' ')"
  EQ105="$(printf '%s' "$FLAT105" | grep -io -E '\bcoordinator\b.{0,60}(^| )(is|as|becomes|equals)( a| the)?( linked)? worktree\b')"
  [ -z "$EQ105" ] && EQ105="$(printf '%s' "$FLAT105" | grep -io -E '\b(a |the )?(linked )?worktree\b.{0,60}(^| )(is|as|becomes|equals)( a| the)? coordinator\b')"
  [ -z "$EQ105" ] \
    && ok "no sentence in the span equates the coordinator with a (linked) worktree" \
    || bad "no sentence in the span equates the coordinator with a (linked) worktree ($EQ105)"
fi
