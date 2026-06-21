# Annifity - AI Product Manager Skills

Annifity is a portable PO operating system for Claude, Codex, Cursor, Copilot, and shared agent environments.

## Source Of Truth

- Canonical skills live only at `skills/*/SKILL.md`.
- Shared templates, workflows, checklists, schemas, and integration notes live under `_refs/`.
- Generated adapters live under `.claude/skills/`, `.codex/skills/`, `.github/skills/`, `.agents/skills/`, and `.cursor/rules/`.
- Do not edit generated adapters manually. Edit `skills/` or `_refs/`, then run `tools/sync-ai-skill-structures.ps1`.

## Skill Map

### PO Flow

| Skill | Use |
|---|---|
| `po-brainstorming` | Frame fuzzy ideas, clarify problem, explore options, confirm direction |
| `po-spec` | Convert confirmed direction into requirements, workflows, risks, and open questions |
| `po-plan` | Build delivery plan, epic map, milestones, dependencies, and release slices |
| `po-execution` | Support active delivery, answer questions, triage decisions, manage scope |
| `po-review` | Review specs, PRDs, stories, UAT, readiness, and risks |
| `po-ship` | Prepare release package, final docs, signoff, and post-ship memory |

### Background Habits

| Skill | Use |
|---|---|
| `docs` | Save, index, export, and changelog artifacts in `.annifity/docs/` |
| `memories` | Read and update durable context in `.annifity/memories/` |

### Artifacts

| Skill | Use |
|---|---|
| `prd` | Create, revise, review, translate, or export PRDs |
| `user-story` | Create, split, review, or export stories and acceptance criteria |
| `uat` | Create or review UAT plans and test cases |
| `change` | Manage requirement changes with impact analysis and changelog |
| `knowledge` | Search and synthesize local, Jira, Confluence, or connector-backed knowledge |

## Working Rules

- Match the user's language by default.
- Follow gated PO flow for end-to-end work: `po-brainstorming -> po-spec -> po-plan -> po-execution -> po-review -> po-ship`.
- Use `docs` after artifact creation or phase gates.
- Use `memories` before workflows and after durable decisions.
- Load only relevant `_refs/` files for the current task.
- If an adapter conflicts with a canonical skill, the canonical skill wins.

## Sync And Hooks

Run checks manually:

```powershell
npm run check
```

Regenerate adapters manually:

```powershell
npm run sync
```

Install Lefthook after cloning:

```powershell
npm install
```

The Lefthook pre-commit runs `tools/pre-commit-annifity.ps1`, which:

1. Runs `tools/check-self-contained.ps1`
2. Runs `tools/sync-ai-skill-structures.ps1`
3. Runs `tools/test-annifity.ps1`
4. Stages generated adapter files

If Lefthook is unavailable, `.githooks/pre-commit` calls the same script as a fallback.
