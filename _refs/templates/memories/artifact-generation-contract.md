# Artifact Generation Contract Memory

Keep one project-wide default at
`.annifity/memories/artifact-profiles/<PROJECT>/defaults.md` and an optional
artifact-specific profile such as
`.annifity/memories/artifact-profiles/<PROJECT>/user-story.md`.

Replace every placeholder before using this profile. Keep values structural and
concise; store explanatory prose after the JSON block.

```json
{
  "schemaVersion": "1.0",
  "profileId": "<project>-<artifact-type>",
  "project": "<PROJECT>",
  "artifactType": "<artifact-type-or-all>",
  "status": "active",
  "values": {
    "outcome": "<decision-or-handoff-enabled>",
    "consumer": {
      "primary": "<primary-consumer>",
      "downstream": []
    },
    "deliverableMode": "<artifact-ready-mode>",
    "sourceAuthority": {
      "primary": "<exact-source-id>",
      "supporting": []
    },
    "baselineTarget": {
      "mode": "<new-artifact|revise-baseline>",
      "artifactId": "<stable-artifact-id-or-empty>"
    },
    "constraints": {
      "noInventedBehavior": true
    },
    "materialDecisions": {
      "actor": "<confirmed-actor>",
      "ownership": "<confirmed-owner>",
      "surface": "<confirmed-surface>",
      "stateModel": "<confirmed-state-model>",
      "storyBoundary": "<confirmed-boundary>",
      "mockupAuthority": "<none|reference|authoritative>"
    },
    "language": "<match-request|en|vi>",
    "template": "<repository-relative-template-path>",
    "destination.pattern": "<repository-relative-output-pattern>",
    "naming.pattern": "<file-or-artifact-naming-pattern>",
    "format.frontmatter": false,
    "baseline.metadataMode": "<frontmatter|registry>",
    "format.diagram": "<none|drawio|mermaid>",
    "identifiers.acceptanceCriteria": "AC-01",
    "sections.required": [],
    "sections.forbidden": []
  },
  "materialKeys": [
    "template",
    "outcome",
    "destination.pattern",
    "naming.pattern",
    "format.frontmatter",
    "baseline.metadataMode",
    "deliverableMode",
    "sourceAuthority",
    "baselineTarget",
    "materialDecisions"
  ],
  "locks": [],
  "questions": []
}
```

## Notes

- Evidence or decision supporting this profile:
- Scope exceptions:
- Owner:
- Last reviewed:

When `format.frontmatter` is `false`, set `baseline.metadataMode` to
`registry`. This preserves stable identity, version, source, lifecycle, and
hash provenance without injecting forbidden YAML into the artifact.
