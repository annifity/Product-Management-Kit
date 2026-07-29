# Artifact State Registry

Use this JSON registry as the machine-readable authority for versioned artifact
identity, lifecycle, content hashes, supersession, and baseline/latest
pointers. Keep it under the workspace, normally at
`.annifity/docs/artifact-state-registry.json`.

The registry supplements human-readable indexes and backlogs. It does not
replace the artifact itself or the accepted decision that authorized a new
baseline.

## Shape

```json
{
  "schemaVersion": "1.0",
  "updated": "2026-07-28",
  "source": "DEC-001",
  "records": [
    {
      "artifactId": "GBIA-US-WFM-002B",
      "version": "1.0",
      "path": ".annifity/docs/user-stories/GBIA-US-WFM-002B_v1.0.md",
      "lifecycle": "superseded",
      "metadataMode": "registry",
      "artifactType": "user-story",
      "documentUpdated": "2026-07-27",
      "documentSource": "GBIA-SPEC-WFM-001",
      "sha256": "64-lowercase-hex-characters",
      "supersedes": []
    },
    {
      "artifactId": "GBIA-US-WFM-002B",
      "version": "1.1",
      "path": ".annifity/docs/user-stories/GBIA-US-WFM-002B_v1.1.md",
      "lifecycle": "baselined",
      "metadataMode": "registry",
      "artifactType": "user-story",
      "documentUpdated": "2026-07-28",
      "documentSource": "DEC-001",
      "sha256": "64-lowercase-hex-characters",
      "supersedes": [
        "GBIA-US-WFM-002B@1.0"
      ]
    }
  ],
  "pointers": [
    {
      "artifactId": "GBIA-US-WFM-002B",
      "baselineVersion": "1.1",
      "baselinePath": ".annifity/docs/user-stories/GBIA-US-WFM-002B_v1.1.md",
      "baselineSha256": "64-lowercase-hex-characters",
      "latestVersion": "1.1",
      "latestPath": ".annifity/docs/user-stories/GBIA-US-WFM-002B_v1.1.md",
      "latestSha256": "64-lowercase-hex-characters",
      "source": "DEC-001"
    }
  ]
}
```

## Registry Contract

| Field | Required | Rule |
|---|---|---|
| `schemaVersion` | Yes | Exact supported schema version. The initial version is `"1.0"`. |
| `updated` | Yes | Registry update date in `YYYY-MM-DD` format. |
| `source` | Yes | Authority for the registry update. |
| `records` | Yes | One immutable version record per `artifactId@version`. |
| `pointers` | Yes | Exactly one baseline/latest pointer set per registered artifact. |

Each record requires:

- `artifactId`: stable identity matching `artifact_id` in document
  frontmatter;
- `version`: exact version matching document frontmatter;
- `path`: workspace-relative Markdown path with no `..` traversal;
- `lifecycle`: `draft`, `reviewed`, `baselined`, `shipped`, or
  `superseded`;
- `metadataMode`: `frontmatter` when document metadata is embedded,
  `registry` when the resolved project profile forbids YAML frontmatter, or
  `legacy-registry` only for an immutable pre-registry artifact that already
  contains legacy frontmatter but lacks the canonical identity contract.
  Omission is treated as `frontmatter` for backward compatibility;
- for `metadataMode: registry` or `legacy-registry`, `artifactType`,
  `documentUpdated`, and `documentSource` carry the document provenance that
  frontmatter would otherwise provide. A decision record also requires
  `decisionStatus`;
- `sha256`: lowercase SHA-256 of the complete file bytes;
- `supersedes`: zero or more predecessor keys in `artifactId@version`
  format.

Each pointer requires:

- the stable `artifactId`;
- exact path, version, and SHA-256 triples for both `baseline` and `latest`;
- `source`, identifying the decision, approval, or controlled update that set
  the pointer.

## Invariants

1. Record keys and paths are unique. Artifact IDs and versions use ordinal,
   case-sensitive identity; case-only variants are distinct and must have
   distinct exact pointers.
2. Exactly one record per artifact is in an active baseline state:
   `baselined` or `shipped`.
3. The baseline pointer matches that active record exactly.
4. The latest pointer resolves to a registered record that is not
   `superseded`. It may point to a draft.
5. Registry hashes match current file bytes.
6. The selected metadata mode is complete: frontmatter agrees with registry
   identity, version, and publication state, or registry metadata supplies
   type, updated date, and document source without modifying a no-frontmatter
   artifact. A superseded record may retain immutable `baselined` or `shipped`
   frontmatter while the registry carries its current `superseded` lifecycle.
7. Supersession stays within one stable artifact, has no missing target,
   self-reference, cycle, or competing successors.
8. A supersession source is currently or historically accepted
   (`baselined`, `shipped`, or `superseded`), and its predecessor is marked
   `superseded`. A historical successor retains its outgoing edge when a later
   version supersedes it, so multi-version lineage remains intact.

`legacy-registry` is migration-only. The complete file hash remains immutable,
the registry supplies canonical identity and provenance, and every legacy
frontmatter field that is present must agree with the registry. Do not use this
mode for newly authored artifacts and do not rewrite a historical document
merely to add `artifact_id`.

## Safe Migration

Run `tools/new-artifact-registry-migration.ps1` with an explicit accepted
evidence manifest. The tool never infers identity, version, lifecycle,
baseline/latest pointers, or supersession from filenames or dates. It may emit
a safe partial candidate: fully evidenced artifact groups are included, while
unselected or invalid Markdown files remain visible in blocked inventory.

Write a candidate only outside `.annifity/docs/`, review it, then apply the
complete Preview -> Confirm -> Apply workflow before replacing the live
registry. A migration report or candidate is not approval to move a baseline.

Identity, version, path, source bytes, and content hash are immutable for one
version record. Lifecycle and pointers are controlled mutable registry state.
Changing a file after registering its hash makes the pointer stale. Publish a
new version through the controlled change workflow; never rewrite historical
bytes or refresh a hash merely to silence a mismatch.

## Resolution Result

A successful resolver result includes:

- stable artifact ID;
- exact baseline and latest workspace paths;
- exact versions and calculated SHA-256 values;
- provenance from the registry, pointer source, and document source;
- an empty diagnostic list.

Any invariant failure produces a blocked result. Ambiguous results must never
fall back to filename or timestamp ordering. Registry metadata is not a weaker
fallback: its exact record, file hash, lifecycle pointer, and source remain
authoritative and auditable.
