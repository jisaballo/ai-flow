# product.md

**What it is.** `product.md` is the business model in the business's language: who uses the product, what
it does, the rules it obeys and what things are called. Its shape, how it is read, written and kept, are
the [context mechanism](context.md)'s and are not restated here. This document states what is
`product.md`'s alone: its fixed part and its resolved part, the key its rules are grouped by, the shape of
a rule, and the moments it is written.

## Two parts

| Part | Sections | Loaded |
|---|---|---|
| Fixed | Every section not titled `Rules:` — the product, its users and roles, its applications, its core flows, its terms | Always, with the nano |
| Resolved | One `## Rules: <key> — <topic>` per group of business rules | Where `<key>` is an affected key of the task |

The fixed part is what every task needs to speak the business's language: who the roles are, which app is
which, what a term means. It is small by nature and bounded by the section length like any section. The
resolved part is where the file grows — one rule per task that confirmed one — and it grows under the same
key vocabulary steering uses, so a task that touches one app or domain loads that key's rules and no other.

**Only the fixed part counts toward the section count.** A `Rules:` section is a record of the growing
part, so it rises with use and by nothing the writer did wrong; counting it would put a ceiling on how many
groups of business rules a product may have, which is a ceiling on the business rather than on the file's
shape. The count bounds topics and not records — [the mechanism](context.md) states the rule and this is
`product.md`'s instance of it. Every other rule still answers for a `Rules:` section, its length included:
a group that has outgrown one section is two topics, and splitting it is the repair.

The keys are the `steering:` map's keys, `workspace` included: a rule every task must know is
`Rules: workspace — <topic>`. One vocabulary names an area across every class, which is what lets the
mechanism resolve `product.md` and steering with one test. A rule whose key has no steering file yet names
the key anyway; the map gains the key when a steering file is born for it.

## The rule line

A business rule is one line: the rule in bold, in product language, then the reason where the rule alone
would be re-argued, then its provenance as `(T-XXX)`. The archive that provenance names holds the
occasion; the rule holds the reason. History is pruned to the destination that already holds it.

## When it is written

- **Step 2 of the archive checklist:** every rule Understand recorded under *New business rules minted* is
  copied into its `Rules: <key> — <topic>` section, with provenance, and the terms sharpen where the task
  sharpened one. A rule that stays only in the archived artifact will be re-asked or re-assumed.
- **The Business-Miss Rule:** when a shipped task violated business intent, the missing rule is written
  alongside the fix task.
- **Re-asks as telemetry:** a question the operator answers twice in the same area is standing context the
  file lacks, and it is written there so it is never asked again.

## Who reads it

Understand states its own use: it reads `product.md` at every Understand — the fixed part and the affected
keys' rules — drafts the Business Frame against it, and hunts contradictions between the task and the
business model on that ground. That is Understand's rule, written in Understand.
