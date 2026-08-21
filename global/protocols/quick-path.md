# Quick Path Protocol

**Trigger:** `"quick: [description]"` — skips backlog, executes directly
**Criteria:** ALL must be true:
- <= 2 files modified
- No design decisions required
- Scope is unambiguous from description alone
- No new services/components/modules

## Flow

1. **No artifacts folder** — no `artifacts/T-XXX/` created, and no state sheet: a quick task
   writes no state anywhere while it runs
2. **Inline plan stated in the conversation** (1-2 steps max, no file)
3. **Execute** with TDD validation — follow Execute Phase Protocol (`~/.claude/ai-flow/protocols/execute.md`)
4. **No formal verify** — rely on test validation
5. **Commit** with format: `type(scope): quick - description`

## Tracking

Quick tasks log to the "Quick Tasks Completed" table in STATE.md (not BACKLOG.md) — the closing row
is the only written trace a quick task leaves.

**The coordinator writes it, at the closing ceremony** (see the backlog protocol, `## Closing a
Workstream`): a quick task has no papers to collect and no archive to write, so its close is the merge
plus this row. A linked checkout never writes it — the ledger stays with the coordinator, and a row
written into a worktree the ceremony is about to dismantle is a trace that does not survive the close.

```markdown
## Quick Tasks Completed
| Date | Description | Commit |
|------|-------------|--------|
| 2026-02-11 | Fix typo in status label | `abc1234` |
```

## Guarantees Maintained

- TDD validation (tests must pass)
- Atomic commits
- User validation before commit
- The closing row in the Quick Tasks table
- Code comments stand alone — no task IDs in source (Execute protocol > Code Comments & Provenance)

## What It Skips

- Backlog entry and T-XXX ID
- artifacts/ folder (understand.md, plan.md, verify.md)
- Formal verify phase

## Escalation

If during execution the task turns out to be more complex than expected (>2 files, design decisions needed), STOP and escalate:
1. Add task to BACKLOG.md with next T-XXX ID
2. Notify user: "This task exceeds quick path scope. Added as T-XXX to backlog."
3. Switch to full path if user confirms
