---
name: ship
description: Prepare and coordinate a product release, rollout, retirement, or final stakeholder/support handoff. Use when the requested outcome is a ship package such as a launch or EOL plan, release notes, rollback/support notes, final document bundle, UAT signoff summary, or post-ship capture. Use `validate` for a read-only readiness audit without package creation and `uat` to create or execute acceptance tests.
---

# Ship

Assemble the evidence, communication, operational controls, and ownership needed to release or retire safely.

## Input Contract

- Reuse final artifacts, decisions, risk acceptances, and release context supplied inline or by file.
- Accept partial evidence and report missing readiness inputs as blockers; ask only for a gap that could change the verdict or release action.
- Label assumptions and evidence limits. Never treat missing evidence as a passed gate.

## Process

1. Read final PRD/spec/stories/UAT and latest decisions.
2. Verify the Ship Gate using release, operational, security, privacy, accessibility, stakeholder, rollback, support, and post-launch checks that apply.
3. Do not return a release-ready verdict while a required item is missing unless the residual risk is explicitly accepted by a named owner.
4. Produce the ship, rollout, retirement, or handoff package the user needs.
5. Before any external release, deployment, publication, or retirement action, preview the target, action, owner, timing, and rollback path and obtain explicit user approval.
6. Ask `docs` to export/index final artifacts.
7. Ask `memories` to save lessons learned, outcomes, accepted risks, and final decisions.

## Output

- Release readiness verdict
- Open blockers
- Final artifact list
- Release note
- Rollout, rollback, and support notes
- Stakeholder summary
- UAT signoff summary
- Accepted risks and named owners
- External action approval status
- Post-ship memory updates

## Reference Routing

Load only references needed for the release or handoff:

- For route, package scope, or release workflow, use `_refs/operating-model/routing.md`, `_refs/operating-model/builder-packs.md`, and `_refs/workflows/release-readiness.md` selectively.
- For the release decision, use the Ship Gate in `_refs/operating-model/phase-gates.md`.
- For ship or operational gates, use `_refs/checklists/ship-readiness.md` and/or `_refs/checklists/operational-readiness.md`.
- For stakeholder, security, privacy, or accessibility signoff, use `_refs/checklists/stakeholder-governance.md` and `_refs/checklists/security-privacy-accessibility.md` as applicable.
- For unresolved release risks or cross-artifact coverage, use `_refs/templates/risk/risk-register.md` and/or `_refs/templates/traceability/rtm.md`.
- For rollout and release communication, use `_refs/templates/release/rollout-plan.md` and `_refs/templates/docs/release-note.md`.

## Handoff

When the Ship Gate passes and any external action is explicitly approved, hand the release package, ownership, timing, rollback path, and accepted risks to the named release owner. If blockers remain, route the evidence to `uat`, `execution`, or `change` according to the gap. After release evidence exists, route outcomes to `learn` and durable records to `memories`.
