# C104 — an inventory paired with its own exit check must name the same subjects, or a later edit to
# either list drifts from the other with the suite still green. Authored during Verify as a repair leg
# (Verify protocol > "The acceptance rule for a repair leg"): its own falsifier was run first — the
# changelog item removed from the inventory list alone — and confirmed red before this leg existed to
# catch it, then reverted.
#
# The verdict is a `diff` between two INDEPENDENTLY extracted spans of the same document, never one span
# read against a pattern this section invents: that is what tells this leg apart from the shape C98
# refuses new instances of (a pattern and the prose it reads, written by the same actor in the same
# change, detecting only that the prose changed). Here the two sides are each other's check.
echo "== C104: an inventory and its exit check name the same five surfaces =="
BLG104="global/protocols/backlog.md"

# Paragraph-scoped (RS=''), never line-anchored: the two sentences move together as prose around them
# changes, and what must never drift apart is which surfaces each list names -- not their line numbers.
# Each anchor is a substring the source keeps on one physical line, so the paragraph match needs no
# cross-newline regex; the multi-line join happens only after the record is already selected.
INV104="$(awk -v RS='' '/Start by/' "$BLG104" | tr '\n' ' ' | tr -s ' ')"
EXIT104="$(awk -v RS='' '/Exit check/' "$BLG104" | tr '\n' ' ' | tr -s ' ')"

# The list segment alone, between its own anchor and its own terminator -- never the whole paragraph,
# which also carries the surrounding sentence and would let an edit anywhere in it satisfy a keyword count.
INVLIST104="$(printf '%s' "$INV104" | sed -E 's/.*ounting\*\*: *//; s/ *\. *Five counts.*//')"
EXITLIST104="$(printf '%s' "$EXIT104" | sed -E 's/.*reads zero: *//; s/\.[[:space:]]*$//')"

tags104() {  # $1 = a ';'- or ','-delimited list -> one canonical tag per item, one per line, in order
  printf '%s\n' "$1" | tr ';' ',' | tr ',' '\n' | while IFS= read -r item; do
    case "$item" in
      *[Bb]rief*)    printf 'brief\n' ;;
      *inline*)      printf 'inline\n' ;;
      *[Nn]otes*)    printf 'STATE.md.Notes\n' ;;
      *[Ii]cebox*)   printf 'Icebox\n' ;;
      *changelog*)   printf 'changelog\n' ;;
      *)             printf 'UNKNOWN(%s)\n' "$item" ;;
    esac
  done
}

if [ -z "$INV104" ] || [ -z "$EXIT104" ]; then
  bad "the inventory and its exit check name the same five surfaces, in the same order (a paragraph was not found)"
else
  # A floor before the equality: an extractor that returns nothing satisfies `diff` over two empty streams
  # as readily as it satisfies a real match, and reads in a report exactly like a row that passed.
  D104="$(diff <(tags104 "$INVLIST104") <(tags104 "$EXITLIST104"))"
  N_INV104="$(tags104 "$INVLIST104" | grep -c .)"
  N_EXIT104="$(tags104 "$EXITLIST104" | grep -c .)"
  if [ -z "$D104" ] && [ "${N_INV104:-0}" -eq 5 ] && [ "${N_EXIT104:-0}" -eq 5 ]; then
    ok "the inventory and its exit check name the same five surfaces, in the same order"
  else
    bad "the inventory and its exit check name the same five surfaces, in the same order (inv=${N_INV104:-0} exit=${N_EXIT104:-0}${D104:+; diff: }${D104})"
  fi
fi
