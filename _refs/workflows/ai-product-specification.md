# AI Product Specification Workflow

Use when AI, a model, prompt, retrieval system, agent, or tool-using assistant is
a material part of the product behavior.

## Decision Supported

Define the bounded AI behavior that product, engineering, evaluation, UAT, and
release owners can implement and judge without inventing policy after results
arrive.

## Inputs

- Confirmed user problem, outcome, scope, and non-goals
- AI suitability and risk framing when available
- Users, affected groups, deployment context, and decision owner
- Approved policies, data sources, tools, permissions, and current baseline
- Known limitations, incidents, evidence, and operational constraints

Stop and route to `discovery` when the purpose, users, or value of AI remains
unresolved. Route a committed behavior change to `change`.

## Process

1. **Bound the behavior.** Name the user task, intended outcome, deployment
   context, users, channels, languages, and conditions outside scope.
2. **Set the autonomy level.** State whether AI suggests, drafts, decides, or
   acts. Define actions that require confirmation, qualified review, or are
   prohibited.
3. **Specify required and prohibited behavior.** Use observable rules. Define
   uncertainty, abstention, escalation, safe fallback, appeal, and recovery.
4. **Define context and data.** Identify authorized inputs, provenance,
   freshness, retrieval rules, tenant or permission boundaries, retention,
   redaction, deletion propagation, and unavailable-context behavior.
5. **Define model and configuration boundaries.** Record provider-neutral model
   capability needs plus versioned prompt, retrieval, tool, policy, and runtime
   configuration identifiers. Do not prescribe a vendor without a sourced
   decision.
6. **Specify tools and side effects.** Define allowed tools, argument and
   permission rules, confirmation boundaries, idempotency, audit evidence,
   partial failure, retry, compensation, and stop conditions.
7. **Specify the human experience.** Define disclosure, expectation setting,
   editable output, confidence or evidence presentation, override, appeal,
   accessibility, and graceful failure.
8. **Set quality and operating budgets.** Define task-quality, safety,
   groundedness, latency, cost, availability, and human-review constraints.
9. **Bind acceptance and evaluation.** Give every material behavior a stable
   requirement ID, acceptance signal, risk tag, and evaluation or UAT route.
10. **Define production controls.** State monitoring signals, incident owner,
    rollback or kill condition, re-evaluation triggers, and review cadence.

## Readiness Rules

The contract is ready only when:

- intended, prohibited, fallback, and escalation behavior are observable;
- every irreversible or high-impact action has an explicit authority boundary;
- data, retrieval, tools, and configurations have reproducible identities;
- material risks have controls, evidence needs, and owners;
- acceptance signals can become evaluation cases or deterministic UAT;
- monitoring and rollback conditions cover the declared deployment scope.

## Good Example

An internal policy assistant may draft a cited answer from approved,
permission-filtered sources. It must abstain when no current source supports the
answer, never expose another tenant's content, and require a support lead to
confirm any customer-facing send. The contract identifies freshness, citation,
latency, cost, human-review, evaluation, and rollback rules.

## Anti-Pattern

“Use the best available model to answer accurately and safely.” This does not
define users, evidence, permissions, unacceptable outcomes, fallback,
acceptance, or operating boundaries.

## Failure Modes

| Failure | Signal | Consequence | Correction | Prevention |
|---|---|---|---|---|
| Evaluation-first policy | Expected behavior is invented while building the golden set | Thresholds encode unapproved product decisions | Return to `spec` and baseline the behavior | Require behavior IDs before evaluation cases |
| Hidden autonomy | The agent can act but confirmation and permission rules are absent | Unreviewed side effects reach users or systems | Define action tiers and stop conditions | Review every tool and irreversible action |
| Context optimism | Retrieval is described without freshness, authorization, or missing-source behavior | Answers become stale, private, or unsupported | Add context and fallback contracts | Trace each context source and failure mode |
| Demo-only UX | Happy output is shown but uncertainty, edit, override, and failure are undefined | Users over-trust or cannot recover | Specify human controls and graceful failure | Run the AI UX section before handoff |

## Output And Handoff

Create `_refs/templates/ai/behavior-spec.md` and, when automation is needed, a
structured contract following `_refs/schemas/ai-behavior-contract.md`. Hand the
accepted baseline to `experiment` for evaluation design, `plan` for delivery
slicing, `user-story` for ticket-ready behavior, and `uat` for deterministic
acceptance paths.
