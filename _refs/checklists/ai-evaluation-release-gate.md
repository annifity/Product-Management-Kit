# AI Evaluation Release Gate

Use this checklist to assess an AI evaluation suite, comparable run evidence,
and the release decision it supports.

## Contents

1. [Decision And Ownership Gate](#decision-and-ownership-gate)
2. [Dataset And Coverage Gate](#dataset-and-coverage-gate)
3. [Grader Quality Gate](#grader-quality-gate)
4. [Threshold And Comparison Gate](#threshold-and-comparison-gate)
5. [Result Integrity Gate](#result-integrity-gate)
6. [Hard Blockers](#hard-blockers)
7. [Verdict](#verdict)
8. [Failure Modes](#failure-modes)
9. [Primary Sources](#primary-sources)

## Decision And Ownership Gate

- Product behavior, deployment context, affected users, and release decision are
  explicit.
- Evaluation owner and decision owner are named.
- Risk tier and unacceptable outcomes are declared.
- Accepted requirements and current baseline configurations are identifiable.
- Unmeasured material risks are listed as evidence limits.

## Dataset And Coverage Gate

- Cases trace to approved requirements, sanitized product evidence, known
  failures, or explicit risk hypotheses.
- Normal, boundary, adversarial, and high-impact failure conditions are covered
  where relevant.
- Material user, language, channel, permission, and risk slices are declared.
- Dataset provenance, version, hash, privacy class, and authorization are known.
- Holdout exposure and synthetic-data use are visible.
- Excluded conditions and generalization limits are stated.

## Grader Quality Gate

- Each criterion uses a fit-for-purpose deterministic, human, or
  model-assisted grader.
- Rubrics define observable pass, fail, and unscorable outcomes.
- Automated graders include positive and negative grader tests.
- Subjective or high-impact model-assisted graders are calibrated against
  qualified human judgment.
- Reviewer disagreement has an adjudication rule.
- Grader versions, configurations, limitations, and owners are recorded.

## Threshold And Comparison Gate

- Thresholds and hard blockers were fixed before candidate results were known.
- Every material slice has a pass rule.
- Critical failures cannot be hidden by an aggregate score.
- Baseline and candidate use comparable suite, dataset, grader, and environment
  versions.
- Stochastic behavior has a declared repeat and uncertainty policy.
- Non-regression, latency, and cost rules are present or explicitly not
  applicable.

## Result Integrity Gate

- Run IDs and configuration fingerprints are reproducible.
- Results include per-case, per-grader, per-slice, and aggregate outcomes.
- Execution errors, missing evidence, unscorable cases, and grader disagreement
  are not counted as passes.
- Failure taxonomy and severity are applied consistently.
- No prior run or failed evidence was overwritten or omitted.
- Residual risks, rollback signals, and monitoring needs are explicit.

## Hard Blockers

Return **Blocked** when any applicable condition holds:

- a critical safety, privacy, permission, or irreversible-action case fails;
- required evaluation data is unauthorized, materially unrepresentative, or
  lacks provenance;
- the release threshold was chosen or relaxed after candidate results without a
  new version and rerun;
- baseline and candidate results are not comparable;
- a material user/risk slice has no coverage or pass rule;
- a high-impact subjective criterion relies only on an uncalibrated automated grader;
- required fallback, human escalation, override, or rollback behavior is
  missing or fails;
- evidence is insufficient to support the requested deployment scope.

An explicit risk acceptance cannot convert missing or invalid evidence into a
passing measurement. It may permit a narrower deployment only when a named
owner, scope limit, monitoring signal, expiry, and rollback action are recorded.

## Verdict

- **Ready**: all applicable gates pass; no hard blocker remains; the evidence
  supports the declared deployment scope.
- **Needs revision**: the suite or evidence has repairable gaps, and no proposed
  release should proceed until the named repairs are complete.
- **Blocked**: a hard blocker, invalid comparison, unauthorized evidence, or
  unsupported deployment claim remains.

Report the exact suite/run versions, failed criteria and slices, evidence
limits, residual risks, risk owners, permitted deployment scope, rollback
condition, and next review date.

## Failure Modes

| Failure | Signal | Consequence | Correction | Prevention |
|---|---|---|---|---|
| Missing deployment claim | Verdict says "model is good" without use case or scope | Evidence is applied beyond tested conditions | Restate the bounded deployment decision | Require context and scope at the gate |
| Silent slice regression | Aggregate passes but one language or permission slice declines | A specific user group receives degraded behavior | Block or narrow release and repair the slice | Require per-slice thresholds |
| Reviewer laundering | Model score is presented as independent assurance | Bias or shared failure modes remain hidden | Add human calibration and adjudication | Inspect grader type and calibration evidence |
| Cost-quality blind spot | Quality improves while latency or cost breaches viability | Product becomes unusable or unsustainable | Apply the precommitted budgets | Treat budgets as release criteria |

## Primary Sources

- [NIST AI RMF Core — Measure and Manage](https://airc.nist.gov/airmf-resources/airmf/5-sec-core/)
- [NIST AI RMF 1.0](https://www.nist.gov/publications/artificial-intelligence-risk-management-framework-ai-rmf-10)
- [Google Responsible Generative AI evaluation guidance](https://ai.google.dev/responsible/docs/evaluation)

This gate is an independent, tool-agnostic Annifity implementation.
