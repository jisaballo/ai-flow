echo "== C71: three rules of conduct enter the rulebooks, and the audit's re-runs stay out of reach =="
# Generated in the Conform phase from understand.md's Verifiable Criteria. Two properties shape the rows.
# First, the execute region deliberately carries the re-run restriction AND the exemption that names the
# audit's own re-run, so a presence grep over the whole region is answered by either sentence: the
# exemption leg is therefore SENTENCE-scoped through `insent`, binding the exemption to the very sentence
# that carries the rule. Second, B6 is a KEEP leg -- green before any of this task's prose was written --
# and it is named as such because it guards a home that was chosen by decision, which nothing else here
# would notice being abandoned.

PLN71="$(awk '/^## Constraints/{f=1;next} f&&/^## /{exit} f' "$ROOT/global/protocols/plan.md")"
LOOP71="$(awk '/^### Execute Step Protocol/{f=1;next} f&&/^#+ /{exit} f' "$ROOT/global/protocols/execute.md")"
TDD71="$(awk '/^## Test-Driven Development/{f=1;next} f&&/^#+ /{exit} f' "$ROOT/global/protocols/execute.md")"
LC71="$(cat "$ROOT/global/protocols/lifecycle.md")"
SKL71="$(cat "$ROOT/global/skills/execute/SKILL.md")"
SKL71_6="$(awk '/^6\. \*\*Work the loop/{f=1} f&&/^7\. /{exit} f' "$ROOT/global/skills/execute/SKILL.md")"
# The re-run rule's OWN bullet, not the loop item that holds it. B3 and B4 are sentence claims, and
# `insent`'s boundary is the period: read over the whole loop item, its one chunk ran from item 3's lead
# line through five bullets to "Fix test.", so 'verify' was answered by the lead line and the exemption
# never had to share a sentence with the rule at all. Cut the region to the clause, as insent's own
# header prescribes.
RRB71="$(awk '/^   - \*\*No reassurance re-runs\*\*/{f=1;print;next} f&&/^   - /{exit} f' "$ROOT/global/protocols/execute.md")"

# Every multi-word pattern below spans this, and not a literal space. `insent` flattens the region's line
# breaks to ONE space, which its header offers as the reason no leg can redden over a re-wrap -- but the
# source's own indentation survives that flattening, so a phrase straddling a line break arrives with the
# newline's space PLUS five of indent. Measured here: re-wrapping the exemption pushed "this rule's
# subject" onto the next line and B4 went red over prose that still said exactly what it had to. The legs
# this remedy rewrites are written tolerant; B1 and B7 are frozen rows it does not touch, and the trap is
# recorded against the helper rather than papered over one block at a time.

# B1 -- the ordering rule itself. "Most likely to break" is the phrase that carries the criterion; a
# constraint merely mentioning order would leave the plan free to order by convenience.
b1_71=""
[ -n "$PLN71" ] || b1_71="$b1_71 [the plan protocol's constraints did not extract]"
[ "$(insent "$PLN71" 'order' 'most likely to break')" = 1 ] \
  || b1_71="$b1_71 [no constraint orders a plan's steps by the assumption most likely to break]"
[ -z "$b1_71" ] && ok "B1 the plan protocol orders the steps so the assumption most likely to break is tested first" \
                || bad "B1 the plan protocol orders the steps so the assumption most likely to break is tested first ($b1_71)"

# B2 -- and it says so without displacing the shape rule beside it. An ORDERING rule stated next to a
# SHAPE rule reads as its replacement unless the deferral is written down; the plan slices vertically
# first and orders the slices second. The pattern carries the NEGATION and not the verb alone: keyed on
# `displace|replace|supersede`, the rule rewritten to say it DOES displace the shape rule answered the
# leg with its own opposite.
b2_71=""
[ -n "$PLN71" ] || b2_71="$b2_71 [the plan protocol's constraints did not extract]"
[ "$(insent "$PLN71" "does${S71}not${S71}displace|without${S71}displacing|does${S71}not${S71}replace|does${S71}not${S71}supersede" 'slice|vertical')" = 1 ] \
  || b2_71="$b2_71 [the ordering rule does not defer to the vertical-slice shape rule]"
[ -z "$b2_71" ] && ok "B2 the ordering rule states that it does not displace the vertical-slice shape rule" \
                || bad "B2 the ordering rule states that it does not displace the vertical-slice shape rule ($b2_71)"

# B3 -- the restriction, in the loop that owns it. Scoped by DOMICILE and not by condition: a rule worded
# as a bare condition would forbid the audit's re-run of the last step's Verify command, which genuinely
# runs over code nothing has changed since.
#
# What the leg pins is the PROHIBITION and not its vocabulary. Keyed on `again|re-run|rerun` + `unchanged`
# it asserted only that the two words shared a chunk: the rule inverted to "you may run a command again
# over code unchanged..." left the whole suite green, and the surviving bold label was no defence because
# nothing asserted the label either. So three parts -- the label, the negation, and the condition -- and
# the region is the rule's own bullet.
b3_71=""
[ -n "$RRB71" ] || b3_71="$b3_71 [the re-run rule's bullet did not extract]"
[ "$(insent "$RRB71" "no${S71}reassurance${S71}re-run" "do${S71}not|never|forbid" 'unchanged')" = 1 ] \
  || b3_71="$b3_71 [the loop does not forbid running a command again over unchanged code]"
[ -z "$b3_71" ] && ok "B3 the execution loop forbids running a command again over code unchanged since it last ran" \
                || bad "B3 the execution loop forbids running a command again over code unchanged since it last ran ($b3_71)"

# B4 -- the exemption rides the rule's OWN sentence. This is the row the block exists for: the region
# holds both cases on purpose, so a region-wide grep proves nothing about which of them is stated. Three
# parts in one sentence -- the restriction's marker, the audit it must not reach, and the words that say
# so -- and splitting that sentence in two is what sizes this leg.
#
# Two corrections the row's first form needed, and both were the same mistake. The region was the whole
# loop item, and the prose it read carried no terminating period, so `insent` saw ONE chunk spanning five
# bullets: the exemption moved out to a sibling bullet still answered the leg, which is the arrangement
# this row exists to reject. And `audit|verify` was answered by item 3's own lead line -- "Run the Verify
# command from the plan step" -- so the reference to the audit was never required to co-occur with
# anything. Region cut to the bullet; the alternation cut to the audit.
b4_71=""
[ -n "$RRB71" ] || b4_71="$b4_71 [the re-run rule's bullet did not extract]"
[ "$(insent "$RRB71" 'unchanged' 'audit' "not${S71}its${S71}subject|not${S71}this${S71}rule|untouched|exempt")" = 1 ] \
  || b4_71="$b4_71 [the sentence carrying the re-run rule does not exempt the audit's re-run of every step's Verify command]"
[ -z "$b4_71" ] && ok "B4 the exemption for the audit's re-run is stated in the sentence that carries the re-run rule" \
                || bad "B4 the exemption for the audit's re-run is stated in the sentence that carries the re-run rule ($b4_71)"

# B4b -- and it locates that audit by NAME, at an anchor the owner still carries. The exemption first
# shipped citing "(Verify protocol, step 7)", an ordinal into another file's numbered list, and this very
# number had already rotted once inside the epic: the backlog row cited step 6, which a later task took
# for the skip-marker grep. B4 could not see it -- the ordinal is not one of its parts -- so the pointer
# could have named step 9 with every leg green. Two parts, because a name is only better than a number
# while the name still exists at the other end: the citation carries the act, and the owner carries the
# heading. Every other pointer from engine prose into verify.md is a named anchor; this makes four.
b4b_71=""
[ -n "$RRB71" ] || b4b_71="$b4b_71 [the re-run rule's bullet did not extract]"
[ "$(insent "$RRB71" "verify${S71}protocol" "re-run${S71}all${S71}verify${S71}commands")" = 1 ] \
  || b4b_71="$b4b_71 [the exemption does not cite the audit's re-run by name, or cites it by ordinal]"
grep -qF '**Re-run all Verify commands**' "$ROOT/global/protocols/verify.md" \
  || b4b_71="$b4b_71 [the verify protocol no longer carries the anchor the exemption cites]"
[ -z "$b4b_71" ] && ok "B4b the exemption cites the audit's re-run by name and the verify protocol carries that anchor" \
                 || bad "B4b the exemption cites the audit's re-run by name and the verify protocol carries that anchor ($b4b_71)"

# B5 -- the red step the fastest level has none of. The map already earns the level on "bug fix with a
# reproducible test"; what was missing is that the test comes FIRST and that its failure is the evidence,
# so both halves are legs and a rule stating only the first would report.
#
# The third leg is the carve-out, and it is load-bearing rather than tidy: the map earns this same level
# for a "mechanical refactor", which has no fault to reproduce, so without the carve-out the two
# documents oblige an impossible step. It went unguarded at first because the whole paragraph was one
# unterminated sentence -- the clause could be deleted outright and the two legs above still matched.
b5_71=""
[ -n "$TDD71" ] || b5_71="$b5_71 [the rulebook's TDD section did not extract]"
[ "$(insent "$TDD71" 'auto' 'reproduc' 'first|before')" = 1 ] \
  || b5_71="$b5_71 [no rule puts the reproducing test before the fix at the fastest level]"
[ "$(insent "$TDD71" 'failure|red' 'evidence')" = 1 ] \
  || b5_71="$b5_71 [the failure is not named as the evidence]"
[ "$(insent "$TDD71" 'refactor' "nothing${S71}to${S71}reproduce")" = 1 ] \
  || b5_71="$b5_71 [the mechanical-refactor carve-out is gone -- the rule now obliges a test the level earns without one]"
[ -z "$b5_71" ] && ok "B5 at the fastest level a bug fix writes the reproducing test first, and that failure is the evidence" \
                || bad "B5 at the fastest level a bug fix writes the reproducing test first, and that failure is the evidence ($b5_71)"

# B6 -- KEEP. Green before this task wrote a line, and it earns its row for that reason: the rule was
# deliberately housed beside the loop rather than in the level table, which states which tasks earn a
# level and states none of the behaviour. Nothing else in this suite would notice the rule acquiring a
# second home in the map.
#
# An absence leg is only as wide as the ways the claim can be written, and this one first rested on the
# single stem `reproduc`: a bullet added to the map's Auto constraints reading "writes the FAILING TEST
# first" states the whole rule and keeps the leg green. Widened to the wordings the claim can take, and
# measured against the map before being trusted -- part one alone matches three sentences there today
# (Conform's "failing tests", the Auto row's "reproducible test"), and none of them carries part two.
b6_71=""
[ -n "$LC71" ] || b6_71="$b6_71 [the lifecycle map did not read]"
[ "$(insent "$LC71" "reproduc|failing${S71}test|red${S71}step|demonstrat" "first|before${S71}the${S71}fix")" = 0 ] \
  || b6_71="$b6_71 [the map now states the red-step rule too -- the behaviour has a second home]"
[ -z "$b6_71" ] && ok "B6 KEEP the lifecycle map states no red-step rule, keeping the behaviour beside the loop" \
                || bad "B6 KEEP the lifecycle map states no red-step rule, keeping the behaviour beside the loop ($b6_71)"

# B7 -- the command routes the rule by name and copies none of it. Two legs, because a name is only worth
# adding while it stays a name: the second reads the WHOLE file for a sentence carrying the rule's own
# pair of terms, which is what a paste of the rule would produce.
b7_71=""
[ -n "$SKL71_6" ] || b7_71="$b7_71 [the command's loop step did not extract]"
[ "$(insent "$SKL71_6" 'rules a run drops first' 'reassurance|re-run')" = 1 ] \
  || b7_71="$b7_71 [the routed list does not name the re-run rule]"
[ "$(insent "$SKL71" 're-run|rerun|again' 'unchanged')" = 0 ] \
  || b7_71="$b7_71 [the command restates the rule's own text -- a second home wearing a pointer's clothes]"
[ -z "$b7_71" ] && ok "B7 the execute command names the re-run rule among the rules it routes and restates none of it" \
                || bad "B7 the execute command names the re-run rule among the rules it routes and restates none of it ($b7_71)"
