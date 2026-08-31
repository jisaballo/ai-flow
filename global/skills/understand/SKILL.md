---
name: understand
description: Run the ai-flow Understand phase for the active task — read the protocol, decompose composite tasks, parallel-investigate affected domains, ask contextual questions, and write understand.md with Verifiable Criteria. Use when the user says "understand", "entender", or activates a task. Requires an .ai-flow/ directory.
---

# ai-flow Understand Phase

Runs the Understand phase of the ai-flow workflow. Works in any project that has `.ai-flow/`.

## Steps

1. **Read the protocol first**: `~/.claude/ai-flow/protocols/understand.md` (central engine). If the project has no `.ai-flow/` directory, it is not ai-flow — tell the user and stop.

2. **Resolve the task**: the task is the one this checkout owns, not the one the session remembers. Follow the ladder in `~/.claude/ai-flow/protocols/backlog.md` (`## State Files` → `### Resolving the task`) — it is written there and only there, so do not reproduce its rungs here. State which task you resolved and the source it read (the task's sheet, or the shared state when that is the rung that answered) before touching anything under `artifacts/`; if the ladder ends without a task, stop and say which rungs you tried. Then test the phase precondition (same document, `## State Files` → `### The phase precondition`) — written there and only there, so do not reproduce the accepted positions here. On a clean pass, write its own phase to the sheet before any of the phase's work; on a disagreement, report and wait, and if the operator says go, run without moving the line. This command has no material leg — it consumes no earlier phase's artifact — and its phase leg cannot fail from below, no phase preceding it. Both are declared, not covered: an assertion over either would pass for a reason that has nothing to do with the fix.

3. **Artifact check**: if `.ai-flow/artifacts/T-XXX/understand.md` already exists, show its contents and ask whether to proceed with it or regenerate. **Never blind-overwrite** an existing artifact.

4. **Read `.ai-flow/product.md` — ALWAYS**, not just for new epics. It is the living domain model (app map, glossary, business rules): the oracle the Business Frame is drafted against.

5. **Follow the protocol**:
   - **Draft the Business Frame first** (role affected, business rule served, today/after, what is lost, out of scope, observable success) from the task + product.md. Holes in the frame are the FIRST question round — before any technical round.
   - Detect composite tasks → propose splitting into independent backlog tasks before planning.
   - Read `.ai-flow/project.yml` for `area_kind` (what an "area" means here) and the `steering` map; use it to phrase the affected area and locate steering files. **Fallback:** if `.ai-flow/project.yml` is absent, infer these from CLAUDE.md (legacy behavior).
   - Load steering files for the affected domains (`.ai-flow/steering/<domain>.md`) — nano block first, full body if the domain is touched.
   - **The scoping pass also runs the Icebox scan** — read the protocol for it; the rule is stated there and only there, and this line is a pointer, not a copy. **Scoping pass must output a written `## Unknowns` list** (or an explicit "Unknowns: none — [source]") presented in chat. Every unknown closes with a Decision + evidence, and the evidence names its provenance — a fact read first-hand carries its `file:line`, an agent finding carries whose answer it was, and an agent's answer to a question that had not yet survived a round of measurement is a lead, not evidence. The inline-vs-agents call derives from the list, never from a mental "enough context". **The first measurement must be able to falsify the framing of the question**: where the task arrives with a diagnosis already attached, measure the whole and locate the part — do not inspect the named suspect first; the artifact records that measurement and what it could have falsified, and carries no such line where no diagnosis arrived. Unknowns spanning 2+ areas → parallel Explore agents, one per area. **The convergence is never delegated**: an agent answers the question it was given, confidently, including when it is wrong, so a fan-out goes out only once its question has survived a round of measurement — while the question is still moving, investigate inline. Skip rules: epic tasks from the 2nd onward (epic-scoped, task's own files only), quick/auto (phase skipped entirely).
   - Do NOT use Plan Mode — a PreToolUse hook (`understand-write-guard.py`) already blocks code writes while the phase is UNDERSTAND; investigation and repro commands stay unrestricted.
   - Ask contextual questions per the protocol's rules: facts are investigated, never asked (a question answerable by grep is forbidden); every question is self-contained in product language (finding + business consequence + options with a recommended answer + a no-cost "I need more context" escape); simple → complex ladder, concrete scenarios over abstract compound questions.
   - Grill techniques: re-question against code/docs, hunt contradictions on TWO fronts (task vs code AND task vs product.md's business model), frontier ordering, re-asks as telemetry.
   - Close only when BOTH gates hold: **Business Closure** (restate the Business Frame — zero file paths — and the user corrects nothing) and Investigation Closure (per protocol).
   - Write `understand.md` with the Business Frame at the top (product language only) and Verifiable Criteria (Automated + Observable + Behavioral; Automated and Behavioral in EARS format per the protocol's Criteria Format section).

6. Respect the phase gate: Understand → Plan requires user approval (Guided/Supervised). Then **close the phase**: advance the sheet to the position Plan will declare, and where this sitting has grown costly, announce the cut and **end the turn** rather than running Plan in it. This is one of the chain's two cut points; the obligations are stated in `~/.claude/ai-flow/protocols/backlog.md` (`### The phase precondition`) and only there, so do not reproduce them here — a session told to carry on runs Plan as usual.
