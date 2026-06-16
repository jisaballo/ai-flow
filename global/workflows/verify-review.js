export const meta = {
  name: 'verify-review',
  description: 'ai-flow verify: 3 parallel auditors (coverage/security/architecture) over the task diff + adversarial refutation of every HIGH/MEDIUM finding',
  phases: [
    { title: 'Review', detail: '3 auditors in parallel over the task diff' },
    { title: 'Refute', detail: 'a skeptic agent tries to refute each HIGH/MEDIUM finding' },
  ],
}

// args (from the /verify skill): { taskId, area, understandPath, steeringPath, claudeMdPath, changedFiles, diffText }
// The Workflow runtime may deliver `args` as a JSON string; parse it back to an object.
let a = args || {}
if (typeof a === 'string') {
  try {
    a = JSON.parse(a)
  } catch (e) {
    a = {}
  }
}
const REFUTE = ['high', 'medium']

const ctx = [
  `Task: ${a.taskId || '(unknown)'} — area: ${a.area || '?'}`,
  `Changed files:`,
  (a.changedFiles && a.changedFiles.length ? a.changedFiles.map((f) => `  - ${f}`).join('\n') : '  (none provided)'),
  ``,
  `--- DIFF (working tree) ---`,
  a.diffText || '(no diff provided)',
  `--- END DIFF ---`,
  ``,
  `How to review:`,
  `- The DIFF above is the authoritative record of what changed — review the added/changed lines directly.`,
  `- Read the cited files only for surrounding context. If a file cannot be opened (e.g. a brand-new file), review from the diff alone — do NOT return empty just because you could not open a file.`,
  `- Actually inspect the changed code before concluding. Report genuine issues in your dimension; don't pad with trivia, but don't skip issues that are plainly visible in the diff.`,
].join('\n')

const FINDINGS_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['findings'],
  properties: {
    findings: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['title', 'severity', 'file', 'rationale'],
        properties: {
          title: { type: 'string' },
          severity: { type: 'string', enum: ['high', 'medium', 'low'] },
          file: { type: 'string' },
          line: { type: 'string' },
          rationale: { type: 'string' },
          suggestedFix: { type: 'string' },
        },
      },
    },
  },
}

const VERDICT_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['confirmed', 'reasoning'],
  properties: {
    confirmed: { type: 'boolean' },
    reasoning: { type: 'string' },
    adjustedSeverity: { type: 'string', enum: ['high', 'medium', 'low'] },
  },
}

function refutePrompt(f) {
  return [
    ctx,
    ``,
    `You are an ADVERSARIAL REVIEWER. Another auditor raised this ${f.severity.toUpperCase()} finding:`,
    ``,
    `  Title: ${f.title}`,
    `  File: ${f.file}${f.line ? ':' + f.line : ''}`,
    `  Rationale: ${f.rationale}`,
    f.suggestedFix ? `  Suggested fix: ${f.suggestedFix}` : ``,
    ``,
    `Your job is to REFUTE it. Read the actual code in context (Read the cited file and surrounding lines; consult the diff above). Decide whether the finding is a GENUINE, actionable issue or a false positive (already handled elsewhere, out of scope for this task, intended behavior, or a misread of the code).`,
    ``,
    `Be skeptical but fair. Set confirmed=false ONLY if you can clearly show it is not a real issue. If you cannot clearly refute it, set confirmed=true (default to keeping it). Optionally set adjustedSeverity if the original rating is wrong.`,
  ].filter((l) => l !== null && l !== undefined).join('\n')
}

const DIMENSIONS = [
  {
    key: 'coverage',
    label: 'Test Coverage Auditor',
    prompt: [
      ctx,
      ``,
      `You are the TEST COVERAGE AUDITOR for an ai-flow verify phase. If a spec is provided, read it for the intended Verifiable Criteria and edge cases: ${a.understandPath || '(none)'}.`,
      ``,
      `Inspect the diff and the changed files (Read them in full as needed). Find test coverage gaps:`,
      `- Public methods / functions without test coverage`,
      `- Branches not exercised (if/else, switch cases, error paths)`,
      `- Edge cases named in the spec without a corresponding test`,
      `- Regression risk: existing tests that should have been updated but weren't`,
      ``,
      `Severity: high = untested critical/public behavior or a missing regression guard; medium = untested branch/edge case; low = nice-to-have. Cite file + line. Return an empty findings array if there are none.`,
    ].join('\n'),
  },
  {
    key: 'security',
    label: 'Security & Error Handling',
    prompt: [
      ctx,
      ``,
      `You are the SECURITY & ERROR HANDLING auditor for an ai-flow verify phase. Inspect the diff and the changed files (Read them as needed). Find:`,
      `- Inputs without validation (especially user-facing)`,
      `- Async operations without error handling`,
      `- Resources acquired but never released (leak risk: subscriptions, listeners, handles, connections)`,
      `- Sensitive data exposed in logs, responses, or state`,
      `- Missing null/undefined checks on external data`,
      ``,
      `Severity high/medium/low. Cite file + line. Return an empty findings array if there are none.`,
    ].join('\n'),
  },
  {
    key: 'architecture',
    label: 'Architecture Boundaries',
    prompt: [
      ctx,
      ``,
      `You are the ARCHITECTURE BOUNDARIES auditor for an ai-flow verify phase. Read the project's architecture and import rules in ${a.claudeMdPath || 'CLAUDE.md'}${a.steeringPath ? ` and the steering file ${a.steeringPath}` : ''}.`,
      ``,
      `Inspect the diff and the changed files. Find:`,
      `- Imports crossing forbidden module/layer boundaries defined by the project`,
      `- Modules reaching into another module's internals instead of its public entry point`,
      `- Code bypassing the project's established access pattern (e.g. skipping a defined abstraction layer)`,
      `- Divergences from the project's reference/gold-standard pattern`,
      `- Steering-file rules violated`,
      ``,
      `Severity high/medium/low. Cite file + line + the rule violated. Return an empty findings array if there are none.`,
    ].join('\n'),
  },
]

const perDimension = await pipeline(
  DIMENSIONS,
  (d) => agent(d.prompt, { label: `review:${d.key}`, phase: 'Review', schema: FINDINGS_SCHEMA }),
  (review, d) => {
    const findings = ((review && review.findings) || []).map((f) => ({ ...f, dimension: d.key }))
    const lows = findings
      .filter((f) => !REFUTE.includes(f.severity))
      .map((f) => ({ ...f, verdict: { confirmed: true, reasoning: 'low severity — listed without adversarial check' } }))
    const toRefute = findings.filter((f) => REFUTE.includes(f.severity))
    if (!toRefute.length) return lows
    return parallel(
      toRefute.map((f) => () =>
        agent(refutePrompt(f), { label: `refute:${d.key}`, phase: 'Refute', schema: VERDICT_SCHEMA })
          .then((v) => ({ ...f, verdict: v }))
          .catch(() => ({ ...f, verdict: { confirmed: true, reasoning: 'refutation agent errored — kept conservatively' } }))
      )
    ).then((refuted) => [...refuted, ...lows])
  }
)

const all = perDimension.flat().filter(Boolean)
all.forEach((f) => {
  if (f.verdict && f.verdict.confirmed && f.verdict.adjustedSeverity) f.severity = f.verdict.adjustedSeverity
})
const confirmed = all.filter((f) => f.verdict && f.verdict.confirmed)
const refuted = all.filter((f) => !(f.verdict && f.verdict.confirmed))
const bySev = (sev) => confirmed.filter((f) => f.severity === sev)

log(
  `Review complete: ${confirmed.length} confirmed (${bySev('high').length} HIGH, ${bySev('medium').length} MED, ${bySev('low').length} LOW); ${refuted.length} refuted/dismissed`
)

return {
  confirmed,
  refuted,
  summary: { high: bySev('high').length, medium: bySev('medium').length, low: bySev('low').length, dismissed: refuted.length },
}
