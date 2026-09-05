# PM Decision Quality Checklist

## Decision Gate

- The decision, owner, horizon, reversibility, and affected users are explicit.
- The requested artifact is not mistaken for the decision itself.
- The selected method fits the decision and its required inputs are available.
- RICE, WSJF, or Kano scoring is not used with invented or missing reach, impact, confidence, effort, or satisfaction inputs.
- Rejected methods and material trade-offs are visible.

## Evidence Gate

- Facts, observations, inference, assumptions, recommendations, and counterevidence are distinguishable.
- No customer quote, metric, benchmark, score, approval, or source is invented.
- A competitive conclusion is not drawn from public marketing copy or press releases alone, with no independent verification.
- Missing evidence that could reverse the decision is a blocker or explicit condition.
- Correlation is not presented as causation.

## Metric And Experiment Gate

- Metrics define population, event or formula, unit, window, source, baseline, target, and guardrail when applicable.
- The headline metric is an outcome the business acts on, not a vanity number (raw signups, downloads, pageviews, likes) with no decision attached.
- Hypotheses are falsifiable and thresholds are set before results.
- Sample or financial calculations use deterministic tools when available.
- Precision does not exceed input quality.

## Recommendation Gate

- The recommendation connects evidence to the decision.
- Non-goals, rejected alternatives, risks, dependencies, and conditions are explicit.
- Exactly one verdict is issued: Proceed / Proceed with conditions / Need evidence / Reframe / Do not proceed.
- The next action has an owner and review trigger.

## Semantic Eval Coverage Map

Each check below is asserted behaviorally by a `tests/fixtures/semantic-forward/cases.json` case (required/prohibited terms scored blind against a real candidate answer), not just checked lexically for keyword presence in a reference doc.

| Check | Case ID |
|---|---|
| Method selection accuracy (no invented RICE/scoring inputs) | `prioritize-without-invented-rice` |
| Does not invent scoring inputs | `prioritize-without-invented-rice` |
| Does not overclaim causality | `growth-constraint-with-causality-limit` |
| Does not invent willingness-to-pay | `commercial-decision-without-invented-wtp` |
| Competitor signal is not an automatic roadmap commitment | `competitive-change-digest-no-parity-roadmap` |
| GTM is not confused with release readiness | `gtm-motion-does-not-claim-ship-readiness` |
| Analytics diagnosis is not confused with independent validation | `diagnose-instrumentation-before-product-cause` |
| Aggregate result does not hide a critical slice failure | `analytics-slice-failure-not-hidden-by-aggregate` |

## Blockers

- The method requires data that is absent or incomparable.
- The proposed action creates material exposure without an authorized owner.
- The conclusion contradicts the strongest evidence without explanation.
- A deterministic result was guessed or hand-derived when a repository calculator exists.
