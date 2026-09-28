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

## Session handoff protocol

The repository must be sufficient for a completely new session — a new Claude
Code session, a new ChatGPT session, or a different agent entirely — to
reconstruct where the project stopped by reading GitHub. Dana should not need
to paste previous conversations, resend screenshots or measurements whose
findings are already documented, re-explain past architectural decisions, or
remind an agent which milestone the project has reached.

### At the start of a new session

Before asking Dana for project context or proposing work:

1. Read:
   - `docs/CURRENT_STATE.md`
   - `docs/DECISIONS.md`
   - `TODO.md`
   - `docs/ARCHITECTURE.md` when present/relevant
2. Inspect the repository itself.
3. When GitHub information is available, inspect relevant:
   - active branch
   - recent commits
   - open PRs
   - current implementation state
4. Reconstruct:
   - what is confirmed
   - what is still assumed/unverified
   - current milestone
   - current blocker
   - last completed work
   - exact next action/decision
5. Do not ask Dana to repeat information already documented in the repository.
6. Do not ask Dana to resend screenshots or measurements when their relevant
   findings have already been recorded as confirmed project evidence.
7. Ask Dana for old information only when:
   - the repository explicitly says it is missing/unverified, or
   - the original artifact is genuinely required for a new verification.

### At the end of meaningful work

Update project memory before considering the work cycle complete.

`docs/CURRENT_STATE.md` must leave enough information for a completely new
session to continue. It should identify, when applicable:

- last completed work
- current milestone
- current branch / PR
- blocker
- next architect decision or next implementation action
- important prohibitions / things not yet authorized

Keep `CURRENT_STATE.md` concise. It is a checkpoint, not a changelog. Git
history and pull requests remain the historical record.

## General agent behavior

- Prefer small, verifiable changes.
- Do not assume a task is complete because related code changed.
- Validate important changes with tests, checks, builds, or direct inspection when possible.
- Keep project-memory files concise.
- Avoid duplicating the same information across multiple documentation files.
- If documentation conflicts with the code, investigate and correct the documentation rather than blindly following it.
