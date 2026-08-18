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

# Work in progress in the clone's engine dirs -> stay quiet
git -C "$CLONE" diff --quiet HEAD -- global 2>/dev/null || exit 0

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
  if ! git -C "$CLONE" show "HEAD:$rel" 2>/dev/null | diff -q - "$dest" >/dev/null 2>&1; then
    DRIFT="${DRIFT}  differs: ${dest}  (vs ${rel} @ HEAD)"$'\n'
  fi
done < <(git -C "$CLONE" ls-tree -r --name-only HEAD -- global/)

[ -z "$DRIFT" ] && exit 0
{
  echo "ai-flow engine drift — the installed engine differs from the clone's committed HEAD:"
  printf "%s" "$DRIFT"
  echo "Fix: if the clone is newer, run: bash '$CLONE/install.sh' update"
  echo "If ~/.claude was edited directly, port that edit into the clone (commit it), then run update."
} >&2
exit 2
