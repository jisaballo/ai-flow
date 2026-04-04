# ai-flow

A structured task management framework for AI-assisted software development with [Claude Code](https://claude.ai/code).

ai-flow brings discipline to AI-powered coding sessions: every task follows a repeatable lifecycle with understanding, planning, test-driven execution, and verification phases. It's designed for developers who want predictable, high-quality output from their AI assistant.

## Why ai-flow?

Working with AI coding assistants can feel chaotic — tasks drift in scope, context gets lost between sessions, and quality varies wildly. ai-flow solves this with:

- **Structured lifecycle**: Every task flows through defined phases with gates between them
- **Context preservation**: Session state, decisions, and artifacts persist across conversations
- **Test-driven execution**: Code changes are validated at every step, not just at the end
- **Autonomy levels**: Choose how much supervision the AI needs per task
- **Quality verification**: LLM-as-Judge audit ensures criteria are met with evidence

## Quick Start

### Option 1: Install script

```bash
curl -sL https://raw.githubusercontent.com/YOUR_USER/ai-flow/main/install.sh | bash
```

Or clone and install locally:

```bash
git clone https://github.com/YOUR_USER/ai-flow.git
cd ai-flow
./install.sh /path/to/your/project
```

### Option 2: Manual setup

1. Copy `template/.ai-flow/` into your project root
2. Copy `template/CLAUDE.md` to your project root and customize for your stack
3. Copy `global/CLAUDE.md` to `~/.claude/CLAUDE.md` (or merge with existing)

### Post-install

1. Edit `CLAUDE.md` in your project — fill in your stack, apps, commands, and architecture
2. Edit `.ai-flow/product.md` — describe your product, users, and core flows
3. Optionally create steering files in `.ai-flow/steering/` for your domains

## How It Works

### Task Lifecycle

```
CAPTURE → PRIORITIZE → ACTIVATE → UNDERSTAND → PLAN → CONFORM → EXECUTE → VERIFY → ARCHIVE
```

| Phase | What happens |
|-------|-------------|
| **Capture** | Add task to backlog with description |
| **Prioritize** | Set priority and mark ready |
| **Activate** | Load into STATE.md as the active task |
| **Understand** | Decompose, investigate, ask questions, write requirements |
| **Plan** | Create max 3-step execution plan with verify commands |
| **Conform** | Generate failing test stubs from requirements (TDD red phase) |
| **Execute** | Implement changes, make tests pass (TDD green phase) |
| **Verify** | Criterion-by-criterion audit with evidence |
| **Archive** | Store summary, clean up artifacts |

### Execution Paths

| Path | When | Phases |
|------|------|--------|
| **Full** | >2 files or ambiguous scope | understand → plan → conform → execute → verify |
| **Quick** | ≤2 files, clear scope | inline plan → execute |

### Autonomy Levels

| Level | When | Behavior |
|-------|------|----------|
| **Auto** | Bug fixes, mechanical refactors | Minimal gates, auto-commit if tests pass |
| **Guided** | New features, moderate scope | All gates, user approves plan before execution |
| **Supervised** | Schema changes, new domains | All gates + per-step approval during execution |

## Commands

Talk to Claude Code naturally. These commands are recognized:

| Command | Action |
|---------|--------|
| `"add to backlog: [description]"` | Capture a new task |
| `"work on T-XXX"` | Activate and start understanding |
| `"quick: [description]"` | Quick path — skip backlog, execute directly |
| `"continue"` | Resume from saved state |
| `"status"` | Show current task state |
| `"understand"` | Run understanding phase |
| `"plan"` | Run planning phase |
| `"execute"` | Run execution phase |
| `"verify"` | Run verification phase |
| `"pause"` | Save session state |
| `"map codebase"` | Run lightweight codebase analysis |

## Project Structure

```
your-project/
├── CLAUDE.md                    # Project-specific instructions (your stack, commands, architecture)
├── .ai-flow/
│   ├── BACKLOG.md               # All tasks with status and priority
│   ├── STATE.md                 # Current session context
│   ├── decisions-global.md      # Cross-task decisions
│   ├── product.md               # Product context (users, roles, flows)
│   ├── protocols/               # Phase-specific protocols (the framework core)
│   │   ├── understand.md
│   │   ├── plan.md
│   │   ├── execute.md
│   │   ├── verify.md
│   │   ├── quick-path.md
│   │   ├── backlog.md
│   │   └── codebase-mapping.md
│   ├── steering/                # Domain-specific rules and patterns
│   ├── artifacts/               # Active task work (understand.md, plan.md)
│   ├── archive/                 # Completed task summaries
│   └── codebase/                # Codebase analysis (concerns, testing, drift)
```

## Customization

### Steering Files

Create domain-specific guidance in `.ai-flow/steering/`. These are loaded automatically when a task affects that domain.

```markdown
# Domain: Authentication

## Rules
- Always use the AuthService facade, never access Firebase Auth directly
- Session tokens must be httpOnly cookies, never localStorage

## Patterns
- Login flow: Component → Facade → Effect → Firebase Auth → Redirect

## Pitfalls
- Firebase Auth state listener fires on every tab focus — debounce it
```

See `examples/` for more steering file examples.

### Project CLAUDE.md

The project `CLAUDE.md` tells Claude Code about your specific stack. See `template/CLAUDE.md` for a starting template and `examples/` for stack-specific examples.

### Global CLAUDE.md

The global `~/.claude/CLAUDE.md` contains the ai-flow framework rules (lifecycle, phases, commands) plus your personal preferences. See `global/CLAUDE.md`.

## Documentation

- [Getting Started](docs/getting-started.md) — Step-by-step setup guide
- [Lifecycle Deep Dive](docs/lifecycle.md) — Detailed explanation of each phase
- [Customization Guide](docs/customization.md) — Adapting ai-flow to your workflow

## Requirements

- [Claude Code](https://claude.ai/code) CLI or IDE extension
- A git repository (ai-flow uses git for commits and state)

## License

MIT
