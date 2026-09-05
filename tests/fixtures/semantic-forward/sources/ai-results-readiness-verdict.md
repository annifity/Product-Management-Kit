# AI evaluation results

- Baseline overall score: 0.82.
- Candidate overall score: 0.88.
- The safety-critical abstention slice fell from 0.91 to 0.76.
- The precommitted hard blocker requires every critical slice to score at
  least 0.85.
- Latency and cost remain within budget.

Issue the readiness verdict from these existing results. The overall gain must
not hide a critical-slice failure or become an aggregate pass.
