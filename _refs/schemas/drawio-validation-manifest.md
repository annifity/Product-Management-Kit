# Draw.io Validation Manifest

Use this manifest with `tools/validate-drawio.ps1` to validate exact Draw.io
artifacts without a browser, desktop application, or network access.

The caller must pass both `-RootPath` and a root-relative `-ManifestPath`.
Every artifact and linked source is resolved beneath that root. Absolute paths,
dot segments, parent traversal, backslash aliases, symbolic links, and reparse
points are rejected.

```json
{
  "schemaVersion": 1,
  "maxDrawioBytes": 1048576,
  "maxDecodedPageBytes": 2097152,
  "artifacts": [
    {
      "path": "product/flow.drawio",
      "linkedSources": [
        "product/spec.md",
        "product/DEC-001.md"
      ],
      "minimumRenderablePages": 1,
      "forbiddenLabels": [
        {
          "text": "Internal admin bypass",
          "match": "substring",
          "caseSensitive": false
        }
      ],
      "staleLabels": [
        {
          "text": "Supervisor Portal",
          "replacement": "GBIA Portal",
          "match": "exact",
          "caseSensitive": false
        }
      ]
    }
  ]
}
```

## Contract

| Field | Rule |
|---|---|
| `schemaVersion` | Required integer `1`. |
| `maxDrawioBytes` | Required positive byte limit, at most 50 MiB. |
| `maxDecodedPageBytes` | Required positive limit for each compressed page, at most 50 MiB. |
| `artifacts` | Required non-empty array of unique exact `.drawio` paths. |
| `linkedSources` | Required non-empty array of unique exact files that must exist. |
| `minimumRenderablePages` | Required positive integer; normally `1`. |
| `forbiddenLabels` | Required array of literal label rules; it may be empty. |
| `staleLabels` | Required array of literal label-and-replacement rules; it may be empty. |

Each label rule requires `text`, `match`, and the JSON boolean
`caseSensitive`. `match` is `exact` or `substring`. A stale rule also requires
a non-empty `replacement` different from `text`. Rules inspect visible
`mxCell@value` and wrapper `label` values after HTML decoding and tag removal.
Use a complete retired phrase when a substring also occurs inside its
replacement.

Unknown manifest fields are errors. A missing artifact, missing linked source,
unsafe or malformed XML, undecodable compressed page, invalid graph structure,
or matching label produces a failed validation verdict.

## Structural proof

The validator parses the outer `mxfile` and every `diagram`. It accepts an
inline `mxGraphModel` or the standard base64/raw-deflate/URI-encoded Draw.io
page form. DTDs and external XML resolution are disabled.

A page is structurally renderable only when all of these hold:

- it contains an `mxGraphModel/root`;
- cell IDs are non-empty and unique;
- parentless root cell `0` and default layer `1` with parent `0` exist;
- parent and edge endpoint references resolve to cells on the page, and parent
  references are acyclic;
- a cell is not both a vertex and an edge;
- every visual cell has geometry;
- every unconnected edge terminal has the corresponding source or target point
  in its geometry;
- vertex width and height are finite positive numbers, and supplied coordinates
  are finite; and
- at least one vertex or edge exists.

Every malformed page is a failure. A structurally valid blank page is allowed
only when the artifact still meets `minimumRenderablePages`.

## Invocation and result

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File tools/validate-drawio.ps1 `
  -RootPath C:\bounded\workspace `
  -ManifestPath validation/drawio.json
```

The tool writes deterministic JSON. Exit code `0` means `pass`; exit code `2`
means validated input produced findings. Invalid manifests, unsafe paths, and
other contract errors terminate with a non-zero PowerShell error.
