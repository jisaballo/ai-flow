---
name: understand
description: Run the ai-flow Understand phase for the active task — read the protocol, decompose composite tasks, parallel-investigate affected domains, ask contextual questions, and write understand.md with Verifiable Criteria. Use when the user says "understand", "entender", or activates a task. Requires an .ai-flow/ directory.
---

# ai-flow Understand Phase

Runs the Understand phase of the ai-flow workflow. Works in any project that has `.ai-flow/`.

## Steps

1. **Read the protocol first**: `.ai-flow/protocols/understand.md`. If it does not exist, this project is not ai-flow — tell the user and stop.

2. **Artifact check**: if `.ai-flow/artifacts/T-XXX/understand.md` already exists, show its contents and ask whether to proceed with it or regenerate. **Never blind-overwrite** an existing artifact.

3. **For new epics**: also read `.ai-flow/product.md` first (users, roles, apps, core business flows).

4. **Follow the protocol**:
   - Detect composite tasks → propose splitting into independent backlog tasks before planning.
   - Load steering files for the affected domains (`.ai-flow/steering/<domain>.md`).
   - If >2 domains are affected, launch parallel Explore agents to investigate before asking questions.
   - Ask contextual questions to gather everything needed for polished code.
   - Write `understand.md` with Verifiable Criteria (Automated + Observable + Behavioral).

5. Respect the phase gate: Understand → Plan requires user approval (Guided/Supervised).
