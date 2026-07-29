# Session Rework Observation Schema

Use this schema to turn explicitly selected, anonymized JSONL session evidence into
deterministic first-pass quality observations. The schema does not authorize
repository-wide or user-home session discovery. `tools/audit-session-rework.ps1`
accepts only named JSONL files or a manifest that names every file.

## Safety Boundary

- Never infer a session directory, expand a glob, or scan all user sessions.
- Require every included session to be declared `root`. Exclude `fork` and
  `subagent` sessions when either session metadata or the manifest declares that
  kind.
- Treat conflicting or missing session-kind declarations, malformed JSONL,
  incomplete chains, invalid classifications, and invalid redaction rules as
  blocking evidence errors.
- Treat `user_scope_change` as a changed request, not a first-pass quality defect.
- Treat `first_pass_defect` as a failure to satisfy the request and context that
  were available before the first output.
- Apply built-in redaction plus manifest rules before emitting any message text.
  Emit source IDs and line anchors, never absolute source paths.

## Invocation

Use exactly one input mode:

```powershell
pwsh -File tools/audit-session-rework.ps1 `
  -SessionPath tests/fixtures/session-rework/valid/root-session.jsonl
```

```powershell
pwsh -File tools/audit-session-rework.ps1 `
  -ManifestPath tests/fixtures/session-rework/valid/manifest.json
```

`-SessionPath` values must be explicit `.jsonl` files. A directory or wildcard is
invalid. Direct-path mode takes identity, skill, privacy, and observation
annotations from the JSONL. Manifest mode may supply those declarations for raw
session formats that cannot carry Annifity annotations.

## Manifest

```json
{
  "schemaVersion": "1.0",
  "sessions": [
    {
      "path": "root-session.jsonl",
      "sourceId": "session-root-001",
      "include": true,
      "sessionId": "S-ROOT-001",
      "sessionKind": "root",
      "skill": {
        "name": "prd",
        "version": "git:0123456789abcdef"
      },
      "privacy": {
        "classification": "anonymized",
        "redaction": "required"
      },
      "observations": [
        {
          "line": 4,
          "chainId": "CHAIN-001",
          "stage": "correction",
          "classification": "first_pass_defect",
          "causes": ["missed_explicit_requirement"],
          "missedContext": [],
          "confidence": 0.95,
          "sourceLinks": ["REQ-001#L12"]
        }
      ]
    },
    {
      "path": "fork-session.jsonl",
      "sourceId": "session-fork-001",
      "include": false,
      "exclusionReason": "forked validation work",
      "sessionKind": "fork"
    }
  ],
  "redaction": {
    "rules": [
      {
        "id": "customer-name",
        "pattern": "(?i)northstar",
        "replacement": "[REDACTED:CUSTOMER]"
      }
    ]
  }
}
```

| Field | Required | Rule |
|---|---|---|
| `schemaVersion` | Yes | Exact value `1.0`. |
| `sessions` | Yes | Non-empty JSON array; order does not affect output. |
| `sessions[].path` | Yes | Explicit `.jsonl` file, relative to the manifest or absolute; no wildcard or directory. |
| `sessions[].sourceId` | Yes | Unique safe ID matching `[A-Za-z0-9][A-Za-z0-9._-]{0,127}`. It replaces the filesystem path in output. |
| `sessions[].include` | No | JSON boolean, default `true`. |
| `sessions[].exclusionReason` | When `include=false` | Non-empty reason. |
| `sessions[].sessionId` | If absent from JSONL | Stable safe session ID. |
| `sessions[].sessionKind` | If absent from JSONL | `root`, `fork`, or `subagent`. |
| `sessions[].skill` | For included sessions if absent from JSONL | Exact skill `name` and `version`. |
| `sessions[].privacy` | For included sessions if absent from JSONL | Classification plus required-redaction declaration. |
| `sessions[].observations` | No | Line-addressed annotations. A line can be annotated once. |
| `redaction.rules` | No | Additional deterministic regular-expression rules. Built-ins cannot be disabled. |

If the same identity, kind, skill, privacy, or observation is declared in both
the manifest and JSONL, the declarations must be equivalent. A conflict blocks
the audit. A manifest declaration can fill a missing JSONL declaration but
cannot override one.

## JSONL Evidence

Every non-empty line must contain one JSON object. Blank lines and JSON arrays
are malformed evidence. The canonical metadata record is:

```json
{"type":"session_meta","payload":{"schemaVersion":"1.0","sessionId":"S-ROOT-001","sessionKind":"root","skill":{"name":"prd","version":"git:0123456789abcdef"},"privacy":{"classification":"anonymized","redaction":"required"}}}
```

Canonical messages use:

```json
{"type":"message","payload":{"messageId":"M-001","role":"user","content":"Create a concise PRD.","observation":{"chainId":"CHAIN-001","stage":"request","sourceLinks":["REQ-001#L1"]}}}
```

The auditor also reads message payloads in common `response_item` and
`event_msg` wrappers. String content and text-bearing content arrays are
supported. An observed message must resolve to role `user` or `assistant` and
non-empty text.

The auditor de-duplicates:

1. repeated stable message IDs whose normalized role and content are identical;
2. consecutive message/event wrappers with the same normalized role and
   content.

Conflicting reuse of a message ID or conflicting annotations on duplicate
payloads blocks the audit. Every retained source line is preserved as a source
anchor on the single emitted observation.

## Observation Stages

An observation may be inline at `payload.observation`,
`payload.annifityObservation`, or the top-level `observation`, or may be supplied
by a manifest entry for the exact JSONL line.

| Stage | Role | Required content |
|---|---|---|
| `request` | `user` | Original request and available request context. |
| `first_output` | `assistant` | First substantive output for the request. |
| `correction` | `user` | Classification, cause evidence when defective, and confidence. |
| `revised_output` | `assistant` | Output produced after a correction. |
| `accepted_output` | `assistant` | Revised output explicitly known to be accepted. |
| `acceptance` | `user` | Evidence that the most recent assistant output was accepted. |
| `manual_edit` | `user` | A summary or patch of edits made outside the assistant response, plus classification and confidence. |

Every observation requires `chainId` and `stage`. A chain must contain exactly
one `request` followed by exactly one `first_output`. Corrections and revised
outputs must preserve source order. An unresolved final correction is allowed
and is emitted as `awaiting_revision`; missing request/first-output evidence is
not allowed.

An `acceptance` marks the most recent first or revised output as the accepted
output. An `accepted_output` is both a revised output and the accepted output.
Only one acceptance outcome is allowed per chain.

## Rework Classification

`correction` and `manual_edit` require:

```json
{
  "classification": "first_pass_defect",
  "causes": ["missed_context"],
  "missedContext": [
    {
      "kind": "linked_source",
      "description": "The request linked the retention rule.",
      "sourceLink": "POLICY-RETENTION#L20"
    }
  ],
  "confidence": 0.9
}
```

Classification values:

- `first_pass_defect`: the first output missed, contradicted, or incorrectly
  handled evidence available before that output.
- `user_scope_change`: the user added or changed requirements after the first
  output. It is rework volume but not a first-pass defect.

Do not infer a classification from wording alone. A missing classification
blocks the chain. `first_pass_defect` requires at least one cause.
`user_scope_change` must not declare a defect cause.

## Cause Taxonomy

| Cause | Meaning |
|---|---|
| `missed_explicit_requirement` | An explicit request constraint was omitted or contradicted. |
| `missed_context` | Available workspace, memory, linked-source, policy, or prior-message context was not used. |
| `incorrect_assumption` | The output silently invented or relied on an unsupported material assumption. |
| `incomplete_coverage` | Required cases, roles, states, or sections were incomplete. |
| `incorrect_behavior` | A rule, calculation, recommendation, or described behavior was wrong. |
| `invalid_diagram` | A generated diagram was syntactically invalid, unrenderable, or semantically unusable. |
| `format_or_structure` | The requested output format or governed structure was not followed. |
| `traceability_gap` | Required source, requirement, or decision traceability was absent or wrong. |
| `privacy_or_security` | The output exposed or mishandled protected information or a security constraint. |
| `repeat_after_fix` | A previously corrected defect recurred after a revised output. |
| `tool_or_execution_error` | A tool action failed or produced a materially incorrect result. |
| `unsupported_content` | Content not supported by the declared sources or request had to be deleted or corrected. |
| `other` | Evidence-backed defect not represented above; explain it in the correction text. |

When cause `missed_context` is present, `missedContext` must contain at least one
record. When missed-context records are present, that cause must be declared.
Allowed missed-context kinds are `request`, `workspace`, `memory`,
`linked_source`, and `policy`.

`repeat_after_fix` is valid only when the same chain already contains a
correction followed by a revised output. This structural rule lets aggregate
consumers count recurrence without reading redacted message text. Dashboard
consumers may likewise compute unsupported-content deletion and invalid-diagram
rates from `metrics.causeCounts` entries for `unsupported_content` and
`invalid_diagram`.

## Skill Version And Confidence

Every included chain resolves one skill identity:

```json
{
  "name": "prd",
  "version": "git:0123456789abcdef"
}
```

The session declaration is the default. A request observation may declare a
chain-specific skill; all later skill declarations in that chain must match.
Names and versions are opaque, non-empty, safe identifiers rather than paths or
free text.

`confidence` is a JSON number from `0` through `1` and represents confidence in
the rework classification, not confidence in the product decision. The chain
confidence is the lowest classified-event confidence. Aggregate confidence is
the arithmetic mean across classified correction and manual-edit events.

## Privacy And Redaction

Every included session declares:

```json
{
  "classification": "synthetic | anonymized | private",
  "redaction": "required"
}
```

Redaction is always required. Built-in rules redact email addresses,
secret/token-shaped values, and user-home path identities. Manifest rules are
sorted by `id` and applied after built-ins. Each custom replacement must use
`[REDACTED:LABEL]` form. Output reports match counts without retaining raw
matches.

Apply redaction to request/output/correction/manual-edit text and missed-context
descriptions. Do not place absolute input paths, raw source text, timestamps, or
unredacted match values in output or diagnostics.

`sourceLinks` are bounded evidence locators, not arbitrary URLs. They must use a
safe source identifier with an optional `#L<line>` suffix and must not contain a
rooted path, `..`, query, fragment other than the line anchor, or credentials.

## Deterministic Audit Output

Success emits one JSON object:

```json
{
  "schemaVersion": "1.0",
  "status": "complete",
  "sources": [],
  "chains": [],
  "metrics": {},
  "privacy": {},
  "diagnostics": []
}
```

Each chain contains:

- stable session, chain, and skill identity;
- redacted `request` and `firstOutput`;
- classified `corrections`;
- `revisedOutputs` and the resolved `acceptedOutput`, if any;
- classified `manualEdits`;
- aggregated `missedContext`, causes, confidence, outcome, and source-line
  links.

Aggregate metrics include included/excluded sessions, retained and duplicate
message payloads, observed chains, corrections, manual edits, accepted and
unresolved outcomes, defect and scope-change event/chain counts, cause counts,
first-pass defect/success rates, scope-change rate, average corrections per
chain, and average classification confidence. Scope changes never reduce the
first-pass success rate.

Sort sources by `sourceId`, chains by source and request line, causes by taxonomy
code, and source anchors by line. Do not emit timestamps or absolute paths.
Equivalent evidence and configuration must produce byte-equivalent JSON.

Failure emits `status: blocked`, no chains or metrics, a stable diagnostic code,
source ID and line when known, and exits with code `2`. Parameter-binding errors
also fail without scanning.
