# Security, Privacy, Accessibility, And AI Risk Checklist

Use for specs, plans, UAT, release readiness, and any feature that touches user data, permissions, payments, automation, or AI behavior.

## Data And Privacy

- PII, PHI, financial data, secrets, or sensitive business data are identified.
- Data collection, retention, deletion, and export behavior are defined.
- Data minimization is considered.
- Consent or notice requirements are identified.
- Analytics events avoid sensitive payloads.

## Security And Abuse

- Role-based access control is defined.
- Privilege escalation paths are considered.
- Audit logging is defined for sensitive actions.
- Abuse, fraud, spam, scraping, and misuse vectors are reviewed.
- Rate limits, monitoring, and incident escalation are known when relevant.

## Accessibility

- Keyboard access is considered.
- Screen reader labels and semantic structure are considered.
- Color contrast and non-color status indicators are considered.
- Error states are clear and recoverable.
- Accessibility acceptance scenarios exist for user-facing workflows.

## AI-Specific Risk

- Hallucination or incorrect recommendation risk is named.
- Human-in-the-loop review is defined when decisions are high impact.
- Prompt injection and data leakage paths are considered.
- Model input/output retention and logging are understood.
- Evaluation method and failure fallback are defined.

## Release Gate

For high-risk launches, unresolved security, privacy, accessibility, or AI risks must have:

- Owner.
- Severity.
- Mitigation or accepted-risk rationale.
- Accepted-by.
- Accepted-date.
- Review date or rollback trigger.
