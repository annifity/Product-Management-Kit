# Phase Gates

Use `_refs/schemas/initiative-state.md` when a phase gate changes the durable state of an initiative.

## Discovery Gate

Proceed only when problem, users, outcome, scope, assumptions, and open questions are explicit.

## Brief Gate

Proceed only when problem, goals, target users, scope boundaries, success metrics, AI-specific requirements when relevant, edge cases, risks, and open questions are explicit.

## Prototype Gate

Proceed only when the prototype has a clear learning objective, minimum user flow, screen list, prompt or wireframe package, exclusions, and validation method.

## Experiment Gate

Proceed only when hypothesis, method, participants or sample, tracking plan, success metrics, guardrails, and decision criteria are explicit. Material evidence should be captured with `_refs/templates/docs/evidence-ledger.md`.

## Validate Gate

Proceed only when results have been compared against the agreed criteria, blockers are separated from improvements, and accepted risks have a named owner.

## Learn Gate

Proceed only when observations, interpretations, decision, roadmap implication, memory updates, and next-loop or delivery action are explicit.

## Spec Gate

Proceed only when requirements are testable, scope boundaries are clear, risks are visible, and artifact quality score is reviewed when the work is high stakes.

## Plan Gate

Proceed only when epics, dependencies, milestones, and blockers are known.

## Execution Gate

Escalate to `change` when an answer modifies committed scope or acceptance criteria.

## Ship Gate

Release only when UAT, operational readiness, stakeholder communication, rollback/support, and post-launch memory capture are ready or accepted as risks.
