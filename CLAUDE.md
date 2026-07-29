# Annifity - AI Product Builder Kit Skills

Annifity is a portable Product Builder Kit for Claude, Codex, Cursor, and Copilot project environments.

## Source Of Truth

- Canonical skill instructions live at `skills/*/SKILL.md`.
- Canonical Codex UI metadata lives at `skills/*/agents/openai.yaml`.
- Shared templates, workflows, checklists, schemas, and integration notes live under `_refs/`.
- Generated adapters live under `.claude/skills/`, `.codex/skills/`, `.github/skills/`, and `.cursor/rules/`.
- Generated adapters are project-local and require the full repository root; do not install an adapter folder by itself.
- Do not edit generated adapters manually. Edit `skills/` or `_refs/`, then run `tools/sync-ai-skill-structures.ps1`.

## Skill Map

### Builder Path

| Skill | Use |
|---|---|
| `discovery` | Frame fuzzy ideas, clarify problem, explore options, confirm direction |
| `brief` | Convert confirmed direction into a one-page product outline |
| `prototype` | Prepare build-to-learn user flows, screens, wireframes, and builder prompts |
| `experiment` | Define hypotheses, metrics, tracking plans, samples, and decision criteria |
| `validate` | Audit existing prototypes, evidence, artifacts, skills, readiness, and risks |
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
| `prd` | Create, revise, translate, or export PRDs and BRDs |
| `user-story` | Create, split, revise, map, or export stories and acceptance criteria |
| `uat` | Create, refine, execute, or record UAT plans and test cases |
| `change` | Manage requirement changes with impact analysis and changelog |
| `knowledge` | Search and synthesize local, Jira, Confluence, or connector-backed knowledge |

## Working Rules

- Match the user's language by default.
- Follow the Annifity builder path for end-to-end work: `discovery -> brief -> prototype -> experiment -> validate -> learn -> spec -> plan -> execution -> ship`.
- Use `docs` after artifact creation or phase gates.
- Use `memories` before workflows and after durable decisions.
- Resolve the artifact-generation contract and applicable project profile before drafting; do not silently invent material decisions.
- Return the compact generation receipt with authored artifacts: fingerprint, disposition, source IDs, and exact baseline target.
- Resolve governed artifacts through the authoritative baseline registry rather than guessing from filenames or dates.
- Apply source-backed minimality, negative-completeness checks, and the local mutation-safety workflow before changing controlled files.
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
2. Runs `tools/test-skill-format.ps1`
3. Runs `tools/check-ref-integrity.ps1`
4. Runs `tools/test-skill-routing.ps1`
5. Runs `tools/sync-ai-skill-structures.ps1`
6. Runs `tools/build-docs-site.ps1`
7. Runs `tools/test-skill-contracts.ps1`
8. Runs `tools/test-annifity.ps1`
9. Stages generated adapter files, deprecated adapter removals, and `docs/data/catalog.js`

If Lefthook is unavailable, `.githooks/pre-commit` calls the same script as a fallback.
