# PM Decision Challenge

Use this workflow when an input, framework choice, metric, experiment, or recommendation could create a material product commitment. The goal is to improve the decision, not to manufacture objections.

## Contents

1. Decision frame
2. Method selection
3. Challenge checks
4. Verdict
5. Output contract

## 1. Decision Frame

State the decision, owner, horizon, reversibility, affected users, constraints, and evidence available. Separate the requested artifact from the decision it is meant to support.

Stop and reframe when the request presents a solution as a fact but does not identify a user problem or intended outcome. Continue with labeled assumptions when the decision is reversible and the missing evidence does not create material user, financial, legal, security, privacy, or operational exposure.

## 2. Method Selection

Select the smallest method that can improve the decision.

| Decision condition | Prefer | Avoid when |
|---|---|---|
| Problem or opportunity is unclear | Problem framing, JTBD, opportunity mapping | A solution or feature list is already being scored as if validated |
| Several options compete for scarce capacity | Value-effort, RICE, WSJF, weighted scoring | Inputs are invented, incomparable, or strategically irrelevant |
| User expectations and satisfaction shape the choice | Kano or opportunity scoring | No customer evidence exists |
| A risky belief must be tested | Assumption mapping and experiment design | The decision is irreversible or traffic/evidence cannot support the method |
| Product or portfolio direction is at stake | Strategy kernel, where-to-play/how-to-win, scenario comparison | Delivery sequencing is the actual decision |
| Commercial viability is at stake | Unit economics, pricing/packaging, market sizing, sensitivity analysis | Inputs lack units, time windows, or source authority |

Record the selected method, rejected alternatives, required inputs, evidence limits, and stop conditions using `_refs/templates/skills/method-selection-record.md`.

## 3. Challenge Checks

Challenge only material weaknesses:

- **Problem integrity:** Is the problem stated without embedding the preferred solution?
- **Evidence integrity:** Are claims traceable, current enough, and distinguished from inference or assumption?
- **Metric integrity:** Does each metric have a definition, population, window, source, baseline, target, and guardrail?
- **Method integrity:** Are required inputs present and comparable? Would another method change the decision less ambiguously? Reject RICE, WSJF, or Kano scoring when reach, impact, confidence, effort, or customer-satisfaction inputs are invented or unavailable — return `Need evidence` instead of a false-precision ranking.
- **Outcome integrity:** Is the headline metric a vanity number (raw signups, downloads, pageviews, likes) with no decision attached, rather than a metric tied to retention, revenue, or another outcome the business acts on?
- **Causality integrity:** Is correlation being presented as causation?
- **Experiment integrity:** Can the hypothesis fail, and were thresholds set before results?
- **Commercial integrity:** Are units, currency, period, cohort, margin basis, and sensitivity explicit?
- **Competitive integrity:** Is a competitive conclusion resting only on public marketing copy or press releases, with no independent verification (usage data, hands-on testing, customer interviews, pricing pages)?
- **Execution integrity:** Are owner, dependency, risk, exclusion, and next decision visible?

Do not create false precision. If an input is missing, report the affected result as unavailable rather than substituting an industry benchmark or invented score.

## 4. Verdict

Issue exactly one decision verdict:

- **Proceed:** evidence and method are sufficient for the stated reversible decision.
- **Proceed with conditions:** action is reasonable only with named limits, owners, or checks.
- **Need evidence:** one or more missing observations could materially reverse the choice.
- **Reframe:** the decision, problem, population, or success definition is malformed.
- **Do not proceed:** evidence contradicts the proposal or exposure exceeds the accepted boundary.

The verdict is not a phase-gate approval. A governed lifecycle transition still follows `_refs/operating-model/phase-gates.md`.

## 5. Output Contract

- Decision and decision owner
- Selected method and why it fits
- Rejected methods and why they do not fit
- Strongest evidence and strongest counterevidence
- Material assumptions and validation path
- Challenge findings, limited to decision-changing issues
- Verdict and conditions
- Next action, owner, and review trigger

## Good Example

For a low-traffic enterprise feature, reject an A/B test that would take nine months to reach the required sample. Recommend five evidence-linked customer walkthroughs plus a reversible concierge pilot, then state `Proceed with conditions` and define the evidence needed before automation.

## Anti-Pattern

Applying RICE to a backlog by inventing reach and confidence values produces a precise ranking with no decision validity. Return `Need evidence`, identify which values are missing, and offer a qualitative value-effort comparison only if its limitations are explicit.
