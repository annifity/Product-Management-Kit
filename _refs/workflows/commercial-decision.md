# Commercial Decision Workflow

Use this workflow for pricing, packaging, market size, SaaS health, unit economics, channel economics, or feature investment decisions.

## 1. Define The Decision

Record the customer, buyer, alternative, owner, horizon, decision options, currency, time period, population, and reversibility. Identify whether the job is willingness-to-pay discovery, price/packaging design, economic diagnosis, market sizing, or investment comparison.

## 2. Build The Input Ledger

For every material input record value, unit, period, cohort/segment, source, observed date, confidence, and whether it is fact, inference, or assumption. Do not combine gross and net revenue, user and account churn, monthly and annual rates, or revenue and contribution margin without an explicit conversion.

## 3. Calculate And Compare

Use `tools/calculate-finance-metrics.ps1` for supported SaaS metrics. Keep raw inputs and formula definitions with results. Compare base, downside, and upside scenarios; vary the two or three assumptions most likely to reverse the recommendation.

## 4. Connect Customer And Business Value

Explain value metric, willingness-to-pay evidence, packaging boundaries, affected segments, adoption risk, revenue/margin impact, channel implications, and expected customer behavior. A financially attractive option that destroys user value or trust is not viable.

## 5. Decide

State rejected options, invalidation conditions, evidence to acquire, owner, and review trigger. Use a scoped verdict from the PM decision challenge. Route portfolio allocation to `strategy`, tests to `experiment`, lifecycle effects to `growth`, and external motion to `gtm`.
