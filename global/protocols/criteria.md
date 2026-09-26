# Criteria Protocol

**What this owns**: the four `observed:` values a Verifiable Criterion may carry, and — for each one —
whether a test may be born for it at each of the four moments a test can be born across this engine's
lifecycle. `understand.md` cites this for the values and their precedence; `plan.md`, `verify.md` and
`verify-review.js` cite it for the moments their own phase governs.

## The four values

`observed:` — how the criterion is observed. One of four:

| Value | The verdict comes from |
|-------|------------------------|
| `run` | **executing** the subject and reading what it did or the status it returned — a program the assertion did not write produced the evidence |
| `compute` | an arithmetic relation between two **derived** quantities: a count against a count, a difference, a set algebra over two extractions. A comparison counts only where both sides are derived |
| `resolve` | a **referent resolving** — a path exists, a name is bound, a revision names something |
| `read` | a **pattern matched against the subject's text**. This is the value with no oracle |

**Precedence is `run > compute > resolve > read`, strongest oracle first, and the reason is part of the
rule**: a criterion that runs something and *then* reads its output is `run`, because letting the reading
speak would file an executed observation under the value that means *no program produced this*.

`falsified-by:` — the change **to the subject** that would make the criterion false, stated in the fact's
own terms. A falsifier phrased against the assertion (*the check would go red*) is not one: it describes
the instrument rather than the thing measured, so the same author supplies both sides — the single-actor
failure this field exists to break.

## The four moments

| `observed:` | Conform emission (plan.md) | Plan-step authorship (plan.md) | Verify's repair-leg rule (verify.md) | Verify's coverage review (verify-review.js) |
|---|---|---|---|---|
| `run` | emits a row | may be proposed | may be authored | may be raised |
| `compute` | emits a row | may be proposed | may be authored | may be raised |
| `resolve` | emits a row | may be proposed | may be authored | may be raised |
| `read` | emits none | never proposed | never authored | never raised |

**The rule, stated once**: a criterion currently carrying `observed: read` gets no test at any of the four
moments — the value has no oracle, so a test over it would be written and read by the same actor. This is
tied to the criterion's *current* value, not permanent: one later reclassified to `run`, `compute` or
`resolve`, because a real oracle was found, is no longer bound by it.

A recorded absence against a `read` criterion — `inspection`, `gap` or `covered`, `plan.md`'s own
vocabulary — is accepted as it stands. A `gap` in particular is a real, honestly-recorded hole, not an
invitation: it is never closed by authoring a leg or raising a finding whose only oracle is that
criterion's own prose.
