# Material Decision Preflight

Run this preflight before drafting a PRD, spec, prototype package, delivery plan, user story, UAT package, release artifact, or controlled revision. Its purpose is to stop a structurally polished output from silently choosing product behavior, ownership, audience, or publication state.

Reuse supplied context. Do not ask again for a decision already present in the request, current accepted baseline, active decision record, project profile, or memories.

## Decision Card

Resolve these fields in `_refs/schemas/artifact-generation-contract.md` before authoring:

| Field | Decision Needed |
|---|---|
| Outcome | What decision or action the artifact must enable |
| Consumer | Who will use it and at which workflow gate |
| Deliverable mode | The smallest mode that satisfies the outcome |
| Source authority | Ordered sources and any active conflict |
| Baseline target | New draft, draft revision, controlled baseline change, export, or publish |
| Actor and permission | Material actor, scope, permission, and denial owner |
| Surface and system | Product surface, system boundary, and adjacent capability |
| Behavior owner | Owning artifact, story, feature, or system for each material behavior |
| State and transition | Relevant states, allowed transitions, and protected states |
| Rules and severity | Confirmed thresholds, validation, blocker/warning severity, and outcomes |
| Design authority | Whether a mockup or prototype is illustrative or behavior-defining |
| NFR placement | Story-level, parent artifact, release gate, or not applicable |
| Format and destination | Markdown, Jira, Confluence, export, local path, metadata mode (`frontmatter` or `registry`), or other target |
| Open decisions | Material unknowns, owner, impact, and blocking status |

Mark each applicable field as `confirmed`, `inferred-non-material`, `open-blocker`, `conflict`, or `not-applicable`. Attach provenance to every confirmed or inferred value.

## Deliverable Mode Gate

Choose the mode before choosing a template:

| Artifact | Common Modes | Selection Rule |
|---|---|---|
| Brief or PRD | Direction brief / formal requirements / prototype-feedback PRD | Select by consumer and decision depth, not by document length |
| Spec | Workflow / product behavior / data / API | Include only the dimensions needed to make delivery decisions |
| User story | Concise Jira / detailed delivery / project-specific rule-based | Follow the resolved project profile and confirmed story boundary |
| UAT | Business demo / business acceptance / full regression | Select by audience, signoff purpose, and release risk before choosing coverage |
| Release artifact | Internal readiness / rollout / retirement / stakeholder handoff | Select by release decision and named owner |
| Document operation | Read-only / new draft / draft update / baseline change / export / external publish | Use the mutation and approval rules for the selected disposition |

If the user explicitly selects a mode, preserve it unless it conflicts with a committed source or safety gate. Do not expand a business-demo package into a regression suite or a concise story into a product specification.

## Gate Rules

Proceed when:

- every material field is confirmed or explicitly not applicable;
- any non-material inference is labeled with provenance and can be changed without altering scope or acceptance;
- the source hierarchy has one authoritative value for each material decision;
- the target baseline and write disposition are unambiguous.

Stop and route the gap to the owning skill when:

- authoritative sources conflict;
- an actor, permission, state, threshold, severity, expected outcome, or story owner must be invented;
- a mockup and accepted requirement disagree;
- the requested output would change committed scope without `change`;
- the selected deliverable mode cannot serve the stated consumer or decision.

Do not block on wording, formatting, optional metadata, or another non-material preference when a safe labeled default exists.

## Responsibility Preview

Before splitting or merging stories, or importing behavior from an adjacent capability, preview:

| Behavior | Owning Story/Artifact | Owning System | Authoritative Source | In Scope Here? |
|---|---|---|---|---|
| [Behavior] | [Owner] | [System] | [Source] | Yes / No / Open |

Confirm the responsibility preview when a different answer would change ticket count, acceptance ownership, integration scope, or release sequencing.

## Good Example

A request asks for UAT scenarios for a stakeholder demonstration. The source stories are baselined, the audience is business stakeholders, and no release signoff is requested. Select `business-demo`, retain representative happy paths and material business exceptions, and leave exhaustive security, concurrency, and technical reliability coverage in the linked regression package.

## Anti-pattern

A request asks for a roster publication story. Without resolving whether minimum staffing is a warning or blocker, the draft chooses a blocking outcome, invents grouped validation UI, and later splits assignment-time rules into the same story. The artifact looks complete but embeds three unconfirmed product decisions.

## Failure Modes

| Failure | Signal | Consequence | Correction | Prevention |
|---|---|---|---|---|
| Mode drift | Output is more detailed or targets a different audience than requested | User must simplify or restructure it | Re-select mode from consumer and decision | Complete the deliverable-mode gate first |
| Authority guess | A threshold, state, or outcome has no accepted source | Inferred behavior becomes delivery scope | Remove it or obtain a decision | Record provenance per material field |
| Ownership smear | One story contains behavior owned by another story or system | Split/merge churn and duplicated AC | Build the responsibility preview | Confirm owner before story slicing |
| Mockup promotion | Illustrative UI becomes accepted behavior without approval | Presentation details are over-specified | Mark mockup authority explicitly | Resolve design authority in the card |
| Repeated interrogation | Agent asks for context already stored in project memory | User repeats constraints and loses trust | Reuse the resolved profile and provenance | Apply the source precedence before asking |

## Verdict

- **Ready:** Material decisions, mode, source authority, ownership, and baseline target are resolved.
- **Ready with labeled defaults:** Only non-material defaults remain and each has provenance.
- **Blocked:** A conflict or missing material decision would change scope, behavior, acceptance, ownership, or publication state.
