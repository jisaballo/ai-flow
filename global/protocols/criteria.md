# Criteria Protocol

**What this owns**: for each of the four `observed:` values a Verifiable Criterion may carry (defined in
`understand.md` > Criteria Format), whether a test may be born for it at each of the four moments a test
can be born across this engine's lifecycle. Every phase that could open that door cites this table rather
than restating it.

## The table

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
