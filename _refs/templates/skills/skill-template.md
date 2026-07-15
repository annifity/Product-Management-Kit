# Canonical Skill Template

Use this template only after `_refs/operating-model/skill-authoring.md` confirms that a distinct front-door skill is necessary. Replace every angle-bracket placeholder and delete optional sections that do not change behavior.

```markdown
---
name: <lowercase-kebab-name>
description: <Action or outcome>. Use when <recognizable user situations>. Route <nearest different intent> to <neighboring-skill>.
---

# <Human-Readable Name>

<One sentence that sets the execution scope without repeating the trigger catalog.>

## Input Contract

- Reuse context supplied inline, in files, or in confirmed prior decisions.
- Accept complete, partial, or missing context.
- Ask only for a missing fact that materially changes the result; otherwise continue with labeled assumptions.

## Process

1. <Load only relevant context.>
2. <Classify the request or choose a branch.>
3. <Execute the smallest reliable sequence.>
4. <Apply the quality or phase gate.>
5. <Prepare the handoff.>

## Decision Points

- If <condition>, <action and rationale>.
- If <stop or escalation condition>, <route or approval needed>.

## Output

- <Observable output field or artifact>
- Assumptions and evidence limits
- Decision, owner, or next action when relevant

## Reference Routing

- Use the minimum relevant files from `_refs/`; give each route a condition.
- Use `_refs/checklists/skill-quality.md` before synchronization.

## Handoff

Route to `<next-skill>` when <minimum gate state>. Route committed-scope changes to `change`.
```

For a new front door, also create canonical `agents/openai.yaml` with a quoted display name, a 25-64 character short description, and a one-sentence default prompt that explicitly mentions the new skill token (for example, `$brief`).

Do not add unsupported frontmatter, copied external examples, placeholder-only references, or platform adapter files to the canonical skill folder. `agents/openai.yaml` is canonical UI metadata, not an adapter.
