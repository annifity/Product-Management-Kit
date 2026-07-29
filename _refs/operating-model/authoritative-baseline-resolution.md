# Authoritative Baseline Resolution

Use this procedure before reading, revising, validating, planning from, or
shipping a controlled artifact.

## Inputs

- Stable artifact ID.
- Workspace root.
- Artifact-state registry following
  `_refs/schemas/artifact-state-registry.md`.

Do not ask for a path again when the user already supplied an exact path.
Treat that path as a candidate, then verify it against the registry before
calling it authoritative.

## Resolution Order

1. Load the registry and verify its schema metadata.
2. Validate every registered path remains inside the workspace.
3. Verify the selected metadata mode and SHA-256. For `frontmatter`, verify
   document identity, version, lifecycle, and source. For `registry`, verify
   registry-held artifact type, document update date, and document source.
   For `legacy-registry`, verify the registry-held fields and reject every
   conflicting legacy frontmatter value without requiring a historical file
   rewrite.
4. Validate the supersession graph.
5. Find exactly one `baselined` or `shipped` record for the requested stable
   artifact ID.
6. Verify the baseline pointer matches that record's path, version, and hash.
7. Verify the latest pointer resolves to a non-superseded record.
8. Return baseline, latest, provenance, and diagnostics.

Use `tools/resolve-authoritative-baseline.ps1` for deterministic local
resolution:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File tools/resolve-authoritative-baseline.ps1 `
  -ArtifactId GBIA-US-WFM-002B `
  -RegistryPath .annifity/docs/artifact-state-registry.json `
  -AsJson
```

The command is read-only, dependency-free, and network-free. A resolved result
uses exit code `0`; a blocked result uses exit code `2`.

## Blocking Rules

Block rather than guess when:

- no active baseline exists;
- more than one active baseline exists;
- the pointer is absent or disagrees with the active record;
- the current file hash differs from the registered hash;
- stable identity, version, source, or lifecycle metadata is absent;
- a project forbids frontmatter but the record does not provide complete
  `metadataMode: registry` metadata;
- supersession is missing, ambiguous, cyclic, or crosses stable identities.

An index, backlog, link, filename, or latest draft is supporting evidence only.
It cannot override a valid registry record. When a registry conflict reflects
a real requirement change, route the update through `change`.

For a pre-registry workspace, first run
`tools/new-artifact-registry-migration.ps1` with an accepted evidence manifest.
The output is only a candidate; replace the live registry only through
`_refs/workflows/local-mutation-safety.md`.

## Provenance

Record all three provenance layers:

| Layer | Evidence |
|---|---|
| Registry | Exact registry path plus top-level `source`. |
| Pointer | Exact pointer fields plus the approval or decision in pointer `source`. |
| Document | Exact baseline path plus source from document frontmatter or the record's `documentSource`, according to `metadataMode`. |

This makes the resolved version reproducible and allows a later audit to
distinguish a stale pointer from changed content.

## Failure Modes

| Failure | Signal | Consequence | Correction | Prevention |
|---|---|---|---|---|
| Newest-file guessing | A filename or date is selected without registry proof | Work starts from an unaccepted draft | Resolve by stable ID and active state | Run the resolver before controlled work |
| Dual baseline | Two versions remain `baselined` or `shipped` | Different workflows use different truth | Complete the supersession transition | Enforce one active baseline invariant |
| Silent content drift | Registered SHA-256 differs from file bytes | Approved content cannot be reproduced | Investigate and apply a controlled change | Verify hash at every resolution |
| Broken lineage | Supersession target is missing, cyclic, has two successors, or a historical successor loses its outgoing edge | History and rollback become ambiguous | Repair the registry from accepted evidence | Retain the complete chain and validate the full graph before pointer movement |
| Stale pointer | Pointer still targets a superseded or modified version | Consumers receive old behavior | Move pointer as part of baseline publication | Update record state and pointer atomically |
