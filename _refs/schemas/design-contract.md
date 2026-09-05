# Design Contract

Use this contract to persist the source, authority, structure, behavior coverage, and handoff state of a spec-derived design package. It describes the design; it does not replace the accepted product specification.

## Contract Shape

```json
{
  "schemaVersion": "1.0",
  "designId": "OPS-DESIGN-001",
  "version": "1.0",
  "status": "draft",
  "source": {
    "artifactId": "OPS-SPEC-001",
    "version": "1.0",
    "path": ".annifity/docs/specs/OPS-SPEC-001_v1.0.md",
    "sha256": "<64 lowercase hex>",
    "requirementIds": ["REQ-001", "REQ-002"]
  },
  "authority": {
    "mockupAuthority": "illustrative",
    "behaviorAuthority": "accepted-source-only",
    "approvedBy": null,
    "approvedAt": null
  },
  "target": {
    "surfaces": ["web"],
    "viewports": ["mobile", "desktop"],
    "locales": ["en"],
    "fidelity": "delivery-design"
  },
  "designSystem": {
    "id": "OPS-DS-001",
    "version": "1.0",
    "status": "accepted"
  },
  "flows": [
    {
      "id": "FLOW-001",
      "requirementIds": ["REQ-001"],
      "screenIds": ["SCREEN-001"]
    }
  ],
  "screens": [
    {
      "id": "SCREEN-001",
      "requirementIds": ["REQ-001"],
      "flowIds": ["FLOW-001"],
      "stateIds": ["STATE-001", "STATE-002"],
      "interactionIds": ["INT-001"]
    }
  ],
  "states": [
    {
      "id": "STATE-001",
      "type": "default",
      "sourceIds": ["REQ-001"]
    }
  ],
  "interactions": [
    {
      "id": "INT-001",
      "sourceIds": ["REQ-001"],
      "trigger": "Select an item",
      "outcome": "Open the sourced detail view"
    }
  ],
  "designGaps": [],
  "quality": {
    "readiness": "needs-review",
    "accessibilityReviewed": false,
    "responsiveReviewed": false,
    "traceabilityComplete": false
  },
  "gate": {
    "gateId": "phase.design.ready",
    "decision": "pending",
    "approvalRecordId": null
  }
}
```

## Required Rules

- Use stable IDs for the design, flows, screens, states, interactions, and gaps.
- Bind the contract to one exact authoritative source baseline and SHA-256.
- Map every screen action and behavior state to at least one authoritative source ID.
- Use `illustrative`, `accepted-presentation`, or `behavior-defining` for `mockupAuthority`; use `behavior-defining` only with explicit approval.
- Use `accepted`, `provisional`, or `none` for design-system status.
- Use `draft`, `in-review`, `accepted`, or `superseded` for contract status.
- Keep an applicable but uncovered state as a design gap; do not omit it silently.
- Do not set status to `accepted` while a blocking design gap remains or the Design Gate decision is not approved.
- Treat a changed source SHA, design-system version, target surface, viewport set, or material design decision as invalidating prior gate approval.

## Coverage Chain

Use this minimum chain for user-visible delivery scope:

```text
SOURCE BASELINE -> REQ-ID -> FLOW-ID -> SCREEN-ID -> STATE-ID / INT-ID
```

Record `not-applicable` with a reason for a quality dimension that does not apply. Absence is not evidence of review.

## Storage

- Store the governed contract, handoff documents, portable preview, and local
  assets together under `.annifity/docs/designs/<initiative>/<design-id>/`.
- Keep preview dependencies package-relative and self-contained. Do not load
  remote scripts, fonts, images, or stylesheets.
- Use `docs` to version, index, and link accepted design artifacts.

## Good Example

`SCREEN-003` contains a reject action mapped to `REQ-014`, and `STATE-009` captures the source-defined mandatory reason error. The contract labels its visual system provisional while preserving the accepted reject behavior.

## Anti-Pattern

The contract maps the entire dashboard to one PRD title and marks traceability complete. Individual actions, permissions, and failure states cannot be traced to accepted behavior.

## Failure Modes

| Failure | Signal | Consequence | Correction | Prevention |
|---|---|---|---|---|
| Baseline drift | Source path exists but SHA changed | Design may represent stale behavior | Resolve the baseline again | Bind artifact ID, version, path, and hash |
| Decorative traceability | A whole screen maps only to a document title | Unsupported controls are hidden | Map actions and states to requirement IDs | Enforce the coverage chain |
| False acceptance | Status is accepted with open blockers | Downstream teams treat gaps as resolved | Return to in-review | Gate accepted status on zero blockers |
| Authority ambiguity | Mockup authority is missing | Visual detail is mistaken for scope | Record explicit authority | Resolve authority in the preflight |
