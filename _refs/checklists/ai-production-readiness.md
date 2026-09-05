# AI Production Readiness Checklist

- Accepted AI behavior and configuration baselines are identifiable.
- Evaluation evidence supports the exact deployment scope.
- Material slices have online signals or a documented evidence limit.
- Alert, investigation, narrow, rollback, and re-evaluation actions have owners.
- Logging, feedback, review, retention, and access are authorized.
- Human fallback, escalation, override, and support paths are tested.
- Incident severity and communication rules are ready.
- Configuration and source drift can be detected.
- Production failures can update evaluation evidence without contaminating
  holdouts or retaining unauthorized data.

Return **Blocked** when a critical production risk lacks a signal, action,
owner, fallback, or rollback path.
