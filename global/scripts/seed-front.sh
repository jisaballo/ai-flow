#!/bin/bash
# Seed a linked worktree with the project data ai-flow needs, then prune the papers it does not own.
# This is the seed-and-prune move of the opening ceremony, as a mechanism: it knows nothing about any
# project, and everything it copies is named by the project's own pattern file.
#
# A front-end that creates the checkout without the project's data leaves it unusable — the data
# directory is ignored by version control, so git carries none of it. Run this against such a checkout
# and it arrives holding what the project declares travels, and only the papers of the task it owns.
#
# Usage: seed-front.sh <front-checkout> <T-XXX> [T-YYY ...]
#        Extra task ids declare papers that stay — a task this front is also working, paused or not.
set -euo pipefail

say()  { echo "seed-front: $1"; }
die()  { echo "seed-front: $1" >&2; exit 1; }

DEST_IN="${1:-}"
TASK="${2:-}"
[ -n "$DEST_IN" ] && [ -n "$TASK" ] || die "usage: $(basename "$0") <front-checkout> <T-XXX> [T-YYY ...]"
[ -d "$DEST_IN" ] || die "not a directory: $DEST_IN"
DEST="$(cd "$DEST_IN" && pwd -P)"
shift 2
# Every task whose papers stay. Naming them is a DECLARATION, and that is the whole point: inferring it
# from what the checkout already holds cannot tell a paper the front is working from one a creation-time
# copy dropped there a second earlier — and on the native path, where the tooling copies the artifacts
# directory wholesale before this ever runs, everything looks like the former and nothing is pruned.
KEEP="$TASK $*"
# Every id names a directory this run creates or spares, so it must BE a name: a value carrying a path
# separator escapes the artifacts directory in the mkdir below, and one that is a directory reference
# spares or destroys the wrong thing in the prune. DEST earns five refusals; these earn theirs.
for t in $KEEP; do
  case "$t" in
    */*|.|..) die "not a usable task id: $t (a name, no path)" ;;
  esac
done

# The primary is the first entry of the repository's own worktree listing — the anchor the guardrail
# hooks and the closing ceremony already resolve. Never the checkout this script runs from: run inside
# the front, that is the checkout with no data in it, and the copy would come from an empty hand.
git -C "$DEST" rev-parse --git-dir >/dev/null 2>&1 \
  || die "not a checkout of any repository: $DEST"

# The listing is read ONCE into a variable and everything below asks the variable. Two constructions are
# deliberately absent, both of them ways a pipeline lies about its own result under `pipefail`:
#   - piping the listing into an early-exiting reader (`awk … exit`, `head -1`) kills the producer, so
#     git dies of SIGPIPE once the listing outgrows its stdio buffer and the whole substitution comes
#     back 141 — with `set -e` that ends the run before any diagnostic can be printed;
#   - ending a pipeline in a `while` loop takes the LOOP's last-iteration status, not the status of the
#     matcher downstream, so a hit found on any entry but the last reads as no hit at all.
LIST="$(git -C "$DEST" worktree list --porcelain)" \
  || die "cannot read the worktree listing of the repository holding $DEST"
PRIMARY=""
REGISTERED=0
while IFS= read -r line; do
  case "$line" in "worktree "*) w="${line#worktree }" ;; *) continue ;; esac
  [ -n "$PRIMARY" ] || PRIMARY="$w"
  if [ "$(cd "$w" 2>/dev/null && pwd -P)" = "$DEST" ]; then REGISTERED=1; fi
done <<< "$LIST"
[ -n "$PRIMARY" ] && [ -d "$PRIMARY" ] || die "cannot resolve the primary checkout from $DEST"
PRIMARY="$(cd "$PRIMARY" && pwd -P)"

# The destination must be a checkout of that same repository, and not the primary itself. A path that
# merely sits inside one is not a checkout: seeding it would scatter the project's data into some
# subdirectory and report success.
[ "$DEST" != "$PRIMARY" ] || die "that is the primary checkout, which already holds the project's data: $DEST"
[ "$REGISTERED" = 1 ] || die "not a registered worktree of $PRIMARY: $DEST"

PATTERNS="$PRIMARY/.worktreeinclude"
# git reads an unreadable or empty pattern file as an empty set of patterns and answers "not selected"
# for every path — so a mechanism that concludes from one seeds nothing and reports success. Existence
# is not readability, and neither is content.
{ [ -r "$PATTERNS" ] && [ -s "$PATTERNS" ]; } \
  || die "no usable pattern file at $PATTERNS — nothing declares what travels, so nothing was copied"

# The pattern file is evaluated in a repository of its own. Ignore rules are ADDITIVE: asked inside the
# checkout the file describes, git answers for the project's own .gitignore too, and every path under an
# already-ignored directory comes back selected — the ledger included. Isolation is what makes the
# answer the pattern file's own.
EV="$(mktemp -d 2>/dev/null)" || die "no writable temporary directory for the pattern evaluator"
trap 'rm -rf "$EV"' EXIT
git init -q "$EV"

# ONE evaluation for the whole candidate list, not one per candidate. `check-ignore --stdin` reads the
# paths and prints back exactly the ones the pattern file selects: the same evaluator answering the same
# question about the same paths, so WHAT is selected is unchanged — what changes is that the cost stops
# scaling with the size of the primary. A fork per candidate is what put a monorepo's dependency
# directory in the critical path of every opening, at ~16ms each, with the prune unreached behind it.
#
# Two files rather than one pipeline, for the reason the worktree listing above is read into a variable:
# a pipeline reports the wrong status here. `check-ignore` exits 1 when it selects NOTHING, which is an
# ordinary answer and not a failure, and under `pipefail` that 1 would sink the whole run.
CAND="$EV/candidates"
SEL="$EV/selected"

evaluate() {  # $1 = NUL-delimited paths to ask about, $2 = where the selection goes -> 0 if non-empty
  local rc=0
  ( cd "$EV" && git -c core.excludesFile="$PATTERNS" check-ignore -z --stdin --no-index < "$1" ) > "$2" \
    || rc=$?
  case "$rc" in
    0|1) ;;   # 0 = something selected, 1 = nothing selected; both are answers, not failures
    *)   die "the pattern file at $PATTERNS could not be evaluated (git check-ignore exited $rc)" ;;
  esac
  [ -s "$2" ]
}

# Candidates are the primary's untracked-and-ignored paths, which is the eligibility rule the product
# states: anything tracked already travels with the checkout. git enumerates them as FILES, so no
# pattern naming a directory can collapse it into its parent. Its status is checked, which a process
# substitution could not do: there, a listing that failed to run was indistinguishable from a primary
# with nothing to seed.
git -C "$PRIMARY" ls-files -z --others --ignored --exclude-standard > "$CAND" \
  || die "cannot enumerate the untracked-and-ignored paths of $PRIMARY"
eligible=0
evaluate "$CAND" "$SEL" && eligible=1

# The papers of the seeded-for task are the one thing this run replaces, and the caller naming that
# task is what authorises it. It is the closing collection's exception read from the other side: there
# the copy from the checkout where the task was WORKED is the authoritative one and the coordinator's
# is a snapshot nobody should have edited; here the front has worked nothing yet, so the authority is
# the coordinator's. Without it the papers a checkout is born holding win forever — the sheet a front
# is given is written after the checkout exists, and nothing could ever bring it in.
#
# Matched with the separator, so a task id that is a PREFIX of another cannot claim its folder.
PAPERS=".ai-flow/artifacts/$TASK/"
PENDING="$EV/pending"
: > "$PENDING"
copied=0
replaced=0
live=""
while IFS= read -r -d '' rel; do
  [ -f "$PRIMARY/$rel" ] || continue
  case "$rel" in
    "$PAPERS"*)
      # Held back whether or not the front holds it, because the verdict below is about the FOLDER: a
      # front that is working the task keeps all of its papers, and mixing the coordinator's copy of
      # one paper into a folder the front is writing is the half-and-half state no reader can reason
      # about. Which copy is authoritative is decided by which was written last — nothing is parsed,
      # so it holds for every paper and not only for the sheet.
      #
      # A TIE counts as not-the-front's-work, and that is the case this exists for: the front-end that
      # copies at creation preserves the primary's own dates, so a snapshot arrives the same age as
      # its origin and never reads as older.
      if [ -e "$DEST/$rel" ] && [ "$DEST/$rel" -nt "$PRIMARY/$rel" ]; then live="$live $rel"; fi
      printf '%s\0' "$rel" >> "$PENDING"
      continue ;;
  esac
  [ -e "$DEST/$rel" ] && continue
  mkdir -p "$DEST/$(dirname "$rel")"
  # Preserving the timestamp, because the age of a copy is now evidence something reads. A copy that
  # stamps itself with the present makes this run's own work look like the front's, and the NEXT run
  # would refuse a checkout that had done nothing.
  cp -p "$PRIMARY/$rel" "$DEST/$rel"
  copied=$((copied+1))
done < "$SEL"

# All of them or none: one paper written after the coordinator's marks the whole folder as work in
# progress, and the refusal that says so is taken at the tail, after the prune.
if [ -z "$live" ]; then
  while IFS= read -r -d '' rel; do
    mkdir -p "$DEST/$(dirname "$rel")"
    if [ -e "$DEST/$rel" ]; then replaced=$((replaced+1)); else copied=$((copied+1)); fi
    cp -p "$PRIMARY/$rel" "$DEST/$rel"
  done < "$PENDING"
fi

# An empty selection is not one situation but two, and only one of them is a defect. Both layouts are
# documented: where the data directory is IGNORED the patterns select it and the copy above carries it;
# where it is COMMITTED git already carried the whole directory into the checkout, so selecting nothing
# among the ignored paths is the correct answer there and the prune below is the only work left. What
# remains is the documented precondition FAILING — a data directory neither ignored nor tracked, or a
# pattern file whose paths have gone stale — and there the front is born with no project data at all
# while the run reports success.
#
# So the question is not whether the selection is empty; it is whether the pattern file matches anything
# in this repository AT ALL, and the tracked paths are the second half of it. Asked only when the first
# half came back empty: the ordinary layout never pays for it, and it costs one evaluation rather than
# one per file — which is what makes asking it affordable at all.
declared=$eligible
if [ "$eligible" = 0 ]; then
  git -C "$PRIMARY" ls-files -z > "$EV/tracked" \
    || die "cannot enumerate the tracked paths of $PRIMARY"
  evaluate "$EV/tracked" "$EV/tracked-selected" && declared=1
fi

# The pattern file names the whole artifacts directory, so the checkout holds the papers of every open
# task — copied by the front-end at creation on the native path, or by the loop above on any other. The
# front owns what was declared: everything else goes, wherever it came from.
mkdir -p "$DEST/.ai-flow/artifacts"
pruned=0
while IFS= read -r dir; do
  name="$(basename "$dir")"
  case " $KEEP " in *" $name "*) continue ;; esac
  rm -rf "$dir"
  pruned=$((pruned+1))
done < <(find "$DEST/.ai-flow/artifacts" -mindepth 1 -maxdepth 1 -type d)
mkdir -p "$DEST/.ai-flow/artifacts/$TASK"

# Refused AFTER the prune, deliberately. The prune is what makes the data condition true on every path —
# a front-end that copied papers in at creation left them here whatever the patterns select — so stopping
# before it would leave foreign papers behind on the way out. What the status reports is that the data
# condition was not satisfied, and the sentence names which of the two causes to go and look at.
if [ "$declared" = 0 ]; then
  die "the pattern file at $PATTERNS matches nothing in $PRIMARY — neither an ignored path nor a tracked one, so $DEST was seeded with no project data. Either the data directory is not in your .gitignore (only untracked-and-ignored paths are eligible) or the patterns are stale."
fi

# Refused here for the same reason the one above is: the prune has to have happened whatever this run
# decides about the papers. What it reports is that the run could not tell a snapshot from live work
# and therefore chose neither — and it names the one act that settles it, because the operator is the
# only one who knows which of the two copies they meant.
if [ -n "$live" ]; then
  die "the papers of $TASK in $DEST were written after the coordinator's in $PRIMARY, so this front is working that task and its copy is the authoritative one — nothing of $TASK was replaced.$live. To take the coordinator's copy instead, delete $DEST/.ai-flow/artifacts/$TASK and run this again."
fi

say "seeded $DEST for $TASK — $copied file(s) copied, $replaced paper(s) replaced, $pruned foreign task folder(s) pruned"
[ -n "$*" ] && say "kept as declared: $*"
exit 0
