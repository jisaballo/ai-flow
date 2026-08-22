# CLAUDE.md — ai-flow

This repository *is* the engine: protocols, skills, hooks, the verify workflow, the installer, and the
template adopting projects receive. The rule below governs every change to any of it.

It lives here, and holds nothing else, for one reason — this is the file a session loads on its own, so
the rule sits in front of whoever proposes a change without anyone having to remember to fetch it. Stack,
apps and architecture sections are deliberately absent: describing the product is the domain model's job,
and a second copy of that map here would drift against the one the phases actually read.

## North Star

> Read this before proposing ANY change to the engine — protocols, skills, hooks, this file included.
> Every proposal must name the failure it prevents and pass the test below.

**ai-flow is a demanding requirements discipline sized for one person or a very small team.** It must
deliver requirements at the best quality standard while carrying none of the ceremony that exists only to
coordinate large teams or big companies. Removing or rewriting what already exists is always on the table.

"Lightweight" and "demanding" are not a trade-off — they cut along different lines:

- **Rigor is kept** when a rule exists because the *model* fails: it assumes, negotiates tests toward
  green, commits scope creep, runs away in LOC, produces plausible-but-false findings. These rules are
  craft; they are why the output is polished.
- **Weight is cut** when a rule exists because an *organization* needs to coordinate: handoffs, rosters,
  notarial prose, "who writes what and when". With one operator, the coordinator and the coordinated are
  the same brain.
- A third source, easy to misclassify: **a human working alone forgets**. Rules that catch that (e.g. the
  Icebox, derived checks) are craft too — but they must be cheap.

**Cost ladder for additions:** a *derived check* (computed from data the flow already has) costs
~nothing; a *field* in an existing artifact is cheap; a *new step, gate, or artifact* is expensive and
must clear a high bar.

**Non-goals:** enterprise coordination features; multi-agent portability. Each carries its reason, because
a refusal stated without one is the refusal that gets re-argued a year later:

- *Enterprise coordination features* — with one operator there is nobody to hand off to. A rule whose
  only job is to keep several people in step is pure weight here.
- *Multi-agent portability* — ai-flow is Claude-Code-native by choice. Its value is the depth of that
  integration (skills, hooks, workflows, subagents, memory), and abstracting for N agents would dilute
  precisely what makes it worth using.
