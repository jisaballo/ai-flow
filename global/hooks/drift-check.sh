#!/bin/bash
# Engine drift guard. The installed ai-flow engine (~/.claude) must match its
# versioned source (the local clone). Quiet while the clone has uncommitted
# engine changes (work in progress). Blocks session close (exit 2) when an
# installed engine file differs from the clone's committed HEAD — either land
# the clone change and reinstall, or port a direct ~/.claude edit back into
# the clone. Engine edits belong in the clone, never in ~/.claude.
# No-op when no clone is known (remote installs) or git is unavailable.
set -u

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
    echo "  bash '$SRC2/install.sh' update   # the checkout this session is in"
    echo "Pick deliberately: installing from the other one reverts this checkout's engine commits."
  fi
  echo "If ~/.claude was edited directly, port that edit into a checkout (commit it), then run update."
} >&2
exit 2
