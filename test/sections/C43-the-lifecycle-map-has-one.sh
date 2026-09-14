echo "== C43: the lifecycle map has one home, and the home is one an adopter receives =="
MAP43="global/protocols/lifecycle.md"
# The nine phases, named once. Every check below derives its patterns from this list rather than
# restating them, so a phase renamed in the engine cannot leave a guard quietly matching nothing.
PH43='CAPTURE|PRIORITIZE|ACTIVATE|UNDERSTAND|PLAN|CONFORM|EXECUTE|VERIFY|ARCHIVE'

# --- the map has exactly one home ------------------------------------------
# A1. Counted, not merely found — the same shape the phase precondition's home guard uses, and for the
# same reason: the whole anti-drift design is that a second statement cannot exist, and a check that
# only asks whether the rule is present anywhere is satisfied by every copy at once. Anchored at line
# start on the first phase's own heading: a document that CITES the map names it inline ("see the
# lifecycle protocol"), which is how every cross-reference in this engine is written, and an unanchored
# count would read each citer as another home. A real second home carries the phase headings itself.
HOME43="$(grep -rliE '^#{2,4} *(1\. *)?CAPTURE\b' global/ 2>/dev/null | wc -l | tr -d ' ')"
ELSE43="$(grep -rliE '^#{2,4} *(1\. *)?CAPTURE\b' template/ docs/ README.md 2>/dev/null | wc -l | tr -d ' ')"
if [ "$HOME43" -eq 1 ] && [ "$ELSE43" -eq 0 ] && [ -f "$MAP43" ]; then
  ok "the lifecycle map is stated in exactly one document, and it is a distributed one"
else
  bad "the lifecycle map is stated in exactly one document, and it is a distributed one (global/: $HOME43, elsewhere: $ELSE43, map present: $([ -f "$MAP43" ] && echo yes || echo no))"
fi

# A2. The direction the count cannot see. A home is recognised by the first phase's heading; a copy that
# describes the phases under any other wording is a second description the count reports as zero. What
# selects one here is a map element LEADING a heading, a table row or a numbered item — the shape a
# description has and a mention does not.
#
# THREE dimensions, not one, and each judged on itself. The map is the phase chain, the execution paths
# AND the autonomy levels, and a guard keyed on phase names alone let two thirds of it be copied back
# with the suite green — proven, not suspected: the pre-change paths and autonomy tables were appended
# to the front door and every row of this block stayed green. That is the drift this task exists to end,
# re-openable in the dimension the one live drift actually sat in, since it was the Supervised row that
# had lost `>5 files` and `architectural decisions` in two copies.
#
# The paths and autonomy legs select TABLE ROWS only, never headings: `### Full path (most tasks)` heads
# a worked transcript in the adopter guide, which is an example and not the criteria, and every copy this
# task removed stated those two dimensions as a table.
PATH43='Full|Quick'
AUTO43='Auto|Guided|Supervised'
# A route row is excluded — the manual MUST keep one — and the exclusion is the narrowest shape that
# describes a route: a two-cell row whose second cell is nothing but a protocol path. The first form of
# it dropped any line containing `protocols/` anywhere, which forgives a restored description that
# happens to cite one (`| **Activate** | Run the opening ceremony (see protocols/backlog.md) |`) —
# the likeliest shape a re-add takes, since a copy written today would cite its source.
ROUTE43='^\|[^|]*\|[[:space:]]*`?[~./A-Za-z0-9_-]*protocols/[a-z-]+\.md`?[[:space:]]*\|[[:space:]]*$'
# Every document a reader meets outside the map itself, the sibling protocols included: a copy grown in
# one of those ships to every adopter and is drift-guarded into being permanent. The map is excluded by
# name rather than by directory, so a second protocol carrying the map is caught rather than exempted.
SET43="README.md $(ls docs/*.md 2>/dev/null) global/CLAUDE.md global/hooks/README.md template/CLAUDE.md $(ls template/.ai-flow/*.md 2>/dev/null) $(ls global/protocols/*.md 2>/dev/null | grep -v 'lifecycle\.md')"
mapcount43() {  # $1 = file, $2 = lead alternation, $3 = 'rows-only' to skip headings and list items
  if [ "${3:-}" = "rows-only" ]; then
    grep -icE "^\| *\*{0,2}($2)\b" "$1" 2>/dev/null | tr -d ' '
  else
    # Three shapes, because a phase name leading a line is not yet a phase being described, and the
    # looser pattern this replaces reported four sibling protocols: a document TITLED `# Plan Phase
    # Protocol`, a section called `## Verify vs Done`, a checklist item `3. **Verify** that ...` and a
    # three-column table row about who writes what. Each shape below is the one an actual copy took —
    # a NUMBERED phase heading (`### 1. CAPTURE`), a TWO-cell table row (`| **Capture** | Add task ... |`),
    # or a numbered item whose bold lead is closed by a colon (`1. **CAPTURE**: Add task ...`). The three
    # copies this task removed used one each, which is why all three are here and none is a guess.
    grep -iE "^(#{1,6} *[0-9]+\. *\*{0,2}($2)\b|\| *\*{0,2}($2)\*{0,2} *\|[^|]*\|[[:space:]]*$|[0-9]+\. *\*{0,2}($2)\*{0,2}:)" "$1" 2>/dev/null \
      | grep -cvE "$ROUTE43" || true
  fi
}
who43=""
for f43 in $SET43; do
  [ -f "$f43" ] || continue
  np43="$(mapcount43 "$f43" "$PH43")"
  nx43="$(mapcount43 "$f43" "$PATH43" rows-only)"
  na43="$(mapcount43 "$f43" "$AUTO43" rows-only)"
  # Three is the threshold for the phase chain — one or two leads is a document explaining a phase it
  # owns. The paths table has only two rows and the autonomy table three, so those tie at two: a single
  # `| **Quick** |` row is a mention, both of them together is the table.
  [ "$np43" -ge 3 ] && who43="$who43 ${f43##*/}:phases=$np43"
  [ "$nx43" -ge 2 ] && who43="$who43 ${f43##*/}:paths=$nx43"
  [ "$na43" -ge 2 ] && who43="$who43 ${f43##*/}:autonomy=$na43"
done
[ -z "$who43" ] \
  && ok "no document outside the map carries the phase chain, the paths table or the autonomy table" \
  || bad "no document outside the map carries the phase chain, the paths table or the autonomy table (:$who43)"

# A2b — the live twin, judged on the same three counts and named separately. It is the copy that governs
# real sessions and the only one nothing distributes: the installer writes it solely when absent and the
# drift guard excludes it as user-owned, so a description removed from the shipped manual survives here
# until somebody ports the edit. The other twin legs in this suite cannot report it — they ask whether
# the manual ROUTES, and a twin still carrying the whole map routes perfectly well. Without this row the
# hand-merge is an intention with nothing behind it, which is the shape of drift this task exists to end.
TWIN43="${HOME:-}/.claude/CLAUDE.md"
if [ -f "$TWIN43" ]; then
  t43=""
  [ "$(mapcount43 "$TWIN43" "$PH43")" -ge 3 ]              && t43="$t43 phases"
  [ "$(mapcount43 "$TWIN43" "$PATH43" rows-only)" -ge 2 ]  && t43="$t43 paths"
  [ "$(mapcount43 "$TWIN43" "$AUTO43" rows-only)" -ge 2 ]  && t43="$t43 autonomy"
  [ -z "$t43" ] \
    && ok "the live twin carries no copy of the map either" \
    || bad "the live twin carries no copy of the map either (:$t43 — port the edit by hand, nothing distributes ~/.claude/CLAUDE.md)"
else
  echo "  [skip] live CLAUDE.md twin absent — the shipped manual carries the count"
fi

# A2c — the route itself, which every removal above depends on and nothing guarded. The map is only
# reachable because the manual's phase table names it: delete that one row and the protocol still ships,
# is still drift-guarded and still counts as the single home, while no document the engine loads points
# a session at it. Proven by mutation rather than argued — the row was deleted and the suite stayed at
# 548/0. Asserted on both copies, because the twin is the one that governs real sessions.
manmap43() { grep -qE '^\|[^|]*\|[^|]*protocols/lifecycle\.md[^|]*\|' "$1"; }
if manmap43 global/CLAUDE.md; then
  ok "the manual's phase table routes a session to the map"
  if [ -f "$TWIN43" ]; then
    manmap43 "$TWIN43" \
      && ok "the live twin routes a session to the map" \
      || bad "the live twin routes a session to the map (port the edit by hand, nothing distributes ~/.claude/CLAUDE.md)"
  else
    echo "  [skip] live CLAUDE.md twin absent — the shipped manual carries the route"
  fi
else
  bad "the manual's phase table routes a session to the map"
  bad "the live twin routes a session to the map (shipped copy is stale)"
fi

# --- the map is whole -------------------------------------------------------
# A5. Every dimension the map claims, present. This matters here in a way it would not in a document
# with siblings: the map is now the ONLY copy, so a section deleted from it is a section the engine no
# longer has anywhere. Every other row in this block guards against the map being COPIED; this is the
# one that guards against it being emptied, and without it the single-home design converts an edit
# slip into an unrecoverable loss. Counted rather than spot-checked — a check naming three phases
# passes on a document that lost the other six.
np5="$(grep -cE '^### [0-9]+\. ' "$MAP43" 2>/dev/null || true)"
a5_43=""
[ "$np5" = "9" ] || a5_43="$a5_43 phase-sections=$np5(want 9)"
grep -qE '^## Execution Paths'  "$MAP43" 2>/dev/null || a5_43="$a5_43 paths-section"
grep -qE '^## Autonomy Levels'  "$MAP43" 2>/dev/null || a5_43="$a5_43 autonomy-section"
grep -qiE '^\| *\*{0,2}Full\b'  "$MAP43" 2>/dev/null || a5_43="$a5_43 full-row"
grep -qiE '^\| *\*{0,2}Quick\b' "$MAP43" 2>/dev/null || a5_43="$a5_43 quick-row"
for lv5 in Auto Guided Supervised; do
  grep -qiE "^\| *\*{0,2}$lv5\b" "$MAP43" 2>/dev/null || a5_43="$a5_43 ${lv5}-row"
done
[ -z "$a5_43" ] \
  && ok "the map carries all nine phases, both paths and all three autonomy levels" \
  || bad "the map carries all nine phases, both paths and all three autonomy levels (missing:$a5_43)"

# --- the map is delivered, not merely written ------------------------------
# A3. The front door sends a reader to the map, and sends them to the copy that ships. A link into
# `docs/` would point at a file no install produces, which is the whole defect this task removes.
if grep -qF "$MAP43" README.md 2>/dev/null; then
  ok "the front door points at the map an adopter receives"
else
  bad "the front door points at the map an adopter receives"
fi

# --- the drift that misclassified a real task ------------------------------
# A4. The Supervised row, scoped to the section that owns the autonomy table. Both triggers, separately:
# the two renderings that drifted kept "schema changes" and lost exactly these, and losing one of the two
# is the same defect as losing both. This is the one criterion here with a live failure behind it — the
# task that wrote this guard was classified by the leg the other copies had already dropped.
AUT43="$(awk '/^## Autonomy Levels/{f=1;next} f && /^## /{exit} f' "$MAP43" 2>/dev/null)"
SUP43="$(printf '%s' "$AUT43" | grep -m1 -iE '^\| *\*{0,2}Supervised')"
a43=""
[ -n "$AUT43" ] || a43="$a43 section-absent"
[ -n "$SUP43" ] || a43="$a43 supervised-row-absent"
printf '%s' "$SUP43" | grep -qiE '> *5 files|more than five files' || a43="$a43 file-count-trigger"
printf '%s' "$SUP43" | grep -qi  'architectural'                   || a43="$a43 architecture-trigger"
[ -z "$a43" ] \
  && ok "the map's Supervised row keeps both triggers the other copies dropped" \
  || bad "the map's Supervised row keeps both triggers the other copies dropped (missing:$a43)"
