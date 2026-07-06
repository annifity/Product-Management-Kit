# Product Builder Kit Example

This example shows how Annifity turns one product idea into builder-ready work.

## Input

Stakeholder ask:

> Sellers ask for an AI assistant that can explain why an order payout is delayed.

## 1. Discovery Pack

- Problem: sellers lose time contacting support because payout delay reasons are unclear.
- Target users: marketplace sellers and seller support agents.
- Evidence needed: support ticket tags, payout delay frequency, interview notes, and operational policy constraints.
- Candidate options:
  - Improve payout status copy.
  - Add guided troubleshooting.
  - Add AI assistant for natural-language explanation.
- Assumptions:
  - Sellers can safely see enough payout reason detail.
  - Support ticket reduction is measurable.
- Success metric draft:
  - Reduce payout-delay support contacts per 1,000 delayed payouts.
  - Guardrail: no increase in incorrect payout disputes.

## 2. Prototype Pack

- Learning objective: learn whether sellers understand delay reasons faster with guided explanation.
- Minimum flow:
  - Seller opens payout detail.
  - Seller sees delay reason and next action.
  - Seller asks one follow-up question.
- Deliberate exclusions:
  - No payment action execution.
  - No policy override.
  - No production model integration.

## 3. Experiment Pack

- Hypothesis: sellers can identify the delay reason and next action faster with guided explanation than with current static copy.
- Method: moderated prototype test with sellers who had delayed payouts in the last 60 days.
- Metrics:
  - Task success.
  - Time to identify next action.
  - Confidence score.
  - Guardrail: misinterpretation rate.
- Decision threshold:
  - Proceed to spec if task success and confidence improve without higher misinterpretation.

## 4. Build Handoff Pack

- REQ-001: Seller can see a plain-language payout delay reason.
- REQ-002: Seller can see the next recommended action.
- REQ-003: System must not reveal internal fraud or risk scoring details.
- REQ-004: Support can see the explanation shown to the seller.
- NFR-001: Explanation loads within agreed payout detail page threshold.
- Risk:
  - RI-001: explanation exposes sensitive operational rules.
  - Mitigation: approved reason taxonomy and blocked internal-only reason fields.

## 5. Jira/UAT Pack

| REQ ID | Story ID | AC ID | UAT ID | Release Check |
|---|---|---|---|---|
| REQ-001 | US-001 | AC-001 | UAT-001 | REL-001 |
| REQ-002 | US-001 | AC-002 | UAT-002 | REL-001 |
| REQ-003 | US-002 | AC-003 | UAT-003 | REL-002 |

Example AC:

- Given a seller has a delayed payout, when they open payout detail, then they see the approved delay reason.
- Given a delay reason is internal-only, when the seller opens payout detail, then the seller sees the approved external-safe reason.

## 6. Release Pack

- Release readiness verdict: ready after UAT signoff and support briefing.
- Rollout: enable for 10% of sellers with delayed payouts, then expand after metric review.
- Rollback: hide explanation module and revert to current static copy.
- Support handoff: provide reason taxonomy and known limitations.
- Accepted risk: sensitive reason taxonomy drift, owned by payout operations with weekly review during rollout.

## 7. Learning Pack

- Observation: sellers understood approved reason categories, but asked for expected resolution dates.
- Decision: iterate on SLA visibility before expanding to all payout delay cases.
- Memory update: "Do not expose internal risk scoring; use approved payout reason taxonomy."
- Roadmap recommendation: add resolution date confidence only after operations confirms data quality.
