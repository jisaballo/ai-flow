# Getting Started with ai-flow

## Prerequisites

- [Claude Code](https://claude.ai/code) installed (CLI, desktop app, or IDE extension)
- A git repository for your project

## Installation

### 1. Install ai-flow in your project

```bash
# Option A: npm — a release you can name, and go back to
npx ai-flow@latest

# Option B: Clone and install — the only route the drift guard can watch
git clone https://github.com/jisaballo/ai-flow.git /tmp/ai-flow
/tmp/ai-flow/install.sh /path/to/your/project

# Option C: One-liner — whatever is on the trunk right now, unversioned
curl -sL https://raw.githubusercontent.com/jisaballo/ai-flow/main/install.sh | bash

# Update later (any device/dev): re-fetch the core + tooling, keep your data, no prompts
npx ai-flow@latest update
curl -sL https://raw.githubusercontent.com/jisaballo/ai-flow/main/install.sh | bash -s update
./install.sh update
```

The three doors install the same engine and differ in what it is pinned to, which decides two things:
what `~/.claude/ai-flow/version` reports afterwards, and whether the drift guard has anything to compare
against. A clone records itself, and the guard then reports at session close whenever the installed
engine differs from that clone's committed HEAD. A package and the one-liner record no such source — by
design, and stated rather than assumed: an installation with nothing to compare against is one the guard
deliberately says nothing about. Recording a location that can disappear would be worse than recording
none, because the guard would then refuse every session close over a directory nobody can restore.

**If a trunk update leaves the engine broken**, this is the way back — no checkout, and it does not go
through the impaired engine:

```bash
npx ai-flow@1.0.0 update           # or whichever version you last had working
cat ~/.claude/ai-flow/version      # confirm what is now in place
```

The installer takes two subcommands: `init` (default — new or existing project, interactive; creates the project's `.ai-flow/` data skeleton and installs the engine) and `update` (unattended — refreshes the engine in `~/.claude`: protocols, skills, the verify workflow, hooks, the ceremony scripts, and the ralph runner; it never writes into a project). A bare path is treated as `init` for back-compat.

This creates:
- `.ai-flow/` directory with the project's own data files — the phase protocols are not among them; they install centrally into `~/.claude` and are shared by every project
- `CLAUDE.md` template (if none exists)

### 2. Set up global instructions

Copy the global CLAUDE.md to your Claude Code config:

```bash
mkdir -p ~/.claude
cp /tmp/ai-flow/global/CLAUDE.md ~/.claude/CLAUDE.md
```

If you already have a `~/.claude/CLAUDE.md`, merge the ai-flow sections into it. The key sections are:
- `## Workflow: .ai-flow` (the entire section)
- `## Action Boundaries`
- `## Working Rules`
- `## Core Principles`

### 3. (Optional) Install the global tooling

The phase skills, verify-review workflow, and guardrail hooks live under `global/`. The installer offers to copy them; to do it manually:

```bash
mkdir -p ~/.claude/skills ~/.claude/workflows ~/.claude/hooks
cp -R /tmp/ai-flow/global/skills/* ~/.claude/skills/
cp /tmp/ai-flow/global/workflows/verify-review.js ~/.claude/workflows/
cp /tmp/ai-flow/global/hooks/*.sh /tmp/ai-flow/global/hooks/*.py ~/.claude/hooks/
mkdir -p ~/.claude/hooks/git
cp /tmp/ai-flow/global/hooks/git/pre-* ~/.claude/hooks/git/ && chmod +x ~/.claude/hooks/git/pre-*
git config --global core.hooksPath ~/.claude/hooks/git   # skip if you already set one
```

The installer **registers the hooks for you** — it merges `global/hooks/settings.hooks.json` into the `hooks` key of `~/.claude/settings.json` idempotently (python3), preserving your other settings and your own hooks. The manual `cp` above is only needed if you skipped the tooling step or python3 is unavailable. See [`global/hooks/README.md`](../global/hooks/README.md). The skills give you `/understand`, `/plan`, `/verify`, and `/discover`.

### 4. Customize for your project

**Edit `CLAUDE.md`** in your project root:
- Fill in your stack (framework, language, database, etc.)
- List your apps and their types
- Document your architecture and import rules
- Add your build/test/lint commands

**Adopting into an existing project?** Run `discover` and let ai-flow derive `.ai-flow/project.yml` for you — it inspects your `package.json`/`nx.json`/layout, confirms the uncertain values with you, and writes a complete project.yml. Use it instead of hand-editing the fields below.

**Edit `.ai-flow/project.yml`** (the structured project layer the skills read) — or let `discover` fill it:
- Set `area_kind` (what an "area" means: app / domain / package / service)
- List `source_dirs` (where your source lives)
- Set `commands.test` / `lint` / `build` (use `{area}` for scoped commands like `npx nx test {area}`)
- Map each area to its steering file under `steering:`
- See [Customization → Project layer](customization.md) for the full schema. If absent, skills fall back to inferring from CLAUDE.md.

**Edit `.ai-flow/product.md`**:
- Describe your product and domain
- List user roles and their actions
- Document core business flows
- Define key domain terms

### 5. (Optional) Create steering files

If your project has distinct domains with specific rules, create steering files:

```bash
# Example for an auth domain
cat > .ai-flow/steering/auth.md << 'EOF'
# Domain: Authentication

## Rules
- Always use AuthService, never access auth provider directly
- Tokens must be stored in httpOnly cookies

## Patterns
- Login: Component → Service → Provider → Redirect

## Pitfalls
- Token refresh race condition during concurrent requests
EOF
```

## Your First Task

Open Claude Code in your project and try:

```
add to backlog: Add input validation to the user registration form
```

Then:

```
work on T-001
```

Claude will:
1. Analyze the task for composite concerns
2. Load any relevant steering files
3. Ask contextual questions
4. Write an understand.md with requirements and verifiable criteria
5. Ask for your approval before planning

## What a Session Looks Like

Two worked transcripts. Which path a task takes, and what each phase actually does, are in
[the lifecycle protocol](../global/protocols/lifecycle.md) — installed on your machine at
`~/.claude/ai-flow/protocols/lifecycle.md` once you have run the installer.

### Full path (most tasks)

```
You: "work on T-001"
Claude: [Understand] Asks questions, writes understand.md
You: "proceed with the plan"
Claude: [Plan] Creates 1-3 step plan with verify commands
Claude: [Conform] Generates failing test stubs
You: "execute"
Claude: [Execute] Makes code changes, runs tests per step
Claude: [Verify] Audits each criterion, runs review agents
You: "approved" / "validated"
Claude: [Archive] Commits, archives, cleans up
```

### Quick path (small changes)

```
You: "quick: Fix typo in login button label"
Claude: [Plan inline] 1 step, identifies file
Claude: [Execute] Makes change, runs tests
You: "approved"
Claude: Commits with "fix(auth): quick - Fix typo in login button label"
```

## Tips

- **One task at a time, per workstream**: ai-flow keeps each front on a single task for quality — two fronts is the working parallelism
- **Trust the phases**: Skipping understanding leads to rework
- **Steering files pay off**: Spend 10 minutes documenting domain rules, save hours of corrections
- **Review verify.md**: The audit table is your quality receipt
- **Use autonomy levels**: Bug fixes don't need the same rigor as new features
