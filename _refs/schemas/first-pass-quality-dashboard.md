# First-Pass Quality Dashboard

Use this schema to aggregate privacy-safe session rework observations into
first-pass quality metrics by skill and skill version. The dashboard consumes
only completed outputs conforming to
`_refs/schemas/session-rework-observation.md`; it never reads raw session JSONL.

## Input Manifest

```json
{
  "schemaVersion": "1.0",
  "inputPaths": [
    ".annifity/docs/audits/session-rework-2026-07.json"
  ]
}
```

Paths are explicit, unique, repository-relative, and bounded to the current
workspace. Inputs with blocked status, raw content emission, conflicting
duplicate chain IDs, unknown outcomes, or malformed metrics are rejected.

## Metric Definitions

| Metric | Numerator / value | Denominator |
|---|---|---|
| First-pass acceptance rate | `accepted_first_pass` plus `accepted_after_scope_change` chains with `firstPassDefect=false` | All observed chains |
| Median correction turns | Median number of `first_pass_defect` correction events per chain | All observed chains |
| Repeat-after-fix rate | Defect correction events carrying cause `repeat_after_fix` | All defect correction events |
| Unsupported-content deletion rate | Defect correction events carrying cause `unsupported_content` | All defect correction events |
| Context-miss rate | Defect correction events carrying cause `missed_context` | All defect correction events |
| Invalid-diagram rate | Chains with at least one `invalid_diagram` defect event | All observed chains |

User scope changes never count as defects or correction turns. A chain can
contribute to more than one cause-based metric.

## Output

```json
{
  "schemaVersion": "1.0",
  "status": "complete",
  "sources": [
    {
      "path": ".annifity/docs/audits/session-rework-2026-07.json",
      "sha256": "..."
    }
  ],
  "overall": {
    "chains": 10,
    "firstPassAcceptedChains": 7,
    "firstPassAcceptanceRate": 0.7,
    "medianCorrectionTurns": 1,
    "defectCorrectionEvents": 8,
    "repeatAfterFixEvents": 1,
    "repeatAfterFixRate": 0.125,
    "unsupportedContentDeletionEvents": 3,
    "unsupportedContentDeletionRate": 0.375,
    "contextMissEvents": 2,
    "contextMissRate": 0.25,
    "invalidDiagramChains": 0,
    "invalidDiagramRate": 0
  },
  "bySkillVersion": [],
  "targets": {},
  "diagnostics": []
}
```

Every `bySkillVersion` row uses the same metric shape plus `skill` and
`version`. Sort rows by ordinal skill and version. Rates are proportions from
0 to 1, rounded to four decimal places; a zero denominator produces `null`,
not a fabricated zero.

Default targets preserve the audit backlog intent:

- first-pass acceptance rate: at least `0.70`;
- median correction turns: at most `2`;
- repeat-after-fix rate: below `0.05`;
- invalid-diagram rate: `0`;
- unsupported-content deletion rate: track a `0.60` relative reduction once a
  baseline period is supplied.

The dashboard reports target status as `met`, `not-met`, or
`baseline-required`; it does not infer a historical baseline.

## Failure Modes

| Failure | Signal | Consequence | Correction | Prevention |
|---|---|---|---|---|
| Raw-session dashboard | Tool reads session JSONL directly | Privacy and dedupe rules are bypassed | Run the observation audit first | Accept observation outputs only |
| Scope-change penalty | User scope change increases rework rate | Skill quality is understated | Exclude its correction events | Require event classification |
| Zero-denominator fiction | Empty group reports 0% defects | Missing evidence looks perfect | Emit `null` | Track numerator and denominator |
| Version blending | Results combine skill revisions | Regression source is hidden | Group by exact skill/version | Require both fields per chain |

