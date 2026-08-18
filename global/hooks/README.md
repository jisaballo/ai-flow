# ai-flow hooks

Optional Claude Code hooks that enforce the ai-flow guardrails. Copy them to
`~/.claude/hooks/` (the installer does this) and register them in
`~/.claude/settings.json` (merge `settings.hooks.json` into your `hooks` key).

| Hook | Event | What it does |
|------|-------|--------------|
| `check-state-size.sh` | Stop | ai-flow guardian. Blocks finishing a turn when `STATE.md` still holds closed-task summaries, `BACKLOG.md` exceeds its ~300-line size budget, or it carries more than 3 session-close changelog entries. No-op in any project without an `.ai-flow/`, so it is safe to install globally. |
| `diff-size-guard.py` | Stop | Nudges when the uncommitted diff exceeds ~150 LOC (the Diff Size Guardrail), so large changes get split or confirmed. |
| `understand-write-guard.py` | PreToolUse (`Edit\|Write`) | Read-only rail for the Understand phase. While `.ai-flow/STATE.md` marks the phase as UNDERSTAND, blocks Edit/Write to any repo file outside `.ai-flow/` — investigation and Bash stay unrestricted. No-op in any project without an `.ai-flow/`. |
| `git-safety.py` | PreToolUse (Bash) | Blocks force-push-to-main and staging of likely secrets before the command runs. |

## Registering them

The installer does this for you: `install.sh` (init with tooling, or `update`)
merges `settings.hooks.json` into the `hooks` key of `~/.claude/settings.json`
idempotently via python3, preserving your other settings and your own hooks.

To do it by hand (e.g. python3 unavailable), merge `settings.hooks.json` into the
`hooks` key of `~/.claude/settings.json` yourself. The commands use `$HOME` so they
are portable across machines.

Hooks are independent — install only the ones you want. They do nothing harmful
outside an ai-flow project (`check-state-size.sh` is a no-op without `.ai-flow/`).
