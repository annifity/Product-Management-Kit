# Dependency Matrix

Use for cross-epic or cross-team delivery dependencies that a single "Dependencies" column cannot represent clearly.

## Matrix

| From (epic/team) | To (epic/team) | Dependency Type | Direction | Description | Owner | Status | Risk If Late |
|---|---|---|---|---|---|---|---|
| [Epic/Team A] | [Epic/Team B] | Blocks / Informs / Shares resource / Shares data | A to B / B to A / Bidirectional | [Description] | [Owner] | Open / Resolved / Accepted risk | [Risk] |

## Critical Path

- Dependencies with no slack:
- Sequencing implication:

## Checklist

- Every dependency has a named owner on both sides, not only the blocked side.
- Direction is explicit; do not record a dependency without stating which side blocks which.
- Unresolved dependencies with material risk are visible in the release slice recommendation, not buried here alone.
