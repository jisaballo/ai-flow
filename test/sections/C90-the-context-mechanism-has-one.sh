# C90 -- the context mechanism has one home, and every reader routes to it.
# Generated in the Conform phase from the Verifiable Criteria of the task that makes
# `global/protocols/context.md` the single home of the mechanism governing every context file. Written RED
# and turned green step by step: A1 at the home's birth, A2/A3/A5 with the engine's routes, A4/A6 with the
# adopter-facing surface.
#
# A NEW block rather than legs bolted onto the architecture-card check or onto one of the three existing
# home sweeps: the concepts guarded here are the context mechanism's, and the sweep they would otherwise
# join carries three file sets and three detector idioms whose consolidation is a rewrite of two other
# guards' headers -- work a task that opened neither of them must not do.
#
# Every region is extracted before it is read and every leg guards its own region: a negative asked of an
# empty region answers "clean", so a renamed heading would otherwise certify a document that says nothing.
echo "== C90: the context mechanism has one home, and every reader routes to it =="

# One name per path, declared before any leg reads one: six legs read overlapping sets, and two spellings
# of a path are two things to keep in step.
CTX90="global/protocols/context.md"
UND90="global/protocols/understand.md"
EXE90="global/protocols/execute.md"
BLG90="global/protocols/backlog.md"
PLN90="global/protocols/plan.md"
DSC90="global/protocols/discover.md"
USK90="global/skills/understand/SKILL.md"
ESK90="global/skills/execute/SKILL.md"
CUS90="docs/customization.md"
GST90="docs/getting-started.md"
RDM90="README.md"
TPR90="template/.ai-flow/product.md"
TYM90="template/.ai-flow/project.yml"

# The fenced block inside a section: what A4 measures for the three homes that quote a skeleton rather
# than being one.
fen90() { sec90 "$1" "$2" | awk '/^```/{c=1-c; next} c'; }
# One clause per line, split on the sentence end and never inside a filename -- `. ` ends a sentence,
# `.md` does not. A3 reads clauses rather than files for a reason its own comment states.
clauses90() { printf '%s' "$1" | tr '\n' ' ' | tr -s ' ' | sed 's/\. /.\n/g'; }


# --- the regions, extracted once ------------------------------------------------------------------
CTXB90="$([ -r "$CTX90" ] && tr '\n' ' ' < "$CTX90" | tr -s ' ')"
CLS90="$(sec90 "$CTX90" '^## The classes')"
UPC90="$(sec90 "$UND90" '^## Product Context')"
USF90="$(sec90 "$UND90" '^## Steering Files')"
ESF90="$(sec90 "$EXE90" '^## Steering Files')"
CHK90="$(sec90 "$BLG90" '^### After ARCHIVE')"
NANOSEC90="$(sec90 "$BLG90" '^### Steering Nano Blocks')"
DSC5_90="$(sec90 "$DSC90" '^## 5\. Suggest steering')"
USL90="$(grep -m1 -i 'steering:. map' "$USK90" 2>/dev/null)"
USK4_90="$(grep -m1 -F 'product.md` — ALWAYS' "$USK90" 2>/dev/null)"
# The template's steering comment, from its lead line to the key it documents. A former home that is
# not markdown: the corpus A3 computes is `-name '*.md'`, so no derived leg reaches a `.yml` and this
# region is the only thing that does.
TYMS90="$([ -r "$TYM90" ] && awk '/^# Map an area to its steering file/{f=1} f{print} /^steering:/{if(f)exit}' "$TYM90" | tr '\n' ' ' | tr -s ' ')"
ESL90="$(grep -m1 -i 'steering:. map' "$ESK90" 2>/dev/null)"
CUSP90="$(sec90 "$CUS90" '^### Product Context')"
CUSS90="$(sec90 "$CUS90" '^### Steering Files')"
RDMS90="$(sec90 "$RDM90" '^### Steering Files')"
RDMD90="$(sec90 "$RDM90" '^## Documentation')"
PFEN90="$([ -r "$PLN90" ] && awk '/^```/{c=1-c;next} c' "$PLN90")"
PREG90="$(printf '%s\n' "$PFEN90" | awk '/^## Decision Register/{f=1;next} /^## /{f=0} f') $(grep -m1 '^2\. \*\*Decision Register' "$PLN90" 2>/dev/null)"
# The checklist's two writing moves, by the act each performs rather than by where it sits.
S1_90=""; S2_90=""
if [ -n "$CHK90" ]; then
  n1_90="$(step_no 'steering update' "$CHK90" 2>/dev/null || true)"
  n2_90="$(step_no 'product\.md write-back' "$CHK90" 2>/dev/null || true)"
  [ -n "$n1_90" ] && S1_90="$(itm90 "$n1_90" "$CHK90")"
  [ -n "$n2_90" ] && S2_90="$(itm90 "$n2_90" "$CHK90")"
fi

# --- the route table, defined once and read twice ------------------------------------------------
# ONE list for the route and its destination. A2 reads every field to prove each former home routes;
# A1 reads the FACT field to prove the home states what those routes hand over. Written as two lists
# they drift in the direction that leaves nine routes pointing at a document nothing reads -- which is
# the state this block shipped in, and the state a mutation proved by deleting 60 lines of the home
# with every leg green.
#
# Fields, `~`-separated because every pattern field carries EREs of its own:
#   label ~ region variable ~ the fact the route hands over ~ the sentence it replaces (`-` for none)
# bash 3.2 cannot parse an apostrophe inside a quoted heredoc nested in a command substitution,
# and every label below carries one -- so the table is a double-quoted multi-line string. No row
# may contain a double quote, `$` or a backtick; the assertion below counts the rows read, which is
# what catches a row that a quoting mistake silently swallowed.
ROUTES90=13
ROUTETBL90="understand's product-context section~UPC90~identity|what it is|class~living domain model
understand's steering section~USF90~nano|cuts~one line per rule
understand's steering section, its second fact~USF90~map's value~conventional place and not the only one
execute's steering section~ESF90~re-read|cuts|sections~Understand protocol
the checklist's steering move~S1_90~where a lesson goes|places it|topic~touches only one of the two
the checklist's product write-back~S2_90~business rule|its key|topic~re-asked or re-assumed
discover's steering step~DSC5_90~shape|mechanism|how a context file~-
the understand skill's steering line~USL90~nano|cuts~Nano block first
the execute skill's steering line~ESL90~re-read|cuts|sections~-
customization's product section~CUSP90~governs|shaped|read|written|kept~provides business context
customization's steering section~CUSS90~cut|read|written|kept~-
the understand skill's product line~USK4_90~class|what the file is~living domain model
the template's steering comment~TYMS90~value means|shaped|read|written|kept~the map's value|whatever path it names"

# --- E0: every region this block reads extracts ---------------------------------------------------
# A leg over an empty region draws no verdict, so the emptiness is reported HERE, once, with the region
# named. Eighteen regions across three steps: at the freeze all but a few are absent by construction.
e0_90=""
for pair90 in \
  "the mechanism's home:$CTXB90" \
  "its classes table:$CLS90" \
  "understand's product-context section:$UPC90" \
  "understand's steering section:$USF90" \
  "execute's steering section:$ESF90" \
  "the archive checklist:$CHK90" \
  "the checklist's steering move:$S1_90" \
  "the checklist's product-write-back move:$S2_90" \
  "the plan register's marker region:$PREG90" \
  "discover's steering step:$DSC5_90" \
  "the understand skill's steering line:$USL90" \
  "the understand skill's product line:$USK4_90" \
  "the execute skill's steering line:$ESL90" \
  "customization's product section:$CUSP90" \
  "customization's steering section:$CUSS90" \
  "the README's steering section:$RDMS90" \
  "the README's documentation list:$RDMD90" \
  "the template's steering comment:$TYMS90" \
; do
  [ -n "${pair90#*:}" ] || e0_90="$e0_90 [${pair90%%:*} did not extract]"
done
[ -z "$e0_90" ] && ok "E0 every region C90 reads extracts" \
                || bad "E0 every region C90 reads extracts ($e0_90)"

# --- A1: the home is readable, and carries the classes table and the visibility rule --------------
# The classes table is counted, not grepped: a table whose rows were deleted leaves a header and a
# separator, and every name-keyed leg over the section is then answered by the header's own words.
a1_90=""
if [ -z "$CTXB90" ]; then
  a1_90=" [$CTX90 is unreadable or empty -- no verdict drawn from an absent home]"
else
  if [ -z "$CLS90" ]; then
    a1_90="$a1_90 [the classes table's section did not extract]"
  else
    # `^| ` selects the header and the class rows and never the separator, whose own pipe is followed by
    # a dash -- so the separator is asserted on its own rather than subtracted from a count it is not in.
    ROWS90="$(printf '%s\n' "$CLS90" | grep -c '^| ' | tr -d ' ')"
    BODY90=$((ROWS90 - 1))
    [ "$(printf '%s\n' "$CLS90" | grep -cE '^\|[ -]*-{3}' | tr -d ' ')" -ge 1 ] \
      || a1_90="$a1_90 [the classes table has no separator -- it is not a table]"
    [ "$BODY90" = 3 ] || a1_90="$a1_90 [the classes table states $BODY90 classes, not three]"
    for c90 in 'steering' 'product\.md' 'decisions-global\.md'; do
      [ "$(printf '%s\n' "$CLS90" | grep -cE "^\|[^|]*$c90" | tr -d ' ')" = 1 ] \
        || a1_90="$a1_90 [no single row of the classes table is the $c90 class]"
    done
    # Three cells at least: a class row states what it is AND what it answers, and a two-cell row
    # states only the first while reading green to every name-keyed leg above.
    MINC90="$(printf '%s\n' "$CLS90" | grep '^| ' | awk -F'|' '{print NF-2}' | sort -n | head -1)"
    [ -n "$MINC90" ] && [ "$MINC90" -ge 3 ] \
      || a1_90="$a1_90 [a row of the classes table carries fewer than three cells]"
  fi
  # The visibility rule as ONE adjacency binding its predicate to its subject. Two loose words in the
  # region accept the claim negated, and accept an exchange that quotes the wrong reading beside the
  # right one.
  nearok90 "$(near90 "$CTXB90" 'CLAUDE\.md' 'nothing (of this mechanism|of the mechanism)' 200)" \
    || a1_90="$a1_90 [the visibility rule never binds CLAUDE.md to what must not be written there]"
  # The three measures are NAMED and carry no value: the numbers live in the check script alone, and a
  # document that breaks its own one-number-one-home rule in its first commit is the one nobody keeps.
  for m90 in 'nano line length' 'section length' 'sections per file'; do
    [ "$(printf '%s' "$CTXB90" | grep -ciE "$m90" | tr -d ' ')" -ge 1 ] \
      || a1_90="$a1_90 [the measure '$m90' is not named]"
    nearzero90 "$(near90 "$CTXB90" "$m90" '[0-9]' 60)" \
      || a1_90="$a1_90 [the measure '$m90' carries a value]"
  done
  # DERIVED from the route table A2 also reads: the home states every fact its routes hand over. One
  # list for the route and its destination, so a row added there immediately demands its fact of the
  # home and a route can never point at a section nobody wrote.
  nf1_90=0
  while IFS='~' read -r l1_90 r1_90 f1_90 d1_90; do
    [ -n "$f1_90" ] || continue
    nf1_90=$((nf1_90 + 1))
    [ "$(printf '%s' "$CTXB90" | grep -ciE "$f1_90" | tr -d ' ')" -ge 1 ] \
      || a1_90="$a1_90 [the home states nothing of '$f1_90', which $l1_90 hands over]"
  done <<< "$ROUTETBL90"
  [ "$nf1_90" = "$ROUTES90" ] \
    || a1_90="$a1_90 [$nf1_90 of $ROUTES90 route facts were read from the table]"
  # And each fact bound to its OWN CLAIM rather than to a word the document uses elsewhere. The derived
  # leg above couples the two lists; this is what makes the coupling load-bearing, because a fact field
  # is an alternation written for the ROUTE's wording -- `topic` alone occurs in `## Three cuts`, so the
  # alternation survives the deletion of the section that actually states the rule. That is not a
  # hypothesis: a mutation deleted `## Writing` and `## Keeping`, 60 of the home's 165 lines, and every
  # leg of this block stayed green. Each pair below was measured to hold before it was written, and each
  # lives in exactly one section, so deleting a section reddens the claims that section owns.
  for claim90 in \
    'affected~reserved .?workspace' \
    'aggregate line~completion criterion' \
    'task in flight~writes no context file' \
    'Does every task in the repository need it~workspace file' \
    'Does every consumer of the domain need it~domain file' \
    'nano line of the edited section~rewritten from that section' \
    'context-check~reads only' \
    'guard opens on two keys~sanctioned moment' \
    'rule is this paragraph~adapter is its rail' \
    'A file that fails the check is repaired~first task' \
    'monorepo is the general case~degenerate' \
    'Everything known about one topic~one heading' \
    'nano~index of pointers' \
  ; do
    nearok90 "$(near90 "$CTXB90" "${claim90%%~*}" "${claim90#*~}" 200)" \
      || a1_90="$a1_90 [the home does not bind '${claim90%%~*}' to '${claim90#*~}']"
  done
fi
[ -z "$a1_90" ] && ok "A1 the mechanism's home carries the classes table, the visibility rule, and every fact its routes hand over" \
                || bad "A1 the mechanism's home carries the classes table, the visibility rule, and every fact its routes hand over:$a1_90"

# --- A2: every former home routes, naming the home AND the fact, and the replaced sentence is gone --
# The list is HAND-KEPT, for the reason the task's papers record: the set of relocated facts is prose with
# no machine-readable enumeration to derive a negative from. What makes a hand list safe is A3 below,
# which is computed over the engine's own files and names a former home this list forgot. Three rows hand
# over a fact without losing a sentence -- they gained a pointer where there was none -- and their dead
# field is `-` rather than a pattern nobody wrote.
#
# THE COUNT WAS TAKEN FROM THE PLAN AND THE PLAN WAS WRONG. The papers said ten former homes and this
# list said nine; the tree holds twelve. Four rows were added after the audit found the gap -- and two of
# the four had their regions extracted and floor-checked here while no leg read them, which is the
# fingerprint of legs intended and dropped. A hand list is only as complete as the count that built it,
# so the count is now stated as a number this leg asserts (ROUTES90) against rows nobody can drop
# silently, and A1 below demands of the home every fact THIS list hands over -- one source for the route
# and its destination, so a row added here cannot leave the home unasserted.
#
# One row is not a resolver and is not markdown: the template's steering comment. A3's corpus is
# `-name '*.md'`, so no derived leg reaches a `.yml` at all, and its negative here is the ONLY thing that
# catches a copy of the map's-value rule in that file. C88 A6 counts it too, and cannot see that shape:
# the copy sat in the same clause as the route, and that row discounts a clause naming the home.
#
# Fields, `~`-separated because every pattern field carries EREs of its own:
#   label ~ region variable ~ the fact the route hands over ~ the sentence it replaces (`-` for none)
n2_90=0
a2_90=""
while IFS='~' read -r l2_90 r2_90 f2_90 d2_90; do
  [ -n "$l2_90" ] || continue
  n2_90=$((n2_90 + 1))
  reg2_90="${!r2_90}"
  if [ -z "$reg2_90" ]; then
    a2_90="$a2_90 [$l2_90: its region did not extract]"; continue
  fi
  [ "$(printf '%s' "$reg2_90" | tr '\n' ' ' | grep -ciE 'context\.md' | tr -d ' ')" -ge 1 ] \
    || { a2_90="$a2_90 [$l2_90 names no home]"; continue; }
  nearok90 "$(near90 "$reg2_90" 'context\.md' "$f2_90" 200)" \
    || a2_90="$a2_90 [$l2_90 names its home and not the fact it hands over]"
  [ "$d2_90" = '-' ] && continue
  [ "$(printf '%s' "$reg2_90" | tr '\n' ' ' | grep -ciE "$d2_90" | tr -d ' ')" = 0 ] \
    || a2_90="$a2_90 [$l2_90 kept the sentence its route replaced]"
done <<< "$ROUTETBL90"
[ "$n2_90" = "$ROUTES90" ] \
  || a2_90="$a2_90 [$n2_90 of $ROUTES90 route rows were read -- a row was dropped from the list]"
# The retired section is an ABSENCE and has no route of its own: a heading kept beside the new home is a
# second home wearing a pointer's clothes.
[ -z "$NANOSEC90" ] || a2_90="$a2_90 [the retired steering-nano section is still in the ledger protocol]"
[ -z "$a2_90" ] && ok "A2 every former home routes, naming its home and the fact, with the old sentence gone" \
                || bad "A2 every former home routes, naming its home and the fact, with the old sentence gone:$a2_90"

# --- A3: the relocated concepts have exactly one home, over a set computed from the tree -----------
# The derived complement of A2's hand list, and the reason that list is safe: a former home nobody
# remembered to add there is named HERE. The corpus is computed, prose only, and excludes three things
# by name, each for a stated reason:
#   - the home itself, which is where every concept below is supposed to live;
#   - `docs/context/`, the epic's DEFINITION layer, which the rows of this epic cite as their source and
#     which therefore states the mechanism on purpose until the epic retires it;
#   - `docs/architecture/README.md`, whose nano rule governs the ARCHITECTURE CARD -- a class outside this
#     mechanism, with a guard of its own -- and whose one reference to the steering nano is an
#     acknowledged analogy, not a second statement of this rule.
# Scripts and hooks are outside the corpus because the rule is the paragraph and a hook is its rail: a
# rail that names the mechanism is not a home of it.
SET90="$(find global docs template examples README.md -type f -name '*.md' 2>/dev/null \
          | grep -v '^docs/context/' | grep -vF "$CTX90" \
          | grep -v '^docs/architecture/README\.md$' | sort)"
a3_90=""
N3_90="$(printf '%s\n' "$SET90" | grep -c . | tr -d ' ')"
[ "$N3_90" -ge 20 ] || a3_90="$a3_90 [the corpus computed $N3_90 files -- no verdict drawn from a set that small]"
printf '%s\n' "$SET90" | grep -qE '^(test/|\.ai-flow/)' \
  && a3_90="$a3_90 [the corpus reaches the suite or the ledger, which name these concepts to guard them]"
if [ -n "$a3_90" ]; then :; else
  while IFS='~' read -r cn90 ce90 na90 nb90; do
    [ -n "$cn90" ] || continue
    for f3_90 in $SET90; do
      # An unread file is empty, an empty file matches nothing, and nothing is green -- in the leg that
      # exists to be A2's safety net. Reported, never inferred.
      [ -r "$f3_90" ] && [ -s "$f3_90" ] || { a3_90="$a3_90 [$f3_90 is in the corpus and could not be read]"; continue; }
      b3_90="$(tr '\n' ' ' < "$f3_90" | tr -s ' ')"
      # Counted per CLAUSE, and a clause that names the mechanism's home is a ROUTE rather than a home:
      # every route this task writes names the fact it hands over, so a file-wide marker count reports
      # the pointer as the thing it points at -- which is what it did, on four files, before this line.
      # The trade is stated once here and in the task's manifest: a second home that names `context.md`
      # in the same clause as its own rule is not seen, and A2's negative over each named home is what
      # covers that shape.
      hit90="$(clauses90 "$b3_90" | grep -iE "$ce90" | grep -civE 'context\.md' | tr -d ' ')"
      if [ "$na90" != '-' ]; then
        hit90=$((hit90 + $(clauses90 "$b3_90" | grep -iE "$na90" | grep -iE "$nb90" \
                             | grep -civE 'context\.md' | tr -d ' ')))
      fi
      [ "$hit90" -ge 1 ] && a3_90="$a3_90 [$f3_90 states $cn90 in $hit90 clause(s)]"
    done
  done <<CONCEPTS_90
the classes table~living domain model|provides business context|Read this file at the start of~-~-
the three cuts~three cuts|sections are topics~nano~derived from the body|one line per rule
the write questions~every task in the repository need|Does every consumer of the domain|twist on a shared topic~-~-
the keeping rules~repair moves forward|repaired by the first task|sanctioned moment|declared decision~-~-
CONCEPTS_90
fi
[ -z "$a3_90" ] && ok "A3 the relocated concepts have one home, over a corpus computed from the tree" \
                || bad "A3 the relocated concepts have one home, over a corpus computed from the tree:$a3_90"

# --- A4: every shipped steering shape is a topic shape with a nano ---------------------------------
# The examples are GLOBBED and the skeletons named: a fourth example added later is measured by the row
# that already exists, which a hand list would not do. Each shape is proven to extract before its two
# legs run -- an absent skeleton satisfies a negative and states nothing.
a4_90=""
EX90="$(ls examples/steering-*.md 2>/dev/null | sort)"
NEX90="$(printf '%s\n' "$EX90" | grep -c . | tr -d ' ')"
[ "$NEX90" -ge 2 ] || a4_90="$a4_90 [the shipped example set globbed $NEX90 files]"
for e4_90 in $EX90; do
  [ -s "$e4_90" ] || { a4_90="$a4_90 [$e4_90 is empty]"; continue; }
  grep -qE '^## Nano' "$e4_90" || a4_90="$a4_90 [$e4_90 carries no nano block]"
  old90="$(grep -cE '^## (Rules|Patterns|Pitfalls) *$' "$e4_90" | tr -d ' ')"
  [ "$old90" = 0 ] || a4_90="$a4_90 [$e4_90 still carries $old90 of the old skeleton's headings]"
done
for pair4_90 in \
  "$CUS90~^### Steering Files" \
  "$RDM90~^### Steering Files" \
  "$GST90~^### 5\. " \
; do
  f4_90="${pair4_90%%~*}"; h4_90="${pair4_90#*~}"
  blk4_90="$(fen90 "$f4_90" "$h4_90")"
  if [ -z "$blk4_90" ]; then
    a4_90="$a4_90 [$f4_90's skeleton block did not extract]"; continue
  fi
  printf '%s\n' "$blk4_90" | grep -qE '^## Nano' \
    || a4_90="$a4_90 [$f4_90's skeleton teaches no nano block]"
  o4_90="$(printf '%s\n' "$blk4_90" | grep -cE '^## (Rules|Patterns|Pitfalls) *$' | tr -d ' ')"
  [ "$o4_90" = 0 ] || a4_90="$a4_90 [$f4_90's skeleton still teaches $o4_90 of the old headings]"
done
[ -z "$a4_90" ] && ok "A4 every shipped steering shape is a topic shape with a nano" \
                || bad "A4 every shipped steering shape is a topic shape with a nano:$a4_90"

# --- A5: the write moment names its marker and its destination ------------------------------------
# The move is located by the act it performs, so the item this task inserts does not shift a leg onto its
# neighbour, and the marker is bound to its destination in one clause rather than counted twice loosely.
a5_90=""
if [ -z "$CHK90" ]; then
  a5_90=" [the archive checklist did not extract]"
else
  g5_90=""
  n5_90="$(step_no 'decisions-global|global decision' "$CHK90" 2>/dev/null || true)"
  [ -n "$n5_90" ] && g5_90="$(itm90 "$n5_90" "$CHK90")"
  if [ -z "$g5_90" ]; then
    a5_90="$a5_90 [no checklist move writes the global decision]"
  else
    nearok90 "$(near90 "$g5_90" 'decisions-global\.md' '\(global\)|marked global' 200)" \
      || a5_90="$a5_90 [the global-decision move names its destination and not the marker that selects it]"
  fi
  nearok90 "$(near90 "$PREG90" '\(global\)|marked global' 'decisions-global' 200)" \
    || a5_90="$a5_90 [the plan register documents no global marker with its destination]"
fi
[ -z "$a5_90" ] && ok "A5 the write moment names its marker and its destination" \
                || bad "A5 the write moment names its marker and its destination:$a5_90"

# --- A6: the adopter surface routes, and the template declares its reserved key -------------------
a6_90=""
if [ ! -r "$TPR90" ] || [ ! -s "$TPR90" ]; then
  a6_90="$a6_90 [the template's product file is unreadable or empty]"
else
  # Keyed on the SHAPE rather than on the sentence the old header happened to use: any rewording passed a
  # single retired literal. What every self-describing header has in common is its position -- prose
  # between the title and the first section, where the file talks about itself instead of holding data.
  hdr90="$(awk 'NR>1 && /^## /{exit} NR>1{print}' "$TPR90")"
  [ "$(printf '%s\n' "$hdr90" | grep -cE '^[>*_]|^[A-Za-z]' | tr -d ' ')" = 0 ] \
    || a6_90="$a6_90 [the template's product file describes itself between its title and its first section]"
fi
if [ ! -r "$TYM90" ]; then
  a6_90="$a6_90 [the template's project.yml is unreadable]"
else
  nearok90 "$(near90 "$(tr '\n' ' ' < "$TYM90")" 'workspace' 'reserved' 200)" \
    || a6_90="$a6_90 [the template never declares workspace a reserved key]"
fi
# The definition's second surface is the README's DOCUMENTATION list, beside the architecture card it
# already carries -- not the Project Structure tree, which draws an adopter's own project and the engine
# as installed. A repo-relative docs path has no place in that tree, and a leg over it passed on the word
# `context` in an unrelated comment, which is how the substitution was found.
if [ -z "$RDMD90" ]; then
  a6_90="$a6_90 [the README's documentation list did not extract]"
else
  printf '%s\n' "$RDMD90" | grep -qF 'docs/context' \
    || a6_90="$a6_90 [the README's documentation list links no definition directory]"
fi
if [ -z "$RDMS90" ]; then
  a6_90="$a6_90 [the README's steering section did not extract]"
else
  printf '%s\n' "$RDMS90" | grep -qF 'docs/context' \
    || a6_90="$a6_90 [the README's steering section links no definition directory]"
fi
[ -z "$a6_90" ] && ok "A6 the adopter surface routes, and the template declares its reserved key" \
                || bad "A6 the adopter surface routes, and the template declares its reserved key:$a6_90"
