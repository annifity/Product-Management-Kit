# Accepted Re-Rostering Review Specification

Accepted baseline `OPS-SPEC-020@1.0` is the only authoritative source.

- `REQ-001`: A Roster Supervisor can view pending AI-generated re-rostering
  recommendations. Each recommendation shows the source disruption, affected
  staff and shift, proposed change, rationale, confidence, and pending status.
- `REQ-002`: A Roster Supervisor can approve or reject one recommendation.
  Approval applies the proposed roster change. Rejection requires a reason and
  leaves the roster unchanged.
- `REQ-003`: A user without the Roster Supervisor permission cannot view or act
  on pending recommendations.
- `NFR-001`: The review interface must support desktop and tablet viewports,
  keyboard operation, visible focus, semantic labels, and non-color status cues.

No requirement supports bulk approval, automatic approval, or notifying Staff
App before supervisor approval. Create only the traceable design handoff; do not
produce production frontend code.
