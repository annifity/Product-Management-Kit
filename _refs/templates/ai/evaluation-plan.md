# AI Evaluation Plan

Use with `_refs/workflows/ai-evaluation.md` and
`_refs/schemas/ai-evaluation-suite.md`. Complete result and verdict sections
only after a traceable run exists.

## Contents

1. [Evaluation Decision](#1-evaluation-decision)
2. [Sources And Baselines](#2-sources-and-baselines)
3. [Deployment Context](#3-deployment-context)
4. [Evaluation Dimensions](#4-evaluation-dimensions)
5. [Dataset And Golden Set](#5-dataset-and-golden-set)
6. [Case Register](#6-case-register)
7. [Graders And Calibration](#7-graders-and-calibration)
8. [Precommitted Thresholds](#8-precommitted-thresholds)
9. [Run Plan](#9-run-plan)
10. [Evidence Limits](#10-evidence-limits)
11. [Results](#11-results)
12. [Verdict](#12-verdict)
13. [Handoff](#13-handoff)

## 1. Evaluation Decision

- Product use case:
- AI-enabled behavior:
- Candidate change:
- Decision this evaluation informs:
- Evaluation owner:
- Decision owner:
- Risk tier:
- Intended deployment scope:
- Unacceptable outcomes:

## 2. Sources And Baselines

| Source ID | Version / Hash | Role | Authority | Path / URL |
|---|---|---|---|---|
|  |  | Requirement / policy / evidence / current configuration | Accepted / supporting |  |

## 3. Deployment Context

- Users and affected communities:
- Channels and languages:
- Permissions and tool/action boundaries:
- Runtime and retrieval context:
- Human review, override, appeal, and fallback:
- Conditions outside the evaluation scope:

## 4. Evaluation Dimensions

| Dimension | Why It Changes The Decision | Metric / Rubric | Risk If Missed |
|---|---|---|---|
| Task quality |  |  |  |
| Groundedness / factuality |  |  |  |
| Safety / privacy / fairness |  |  |  |
| Tool and action correctness |  |  |  |
| Latency |  |  |  |
| Cost |  |  |  |

Delete dimensions that are genuinely not applicable and record the rationale.

## 5. Dataset And Golden Set

- Dataset ID and version:
- Hash or immutable source:
- Provenance and authorization:
- Privacy classification and redaction:
- Holdout and known-exposure policy:
- Synthetic-data use:
- Review date and owner:

| Slice | Why Material | Normal | Boundary | Adversarial | Known Failure | Pass Rule |
|---|---|---:|---:|---:|---:|---|
|  |  |  |  |  |  |  |

## 6. Case Register

| Case ID | Slice | Source | Expected Behavior | Prohibited Behavior | Severity | Grader |
|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |

## 7. Graders And Calibration

| Grader ID | Type | Criterion | Scale | Pass / Unscorable Rule | Calibration Evidence | Adjudication |
|---|---|---|---|---|---|---|
|  | Deterministic / Human / Model-assisted |  |  |  |  |  |

## 8. Precommitted Thresholds

- Overall pass rule:
- Per-slice pass rules:
- Hard blockers:
- Non-regression margin:
- Latency budget or N/A rationale:
- Cost budget or N/A rationale:
- Minimum runs / repeat policy:
- Go rule:
- Limited-rollout rule:
- Iterate rule:
- Stop rule:
- Threshold fingerprint and confirmation:

## 9. Run Plan

- Baseline configuration fingerprint:
- Candidate configuration fingerprint:
- Suite, dataset, and grader versions:
- Controlled environment:
- Randomization / repeat handling:
- Result destination:
- Execution owner and timing:

## 10. Evidence Limits

- Unmeasured risks:
- Missing or unrepresentative slices:
- Grader limitations:
- Generalization limits:
- Assumptions and validation actions:

## 11. Results

| Run ID | Configuration | Overall | Failed Slices | Hard Blockers | Latency | Cost | Evidence Path |
|---|---|---:|---|---|---|---|---|
|  |  |  |  |  |  |  |  |

## 12. Verdict

- Verdict: Ready / Needs revision / Blocked
- Exact suite and run versions:
- Baseline-to-candidate delta:
- Blocking failures:
- Permitted deployment scope:
- Residual risks and named owners:
- Rollback condition:
- Next review date:

## 13. Handoff

- `learn`: interpretation and product decision
- `change`: accepted product behavior or baseline change
- `ship`: release gate and rollout controls
- `docs`: versioned suite, run evidence, and index update
- `memories`: durable decision, risk acceptance, and learning
