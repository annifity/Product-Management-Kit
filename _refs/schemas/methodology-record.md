# Methodology Record Schema

Use one record per reusable PM method. Store facts about the method separately from Annifity's independently authored execution guidance.

```yaml
method_id: method-lowercase-kebab
name: Human-readable method name
decision_supported: Decision this method improves
best_when:
  - Observable condition
not_when:
  - Observable exclusion
required_inputs:
  - Input with unit, population, or evidence expectation
outputs:
  - Decision-relevant output
failure_modes:
  - Failure and prevention check
source:
  title: Primary or authoritative source title
  author_or_owner: Source owner
  url: Public source URL when available
  accessed_on: YYYY-MM-DD
license_or_usage_note: Attribution, reuse, or human/legal review note
annifity_adaptation: Independently authored behavior or explicit adapted portion
last_reviewed: YYYY-MM-DD
```

## Rules

- Never infer a license from repository visibility.
- Mark uncertain reuse as `Requires human/legal license review`.
- Cite external factual claims in the method reference.
- A method name or general idea does not justify copying proprietary examples, prose, tables, or decision trees.
- Update `last_reviewed` when sources, formulas, or usage boundaries change.
