#!/bin/bash
set -e

# ai-flow installer
# Usage: ./install.sh [target-directory]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-.}"
TARGET="$(cd "$TARGET" && pwd)"

echo "Installing ai-flow into: $TARGET"
echo ""

# Check if .ai-flow already exists
if [ -d "$TARGET/.ai-flow" ]; then
  echo "Warning: $TARGET/.ai-flow already exists."
  read -p "Overwrite protocols only (keeps your data)? [y/N] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
  fi
  UPGRADE=true
else
  UPGRADE=false
fi

# Create directory structure
mkdir -p "$TARGET/.ai-flow"/{protocols,steering,artifacts,archive,codebase}

# Copy protocols (always — these are the framework core)
cp "$SCRIPT_DIR/template/.ai-flow/protocols/"*.md "$TARGET/.ai-flow/protocols/"
echo "  [ok] Protocols installed (7 files)"

# Copy data files only on fresh install
if [ "$UPGRADE" = false ]; then
  cp "$SCRIPT_DIR/template/.ai-flow/BACKLOG.md" "$TARGET/.ai-flow/BACKLOG.md"
  cp "$SCRIPT_DIR/template/.ai-flow/STATE.md" "$TARGET/.ai-flow/STATE.md"
  cp "$SCRIPT_DIR/template/.ai-flow/decisions-global.md" "$TARGET/.ai-flow/decisions-global.md"
  cp "$SCRIPT_DIR/template/.ai-flow/product.md" "$TARGET/.ai-flow/product.md"
  echo "  [ok] Data files created (BACKLOG, STATE, decisions, product)"
fi

# CLAUDE.md — only if it doesn't exist
if [ ! -f "$TARGET/CLAUDE.md" ]; then
  cp "$SCRIPT_DIR/template/CLAUDE.md" "$TARGET/CLAUDE.md"
  echo "  [ok] CLAUDE.md created — customize it for your stack"
else
  echo "  [skip] CLAUDE.md already exists"
fi

# Global CLAUDE.md hint
GLOBAL_CLAUDE="$HOME/.claude/CLAUDE.md"
if [ ! -f "$GLOBAL_CLAUDE" ]; then
  echo ""
  echo "  [!] No global CLAUDE.md found at $GLOBAL_CLAUDE"
  echo "      Copy global/CLAUDE.md there to enable ai-flow commands:"
  echo "      mkdir -p ~/.claude && cp $SCRIPT_DIR/global/CLAUDE.md ~/.claude/CLAUDE.md"
else
  echo "  [info] Global CLAUDE.md exists at $GLOBAL_CLAUDE"
  echo "         Merge ai-flow rules from global/CLAUDE.md if needed"
fi

echo ""
echo "Done! Next steps:"
echo "  1. Edit $TARGET/CLAUDE.md — fill in your stack, apps, and commands"
echo "  2. Edit $TARGET/.ai-flow/product.md — describe your product and users"
echo "  3. Copy global/CLAUDE.md to ~/.claude/CLAUDE.md (or merge)"
echo "  4. Optionally create steering files in .ai-flow/steering/"
echo ""
echo "Start working: open Claude Code and say 'add to backlog: [your task]'"
