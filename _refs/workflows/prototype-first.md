# Prototype First Workflow

Display name: Prototype First Workflow

Description: Create PRO first, generate prototype, collect feedback, then produce PRD.

Use this when the user wants to validate quickly, create a prototype, demo UI, test value, explore concept fit, collect client feedback before build, or is not sure the solution is right.

## Workflow Selector

When a new request does not clearly choose a workflow, ask:

"Bạn muốn đi theo hướng nào?
A. Prototype First: tạo PRO dưới 500 từ -> generate prototype -> lấy feedback -> viết PRD sau.
B. Traditional: làm rõ spec -> viết PRD chi tiết ngay."

Auto-select Prototype First when the user says prototype, validate quickly, demo UI, mockup, runnable FE, test idea, client feedback before build, PRO, frontend prototype builder, or a specific builder such as `sdcorejs-agent`.

Auto-select Traditional when the user says detailed PRD, full spec, engineering handoff, backlog, delivery planning, or confirmed requirement, unless they also mention prototype-first validation.

## Prototype First Flow

Initial Request / Idea
-> Light Discovery if needed
-> PRO - Prototyping Requirements One-Pager
-> Prototype Builder Input (tool-agnostic; for example `sdcorejs-agent`)
-> Runnable FE Prototype with mock data
-> Client/User Feedback
-> Validate / Learn
-> Detailed PRD if the prototype has enough learning or the user asks for it

Rules:

- Do not create PRD before PRO.
- Do not create a full spec before PRO unless a very short clarification is needed.
- Do not create backlog, user story, or Jira ticket before prototype learning unless the user explicitly asks.
- PRO is the first artifact.
- PRD after prototype feedback requires at least one input: client feedback, user feedback, prototype review notes, validation result, learning summary, or stakeholder decision.

## Traditional Workflow

Initial Request / Requirement
-> Discovery/Clarification if needed
-> Spec
-> PRD
-> Plan/User Story/UAT if needed

Rules:

- Confirmed spec + user asks for PRD -> Traditional Workflow.
- Spec is the source of truth for PRD.
- Use traditional flow when requirements are clear, stakeholders need a detailed document, or the team needs delivery handoff / engineering planning.

## Routing Cases

| Request | Route |
|---|---|
| Raw idea + need prototype/validate quickly | Prototype First Workflow |
| Raw idea + user asks for PRO | Prototype First Workflow |
| Raw idea + user asks for UI prototype | Prototype First Workflow |
| Raw idea + user asks for PRD but also mentions prototype | recommend Prototype First before PRD |
| PRO + client feedback | PRD from PRO + Client Feedback |
| Confirmed spec + user asks for PRD | Traditional Workflow, spec -> PRD |
| Engineering handoff/build planning | Traditional Workflow unless prototype learning already exists |

## Prototype First Source Of Truth

- Before prototype: PRO is the temporary source of truth.
- After prototype review: PRO + feedback + learning is the source of truth.
- When PRD is created: PRD must trace back to PRO and feedback.
- Do not include assumptions that feedback has rejected.

## Traditional Source Of Truth

- Spec is the source of truth for PRD.
- PRD must trace back to spec.
