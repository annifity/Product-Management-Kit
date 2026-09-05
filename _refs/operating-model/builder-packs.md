# Builder Packs

Annifity is a Product Builder Kit: users should know what package they get at each point in the build journey. Use these packs to bundle artifacts, evidence, and handoff context.

Every generated pack carries a concise, localized result that tells the user
what was created or updated, the human-readable target and source, baseline
impact, unresolved blockers, and the next action. Keep the resolved contract
fingerprint, raw hashes, internal source IDs, resolver state, and project-profile
details in a machine-readable companion or technical audit record unless the
user explicitly requests diagnostics. Run
`_refs/checklists/material-decision-preflight.md` before authoring and
`_refs/checklists/source-backed-minimality.md` before handoff.

## Discovery Pack

Use after `discovery` when the opportunity is shaped but not yet committed.

- Problem statement without solution language.
- Target users and jobs.
- Evidence summary and confidence.
- Source-linked customer findings, counterevidence, and method or privacy limits
  when interviews or qualitative research are used.
- Provisional customer jobs and circumstances when supported by evidence.
- Opportunity or solution options with trade-offs.
- Scope in / scope out.
- Assumptions and open questions.
- Success metric draft.
- Recommended next gate.

## Prototype Pack

Use after `brief` or `prototype` when the goal is build-to-learn.

- PRO - Prototyping Requirements One-Pager when a raw idea needs prompt-ready frontend prototype builder input.
- Prototype First Workflow state: PRO -> selected frontend prototype builder -> runnable FE prototype with mock data -> feedback -> validate/learn -> PRD when learning is sufficient.
- Learning objective and riskiest assumptions.
- Minimum user flow.
- Screen list or wireframe description.
- Builder prompt when relevant.
- Out-of-scope behaviors.
- Validation method and decision criteria.

## Strategy Pack

Use when evidence must become a product-direction or portfolio investment choice.

- Decision owner and horizon.
- Product vision, target segments, and intended outcomes.
- Where-to-play and how-to-win choices.
- Portfolio bet posture: explore, validate, invest, sustain, sequence, pause, or stop.
- Investment and capacity constraints.
- Explicit exclusions and displaced work.
- Outcome measures, guardrails, invalidation conditions, and review triggers.
- Evidence confidence, dissent, and stakeholder decision record.

## Experiment Pack

Use when evidence is needed before committed delivery.

- Hypothesis.
- Participant/sample plan.
- Metrics, guardrails, and tracking events.
- Decision thresholds.
- For AI behavior: versioned evaluation set, representative and adversarial
  slices, calibrated graders, baseline comparison, non-regression rule, and
  latency/cost budgets.
- Evidence ledger entry.
- Learning synthesis plan.

## Build Handoff Pack

Use when a validated direction is ready for implementation planning.

- Product spec with requirement IDs.
- AI behavior contract with autonomy, human authority, data/retrieval/tool
  boundaries, acceptance signals, evaluation obligations, and monitoring when
  AI is material.
- Business rules and state behavior.
- Data/API requirements.
- Non-functional requirements.
- Risk register.
- Requirement traceability matrix.
- Delivery plan, epics, dependencies, and grooming questions.

## Design Handoff Pack

Use after an accepted spec when user-visible behavior needs a reviewable design
contract before delivery planning, story authoring, or implementation.

- Exact human-readable source baseline, requirement IDs, and design authority.
- Design contract with stable flow, screen, state, interaction, and gap IDs.
- Information architecture, user flows, and screen inventory.
- Screen specifications and applicable interaction/state matrix.
- Accepted design-system binding or clearly labeled provisional visual direction.
- Responsive, accessibility, content, permission, privacy, and applicable
  AI-native UX obligations.
- `REQ -> FLOW -> SCREEN -> STATE/INTERACTION` traceability.
- Design-gap register, review evidence, Design Gate decision, and concise
  user-facing result.

## Jira/UAT Pack

Use when scope must be split, assigned, tested, and accepted.

- Epic map.
- Jira-ready stories.
- Source-aligned Given/When/Then acceptance criteria with stable AC IDs.
- UAT plan and test case register.
- Permission, boundary, unhappy path, and NFR scenarios.
- Coverage report: REQ-ID -> STORY-ID -> AC-ID -> TC-ID.

## Release Pack

Use when the team is preparing to ship, hand off, retire, or publish final documentation.

- Release readiness verdict.
- UAT signoff summary.
- Rollout, rollback, and support notes.
- Stakeholder communication.
- Operational readiness gaps.
- Accepted risks with owners.
- Release note and final artifact list.
- Audience, positioning, enablement, launch-channel, and adoption plan when a go-to-market motion is required.

## Learning Pack

Use after validation, experiment, release, or post-ship review.

- Observations separated from interpretations.
- Prototype feedback summary when feedback comes from a runnable prototype.
- Decision memo.
- Metric results against baseline and target.
- Roadmap recommendation.
- Memory updates.
- Next-loop recommendation.

## Priority Decision Pack

- Decision, owner, horizon, option set, and capacity constraint.
- Selected and rejected methods.
- Raw inputs, ranked options, evidence confidence, and sensitivity.
- Displaced work, verdict, next action, and review trigger.

## Analytics Diagnosis Pack

- Decision question, metric and event contracts, population, and window.
- Data-quality, funnel, cohort, retention, activation, or adoption findings as applicable.
- Competing explanations, causality limits, missing instrumentation, and next analysis.

## Growth Plan

- Growth model, critical event, natural frequency, and binding constraint.
- Cohort and segment evidence, drivers, detractors, and confounders.
- Prioritized interventions, anti-plays, experiments, guardrails, owners, and review triggers.

## Commercial Decision Pack

- Decision, alternatives, source and assumption ledger.
- Deterministic metrics, formula definitions, and scenario sensitivity.
- Customer-value, revenue, margin, and risk implications.
- Verdict, invalidation condition, owner, and next evidence.

## GTM And Adoption Pack

- ICP, buyer/user roles, positioning, message hierarchy, and launch tier.
- Audience sequence, channel rationale, enablement, adoption hypothesis, and counter-metrics.
- Dependencies, owners, stop conditions, and handoff to operational release readiness.

## Competitive Intelligence Pack

- Dated scope, competitor baseline, source ledger, and evidence classification.
- Change digest, product implications, counterevidence, confidence, and watch triggers.
- Receiving decision owner; no automatic roadmap commitment.
