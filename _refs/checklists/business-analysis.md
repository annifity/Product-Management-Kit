# Business Analysis Checklist

Use this before writing BRDs, PRDs, specs, or stories from raw business input.

## BRD Maturity Gate

Classify the source before analysis.

| Level | Signals | Action |
|---|---|---|
| Raw | Meeting notes, bullets, loose ideas, no objective or actor | Ask up to 3 missing-core questions, then proceed with assumptions labeled. |
| Partial | Has structure but missing workflow, rules, metrics, or dependencies | Proceed and log gaps as Block / Clarify / Deferred. |
| Complete | Objective, users, scope, rules, workflow, risks, dependencies, and metrics are present | Proceed directly to deep analysis. |

Ask only missing-core questions:

- What business objective must this support?
- Who is the primary user or actor?
- Are there deadlines, regulatory constraints, or technical constraints?

## Ten-Dimension Analysis

Analyze each material requirement across all dimensions.

- Feature extraction: distinct capabilities implied by the input.
- Business rules: explicit and implied rules that govern behavior.
- Business intent: the outcome behind the requested solution.
- Ambiguity: undefined terms, vague thresholds, unclear ownership.
- Assumptions: facts the document relies on but does not prove.
- Workflow: actors, handoffs, states, decisions, happy path, exception path.
- Edge cases: boundary, invalid, concurrent, retry, timeout, permission, and recovery cases.
- Dependencies: systems, teams, data, policy, vendors, and rollout dependencies.
- Risks: product, business, technical, operational, compliance, schedule, stakeholder.
- Implementation readiness: whether the requirement can safely enter planning.

For every High or Medium severity finding, add a business impact line. Do not add impact text to Low findings unless it changes prioritization.

## Checklist

- Business problem: state the core issue, not the requested solution.
- Root cause: explain why the problem exists; avoid treating symptoms as causes.
- Stakeholders: identify who is affected, who decides, who implements, and who supports.
- Current process: describe the as-is workflow, tools, handoffs, workarounds, and pain.
- Future outcome: describe the desired business behavior and measurable improvement.
- Constraints: capture time, budget, technical, legal, regulatory, and organizational limits.
- Success metrics: define baseline, target, and measurement method when possible.
- Risks: capture what could go wrong during build, rollout, operation, or adoption.
- Open questions: label each question as Block, Clarify, or Deferred and assign an owner.

## Finding Severity

| Severity | Use When | Required Handling |
|---|---|---|
| High | Blocks correct design, implementation, compliance, data integrity, or stakeholder signoff | Resolve before sprint commitment or explicitly accept by decision owner. |
| Medium | Can cause rework, test gaps, support load, or wrong prioritization | Resolve before implementation when feasible; otherwise track owner and date. |
| Low | Minor clarity or polish issue with limited delivery impact | Fix opportunistically or park with rationale. |

## Priority Matrix

|  | High Business Impact | Low Business Impact |
|---|---|---|
| High Severity | Block before development | Fix in sprint or before handoff |
| Low Severity | Monitor and assign owner | Parking lot |

## Readiness Score

Start at 100 and subtract for unresolved gaps.

| Gap | Suggested Deduction |
|---|---|
| Missing business objective | -20 |
| Missing primary user or actor | -15 |
| Undefined business rules | -15 |
| Missing workflow or state behavior | -15 |
| Missing dependency mapping | -10 |
| Missing acceptance signals or success metrics | -10 |
| High ambiguity unresolved | -10 each |
| Medium ambiguity unresolved | -5 each |

Verdict:

- 85-100: Ready for specification or planning.
- 70-84: Needs clarification, but planning can begin with tracked risks.
- 50-69: Needs clarification before development.
- Below 50: Needs reframing or redesign.

## Output

Return:

- BRD maturity: Raw / Partial / Complete.
- Requirement summary.
- Feature list with IDs.
- Business rules with IDs.
- Ambiguities with severity and business impact.
- Hidden assumptions with risk if wrong.
- Missing information grouped as Block / Clarify / Deferred.
- Edge cases and dependencies.
- Readiness score with breakdown and verdict.
