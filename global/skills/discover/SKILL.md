---
name: discover
description: Derive the ai-flow project layer for an existing repo — analyze the codebase, confirm uncertain values with the user, and write a complete .ai-flow/project.yml. Use when adopting ai-flow into an existing project, or when the user says "discover", "discover project", or "derive project.yml". Requires an .ai-flow/ directory.
---

# ai-flow Discover

Derives the **project layer** (`.ai-flow/project.yml`) for an existing codebase, so a developer adopting ai-flow doesn't hand-write it. This is an **onboarding action**, not a lifecycle phase — it has no understand/plan/verify gates and runs once at adoption (re-run if the stack changes).

## Steps

1. **Read the protocol first**: `~/.claude/ai-flow/protocols/discover.md` (central engine). If the project has no `.ai-flow/` directory, it is not ai-flow — tell the user and stop.

2. **Overwrite guard**: if `.ai-flow/project.yml` already exists with non-placeholder values (real commands/dirs, not the `<...>` template), show it and ask whether to re-derive or keep it. **Never blind-overwrite** a populated project.yml.

3. **Follow the protocol**: detect the project-layer values from real signals, confirm every low-confidence field with `AskUserQuestion` (best detection as option 1 — never persist a guessed value unconfirmed), then write a complete, valid `.ai-flow/project.yml`.

4. **Suggest, don't generate, steering**: list the candidate areas you detected and suggest creating `steering/<area>.md` for the high-value ones. Do **not** generate steering skeletons.

5. **Sanity check**: confirm the written `project.yml` is valid YAML with all required keys (`name`, `area_kind`, `source_dirs`, `commands.test`, `steering`).

## Notes
- Detection is done by reading config files — no parser/tooling is added.
