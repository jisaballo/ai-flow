echo "== C68: one statement of when a step is handed off, and it rests on what the cut cannot destroy =="
# Generated in the Conform phase from understand.md's Verifiable Criteria. Every row reads prose -- which
# is what this change is, a rule four actors obey -- so each is built to fail with THE FACT THAT WAS LOST
# named, never with "the text changed".

EX68="$ROOT/global/protocols/execute.md"
FS68="$ROOT/global/skills/execute/SKILL.md"
GC68="$ROOT/global/CLAUDE.md"

# The set the home count sweeps. It includes `global/skills/` BY NAME. IB-025 records that the engine's
# existing home guards (C43's SET43, C63's A2) cannot see the phase skills, and one of the two homes this
# task retires IS a phase skill -- so a sweep inheriting that blind spot would certify the fix while the
# copy it was written against sat untouched. Its own set rather than an extension of SET43, because the
# honest remedy over there is a consolidation of two overlapping sweeps, which is a rewrite of two other
# checks' headers and not this task's to make.
SET68="$(ls "$ROOT"/global/protocols/*.md 2>/dev/null) $(ls "$ROOT"/global/skills/*/SKILL.md 2>/dev/null) $GC68 $ROOT/template/CLAUDE.md"

# The section, kept as LINES with trailing blanks dropped -- the form legs below read line SHAPE (a table
# row, a bullet, a sub-heading), so this one region must not be flattened the way every prose region in
# this file is. The SIZE leg counts words, not these lines: see A1.
MD68="$(awk '/^## Model Delegation/{f=1} (f && /^## / && !/^## Model Delegation/){f=0} f' "$EX68" 2>/dev/null \
  | awk 'NF{n=NR} {l[NR]=$0} END{for(i=1;i<=n;i++) print l[i]}')"
MDW68="$(printf '%s\n' "$MD68" | wc -w | tr -d ' ')"

# A file STATES the polarity when one of its PARAGRAPHS pairs a delegation term, a preference term and
# the unit being decided. A paragraph and not a line, because the statement spans a lead sentence and the
# criterion beneath it -- a per-line sweep reports the home itself as silent and would certify a fix that
# moved nothing.
#
# Each of the three terms is narrower than the obvious choice, and each was narrowed against a measured
# false positive rather than out of caution. `delegat|subagent|task tool` and NOT a bare `agent`, and not
# `inline` either: `inline` is what this engine calls an AUTO-LEVEL PLAN, so the loose pair reported the
# autonomy table in the lifecycle map and the accepted-positions bullet in the backlog protocol -- five
# homes where there are two, and a count that can never reach one is a row that can never go green.
# `step` is the unit: a plan is inline, a STEP is delegated, and that word is what separates them.
pol68() {
  awk 'BEGIN{RS=""} { p=tolower($0) }
       p ~ /delegat|subagent|task tool|lighter model/ \
         && p ~ /default|prefer|unless|only when|only where/ \
         && p ~ /step/ {n++}
       END{print n+0}' "$1" 2>/dev/null
}
homes68=""; nh68=0
for f68 in $SET68; do
  [ -f "$f68" ] || continue
  if [ "$(pol68 "$f68")" -gt 0 ]; then nh68=$((nh68+1)); homes68="$homes68 ${f68##*/}"; fi
done

# E0 -- the regions all extract. Drawn before any verdict, because a row read over an empty string
# reports on nothing while looking green: four of the rows below share the section alone.
e0_68=""
[ -n "$MD68" ] || e0_68="$e0_68 [the Model Delegation section did not extract]"
[ -f "$FS68" ] || e0_68="$e0_68 [the execute skill is not on disk]"
[ -f "$GC68" ] || e0_68="$e0_68 [the manual is not on disk]"
[ -z "$e0_68" ] && ok "E0 every region C68 reads extracts" || bad "E0 every region C68 reads extracts ($e0_68)"

# A1 -- the section is at most 210 words and states the choice in exactly one form.
#
# WORDS, not lines. A physical-line count over prose is typographic: this file says so itself where it
# rejects the same metric elsewhere, and it is wrong in both directions -- re-wrapping these same words
# reddens the row with the content unchanged, while the retired 37-line content restored as four
# unwrapped lines passes it. The region's longest neighbouring line here is 681 characters, so the
# unwrapped regrowth is this file's own other convention rather than a contrived case.
#
# The budget: the section was 266 words before this task and is 191 after. 210 leaves ~10% for a
# legitimate clarification and catches the retired content coming back whole -- the factor table costs
# 68 words (259), the two bullet lists 118 (309), both 186 (377).
#
# The two legs are independent and BOTH are needed; neither backstops the other. Measured: a TRIMMED
# three-row table restored under the prose scores 208 words and passes this leg -- the form leg below is
# what reddens it. And a pure reflow of the shipped section onto 7 long lines leaves the words at 191,
# which is the wrap-invariance the line count did not have.
a1_68=""
[ "$MDW68" -le 210 ] || a1_68="$a1_68 [the section is $MDW68 words, over the 210-word budget]"
# The form leg counts ENUMERATION STRUCTURES and requires ZERO. The shipped section is prose end to end,
# and that is the "one form" -- so the honest count is not "at most one enumeration" but none at all.
# Counting to a ceiling of one was the hole: prose stating the choice PLUS one restored table scores 1
# and passes, which is exactly the duplication this task exists to end.
#
# The detector is wide on purpose, because the narrow one was blind to the cheapest ways back: a run of
# TWO bullets, an indented bullet, a numbered list. A `###` sub-heading counts too -- the extraction
# stops only at `## `, so a sub-heading is inside the region, and the three `### How It Works` facts were
# folded into the prose by this task rather than kept as a fourth heading.
enum68="$(printf '%s\n' "$MD68" | grep -cE '^\||^[[:space:]]*[-*][[:space:]]|^[[:space:]]*[0-9]+\.[[:space:]]|^###[[:space:]]' | tr -d ' ')"
[ "$enum68" -eq 0 ] || a1_68="$a1_68 [$enum68 line(s) of the section are a table row, a bullet, a numbered item or a sub-heading, so the choice is stated in more than the one prose form]"
[ -z "$a1_68" ] && ok "A1 the section is at most 210 words and states the choice in one form" \
                || bad "A1 the section is at most 210 words and states the choice in one form ($a1_68)"

# A2 -- the inline path may not rest on conversation. A line that NAMES conversation is not the defect:
# the rewritten section must say out loud that prior conversation is NOT a criterion, and a bare grep
# would redden exactly the text this task exists to write. What fails is a mention that does not strike
# itself -- the contradiction is resolved only when naming it and denying it are the same sentence.
CONV68="$(printf '%s\n' "$MD68" | grep -inE 'conversation context|prior conversation|recent decisions' || true)"
a2_68=""
if [ -n "$CONV68" ]; then
  while IFS= read -r ln68; do
    [ -n "$ln68" ] || continue
    printf '%s' "$ln68" | grep -qiE 'not a criterion|not one|is not|are not|never|no longer|rather than|instead of' \
      || a2_68="$a2_68 [\"$(printf '%s' "${ln68#*:}" | cut -c1-52)\" names conversation as a criterion of the inline path]"
  done <<< "$CONV68"
fi
[ -z "$a2_68" ] && ok "A2 the inline path does not rest on context the session cut destroys" \
                || bad "A2 the inline path does not rest on context the session cut destroys ($a2_68)"

# A3 -- exactly one installed file states the default, and the sweep proving it can see the phase skills.
a3_68=""
[ "$nh68" -eq 1 ] || a3_68="$a3_68 [$nh68 installed files state the inline-versus-delegate default:$homes68]"
printf '%s' "$SET68" | grep -q 'global/skills/' \
  || a3_68="$a3_68 [the sweep cannot see the phase skills, which is the blind spot IB-025 records]"
ls "$ROOT"/global/skills/*/SKILL.md >/dev/null 2>&1 \
  || a3_68="$a3_68 [the sweep names global/skills/ but matches no file there, so that half of it asserts nothing]"
[ -z "$a3_68" ] && ok "A3 exactly one installed file states the default, and the sweep sees the phase skills" \
                || bad "A3 exactly one installed file states the default, and the sweep sees the phase skills ($a3_68)"

# A4 -- the hand-off packet names the task's OWN sheet and never the shared roster.
#
# The pre-existing sweep over this file (the `execute-agent-input` leg, ~:1219) was the only coverage this
# fact had, and it is pinned to the literal `CLAUDE.md, STATE.md, understand.md` -- a three-item phrase in
# one comma order. That order was the old sentence's. The rewritten sentence puts `this protocol` in the
# second slot, so the regression the leg exists to catch now reads `CLAUDE.md, this protocol, STATE.md,
# understand.md` and the literal cannot match it: the guard survived the edit and stopped guarding. Proven
# rather than argued -- swapping the sheet for the roster leaves the whole suite green.
#
# So this row keys on the CLAIM and judges both halves of it, over the section rather than the file: the
# packet must name the task's own sheet, and must name no roster at all. A one-directional check would
# pass a sentence that names both.
PKT68="$(printf '%s\n' "$MD68" | grep -i 'delegated agent receives\|agent receives' || true)"
a4_68=""
if [ -z "$PKT68" ]; then
  a4_68="$a4_68 [the section no longer says what a delegated agent receives, so nothing routes it anywhere]"
else
  printf '%s' "$PKT68" | grep -q 'artifacts/T-XXX/state.md' \
    || a4_68="$a4_68 [the hand-off packet does not name the task's own sheet]"
  printf '%s' "$PKT68" | grep -q 'STATE\.md' \
    && a4_68="$a4_68 [the hand-off packet routes a delegated agent to the shared roster instead of the task's own sheet]"
fi
[ -z "$a4_68" ] && ok "A4 the hand-off packet names the task's own sheet and never the shared roster" \
                || bad "A4 the hand-off packet names the task's own sheet and never the shared roster ($a4_68)"

# A5 -- the section may not restate the Supervised step-boundary rule. That rule was given a single home
# elsewhere and no other surface may state it, and this section gains a routing sentence in the same edit --
# which is the moment a rule about stopping at step boundaries looks like it belongs here.
a5_68=""
printf '%s\n' "$MD68" | grep -qiE 'supervised|step[ -]boundary|approves? each step' \
  && a5_68=" [the section states the Supervised step-boundary rule, whose single home is elsewhere]"
[ -z "$a5_68" ] && ok "A5 the section does not restate the Supervised step-boundary rule" \
                || bad "A5 the section does not restate the Supervised step-boundary rule ($a5_68)"

# B1 -- and the one statement is the Execute protocol's. A3 counts; this says WHICH, and judges the two
# retired homes on themselves: a count of one is satisfied just as well by the wrong file surviving.
b1_68=""
[ "$nh68" -eq 1 ] || b1_68="$b1_68 [$nh68 files state the choice, so a session deciding a step meets more than one]"
[ "$(pol68 "$EX68")" -gt 0 ] || b1_68="$b1_68 [the Execute protocol does not state the choice, so the one home is not the protocol]"
[ "$(pol68 "$FS68")" -eq 0 ] || b1_68="$b1_68 [the execute skill restates the polarity instead of routing to the section]"
grep -q 'Model Delegation' "$FS68" 2>/dev/null \
  || b1_68="$b1_68 [the execute skill no longer routes to the section at all, which is a hole and not a fix]"
grep -qiE '^[[:space:]]*-[[:space:]]*\*\*>[0-9]+ files' "$GC68" 2>/dev/null \
  && b1_68="$b1_68 [the manual still prefers agents on a file count, pointing the opposite way from the section]"
[ -z "$b1_68" ] && ok "B1 the one statement of the choice is the Execute protocol's, and the two rivals route or are silent" \
                || bad "B1 the one statement of the choice is the Execute protocol's, and the two rivals route or are silent ($b1_68)"

# B2 -- and the copy that governs real sessions is judged too.
#
# B1 above counts SHIPPED files. The manual a session actually loads is `~/.claude/CLAUDE.md`, which no
# tool repairs: the installer writes it only when absent and the drift guard excludes it as user-owned.
# So "exactly one installed file states the default" can be green over the trunk while the file that
# decides real behaviour states the opposite -- which is precisely what it did, and no row in this block
# could say so. Four other checks in this file already carry a twin leg for exactly this reason; this is
# the fifth, kept as its own row rather than folded into B1 so the shipped count and the un-distributed
# copy keep distinct verdicts.
#
# Guarded on existence: a verdict about a manual the host does not own blames a reader for a file they
# never had.
TW68="$HOME/.claude/CLAUDE.md"
if [ -r "$TW68" ]; then
  b2_68=""
  [ "$(pol68 "$TW68")" -eq 0 ] || b2_68="$b2_68 [the live manual states the inline-versus-delegate choice, so a real session meets two]"
  grep -qiE '^[[:space:]]*-[[:space:]]*\*\*>[0-9]+ files' "$TW68" 2>/dev/null \
    && b2_68="$b2_68 [the live manual still prefers agents on a file count -- port the edit by hand, nothing distributes ~/.claude/CLAUDE.md]"
  [ -z "$b2_68" ] && ok "B2 the live manual states no rival default" \
                  || bad "B2 the live manual states no rival default ($b2_68)"
else
  echo "  [skip] B2 the live manual states no rival default (no ~/.claude/CLAUDE.md on this host)"
fi
