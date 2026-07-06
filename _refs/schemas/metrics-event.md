# Metrics Event Schema

Use to define experiment, prototype, and product analytics events consistently.

```yaml
event_name: feature_action
description: [What behavior this event captures]
trigger: [When the event fires]
owner: [Team or role]
properties:
  property_name:
    type: string | number | boolean | enum | timestamp
    required: true
    description: [Meaning]
quality_checks:
  - [Validation rule]
privacy_notes:
  - [PII, consent, retention, or masking note]
```

## Naming Rules

- Use lowercase snake_case.
- Name the user behavior, not the UI element.
- Keep event properties stable across experiment and production when possible.
- Do not include PII unless there is explicit legal and product approval.
