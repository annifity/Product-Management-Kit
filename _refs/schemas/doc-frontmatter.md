# Document Frontmatter

Use frontmatter to identify a document and describe its lifecycle state when
the resolved artifact profile permits it. Do not infer identity, version, or
baseline status from the filename.

```yaml
---
artifact_id: GBIA-US-WFM-002B
title: Publish a roster
type: brd | prd | spec | user-story | uat | decision | changelog | release-note | session | traceability | roadmap | risk
status: draft | reviewed | baselined | shipped | superseded
updated: YYYY-MM-DD
source: [Source artifact, accepted decision, ticket, or session]
version: 1.0
owner: [Optional owner]
decision_status: proposed | accepted | rejected | withdrawn | not-applicable
supersedes: [Optional artifact_id@version value]
---
```

## Field Contract

| Field | Required | Meaning |
|---|---|---|
| `artifact_id` | Yes for governed artifacts | Stable identifier shared by every version of the same logical artifact. It must not contain `@`. |
| `title` | Yes | Human-readable title. |
| `type` | Yes | Artifact type from the supported list. |
| `status` | Yes | Lifecycle state only. It must not be used to represent product approval or decision outcome. |
| `updated` | Yes | Date of the last material update in `YYYY-MM-DD` format. |
| `source` | Yes | Authority or evidence used to create the version. |
| `version` | Yes for governed artifacts | Exact version token. Use the same value in the artifact-state registry. |
| `owner` | No | Accountable owner when known. |
| `decision_status` | Required for `decision` | Decision outcome, kept separate from document lifecycle. Use `not-applicable` only on non-decision artifacts when an explicit value is useful. |
| `supersedes` | Required when publishing a replacement | Immediate predecessor expressed as `artifact_id@version`. The machine-readable registry remains authoritative for multi-predecessor changes. |

`artifact_id`, `version`, and `source` are mandatory in frontmatter before a
frontmatter-managed document can be resolved as an authoritative baseline.
When a project profile explicitly forbids YAML frontmatter, set
`metadataMode: registry` on the artifact-state record and store
`artifactType`, `documentUpdated`, and `documentSource` there instead. A legacy
document with neither complete frontmatter nor complete registry metadata may
remain readable, but the baseline resolver must report it as unmanaged rather
than guessing.

Do not store a document's SHA-256 inside its own frontmatter because doing so
would create a self-referential hash. Store the externally calculated hash in
the artifact-state registry defined by
`_refs/schemas/artifact-state-registry.md`.

## Lifecycle Versus Decision Status

- `status` answers where the document is in its publishing lifecycle.
- `decision_status` answers whether the business or product decision was
  accepted.
- A reviewed decision can still be `proposed`; a baselined decision normally
  has `decision_status: accepted`.
- Replacing a baseline changes the old version to `superseded`; it does not
  rewrite the old version's historical decision outcome.

Use `_refs/operating-model/authoritative-baseline-resolution.md` before a
workflow reads or changes a controlled baseline.
