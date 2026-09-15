# =====================================================================================================
# C93 -- the suite is a set of independent sections behind a filtering runner
#
# Generated in the Conform phase from understand.md's Verifiable Criteria; every row is RED until the
# preamble, the section files, the runner's filter and the sweep exist.
#
# This block judges THIS suite's own source, which is the shape that produced one defect class five
# times in C92 and cost that task four verify rounds. Three rules are applied here because of that, and
# a row added later that breaks one of them is a hollow row whatever it prints:
#
#   1. Every corpus EXCLUDES this block's own file by name, and the exclusion is ASSERTED POPULATED
#      before any verdict is read from it. An absence leg over a corpus that silently emptied is green
#      for the wrong reason, and a glob that stops matching is how it empties.
#   2. Every absence leg is PAIRED with a presence control over the same corpus and the same machinery.
#      "the old wording is gone" and "the corpus carries no wordings at all" are otherwise the same
#      green row.
#   3. The three runner rows are FUNCTIONAL and run against a FIXTURE section set inside a sandbox,
#      never against this repo's own sections: a row that invoked the real runner would re-enter this
#      file, and a structural grep over the runner's source would judge the words rather than the act.
# =====================================================================================================
echo ""
echo "== C93: the suite is a set of independent sections behind a filtering runner =="

T93="$(mkbox)" || fatal 'C93 fixtures'

SECD93="$ROOT/test/sections"
PRE93="$ROOT/test/lib/preamble.sh"
SWEEP93="$ROOT/test/tools/self-sufficiency.sh"

# The corpus, minus this block's own file. Rule 1 above: read once, asserted below before any verdict
# reads it. `find` on a directory that does not exist prints nothing and says so on stderr; the guard
# keeps that off the transcript without turning the absence into a pass.
corpus93() {
  [ -d "$SECD93" ] || return 0
  find "$SECD93" -maxdepth 1 -name 'C*.sh' 2>/dev/null | grep -v '/C93-' | sort
}
CORPUS93="$(corpus93)"
n93="$(printf '%s\n' "$CORPUS93" | grep -c .)"

# ROW 1 -- the corpus itself. Nothing below means anything without it.
if [ "${n93:-0}" -ge 74 ] && ! printf '%s\n' "$CORPUS93" | grep -q '/C93-'; then
  ok "the section corpus is populated and holds every section but this one"
else
  bad "the section corpus is populated and holds every section but this one (${n93:-0} file(s))"
fi

# -----------------------------------------------------------------------------------------------------
# The runner, exercised functionally against a fixture section set (rule 3).
#
# Three sections named C2, C9 and C10, because that triple is the only one that tells a NUMERIC
# iteration from a LEXICAL one: sorted as text the answer is C10 C2 C9, and a runner that iterates its
# directory with a bare glob gets exactly that and looks fine on any single-digit suite.
# -----------------------------------------------------------------------------------------------------
mkdir -p "$T93/test/lib" "$T93/test/sections" "$T93/test/tools"
if [ -d "$SECD93" ] && [ -r "$ROOT/test/validate.sh" ] && [ -r "$PRE93" ]; then
  cp "$ROOT/test/validate.sh" "$T93/test/validate.sh"
  cp "$PRE93" "$T93/test/lib/preamble.sh"
  for f93 in 2 9 10; do
    printf 'echo "== C%s: fixture =="\nok "C%s ran"\n' "$f93" "$f93" > "$T93/test/sections/C$f93-fixture.sh"
  done
  r93_ready=1
else
  r93_ready=0
fi

# ROW 2 -- no argument runs everything, in numeric order.
if [ "$r93_ready" = 1 ]; then
  ord93="$( cd "$T93" && bash test/validate.sh 2>/dev/null | sed -n 's/^== C\([0-9][0-9]*\).*/\1/p' | tr '\n' ' ' )"
else
  ord93=""
fi
[ "$ord93" = "2 9 10 " ] \
  && ok "an unfiltered run executes every section in numeric order" \
  || bad "an unfiltered run executes every section in numeric order (order: '${ord93}')"

# ROW 3 -- a filter runs one section and reports that section's totals, not the suite's.
if [ "$r93_ready" = 1 ]; then
  flt93="$( cd "$T93" && bash test/validate.sh C9 2>/dev/null )"
else
  flt93=""
fi
if printf '%s\n' "$flt93" | grep -q '^== C9:' \
   && ! printf '%s\n' "$flt93" | grep -qE '^== C(2|10):' \
   && printf '%s\n' "$flt93" | grep -qF 'Result: 1 passed, 0 failed'; then
  ok "a filtered run executes only the named section and reports only its totals"
else
  bad "a filtered run executes only the named section and reports only its totals"
fi

# ROW 4 -- an identifier naming no section is named, and the run fails.
#
# BOTH legs, because either alone is satisfied by a broken runner: a run that names the identifier and
# exits 0 is a silent full run, and a run that exits non-zero saying nothing is indistinguishable from a
# crash.
if [ "$r93_ready" = 1 ]; then
  ( cd "$T93" && bash test/validate.sh C999 ) > "$T93/unknown.out" 2>&1
  rc93=$?
else
  rc93=0; : > "$T93/unknown.out"
fi
{ [ "$rc93" != 0 ] && grep -qF 'C999' "$T93/unknown.out"; } \
  && ok "an identifier naming no section is named and the run exits non-zero" \
  || bad "an identifier naming no section is named and the run exits non-zero (status $rc93)"

# -----------------------------------------------------------------------------------------------------
# The independence properties, read off the corpus.
# -----------------------------------------------------------------------------------------------------

# ROW 5 -- no section file defines a helper the preamble owns.
#
# The 37 names are written out rather than derived from the corpus, and that is the point: derived from
# the files it judges, this row would assert that whatever is there is what belongs there. This list is
# the frozen contract from understand.md.
HELP93='brake clohead dmove graw hookcall hookraw insent keyed ledger
malformed manfact manstate marker89 mbul mkbig mkproj msect near90 nearok90 nearzero90 nitem nlines nreg
nstep nwords off pair purity_sweep sbullet sec90 shapes83 sheet step_no sweep89 vstep waved word83 wraw
wguard wti_classify wti_probe wti_tracked_leak'
r5_93=""
if [ "${n93:-0}" -ge 74 ] && [ -r "$PRE93" ]; then
  for h93 in $HELP93; do
    grep -qE "^${h93}\(\)[[:space:]]*\{" "$PRE93" || r5_93="$r5_93 [$h93 is not defined in the preamble]"
    printf '%s\n' "$CORPUS93" | while IFS= read -r f93; do
      grep -qE "^[[:space:]]*${h93}\(\)[[:space:]]*\{" "$f93" && printf '%s' "x"
    done | grep -q x && r5_93="$r5_93 [$h93 is still defined inside a section]"
  done
  # The list's own COMPLETENESS, which no per-name leg can give. A helper hoisted into the preamble and
  # not written above is a helper this row certifies nothing about, and the row stays green over it --
  # which is how the delivered form came to name 37 of the 45 the preamble owns, omitting the two with
  # the widest reach in the suite. The names stay written out; this leg only refuses a list that has
  # fallen behind the file it enumerates. The nine run-machinery names are the ones that are NOT helpers.
  MACH93='ok bad mkbox fatal cleanup_boxes suite_sections section_id suite_src suite_src_others'
  nd93="$(grep -cE '^[a-zA-Z_][a-zA-Z0-9_]*\(\)[[:space:]]*\{' "$PRE93" | tr -d ' ')"
  nm93="$(printf '%s\n' $MACH93 | grep -c . | tr -d ' ')"
  nh93="$(printf '%s\n' $HELP93 | grep -c . | tr -d ' ')"
  [ "$((nd93 - nm93))" = "$nh93" ] \
    || r5_93="$r5_93 [the preamble owns $((nd93 - nm93)) helpers and this list names $nh93]"
else
  r5_93=" [no preamble or no corpus to read]"
fi
[ -z "$r5_93" ] \
  && ok "every helper more than one section reads is defined in the preamble and in no section" \
  || bad "every helper more than one section reads is defined in the preamble and in no section ($r5_93)"

# ROW 6 -- no section writes a trap; the one that exists removes every sandbox mkbox handed out.
#
# Rewritten from "every $VAR a trap mentions is assigned in the same file". That form asserted a property
# OF trap lines, and there are now none in any section -- it would pass over an empty set, green because
# there is nothing to look at, which is the vacuous shape this harness exists to refuse. The positive
# fact is asserted instead, and the direction is unchanged: a section that takes teardown into its own
# hands fails this row.
#
# Why there can be only one: `trap ... EXIT` is global state and a second REPLACES the first. Seventeen
# per-section traps left the last one standing and leaked sixteen sandboxes, which is why the teardown
# used to be a chain every block extended with its neighbours' paths -- and why a filtered run died on a
# variable the neighbour that never ran would have set.
r6_93=""
if [ "${n93:-0}" -ge 74 ] && [ -r "$PRE93" ]; then
  while IFS= read -r f93; do
    [ -n "$f93" ] || continue
    grep -qE '^[[:space:]]*trap ' "$f93" && r6_93="$r6_93 [$(basename "$f93") installs its own trap]"
  done <<< "$CORPUS93"
  nt93="$(grep -cE '^[[:space:]]*trap ' "$PRE93" || true)"
  [ "${nt93:-0}" = 1 ] || r6_93="$r6_93 [the shared machinery holds $nt93 traps, not one]"
  # The trap is only as good as what reaches the registry, and only mkbox writes to it.
  awk '/^mkbox\(\) \{/{f=1} f{print} f && /^\}/{exit}' "$PRE93" | grep -q '>> "$BOXREG"' \
    || r6_93="$r6_93 [mkbox does not register the sandbox it hands out]"
  grep -q 'done < "$BOXREG"' "$PRE93" \
    || r6_93="$r6_93 [the teardown does not read the registry, so what it removes is a list of names again]"
else
  r6_93=" [no corpus or no preamble to read]"
fi
[ -z "$r6_93" ] \
  && ok "no section writes a trap; the one that exists removes every sandbox mkbox handed out" \
  || bad "no section writes a trap; the one that exists removes every sandbox mkbox handed out ($r6_93)"

# ROW 7 -- the two rows whose claim the split makes impossible carry their new wording, and only it.
#
# Scoped to the two files that own the rows, never to the corpus: this block quotes both wordings above
# and would answer itself over any corpus that included it. The presence control is rule 2 -- a
# neighbouring description from the same file, read by the same grep, so "the old wording is gone"
# cannot be satisfied by a file that was never read.
C19F93="$(printf '%s\n' "$CORPUS93" | grep -E '/C19-' | head -1)"
C21F93="$(printf '%s\n' "$CORPUS93" | grep -E '/C21-' | head -1)"
r7_93=""
for f93 in "$C19F93" "$C21F93"; do
  if [ -z "$f93" ] || [ ! -r "$f93" ]; then r7_93="$r7_93 [a section file is missing]"; continue; fi
  grep -qF 'ok "the sandbox is torn down"' "$f93" \
    || r7_93="$r7_93 [$(basename "$f93") does not carry the new wording]"
  grep -qF 'the sandbox is torn down and the live cleanup trap survives this block' "$f93" \
    && r7_93="$r7_93 [$(basename "$f93") still carries the old wording]"
  grep -qF 'the sandbox is torn down' "$f93" \
    || r7_93="$r7_93 [$(basename "$f93") was not read at all]"
done
[ -z "$r7_93" ] \
  && ok "the two trap-survival rows carry the new wording and no longer claim the neighbour's cleanup" \
  || bad "the two trap-survival rows carry the new wording and no longer claim the neighbour's cleanup ($r7_93)"

# ROW 8 -- marker89's inputs are derived outside the readable branch (IB-021).
#
# They went further than the criterion asked. The helper moved to the shared machinery, and inputs that
# stayed behind in the section that first needed them would be the same defect one level down -- so they
# sit beside it, at the top level, where nothing conditional can skip them. Asserted in BOTH directions:
# present in the preamble, and absent from every section, which is the half that would otherwise let a
# second copy grow back.
r8_93=""
if [ -r "$PRE93" ] && [ "${n93:-0}" -ge 74 ]; then
  for v93 in now83 stale83 DIM83 k83; do
    grep -qE "^${v93}=" "$PRE93" || r8_93="$r8_93 [\$$v93 is not derived in the shared machinery]"
  done
  grep -qE '^marker89\(\)' "$PRE93" || r8_93="$r8_93 [marker89 is not defined in the shared machinery]"
  while IFS= read -r f93; do
    [ -n "$f93" ] || continue
    grep -qE '^[[:space:]]*(marker89\(\)|now83=|stale83=)' "$f93" \
      && r8_93="$r8_93 [$(basename "$f93") derives the marker or its inputs again]"
  done <<< "$CORPUS93"
else
  r8_93=" [no preamble or no corpus to read]"
fi
[ -z "$r8_93" ] \
  && ok "marker89's inputs are derived outside the readable branch" \
  || bad "marker89's inputs are derived outside the readable branch ($r8_93)"

# ROW 9 -- the sweep ships. A session script that produced the same numbers would leave the next task
# re-deriving them, which is what this one paid twice for.
if [ -r "$SWEEP93" ] && $GIT ls-files --error-unmatch test/tools/self-sufficiency.sh >/dev/null 2>&1; then
  ok "the self-sufficiency sweep is a tracked file in the repository"
else
  bad "the self-sufficiency sweep is a tracked file in the repository"
fi

# ROW 10 -- the CONSTANTS half of the same criterion, which had no row at all.
#
# understand.md reads "No helper function **or constant** read by more than one section is defined inside
# a section file". ROW 5 answers the first half and nothing answered the second. Three of the names below
# (VP/VS/VW) existed as DUPLICATE definitions in two sections before this task collapsed them, which is
# precisely the regrowth this half exists to refuse -- and a criterion half nobody asserts is a half that
# grows back without anything going red.
#
# Both directions, like ROW 8 and for the same reason: present in the shared machinery, absent from every
# section. The presence half alone passes over a section that keeps its own copy beside the shared one.
CONST93='HK GIT PY3 VP VS VW MAN MANTWIN BLG24 S71 PY'
r10_93=""
if [ "${n93:-0}" -ge 74 ] && [ -r "$PRE93" ]; then
  for c93 in $CONST93; do
    grep -qE "^${c93}=" "$PRE93" || r10_93="$r10_93 [\$$c93 is not assigned in the shared machinery]"
    printf '%s\n' "$CORPUS93" | while IFS= read -r f93; do
      grep -qE "^[[:space:]]*${c93}=" "$f93" && printf '%s' "x"
    done | grep -q x && r10_93="$r10_93 [\$$c93 is assigned again inside a section]"
  done
else
  r10_93=" [no preamble or no corpus to read]"
fi
[ -z "$r10_93" ] \
  && ok "every constant more than one section reads is assigned in the preamble and in no section" \
  || bad "every constant more than one section reads is assigned in the preamble and in no section ($r10_93)"
# ROW 11 -- no helper in the shared machinery reads a name only a section assigns.
#
# The doctrine this row enforces: a shared helper takes what it needs as an ARGUMENT; it does not read a
# value its caller happens to have set. Seven helpers were hoisted into the preamble closing over a global
# that exactly one section assigns, and nothing went red -- because each had one caller, which assigned
# first. For FIVE of the seven the failure mode when a second caller appears is SILENT, not loud: the
# leaked name sits anywhere but the pipeline's last stage, so `set -u` kills an inner subshell and the
# last stage (`tr`, `head`) exits 0 on empty input -- an absence leg built on one of them reports ABSENT
# and goes green. The other two fail LOUDLY and are named here so the next reader does not generalise the
# silent shape to every leak: `keyed` interpolates the name into its final grep and `graw` passes it as
# python3's argument, so in both the dying stage IS the last one and the caller sees a non-zero status.
#
# The admission rule that let them in was applied to a caller count produced by a lexical detector, which
# counted a grep PATTERN STRING as a call. That detector is retired: no lexical pass over bash separates
# the two, proven twice. This row replaces it with a derivation that asks a different question -- not who
# calls a helper, but what a helper reads that its own file never assigns.
#
# Rule 2 above, and the class this row belongs to: a guard for a defect whose whole characteristic is that
# it stays green is the last place to accept a one-directional check. So the machinery is exercised on a
# fixture carrying a PLANTED leak before the real verdict is read from it -- an empty answer then means
# "no leaks", never "the extractor stopped extracting".
#
# A shell function ends where its BRACES BALANCE, and never at a line that merely looks like an ending.
# The two shapes a line-shape test misses are both in the file this parses: `keyed` is a one-liner whose
# `}` is followed by a trailing comment, and `shapes83` closes on an indented continuation line. Under a
# line-shape test neither closes, the reader stays open, and every following line -- top-level code
# included -- is attributed to a helper that does not contain it. Counting depth closes all 50 at their
# own last line, and `nfun93` below is what makes a future break in this model LOUD rather than silent.
scan93() { # $1 = preamble file -> `R <fn> <name>` per name read inside a body, `C <fn>` per body closed
  awk '
    /^[a-zA-Z_][a-zA-Z0-9_]*\(\)[[:space:]]*\{/ && !d { fn=$0; sub(/\(\).*/,"",fn); d=1; depth=0 }
    d {
      line=$0
      while (match(line, /\$\{?[a-zA-Z_][a-zA-Z0-9_]*/)) {
        v=substr(line, RSTART, RLENGTH); gsub(/[${]/,"",v)
        print "R " fn " " v
        line=substr(line, RSTART+RLENGTH)
      }
      t=$0; o=gsub(/\{/,"",t); t=$0; c=gsub(/\}/,"",t)
      depth += o - c
      if (depth <= 0) { print "C " fn; fn=""; d=0 }
    }' "$1"
}

# How many bodies the parse actually closed. The verdict below is an ABSENCE over the real preamble, so
# a parse that quietly stopped reading produces the same empty answer as a clean tree: this count is the
# floor that tells the two apart, and it is compared against the definitions the file declares.
nfun93() { scan93 "$1" | grep -c '^C ' | tr -d ' '; }

leak93() { # $1 = preamble file, $2 = newline list of section files -> one `fn:VAR` per leak
  local pre="$1" secs="$2" reads
  # Every name READ inside a function body of the preamble, paired with the function that reads it. A
  # helper called only by another helper is still shared layer, so the pairing is per definition and the
  # verdict below is per name: threading a value through a wrapper is a repair, not an evasion.
  reads="$(scan93 "$pre" | awk '$1 == "R" { print $2 ":" $3 }' | sort -u)"
  printf '%s\n' "$reads" | while IFS=: read -r fn v; do
    [ -n "$v" ] || continue
    # Assigned somewhere in the preamble itself -- as a constant, a local, a loop variable or a read
    # target -- is the ordinary case and not a leak.
    grep -qE "(^|[[:space:]]|;|\(|local |for |read -r )${v}=" "$pre" && continue
    grep -qE "(for|read -r|local)[[:space:]]+${v}([[:space:]]|$)" "$pre" && continue
    # Assigned by at least one section is what makes it a leak. The pattern allows LEADING WHITESPACE:
    # C31 assigns $GS indented inside `if [ "$PY3" = 1 ]`, and an anchor at column 0 misses exactly the
    # one of the seven that sits in the readable branch ROW 8 was written against.
    printf '%s\n' "$secs" | while IFS= read -r f; do
      [ -n "$f" ] && grep -qE "^[[:space:]]*${v}=" "$f" && printf '%s:%s\n' "$fn" "$v"
    done
  done | sort -u
}
r11_93=""
if [ "${n93:-0}" -ge 74 ] && [ -r "$PRE93" ]; then
  # The presence control, on the same machinery the verdict uses: a fixture preamble whose helpers close
  # over values only the fixture section assigns. Found here, an empty answer over the real tree means
  # what it says.
  #
  # BOTH shapes of each dimension, because one fixture certifies only the path it walks. A one-line body
  # puts the read on the definition line, where the scan opens and closes in the same step -- it never
  # enters the continuation, which is the path 33 of the preamble's 50 helpers use. And a section
  # assignment at column 0 never exercises the leading-whitespace allowance that `$GS` needs. The
  # multi-line helper reading an INDENTED assignment is `graw`/`$GS` reproduced exactly, which is the one
  # of the seven understand.md singles out as hardest to see.
  mkdir -p "$T93/leak/lib" "$T93/leak/sections"
  { printf '%s\n' 'plantone() { printf "%s" "$PLANT1_93"; }  # a one-liner closing before a comment'
    printf '%s\n' 'plantmulti() {'
    printf '%s\n' '  printf "%s" "$PLANT2_93"'
    printf '%s\n' '}'
  } > "$T93/leak/lib/preamble.sh"
  { printf '%s\n' 'PLANT1_93="x"'
    printf '%s\n' '  PLANT2_93="y"'
  } > "$T93/leak/sections/C01-fixture.sh"
  PLANTED93="$(leak93 "$T93/leak/lib/preamble.sh" "$T93/leak/sections/C01-fixture.sh" | tr '\n' ' ')"
  if [ "$PLANTED93" != "plantmulti:PLANT2_93 plantone:PLANT1_93 " ]; then
    r11_93=" [the extractor did not find both planted leaks: it is not measuring ($PLANTED93)]"
  elif [ "$(nfun93 "$T93/leak/lib/preamble.sh")" != 2 ]; then
    r11_93=" [the fixture parse closed $(nfun93 "$T93/leak/lib/preamble.sh") of 2 bodies]"
  else
    # The floor over the REAL parse. An absence verdict is only worth what the parse behind it is worth:
    # a model that stopped closing bodies returns the same empty answer as a clean tree.
    nd11_93="$(grep -cE '^[a-zA-Z_][a-zA-Z0-9_]*\(\)[[:space:]]*\{' "$PRE93" | tr -d ' ')"
    nc11_93="$(nfun93 "$PRE93")"
    if [ "$nc11_93" != "$nd11_93" ]; then
      r11_93=" [the preamble declares $nd11_93 helpers and the scan closed $nc11_93]"
    else
      LEAKS93="$(leak93 "$PRE93" "$CORPUS93")"
      [ -n "$LEAKS93" ] && r11_93=" [$(printf '%s' "$LEAKS93" | tr '\n' ' ')]"
    fi
  fi
else
  r11_93=" [no preamble or no corpus to read]"
fi
[ -z "$r11_93" ] \
  && ok "no helper in the shared machinery reads a name only a section assigns" \
  || bad "no helper in the shared machinery reads a name only a section assigns ($r11_93)"

# ROW 12 -- no name a section declares at top level is declared by another section.
#
# ROW 10 answers the names the SHARED layer owns: present in the preamble, absent from every section.
# Nothing answered the other half -- two sections declaring the same name with the preamble holding
# neither. Three did: T11 (a sandbox path six sections reached for), T25 (a sandbox), a5 (an accumulator).
#
# The unit is a TOP-LEVEL declaration, at column 0, and that is the claim rather than a convenience. An
# indented assignment sits inside an `if`, a `for` or a function body: it is scratch, written before it is
# read in the same block, and eighteen names are shared that way with nothing at stake -- `i`, `f`, `c`,
# `out`, `miss`. A row that reported those would report eighteen non-defects beside every real one, which
# is the alarm nobody acts on. What makes a collision cost something is a name a section DECLARES and a
# later section silently inherits, and a declaration is what column 0 marks.
#
# The cost of the boundary, stated so the next reader does not have to find it: a genuine collision written
# indented escapes this row. That is accepted here because the failure it protects against is inheritance
# across sections, and a value inherited across sections is one declared where the section can see it.
#
# Rule 2 of this block's header: the verdict is an absence, so it is read only after the same machinery has
# been made to speak on a fixture that plants one.
decl93() { # $1 = newline list of section files -> `NAME SECTIONID` per top-level declaration
  printf '%s\n' "$1" | while IFS= read -r f93d; do
    [ -n "$f93d" ] || continue
    id93d="$(section_id "$f93d")"
    grep -oE '^[A-Za-z_][A-Za-z0-9_]*=' "$f93d" | tr -d '=' | sort -u \
      | while IFS= read -r n93d; do [ -n "$n93d" ] && printf '%s %s\n' "$n93d" "$id93d"; done
  done
}
coll93() { # $1 = newline list of section files -> `NAME: id id ...` per name declared by more than one
  decl93 "$1" | sort | awk '{ n[$1] = n[$1] " " $2; c[$1]++ }
                            END { for (k in c) if (c[k] > 1) print k ":" n[k] }' | sort
}
r12_93=""
if [ "${n93:-0}" -ge 74 ] && [ -r "$PRE93" ]; then
  # The presence control, on the same machinery the verdict uses. Two fixture sections declaring one name
  # between them: found here, an empty answer over the real corpus means what it says rather than meaning
  # that the extractor stopped extracting.
  mkdir -p "$T93/coll/sections"
  printf '%s\n' 'PLANT93="a"' > "$T93/coll/sections/C01-fixture.sh"
  { printf '%s\n' 'PLANT93="b"'
    printf '%s\n' '  INDENTED93="c"'
  } > "$T93/coll/sections/C02-fixture.sh"
  printf '%s\n' '  INDENTED93="d"' >> "$T93/coll/sections/C01-fixture.sh"
  PLANTC93="$(coll93 "$(find "$T93/coll/sections" -name 'C*.sh' | sort)" | tr '\n' ' ' | sed 's/ *$//')"
  if [ "$PLANTC93" != "PLANT93: C01 C02" ]; then
    # Both halves in one comparison: the planted top-level collision must be found, and the planted
    # INDENTED one must NOT be -- a machine that reported both would be the false-red machine this row
    # was shaped to avoid, and it would pass a control that only asked whether anything was found.
    r12_93=" [the extractor did not answer the planted corpus exactly: it is not measuring ($PLANTC93)]"
  else
    COLL93="$(coll93 "$CORPUS93")"
    # A name the preamble also assigns is ROW 10's subject, not this row's: reporting it here would bill
    # one defect to two rows and send the repair to the wrong layer.
    COLL93="$(printf '%s\n' "$COLL93" | while IFS= read -r l93; do
      [ -n "$l93" ] || continue
      grep -qE "^${l93%%:*}=" "$PRE93" || printf '%s\n' "$l93"
    done)"
    [ -n "$COLL93" ] && r12_93=" [$(printf '%s' "$COLL93" | tr '\n' ' ')]"
  fi
else
  r12_93=" [no preamble or no corpus to read]"
fi
[ -z "$r12_93" ] \
  && ok "no name a section declares at top level is declared by another section" \
  || bad "no name a section declares at top level is declared by another section ($r12_93)"

# ROW 13 -- a section may read the runner's per-section variable only because the shared layer declares it.
#
# The runner assigns $SECTION once, as the loop variable of the run, and three readers close over it: the
# preamble's own extractor and two sections. Read across files and declared nowhere, it is an undeclared
# cross-file API -- the shape ROW 11 refuses for helpers, arrived at from the other side. ROW 11 asks what a
# shared helper reads that its own file never assigns; this asks what a SECTION reads that neither it nor
# the shared layer ever assigns, which no row covered.
#
# The repair the row drives is a declaration, never a rename: four call sites moved would buy nothing the
# declaration does not already give, and the name is not the defect.
#
# Rule 2 again, and it bites harder here than anywhere: the verdict is "no section reads an undeclared
# name", and the cheapest way to make that green is an extractor that finds no readers at all. So the
# machinery is shown a fixture whose shared layer declares nothing and whose section reads the name, and
# its answer is checked before the real corpus is read.
reads93() { # $1 = newline list of section files -> one section id per file reading the runner's variable
  printf '%s\n' "$1" | while IFS= read -r f93r; do
    [ -n "$f93r" ] || continue
    grep -qE '\$\{?SECTION\b' "$f93r" && printf '%s\n' "$(section_id "$f93r")"
  done
}
undecl93() { # $1 = preamble file, $2 = newline list of section files -> readers left undeclared
  grep -qE '^SECTION=' "$1" && return 0
  reads93 "$2"
}
r13_93=""
if [ "${n93:-0}" -ge 74 ] && [ -r "$PRE93" ]; then
  mkdir -p "$T93/decl/lib" "$T93/decl/sections"
  printf '%s\n' 'nothing_declared_here() { :; }' > "$T93/decl/lib/preamble.sh"
  printf '%s\n' 'printf "%s" "$SECTION"' > "$T93/decl/sections/C01-fixture.sh"
  FX93="$(find "$T93/decl/sections" -name 'C*.sh' | sort)"
  PLANTD93="$(undecl93 "$T93/decl/lib/preamble.sh" "$FX93" | tr '\n' ' ' | sed 's/ *$//')"
  if [ "$PLANTD93" != "C01" ]; then
    r13_93=" [the extractor did not name the planted undeclared reader: it is not measuring ($PLANTD93)]"
  else
    # The other direction of the same fixture: with the declaration added, the same machinery must fall
    # silent. A control that only proves the row can go red leaves it free to be red always.
    printf '%s\n' 'SECTION="${SECTION-}"' >> "$T93/decl/lib/preamble.sh"
    if [ -n "$(undecl93 "$T93/decl/lib/preamble.sh" "$FX93")" ]; then
      r13_93=" [the extractor still reports a reader after the fixture declared the name: it cannot go green]"
    else
      U93="$(undecl93 "$PRE93" "$CORPUS93" | tr '\n' ' ')"
      [ -n "$U93" ] && r13_93=" [the shared layer declares no SECTION, and these sections read it: $U93]"
    fi
  fi
else
  r13_93=" [no preamble or no corpus to read]"
fi
[ -z "$r13_93" ] \
  && ok "the runner's per-section variable is declared in the shared machinery" \
  || bad "the runner's per-section variable is declared in the shared machinery ($r13_93)"

rm -rf "$T93"
