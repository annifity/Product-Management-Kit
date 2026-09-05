# AI Unit Economics Checklist

Use when AI materially affects product value, cost, margin, risk, or scale.

## Unit Definition

- [ ] Define the economic unit: request, task, active user, case, workflow, or resolved outcome.
- [ ] Define the value unit and who receives it.
- [ ] Separate fixed build/evaluation costs from variable serving and operational costs.

## Cost Model

- [ ] Model/token, embedding, retrieval, storage, tool, orchestration, and observability costs are included.
- [ ] Human review, exception handling, support, incident, and rework costs are included.
- [ ] Retry, fallback, abuse, long-context, and peak-load scenarios are included.
- [ ] Cost is reported per successful or accepted outcome, not only per model call.

## Value And Margin

- [ ] Baseline deterministic or human workflow cost is known or explicitly unknown.
- [ ] Revenue, retention, conversion, time saved, risk reduction, or service improvement is evidence-linked.
- [ ] Quality-adjusted contribution margin and payback are evaluated at expected and downside volumes.
- [ ] A cheaper model or lower autonomy option is considered where it meets the behavior contract.

## Decision Controls

- [ ] Quality, latency, cost, and autonomy trade-offs have owner-approved thresholds.
- [ ] Cost anomalies, budget breach, and margin deterioration have monitoring and fallback actions.
- [ ] Re-evaluation triggers cover model, prompt, retrieval, tool, data, pricing, and traffic-mix change.
