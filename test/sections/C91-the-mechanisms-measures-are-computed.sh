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
                        printf 'steering:\n  checkout: steering/checkout.md\n  payments: steering/payments.md\n' \
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
  printf 'steering:\n  payments: steering/payments.md\n  c++: steering/cpp.md\n' > "$A1K91/.ai-flow/project.yml"
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
  printf 'steering:\n  payments: steering/payments.md\n  verify: ../docs/borrowed.md\n' \
    > "$A2BOX91/.ai-flow/project.yml"
  rc91="$(run91 "$A2BOX91")"
  [ "$rc91" = 0 ] || a2_91="$a2_91 [the default run over files in shape exits ${rc91}]"
  for want91 in 'steering/payments.md' 'steering/undeclared.md' 'product.md' 'decisions-global.md'; do
    grep -q -F "$want91" "$OUT91" || a2_91="$a2_91 [the default set does not reach ${want91}]"
  done
  grep -q -F 'pencil-design' "$OUT91" && a2_91="$a2_91 [pencil-design.md is measured]"
  grep -q -F 'borrowed.md'   "$OUT91" && a2_91="$a2_91 [a map value outside .ai-flow/ is measured]"
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

rm -rf "$BOX91"
