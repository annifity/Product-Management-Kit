# AI Production Monitoring And Improvement

Use after an AI behavior is approved for a bounded deployment.

## Decision Supported

Decide whether deployed AI behavior remains within its accepted quality, risk,
cost, and scope boundaries and when to investigate, roll back, or re-evaluate.

## Process

1. Load the accepted AI behavior contract, evaluation verdict, deployment
   scope, monitoring owner, and rollback conditions.
2. Define online signals for task success, groundedness, safety, permissions,
   abstention, escalation, latency, cost, and human-review load.
3. Preserve material user, language, channel, permission, and risk slices.
4. Set alert, investigation, rollback, and re-evaluation thresholds before
   production evidence is reviewed.
5. Define privacy-safe logging, sampling, retention, access, redaction, and
   authorized expert-review queues.
6. Classify incidents and near misses; link confirmed failures to behavior
   rules, evaluation cases, product metrics, and change records.
7. Detect drift in inputs, sources, retrieval coverage, configuration,
   outcomes, graders, and user behavior.
8. Route material model, prompt, retrieval, tool, policy, data, or scope changes
   through `change` and rerun the required evaluation.
9. Send assessed evidence to `learn`; expand the golden set only from
   authorized, reviewed evidence.

## Decision Rules

- **Continue:** signals and slices stay within accepted bounds.
- **Investigate:** evidence is incomplete or a warning threshold is crossed.
- **Narrow:** one slice or action boundary cannot support the current scope.
- **Rollback:** a hard blocker, critical incident, or rollback trigger occurs.
- **Re-evaluate:** configuration, context, risk, user population, or failure
  taxonomy changes materially.

## Failure Modes

| Failure | Signal | Consequence | Correction | Prevention |
|---|---|---|---|---|
| Aggregate-only monitoring | Overall quality is stable while one slice degrades | Affected users receive silent harm | Restore slice dashboards and thresholds | Mirror evaluation slices |
| Feedback landfill | User feedback is stored without triage or authority | Noise and private data contaminate learning | Add review, redaction, and disposition | Define feedback governance |
| Configuration drift | Prompt or retrieval changes without a new fingerprint | Evidence no longer matches production | Baseline the change and re-evaluate | Alert on configuration identity |
| Monitor without action | Alerts have no owner or response | Known failures persist | Bind every threshold to action and owner | Test incident and rollback paths |
