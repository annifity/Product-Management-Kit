# Interaction And State Matrix

## Applicability

| Dimension | Applicable? | Source or reason |
|---|---|---|
| Loading | Yes / No | [REQ / NFR / reason] |
| Empty | Yes / No | [REQ / NFR / reason] |
| Error | Yes / No | [REQ / NFR / reason] |
| Success | Yes / No | [REQ / NFR / reason] |
| Disabled | Yes / No | [REQ / rule / reason] |
| Permission denied | Yes / No | [Permission / reason] |
| Partial or stale data | Yes / No | [Data rule / reason] |
| Offline | Yes / No | [NFR / reason] |
| Conflict or concurrency | Yes / No | [Rule / reason] |

## Matrix

| Screen ID | State / Interaction ID | Role | Trigger | Visible behavior | Recovery / next state | Source IDs | Coverage |
|---|---|---|---|---|---|---|---|
| SCREEN-001 | STATE-001 | [Role] | [Trigger] | [Behavior] | [Recovery] | [REQ / RULE / NFR] | Covered / gap |

## Gaps

| Design Gap ID | Missing decision | Affected IDs | Owner | Route | Status |
|---|---|---|---|---|---|
| DESIGN-GAP-001 | [Decision] | [REQ / SCREEN / STATE] | [Owner] | spec / change | Open |
