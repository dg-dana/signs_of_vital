---
name: todo_list
description: Read-only. Return all open items from TODO.md as a compact ordered checklist. Use when the user or an agent wants to see everything still unfinished, review the backlog, or get an overview of remaining work. Must not modify any files.
---

# todo_list

Return every open task from `TODO.md`. **Read-only** — never modify project state.

## Steps

1. Read `TODO.md` at the repository root.
2. Collect all unchecked items (`- [ ]`), preserving their order (the file is kept sorted with the next actionable item first).
3. Present them as a compact checklist, keeping any inline context lines that belong to each item.

## Rules

- Do not edit `TODO.md` or any other file.
- Preserve the existing order — do not re-rank.
- If there are no open items, say the list is empty.
