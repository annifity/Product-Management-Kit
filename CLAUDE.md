# Annifity - AI Product Manager Skills

Annifity is a portable PO operating system for Claude, Codex, Cursor, Copilot, and shared agent environments.

## Source Of Truth

- Canonical skills live only at `skills/*/SKILL.md`.
- Shared templates, workflows, checklists, schemas, and integration notes live under `_refs/`.
- Generated adapters live under `.claude/skills/`, `.codex/skills/`, `.github/skills/`, `.agents/skills/`, and `.cursor/rules/`.
- Do not edit generated adapters manually. Edit `skills/` or `_refs/`, then run `tools/sync-ai-skill-structures.ps1`.

## Skill Map

### Learning And Delivery Flow

| Skill | Use |
|---|---|
| `discovery` | Frame fuzzy ideas, clarify problem, explore options, confirm direction |
| `brief` | Convert confirmed direction into a one-page product outline |
| `prototype` | Prepare build-to-learn user flows, screens, wireframes, and builder prompts |
| `experiment` | Define hypotheses, metrics, tracking plans, samples, and decision criteria |
| `validate` | Review prototypes, experiments, specs, PRDs, stories, UAT, readiness, and risks |
| `learn` | Synthesize insight, retrospective, decision memo, and roadmap recommendation |
| `spec` | Convert confirmed learning or direction into requirements, workflows, risks, and open questions |
| `plan` | Build delivery plan, epic map, milestones, dependencies, and release slices |
| `execution` | Support active delivery, answer questions, triage decisions, manage scope |
| `ship` | Prepare release package, final docs, signoff, and post-ship memory |

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
- Follow the Annifity learning and delivery path for end-to-end work: `discovery -> brief -> prototype -> experiment -> validate -> learn -> spec -> plan -> execution -> ship`.
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
