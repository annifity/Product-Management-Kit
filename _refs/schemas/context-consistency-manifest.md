# Context Consistency Manifest

Use this manifest with `tools/lint-context-consistency.ps1` to check a bounded,
explicit set of workspace context files. The linter does not discover files,
follow links, query external systems, or infer scan scope from the current
directory.

The caller must pass both `-RootPath` and a root-relative `-ManifestPath`.
Every source must also appear in `scanPaths`. Absolute paths, backslash aliases,
empty/dot/parent segments, symbolic links, and reparse points are rejected.
Unknown fields and invalid field types are errors.

```json
{
  "schemaVersion": 1,
  "maxTextBytes": 1048576,
  "scanPaths": [
    "context/open-questions.md",
    "context/decisions.md",
    "context/terminology.md",
    "context/profile.md",
    "docs/story.md",
    "docs/change-1.0.md",
    "docs/change-1.1.md"
  ],
  "questionSources": [
    "context/open-questions.md"
  ],
  "frontmatterPolicies": [
    {
      "path": "docs/story.md",
      "profilePath": "context/profile.md"
    }
  ],
  "terminologyRules": [
    {
      "stale": "Supervisor Portal",
      "replacement": "GBIA Portal",
      "match": "substring",
      "caseSensitive": false,
      "paths": [
        "docs/story.md"
      ]
    }
  ],
  "decisions": [
    {
      "id": "DEC-001",
      "key": "portal.surface-name",
      "value": "GBIA Portal",
      "status": "active",
      "source": "context/decisions.md",
      "supersedes": []
    }
  ],
  "changelogStreams": [
    {
      "id": "STORY-001",
      "expectedHead": "1.1",
      "entries": [
        {
          "version": "1.0",
          "source": "docs/change-1.0.md",
          "previous": null
        },
        {
          "version": "1.1",
          "source": "docs/change-1.1.md",
          "previous": "1.0"
        }
      ]
    }
  ]
}
```

## Scan contract

`schemaVersion`, `maxTextBytes`, `scanPaths`, `questionSources`,
`frontmatterPolicies`, `terminologyRules`, `decisions`, and
`changelogStreams` are required. Detector arrays may be empty, but `scanPaths`
must contain at least one unique exact file. Every scanned file is decoded as
strict UTF-8 and must not exceed `maxTextBytes`, whose maximum is 50 MiB.

The linter always checks every `scanPaths` file for likely mojibake. It detects
the Unicode replacement character and common UTF-8 continuation-byte patterns
that were decoded as Windows-1252 or Latin-1. It does not flag an isolated
Vietnamese `Â` or `â` followed by a normal letter.

## Detector records

### Questions

`questionSources` use the existing Annifity Markdown table shape with headers
`ID`, `Question`, and `Status`; additional columns are allowed. Status beginning
with `Open` is open. Status beginning with `Closed`, `Resolved`, or
`Superseded` is closed. The same ID appearing in both states is a conflict.
Unknown statuses and a declared source with no matching rows are findings.

### Frontmatter

Each policy requires `path` and exactly one authority:

- `allowed`: an explicit JSON boolean in this manifest; or
- `profilePath`: a JSON file, or a Markdown profile containing exactly one
  fenced JSON block.

The profile must expose boolean `format.frontmatter` under either `values`
(profile source shape) or `resolvedProfile` (resolver result shape). When the
resolved value is `false`, a target beginning with YAML `---` is rejected.
`true` permits frontmatter but does not require it.

### Terminology

Each rule requires non-empty `stale` and `replacement`, `match` (`exact` or
`substring`), boolean `caseSensitive`, and one or more exact `paths`.
The linter uses literal matching only. Prefer a complete retired phrase when
the stale text is also contained in its replacement.

### Decisions

Decision claims are normalized explicitly because prose contradiction cannot
be detected safely. Each claim requires:

| Field | Meaning |
|---|---|
| `id` | Unique decision ID, which must occur in `source`. |
| `key` | Stable property or behavior governed by the claim. |
| `value` | Normalized selected value, which must occur in `source`. |
| `status` | `active`, `superseded`, or `rejected`. |
| `source` | Exact evidence file in `scanPaths`. |
| `supersedes` | Array of predecessor decision IDs. |

Both the ID and value must occur in the source, and a source declaring
supersession must also contain the predecessor ID. This prevents an ungrounded
manifest claim. Different values from two or more active decisions with the
same `key` are an unsuperseded conflict. A supersession link is valid only from
an active replacement to a declared, superseded predecessor with the same key.

### Changelog continuity

A stream requires a unique `id`, an `expectedHead`, and one or more ordered
entries. Every entry requires `version`, `source`, and `previous`. The first
entry uses JSON `null`; each later entry names the immediately preceding
version. The final version must equal `expectedHead`, and every source must
contain its declared version token. Missing predecessors, duplicates, wrong
order, and a missing expected head are findings.

## Invocation and result

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File tools/lint-context-consistency.ps1 `
  -RootPath C:\bounded\workspace `
  -ManifestPath validation/context.json
```

The tool writes deterministic JSON. Exit code `0` means `pass`; exit code `2`
means the bounded context produced findings. Invalid manifests, undeclared
source paths, unsafe paths, and unreadable text terminate with a non-zero
PowerShell error.
