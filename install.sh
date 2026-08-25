#!/bin/bash
set -e

# ai-flow installer
# Usage:
#   Init (new or existing project; interactive):
#     curl -sL https://raw.githubusercontent.com/jisaballo/ai-flow/main/install.sh | bash
#     curl -sL .../install.sh | bash -s /path/to/project        # back-compat: bare path => init
#     curl -sL .../install.sh | bash -s init /path/to/project
#     ./install.sh [init] [target-directory]
#   Update (re-fetch the engine + global tooling into ~/.claude; unattended.
#   It writes no project file, and it makes one machine-wide change outside ~/.claude: git's
#   core.hooksPath, so the two git guards run. An existing value is reported and left alone):
#     curl -sL .../install.sh | bash -s update
#     ./install.sh update

# Test seam, deliberately undocumented: the download base and the mode below both resolve from the
# environment when set, so the download path — and above all its failure path — is reachable without a
# network. Installing from a fork is not a supported capability, so this stays out of the user docs; the
# conformance block that exercises a failed download is what keeps these two lines from reading unused.
REPO_URL="${AI_FLOW_REPO_URL:-https://raw.githubusercontent.com/jisaballo/ai-flow/main}"

# --- Parse subcommand + target (back-compat: if $1 is a path, treat as init target) ---
CMD="init"
case "${1:-}" in
  init|update) CMD="$1"; shift ;;
esac
TARGET="${1:-.}"

# A project target belongs to init alone. update writes into ~/.claude and never into a project, so
# resolving one here would create a directory nothing goes on to write and announce it as the
# destination — a line contradicted by the next one the subcommand prints.
if [ "$CMD" = "init" ]; then
  # Resolve absolute path (handle both existing and new directories)
  mkdir -p "$TARGET"
  TARGET="$(cd "$TARGET" && pwd)"
  TARGET_LINE="  Target: $TARGET"
else
  TARGET_LINE="  Target: $HOME/.claude, plus git's core.hooksPath (no project file is touched)"
fi

echo ""
echo "  ai-flow installer ($CMD)"
echo "  ─────────────────"
echo "$TARGET_LINE"
echo ""

# Detect mode: local (cloned repo) or remote (curl)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" 2>/dev/null || echo ".")" && pwd)"
if [ -n "${AI_FLOW_MODE:-}" ]; then
  MODE="$AI_FLOW_MODE"                                   # test seam (see REPO_URL above)
elif [ -f "$SCRIPT_DIR/global/protocols/understand.md" ]; then
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
    return 0
  fi
  # curl already DETECTS a bad transfer — a failing status with -f, a truncated body with exit 18. What
  # was missing was a consequence at the destination: writing straight there meant the detection arrived
  # after the damage, and the installers that never overwrite an existing file (the global manual, and
  # every project data file) then preserved the broken copy for good.
  #
  # The temporary file is created in the DESTINATION's own directory so the move below is a rename inside
  # one filesystem, which cannot be interrupted half-written. A system temporary file would cross
  # filesystems, where the move degrades to copy-then-unlink and a partial file can reach the destination
  # after all — losing exactly the guarantee this code exists to make.
  local tmp
  if ! tmp="$(mktemp "$(dirname "$dest")/.aiflow-fetch.XXXXXX" 2>/dev/null)"; then
    echo "  [FAIL] download failed: $rel_path (no writable temporary file beside $dest)" >&2
    return 1
  fi
  if ! curl -sfL "$REPO_URL/$rel_path" -o "$tmp"; then
    rm -f "$tmp"
    echo "  [FAIL] download failed: $rel_path" >&2
    return 1
  fi
  if [ ! -s "$tmp" ]; then
    rm -f "$tmp"
    echo "  [FAIL] download failed: $rel_path (empty result)" >&2
    return 1
  fi
  mv "$tmp" "$dest"
}

PROTOCOLS="understand plan execute verify quick-path backlog discover lifecycle"
SKILLS="understand plan verify discover"
HOOKS="check-state-size.sh diff-size-guard.py git-safety.py understand-write-guard.py drift-check.sh"
# Git's own hooks, which carry the two Never rules. They live under a subdirectory because that is
# what core.hooksPath is pointed at, and because the drift guard's prefix map already covers the
# path with no change to the guard.
GIT_HOOKS="pre-push pre-commit _chain"

# Pointing core.hooksPath at a directory REPLACES where git looks for every hook, so a repository's own
# commit-msg, post-checkout or post-merge would simply stop running. Every other name git knows gets a
# copy of _chain, which hands the hook straight back to the repository. The engine adds two guards and
# takes nothing away.
#
# fsmonitor-watchman is deliberately absent: it is opted into by configuration rather than by presence,
# and it sits on the hot path of every status. A repository that wants it under a hook path can add it.
GIT_CHAINED="applypatch-msg pre-applypatch post-applypatch pre-merge-commit prepare-commit-msg \
commit-msg post-commit pre-rebase post-checkout post-merge pre-auto-gc post-rewrite sendemail-validate \
post-index-change reference-transaction push-to-checkout proc-receive pre-receive update post-receive \
post-update"
RALPH="ralph.sh ralph-prompt.md review-prompt.md"
SCRIPTS="seed-front.sh"

# --- Reusable install units ---

# Engine: phase protocols, installed centrally — never into a project
install_engine() {
  mkdir -p "$HOME/.claude/ai-flow/protocols"
  if [ "$MODE" = "local" ]; then
    echo "$SCRIPT_DIR" > "$HOME/.claude/ai-flow/source.path"
  fi
  local count=0
  for proto in $PROTOCOLS; do
    fetch_file "global/protocols/$proto.md" "$HOME/.claude/ai-flow/protocols/$proto.md"
    count=$((count+1))
  done
  echo "  [ok] Engine protocols installed to ~/.claude/ai-flow/protocols ($count files)"
}

# Project data: fresh install only — the only thing that lives in the project
install_data() {
  mkdir -p "$TARGET/.ai-flow"/{steering,artifacts,archive}
  for f in BACKLOG STATE decisions-global product; do
    fetch_file "template/.ai-flow/$f.md" "$TARGET/.ai-flow/$f.md"
  done
  fetch_file "template/.ai-flow/project.yml" "$TARGET/.ai-flow/project.yml"
  echo "  [ok] Data files created (BACKLOG, STATE, decisions, product, project.yml)"
}

# Project CLAUDE.md — only if it doesn't exist (never clobbered)
install_project_claude() {
  if [ ! -f "$TARGET/CLAUDE.md" ]; then
    fetch_file "template/CLAUDE.md" "$TARGET/CLAUDE.md"
    echo "  [ok] CLAUDE.md created — customize it for your stack"
  else
    echo "  [skip] CLAUDE.md already exists"
  fi
}

# Worktree provisioning: what a linked worktree receives, and which commit it is cut from.
# Both files are created only when absent — an existing one is the project's own decision.
install_worktree_entry() {
  if [ ! -f "$TARGET/.worktreeinclude" ]; then
    fetch_file "template/.worktreeinclude" "$TARGET/.worktreeinclude"
    echo "  [ok] .worktreeinclude created — lists the project data a linked worktree should receive"
    echo "  [note] it only takes effect for paths your repo gitignores; see docs/customization.md"
  else
    echo "  [skip] .worktreeinclude already exists"
  fi

  if [ ! -f "$TARGET/.claude/settings.json" ]; then
    mkdir -p "$TARGET/.claude"
    fetch_file "template/.claude/settings.json" "$TARGET/.claude/settings.json"
    echo "  [ok] .claude/settings.json created — worktree.baseRef set to 'fresh'"
  else
    echo "  [skip] .claude/settings.json already exists"
    echo "  [action] add \"worktree\": { \"baseRef\": \"fresh\" } to $TARGET/.claude/settings.json by hand"
  fi

  # What this function provisions is the native worktree path, and that path puts the checkout inside
  # the project. Uncovered by the project's ignore rules it is untracked content in the primary, which
  # the audit then copies into its snapshot and requires byte-exact against a working copy another
  # session is writing. The line is the project's own to write, so this states it and does not.
  echo "  [note] add /.claude/worktrees/ to your .gitignore — the native worktree path creates checkouts"
  echo "         there, and an unignored one becomes untracked content the coordinator's audit reads"
}

# Idempotently merge ai-flow hooks into ~/.claude/settings.json (preserves other keys + user hooks)
merge_hooks() {
  local settings="$HOME/.claude/settings.json"
  local src
  src="$(mktemp)"
  fetch_file "global/hooks/settings.hooks.json" "$src"
  if ! command -v python3 >/dev/null 2>&1; then
    echo "  [action] python3 not found — merge $src into the 'hooks' key of $settings manually"
    return 0
  fi
  python3 - "$settings" "$src" <<'PY'
import json, os, sys
settings_path, src_path = sys.argv[1], sys.argv[2]
try:
    with open(settings_path) as f:
        settings = json.load(f)
except (FileNotFoundError, ValueError):
    settings = {}
with open(src_path) as f:
    incoming = json.load(f)
hooks = settings.setdefault("hooks", {})
for event, groups in incoming.items():
    existing = hooks.setdefault(event, [])
    seen = {h.get("command") for g in existing for h in g.get("hooks", [])}
    for g in groups:
        fresh = [h for h in g.get("hooks", []) if h.get("command") not in seen]
        if not fresh:
            continue
        matcher = g.get("matcher")
        target = next((eg for eg in existing if eg.get("matcher") == matcher), None)
        if target is None:
            ng = {"hooks": fresh}
            if matcher is not None:
                ng = {"matcher": matcher, "hooks": fresh}
            existing.append(ng)
        else:
            target.setdefault("hooks", []).extend(fresh)
        seen.update(h.get("command") for h in fresh)
os.makedirs(os.path.dirname(settings_path), exist_ok=True)
with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")
PY
  rm -f "$src"
  echo "  [ok] Hooks registered in $settings"
}

# Point git at the engine's hooks, for every repository on this machine.
#
# It reports rather than overwrites. Someone who already manages hooks globally has a setup of their own,
# and replacing it silently would take away a protection to install one — so an existing value is named
# and left exactly as it was. The engine's Bash rail is what then tells them, per repository, that these
# hooks are not running, and it names the same two commands this function would have run.
point_git_at_hooks() {
  local target="$HOME/.claude/hooks/git"
  if ! command -v git >/dev/null 2>&1; then
    echo "  [skip] git not found — the trunk and secret hooks are installed but nothing points at them"
    return 0
  fi
  local current
  current="$(git config --global --get core.hooksPath 2>/dev/null || true)"
  if [ -n "$current" ] && [ "$current" != "$target" ]; then
    echo "  [skip] a global hook path is already set ($current) — left untouched"
    echo "         to run the engine's hooks too, chain them from there, or set:"
    echo "           git config --global core.hooksPath $target"
    return 0
  fi
  git config --global core.hooksPath "$target"
  echo "  [ok] git points at $target (every repository on this machine)"
}

# Global tooling: phase skills, verify-review workflow, guardrail hooks + settings.json merge
install_tooling() {
  mkdir -p "$HOME/.claude"/skills "$HOME/.claude/workflows" "$HOME/.claude/hooks"
  for skill in $SKILLS; do
    mkdir -p "$HOME/.claude/skills/$skill"
    fetch_file "global/skills/$skill/SKILL.md" "$HOME/.claude/skills/$skill/SKILL.md"
  done
  echo "  [ok] Skills installed (/understand, /plan, /verify, /discover)"

  fetch_file "global/workflows/verify-review.js" "$HOME/.claude/workflows/verify-review.js"
  echo "  [ok] verify-review workflow installed"

  for hook in $HOOKS; do
    fetch_file "global/hooks/$hook" "$HOME/.claude/hooks/$hook"
  done
  chmod +x "$HOME/.claude/hooks/check-state-size.sh" 2>/dev/null || true
  echo "  [ok] Hooks installed to ~/.claude/hooks"

  # Git's own hooks. The executable bit is set explicitly and is not optional: the download path fetches
  # with curl, which does not carry it, and git skips a hook that lacks it with a hint and nothing else
  # — the quietest way this protection can fail.
  mkdir -p "$HOME/.claude/hooks/git"
  for hook in $GIT_HOOKS; do
    fetch_file "global/hooks/git/$hook" "$HOME/.claude/hooks/git/$hook"
    chmod +x "$HOME/.claude/hooks/git/$hook" 2>/dev/null || true
  done
  # A copy per name rather than a symlink: the download path cannot carry a link, and a copy is what
  # lets each one read its own name from the path git invoked it by.
  for hook in $GIT_CHAINED; do
    cp "$HOME/.claude/hooks/git/_chain" "$HOME/.claude/hooks/git/$hook" 2>/dev/null || true
    chmod +x "$HOME/.claude/hooks/git/$hook" 2>/dev/null || true
  done
  echo "  [ok] Git hooks installed to ~/.claude/hooks/git (2 guards + pass-through for every other hook)"
  point_git_at_hooks

  mkdir -p "$HOME/.claude/ai-flow/ralph"
  for f in $RALPH; do
    fetch_file "global/ralph/$f" "$HOME/.claude/ai-flow/ralph/$f"
  done
  chmod +x "$HOME/.claude/ai-flow/ralph/ralph.sh" 2>/dev/null || true
  echo "  [ok] Ralph AFK loop installed to ~/.claude/ai-flow/ralph"

  mkdir -p "$HOME/.claude/ai-flow/scripts"
  for f in $SCRIPTS; do
    fetch_file "global/scripts/$f" "$HOME/.claude/ai-flow/scripts/$f"
    chmod +x "$HOME/.claude/ai-flow/scripts/$f" 2>/dev/null || true
  done
  echo "  [ok] Ceremony scripts installed to ~/.claude/ai-flow/scripts"
  merge_hooks
}

# Global CLAUDE.md — install only if absent (never clobbered)
install_global_claude() {
  local global_claude="$HOME/.claude/CLAUDE.md"
  if [ ! -f "$global_claude" ]; then
    mkdir -p "$HOME/.claude"
    fetch_file "global/CLAUDE.md" "$global_claude"
    echo "  [ok] Global CLAUDE.md installed"
  else
    echo "  [info] Global CLAUDE.md exists — merge ai-flow rules manually if needed"
  fi
}

# --- Subcommands ---

cmd_init() {
  if [ -d "$TARGET/.ai-flow" ] && [ -f "$TARGET/.ai-flow/BACKLOG.md" ]; then
    echo "  [info] $TARGET/.ai-flow already exists — project data preserved (only the engine + tooling refresh)."
  else
    install_data
  fi
  install_engine
  install_project_claude
  install_worktree_entry

  read -p "  Install/refresh global CLAUDE.md? [Y/n] " -n 1 -r; echo
  [[ ! $REPLY =~ ^[Nn]$ ]] && install_global_claude || echo "  [skip] Global CLAUDE.md"

  read -p "  Install ai-flow global tooling (skills, verify workflow, hooks)? [Y/n] " -n 1 -r; echo
  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    install_tooling
  else
    echo "  [skip] Global tooling — install later with './install.sh update'"
  fi

  echo ""
  echo "  Done! Next steps:"
  echo "    1. Edit CLAUDE.md — fill in your stack, apps, and commands"
  echo "       (or run 'discover' in Claude Code to derive .ai-flow/project.yml)"
  echo "    2. Edit .ai-flow/product.md — describe your product and users"
  echo "    3. Optionally create steering files in .ai-flow/steering/"
  echo ""
  echo "  Start working: open Claude Code and say 'add to backlog: [your task]'"
  echo ""
}

cmd_update() {
  echo "  Updating the ai-flow engine + global tooling in ~/.claude (no project is touched)..."
  install_engine    # re-fetch protocols into ~/.claude/ai-flow
  install_tooling   # re-fetch skills/workflow/hooks/ralph + re-merge settings.json (unattended)
  echo ""
  echo "  [ok] Update complete. Projects hold only their own data — nothing there to touch."
  echo ""
}

case "$CMD" in
  init)   cmd_init ;;
  update) cmd_update ;;
esac
