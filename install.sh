#!/bin/bash
set -e

# ai-flow installer
# Usage:
#   Remote:  curl -sL https://raw.githubusercontent.com/jisaballo/ai-flow/main/install.sh | bash
#   Remote with target:  curl -sL https://raw.githubusercontent.com/jisaballo/ai-flow/main/install.sh | bash -s /path/to/project
#   Local:   ./install.sh [target-directory]

REPO_URL="https://raw.githubusercontent.com/jisaballo/ai-flow/main"
TARGET="${1:-.}"

# Resolve absolute path (handle both existing and new directories)
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

echo ""
echo "  ai-flow installer"
echo "  ─────────────────"
echo "  Target: $TARGET"
echo ""

# Detect mode: local (cloned repo) or remote (curl)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" 2>/dev/null || echo ".")" && pwd)"
if [ -f "$SCRIPT_DIR/template/.ai-flow/protocols/understand.md" ]; then
  MODE="local"
else
  MODE="remote"
fi

# Helper: fetch a file from local template or remote
fetch_file() {
  local rel_path="$1"
  local dest="$2"
  if [ "$MODE" = "local" ]; then
    cp "$SCRIPT_DIR/$rel_path" "$dest"
  else
    curl -sfL "$REPO_URL/$rel_path" -o "$dest"
  fi
}

# Check if .ai-flow already exists
UPGRADE=false
if [ -d "$TARGET/.ai-flow" ]; then
  echo "  Warning: $TARGET/.ai-flow already exists."
  read -p "  Overwrite protocols only (keeps your data)? [y/N] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "  Aborted."
    exit 1
  fi
  UPGRADE=true
fi

# Create directory structure
mkdir -p "$TARGET/.ai-flow"/{protocols,steering,artifacts,archive,codebase}

# Protocols (always — these are the framework core)
PROTOCOLS="understand plan execute verify quick-path backlog codebase-mapping"
for proto in $PROTOCOLS; do
  fetch_file "template/.ai-flow/protocols/$proto.md" "$TARGET/.ai-flow/protocols/$proto.md"
done
echo "  [ok] Protocols installed (7 files)"

# Data files only on fresh install
if [ "$UPGRADE" = false ]; then
  for f in BACKLOG STATE decisions-global product; do
    fetch_file "template/.ai-flow/$f.md" "$TARGET/.ai-flow/$f.md"
  done
  fetch_file "template/.ai-flow/project.yml" "$TARGET/.ai-flow/project.yml"
  echo "  [ok] Data files created (BACKLOG, STATE, decisions, product, project.yml)"
fi

# CLAUDE.md — only if it doesn't exist
if [ ! -f "$TARGET/CLAUDE.md" ]; then
  fetch_file "template/CLAUDE.md" "$TARGET/CLAUDE.md"
  echo "  [ok] CLAUDE.md created — customize it for your stack"
else
  echo "  [skip] CLAUDE.md already exists"
fi

# Global CLAUDE.md
GLOBAL_CLAUDE="$HOME/.claude/CLAUDE.md"
if [ ! -f "$GLOBAL_CLAUDE" ]; then
  read -p "  Install global CLAUDE.md to ~/.claude/CLAUDE.md? [Y/n] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    mkdir -p "$HOME/.claude"
    fetch_file "global/CLAUDE.md" "$GLOBAL_CLAUDE"
    echo "  [ok] Global CLAUDE.md installed"
  else
    echo "  [skip] Global CLAUDE.md — install manually later"
  fi
else
  echo "  [info] Global CLAUDE.md exists — merge ai-flow rules manually if needed"
fi

# Global tooling: phase skills, verify-review workflow, guardrail hooks
read -p "  Install ai-flow global tooling (phase skills, verify workflow, hooks) to ~/.claude? [Y/n] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
  mkdir -p "$HOME/.claude"/skills/{understand,plan,verify} "$HOME/.claude/workflows" "$HOME/.claude/hooks"

  for skill in understand plan verify; do
    fetch_file "global/skills/$skill/SKILL.md" "$HOME/.claude/skills/$skill/SKILL.md"
  done
  echo "  [ok] Phase skills installed (/understand, /plan, /verify)"

  fetch_file "global/workflows/verify-review.js" "$HOME/.claude/workflows/verify-review.js"
  echo "  [ok] verify-review workflow installed"

  for hook in check-state-size.sh diff-size-guard.py git-safety.py; do
    fetch_file "global/hooks/$hook" "$HOME/.claude/hooks/$hook"
  done
  chmod +x "$HOME/.claude/hooks/check-state-size.sh" 2>/dev/null || true
  echo "  [ok] Hooks installed to ~/.claude/hooks"
  echo "  [action] Register them: merge global/hooks/settings.hooks.json into the 'hooks' key of ~/.claude/settings.json"
else
  echo "  [skip] Global tooling — install manually from global/ later"
fi

echo ""
echo "  Done! Next steps:"
echo "    1. Edit CLAUDE.md — fill in your stack, apps, and commands"
echo "    2. Edit .ai-flow/product.md — describe your product and users"
echo "    3. Optionally create steering files in .ai-flow/steering/"
echo ""
echo "  Start working: open Claude Code and say 'add to backlog: [your task]'"
echo ""
