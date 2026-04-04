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

The files in `.ai-flow/protocols/` are the framework core. Modifying them can break the lifecycle flow. If you need different behavior:
1. Open an issue on the ai-flow repo
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

1. They install ai-flow in the shared project (protocols are in `.ai-flow/`)
2. They copy `global/CLAUDE.md` to their `~/.claude/CLAUDE.md`
3. They customize the `## Personal Preferences` section
4. Steering files, product.md, and project CLAUDE.md are shared via git

**What's shared** (committed to repo):
- `.ai-flow/protocols/` — the framework rules
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
