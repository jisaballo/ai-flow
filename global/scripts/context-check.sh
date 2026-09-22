#!/bin/bash
# Compute the context mechanism's measures — one verdict per file and per rule.
#
# The shape rules are stated in protocols/context.md; this is what turns them into an answer, so that
# "is this context file still in shape?" stops being a judgement made differently by each reader. It is
# the `Verify` of every archive move that writes a context file, and it runs by hand and from CI on the
# same terms.
#
# It knows nothing about any project. The set it measures is WHERE THE FILES LIVE — the steering
# directory plus the two fixed files — and never what a delivery map points at: a map answers which
# document a task receives, and the honest answer may be a document whose own home refuses these
# ceilings. Reading the map would measure that document with rules it never accepted, and would miss a
# steering file nobody declared.
#
# The map is read for two things, and NEITHER of them is a ceiling, so the paragraph above stands
# unchanged. The application keys the no-app-key-in-a-domain-file rule needs. And, per entry, whether
# the value RESOLVES — from the checkout root, to a file that exists. That second one is a verdict about
# the declaration and not about the document: a value pointing outside `.ai-flow/` resolves, passes, and
# is measured by nothing, because the question asked is existence and never location. It is here rather
# than in the phases that consume the map for the reason the map went unchecked for so long: a consumer
# that skips what it cannot open is not a check, it is the silence.
#
# Usage: context-check.sh [--report] [file …]
#        Run from a checkout root. With no argument the set is the steering directory's `*.md`, plus
#        `product.md` and `decisions-global.md`, once each. `--report` prints the threshold each verdict
#        applied.
#
# `set -e` is deliberately absent. This is a mechanism that COLLECTS verdicts: dying at the first
# non-zero would report the first failing file and stay silent about every one after it, which is the
# opposite of a survey. Every exit below is taken on purpose.
set -uo pipefail

# The three numbers, and their one home. protocols/context.md names these measures and never their
# values — a value spelled anywhere else is a second home, and the drift starts the day one of them
# moves. Each was sized against the real sets rather than chosen: every file already in shape sits
# below its ceiling, every file already judged out of shape sits above it.
NANO_LINE_MAX=200      # characters in one logical nano bullet, its continuations included
SECTION_WORD_MAX=450   # words in one `##` section
SECTION_MAX=10         # `##` sections in one file, the nano block excluded

FAIL_MARK="FAIL"

say() { printf 'context-check: %s\n' "$1"; }
die() { printf 'context-check: %s\n' "$1" >&2; exit 2; }

usage() {
  cat <<'USAGE'
usage: context-check.sh [--report] [file ...]

  Run from a checkout root; reads only that checkout's .ai-flow/.
  With no argument the set is the steering directory's *.md
  plus product.md and decisions-global.md, once each.

  --report   print the threshold each verdict applied
USAGE
}

REPORT=0
ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --report)  REPORT=1 ;;
    -h|--help) usage; exit 0 ;;
    --)        shift; while [ $# -gt 0 ]; do ARGS+=("$1"); shift; done; break ;;
    -*)        die "unknown option: $1" ;;
    *)         ARGS+=("$1") ;;
  esac
  shift
done

ROOT="$PWD"
DATA="$ROOT/.ai-flow"
[ -d "$DATA" ] || die "no .ai-flow/ here, so there is nothing of this project's context to measure: $ROOT"

# Lexical normalisation, because the path need NOT exist: a file named as an argument and absent is a
# refusal this script must name, and `realpath` on it answers nothing at all. Lexical is also what
# catches the climb — a comparison of leading strings accepts `.ai-flow/../docs/x.md`, which is outside
# the data directory by every meaning except the one the string has.
normalise() {
  local p="$1" out="" seg
  case "$p" in /*) ;; *) p="$PWD/$p" ;; esac
  local IFS=/
  set -f
  for seg in $p; do
    case "$seg" in
      ''|.) ;;
      ..)   out="${out%/*}" ;;
      *)    out="$out/$seg" ;;
    esac
  done
  set +f
  printf '%s' "${out:-/}"
}

# The `steering:` block: the SHAPE OF ITS LEAD, then one entry per line beneath it. ONE parser with
# three readers below it — the application keys, the resolution verdict, and the lead the verdict
# reports on — because a block parsed twice is a block whose readers can come to disagree about what an
# entry is.
#
# THE LEAD IS CLASSIFIED AND NEVER MERELY MATCHED, and that is the whole reason this function has a
# shape of its own. An earlier form entered the block on a bare `steering:` alone and turned the scanner
# OFF for every other spelling, which made two legal, shipped shapes yield zero entries in silence: a
# lead carrying a trailing comment — the form `docs/customization.md` documents in the very sample it
# introduces as the one the phase skills read — and a populated flow mapping. Zero entries then read as
# an empty map, the run exited 0, and every value in it was checked by nothing. That is the defect this
# verdict exists to end, reproduced one level up, and the fix is not a wider pattern: it is a THIRD
# answer, `unparsed`, so that *the map was not read* can never again wear the face of *the map is empty*.
#
# `steering: {}` is the shipped default and is the one legitimate zero — an EMPTY flow mapping, told
# apart from a populated one, so the default state most adopters are in stays silent and correct. A key
# declared with NO value yields an empty value rather than no row, which is what lets the verdict tell it
# apart from a key that is absent altogether.
# `return 0` ONLY where there is no file. A `project.yml` that EXISTS and cannot be read is the case
# this whole verdict was added for -- a declaration nobody could resolve -- and the tolerance carried
# over from the old key-only reader answered it with the same silence as a project that declares
# nothing. The two are told apart at their one source, so every reader below inherits the distinction.
map_scan() {
  local yml="$DATA/project.yml"
  if [ ! -r "$yml" ]; then
    [ -e "$yml" ] && printf 'lead\tunreadable\n'
    return 0
  fi
  awk '
    /^steering:/ {
      rest = $0
      sub(/^steering:[ \t]*/, "", rest)
      sub(/[ \t]*#.*$/, "", rest)
      sub(/[ \t]+$/, "", rest)
      if (rest == "")            { print "lead\tblock";    m = 1; next }
      if (rest ~ /^\{[ \t]*\}$/) { print "lead\tempty";    m = 0; next }
                                   print "lead\tunparsed"; m = 0; next
    }
    m && /^[ \t]*#/             { next }
    m && /^[ \t]+[^ \t#][^:]*:/ {
      line = $0
      sub(/^[ \t]+/, "", line)
      k = line; sub(/:.*$/, "", k)
      v = line; sub(/^[^:]*:[ \t]*/, "", v)
      sub(/[ \t]+#.*$/, "", v); sub(/[ \t]+$/, "", v)
      gsub(/^["'"'"']|["'"'"']$/, "", v)
      print "entry\t" k "\t" v
      next
    }
    m && /^[^ \t]/              { m = 0 }
  ' "$yml"
}

# The three readers. Each takes its own field out of the one scan above rather than parsing the block
# again: a second parse is a second opinion about what an entry is, and this block already cost the
# engine one.
map_entries() { map_scan | awk -F'\t' '$1 == "entry" { print $2 "\t" $3 }'; }
map_lead()    { map_scan | awk -F'\t' '$1 == "lead"  { print $2; exit }'; }

# The application keys, and only those: a `steering:` key whose area has a directory of its own under
# `apps/` or `libs/`. In a single-application project the layer does not exist and the rule below has
# nothing to fire on, which is correct rather than a gap. Read once into APP_MAP -- the same "one scan"
# discipline the block above states -- so ownership below reads its own key's value out of this capture
# rather than asking map_entries again per key per file.
APP_MAP="$(map_entries)"
APP_KEYS=""
while IFS="$(printf '\t')" read -r k v; do
  [ -n "$k" ] || continue
  if [ -d "$ROOT/apps/$k" ] || [ -d "$ROOT/libs/$k" ]; then APP_KEYS="$APP_KEYS $k"; fi
done <<MAPENTRIES
$APP_MAP
MAPENTRIES

# Ownership is by VALUE and never by name: key $1 owns file $2 when its map entry, resolved from the
# checkout root, IS that file -- so an alias (two keys pointing at the same file) owns it together, and
# a key merely sharing the file's basename with no map entry to match owns nothing. Reads $APP_MAP,
# captured once above, rather than re-scanning the map per key per file.
owns_this_file() {
  local k="$1" f="$2" v
  v="$(printf '%s\n' "$APP_MAP" | awk -F'\t' -v key="$k" '$1 == key { print $2; exit }')"
  [ -n "$v" ] || return 1
  [ "$(normalise "$ROOT/$v")" = "$f" ]
}

# A title names an application when the key stands as a word in it. Padded and bounded on both sides,
# so `checkout` is not found inside `checkouts` and a key at either end is still found.
#
# The key is the operator's own text and reaches this matcher verbatim, so it must never become a
# PATTERN. Built into an ERE it could be refused rather than unmatched -- `c++` is not a valid one -- and
# a matcher that returns non-zero for both leaves the caller unable to tell "the title does not name it"
# from "the question was never asked", which is a rule printed as `ok` having never run. `case` matches a
# QUOTED variable literally, so there is nothing to escape, no second process, and no status to misread.
title_names_app() {
  local t k
  t="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  k="$(printf '%s' "$2" | tr '[:upper:]' '[:lower:]')"
  case " $t " in *[!a-z0-9]"$k"[!a-z0-9]*) return 0 ;; esac
  return 1
}

# --- the file set ---------------------------------------------------------------------------------
FILES=()
add_file() {
  local n="$1" i=0
  while [ "$i" -lt "${#FILES[@]}" ]; do
    [ "${FILES[$i]}" = "$n" ] && return 0
    i=$((i + 1))
  done
  FILES+=("$n")
}

if [ "${#ARGS[@]}" -eq 0 ]; then
  # A member of the default set that is not there is REPORTED and is not a failure: the default form is
  # a survey of what the project has, and a project with no decision log has not broken a rule.
  if [ -d "$DATA/steering" ]; then
    for f in "$DATA"/steering/*.md; do
      [ -e "$f" ] || continue
      add_file "$f"
    done
  fi
  for f in "$DATA/product.md" "$DATA/decisions-global.md"; do
    if [ -f "$f" ]; then add_file "$f"; else say "not present: ${f#"$ROOT"/}"; fi
  done
else
  # The argument form is a REQUEST, so what it names must be readable and must be this script's to read.
  # Every argument is judged before any file is opened, and one refusal ends the run: a refusal followed
  # by verdicts about the other arguments reads as though the refused path had been measured too.
  refused=0
  for a in "${ARGS[@]}"; do
    abs="$(normalise "$a")"
    case "$abs" in
      "$DATA"/*) ;;
      *) say "refused, outside this checkout's data directory: $a"; refused=1; continue ;;
    esac
    if [ ! -f "$abs" ]; then say "no such file: $a"; refused=1; continue; fi
    add_file "$abs"
  done
  [ "$refused" = 0 ] || exit 2
fi

# --- the reader -----------------------------------------------------------------------------------
# One pass per file, emitting facts the verdicts are drawn from. A fenced block and an HTML comment are
# NOT body: the shipped decision-log skeleton teaches its own format in a comment whose example line
# begins with `##`, and a blind reader indexes that example as a section the nano is missing.
AWK_READ='
{
  line = $0
  if (line ~ /^[ \t]*```/) { fence = 1 - fence; next }
  if (fence) next
  res = ""
  while (length(line) > 0) {
    if (comment) {
      i = index(line, "-->")
      if (i == 0) { line = ""; break }
      line = substr(line, i + 3); comment = 0
    } else {
      i = index(line, "<!--")
      if (i == 0) { res = res line; line = ""; break }
      res = res substr(line, 1, i - 1)
      line = substr(line, i + 4)
      comment = 1
    }
  }
  line = res
  if (line ~ /^# /)  { h1++; next }
  if (line ~ /^## /) {
    t = substr(line, 4)
    sub(/^[ \t]+/, "", t); sub(/[ \t]+$/, "", t)
    if (t == "Nano") { nano = 1; innano = 1; next }
    innano = 0
    nsec++; title[nsec] = t; words[nsec] = 0
    next
  }
  if (innano) {
    if (line ~ /^[-*][ \t]/)                    { nl++; raw[nl] = line }
    else if (nl > 0 && line ~ /^[ \t]+[^ \t]/)  { raw[nl] = raw[nl] " " line }
    next
  }
  if (nsec > 0) {
    body = line
    gsub(/^[ \t]+/, "", body); gsub(/[ \t]+$/, "", body)
    if (body != "") words[nsec] += split(body, tmp, /[ \t]+/)
  }
}
END {
  printf "H1 %d\n", h1
  printf "NANO %d\n", nano
  for (i = 1; i <= nsec; i++) printf "SEC %d %s\n", words[i], title[i]
  for (i = 1; i <= nl; i++) {
    r = raw[i]
    gsub(/[ \t]+/, " ", r); sub(/^ /, "", r); sub(/ $/, "", r)
    b = r; sub(/^[-*] +/, "", b)
    t = ""
    if (substr(b, 1, 2) == "**") {
      rest = substr(b, 3)
      j = index(rest, "**")
      if (j > 0) t = substr(rest, 1, j - 1)
    }
    printf "NANOLINE %d %s\n", length(r), t
  }
}'

FAILING=0
verdict() {  # $1 = file as displayed; $2 = rule; $3 = the cause, empty when the rule holds; $4 = its
             # threshold; $5 = "na" when the rule was not evaluated -- $3 then carries why, not a failure
  local rel="$1" rule="$2" cause="${3:-}" limit="${4:-}" na="${5:-}" mark="ok" line
  if [ "$na" = na ]; then mark="n/a"
  elif [ -n "$cause" ]; then mark="$FAIL_MARK"; FAILING=$((FAILING + 1))
  fi
  line="$(printf '%-40s %-17s %-4s' "$rel" "$rule" "$mark")"
  if [ "$REPORT" = 1 ] && [ -n "$limit" ]; then line="$line  ($limit)"; fi
  if [ -n "$cause" ]; then line="$line  $cause"; fi
  printf '%s\n' "$line"
}

measure() {
  local f="$1" rel="$2"
  local facts h1=0 nano=0 l rest i n cause k class
  local sec_words=() sec_title=() nano_len=() nano_title=()

  # The class a file belongs to is resolved HERE, once, from its normalised path -- never from its
  # basename, which a file in the steering directory can borrow from either fixed file. Every
  # class-dependent rule below reads this result and derives its own class nowhere else.
  case "$rel" in
    .ai-flow/product.md)          class=product ;;
    .ai-flow/decisions-global.md) class=decisions ;;
    .ai-flow/steering/*)          class=steering ;;
    *)                             class=other ;;
  esac

  facts="$(awk "$AWK_READ" "$f")" || { say "unreadable: $rel"; FAILING=$((FAILING + 1)); return; }
  while IFS= read -r l; do
    case "$l" in
      "H1 "*)       h1="${l#H1 }" ;;
      "NANO "*)     nano="${l#NANO }" ;;
      "SEC "*)      rest="${l#SEC }";      sec_words+=("${rest%% *}"); sec_title+=("${rest#* }") ;;
      "NANOLINE "*) rest="${l#NANOLINE }"; nano_len+=("${rest%% *}");  nano_title+=("${rest#* }") ;;
    esac
  done <<< "$facts"

  # nano-present. When it fails, `nano-order` is not asked: there is no index to compare, and a second
  # verdict about the same absence reports one defect twice.
  if [ "$nano" = 1 ]; then verdict "$rel" nano-present ""
  else                     verdict "$rel" nano-present "no '## Nano' block"
  fi

  if [ "$nano" = 1 ]; then
    cause=""
    if [ "${#nano_title[@]}" != "${#sec_title[@]}" ]; then
      cause="the index holds ${#nano_title[@]} line(s) for ${#sec_title[@]} section(s)"
    else
      i=0
      while [ "$i" -lt "${#sec_title[@]}" ]; do
        if [ "${nano_title[$i]}" != "${sec_title[$i]}" ]; then
          cause="index line $((i + 1)) reads '${nano_title[$i]}' where the body reads '${sec_title[$i]}'"
          break
        fi
        i=$((i + 1))
      done
    fi
    verdict "$rel" nano-order "$cause"
  else
    verdict "$rel" nano-order "there is no index to measure" "" na
  fi

  # A nano line is a LOGICAL bullet, its indented continuations included. Measuring physical lines makes
  # the ceiling a function of the file's wrap width, so the same index passes at 100 columns and fails
  # at 80.
  if [ "$nano" = 1 ]; then
    cause=""
    i=0
    while [ "$i" -lt "${#nano_len[@]}" ]; do
      if [ "${nano_len[$i]}" -gt "$NANO_LINE_MAX" ]; then
        cause="index line $((i + 1)) runs ${nano_len[$i]} characters"
        break
      fi
      i=$((i + 1))
    done
    verdict "$rel" nano-line-length "$cause" "limit $NANO_LINE_MAX characters"
  else
    verdict "$rel" nano-line-length "there is no index to measure" "limit $NANO_LINE_MAX characters" na
  fi

  # The decision log is exempt from this rule ALONE: a decision's alternatives are the content that keeps
  # it from being re-argued, so there is no verdict to draw. Every other rule still answers for it. The
  # exemption is `n/a`, carrying that reason, rather than silence -- silence is the same lie a passing
  # verdict would tell, told the other way: a reader could not tell the exemption from a rule the check
  # forgot to ask.
  if [ "$class" = decisions ]; then
    verdict "$rel" section-length "this file is a record from end to end" "limit $SECTION_WORD_MAX words" na
  else
    cause=""
    i=0
    while [ "$i" -lt "${#sec_words[@]}" ]; do
      if [ "${sec_words[$i]}" -gt "$SECTION_WORD_MAX" ]; then
        cause="the section '${sec_title[$i]}' runs ${sec_words[$i]} words"
        break
      fi
      i=$((i + 1))
    done
    verdict "$rel" section-length "$cause" "limit $SECTION_WORD_MAX words"
  fi

  # The count bounds TOPIC sections, and the nano is not counted among the things it indexes. A section
  # that is a RECORD of a growing enumeration is not a topic: its number only ever rises, and no repair
  # this mechanism offers can lower it, so a ceiling over records is a ceiling nothing can ever meet.
  # `Rules: <key> — <topic>` is where `product.md` grows by design, so those sections do not count while
  # its fixed part does. The exemption is keyed on the CLASS resolved above and not on the title prefix:
  # the marker rule offers that title form to any class needing groups, so keyed on the title alone a
  # steering file of twenty `Rules:` sections would be uncountable -- a drawer, invisible to the one rule
  # whose job is catching a file that has become one. The decision log is records end to end — one `##`
  # per decision, with no retirement route anywhere in the mechanism — so the rule does not apply to it
  # at all, and the exemption is `n/a`, on the same terms as the section length above.
  if [ "$class" = decisions ]; then
    verdict "$rel" section-count "this file is a record from end to end" "limit $SECTION_MAX sections" na
  else
    n=0
    i=0
    while [ "$i" -lt "${#sec_title[@]}" ]; do
      case "$class:${sec_title[$i]}" in product:Rules:*) ;; *) n=$((n + 1)) ;; esac
      i=$((i + 1))
    done
    cause=""
    [ "$n" -gt "$SECTION_MAX" ] && cause="the file holds $n topic sections"
    verdict "$rel" section-count "$cause" "limit $SECTION_MAX sections"
  fi

  # A title that needs an application's name belongs in that application's file. The rule is the domain
  # layer's and polices steering files alone -- an application's own file may name itself there, and it
  # holds and says so. Neither fixed file is a domain file, so the rule was never asked of them: `n/a`,
  # not the vacuous `ok` a rule that never ran must not print.
  if [ "$class" = steering ]; then
    cause=""
    for k in $APP_KEYS; do
      owns_this_file "$k" "$f" && continue
      i=0
      while [ "$i" -lt "${#sec_title[@]}" ]; do
        if title_names_app "${sec_title[$i]}" "$k"; then
          cause="the title '${sec_title[$i]}' names the application '$k'"
          break
        fi
        i=$((i + 1))
      done
      [ -n "$cause" ] && break
    done
    verdict "$rel" app-key "$cause"
  else
    verdict "$rel" app-key "the domain-layer rule only polices steering files" "" na
  fi

  # One `#` is the title; every section boundary below it is `##`, which is what lets one command read
  # every class. A `###` inside a section is content and is not a boundary.
  if [ "$h1" = 1 ]; then verdict "$rel" marker ""
  else                   verdict "$rel" marker "the file carries $h1 top-level headings, not one"
  fi

  # reachable -- a directory-wide property, so it is asked only of the default survey, on the same terms
  # map_verdict already keys on. The argument form asks about the files it names, never about the map.
  if [ "${#ARGS[@]}" -eq 0 ]; then
    reachable_verdict "$rel" "$f" "$class"
  fi
}

# One verdict per map entry: the value resolves, from the CHECKOUT ROOT, to a file that exists.
#
# One base and no fallback. Trying `.ai-flow/` when the root finds nothing would make one string mean two
# things, and the two readers of it would never meet — which is the defect this verdict exists to end,
# not one to accommodate. So a value written under the other base does not resolve, and what the check
# owes the operator instead is a DIAGNOSIS: the file it can see, named beside the value, as a question.
# That is not the forgiving form wearing a report's clothes — the forgiving form resolves against two
# bases, this resolves against none and only says what it found.
#
# Three causes and not one, because they are three different mistakes and an operator reading `does not
# resolve` beside an empty value goes looking for a file that was never named.
#
# The row is printed through `verdict()` with the ENTRY in the column that otherwise holds a file: a map
# verdict has no file to be a verdict of, and a second printing path for one rule is the duplication this
# script's own one-home discipline refuses. A PASSING row names the key alone. The value rides only in a
# failing row's cause — a passing verdict that echoed the path would put a borrowed document into the
# output, and `reads only .ai-flow/` is the one thing this check's docstring promises about what it names.
map_verdict() {
  local k v cause cand
  # The lead first, because a map nothing could read is not a map with no entries. Reported as a FAILING
  # verdict rather than a note: the whole of this check's promise is that a declaration nobody resolved
  # cannot pass quietly, and a lead this parser does not take is a declaration nobody resolved.
  case "$(map_lead)" in
    unparsed)
      verdict "steering:<lead>" map-resolves \
        "the map's lead is neither a block mapping nor an empty flow mapping, so no entry was read at all" ;;
    unreadable)
      verdict "steering:<lead>" map-resolves \
        "the project declares a project.yml that cannot be read, so no entry was read at all" ;;
  esac
  while IFS="$(printf '\t')" read -r k v; do
    [ -n "$k" ] || continue
    cause=""
    if [ -z "$v" ]; then
      cause="the key is declared with no value"
    elif [ -d "$ROOT/$v" ]; then
      cause="'$v' names a directory, not a file"
    elif [ ! -f "$ROOT/$v" ]; then
      cause="'$v' does not resolve from the checkout root"
      cand="$DATA/steering/${v##*/}"
      [ -f "$cand" ] && cause="$cause; '${cand#"$ROOT"/}' exists -- did you mean that?"
    fi
    verdict "steering:$k" map-resolves "$cause"
  done <<MAPENTRIES
$(map_entries)
MAPENTRIES
}

# `reachable`: the rule this measures is protocols/context.md > Keeping > Reachable, and is not restated
# here.
#
# STEERING_MAPPED: every map value that resolves, from the checkout root, to a file under this project's
# steering directory -- read once, on the same "one scan" discipline APP_MAP already keeps.
STEERING_MAPPED=""
while IFS="$(printf '\t')" read -r k v; do
  [ -n "$k" ] || continue
  cand="$(normalise "$ROOT/$v")"
  case "$cand" in "$DATA"/steering/*) STEERING_MAPPED="$STEERING_MAPPED
$cand" ;; esac
done <<MAPENTRIES
$APP_MAP
MAPENTRIES

is_steering_mapped() {  # $1 = normalised absolute path
  printf '%s\n' "$STEERING_MAPPED" | grep -qxF -- "$1"
}

# A path token is bounded, never merely found. `title_names_app()` above bounds a bare key the same way
# on purpose; a path cannot reuse its class outright, because `.`, `/` and `-` are legitimate PARTS of a
# path where they are noise around a key. So the boundary set widens to match, with one refinement: a
# single trailing `.` is still a legitimate right edge (ordinary end-of-sentence prose, as the `hub.md`
# fixture pins with `...both.md.`) unless the character right after THAT dot is itself in the set -- which
# is what a hub naming its own backup (`....md.bak`) or superseded copy (`....md-old`) looks like, the
# false `reachable: ok` this bounds. Reads the operator's text -- the candidate's own path -- through
# `index()`, a literal substring search and never a pattern (the hazard hooks.md names).
path_bounded_match() {  # $1 = the literal path; $2 = the file to search
  awk -v t="$1" '
    BEGIN { tl = length(t) }
    tl == 0 { next }
    {
      line = $0
      start = 1
      while ((i = index(substr(line, start), t)) > 0) {
        pos = start + i - 1
        before  = (pos > 1) ? substr(line, pos - 1, 1) : ""
        after1  = substr(line, pos + tl, 1)
        after2  = substr(line, pos + tl + 1, 1)
        if (before  !~ /[A-Za-z0-9._\/-]/ \
            && after1 !~ /[A-Za-z0-9_\/-]/ \
            && !(after1 == "." && after2 ~ /[A-Za-z0-9_]/)) { found = 1; exit }
        start = pos + 1
      }
    }
    END { exit(found ? 0 : 1) }
  ' "$2"
}

# One hop, and the text matched is the OPERATOR'S -- a relative path, never built into a pattern (the
# hazard hooks.md names: text the operator wrote must never become a pattern).
is_pointer_reached() {  # $1 = candidate's path relative to ROOT
  local hub
  [ -d "$DATA/steering" ] || return 1
  for hub in "$DATA"/steering/*.md; do
    [ -e "$hub" ] || continue
    is_steering_mapped "$(normalise "$hub")" || continue
    path_bounded_match "$1" "$hub" && return 0
  done
  return 1
}

reachable_verdict() {  # $1 = file as displayed (rel); $2 = its normalised absolute path; $3 = its class
  if [ "$3" != steering ]; then
    verdict "$1" reachable "reached by construction, not a steering-directory file" "" na
    return
  fi
  # The map's own validity has one classifier, map_lead(), and this asks it rather than re-testing
  # readability on its own: a second test here previously called an unreadable-but-present project.yml
  # "no project.yml", which map_verdict()'s own case below already tells apart.
  case "$(map_lead)" in
    '')
      verdict "$1" reachable "no project.yml, so reachability cannot be derived" "" na
      return ;;
    unreadable)
      verdict "$1" reachable \
        "the project declares a project.yml that cannot be read, so reachability cannot be derived" "" na
      return ;;
    unparsed)
      verdict "$1" reachable \
        "the map's lead is neither a block mapping nor an empty flow mapping, so reachability cannot be derived" "" na
      return ;;
  esac
  if is_steering_mapped "$2" || is_pointer_reached "$1"; then
    verdict "$1" reachable ""
  else
    verdict "$1" reachable "no steering: map entry names it and no reachable file points at it"
  fi
}

scanned=0
i=0
while [ "$i" -lt "${#FILES[@]}" ]; do
  f="${FILES[$i]}"
  measure "$f" "${f#"$ROOT"/}"
  scanned=$((scanned + 1))
  i=$((i + 1))
done

# THE MAP VERDICT BELONGS TO THE SURVEY AND NOT TO THE REQUEST FORM. The argument form asks about the
# files it names; the map is a property of the project, and a run told to look at one file has not been
# asked about it. Called unconditionally it reached the three archive moves that pass a file by name
# (`protocols/backlog.md`, the `Verify` of the steering update and the two write-backs) and failed them
# over a declaration the move never wrote and cannot fix from where it stands — an adopter with one
# stale entry could land no context file at all. That is a second consequence beyond the one the
# contract disclosed, and it is not the one the operator accepted.
#
# It also keeps the summary honest without a second count: `FAILING` and `scanned` are only ever mixed
# on the flow where both the files and the map are in scope.
if [ "${#ARGS[@]}" -eq 0 ]; then map_verdict; fi

say "$scanned file(s) scanned, $FAILING failing"
[ "$FAILING" -eq 0 ]
