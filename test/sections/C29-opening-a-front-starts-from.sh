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
if [ -n "$M5_31" ]; then
  # A6 — the JOIN, not each half. The move names a key, the template documents one and the guide shows
  # one; nothing compared them, and that is the hole a rename walks through. The key is READ from the
  # protocol and looked for everywhere it must also appear.
  KEY31="$(printf '%s' "$M5_31" | grep -oE '`[a-z_]+` in `project\.yml`' | head -1 | tr -d '`' | awk '{print $1}')"
  if [ -n "$KEY31" ]; then
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
  else
    bad "the shipped template documents the same key as optional and declares none (no key named)"
  fi
else
  for m in \
    "the shipped template documents the same key as optional and declares none"; do
    bad "$m (creation move not found)"
  done
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
