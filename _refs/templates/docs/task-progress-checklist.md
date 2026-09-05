# Task Progress Checklist

Use the smallest display that keeps the work understandable. Localize the heading and labels to the user's language.

```markdown
Progress

- [ ] 1. <verifiable outcome>
- [ ] 2. <verifiable outcome>
- [ ] 3. <verifiable outcome>
```

Update an active item without changing its stable number:

```markdown
- [~] 2. <verifiable outcome> — in progress
```

Use concise reason text only when it helps the user act:

```markdown
- [!] 3. Confirm release scope — blocked: approval owner is unknown; next action: name the release approver
- [-] 4. Export to Confluence — skipped: removed from the revised scope
```

At handoff, show the final state or a compact equivalent and name any remaining required item. Do not include raw schema fields, tool logs, or unverified completion claims.
