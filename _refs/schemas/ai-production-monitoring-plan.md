# AI Production Monitoring Plan Schema

Implement as UTF-8 JSON when automation is required.

Required fields:

- `schemaVersion`, `planId`, `planVersion`, `behaviorBaseline`,
  `evaluationVerdict`, `deploymentScope`;
- `owners`: product, operations, incident, and review owners;
- `signals`: metric, slice, source, cadence, threshold, action, and owner;
- `logging`: authorization, privacy class, redaction, retention, and access;
- `feedback`: channels, sampling, review, adjudication, and disposition;
- `incidents`: severity taxonomy, escalation, communication, and evidence path;
- `drift`: input, source, retrieval, configuration, output, and outcome checks;
- `rollback`: triggers, authority, action, recovery, and verification;
- `reevaluationTriggers`;
- `reviewCadence` and `nextReview`;
- `sourceRefs`.

## Invariants

1. Every signal has a material slice or explicit overall-only rationale.
2. Every threshold has an action and owner.
3. Critical signals have rollback or stop behavior.
4. Production evidence is authorized before it enters an evaluation set.
5. Configuration identity matches the accepted behavior and evaluation
   baselines or triggers re-evaluation.
6. Missing data never counts as a healthy result.
