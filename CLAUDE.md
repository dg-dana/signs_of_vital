# Claude Code Instructions

Read `AGENTS.md` before doing substantial work.

`AGENTS.md` contains the shared rules for all coding agents working in this repository.

Claude-specific workflows may live under:

```text
.claude/skills/
```

This template ships three TODO skills under `.claude/skills/`. Use them as the interface to `TODO.md`:

- `todo_next` — read-only; return the first open item and essential context.
- `todo_list` — read-only; return all open items as a compact list.
- `todo_update` — write; update `TODO.md` after meaningful state changes.

Read skills must not mutate project state.

`todo_update` should be the single Claude-specific write path for the TODO system and should trigger after real project changes such as:

- a bug being fixed;
- a feature being completed;
- a PR being merged;
- QA being completed;
- setup or configuration being finished;
- new actionable work being discovered.

The underlying file format and project-state rules are defined in `AGENTS.md`.
