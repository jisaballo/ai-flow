#!/bin/bash
# Seed a linked worktree with the project data ai-flow needs, then prune the papers it does not own.
# This is the seed-and-prune move of the opening ceremony, as a mechanism: it knows nothing about any
# project, and everything it copies is named by the project's own pattern file.
#
# A front-end that creates the checkout without the project's data leaves it unusable — the data
# directory is ignored by version control, so git carries none of it. Run this against such a checkout
# and it arrives holding what the project declares travels, and only the papers of the task it owns.
#
# Usage: seed-front.sh <front-checkout> <T-XXX>
set -euo pipefail

say()  { echo "seed-front: $1"; }
die()  { echo "seed-front: $1" >&2; exit 1; }

DEST_IN="${1:-}"
TASK="${2:-}"
[ -n "$DEST_IN" ] && [ -n "$TASK" ] || die "usage: $(basename "$0") <front-checkout> <T-XXX>"
[ -d "$DEST_IN" ] || die "not a directory: $DEST_IN"
DEST="$(cd "$DEST_IN" && pwd -P)"

# The primary is the first entry of the repository's own worktree listing — the anchor the guardrail
# hooks and the closing ceremony already resolve. Never the checkout this script runs from: run inside
# the front, that is the checkout with no data in it, and the copy would come from an empty hand.
git -C "$DEST" rev-parse --git-dir >/dev/null 2>&1 \
  || die "not a checkout of any repository: $DEST"
PRIMARY="$(git -C "$DEST" worktree list --porcelain | awk '/^worktree /{print substr($0,10); exit}')"
[ -n "$PRIMARY" ] && [ -d "$PRIMARY" ] || die "cannot resolve the primary checkout from $DEST"
PRIMARY="$(cd "$PRIMARY" && pwd -P)"

# The destination must be a checkout of that same repository, and not the primary itself. A path that
# merely sits inside one is not a checkout: seeding it would scatter the project's data into some
# subdirectory and report success.
[ "$DEST" != "$PRIMARY" ] || die "that is the primary checkout, which already holds the project's data: $DEST"
git -C "$PRIMARY" worktree list --porcelain \
  | awk '/^worktree /{print substr($0,10)}' \
  | while read -r w; do [ "$(cd "$w" 2>/dev/null && pwd -P)" = "$DEST" ] && echo hit; done \
  | grep -q hit \
  || die "not a registered worktree of $PRIMARY: $DEST"

PATTERNS="$PRIMARY/.worktreeinclude"
# git reads an unreadable or empty pattern file as an empty set of patterns and answers "not selected"
# for every path — so a mechanism that concludes from one seeds nothing and reports success. Existence
# is not readability, and neither is content.
{ [ -r "$PATTERNS" ] && [ -s "$PATTERNS" ]; } \
  || die "no usable pattern file at $PATTERNS — nothing declares what travels, so nothing was copied"

# The pattern file is evaluated in a repository of its own. Ignore rules are ADDITIVE: asked inside the
# checkout the file describes, git answers for the project's own .gitignore too, and every path under an
# already-ignored directory comes back selected — the ledger included. Isolation is what makes the
# answer the pattern file's own.
EV="$(mktemp -d 2>/dev/null)" || die "no writable temporary directory for the pattern evaluator"
trap 'rm -rf "$EV"' EXIT
git init -q "$EV"

selected() {  # $1 = path relative to the primary -> 0 selected, 1 not, dies on an unanswerable probe
  local rc=0
  ( cd "$EV" && git -c core.excludesFile="$PATTERNS" check-ignore -q --no-index -- "$1" ) || rc=$?
  case "$rc" in
    0|1) return "$rc" ;;
    *)   die "the pattern file could not be evaluated for $1 (git exited $rc)" ;;
  esac
}

# Papers the front already holds are its own work — a front taking on its next task runs this move over
# a checkout it has been working, and the coordinator's copy of those papers is a snapshot from when the
# front opened. What exists here is never overwritten, and never pruned below.
PRE=""
if [ -d "$DEST/.ai-flow/artifacts" ]; then
  PRE="$( (cd "$DEST/.ai-flow/artifacts" && find . -mindepth 1 -maxdepth 1 -type d -exec basename {} \; ) | tr '\n' ' ')"
fi

# Candidates are the primary's untracked-and-ignored paths, which is the eligibility rule the product
# states: anything tracked already travels with the checkout. git enumerates them as FILES, so no
# pattern naming a directory can collapse it into its parent.
copied=0
while IFS= read -r -d '' rel; do
  selected "$rel" || continue
  [ -f "$PRIMARY/$rel" ] || continue
  [ -e "$DEST/$rel" ] && continue
  mkdir -p "$DEST/$(dirname "$rel")"
  cp "$PRIMARY/$rel" "$DEST/$rel"
  copied=$((copied+1))
done < <(git -C "$PRIMARY" ls-files -z --others --ignored --exclude-standard)

# The copy above carried the papers of every open task, because the pattern file names the whole
# artifacts directory. The front owns one: everything this run brought in for another task goes.
mkdir -p "$DEST/.ai-flow/artifacts"
pruned=0
while IFS= read -r dir; do
  name="$(basename "$dir")"
  [ "$name" = "$TASK" ] && continue
  case " $PRE " in *" $name "*) continue ;; esac
  rm -rf "$dir"
  pruned=$((pruned+1))
done < <(find "$DEST/.ai-flow/artifacts" -mindepth 1 -maxdepth 1 -type d)
mkdir -p "$DEST/.ai-flow/artifacts/$TASK"

say "seeded $DEST for $TASK — $copied file(s) copied, $pruned foreign task folder(s) pruned"
[ -n "$PRE" ] && say "kept the papers already here: $PRE"
exit 0
