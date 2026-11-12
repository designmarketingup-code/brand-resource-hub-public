# Brand Resource Hub

- `index.html` - the complete website (single file, no dependencies). Open it in a browser or host it on any static host.
- `brands-data.json` - all brand data exported from the live artifact (names, categories, content sheet, upload folder and guideline URLs).
- `index-claude-artifact.html` - the original page as published on claude.ai (needs the claude.ai runtime; shared database, Editor-only editing).

## Standalone behavior
In `index.html`, brand data is embedded and edits made in **Edit Resources** are saved in that browser's localStorage only.
Everyone who opens the file sees the embedded data until they edit locally. To share edits across a team you need a shared backend
(or keep using the claude.ai artifact). Edit access is open in the standalone copy; add real authentication before hosting it publicly.

## Automation
`triggerKhelstakeAutomation()` and `AUTOMATION_CONFIG.endpoint` in `index.html` are the n8n hook points. Use `setAutomationRun({...})` to update status.
Keep API keys/webhook secrets on a server-side endpoint, never in this file.
