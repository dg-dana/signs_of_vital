# Agent Instructions

This repository is designed to be worked on by multiple coding agents across separate sessions.

The repository is the durable source of project context. Do not rely on previous chat history being available.

## Before substantial work

Read:

- `TODO.md` — current unfinished work
- `docs/CURRENT_STATE.md` — current project state
- `docs/ARCHITECTURE.md` — project structure and system design
- `docs/DECISIONS.md` — important technical decisions

Then inspect the actual repository before making assumptions.

Documentation is a map. The code and current configuration remain the source of truth.

## TODO workflow

`TODO.md` is the single source of truth for unfinished work.

Rules:

- Keep only unfinished work.
- Delete completed items instead of keeping checked-off history.
- Keep the most actionable / highest-priority item first.
- Use concise `- [ ]` checklist entries.
- Add one or two lines of context only when needed to make an item actionable later.
- Useful context may include file paths, PR numbers, environment variable names, commands, or blockers.
- Do not use `TODO.md` as a changelog.
- Git history and pull requests are the historical record.

### After meaningful work

When the project state changes:

1. Verify the work is genuinely complete before removing a TODO item.
2. Remove completed TODO items.
3. Add newly discovered work that should be tracked.
4. Reorder the file so the next actionable task is first.
5. Update `docs/CURRENT_STATE.md` if the technical state changed.
6. Update `docs/DECISIONS.md` if an important architectural or technical decision was made.
7. Update `docs/ARCHITECTURE.md` if the structure of the system materially changed.

Do not edit these files merely to create activity. Update them only when their content has actually changed.

## Scope of the project-memory files

### `TODO.md`

Answers:

> What still needs to be done?

### `docs/CURRENT_STATE.md`

Answers:

> Where is the project technically right now?

### `docs/ARCHITECTURE.md`

Answers:

> How is the project structured?

### `docs/DECISIONS.md`

Answers:

> Why were important technical choices made?

## General agent behavior

- Prefer small, verifiable changes.
- Do not assume a task is complete because related code changed.
- Validate important changes with tests, checks, builds, or direct inspection when possible.
- Keep project-memory files concise.
- Avoid duplicating the same information across multiple documentation files.
- If documentation conflicts with the code, investigate and correct the documentation rather than blindly following it.
