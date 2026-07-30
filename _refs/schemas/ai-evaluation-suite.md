# AI Evaluation Suite Schema

Use this contract for a versioned, auditable AI evaluation plan and its run
results. Implement it as UTF-8 JSON or equivalent structured data when
automation is needed.

## Contents

1. [Required Top-Level Fields](#required-top-level-fields)
2. [Dataset Contract](#dataset-contract)
3. [Case Contract](#case-contract)
4. [Grader Contract](#grader-contract)
5. [Threshold Contract](#threshold-contract)
6. [Run Result Contract](#run-result-contract)
7. [Invariants](#invariants)
8. [Minimal Sanitized Example](#minimal-sanitized-example)
9. [Validation](#validation)
10. [Primary Sources](#primary-sources)

## Required Top-Level Fields

| Field | Type | Meaning |
|---|---|---|
| `schemaVersion` | string | Contract version |
| `suiteId` | string | Stable suite identifier |
| `suiteVersion` | string | Immutable version of cases, graders, and thresholds |
| `productUseCase` | string | Bounded AI-enabled product behavior |
| `decision` | string | Decision the results will inform |
| `evaluationOwner` | string | Owner of suite integrity |
| `decisionOwner` | string | Owner of release or product decision |
| `riskTier` | string | Project-defined impact tier |
| `deploymentContext` | object | Users, channels, languages, permissions, and operating conditions |
| `sourceBaselines` | array | Accepted requirements and current behavior/configuration identifiers |
| `dataset` | object | Dataset provenance, privacy, holdout policy, and declared slices |
| `cases` | array | Evaluation cases |
| `graders` | array | Deterministic, human, or model-assisted grading contracts |
| `thresholds` | object | Precommitted overall, slice, hard-blocker, regression, latency, and cost rules |
| `runPolicy` | object | Environment, repeat, randomization, and comparison controls |
| `results` | array | Immutable run references; empty before execution |
| `verdict` | object or null | Latest assessed verdict with evidence limits |

## Dataset Contract

`dataset` must include:

- `datasetId`, `version`, and content hash or immutable source reference;
- dataset provenance and authorization basis;
- privacy classification and redaction rule;
- creation and last-review dates;
- holdout policy and known exposure;
- representative normal, boundary, adversarial, and known-failure slices;
- material user, language, channel, permission, and risk slices;
- excluded conditions and generalization limits.

Synthetic cases must be labeled. Synthetic volume does not replace
representative product evidence or domain review.

## Case Contract

Each case requires:

| Field | Meaning |
|---|---|
| `caseId` | Stable unique identifier |
| `sliceIds` | One or more declared dataset slices |
| `inputRef` | Sanitized input or stable authorized reference |
| `contextRefs` | Required source/context identifiers |
| `expectedBehavior` | Observable required outcome |
| `prohibitedBehavior` | Observable failure or forbidden outcome |
| `riskTags` | Product risk categories |
| `severity` | Impact if the case fails |
| `graderIds` | Graders used for the case |
| `sourceRefs` | Requirement, incident, research, or approved evidence sources |

Do not encode a single prose "ideal answer" when several outputs would satisfy
the product requirement. Prefer observable criteria and prohibited behavior.

## Grader Contract

Each grader requires:

- stable `graderId`, type, version, and owner;
- criterion and plain-language rubric;
- input and output fields;
- score or label scale;
- pass rule and unscorable rule;
- calibration set reference and last calibration result;
- disagreement or adjudication rule;
- model/configuration identifier when model-assisted;
- known limitations.

## Threshold Contract

Thresholds must be recorded before candidate execution and include:

- `overallPassRule`;
- `slicePassRules`;
- `hardBlockers`;
- `nonRegressionRule`;
- `latencyBudget` and `costBudget`, or an explicit `notApplicable` rationale;
- `minimumRuns` or repeat policy;
- `go`, `limitedRollout`, `iterate`, and `stop` dispositions.

## Run Result Contract

Each immutable result requires:

- `runId`, timestamp, suite version, dataset version, and environment;
- baseline or candidate configuration fingerprint;
- per-case and per-grader outcomes;
- aggregate and slice metrics;
- latency and cost measures when applicable;
- failed hard blockers;
- grader disagreement and unscorable counts;
- execution errors and evidence gaps;
- artifact path or run URL plus result hash.

The verdict must cite exact run IDs and state the permitted deployment scope,
residual risks, accepted-risk owners, rollback condition, and next review date.

## Invariants

1. IDs are unique within the suite.
2. Every case references declared slices, graders, and sources.
3. Every material slice has a pass rule.
4. Hard blockers cannot be averaged away or waived without a named decision
   owner and explicit risk record.
5. Baseline and candidate comparisons use the same suite and dataset versions,
   or the verdict explains why comparison is invalid.
6. Threshold changes create a new suite version; prior results remain intact.
7. Missing, unscorable, or unauthorized data never counts as a pass.
8. Secrets and unnecessary personal data are not embedded in the suite.

## Minimal Sanitized Example

```json
{
  "schemaVersion": "1.0",
  "suiteId": "support-answer-quality",
  "suiteVersion": "1.0.0",
  "productUseCase": "Answer policy questions from approved sources",
  "decision": "Release retrieval configuration candidate B",
  "evaluationOwner": "AI Quality Lead",
  "decisionOwner": "Product Owner",
  "riskTier": "medium",
  "deploymentContext": {
    "users": ["support-agent"],
    "languages": ["en", "vi"],
    "channels": ["internal-portal"]
  },
  "sourceBaselines": ["SPEC-SUPPORT-004@2.1", "config-A@sha256:..."],
  "dataset": {
    "datasetId": "support-golden-set",
    "version": "3.0",
    "hash": "sha256:...",
    "provenance": "sanitized approved support evidence",
    "privacyClass": "internal-sanitized",
    "holdoutPolicy": "not used for prompt tuning",
    "slices": ["common", "policy-exception", "stale-source", "privacy", "vi"]
  },
  "cases": [
    {
      "caseId": "privacy-001",
      "sliceIds": ["privacy"],
      "inputRef": "case-data/privacy-001.json",
      "contextRefs": ["POLICY-PRIVACY-02"],
      "expectedBehavior": "Refuse disclosure and provide the approved escalation",
      "prohibitedBehavior": "Expose restricted account data",
      "riskTags": ["privacy"],
      "severity": "critical",
      "graderIds": ["privacy-rule"],
      "sourceRefs": ["SPEC-SUPPORT-004:R-18"]
    }
  ],
  "graders": [
    {
      "graderId": "privacy-rule",
      "type": "deterministic",
      "version": "1.0",
      "owner": "Security QA",
      "criterion": "No restricted data is returned",
      "scale": ["pass", "fail", "unscorable"],
      "passRule": "pass only",
      "calibrationRef": "grader-tests/privacy-rule.json",
      "adjudication": "Security QA review",
      "limitations": "Detects declared restricted field patterns"
    }
  ],
  "thresholds": {
    "overallPassRule": "quality >= 0.85",
    "slicePassRules": {"vi": "quality >= 0.80"},
    "hardBlockers": ["any critical privacy failure"],
    "nonRegressionRule": "no material slice declines by more than 0.02",
    "latencyBudget": "p95 <= 2500 ms",
    "costBudget": "mean request cost within approved budget",
    "minimumRuns": 3,
    "dispositions": ["go", "limited-rollout", "iterate", "stop"]
  },
  "runPolicy": {
    "comparison": "same suite, dataset, and environment",
    "preservePriorRuns": true
  },
  "results": [],
  "verdict": null
}
```

## Validation

Reject the suite when required identity, provenance, authorization, thresholds,
owners, or source links are missing. Treat a result as incomparable when suite,
dataset, grader, or environment drift is not explained.

## Primary Sources

- [NIST AI RMF Core — Measure](https://airc.nist.gov/airmf-resources/airmf/5-sec-core/)
- [OpenAI Evals API](https://platform.openai.com/docs/api-reference/evals)
- [OpenAI Graders API](https://platform.openai.com/docs/api-reference/graders)

The schema is an independent Annifity contract and does not require a specific
model provider or evaluation platform.
