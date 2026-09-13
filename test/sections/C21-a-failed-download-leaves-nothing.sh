echo "== C21: a failed download leaves nothing behind =="
# fetch_file detects a bad transfer already (curl -f, and exit 18 on a truncated one) — what it lacks is
# a consequence at the destination: the bytes are written straight to the final path, so the detection
# arrives after the damage. Where a never-overwrite rule then preserves what it finds (the global
# manual, and every project data file), a partial write becomes permanent.
if ! command -v curl >/dev/null 2>&1; then
  echo "  [skip] C21 needs curl to exercise the download path"
else
TH21="$(mkbox)" || fatal 'C21 fixtures'; TH21B="$(mkbox)" || fatal 'C21 fixtures'; TH21C="$(mkbox)" || fatal 'C21 fixtures'
TH21D="$(mkbox)" || fatal 'C21 fixtures'; TH21E="$(mkbox)" || fatal 'C21 fixtures'; TW21="$(mkbox)" || fatal 'C21 fixtures'
# The trap carries the sandboxes still live from earlier blocks: replacing it instead of extending it
# leaked two sandboxes per run once already, so it is extended here and handed back below, not cleared.
trap 'rm -rf "$TH21" "$TH21B" "$TH21C" "$TH21D" "$TH21E" "$TW21" "$T12" "$T13"' EXIT
PROTO21="ai-flow/protocols/understand.md"

# Run A — a source that cannot be read, and a destination that does not exist yet.
if OUT21A="$( AI_FLOW_MODE=remote AI_FLOW_REPO_URL="file://$TW21/absent" \
              HOME="$TH21" bash "$ROOT/install.sh" update </dev/null 2>&1 )"; then
  ST21A=0
else
  ST21A=$?
fi
if [ ! -e "$TH21/.claude/$PROTO21" ]; then
  ok "a failed download creates no destination file"
else
  bad "a failed download creates no destination file"
fi
# It must also say which file it was. A run that aborts mutely leaves the operator to guess, which is
# the same silence the reworded verdicts above exist to remove.
if printf '%s' "$OUT21A" | grep -qF 'global/protocols/understand.md' \
   && printf '%s' "$OUT21A" | grep -qiE 'download failed|could not fetch'; then
  ok "a failed download names the file it could not fetch"
else
  bad "a failed download names the file it could not fetch"
fi

# The failure must also STOP the run, and this was measured: turning each failure branch's non-zero
# return into a zero one left the suite at 243/0, while the installer went on to announce eight
# protocols installed over an empty directory. Reporting a failure and then narrating success is a
# worse lie than the silence this block already forbids, and nothing held it but a shell option.
if [ "$ST21A" -ne 0 ]; then
  ok "a failed download stops the run"
else
  bad "a failed download stops the run (exited 0)"
fi
if ! printf '%s' "$OUT21A" | grep -qE 'Engine protocols installed|Update complete'; then
  ok "a failed download is never followed by a success report"
else
  bad "a failed download is never followed by a success report"
fi

# Run B — the same failure over a destination that already holds a good file. This is the never-overwrite
# path: what survives here is what the operator keeps forever.
mkdir -p "$TH21B/.claude/ai-flow/protocols"
printf 'sentinel-kept-intact\n' > "$TH21B/.claude/$PROTO21"
( AI_FLOW_MODE=remote AI_FLOW_REPO_URL="file://$TW21/absent" \
  HOME="$TH21B" bash "$ROOT/install.sh" update </dev/null >/dev/null 2>&1 ) || true
if [ "$(cat "$TH21B/.claude/$PROTO21" 2>/dev/null || true)" = "sentinel-kept-intact" ]; then
  ok "a failed download leaves an existing file byte-identical"
else
  bad "a failed download leaves an existing file byte-identical"
fi

# Run C — a readable source, to prove the base given is the base used and not the clone beside it. The
# run is expected to abort once it reaches a file this stub source does not carry; the protocol it did
# fetch is what the assertion reads.
mkdir -p "$TW21/stub/global/protocols"
printf 'sentinel-from-the-given-base\n' > "$TW21/stub/global/protocols/understand.md"
( AI_FLOW_MODE=remote AI_FLOW_REPO_URL="file://$TW21/stub" \
  HOME="$TH21C" bash "$ROOT/install.sh" update </dev/null >/dev/null 2>&1 ) || true
if grep -qF 'sentinel-from-the-given-base' "$TH21C/.claude/$PROTO21" 2>/dev/null; then
  ok "the installer fetches from the base it is given, not the clone beside it"
else
  bad "the installer fetches from the base it is given, not the clone beside it"
fi

# Run E — the case that actually guards the mechanism, and it was added because its absence was measured:
# with only the runs above, writing the download straight to its final path killed no assertion at all.
# Those reds came from the seam being missing, not from the temp-and-move. A source that EXISTS and is
# empty is the discriminating case: the transfer succeeds, so a direct write lands nothing over a good
# file, and a missing non-empty check moves nothing over it. Both are observable here and nowhere above.
mkdir -p "$TW21/hollow/global/protocols"
: > "$TW21/hollow/global/protocols/understand.md"
mkdir -p "$TH21E/.claude/ai-flow/protocols"
printf 'sentinel-survives-an-empty-transfer\n' > "$TH21E/.claude/$PROTO21"
OUT21E="$( AI_FLOW_MODE=remote AI_FLOW_REPO_URL="file://$TW21/hollow" \
           HOME="$TH21E" bash "$ROOT/install.sh" update </dev/null 2>&1 )" || true
if [ "$(cat "$TH21E/.claude/$PROTO21" 2>/dev/null || true)" = "sentinel-survives-an-empty-transfer" ]; then
  ok "a transfer that succeeds but delivers nothing never reaches the destination"
else
  bad "a transfer that succeeds but delivers nothing never reaches the destination"
fi
# And it must be reported. Without this, dropping the non-empty check turns the run into a silent success
# that installs an empty engine file — a failure mode with no symptom until a phase reads the blank.
if printf '%s' "$OUT21E" | grep -qiE 'download failed|could not fetch'; then
  ok "a transfer that delivers nothing is reported, not passed over in silence"
else
  bad "a transfer that delivers nothing is reported, not passed over in silence"
fi

# The abandoned temporary file must not be left beside the destination either: litter in the engine
# directory outlives the run that made it, and the next reader cannot tell it from an installed file.
# Every sandbox whose run reaches a branch that creates a temporary file, not just the first: the
# curl-failure branch and the empty-result branch each remove their own file, and one glob over one
# sandbox only ever exercised the first of them.
LITTER20=""
for h in "$TH21" "$TH21B" "$TH21E"; do
  ls "$h/.claude/ai-flow/protocols/".aiflow-fetch.* >/dev/null 2>&1 && LITTER20="$LITTER20 $h"
done
if [ -z "$LITTER20" ]; then
  ok "no failure branch leaves a temporary file beside the destination"
else
  bad "no failure branch leaves a temporary file beside the destination (left in:$LITTER20)"
fi

# The default download base, which run D below cannot observe: with nothing set the installer resolves
# MODE to local and never reads the base at all, so that run proves the mode default and only the mode.
# A typo or a bad merge in the substitution would ship an installer fetching from the wrong host with the
# suite still green. Checked against the base the docs publish, so the two cannot drift apart, and with
# no network involved.
DEFBASE20="$(sed -n 's/^REPO_URL="\${AI_FLOW_REPO_URL:-\(.*\)}"$/\1/p' "$ROOT/install.sh")"
if [ -n "$DEFBASE20" ] && grep -qF "$DEFBASE20" "$ROOT/README.md"; then
  ok "the default download base is the one the docs publish"
else
  bad "the default download base is the one the docs publish (resolved '$DEFBASE20')"
fi

# Run D — nothing set. The seam exists for the tests above; it must not have moved the default, so this
# run has to behave exactly as every other install in this suite does.
( cd "$ROOT" && env -u AI_FLOW_MODE -u AI_FLOW_REPO_URL HOME="$TH21D" \
  bash "$ROOT/install.sh" update </dev/null >/dev/null 2>&1 ) || true
if [ -s "$TH21D/.claude/$PROTO21" ] \
   && cmp -s "$TH21D/.claude/$PROTO21" "$ROOT/global/protocols/understand.md"; then
  ok "an unset environment leaves the installer's own resolution untouched"
else
  bad "an unset environment leaves the installer's own resolution untouched"
fi

rm -rf "$TH21" "$TH21B" "$TH21C" "$TH21D" "$TH21E" "$TW21"
trap 'rm -rf "$T12" "$T13"' EXIT   # handed back to the section that owned it
{ [ ! -d "$TH21" ] && [ ! -d "$TW21" ] && [ -d "$T12" ]; } \
  && ok "the sandbox is torn down and the live cleanup trap survives this block" \
  || bad "the sandbox is torn down and the live cleanup trap survives this block"
fi
