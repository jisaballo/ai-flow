# ai-flow hooks

Optional Claude Code hooks that enforce the ai-flow guardrails. Copy them to
`~/.claude/hooks/` (the installer does this) and register them in
`~/.claude/settings.json` (merge `settings.hooks.json` into your `hooks` key).

| Hook | Event | What it does |
|------|-------|--------------|
| `check-state-size.sh` | Stop | ai-flow guardian, **coordinator checkout only**. Blocks finishing a turn when `STATE.md` carries closed-work narrative outside its two sanctioned records — the roster table and `## Quick Tasks Completed`, both exempt because the guard reads narrative prose and never a table row — or when `BACKLOG.md` exceeds its ~300-line size budget, or it carries more than 3 session-close changelog entries. Exits immediately in a linked worktree: the ledger there is a copy the coordinator owns. An `.ai-flow/` that is **absent** is the designed no-op, so the hook is safe to install globally; one that exists but **cannot be read** — the directory itself, `STATE.md`, or `BACKLOG.md` — is refused and named, because an unreadable ledger reported as clean is the one verdict this guard must never give. |
| `diff-size-guard.py` | Stop | The Diff Size Guardrail, two ceilings: the **step** (uncommitted work >150 LOC) and the **task** (>400 LOC on this branch since its base — commits included, so committing no longer hides growth). Measured in the checkout it runs in, so a worktree is judged on its own branch. Test suites are excluded across stacks (JS/TS, Kotlin, Swift, Java, C#, Python, Go, Ruby, `test/`-style directories). With no resolvable base branch, only the step ceiling applies. |
| `understand-write-guard.py` | PreToolUse (`Edit\|Write`) | Read-only rail for the Understand phase. Reads the phase from the task the checkout is working: the `.ai-flow/artifacts/*/state.md` whose `branch:` line names the branch currently checked out; a sheet naming another branch is another workstream's and is never read here, so the only other candidate is a single sheet that names no branch at all — a project written before the field, or a task whose claim was released when the checkout took on another (`released-branch:`, which the anchored pattern cannot read as a claim) — and failing that the ledger `.ai-flow/STATE.md`. The phase itself is read from the **first** line of that file declaring the field (label, then a colon — see the backlog protocol's `## State Files`); no other line counts, so prose that merely quotes the field declares nothing, and a phase written in any other form leaves the rail silent. A sheet that **cannot be read** is neither: it loses its `branch:` claim along with its phase, so which task resolves would change silently — the rail refuses and names it, but only where reading it could have changed the answer, since refusing on any unreadable sheet under `artifacts/` would let one stale sheet block every write. Jurisdiction is settled before any verdict, refusals included, so a write under `.ai-flow/` or outside the repository is never refused for a phase the rail could not read — an unknown phase cannot change an answer that never depended on it, and the refusal's own text names correcting the sheet as the way out. The refusal has **two** sites, because the ledger answers where no task sheet resolves: the sheet the ladder could not classify, and the resolved state file whose phase could not be read. An `.ai-flow/` that cannot be **listed** is the third: Python raises there rather than answering, and an uncaught raise leaves a `PreToolUse` hook on exit 1, which does not block — so the write went through with a stack trace printed over it. While that phase is UNDERSTAND blocks Edit/Write to any repo file outside `.ai-flow/`, judging the written path against the working directory the session declares, never the hook process's own; the block message names the file it read. A linked worktree is judged by its own state, never by an enclosing repo's. Investigation and Bash stay unrestricted. No-op in any project without an `.ai-flow/`. |
| `drift-check.sh` | Stop | Engine drift guard. Quiet while the engine source has uncommitted changes; blocks session close when an installed engine file differs from its committed HEAD, printing the exact fix. It reports **at most once per request**, and where any Stop hook already refused in that request it stays quiet for the rest of it: the payload says whether the stop is one the harness is re-delivering after a refusal, and on a re-delivery the guard exits quietly rather than turning one refusal into a loop. So a request in which a sibling spoke first can pass with this guard saying nothing at all — the report is deferred to the next request, never dropped, and it returns on every request until the divergence is gone. The payload is **parsed**, not matched as text, so a truncated or non-JSON one is absent input and absent input reports; where `python3` is unavailable no suppression happens and the guard behaves as it did before. The read is bounded and accumulates line-wise, because a Stop hook waiting for input it never receives is a hung session, and a read that waits for a delimiter loses on bash 3.2 whatever it had already taken. Where the session sits in a linked engine checkout, the message states that installing from it repoints the guard's own source and silences the guard for good once that checkout is dismantled, so it is not offered as an equivalent remedy. An installed file counts as clean when it matches **any** engine checkout's committed HEAD — the recorded clone or, when the session runs in a linked worktree of it, that worktree too; otherwise a worktree's own engine commits would read as drift, and a stale worktree would raise the opposite false alarm. No-op on remote installs, where **no clone is recorded**. A recorded path that **cannot be read** is refused and named instead: the clone is known and the guard simply could not reach the record, which is not the same fact. |
| `git-safety.py` | PreToolUse (Bash) | Reports whether this repository's own protections are in place; it judges no command. The two `Never` rules live in the git hooks below, which are handed the refs and the index rather than the command's text — the guard that read that text refused documents for quoting an operation and could not be narrowed without losing protections. On a command that would record or publish something, this rail resolves the working directory the session declares and, if the repository's effective hook path is not `~/.claude/hooks/git` and it carries none of these hooks, refuses and prints the command that fixes it. A repository whose own tooling owns the hook path silences it with `git config aiflow.protection acknowledged` — an accepted gap and a silent one look identical from outside, and that is what tells them apart. Its trigger is a crude text test on purpose: a shape it misses is a reminder that does not fire, never a protection that does not run. |
| `git/pre-push` | git `pre-push` | The trunk on a remote is never rewritten and never deleted. Decides from what git reports per ref — the destination, an all-zero local sha, and whether the commit the remote holds is still an ancestor of the one being sent — so no command text is involved and no wrapping, quoting or alias changes the verdict. `--force` and `--force-with-lease` arrive identically and both are refused: a lease guards against overwriting someone else's work, not against rewriting the trunk. The trunk is matched by exact ref name, so an ordinary branch whose path merely ends in `main` is untouched. A repository's own `pre-push` still runs, chained after this one and its verdict honoured. Bypass with `--no-verify`, which the refusal names. |
| `git/pre-commit` | git `pre-commit` | A commit never records a secret. Reads the index — the paths the commit would actually record — so a secrets file named only in the message, or sitting unstaged, is not a staging. Only additions and changes are judged: removing a secret committed by mistake must stay possible, and for the same reason an amend that merely carries forward a secret its parent already records is not re-judged, while one that adds a secret is refused. POSIX shell, no interpreter dependency: a commit hook that cannot start makes git refuse the commit. Chains to a repository's own `pre-commit`. Bypass with `--no-verify`. |

## What a guard may conclude from

**Every input a verdict concludes from is proven usable before it is concluded from.** A guard that
could not read its input has not found the input clean — it has reached no verdict at all, and the two
must never leave by the same exit. This is craft rather than ceremony: the guards here exist to say
*somebody looked*, so the one moment the claim matters is the moment it silently stops being true.

The distinction that makes the rule applicable:

- **Absent is silence by design.** No `.ai-flow/` means this is not an ai-flow project; no recorded
  clone means the engine was installed from no checkout; no declared phase means no rail to raise. Each
  guard documents its own silences in the table above, and they stay silences.
- **Unreadable is a refusal that names the file.** The input exists and the guard cannot reach it, so it
  refuses, names the file, and carries the fix. Blocking on a permission fault is an interruption; the
  alternative is a guard that reports "clean" on something nobody read.

Two traps, both of which shipped here before being reproduced and removed:

- **`-f` is true for a file whose contents cannot be read** — stat only needs the parent directory. So
  is `-d` for a directory that cannot be entered, which matters because such a directory makes the files
  inside it test as *absent*, i.e. as the designed silence. `-r` is the test that separates them **for a
  file**, and it is needed beside `-f`, not instead of it. **For a directory the bit is search (`-x`),
  not read** — and confusing the two breaks the check in both directions: mode `0400` leaves `-r` true
  while no child can be stat'ed, so an `-r` gate stays silent over the very fail-open it was added to
  close, and mode `0100` reads every child fine while an `-r` gate refuses and claims nothing was
  checked. Ask which access the guard actually performs: opening a known path needs search on its
  directories, listing one needs read as well. In Python the same fault arrives as an
  exception instead of a false answer: listing an unreadable directory raises, and an uncaught raise
  exits 1 — a code no hook event treats as blocking, so the guard fails open *and* prints a stack trace
  over whatever it was judging. Catch it and refuse; the raise is the authority, so catching it beats
  pre-testing with an access check, which is only a guess about what the next call will do.
- **A discarded exit status cannot be recovered from the output.** `awk` on an unreadable file and a
  file legitimately holding nothing both yield nothing; `grep -c` answers 1 for a legitimate "found
  none" and 2 for an error. So key on the status, captured on the line immediately after the command,
  and where a counting tool cannot report its own failure, gate on readability before it runs.

Two things this does not close, named here rather than left for the next reader to discover. A read that
fails *after* the readability test passes: where the status is free to capture, capture it and the window
shuts; where it is not, the window is accepted. And a guard that folds "could not determine" into an
existing silence for a *different* reason — the drift guard treats any non-zero from its
work-in-progress probe as work in progress — which is the same collapse one level out from the input,
and worth stating so the list is not read as exhaustive when it is not.

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
