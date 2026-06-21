# Annifity AI Product Manager Skills

Annifity is a portable PO operating system for brainstorming, specification, planning, execution support, review, shipping, documentation, memory, and product artifacts.

## Source Of Truth

- Canonical skill files live under top-level skills/*/SKILL.md only.
- Shared PM templates, checklists, and workflows live under _refs/.
- Generated adapters live under .claude/skills/, .github/skills/, .agents/skills/, .codex/skills/, and .cursor/rules/.
- Do not edit generated adapters manually. Edit skills/ or _refs/, then run tools/sync-ai-skill-structures.ps1.

## Working Rules

- Match the user's language by default; Vietnamese and English are both first-class.
- Follow the PO phase gates: po-brainstorming -> po-spec -> po-plan -> po-execution -> po-review -> po-ship.
- Use docs to save and index artifacts, and memories to persist durable context across workflow gates.
- For ambiguous requirements, clarify before drafting final deliverables.
- Load only the relevant skill and reference files for the task; avoid pulling the whole repository into context.
- If an adapter conflicts with a canonical skill file, the canonical skill file wins.

## Available Skills

- change: Manage requirement changes to existing PRDs, specs, user stories, UAT, or release scope. Use when requirements change mid-flight, a stakeholder updates scope, a document needs controlled edits, or impact analysis and changelog are required. Source: skills/change/SKILL.md
- docs: Maintain Annifity working documents automatically. Use alongside every PO workflow to create, update, index, export, and summarize PRDs, specs, user stories, UAT cases, decision logs, changelogs, session notes, and release documents in `.annifity/docs/`. Source: skills/docs/SKILL.md
- knowledge: Retrieve and synthesize organizational product knowledge from local docs, pasted context, Jira, Confluence, or available workspace connectors. Use for feature existence checks, ownership questions, decision history, runbooks, and product context lookup. Source: skills/knowledge/SKILL.md
- memories: Maintain durable Annifity product memory. Use before and after PO workflows to read and update product context, team preferences, terminology, stakeholder constraints, decisions, assumptions, and open questions in `.annifity/memories/`. Source: skills/memories/SKILL.md
- po-brainstorming: Explore early product ideas, stakeholder asks, vague feature requests, or unclear problems before writing specs or artifacts. Use when the user needs PO-style brainstorming, problem framing, discovery questions, option exploration, scope clarification, or a Superpowers-like gate before moving to specification. Source: skills/po-brainstorming/SKILL.md
- po-execution: Support active delivery after planning begins. Use for developer questions, scope decisions, requirement interpretation, blocked tickets, acceptance clarification, trade-off decisions, and controlled updates while implementation is underway. Source: skills/po-execution/SKILL.md
- po-plan: Convert a confirmed product spec into a delivery plan, epic map, release slices, dependency map, milestone plan, and team handoff sequence. Use after specification and before execution or story writing. Source: skills/po-plan/SKILL.md
- po-review: Review product artifacts before handoff, sprint commitment, QA, or release. Use for reviewing PRDs, specs, user stories, acceptance criteria, UAT cases, risks, edge cases, readiness, and document quality. Source: skills/po-review/SKILL.md
- po-ship: Prepare a product change for release or stakeholder handoff. Use for release readiness, signoff, final document bundle, release notes, decision summary, UAT signoff, and post-ship memory capture. Source: skills/po-ship/SKILL.md
- po-spec: Turn a confirmed product idea, PRD input, BRD, meeting note, or brainstorming brief into a precise product specification. Use for scope, requirements, workflows, edge cases, data rules, non-functional requirements, assumptions, risks, and open questions before delivery planning. Source: skills/po-spec/SKILL.md
- prd: Create, revise, review, translate, or export Product Requirement Documents. Use when the user asks for a PRD, PRD draft, PRD review, product requirements document, product spec document, PRD translation, PRD export, or Confluence-ready PRD. Source: skills/prd/SKILL.md
- uat: Create or review User Acceptance Testing plans and test cases from PRDs, specs, user stories, acceptance criteria, or release scope. Use for UAT coverage, role-based scenarios, happy paths, unhappy paths, boundary cases, and signoff readiness. Source: skills/uat/SKILL.md
- user-story: Create, split, refine, review, or export user stories and acceptance criteria from a PRD, BRD, feature spec, or confirmed product plan. Use for INVEST stories, story maps, Jira-ready stories, Given/When/Then acceptance criteria, and story quality review. Source: skills/user-story/SKILL.md
