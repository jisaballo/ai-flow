# Discover Protocol

**Trigger:** `"discover"` / `"discover project"` — derive the project layer (`.ai-flow/project.yml`) for an existing repo.

**When to use:**
- Right after installing ai-flow into an **existing** codebase, instead of hand-writing `project.yml`
- When the stack/build tooling changes enough that the project layer is stale
- NOT a per-task phase — it has no understand/plan/verify gates

**Goal:** produce a complete, correct `.ai-flow/project.yml` in one interactive pass — never a half-guessed file.

## 1. Overwrite guard

If `.ai-flow/project.yml` already holds non-placeholder values (real commands/dirs, not the `<...>` template), show it and ask whether to re-derive or keep it. Never blind-overwrite a populated file.

## 2. Detect from real signals

Read configuration and structure — do not guess from the project name. Sources, in priority order:

| Field | Detect from |
|-------|-------------|
| `name` | `package.json` `name`, nx workspace name, or the repo directory |
| `commands.{test,lint,build}` | `package.json` `scripts`, `nx.json` / `project.json` targets, `Makefile`, `pyproject.toml`, `cargo.toml`, CI config |
| `area_kind` | Monorepo layout: `apps/`+`libs/` → `app`/`domain`; `packages/` → `package`; single `src/` → leave as the module/service the repo represents |
| `source_dirs` | Top-level source directories actually present (`apps`, `libs`, `packages`, `src`, …) |
| `steering` | Usually empty at first — only map an area if a `steering/<area>.md` already exists |

For monorepo command runners (Nx, Turbo, pnpm workspaces), prefer the scoped form with the `{area}` placeholder (e.g. `npx nx test {area}`). For a single-package repo, use the flat command (e.g. `npm test`).

## 3. Confirm every low-confidence field (mandatory)

For each field you cannot infer with high confidence, ask via `AskUserQuestion`:
- Put your **best detection as option 1** (recommended).
- Offer the most likely alternatives as the other options.
- **Never persist a guessed value without confirmation.** A wrong `commands.test` silently breaks the plan/verify phases.

Fields that usually need confirmation: `area_kind` (the convention isn't always obvious), and any `commands.*` where multiple plausible scripts exist (e.g. `test` vs `test:ci`).

## 4. Write `project.yml`

Write `.ai-flow/project.yml` using the T-001 v1 schema. It must be valid YAML with all required keys: `name`, `area_kind`, `source_dirs`, `commands.test`, `steering`. Keep the human-authority note (project.yml is authoritative for commands; CLAUDE.md prose is human-only).

**Carry over every optional key the file already declares** — `commands.distribute`, `front_tool`, anything a later schema adds. A re-derive that writes only the keys it knows about deletes the operator's own declarations without saying so, and the two above are read by ceremonies rather than by this protocol: nothing here would notice their absence, and the ceremony that reads one would report the project as declaring none.

## 5. Suggest steering — do not generate it

List the candidate areas you detected (apps / domains / packages) and suggest creating `steering/<area>.md` for the high-value ones (domains with non-obvious rules, security/compliance, established patterns). **Do not generate steering skeletons** — empty files are noise. Point the user at the steering guidance in the customization docs.
