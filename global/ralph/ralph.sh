#!/usr/bin/env bash
# ai-flow AFK loop (Ralph pattern).
# One disposable `claude -p` process per [afk]-tagged backlog task, serial, on a
# dedicated afk/YYYY-MM-DD branch. Hard cap on iterations — the loop is a bounded `for`.
# Rails: never main, never push (deny list — the project allowlist permits
# `git push:*`/`git *`, so the REAL rail is `--disallowedTools`, deny beats allow).
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

MAX_ITER=5
DATE="$(date +%Y-%m-%d)"
RUN_LOG=".ai-flow/afk-run-${DATE}.md"
PROMPT_FILE="$HOME/.claude/ai-flow/ralph/ralph-prompt.md"
ITER_TIMEOUT="45m"   # per-iteration cap (needs coreutils timeout/gtimeout; skipped if absent)

# `git -C` is denied wholesale: ralph works from the repo root and the -C form
# would bypass every pattern below.
DISALLOWED='Bash(git push:*),Bash(git reset:*),Bash(git checkout:*),Bash(git restore:*),Bash(git stash:*),Bash(git rm:*),Bash(git clean:*),Bash(git rebase:*),Bash(git merge:*),Bash(git cherry-pick:*),Bash(git revert:*),Bash(git branch -D:*),Bash(git branch -d:*),Bash(git -C:*)'
ALLOWED='Edit,Write'

# --- Guard: never start over the user's uncommitted work --------------------
if [ -n "$(git status --porcelain)" ]; then
  echo "ABORT: working tree is dirty — commit or stash first. Ralph never resets what it didn't create." >&2
  exit 1
fi

if [ ! -f "$PROMPT_FILE" ]; then
  echo "ABORT: $PROMPT_FILE not found." >&2
  exit 1
fi

ORIG_BRANCH="$(git branch --show-current)"

# --- Dedicated branch (suffix -2, -3... if today's already exists) ----------
BRANCH="afk/${DATE}"
n=2
while git show-ref --verify --quiet "refs/heads/${BRANCH}"; do
  BRANCH="afk/${DATE}-${n}"
  n=$((n + 1))
done
git checkout -b "$BRANCH" main

TIMEOUT_BIN="$(command -v gtimeout || command -v timeout || true)"

# macOS notification per iteration (same pattern as check:workspace). No-op elsewhere.
notify() {
  command -v osascript >/dev/null 2>&1 &&
    osascript -e "display notification \"$1\" with title \"Ralph AFK\"" >/dev/null 2>&1 || true
}

{
  echo "# AFK run ${DATE} — branch \`${BRANCH}\`"
  echo ""
} >>"$RUN_LOG"

CLEAN=0
PARKED=0

# Script-owned cleanup after a parked/failed iteration. `.ai-flow/` is gitignored,
# so reset/clean (no -x) cannot touch the run log or the [afk-parked] retag —
# only the iteration's own code leftovers are discarded.
discard_leftovers() {
  local status
  status="$(git status --porcelain)"
  if [ -n "$status" ]; then
    {
      echo "Discarded on park:"
      echo '```'
      echo "$status"
      echo '```'
    } >>"$RUN_LOG"
    git reset --hard >/dev/null
    git clean -fd >/dev/null
  fi
}

for i in $(seq 1 "$MAX_ITER"); do
  echo "## Iteration ${i} — $(date +%H:%M:%S)" >>"$RUN_LOG"

  set +e
  if [ -n "$TIMEOUT_BIN" ]; then
    OUTPUT="$("$TIMEOUT_BIN" "$ITER_TIMEOUT" claude -p "$(cat "$PROMPT_FILE")" \
      --allowedTools "$ALLOWED" --disallowedTools "$DISALLOWED" 2>>"$RUN_LOG")"
  else
    OUTPUT="$(claude -p "$(cat "$PROMPT_FILE")" \
      --allowedTools "$ALLOWED" --disallowedTools "$DISALLOWED" 2>>"$RUN_LOG")"
  fi
  set -e

  printf '%s\n' "$OUTPUT" >>"$RUN_LOG"

  TASK_ID="$(printf '%s' "$OUTPUT" | grep -oE 'T-[0-9]+' | head -1)"
  # Sentinel = the LAST non-empty line, exact match. Reports mention DONE/PARKED
  # in prose, so substring matching over the whole output misclassifies.
  SENTINEL="$(printf '%s\n' "$OUTPUT" | awk 'NF{last=$0} END{print last}' | tr -d '[:space:]')"

  case "$SENTINEL" in
    NO_AFK_TASKS)
      echo "Iteration ${i}: NO_AFK_TASKS — stopping." | tee -a "$RUN_LOG"
      notify "No [afk] tasks left — stopping (iteration ${i})."
      break
      ;;
    PARKED)
      PARKED=$((PARKED + 1))
      echo "Iteration ${i}: PARKED (${TASK_ID:-unknown})." | tee -a "$RUN_LOG"
      notify "${TASK_ID:-Task} PARKED (${i}/${MAX_ITER})."
      discard_leftovers
      ;;
    DONE)
      CLEAN=$((CLEAN + 1))
      echo "Iteration ${i}: DONE (${TASK_ID:-unknown})." | tee -a "$RUN_LOG"
      notify "${TASK_ID:-Task} DONE (${i}/${MAX_ITER}, clean ${CLEAN})."
      ;;
    *)
      # Died without a sentinel (crash, timeout) → treat as parked.
      PARKED=$((PARKED + 1))
      echo "Iteration ${i}: no sentinel on last line — treating as PARKED." | tee -a "$RUN_LOG"
      notify "Iteration ${i}: no sentinel — treated as PARKED."
      discard_leftovers
      ;;
  esac
done

git checkout "$ORIG_BRANCH"

{
  echo ""
  echo "## Run summary"
  echo "- Clean: ${CLEAN} · Parked: ${PARKED}"
  echo "- Branch: \`${BRANCH}\` ($(git log "$BRANCH" --oneline | grep -c '\[auto\]\[afk\]' || true) [auto][afk] commits)"
  echo "- Morning review: inspect the branch, merge to main only after review, then archive each task normally."
} >>"$RUN_LOG"

notify "Run finished — clean: ${CLEAN}, parked: ${PARKED}."
echo "AFK run finished — clean: ${CLEAN}, parked: ${PARKED}. Log: ${RUN_LOG}, branch: ${BRANCH}"

# --- Post-run auditor (T-980): read-only reviewer over the afk branch --------
# No --allowedTools at all: the reviewer prints markdown to stdout and this
# script writes the file — the auditor physically cannot modify what it reviews.
REVIEW_LOG=".ai-flow/afk-review-${DATE}.md"
REVIEW_PROMPT_FILE="$HOME/.claude/ai-flow/ralph/review-prompt.md"
if [ "$CLEAN" -ge 1 ] && [ -f "$REVIEW_PROMPT_FILE" ]; then
  REVIEW_PROMPT="$(sed -e "s|{{BRANCH}}|${BRANCH}|g" -e "s|{{BASE}}|main|g" "$REVIEW_PROMPT_FILE")"
  set +e
  if [ -n "$TIMEOUT_BIN" ]; then
    REVIEW_OUT="$("$TIMEOUT_BIN" "$ITER_TIMEOUT" claude -p "$REVIEW_PROMPT" \
      --disallowedTools "$DISALLOWED" 2>>"$RUN_LOG")"
  else
    REVIEW_OUT="$(claude -p "$REVIEW_PROMPT" --disallowedTools "$DISALLOWED" 2>>"$RUN_LOG")"
  fi
  REVIEW_RC=$?
  set -e
  if [ "$REVIEW_RC" -eq 0 ] && [ -n "$REVIEW_OUT" ]; then
    {
      echo ""
      echo "# AFK review ${DATE} — branch \`${BRANCH}\` (base main)"
      echo ""
      printf '%s\n' "$REVIEW_OUT"
    } >>"$REVIEW_LOG"
    echo "Review report: ${REVIEW_LOG}" | tee -a "$RUN_LOG"
    notify "Review report ready."
  else
    echo "Review auditor failed (rc=${REVIEW_RC}) — review the branch manually." | tee -a "$RUN_LOG"
    notify "Review report FAILED — review manually."
  fi
fi
