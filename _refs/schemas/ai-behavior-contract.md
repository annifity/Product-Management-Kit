# AI Behavior Contract Schema

Use this provider-neutral contract to make an AI-enabled product behavior
versioned, traceable, and evaluable. Store it as UTF-8 JSON when automation is
required.

## Required Top-Level Fields

| Field | Type | Meaning |
|---|---|---|
| `schemaVersion` | string | Contract schema version |
| `behaviorId` | string | Stable behavior identifier |
| `behaviorVersion` | string | Immutable accepted version |
| `status` | string | `draft`, `accepted`, `superseded`, or `retired` |
| `decisionOwner` | string | Owner of product behavior |
| `purpose` | object | User task, outcome, non-goals, and deployment scope |
| `affectedUsers` | array | Users and communities affected |
| `autonomy` | object | Suggest, draft, decide, or act boundaries |
| `behaviorRules` | array | Required, prohibited, fallback, and escalation rules |
| `contextAndData` | object | Inputs, provenance, authorization, freshness, retention |
| `configuration` | object | Model, prompt, retrieval, tool, policy, and runtime IDs |
| `tools` | array | Action, permission, confirmation, and side-effect contracts |
| `humanExperience` | object | Disclosure, edit, override, appeal, and failure UX |
| `budgets` | object | Quality, safety, latency, cost, and availability constraints |
| `risks` | array | Risk, severity, control, owner, and evidence requirement |
| `acceptanceSignals` | array | Observable signals linked to behavior rules |
| `monitoring` | object | Signals, incidents, rollback, review, re-evaluation |
| `sourceRefs` | array | Accepted source and decision identifiers |

## Behavior Rule

Each rule requires:

- stable `ruleId`;
- `kind`: `required`, `prohibited`, `abstain`, `escalate`, or `fallback`;
- observable `condition` and `expectedBehavior`;
- `riskTags` and `severity`;
- `acceptanceSignalIds`;
- evaluation or deterministic-test route;
- source references.

Do not use an ideal prose answer when several outputs may be correct.

## Autonomy And Tool Contract

`autonomy` must declare the maximum action level and which transitions require
human confirmation. Every tool entry requires:

- stable tool and action ID;
- allowed purpose and actors;
- input, permission, and argument rules;
- confirmation and irreversible-action boundary;
- expected side effect and audit evidence;
- idempotency, retry, partial-failure, and compensation behavior;
- prohibited conditions and stop/escalation rule.

## Context And Data Contract

Declare authorized sources, owners, privacy class, tenant boundary, retrieval
trigger, freshness rule, provenance returned to users, retention, redaction,
deletion propagation, and behavior when context is missing, conflicting, stale,
or unauthorized.

## Monitoring Contract

Declare online quality and safety signals, material slices, alert thresholds,
incident owner, sampling and human-review policy, rollback or kill condition,
re-evaluation triggers, and next review date. Missing evidence never counts as
a healthy signal.

## Invariants

1. IDs are unique within the contract.
2. Every acceptance signal references at least one behavior rule.
3. Every high or critical risk has an owner, control, evidence need, and
   rollback or escalation response.
4. Every action with external or irreversible effects has an explicit
   permission and confirmation rule.
5. Every context source has authorization, provenance, and freshness behavior.
6. Configuration changes create a new behavior or configuration baseline and
   trigger the declared re-evaluation policy.
7. An accepted contract has no unresolved material behavior decision.

## Minimal Example

```json
{
  "schemaVersion": "1.0",
  "behaviorId": "policy-answer",
  "behaviorVersion": "1.0.0",
  "status": "accepted",
  "decisionOwner": "Product Owner",
  "purpose": {
    "userTask": "Draft a cited policy answer",
    "outcome": "Reduce lookup time without inventing policy",
    "nonGoals": ["make binding policy decisions"],
    "deploymentScope": "internal support portal"
  },
  "affectedUsers": ["support-agent"],
  "autonomy": {
    "maximumLevel": "draft",
    "humanConfirmationRequiredFor": ["customer-send"]
  },
  "behaviorRules": [
    {
      "ruleId": "AI-BR-001",
      "kind": "abstain",
      "condition": "no current approved source supports an answer",
      "expectedBehavior": "state the evidence gap and route to policy support",
      "riskTags": ["groundedness"],
      "severity": "high",
      "acceptanceSignalIds": ["AI-AS-001"],
      "testRoute": "ai-evaluation",
      "sourceRefs": ["POLICY-BASELINE-01"]
    }
  ],
  "contextAndData": {},
  "configuration": {},
  "tools": [],
  "humanExperience": {},
  "budgets": {},
  "risks": [],
  "acceptanceSignals": [
    {"signalId": "AI-AS-001", "ruleIds": ["AI-BR-001"], "observable": "abstains and escalates"}
  ],
  "monitoring": {},
  "sourceRefs": ["SPEC-SUPPORT-01"]
}
```

## Validation

Reject an accepted contract when identity, source authority, required behavior,
autonomy, data authorization, tool boundaries, acceptance signals, material
risk ownership, or monitoring controls are missing.
