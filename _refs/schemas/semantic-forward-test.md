# Semantic Forward-Test Contract

Use this contract to turn a historical rework pattern into a reproducible,
privacy-safe forward test without leaking the expected answer to the candidate
or evaluator.

## Case Manifest

Store cases in UTF-8 JSON:

```json
{
  "schemaVersion": "1.0",
  "corpusId": "annifity-first-pass-regressions",
  "cases": [
    {
      "caseId": "baseline-selection",
      "skill": "user-story",
      "prompt": "Revise the accepted scheduling story for implementation.",
      "sourceFiles": [
        "tests/fixtures/semantic-forward/sources/baseline-selection.md"
      ],
      "dimensions": [
        "unsupported-behavior",
        "context-adherence",
        "minimality",
        "baseline-selection",
        "usability"
      ],
      "oracle": {
        "requiredTerms": ["SCHED-002@1.0"],
        "prohibitedTerms": ["SCHED-002@1.1", "SCHED-002@1.2"],
        "expectedBaseline": "SCHED-002@1.0",
        "maxWords": 220
      }
    }
  ]
}
```

`caseId`, `skill`, `prompt`, one or more bounded `sourceFiles`, all five
dimensions, and `oracle` are required. Source paths must be repository-relative,
must not escape the workspace, and are hashed when a run is prepared.

The oracle may contain:

- `requiredTerms`: source facts or project conventions the output must retain;
- `prohibitedTerms`: unsupported behavior, stale context, forbidden sections,
  or wrong baselines that must not appear;
- `expectedBaseline`: exact stable ID and version when baseline choice matters;
- `maxWords`: a case-specific upper bound used only as a minimality guard.

Do not put customer names, secrets, personal data, verbatim private session
content, or production identifiers in the corpus. Preserve the rework pattern,
not the original business data.

## Three Separated Surfaces

1. **Candidate task** contains only the user-like prompt, selected skill,
   bounded source artifacts, and their hashes. It never contains the oracle,
   suspected defect, intended fix, prior output, or expected answer.
2. **Blind evaluator task** contains the candidate output, source artifacts,
   and the generic five-dimension rubric. It never contains the oracle or
   deterministic pass/fail result.
3. **Harness verdict** combines the blind usability rating with hidden,
   deterministic oracle checks after both independent runs finish.

Run the candidate and evaluator in separate fresh threads. Their result records
must declare distinct context IDs, the exact files read, and that no additional
context was supplied. A declaration is auditable evidence, not proof of model
isolation; CI validates the package boundary and source hashes.

## Canonical Candidate Task Binding

`tools/new-semantic-forward-run.ps1` emits an opaque `taskFingerprint`:

```json
{
  "schemaVersion": "1.0",
  "caseId": "baseline-selection",
  "runId": "run-001",
  "taskFingerprint": "sha256:<64 lowercase hex>",
  "skill": "user-story",
  "prompt": "Revise the accepted scheduling story for implementation.",
  "contextPolicy": {
    "freshThread": true,
    "allowedSourcesOnly": true,
    "doNotReadExpectedAnswer": true,
    "doNotReadPriorOutputs": true
  },
  "sources": [
    {
      "path": "tests/fixtures/semantic-forward/sources/baseline-selection.md",
      "sha256": "<64 lowercase hex>",
      "content": "<bounded source content>"
    }
  ],
  "sourceHashes": {
    "tests/fixtures/semantic-forward/sources/baseline-selection.md": "<64 lowercase hex>"
  }
}
```

The fingerprint covers the canonical manifest hash, corpus, case and run IDs,
skill, exact case prompt, context policy, and ordered source paths and hashes.
It does not cover or reveal the hidden oracle. Source lists, source paths, and
source content must be non-empty.

Before producing an evaluator task or scoring a result, regenerate the
candidate task from the canonical manifest and current source files. Require
the submitted task to match that generated artifact exactly, including its
fingerprint. Fail closed with stable code `task-binding-invalid` when the task
is fabricated, empty, stale, reserialized, or changes the prompt, context
policy, source path, source hash, or source content.

## Candidate Result

```json
{
  "schemaVersion": "1.0",
  "caseId": "baseline-selection",
  "runId": "run-001",
  "contextId": "candidate-thread-001",
  "freshContext": true,
  "additionalContextUsed": false,
  "sourceHashes": {
    "tests/fixtures/semantic-forward/sources/baseline-selection.md": "sha256"
  },
  "output": "candidate output"
}
```

## Blind Evaluation

```json
{
  "schemaVersion": "1.0",
  "caseId": "baseline-selection",
  "runId": "run-001",
  "contextId": "evaluator-thread-001",
  "independentContext": true,
  "sawExpectedAnswer": false,
  "usabilityScore": 4,
  "usabilityReason": "The handoff is directly actionable."
}
```

`usabilityScore` is an integer from 0 to 4. The evaluator rates only whether
the output is clear, actionable, and internally coherent. It does not decide
whether hidden expected terms or baseline identities match.

## Verdict

The harness reports each dimension on a 0-to-4 scale:

- `unsupported-behavior`: 4 when no prohibited term appears, otherwise 0;
- `context-adherence`: proportional coverage of required terms;
- `minimality`: 4 when the case word bound is met, otherwise 0;
- `baseline-selection`: 4 when the exact expected baseline appears and no
  prohibited baseline appears; `not-applicable` when no baseline is specified;
- `usability`: the independent evaluator score.

Any prohibited behavior, wrong baseline, leaked oracle, reused context ID,
source-hash drift, or isolation declaration failure is a hard failure.
Otherwise, every applicable dimension must score at least 3.

### Candidate-visible verdict

Candidate-visible output may contain only stable verdict fields, dimension
scores, stable failure codes, and aggregate counts. It must never return:

- the missing required terms;
- the prohibited terms that were found;
- the expected baseline identifier;
- the case-specific word limit;
- a source path embedded in a failure code.

Use aggregate evidence such as `requiredTermCount`, `missingRequiredCount`,
`prohibitedTermCount`, `prohibitedFoundCount`, `wordCount`, and
`distinctContextCount`. Use stable codes such as `prohibited-content`,
`source-hash-drift`, `wrong-or-missing-baseline`, and
`task-binding-invalid`. Keep exact oracle evidence inside the harness process.

## Failure Modes

| Failure | Signal | Consequence | Correction | Prevention |
|---|---|---|---|---|
| Expected-answer leak | Candidate/evaluator task contains `oracle` | Test measures recall, not generalization | Rebuild separated run bundles | Reject leaked fields before execution |
| Verdict oracle leak | Verdict returns matched or missing oracle strings | Candidate can tune directly to hidden checks | Return stable codes and aggregate counts only | Scan candidate-visible output for every oracle term |
| Fabricated task | Submitted task has empty sources or altered prompt/context with copied IDs | Evaluator scores an untrusted task | Regenerate and compare the canonical task before scoring | Bind manifest, prompt, context policy, and source hashes in `taskFingerprint` |
| Warm-context pass | Candidate and evaluator reuse a context ID | Prior conclusions influence the verdict | Rerun in distinct fresh threads | Validate context declarations |
| Corpus memorization | Case copies private names or accepted output | Regression is unsafe and overfit | Anonymize actors, IDs, and wording | Privacy review every source fixture |
| Structural-only score | Output has headings but invents behavior | First-pass defect is missed | Add source-backed prohibited/required facts | Score all five dimensions |
