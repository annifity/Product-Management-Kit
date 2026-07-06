# Confluence PRD Strict HTML Notes

Use only when the user requests Confluence-ready HTML.

## Required Sections

1. Document Information.
2. Executive Summary.
3. Customers and Personas.
4. In Scope.
5. Out of Scope.
6. User Stories.
7. Functional Requirements.
8. Dependencies and Risks.
9. Metrics and NFRs when relevant.
10. Changelog.

## Strict Rules

- Tables use `thead` and `tbody`.
- Header cells include background color and readable text color.
- Lists use proper list item wrapping for Confluence storage compatibility.
- Changelog is append-only.
- Ticket and epic links use inline card appearance when Confluence supports it.
- Story page links stay plain when readability matters.
- Status colors: Added green, Modified yellow, Rejected red, Removed red.
- If connector publishing is unavailable, save HTML or Markdown under `.annifity/docs/exports/`.
