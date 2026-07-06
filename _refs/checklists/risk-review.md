# Risk Review Checklist

Check all categories before sprint commitment, stakeholder signoff, or release.

## Risk Categories

Analyze all categories. Mark "low exposure" with rationale instead of skipping.

| Category | Key Question | Common Signals |
|---|---|---|
| Product | Are we solving the right problem for the right users? | Thin research, unclear adoption path, behavior change, unvalidated value. |
| Market and Business | Does the business context support the decision? | Weak ROI, pricing uncertainty, competitor pressure, policy change. |
| Technical | Can the team build the solution as designed? | New tech, third-party dependency, scale uncertainty, technical debt. |
| Operational | Can the organization run and support this after launch? | No runbook, no monitoring, manual work, support training gap. |
| Data and Privacy | Is data accurate, protected, retained, and auditable? | Sensitive data, unclear retention, missing audit trail, data quality gaps. |
| Compliance and Legal | Are regulatory, legal, contractual, or policy constraints clear? | Regulated domain, third-party data sharing, missing approval. |
| Schedule and Resource | Can we deliver with the available time and people? | Single point dependency, optimistic estimate, unclear scope. |
| Stakeholder Alignment | Are decision makers aligned on success and trade-offs? | Conflicting goals, late approver, unclear owner, unmanaged expectation. |

## Scoring

Score likelihood and impact separately.

|  | Impact: High | Impact: Medium | Impact: Low |
|---|---|---|---|
| Likelihood: High | Critical | High | Medium |
| Likelihood: Medium | High | Medium | Low |
| Likelihood: Low | Medium | Low | Low |

## Risk Fields

For each risk, capture:

- Description: what could go wrong and why.
- Likelihood: High / Medium / Low with rationale.
- Impact: High / Medium / Low with consequence.
- Score: Critical / High / Medium / Low.
- Mitigation: action that reduces likelihood or impact.
- Contingency: action if the risk happens anyway.
- Owner: exactly one role or team.
- Trigger or due date: when to act.
- Decision: Mitigate / Accept / Transfer / Avoid.

Use `_refs/templates/risk/risk-register.md` for material risk reviews.

## Rules

- Do not rate everything Medium; force explicit rationale.
- Monitoring is not mitigation unless it reduces likelihood or impact.
- Every Critical and High risk needs owner, mitigation, contingency, and trigger.
- Accepted risks must name the decision maker.
- Separate product/business risk from edge cases; use `_refs/checklists/edge-cases.md` for system failure modes.
