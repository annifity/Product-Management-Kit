# AI Behavior Specification

Use with `_refs/workflows/ai-product-specification.md`. Delete genuinely
inapplicable sections only with a short rationale.

## Identity And Decision

- Behavior ID and version:
- Status:
- Decision owner:
- Accepted source baselines:
- Deployment scope:

## User Task And Outcome

- Users and affected groups:
- User task:
- Intended outcome:
- Why AI is appropriate:
- Non-goals and excluded conditions:

## Autonomy And Human Authority

- Maximum level: Suggest / Draft / Decide / Act
- Human confirmation boundaries:
- Qualified-review requirements:
- Prohibited autonomous actions:
- Override and appeal:

## Behavior Rules

| Rule ID | Kind | Condition | Expected / Prohibited Behavior | Severity | Acceptance Signal | Test Route | Source |
|---|---|---|---|---|---|---|---|
| AI-BR-001 | Required / Prohibited / Abstain / Escalate / Fallback |  |  |  | AI-AS-001 | Evaluation / UAT |  |

## Context, Retrieval, And Data

| Source | Purpose | Authority | Permission / Tenant Boundary | Freshness | Provenance | Retention / Deletion | Missing Or Conflict Behavior |
|---|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |  |

## Model And Runtime Configuration

- Required capability, not vendor assumption:
- Model/configuration identifier:
- Prompt identifier and version:
- Retrieval/index identifier and version:
- Policy and safeguard identifiers:
- Runtime/environment fingerprint:
- Configuration-change and re-evaluation rule:

## Tools And Side Effects

| Tool / Action | Allowed Purpose | Actor / Permission | Confirmation | Side Effect | Idempotency / Retry | Failure / Compensation | Audit Evidence |
|---|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |  |

## Human Experience

- AI disclosure and expectation setting:
- Evidence, citation, confidence, or uncertainty presentation:
- Edit, confirm, override, and appeal:
- Graceful failure and recovery:
- Accessibility considerations:

## Quality And Operating Budgets

| Dimension | Target / Limit | Measurement Route | Hard Blocker |
|---|---|---|---|
| Task quality |  |  |  |
| Groundedness / factuality |  |  |  |
| Safety / privacy / fairness |  |  |  |
| Latency |  |  |  |
| Cost per successful outcome |  |  |  |
| Availability / fallback |  |  |  |

## Risk And Control Register

| Risk ID | Risk / Affected Group | Severity | Control | Evidence Needed | Owner | Escalation / Rollback |
|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |

## Acceptance And Evaluation Traceability

| Signal ID | Rule IDs | Observable Signal | Evaluation Slice / UAT Case | Owner |
|---|---|---|---|---|
| AI-AS-001 | AI-BR-001 |  |  |  |

## Production Monitoring

- Online quality and safety signals:
- Material user/language/permission/risk slices:
- Sampling and human-review policy:
- Incident owner and escalation:
- Rollback or kill condition:
- Re-evaluation triggers:
- Review cadence and next review:

## Evidence Limits And Open Decisions

- Unmeasured risks:
- Assumptions:
- Material open decisions:
- Required owner and resolution:

## Handoff

- `experiment`: behavior rules, risks, slices, budgets, and unacceptable outcomes
- `plan`: accepted scope, dependencies, owners, and operating work
- `user-story`: sourced user-visible behavior and stable acceptance signals
- `uat`: deterministic flows, permissions, human controls, and recovery
- `ship`: accepted monitoring, rollback, support, and evaluation obligations
