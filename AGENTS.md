# Annifity AI Product Manager Skills

Annifity is a portable PO operating system for discovery, briefs, prototypes, experiments, validation, learning, specification, planning, execution support, shipping, documentation, memory, and product artifacts.

## Source Of Truth

- Canonical skill files live under top-level skills/*/SKILL.md only.
- Shared PM templates, checklists, and workflows live under _refs/.
- Generated adapters live under .claude/skills/, .github/skills/, .agents/skills/, .codex/skills/, and .cursor/rules/.
- Do not edit generated adapters manually. Edit skills/ or _refs/, then run tools/sync-ai-skill-structures.ps1.

## Working Rules

- Match the user's language by default; Vietnamese and English are both first-class.
- Follow the Annifity learning and delivery path: discovery -> brief -> prototype -> experiment -> validate -> learn -> spec -> plan -> execution -> ship.
- Use docs to save and index artifacts, and memories to persist durable context across workflow gates.
- For ambiguous requirements, clarify before drafting final deliverables.
- Load only the relevant skill and reference files for the task; avoid pulling the whole repository into context.
- If an adapter conflicts with a canonical skill file, the canonical skill file wins.

## Available Skills

- brief: Use when a confirmed discovery direction needs a concise one-pager or Product Requirements Outline before prototype, experiment, spec, roadmap, or stakeholder alignment work. Applies to problem framing, goals, target users, scope, success metrics, AI-specific requirements, edge cases, and risks. Source: skills/brief/SKILL.md
- change: Manage requirement changes to existing PRDs, BRDs, specs, user stories, UAT, Jira tickets, Confluence pages, or release scope. Use when requirements change mid-flight, a stakeholder updates scope, a document needs controlled edits, spec versioning, surgical patching, impact analysis, changelog, notification, or AI context handoff. Source: skills/change/SKILL.md
- discovery: Use when early product ideas, stakeholder asks, vague feature requests, product discovery, opportunity framing, strategy questions, solution options, scope clarification, market sizing, finance or business model thinking, workshop facilitation, external research, AI context design, or problem framing need shaping before a brief, prototype, experiment, spec, or artifact. Source: skills/discovery/SKILL.md
- docs: Maintain Annifity working documents automatically. Use alongside every PO workflow to create, update, index, export, summarize, version, and link PRDs, BRDs, specs, user stories, UAT cases, decision logs, decision ledger records, changelogs, templates, session notes, release documents, and traceability artifacts in `.annifity/docs/`. Source: skills/docs/SKILL.md
- execution: Use when active delivery after planning begins needs product-owner support, including developer questions, scope decisions, requirement interpretation, blocked tickets, acceptance clarification, trade-off decisions, Jira/Confluence context handoff, dependency decisions, or controlled updates while implementation is underway. Source: skills/execution/SKILL.md
- experiment: Use when a product hypothesis, prototype, or brief needs a validation experiment with success metrics, tracking plan, decision criteria, sample size, learning plan, or evidence design. Applies before building production scope and differs from UAT, which verifies acceptance of committed delivery. Source: skills/experiment/SKILL.md
- knowledge: Retrieve and synthesize organizational product knowledge from local docs, memories, decision ledger records, pasted context, Jira, Confluence, or available workspace connectors. Use for feature existence checks, ownership questions, decision history, archaeology of past decisions, runbooks, artifact lookup, template lookup, and product context retrieval. Source: skills/knowledge/SKILL.md
- learn: Use when discovery, prototype, experiment, validation, release, or post-ship evidence needs to become an insight summary, product retrospective, decision memo, roadmap recommendation, memory update, or next-loop recommendation. Source: skills/learn/SKILL.md
- memories: Maintain durable Annifity product memory. Use before and after PO workflows to read and update product context, team preferences, terminology, stakeholder constraints, decisions, decision outcomes, assumptions, template preferences, lessons learned, and open questions in `.annifity/memories/`. Source: skills/memories/SKILL.md
- plan: Use when a confirmed product spec needs a delivery plan, roadmap slice, prioritization decision, business case, market/finance-informed investment decision, epic map, release slices, dependency map, milestone plan, grooming questions, or team handoff sequence before execution, story writing, sprint planning, or roadmap communication. Source: skills/plan/SKILL.md
- prd: Create, revise, review, translate, or export Product Requirement Documents and BRD-style requirement artifacts. Use when the user asks for a PRD, BRD, one-pager, product requirements document, product spec document, PRD/BRD review, translation, export, Confluence-ready document, or strict Confluence HTML. Source: skills/prd/SKILL.md
- prototype: Use when a product brief or validated direction needs a build-to-learn prototype plan, user flow, screen list, wireframe description, clickable mockup prompt, Claude Code prompt, Lovable prompt, Bolt prompt, or prototype handoff before experimentation or specification. Source: skills/prototype/SKILL.md
- ship: Use when a product change needs release, rollout, stakeholder handoff, support handoff, retirement, release readiness, launch planning, support notes, rollback planning, EOL communication, signoff, final document bundle, release notes, decision summary, UAT signoff, or post-ship memory capture. Source: skills/ship/SKILL.md
- spec: Use when a confirmed product idea, PRD input, BRD, meeting note, discovery brief, roadmap item, learning outcome, or brainstorming brief needs to become a precise product specification with scope, business rules, workflows, state behavior, edge cases, data/API rules, non-functional requirements, assumptions, risks, and open questions before delivery planning. Source: skills/spec/SKILL.md
- uat: Create or review User Acceptance Testing plans, scenario tests, test case registers, and coverage reports from PRDs, BRDs, specs, user stories, acceptance criteria, or release scope. Use for UAT coverage, role-based scenarios, happy paths, unhappy paths, boundary cases, permission validation, NFR scenarios, execution logs, and signoff readiness. Source: skills/uat/SKILL.md
- user-story: Create, split, refine, review, map, or export user stories, epics, acceptance criteria, story maps, Jira tickets, and Confluence-ready story pages from a PRD, BRD, feature spec, roadmap item, or confirmed product plan. Use for INVEST stories, story splitting, epic breakdown, story maps, Jira-ready stories, Given/When/Then acceptance criteria, and story quality review. Source: skills/user-story/SKILL.md
- validate: Use when product artifacts, prototypes, experiments, sprint scope, QA packages, release readiness, stakeholder handoff, or implementation inputs need validation. Applies to PRDs, BRDs, specs, user stories, acceptance criteria, UAT cases, risk registers, traceability, edge cases, sprint readiness, operational readiness, delivery readiness, experiment outcomes, and document quality. Source: skills/validate/SKILL.md
