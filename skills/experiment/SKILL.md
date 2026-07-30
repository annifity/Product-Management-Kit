---
name: experiment
description: Design an evidence-producing product experiment or AI evaluation plan from a hypothesis, brief, prototype, or confirmed AI behavior. Use when the user needs an experiment method, sample logic, success metrics, tracking, guardrails, or an AI golden set, graders, regression thresholds, latency/cost budgets, and precommitted go/iterate/stop criteria before production delivery. Use `validate` after evidence exists to judge results; use `uat` to verify acceptance of already committed deterministic behavior.
---

# Experiment

Design an evidence plan that can resolve a named product uncertainty.

## Input Contract

Reuse the supplied hypothesis, brief, prototype, AI behavior contract, evidence, and constraints. Require a named uncertainty and the decision it should inform; ask only for material gaps that prevent a testable design. Continue with labeled assumptions for non-blocking gaps in audience, metrics, or method.

## Process

1. Read the brief, prototype notes, known evidence, metrics, and assumptions.
2. Run the material-decision preflight for the experiment consumer, evidence authority, method mode, decision, and destination.
3. Write the hypothesis and the decision it should inform.
4. Define success metrics, guardrails, tracking events, and sample size logic.
5. Choose the method: prototype test, concierge test, survey, A/B test, beta, analytics review, interview round, or a versioned AI evaluation suite with representative and adversarial cases.
6. Define go / iterate / park / reject criteria before results arrive and apply source-backed minimality.
7. Recommend `validate` after data is collected.

## Output

- Hypothesis
- Experiment method
- Participants or sample
- Success metrics and guardrails
- Tracking plan
- Decision criteria
- Risks and ethics notes
- AI evaluation suite, graders, slices, and regression budgets when applicable
- Next action

## Reference Routing

Load only references needed for the experiment design:

- For workflow or packaged handoff, use `_refs/workflows/experiment-design.md` and `_refs/operating-model/builder-packs.md`.
- For an AI evaluation plan, use `_refs/workflows/ai-evaluation.md`, `_refs/schemas/ai-evaluation-suite.md`, `_refs/templates/ai/evaluation-plan.md`, and `_refs/checklists/ai-evaluation-release-gate.md`.
- Before design, resolve `_refs/schemas/artifact-generation-contract.md` through `_refs/operating-model/artifact-profile-resolution.md`, then use `_refs/checklists/material-decision-preflight.md`; before handoff, use `_refs/checklists/source-backed-minimality.md`.
- When the hypothesis or prototype source is governed, resolve it through `_refs/operating-model/authoritative-baseline-resolution.md` before designing the experiment.
- For hypothesis and plan structure, use `_refs/templates/experiment/hypothesis.md` and `_refs/templates/experiment/experiment-plan.md`.
- For instrumentation, use `_refs/templates/experiment/tracking-plan.md` and `_refs/schemas/metrics-event.md`.
- For decision thresholds or sampling, use `_refs/templates/experiment/decision-criteria.md` and/or `_refs/templates/experiment/sample-size.md`.
- For evidence persistence, use `_refs/templates/docs/evidence-ledger.md`.
- For sensitive participants, data, accessibility, or ethics, use `_refs/checklists/security-privacy-accessibility.md`.
- When checking experiment readiness or the evidence handoff gate, use `_refs/operating-model/phase-gates.md`.
- For the next learning phase, use `_refs/operating-model/learning-loop.md`.

## Handoff

After results exist, hand the experiment or AI evaluation plan, versioned suite, evidence, tracking limits, guardrails, and pre-set decision criteria to `validate`. Route the resulting verdict and evidence to `learn` for interpretation and the next product decision.
