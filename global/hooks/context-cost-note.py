#!/usr/bin/env python3
"""Stop hook (ai-flow only): says once, without ever blocking, that the session has grown expensive
enough that cutting it pays -- and names the two things a cut destroys.

Why this exists at all. Measured over 285 transcripts: cache-read is ~70% of the price-weighted bill,
and cache-read IS context size x turns, so what a turn *does* barely moves its cost -- only how much
context it drags. Sessions of 150 turns or more are 95.7% of this engine's own repository's bill.
Simulated on each session's real per-turn curve with re-caching priced in, restarting every 150 turns
saves 24.3% there and 32.9% on the project the engine is used to build. Those are the corrected figures:
an earlier estimate of 51.3% came from a model that restarted from zero context, and there is no such
thing -- turn 1 already costs 43-47k for the system prompt, the project's own instructions and the tool
definitions. That floor is why the honest number is a quarter to a third, not a half, and it is the
number this hook is worth keeping for.

Why it recommends instead of refusing. Its three siblings at this event exit 2, which stops the turn
from ending. Blocking mid-Execute costs more than the tokens it saves, so this one exits 0 on every
path -- and that choice decides the channel, because a Stop hook that exits 0 has its stderr discarded
by the harness. A message written to stderr here would reach nobody. The one channel that carries a
message without blocking is a top-level `systemMessage` on stdout, which is what this writes.
"""
import sys, json, os, glob, re

FIRST, SECOND = 150, 300

# The note's own text is the mark that says it has already spoken. What makes reading it back possible is
# that the harness records a delivered systemMessage into the session's own transcript, in two independent
# records: the hook_system_message it becomes, and the verbatim stdout kept beside the hook's exit status.
# So the mark needs no sentinel file -- no path to choose, no scope to decide between session and
# checkout, nothing left behind to clean up.
#
# It is read ONLY out of those two records, and that restriction is the whole of what makes the mark
# mean anything. An unanchored search of the file counts every OTHER way the text can arrive: a user who
# names it, an assistant that quotes it, a tool result that greps it. The engine's own conformance suite
# holds both marks verbatim, and that file is the Verify command of every step of every task here -- so
# under a text search the first session to read it would mark both thresholds as already spoken and the
# note would never fire again, in the one repository whose transcripts the thresholds were fitted on.
# It fails silent, which is the direction that leaves nothing to find it by. Reproduced live before this
# was written: a session 248 turns long, no note ever delivered, silenced by one line of its own
# tool output.
#
# So the mark is anchored to its record the way `phase:` and `branch:` are anchored to the start of their
# line: the same rule this engine already states for the sheet's declarations and for the write guard,
# where a later line quoting the field is an example and never the declaration.
MARK = "ai-flow context note [%d]"
# The two records the harness itself writes when it delivers a hook's message. Nothing a session says
# can forge either one: they are the harness's account of a hook having run, not text in a conversation.
DELIVERY = ("hook_system_message", "hook_success")


def note(threshold: int, turns: int, seen) -> str:
    # What the note claims about its own history has to be true, and the firmer one cannot assume it
    # follows the softer. A session that meets this hook already past the second threshold -- every
    # session in flight on the day it is installed, and any that ran a stretch with no readable
    # transcript -- hears the firmer note as the FIRST thing it hears. Saying "the second and last time"
    # there is a message that misdescribes the conversation the operator just had, which is exactly the
    # kind of thing that teaches someone to stop reading it. Observed on a live 318-turn session before
    # this was written.
    if threshold != SECOND:
        firmer = ""
    elif FIRST in seen:
        firmer = "This is the second and last time this is said. "
    else:
        firmer = "This is said once, and not again. "
    return (
        f"{MARK % threshold} — {turns} model turns in. {firmer}"
        "Cutting the session here is now worth roughly a quarter to a third of what the rest of it "
        "would cost, because almost the whole bill is the accumulated context being re-read every turn. "
        "Cut at the NEXT PHASE BOUNDARY, not now: the handoff artifact already exists there, so the cut "
        "costs nothing extra. Before cutting, write to the task's sheet the two things a cut destroys "
        "and nothing else records — under `## Ruled out`, a `hypothesis:` line for anything tested and "
        "killed, and an `alternative:` line for any route considered and rejected, with its reason. "
        "Decisions taken are already on the sheet; these two are not, and they are what a session takes "
        "with it when it ends."
    )


def transcript_for(payload, cwd):
    """The path the session names, else the newest record for this working copy.

    The declared path is the primary and was measured present on every Stop payload; the fallback is
    there because a gap in it must cost a missed note and never a wrong one, and a hook that gave up at
    the first absent key would go silent for a whole session without saying so."""
    p = payload.get("transcript_path")
    if isinstance(p, str) and os.path.isfile(p):
        return p
    slug = re.sub(r"[^A-Za-z0-9]", "-", cwd)
    found = glob.glob(os.path.join(os.path.expanduser("~/.claude/projects"), slug, "*.jsonl"))
    return max(found, key=os.path.getmtime) if found else None


def read(path):
    """One pass, returning the main-loop turn count and which marks already stand.

    Turns are counted as assistant records carrying `usage`, which is the same quantity the thresholds
    were fitted on. Records marked isSidechain are skipped: a subagent's turns do not sit in this
    session's context, so they are not what makes the next turn expensive -- and counting them would
    fire the note on a session that never actually grew. They are a rounding error in any case, measured
    at 1.2% of the bill, and they live in their own files rather than in this one.

    A line that will not parse is skipped rather than fatal. A transcript is written while it is being
    read, so its last line can be half-flushed, and a hook that raised there would go silent for the
    rest of the session -- silent on a session that is, by construction, a long one."""
    turns = 0
    seen = set()
    with open(path, errors="replace") as fh:
        for line in fh:
            try:
                rec = json.loads(line)
            except Exception:
                continue
            if not isinstance(rec, dict):
                continue
            att = rec.get("attachment")
            if isinstance(att, dict) and att.get("type") in DELIVERY:
                # Only the harness's own delivery records are read, and only their message-bearing
                # fields -- `content` for the delivered message, `stdout` for the verbatim output kept
                # beside the exit status. Anything else in the file is a session talking about the mark.
                spoken = "%s%s" % (att.get("content") or "", att.get("stdout") or "")
                for t in (FIRST, SECOND):
                    if MARK % t in spoken:
                        seen.add(t)
                continue
            if rec.get("isSidechain") or rec.get("type") != "assistant":
                continue
            # The record type is checked and not merely assumed. Measured across 60 real transcripts:
            # 11,738 records carry `message.usage` and every one of them is an assistant record. Reading
            # `usage` alone happens to give the same count today, and would silently inflate it the day
            # any other record shape starts carrying the field -- firing the note early on a session
            # that never grew, which is the wrong direction for this hook to fail in.
            msg = rec.get("message")
            if isinstance(msg, dict) and msg.get("usage"):
                turns += 1
    return turns, seen


def governs(cwd: str) -> bool:
    """Whether an engine data directory governs this working directory.

    Walked upward, because a session sitting in a subdirectory is still inside its project -- and
    **stopped at the checkout boundary**, which is the unit every hook in this directory judges by.
    Unbounded, the climb reaches the filesystem root, so a working copy with no engine data of its own,
    sitting anywhere beneath one that has it, would receive a note pointing at a sheet it does not have.
    That is a wrong note, and a wrong note is the one direction this hook must never fail in -- every
    other gap here costs a note that does not arrive, which is harmless.

    Where nothing marks a checkout at all -- no repository anywhere above -- there is no boundary to
    respect and the climb runs to the root. That is not a fallback so much as the same rule with its
    limit absent: the question is about an engine data directory, and it still has an answer where
    version control has none.

    The boundary is found by looking for the marker on the way up, and NOT by asking git. The sibling
    hooks shell out to `rev-parse --show-toplevel` and are right to -- they act on what git reports,
    where this one needs a single directory name and the nearest ancestor holding the marker IS the
    checkout root. Measured rather than argued, and the first version of this note had the numbers
    wrong: the subprocess costs 14.6 ms, the walk 0.015 ms, and neither is what this hook spends --
    interpreter startup is ~287 ms on the machine this was written on and parsing a 3.4 MB transcript is
    13 ms. So the walk is not a performance fix and must not be recorded as one; it is one fewer moving
    part for a question that never needed a process. What the startup figure does say is that this hook's
    cost is the floor every Python hook at this event already pays, and that no amount of care inside it
    moves that -- which is worth knowing before anyone optimises the wrong half.
    Checked with `exists` and not `isdir` on purpose: a linked worktree's marker is a file.
    """
    probe = os.path.abspath(cwd)
    while True:
        if os.path.isdir(os.path.join(probe, ".ai-flow")):
            return True
        if os.path.exists(os.path.join(probe, ".git")):
            return False  # a checkout of its own, with no engine data: not this engine's business
        parent = os.path.dirname(probe)
        if parent == probe:
            return False
        probe = parent


def _run():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return  # a payload this hook cannot read is not a session it may judge
    if not isinstance(payload, dict):
        return
    if payload.get("stop_hook_active"):
        return  # the stop is already being re-delivered; speaking again would only be louder

    cwd = payload.get("cwd") or os.getcwd()
    if not isinstance(cwd, str):
        return
    if not governs(cwd):
        return

    path = transcript_for(payload, cwd)
    if not path:
        return
    try:
        turns, seen = read(path)
    except Exception:
        return  # every gap falls on the side of no note; a false one is the failure that matters

    # The note is about the level the session has REACHED, and only that level is ever spoken. Written as
    # a search for any unspoken threshold, it had a defect that broke the hook's whole premise: a session
    # arriving past the second threshold without having been told got the firmer note -- which ends "this
    # is the second and last time this is said" -- and then, on the very next turn close, got the SOFTER
    # one, because the first threshold's mark had never entered the transcript. Two notices in two
    # consecutive closes, in descending firmness, one of them contradicting the other in writing. It is
    # reachable the day the hook is installed, since every session already in flight meets it at whatever
    # length it has reached, and again after any stretch where the transcript could not be read.
    #
    # Naming the level instead of scanning for gaps removes the case rather than guarding it: a threshold
    # the session has already passed is never revisited, so there is nothing left for a lower note to
    # come back through.
    crossed = SECOND if turns >= SECOND else (FIRST if turns >= FIRST else None)
    if crossed is not None and crossed not in seen:
        print(json.dumps({"systemMessage": note(crossed, turns, seen)}))


def main():
    """Exiting 0 is the promise, so it is made once here rather than at each return.

    Written as a promise per path it was only as true as the enumeration of paths: three calls sat
    outside every guard -- resolving the working directory, globbing the fallback and stat-ing its
    candidates, and the write to stdout itself -- and each raises for reasons this hook does not control
    (a working directory deleted under a running session, a transcript rotated away between the glob and
    the stat, a closed pipe). An uncaught raise here leaves a non-zero status, and a non-zero status at
    this event stops the operator's turn from ending: the one thing this hook exists not to do. Guarding
    the outside makes the invariant structural instead of enumerated -- there is no path left to forget.
    """
    try:
        _run()
    except Exception:
        pass
    sys.exit(0)


main()
