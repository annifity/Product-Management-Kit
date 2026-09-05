# AI-Native PM Loop

Use when a product workflow should run as a grounded, auditable AI-assisted operating loop rather than a one-off prompt.

## Learning Loop

1. Retrieve context: load only relevant docs, memories, decisions, evidence, and current initiative state.
2. Frame: state objective, current skill, needed artifacts, assumptions, and approval gates.
3. Produce: create or update the brief, prototype, experiment, spec, design handoff, plan, or release artifact with source traceability.
4. Critique: use `_refs/checklists/artifact-quality-scorecard.md`, risk, edge, UAT, or experiment criteria as appropriate.
5. Validate: check claims against `_refs/templates/docs/evidence-ledger.md`, local sources, prototype results, or experiment results.
6. Learn: capture insight, decision, confidence, and roadmap implication.
7. Handoff: update initiative state, docs index, decisions, open questions, and recommended next skill.

## Skill Path

`discovery -> brief -> prototype -> experiment -> validate -> learn -> spec -> design (when user-visible) -> plan -> execution -> ship`

Skip steps only when the user has already provided the required evidence or explicitly accepts the risk.

## Context Rules

- Do not load the whole repository when a narrower source is enough.
- Persist stable facts to memories; retrieve episodic project context on demand.
- Treat context as attention, not storage.
- For research-heavy work, use Research -> Plan -> Reset -> Implement: synthesize evidence into a high-density plan before implementation.

## Approval Gates

| Gate | Human Approval Needed When |
|---|---|
| Scope baseline | A spec or PRD becomes source of truth. |
| Material change | Scope, timeline, compliance, user impact, or cost changes. |
| External publish | Jira, Confluence, release note, or stakeholder-facing artifact will be updated. |
| Accepted risk | Critical or high risk is not mitigated. |
| Launch | Rollout, rollback, UAT signoff, and support handoff are complete. |

## Observability

Every material workflow should leave:

- Artifact path or external URL.
- Source/evidence links.
- Decision or assumption record.
- Quality score or readiness verdict.
- Open question owner.
- Next action and recommended skill.
