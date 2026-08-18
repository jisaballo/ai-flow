---
name: understand
description: Run the ai-flow Understand phase for the active task — read the protocol, decompose composite tasks, parallel-investigate affected domains, ask contextual questions, and write understand.md with Verifiable Criteria. Use when the user says "understand", "entender", or activates a task. Requires an .ai-flow/ directory.
---

# ai-flow Understand Phase

Runs the Understand phase of the ai-flow workflow. Works in any project that has `.ai-flow/`.

## Steps

1. **Read the protocol first**: `.ai-flow/protocols/understand.md`. If it does not exist, this project is not ai-flow — tell the user and stop.

2. **Artifact check**: if `.ai-flow/artifacts/T-XXX/understand.md` already exists, show its contents and ask whether to proceed with it or regenerate. **Never blind-overwrite** an existing artifact.

3. **Read `.ai-flow/product.md` — ALWAYS**, not just for new epics. It is the living domain model (app map, glossary, business rules): the oracle the Business Frame is drafted against.

4. **Follow the protocol**:
   - **Draft the Business Frame first** (role affected, business rule served, today/after, what is lost, out of scope, observable success) from the task + product.md. Holes in the frame are the FIRST question round — before any technical round.
   - Detect composite tasks → propose splitting into independent backlog tasks before planning.
   - Read `.ai-flow/project.yml` for `area_kind` (what an "area" means here) and the `steering` map; use it to phrase the affected area and locate steering files. **Fallback:** if `.ai-flow/project.yml` is absent, infer these from CLAUDE.md (legacy behavior).
   - Load steering files for the affected domains (`.ai-flow/steering/<domain>.md`) — nano block first, full body if the domain is touched.
   - **Scoping pass must output a written `## Unknowns` list** (or an explicit "Unknowns: none — [source]") presented in chat. Every unknown closes with a Decision + evidence (file:line or agent finding) — the inline-vs-agents call derives from the list, never from a mental "enough context". Unknowns spanning 2+ areas → parallel Explore agents, one per area. Skip rules: epic tasks from the 2nd onward (epic-scoped, task's own files only), quick/auto (phase skipped entirely).
   - Do NOT use Plan Mode — a PreToolUse hook (`understand-write-guard.py`) already blocks code writes while the phase is UNDERSTAND; investigation and repro commands stay unrestricted.
   - Ask contextual questions per the protocol's rules: facts are investigated, never asked (a question answerable by grep is forbidden); every question is self-contained in product language (finding + business consequence + options with a recommended answer + a no-cost "I need more context" escape); simple → complex ladder, concrete scenarios over abstract compound questions.
   - Grill techniques: re-question against code/docs, hunt contradictions on TWO fronts (task vs code AND task vs product.md's business model), frontier ordering, re-asks as telemetry.
   - Close only when BOTH gates hold: **Business Closure** (restate the Business Frame — zero file paths — and the user corrects nothing) and Investigation Closure (per protocol).
   - Write `understand.md` with the Business Frame at the top (product language only) and Verifiable Criteria (Automated + Observable + Behavioral; Automated and Behavioral in EARS format per the protocol's Criteria Format section).

5. Respect the phase gate: Understand → Plan requires user approval (Guided/Supervised).
