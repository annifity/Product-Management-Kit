# Confluence Integration Notes

- Ask for space key and parent page when publishing.
- Prefer one parent page per feature with child pages for stories and UAT when the artifact set is large.
- Keep storage/export fallback under `.annifity/docs/exports/`.
- Cite page URLs when answering knowledge questions.

## Publishing Rules

- Treat generated pages as draft until the user approves publish.
- Preserve Markdown source one-to-one with generated Confluence export.
- Use strict HTML notes from PRD or user-story templates when the user asks for Confluence-ready HTML.
- Keep changelog rows append-only.
- Link Jira tickets inline when supported; keep story page links plain when readability is better.

## Fallback

If no connector is available, save Markdown or HTML export and report the exact local path.
