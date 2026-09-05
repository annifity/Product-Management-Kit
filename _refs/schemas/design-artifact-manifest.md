# Design Artifact Manifest

Use `design-manifest.json` as the machine-readable authority for one Annifity
design package. Store it at the package root, normally under
`.annifity/docs/designs/<initiative>/<design-id>/`.

## Shape

```json
{
  "schemaVersion": "1.0",
  "designId": "OPS-DES-001",
  "title": "Service request review",
  "status": "draft",
  "mode": "interactive-html",
  "sourceSpec": {
    "artifactId": "OPS-SPEC-001",
    "version": "1.0",
    "path": ".annifity/docs/specs/OPS-SPEC-001_v1.0.md",
    "sha256": "sha256:<64-lowercase-hex>"
  },
  "contractFingerprint": "sha256:<64-lowercase-hex>",
  "designAuthority": {
    "mode": "bound-system",
    "source": "OPS-DS-001@2.1"
  },
  "decisionOwner": "role:product-owner",
  "artifacts": [
    {"kind": "contract", "path": "design-contract.json"},
    {"kind": "handoff", "path": "design-handoff.md"},
    {"kind": "brief", "path": "design-brief.md"},
    {"kind": "design-system", "path": "DESIGN.md"},
    {"kind": "traceability", "path": "traceability.md"},
    {"kind": "screens", "path": "screens.md"},
    {"kind": "review", "path": "review.md"},
    {"kind": "preview", "path": "preview/index.html"}
  ],
  "blockers": [],
  "created": "2026-07-30",
  "updated": "2026-07-30"
}
```

## Contract

- `schemaVersion` is exactly `1.0`.
- `designId` is stable across revisions of the same logical design package.
- `status` is `draft`, `reviewed`, `approved`, `changes-requested`,
  `baselined`, or `superseded`.
- `mode` is `screen-architecture`, `wireframe`, `visual-design`, or
  `interactive-html`.
- `sourceSpec` identifies the exact accepted source artifact, version, path,
  and SHA-256. Never use `latest` or a filename date as source authority.
- `contractFingerprint` is the resolved artifact-generation fingerprint used
  for the authored package.
- `designAuthority.mode` is `bound-system`, `existing-ui`, or `free-design`.
  `source` names the exact authority or the explicit applicability decision.
- `decisionOwner` names the owner of the Design Gate decision.
- `artifacts` uses package-relative paths, contains no `..` traversal, and
  points to files inside the package.
- `blockers` contains unresolved material questions. An approved or baselined
  package has no blockers.
- `created` and `updated` use `YYYY-MM-DD`.

## Package Layout

```text
<design-package>/
|-- design-manifest.json
|-- design-contract.json
|-- design-handoff.md
|-- design-brief.md
|-- DESIGN.md
|-- traceability.md
|-- screens.md
|-- review.md
`-- preview/
    `-- index.html
```

The HTML preview is a design artifact, not production frontend code. Keep it
self-contained unless the resolved profile explicitly permits vendored local
assets. Do not depend on remote scripts, fonts, images, or stylesheets.

## Version And Baseline Rules

- Register a governed design baseline with artifact type `design`.
- Preserve the source spec identity and generation fingerprint for the version.
- Use a new design version when an approved package changes materially.
- Route changes to committed product behavior through `change` before creating
  the replacement design baseline.
- Use the local mutation-safety workflow before replacing files in an existing
  package.
