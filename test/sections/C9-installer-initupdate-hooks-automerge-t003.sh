echo "== C9: installer init/update + hooks auto-merge (T-003) =="
# --- structural ---
grep -qE '(init|update)\)' install.sh && ok "install.sh has init/update dispatch" || bad "no init/update dispatch"
grep -A3 '^PROTOCOLS=' install.sh | grep -q discover && ok "PROTOCOLS includes discover" || bad "PROTOCOLS missing discover"
grep -q "python3" install.sh && ok "install.sh uses python3 (hook merge)" || bad "no python3 hook merge"
# --- functional (sandboxed HOME + temp target; NEVER touches the real ~/.claude) ---
TH="$(mkbox)" || fatal 'C9 fixtures'; TT="$(mkbox)" || fatal 'C9 fixtures'; TW="$(mkbox)" || fatal 'C9 fixtures'
mkdir -p "$TT/.ai-flow/protocols"
echo "SENTINEL-KEEP-ME" > "$TT/.ai-flow/BACKLOG.md"
( cd "$TW" && HOME="$TH" bash "$ROOT/install.sh" update "$TT" </dev/null >/dev/null 2>&1 ) || true
grep -q "SENTINEL-KEEP-ME" "$TT/.ai-flow/BACKLOG.md" 2>/dev/null && ok "update preserves project data" || bad "update clobbered/missed project data"
test -f "$TH/.claude/ai-flow/protocols/discover.md" && ok "update delivers discover.md centrally" || bad "update did not deliver discover.md centrally"
# The map is the one protocol a reader is sent to rather than one a phase command reads, so its delivery
# is asserted on the run itself and not inferred from the declared set agreeing with the tree: those two
# can agree perfectly about a file the installer never writes.
test -f "$TH/.claude/ai-flow/protocols/lifecycle.md" && ok "update delivers the lifecycle map centrally" || bad "update did not deliver the lifecycle map centrally"
( cd "$TW" && HOME="$TH" bash "$ROOT/install.sh" update "$TT" </dev/null >/dev/null 2>&1 ) || true
SJ="$TH/.claude/settings.json"
if [ -f "$SJ" ] && command -v python3 >/dev/null 2>&1; then
  python3 -c "import json; json.load(open('$SJ'))" 2>/dev/null && ok "settings.json is valid JSON" || bad "settings.json invalid JSON"
  cnt="$(grep -c "git-safety.py" "$SJ" 2>/dev/null || echo 0)"
  [ "$cnt" = "1" ] && ok "hook merge idempotent (1 git-safety entry)" || bad "hook merge not idempotent ($cnt git-safety entries)"
  # Every command settings.hooks.json references must have actually been fetched: a file wired into a
  # matcher but missing from install.sh's own HOOKS= list ships uninstalled, and the first real Edit/Write
  # after install then runs `python3 <missing file>`, which exits 2 -- read by PreToolUse as a refusal.
  missing=""
  for hf in $(grep -oE '\$HOME/\.claude/hooks/[A-Za-z0-9_.-]+' "$SJ" | sed 's#.*/##' | sort -u); do
    [ -f "$TH/.claude/hooks/$hf" ] || missing="$missing $hf"
  done
  [ -z "$missing" ] && ok "every hook settings.json references was actually fetched" \
                     || bad "every hook settings.json references was actually fetched: missing$missing"
else
  bad "update did not create settings.json (expected hook auto-merge)"
fi
rm -rf "$TH" "$TT" "$TW"
