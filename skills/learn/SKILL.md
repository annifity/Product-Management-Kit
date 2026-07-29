---
name: learn
description: Synthesize completed discovery, prototype, experiment, validation, release, or post-ship evidence into reusable insight and a product decision. Use for insight summaries, retrospectives, decision memos, roadmap recommendations, and next-loop recommendations after evidence has been assessed. Use `validate` for the readiness/result verdict itself; use `learn` to interpret what the evidence means and what to do next.
---

# Learn

Convert assessed evidence into insight, a decision, and the next learning loop.

## Input Contract

Reuse the supplied evidence, validation result, hypothesis, decisions, and memories. Require assessed evidence tied to a product question; if it is missing, stop and request it, and route raw, unevaluated evidence to `validate` first. Ask only for material gaps, continue with labeled assumptions for non-blocking gaps, and state confidence when evidence is partial.

## Process

1. Read the experiment plan, validation notes, evidence, decisions, docs, and relevant memories.
2. Run the material-decision preflight for evidence authority, learning consumer, decision mode, and destination.
3. Separate observations from interpretations and recommendations.
4. Compare results to the original hypothesis, success metrics, and decision criteria.
5. For prototype feedback, summarize feedback, evidence strength, validated value, usability issues, requested changes, risks, and recommendation.
6. Identify reusable insights, product implications, and unresolved questions.
7. Apply source-backed minimality and recommend iterate prototype, write PRD, specify, plan, ship, park, reject, or run another experiment.
8. Ask `docs` to save the artifact and `memories` to persist durable outcomes.

## Output

- Insight summary
- Evidence reviewed
- Confidence and evidence limits
- Decision memo
- Product retrospective when relevant
- Roadmap recommendation
- Memory updates
- Next loop or delivery action

## Reference Routing

Load only references needed for the evidence and output:

- For workflow or packaged handoff, use `_refs/workflows/learning-synthesis.md`, `_refs/operating-model/learning-loop.md`, and `_refs/operating-model/builder-packs.md` selectively.
- Before synthesis, resolve `_refs/schemas/artifact-generation-contract.md` through `_refs/operating-model/artifact-profile-resolution.md`, then use `_refs/checklists/material-decision-preflight.md`; before handoff, use `_refs/checklists/source-backed-minimality.md`.
- Resolve governed evidence packages and source artifacts through `_refs/operating-model/authoritative-baseline-resolution.md` before interpreting them.
- For prototype-first evidence, use `_refs/workflows/prototype-first.md` and `_refs/templates/prototype/prototype-feedback-summary.md`.
- For the requested learning artifact, use `_refs/templates/learning/insight-summary.md`, `_refs/templates/learning/product-retrospective.md`, `_refs/templates/learning/decision-memo.md`, and/or `_refs/templates/learning/roadmap-recommendation.md`.
- For durable decision outcomes, use `_refs/templates/memories/decision-outcomes.md` and `_refs/templates/docs/decision-ledger.md`.
- When checking whether learning supports another loop or entry into delivery, use `_refs/operating-model/phase-gates.md`.

## Handoff

Hand off assessed evidence, observations, interpretations, the product decision, roadmap implication, confidence, and unresolved questions. Route to `spec` for delivery definition, `prototype` or `experiment` for another learning loop, `plan` when scope is already delivery-ready, or `ship` when only launch and handoff work remain.
