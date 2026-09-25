echo "== C42: one cause for several sheets, and a prune whose reason covers both layouts =="
BLG42="global/protocols/backlog.md"
RAIL42="global/hooks/understand-write-guard.py"
DOC42="docs/customization.md"

# The rejected attribution, as a CLASS and not as the one token the change happened to delete: any of
# these causes standing within a sentence of "several sheets" is the contradiction returning, whatever
# verb it is spelled with. A single-token negative was tried first and was shown to pass on "copied as a
# whole at creation" — the same claim, in the file the protocol declares the winner on disagreement.
NEG42='(travel|copied|carried|arriv|snapshot|wholesale|as a whole|at creation)[^.]{0,120}sever[a-z]* (state )?sheets|sever[a-z]* (state )?sheets[^.]{0,120}(travel|copied|carried|arriv|snapshot|wholesale|as a whole|at creation)'
# The producer that survives a correct ceremony, bound to what it produces. Loose, the phrase occurs in
# this protocol for other reasons and the paragraph could keep the wrong cause while gaining the right
# words.
POS42='sever[a-z]* (state )?sheets[^.]{0,160}next task|next task[^.]{0,160}sever[a-z]* (state )?sheets'

# The ladder's OPENING PARAGRAPH, not its section: the producer this criterion requires is also named
# further down in rung 4, so a section-wide grep is satisfied by text that predates the change.
# Each non-blank line ONCE. An earlier form ended with a bare truth pattern and no action, so awk's
# default print fired beside the explicit one and every line came out twice — and after the flattening
# below that fabricates a junction from the end of a line to the start of the SAME line, which the
# bounded windows above can be satisfied by. The duplication check is what says it cannot come back.
RAW42="$(awk '/^### Resolving the task/{f=1;next} f && NF==0 && seen {exit} f && NF {seen=1; print}' "$BLG42")"
OPEN42="$(printf '%s\n' "$RAW42" | tr '\n' ' ' | tr -s ' ')"
DUP42="$(printf '%s\n' "$RAW42" | sort | uniq -d | wc -l | tr -d ' ')"

# Rung 4 of the same ladder — the sentence the opening's correction is anchored to.
RUNG4_42="$(awk '/^### Resolving the task/{f=1;next} f&&/^### /{exit} f' "$BLG42" | awk '/^4\. /{f=1} f' | tr '\n' ' ' | tr -s ' ')"

OPN42="$(awk '/^## Opening a Workstream/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^## /){f=0} f' "$BLG42")"
o42() { printf '%s\n' "$OPN42" | awk -v n="$1" '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==n' | tr '\n' ' ' | tr -s ' '; }
M6_42="$(o42 6)"
# Cut before the third-layout sentence. That sentence contains both `ignored` and `tracked`, so over the
# whole move it lent its words to the two layout legs below and the clause they exist to pin was
# deletable with the suite green — proven by mutation, not suspected. It gets its own assertion instead.
M6CUT42="${M6_42%%A data directory neither*}"
# The adopter's copy of the same rationale. Guarded because the whole point of pairing the two documents
# is that they not drift, and the copy was reachable by nothing but a negative sweep.
DOCD42="$(awk '/^2\. \*\*Data\*\*/{f=1;next} /^3\. /{f=0} f' "$DOC42" | tr '\n' ' ' | tr -s ' ')"
# The rail's own account, in the file the protocol declares authoritative on disagreement.
RAILD42="$(awk '/def resolve_task_sheet/{f=1} f&&/per_task = /{exit} f' global/hooks/_aiflow_state.py | tr '\n' ' ' | tr -s ' ')"

if [ "$DUP42" = 0 ] && [ -n "$RAW42" ]; then
  ok "the paragraph extractor reads each line once"
else
  bad "the paragraph extractor reads each line once ($DUP42 duplicated line(s), $( printf '%s\n' "$RAW42" | grep -c . ) line(s) read)"
fi

if [ -n "$OPEN42" ] && [ "$DUP42" = 0 ]; then
  m42a=""
  printf '%s' "$OPEN42" | grep -qiE "$POS42"                            || m42a="$m42a producer-not-bound-to-several-sheets"
  printf '%s' "$OPEN42" | grep -qiE 'writes that line|recognises its own task' \
    || m42a="$m42a purpose-of-the-claim-traded-away"
  printf '%s' "$OPEN42" | grep -qiE "$NEG42"                            && m42a="$m42a rejected-cause-still-credited"
  # The opening is corrected TO AGREE with rung 4, so the sentence it agrees with has to still be there:
  # delete the anchor and the opening states a cause nothing in the section corroborates, which is the
  # single-statement property this criterion is really about.
  printf '%s' "$RUNG4_42" | grep -qiE 'workstream taking on its next task|takes on its next task' \
    || m42a="$m42a rung-4-anchor-gone"
  [ -z "$m42a" ] && ok "the ladder credits the producer that survives a correct ceremony" \
                 || bad "the ladder credits the producer that survives a correct ceremony (:$m42a)"
else
  bad "the ladder credits the producer that survives a correct ceremony (extractor read nothing usable)"
fi

# The same statement in the file that wins if the two ever read differently. Asserted POSITIVELY and not
# only swept: the corrected sentence was deletable from the docstring outright with the suite green, so
# the propagation half of this change had no guard at all.
if [ -n "$RAILD42" ]; then
  m42r=""
  printf '%s' "$RAILD42" | grep -qiE "$POS42" || m42r="$m42r producer-unstated"
  printf '%s' "$RAILD42" | grep -qiE "$NEG42" && m42r="$m42r rejected-cause-credited"
  [ -z "$m42r" ] && ok "the rail states the same cause as the ladder it implements" \
                 || bad "the rail states the same cause as the ladder it implements (:$m42r)"
else
  bad "the rail states the same cause as the ladder it implements (docstring not found)"
fi

# The attribution swept across every shipped document, hook and skill. One place stating it correctly is
# worth nothing while a second states it wrongly. Flattened per file, because the two halves of the
# sentence sit on different lines in the protocol and a per-line grep reports the file clean.
#
# The set is COUNTED, and membership is required for the two files that carried the attribution — not for
# the whole set, which is a glob and would be a second list to keep current. What the count and those two
# buy is the case a mistyped glob produces: selects nothing, finds nothing, reports success — the
# empty-selection defect this suite already knows from the seeder. test/ is outside the set, or this
# block's own patterns would match themselves.
s42=""; n42=0; have42=""
for f42 in global/protocols/*.md global/hooks/*.py global/hooks/*.sh global/hooks/git/* global/skills/*/SKILL.md docs/*.md global/CLAUDE.md README.md; do
  [ -f "$f42" ] || continue
  n42=$((n42+1))
  case "$f42" in
    global/protocols/backlog.md)            have42="$have42 protocol" ;;
    global/hooks/understand-write-guard.py) have42="$have42 rail" ;;
  esac
  if tr '\n' ' ' < "$f42" | tr -s ' ' | grep -qiE "$NEG42"; then s42="$s42 ${f42##*/}"; fi
done
case "$have42" in
  *protocol*rail*|*rail*protocol*) ;;
  *) s42="$s42 SET-INCOMPLETE(scanned=$n42)" ;;
esac
[ -z "$s42" ] && ok "no shipped document credits a creation-time cause for several sheets" \
             || bad "no shipped document credits a creation-time cause for several sheets (:$s42)"

if [ -n "$M6CUT42" ] && [ "$M6CUT42" != "$M6_42" ]; then
  # Each layout bound to the mechanism claim that distinguishes it, not named by a bare word: the words
  # alone were carried by a neighbouring sentence, so the pair could be deleted whole with this green.
  #
  # Both layouts sit in ONE sentence, joined by a semicolon, and each half repeats the other's vocabulary
  # — `ignored paths` stands beside `the pattern file selects nothing` in the committed half. Read whole,
  # a same-sentence leg cannot tell which half made the claim, and the committed clause alone would answer
  # the ignored leg. So the region is cut at the semicolon and each leg reads its own clause only, which is
  # this block's own idiom, already used to cut the third-layout sentence away. The cut is asserted: a
  # rewrite that separates the two layouts leaves both halves equal to the whole and the legs weaker than
  # they read, and that is reported rather than passed over.
  M6IGN42="${M6CUT42%%; where the project*}"
  M6COM42="${M6CUT42#*; where the project}"
  m42c=""
  [ "$M6IGN42" != "$M6CUT42" ] || m42c="$m42c layout-clause-cut-found-nothing"
  [ "$(insent "$M6IGN42" 'ignor[a-z]*' 'pattern file' 'wholesale|the copy')" = 1 ] \
    || m42c="$m42c ignored-layout-not-bound-to-the-pattern-file"
  [ "$(insent "$M6COM42" 'commit[a-z]*' 'git carried|selects nothing')" = 1 ] \
    || m42c="$m42c committed-layout-not-bound-to-its-cause"
  # `every folder` is the object of the prune, and it is what keeps the both-layouts half from answering
  # the first part on its own: that half carries `the prune does not`, so with a bare verb the leg stayed
  # green with its two halves in different sentences — measured, not supposed.
  [ "$(insent "$M6CUT42" 'prun[a-z]*' 'every folder' 'both|either|each' 'layout')" = 1 ] \
    || m42c="$m42c prune-not-required-on-both-layouts"
  [ -z "$m42c" ] && ok "the seed-and-prune move names both layouts and the prune required on each" \
                 || bad "the seed-and-prune move names both layouts and the prune required on each (:$m42c)"
else
  bad "the seed-and-prune move names both layouts and the prune required on each (move not found, or the third-layout sentence is absent so the cut could not be made)"
fi

# The edge case, guarded on its own so the two sentences stop propping each other up: a data directory
# neither ignored nor tracked is the documented precondition failing and not a third layout.
if [ -n "$M6_42" ]; then
  printf '%s' "$M6_42" | grep -qiE 'neither ignored nor tracked[^.]{0,140}third layout|third layout[^.]{0,140}precondition' \
    && ok "a workspace neither ignored nor tracked is named as the precondition failing, not a third layout" \
    || bad "a workspace neither ignored nor tracked is named as the precondition failing, not a third layout"
else
  bad "a workspace neither ignored nor tracked is named as the precondition failing, not a third layout (no move)"
fi

# The adopter's copy of the two-layout rationale. The pair is the point: a rule stated in the protocol and
# not in the guide an adopter actually reads is a rule half the readership never sees.
if [ -n "$DOCD42" ]; then
  m42d=""
  printf '%s' "$DOCD42" | grep -qiE 'ignore[^.]{0,140}pattern' \
    || m42d="$m42d ignored-layout-not-bound-to-the-patterns"
  printf '%s' "$DOCD42" | grep -qiE 'commit[^.]{0,140}(git carried|select nothing|selects nothing)' \
    || m42d="$m42d committed-layout-not-bound-to-its-cause"
  [ -z "$m42d" ] && ok "the adopter guide carries the same two-layout rationale as the ceremony" \
                 || bad "the adopter guide carries the same two-layout rationale as the ceremony (:$m42d)"
else
  bad "the adopter guide carries the same two-layout rationale as the ceremony (data condition not found)"
fi
