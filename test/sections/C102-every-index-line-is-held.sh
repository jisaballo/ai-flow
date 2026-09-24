# C102 — every index line written or changed this session is held to its 25-word ceiling, and a new
# STATE.md section outside the two sanctioned ones is refused the same way. Generated in the Conform
# phase from understand.md's Verifiable Criteria (T-170), against a guard this row does not yet find:
# global/hooks/index-line-budget-guard.py does not exist until Step 1 of T-170's plan writes it, so every
# row below is bound to that absence today. That is the correct red — the assertions key on the refusal's
# own words, never on the exit code alone, because a python3 "no such file" failure also exits 2 and would
# satisfy an exit-code-only leg for the wrong reason (harness nano: "a leg satisfied by something other
# than the fact it names").
echo "== C102: every index line is held to its budget by a check =="
IGRD102="$HK/index-line-budget-guard.py"

# $1 = file_path (relative to the sandbox), $2 = the new_string this session is writing -> combined
# output, hook exit code. `old_string` is a fixed placeholder: this guard reads the new text directly
# (per Unknown #4's ruling) and never diffs against what the edit replaces.
iguard102() { hookcall "$IGRD102" "$T102" "$1" Edit ",\"old_string\":\"anchor\",\"new_string\":\"$2\""; }

T102=""
if ! T102="$(mkbox)" || [ ! -d "$T102" ]; then
  bad "A1 a 26-word new Icebox line is refused, naming the count and the ceiling (no sandbox: mktemp -d failed)"
  bad "A2 the same line trimmed to 25 words is allowed (no sandbox: mktemp -d failed)"
  bad "A3 a new STATE.md heading outside the two sanctioned ones is refused (no sandbox: mktemp -d failed)"
  bad "A4 an ordinary roster-row edit to STATE.md is allowed (no sandbox: mktemp -d failed)"
  bad "A5 a file outside the four watched surfaces passes clean, whatever it contains (no sandbox: mktemp -d failed)"
else
  # A real repository, not a bare directory: this guard is expected to resolve its jurisdiction the way
  # every sibling PreToolUse guard does, through `ledger_root()`'s git-based lookup — a plain tmp dir
  # would make that lookup answer "not a project" and every row below would pass for the wrong reason,
  # once the guard exists to be judged at all.
  PROJ102="$T102/proj"
  mkproj "$PROJ102" main
  mkdir -p "$PROJ102/.ai-flow"
  T102="$PROJ102"

  # --- A1/A2: the ceiling pair, over the 4-file jurisdiction's clearest shape -------------------------
  # The prefix "- IB-042 (found in T-100)" is 5 whitespace-split tokens on its own (per Unknown #7's
  # ruling: the WHOLE rendered line is measured). 21 more words makes 26; 20 more makes 25 — the boundary
  # this row exists to prove, on the criterion's own wording: a fixture one word over the ceiling refused,
  # the same fixture trimmed to it allowed. Together they are this task's own mutation proof: today both
  # read red (the guard is absent), and Step 1 turns them both green by writing the real check — a fixture
  # that passed unimplemented would be satisfied by something other than the fact it names.
  L102_OVER="- IB-042 (found in T-100) $(nwords 21 | tr -d '\n')"
  L102_AT="- IB-042 (found in T-100) $(nwords 20 | tr -d '\n')"
  o102="$(iguard102 ".ai-flow/BACKLOG.md" "## Icebox\\n\\n${L102_OVER}\\n")"; rc102=$?
  c1_102=""
  [ "$rc102" = 2 ] || c1_102="$c1_102 [a 26-word new Icebox line was not refused (exit ${rc102})]"
  case "$o102" in *"26 words"*) : ;; *) c1_102="$c1_102 [the refusal does not state the measured word count]" ;; esac
  case "$o102" in *"25-word ceiling"*) : ;; *) c1_102="$c1_102 [the refusal does not name the 25-word ceiling]" ;; esac
  case "$o102" in *"IB-042"*) : ;; *) c1_102="$c1_102 [the refusal does not quote the offending line]" ;; esac
  [ -z "$c1_102" ] && ok "A1 a 26-word new Icebox line is refused, naming the count and the ceiling" \
                    || bad "A1 a 26-word new Icebox line is refused, naming the count and the ceiling:${c1_102}"

  o102="$(iguard102 ".ai-flow/BACKLOG.md" "## Icebox\\n\\n${L102_AT}\\n")"; rc102=$?
  c2_102=""
  [ "$rc102" = 0 ] || c2_102="$c2_102 [a 25-word new Icebox line was refused (exit ${rc102}, said: ${o102})]"
  [ -z "$o102" ]   || c2_102="$c2_102 [a 25-word line produced output, so something over the ceiling was still found]"
  [ -z "$c2_102" ] && ok "A2 the same line trimmed to 25 words is allowed" \
                    || bad "A2 the same line trimmed to 25 words is allowed:${c2_102}"

  # --- A3/A4: the STATE.md shape, an independent refusal from the ceiling above ------------------------
  o102="$(iguard102 ".ai-flow/STATE.md" "## Notes\\n\\nCross-workstream context only.\\n")"; rc102=$?
  c3_102=""
  [ "$rc102" = 2 ] || c3_102="$c3_102 [a new ## Notes heading was not refused (exit ${rc102})]"
  case "$o102" in *"## Workstreams"*) : ;; *) c3_102="$c3_102 [the refusal does not name the sanctioned Workstreams section]" ;; esac
  case "$o102" in *"## Quick Tasks Completed"*) : ;; *) c3_102="$c3_102 [the refusal does not name the sanctioned Quick Tasks section]" ;; esac
  [ -z "$c3_102" ] && ok "A3 a new STATE.md heading outside the two sanctioned ones is refused" \
                    || bad "A3 a new STATE.md heading outside the two sanctioned ones is refused:${c3_102}"

  o102="$(iguard102 ".ai-flow/STATE.md" "| coordinator | . | T-101 | E-009 | auth | - | 2026-08-01 |\\n")"; rc102=$?
  c4_102=""
  [ "$rc102" = 0 ] || c4_102="$c4_102 [an ordinary roster-row edit was refused (exit ${rc102}, said: ${o102})]"
  [ -z "$o102" ]   || c4_102="$c4_102 [an ordinary roster-row edit produced output]"
  [ -z "$c4_102" ] && ok "A4 an ordinary roster-row edit to STATE.md is allowed" \
                    || bad "A4 an ordinary roster-row edit to STATE.md is allowed:${c4_102}"

  # --- A5: jurisdiction — a file this guard does not watch passes clean, whatever it holds -------------
  # The same over-ceiling line from A1, on a file outside the four watched surfaces: if this row is green
  # for the wrong reason (word-counting everywhere), A1 already proved the mechanism fires — this row
  # proves it does NOT fire where it has no jurisdiction, matching every sibling PreToolUse guard's own
  # fail-open contract for what is not theirs to judge.
  o102="$(iguard102 "README.md" "${L102_OVER}\\n")"; rc102=$?
  c5_102=""
  [ "$rc102" = 0 ] || c5_102="$c5_102 [a file outside the watched surfaces was refused (exit ${rc102})]"
  [ -z "$o102" ]   || c5_102="$c5_102 [a file outside the watched surfaces produced output]"
  [ -z "$c5_102" ] && ok "A5 a file outside the four watched surfaces passes clean, whatever it contains" \
                    || bad "A5 a file outside the four watched surfaces passes clean, whatever it contains:${c5_102}"
fi
