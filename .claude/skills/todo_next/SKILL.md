---
name: todo_next
description: Read-only. Return the first open item in TODO.md plus the minimal context needed to start it. Use when the user or an agent asks "what's next", "what should I work on", or wants the next actionable task without listing everything. Must not modify any files.
---

# todo_next

Return the next actionable task from `TODO.md`. **Read-only** — never modify project state.

## Steps

1. Read `TODO.md` at the repository root.
2. Identify the first unchecked item (`- [ ]`). By the project rules, `TODO.md` is ordered so the highest-priority / next-actionable item is first.
3. Report that item verbatim, plus any inline context lines attached to it (file paths, PR numbers, env var names, commands, blockers).
4. If helpful, point to the relevant project-memory files to read before starting: `docs/CURRENT_STATE.md`, `docs/ARCHITECTURE.md`, `docs/DECISIONS.md`.

## Rules

- Do not edit `TODO.md` or any other file.
- If there are no open items, say so plainly.
- Do not invent tasks that are not written in `TODO.md`.
