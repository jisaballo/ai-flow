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

## Discoveries on a path that keeps no papers

A quick task writes no `artifacts/T-XXX/`, so the staging file of Discovery Triage (Understanding
protocol) does not exist here. It takes the routing test's two terminals unchanged — a finding in a file
this task's diff already covers is fixed now, and a finding the flow cannot reach is discarded with the
reason stated — and whatever survives is **surfaced to the user at the close**, in the same sitting,
where the user is already present to decide where it goes.

That is the whole of it, and it is written as this path's own rule rather than as an exemption: the
alternative was routing a survivor to the ledger unseen, which is the leak the routing test exists to
close. A quick task never writes to BACKLOG.md's `## Icebox` itself.

## Guarantees Maintained

- TDD validation (tests must pass)
- Atomic commits
- User validation before commit
- The closing row in the Quick Tasks table
- Code comments stand alone — no task IDs in source (Execute protocol > Code Comments & Provenance)

## What It Skips

- Backlog entry and T-XXX ID
- artifacts/ folder (understand.md, plan.md, verify.md, discoveries.md)
- Formal verify phase

## Escalation

If during execution the task turns out to be more complex than expected (>2 files, design decisions needed), STOP and escalate:
1. Add task to BACKLOG.md with next T-XXX ID
2. Notify user: "This task exceeds quick path scope. Added as T-XXX to backlog."
3. Switch to full path if user confirms
