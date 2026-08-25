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

Underneath those five, one thesis: **ai-flow is a demanding requirements discipline sized for one person or a very small team.** It aims at the best quality standard a spec-driven flow can reach while carrying none of the ceremony that exists only to coordinate large teams. Rigor is kept wherever a rule exists because the *model* fails — it assumes, negotiates tests toward green, lets scope creep in; weight is cut wherever a rule exists only to keep several people in step, because with one operator the coordinator and the coordinated are the same brain.

Two things it deliberately is **not**: enterprise coordination features, and multi-agent portability. The first because with nobody to hand off to, a rule whose only job is to synchronise several people is pure weight here. The second because ai-flow is Claude-Code-native by choice — its value is the depth of that integration (skills, hooks, workflows, subagents, memory), and abstracting for N agents would dilute precisely what makes it worth using.

## Quick Start

### Option 1: Install script

```bash
curl -sL https://raw.githubusercontent.com/jisaballo/ai-flow/main/install.sh | bash
```

Or clone and install locally:

```bash
git clone https://github.com/jisaballo/ai-flow.git
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

Nine phases, two execution paths and three autonomy levels, described one by one in
[the lifecycle protocol](global/protocols/lifecycle.md) — the same file the installer puts on your
machine, so what you read here before adopting is what a session reads afterwards.

What the discipline buys you:

| | |
|---|---|
| **Understanding before code** | Questions asked and requirements written down before a line changes |
| **A plan you approved** | Three steps at most, each with the command that proves it |
| **Evidence, not opinion** | Every criterion audited against a file, a line, or a test name |

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
| `bash ~/.claude/ai-flow/ralph/ralph.sh` | Unattended run of the `[afk]`-tagged tasks (up to 5), on a dedicated `afk/` branch — review it before merging |

## Project Structure

```
your-project/
├── CLAUDE.md                    # Project-specific instructions (your stack, commands, architecture)
├── .ai-flow/
│   ├── BACKLOG.md               # All tasks with status and priority
│   ├── STATE.md                 # Roster of open workstreams — one row per front
│   ├── decisions-global.md      # Cross-task decisions
│   ├── product.md               # Product context (users, roles, flows)
│   ├── steering/                # Domain-specific rules and patterns
│   ├── artifacts/               # One folder per open task (state.md, understand.md, plan.md)
│   └── archive/                 # Completed task summaries

~/.claude/                       # The engine — installed once, shared by every project
├── ai-flow/
│   ├── protocols/               # Phase protocols (the framework core)
│   ├── ralph/                   # AFK loop runner + prompts
│   └── scripts/                 # ceremony mechanisms (front seeding)
├── skills/                      # /understand, /plan, /verify, /discover
├── workflows/verify-review.js   # 4-auditor verify workflow
└── hooks/                       # Guardrails (incl. the engine drift-check)
```

The project holds only its **data** (tasks, product context, steering); the **engine** lives centrally in `~/.claude` and is versioned in this repo — a drift-check hook nags whenever the two diverge.

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

### Global Tooling (skills, workflow, hooks)

The framework ships optional global tooling under `global/`, installed to `~/.claude/` by the installer. It is generic — no project-specific assumptions.

**Phase skills** (`global/skills/` → `~/.claude/skills/`) — slash-command entry points that run a phase by following its protocol:

| Skill | Runs |
|-------|------|
| `/understand` | Understand phase — decompose, investigate, write `understand.md` with Verifiable Criteria |
| `/plan` | Plan + Conform phase — max-3-step `plan.md`, then failing conformance test stubs |
| `/verify` | Verify phase — criterion audit, then the `verify-review` workflow |

**verify-review workflow** (`global/workflows/verify-review.js` → `~/.claude/workflows/`) — a deterministic multi-agent review invoked by `/verify`: four auditors (business contract / coverage / security / architecture) in parallel over the task diff, then adversarial refutation of every HIGH finding — the level that blocks — so only genuine blockers survive; MEDIUM and LOW come back unadjudicated for the verify phase to triage.

**Guardrail hooks** (`global/hooks/` → `~/.claude/hooks/`) — optional Claude Code hooks that enforce the workflow. See [`global/hooks/README.md`](global/hooks/README.md) for what each does and how to register them in `settings.json`. These are safe to install globally (no-op outside an ai-flow project).

**Git hooks** (`global/hooks/git/` → `~/.claude/hooks/git/`) — these are **not** Claude Code hooks and they are **not** no-ops outside an ai-flow project. They carry the two `Never` rules — the trunk is never rewritten or deleted on a remote, a commit never records a secret — and they are reached by pointing git's `core.hooksPath` at them, which is machine-wide by design. Because that setting replaces where git looks for *every* hook, the directory also holds a pass-through for every other hook name, so a repository keeps its own `commit-msg`, `post-checkout` and the rest: the engine adds two guards and takes nothing away. An existing global hook path is reported and left alone rather than replaced. Bypass either guard with `--no-verify`; accept the gap in one repository with `git config aiflow.protection acknowledged`.

## Documentation

- [Getting Started](docs/getting-started.md) — Step-by-step setup guide
- [Lifecycle Protocol](global/protocols/lifecycle.md) — Every phase, the execution paths and the autonomy levels
- [Customization Guide](docs/customization.md) — Adapting ai-flow to your workflow

## Related

- [ai-flow-skills](https://github.com/jisaballo/ai-flow-skills) — companion pack of stack-specific Claude Code skills (Angular / Nx / Ionic) you can drop into a project alongside ai-flow.

## Requirements

- [Claude Code](https://claude.ai/code) CLI or IDE extension
- A git repository (ai-flow uses git for commits and state)

## License

MIT
