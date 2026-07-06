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

- change: Manage requirement changes to existing PRDs, BRDs, specs, user stories, UAT, Jira tickets, Confluence pages, or release scope. Use when requirements change mid-flight, a stakeholder updates scope, a document needs controlled edits, spec versioning, surgical patching, impact analysis, changelog, notification, or AI context handoff. Source: skills/change/SKILL.md
- docs: Maintain Annifity working documents automatically. Use alongside every PO workflow to create, update, index, export, summarize, version, and link PRDs, BRDs, specs, user stories, UAT cases, decision logs, decision ledger records, changelogs, templates, session notes, release documents, and traceability artifacts in `.annifity/docs/`. Source: skills/docs/SKILL.md
- knowledge: Retrieve and synthesize organizational product knowledge from local docs, memories, decision ledger records, pasted context, Jira, Confluence, or available workspace connectors. Use for feature existence checks, ownership questions, decision history, archaeology of past decisions, runbooks, artifact lookup, template lookup, and product context retrieval. Source: skills/knowledge/SKILL.md
- memories: Maintain durable Annifity product memory. Use before and after PO workflows to read and update product context, team preferences, terminology, stakeholder constraints, decisions, decision outcomes, assumptions, template preferences, lessons learned, and open questions in `.annifity/memories/`. Source: skills/memories/SKILL.md
- po-brainstorming: Explore early product ideas, stakeholder asks, vague feature requests, product discovery, opportunity framing, strategy questions, solution options, scope clarification, market sizing, finance or business model thinking, workshop facilitation, external research, AI context design, or problem framing before writing specs or artifacts. Use when the user needs PO-style brainstorming, discovery questions, option exploration, opportunity scoring, market/finance analysis, or a phase gate before moving to specification. Source: skills/po-brainstorming/SKILL.md
- po-execution: Support active delivery after planning begins. Use for developer questions, scope decisions, requirement interpretation, blocked tickets, acceptance clarification, trade-off decisions, Jira/Confluence context handoff, dependency decisions, and controlled updates while implementation is underway. Source: skills/po-execution/SKILL.md
- po-plan: Convert a confirmed product spec into a delivery plan, roadmap slice, prioritization decision, business case, market/finance-informed investment decision, epic map, release slices, dependency map, milestone plan, grooming questions, and team handoff sequence. Use after specification and before execution, story writing, sprint planning, or roadmap communication. Source: skills/po-plan/SKILL.md
- po-review: Review product artifacts before handoff, sprint commitment, QA, release, stakeholder approval, or implementation. Use for reviewing PRDs, BRDs, specs, user stories, acceptance criteria, UAT cases, risk registers, traceability, edge cases, sprint readiness, operational readiness, delivery readiness, and document quality. Source: skills/po-review/SKILL.md
- po-ship: Prepare a product change for release, rollout, stakeholder handoff, support handoff, or retirement. Use for release readiness, launch plan, support notes, rollback plan, EOL communication, signoff, final document bundle, release notes, decision summary, UAT signoff, and post-ship memory capture. Source: skills/po-ship/SKILL.md
- po-spec: Turn a confirmed product idea, PRD input, BRD, meeting note, discovery brief, roadmap item, or brainstorming brief into a precise product specification. Use for BRD analysis, feature design, scope, business rules, requirements, workflows, state behavior, edge cases, data/API rules, non-functional requirements, assumptions, risks, and open questions before delivery planning. Source: skills/po-spec/SKILL.md
- prd: Create, revise, review, translate, or export Product Requirement Documents and BRD-style requirement artifacts. Use when the user asks for a PRD, BRD, one-pager, product requirements document, product spec document, PRD/BRD review, translation, export, Confluence-ready document, or strict Confluence HTML. Source: skills/prd/SKILL.md
- uat: Create or review User Acceptance Testing plans, scenario tests, test case registers, and coverage reports from PRDs, BRDs, specs, user stories, acceptance criteria, or release scope. Use for UAT coverage, role-based scenarios, happy paths, unhappy paths, boundary cases, permission validation, NFR scenarios, execution logs, and signoff readiness. Source: skills/uat/SKILL.md
- user-story: Create, split, refine, review, map, or export user stories, epics, acceptance criteria, story maps, Jira tickets, and Confluence-ready story pages from a PRD, BRD, feature spec, roadmap item, or confirmed product plan. Use for INVEST stories, story splitting, epic breakdown, story maps, Jira-ready stories, Given/When/Then acceptance criteria, and story quality review. Source: skills/user-story/SKILL.md
