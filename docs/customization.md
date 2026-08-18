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
commands:
  test: "npm test"          # use {area} when the command is scoped, e.g. "npx nx test {area}"
  lint: "npm run lint"
  build: "npm run build"
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

## What NOT to Customize

### Protocols

The protocols installed at `~/.claude/ai-flow/protocols/` are the framework core. Never edit the installed copies — a drift-check hook will flag it. If you need different behavior:
1. Change them in your clone of the ai-flow repo (commit), then run `./install.sh update`
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
| `continue` / `continua` | Resume from STATE.md |
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

To pull framework improvements on any device later, run `./install.sh update` (unattended): it refreshes the engine in `~/.claude` — protocols, skills, the verify workflow, hooks, and the ralph runner — and never writes into any project.

**What's shared** (committed to repo):
- `.ai-flow/product.md` — product context
- `.ai-flow/steering/` — domain rules
- `CLAUDE.md` — project configuration

**What's personal** (in `~/.claude/`):
- `CLAUDE.md` — framework rules + personal preferences
- Language, response style, custom commands

**What's ephemeral** (gitignored or not committed):
- `.ai-flow/artifacts/` — active work (consider gitignoring)
- `.ai-flow/STATE.md` — session state (consider gitignoring)
- `.ai-flow/archive/` — completed work (commit or gitignore, your choice)
