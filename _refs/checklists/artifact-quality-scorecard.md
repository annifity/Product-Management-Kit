# Artifact Quality Scorecard

Use to evaluate PRDs, BRDs, product specs, story maps, user stories, UAT plans, change plans, and release packages before handoff.

## Score Dimensions

Score each dimension from 0 to 5.

| Dimension | 0 | 3 | 5 |
|---|---|---|---|
| Problem clarity | Not stated | Stated but generic | Specific, user/business-centered, and evidence-backed |
| Source grounding | No sources | Some sources or assumptions mixed | Claims trace to sources, evidence, or explicit assumptions |
| Scope control | Scope vague | In/out mostly clear | Scope, non-goals, and change triggers explicit |
| Requirement testability | Not testable | Some testable requirements | Requirements have IDs and observable acceptance signals |
| Workflow/state coverage | Missing | Happy path present | Actors, states, exceptions, recovery, and operations covered |
| Risk/edge coverage | Missing | Some risks listed | Edge cases, risk register, severity, owner, mitigation present |
| Metrics and success | Missing | Metrics named | Baseline, target, source, owner, guardrails present |
| Traceability | Missing | Partial links | Source -> requirement -> story -> UAT traceability clear |
| Decision readiness | No verdict | Issues listed | Verdict, blockers, owners, and next action explicit |
| Enterprise readiness | Not addressed | Some ops/compliance notes | Security, privacy, compliance, support, rollout considered |

## Verdict

| Score | Verdict | Action |
|---|---|---|
| 45-50 | Ready | Can hand off or publish. |
| 35-44 | Conditionally ready | Proceed only with tracked accepted risks. |
| 20-34 | Needs revision | Fix blockers before handoff. |
| 0-19 | Blocked | Reframe, gather evidence, or redesign. |

## Required Output

- Total score and verdict.
- Top 5 blockers.
- Accepted risks and decision owners.
- Evidence gaps.
- Recommended next skill or workflow.
