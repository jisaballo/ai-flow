# Getting Started with ai-flow

## Prerequisites

- [Claude Code](https://claude.ai/code) installed (CLI, desktop app, or IDE extension)
- A git repository for your project

## Installation

### 1. Install ai-flow in your project

```bash
# Option A: Clone and install
git clone https://github.com/YOUR_USER/ai-flow.git /tmp/ai-flow
/tmp/ai-flow/install.sh /path/to/your/project

# Option B: One-liner (once published)
curl -sL https://raw.githubusercontent.com/YOUR_USER/ai-flow/main/install.sh | bash
```

This creates:
- `.ai-flow/` directory with protocols and empty data files
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

### 3. Customize for your project

**Edit `CLAUDE.md`** in your project root:
- Fill in your stack (framework, language, database, etc.)
- List your apps and their types
- Document your architecture and import rules
- Add your build/test/lint commands

**Edit `.ai-flow/product.md`**:
- Describe your product and domain
- List user roles and their actions
- Document core business flows
- Define key domain terms

### 4. (Optional) Create steering files

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

## Understanding the Flow

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

- **One task at a time**: ai-flow enforces single-task focus for quality
- **Trust the phases**: Skipping understanding leads to rework
- **Steering files pay off**: Spend 10 minutes documenting domain rules, save hours of corrections
- **Review verify.md**: The audit table is your quality receipt
- **Use autonomy levels**: Bug fixes don't need the same rigor as new features
