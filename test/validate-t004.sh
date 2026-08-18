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

echo ""
echo "protocol-port harness: $PASS ok, $FAIL fail"
[ "$FAIL" -eq 0 ]
