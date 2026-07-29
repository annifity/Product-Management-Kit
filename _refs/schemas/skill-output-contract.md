# Skill Output Contract

Use this machine-readable contract to prove that every canonical Annifity skill
defines what it accepts, what it returns, and what a downstream consumer
receives. This complements prompt fixtures; it does not replace semantic
forward tests.

## Contract Shape

```json
{
  "schemaVersion": "1.0",
  "skills": [
    {
      "skill": "user-story",
      "input": {
        "requiredTerms": ["Reuse", "partial", "missing"]
      },
      "output": {
        "requiredTerms": ["ticket", "generation receipt", "TBD"]
      },
      "handoff": {
        "requiredTerms": ["execution", "uat", "acceptance"]
      },
      "templates": [
        {
          "path": "_refs/templates/user-story/default-user-story.md",
          "requiredTerms": [
            "As a [user]",
            "Acceptance Criteria",
            "AC-01",
            "generation receipt"
          ]
        }
      ]
    }
  ]
}
```

The manifest must contain exactly one record for each canonical skill.
`Input Contract`, `Output`, and `Handoff` are required H2 sections in every
`SKILL.md`. Required terms are evaluated inside the named section, not across
the whole file, so a reference link cannot accidentally satisfy an output
obligation.

Each primary template named by a skill must list the fields needed to fulfill
that skill's output or handoff. Template assertions check field labels,
identifiers, generation evidence, or actionable placeholders—not merely that a
heading exists. Skills without a primary artifact template may use an empty
template list only when their Output section is self-contained.

## Change Rule

When an output, template, or handoff changes:

1. update the canonical skill;
2. update its primary template when applicable;
3. update the machine-readable contract in the same change;
4. add or update a semantic forward case when product meaning could change;
5. run output conformance, skill validation, synchronization, and the full
   repository check.

## Failure Modes

| Failure | Signal | Consequence | Correction | Prevention |
|---|---|---|---|---|
| Heading-only compliance | Sections exist but required fields do not | Handoff still needs manual reconstruction | Add field-level obligations | Validate terms inside each section and template |
| Template drift | Skill promises data absent from its template | Generated output silently omits it | Update skill/template together | Bind template fields in the manifest |
| Partial skill coverage | Only common artifact skills are tested | A long-tail skill regresses unnoticed | Add all canonical skills | Exact set equality is a hard gate |
| Cross-section false pass | A term appears only in Reference Routing | Output contract looks satisfied | Scope assertion to the section | Parse H2 section boundaries |

