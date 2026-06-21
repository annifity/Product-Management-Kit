# Annifity AI PM Instructions

Use Annifity for product-management work: PO brainstorming, product specs, delivery planning, execution support, artifact review, shipping, docs, memories, PRDs, user stories, UAT, change management, and org knowledge lookup.

Canonical source lives in top-level skills/*/SKILL.md and _refs/. Generated Copilot skill adapters live in .github/skills/; do not edit adapters manually. Update skills/ or _refs/, then run tools/sync-ai-skill-structures.ps1.

Match the user's language by default. Follow the PO phase gates when doing end-to-end product work. Use docs to save artifacts and memories to preserve durable product context. Clarify ambiguous requirements before drafting final deliverables.

Top-level skills:

- change: Manage requirement changes to existing PRDs, specs, user stories, UAT, or release scope. Use when requirements change mid-flight, a stakeholder updates scope, a document needs controlled edits, or impact analysis and changelog are required.
- docs: Maintain Annifity working documents automatically. Use alongside every PO workflow to create, update, index, export, and summarize PRDs, specs, user stories, UAT cases, decision logs, changelogs, session notes, and release documents in `.annifity/docs/`.
- knowledge: Retrieve and synthesize organizational product knowledge from local docs, pasted context, Jira, Confluence, or available workspace connectors. Use for feature existence checks, ownership questions, decision history, runbooks, and product context lookup.
- memories: Maintain durable Annifity product memory. Use before and after PO workflows to read and update product context, team preferences, terminology, stakeholder constraints, decisions, assumptions, and open questions in `.annifity/memories/`.
- po-brainstorming: Explore early product ideas, stakeholder asks, vague feature requests, or unclear problems before writing specs or artifacts. Use when the user needs PO-style brainstorming, problem framing, discovery questions, option exploration, scope clarification, or a Superpowers-like gate before moving to specification.
- po-execution: Support active delivery after planning begins. Use for developer questions, scope decisions, requirement interpretation, blocked tickets, acceptance clarification, trade-off decisions, and controlled updates while implementation is underway.
- po-plan: Convert a confirmed product spec into a delivery plan, epic map, release slices, dependency map, milestone plan, and team handoff sequence. Use after specification and before execution or story writing.
- po-review: Review product artifacts before handoff, sprint commitment, QA, or release. Use for reviewing PRDs, specs, user stories, acceptance criteria, UAT cases, risks, edge cases, readiness, and document quality.
- po-ship: Prepare a product change for release or stakeholder handoff. Use for release readiness, signoff, final document bundle, release notes, decision summary, UAT signoff, and post-ship memory capture.
- po-spec: Turn a confirmed product idea, PRD input, BRD, meeting note, or brainstorming brief into a precise product specification. Use for scope, requirements, workflows, edge cases, data rules, non-functional requirements, assumptions, risks, and open questions before delivery planning.
- prd: Create, revise, review, translate, or export Product Requirement Documents. Use when the user asks for a PRD, PRD draft, PRD review, product requirements document, product spec document, PRD translation, PRD export, or Confluence-ready PRD.
- uat: Create or review User Acceptance Testing plans and test cases from PRDs, specs, user stories, acceptance criteria, or release scope. Use for UAT coverage, role-based scenarios, happy paths, unhappy paths, boundary cases, and signoff readiness.
- user-story: Create, split, refine, review, or export user stories and acceptance criteria from a PRD, BRD, feature spec, or confirmed product plan. Use for INVEST stories, story maps, Jira-ready stories, Given/When/Then acceptance criteria, and story quality review.
