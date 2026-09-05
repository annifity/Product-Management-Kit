# Methodology Catalog

This catalog records provenance and usage boundaries for named methods routed by Annifity. Method descriptions, examples, templates, and decision logic in this repository are independently authored unless a record explicitly states otherwise.

| Method ID | Decision supported | Best when | Not when | Source | Usage note | Last reviewed |
|---|---|---|---|---|---|---|
| rice | Rank a comparable initiative set using reach, impact, confidence, and effort | Units and time horizon are consistent and estimates have evidence | Reach or confidence would be invented; portfolio strategy is unresolved | [Intercom: RICE](https://www.intercom.com/blog/rice-simple-prioritization-for-product-managers/) | Method name and general formula referenced; Annifity wording and examples are independent | 2026-08-03 |
| wsjf | Sequence economic value under delay and job-size constraints | Cost of delay and job size can be compared on one scale | Scores mix incomparable time horizons or replace strategy | [Scaled Agile: WSJF](https://scaledagileframework.com/wsjf/) | Trademarked framework name referenced; do not copy diagrams or proprietary training text | 2026-08-03 |
| kano | Explore how user satisfaction changes with product attributes | Customer evidence can distinguish basic, performance, and delight expectations | No customer evidence exists or the decision is investment allocation | [Kano et al., 1984 bibliographic record](https://doi.org/10.20684/quality.14.2_147) | General method referenced; questionnaire and examples are independently authored | 2026-08-03 |
| jobs-to-be-done | Frame customer progress, circumstance, alternatives, and trade-offs | Behavioral evidence exists about why people switch, hire, or abandon a solution | The output is an invented persona or unsupported quote | [Christensen Institute: Jobs to Be Done](https://www.christenseninstitute.org/theory/jobs-to-be-done/) | General theory referenced; Annifity synthesis workflow is independent | 2026-08-03 |
| opportunity-solution-tree | Connect a measurable outcome to opportunities, solutions, and tests | Teams need to keep discovery evidence separate from solution commitment | Used as a feature roadmap or without a measurable outcome | [Product Talk: Opportunity Solution Trees](https://www.producttalk.org/opportunity-solution-tree/) | Method name and general structure referenced; templates and examples are independent | 2026-08-03 |
| ab-proportion-planning | Approximate equal-size sample needs for a two-sided binary-rate comparison | Baseline, absolute MDE, alpha, power, and eligible population are known | Traffic, interference, ethics, reversibility, or outcome type make the design unsuitable | Standard normal-approximation method implemented in `tools/estimate-experiment-sample.ps1` | Formula implementation and tests are repository-authored; not a substitute for statistical review | 2026-08-03 |
| saas-unit-economics | Compare recurring revenue, retention, acquisition cost, lifetime value, and payback | Units, cohorts, period, margin basis, and denominators are explicit | Inputs mix logo/revenue churn or monthly/annual periods | Formula definitions in `_refs/checklists/finance-metrics.md` | Repository-authored calculation implementation; verify finance policy before investment approval | 2026-08-03 |

## Method Records

The table above carries `method_id`, `decision_supported`, `best_when`/`not_when`, `source`, `license_or_usage_note`, and `last_reviewed`. The remaining `_refs/schemas/methodology-record.md` fields for each method are recorded here rather than in per-method files, to avoid duplication.

**rice**
- required_inputs: reach (users per period, evidenced), impact (evidenced scale, not invented), confidence (percentage with rationale), effort (person-time estimate)
- outputs: ranked initiative list with a per-item score and a sensitivity note
- failure_modes: invented reach or confidence produces false precision; scores compared across incomparable time horizons
- annifity_adaptation: blocks the score and returns `Need evidence` when any input is invented; scoring and sensitivity logic are repository-authored

**wsjf**
- required_inputs: cost-of-delay components (user-business value, time criticality, risk reduction or opportunity enablement) and job-size estimate, all on one comparable scale
- outputs: sequenced backlog with a WSJF score per item
- failure_modes: comparing items scored on different time horizons or units; treating WSJF as a strategy substitute
- annifity_adaptation: requires named comparable-scale evidence before scoring; sequencing logic and templates are repository-authored

**kano**
- required_inputs: customer survey or interview evidence distinguishing basic, performance, and delight attributes
- outputs: attribute classification (basic/performance/delight/indifferent) informing feature emphasis
- failure_modes: running Kano without customer evidence; using it for an investment-allocation decision it was not designed for
- annifity_adaptation: questionnaire structure, synthesis workflow, and challenge checks are repository-authored

**jobs-to-be-done**
- required_inputs: behavioral evidence of switching, hiring, or abandoning a solution; circumstance and desired progress
- outputs: job statement, forces-of-progress map, and competing-alternatives map
- failure_modes: inventing a persona or quote in place of evidence; treating an unvalidated job statement as a confirmed need
- annifity_adaptation: synthesis workflow, forces framing, and evidence labeling are repository-authored

**opportunity-solution-tree**
- required_inputs: a measurable outcome, evidence-linked opportunities, candidate solutions, and planned tests
- outputs: outcome-to-opportunity-to-solution-to-test map with evidence links
- failure_modes: using the tree as a feature roadmap; adding a solution branch with no linked opportunity or test
- annifity_adaptation: tree template and evidence-linkage checks are repository-authored

**ab-proportion-planning**
- required_inputs: baseline rate, absolute MDE, alpha, power, variant count, eligible daily traffic
- outputs: sample size per variant, total sample, estimated duration (planning approximation)
- failure_modes: running the test when traffic, interference, ethics, or reversibility make the design unsuitable; treating the estimate as an exact requirement
- annifity_adaptation: deterministic implementation in `tools/estimate-experiment-sample.ps1`; not a substitute for statistical review

**saas-unit-economics**
- required_inputs: MRR components, currency, period, cohort definition, churn/expansion amounts, CAC spend, gross margin
- outputs: ending MRR, ARR, NRR, GRR, CAC, estimated LTV, CAC payback period
- failure_modes: mixing logo and revenue churn; mixing monthly and annual periods; inventing a benchmark when an input is missing
- annifity_adaptation: deterministic implementation in `tools/calculate-finance-metrics.ps1`; returns `Not available` rather than inventing a value

For a new named method, add a record using `_refs/schemas/methodology-record.md` before it becomes a recommended default. Mark uncertain content reuse as `Requires human/legal license review`.
