# Market Sizing Workflow

Use when sizing TAM, SAM, SOM, estimating business opportunity, preparing executive review, or comparing strategic bets.

## When Not To Use

- Internal tools with captive users and no market choice.
- Ideas without a clear problem space or target customer.
- Decisions where customer validation is more important than market volume.

## Process

1. Define problem space, buyer/user, geography, segment, and business model.
2. Pick sizing method:
   - Top-down: industry market size narrowed to target segment.
   - Bottom-up: number of reachable customers x ARPU/ARPA.
   - Value-based: value created or cost avoided x monetizable share.
3. Estimate TAM: total demand if all relevant buyers/users adopt.
4. Estimate SAM: portion realistically serviceable by product, geography, model, channel, compliance, and segment.
5. Estimate SOM: portion realistically obtainable in 1-3 years, constrained by competition, GTM capacity, conversion, retention, and delivery capacity.
6. Document assumptions and evidence source for every number.
7. Run sensitivity analysis with downside, base, and upside cases.
8. Connect sizing to roadmap or investment decision.

## Output

| Layer | Definition | Population / Units | ARPU/Value | Estimate | Evidence | Key Assumption |
|---|---|---|---|---|---|---|
| TAM | [Definition] | [Count] | [Value] | [Amount] | [Source] | [Assumption] |
| SAM | [Definition] | [Count] | [Value] | [Amount] | [Source] | [Assumption] |
| SOM | [Definition] | [Count] | [Value] | [Amount] | [Source] | [Assumption] |

## Sanity Checks

- SOM is not equal to SAM unless there is a defensible monopoly/captive context.
- Population and revenue estimates are both visible.
- Every estimate has a cited source or an explicit assumption.
- GTM capacity and competition constrain SOM.
- Market size does not replace customer validation.

## Decision Guidance

- Use with `_refs/checklists/opportunity-scoring.md` for roadmap comparison.
- Use with `_refs/checklists/finance-metrics.md` when pricing, revenue, retention, or channel economics influence the decision.
- Save material assumptions to docs/memory so future reviews can revisit them.
