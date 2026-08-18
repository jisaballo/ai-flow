#!/bin/bash
# Conformance harness for the protocol port: the template teaches the current
# field-proven engine, fully generic. Anchors assert each ported feature exists;
# guards assert no origin-project identifiers leaked and the project.yml layering survived.
# Dependency-free (grep-based). Exit 0 only when every section is green.

set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
P="template/.ai-flow/protocols"

PASS=0; FAIL=0
ok()  { echo "  [ok]   $1"; PASS=$((PASS+1)); }
bad() { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }

has()    { grep -q "$2" "$P/$1" && ok "$1: has '$2'" || bad "$1: missing '$2'"; }
hasnt()  { grep -qiE "$2" "$P/$1" && bad "$1: contains forbidden /$2/" || ok "$1: clean of /$2/"; }

echo "== S1 anchors: quick-path / execute / backlog =="
has quick-path.md "Code comments stand alone"
has execute.md "Code Comments & Provenance"
has execute.md "Discovery Triage"
has execute.md "Conformance Contracts Exception"
has backlog.md "Icebox"
has backlog.md "Scope Contract"
has backlog.md "Growth Budget"

echo "== S2 anchors: plan / verify =="
has plan.md "Pyramid Rule"
has plan.md "Decision Register"
has plan.md "Criteria Coverage"
has plan.md "what this suite guarantees"
has verify.md "Provenance grep"
has verify.md "Business Contract"
has verify.md "Skills Feedback"

echo "== S3 anchors: understand =="
has understand.md "Business Frame"
has understand.md "## Unknowns"
has understand.md "EARS"
has understand.md "Business Closure"
has understand.md "Investigation Closure"
has understand.md "understand-write-guard"

echo "== project.yml layering keepers (guard: must STAY green) =="
has plan.md "project.yml"
has plan.md "commands.test"
grep -qi "not installed" "$P/verify.md" && ok "verify.md: skill-absent fallback" || bad "verify.md: lost skill-absent fallback"

echo "== Purity: no origin-project identifiers (all 6) =="
for f in backlog execute plan quick-path understand verify; do
  hasnt "$f.md" 'isn|residents|gate-manager|zoomin|esp32|firestore|ionic|angular|haiku|/architect|/ngrx|/data-access|/frontend-design'
  hasnt "$f.md" 'E-099|T-7[0-9][0-9]|T-9[0-9][0-9]'
done

echo "== Style: ASCII arrows only (all 6) =="
for f in backlog execute plan quick-path understand verify; do
  grep -q '→' "$P/$f.md" && bad "$f.md: unicode arrow" || ok "$f.md: ASCII arrows"
done


echo "== Global side: hook shipped + wired =="
test -f global/hooks/understand-write-guard.py && ok "understand-write-guard.py shipped" || bad "understand-write-guard.py missing"
grep -q "understand-write-guard.py" global/hooks/settings.hooks.json && ok "settings entry present" || bad "settings entry missing"
grep -q 'Edit|Write' global/hooks/settings.hooks.json && ok "Edit|Write matcher" || bad "Edit|Write matcher missing"
grep -q "understand-write-guard" global/hooks/README.md && ok "README row" || bad "README row missing"

echo "== Global side: skill flow anchors =="
G="global/skills"
grep -q "Business Frame" "$G/understand/SKILL.md" && ok "understand: Business Frame" || bad "understand: missing Business Frame"
grep -q "Unknowns" "$G/understand/SKILL.md" && ok "understand: Unknowns" || bad "understand: missing Unknowns"
grep -q "Business Closure" "$G/understand/SKILL.md" && ok "understand: Business Closure" || bad "understand: missing Business Closure"
grep -q "Contract (layer 1)" "$G/plan/SKILL.md" && ok "plan: pyramid Contract" || bad "plan: missing pyramid Contract"
grep -q "Decision Register" "$G/plan/SKILL.md" && ok "plan: Decision Register" || bad "plan: missing Decision Register"
grep -q "Criteria Coverage" "$G/plan/SKILL.md" && ok "plan: Criteria Coverage" || bad "plan: missing Criteria Coverage"
grep -q "Contract check" "$G/verify/SKILL.md" && ok "verify: Contract check" || bad "verify: missing Contract check"
grep -q "Reverse audit" "$G/verify/SKILL.md" && ok "verify: Reverse audit" || bad "verify: missing Reverse audit"
grep -q "4-auditor" "$G/verify/SKILL.md" && ok "verify: 4-auditor" || bad "verify: missing 4-auditor"

echo "== Global side: workflow contract + purity =="
W="global/workflows/verify-review.js"
grep -q "Business Contract Auditor" "$W" && ok "workflow: contract auditor" || bad "workflow: missing contract auditor"
grep -q "planPath" "$W" && ok "workflow: planPath arg" || bad "workflow: missing planPath"
grep -rqiE "residents|facade|/Users/saballo|npx nx" global/ && bad "global/: origin-project leak" || ok "global/: no origin-project leaks"

echo ""
echo "protocol-port harness: $PASS ok, $FAIL fail"
[ "$FAIL" -eq 0 ]
