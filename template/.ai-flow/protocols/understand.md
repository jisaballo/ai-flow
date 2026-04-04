# Understanding Phase Protocol

**CRITICAL:** This phase ensures polished code by gathering all necessary context BEFORE planning.

**AUTO Plan Mode:** Enter Plan Mode (`EnterPlanMode`) at the start of Understanding phase ONLY if `artifacts/T-XXX/understand.md` does not exist yet. If understand.md already exists, skip Plan Mode — just read and use the existing artifact. Exit Plan Mode (`ExitPlanMode`) **before writing understand.md** — Plan Mode is read-only and blocks file writes.

## Product Context

If this is the first task in a new epic, read `.ai-flow/product.md` for business context before investigating.

## Automatic Task Split

**BEFORE asking questions**, analyze if the task mixes multiple concerns:

**IMPORTANT: Split tasks are independent first-class tasks — NOT subtasks. Each gets its own T-XXX ID, its own backlog entry, and its own full lifecycle. There is no parent/child relationship.**

**Indicators of composite tasks:**
- Task mentions multiple features ("Add X and Y")
- Task affects multiple unrelated domains (auth + UI + data-access)
- Task description uses "and", "also", "plus" repeatedly
- Task solves problems in different places (component + service + state)
- Task has dependencies that could be separate tasks

**When detected:**
1. **STOP** and propose splitting the task
2. Use `AskUserQuestion` to confirm split:
   ```
   Question: "I detected this task mixes multiple concerns:"
   Options:
   - "Work on [Concern 1] first, add others to backlog as independent tasks (Recommended)"
   - "Keep all concerns together"
   - "Different split: [alternative]"

   Context shown:
   - Concern 1: [description]
   - Concern 2: [description]
   - Concern 3: [description]
   ```
3. If user confirms split:
   - Keep ONLY the first concern in current task, update its description
   - Create each remaining concern as a **new independent task** in BACKLOG.md (T-XXX+1, T-XXX+2, etc.)
   - These new tasks are **peers**, not subtasks — same format, same lifecycle as any other backlog task
4. If user rejects, proceed with full task (but warn about complexity)

## Steering Files

**After task split analysis**, identify which domains the task affects and read the corresponding steering files from `.ai-flow/steering/{domain}.md`. These contain domain-specific rules, patterns, and pitfalls that inform better questions and plans.

If no steering file exists for the affected domain, proceed without one.

## Parallel Investigation

**After task split analysis and steering file load** (if applicable), if the task affects >2 domains/areas of the codebase, launch Agent (subagent_type=Explore) in parallel — one per area. If <=2 areas, investigate inline as usual.

**Example:** Task affects auth + payments + notifications ->
- Agent 1: Explore auth domain (models, services, state)
- Agent 2: Explore payments domain (relevant interfaces, APIs)
- Agent 3: Explore notification service (current patterns, triggers)

Use the results to formulate better contextual questions. Do NOT ask the user questions that could be answered by reading the codebase.

## Contextual Questions

After decomposition and investigation (or if task is atomic), gather missing context:

**Always ask when:**
- Task has ambiguous requirements ("improve UX", "optimize performance")
- Multiple implementation approaches exist
- Expected behavior is not explicitly defined
- UI/UX details are missing (positioning, styling, interactions)
- Business logic is unclear
- Edge cases are not specified

**Question categories:**
1. **Requirements clarity** - What exactly should happen?
2. **Expected behavior** - How should it behave in edge cases?
3. **UI/UX details** - Where, how, when should UI appear?
4. **Technical approach** - Preferred patterns/libraries/strategies?
5. **Verifiable criteria** - What concrete checks (tests + code inspection) confirm correctness?

**Format:**
- Use `AskUserQuestion` with 2-4 questions max
- Each question should have 2-4 specific options
- Always include "More questions" option to gather additional context

## Output: understand.md

Include only fields relevant to the task type. Omit sections that don't apply (e.g., skip UI/UX Details for backend-only tasks).

Write `artifacts/T-XXX/understand.md` with:
```markdown
# Understanding: [Task ID] - [Task Title]

## Original Task
[Original description from backlog]

## Task Decomposition
- **Status**: [Atomic / Decomposed]
- **Active Scope**: [What we're solving now]
- **Deferred to Backlog**: [List of new task IDs, if decomposed]

## Context Gathered
[Answers from user questions]

## Requirements Clarification
- **Goal**: [Clear, specific goal]
- **Expected Behavior**: [Detailed behavior description]
- **UI/UX Details**: [Specific details: position, style, interactions]
- **Edge Cases**: [How to handle edge cases]
- **Verifiable Criteria**:
  - **Automated** (tests): `[spec file]` — [what it tests]
  - **Observable** (code inspection): [concrete checkable fact]
  - **Behavioral** (UI/flow tasks only):
    - GIVEN [context] WHEN [trigger] THEN [result]
    - GIVEN [context] WHEN [trigger] THEN [result]

## Technical Considerations
- **Files Affected**: [Estimated files]
- **Approach**: [Preferred approach based on user answers]
- **Risks**: [Potential issues to watch for]
```

## Understanding -> Plan Transition

Before proceeding to plan:
1. Show understand.md summary
2. Use `AskUserQuestion`:
   ```
   Question: "Do you need to clarify anything else before I create the plan?"
   Options:
   - "No, proceed with the plan (Recommended)"
   - "Yes, I have more questions"
   ```
3. Only proceed to plan when user confirms clarity
4. Plan Mode was already exited before writing understand.md — file writes are now allowed for plan.md
