echo "== C26: the claim line's form is written where it is read and pinned where it is checked =="
# A sandbox of this block's own. It used to read the one C11 opens, which is why this section could
# not be asked for on its own: under a filter C11 never runs and every path below collapses to "/".
BOX26="$(mkbox)" || fatal 'C26 fixtures'
# The sibling of the phase declaration, and the same defect one field over: the reader was already
# correct and nothing stopped it being reverted with the suite green. These two fixtures discriminate
# by construction — each names a different file, and returns a different exit code, under the reading
# it forbids than under the reading the rule states.
if [ "$PY3" = 1 ]; then
  # A later mention is not the declaration. The claiming sheet names another branch and its prose
  # quotes this one; a whole-file reader resolves that sheet (phase EXECUTE, no block), a
  # first-line reader falls to the lone unclaimed sheet (phase UNDERSTAND, blocked and named).
  F26A="$BOX26/f26a"; mkproj "$F26A" main
  mkdir -p "$F26A/.ai-flow/artifacts/elsewhere" "$F26A/.ai-flow/artifacts/lone"
  # The later mention must itself begin with the label, or no reader would match it and the fixture
  # discriminates nothing: a mention inside a sentence is invisible to a whole-file reader too. A
  # fenced block showing the form is the shape a real sheet grows — the phase fixtures above use it.
  { printf '# Task state\n\nbranch: other\nphase: **EXECUTE**\n\n## Decisions\n\n'
    printf -- '- the claim released here is quoted below, and quoting is not claiming:\n\n'
    printf '```\nbranch: main\n```\n'
  } > "$F26A/.ai-flow/artifacts/elsewhere/state.md"
  printf '# Task state\n\nphase: **UNDERSTAND**\n' > "$F26A/.ai-flow/artifacts/lone/state.md"
  out="$(wguard "$F26A" "$F26A/app.txt")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *"artifacts/lone/state.md"*) ok "a later mention of the claim field is not the declaration" ;;
      *) bad "a later mention of the claim field is not the declaration (blocked, but named another file)" ;;
    esac
  else
    bad "a later mention of the claim field is not the declaration (exit $rc)"
  fi

  # An annotated value declares no claim. Beside a second unclaimed sheet the strict reading has no
  # lone one to fall back on, so it reaches the ledger; a first-token reading would claim the branch
  # and answer with a sheet whose phase raises no rail at all.
  F26B="$BOX26/f26b"; mkproj "$F26B" main
  mkdir -p "$F26B/.ai-flow/artifacts/annotated" "$F26B/.ai-flow/artifacts/second"
  printf 'Current phase: **UNDERSTAND**\n' > "$F26B/.ai-flow/STATE.md"
  printf '# Task state\n\nbranch: main (paused)\nphase: **EXECUTE**\n' > "$F26B/.ai-flow/artifacts/annotated/state.md"
  printf '# Task state\n\nphase: **EXECUTE**\n' > "$F26B/.ai-flow/artifacts/second/state.md"
  out="$(wguard "$F26B" "$F26B/app.txt")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *".ai-flow/STATE.md"*) ok "an annotated value declares no claim" ;;
      *) bad "an annotated value declares no claim (blocked, but named another file)" ;;
    esac
  else
    bad "an annotated value declares no claim (exit $rc)"
  fi
  # The colon is declared load-bearing by the prose, so it is load-bearing in the reader too. Same
  # shape as the fixture above: beside a second unclaimed sheet a colonless line leaves no lone sheet
  # to fall back on, so the ledger answers; a reader that treated the colon as optional would claim
  # the branch and answer with a sheet whose phase raises no rail.
  F26C="$BOX26/f26c"; mkproj "$F26C" main
  mkdir -p "$F26C/.ai-flow/artifacts/nocolon" "$F26C/.ai-flow/artifacts/other2"
  printf 'Current phase: **UNDERSTAND**\n' > "$F26C/.ai-flow/STATE.md"
  printf '# Task state\n\nbranch main\nphase: **EXECUTE**\n' > "$F26C/.ai-flow/artifacts/nocolon/state.md"
  printf '# Task state\n\nphase: **EXECUTE**\n' > "$F26C/.ai-flow/artifacts/other2/state.md"
  out="$(wguard "$F26C" "$F26C/app.txt")"; rc=$?
  if [ "$rc" = 2 ]; then
    case "$out" in
      *".ai-flow/STATE.md"*) ok "a claim written without its colon declares no claim" ;;
      *) bad "a claim written without its colon declares no claim (blocked, but named another file)" ;;
    esac
  else
    bad "a claim written without its colon declares no claim (exit $rc)"
  fi
else
  echo "  [skip] C26 needs python3 to run the rail"
fi

# --- the rule states it where a reader with no parser looks ---------------
# T-020's law: a rule stated as one reader's implementation detail is not stated. The claim block is
# where a person looks, fourteen lines below the paragraph that does this for the phase field.
# Normalised before anything is asserted about it: emphasis marks and a wrapped source line both cut
# the phrase a check looks for, and in both directions — a requirement that is met reports failure, a
# veto that finds nothing reports success. What is asserted here is content, never typography.
# Bounded to the paragraph itself, not to the whole section: an extractor spanning its neighbours
# lets a phrase from an adjacent paragraph satisfy a check about this one. And a phrase from EVERY
# sentence is pinned — pinning three keywords inside two sentences leaves the rest deletable with the
# suite green, which is a rule half-stated reported as stated.
CLAIM26="$(awk '/line is machine-read on the same terms/{f=1} f && /^$/{exit} f' \
  "$ROOT/global/protocols/backlog.md" | tr -d '*`' | tr -s ' \n' '  ')"
miss26=""
[ -n "$CLAIM26" ] || miss26="$miss26 paragraph-absent"
printf '%s' "$CLAIM26" | grep -qi 'machine-read'                     || miss26="$miss26 machine-read"
printf '%s' "$CLAIM26" | grep -qiE 'first line that declares'        || miss26="$miss26 first-line"
printf '%s' "$CLAIM26" | grep -qi 'colon'                            || miss26="$miss26 colon"
printf '%s' "$CLAIM26" | grep -qiE 'single token|one token'           || miss26="$miss26 single-token"
printf '%s' "$CLAIM26" | grep -qi 'branch: main (paused)'             || miss26="$miss26 annotated-example"
printf '%s' "$CLAIM26" | grep -qi 'no other line is read'             || miss26="$miss26 no-other-line"
printf '%s' "$CLAIM26" | grep -qiE 'any other form declares no branch' || miss26="$miss26 any-other-form"
[ -z "$miss26" ] \
  && ok "the claim block states what is load-bearing about the line" \
  || bad "the claim block states what is load-bearing about the line (missing:$miss26)"
