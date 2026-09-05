# AI Suitability And Risk Gate

## Suitability Gate

Proceed with AI only when:

- a confirmed user task and outcome exist;
- AI has a specific advantage over no change or deterministic rules;
- authorized data/context and evaluation evidence are feasible;
- failure can be detected, contained, escalated, or reversed;
- expected value exceeds implementation, review, failure, and operating cost;
- the minimum useful autonomy and human authority are explicit.

## Risk Tier

| Tier | Typical condition | Required control |
|---|---|---|
| Low | Reversible assistance, low sensitivity, no material decision | Basic evaluation, disclosure, monitoring |
| Medium | Material workflow influence or sensitive internal data | Behavior contract, slice evaluation, human override, rollback |
| High | Significant rights, financial, safety, employment, or external action impact | Qualified review, independent evidence, strict action controls, limited rollout |
| Critical | Plausible irreversible or severe harm without reliable prevention and recovery | Do not deploy until scope or control changes make risk governable |

Use the highest applicable impact. “Internal,” “pilot,” or “human in the loop”
does not automatically lower the tier.

## Hard Stops

- No confirmed problem or intended outcome
- No authority to use required data
- Unbounded autonomous or irreversible action
- No feasible way to evaluate a material failure
- No accountable decision owner
- Expected downside cannot be contained within the proposed scope

## Verdict

Return the option, risk tier, evidence, rejected alternatives, minimum autonomy,
hard stops, owner, and next decision.
