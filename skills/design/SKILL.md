---
name: design
description: Turn an accepted product specification into a traceable UX/UI design package and delivery handoff. Use when confirmed requirements must become information architecture, user flows, screens, interaction and state behavior, responsive rules, accessibility obligations, or a design-system-bound handoff before planning or implementation. Use `prototype` for build-to-learn mockups before behavior is confirmed; use `validate` to audit an existing design; route design-discovered changes to accepted behavior through `change`.
---

# Design

Translate accepted product behavior into a reviewable interface contract without promoting visual invention into product scope.

## Input Contract

Reuse the supplied accepted spec, authoritative baseline, requirement IDs, roles, workflows, design authority, target surfaces, brand constraints, and existing design system. Require confirmed user-visible behavior and source authority; route unstable requirements to `spec` or committed-scope changes to `change`. Accept partial visual direction and continue with labeled, reversible defaults unless a missing choice would alter behavior, accessibility, brand authority, or handoff acceptance.

## Process

1. Resolve the accepted source through the authoritative baseline registry and resolve the artifact-generation contract, project profile, design authority, destination, and deliverable mode. Take artifact ID, version, and lifecycle from the resolver result. If resolution is blocked, use the document's declared identity metadata only to describe the candidate; never extract a version from its provenance or `source` prose.
2. Extract in-scope users, jobs, requirements, workflows, rules, permissions, states, NFRs, and exclusions. Record each unsupported or conflicting design need as a design gap.
3. Apply `_refs/workflows/spec-to-design.md` to produce the design brief, information architecture, flows, screen inventory, interaction/state matrix, and requirement traceability.
4. Bind the package to an existing design system when one is authoritative. Create only a provisional visual system when authority permits; never let tokens or mockups redefine accepted behavior.
5. Specify responsive behavior, content, accessibility, role and permission handling, and AI-native interaction states when applicable.
6. Run design readiness and quality checks. Resolve the Design Gate before handing the package to delivery planning or implementation.
7. Return a short, localized result stating what was created, whether the supplied source is approved for design, the concrete blocker, and the next business action. Translate the Design Gate into “ready for design” or “not yet ready for design.” Name a receiving skill or internal phase only after explaining what work it performs. Keep machine audit details out of the user-facing result unless diagnostics are explicitly requested.

## Decision Points

- If the goal is learning from an unconfirmed direction, route to `prototype`.
- If a screen needs behavior, permission, state, or data not present in the accepted source, stop that portion and route the gap to `spec` or `change`.
- If no design system exists, use low-fidelity structure by default; create a provisional visual direction only when design authority and brand constraints permit it.
- If the user asks only for an independent review of an existing design, route to `validate`.
- Treat tool choice such as Figma, Stitch, or local HTML as a target adapter decision, not a product-behavior decision.

## Output

- Design Handoff Pack with human-readable source baseline
- Design contract, artifact manifest, and declared design authority
- Information architecture, user flows, and screen inventory
- Screen specifications and interaction/state coverage
- Design-system binding or labeled provisional visual direction
- Responsive, accessibility, content, permission, and applicable AI-native UX obligations
- Spec-to-design traceability and design-gap register
- Design Gate status, assumptions, evidence limits, and concise user-facing result

Keep machine audit details internal unless diagnostics are explicitly requested.

## Reference Routing

- For an ambiguous front door, use `_refs/operating-model/routing.md`.
- For the end-to-end conversion, use `_refs/workflows/spec-to-design.md`.
- For behavior coverage and stable IDs, use `_refs/schemas/design-contract.md`; use `_refs/schemas/design-artifact-manifest.md` when a multi-file package needs a machine-readable inventory.
- For the primary package, use `_refs/templates/design/design-handoff.md`. Use `_refs/templates/design/design-brief.md`, `_refs/templates/design/interaction-state-matrix.md`, and `_refs/templates/design/design-system.md` only when that surface is required.
- Use `_refs/templates/design/screen-design.md` for a compact screen-architecture mode and `_refs/templates/design/screen-spec.md` for delivery-grade action and state detail. Use `_refs/templates/design/design-traceability.md` for lightweight bidirectional mapping and `_refs/templates/design/spec-design-traceability.md` when coverage counts and the full source chain are required.
- Use `_refs/templates/design/portable-html.html` only when the user explicitly selects a portable, click-through local HTML preview; it renders real screen and state toggling with plain HTML/CSS/JS (no network calls), but the preview remains a design artifact, not production frontend code.
- Create or validate that package with `tools/new-design-package.ps1` and
  `tools/validate-design-package.ps1`; never overwrite an existing package
  without the controlled mutation workflow.
- Before authoring, resolve `_refs/schemas/artifact-generation-contract.md` through `_refs/operating-model/artifact-profile-resolution.md`, then use `_refs/checklists/material-decision-preflight.md` and `_refs/operating-model/authoritative-baseline-resolution.md`.
- Before handoff, use `_refs/checklists/design-readiness.md`, `_refs/checklists/design-quality.md`, `_refs/checklists/source-backed-minimality.md`, and the Design Gate in `_refs/operating-model/phase-gates.md`. Use `_refs/templates/design/design-review.md` when recording the gate review.
- When a design choice creates a material product commitment (irreversible pattern, accessibility trade-off, permission model), use `_refs/workflows/pm-decision-challenge.md`, `_refs/templates/skills/method-selection-record.md`, and `_refs/checklists/pm-decision-quality.md` before handoff.
- For security, privacy, accessibility, or material AI behavior, selectively use `_refs/checklists/security-privacy-accessibility.md`, `_refs/schemas/ai-behavior-contract.md`, and `_refs/templates/ai/behavior-spec.md`.

## Handoff

Route the accepted Design Handoff Pack to `plan` for delivery sequencing or to `user-story` for ticket-ready decomposition when the Design Gate passes. Provide `execution` with the exact design contract, source IDs, states, gaps, and design-system binding. Route an independent design-readiness verdict to `validate`; route any change to accepted scope, behavior, permission, or acceptance through `change`.
