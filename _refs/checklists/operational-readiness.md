# Operational Readiness Checklist

Use before sprint commitment, release, or support handoff for operationally meaningful features.

- Admin operations: who can configure, correct, pause, retry, or override?
- Support runbook: L1/L2 steps exist for top failure scenarios.
- Escalation path: owner, channel, and SLA are known.
- Monitoring: success, failure, latency, backlog, and stuck-state signals are visible.
- Alerts: critical silent failures have alert thresholds and recipients.
- Manual override: stuck states can be resolved without engineer intervention when feasible.
- Audit trail: important actions and state changes are logged with actor and timestamp.
- Data recovery: rollback, retry, and reconciliation behavior is defined.
- Reporting impact: dashboards, exports, or existing reports affected by the feature are known.
- Launch support: release note, known limitations, and fallback plan are ready.
