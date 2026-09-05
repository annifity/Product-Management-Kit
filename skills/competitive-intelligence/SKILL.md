---
name: competitive-intelligence
description: Build or update sourced competitive intelligence that tracks competitor products, positioning, pricing, customers, launches, and strategic moves over time. Use when a PM needs a competitor baseline, change digest, watchlist, battlecard input, or evidence-backed product implication rather than a one-off factual lookup. Use `knowledge` to retrieve existing internal intelligence, `discovery` for broad unresolved market exploration, and `strategy` to make the resulting product or portfolio choice.
---

# Competitive Intelligence

Turn dated external signals into a diffable intelligence record and bounded product implications.

## Input Contract

Reuse supplied competitor set, prior snapshot, market boundary, decision question, sources, and monitoring cadence. Current external claims require source URLs and observed dates; do not infer product behavior from marketing copy alone.

## Process

1. Define the decision consumer, category boundary, competitor set, source policy, baseline date, and cadence.
2. Collect or reuse primary evidence for product, positioning, pricing, customer, launch, distribution, hiring, partnership, and regulatory signals as relevant.
3. Label each item as fact, inference, or assumption with confidence and observed date.
4. Compare with the previous snapshot; separate new, changed, unchanged, and no-longer-supported claims.
5. Apply the PM decision challenge to strategic implications and reject unsupported feature-parity recommendations.
6. Produce watch triggers, product implications, counterevidence, and the receiving decision owner.

## Output

- Intelligence question, scope, competitors, and snapshot date
- Source ledger and evidence classification
- Competitor baseline or change digest
- Product, positioning, pricing, and GTM implications
- Counterevidence and confidence
- Watchlist, triggers, owner, and cadence
- Decision handoff; no automatic roadmap commitment

## Reference Routing

- Use `_refs/workflows/competitive-intelligence.md`, `_refs/checklists/competitive-intelligence-quality.md`, and `_refs/templates/strategy/competitive-intelligence-brief.md` for the core record.
- Use `_refs/workflows/research-evidence.md`, `_refs/templates/docs/evidence-ledger.md`, and `_refs/templates/strategy/company-research-brief.md` for source discipline and company-level research.
- Use `_refs/workflows/pm-decision-challenge.md`, `_refs/checklists/pm-decision-quality.md`, `_refs/operating-model/artifact-quality-system.md`, and `_refs/checklists/source-backed-minimality.md` before handoff.

## Handoff

Route retrieval of an existing snapshot to `knowledge`, an unresolved market boundary to `discovery`, a selected strategic response to `strategy`, positioning implications to `gtm`, and approved recurring records to `docs` and `memories`.
