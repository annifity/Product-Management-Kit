---
name: ship
description: Prepare and coordinate a product release, rollout, retirement, or final stakeholder/support handoff. Use when the requested outcome is a ship package such as an operational launch or EOL plan, release notes, rollback/support notes, final document bundle, UAT signoff summary, AI release regression gate, or post-ship capture. Use `gtm` for ICP, positioning, channels, enablement, and adoption motion before release operations; use `validate` for a read-only readiness verdict and `uat` to create or execute acceptance tests.
---

# Ship

Assemble the evidence, communication, operational controls, and ownership needed to release or retire safely.

## Input Contract

- Reuse final artifacts, decisions, risk acceptances, and release context supplied inline or by file.
- Accept partial evidence and report missing readiness inputs as blockers; ask only for a gap that could change the verdict or release action.
- Label assumptions and evidence limits. Never treat missing evidence as a passed gate.

## Process

1. Read final PRD/spec/stories/UAT and latest decisions, then run the material-decision preflight for release mode, source baseline, target, owner, and action.
2. Verify the Ship Gate using release, operational, security, privacy, accessibility, stakeholder, rollback, support, post-launch, and AI evaluation regression checks that apply.
3. Do not return a release-ready verdict while a required item is missing unless the residual risk is explicitly accepted by a named owner.
4. Produce the smallest source-backed ship, rollout, retirement, or handoff package that serves the selected mode.
5. Before any external release, deployment, publication, or retirement action, preview the target, action, owner, timing, and rollback path and obtain explicit user approval.
6. Ask `docs` to export/index final artifacts.
7. Ask `memories` to save lessons learned, outcomes, accepted risks, and final decisions.

## Output

- Release readiness verdict
- Open blockers
- Final artifact list
- Release note, or an EOL/retirement plan when the release mode is retirement
- Rollout, rollback, and support notes
- Stakeholder summary
- UAT signoff summary
- Accepted risks and named owners
- External action approval status
- Post-ship memory updates
- AI production monitoring plan when AI is material

## Reference Routing

Load only references needed for the release or handoff:

- For route, package scope, or release workflow, use `_refs/operating-model/routing.md`, `_refs/operating-model/builder-packs.md`, and `_refs/workflows/release-readiness.md` selectively.
- Before producing the package, resolve `_refs/schemas/artifact-generation-contract.md` through `_refs/operating-model/artifact-profile-resolution.md`, then use `_refs/checklists/material-decision-preflight.md` and `_refs/checklists/source-backed-minimality.md`.
- Resolve every controlled release source through `_refs/operating-model/authoritative-baseline-resolution.md`; do not ship from an unaccepted latest draft.
- For the release decision, use the Ship Gate in `_refs/operating-model/phase-gates.md`.
- For ship or operational gates, use `_refs/checklists/ship-readiness.md` and/or `_refs/checklists/operational-readiness.md`.
- For an AI-enabled release or material model, prompt, retrieval, tool, policy, or data change, require an assessed suite using `_refs/schemas/ai-evaluation-suite.md` and `_refs/checklists/ai-evaluation-release-gate.md`; use `_refs/workflows/ai-evaluation.md` when the evidence chain needs inspection.
- For deployed AI behavior, use `_refs/workflows/ai-production-monitoring.md`, `_refs/schemas/ai-production-monitoring-plan.md`, `_refs/templates/ai/production-monitoring-plan.md`, and `_refs/checklists/ai-production-readiness.md`.
- For stakeholder, security, privacy, or accessibility signoff, use `_refs/checklists/stakeholder-governance.md` and `_refs/checklists/security-privacy-accessibility.md` as applicable.
- For unresolved release risks or cross-artifact coverage, use `_refs/templates/risk/risk-register.md` and/or `_refs/templates/traceability/rtm.md`.
- For rollout and release communication, use `_refs/templates/release/rollout-plan.md` and `_refs/templates/docs/release-note.md`. For a retirement or EOL release mode, use `_refs/templates/release/eol-plan.md` instead of the rollout plan.
- For audience, positioning, enablement, launch channels, and adoption, use `_refs/workflows/go-to-market-adoption.md` and `_refs/templates/release/go-to-market-plan.md`; keep release readiness, rollback, and external-action approval in this skill.
- When decision authority, dissent, or cross-team communication is material, use `_refs/workflows/stakeholder-decision-governance.md` with `_refs/templates/strategy/stakeholder-decision-map.md`.

## Handoff

When the Ship Gate passes and any external action is explicitly approved, hand the release package, ownership, timing, rollback path, and accepted risks to the named release owner. If blockers remain, route the evidence to `uat`, `execution`, or `change` according to the gap. After release evidence exists, route outcomes to `learn` and durable records to `memories`.
