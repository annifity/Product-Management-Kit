# Artifact Generation Contract

Use this contract to resolve the project-specific rules that an artifact-producing
skill must follow before it drafts or changes an artifact. The contract is a
property-level merge: every resolved value retains its source and lower-priority
alternatives.

## Request

Pass UTF-8 JSON by `-RequestPath` or `-RequestJson` to
`tools/resolve-artifact-profile.ps1`. `-RequestJson` supports transient,
read-only resolution without first writing a request file into the workspace.

```json
{
  "schemaVersion": "1.0",
  "project": "GBIA",
  "artifactType": "user-story",
  "action": "create",
  "requiredKeys": [
    "language",
    "template",
    "destination.pattern",
    "outcome",
    "consumer",
    "deliverableMode",
    "baselineTarget"
  ],
  "materialKeys": [
    "template",
    "destination.pattern",
    "story.boundary"
  ],
  "changeAuthorized": false,
  "sources": [
    {
      "id": "request",
      "layer": "explicit-request",
      "values": {
        "language": "vi",
        "outcome": "create-an-implementation-ready-story",
        "consumer": {
          "primary": "delivery-team"
        },
        "deliverableMode": "jira-ready",
        "sourceAuthority": {
          "primary": "request",
          "supporting": [
            "gbia-user-story-profile"
          ]
        },
        "baselineTarget": {
          "mode": "new-artifact"
        },
        "constraints": {
          "noInventedBehavior": true
        },
        "materialDecisions": {
          "actor": "HR Admin",
          "ownership": "HCM",
          "stateModel": "confirmed"
        }
      }
    },
    {
      "id": "gbia-user-story-profile",
      "layer": "artifact-profile",
      "status": "active",
      "path": ".annifity/memories/artifact-profiles/GBIA/user-story.md"
    },
    {
      "id": "annifity-user-story-default",
      "layer": "canonical-fallback",
      "values": {
        "language": "match-request",
        "template": "_refs/templates/user-story/default-user-story.md",
        "destination.pattern": ".annifity/docs/user-stories/"
      }
    }
  ]
}
```

`project`, `artifactType`, `action`, and at least one source are required.
Supported actions are `create`, `revise`, `baseline`, `publish`, and `export`.
Property names are stable dot-delimited keys. A property value can be a scalar,
array, or object; the resolver treats that value atomically.

### Source shape

| Field | Required | Meaning |
|---|---:|---|
| `id` | Yes | Stable identifier used in provenance and conflict reports |
| `layer` | Yes | One of the layers defined by the resolution operating model |
| `status` | Conditional | `accepted` for `accepted-decision`; `baselined` or `shipped` for `accepted-baseline`. Do not mix decision outcome with document lifecycle. |
| `authority` | Accepted layers | Exact workspace, registry, artifact type, ID, baseline version/path/SHA verified through the authoritative baseline resolver |
| `valueEvidence` | Accepted layers | Per-value exact excerpt and excerpt SHA-256 present in the verified artifact |
| `values` | One of `values` or `path` | Inline property bag |
| `path` | One of `values` or `path` | Repository-relative JSON or Markdown profile |
| `materialKeys` | No | Keys whose unresolved disagreement must block writing |
| `locks` | No | Accepted keys that cannot be changed outside authorized change governance |
| `questions` | No | Open questions supplied by this source |
| `resolvesQuestions` | No | Question IDs explicitly resolved by this source |

Do not supply both `values` and `path`. A Markdown source must contain exactly
one fenced `json` block with a profile document. JSON and Markdown profile
documents use this reusable shape:

```json
{
  "schemaVersion": "1.0",
  "profileId": "gbia-user-story",
  "project": "GBIA",
  "artifactType": "user-story",
  "status": "active",
  "values": {
    "language": "en",
    "format.frontmatter": false
  },
  "materialKeys": [
    "format.frontmatter"
  ],
  "locks": [],
  "questions": []
}
```

An open question has the following shape:

```json
{
  "id": "GBIA-OQ-001",
  "text": "Which actor owns final approval?",
  "status": "open",
  "material": true,
  "affectsKeys": [
    "actor.approver"
  ]
}
```

An accepted source can resolve the question by listing its ID under
`resolvesQuestions`. Only an `explicit-request`, `accepted-decision`, or
`accepted-baseline` source may resolve a question, and it must supply values
for the question's `affectsKeys`. A profile, preference, fallback, or bare
top-level question ID cannot close a material gap. A material open question
without an explicit authoritative resolution blocks writing.

### Standard generation context

Use these exact property keys when the material-decision preflight supplies
generation context. Their values are atomic JSON values and are also copied to
`generationContext` in the resolver result.

| Key | Expected value |
|---|---|
| `outcome` | Decision, action, or handoff the artifact must enable |
| `consumer` | Primary audience plus optional downstream consumers |
| `deliverableMode` | Mode such as `jira-ready`, `business-demo`, `uat-signoff`, or `full-regression` |
| `sourceAuthority` | Primary authority and any accepted supporting sources |
| `baselineTarget` | `new-artifact`, or stable artifact ID plus exact baseline, version, and path |
| `constraints` | Confirmed scope, format, safety, and no-invention constraints |
| `materialDecisions` | Map of actor, ownership, surface, state model, story boundary, mockup authority, or other decisions that change the output |

The resolver always requires `outcome`, `consumer`, `deliverableMode`,
`sourceAuthority`, `baselineTarget`, `constraints`, and `materialDecisions`;
callers may add artifact-specific `requiredKeys`. `sourceAuthority.primary`
and each supporting value must be an exact supplied source ID. An absent
preflight decision therefore becomes a blocking `missing-required-value`
instead of an implicit assumption.

`consumer.primary` must be non-empty. `constraints.noInventedBehavior` must be
a JSON boolean. `materialDecisions` must record at least one confirmed value or
explicit applicability decision. For `revise`, `baseline`, and `publish`,
`baselineTarget` must carry exact ID, version, path, SHA-256, and match a
verified `accepted-baseline` source.

For governed artifacts, also resolve `format.frontmatter` and
`baseline.metadataMode`. Use `frontmatter` metadata mode when frontmatter is
permitted; use `registry` when a project profile forbids YAML. Never inject
frontmatter merely to make baseline resolution work.

Use `_refs/checklists/material-decision-preflight.md` to determine which
`materialDecisions` are applicable. Treat actor, permission, behavior owner,
story boundary, state model, thresholds, blocker/warning severity, and mockup
authority as material whenever changing them would change scope or acceptance.

When `changeAuthorized` is `true`, `changeEvidence` is required and must identify
the approved change record, decision, or user confirmation. Authorization permits
an explicit request to supersede a locked accepted value, but the resolver still
requires confirmation before writing.

## Result

The resolver returns JSON with:

| Field | Contract |
|---|---|
| `resolvedProfile` | Deterministic property bag selected by precedence |
| `generationContext` | Standard consumer, mode, authority, baseline target, constraints, and material-decision fields |
| `provenance` | Selected source, layer, status, and overridden sources for every key |
| `conflicts` | Informational overrides, warnings, and blocking material conflicts |
| `blockers` | Normalized material conflicts that prevent writing |
| `openQuestions` | All unresolved questions and whether each blocks writing |
| `fingerprint` | SHA-256 of the canonical resolution result, excluding the fingerprint itself |
| `writeDisposition` | `allowed`, `confirmation-required`, or `blocked`, with reasons and next action |

`blocked` is a successful resolution outcome, not a script failure. A malformed
request, inaccessible source, unsupported layer, or invalid profile is a script
error.

Consumers must bind the fingerprint to any protected preview and persist it in
the technical audit record. Do not require the user to interpret or approve the
fingerprint. Before a write, resolve again and reject the write if the
fingerprint changed.

Return the localized user-facing generation result defined in
`_refs/templates/docs/generation-receipt.md` alongside every authored artifact
or preview. Keep the technical audit record containing the fingerprint, write
disposition, exact source IDs, baseline identity/path/SHA, project-profile
sources, material decisions, and blockers internal or in a companion record.
Expose it only for explicitly requested diagnostics or a required audit export.
For a stale-state failure, explain what changed and which action must be
repeated without returning raw comparison values. Keep both outside the
artifact when the resolved profile forbids embedded metadata.

The default response must not name the user-facing summary a `generation
receipt`, expose resolver field names, or append the technical audit record.
Translate the result into the completed action, human-readable target and
source, baseline impact, concrete blocker, and next action.

## Material Conflict Rules

A conflict is blocking when any of these conditions is true:

- sources at the same precedence assign different values to a material key;
- an explicit request changes a material or locked accepted decision/baseline
  without authorized change evidence;
- a required key remains unresolved;
- a material open question is not explicitly resolved.

A higher-priority value can normally override a lower-priority value. The
resolver records that override as informational so the result remains auditable.

## Good Example

The project profile selects the GBIA Jira template and disables YAML frontmatter.
The explicit request selects Vietnamese. The canonical fallback supplies only a
missing destination. The result is writable because every property has one
authoritative value and provenance identifies all three sources.

## Anti-pattern

Do not copy prose from team preferences into a prompt and silently choose a
template. That loses source identity, makes precedence implicit, and cannot
detect a later accepted decision that contradicts the prompt.
