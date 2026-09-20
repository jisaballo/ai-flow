# AGENTS.md — ai-flow

This repository *is* the engine: protocols, skills, hooks, the verify workflow, the installer, and the
template adopting projects receive. The direction below governs every change to any of it, and it lives
here because this is the file a session loads on its own. Stack and architecture notes stay out — this
file holds direction and nothing else.

## North Star

> Read this before proposing any change to the engine, this file included. A change that cannot be
> argued from the direction below does not belong, however good it looks on its own.

**ai-flow exists to produce the best code that can be maintained and scaled over time, at a reasonable
cost and at an acceptable speed.**

**Quality is the objective.** Architecture, simplicity, readability: code a stranger can change a year
from now without fear. Everything else here serves that, and nothing here may trade it away.

**Cost and speed are the budgets that keep quality honest.** Unbounded, the pursuit of quality becomes
the pursuit of perfection, and what is perfect but unaffordable never ships — which is worth nothing at
all. The budgets never lower the bar: when one is reached, the work gets smaller, not worse.

**The discipline is the method, never the purpose.** Phases, gates and artifacts exist because they make
code better within those budgets, and each must be able to say which pillar it serves. Internal
coherence, symmetry and completeness justify nothing on their own. An engine that improves itself faster
than it improves the code it produces has lost the thread.

**A rule must outlive whoever is running it.** Quality that depends on one tool stops the day the tool
moves, so nothing here may depend on a particular model, a particular harness, or a particular number of
people: the discipline has to hold for any competent model, survive being carried to another tool, and
read the same for one person and for a team. Where it does not yet, that is debt to be paid down, not a
property to be defended.

**Coordination is not an end in itself.** Reporting, allocation and ceremony that exists so that people
can be seen to be in step spend both budgets and improve no code. Coordination that makes the work
better — a second pair of eyes on a change — is method, and earns its place like anything else.

**This file states intention and holds nothing that can go out of date.** Mechanisms, measurements and
the reasons behind past decisions live where they are performed and where they are recorded.
