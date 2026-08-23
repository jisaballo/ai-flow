# ai-flow hooks

Optional Claude Code hooks that enforce the ai-flow guardrails. Copy them to
`~/.claude/hooks/` (the installer does this) and register them in
`~/.claude/settings.json` (merge `settings.hooks.json` into your `hooks` key).

| Hook | Event | What it does |
|------|-------|--------------|
| `check-state-size.sh` | Stop | ai-flow guardian, **coordinator checkout only**. Blocks finishing a turn when `STATE.md` still holds closed-task summaries, `BACKLOG.md` exceeds its ~300-line size budget, or it carries more than 3 session-close changelog entries. Exits immediately in a linked worktree: the ledger there is a copy the coordinator owns. No-op in any project without an `.ai-flow/`, so it is safe to install globally. |
| `diff-size-guard.py` | Stop | The Diff Size Guardrail, two ceilings: the **step** (uncommitted work >150 LOC) and the **task** (>400 LOC on this branch since its base — commits included, so committing no longer hides growth). Measured in the checkout it runs in, so a worktree is judged on its own branch. Test suites are excluded across stacks (JS/TS, Kotlin, Swift, Java, C#, Python, Go, Ruby, `test/`-style directories). With no resolvable base branch, only the step ceiling applies. |
| `understand-write-guard.py` | PreToolUse (`Edit\|Write`) | Read-only rail for the Understand phase. Reads the phase from the task the checkout is working: the `.ai-flow/artifacts/*/state.md` whose `branch:` line names the branch currently checked out; a sheet naming another branch is another workstream's and is never read here, so the only other candidate is a single sheet that names no branch at all — a project written before the field, or a task whose claim was released when the checkout took on another (`released-branch:`, which the anchored pattern cannot read as a claim) — and failing that the ledger `.ai-flow/STATE.md`. The phase itself is read from the **first** line of that file declaring the field (label, then a colon — see the backlog protocol's `## State Files`); no other line counts, so prose that merely quotes the field declares nothing, and a phase written in any other form leaves the rail silent. While that phase is UNDERSTAND blocks Edit/Write to any repo file outside `.ai-flow/`, judging the written path against the working directory the session declares, never the hook process's own; the block message names the file it read. A linked worktree is judged by its own state, never by an enclosing repo's. Investigation and Bash stay unrestricted. No-op in any project without an `.ai-flow/`. |
| `drift-check.sh` | Stop | Engine drift guard. Quiet while the engine source has uncommitted changes; blocks session close when an installed engine file differs from its committed HEAD, printing the exact fix. An installed file counts as clean when it matches **any** engine checkout's committed HEAD — the recorded clone or, when the session runs in a linked worktree of it, that worktree too; otherwise a worktree's own engine commits would read as drift, and a stale worktree would raise the opposite false alarm. No-op on remote installs (no clone known). |
| `git-safety.py` | PreToolUse (Bash) | Blocks hard force-push to `main`/`master` and staging of likely secrets before the command runs. **The flattened reading is the verdict** — it looks at every character, so it cannot be slipped past — and the parse only ever gets to *excuse* it: a refusal is lifted only where the walk is sure of what it read and no runnable piece of the command still looks dangerous once comments and written documents are set aside. So a document may quote a forbidden command, and a note may mention one, while anything the walk cannot read (a command substitution, an unbalanced quote, an unterminated here-document) keeps the refusal rather than lifting it. The consequence is deliberate: a bug in the parse costs a refusal of something harmless, never a protection lost in silence. A here-document body counts as written data only where a plain writer of standard input reads it. A payload whose type it cannot use is waved through in **silence**, because a non-zero exit here is a non-blocking error and a traceback ran the command with no guard at all. Each refusal names the piece it judged, with assignment values and URL credentials redacted. **Not a sandbox:** it is a rail against mistakes, and a command deliberately assembled to evade it is not caught. The reasoning behind each decision lives in the module's own docstrings, which is where it stays current. |

## Registering them

The installer does this for you: `install.sh` (init with tooling, or `update`)
merges `settings.hooks.json` into the `hooks` key of `~/.claude/settings.json`
idempotently via python3, preserving your other settings and your own hooks.

To do it by hand (e.g. python3 unavailable), merge `settings.hooks.json` into the
`hooks` key of `~/.claude/settings.json` yourself. The commands use `$HOME` so they
are portable across machines.

Hooks are independent — install only the ones you want. They do nothing harmful
outside an ai-flow project (`check-state-size.sh` is a no-op without `.ai-flow/`).
