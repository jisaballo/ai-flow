echo "== C101: the engine is switched on only where a project asks for it =="
# Generated in the Conform phase from understand.md's Verifiable Criteria. Every row is functional --
# it runs the real installer against a sandboxed HOME and target -- because the claims are about what
# the installer DOES, not about which lines its source happens to contain today.

# A1/A2/A4a -- one sandboxed `init`, the accept path on its first prompt (before this task that prompt
# offers the old global manual; after it, the prompt offers the tooling install and the old prompt is
# gone). The second answer declines whichever prompt is second, so the run stays bounded either way.
TH101="$(mkbox)" || fatal 'C101 fixtures'
TT101="$(mkbox)" || fatal 'C101 fixtures'
TW101="$(mkbox)" || fatal 'C101 fixtures'
( cd "$TW101" && printf 'y\nn\n' | HOME="$TH101" bash "$ROOT/install.sh" init "$TT101" >/dev/null 2>&1 ) || true

if [ -e "$TH101/.claude/CLAUDE.md" ]; then
  bad "A1 the installer never writes \$HOME/.claude/CLAUDE.md, under init (it exists after an accepted init)"
else
  ok "A1 the installer never writes \$HOME/.claude/CLAUDE.md, under init"
fi

if [ -f "$TT101/CLAUDE.md" ] && grep -q '\.claude/ai-flow/AGENTS\.md' "$TT101/CLAUDE.md"; then
  ok "A2 a freshly written project CLAUDE.md already carries the plug line pointing at ~/.claude/ai-flow/AGENTS.md"
else
  bad "A2 a freshly written project CLAUDE.md does not point at ~/.claude/ai-flow/AGENTS.md"
fi

if [ -s "$TH101/.claude/ai-flow/AGENTS.md" ]; then
  ok "A4a the engine installs its own operating-instructions file to ~/.claude/ai-flow/AGENTS.md"
else
  bad "A4a ~/.claude/ai-flow/AGENTS.md was not created by init"
fi

# A1b -- `update` never writes the global CLAUDE.md either. No accept/decline needed: `update` has no
# prompt of its own that could reach that file on any version of this script, so this leg's own weight is
# in the functional run and not in the branch it takes.
TH101B="$(mkbox)" || fatal 'C101 fixtures'
TW101B="$(mkbox)" || fatal 'C101 fixtures'
( cd "$TW101B" && HOME="$TH101B" bash "$ROOT/install.sh" update </dev/null >/dev/null 2>&1 ) || true
if [ -e "$TH101B/.claude/CLAUDE.md" ]; then
  bad "A1b the installer never writes \$HOME/.claude/CLAUDE.md, under update (it exists after update)"
else
  ok "A1b the installer never writes \$HOME/.claude/CLAUDE.md, under update"
fi

# A3 -- WHEN init runs against a target that already has a CLAUDE.md, that file is left byte-identical.
# No existing row in this suite exercises `install_project_claude`'s only-if-absent guard functionally, so
# this is a real new oracle rather than a duplicate of one already reached.
TH103="$(mkbox)" || fatal 'C101 fixtures'
TT103="$(mkbox)" || fatal 'C101 fixtures'
TW103="$(mkbox)" || fatal 'C101 fixtures'
mkdir -p "$TT103"
printf 'SENTINEL-EXISTING-CLAUDE-T163\n' > "$TT103/CLAUDE.md"
cp "$TT103/CLAUDE.md" "$TT103/CLAUDE.md.before"
( cd "$TW103" && printf 'n\nn\n' | HOME="$TH103" bash "$ROOT/install.sh" init "$TT103" >/dev/null 2>&1 ) || true
if cmp -s "$TT103/CLAUDE.md" "$TT103/CLAUDE.md.before"; then
  ok "A3 an existing project CLAUDE.md is left byte-identical by init"
else
  bad "A3 init changed a project CLAUDE.md that already existed"
fi

# A4b -- the refresh half of A4a: AGENTS.md is not merely created once, it is overwritten on `update` too.
# A stale copy that `update` leaves untouched would satisfy A4a (present) while failing the actual
# criterion (refreshed on both init and update).
TH104="$(mkbox)" || fatal 'C101 fixtures'
TW104="$(mkbox)" || fatal 'C101 fixtures'
mkdir -p "$TH104/.claude/ai-flow"
printf 'STALE-SENTINEL-T163\n' > "$TH104/.claude/ai-flow/AGENTS.md"
( cd "$TW104" && HOME="$TH104" bash "$ROOT/install.sh" update </dev/null >/dev/null 2>&1 ) || true
if [ -f "$TH104/.claude/ai-flow/AGENTS.md" ] && ! grep -q 'STALE-SENTINEL-T163' "$TH104/.claude/ai-flow/AGENTS.md"; then
  ok "A4b the engine's operating-instructions file is refreshed on update, not left stale"
else
  bad "A4b update left ~/.claude/ai-flow/AGENTS.md stale or missing"
fi

# A5 -- the heading alone (guarded by C47) says nothing about its body: the body must stop inviting an
# in-place edit of a file the installer now overwrites every update, and route a cross-project
# preference to the operator's own global file and a project-specific one to that project's own file.
# Read from the INSTALLED copy the A1/A2/A4a sandbox above already produced, never from the repo's own
# source -- a new site reading this engine's own documents as text has no independent oracle and is
# refused outright (C98).
PP101="$(awk '/^## Engine Defaults$/{f=1;next} /^## /{f=0} f' "$TH101/.claude/ai-flow/AGENTS.md")"
if printf '%s' "$PP101" | grep -qi 'Customize this section for your workflow'; then
  bad "A5 the installed engine instructions still invite an in-place edit of the shipped file"
elif ! printf '%s' "$PP101" | grep -qi '~/\.claude/CLAUDE\.md'; then
  bad "A5 the installed engine instructions do not route a cross-project preference to the operator's own global file"
elif ! printf '%s' "$PP101" | grep -qi "project'"'s own'; then
  bad "A5 the installed engine instructions do not route a project-specific preference to that project's own file"
else
  ok "A5 the installed engine instructions route each preference to its own home, and invite no in-place edit"
fi
