echo "== C29: opening a front starts from the surface the operator works in =="
BLG31="global/protocols/backlog.md"
PY31="template/.ai-flow/project.yml"
TST31="template/.ai-flow/STATE.md"
DOC31="docs/customization.md"

# Same extractor as the block above, and for the same reasons: fence-aware section cut, one numbered
# move flattened and whitespace-squeezed, classified on the move NUMBER so a move that moved is still
# seen. Defined here rather than borrowed, so this block survives being reordered.
OPN31="$(awk '/^## Opening a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG31")"
CLO31="$(awk '/^## Closing a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG31")"
o31() { printf '%s\n' "$OPN31" | awk -v n="$1" '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==n' | tr '\n' ' ' | tr -s ' '; }
c31() { printf '%s\n' "$CLO31" | awk -v n="$1" '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==n' | tr '\n' ' ' | tr -s ' '; }

M5_31="$(o31 5)"
M5RAW31="$(printf '%s\n' "$OPN31" | awk '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==5')"
# The move's PREAMBLE — everything ahead of the first condition. The identification has to be the move's
# first act, and a sentence about it buried after the four conditions is a different claim: it would read
# as something to do once the checkout exists, which is exactly the order that produced the incident.
HEAD31="$(printf '%s' "$M5_31" | sed 's/ - \*\*base\*\*.*//')"

# One condition bullet, by its own label. Every facet of the asymmetry is asserted INSIDE the bullet it
# belongs to: read over the whole move, `by hand` is answered by the sentence introducing the list and
# `every path` by the data bullet and the floor paragraph, so three of the four attributions could be
# deleted with the guard green. A facet a neighbouring sentence can satisfy reports the list as present
# while it is missing — the discipline this block already applies to the docs side.
b31() {  # $1 = condition label -> that bullet's text, flattened
  printf '%s\n' "$M5RAW31" | awk -v lab="- **$1**" '
    !f && index($0, lab) { f = 1; print; next }
    f && ($0 ~ /^[[:space:]]*$/ || $0 ~ /^   - \*\*/) { exit }
    f { print }' | tr '\n' ' ' | tr -s ' '
}

if [ -n "$M5_31" ]; then
  # A1 — the first act. The truncation is asserted before anything is concluded from it: `sed` reports
  # nothing when its pattern is absent, so a relabelled or reordered first condition would leave HEAD31
  # equal to the whole move and quietly turn this from an assertion about ORDER into one about presence —
  # satisfied by a sentence sitting after the conditions, which is the order that produced the incident.
  a1=""
  [ "$HEAD31" != "$M5_31" ] || a1="$a1 preamble-boundary-not-found"
  printf '%s' "$HEAD31" | grep -qE '\*\*(base|data|visibility|ownership)\*\*' && a1="$a1 preamble-cut-too-late"
  printf '%s' "$HEAD31" | grep -qiE 'identif'                            || a1="$a1 no-identification"
  printf '%s' "$HEAD31" | grep -qiE 'front_tool|the project (declares|is managed in)' || a1="$a1 nothing-to-read-it-from"
  [ -z "$a1" ] \
    && ok "the creation move identifies the project's tool before it creates anything" \
    || bad "the creation move identifies the project's tool before it creates anything (missing:$a1)"

  # A2a — the half of the split claim that says WHICH path comes first. Written as an ordered
  # co-occurrence inside one sentence rather than as a fixed phrase: what must hold is that the SUBJECT
  # of "the default" is the project's tool, and a bare word match is answered by any neighbouring
  # sentence that happens to carry it — including the base condition's own "published default branch".
  printf '%s' "$M5_31" | grep -qiE "(the (project'?s )?(declared )?tool|the tool the project (declares|is managed in))[^.]{0,120}is the default" \
    && ok "the creation move names the project's tool as the default" \
    || bad "the creation move names the project's tool as the default"

  # A2b — the weld itself, as a class and across every layer that could restate it. The floor half stays
  # asserted in the block above; what must never come back is the two claims sharing one predicate,
  # because that is the reading that stopped the question from being formed.
  w31="$(grep -rniE 'default and the floor' global docs template 2>/dev/null | wc -l | tr -d ' ')"
  [ "$w31" = "0" ] \
    && ok "no document welds the default and the floor into one claim" \
    || bad "no document welds the default and the floor into one claim ($w31 line(s))"

  # A5 — the undeclared case. A silence and a declaration read identically in a report, so the move has
  # to say it is falling back rather than simply doing it.
  a5=""
  printf '%s' "$M5_31" | grep -qiE 'declares (no|none|nothing)|no tool is declared|undeclared' || a5="$a5 case-not-named"
  printf '%s' "$M5_31" | grep -qiE '(declares (no|none|nothing)|undeclared)[^.]{0,200}(say|states|named|names)' || a5="$a5 not-stated"
  [ -z "$a5" ] \
    && ok "an undeclared front tool is a stated fallback, not a silent default" \
    || bad "an undeclared front tool is a stated fallback, not a silent default (missing:$a5)"

  # A3 — the asymmetry, asserted inside each condition it attributes. Facets named individually: a single
  # verdict over four facts cannot be acted on, and this is the list an operator reads to know what they
  # are paying for. An empty cut is its own failure, never a silently satisfied facet.
  a3=""
  for cond31 in base data visibility ownership; do
    [ -n "$(b31 "$cond31")" ] || a3="$a3 no-$cond31-bullet"
  done
  printf '%s' "$(b31 base)"       | grep -qiE 'worktree\.baseRef'            || a3="$a3 base-native-mechanism"
  printf '%s' "$(b31 base)"       | grep -qiE 'by hand'                      || a3="$a3 base-by-hand"
  printf '%s' "$(b31 data)"       | grep -qiE 'worktreeinclude'              || a3="$a3 data-native-mechanism"
  printf '%s' "$(b31 data)"       | grep -qiE 'by hand'                      || a3="$a3 data-by-hand"
  printf '%s' "$(b31 visibility)" | grep -qiE 'per.tool|tool by tool|depends on the tool' || a3="$a3 visibility-per-tool"
  printf '%s' "$(b31 ownership)"  | grep -qiE 'every path|on any path'       || a3="$a3 ownership-universal"
  printf '%s' "$M5_31"            | grep -qiE 'without help'                 || a3="$a3 native-gets-free"
  # The attribution rule itself, added because a field measurement falsified the absolute this list used
  # to state: a tool whose help never mentions the pattern file was found transferring exactly what it
  # selects. What a tool brings is a fact about the checkout, not about the documentation — and a
  # correction needs a guard as much as a feature does, or it is revertible with the suite green.
  printf '%s' "$M5_31" | grep -qiE 'read from the checkout' || a3="$a3 attribution-read-from-the-checkout"
  printf '%s' "$(b31 data)" | grep -qiE 'per.tool and per.version|per.version' || a3="$a3 data-not-absolute"
  [ -z "$a3" ] \
    && ok "the creation move says which conditions a non-native tool takes on by hand" \
    || bad "the creation move says which conditions a non-native tool takes on by hand (missing:$a3)"

  # A4 — the acknowledgement. The consequence the four conditions cannot express is the operator's own
  # view of the front, and an obligation with no written trace is the visibility condition's own defect
  # repeated: nothing reads it, nothing acts on it.
  # The gate is the half that matters, and the three facets below could all be met by a note written
  # after the checkout exists. What the criterion says is that the opening does not continue until the
  # line is on the sheet, so the halt and the resumption are pinned too — the wording move 3 already
  # uses for the collision this one is modelled on.
  a4=""
  printf '%s' "$M5_31" | grep -qiE 'fall(s|ing)? back|falls back'          || a4="$a4 fallback-not-named"
  printf '%s' "$M5_31" | grep -qiE 'acknowledg'                            || a4="$a4 no-acknowledgement"
  printf '%s' "$M5_31" | grep -qiE "task'?s (own )?sheet"                  || a4="$a4 no-home-for-it"
  printf '%s' "$M5_31" | grep -qiE 'resumes only once|does not continue until|only once that is' || a4="$a4 not-a-gate"
  [ -z "$a4" ] \
    && ok "falling back to the native path is acknowledged in writing on the task's sheet" \
    || bad "falling back to the native path is acknowledged in writing on the task's sheet (missing:$a4)"

  # A6 — the JOIN, not each half. The move names a key, the template documents one and the guide shows
  # one; nothing compared them, and that is the hole a rename walks through. The key is READ from the
  # protocol and looked for everywhere it must also appear.
  KEY31="$(printf '%s' "$M5_31" | grep -oE '`[a-z_]+` in `project\.yml`' | head -1 | tr -d '`' | awk '{print $1}')"
  if [ -n "$KEY31" ]; then
    ok "the creation move names the key it reads ($KEY31)"
    # As a KEY, never as a word: the guide and the template both discuss tools in prose, so a bare word
    # match is answered by a neighbouring sentence.
    keyed31() { printf '%s' "$1" | grep -qE "(^|[[:space:]#])${KEY31}:"; }
    # The key's own comment BLOCK — the run of consecutive comment lines it closes. A fixed -B window is
    # a line count masquerading as a structure: the block is five lines today and any edit to the prose
    # moves the facts out of the window while leaving them exactly where a reader finds them.
    BLK31="$(awk -v key="${KEY31}:" '
      /^#/ { buf = buf $0 "\n"; if (index($0, key)) { printf "%s", buf; exit } next }
      { buf = "" }' "$PY31")"
    if keyed31 "$(cat "$PY31")" \
       && printf '%s' "$BLK31" | grep -qi 'optional' \
       && ! grep -qE "^[[:space:]]*${KEY31}:" "$PY31"; then
      ok "the shipped template documents the same key as optional and declares none"
    else
      bad "the shipped template documents the same key as optional and declares none"
    fi
    keyed31 "$(awk '/^```yaml/{f=1;next} /^```/{f=0} f' "$DOC31")" \
      && ok "the schema the docs show carries the same key" \
      || bad "the schema the docs show carries the same key"
    # The LEVEL, not only the spelling. It holds a name and not a command, and an adopter who writes it
    # under `commands:` gets a file the ceremony reads as declaring nothing — the join pinned the word
    # and left the one thing a reader actually gets wrong unpinned.
    l31=""
    grep -qE "^#[[:space:]]*${KEY31}:" "$PY31"                    || l31="$l31 template-not-top-level"
    # Read from the comment BLOCK around the key, not from the key's own line: the two facts live on
    # different lines by construction, and a same-line grep asks for a sentence nobody would write.
    printf '%s' "$BLK31" | grep -qiE 'top.level'                   || l31="$l31 template-says-nothing"
    printf '%s' "$(awk '/^```yaml/{f=1;next} /^```/{f=0} f' "$DOC31")" | grep -qiE "${KEY31}[^#]*#.*top.level" \
      || l31="$l31 docs-says-nothing"
    [ -z "$l31" ] \
      && ok "both homes say the key is top-level, not a command" \
      || bad "both homes say the key is top-level, not a command (missing:$l31)"
    # A re-derive writes project.yml from scratch and knows only the required keys, so an optional one
    # this task added is deleted with nothing said. The protocol that writes the file is where that is
    # prevented; the ceremony that reads the key would otherwise report the project as declaring none.
    grep -qE "${KEY31}" global/protocols/discover.md \
      && ok "the protocol that rewrites the project sheet carries the optional key over" \
      || bad "the protocol that rewrites the project sheet carries the optional key over"
  else
    bad "the creation move names the key it reads"
    bad "the shipped template documents the same key as optional and declares none (no key named)"
    bad "the schema the docs show carries the same key (no key named)"
  fi

  # O1's machine half — the operator's guide is a second home for the same rules and can go stale.
  # Scoped to the section it is about, then to each item inside it — a file-wide grep over the guide is
  # answered from anywhere, and this same task added a schema comment a hundred lines above that carries
  # `identif` and would answer for the paragraph the facet exists to pin. The reference pattern for a
  # second-home check in this suite cuts the region first (the distribution join does exactly that with
  # the guide's fenced block), and the asymmetry facets are asserted per numbered item for the reason
  # the protocol side is: `by hand` is answered by the paragraph above the list and `every path` by the
  # data item, so the base and ownership attributions were pinned by nothing.
  SEC31="$(awk '/^### Parallel workstreams/{f=1} (f && /^## /){f=0} f' "$DOC31")"
  i31() {  # $1 = list item number -> that numbered item's text, flattened
    printf '%s\n' "$SEC31" | awk -v n="$1" '
      $0 ~ "^"n"\\. \\*\\*" { f = 1; print; next }
      f && ($0 ~ /^[0-9]+\. \*\*/ || $0 ~ /^[[:space:]]*$/) { exit }
      f { print }' | tr '\n' ' ' | tr -s ' '
  }
  d31=""
  [ -n "$SEC31" ] || d31="$d31 section-not-found"
  for n31 in 1 2 3 4; do [ -n "$(i31 "$n31")" ] || d31="$d31 no-item-$n31"; done
  printf '%s' "$SEC31" | grep -qiE 'identif[^.]{0,120}tool this project is managed in' || d31="$d31 first-step"
  printf '%s' "$(i31 1)" | grep -qiE 'by hand'    || d31="$d31 base-by-hand"
  printf '%s' "$(i31 2)" | grep -qiE 'by hand'    || d31="$d31 data-by-hand"
  printf '%s' "$(i31 3)" | grep -qiE 'per.tool'   || d31="$d31 visibility-per-tool"
  printf '%s' "$(i31 4)" | grep -qiE 'every path' || d31="$d31 ownership-universal"
  printf '%s' "$SEC31" | grep -qiE 'acknowledg'   || d31="$d31 acknowledgement"
  printf '%s' "$SEC31" | grep -qiE 'read from the checkout' || d31="$d31 attribution-read-from-the-checkout"
  [ -z "$d31" ] \
    && ok "the operator's document carries the first step, the asymmetry and the acknowledgement" \
    || bad "the operator's document carries the first step, the asymmetry and the acknowledgement (missing:$d31)"
else
  for m in \
    "the creation move identifies the project's tool before it creates anything" \
    "the creation move names the project's tool as the default" \
    "an undeclared front tool is a stated fallback, not a silent default" \
    "the creation move says which conditions a non-native tool takes on by hand" \
    "falling back to the native path is acknowledged in writing on the task's sheet" \
    "the creation move names the key it reads" \
    "the shipped template documents the same key as optional and declares none" \
    "the schema the docs show carries the same key" \
    "the operator's document carries the first step, the asymmetry and the acknowledgement"; do
    bad "$m (creation move not found)"
  done
  bad "no document welds the default and the floor into one claim (creation move not found)"
fi

# --- what created the front, recorded and read ---------------------------
# The roster is the front-scoped paper — the same reason the declared areas live there — and it is still
# present when the dismantling move runs, because the row is removed after it and not before.
r31=""
grep -qiE '^\|[^|]*workstream[^|]*\|.*\|[^|]*tool[^|]*\|' "$TST31" 2>/dev/null || r31="$r31 template-column"
# A header row alone is not a table: a delimiter row of the old width renders the column away, and the
# example row is what tells an operator the cell takes a value at all.
# Scoped to the Workstreams table: the file carries a second one (Quick Tasks) of a different width, so
# a check that measures every pipe-line in the file compares two tables and calls the pair ragged.
WSTBL31="$(awk '/^## Workstreams/{f=1;next} (f && /^## /){f=0} (f && /^\|/)' "$TST31" 2>/dev/null)"
[ "$(printf '%s\n' "$WSTBL31" | grep -c '^|')" -ge 3 ] || r31="$r31 template-no-example-row"
[ "$(printf '%s\n' "$WSTBL31" | awk -F'|' '{print NF}' | sort -u | wc -l | tr -d ' ')" = 1 ] || r31="$r31 template-ragged-table"
printf '%s\n' "$(awk '/^## State Files/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG31")" \
  | grep -qiE '^\|[^|]*workstream[^|]*\|.*\|[^|]*tool[^|]*\|' || r31="$r31 protocol-column"
# Anchored to the ROW, in the ordered-co-occurrence shape used for the default claim: move 7 describes
# two papers, and `tool` anywhere in it is satisfied by a sentence putting the creator on the SHEET —
# which would leave the closing move, that reads it from the row, with nothing. A writer and a reader
# disagreeing about which paper holds the datum is the one thing this join exists to catch.
printf '%s' "$(o31 7)" | grep -qiE 'row carries[^.]{0,200}(what created|the tool)' || r31="$r31 no-writer"
[ -z "$r31" ] \
  && ok "the roster records what created each front, on both sides and with a writer" \
  || bad "the roster records what created each front, on both sides and with a writer (missing:$r31)"

# A row that predates the column is not broken, and the clause that says so is what keeps a migration
# from reading as a defect — the shape the Areas column already established.
grep -qiE 'predates the \*\*tool\*\* column|predates the tool column' "$BLG31" \
  && ok "a roster that predates the tool column is not broken" \
  || bad "a roster that predates the tool column is not broken"

# A8 — the reader. Ownership had no reader at all: the move said "whatever created it" and nothing
# recorded what that was.
ndis31="$(printf '%s\n' "$CLO31" | awk '/^[0-9]+\. /{h=tolower($0); if (h ~ /dismantl/) {print $0+0; exit}}')"
printf '%s' "$(c31 "${ndis31:-0}")" | grep -qiE 'roster' \
  && ok "the dismantling move reads the creator from the roster row" \
  || bad "the dismantling move reads the creator from the roster row"

# B3 (regression) — the ordinary opening must not get heavier. The preamble says which moves have
# nothing to do with one front open; the creation move has to stay inside that set, or a project with a
# single front is now told to identify a tool for a checkout nobody is creating.
PRE31="$(printf '%s\n' "$OPN31" | awk '/^1\. /{exit} {print}' | tr '\n' ' ' | tr -s ' ')"
# The set is a RANGE in the prose ("steps 3 to 6"), so the membership test reads the range rather than
# hunting for a literal digit: asking for '5' in the characters of "3 to 6" answers no on a sentence
# that says yes, and the check would then demand a change to a preamble that is already correct.
covers31() {  # 0 when the preamble's "nothing to do" set contains move 5
  printf '%s' "$1" | grep -qiE 'nothing to do' || return 1
  printf '%s' "$1" | awk '
    { n = 0
      while (match($0, /[0-9]+ (to|-|through) [0-9]+/)) {
        s = substr($0, RSTART, RLENGTH); $0 = substr($0, RSTART + RLENGTH)
        split(s, p, /[^0-9]+/); if (p[1] <= 5 && 5 <= p[2]) n = 1
      }
      exit n ? 0 : 1 }'
}
if covers31 "$PRE31"; then
  ok "the single-front reduction still covers the creation move"
else
  bad "the single-front reduction still covers the creation move"
fi

# --- the installer names the ignore line the native path needs -----------
# Executed, not grepped: a message found in the source proves the message exists, never that anything
# reaches it. The prompts are answered rather than closed, for the reason the block above records.
if ! T31="$(mkbox)" || [ ! -d "$T31" ]; then
  bad "install names the ignore line the native worktree path needs (no sandbox: mktemp -d failed)"
else
  H31="$T31/home"; A31="$T31/adopt"; mkdir -p "$H31" "$A31"
  ( cd "$T31" && printf 'n\nn\n' | HOME="$H31" bash "$ROOT/install.sh" init "$A31" ) > "$T31/init.out" 2>&1 || true
  # Both halves of "names and does not write". The negative half is the load-bearing one: a project's
  # ignore rules are the project's own, and an installer that edits them has taken a decision nobody
  # delegated. Asserted on the filesystem, because the notice's own wording cannot prove abstention.
  if grep -q '\.claude/worktrees/' "$T31/init.out" && [ ! -e "$A31/.gitignore" ]; then
    ok "install names the ignore line the native worktree path needs and writes none"
  else
    bad "install names the ignore line the native worktree path needs and writes none"
  fi
  rm -rf "$T31"
fi
