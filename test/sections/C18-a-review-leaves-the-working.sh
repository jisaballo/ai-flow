echo "== C18: a review leaves the working copy as it found it =="
PP="global/protocols/plan.md"
RULE_SECTION="Mutation and the Working Copy"

# The rule's own section, bounded at the next heading and fence-aware — the same shape C14 uses for
# the task-diff definition, and for the same reason: a file-wide grep finds the citations, not the rule.
RULE="$(awk '/^## Mutation and the Working Copy/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^#+ /){f=0} f' "$VP" | tr '\n' ' ')"

# Fact 1a — the invariant itself. Asserted on the section, never on the file: every consumer names the
# section, so a file-wide grep for the citation stays green after the rule itself is deleted.
if [ -n "$RULE" ] && printf '%s' "$RULE" | grep -qi 'never modifies what it audits'; then
  ok "the verify protocol states the invariant (an audit never modifies what it audits)"
else
  bad "the verify protocol states the invariant (an audit never modifies what it audits)"
fi

# Fact 1b — the obligation, which is what the invariant is worth. An invariant with no duty attached
# reads as a preference: the change is taken back, and the run says the copy was left as found.
if [ -n "$RULE" ] \
   && printf '%s' "$RULE" | grep -qiE 'taken back|restored|puts? it back|put back' \
   && printf '%s' "$RULE" | grep -qiE 'left as it was found|byte-exact|byte-identical'; then
  ok "the rule obliges the change to be taken back and the copy proven as found"
else
  bad "the rule obliges the change to be taken back and the copy proven as found"
fi

# Fact 1c — serialisation. This is the half that answers the race, and it is the half a reader tempted
# by speed deletes first: parallel provers lose no work and still produce a verdict about a state that
# never existed.
if [ -n "$RULE" ] && printf '%s' "$RULE" | grep -qiE 'one actor at a time|one at a time|never in parallel|never beside'; then
  ok "the rule serialises proving to one actor at a time"
else
  bad "the rule serialises proving to one actor at a time"
fi

# Fact 1d — the failure mode is spoken, not silent. A run that cannot prove the copy clean says so;
# silence here is indistinguishable from a clean run, which is the defect the whole task exists for.
if [ -n "$RULE" ] \
   && printf '%s' "$RULE" | grep -qiE 'says so|declares|reports it' \
   && printf '%s' "$RULE" | grep -qiE 'rather than (staying )?silent|never silent|not stay silent'; then
  ok "the rule requires a run that cannot prove it clean to say so"
else
  bad "the rule requires a run that cannot prove it clean to say so"
fi

# Fact 1e — the evidence half of the rule, at its canonical home. Every other bullet in this section has
# a leg asserted on the `RULE` region; this one had none, and the review proved the gap by deleting the
# whole bullet with the suite green. What that leaves behind is worse than an unguarded sentence: the
# workflow header is REQUIRED to cite this section by name, so the citation would survive pointing at a
# section that no longer contains the rule it cites.
#
# Two legs, because two clauses are load-bearing and they fail differently. The prohibition is what the
# rule says; the exemption is what keeps the actor appointed to run from reading the prohibition as its
# own, and a rule that swallowed its own prover would return every proposed mutation unproven while
# reading, in a report, exactly like a review that proved them.
r1e=""
[ -n "$RULE" ] || r1e="$r1e rule-region-empty"
printf '%s' "$RULE" | grep -qiE 'never what it ran' || r1e="$r1e prohibition-absent"
printf '%s' "$RULE" | grep -qiE 'appointed to run it is the one whose outcome' || r1e="$r1e exemption-absent"
[ -z "$r1e" ] \
  && ok "the rule states what an auditor may report, and exempts the actor appointed to run" \
  || bad "the rule states what an auditor may report, and exempts the actor appointed to run (missing:$r1e)"

# Fact 1f — and it has one home, like its sibling. The canary is the third-person wording, which the
# workflow's second-person instruction deliberately does not match: the prompt is required to CITE this
# section, never to restate it, and a second copy is the one that drifts.
NEW_RULE_HOMES="$(grep -rlie 'never what it ran' global/ 2>/dev/null | wc -l | tr -d ' ')"
[ "$NEW_RULE_HOMES" = "1" ] \
  && ok "the evidence rule is stated in exactly one engine file (found in $NEW_RULE_HOMES)" \
  || bad "the evidence rule is stated in exactly one engine file (found in $NEW_RULE_HOMES)"

# The workflow's shared prompt header, bounded by the join that closes it: the five auditors and the
# refuter all inherit it, so a fact placed here is a fact every worker reads — and a fact asserted on
# the whole file would pass on the schema, the comments, or a dimension that no longer includes it.
CTX="$(awk "/^const ctx = \[/{f=1;next} /^\]\.join/{f=0} f" "$VW" | tr '\n' ' ')"

# Fact 2 — the three consumers cite the rule by the section that owns it. A consumer that names no
# section sends its reader nowhere, which is how a second, drifting copy gets written.
for pair in "$VS:the verify skill" "$PP:the plan protocol's Conform section"; do
  f="${pair%%:*}"; what="${pair#*:}"
  grep -qF "$RULE_SECTION" "$f" && ok "$what cites the rule's section" || bad "$what cites the rule's section"
done
# The workflow carries two citations — the shared header and the prover's own prompt — so a file-wide
# grep stays green after the auditors' half is deleted, which is the half that governs the five agents
# reading the same working copy. Each is asserted where its reader actually finds it.
{ [ -n "$CTX" ] && printf '%s' "$CTX" | grep -qF "$RULE_SECTION"; } \
  && ok "the review workflow cites the rule's section in the header every auditor reads" \
  || bad "the review workflow cites the rule's section in the header every auditor reads"

# Fact 2b — and none of them restates it. One fact in two documents is the drift this epic has already
# paid for twice; the invariant sentence is the canary, and it lives in exactly one engine file.
RULE_HOMES="$(grep -rlie 'never modifies what it audits' global/ 2>/dev/null | wc -l | tr -d ' ')"
[ "$RULE_HOMES" = "1" ] \
  && ok "the invariant is stated in exactly one engine file (found in $RULE_HOMES)" \
  || bad "the invariant is stated in exactly one engine file (found in $RULE_HOMES)"

# Fact 3a — the workers declare themselves read-only. Emergent mutation is what three tasks paid for,
# and nothing in this file has ever said not to.
if [ -n "$CTX" ] \
   && printf '%s' "$CTX" | grep -qiE 'read-only|read only' \
   && printf '%s' "$CTX" | grep -qiE 'do not (edit|modify|change|write)|never (edit|modify|change|write)'; then
  ok "the shared review header declares every worker read-only"
else
  bad "the shared review header declares every worker read-only"
fi

# Fact 3b — and every worker actually inherits that header. The declaration is worth exactly as much as
# its reach: dropping `ctx` from one dimension is a mutation that leaves the sentence in place.
CTX_USES="$(awk '/^const DIMENSIONS = \[/{f=1;next} /^\]$/{f=0} f' "$VW" | grep -cE '^[[:space:]]+ctx,')"
[ "$CTX_USES" = "5" ] \
  && ok "all five auditor prompts inherit the shared header (found $CTX_USES)" \
  || bad "all five auditor prompts inherit the shared header (found $CTX_USES)"
awk '/^function refutePrompt/{f=1} f&&/^}/{exit} f' "$VW" | grep -qE '^[[:space:]]+ctx,' \
  && ok "the refutation prompt inherits the shared header" \
  || bad "the refutation prompt inherits the shared header"

# Fact 3c — the refutation's reach, in both directions. HIGH is what blocks the archive gate and the
# refutation is what keeps a false one from blocking it; MEDIUM neither blocks nor gets fixed, so a skeptic
# spent on it buys a cleaner list and nothing else. A grep for the surviving level stays green after the
# dropped one is put back, and putting it back is the direction that costs money, so both are asserted.
REFUTE_SET="$(grep -E '^const REFUTE = ' "$VW")"
r3c=""
[ -n "$REFUTE_SET" ] || r3c="$r3c declaration-absent"
printf '%s' "$REFUTE_SET" | grep -q "'high'"   || r3c="$r3c high-missing"
printf '%s' "$REFUTE_SET" | grep -q "'medium'" && r3c="$r3c medium-present"
[ -z "$r3c" ] \
  && ok "the refutation reaches HIGH and nothing else" \
  || bad "the refutation reaches HIGH and nothing else (missing:$r3c)"

# Fact 3d — and what it does not reach is not folded in beside what it cleared. A MEDIUM sitting inside the
# confirmed set reads as though a skeptic had passed it, which is the overclaim this stage exists to remove;
# it arrives in its own set, marked unadjudicated, for the phase to decide.
r3d=""
grep -qE '^const adjudicated = all\.filter\(\(f\) => f\.adjudicated\)' "$VW" || r3d="$r3d no-adjudicated-set"
grep -qE '^const unverified = all\.filter\(\(f\) => !f\.adjudicated\)' "$VW" || r3d="$r3d no-unverified-set"
grep -qE '^const confirmed = adjudicated\.' "$VW" || r3d="$r3d confirmed-not-from-adjudicated"
grep -qE '^  unverified,' "$VW" || r3d="$r3d not-returned"
[ -z "$r3d" ] \
  && ok "what the refutation never read is returned unadjudicated, not beside what it cleared" \
  || bad "what the refutation never read is returned unadjudicated, not beside what it cleared (missing:$r3d)"

# Fact 3e — the phase that consumes the review adjudicates what the review did not. Dropping the skeptic
# from MEDIUM is a saving only while something still decides those findings: left as a list nobody acts on,
# the level yields neither a gate nor a fix and five auditors are paid to fill it. The phase already holds
# the diff and the criteria, so the decision is made where the context already is.
TRIAGE="$(awk '/Triaging the Unadjudicated/{f=1} f' "$VS" | tr '\n' ' ')"
t3e=""
[ -n "$TRIAGE" ] || t3e="$t3e section-absent"
printf '%s' "$TRIAGE" | grep -qiE 'fix now|fix it now'     || t3e="$t3e no-fix-outcome"
printf '%s' "$TRIAGE" | grep -qiE 'discoveries\.md|stage it' || t3e="$t3e no-defer-outcome"
printf '%s' "$TRIAGE" | grep -qiE 'discard|false positive' || t3e="$t3e no-discard-outcome"
[ -z "$t3e" ] \
  && ok "the verify phase triages the unadjudicated findings it is handed" \
  || bad "the verify phase triages the unadjudicated findings it is handed (missing:$t3e)"

# Fact 3f — the prover spends only on what a skeptic has already read. Proving is the most expensive
# adjudication in the run: it applies a change and runs the whole suite, one proposal at a time. A proposal
# carried by a finding nobody adjudicated is that cost spent on a guess, and an unadjudicated finding keeps
# its proposal as data for the triage instead. Asserted on the set the filter reads, because `all` and
# `unverified` would each satisfy a grep for the field's name.
grep -qE '^const proposals = confirmed\.filter' "$VW" \
  && ok "the prover's proposals come only from adjudicated survivors" \
  || bad "the prover's proposals come only from adjudicated survivors"

# Fact 3g — what a worker may REPORT, which is the half that governs evidence rather than damage. The
# header already forbids an auditor from CHANGING the copy; nothing forbade it from telling the phase
# what it RAN. The read-only sentence being in place and already guarded does not reach the account, so
# the prohibition on the act and the prohibition on the account are two rules, and only the first
# existed. The occasion that showed it is in the record; what this leg needs is the claim.
#
# Scoped to the single bullet that carries it, never to the header: `proposedMutation` occurs in the
# bullet above this one, so a header-wide grep for the route stays green with this whole bullet deleted.
# That is the hollow shape an assertion takes when it pins a noun its rule shares with the rule's
# negation, and it is why the region is extracted per claim rather than asserted on the header.
#
# The selector IS the presence claim, deliberately: the bullet is found by its prohibition, so an empty
# region and a deleted rule are the same verdict. A bullet reworded in place to PERMIT the report no
# longer carries the prohibition and is no longer found — but that reasoning covers only an edit in
# place, so the permissive-sibling leg below covers the other way in.
REPORT_BULLET="$(awk '/^const ctx = \[/{f=1;next} /^\]\.join/{f=0} f' "$VW" | grep -iE 'never what (you|it) ran' | head -1)"
[ -n "$REPORT_BULLET" ] \
  && ok "the shared review header forbids reporting what a worker ran" \
  || bad "the shared review header forbids reporting what a worker ran"

# Fact 3h — and no sibling bullet gives back what this one takes away. A permission added ALONGSIDE the
# prohibition leaves the prohibition intact, so the selector above still finds it and reports green over
# a header that now contradicts itself — with the permissive line the one a worker reads last. Asserted
# over the whole header, which is the region a contradiction can hide anywhere in, and derived from a
# count rather than a bare grep so an empty region cannot read as a pass.
PERMIT_N="$(printf '%s' "$CTX" | grep -ciE 'may report[^.]{0,60}(ran|run)|you may run|permitted to run' | tr -d ' ')"
[ "$PERMIT_N" = "0" ] \
  && ok "no header bullet permits what the prohibition forbids (found $PERMIT_N)" \
  || bad "no header bullet permits what the prohibition forbids (found $PERMIT_N)"

# Fact 3i — and the prohibition carries its route. A rule that forbids the only way a worker could settle
# a suspicion, without naming what to do instead, is the rule people route around: the suspicion still
# needs settling, and the report is still where it lands. Asserted INSIDE the bullet, which is what makes
# it a different fact from 3g rather than the same grep twice.
r3i=""
[ -n "$REPORT_BULLET" ] || r3i="$r3i bullet-absent"
printf '%s' "$REPORT_BULLET" | grep -q 'proposedMutation' || r3i="$r3i route-absent"
printf '%s' "$REPORT_BULLET" | grep -qF "$RULE_SECTION" || r3i="$r3i citation-absent"
[ -z "$r3i" ] \
  && ok "the prohibition names the route a run-dependent suspicion takes" \
  || bad "the prohibition names the route a run-dependent suspicion takes (missing:$r3i)"

# Fact 3j — the fence stops at the prover, and that boundary is load-bearing in the OTHER direction.
# The prover is the one actor appointed to run and to mutate; a prohibition that reached it would leave
# every proposed mutation unproven while reading, in a report, exactly like a review that proved them.
# It cannot inherit the header by construction — its prompt is built from scratch — and this row is what
# keeps that construction from being "simplified" into sharing `ctx`.
#
# Its own name and the anchored pattern the other extractor of this region uses: a second binding of a
# name already bound further down shadows it in one flat scope, and two extractors over one region that
# disagree on anchoring do not fail together — the one left behind then guards nothing, in green.
PROVE_PROMPT="$(awk '/^  const provePrompt = \[/{f=1;next} /^  \]\.join/{f=0} f' "$VW")"
r3j=""
[ -n "$PROVE_PROMPT" ] || r3j="$r3j prover-prompt-absent"
printf '%s' "$PROVE_PROMPT" | grep -q 'a.testCommand' || r3j="$r3j run-instruction-absent"
printf '%s\n' "$PROVE_PROMPT" | grep -qE '^[[:space:]]+ctx,' && r3j="$r3j inherits-header"
[ -z "$r3j" ] \
  && ok "the prover keeps its run instruction and does not inherit the header" \
  || bad "the prover keeps its run instruction and does not inherit the header (missing:$r3j)"

# Fact 3k — and the remedy this task DECLINED stays declined. The Scope Contract that produced this work
# named a read-only agent type on the auditor calls as the fix; measured, no available read-only type
# removes the ability to RUN a command, and the incident was an account of a run — so the named fix would
# not have prevented a word of it, and the one type that is read-only declares in its own definition that
# it does not audit. Asserting the ABSENCE is what makes that refusal durable: a paragraph explaining why
# it was declined is deletable with the suite green, and the next reader meets a plausible fix with no
# record of its measure.
#
# Scoped to the option objects of the review's own agent calls, and widened past one spelling: the
# refusal is about a capability restriction, which four different keys express, and a count over the
# whole file would forbid the file from ever explaining the refusal in a comment — which is the one place
# the next reader would look. Derived from a count, never a `grep -v` inside an `if`. The hazard is NOT
# BSD grep, which exits 1 on empty input: it is the search tool a session substitutes into its shell,
# which exits 0. This file is run as a child script and gets the system grep; a command an agent types
# does not, which is the surface where the shape has actually cost a verdict.
RESTRICT_N="$(grep -oE 'agent\([^)]*\{[^}]*\}' "$VW" | grep -cE 'agentType|allowedTools|disallowedTools|subagent_type|tools[[:space:]]*:' | tr -d ' ')"
[ "$RESTRICT_N" = "0" ] \
  && ok "no review agent call carries a capability restriction (found $RESTRICT_N)" \
  || bad "no review agent call carries a capability restriction (found $RESTRICT_N)"

# Fact 4a — the mutation instinct becomes a structured proposal the worker hands over.
FSCHEMA="$(awk '/^const FINDINGS_SCHEMA = \{/{f=1} f&&/^\}$/{print;exit} f' "$VW" | tr '\n' ' ')"
if [ -n "$FSCHEMA" ] && printf '%s' "$FSCHEMA" | grep -q 'proposedMutation'; then
  ok "the findings schema carries a proposed mutation"
else
  bad "the findings schema carries a proposed mutation"
fi

# Fact 4b — and the header calls it a proposal the worker does not perform. A field alone invites the
# very act it was meant to replace.
if [ -n "$CTX" ] && printf '%s' "$CTX" | grep -q 'proposedMutation' \
   && printf '%s' "$CTX" | grep -qiE 'do not apply|never apply|without applying|do not run it'; then
  ok "the header describes the proposal as something the worker does not perform"
else
  bad "the header describes the proposal as something the worker does not perform"
fi

# Byte offset of a fixed string: for the facts that are an ORDER, which presence greps cannot see.
voff() { grep -obF "$2" "$1" | head -1 | cut -d: -f1; }

# Fact 5a — exactly one prover. Two of them is the race again, wearing the new name.
PROVERS="$(grep -cF "phase: 'Prove'" "$VW")"
[ "$PROVERS" = "1" ] \
  && ok "the workflow runs exactly one prover stage (found $PROVERS)" \
  || bad "the workflow runs exactly one prover stage (found $PROVERS)"
grep -qE "\{ title: 'Prove'" "$VW" \
  && ok "the workflow declares the prover phase in its meta" \
  || bad "the workflow declares the prover phase in its meta"

# Fact 5b — it runs after the refutation, not beside it. Presence cannot see an order, so this is an
# offset: a prover spawned inside the pipeline would still satisfy every check above.
O_REF="$(voff "$VW" "phase: 'Refute'")"; O_PRV="$(voff "$VW" "phase: 'Prove'")"
if [ -n "$O_REF" ] && [ -n "$O_PRV" ] && [ "$O_PRV" -gt "$O_REF" ]; then
  ok "the prover stage is sequenced after the refutation stage"
else
  bad "the prover stage is sequenced after the refutation stage"
fi

# The prover's own region, from its anchor to the end of the script.
PROVE="$(awk '/One prover, serialised/{f=1} f' "$VW")"

# The prover reads its own copy of the citation: it is the actor the rule appoints, and the header it
# does not inherit is the one that would otherwise have told it so.
# Scoped to the prompt array, never to the region: the comment introducing that region carries the
# citation too, and a human reading the source is not the reader this fact is about.
PROMPT="$(awk '/^  const provePrompt = \[/{f=1;next} /^  \]\.join/{f=0} f' "$VW" | tr '\n' ' ')"
{ [ -n "$PROMPT" ] && printf '%s' "$PROMPT" | grep -qF "$RULE_SECTION"; } \
  && ok "the prover's prompt cites the rule it works under" \
  || bad "the prover's prompt cites the rule it works under"

# Fact 5c — nothing in that region fans out. The whole point of moving the proof here is that exactly
# one worker touches the copy at a time.
if [ -n "$PROVE" ] && ! printf '%s' "$PROVE" | grep -q 'parallel('; then
  ok "the prover stage spawns no parallel work"
else
  bad "the prover stage spawns no parallel work"
fi

# Fact 6 — no proposal, no prover. Without the guard every review pays for a worker with nothing to do,
# and the promise that a clean review costs what it costs today is broken.
if [ -n "$PROVE" ] && printf '%s' "$PROVE" | grep -qE 'proposedMutation|proposals'; then
  # Anchored on a conditional over the proposals themselves, at line start. The loose form matched a
  # ternary inside the prompt text, so removing the guard entirely left the assertion green.
  G="$(printf '%s' "$PROVE" | grep -nE '^if \(.*proposals' | head -1 | cut -d: -f1)"
  A="$(printf '%s' "$PROVE" | grep -nF 'agent(' | head -1 | cut -d: -f1)"
  if [ -n "$G" ] && [ -n "$A" ] && [ "$G" -lt "$A" ]; then
    ok "the prover is guarded by the presence of a proposal"
  else
    bad "the prover is guarded by the presence of a proposal"
  fi
else
  bad "the prover is guarded by the presence of a proposal"
fi

N_INV="$(grep -nE '^[0-9]+\. \*\*Invoke the verify-review workflow' "$VS" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/')"
N_COPY="$(grep -nE '^[0-9]+\. \*\*Take the byte-exact copy' "$VS" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/')"

# Fact 7a — the copy is taken before the review is invoked, and it covers what no diff reaches.
# Resolved as its own step. It used to be a bullet of the gather, and was scoped to the bullet for a
# reason that no longer exists: the gather collected untracked files for the diff in that same step, so
# a step-wide grep for 'untracked' stayed green after the copy stopped taking them. The gather is a
# different step now and the copy step contains nothing but the copy, so the step IS the tight scope —
# and the `/untracked/` anchor below is the copy's own destination directory, never the git command.
S_COPY="$([ -n "$N_COPY" ] && vstep "$VS" "$N_COPY")"
if [ -n "$N_COPY" ]; then
  if [ -n "$S_COPY" ] \
     && printf '%s' "$S_COPY" | grep -qF '/untracked/' \
     && printf '%s' "$S_COPY" | grep -qiE 'outside the repository|mktemp'; then
    ok "the verify skill takes a byte-exact copy, untracked files included, outside the repository"
  else
    bad "the verify skill takes a byte-exact copy, untracked files included, outside the repository"
  fi
else
  bad "the verify skill takes a byte-exact copy, untracked files included, outside the repository"
fi

# Fact 7b — the comparison happens after the invocation. This is the fact the whole task turns on, so it
# is an order and not a presence: a compare step written before the invocation proves nothing at all.
if [ -n "$N_INV" ]; then
  S_AFTER="$(vstep "$VS" "$((N_INV + 1))")"
  if printf '%s' "$S_AFTER" | grep -qiE 'compare' \
     && printf '%s' "$S_AFTER" | grep -qiE 'restore' \
     && printf '%s' "$S_AFTER" | grep -qiE 'byte-exact|byte-identical|copy taken'; then
    ok "the step after the invocation compares against the copy and restores from it"
  else
    bad "the step after the invocation compares against the copy and restores from it"
  fi
else
  bad "the step after the invocation compares against the copy and restores from it"
fi

# Fact 7c — the bracketing is a step, not a suggestion. Softening it back to a discipline is the exact
# regression this task exists to end, and every hedge below leaves the sentence otherwise intact.
if [ -n "$S_COPY" ] \
   && ! printf '%s' "$S_COPY" | grep -qiE 'optional|if you remember|when convenient|recommended'; then
  ok "the copy step is stated as a step, not as a recommendation"
else
  bad "the copy step is stated as a step, not as a recommendation"
fi

# Fact 7d — the writer records the verdict, with both branches. The slot existing in the template and
# nobody being told to fill it is the same silence this task exists to end: deleting the clause from the
# write step left the whole suite green.
N_WR="$(grep -nE '^[0-9]+\. \*\*Write\*\* ' "$VS" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/')"
S_WR="$([ -n "$N_WR" ] && vstep "$VS" "$N_WR")"
if printf '%s' "$S_WR" | grep -qiE 'left as found|tree verdict' \
   && printf '%s' "$S_WR" | grep -qiE 'what differed|restored'; then
  ok "the write step records the tree verdict, both branches"
else
  bad "the write step records the tree verdict, both branches"
fi

# Fact 7e — the copy is taken in a form that can actually put things back. A plain patch cannot represent
# a binary change, so a restore from one silently cannot restore it.
if printf '%s' "$S_COPY" | grep -qF -- '--binary'; then
  ok "the copy is taken in a form that can restore a binary change"
else
  bad "the copy is taken in a form that can restore a binary change"
fi

# Fact 7f — the comparison fails closed. Reached with no record, the destructive branch would discard the
# work against nothing; reached with a record it cannot replay, it would erase and then fail to put back.
if printf '%s' "$S_AFTER" | grep -qiE 'missing|absent' \
   && printf '%s' "$S_AFTER" | grep -qiE 'not\*{0,2} enter|never enter' \
   && printf '%s' "$S_AFTER" | grep -qF -- '--check' \
   && printf '%s' "$S_AFTER" | grep -qiE 'restore \*\*nothing\*\*|restore nothing'; then
  ok "the comparison fails closed: no record and no replayable record both stop before discarding"
else
  bad "the comparison fails closed: no record and no replayable record both stop before discarding"
fi

# Fact 7g — and it names the command it must never use. The same prohibition the prover carries; one fact
# stated at both actors is what keeps the two halves of this engine from contradicting each other.
if printf '%s' "$S_AFTER" | grep -qiE 'never restore with' && printf '%s' "$S_AFTER" | grep -qF 'git checkout -- .'; then
  ok "the restore names the destructive command it must never use"
else
  bad "the restore names the destructive command it must never use"
fi

# Fact 7h — both halves of the bracketing say they are unconditional. Made conditional on something having
# been proven, the whole mechanism stops catching the case it was built for: an auditor that broke its
# read-only contract on a review where nothing was proposed.
if printf '%s' "$S_AFTER" | grep -qiE 'whether or not|regardless of|even if' \
   && printf '%s' "$S_AFTER" | grep -qiE 'completed|died|proven'; then
  ok "the comparison states it runs whether or not anything was proven"
else
  bad "the comparison states it runs whether or not anything was proven"
fi
if printf '%s' "$S_COPY" | grep -qiE 'every review|including the ones that prove nothing'; then
  ok "the copy states it is taken on every review"
else
  bad "the copy states it is taken on every review"
fi

# Fact 4c — the field is OPTIONAL. Listed as required, every auditor must invent a mutation for every
# finding, and a fabricated proposal becomes a real file change in the prover's hands — while a grep for
# the field's name stays green either way.
if [ -n "$FSCHEMA" ] && ! printf '%s' "$FSCHEMA" | grep -oE "required: \[[^]]*\]" | grep -q 'proposedMutation'; then
  ok "the proposed mutation is optional, not required of every finding"
else
  bad "the proposed mutation is optional, not required of every finding"
fi

# Facts 5d-5g — the prover's procedure, asserted on the prompt body. The stage's SHAPE was guarded above
# (one of it, after the refutation, no fan-out, guarded by a proposal) and not one line of what makes the
# stage safe: every clause below could be dropped or inverted with the suite green.
if [ -n "$PROMPT" ] \
   && printf '%s' "$PROMPT" | grep -qiE 'one at a time' \
   && printf '%s' "$PROMPT" | grep -qiE 'put the file back|before the next|before you move'; then
  ok "the prover is ordered to prove one at a time and put each file back before the next"
else
  bad "the prover is ordered to prove one at a time and put each file back before the next"
fi

# The prohibition is the only guard against a restore that deletes the very work under review — and it is
# the same command the phase's own restore names. One fact, both actors: this is where the two halves of
# the engine were found contradicting each other.
if [ -n "$PROMPT" ] && printf '%s' "$PROMPT" | grep -qF 'git checkout -- .' \
   && printf '%s' "$PROMPT" | grep -qiE 'never restore|would delete|destructive'; then
  ok "the prover is forbidden the restore that discards the work under review"
else
  bad "the prover is forbidden the restore that discards the work under review"
fi

# A guessed outcome is worse than no outcome: it retires a real finding on an invented proof.
if [ -n "$PROMPT" ] && printf '%s' "$PROMPT" | grep -q 'unproven' \
   && printf '%s' "$PROMPT" | grep -qiE 'never guess|do not guess'; then
  ok "an unrunnable proposal is unproven, never a guessed outcome"
else
  bad "an unrunnable proposal is unproven, never a guessed outcome"
fi

# Containment is the workflow's job, not the prompt's. The proposal's path is free text from an agent, and
# the prover is the one agent with write access — a path outside the repository would also be invisible to
# the phase's comparison, which only ever looks inside it.
if [ -n "$PROVE" ] \
   && printf '%s' "$PROVE" | grep -qE 'const proposals = .*inScope' \
   && printf '%s' "$PROVE" | grep -qF "startsWith('/')" \
   && printf '%s' "$PROVE" | grep -qF "'..'" \
   && printf '%s' "$PROVE" | grep -q 'changedFiles'; then
  ok "proposal paths are contained before the prover's prompt is built"
else
  bad "proposal paths are contained before the prover's prompt is built"
fi

# Fact 8 — every report template carries the verdict, and both branches of it. A slot with only the clean
# branch is the mutation that makes a dirty run unreportable while every other check stays green.
TPL_OK=1
# The paragraph is the boundary, not a fixed line count: a slot that grew by one sentence pushed the
# verdict out of a five-line window and failed this on where the prose wraps rather than on the fact.
for t in $(grep -n '^\*\*Audited\*\*' "$VP" | cut -d: -f1); do
  BLK="$(awk -v s="$t" 'NR>=s{ if (NR>s && $0 ~ /^[[:space:]]*$/) exit; buf=buf" "$0 } END{print buf}' "$VP")"
  printf '%s' "$BLK" | grep -qiE 'left as (it was )?found|working copy unchanged' || TPL_OK=0
  printf '%s' "$BLK" | grep -qiE 'was not|otherwise|restored' || TPL_OK=0
done
# A floor, not a cardinality: the loop above holds every template it finds, and zero templates would
# otherwise leave TPL_OK untouched at 1 and certify the verdict over nothing.
[ "$(grep -c '^\*\*Audited\*\*' "$VP")" -ge 1 ] 2>/dev/null || TPL_OK=0
[ "$TPL_OK" = "1" ] \
  && ok "every report template carries the tree verdict with both of its branches" \
  || bad "every report template carries the tree verdict with both of its branches"

# Fact 9 — a difference reaches the user as a suspect verdict. Restoring quietly is the failure this
# criterion guards: the copy is clean again, and the audit was written against something else.
CONS="$(awk '/^### Consolidation into verify.md/{f=1;next} (f && /^#+ /){exit} f' "$VP" | tr '\n' ' ')"
# From the file, not from the flattened section: the bullet is a run of LINES, and $CONS has had its
# newlines squeezed out for the section-wide checks above.
CONS_WC="$(awk '/^### Consolidation into verify.md/{c=1;next} (c && /^#+ /){exit} c' "$VP" \
  | awk '/^- \*\*The working copy differs/{f=1;print;next} f && /^- /{exit} f' | tr '\n' ' ')"
if [ -n "$CONS_WC" ] \
   && printf '%s' "$CONS_WC" | grep -qiE 'restore|record' \
   && printf '%s' "$CONS_WC" | grep -qiE 'verdict \*\*suspect\*\*|verdict suspect' \
   && printf '%s' "$CONS_WC" | grep -qiE 'user decides'; then
  ok "a changed working copy is consolidated as a suspect verdict for the user to decide"
else
  bad "a changed working copy is consolidated as a suspect verdict for the user to decide"
fi

# Fact 10 — the template ships no copy of the rule. It carries project data only; a copy there would be
# a second home nothing keeps in step.
# Precondition, or the check is free: with the rule written nowhere, "the template does not carry it"
# passes on an empty repository and proves nothing.
if [ "$RULE_HOMES" -ge 1 ] 2>/dev/null && ! grep -rqie 'never modifies what it audits' template/ 2>/dev/null; then
  ok "the template ships no copy of the rule"
else
  bad "the template ships no copy of the rule"
fi
