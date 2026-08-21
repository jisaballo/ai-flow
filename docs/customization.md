# Customization Guide

ai-flow is designed to be adapted to your project, stack, and workflow preferences.

## What to Customize

### Project CLAUDE.md (required)

The project `CLAUDE.md` tells Claude Code about your specific tech stack. This is the most important file to customize.

**Key sections to fill in:**
- **Stack**: Your framework, language, database, and key libraries
- **Apps**: Your applications and their types (web, mobile, API, etc.)
- **Architecture**: How your code is organized, import rules, layer patterns
- **Commands**: Build, test, lint, deploy commands
- **Pre-commit**: Hooks that run on git commit

### Project layer — `project.yml` (required)

ai-flow ships a **generic, stack-agnostic core** (protocols, phase skills, hooks). Everything specific to your repo lives in a thin **project layer** so the core never needs editing. The structured part of that layer is `.ai-flow/project.yml` — the single source the phase skills read for the values they interpolate:

```yaml
name: my-project
area_kind: package          # what an "area" means here: app | domain | package | service
source_dirs:                # verify scopes changed files to these
  - src
# front_tool: "<tool>"      # optional, TOP-LEVEL — the tool this project is managed in; the opening
                            # ceremony identifies it before it creates a front. Absent, the native
                            # worktree path is used and the ceremony says so
commands:
  test: "npm test"          # use {area} when the command is scoped, e.g. "npx nx test {area}"
  lint: "npm run lint"
  build: "npm run build"
# distribute: "..."         # optional — a key UNDER commands: what puts merged work into effect
                            # (publish/deploy/reinstall); absent, the close's distribution move is a
                            # stated no-op
steering:                   # area -> steering file the verify phase loads
  auth: steering/auth.md
```

**Why it exists:** without it, the skills would have to guess your test command from CLAUDE.md prose, so people hardcode their stack into the skills and the framework drifts. `project.yml` makes one generic skill as reliable as a hardcoded one.

**Authority:** `project.yml` is authoritative for commands. CLAUDE.md may list commands in prose for humans — keep them consistent; the skills trust `project.yml`.

**Fallback:** if `project.yml` is absent, the skills infer values from CLAUDE.md (legacy behavior), so older projects keep working.

### Product Context (recommended)

`.ai-flow/product.md` provides business context that helps Claude make better decisions. Especially important for:
- New epics (groups of related tasks)
- Tasks that involve business logic
- UI/UX decisions

### Steering Files (optional, high-value)

Steering files in `.ai-flow/steering/` contain domain-specific knowledge that prevents recurring mistakes.

**Structure:**
```markdown
# Domain: [Name]

## Rules
- [Hard rules that must always be followed]

## Patterns
- [Established patterns in this domain]

## Pitfalls
- [Common mistakes and how to avoid them]
```

**When to create one:**
- You've corrected Claude on the same domain-specific issue more than once
- A domain has non-obvious constraints (security, compliance, performance)
- There are established patterns that differ from framework defaults

**Examples of good steering file topics:**
- Authentication (token handling, session management)
- Payments (idempotency, error handling, refund flows)
- Database (migration patterns, naming conventions, indexing rules)
- API design (versioning, error formats, rate limiting)

### Parallel workstreams — `.worktreeinclude` + `worktree.baseRef` (optional)

Two files decide how a second working copy of the project is born. Both are created by
`./install.sh init` and never overwritten if you already have your own.

**`.worktreeinclude`** (repo root) lists what a linked worktree receives that git would otherwise
leave behind. It uses gitignore syntax, and only untracked-and-ignored paths are eligible —
anything tracked already travels with the checkout, so naming it there does nothing. The shipped
set carries project **data** and deliberately leaves the ledger behind:

```
.ai-flow/project.yml
.ai-flow/product.md
.ai-flow/steering/
.ai-flow/codebase/
.ai-flow/artifacts/
```

**The precondition, stated plainly**: this only takes effect for paths your repository *ignores*.
If `.ai-flow/` is not in your `.gitignore`, none of these patterns is eligible and a new worktree is
still born without them — and the seeding step below **refuses** rather than reporting a success it
did not achieve, naming this and stale patterns as the two things to go and check. If instead you
commit `.ai-flow/`, git carries the **whole** directory into every worktree — backlog, state, decision
log and archive included — which is the opposite of what the pattern file is for. That layout still
seeds successfully: git has already carried the data, so selecting nothing to copy is the right answer
there and the step only has the papers to strip. In that layout the single-writer rule for the ledger is held by convention
rather than by the tool, so decide which way you want it before relying on either. The installer does
not edit your `.gitignore`; that is your project's call.

Do not broaden the patterns casually. Everything they match is **ignored** content, which is exactly
where credentials, tokens and local environment files live — a pattern like `.env*` or a bare `*.json`
would copy those into every worktree the tool creates, including the ones agents open on their own.
Name the paths you mean.

`BACKLOG.md`, `STATE.md`, `decisions-global.md` and `archive/` are absent on purpose: the primary
checkout is their single writer, and a second copy that could edit them would race it. The engine
is absent too — protocols, skills and hooks live in `~/.claude` and reach every worktree without
being copied.

Two properties worth knowing before you rely on it. The transfer is a **copy taken once**, at
creation: it goes stale the moment either side changes, so treat it as a snapshot rather than a
shared folder. And it applies to **every** worktree the tool creates, including the isolated ones
agents open for themselves — cheap for text files, but not something you opt into per workstream.

**`worktree.baseRef`** (in `.claude/settings.json`) decides which commit a new worktree is cut
from. The shipped value is `fresh`, which branches from `origin/<default>` — the **published**
default branch, not your local one. The consequence is worth stating plainly: work you have
committed but not pushed does not exist for a new worktree. Publishing the default branch is part
of opening a workstream. The alternative, `head`, branches from your local `HEAD` and carries
unpushed commits along with whatever else is sitting in that checkout.

Projects installed before these files existed receive them by re-running `./install.sh init`;
`update` never writes into a project, by design.

**Start by identifying the tool this project is managed in.** That is the opening ceremony's first act,
and `front_tool` above is where the answer lives — read it before you decide anything, because the
decision may already be made there. The tool you declare is the default — preferred
wherever it can satisfy the conditions below, with whatever it does not bring completed by hand.
Declare nothing and the ceremony uses Claude Code's own worktree path and tells you that is what it
did, rather than leaving you to assume it.

The reason the order matters: the four conditions are all facts your repository can answer, and the
surface *you* work in is not one of them. A checkout can satisfy every condition on the list and still
be a front you never see — which is why the tool comes first and the conditions are checked on the
result.

**Any tool may create the worktree.** ai-flow requires no particular front-end: what it requires is a
checkout satisfying four conditions, and the opening ceremony checks them on the result rather than
trusting the tool that produced it.

They are not symmetric across tools, so each one below says who pays for it. But what your tool actually
brings is **read from the checkout it produced, never from its documentation** — a tool that never
mentions `.worktreeinclude` may still honour it, and one version may differ from the next. The
attributions below say where each condition usually comes from; look at the checkout to see what
arrived.

1. **Base** — the branch starts from the **published default branch**, which is what `worktree.baseRef`
   above governs on the native path. Any other tool takes it on **by hand**: name the base ref
   explicitly when you create the checkout.
2. **Data** — the checkout holds what `.worktreeinclude` declares travels, and **only the papers** of
   the task it owns. The native path brings the first half without help; whether another tool does is
   per-tool and per-version, so look before you seed and take it on by hand only for what is missing —
   the seeding mechanism below leaves alone whatever is already there, with the one exception below.
   The pruning half is run on every path regardless: a copy taken at creation is a snapshot, and it can
   arrive holding papers of tasks this front does not own — and, being a snapshot, it can also arrive
   holding a version of the papers that has since moved on.
3. **Visibility** — the coordinator's audit cannot see the checkout. Outside your project folder that
   holds by itself; inside it, only where your ignore rules cover the path. This one is **per-tool** —
   which of the two cases you are in depends on where your tool puts the checkout.
4. **Ownership** — whatever created the checkout removes it. A tool that keeps its own registry of
   worktrees is left pointing at one something else deleted. This one holds on **every path** and is
   free on none.

Claude Code's own tooling — `EnterWorktree`, `claude -w`, an agent's `isolation: worktree` — is the
**floor**: what the ceremony falls back to and the yardstick the rest are measured against, not the
first choice. It meets condition 1, and it brings the data of condition 2 without help. It does not finish
condition 2 on its own — it copies the papers of *every* open task, so the pruning step below is run on
this path too. It creates the worktree **inside** `.claude/worktrees/`, so with
it condition 3 is your ignore rules' job: add `/.claude/worktrees/` to your `.gitignore` (this
repository does). Left out, that checkout is untracked content inside your project, and the review's
own before/after comparison then runs over a second working copy something else is writing.

For a front-end that carries no project data — a plain `git worktree add`, or any tool that knows
nothing of `.worktreeinclude` — the engine ships the mechanism that satisfies condition 2:

```
~/.claude/ai-flow/scripts/seed-front.sh <checkout> <T-XXX>
```

It reads your pattern file, copies what that selects, and removes the papers of every task except the
ones you name. Name more than one when the front is working more than one — `seed-front.sh <checkout>
<T-XXX> [T-YYY ...]` — because that list is what stops a re-run from deleting a paused task's papers,
and those extra ones are never overwritten either.

One thing it does replace: **the papers of the task it is seeded for**, the first id you give it. A copy
taken when the checkout was created is a snapshot, and the sheet that says which task the checkout is on
is written *after* that — so without the replacement a front born holding an older version of those
papers keeps it forever, and the reader that looks for its task there answers with a dead branch or, worse,
with the wrong phase. It is the same exception the closing collection has, read from the other side: the
authoritative copy is the one from the checkout where the task was worked, and a front that has not
worked it yet holds none.

Which is why it stops where it cannot tell. If any of those papers in the checkout was written **after**
your own copy of it, that front is working the task and its copy is the authoritative one: nothing of
that task is replaced and the run **refuses**, naming both copies. To take your copy instead, delete the
front's folder for that task and run it again. Run it from anywhere in the repository: it resolves your
primary checkout from git's own worktree listing, not from wherever it was invoked. Where your pattern
file matches nothing in the repository at all — neither an ignored path nor a tracked one — it strips the
papers and then **refuses**, rather than reporting a success it did not achieve; that is the precondition
above, and the refusal names it.

When the tool you declared cannot satisfy a condition and nothing completes it, the ceremony falls back
to the floor — and that costs you something the four conditions cannot express: your own view of the
front. So the opening **stops**, and resumes only once the fallback is **acknowledged in writing on the
task's sheet**, naming the condition that could not be satisfied and why going ahead without that view
is acceptable. It is the same
acknowledgement the ceremony already asks for when two fronts collide, and for the same reason: a loss
it chooses is a loss somebody decided.

## What NOT to Customize

### Protocols

The protocols installed at `~/.claude/ai-flow/protocols/` are the framework core. Never edit the installed copies — a drift-check hook will flag it. If you need different behavior:
1. Change them in your clone of the ai-flow repo, as a task like any other — putting the committed
   change into effect is a move of the close, not a step you have to remember (see `## Closing a
   Workstream` in the backlog protocol)
2. Use steering files for domain-specific rules instead
3. Use the global CLAUDE.md for workflow preferences

### Lifecycle phases

The phase order (understand → plan → conform → execute → verify) is intentional. Each phase depends on the previous one's output. Skipping phases leads to the same problems ai-flow was designed to prevent.

## Adapting Commands

The global CLAUDE.md includes command keywords that trigger phases. You can customize these in the `### Phase Orchestration` and `### Quick Commands` sections.

**Default commands** (English):
- "add to backlog", "work on T-XXX", "quick:", "continue", "status", "pause"

**Example: Spanish commands**:
```markdown
### Phase Orchestration
| Command | Action |
|---------|--------|
| `continue` / `continua` | Resume the task this checkout owns, from that task's own sheet |
| `status` / `estado actual` | Show current state |

### Quick Commands
- **Add task**: "agrega al backlog: [description]"
- **View backlog**: "muestrame el backlog"
- **Start task**: "trabaja en T-XXX"
```

## Adapting Commit Messages

The default commit format is `type(scope): description`. Customize in the Commit Protocol section of your global CLAUDE.md if your team uses a different convention.

## Team Adoption

When onboarding team members:

1. They run `./install.sh init` in the shared project (creates the `.ai-flow/` data skeleton; the engine — protocols, skills, workflow, hooks — installs into their `~/.claude`)
2. They customize the `## Personal Preferences` section of their `~/.claude/CLAUDE.md`
3. Steering files, product.md, `project.yml`, and project CLAUDE.md are shared via git

To pull framework improvements on any device later, run `./install.sh update` (unattended): it refreshes the engine in `~/.claude` — protocols, skills, the verify workflow, hooks, the ceremony scripts, and the ralph runner — and never writes into any project.

**What's shared** (committed to repo):
- `.ai-flow/product.md` — product context
- `.ai-flow/steering/` — domain rules
- `CLAUDE.md` — project configuration

**What's personal** (in `~/.claude/`):
- `CLAUDE.md` — framework rules + personal preferences
- Language, response style, custom commands

**What's ephemeral** (gitignored or not committed):
- `.ai-flow/artifacts/` — active work (consider gitignoring)
- `.ai-flow/STATE.md` — the roster of open workstreams (consider gitignoring)
- `.ai-flow/archive/` — completed work (commit or gitignore, your choice)
