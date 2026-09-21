# C91 -- the mechanism's measures are computed by one script.
# Generated in the Conform phase from the Verifiable Criteria of the task that gives the context mechanism
# the check it already names. Written RED -- A1-A7 and A11 fail while `global/scripts/context-check.sh`
# does not exist, A9 fails on prose that still takes the default set from the map, A10 on two archive moves
# that name no check -- and turned green step by step: A1-A6 and A11 with the measure and the skeletons,
# A7 with the delivery, A8-A10 with the prose.
#
# Eight of the eleven legs RUN the script against real fixtures rather than reading prose about it. Each of
# the seven rules gets a fixture that breaks it and only it, beside one that is in shape: a rule asserted in
# one direction alone is satisfied by a check that fails everything, or by one that fails nothing. Each
# fixture also asserts that no OTHER rule fails on it, which is what makes "and only it" a measurement.
#
# C90's helpers are reused BY NAME -- `sec90`, `near90`, `nearok90`, `nearzero90` -- and not re-declared
# with a 91 suffix; the numbered-item extractor is `nitem`, which is the shared preamble's and no longer
# C90's to lend. A concept written out twice is a concept that will be written out differently twice, and
# the sentence-window helper carries three corrections in its own comment that a copy would not inherit.
#
# Every adjacency pair below was probed against the current documents before it was written, by lifting
# those helpers by name into a scratchpad -- no repository change, no snapshot. Two of the first drafts came
# back `E`: the machine's grep is ugrep, and it REFUSED `steering directory|directory.{0,20}steering` and a
# four-way alternation windowed at 80 as exceeding its complexity limits. A refusal read as an absence is a
# leg that passes forever, so every pattern here is one claim, with no bounded repeat inside an alternation.
echo "== C91: the mechanism's measures are computed by one script =="

CHK91="global/scripts/context-check.sh"
BLG91="global/protocols/backlog.md"
CTXP91="global/protocols/context.md"
CTXD91="docs/context/context.md"
STG91="docs/context/steering.md"
TPR91="template/.ai-flow/product.md"
TDG91="template/.ai-flow/decisions-global.md"

# The three numbers, declared once so every leg reads the same value. A leg spelling a threshold inline
# would go green against a check that applies a different one.
NANOMAX91=200
SECMAX91=450
SECCNT91=10

# The seven rule identifiers a verdict names, and the marker a failing verdict carries. Frozen in the
# conformance manifest: the check's sentences are free to change during Execute, these tokens are not,
# because A3 asks that a failure name the rule and a leg keyed on a sentence would be a leg about wording.
RULES91="nano-present nano-order nano-line-length section-length section-count app-key marker"
FAILMK91="FAIL"

BOX91="$(mkbox)" || fatal 'the context-check fixtures'
OUT91="$BOX91/out"

# Run the check inside a checkout and leave its output in a file. Two things are deliberate. The status
# reaches the caller through the substitution and the OUTPUT goes to a FILE -- a variable assigned inside
# `$( )` dies with the subshell, so a helper reporting both out of band would report neither. And the `cd`
# is checked and confined to a subshell: unchecked, a failed `cd` runs the check against this repository
# and scores fixtures that were never read.
run91() {  # $1 = the checkout to run in; $2... = the check's own arguments
  local d="$1"; shift
  ( cd "$d" && bash "$ROOT/$CHK91" "$@" ) > "$OUT91" 2>&1
  printf '%s' "$?"
}

# Every rule but the named one must come back clean on a fixture built to break that one. This is what
# turns each fixture into a measurement of its own rule rather than of the check's general unhappiness.
only91() {  # $1 = the rule the fixture breaks
  local r o=""
  for r in $RULES91; do
    [ "$r" = "$1" ] && continue
    grep -F "$FAILMK91" "$OUT91" | grep -q -- "$r" && o="$o [the $1 fixture also fails ${r}]"
  done
  printf '%s' "$o"
}

# A steering file that is in shape: two topics, one nano line per topic in body order, each opening with
# its section title in bold. Every fixture below is derived from it, so a deriver breaks one rule.
good91() {  # $1 = the file to write
  cat > "$1" <<'SHAPED'
# Payments

## Nano

- **Idempotency** — every write carries a key of the caller and a repeat is a no-op.
- **Refund flow** — a refund is a new record and never an edit of the charge it reverses.

## Idempotency

The key belongs to the caller and the store rejects a repeat.

## Refund flow

A refund never edits the charge it reverses.
SHAPED
}

# A skeleton project: `.ai-flow/` with the two fixed files in shape and a steering directory.
mk91() {  # $1 = the checkout root to build
  mkdir -p "$1/.ai-flow/steering"
  cat > "$1/.ai-flow/product.md" <<'PROD'
# Product Context

## Nano

- **Product** — one gateway, sold to marketplaces, billed per settled transaction.
- **Rules: checkout — totals** — a total is recomputed on the server and never trusted from the client.

## Product

A payment gateway sold to marketplaces.

## Rules: checkout — totals

A total is recomputed on the server. (T-001)
PROD
  cat > "$1/.ai-flow/decisions-global.md" <<'DEC'
# Global Decisions

## Nano

- **2026-01-01 - Settlement is nightly** — settlement runs nightly and never on the request path.

## 2026-01-01 - Settlement is nightly

Context: the request path cannot carry it. Decision: nightly. Alternatives: inline, rejected for latency.
DEC
  printf 'steering: {}\n' > "$1/.ai-flow/project.yml"
}

# --- A1: the check answers each of the seven rules in both directions -----------------------------
a1_91=""
if [ ! -r "$CHK91" ]; then
  a1_91=" [$CHK91 is not there -- no verdict drawn from an absent check]"
else
  A1BOX91="$BOX91/a1"; mk91 "$A1BOX91"
  good91 "$A1BOX91/.ai-flow/steering/payments.md"
  # The clean direction, asked of every rule at once: a verdict per rule, and none of them failing.
  rc91="$(run91 "$A1BOX91" .ai-flow/steering/payments.md)"
  [ "$rc91" = 0 ] || a1_91="$a1_91 [a file in shape is not clean (exit ${rc91})]"
  for r91 in $RULES91; do
    grep -q -- "$r91" "$OUT91" || a1_91="$a1_91 [no verdict for the rule ${r91} on a file in shape]"
  done
  for r91 in $RULES91; do
    d91="$BOX91/a1-$r91"; mk91 "$d91"; f91="$d91/.ai-flow/steering/payments.md"
    good91 "$f91"
    case "$r91" in
      nano-present)     awk '!/^## Nano$/ && !/^- \*\*(Idempotency|Refund flow)\*\*/' "$f91" > "$f91.t" \
                          && mv "$f91.t" "$f91" ;;
      # A three-step swap and not a two-step one: `s/a/b/; s/b/a/` sends the first line through both and
      # leaves the file unchanged, which is a fixture that breaks nothing and a leg that proves nothing.
      nano-order)       sed -e 's/^- \*\*Idempotency\*\*/- **XXMARKXX**/' \
                            -e 's/^- \*\*Refund flow\*\*/- **Idempotency**/' \
                            -e 's/^- \*\*XXMARKXX\*\*/- **Refund flow**/' "$f91" > "$f91.t" \
                          && mv "$f91.t" "$f91" ;;
      nano-line-length) pad91="$(awk -v n=$((NANOMAX91 + 40)) 'BEGIN{while(++i<=n)printf "x"}')"
                        sed "s/^- \*\*Idempotency\*\* .*/- **Idempotency** — $pad91/" "$f91" > "$f91.t" \
                          && mv "$f91.t" "$f91" ;;
      section-length)   long91="$(awk -v n=$((SECMAX91 + 20)) 'BEGIN{while(++i<=n)printf "word "}')"
                        printf '%s\n' "$long91" >> "$f91" ;;
      # Built from scratch rather than grown: inserting each nano line under `## Nano` in turn puts them in
      # REVERSE body order, so the fixture broke the ordering rule as well and measured neither.
      section-count)    i91=1; nano91=""; body91=""
                        while [ "$i91" -le $((SECCNT91 + 1)) ]; do
                          nano91="$nano91- **Topic $i91** — a topic of its own.
"
                          body91="$body91
## Topic $i91

A topic of its own.
"
                          i91=$((i91 + 1))
                        done
                        printf '# Payments\n\n## Nano\n\n%s%s' "$nano91" "$body91" > "$f91" ;;
      app-key)          mkdir -p "$d91/apps/checkout"
                        printf 'steering:\n  checkout: .ai-flow/steering/checkout.md\n' \
                          > "$d91/.ai-flow/project.yml"
                        sed -e 's/^- \*\*Refund flow\*\*/- **Refund flow in checkout**/' \
                            -e 's/^## Refund flow$/## Refund flow in checkout/' "$f91" > "$f91.t" \
                          && mv "$f91.t" "$f91" ;;
      marker)           printf '\n# A second title\n\nSomething else entirely.\n' >> "$f91" ;;
    esac
    rc91="$(run91 "$d91" .ai-flow/steering/payments.md)"
    [ "$rc91" != 0 ] || a1_91="$a1_91 [the rule ${r91} is not enforced -- a file breaking it exits 0]"
    grep -F "$FAILMK91" "$OUT91" | grep -q -- "$r91" \
      || a1_91="$a1_91 [the failing verdict for ${r91} does not name the rule]"
    a1_91="$a1_91$(only91 "$r91")"
  done
  # `nano-order` has two failure branches and the loop above reaches only one of them. The positional
  # branch (two titles swapped) is the fixture; the COUNT branch -- a section added and its index line
  # forgotten -- is the commonest real drift and had no fixture at all, which a mutation at the Verify
  # gate proved by dropping the branch and watching the suite stay green.
  A1N91="$BOX91/a1-nano-count"; mk91 "$A1N91"; F1N91="$A1N91/.ai-flow/steering/payments.md"
  good91 "$F1N91"
  grep -v '^- \*\*Refund flow\*\*' "$F1N91" > "$F1N91.t" && mv "$F1N91.t" "$F1N91"
  rc91="$(run91 "$A1N91" .ai-flow/steering/payments.md)"
  [ "$rc91" != 0 ] || a1_91="$a1_91 [an index missing a line for a section it indexes exits 0]"
  grep -F "$FAILMK91" "$OUT91" | grep -q -- 'nano-order' \
    || a1_91="$a1_91 [the count mismatch does not fail nano-order]"
  a1_91="$a1_91$(only91 nano-order)"
  # `nano-line-length` is defined over a LOGICAL bullet -- the check joins an indented continuation onto
  # the bullet above it, so the ceiling does not become a function of the file's wrap width. Every other
  # nano this card writes is a single physical line, so the join was asserted by nothing: deleting it at
  # the Verify gate left the whole suite green. Under the ~100-column discipline these files are written
  # to, a bullet past the ceiling is ALWAYS two or three physical lines, so this is the only shape the
  # rule ever really meets.
  half91="$(awk -v n=$((NANOMAX91 / 2)) 'BEGIN{while(++i<=n)printf "x"}')"
  A1W91="$BOX91/a1-nano-wrap"; mk91 "$A1W91"; F1W91="$A1W91/.ai-flow/steering/payments.md"
  good91 "$F1W91"
  awk -v h="$half91" '/^- \*\*Idempotency\*\*/{print "- **Idempotency** — " h; print "  " h; next} {print}' \
    "$F1W91" > "$F1W91.t" && mv "$F1W91.t" "$F1W91"
  # The fixture is only a measurement of the join if every PHYSICAL line stays inside the ceiling: one
  # long line would be caught by a check that never joined anything, and the leg would prove nothing.
  wide91="$(awk -v m="$NANOMAX91" '/^## /{n=0} /^## Nano$/{n=1;next} n && length($0) >= m {print "x"}' "$F1W91")"
  [ -z "$wide91" ] \
    || a1_91="$a1_91 [the wrapped fixture has a physical nano line at or past the ceiling -- it does not measure the join]"
  rc91="$(run91 "$A1W91" .ai-flow/steering/payments.md)"
  [ "$rc91" != 0 ] || a1_91="$a1_91 [a nano bullet wrapped past the ceiling exits 0 -- the ceiling follows the wrap width]"
  grep -F "$FAILMK91" "$OUT91" | grep -q -- 'nano-line-length' \
    || a1_91="$a1_91 [the wrapped bullet does not fail nano-line-length]"
  a1_91="$a1_91$(only91 nano-line-length)"
  # A map key is the operator's text and reaches the matcher verbatim. Built into an ERE it could be
  # REFUSED rather than unmatched, and a refusal read as an absence prints `ok` for a rule that never
  # ran -- the one shape this card exists to keep out of a verdict. `c++` is the cheapest key that says so.
  A1K91="$BOX91/a1-app-meta"; mk91 "$A1K91"; F1K91="$A1K91/.ai-flow/steering/payments.md"
  good91 "$F1K91"
  mkdir -p "$A1K91/apps/c++"
  printf 'steering:\n  c++: .ai-flow/steering/c++.md\n' > "$A1K91/.ai-flow/project.yml"
  sed -e 's/^- \*\*Refund flow\*\*/- **Refund flow in c++**/' \
      -e 's/^## Refund flow$/## Refund flow in c++/' "$F1K91" > "$F1K91.t" && mv "$F1K91.t" "$F1K91"
  rc91="$(run91 "$A1K91" .ai-flow/steering/payments.md)"
  [ "$rc91" != 0 ] \
    || a1_91="$a1_91 [a key holding a regex metacharacter is not matched -- the rule is skipped or its refusal is read as an absence]"
  grep -F "$FAILMK91" "$OUT91" | grep -q -- 'app-key' \
    || a1_91="$a1_91 [the title naming the application 'c++' does not fail app-key]"
  a1_91="$a1_91$(only91 app-key)"
fi
[ -z "$a1_91" ] && ok "A1 the check answers each of the seven rules in both directions" \
                || bad "A1 the check answers each of the seven rules in both directions:$a1_91"

# --- A2: the default set is where the files live, once each ---------------------------------------
# The set is the steering directory plus the two fixed files, and the MAP is not its input. Both
# directions of that: a steering file the map never declares is measured, and a map entry pointing outside
# the data directory is not.
a2_91=""
if [ ! -r "$CHK91" ]; then
  a2_91=" [$CHK91 is not there -- no verdict drawn from an absent check]"
else
  A2BOX91="$BOX91/a2"; mk91 "$A2BOX91"
  good91 "$A2BOX91/.ai-flow/steering/payments.md"
  good91 "$A2BOX91/.ai-flow/steering/undeclared.md"
  good91 "$A2BOX91/.ai-flow/steering/pencil-design.md"
  mkdir -p "$A2BOX91/docs"; good91 "$A2BOX91/docs/borrowed.md"
  printf 'steering:\n  payments: .ai-flow/steering/payments.md\n  verify: docs/borrowed.md\n' \
    > "$A2BOX91/.ai-flow/project.yml"
  rc91="$(run91 "$A2BOX91")"
  [ "$rc91" = 0 ] || a2_91="$a2_91 [the default run over files in shape exits ${rc91}]"
  for want91 in 'steering/payments.md' 'steering/undeclared.md' 'product.md' 'decisions-global.md'; do
    grep -q -F "$want91" "$OUT91" || a2_91="$a2_91 [the default set does not reach ${want91}]"
  done
  grep -q -F 'pencil-design' "$OUT91" && a2_91="$a2_91 [pencil-design.md is measured]"
  grep -q -F 'borrowed.md'   "$OUT91" && a2_91="$a2_91 [a map value outside .ai-flow/ is measured]"
  # Both entries RESOLVE and neither is measured. Added in the Conform phase of the task that gives the
  # check a verdict over the map, and it is what makes the two lines above mean what they say: without
  # it, `borrowed.md` is absent from the output because nothing looked the map up at all, and the row
  # would certify the exemption on the strength of a check that never ran.
  #
  # The passing row names the KEY and not the path, which is the shape the exemption depends on -- a
  # passing verdict that echoed the value would put `borrowed.md` in the output and redden the line
  # above over a document that was correctly left unmeasured.
  for k91 in 'steering:payments' 'steering:verify'; do
    grep -q -F "$k91" "$OUT91" || a2_91="$a2_91 [no passing map verdict for the entry ${k91}]"
  done
  grep -F "$FAILMK91" "$OUT91" | grep -q -- 'map-resolves' \
    && a2_91="$a2_91 [an entry that resolves is reported failing -- the exemption is refused, not passed]"
  # Once each, read off the count the check prints rather than off the verdict lines, of which there are
  # seven per file by construction. Four files live under `.ai-flow/`; `pencil-design.md` is not one of the
  # set, so three is the whole claim -- two steering files plus the two fixed ones is four.
  grep -q -F '4 file(s) scanned' "$OUT91" \
    || a2_91="$a2_91 [the default set is not four files scanned once each: $(grep -F 'scanned' "$OUT91" | head -1)]"
  # An empty steering directory is zero steering files and not an error; an absent one likewise.
  A2E91="$BOX91/a2-empty"; mk91 "$A2E91"
  rc91="$(run91 "$A2E91")"
  [ "$rc91" = 0 ] || a2_91="$a2_91 [an empty steering directory is an error (exit ${rc91})]"
  grep -q -F '2 file(s) scanned' "$OUT91" || a2_91="$a2_91 [an empty steering directory does not scan the two fixed files]"
  A2N91="$BOX91/a2-none"; mk91 "$A2N91"; rmdir "$A2N91/.ai-flow/steering"
  rc91="$(run91 "$A2N91")"
  [ "$rc91" = 0 ] || a2_91="$a2_91 [an absent steering directory is an error (exit ${rc91})]"
fi
[ -z "$a2_91" ] && ok "A2 the default set is where the files live, once each" \
                || bad "A2 the default set is where the files live, once each:$a2_91"

# --- A3: a failure exits non-zero and names the file and the rule ---------------------------------
# The file AND the rule on ONE line. Two loose greps over the whole output are satisfied by any multi-file
# run, which names every file in one place and some rule in another.
a3_91=""
if [ ! -r "$CHK91" ]; then
  a3_91=" [$CHK91 is not there -- no verdict drawn from an absent check]"
else
  A3BOX91="$BOX91/a3"; mk91 "$A3BOX91"
  good91 "$A3BOX91/.ai-flow/steering/payments.md"
  good91 "$A3BOX91/.ai-flow/steering/broken.md"
  awk '!/^## Nano$/ && !/^- \*\*(Idempotency|Refund flow)\*\*/' "$A3BOX91/.ai-flow/steering/broken.md" \
    > "$A3BOX91/.ai-flow/steering/broken.t" \
    && mv "$A3BOX91/.ai-flow/steering/broken.t" "$A3BOX91/.ai-flow/steering/broken.md"
  rc91="$(run91 "$A3BOX91")"
  [ "$rc91" != 0 ] || a3_91="$a3_91 [a run holding a failing file exits 0]"
  grep -F 'broken.md' "$OUT91" | grep -F "$FAILMK91" | grep -q -- 'nano-present' \
    || a3_91="$a3_91 [no single line names the failing file, its rule and the failure]"
  # And the neighbour that is in shape is not blamed for it.
  grep -F 'payments.md' "$OUT91" | grep -q -F "$FAILMK91" \
    && a3_91="$a3_91 [a file in shape is reported as failing beside a file that is not]"
fi
[ -z "$a3_91" ] && ok "A3 a failure exits non-zero and names the file and the rule" \
                || bad "A3 a failure exits non-zero and names the file and the rule:$a3_91"

# --- A4: the decision log is measured on five rules and not seven ---------------------------------
# REVERSED AT THE VERIFY GATE (D11, recorded in understand.md > Implementation Decisions). This row was
# frozen asserting the log IS measured on `section-count`; that rule was found unmeetable by construction
# for this class -- every `##` here is one decision, the class has no retirement route, so the ceiling can
# only ever be crossed -- and the count now bounds TOPIC sections only. The log is therefore exempt from
# two rules, and both exemptions are the same shape: SILENCE, not a passing verdict, because a verdict of
# `ok` would claim a rule was applied and held when it was never asked.
#
# The exemptions need their opposing legs or they exempt everything: a steering file carrying the SAME
# oversized body must still fail `section-length`, a file of the same section count must still fail
# `section-count`, and the log must still answer the nano line length -- without that last one the row is
# satisfied by a check that exempts the log from all seven.
#
# The rule list below is the five that remain, `app-key` included. It was four when this row asserted six,
# which is the shape the coverage axis flagged: a leg whose own title counts higher than its assertions.
a4_91=""
if [ ! -r "$CHK91" ]; then
  a4_91=" [$CHK91 is not there -- no verdict drawn from an absent check]"
else
  A4BOX91="$BOX91/a4"; mk91 "$A4BOX91"
  long91="$(awk -v n=$((SECMAX91 + 20)) 'BEGIN{while(++i<=n)printf "word "}')"
  printf '%s\n' "$long91" >> "$A4BOX91/.ai-flow/decisions-global.md"
  rc91="$(run91 "$A4BOX91" .ai-flow/decisions-global.md)"
  [ "$rc91" = 0 ] || a4_91="$a4_91 [the decision log is held to the section length (exit ${rc91})]"
  grep -q -- 'section-length' "$OUT91" \
    && a4_91="$a4_91 [the decision log is given a section-length verdict it is exempt from]"
  grep -q -- 'section-count' "$OUT91" \
    && a4_91="$a4_91 [the decision log is given a section-count verdict it is exempt from]"
  for r91 in nano-present nano-order nano-line-length app-key marker; do
    grep -q -- "$r91" "$OUT91" || a4_91="$a4_91 [the decision log is not measured on ${r91}]"
  done
  # The count exemption's opposing leg: a log carrying MORE sections than the ceiling is still clean,
  # while a steering file of the same shape is not. Without the second half the exemption is a check that
  # counts nothing anywhere.
  A4C91="$BOX91/a4-count"; mk91 "$A4C91"
  printf '# Global Decisions\n\n## Nano\n\n' > "$A4C91/.ai-flow/decisions-global.md"
  i91=1
  while [ "$i91" -le $((SECCNT91 + 1)) ]; do
    printf -- '- **2026-01-%02d - Decision %d** — decided.\n' "$i91" "$i91" >> "$A4C91/.ai-flow/decisions-global.md"
    i91=$((i91 + 1))
  done
  i91=1
  while [ "$i91" -le $((SECCNT91 + 1)) ]; do
    printf '\n## 2026-01-%02d - Decision %d\n\nContext: none. Decision: this. Alternatives: the other, rejected.\n' \
      "$i91" "$i91" >> "$A4C91/.ai-flow/decisions-global.md"
    i91=$((i91 + 1))
  done
  rc91="$(run91 "$A4C91" .ai-flow/decisions-global.md)"
  [ "$rc91" = 0 ] \
    || a4_91="$a4_91 [a decision log of $((SECCNT91 + 1)) decisions is out of shape (exit ${rc91}): $(grep -F "$FAILMK91" "$OUT91" | head -2 | tr '\n' ' ')]"
  grep -q -- 'section-count' "$OUT91" \
    && a4_91="$a4_91 [the growing decision log is given a section-count verdict]"
  good91 "$A4BOX91/.ai-flow/steering/payments.md"
  printf '%s\n' "$long91" >> "$A4BOX91/.ai-flow/steering/payments.md"
  rc91="$(run91 "$A4BOX91" .ai-flow/steering/payments.md)"
  [ "$rc91" != 0 ] || a4_91="$a4_91 [the section length is enforced on no class -- the same body passes as steering]"
  grep -F "$FAILMK91" "$OUT91" | grep -q -- 'section-length' \
    || a4_91="$a4_91 [the steering failure does not name section-length]"
  pad91="$(awk -v n=$((NANOMAX91 + 40)) 'BEGIN{while(++i<=n)printf "x"}')"
  sed "s/^- \*\*2026-01-01.*/- **2026-01-01 - Settlement is nightly** — $pad91/" \
    "$A4BOX91/.ai-flow/decisions-global.md" > "$A4BOX91/.ai-flow/dg.t" \
    && mv "$A4BOX91/.ai-flow/dg.t" "$A4BOX91/.ai-flow/decisions-global.md"
  rc91="$(run91 "$A4BOX91" .ai-flow/decisions-global.md)"
  [ "$rc91" != 0 ] || a4_91="$a4_91 [the decision log is exempt from the nano line length too]"
fi
[ -z "$a4_91" ] && ok "A4 the decision log is measured on five rules and not seven" \
                || bad "A4 the decision log is measured on five rules and not seven:$a4_91"

# --- A12: the count bounds topics, and a record section is not a topic ----------------------------
# D11. `section-count` exists to catch a file that has become a drawer -- too many TOPICS. A class whose
# sections are RECORDS of a growing enumeration cannot be judged that way: the count only ever rises, and
# no repair the mechanism offers can lower it. So a `Rules: <key> — <topic>` section, which is where
# `product.md` grows by design (docs/context/product.md > Two parts), does not count toward the ceiling.
#
# Both directions, and the second is what keeps this from exempting everything: the same file with its
# record sections retitled as topics must fail. Keyed on SECCNT91, never on a spelled number.
a12_91=""
if [ ! -r "$CHK91" ]; then
  a12_91=" [$CHK91 is not there -- no verdict drawn from an absent check]"
else
  # A product file over the ceiling in total sections, where all but five are records.
  mkprod91() {  # $1 = file; $2 = the title prefix for the growing part
    local n91=$((SECCNT91 + 1)) i91=6
    printf '# Product Context\n\n## Nano\n\n' > "$1"
    printf -- '- **Product** — one gateway.\n- **Users & Roles** — one role.\n' >> "$1"
    printf -- '- **Applications** — one app.\n- **Core Business Flows** — one flow.\n' >> "$1"
    printf -- '- **Key Domain Terms** — one term.\n' >> "$1"
    while [ "$i91" -le "$n91" ]; do printf -- '- **%s %d** — a rule.\n' "$2" "$i91" >> "$1"; i91=$((i91 + 1)); done
    printf '\n## Product\n\nOne gateway.\n\n## Users & Roles\n\nOne role.\n' >> "$1"
    printf '\n## Applications\n\nOne app.\n\n## Core Business Flows\n\nOne flow.\n' >> "$1"
    printf '\n## Key Domain Terms\n\nOne term.\n' >> "$1"
    i91=6
    while [ "$i91" -le "$n91" ]; do printf '\n## %s %d\n\nA rule. (T-000)\n' "$2" "$i91" >> "$1"; i91=$((i91 + 1)); done
  }
  A12BOX91="$BOX91/a12"; mk91 "$A12BOX91"
  mkprod91 "$A12BOX91/.ai-flow/product.md" 'Rules: checkout —'
  rc91="$(run91 "$A12BOX91" .ai-flow/product.md)"
  [ "$rc91" = 0 ] \
    || a12_91="$a12_91 [a product file of $((SECCNT91 + 1)) sections whose growing part is records is out of shape (exit ${rc91}): $(grep -F "$FAILMK91" "$OUT91" | head -2 | tr '\n' ' ')]"
  grep -F "$FAILMK91" "$OUT91" | grep -q -- 'section-count' \
    && a12_91="$a12_91 [record sections are counted toward the ceiling]"
  # The opposing direction: the same shape with the records retitled as topics must fail, or the rule
  # above is a check that counts nothing.
  A12T91="$BOX91/a12-topics"; mk91 "$A12T91"
  mkprod91 "$A12T91/.ai-flow/product.md" 'Topic'
  rc91="$(run91 "$A12T91" .ai-flow/product.md)"
  [ "$rc91" != 0 ] || a12_91="$a12_91 [$((SECCNT91 + 1)) topic sections are within the ceiling -- the count is inert]"
  grep -F "$FAILMK91" "$OUT91" | grep -q -- 'section-count' \
    || a12_91="$a12_91 [the failure over topic sections does not name section-count]"
  # The exemption belongs to the CLASS that grows by records, not to the title prefix. `## The marker`
  # offers `Rules: <key> — <topic>` as the general way any class expresses groups, so keyed on the title
  # alone a steering file of twenty `Rules:` sections is uncountable -- a drawer, invisible to the one
  # rule whose stated job is catching a file that has become a drawer.
  A12S91="$BOX91/a12-steering-records"; mk91 "$A12S91"
  F12S91="$A12S91/.ai-flow/steering/payments.md"
  i91=1; nano91=""; body91=""
  while [ "$i91" -le $((SECCNT91 + 1)) ]; do
    nano91="$nano91- **Rules: payments — group $i91** — a group of its own.
"
    body91="$body91
## Rules: payments — group $i91

A group of its own.
"
    i91=$((i91 + 1))
  done
  printf '# Payments\n\n## Nano\n\n%s%s' "$nano91" "$body91" > "$F12S91"
  rc91="$(run91 "$A12S91" .ai-flow/steering/payments.md)"
  [ "$rc91" != 0 ] \
    || a12_91="$a12_91 [a steering file of $((SECCNT91 + 1)) sections titled 'Rules:' is within the ceiling -- the exemption is keyed on the title, not on the class]"
  grep -F "$FAILMK91" "$OUT91" | grep -q -- 'section-count' \
    || a12_91="$a12_91 [the steering drawer does not fail section-count]"
fi
[ -z "$a12_91" ] && ok "A12 the count bounds topics, and a record section is not a topic" \
                 || bad "A12 the count bounds topics, and a record section is not a topic:$a12_91"

# --- A13: the check refuses where there is nothing of this project's context to measure -----------
# Both of the script's hard refusals, neither of which any leg reached: every fixture in this card builds
# `.ai-flow/` before invoking the check, so deleting either `die` left the suite at its full green. Proved
# at the Verify gate by deleting the guard and watching the count not move -- a hollow guard, not a
# suspected one. The wrong cwd is the ordinary operator mistake here, because the script takes `ROOT=$PWD`.
a13_91=""
if [ ! -r "$CHK91" ]; then
  a13_91=" [$CHK91 is not there -- no verdict drawn from an absent check]"
else
  A13BOX91="$BOX91/a13"; mkdir -p "$A13BOX91"
  rc91="$(run91 "$A13BOX91")"
  [ "$rc91" != 0 ] || a13_91="$a13_91 [a run with no .ai-flow/ present exits 0 having measured nothing]"
  grep -q -F "$A13BOX91" "$OUT91" || a13_91="$a13_91 [the refusal does not name the directory it was run in]"
  for r91 in $RULES91; do
    grep -q -- "$r91" "$OUT91" && a13_91="$a13_91 [a run with no .ai-flow/ measured ${r91} anyway]"
  done
  # A mistyped flag is refused AS AN OPTION, not swallowed as a file. The discrimination is the whole
  # leg: a first draft asserted only a non-zero exit and the flag's name, and it stayed green when the
  # option refusal was deleted -- because `--reports` then falls through to the argument form, normalises
  # to a path outside `.ai-flow/`, and is refused there with the same status and the same name in the
  # output. So the leg also asserts what the refusal must NOT be. Keyed on the message rather than on the
  # status, because both refusals exit 2 and nothing else separates them.
  A13O91="$BOX91/a13-opt"; mk91 "$A13O91"
  rc91="$(run91 "$A13O91" --reports)"
  [ "$rc91" != 0 ] || a13_91="$a13_91 [an unknown option is accepted]"
  grep -q -F -- '--reports' "$OUT91" || a13_91="$a13_91 [the unknown option is not named]"
  grep -q -F -- 'option' "$OUT91" || a13_91="$a13_91 [the refusal does not say the argument was an option]"
  grep -q -F -- 'outside this checkout' "$OUT91" \
    && a13_91="$a13_91 [an unknown option is refused as a path rather than as an option]"
fi
[ -z "$a13_91" ] && ok "A13 the check refuses where there is nothing of this project's context to measure" \
                 || bad "A13 the check refuses where there is nothing of this project's context to measure:$a13_91"

# --- A5: --report prints every verdict with its threshold -----------------------------------------
# Each threshold beside the rule it bounds, not merely somewhere in the output -- a banner listing three
# numbers satisfies the loose form. And the flag is what produces them: without it the numbers stay in the
# script, which is the half that keeps `--report` from being the default with extra words.
a5_91=""
if [ ! -r "$CHK91" ]; then
  a5_91=" [$CHK91 is not there -- no verdict drawn from an absent check]"
else
  A5BOX91="$BOX91/a5"; mk91 "$A5BOX91"
  good91 "$A5BOX91/.ai-flow/steering/payments.md"
  rc91="$(run91 "$A5BOX91" --report)"
  [ "$rc91" = 0 ] || a5_91="$a5_91 [--report over files in shape exits ${rc91}]"
  for r91 in $RULES91; do
    grep -q -- "$r91" "$OUT91" || a5_91="$a5_91 [--report does not print a verdict for ${r91}]"
  done
  grep -E 'nano-line-length' "$OUT91" | grep -q -- "$NANOMAX91" \
    || a5_91="$a5_91 [the nano line length is not printed with its own verdict]"
  grep -E 'section-length'   "$OUT91" | grep -q -- "$SECMAX91" \
    || a5_91="$a5_91 [the section length is not printed with its own verdict]"
  grep -E 'section-count'    "$OUT91" | grep -q -- "$SECCNT91" \
    || a5_91="$a5_91 [the section count is not printed with its own verdict]"
  rc91="$(run91 "$A5BOX91")"
  grep -q -- "$SECMAX91" "$OUT91" && a5_91="$a5_91 [the thresholds are printed without --report]"
fi
[ -z "$a5_91" ] && ok "A5 --report prints every verdict with its threshold" \
                || bad "A5 --report prints every verdict with its threshold:$a5_91"

# --- A6: the check refuses what is not its to read, and names it ----------------------------------
# Refusing is not failing a rule: the path is NOT READ. A leg over the exit status alone is satisfied by a
# check that reads the file and fails it, which is the opposite of the guarantee.
a6_91=""
if [ ! -r "$CHK91" ]; then
  a6_91=" [$CHK91 is not there -- no verdict drawn from an absent check]"
else
  A6BOX91="$BOX91/a6"; mk91 "$A6BOX91"
  mkdir -p "$A6BOX91/docs"; good91 "$A6BOX91/docs/outside.md"
  rc91="$(run91 "$A6BOX91" docs/outside.md)"
  [ "$rc91" != 0 ] || a6_91="$a6_91 [a path outside .ai-flow/ is accepted]"
  grep -q -F 'docs/outside.md' "$OUT91" || a6_91="$a6_91 [the refused path is not named]"
  for r91 in $RULES91; do
    grep -q -- "$r91" "$OUT91" && a6_91="$a6_91 [the refused path was read anyway -- ${r91} was measured]"
  done
  # A climb out of the data directory, asserted separately because a check comparing only the leading
  # string accepts it.
  rc91="$(run91 "$A6BOX91" .ai-flow/../docs/outside.md)"
  [ "$rc91" != 0 ] || a6_91="$a6_91 [a path climbing out of .ai-flow/ is accepted]"
  # A named file that does not exist is named rather than silently skipped.
  rc91="$(run91 "$A6BOX91" .ai-flow/steering/absent.md)"
  [ "$rc91" != 0 ] || a6_91="$a6_91 [a named file that does not exist is silently skipped]"
  grep -q -F 'absent.md' "$OUT91" || a6_91="$a6_91 [a named file that does not exist is not named]"
fi
[ -z "$a6_91" ] && ok "A6 the check refuses what is not its to read, and names it" \
                || bad "A6 the check refuses what is not its to read, and names it:$a6_91"

# --- A7: the check is delivered, swept and reported missing ---------------------------------------
# Three producers, because the delivery is three mechanisms: the installer's list, the sweep that prunes
# what the list no longer names, and the drift guard's prefix map. A leg over the list alone is satisfied
# by a name nothing copies -- the shape the seeder's own row was written to catch, whose idiom this reuses.
a7_91=""
if [ ! -r "$CHK91" ]; then
  a7_91=" [$CHK91 is not there -- no verdict drawn from an absent check]"
else
  IH91="$BOX91/home-install"; IT91="$BOX91/target"; mkdir -p "$IH91" "$IT91"
  ( cd "$BOX91" && HOME="$IH91" bash "$ROOT/install.sh" update "$IT91" </dev/null >/dev/null 2>&1 ) || true
  [ -x "$IH91/.claude/ai-flow/scripts/context-check.sh" ] \
    || a7_91="$a7_91 installer-does-not-deliver-it"
  [ -x "$IH91/.claude/ai-flow/scripts/seed-front.sh" ] \
    || a7_91="$a7_91 installer-delivers-neither-script-the-fixture-proves-nothing"
  # The sweep can reach the directory: a script the list does not name is removed, and the one it does
  # name survives the same run.
  printf '#!/bin/bash\necho stray\n' > "$IH91/.claude/ai-flow/scripts/stray.sh"
  ( cd "$BOX91" && HOME="$IH91" bash "$ROOT/install.sh" update "$IT91" </dev/null >/dev/null 2>&1 ) || true
  [ ! -f "$IH91/.claude/ai-flow/scripts/stray.sh" ] || a7_91="$a7_91 scripts-directory-not-swept"
  [ -x "$IH91/.claude/ai-flow/scripts/context-check.sh" ] || a7_91="$a7_91 sweep-removed-what-it-installed"
  # The drift guard reports the installed copy. Executed against a clone holding only that path, because
  # the guard returns "" for a prefix it does not recognise -- a silent skip a grep of the map cannot see.
  G91D="git -c user.email=t@t.t -c user.name=t -c commit.gpgsign=false"
  CL91="$BOX91/clone"; mkdir -p "$CL91/global/scripts"
  $G91D init -q "$CL91"
  printf '#!/bin/bash\necho checked\n' > "$CL91/global/scripts/context-check.sh"
  $G91D -C "$CL91" add -A >/dev/null 2>&1
  $G91D -C "$CL91" commit -q -m engine
  mkdir -p "$BOX91/home-drift/.claude/ai-flow"
  printf '%s\n' "$CL91" > "$BOX91/home-drift/.claude/ai-flow/source.path"
  out91="$( cd "$BOX91" && HOME="$BOX91/home-drift" bash "$ROOT/global/hooks/drift-check.sh" 2>&1 <<<'{}' )"
  case "$out91" in
    *"scripts/context-check.sh"*) ;;
    *) a7_91="$a7_91 drift-guard-skips-the-prefix" ;;
  esac
fi
[ -z "$a7_91" ] && ok "A7 the check is delivered, swept and reported missing" \
                || bad "A7 the check is delivered, swept and reported missing ($a7_91)"

# --- A8: the three numbers have one home ----------------------------------------------------------
# Both halves, and the presence half is what makes the absence half mean anything: without it the sweep is
# green over a repository where no number exists at all, which is the state this block was written in.
#
# The absence half is asked TWICE, in two shapes, because one number cannot be swept the way the other two
# can. Measured over the shipped surface: `200` and `450` appear in zero files, so a literal sweep for them
# is safe; `10` appears in eleven, in dates and task ids, so a literal sweep for it would be a leg that
# reddens on prose about something else. What is forbidden is a VALUE OF A MEASURE, so the second shape asks
# that no number sit beside a measure's name -- probed over all 40 files with no hit before it was written.
a8_91=""
if [ ! -r "$CHK91" ]; then
  a8_91=" [$CHK91 is not there -- no verdict drawn from an absent check]"
else
  for t91 in "$NANOMAX91" "$SECMAX91" "$SECCNT91"; do
    grep -q -E "(^|[^0-9])${t91}([^0-9]|$)" "$CHK91" \
      || a8_91="$a8_91 [the check does not declare the threshold ${t91}]"
  done
  seen91=0
  # NUL-delimited: a path list built as a string and word-split inspects nothing under a directory with a
  # space in it and reports green having read zero files. The count is asserted below for the same reason.
  while IFS= read -r -d '' p91; do
    case "$p91" in "./$CHK91"|./test/*) continue ;; esac
    seen91=$((seen91 + 1))
    for t91 in "$NANOMAX91" "$SECMAX91"; do
      grep -q -E "(^|[^0-9])${t91}([^0-9]|$)" "$p91" \
        && a8_91="$a8_91 [${p91#./} states the threshold ${t91}]"
    done
    flat91="$(tr '\n' ' ' < "$p91" | tr -s ' ')"
    for m91 in 'nano line' 'section length' 'sections per file'; do
      nearzero90 "$(near90 "$flat91" "$m91" '[0-9]' 60)" \
        || a8_91="$a8_91 [${p91#./} states a value beside the measure '${m91}']"
    done
  done < <(find ./global ./template ./docs/context -type f -name '*.md' -print0 2>/dev/null; \
           find ./global/scripts ./global/hooks -type f -print0 2>/dev/null)
  [ "$seen91" -ge 20 ] \
    || a8_91="$a8_91 [the shipped surface swept ${seen91} files -- the sweep read nothing]"
fi
[ -z "$a8_91" ] && ok "A8 the three numbers have one home" \
                || bad "A8 the three numbers have one home:$a8_91"

# --- A9: both homes state the set and state no number ---------------------------------------------
# A sentence relocated inside two homes, so both directions in each: the new set is stated, the retired
# wording is gone, and neither home carries a value. The retired wording is keyed on what the documents
# actually said -- `takes every value of the steering: map` -- and not on a paraphrase of it.
#
# Two of the four legs are `stays green` directions and are marked as such, because a direction phrased as
# an absence names nothing that would redden it. What would: writing `450 words` beside `section length`,
# and dropping either filename from the sentence that names the set.
a9_91=""
K91P="$(sec90 "$CTXP91" '^## Keeping')"
K91D="$(sec90 "$CTXD91" '^## Keeping')"
if [ -z "$K91P" ] || [ -z "$K91D" ]; then
  a9_91=" [the Keeping section did not extract from one of the two homes -- no verdict drawn from an empty region]"
else
  for pair91 in "the protocol~$K91P" "the definition~$K91D"; do
    lbl91="${pair91%%~*}"; reg91="${pair91#*~}"
    nearok90 "$(near90 "$reg91" 'steering directory' 'no argument' 200)" \
      || a9_91="$a9_91 [${lbl91} does not bind the default run to the steering directory]"
    nearok90 "$(near90 "$reg91" 'product\.md' 'decisions-global\.md' 120)" \
      || a9_91="$a9_91 [${lbl91} no longer names the two fixed files together]"
    nearzero90 "$(near90 "$reg91" 'steering:. map' 'no argument' 200)" \
      || a9_91="$a9_91 [${lbl91} still takes the default set from the steering map]"
    for m91 in 'nano line' 'section length' 'sections per file'; do
      nearzero90 "$(near90 "$reg91" "$m91" '[0-9]' 60)" \
        || a9_91="$a9_91 [${lbl91} carries a value beside the measure '${m91}']"
    done
  done
  # The class document says a steering file the map does not name is measured all the same. Its own
  # section: the claim is steering's alone, and the mechanism states nothing about the map.
  M91="$(sec90 "$STG91" '^## How the map names a file')"
  if [ -z "$M91" ]; then
    a9_91="$a9_91 [the steering class document's map section did not extract]"
  else
    nearok90 "$(near90 "$M91" 'does not name' 'check' 200)" \
      || a9_91="$a9_91 [the class document does not say an undeclared steering file is checked]"
  fi
fi
[ -z "$a9_91" ] && ok "A9 both homes state the set and state no number" \
                || bad "A9 both homes state the set and state no number:$a9_91"

# --- A10: every move that writes a context file ends on the check ---------------------------------
# The enumeration is COUNTED FROM THE TREE and never from this task's papers, which said the moves to
# change were "steps 1-2" while the tree held three -- the row was drafted before the third move existed.
# Every numbered item is read, the ones whose ACT writes a context file are selected by the act rather than
# by the mention, and each of those must carry the check. Probed: it selects 1, 2 and 3, and leaves out the
# 651-word Icebox move that mentions steering in passing.
a10_91=""
CHKL91="$(sec90 "$BLG91" '^### After ARCHIVE')"
if [ -z "$CHKL91" ]; then
  a10_91=" [the archive checklist did not extract -- no verdict drawn from an empty region]"
else
  w91=0; g91=0
  for n91 in $(printf '%s\n' "$CHKL91" | awk '/^[0-9]+\. /{print $0+0}'); do
    it91="$(nitem "$n91" "$CHKL91")"
    [ -n "$it91" ] || { a10_91="$a10_91 [move ${n91} of the checklist did not extract]"; continue; }
    nearok90 "$(near90 "$it91" 'steering|product\.md|decisions-global\.md' 'place it|copy every rule|becomes a section' 200)" \
      || continue
    w91=$((w91 + 1))
    if nearok90 "$(near90 "$it91" 'context-check' 'Verify' 200)"; then
      g91=$((g91 + 1))
    else
      a10_91="$a10_91 [move ${n91} writes a context file and names no check as its Verify]"
    fi
  done
  # A floor against a broken selector, never a ceiling on the checklist: the loop judges every move it
  # finds, so a fourth writing move added later is measured rather than assumed.
  [ "$w91" -ge 3 ] \
    || a10_91="$a10_91 [only ${w91} moves were selected as writing a context file -- the selector found nothing]"
  [ "$w91" = "$g91" ] || a10_91="$a10_91 [${g91} of ${w91} writing moves end on the check]"
fi
[ -z "$a10_91" ] && ok "A10 every move that writes a context file ends on the check" \
                 || bad "A10 every move that writes a context file ends on the check:$a10_91"

# --- A11: a fresh install passes the check on its own skeletons -----------------------------------
# Presence of the block is not the claim: a `## Nano` whose lines name sections the file does not have
# fails the first rule. So the skeletons are run through the check itself, and the run is asserted to have
# reached both of them -- a clean exit over zero files is not a passing skeleton.
a11_91=""
for f91 in "$TPR91" "$TDG91"; do
  if [ ! -r "$f91" ]; then
    a11_91="$a11_91 [${f91} is unreadable]"
  else
    grep -q '^## Nano$' "$f91" || a11_91="$a11_91 [${f91} carries no nano block]"
  fi
done
if [ ! -r "$CHK91" ]; then
  a11_91="$a11_91 [$CHK91 is not there -- no verdict drawn from an absent check]"
else
  A11BOX91="$BOX91/a11"; mkdir -p "$A11BOX91"
  cp -R template/.ai-flow "$A11BOX91/.ai-flow"
  rc91="$(run91 "$A11BOX91")"
  [ "$rc91" = 0 ] \
    || a11_91="$a11_91 [a fresh install fails the check (exit ${rc91}): $(grep -F "$FAILMK91" "$OUT91" | head -3 | tr '\n' ' ')]"
  for want91 in 'product.md' 'decisions-global.md'; do
    grep -q -F "$want91" "$OUT91" || a11_91="$a11_91 [the fresh install run never reached ${want91}]"
  done
fi
[ -z "$a11_91" ] && ok "A11 a fresh install passes the check on its own skeletons" \
                 || bad "A11 a fresh install passes the check on its own skeletons:$a11_91"

# --- A14: the map verdict fails a value that resolves to nothing ----------------------------------
# Generated in the Conform phase of the task that gives the check a verdict over the delivery map. RED
# at the freeze: nothing in the engine resolves a value, so every fixture below exits 0.
#
# The rule identifier is NOT added to RULES91. Those seven are the PER-FILE rules and A1 walks them with
# a fixture branch each; this one is per ENTRY and has no file to be a verdict of, so joining that list
# would give A1 a rule with no branch and redden it for a reason that is not about the check. `only91 ''`
# is how these legs get the same "and only it" measurement: it skips nothing and asks that none of the
# seven fail on a fixture built to break this one.
#
# Three failing causes and not one, because they are three different mistakes and a check that answered
# them with one sentence would send the operator looking for a file where the defect is a missing value.
MAPRULE91="map-resolves"
a14_91=""
if [ ! -r "$CHK91" ]; then
  a14_91=" [$CHK91 is not there -- no verdict drawn from an absent check]"
else
  # The failing direction: a key whose value names no file anywhere.
  A14BOX91="$BOX91/a14"; mk91 "$A14BOX91"
  good91 "$A14BOX91/.ai-flow/steering/payments.md"
  printf 'steering:\n  payments: .ai-flow/steering/payments.md\n  auth: .ai-flow/steering/auth.md\n' \
    > "$A14BOX91/.ai-flow/project.yml"
  rc91="$(run91 "$A14BOX91")"
  [ "$rc91" != 0 ] || a14_91="$a14_91 [a value naming no existing file exits 0]"
  # The key AND the value on ONE line with the failing mark. Three loose greps over the whole output are
  # satisfied by any run that names the key in a passing row and the path in a neighbouring one.
  grep -F "$FAILMK91" "$OUT91" | grep -q -- "$MAPRULE91" \
    || a14_91="$a14_91 [the failing verdict does not name the rule ${MAPRULE91}]"
  grep -F "$FAILMK91" "$OUT91" | grep -- "$MAPRULE91" | grep -q -F 'auth' \
    || a14_91="$a14_91 [the failing line does not name the key]"
  grep -F "$FAILMK91" "$OUT91" | grep -- "$MAPRULE91" | grep -q -F '.ai-flow/steering/auth.md' \
    || a14_91="$a14_91 [the failing line does not name the value]"
  # The entry that DOES resolve is not dragged down with it: one verdict per entry, not one per map.
  grep -F "$FAILMK91" "$OUT91" | grep -- "$MAPRULE91" | grep -q -F 'payments' \
    && a14_91="$a14_91 [the entry that resolves is reported failing too]"
  a14_91="$a14_91$(only91 '')"
  # A key present with NO value is not a key absent altogether, and it does not resolve. Its cause is
  # its own: an operator reading `does not resolve` beside an empty value goes looking for a file.
  A14E91="$BOX91/a14-novalue"; mk91 "$A14E91"
  good91 "$A14E91/.ai-flow/steering/payments.md"
  printf 'steering:\n  payments: .ai-flow/steering/payments.md\n  auth:\n' \
    > "$A14E91/.ai-flow/project.yml"
  rc91="$(run91 "$A14E91")"
  [ "$rc91" != 0 ] || a14_91="$a14_91 [a key declared with no value exits 0]"
  grep -F "$FAILMK91" "$OUT91" | grep -- "$MAPRULE91" | grep -q -iE 'no value|empty' \
    || a14_91="$a14_91 [a key with no value is not told apart from one naming a missing file]"
  a14_91="$a14_91$(only91 '')"
  # A directory is not a file. The verdict is existence AS A FILE -- a value naming the steering
  # directory itself resolves to something that exists and is still not a document to deliver.
  A14D91="$BOX91/a14-dir"; mk91 "$A14D91"
  good91 "$A14D91/.ai-flow/steering/payments.md"
  printf 'steering:\n  payments: .ai-flow/steering\n' > "$A14D91/.ai-flow/project.yml"
  rc91="$(run91 "$A14D91")"
  [ "$rc91" != 0 ] || a14_91="$a14_91 [a value naming a directory exits 0]"
  grep -F "$FAILMK91" "$OUT91" | grep -q -- "$MAPRULE91" \
    || a14_91="$a14_91 [a value naming a directory does not fail ${MAPRULE91}]"
  # BY NAME, because the generic cause catches this fixture anyway: with the directory branch deleted a
  # directory is still not a regular file, so `[ ! -f ]` fires, the row still FAILs and the exit is still
  # non-zero. The two assertions above therefore survive the branch's deletion and the third cause the
  # code and its comment both claim would be reachable by nothing.
  grep -F "$FAILMK91" "$OUT91" | grep -- "$MAPRULE91" | grep -q -i 'directory' \
    || a14_91="$a14_91 [a value naming a directory is not told apart from one naming nothing]"
  # A VALUE AS AN OPERATOR WRITES IT: quoted, with an inline comment and trailing space. The parser
  # strips all three, and this is the direction that matters -- a regression here turns a CORRECT
  # declaration red, which is the loudest thing this change can do to an adopter, and every other
  # fixture in this block writes a bare value that exercises none of it.
  A14Q91="$BOX91/a14-written-by-hand"; mk91 "$A14Q91"
  good91 "$A14Q91/.ai-flow/steering/payments.md"
  printf 'steering:\n  payments: ".ai-flow/steering/payments.md"   # the payment rules\n' \
    > "$A14Q91/.ai-flow/project.yml"
  rc91="$(run91 "$A14Q91")"
  [ "$rc91" = 0 ] \
    || a14_91="$a14_91 [a quoted value with an inline comment is refused (exit ${rc91}): $(grep -F "$FAILMK91" "$OUT91" | head -1 | tr -s ' ')]"
  grep -q -F 'steering:payments' "$OUT91" \
    || a14_91="$a14_91 [the quoted fixture drew no map verdict at all -- its pass is unmeasured]"
  # The clean direction, and the empty map beside it: zero entries is zero verdicts and not a failure.
  # `mk91` writes `steering: {}`, which is the shipped default -- the state most adopters are in.
  A14C91="$BOX91/a14-clean"; mk91 "$A14C91"
  good91 "$A14C91/.ai-flow/steering/payments.md"
  printf 'steering:\n  payments: .ai-flow/steering/payments.md\n' > "$A14C91/.ai-flow/project.yml"
  rc91="$(run91 "$A14C91")"
  [ "$rc91" = 0 ] || a14_91="$a14_91 [a map whose every value resolves exits ${rc91}]"
  grep -q -- "$MAPRULE91" "$OUT91" || a14_91="$a14_91 [no verdict for ${MAPRULE91} on a map that resolves]"
  A14M91="$BOX91/a14-empty"; mk91 "$A14M91"
  good91 "$A14M91/.ai-flow/steering/payments.md"
  rc91="$(run91 "$A14M91")"
  [ "$rc91" = 0 ] || a14_91="$a14_91 [the shipped empty map is an error (exit ${rc91})]"
  grep -F "$FAILMK91" "$OUT91" | grep -q -- "$MAPRULE91" \
    && a14_91="$a14_91 [an empty map produces a failing ${MAPRULE91} verdict]"
fi
[ -z "$a14_91" ] && ok "A14 the map verdict fails a value that resolves to nothing" \
                 || bad "A14 the map verdict fails a value that resolves to nothing:$a14_91"

# --- A15: the candidate hint rides the failing line, and no other ---------------------------------
# The diagnosis is the whole of what the operator gets: the check resolves against ONE base, so it
# cannot tell them their value is right under another -- it can only say which file it can see. Both
# directions, because the hint printed beside a value that resolved is the forgiving form leaking back
# in through the report.
a15_91=""
if [ ! -r "$CHK91" ]; then
  a15_91=" [$CHK91 is not there -- no verdict drawn from an absent check]"
else
  A15BOX91="$BOX91/a15"; mk91 "$A15BOX91"
  good91 "$A15BOX91/.ai-flow/steering/auth.md"
  printf 'steering:\n  auth: steering/auth.md\n' > "$A15BOX91/.ai-flow/project.yml"
  rc91="$(run91 "$A15BOX91")"
  [ "$rc91" != 0 ] || a15_91="$a15_91 [a value that resolves under no base exits 0]"
  # The candidate AND the invitation on the SAME line as the failure: a path printed on a line of its
  # own is a second output shape, and a reader scanning the failing rows never sees it.
  grep -F "$FAILMK91" "$OUT91" | grep -- "$MAPRULE91" | grep -q -F '.ai-flow/steering/auth.md' \
    || a15_91="$a15_91 [the failing line does not name the file the value probably meant]"
  grep -F "$FAILMK91" "$OUT91" | grep -- "$MAPRULE91" | grep -q -i 'did you mean' \
    || a15_91="$a15_91 [the candidate is printed without saying it is a guess]"
  # No candidate under the steering directory: the line still fails and still names key and value, and
  # it invents nothing. Without this, a check that always printed a guess would pass the row above.
  A15N91="$BOX91/a15-nocand"; mk91 "$A15N91"
  good91 "$A15N91/.ai-flow/steering/payments.md"
  printf 'steering:\n  payments: .ai-flow/steering/payments.md\n  billing: docs/billing.md\n' \
    > "$A15N91/.ai-flow/project.yml"
  rc91="$(run91 "$A15N91")"
  [ "$rc91" != 0 ] || a15_91="$a15_91 [a value with no candidate beneath the steering directory exits 0]"
  grep -F "$FAILMK91" "$OUT91" | grep -- "$MAPRULE91" | grep -q -i 'did you mean' \
    && a15_91="$a15_91 [a candidate is invented for a value whose basename names nothing]"
  # And the passing direction: nothing is said about an entry that resolved.
  A15C91="$BOX91/a15-clean"; mk91 "$A15C91"
  good91 "$A15C91/.ai-flow/steering/auth.md"
  printf 'steering:\n  auth: .ai-flow/steering/auth.md\n' > "$A15C91/.ai-flow/project.yml"
  rc91="$(run91 "$A15C91")"
  [ "$rc91" = 0 ] || a15_91="$a15_91 [the resolving fixture exits ${rc91}]"
  grep -q -i 'did you mean' "$OUT91" \
    && a15_91="$a15_91 [a candidate is printed beside a value that resolved]"
fi
[ -z "$a15_91" ] && ok "A15 the candidate hint rides the failing line, and no other" \
                 || bad "A15 the candidate hint rides the failing line, and no other:$a15_91"

# --- A16: the base is the checkout root, and there is no second one -------------------------------
# The anti-fallback leg, and the reason it is not folded into A14: A14's fixture names a file that
# exists under NO base, so a check that quietly tried `.ai-flow/` as well would pass it and A14 would
# stay green. This fixture names a file that exists under the OLD base and nowhere else -- the exact
# shape 15 of 15 values in the measured adopter are written in -- so a second base is the only way it
# can come back clean.
a16_91=""
if [ ! -r "$CHK91" ]; then
  a16_91=" [$CHK91 is not there -- no verdict drawn from an absent check]"
else
  A16BOX91="$BOX91/a16"; mk91 "$A16BOX91"
  good91 "$A16BOX91/.ai-flow/steering/payments.md"
  printf 'steering:\n  payments: steering/payments.md\n' > "$A16BOX91/.ai-flow/project.yml"
  rc91="$(run91 "$A16BOX91")"
  [ "$rc91" != 0 ] \
    || a16_91="$a16_91 [a value written under the .ai-flow/ base passes -- the check resolves against a second base]"
  a16_91="$a16_91$(only91 '')"
  # The control, over the SAME file and the SAME machinery: written from the root the identical value
  # resolves. Without it, a check that failed every map entry whatever it named would pass the row above.
  A16C91="$BOX91/a16-root"; mk91 "$A16C91"
  good91 "$A16C91/.ai-flow/steering/payments.md"
  printf 'steering:\n  payments: .ai-flow/steering/payments.md\n' > "$A16C91/.ai-flow/project.yml"
  rc91="$(run91 "$A16C91")"
  [ "$rc91" = 0 ] \
    || a16_91="$a16_91 [the same file named from the checkout root does not resolve either (exit ${rc91})]"
fi
[ -z "$a16_91" ] && ok "A16 the base is the checkout root, and there is no second one" \
                 || bad "A16 the base is the checkout root, and there is no second one:$a16_91"

# --- A17: every caller the check's paragraph names is one a shipped file performs ------------------
# Both homes, because A9 already proves this paragraph is written twice and a clause deleted from one
# of them survives in the other. The retired clause is keyed on what the documents actually say -- the
# protocol's `from a harness hook` and the definition's `from any harness's hook` -- and both spellings
# are asked for, since a leg keyed on one of them certifies the home that carries the other.
#
# Paired with a PRESENCE control over the same regions: `no hook is named` and `the paragraph emptied`
# are otherwise the same green row. The three callers that remain are the control, and they are the
# three a shipped file actually performs -- by hand, from CI, and as the `Verify` of the archive moves,
# which A10 counts from the tree.
#
# THE REGION IS THE CHECK'S OWN PARAGRAPH and not the whole of `## Keeping`, which is the section's
# other resident: the structure guard, whose paragraph names a HARNESS ADAPTER because that is what
# performs it. A leg over the section reddens on that neighbour and reports the check as naming a
# caller it does not name -- this block's own house rule, that a verdict keyed on a verb takes its
# object with it, asked of a section instead of a sentence.
para91() {  # $1 = a home -> the check's paragraph, from its lead to the structure guard's
  sec90 "$1" '^## Keeping' | awk '/^\*\*The structure guard\.\*\*/{f=0} /^\*\*The check\.\*\*/{f=1} f'
}
a17_91=""
K17P91="$(para91 "$CTXP91")"
K17D91="$(para91 "$CTXD91")"
if [ -z "$K17P91" ] || [ -z "$K17D91" ]; then
  a17_91=" [the Keeping section did not extract from one of the two homes -- no verdict drawn from an empty region]"
else
  for pair91 in "the protocol~$K17P91" "the definition~$K17D91"; do
    lbl91="${pair91%%~*}"; reg91="${pair91#*~}"
    [ "$(nreg "$reg91" 'harness')" = 0 ] \
      || a17_91="$a17_91 [${lbl91} still names a harness hook among the check's callers]"
    for c91 in 'by hand' 'from CI' 'archive'; do
      [ "$(nreg "$reg91" "$c91")" = 0 ] \
        && a17_91="$a17_91 [${lbl91} no longer names the caller '${c91}' -- the region is empty of callers, not free of false ones]"
    done
  done
fi
[ -z "$a17_91" ] && ok "A17 every caller the check's paragraph names is one a shipped file performs" \
                 || bad "A17 every caller the check's paragraph names is one a shipped file performs:$a17_91"

# --- A18: every documented map example is a value the check accepts -------------------------------
# Generated in the Conform phase of the task that settles the map's one base, and the SECOND shape this
# row was written in. The first swept the shipped tree for the old form and matched it as text -- which
# is a verdict site whose evidence is this engine's own prose, the class the recurrence guard refuses
# outright and with no escape hatch. It was right twice over: the criterion says a documented value must
# RESOLVE, and resolving is an oracle the check already owns, so reading the documents was the weaker
# instrument as well as the refused one.
#
# So the check is the oracle. Each documented example is lifted into a fixture project.yml, the file its
# key conventionally names is written at the conventional place, and the check is RUN. An example
# written under the `.ai-flow/` base does not resolve from the fixture's root and the check says so; the
# same example written from the root resolves and it passes. Nothing here matches a pattern against a
# sentence, and a rewording of either document cannot move this verdict.
#
# The two surfaces are asked separately and both are asked, because they are produced by different
# hands: the guide is prose an author edits, the template is a file an adopter copies. Correcting one
# and not the other is the state this task found the engine in.
a18_91=""
# `steering:` entries out of a document: the key and the value of every INDENTED `key: value` line that
# follows a `steering:` lead, a comment marker stripped where there is one, ending at the first line that
# starts in column zero -- which is what keeps the guide's next top-level key, and the template's commented
# `review:` block beneath it, out of a fixture built for the steering map. The extractor
# takes a VALUE out of the documents and never spends one as a pattern -- the position that separates
# admissible counting from a suite judging a file by a string it copied out of itself.
entries91() {  # $1 = the file to lift from
  awk '
    /^[ \t]*#?[ \t]*steering:/ { m = 1; next }
    m && /^[^ \t]/            { m = 0 }
    m {
      line = $0
      sub(/^[ \t]+/, "", line)
      sub(/^#[ \t]*/, "", line)
      if (line !~ /^[A-Za-z0-9_+.-]+:[ \t]+[^ \t]/) next
      k = line; sub(/:.*$/, "", k)
      # The SAME normalisation the checks own parser applies -- inline comment, trailing space,
      # surrounding quotes -- and not a truncation at the first space. This extractor stands in for that
      # parser on the documented surfaces, so where the two disagree the fixture measures a string the
      # guide does not show, and the whole argument of the row (the check is the oracle) is spent on it.
      # NO APOSTROPHE BELOW OR ABOVE: this awk program is a single-quoted shell string, so one ends it.
      v = line; sub(/^[^:]*:[ \t]*/, "", v)
      sub(/[ \t]+#.*$/, "", v); sub(/[ \t]+$/, "", v)
      gsub(/^["'"'"']|["'"'"']$/, "", v)
      print k "\t" v
    }
  ' "$1"
}
for pair91 in "the distributed guide~docs/customization.md" "the template an adopter copies~template/.ai-flow/project.yml"; do
  lbl91="${pair91%%~*}"; src91="${pair91#*~}"
  if [ ! -r "$src91" ]; then
    a18_91="$a18_91 [${lbl91}: ${src91} is unreadable]"
    continue
  fi
  if [ ! -r "$CHK91" ]; then
    a18_91="$a18_91 [$CHK91 is not there -- no verdict drawn from an absent check]"
    continue
  fi
  ent91="$(entries91 "$src91")"
  # An empty extraction is not a document free of examples: it is an extractor that stopped matching,
  # and a fixture built from nothing passes the check for the wrong reason. Both documents carry at
  # least one example by construction -- a surface that stops carrying one is a change this row should
  # notice, not one it should wave through.
  if [ -z "$ent91" ]; then
    a18_91="$a18_91 [${lbl91} yielded no map example -- the fixture would be empty and its pass would mean nothing]"
    continue
  fi
  A18B91="$BOX91/a18-$(printf '%s' "$lbl91" | tr -cd 'a-z')"; mk91 "$A18B91"
  # THE SOURCE'S OWN LEAD, carried verbatim where it is a block lead. Writing `steering:` here instead
  # was this row's own defect: it normalised away the one property of the documented block the check
  # chokes on, so the row green-lit a document the check would go blind on. A lead that is a FLOW
  # mapping is not carried -- the template's is `steering: {}` and its examples beneath it are comments,
  # so carrying it would build a fixture with no entries and assert nothing. The lead shapes themselves
  # are A19's subject; what this row owes is not to hide them.
  lead91="$(grep -m1 -E '^steering:' "$src91")"
  case "$(printf '%s' "$lead91" | sed -e 's/^steering:[ \t]*//' -e 's/[ \t]*#.*$//' -e 's/[ \t]*$//')" in
    "") printf '%s\n' "$lead91" > "$A18B91/.ai-flow/project.yml" ;;
    *)  printf 'steering:\n'    > "$A18B91/.ai-flow/project.yml" ;;
  esac
  printf '%s\n' "$ent91" | while IFS="$(printf '\t')" read -r k91 v91; do
    [ -n "$k91" ] || continue
    printf '  %s: %s\n' "$k91" "$v91" >> "$A18B91/.ai-flow/project.yml"
    # The file at the place the convention puts it, and at no other. Writing it wherever the value
    # happens to point would make every form resolve and the row would pass on any document at all.
    good91 "$A18B91/.ai-flow/steering/$k91.md"
  done
  rc91="$(run91 "$A18B91")"
  [ "$rc91" = 0 ] \
    || a18_91="$a18_91 [${lbl91} documents an example the check refuses (exit ${rc91}): $(grep -F "$FAILMK91" "$OUT91" | head -2 | tr -s ' \n' ' ')]"
  # The exit status alone does not bind this row to anything: a check with no verdict over the map
  # exits 0 whatever the documents say, and the row would report a corrected guide on the strength of
  # a lookup that never happened. So the verdict is asked for BY NAME, per extracted key.
  printf '%s\n' "$ent91" | while IFS="$(printf '\t')" read -r k91 v91; do
    [ -n "$k91" ] || continue
    grep -q -F "steering:$k91" "$OUT91" || printf 'x'
  done | grep -q x \
    && a18_91="$a18_91 [${lbl91}: the check drew no map verdict over an extracted example -- the pass is unmeasured]"
done
[ -z "$a18_91" ] && ok "A18 every documented map example is a value the check accepts" \
                 || bad "A18 every documented map example is a value the check accepts:$a18_91"

# --- A19: the lead is classified, and one the parser does not take is reported, never read as empty ---
# A REPAIR LEG, written at the Verify gate of the task that added the map verdict, against a confirmed
# finding: the parser entered the block on a bare `steering:` alone and switched OFF for every other
# spelling, so two legal shipped shapes yielded zero entries IN SILENCE -- a lead carrying a trailing
# comment, which is the form `docs/customization.md` documents in the sample it calls the one the phase
# skills read, and a populated flow mapping. The run exited 0 and every value in the map was checked by
# nothing: the defect the verdict exists to end, one level up.
#
# FOUR shapes and not two, because the rule has three answers and a leg asserting only the two failures
# is satisfied by a parser that refuses everything. `{}` is the shipped default and the one legitimate
# zero; the bare lead is the control that proves the machinery is live on this fixture at all.
#
# Each shape carries the SAME non-resolving value, so what varies between the four runs is the lead and
# nothing else. A fixture that also changed its entries would measure the pair and neither of them.
a19_91=""
if [ ! -r "$CHK91" ]; then
  a19_91=" [$CHK91 is not there -- no verdict drawn from an absent check]"
else
  for pair91 in \
    'a lead carrying a trailing comment~steering:                   # area -> its rules file~entry' \
    'a populated flow mapping~steering: {auth: .ai-flow/steering/nope.md}~lead' \
    'the shipped empty flow mapping~steering: {}~silent' \
    'a bare block lead~steering:~entry'; do
    lbl91="${pair91%%~*}"; rest91="${pair91#*~}"; lead91="${rest91%~*}"; want91="${rest91##*~}"
    A19B91="$BOX91/a19-$(printf '%s' "$want91$lbl91" | tr -cd 'a-z')"; mk91 "$A19B91"
    good91 "$A19B91/.ai-flow/steering/payments.md"
    printf '%s\n  auth: .ai-flow/steering/nope.md\n' "$lead91" > "$A19B91/.ai-flow/project.yml"
    rc91="$(run91 "$A19B91")"
    case "$want91" in
      entry)
        [ "$rc91" != 0 ] \
          || a19_91="$a19_91 [${lbl91}: a value that resolves to nothing exits 0 -- the block was not read]"
        grep -F "$FAILMK91" "$OUT91" | grep -- "$MAPRULE91" | grep -q -F 'auth' \
          || a19_91="$a19_91 [${lbl91}: no failing verdict names the entry -- zero entries is wearing the face of an empty map]"
        ;;
      lead)
        [ "$rc91" != 0 ] \
          || a19_91="$a19_91 [${lbl91}: a lead the parser does not take exits 0]"
        grep -F "$FAILMK91" "$OUT91" | grep -q -- "$MAPRULE91" \
          || a19_91="$a19_91 [${lbl91}: a lead the parser does not take draws no verdict at all]"
        ;;
      silent)
        [ "$rc91" = 0 ] \
          || a19_91="$a19_91 [${lbl91}: the one legitimate zero is an error (exit ${rc91})]"
        grep -F "$FAILMK91" "$OUT91" | grep -q -- "$MAPRULE91" \
          && a19_91="$a19_91 [${lbl91}: the shipped default draws a failing verdict]"
        ;;
    esac
  done
fi
# The fourth state, and the one the old reader had no answer for: a project.yml that EXISTS and cannot
# be read. Carried over from the key-only reader, the tolerance answered it with the same silence as a
# project that declares nothing -- one guard standing in for two invariants, and the second of them is
# the reason this verdict exists at all. Skipped where the runner can read it anyway, because a check
# that cannot be made to fail is a check that proves nothing about the branch it names.
if [ -r "$CHK91" ]; then
  A19U91="$BOX91/a19-unreadable"; mk91 "$A19U91"
  good91 "$A19U91/.ai-flow/steering/payments.md"
  printf 'steering:\n  auth: .ai-flow/steering/nope.md\n' > "$A19U91/.ai-flow/project.yml"
  chmod 000 "$A19U91/.ai-flow/project.yml" 2>/dev/null || true
  if [ -r "$A19U91/.ai-flow/project.yml" ]; then
    a19_91="$a19_91 [the unreadable case could not be staged -- this runner reads the file anyway, so the branch is unmeasured]"
  else
    rc91="$(run91 "$A19U91")"
    [ "$rc91" != 0 ] \
      || a19_91="$a19_91 [a declaration that exists and cannot be read exits 0 -- the silence the verdict was added to end]"
    grep -F "$FAILMK91" "$OUT91" | grep -q -- "$MAPRULE91" \
      || a19_91="$a19_91 [an unreadable declaration draws no verdict at all]"
  fi
  chmod 644 "$A19U91/.ai-flow/project.yml" 2>/dev/null || true
fi
[ -z "$a19_91" ] && ok "A19 a lead the parser does not take is reported, never read as an empty map" \
                 || bad "A19 a lead the parser does not take is reported, never read as an empty map:$a19_91"

# --- A20: the map verdict is the survey's, and the argument form is still a request ------------------
# A REPAIR LEG, written at the Verify gate against a confirmed finding. Called unconditionally, the map
# verdict reached the form that names a file -- which is the form `protocols/backlog.md` prescribes for
# the three archive moves that write a context file, each worded "on the file". An adopter with one
# stale entry could then land no context file at all: every one of those moves failed its own Verify
# over a declaration the move never wrote and cannot fix from where it stands. That is a second
# consequence beyond the one the task's contract disclosed, and not the one the operator accepted.
#
# BOTH directions over ONE fixture, because each alone is satisfied by the wrong check: a verdict that
# never fires anywhere passes the first, and one that fires everywhere passes the second.
a20_91=""
if [ ! -r "$CHK91" ]; then
  a20_91=" [$CHK91 is not there -- no verdict drawn from an absent check]"
else
  A20B91="$BOX91/a20"; mk91 "$A20B91"
  good91 "$A20B91/.ai-flow/steering/payments.md"
  printf 'steering:\n  auth: .ai-flow/steering/nope.md\n' > "$A20B91/.ai-flow/project.yml"
  # The request form: the named file is in shape, so the run is clean and says nothing about the map.
  rc91="$(run91 "$A20B91" .ai-flow/steering/payments.md)"
  [ "$rc91" = 0 ] \
    || a20_91="$a20_91 [a run asked about one file in shape fails over a map entry it never touched (exit ${rc91})]"
  grep -q -- "$MAPRULE91" "$OUT91" \
    && a20_91="$a20_91 [the request form draws a map verdict -- the argument form is no longer a request]"
  # The survey form, over the SAME fixture: the entry is still broken and the survey still says so.
  rc91="$(run91 "$A20B91")"
  [ "$rc91" != 0 ] \
    || a20_91="$a20_91 [the survey form does not fail the same broken entry -- the verdict fires nowhere]"
  grep -F "$FAILMK91" "$OUT91" | grep -q -- "$MAPRULE91" \
    || a20_91="$a20_91 [the survey form draws no map verdict at all]"
fi
[ -z "$a20_91" ] && ok "A20 the map verdict is the survey's, and the argument form is still a request" \
                 || bad "A20 the map verdict is the survey's, and the argument form is still a request:$a20_91"

# --- A21: the app-key exemption is per key and its value, not the whole file or its name ----------
# Legs (a) and (b) are the bug's own two reproductions: a domain file whose OWN basename is a
# declared key used to skip the WHOLE file, so a title naming a DIFFERENT application still printed
# `ok`. Leg (c) is the fix's own corollary: a key aliased to a differently-named file is a real owner
# of it now, not a coincidence the old basename comparison happened to reject. Leg (d) is the boundary
# that must not move -- the two fixed files never enter the `.ai-flow/steering/*` branch at all.
a21_91=""
if [ ! -r "$CHK91" ]; then
  a21_91=" [$CHK91 is not there -- no verdict drawn from an absent check]"
else
  # (a) apps-backed: the file's own basename (gate-manager) is a declared, apps-backed key, and its
  # title names a DIFFERENT declared key (resident-mobile) -- the whole-file skip used to swallow this.
  A21A91="$BOX91/a21-apps-own"; mk91 "$A21A91"
  mkdir -p "$A21A91/apps/gate-manager" "$A21A91/apps/resident-mobile"
  printf 'steering:\n  gate-manager: .ai-flow/steering/gate-manager.md\n  resident-mobile: .ai-flow/steering/resident-mobile.md\n' \
    > "$A21A91/.ai-flow/project.yml"
  good91 "$A21A91/.ai-flow/steering/gate-manager.md"
  sed -e 's/^- \*\*Refund flow\*\*/- **Password Writes (resident-mobile)**/' \
      -e 's/^## Refund flow$/## Password Writes (resident-mobile)/' \
      "$A21A91/.ai-flow/steering/gate-manager.md" > "$A21A91/.ai-flow/steering/gate-manager.md.t" \
    && mv "$A21A91/.ai-flow/steering/gate-manager.md.t" "$A21A91/.ai-flow/steering/gate-manager.md"
  rc91="$(run91 "$A21A91" .ai-flow/steering/gate-manager.md)"
  [ "$rc91" != 0 ] \
    || a21_91="$a21_91 [an apps-backed key's own file naming a different application exits 0]"
  grep -F "$FAILMK91" "$OUT91" | grep -- 'app-key' | grep -q -F 'resident-mobile' \
    || a21_91="$a21_91 [the failing app-key line does not name the foreign application 'resident-mobile']"

  # (b) libs-backed: the same shape, but the file's own key (auth) is backed only by libs/, never apps/.
  A21B91="$BOX91/a21-libs-own"; mk91 "$A21B91"
  mkdir -p "$A21B91/libs/auth" "$A21B91/apps/gate-manager"
  printf 'steering:\n  auth: .ai-flow/steering/auth.md\n  gate-manager: .ai-flow/steering/gate-manager.md\n' \
    > "$A21B91/.ai-flow/project.yml"
  good91 "$A21B91/.ai-flow/steering/auth.md"
  sed -e 's/^- \*\*Refund flow\*\*/- **Phone-Based Auth (gate-manager)**/' \
      -e 's/^## Refund flow$/## Phone-Based Auth (gate-manager)/' \
      "$A21B91/.ai-flow/steering/auth.md" > "$A21B91/.ai-flow/steering/auth.md.t" \
    && mv "$A21B91/.ai-flow/steering/auth.md.t" "$A21B91/.ai-flow/steering/auth.md"
  rc91="$(run91 "$A21B91" .ai-flow/steering/auth.md)"
  [ "$rc91" != 0 ] \
    || a21_91="$a21_91 [a libs-backed key's own file naming a different application exits 0]"
  grep -F "$FAILMK91" "$OUT91" | grep -- 'app-key' | grep -q -F 'gate-manager' \
    || a21_91="$a21_91 [the failing app-key line does not name the foreign application 'gate-manager']"

  # (c) the corollary: an aliased key -- its map value resolves to a file whose basename is NOT its own
  # name -- owns that file, and naming itself in the title passes rather than failing on a coincidence.
  A21C91="$BOX91/a21-alias"; mk91 "$A21C91"
  mkdir -p "$A21C91/apps/checkout"
  printf 'steering:\n  checkout: .ai-flow/steering/payments.md\n' > "$A21C91/.ai-flow/project.yml"
  good91 "$A21C91/.ai-flow/steering/payments.md"
  sed -e 's/^- \*\*Refund flow\*\*/- **Refund flow in checkout**/' \
      -e 's/^## Refund flow$/## Refund flow in checkout/' \
      "$A21C91/.ai-flow/steering/payments.md" > "$A21C91/.ai-flow/steering/payments.md.t" \
    && mv "$A21C91/.ai-flow/steering/payments.md.t" "$A21C91/.ai-flow/steering/payments.md"
  rc91="$(run91 "$A21C91" .ai-flow/steering/payments.md)"
  [ "$rc91" = 0 ] \
    || a21_91="$a21_91 [an aliased key's own file naming itself fails (exit ${rc91}): $(grep -F "$FAILMK91" "$OUT91" | grep -- 'app-key' | head -1 | tr -s ' ')]"

  # (d) the boundary: the two fixed files never enter the `.ai-flow/steering/*` branch, whatever the
  # project's app keys are -- `mk91`'s own product.md already carries 'checkout' in a section title.
  A21D91="$BOX91/a21-fixed-untouched"; mk91 "$A21D91"
  mkdir -p "$A21D91/apps/checkout"
  printf 'steering:\n  checkout: .ai-flow/steering/payments.md\n' > "$A21D91/.ai-flow/project.yml"
  rc91="$(run91 "$A21D91" .ai-flow/product.md)"
  [ "$rc91" = 0 ] \
    || a21_91="$a21_91 [product.md fails with an app key declared, though it lies outside .ai-flow/steering/ (exit ${rc91})]"
  grep -F "$FAILMK91" "$OUT91" | grep -q -- 'app-key' \
    && a21_91="$a21_91 [product.md draws an app-key FAIL though the two-fixed-files guard should skip it entirely]"
fi
[ -z "$a21_91" ] && ok "A21 the app-key exemption is per key and its value, not the whole file or its name" \
                 || bad "A21 the app-key exemption is per key and its value, not the whole file or its name:$a21_91"

rm -rf "$BOX91"
