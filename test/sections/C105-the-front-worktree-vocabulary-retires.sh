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
  m105=""
  printf '%s' "$SPAN105" | grep -qi 'front-end'      || m105="$m105 front-end-missing"
  printf '%s' "$SPAN105" | grep -qi 'in front of'    || m105="$m105 in-front-of-missing"
  printf '%s' "$SPAN105" | grep -qi 'seed-front\.sh' || m105="$m105 seed-front.sh-missing"
  printf '%s' "$SPAN105" | grep -qi 'front_tool'     || m105="$m105 front_tool-missing"
  [ -z "$m105" ] \
    && ok "\"front-end\", the idiom, the script's filename and the schema key survive the rewrite untouched" \
    || bad "\"front-end\", the idiom, the script's filename and the schema key survive the rewrite untouched ($m105)"
fi
