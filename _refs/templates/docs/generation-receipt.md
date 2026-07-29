# Generation Receipt

Return this compact receipt alongside an authored artifact or preview. Embed it
inside the artifact only when the resolved project profile permits metadata;
otherwise keep it in the handoff response or companion record.

| Field | Value |
|---|---|
| Contract fingerprint | `sha256:<64 lowercase hex>` |
| Write disposition | `allowed` / `confirmation-required` / `blocked` |
| Outcome / mode / consumer | [Resolved generation context] |
| Source authority | [Exact resolved source IDs] |
| Baseline target | `new-artifact` or `<artifactId>@<version> | <path> | <sha256>` |
| Project profile | [Profile source IDs and paths] |
| Material decisions | [Confirmed values or applicability] |
| Open blockers | [None or exact blocker IDs] |

The receipt is evidence of the exact context used to generate the output. It
does not itself approve a baseline, external publish, or mutation.
