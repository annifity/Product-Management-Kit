# GBIA User Story Artifact Profile

```json
{
  "schemaVersion": "1.0",
  "profileId": "gbia-user-story",
  "project": "GBIA",
  "artifactType": "user-story",
  "status": "active",
  "values": {
    "outcome": "produce-jira-ready-user-story",
    "consumer": {
      "primary": "delivery-team",
      "downstream": [
        "qa"
      ]
    },
    "deliverableMode": "jira-ready",
    "sourceAuthority": {
      "primary": "active-request",
      "supporting": [
        "accepted-diagram-decision"
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
    },
    "language": "en",
    "template": "_refs/templates/user-story/jira-user-story.md",
    "destination.pattern": ".annifity/docs/user-stories/GBIA/",
    "format.frontmatter": false,
    "baseline.metadataMode": "registry",
    "format.diagram": "drawio"
  },
  "materialKeys": [
    "template",
    "destination.pattern",
    "format.frontmatter",
    "baseline.metadataMode",
    "deliverableMode",
    "sourceAuthority",
    "baselineTarget",
    "materialDecisions"
  ],
  "locks": [],
  "questions": []
}
```
