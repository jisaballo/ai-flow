# Codebase Mapping Protocol

**Trigger:** `"map codebase"` — run lightweight codebase analysis
**When to use:**
- Before starting a new epic (group of related tasks)
- After significant refactors
- When onboarding to an unfamiliar area of the codebase
- NOT needed for every task — only when entering unfamiliar territory

## Output

3 files in `.ai-flow/codebase/`:

| File | Content | How it's generated |
|------|---------|-------------------|
| `CONCERNS.md` | Technical debt: TODOs, large files (>300 LOC), fragile areas, missing tests | Grep for TODOs/FIXMEs, analyze file sizes, check test coverage gaps |
| `TESTING.md` | Test patterns per module: mock strategies, fixture patterns, test utilities | Analyze existing spec files for patterns, document conventions |
| `DRIFT.md` | Differences between project CLAUDE.md (architecture/patterns) and actual code reality | Compare documented patterns vs actual imports, structure, conventions |

## Format Rules

- **Prescriptive** language: "Use X pattern" not "X pattern is used"
- **Include file paths**: backtick format for navigation (`src/modules/auth/`)
- **Include real code examples**: actual patterns from the codebase, not abstractions
- **Current state only**: no historical or hypothetical content

## CONCERNS.md Template

```markdown
# Codebase Concerns

## Technical Debt
| Location | Type | Description |
|----------|------|-------------|
| `src/services/...` | TODO | [description] |

## Large Files (>300 LOC)
| File | LOC | Suggestion |
|------|-----|------------|
| `path/to/file.ts` | 450 | Consider splitting [reason] |

## Missing Test Coverage
| File/Module | Status |
|-------------|--------|
| `src/auth/` | No spec files |
```

## Staleness

Files in `codebase/` include a `> Last analyzed: [date]` header. Consider re-running if >2 weeks old or after major changes.
