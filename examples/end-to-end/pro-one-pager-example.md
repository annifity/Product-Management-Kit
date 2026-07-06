# PRO One-Pager Example

## Input

"I want to prototype an AI feature that turns messy meeting notes into action items."

## Output

# PRO - Prototyping Requirements One-Pager

## 1. Problem Statement And Goal

- Teams lose decisions and action items after meetings because notes are scattered across docs, chat, and calendars.
- Goal: prototype an AI feature that turns raw meeting notes into clear action items, owners, and due dates in under 60 seconds.

## 2. Target Users And Use Case

- Busy knowledge workers who attend multiple meetings per day and struggle to track follow-ups.
- Core use case: paste notes, receive a clean task list, edit it, then save or copy it.

## 3. Key Requirements And Features

- Paste raw notes or bullet dumps into one input.
- Output action items with owner, due date suggestion, and confidence label.
- Edit any action item before saving.
- Export to task-list view or copy to clipboard.

## 4. AI Considerations

- Prioritize clarity over cleverness; keep language short and concrete.
- If notes are ambiguous, ask one quick follow-up question instead of guessing.
- Preserve original intent and avoid inventing commitments.

## 5. Golden Paths

- Path 1: paste messy notes and get 5-8 action items with owners and due dates.
- Path 2: edit two items, remove one, and save the list.
- Path 3: paste partial notes; AI asks one clarifying question, then finalizes.

## 6. Edge Cases And Risks

- Notes include multiple people with unclear ownership.
- Notes contain vague timing like "ASAP" or "someone should handle this."
- Notes include sensitive content that should not be stored or shown broadly.

## 7. Assumptions And Constraints

- Assumption: users can paste meeting notes when security rules allow it.
- Assumption: "good enough" action items beat perfect action items if editing is fast.
- Constraint: no calendar, task-tool, auth, backend, or production storage integration.

## 8. Success Metrics Or Criteria

- Most users get a usable task list in one attempt with minimal edits.
- Measure edit rate per task list, perceived usefulness, time to "ready to save," and helpfulness of follow-up questions.

## 9. Non-Goals

- No meeting transcription, live capture, fully automated task assignment, or custom model training.

## 10. Prompt-Ready Input For AI Prototyping

- For the selected frontend prototype builder: create a notes input area, generate button, and editable results panel with action item, owner, due date, and confidence. Simulate messy notes plus one ambiguity that triggers a single follow-up question. Explore minimal, spreadsheet-like, and chat-style UI variations.

## 11. Next Steps

- Build three UI concepts, run 5 quick usability tests focused on output trust and edit speed, choose the best concept, then test again with real notes from 3 teams.
