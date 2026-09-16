#!/bin/bash
# Shared machinery for the conformance suite: the counters and reporters, the git sandbox, the constants
# more than one section reads, and every helper more than one section calls.
#
# Sourced by the runner, never executed. The runner resolves ROOT from ITS OWN location and exports it
# before sourcing this file -- resolving ROOT here would answer `test/`, because ${BASH_SOURCE[0]} is
# this file and this file sits one directory deeper than the runner. A whole measurement was thrown away
# to that mistake once: every section then greps an empty tree and fails for a reason unrelated to what
# it claims.
#
# A helper belongs here when more than one section calls it, OR when a helper that belongs here calls it.
# The second half is not a nicety: a helper hoisted without the helper it calls is a section dependency
# that has merely moved, which is the exact failure this file exists to remove.


# The runner's per-section variable, declared here because it is read across files.
#
# The runner assigns it once per iteration of the run, to the path of the section it is about to source;
# this file and three sections read it (C47, C92, and C93's own row about this declaration). That makes it
# a cross-file API, and an API nobody declares is one a reader has to discover by grepping the runner --
# the same shape a shared helper closing over a caller's global has, arrived at from the other side.
# Declared rather than renamed: the name was never the defect, and four call sites moved would buy nothing
# this line does not.
#
# What the `-` default buys is the single home below: the defaulting decision is made here, once, so a
# reader downstream writes `$SECTION` and not `${SECTION-}` and has nothing to work out. It is NOT what
# makes this file safe to source standalone -- `$ROOT` is read undefaulted at column 0 further down and
# would die first -- and it is not what protects the runner's own loop, which binds the name before it
# sources anything, filter or no filter.
SECTION="${SECTION-}"

PASS=0
FAIL=0
ok()   { echo "  [ok]   $1"; PASS=$((PASS+1)); }
bad()  { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }

# The number of the numbered item whose LEAD LINE performs an act. $1 = an ERE matched against the
# lowercased lead line; $2 = the section's text.
#
# A step read by its literal number is silently wrong after a renumber: it extracts the neighbour that
# now sits there, the neighbour answers the same legs, and the row goes on claiming it judged the step
# its name still spells. That has happened twice in this file, and the second time one leg passed on the
# wrong step while its twin went red -- which is luck, not a mechanism.
#
# When no item performs the act it prints NOTHING, names the act on stderr and returns 1. Never a default
# index: a `:-0` fallback turns "the act is gone" into "the act is item zero", and item zero is the
# section's preamble, which answers a surprising number of prose legs.
step_no() {
  local n
  n="$(printf '%s\n' "$2" | awk -v p="$1" '/^[0-9]+\. /{h=tolower($0); if (h ~ p) {print $0+0; exit}}')"
  if [ -z "$n" ]; then
    echo "  step_no: no numbered item performs the act: $1" >&2
    return 1
  fi
  printf '%s' "$n"
}

# How the close states the destruction of the task's papers, in every wording the protocol uses for it.
# ONE home, because three blocks match on it and a fourth phrasing added to two of them silently narrows
# the third: an absence leg is only as wide as the ways the claim can be written, and a leg answered by
# none of them reports "the act is gone" when the act was merely reworded.
#
# NO BACKSLASH belongs in this pattern. It is handed to awk over `-v`, where an escape the language does
# not define is undefined behaviour: written with `\*`, it reached the matcher as a bare `*`, the whole
# alternation stopped matching an item that had not moved, and four green rows went red with nothing but
# the act-not-found line to say why.
DEL_ACT='delete[^a-z]*artifacts/t-xxx|papers are deleted|deletes the task.s papers'

# Does one sentence of $1 carry every pattern given after it? Prints 1, 0, or E.
#
# The form a proximity claim about prose takes at the legs that were moved to it. The `a[^.]{0,140}b`
# bridge is still written at other sites in this file and this helper asserts nothing about those. Two
# reasons it exists: a bounded repeat over a negated class compiles to an automaton the stricter of the
# two search engines a developer may have refuses outright, and a refusal read as "nothing found" reports
# a rule these documents still carry as one they lost; and a character count was only ever an
# approximation of "in one sentence" that a rewrite ten characters longer breaks.
#
# The boundary is the period and only the period: the region's own line breaks are flattened first, so no
# leg can go red because unchanged words were re-wrapped. A period inside a filename splits a sentence
# here, exactly as it did for the bridge.
#
# Three things it gives up against the bridge, and the third has already produced a hollow leg in this
# file: the order of the parts; the ceiling on how far apart they may sit; and any ability to tell one
# clause from another inside a long sentence — where two cases are joined by a semicolon, the wrong case's
# clause answers the leg. So cut the region to the clause, bind a part to the mechanism that distinguishes
# that case, and size every leg by splitting its own clause and watching it go red.
#
# `E` is the answer that is neither 1 nor 0: no patterns to test, or a pattern the engine refused. It
# fails the callers' `= 1` test so the leg reports, and the reason goes to stderr — a refusal counted as
# an absence is the exact defect this helper was written to remove, and reproducing it one level down
# would be worse than the bridge.
insent() {  # $1 = region, $2… = patterns; 1 when one sentence of the region carries all of them
  local region="$1"; shift
  [ "$#" -ge 1 ] || { echo 'insent: called with no patterns' >&2; printf 'E'; return; }
  [ -n "$region" ] || { printf '0'; return; }
  local sent p all rc
  while IFS= read -r sent; do
    all=1
    for p in "$@"; do
      printf '%s' "$sent" | grep -qiE "$p"; rc=$?
      case "$rc" in
        0) ;;
        1) all=0; break ;;
        *) echo "insent: the search engine refused a pattern (status $rc): $p" >&2; printf 'E'; return ;;
      esac
    done
    [ "$all" = 1 ] && { printf '1'; return; }
  done <<SENTENCES
$(printf '%s' "$region" | tr '\n' ' ' | tr '.' '\n')
SENTENCES
  printf '0'
}

# How many lines of a region carry a pattern. The count-in-a-region leg, which thirteen sections each
# write out as their own three-token pipeline under a name of their own — and in two incompatible
# argument orders, so a row copied between sections goes green on a swapped call, which still exits 0 and
# still returns a number. This is the family's home; the thirteen existing copies are pre-existing and
# are not touched here. Argument order is the majority one: the region first, the pattern second.
#
# Case-INSENSITIVE, like every copy it replaces. Where a leg needs the sentence boundary, or a bound on
# how far two parts may sit apart, `insent` and `near90` are the helpers that give it — this one answers
# only "the region carries these bytes", and a leg that needs more than that must say so itself.
nreg() { printf '%s' "$1" | grep -ciE "$2" | tr -d ' '; }

# A usable sandbox, or a named cause and a stopped run. `mktemp -d` failing is a broken environment, not
# a failing test: the substitution yields an empty string, every fixture path under it collapses to the
# filesystem root, and the section then scores whatever the greps make of files that were never written.
#
# Two things about the shape are load-bearing. The diagnostic goes to **stderr**, because this is called
# inside a command substitution and anything on stdout becomes the sandbox path. And the **caller**
# performs the exit, because a command substitution runs in a subshell: an `exit` here would end only
# that subshell and leave the caller running with the empty path this exists to prevent.
#
# The sections guarded when they were written wrap their whole body in an `else` instead. That shape was
# not retrofitted here: doing so re-indents 1,532 lines across nine sections, and a whitespace diff that
# size buries whatever change it arrives with.
mkbox() {  # a sandbox on stdout, or nothing and a non-zero status
  local d
  d="$(mktemp -d 2>/dev/null)" || d=""
  [ -n "$d" ] && [ -d "$d" ] || return 1
  # Registered so the one EXIT trap can remove it. A FILE and not a variable: this function is called
  # through command substitution, so its body runs in a subshell and any variable it set would die with
  # that subshell -- the assignment would look right and register nothing.
  printf '%s\n' "$d" >> "$BOXREG"
  printf '%s' "$d"
}
fatal() {  # $1 = what cannot run without a sandbox
  # Called from the CALLER, never from inside the substitution, and that placement is the whole point:
  # here it runs in the parent shell, so `bad` really counts and the `Result:` line below is the run's
  # own tail rather than a second copy. Reporting from inside `mkbox` would increment a counter in a
  # subshell that is about to vanish, and would put the message on stdout, where it becomes the path.
  bad "$1 (no sandbox: mktemp -d failed)"
  echo ""
  echo "Result: $PASS passed, $FAIL failed"
  echo "  run stopped here: a section cannot build its fixtures, so every verdict after it would be about nothing"
  exit 1
}

# Git's global configuration is sandboxed for the whole run, and this is a guard rather than tidiness.
# The installer this suite exercises writes `core.hooksPath` with `git config --global`; a sandbox that
# only redirects HOME does not contain that, because git writes its global config to
# $XDG_CONFIG_HOME/git/config when that file exists. On a developer who sets XDG_CONFIG_HOME, running
# this suite rewrote their real global hook path. Both variables are set here, at the top, so no call
# site can be added later that escapes it.
# Captured before the sandbox below replaces them. One row has to ask git what a developer's REAL ignore
# rules hide, because that set — a personal global ignore, .git/info/exclude — is precisely what npm cannot
# see and therefore ships. Asked inside the sandbox the question is answered by an empty configuration, and
# the row comes back clean over a package that leaks. Read-only: the sandbox exists to stop this suite
# WRITING a developer's git configuration, and nothing here writes.
REAL_XDG="${XDG_CONFIG_HOME-}"
REAL_GCG="${GIT_CONFIG_GLOBAL-}"

# Every sandbox the run creates, and the ONE trap that removes them.
#
# A trap is global state: `trap ... EXIT` REPLACES whatever was installed before it, it does not add to
# it. A suite whose blocks each installed their own kept only the last, and the sixteen before it leaked
# on every run -- which is why the teardown used to be one chain extended by every block that needed a
# sandbox, each block naming its neighbours' paths. That chain is the reason a filtered run could not
# work: under a filter the neighbour never runs, its variable is never set, and the trap dies on it.
#
# So the trap lives here, once, and reads a registry instead of a list of names. No section writes a trap
# and no section needs to know another exists. `chmod` first because a handful of fixtures are made
# deliberately unwritable, and rm would otherwise fail on exactly the sandboxes that most need removing.
BOXREG="$(mktemp 2>/dev/null)" || { echo "cannot create the sandbox registry (mktemp failed)" >&2; exit 1; }
cleanup_boxes() {
  local d
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    chmod -R u+rwX "$d" 2>/dev/null
    rm -rf "$d"
  done < "$BOXREG"
  rm -f "$BOXREG"
}
trap cleanup_boxes EXIT

GITSANDBOX="$(mkbox)" || fatal 'the git sandbox for the whole run'
mkdir -p "$GITSANDBOX/git"
: > "$GITSANDBOX/gitconfig"
export GIT_CONFIG_GLOBAL="$GITSANDBOX/gitconfig"
export XDG_CONFIG_HOME="$GITSANDBOX"

PY="template/.ai-flow/project.yml"


# --- constants more than one section reads -----------------------------------------------------------
HK="$ROOT/global/hooks"
GIT="git -c user.email=t@t.t -c user.name=t -c commit.gpgsign=false"
PY3=1
command -v python3 >/dev/null 2>&1 || PY3=0
VP="global/protocols/verify.md"
VS="global/skills/verify/SKILL.md"
VW="global/workflows/verify-review.js"
MAN="global/CLAUDE.md"
MANTWIN="${HOME:-}/.claude/CLAUDE.md"   # guarded: the suite runs under set -u and the twin is optional
BLG24="global/protocols/backlog.md"
S71='[[:space:]]+'

# --- the suite's own source, for the rows that audit it ------------------------------------------------
# A handful of rows take this suite's own text as their subject: how many places reach for a sandbox, what
# shape the marker table has, whether a helper's promise and the count that checks it still agree. The
# suite stopped being ONE file when the shared machinery moved out of the runner, so those rows read this
# list and never a single path -- a row still naming the runner alone would judge a file the thing it
# describes has left, and report its own blindness as a clean verdict.
#
# Unquoted at every call site ON PURPOSE: the word splitting is what hands grep and awk several files.
# The section files, in NUMERIC order. A glob answers lexically, where C10 precedes C2, and a suite that
# runs its blocks out of order is one whose output cannot be diffed against a previous run.
suite_sections() {
  [ -d "$ROOT/test/sections" ] || return 0
  find "$ROOT/test/sections" -maxdepth 1 -name 'C*.sh' 2>/dev/null \
    | awk -F/ '{n=$NF; sub(/^C/,"",n); sub(/-.*/,"",n); print n"\t"$0}' | sort -n | cut -f2-
}

# The identifier a section answers to on the command line: the C-number its filename opens with, never
# the slug after it, so renaming a section's words never changes how it is asked for.
section_id() {
  local b="${1##*/}"
  printf '%s' "${b%%-*}"
}

# Ordered: the machinery, then the sections as they run, then the runner. A row asking for "everything
# above this block" means by that the text that has already been read, and only this order keeps it true.
SUITE_SRC="$ROOT/test/lib/preamble.sh $(suite_sections | tr '\n' ' ')$ROOT/test/validate.sh"

# The suite's text as one stream, for a row that counts or slices rather than merely testing presence:
# `grep -c` over several files prints one count per file, and `grep -m1` stops once per file.
suite_src() { cat $SUITE_SRC; }

# The suite minus the block now running -- a hole of exactly one block, never a horizon. A row that
# audits how its neighbours are written must not be answered by its own text, and a row that excluded
# "everything from here on" would stop covering whatever is appended after it.
suite_src_others() {
  local f
  for f in $SUITE_SRC; do
    [ "$f" = "$SECTION" ] || cat "$f"
  done
}

# --- helpers more than one section calls -------------------------------------------------------------
mkproj() {  # $1 = dir, $2 = initial branch name -> repo with one commit
  mkdir -p "$1"
  $GIT init -q "$1"
  $GIT -C "$1" symbolic-ref HEAD "refs/heads/$2"
  printf 'x\n' > "$1/app.txt"
  $GIT -C "$1" add -A >/dev/null 2>&1
  $GIT -C "$1" commit -q -m init
}

nlines() { seq 1 "$1" | sed 's/^/line /'; }

# The payload shape a PreToolUse hook is actually sent, built in ONE place -- and now actually one: the
# two named helpers below, `wguard` and `aguard`, delegate here instead of printing a near-copy apiece,
# which is what the sentence claimed while three spellings of the contract were still in the file. They
# keep their names because 52 call sites read better for them, and a name that forwards is not a second
# home. The copies made the payload shape a thing spelled in five places, so a change to the hook
# contract had five edits and the suite went green on whichever ones were updated.
# `tool_name` rides every call because a guard's jurisdiction is its own and not the matcher's alone, and
# the trailing argument carries the tool's REMAINING fields verbatim -- which is what keeps a fixture
# honest about what production sends rather than trimmed to whatever the guard happens to read.
hookcall() {  # $1 = guard, $2 = cwd, $3 = file_path, $4 = tool_name, $5 = extra tool_input JSON (leading comma)
  printf '{"cwd":"%s","tool_name":"%s","tool_input":{"file_path":"%s"%s}}' "$2" "$4" "$3" "${5:-}" \
    | python3 "$1" 2>&1
}

# Its counterpart, and the ONLY other way a fixture may reach a hook: a payload `hookcall` cannot express
# because the whole subject of the row is a shape production would never send.
hookraw() {  # $1 = guard, $2 = a whole payload -> output, returns the hook's exit code
  printf '%s' "$2" | python3 "$1" 2>&1
}

# N words, exactly, counted the way `wc -w` counts them: whitespace-separated tokens. `nlines` cannot
# serve where a word budget is being driven — it emits two words per line, so its 400-line fixture is 800
# words and sits an order of magnitude under the budget.
nwords() { seq 1 "$1" | tr '\n' ' '; printf '\n'; }

wguard() {  # $1 = cwd, $2 = file_path -> prints output, returns hook exit code
  # The phase rail reads no `tool_name` -- its jurisdiction is the matcher's -- so this used to send a
  # payload without one. That trimmed the fixture to what the guard happens to read, which is the very
  # thing `hookcall` exists to prevent: production sends the field whether or not this rail looks at it.
  hookcall "$HK/understand-write-guard.py" "$1" "$2" Write
}

# --- a payload whose fields are not the shape the guard expects ----------
# The guard reads three fields and assumed the type of every one: `tool_input`, the `file_path`
# inside it, and `cwd`. Each assumption was a traceback with the rail down — a non-blocking exit, so
# the write it was meant to judge went through anyway, on every Edit and Write. Exit 0 is the answer
# the file already gives everywhere it cannot judge: a field it cannot read is a write it cannot
# judge. The helper below exists because the well-formed one above cannot express a malformed payload.
wraw() {  # $1 = raw payload -> prints output, returns the hook's exit code
  printf '%s' "$1" | python3 "$HK/understand-write-guard.py" 2>&1
}

malformed() {  # $1 = label, $2 = raw payload -> asserts the pair: waved through, and nothing said
  out="$(wraw "$2")"; rc=$?
  # Silence, not merely the absence of a crash: a guard that stands aside with a diagnostic is chatter
  # on every Edit and Write, which is the noise the silent stand-aside was chosen over in the first
  # place. A traceback is named separately in the failure label so a crash still reads as a crash.
  if [ "$rc" = 0 ] && [ -z "$out" ]; then
    ok "$1"
  else
    case "$out" in
      *Traceback*) bad "$1 (exit $rc, traceback)" ;;
      *)           bad "$1 (exit $rc, said: $out)" ;;
    esac
  fi
}

# --- the diff brake ------------------------------------------------------
# The payload DECLARES `Stop`, where the ceilings live and where a refusal is possible. It used to send
# `{}` and lean on the hook treating an unplaceable event as the refusing half — the very default that
# let a refusal reach the prompt event, now removed. A fixture that says which occasion it means is what
# the split needs from both sides.
brake() { ( cd "$1" && printf '{"hook_event_name":"Stop"}' | python3 "$HK/diff-size-guard.py" 2>&1 ); }

# A repo whose base commit already holds one large file, on a branch: the shape the note exists for is
# a small change to a file that was big before the task began, so neither ceiling fires.
mkbig() {  # $1 = dir, $2 = path of the big file, $3 = its committed line count
  mkproj "$1" main
  mkdir -p "$1/.ai-flow"; printf 'Current phase: **EXECUTE**\n' > "$1/.ai-flow/STATE.md"
  mkdir -p "$(dirname "$1/$2")"
  nlines "$3" > "$1/$2"
  $GIT -C "$1" add -A >/dev/null 2>&1
  $GIT -C "$1" commit -q -m big
  $GIT -C "$1" checkout -q -b feat
}

# git stands in for the pattern engine the product uses: same gitignore specification, no package
# dependency in a harness that is otherwise pure shell and git. Anchoring and negation are git's to
# resolve — a harness that re-implements either gets a different answer than the product does.
#
# THREE answers, never two. check-ignore reports a verdict with 0 (this path is selected) and 1 (it is
# not), and a failure with anything above. Collapsing the failure into "not selected" makes every
# verdict built on it vacuous: a git that cannot run then reads as "the ledger stays behind", which is
# the very answer the guard exists to earn rather than assume.
#
# The evaluator must be a repository with NO .gitignore of its own. core.excludesFile is ADDITIVE, so
# evaluating inside a checkout that already ignores .ai-flow/ reports every path under it as ignored no
# matter what the pattern file says, and the file becomes untestable. Isolation is the check.
#
# The caller establishes that the pattern file exists: a missing one is not a probe failure to git,
# which reads it as an empty set of patterns and answers "not selected" for everything.
wti_probe() {  # $1 = evaluator repo, $2 = pattern file, $3 = path -> 0 selected, 1 not, 2 unanswerable
  # The pattern set is asserted readable and non-empty before anything is concluded from it — the same
  # law the path list below carries, applied to the other input. git does not report an unreadable or
  # empty pattern file as a failure: it reads it as an empty set of patterns and answers "not selected"
  # for every path, so "the ledger stays behind" comes back established from a file nobody read.
  # Existence is not readability, and neither is content.
  { [ -r "$2" ] && [ -s "$2" ]; } || return 2
  ( cd "$1" 2>/dev/null || exit 2
    $GIT -c core.excludesFile="$2" check-ignore -q --no-index "$3" ) >/dev/null 2>&1
  case $? in 0) return 0 ;; 1) return 1 ;; *) return 2 ;; esac
}

# The classification is a function because an assertion can execute a function and cannot execute a
# shape inlined in a verdict. Grepping the harness for the message a verdict would print proves the
# message exists, never that any path reaches it — and the arm that counts the probe's third answer is
# exactly such a path. `want` is which answer the caller expects for these paths: `in` for the project
# data that must travel, `out` for the ledger that must not.
wti_classify() {  # $1 = evaluator, $2 = pattern file, $3 = in|out, $4.. = paths
                  # -> echoes "clean" | "unanswered N" | "wrong N"; diagnostics to stderr
  local ev="$1" pf="$2" want="$3"; shift 3
  local wrong=0 un=0 p rc
  for p in "$@"; do
    wti_probe "$ev" "$pf" "$p"; rc=$?
    if [ "$rc" = 2 ]; then
      un=$((un+1)); echo "         unanswered: $p" >&2
    elif [ "$want" = in ] && [ "$rc" != 0 ]; then
      wrong=$((wrong+1)); echo "         not selected: $p" >&2
    elif [ "$want" = out ] && [ "$rc" = 0 ]; then
      wrong=$((wrong+1)); echo "         ledger would travel: $p" >&2
    fi
  done
  if   [ "$un" != 0 ];    then printf 'unanswered %s\n' "$un"
  elif [ "$wrong" != 0 ]; then printf 'wrong %s\n' "$wrong"
  else printf 'clean\n'; fi
}

# Does this pattern file select any path git already tracks? Asked of the PATHS, never of the patterns:
# a gitignore pattern is not a pathspec, and reading it as one silently changes the question. `/x` is a
# legal anchored pattern and an illegal pathspec, `!x` names nothing at all — both answer empty, and an
# empty answer read as a clean verdict is how a real mistake passes. Handing the file to git instead
# also settles negation without a rule of our own: a negation only ever subtracts from the travel set,
# so it can never be the reason a tracked path is selected.
#
# The path list is asserted non-empty before anything is concluded from it — a guard whose extractor
# returned nothing otherwise passes every check it makes.
wti_tracked_leak() {  # $1 = evaluator repo, $2 = pattern file -> 0 a tracked path is selected, 1 none, 2 unanswerable
  local list
  list="$( $GIT -C "$ROOT" ls-files 2>/dev/null )" || return 2
  [ -n "$list" ] || return 2
  printf '%s\n' "$list" \
    | ( cd "$1" 2>/dev/null || exit 2
        $GIT -c core.excludesFile="$2" check-ignore -q --no-index --stdin ) >/dev/null 2>&1
  case $? in 0) return 0 ;; 1) return 1 ;; *) return 2 ;; esac
}

# One fact with two halves, and each copy judged on both of them: the manual names the task's own
# sheet, AND it no longer routes step progress to the roster. The shipped copy gets the negative half
# from the sweep above. The live twin was getting the positive half alone — so a manual that names the
# new path while still carrying the old line passed, and the copy that governs real sessions is the one
# no tool can repair: the installer writes it only when absent and the drift guard excludes it as
# user-owned (global/hooks/drift-check.sh). Half a fact about that file is the half that matters least.
manstate() {  # $1 = a manual -> 0 when it routes step progress to the task's own sheet and nowhere else
  grep -q 'artifacts/T-XXX/state.md' "$1" \
    && ! grep -q 'Update STATE.md with step progress' "$1"
}

ledger() {  # $1 = repo, $2 = phase -> the ledger STATE.md of a project that has not migrated
  mkdir -p "$1/.ai-flow"
  printf 'Current phase: **%s**\n' "$2" > "$1/.ai-flow/STATE.md"
}

sheet() {  # $1 = repo, $2 = task dir, $3 = branch line or "-", $4 = phase
  mkdir -p "$1/.ai-flow/artifacts/$2"
  { printf '# Task state\n\n'
    [ "$3" = "-" ] || printf 'branch: %s\n' "$3"
    printf 'phase: **%s**\n' "$4"
  } > "$1/.ai-flow/artifacts/$2/state.md"
}

pair() { # step, pattern A, pattern B, label, the text the step is read from
  printf '%s' "$(nitem "$1" "$5")" | grep -qiE "$2" && printf '%s' "$(nitem "$1" "$5")" | grep -qiE "$3" \
    && ok "$4" || bad "$4"
}

# A numbered step, flattened: what a step must say is a property of the step, never of where its prose
# happens to wrap.
nstep() { awk -v s="^$2\\\\. " -v e="^$(($2 + 1))\\\\. " '$0 ~ e {f=0} $0 ~ s {f=1} f' "$1" | tr '\n' ' '; }

# One bullet inside one step. Two bounds, not one: a fact scoped to a whole step passes on a
# neighbouring bullet's words, and an extractor anchored on the whole file can be retargeted by an
# edit anywhere else in it.
sbullet() { # file, step, pattern
  awk -v s="^$2\\\\. " -v e="^$(($2 + 1))\\\\. " '$0 ~ e {f=0} $0 ~ s {f=1} f' "$1" \
    | awk -v p="$3" 'g && (/^[[:space:]]*[-*][[:space:]]/ || /^[0-9]+\./) {exit} $0 ~ p {g=1} g' | tr '\n' ' '
}

# Byte offset of a fixed string: for the facts that are an ORDER, which presence greps cannot see.
off() { printf '%s' "$1" | grep -obF "$2" | head -1 | cut -d: -f1; }

# The move's own lead line — its identity. Classifying on the lead rather than on the body is what
# lets the order assertion see a MOVED move: a body pattern matches wherever its words landed.
# $1 = move number, $2 = the ceremony text. The text is an ARGUMENT and never a global this reaches
# for: a shared helper closing over a value one caller happens to assign answers empty-and-successful
# for every other caller — this is a pipeline whose last stage exits 0 on empty input, so the unbound
# expansion dies in the first subshell and never reaches the caller.
clohead() { printf '%s\n' "$2" | grep -E "^$1\. " | head -1; }

# A section body, bounded by the next heading of any depth: a fact belongs to the section that governs
# it, and a file-wide grep finds the first line that happens to match anywhere in a 200-line manual.
msect() { awk -v h="$2" '$0 ~ h {f=1;next} (f && /^#+ /){exit} f' "$1"; }

# One bullet of that section, from its lead to the next bullet, flattened: what a bullet says is a
# property of the bullet, never of where its prose wraps or of the neighbouring bullet's words.
mbul() { msect "$1" "$2" | awk -v s="$3" '/^- /{ if(f) exit; f=($0 ~ s) } f' | tr -s ' \n' '  '; }

# One fact, checked identically in both copies. The live twin carries the user's own language and
# sections, so every fact below is matched by what it says and never by the text around it. The remedy
# names the hand-merge because nothing distributes this file: the installer writes it only when absent
# and the drift guard excludes it as user-owned (global/hooks/drift-check.sh).
# Initialised HERE, beside the helper that writes it, and not in the one section that reports it. A
# counter a shared helper increments but only C17 declares dies under `set -u` the moment any OTHER
# caller reaches the skip branch -- `bash test/validate.sh C47` on a host with no live twin, which is a
# supported host, not a hypothetical: the `[skip]` line above exists to serve it.
C17_SKIPPED=0
manfact() {
  local fn="$1" what="$2"
  "$fn" "$MAN" && ok "$what" || bad "$what"
  # Each copy is judged on itself. A verdict about the twin printed without opening the twin blames a
  # manual the reader may not own — and on a host without one it turns the documented skip into a failure.
  if [ -f "$MANTWIN" ]; then
    "$fn" "$MANTWIN" && ok "the live twin: $what" \
      || bad "the live twin: $what (port the edit by hand — nothing distributes ~/.claude/CLAUDE.md)"
  else
    echo "  [skip] live CLAUDE.md twin absent — the shipped copy carries the fact"
    C17_SKIPPED=$((C17_SKIPPED+1))
  fi
}

# A numbered step of the skill, flattened. Not pinned to a literal number: inserting the bracket step
# renumbers everything after it, and an assertion that dies to renumbering tests the numbering.
vstep() { awk -v s="^$2\\\\. " -v e="^$(($2 + 1))\\\\. " '$0 ~ e {f=0} $0 ~ s {f=1} f' "$1" | tr '\n' ' '; }

# One numbered move, flattened AND whitespace-squeezed. What a move must say is a property of the move,
# never of where its prose happens to wrap, and never of a neighbouring move's words — a section-wide
# grep here would pass on the record move above it and on the dismantle move below.
# $1 = move number, $2 = the ceremony text — passed in, for the reason clohead's own note gives.
dmove() { printf '%s\n' "$2" | awk -v n="$1" '/^#+ /{cur=-1; next} /^[0-9]+\. /{cur=$0+0} cur==n' | tr '\n' ' ' | tr -s ' '; }

# As a KEY, never as a word: both the template's comment and the doc's list the candidate verbs in
# prose ("publish, deploy, regenerate"), so a bare word match answered from a neighbouring sentence —
# renaming the key on the protocol side alone stayed green on the word it happened to pick.
keyed() { printf '%s' "$1" | grep -qE "(^|[[:space:]#])${2}:"; }  # $1 = haystack, $2 = the key

nitem() {  # $1 = the item's number, $2 = the text it is read from
  # One numbered item of a section, flattened: what an item must say is a property of that item, never
  # of a neighbour's words nor of where its prose happens to wrap.
  #
  # One function under five names was the shape this replaced. cerstep, rung and a41 each closed over a
  # DIFFERENT global, and that is the whole reason they looked like different functions and could each
  # be hoisted on its own. Re-parameterised they are this body, so keeping five names would be a defect
  # introduced by the repair. The text is an argument: a shared helper does not read a value its caller
  # happens to have set, because when a second caller appears this pipeline's last stage exits 0 on
  # empty input and the caller reads success over nothing.
  printf '%s\n' "$2" | awk -v s="^$1\\\\. " -v e="^$(($1 + 1))\\\\. " '$0 ~ e {f=0} $0 ~ s {f=1} f' \
    | tr '\n' ' ' | tr -s ' '
}

# Which top-level list items of a file -- or of ONE REGION of it -- carry a given reference. The unit is
# the LIST ITEM, which is structure: a line `N. ` or a column-0 `- ` opens an item and every line after it
# belongs to that item until the next one opens. The extractor never learns any particular name; it reads
# whatever cites.
#
# A REGION ends at the next heading of its own level or higher, never at the next `###`. Keyed on `###`
# alone a `## ` region runs past its own end into the following section, and a `#### ` subheading closes a
# `### ` region that has not ended -- two wrong answers in opposite directions from one pattern.
#
# Two functions under two names was the shape this replaced, and they were one commit apart. One took a
# region heading and keyed an item by its number prefix; the other read the whole file, keyed by NR, and
# also let a column-0 bullet open an item. Re-parameterised they are this body, so keeping both names
# would have been a defect introduced by a repair -- the same finding nitem() above records for its own
# five copies.
#
# The key is NR and never the number prefix, because the two openers have to share ONE key space: item
# `3` and line 3 collide under `sort -u`, so a mixed key answers two different questions with one number.
# What a caller may read from a key is IDENTITY and COUNT, never the item's ordinal.
citing_items() { # $1 = file, $2 = region heading or '' for the whole file, $3 = needle -> one key per line
  awk -v head="$2" -v needle="$3" '
    BEGIN { if (head != "") { match(head, /^#+/); hlvl = RLENGTH } }
    head != "" && $0 == head { f = 1; item = ""; next }
    head != "" && f && match($0, /^#+ /) && RLENGTH - 1 <= hlvl { exit }
    head == "" || f {
      if ($0 ~ /^[0-9]+\. / || $0 ~ /^- /) item = NR
      if (item != "" && index($0, needle) > 0) print item
    }
  ' "$1" | sort -u
}

# The extractor above, shown to MEASURE on planted fixtures before any verdict is read from it. BOTH
# modes are proven here, in one place, because both are that one body: region-bounded with numbered
# openers, and whole-file with the two openers mixed. An extractor that found nothing would score every
# verdict taken over it perfect, and a fixture pair retyped per section is a proof each section owns a
# copy of -- which is what this helper's own siblings were.
#
# The fixture SHAPES are load-bearing and were arrived at by mutation, not by taste. A whole-file fixture
# that puts its bullets BEHIND a numbered item leaves the bullet opener never load-bearing: dropping that
# opener from the extractor keeps such a fixture green. The pair below places two column-0 bullets where
# it is, which is what makes that mutation kill.
item_extractor_measures() { # $1 = a writable sandbox -> 0 when it measures; prints the diagnostic on 1
  local d="$1/item-fx" rc rs wc ws
  mkdir -p "$d" || { printf 'could not plant fixtures under %s' "$d"; return 1; }
  { printf '%s\n' '### Region Head'
    printf '%s\n' '1. first'
    printf '%s\n' '2. second'
    printf '%s\n' '   - see the widget rule below'
    printf '%s\n' '   - and again the widget rule below'
    printf '%s\n' '### Something Else'
  } > "$d/r-collapsed.md"
  { printf '%s\n' '### Region Head'
    printf '%s\n' '1. first, see the widget rule below'
    printf '%s\n' '2. second'
    printf '%s\n' '   - also the widget rule below'
    printf '%s\n' '### Something Else'
  } > "$d/r-spread.md"
  { printf '%s\n' '1. first step'
    printf '%s\n' '2. second step'
    printf '%s\n' '   - one mention of the widget rule'
    printf '%s\n' '   - and again the widget rule'
  } > "$d/w-collapsed.md"
  { printf '%s\n' '1. first step, see the widget rule'
    printf '%s\n' '- a bullet that also names the widget rule'
    printf '%s\n' '- a second bullet naming the widget rule'
  } > "$d/w-spread.md"
  rc="$(citing_items "$d/r-collapsed.md" '### Region Head' 'widget rule' | tr '\n' ' ' | sed 's/ *$//')"
  rs="$(citing_items "$d/r-spread.md"    '### Region Head' 'widget rule' | tr '\n' ' ' | sed 's/ *$//')"
  wc="$(citing_items "$d/w-collapsed.md" ''                'widget rule' | tr '\n' ' ' | sed 's/ *$//')"
  ws="$(citing_items "$d/w-spread.md"    ''                'widget rule' | tr '\n' ' ' | sed 's/ *$//')"
  [ "$rc" = "3" ] && [ "$rs" = "2 3" ] && [ "$wc" = "2" ] && [ "$ws" = "1 2 3" ] && return 0
  printf "region collapsed='%s' spread='%s' | whole-file collapsed='%s' spread='%s'" "$rc" "$rs" "$wc" "$ws"
  return 1
}

# The markdown corpus under a directory, counted with find's ERRORS KEPT rather than swallowed. A subtree
# find cannot descend disappears from the corpus and from every count taken over it at once -- which is
# precisely the green a "one home" row awards -- so the error file is the CALLER's to test. Three sections
# take this measurement and each wraps it in its own guard, because what else must be readable differs
# per section; what is shared is the pipeline, and that is what lives here.
md_count() { # $1 = directory, $2 = a writable path for find's stderr -> the count, on stdout
  find "$1" -name '*.md' 2>"$2" | grep -c . | tr -d ' '
}

# How many files under a root carry a heading line: the count of a rule's HOMES. Matched WHOLE-LINE and
# FIXED-STRING, which is what keeps a citation of the heading from counting as a statement of it -- and
# which is also the limit, recorded where it is read: a second home worded unlike the heading escapes it.
home_count() { # $1 = the heading line, $2 = root -> the count, on stdout
  grep -rlxF "$1" --include='*.md' "$2" 2>/dev/null | grep -c . | tr -d ' '
}

# What ships is what the installer fetches out of version control, which is what git can name: tracked
# files, plus untracked ones git is not ignoring. A recursive walk of the directory reads more than
# that. Running the hooks in place leaves Python bytecode under `global/hooks/__pycache__/`, and that
# bytecode carries the absolute path it was compiled from -- so an ignored directory the installer
# never distributes turned this row red, accusing the shipped engine of carrying an author home path
# it does not carry. Neither probe the working-copy comparison uses reaches an ignored file, so the run
# reported the tree left as found while this verdict had already changed. The failure was also
# intermittent: the system grep announces a binary match and the row fails, ugrep suppresses it and the
# row passes, so the same tree answered differently on different machines.
purity_sweep() { # repo root, subpath -- one `file:line:text` per hit among the files that could ship
  local root="$1" sub="$2" list
  # Reading the file list from git buys precision and brings git's own failure modes with it. A tree
  # that is not a repository, or a git that cannot answer, yields an empty list -- and an empty list
  # grepped for a leak finds none, so the row would report a clean engine on the strength of having
  # read nothing. The walk this replaced could not fail that way, so the guard is part of the
  # replacement: every input a verdict concludes from is proven usable before it is concluded from.
  # Non-zero here means "could not run", which the caller reports as such and never as a pass.
  git -C "$root" rev-parse --git-dir >/dev/null 2>&1 || return 2
  list="$(git -C "$root" ls-files --cached --others --exclude-standard -- "$sub" 2>/dev/null)" || return 2
  # Selecting nothing is the same defect wearing a mistyped path: the seeder's empty-selection case.
  [ -n "$list" ] || return 2
  # `-H` because grep omits the filename when it is handed exactly one file, and a hit that cannot say
  # which file carries it is a hit nobody can act on.
  # The subshell's own status is grep's, and grep answers 1 for "found nothing" -- which is the passing
  # case here, not a failure. So the only status this function forwards is the one that means the files
  # could not be reached; everything else is a completed sweep whose hits are its output.
  ( cd "$root" 2>/dev/null || exit 9
    printf '%s\n' "$list" | tr '\n' '\0' \
      | xargs -0 grep -HniEI 'residents|gate-manager|zoomin|esp32|/Users/[a-z]' 2>/dev/null )
  [ $? -eq 9 ] && return 2
  return 0
}

graw() {  # $1 = raw payload, $2 = the guard script -> combined output, the hook's exit code
  printf '%s' "$1" | python3 "$2" 2>&1
}

# --- Step 1: a field the rail cannot read is a command it cannot judge ----
# Each check below drives several payload shapes and reports ONE verdict, naming the shapes that
# failed. Silence, not merely the absence of a crash: a rail that stands aside with a diagnostic is
# chatter on every Bash command, and a traceback is named separately so a crash still reads as a crash.
waved() {  # $1 = the guard script, $2 = label, $3.. = raw payloads -> one verdict for the set
  # The script comes FIRST here, against this file's habit of appending the input, because the tail is
  # variadic: a payload list and a trailing argument cannot both be "the rest of the arguments".
  gsw="$1"; label="$2"; shift 2; whyw=""
  for p in "$@"; do
    out="$(graw "$p" "$gsw")"; rc=$?
    if [ "$rc" != 0 ] || [ -n "$out" ]; then
      case "$out" in
        *Traceback*) whyw="$whyw [$p -> exit $rc, traceback]" ;;
        *)           whyw="$whyw [$p -> exit $rc, said: $out]" ;;
      esac
    fi
  done
  [ -z "$whyw" ] && ok "$label" || bad "$label ($whyw)"
}

# $1: i case-insensitive, s case-sensitive. $2: extended regex. $3: the corpus, defaulting to CORPUS89.
# Paths print relative to $ROOT, which is the form the card cites them in, so neither side needs
# normalising before they are compared.
#
# The corpus is a PARAMETER rather than a second copy of this pipeline. A caller needing a different
# reach used to retype the three stages under a new name, which passes C93's ROW 5 on the rename alone:
# the row forbids a section from DEFINING a preamble-owned name, and a copy called something else is
# invisible to it. Defaulting the parameter is what keeps every existing call unchanged, including the
# two whose exact text another section pins.
#
# `${3-…}` and never `${3:-…}`: UNSET falls to the default, EMPTY does not. A caller computes its corpus
# from a command substitution that can legitimately come out empty — `git ls-files` failing, or a filter
# selecting nothing — and `:-` would quietly run that call over CORPUS89 instead, which is a DIFFERENT
# reach: it excludes the suite's own sources, the very files a whole-tree caller passed its own corpus
# to cover. An absence verdict computed over a corpus that cannot hold the survivors is a green row
# about a question nobody asked.
sweep89() {
  if [ "$1" = "s" ]; then
    printf '%s\n' "${3-$CORPUS89}" | tr '\n' '\0' | (cd "$ROOT" && xargs -0 grep -lIE -- "$2" 2>/dev/null) | sort -u
  else
    printf '%s\n' "${3-$CORPUS89}" | tr '\n' '\0' | (cd "$ROOT" && xargs -0 grep -lIiE -- "$2" 2>/dev/null) | sort -u
  fi
}


# --- what the homes marker runs on -------------------------------------------------------------------
# `marker89` below closes over every name in this block. They used to be derived inside the section that
# first needed them, and inside a readable-files branch at that, so a second section calling the marker
# got an unbound variable or a silently empty sweep depending on where it ran. A helper's inputs belong
# with the helper: that is the rule this whole restructuring is an instance of.
#
# Tolerant by construction. An unreadable workflow file leaves these empty rather than stopping the run,
# because whether the file is readable is a VERDICT some section owns, not a fact the machinery may
# assume. An empty extraction makes the rows that depend on it fail, which is what it is for.
VW83="global/workflows/verify-review.js"
DIM83="$(awk '/^const DIMENSIONS = \[/{f=1;next} /^\]$/{f=0} f' "$VW83")"
k83="$(printf '%s\n' "$DIM83" | grep -cE "^[[:space:]]+key: '" | tr -d ' ')"
shapes83() { printf '%s auditors|%s auditors|%s-auditor|%s-auditor|%s parallel auditors|%s parallel auditors|%s review agents|%s review agents|%s review auditors|%s review auditors|%s lists|%s lists' \
  "$1" "$2" "$1" "$2" "$1" "$2" "$1" "$2" "$1" "$2" "$1" "$2"; }
word83() { case "$1" in 3) printf three;; 4) printf four;; 5) printf five;; 6) printf six;; 7) printf seven;; *) printf %s "$1";; esac; }
now83="$(shapes83 "$k83" "$(word83 "$k83")")"
stale83=""
for c83 in 3 4 5 6 7; do
  [ "$c83" = "$k83" ] && continue
  stale83="${stale83:+$stale83|}$(shapes83 "$c83" "$(word83 "$c83")")"
done
SELFEX89="$(for f89 in $SUITE_SRC; do printf '%s\n' "${f89#$ROOT/}"; done)"
ax89="$(printf '%s\n' "$DIM83" | sed -nE "s/^[[:space:]]+key: '([a-z]+)'.*/\\1/p" | paste -sd'|' -)"
CORPUS89="$(cd "$ROOT" && git ls-files 2>/dev/null | grep -vxF -f <(printf '%s\n' "$SELFEX89"))"

# The whole tracked tree, suite source included. CORPUS89 above excludes the suite, because a HOME is a
# home of the engine and never of the row that counts it. An ABSENCE leg needs the opposite reach: a
# retired identifier surviving inside the harness is precisely the case a corpus blind to the harness
# cannot see, and this task's own sweep found two such sites. Assigned here, beside the corpus it is the
# counterpart of, for the reason the block header above gives about a helper's inputs.
CORPUS_ALL89="$(cd "$ROOT" && git ls-files 2>/dev/null)"

# One marker per concept: the rule that recognises a HOME of it, as against a file that merely mentions
# it. The difference is not cosmetic and two of the six prove it — `**Audited**` unanchored finds three
# referrers beside the one home, and the template's axis keys sit inside `#` comments, so a marker blind
# to either is wrong, in opposite directions. An unknown concept returns non-zero: that is the signal a
# row has no marker, and it is why every known branch ends by returning zero even when it matched nothing.
marker89() {
  case "$1" in
    "Auditor list")
      # Current OR stale shapes. A document naming a count that is no longer current is a home that has
      # gone wrong, and a marker sweeping only the current shapes goes quiet on exactly that document.
      sweep89 i "$now83|$stale83" ;;
    "Axis content (what each auditor looks for)")
      # The array itself, not a phrase out of one axis's prompt. A lexical fingerprint recognises the
      # dimension it was copied from and no other, so a rewording of those two sentences would empty the
      # set — and the two phrases already have a home in A5 above, which is the duplication this whole
      # mechanism exists to refuse.
      sweep89 s '^const DIMENSIONS = \[' ;;
    "Workflow arguments")
      sweep89 i 'understandPath|contextPaths|diffText|changedFiles|testCommand' ;;
    "Declarable profile axes")
      # Two ways to carry the set: as YAML keys, or as the `<axis>Checklist` identifiers the call and the
      # prompts use. The comment prefix is stripped before the keys are read, because the shipped
      # template hands every adopter its example commented out — a marker that read typography would
      # miss the one file every project starts from.
      # The five names come from DIMENSIONS, never from a list written here: a marker inside machinery
      # whose whole claim is "computed, never enumerated" cannot itself enumerate the thing it looks for,
      # and a sixth axis would otherwise be declarable everywhere except in the guard that finds it.
      printf '%s\n' "$CORPUS89" | while IFS= read -r f89; do
        [ -n "$f89" ] || continue
        if sed 's/^[[:space:]]*#[[:space:]]*//' "$ROOT/$f89" 2>/dev/null \
             | grep -qE "^[[:space:]]*($ax89):[[:space:]]" \
           || grep -qE "($ax89)Checklist" "$ROOT/$f89" 2>/dev/null
        then printf '%s\n' "$f89"; fi
      done | sort -u ;;
    "Report template")
      # Anchored at line start, which is the whole marker: the template's own first line begins with it,
      # while every reference to it names it mid-sentence.
      sweep89 s '^\*\*Audited\*\*:' ;;
    "Outcome disclosure")
      # The table's own header is the marker — three columns naming the outcome, what the run says and
      # what the report records. Case-sensitive and anchored at the row, because every other surface
      # names the table mid-sentence in order to cite it, and a marker that reached those would report
      # the citers as homes. One home is the point of the row, and a matrix stated in prose is the
      # shape that acquires more of them without anyone deciding to: every copy reads as a restatement
      # until the day two of them disagree.
      sweep89 s '^[[:space:]]*\| Outcome \| What the run says' ;;
    "Severities")
      # All three levels, not any one: a file naming a single level is stating a rule about that level,
      # not carrying the scheme, and the scheme is what a change to severities would have to tick.
      printf '%s\n' "$CORPUS89" | while IFS= read -r f89; do
        [ -n "$f89" ] || continue
        grep -qE '\bHIGH\b' "$ROOT/$f89" 2>/dev/null \
          && grep -qE '\bMEDIUM\b' "$ROOT/$f89" 2>/dev/null \
          && grep -qE '\bLOW\b' "$ROOT/$f89" 2>/dev/null \
          && printf '%s\n' "$f89"
      done | sort -u ;;
    *) return 1 ;;
  esac
  return 0
}

# A section body, FENCE-AWARE. Three of the regions below quote a steering skeleton whose own lines begin
# with `## `, and a fence-blind extractor ends the section on the skeleton's first heading -- inside the
# fence, which is precisely where the shape A4 measures lives.
sec90() { [ -r "$1" ] || return 0
          awk -v h="$2" '$0 ~ h {f=1;next} /^```/{c=1-c; if(f) print; next} (c==0 && /^#+ /){f=0} f' "$1"; }

# 1 when two patterns sit inside ONE CLAUSE of a region, in either order -- an ordered co-occurrence that
# cannot span a sentence. Two loose greps over a region accept either claim NEGATED and accept a
# comma-joined exchange as one chunk; a window bounded at the sentence binds a predicate to its own
# subject and holds whatever the punctuation does.
#
# The window is `[^.]` OR a period followed by a letter, which is the difference between a sentence end
# and a FILENAME. Every clause this block reads is prose about files -- `product.md`, `.ai-flow`,
# `context.md` -- so a window that stops at any period stops in the middle of the subject it is binding,
# and the leg then reddens a document that says exactly the right thing.
#
# A REFUSED pattern is not an absence. `grep -ci` exits 1 for no match and >1 when the engine rejects the
# expression, and a bare count pipeline throws that away -- so a leg keyed on a malformed pattern reads
# "clean" and passes forever. This helper answers `E` for that case, the way the suite's own `insent()`
# does, and its seven callers go through the two wrappers below so a refusal fails CLOSED at the leg that
# suffered it. An accumulator was written first and could never fire: every call sits inside `$( )`, so
# anything the helper assigns dies with the subshell.
near90() { [ -n "$1" ] || { printf '0'; return; }
           n90="$(printf '%s' "$1" | tr '\n' ' ' | tr -s ' ' \
             | grep -ciE "($2)([^.]|\.[a-zA-Z]){0,$4}($3)|($3)([^.]|\.[a-zA-Z]){0,$4}($2)")"
           case "$?" in 0|1) printf '%s' "$n90" | tr -d ' ';; *) printf 'E';; esac; }

# True when near90 found at least one adjacency; false for zero AND for `E`, which is neither present nor
# absent. Same for the zero form, which asks that something be ABSENT: a refusal must not satisfy it.
nearok90()   { case "${1:-}" in ''|*[!0-9]*) return 1;; esac; [ "$1" -ge 1 ]; }

nearzero90() { case "${1:-}" in ''|*[!0-9]*) return 1;; esac; [ "$1" = 0 ]; }
