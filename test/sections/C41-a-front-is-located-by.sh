echo "== C41: a front is located by the one field a chain of tasks does not change =="
BLG41="global/protocols/backlog.md"
TPL41="template/.ai-flow/STATE.md"

# Extractors re-declared rather than inherited: a criterion reading another section's extractor changes
# verdict when that one is re-scoped. Each is asserted non-empty before any verdict is trusted — an
# assertion that fails because its extractor found nothing passes on anything once the file is edited.
CLO41="$(awk '/^## Closing a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG41")"
OPN41="$(awk '/^## Opening a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG41")"
c41() { printf '%s\n' "$CLO41" | awk -v n="$1" '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==n' | tr '\n' ' ' | tr -s ' '; }
o41() { printf '%s\n' "$OPN41" | awk -v n="$1" '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==n' | tr '\n' ' ' | tr -s ' '; }
sec41() { awk -v h="$1" '$0 ~ h {f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^#+ /){f=0} f' "$BLG41" | tr '\n' ' ' | tr -s ' '; }
# The checklist's items one at a time. The deletion step is item 4 and its neighbours talk about the same
# papers in the same words, so a section-wide grep passes on a neighbour's sentence.
ARCH41="$(awk '/^### After ARCHIVE/{f=1;next} /^#+ /{if(f) exit} f' "$BLG41")"

M2_41="$(c41 2)"
if [ -n "$M2_41" ]; then
  # The field AND the absence of the one it replaces, as a pair: the new spelling can be added beside the
  # old one and read as done, while what makes the locator stable is that only one field is named.
  m41a=""
  printf '%s' "$M2_41" | grep -qiE 'checkout path|path on that front|by the checkout' || m41a="$m41a the-path-is-not-the-key"
  printf '%s' "$M2_41" | grep -qiE 'matched by the branch|by the branch on'           && m41a="$m41a the-branch-is-still-a-key"
  [ -z "$m41a" ] && ok "the collection move locates the front by the checkout path on its roster row" \
                 || bad "the collection move locates the front by the checkout path on its roster row (:$m41a)"

  # The rationale, guarded because this epic has already watched an unguarded one go: a reason nothing
  # asserts is deletable with the suite green, and this one is the whole reason the field changed.
  printf '%s' "$M2_41" | grep -qiE 'does not (move|change)|no chain of tasks|never moves|outlives' \
    && ok "the field the locator keys on is the one no chain of tasks changes" \
    || bad "the field the locator keys on is the one no chain of tasks changes"

  # One anchored pattern, not three presences. As three, each leg was satisfiable by unrelated text in
  # this same move: the listing by the locator sentence, the halt by any word containing 'stop', the path
  # by m41a's own leg three lines above. The fact is that the absence OF THAT PATH is what halts it.
  printf '%s' "$M2_41" | grep -qiE 'listing does not name that path[^.]*stop|does not name that path, stop' \
    && ok "an unlocatable front still stops the closing, on the absence of that path" \
    || bad "an unlocatable front still stops the closing, on the absence of that path"

  # The hole the removed column opens. The merge needs a branch and the roster was the only field that
  # could have been read for it, so the ceremony must name a source or the removal strands a consumer.
  FLAT41="$(printf '%s' "$CLO41" | tr '\n' ' ' | tr -s ' ')"
  m41c=""
  printf '%s' "$FLAT41" | grep -qiE "branch[^.]*(read|comes) from[^.]*(checkout|git)|git[^.]*that checkout" \
    || m41c="$m41c no-source-named"
  printf '%s' "$FLAT41" | grep -qiE 'never from the roster|not from the roster|never the roster' \
    || m41c="$m41c roster-not-excluded"
  [ -z "$m41c" ] && ok "the branch the merge needs is read from the located checkout, never from the roster" \
                 || bad "the branch the merge needs is read from the located checkout, never from the roster (:$m41c)"
else
  bad "the collection move locates the front by the checkout path on its roster row (move not found)"
  bad "the field the locator keys on is the one no chain of tasks changes (move not found)"
  bad "an unlocatable front still stops the closing, on the absence of that path (move not found)"
  bad "the branch the merge needs is read from the located checkout, never from the roster (move not found)"
fi

# The deletion of the papers, located by the ACT: its number moves whenever a move is inserted above it,
# and its home moves once it becomes a move of the ceremony rather than a step of the checklist. Both legs
# below are about what the deletion SAYS, which is the same claim in either home. The probe is silenced
# and the fallback is not: one of the two must answer, and the failure names the act.
if NDEL41="$(step_no "$DEL_ACT" "$CLO41" 2>/dev/null)"; then
  A4_41="$(c41 "$NDEL41")"
elif NDEL41="$(step_no "$DEL_ACT" "$ARCH41")"; then
  A4_41="$(nitem "$NDEL41" "$ARCH41")"
else
  A4_41=""
fi
if [ -n "$A4_41" ]; then
  # One home for the rule. This step both delegates to the collection move and restates its field, so
  # the restatement is the second copy — and a second copy is what the repository's own rule refuses.
  m41d=""
  printf '%s' "$A4_41" | grep -qiE 'the way move 2|as move 2|the way the collection move' || m41d="$m41d no-delegation"
  # Not the literal phrase this diff deleted: a restatement in different words ("keyed on the path its
  # roster row records") would pass while the rule has two homes again, which is what the label denies.
  printf '%s' "$A4_41" | grep -qiE 'worktree listing|checkout path|roster row'             && m41d="$m41d restates-the-rule"
  [ -z "$m41d" ] && ok "the deletion step locates the front the way the collection move does, and states it once" \
                 || bad "the deletion step locates the front the way the collection move does, and states it once (:$m41d)"
else
  bad "the deletion step locates the front the way the collection move does, and states it once (no step)"
fi

# Scoped to the Checkout paragraph, NOT to the roster section: over the whole section a readers leg is
# carried by the pre-existing Tool sentence ("read by the closing ceremony's dismantling move"), which is
# a different column and a different reader — it was already green before this change, so the half of the
# criterion that matters ("and name what reads it") was inert. Bounded at the sibling that follows.
CHK41="$(awk '/^\*\*Checkout\*\*/{f=1} f&&/^\*\*Areas\*\*/{exit} f' "$BLG41" | tr '\n' ' ' | tr -s ' ')"
if [ -n "$CHK41" ]; then
  # All four readers, because the count is the fact: a definition naming half the readership is what the
  # next person prices a change to this column from, and two of the four unlisted sites act destructively.
  m41e=""
  printf '%s' "$CHK41" | grep -qE '\*\*Checkout\*\*'                     || m41e="$m41e undefined"
  printf '%s' "$CHK41" | grep -qiE 'four'                                 || m41e="$m41e reader-count-unstated"
  printf '%s' "$CHK41" | grep -qiE 'collection move'                      || m41e="$m41e collection-unnamed"
  printf '%s' "$CHK41" | grep -qiE 'dismantl'                             || m41e="$m41e dismantling-unnamed"
  printf '%s' "$CHK41" | grep -qiE 'last move'                            || m41e="$m41e last-move-unnamed"
  # The fourth reader by its ROLE, plus the negative on the home it left. The positive alone would have
  # gone on passing on "the deletion step of the archive checklist" long after that step ceased to exist,
  # which is how this paragraph came to certify an act at an address the protocol had already vacated.
  printf '%s' "$CHK41" | grep -qiE 'deletion move'                        || m41e="$m41e deletion-move-unnamed"
  printf '%s' "$CHK41" | grep -qiE 'deletion step|archive checklist'      && m41e="$m41e deletion-still-a-checklist-step"
  [ -z "$m41e" ] && ok "the checkout column is defined where it lives, and names all four sites that read it" \
                 || bad "the checkout column is defined where it lives, and names all four sites that read it (:$m41e)"

  # The mechanism the whole re-key rests on, and it was deletable from both its sites with the suite fully
  # green — proven by mutation, not suspected. Three legs because the rule has three parts and each was
  # separately absent from the text this replaces: resolution, the base a relative row resolves against,
  # and the empty-equals-empty case that would read an unresolvable path as a match.
  m41h=""
  printf '%s' "$CHK41" | grep -qiE 'resolved|resolve'                        || m41h="$m41h no-resolution-rule"
  printf '%s' "$CHK41" | grep -qiE "coordinator's own checkout root|against the coordinator" || m41h="$m41h no-resolution-base"
  printf '%s' "$CHK41" | grep -qiE 'does not resolve is not a match'         || m41h="$m41h unresolvable-reads-as-located"
  [ -z "$m41h" ] && ok "the column says how it is compared: resolved, against the coordinator's root, and an unresolvable path is no match" \
                 || bad "the column says how it is compared: resolved, against the coordinator's root, and an unresolvable path is no match (:$m41h)"
else
  bad "the checkout column is defined where it lives, and names all four sites that read it (no paragraph)"
  bad "the column says how it is compared: resolved, against the coordinator's root, and an unresolvable path is no match (no paragraph)"
fi

# All three places a branch column is declared: the protocol's skeleton, the skeleton adopters receive,
# and the move that writes a row. Pinned together because two of them passing is not the fact — a column
# the opening still writes comes back into every roster the next time a front opens.
m41f=""
# Case-insensitive and space-tolerant: every other roster pattern in this suite is written that way, and
# the sweep that priced this task's blast radius missed two assertions for exactly this reason.
grep -qiE '^\| *workstream *\|.*\| *branch *\|' "$BLG41" && m41f="$m41f skeleton"
grep -qiE '^\| *workstream *\|.*\| *branch *\|' "$TPL41" && m41f="$m41f shipped-template"
M7_41="$(o41 7)"
CARRIES41="$(printf '%s' "$M7_41" | sed -n 's/.*[Tt]he row carries \([^.]*\)\..*/\1/p')"
if [ -z "$CARRIES41" ]; then
  m41f="$m41f row-carries-clause-not-found"
else
  printf '%s' "$CARRIES41" | grep -qi 'branch' && m41f="$m41f the-opening-still-writes-it"
fi
[ -z "$m41f" ] && ok "no roster declares a branch column — not the skeleton, not the shipped template, not the move that writes the row" \
               || bad "no roster declares a branch column — not the skeleton, not the shipped template, not the move that writes the row (still declared:$m41f)"

# Counted, not matched. Every other roster assertion in this suite reads the HEADER row alone, and the
# ledger guardian drops table lines by design (`awk '!/^\|/'`), so a stale separator group or a leftover
# cell ships a malformed roster into every adopting project with the suite at zero failures. Column-shape
# edits are the class of change this area attracts, and the first pass of this very task got the separator
# wrong — six hand-edited rows across two shipped files is where a count earns its keep.
rostercols41() {  # $1 = file -> the cell count of every line of the roster table, one per line
  awk -F'|' '/^\| *[Ww]orkstream *\|/{f=1} f&&!/^\|/{exit} f{print NF-2}' "$1"
}
m41i=""
for f41 in "$BLG41" "$TPL41"; do
  counts41="$(rostercols41 "$f41")"
  if [ -z "$counts41" ]; then
    m41i="$m41i ${f41##*/}=no-table"
  elif [ "$(printf '%s\n' "$counts41" | sort -u | wc -l | tr -d ' ')" != 1 ]; then
    m41i="$m41i ${f41##*/}=($(printf '%s\n' "$counts41" | tr '\n' ',' | sed 's/,$//'))"
  fi
done
[ -z "$m41i" ] && ok "every line of a shipped roster agrees with its header on the column count" \
              || bad "every line of a shipped roster agrees with its header on the column count (counts:$m41i)"

MIG41="$(sec41 '^### Migrating an existing ledger')"
if [ -n "$MIG41" ]; then
  # The paragraph that keeps an adopter's extra column from reading as a defect, in the shape of the two
  # already beside it. Without it the removal looks like a break in every ledger written before it.
  m41g=""
  printf '%s' "$MIG41" | grep -qiE 'branch[^ ]* column'          || m41g="$m41g column-unmentioned"
  printf '%s' "$MIG41" | grep -qiE 'not broken|nothing (consults|reads) it' || m41g="$m41g verdict-unstated"
  [ -z "$m41g" ] && ok "a roster that still carries the branch column is not broken" \
                 || bad "a roster that still carries the branch column is not broken (:$m41g)"
else
  bad "a roster that still carries the branch column is not broken (no section)"
fi
