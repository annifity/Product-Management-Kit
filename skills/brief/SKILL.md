---
name: brief
description: Create a concise product-direction brief or Product Requirements Outline from confirmed discovery. Use for a one-page alignment artifact covering problem, users, goals, scope, metrics, assumptions, and risks before prototype, experiment, or detailed requirements. Use `brief` for pre-delivery direction; use `prd` for a formal PRD/BRD and `spec` for implementation-ready rules and behavior.
---

# Brief

Produce the smallest alignment artifact that preserves a confirmed direction without expanding it into delivery detail.

## Process

1. Read the confirmed discovery context, relevant docs, memories, and evidence.
2. Clarify only material gaps in problem, users, goals, scope, metrics, AI behavior, or risks.
3. Produce a one-page brief with explicit assumptions and open questions.
4. Keep implementation detail out unless it affects feasibility, compliance, or learning.
5. Ask for confirmation before moving to `prototype`, `experiment`, or `spec`.

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
- For the brief structure, use `_refs/templates/prd/one-pager.md`.
- For measurable outcomes, use `_refs/templates/metrics/metric-tree.md`.
- For AI context or agent behavior, use `_refs/templates/ai/context-manifest.md`.
- When checking whether the confirmed direction can leave the brief phase, use `_refs/operating-model/phase-gates.md`.
- For analysis, edge cases, or governance gaps, use `_refs/checklists/business-analysis.md`, `_refs/checklists/edge-cases.md`, and `_refs/checklists/stakeholder-governance.md` selectively.
- For multi-phase AI-native work or learning-loop handoff, use `_refs/workflows/ai-native-pm-loop.md` and `_refs/operating-model/learning-loop.md`.

## Handoff

Hand off the confirmed one-page brief with problem, users, goals, scope, metrics, assumptions, risks, and open questions. Route it to `prototype` for build-to-learn, `experiment` when hypothesis and metrics are testable, or `spec` only when the delivery-entry gate is satisfied.
