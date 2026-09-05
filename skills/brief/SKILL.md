---
name: brief
description: Create a concise product-direction brief or Product Requirements Outline from confirmed discovery. Use for a one-page alignment artifact covering problem, users, goals, scope, metrics, assumptions, and risks before prototype, experiment, or detailed requirements. Use `discovery` first when the problem, users, or outcome are still unconfirmed. Use `brief` for pre-delivery direction; use `prd` for a formal PRD/BRD and `spec` for implementation-ready rules and behavior.
---

# Brief

Produce the smallest alignment artifact that preserves a confirmed direction without expanding it into delivery detail.

## Input Contract

Reuse the confirmed discovery context, evidence, decisions, and project profile already supplied. If the problem, target user, outcome, or direction is not confirmed, stop and route to `discovery`; accept other partial input and expose only material gaps rather than inventing delivery detail.

## Process

1. Read the confirmed discovery context, relevant docs, memories, and evidence.
2. Run the material-decision preflight for the brief consumer, source authority, scope, mode, and destination; clarify only gaps that change direction or the handoff.
3. Produce a one-page brief with explicit assumptions and open questions.
4. Apply source-backed minimality and keep implementation detail out unless it affects feasibility, compliance, or learning.
5. Resolve the Brief Gate approval through `_refs/operating-model/phase-gates.md`. Reuse a valid recorded approval only while its source, evidence, and material decisions remain unchanged; otherwise ask for a fresh decision before moving to `prototype`, `experiment`, or `spec`.

## Output

- Problem
- Goals and non-goals
- Target users
- Scope in / scope out
- Success metrics
- AI-specific requirements when relevant
- Edge cases and risks
- Assumptions and open questions
- Recommended next skill

## Reference Routing

Load only references needed for the request:

- For skill choice or packaged handoff, use `_refs/operating-model/routing.md` and `_refs/operating-model/builder-packs.md`.
- Before authoring, resolve `_refs/schemas/artifact-generation-contract.md` through `_refs/operating-model/artifact-profile-resolution.md`, then use `_refs/checklists/material-decision-preflight.md`; before handoff, use `_refs/checklists/source-backed-minimality.md`.
- When direction depends on a governed source, resolve it through `_refs/operating-model/authoritative-baseline-resolution.md`; do not prefer a newer unaccepted draft.
- For the brief structure, use `_refs/templates/prd/one-pager.md`.
- For measurable outcomes, use `_refs/templates/metrics/metric-tree.md`.
- For AI context or agent behavior, use `_refs/templates/ai/context-manifest.md`.
- When the direction depends on AI, carry forward the suitability decision, minimum autonomy, risk tier, and evidence burden from `_refs/workflows/ai-suitability-risk-framing.md` and `_refs/checklists/ai-suitability-risk-gate.md`.
- When checking whether the confirmed direction can leave the brief phase, use `_refs/operating-model/phase-gates.md`.
- For analysis, edge cases, or governance gaps, use `_refs/checklists/business-analysis.md`, `_refs/checklists/edge-cases.md`, and `_refs/checklists/stakeholder-governance.md` selectively.
- For multi-phase AI-native work or learning-loop handoff, use `_refs/workflows/ai-native-pm-loop.md` and `_refs/operating-model/learning-loop.md`.

## Handoff

Hand off the confirmed one-page brief with problem, users, goals, scope, metrics, assumptions, risks, and open questions. Route it to `prototype` for build-to-learn, `experiment` when hypothesis and metrics are testable, or `spec` only when the delivery-entry gate is satisfied.
