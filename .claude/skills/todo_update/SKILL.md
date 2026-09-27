---
name: todo_update
description: Write path for the TODO system. Update TODO.md after real project changes — a bug fixed, a feature completed, a PR merged, QA finished, setup/config done, or new actionable work discovered. Removes completed items, adds newly found work, and reorders so the next actionable task is first. Also prompts updating docs/CURRENT_STATE.md, docs/DECISIONS.md, and docs/ARCHITECTURE.md when those genuinely changed.
---

# todo_update

The single Claude-specific **write** path for the TODO system. Use it only after meaningful work, such as:

- a bug being fixed;
- a feature being completed;
- a PR being merged;
- QA being completed;
- setup or configuration being finished;
- new actionable work being discovered.

## Steps

1. Read `TODO.md` at the repository root.
2. Verify each finished item is genuinely complete before touching it.
3. **Delete** completed items — do not keep checked-off history. Git history and pull requests are the changelog.
4. **Add** newly discovered actionable work as concise `- [ ]` entries. Add one or two context lines only when needed to make an item actionable later (file paths, PR numbers, env var names, commands, blockers).
5. **Reorder** so the highest-priority / next-actionable item is first.
6. Update related project-memory docs *only when their content actually changed*:
   - `docs/CURRENT_STATE.md` — when the technical state changed.
   - `docs/DECISIONS.md` — when an important technical/architectural decision was made.
   - `docs/ARCHITECTURE.md` — when the structure of the system materially changed.

## Rules

- Keep only unfinished work in `TODO.md`; never use it as a changelog.
- Keep entries concise; avoid duplicating information across the docs.
- Do not edit files merely to create activity — change them only when content genuinely changed.
- The authoritative format and project-state rules live in `AGENTS.md`.
