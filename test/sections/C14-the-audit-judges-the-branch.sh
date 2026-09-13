echo "== C14: the audit judges the branch, not the working tree =="
BRAKE="global/hooks/diff-size-guard.py"

# The two steps this block reaches into, resolved by CONTENT. Moving a step renumbers every step after
# it, and an assertion that dies to renumbering is testing the numbering, not the fact: what each check
# below asserts is a property of the step that carries it, wherever that step sits. Same shape as the
# WRITE-step resolution further down, and the reason it exists.
vsn() { grep -nE "^[0-9]+\. \*\*$1" "$VS" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/'; }
NG14="$(vsn 'Gather the task diff')"
NA14="$(vsn 'Criterion audit')"

# The one definition every consumer reads: bounded at the next heading, fence-aware.
TD="$(awk '/^## The Task Diff/{f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^#+ /){f=0} f' "$VP" | tr '\n' ' ')"
# The bolded definition SENTENCE, cut at its closing marker. Scoped this tight because 'uncommitted'
# and 'untracked' both recur in the neighbouring paragraphs, so a section-wide grep stayed green when
# the sentence itself was inverted to "Uncommitted work is out of scope".
DEF="$(awk '
  /^\*\*The task diff is/ { b=$0; sub(/^\*\*/,"",b); if (index(b,"**")) { print substr(b,1,index(b,"**")-1); exit } f=1; next }
  f { b = b " " $0; if (index(b,"**")) { print substr(b,1,index(b,"**")-1); exit } }
' "$VP")"

if [ -n "$DEF" ] \
   && printf '%s' "$DEF" | grep -qiE 'since its base|since the base' \
   && printf '%s' "$DEF" | grep -qiE 'commits included|including its commits' \
   && printf '%s' "$DEF" | grep -qi 'uncommitted' \
   && printf '%s' "$DEF" | grep -qi 'untracked' \
   && ! grep -qi 'working tree, uncommitted' "$VP"; then
  ok "the verify protocol defines the task diff (branch since base + uncommitted)"
else
  bad "the verify protocol defines the task diff (branch since base + uncommitted)"
fi

# the degradation rule is part of the definition, not only of the skill that implements it: without
# this, the protocol paragraph and the templates' fallback wording were deletable with a green suite
if printf '%s' "$TD" | grep -qi 'no base resolves' && printf '%s' "$TD" | grep -qi 'unavailable'; then
  ok "the definition carries the no-base degradation rule"
else
  bad "the definition carries the no-base degradation rule"
fi

# the reverse audit and the provenance grep stop naming a scope of their own. Both patterns are
# required, and the pointer is the marked-up section name matched case-sensitively: a
# case-insensitive "the task diff" collapses onto the bare mention that is already there today,
# which made this pair incapable of failing.
for n in 4 5; do
  S="$(nstep "$VP" "$n")"
  if printf '%s' "$S" | grep -qi 'task diff' \
     && printf '%s' "$S" | grep -q '\*\*The Task Diff\*\*'; then
    ok "verify protocol step $n points at the task diff definition"
  else
    bad "verify protocol step $n points at the task diff definition"
  fi
done

S5="$([ -n "$NG14" ] && nstep "$VS" "$NG14")"
if printf '%s' "$S5" | grep -q 'origin/HEAD' \
   && printf '%s' "$S5" | grep -q 'rev-parse' \
   && printf '%s' "$S5" | grep -q 'main' \
   && printf '%s' "$S5" | grep -q 'master' \
   && printf '%s' "$S5" | grep -q 'merge-base'; then
  ok "verify skill resolves the base like the diff brake and diffs from merge-base"
else
  bad "verify skill resolves the base like the diff brake and diffs from merge-base"
fi

# which candidate WINS is the fact; three presence greps are satisfied in any order, so the order is
# asserted positionally, on the backticked forms so a substring elsewhere cannot stand in
o1="$(off "$S5" 'origin/HEAD')"; o2="$(off "$S5" '`main`')"; o3="$(off "$S5" '`master`')"
if [ -n "$o1" ] && [ -n "$o2" ] && [ -n "$o3" ] && [ "$o1" -lt "$o2" ] && [ "$o2" -lt "$o3" ]; then
  ok "the skill states the base precedence in the brake's order"
else
  bad "the skill states the base precedence in the brake's order (offsets: $o1/$o2/$o3)"
fi

# derived from the source of truth rather than restated beside it: change the hook's candidate list
# and this harness fails, which is the only thing that makes a knowingly duplicated rule safe
cands="$(sed -n "s/.*for cand in (\(.*\)):.*/\1/p" "$BRAKE" | tr -d "\"'" | tr ',' ' ')"
miss=""
for c in $cands; do printf '%s' "$S5" | grep -q "\`$c\`" || miss="$miss $c"; done
if [ -n "$cands" ] && [ -z "$miss" ]; then
  ok "the skill names every base candidate the diff brake actually tries"
else
  bad "the skill names every base candidate the diff brake actually tries (missing:$miss)"
fi

# THE operative command, asserted by shape and not by the word 'merge-base' — which a neighbouring
# bullet supplies, so the word alone stayed green both when a range operator was appended (dropping
# the uncommitted half) and when the command was reverted to plain `git diff HEAD`
MBB="$([ -n "$NG14" ] && sbullet "$VS" "$NG14" 'Capture it once')"
if printf '%s' "$MBB" | grep -qF 'MB="$(git merge-base <base> HEAD)"' \
   && ! printf '%s' "$MBB" | grep -qE 'merge-base[^`]*\.\.'; then
  ok "the skill captures the merge-base itself, with no range operator narrowing it"
else
  bad "the skill captures the merge-base itself, with no range operator narrowing it"
fi
DTB="$([ -n "$NG14" ] && sbullet "$VS" "$NG14" 'Otherwise')"
if printf '%s' "$DTB" | grep -qF 'git diff "$MB"' \
   && ! printf '%s' "$DTB" | grep -qE 'MB[^`]*\.\.'; then
  ok "the diff that becomes diffText runs from the captured base to the working tree"
else
  bad "the diff that becomes diffText runs from the captured base to the working tree"
fi

# the copy names its original, so a reader finds the brake instead of two rules that drifted apart
printf '%s' "$S5" | grep -q 'diff-size-guard' \
  && ok "the skill's base resolution cites the diff brake it copies" \
  || bad "the skill's base resolution cites the diff brake it copies"

# The protocol states the same resolution in prose, and nothing watched it. The skill's copy above is
# derived from the brake; this paragraph was the one statement of the three that could drift in silence.
# It keeps stating the rule in full rather than being reduced to a pointer, because the protocol is what
# a run follows when the skill is not installed -- so the fix is a watcher, not a deletion.
#
# Cut TIGHT, from the bolded opening to the blank line that closes it. The degradation sentence later in
# the same section also carries `main` and `master`, so a section-wide grep is satisfied by the wrong
# paragraph -- the same hazard the DEF extractor above exists for.
BP="$(awk '/^\*\*The base is resolved/{f=1} f{print} f && /^$/{exit}' "$VP" | tr '\n' ' ')"
[ -n "$BP" ] \
  && ok "the base paragraph extracted" \
  || bad "the base paragraph extracted (was the opening bold renamed?)"

# When the paragraph does not extract, the three rows below have not read their facts -- and reporting
# those facts as ABSENT sends a reader hunting for prose that is still on disk. One renaming is one
# report: each row names the extraction as its reason and makes no claim about a fact it never saw.
NOBP=" (not judged: the paragraph did not extract)"

# Derived from the brake's own source, exactly as the skill's row is: change the hook's candidate list
# and this row fails. A list restated beside the original drifts; a list read out of it cannot.
missp=""
for c in $cands; do printf '%s' "$BP" | grep -q "\`$c\`" || missp="$missp $c"; done
if [ -z "$BP" ]; then
  bad "the verify protocol's base paragraph names every candidate the diff brake actually tries$NOBP"
elif [ -n "$cands" ] && [ -z "$missp" ]; then
  ok "the verify protocol's base paragraph names every candidate the diff brake actually tries"
else
  bad "the verify protocol's base paragraph names every candidate the diff brake actually tries (missing:$missp)"
fi

# Which candidate WINS is the fact, and presence greps are satisfied in any order.
bo1="$(off "$BP" 'origin/HEAD')"; bo2="$(off "$BP" '`main`')"; bo3="$(off "$BP" '`master`')"
if [ -z "$BP" ]; then
  bad "the protocol states the base precedence in the brake's order$NOBP"
elif [ -n "$bo1" ] && [ -n "$bo2" ] && [ -n "$bo3" ] && [ "$bo1" -lt "$bo2" ] && [ "$bo2" -lt "$bo3" ]; then
  ok "the protocol states the base precedence in the brake's order"
else
  bad "the protocol states the base precedence in the brake's order (offsets: $bo1/$bo2/$bo3)"
fi

if [ -z "$BP" ]; then
  bad "the protocol's base resolution cites the diff brake it copies$NOBP"
elif printf '%s' "$BP" | grep -q 'diff-size-guard'; then
  ok "the protocol's base resolution cites the diff brake it copies"
else
  bad "the protocol's base resolution cites the diff brake it copies"
fi

CF="$([ -n "$NG14" ] && sbullet "$VS" "$NG14" 'changedFiles')"
if printf '%s' "$CF" | grep -qiE 'base-scoped|that same' \
   && printf '%s' "$CF" | grep -qi 'untracked' \
   && printf '%s' "$CF" | grep -q 'source_dirs'; then
  ok "changedFiles derives from the base-scoped diff plus untracked, scoped to source_dirs"
else
  bad "changedFiles derives from the base-scoped diff plus untracked, scoped to source_dirs"
fi

FB="$([ -n "$NG14" ] && sbullet "$VS" "$NG14" 'no base')"
if printf '%s' "$FB" | grep -q 'git diff HEAD' \
   && printf '%s' "$FB" | grep -qi 'unavailable'; then
  ok "no resolvable base falls back to the working tree and says so"
else
  bad "no resolvable base falls back to the working tree and says so"
fi

# the count the report must carry has to be measured somewhere, and written somewhere
printf '%s' "$S5" | grep -q 'rev-list' \
  && ok "the skill measures the commit count its report has to name" \
  || bad "the skill measures the commit count its report has to name"
# Resolved by content: inserting a step renumbers every step after it, and an assertion that dies to
# renumbering is testing the numbering. The fact is a property of the WRITE step, wherever it sits.
N_WRITE="$(grep -nE '^[0-9]+\. \*\*Write\*\* ' "$VS" | head -1 | sed -E 's/^[0-9]+:([0-9]+)\..*/\1/')"
S8="$([ -n "$N_WRITE" ] && nstep "$VS" "$N_WRITE")"
if printf '%s' "$S8" | grep -q '\*\*Audited\*\*' && printf '%s' "$S8" | grep -qi 'commit'; then
  ok "the report writer carries the base and the commit count into verify.md"
else
  bad "the report writer carries the base and the commit count into verify.md"
fi

# The skill's own reverse audit names where its scope comes from — and that step has already run.
# This assertion used to demand the opposite: it required the bullet to point FORWARD at the gather,
# so it was green precisely because the consumer read a diff nobody had gathered yet. Kept as an order
# over step INDEXES, which is a different mutation from the byte-offset order asserted later: a step
# renumbered without being moved kills one and not the other.
RA="$([ -n "$NA14" ] && sbullet "$VS" "$NA14" 'Reverse audit')"
if printf '%s' "$RA" | grep -qi 'task diff' \
   && [ -n "$NG14" ] && [ -n "$NA14" ] && [ "$NG14" -lt "$NA14" ]; then
  ok "the skill's reverse audit reads a task diff an earlier step already gathered"
else
  bad "the skill's reverse audit reads a task diff an earlier step already gathered"
fi

# every report template, not only the review-bearing shape: the reverse audit and the provenance grep
# consume the task diff even when the review is skipped, and the one form covers both cases. Counted
# rather than assumed, so a silently re-added second form is held to the same clause. Read off
# non-comment lines carrying the placeholders themselves — 'base' plus 'commit' were satisfied by a
# commented-out fallback line ("uncommitted" contains "commit"), so deleting the whole Audited line
# left the suite green.
TC="$(awk '
  /^```/ { if (inf) { if (seen) { total++; if (hb && hc && hf) good++ } seen=0; hb=0; hc=0; hf=0 } inf=1-inf; next }
  inf {
    if ($0 ~ /# Verify: T-XXX/) seen=1
    if ($0 ~ /^[[:space:]]*<!--/) next
    if ($0 ~ /\[base ref\]/) hb=1
    if ($0 ~ /commit\(s\)/) hc=1
    if (tolower($0) ~ /branch scope unavailable/) hf=1
  }
  END { print (good+0) "/" (total+0) }
' "$VP")"
[ "${TC#*/}" -ge 1 ] 2>/dev/null && [ "${TC%/*}" = "${TC#*/}" ] \
  && ok "every report template carries the measured base and commit count" \
  || bad "every report template carries the measured base and commit count ($TC)"

DH="$(grep 'DIFF' "$VW" | tr '\n' ' ')"
if printf '%s' "$DH" | grep -qiE 'branch|since|base' && ! printf '%s' "$DH" | grep -qi 'working tree'; then
  ok "the auditors' diff header names the branch scope, not the working tree"
else
  bad "the auditors' diff header names the branch scope, not the working tree"
fi
