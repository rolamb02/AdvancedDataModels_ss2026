---
name: "Sync CLAUDE and Copilot Instructions"
description: "Synchronize CLAUDE.md and .github/copilot-instructions.md with latest repo changes (Group 2 focus)."
argument-hint: "Optional: What changed since the last sync?"
agent: "agent"
---

Synchronize the two instruction files in this repository:
- `CLAUDE.md`
- `.github/copilot-instructions.md`

Mandatory workflow (strict order):
1. Read both files first.
2. Scan the repository for current structure and recent changes.
3. Keep focus on Group 2 (`groups/group2-triple-stores/`) and top-level repo files.
4. Treat other groups as out of scope unless explicitly requested.
5. Update both files so they are aligned, current, and at the same detail level.

Hard requirements:
- Use actual repository state as source of truth.
- Fix stale paths and renamed/moved files.
- Keep demo guidance consistent with current files and runnable artifacts.
- Keep scope/rules consistent across both files.
- Do not add slide-content automation rules here (for example no automatic maintenance requirement for `slides/data-structure-quellen.md` in this prompt).

Quality checks before finishing:
- No contradictions between `CLAUDE.md` and `.github/copilot-instructions.md`.
- Referenced paths exist.
- Group-2 constraints are intact.
- Changes are minimal but sufficient.

Output format:
1. Summary of what changed in each file.
2. List of resolved inconsistencies.
3. Open risks or follow-up checks (if any).
