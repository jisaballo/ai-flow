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
| `git-safety.py` | PreToolUse (Bash) | Reports whether this repository's own protections are in place; it judges no command. The two `Never` rules live in the git hooks below, which are handed the refs and the index rather than the command's text — the guard that read that text refused documents for quoting an operation and could not be narrowed without losing protections. On a command that would record or publish something, this rail resolves the working directory the session declares and, if the repository's effective hook path is not `~/.claude/hooks/git` and it carries none of these hooks, refuses and prints the command that fixes it. A repository whose own tooling owns the hook path silences it with `git config aiflow.protection acknowledged` — an accepted gap and a silent one look identical from outside, and that is what tells them apart. Its trigger is a crude text test on purpose: a shape it misses is a reminder that does not fire, never a protection that does not run. |
| `git/pre-push` | git `pre-push` | The trunk on a remote is never rewritten and never deleted. Decides from what git reports per ref — the destination, an all-zero local sha, and whether the commit the remote holds is still an ancestor of the one being sent — so no command text is involved and no wrapping, quoting or alias changes the verdict. `--force` and `--force-with-lease` arrive identically and both are refused: a lease guards against overwriting someone else's work, not against rewriting the trunk. The trunk is matched by exact ref name, so an ordinary branch whose path merely ends in `main` is untouched. A repository's own `pre-push` still runs, chained after this one and its verdict honoured. Bypass with `--no-verify`, which the refusal names. |
| `git/pre-commit` | git `pre-commit` | A commit never records a secret. Reads the index — the paths the commit would actually record — so a secrets file named only in the message, or sitting unstaged, is not a staging. Only additions and changes are judged: removing a secret committed by mistake must stay possible, and for the same reason an amend that merely carries forward a secret its parent already records is not re-judged, while one that adds a secret is refused. POSIX shell, no interpreter dependency: a commit hook that cannot start makes git refuse the commit. Chains to a repository's own `pre-commit`. Bypass with `--no-verify`. |

## Registering them

The installer does this for you: `install.sh` (init with tooling, or `update`)
merges `settings.hooks.json` into the `hooks` key of `~/.claude/settings.json`
idempotently via python3, preserving your other settings and your own hooks.

The two git hooks are registered differently, because git does not read
`settings.json`: the installer copies them to `~/.claude/hooks/git`, sets their executable
bit explicitly — a hook without it is skipped by git with a hint and nothing else — and points
`core.hooksPath` there for every repository on the machine. **An existing global hook path is
reported and left alone**, never replaced: someone who already manages hooks globally has a
setup of their own, and taking it away to install one is not an improvement. A repository that
sets its own hook path (a hook manager typically does) displaces them; `git-safety.py` is what
says so, per repository, instead of letting the gap pass unmentioned.

To do it by hand (e.g. python3 unavailable), merge `settings.hooks.json` into the
`hooks` key of `~/.claude/settings.json` yourself. The commands use `$HOME` so they
are portable across machines.

Hooks are independent — install only the ones you want. They do nothing harmful
outside an ai-flow project (`check-state-size.sh` is a no-op without `.ai-flow/`).
