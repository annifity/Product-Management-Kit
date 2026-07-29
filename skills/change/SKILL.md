---
name: change
description: Assess and apply controlled changes to an existing PRD, BRD, spec, user story, UAT package, Jira/Confluence record, or release baseline. Use when scope or requirements change mid-flight and impact analysis, versioned edits, traceable patching, changelog, or stakeholder notification is needed. Use `execution` for delivery clarification that does not change the baseline; route here when committed scope, acceptance, or user-visible behavior changes.
---

# Change

Keep baselined artifacts consistent while recording the reason, impact, owner, and version of each accepted change.

## Input Contract

Reuse the supplied baseline and change context. Require an identifiable current baseline and requested change; ask only for material gaps before assessing impact. Continue through non-blocking gaps with labeled assumptions, but do not apply edits until the change plan is confirmed.

## Process

1. Resolve the current baseline by stable artifact ID and verify its registry path, version, and hash.
2. Run the material-decision preflight for source authority, requested outcome, affected ownership, baseline target, deliverable mode, and destination.
3. Clarify the requested change.
4. Classify change impact: minor, material/medium, or breaking.
5. Assess impact on scope, stories, UAT, Jira tickets, Confluence pages, timeline, dependencies, risk, and release.
6. Draft an impact-aware change plan and fingerprinted local mutation preview; ask for confirmation before applying edits.
7. Revalidate the preview fingerprint, then apply only the confirmed surgical, source-backed edits and prune duplicated or superseded content.
8. Verify the declared end state and affected pointers before asking `docs` to update changelog, spec context, registry, and decision logs.
9. Ask `memories` to persist durable decisions.

## Reference Routing

Load only references needed for the affected baseline and channel:

- For route or change-control rules, use `_refs/operating-model/routing.md` and `_refs/workflows/change-governance.md`.
- Resolve `_refs/schemas/artifact-generation-contract.md` through `_refs/operating-model/artifact-profile-resolution.md`; use `_refs/checklists/material-decision-preflight.md` for source, ownership, mode, and baseline decisions, and `_refs/checklists/source-backed-minimality.md` for the final patch.
- For exact baseline selection, use `_refs/operating-model/authoritative-baseline-resolution.md` with `_refs/schemas/artifact-state-registry.md`.
- For preview, confirmation, application boundaries, and post-change proof, use `_refs/workflows/local-mutation-safety.md`, `_refs/schemas/mutation-preview.md`, and `_refs/checklists/negative-completeness.md`.
- For planning and impact analysis, use `_refs/templates/change/change-plan.md` and `_refs/templates/change/impact-analysis.md`.
- For applying and recording an approved change, use `_refs/templates/change/changelog.md` and `_refs/templates/change/spec-change-context.md`.
- For approval or notification risk, use `_refs/checklists/stakeholder-governance.md`.
- For external artifact updates, use `_refs/integrations/jira.md` and/or `_refs/integrations/confluence.md` only when that system is in scope.

## Output

Return the impact assessment, proposed edits, change plan, exact preview,
baseline disposition, traceability impact, and changelog entries.

## Handoff

Return the approved change to the owning skill (`prd`, `spec`, `user-story`, `uat`, or `ship`) with its impact, updated baseline/version, and unresolved risks; use `execution` for implementation clarification after delivery resumes.
