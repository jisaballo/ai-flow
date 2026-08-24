#!/bin/bash
# Engine drift guard. The installed ai-flow engine (~/.claude) must match its
# versioned source (the local clone). Quiet while the clone has uncommitted
# engine changes (work in progress). Blocks session close (exit 2) when an
# installed engine file differs from the clone's committed HEAD — either land
# the clone change and reinstall, or port a direct ~/.claude edit back into
# the clone. Engine edits belong in the clone, never in ~/.claude.
# No-op when no clone is known (remote installs) or git is unavailable.
set -u

# A refused stop is re-delivered to the same request, and a guard that reports on every delivery turns
# one refusal into a loop rather than a louder warning: nine consecutive re-deliveries were observed
# with no work of any kind between them. The payload says which delivery this is. Read it before every
# early exit below, so no quiet path can skip the check and leave the loop in place.
#
# Accumulated line by line rather than read to a delimiter that never arrives. The /bin/bash these
# hooks run under on macOS is 3.2, where a read that times out discards what it had already received:
# a caller that writes the payload and then holds the pipe open would leave the variable empty, every
# delivery would look fresh, and the loop this exists to stop would come back with nothing to show it.
# The bound stays -- each read is capped, so the guard never waits without end, which matters because
# a Stop hook that waits for input it never receives is a hung session, strictly worse than the noise
# being removed. The `|| [ -n "$stop_line" ]` arm is what keeps a payload with no trailing newline,
# which is the ordinary shape: at EOF the read reports failure and still assigns what it took.
STOP_PAYLOAD=""
stop_line=""
if [ ! -t 0 ]; then
  while IFS= read -r -t 2 stop_line || [ -n "$stop_line" ]; do
    STOP_PAYLOAD="$STOP_PAYLOAD$stop_line"
    stop_line=""
  done
fi

# Parsed, never matched as text, and for the reason this repository already carries as a rule: a guard
# reading the characters of a mechanism cannot tell the field from the same characters appearing inside
# something else, and a truncated or non-JSON payload carrying them would be read as an instruction to
# go quiet -- a false all-clear over an engine that really is undistributed, which is the one direction
# this guard must never fail in. Malformed is therefore absent, and absent reports, exactly as the
# sibling Stop hook resolves the same field. Where python3 is missing no suppression happens at all and
# the guard behaves as it did before this existed: the noisy direction, which is the safe one.
if [ -n "$STOP_PAYLOAD" ] && command -v python3 >/dev/null 2>&1; then
  printf '%s' "$STOP_PAYLOAD" | python3 -c 'import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    d = {}
sys.exit(0 if isinstance(d, dict) and d.get("stop_hook_active") is True else 1)' && exit 0
fi

SRC_FILE="$HOME/.claude/ai-flow/source.path"
[ -f "$SRC_FILE" ] || exit 0
CLONE="$(cat "$SRC_FILE")"
[ -d "$CLONE/global" ] || exit 0
command -v git >/dev/null 2>&1 || exit 0
git -C "$CLONE" rev-parse HEAD >/dev/null 2>&1 || exit 0

# Engine work can happen in a linked worktree of the clone, so that checkout vouches for the
# installed engine too: judging only by the primary's HEAD would read the worktree's own commits
# as drift and the fix printed below would revert them. A second, stale worktree must not create
# the opposite false alarm either — hence "matches ANY engine checkout", not "matches the last one".
abs_git_common() { ( cd "$1" 2>/dev/null && d="$(git rev-parse --git-common-dir 2>/dev/null)" && cd "$d" 2>/dev/null && pwd -P ); }
SRC2=""
here_repo="$(abs_git_common "$PWD")"
if [ -n "$here_repo" ] && [ "$here_repo" = "$(abs_git_common "$CLONE")" ]; then
  here_top="$(git rev-parse --show-toplevel 2>/dev/null || true)"
  if [ -n "$here_top" ] && [ -d "$here_top/global" ] && [ "$here_top" != "$CLONE" ]; then
    SRC2="$here_top"
  fi
fi

# Work in progress in any engine checkout -> stay quiet
git -C "$CLONE" diff --quiet HEAD -- global 2>/dev/null || exit 0
if [ -n "$SRC2" ]; then
  git -C "$SRC2" diff --quiet HEAD -- global 2>/dev/null || exit 0
fi

# An installed file is drifted only when it matches no engine checkout's HEAD
matches_a_source() {  # $1 = path in the repo, $2 = installed file
  git -C "$CLONE" show "HEAD:$1" 2>/dev/null | diff -q - "$2" >/dev/null 2>&1 && return 0
  if [ -n "$SRC2" ]; then
    git -C "$SRC2" show "HEAD:$1" 2>/dev/null | diff -q - "$2" >/dev/null 2>&1 && return 0
  fi
  return 1
}

# Map each engine file in the clone's HEAD to its installed location
installed_path() {
  case "$1" in
    global/CLAUDE.md) echo "" ;;                                  # user-owned, never compared
    global/hooks/settings.hooks.json|global/hooks/README.md) echo "" ;;
    global/protocols/*) echo "$HOME/.claude/ai-flow/protocols/${1#global/protocols/}" ;;
    global/skills/*)    echo "$HOME/.claude/skills/${1#global/skills/}" ;;
    global/workflows/*) echo "$HOME/.claude/workflows/${1#global/workflows/}" ;;
    global/hooks/*)     echo "$HOME/.claude/hooks/${1#global/hooks/}" ;;
    global/ralph/*)     echo "$HOME/.claude/ai-flow/ralph/${1#global/ralph/}" ;;
    global/scripts/*)   echo "$HOME/.claude/ai-flow/scripts/${1#global/scripts/}" ;;
    *) echo "" ;;
  esac
}

DRIFT=""
while IFS= read -r rel; do
  dest="$(installed_path "$rel")"
  [ -n "$dest" ] || continue
  if [ ! -f "$dest" ]; then
    DRIFT="${DRIFT}  missing: ${dest}"$'\n'
    continue
  fi
  if ! matches_a_source "$rel" "$dest"; then
    DRIFT="${DRIFT}  differs: ${dest}  (vs ${rel} @ HEAD)"$'\n'
  fi
done < <(git -C "$CLONE" ls-tree -r --name-only HEAD -- global/)

[ -z "$DRIFT" ] && exit 0
{
  echo "ai-flow engine drift — the installed engine differs from the clone's committed HEAD:"
  printf "%s" "$DRIFT"
  echo "Fix: reinstall from the engine checkout whose commits you want installed:"
  echo "  bash '$CLONE/install.sh' update"
  if [ -n "$SRC2" ]; then
    # Not a second option, and it is not offered as one. install.sh writes the checkout it runs from
    # into source.path, so installing from a linked checkout repoints this guard at that checkout --
    # and the close dismantles it, after which the guard finds no clone, exits 0 and says nothing,
    # permanently. What is lost is the check itself, which is a different order of cost from which
    # commits end up installed, and the line that named only the latter read as an equal choice.
    echo "Installing from the checkout this session is in is a different act, not a second option:"
    echo "install.sh writes the checkout it runs from into source.path, this guard's own source, so"
    echo "it would then watch this checkout -- and once the close dismantles it, the guard goes silent"
    echo "for good, with no diagnostic. It also reverts the recorded clone's engine commits. Use it"
    echo "only to try this checkout's engine, and reinstall from the clone above before it closes:"
    echo "  bash '$SRC2/install.sh' update"
  fi
  echo "If ~/.claude was edited directly, port that edit into a checkout (commit it), then run update."
} >&2
exit 2
