# Material Decision Preflight

Run this preflight before drafting a PRD, spec, prototype package, design handoff, delivery plan, user story, UAT package, release artifact, or controlled revision. Its purpose is to stop a structurally polished output from silently choosing product behavior, ownership, audience, or publication state.

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
| Design | Low-fidelity structure / delivery design / design-system handoff | Select by review decision, source maturity, design authority, and downstream consumer |
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

## User Confirmation Clarity Gate

Before asking a user to confirm a decision or placing it in `Open Questions`:

1. Name the exact decision in the first sentence using the user's language and product terminology.
2. Explain briefly why the decision is needed and which user-visible behavior, scope, or acceptance outcome it changes.
3. Ask one decision per question. Split business behavior from implementation design.
4. Offer two or three mutually exclusive options when the available choices are known. Describe the observable consequence of each option and identify the recommended option when evidence supports one.
5. Define unavoidable acronyms or technical terms. Do not require a business user to interpret architecture, API, storage, or orchestration language.
6. Assign technical implementation choices to the technical owner. Ask the product or business owner only for the behavior or outcome they own.
7. State the owner and whether the decision blocks the current artifact or can be deferred.

Use this compact pattern:

```markdown
Decision needed: [plain-language choice].
Why it matters: [user-visible or scope impact].
Options:
- A — [behavior and consequence].
- B — [behavior and consequence].
Recommendation: [option and short evidence-based reason, when applicable].
Owner / timing: [owner]; [blocking or deferred].
```

Good confirmation question:

> Decision needed: If an employee rejects an optional consent purpose, which Staff App functions remain available? This decision defines the user's access. Choose full block, limited access to named functions, or no access restriction. Product and Legal own the outcome; Architecture owns how it is implemented.

Anti-pattern:

> Does CTMS/ECMP return the access decision, or does Staff App Backend evaluate it from purpose-level results?

The anti-pattern asks a business reviewer to choose a technical mechanism without first resolving the user-visible access rule.

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
| Confirmation fog | A question says only “confirm this,” mixes several decisions, or uses unexplained technical language | The user cannot tell what they are approving or how the answer changes the product | Rewrite it as one plain-language decision with options, consequences, owner, and timing | Apply the User Confirmation Clarity Gate before presenting the question |

## Verdict

- **Ready:** Material decisions, mode, source authority, ownership, and baseline target are resolved.
- **Ready with labeled defaults:** Only non-material defaults remain and each has provenance.
- **Blocked:** A conflict or missing material decision would change scope, behavior, acceptance, ownership, or publication state.
