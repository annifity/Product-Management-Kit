---
name: experiment
description: Use when a product hypothesis, prototype, or brief needs a validation experiment with success metrics, tracking plan, decision criteria, sample size, learning plan, or evidence design. Applies before building production scope and differs from UAT, which verifies acceptance of committed delivery.
---

# Experiment

Use this to design how the team will test a product hypothesis with real evidence.

## Process

1. Read the brief, prototype notes, known evidence, metrics, and assumptions.
2. Write the hypothesis and the decision it should inform.
3. Define success metrics, guardrails, tracking events, and sample size logic.
4. Choose the experiment method: prototype test, concierge test, survey, A/B test, beta, analytics review, or interview round.
5. Define go / iterate / park / reject criteria before results arrive.
6. Recommend `validate` after data is collected.

## Output

- Hypothesis
- Experiment method
- Participants or sample
- Success metrics and guardrails
- Tracking plan
- Decision criteria
- Risks and ethics notes
- Next action

## Required References

- `_refs/workflows/experiment-design.md`
- `_refs/templates/experiment/hypothesis.md`
- `_refs/templates/experiment/experiment-plan.md`
- `_refs/templates/experiment/tracking-plan.md`
- `_refs/templates/experiment/decision-criteria.md`
- `_refs/templates/experiment/sample-size.md`
- `_refs/schemas/metrics-event.md`
- `_refs/templates/docs/evidence-ledger.md`
- `_refs/operating-model/learning-loop.md`

## Handoff

Use `validate` to review results against the pre-set criteria, then `learn` to synthesize insight and decide whether to iterate, specify, plan, or stop.
