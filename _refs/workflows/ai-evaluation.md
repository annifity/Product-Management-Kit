# AI Evaluation Workflow

Use this workflow to design and assess repeatable evaluations for an AI-enabled
product behavior before release or after a material model, prompt, retrieval,
tool, policy, or data change.

## Contents

1. [Decision This Workflow Supports](#decision-this-workflow-supports)
2. [Inputs](#inputs)
3. [Process](#process)
4. [Good Example](#good-example)
5. [Anti-Pattern](#anti-pattern)
6. [Failure Modes](#failure-modes)
7. [Primary Sources](#primary-sources)

## Decision This Workflow Supports

The workflow answers one bounded question: is the candidate AI behavior safe
and useful enough for the declared deployment context, compared with the
accepted baseline and the team's risk tolerance?

An evaluation is not a generic model benchmark. It must represent the product
use case, affected users, failure impact, runtime configuration, and release
decision.

## Inputs

- Accepted product behavior or requirement baseline
- Candidate change and comparable current baseline
- Deployment context, users, languages, and risk tier
- Known production evidence or representative source material
- Quality, safety, latency, and cost constraints
- Named evaluation owner and release decision owner

If the product behavior, deployment context, or release decision is unresolved,
stop and route the gap to `discovery`, `spec`, or `change` before constructing a
large evaluation set.

## Process

### 1. Frame The Decision And Risk

State the behavior being evaluated, who can be affected, the decision the
results will inform, and the unacceptable outcomes. Select only dimensions that
can change that decision:

- task success and instruction adherence;
- groundedness, factuality, citation, or retrieval quality;
- safety, privacy, fairness, and policy compliance;
- tool selection, action correctness, permissions, and stop/escalation behavior;
- consistency across material user, language, channel, and risk slices;
- latency and cost where they affect usability or operating viability;
- human review, override, appeal, and safe fallback.

Document any material risk that cannot be measured. Absence of a metric is an
evidence limit, not a pass.

### 2. Build A Versioned Evaluation Set

Create representative normal, boundary, and adversarial cases from approved
requirements, sanitized product evidence, known failures, and plausible
high-impact risks. Each case must identify its provenance, slice, expected and
prohibited behavior, severity, and graders.

Keep a held-out regression set when feasible. Prevent training, prompt tuning,
or grader calibration from silently using held-out expected answers. Store only
data the team is authorized to retain; use stable source references instead of
copying secrets or unnecessary personal data.

Use `_refs/schemas/ai-evaluation-suite.md` for the machine-readable contract.

### 3. Choose And Calibrate Graders

Use the least subjective reliable grader for each criterion:

| Grader | Best fit | Required control |
|---|---|---|
| Deterministic | Exact values, schemas, permissions, tool calls, citations, latency, cost | Test both pass and fail examples |
| Human | Nuanced usefulness, domain correctness, harm, ambiguity | Named rubric, reviewer role, and disagreement rule |
| Model-assisted | Scalable rubric scoring or classification | Human-calibrated sample, pinned configuration, and audit trail |

Do not use a model grader as the sole authority for a high-impact criterion
without calibration against qualified human judgment. Do not allow the same
unreviewed model behavior to both produce and conclusively approve its own
output.

### 4. Precommit Thresholds

Set thresholds before the candidate results are known:

- minimum overall quality;
- minimum performance for every material slice;
- zero-tolerance or maximum-count hard blockers;
- non-regression margin against the accepted baseline;
- latency and cost budgets where applicable;
- the minimum sample and repeat policy for stochastic behavior;
- `go`, `limited rollout`, `iterate`, and `stop` rules.

An aggregate score must never mask a failed critical slice or hard blocker.

### 5. Run Comparable Baseline And Candidate Evaluations

Run the accepted baseline and candidate with the same suite version, data,
grader versions, environment controls, and repeat policy. Record model, prompt,
retrieval, tool, policy, and configuration identifiers needed to reproduce the
run. Never overwrite prior results.

### 6. Analyze Failures And Uncertainty

Report results by criterion and material slice, not only as one average. Group
failures using a declared taxonomy such as:

- incorrect or unsupported answer;
- missing required answer or refusal;
- unsafe, private, biased, or policy-violating output;
- wrong tool, argument, permission, or side effect;
- missed escalation, override, or fallback;
- excessive latency or cost;
- grader disagreement or unscorable evidence.

Separate measured regression from sampling uncertainty, grader uncertainty, and
missing coverage.

### 7. Issue A Verdict And Handoff

Use `_refs/checklists/ai-evaluation-release-gate.md`:

- **Ready**: every hard gate passes and evidence supports the declared scope.
- **Needs revision**: no immediate unsafe release condition exists, but quality,
  coverage, calibration, or traceability needs repair.
- **Blocked**: a hard blocker fails, the comparison is invalid, or evidence is
  insufficient for the requested release decision.

Hand the versioned suite, run evidence, deltas, failures, evidence limits, and
verdict to `learn` for product interpretation or to `ship` for a release gate.
Route a committed behavior change to `change`.

## Good Example

A support-answer assistant is evaluated against the accepted production
configuration and a candidate retrieval change. The suite contains sanitized
frequent questions, rare policy exceptions, stale-source traps, Vietnamese and
English cases, and attempts to obtain restricted account data. Deterministic
checks verify citations and source freshness; domain reviewers calibrate a
groundedness rubric; thresholds require no critical privacy failures, no
material language-slice regression, p95 latency within budget, and a minimum
quality improvement before rollout.

## Anti-Pattern

The team tries ten attractive prompts, lets the candidate model score its own
answers, chooses a pass threshold after seeing the scores, and reports only the
average. The result cannot support a release decision because it lacks a
comparable baseline, representative slices, independent calibration, and
precommitted hard gates.

## Failure Modes

| Failure | Signal | Consequence | Correction | Prevention |
|---|---|---|---|---|
| Benchmark theater | Cases are generic and disconnected from deployment | High scores do not predict product behavior | Rebuild around product tasks and risks | Require deployment context and source provenance |
| Average hides harm | Overall score passes while one critical slice fails | Affected users receive unsafe or unusable behavior | Apply per-slice thresholds and hard blockers | Block release on critical-slice failure |
| Grader circularity | Candidate behavior is approved only by an uncalibrated model grader | Systematic errors appear as passes | Calibrate with qualified humans and deterministic checks | Record grader evidence and disagreement |
| Threshold after the fact | Pass rule changes after candidate results are visible | Decision becomes biased and irreproducible | Restore the precommitted decision rule or rerun a new suite version | Fingerprint thresholds before execution |
| Contaminated holdout | Expected answers were used during tuning | Regression results overstate generalization | Replace and quarantine held-out cases | Track exposure and dataset version |

## Primary Sources

- [NIST AI RMF Core — Measure](https://airc.nist.gov/airmf-resources/airmf/5-sec-core/)
- [NIST AI RMF 1.0](https://www.nist.gov/publications/artificial-intelligence-risk-management-framework-ai-rmf-10)
- [OpenAI Evals API](https://platform.openai.com/docs/api-reference/evals)
- [OpenAI Graders API](https://platform.openai.com/docs/api-reference/graders)
- [Google Responsible Generative AI evaluation guidance](https://ai.google.dev/responsible/docs/evaluation)

These sources inform general evaluation principles. The workflow, structure,
wording, example, and decision logic above are Annifity's independent,
tool-agnostic implementation.
