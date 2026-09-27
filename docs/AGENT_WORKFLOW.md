# Agent Workflow

This document explains how to use the repository with Claude Code, Codex, or another coding agent.

## Core principle

The repository owns the memory.

Do not design the workflow around one continuous AI conversation.

A fresh agent should be able to enter the repository, read the project-memory files, inspect the code, and continue.

## Starting a fresh session

A generic prompt is:

```text
Read AGENTS.md and the project files it references.

Inspect the repository to verify the current state.

Then show me the next actionable item in TODO.md.
Do not make changes yet.
```

To immediately begin work:

```text
Read AGENTS.md and the project files it references.

Inspect the repository and work on the first actionable item in TODO.md.

Verify the result before considering it complete.

After meaningful state changes, update TODO.md and any relevant project-state documentation.
```

## Claude Code

Claude should begin with `CLAUDE.md`.

`CLAUDE.md` points Claude to the shared instructions in `AGENTS.md`.

Claude-specific skills may provide convenient commands around the shared repository state.

Recommended TODO skills:

```text
todo_next
todo_list
todo_update
```

The skills are an interface. `TODO.md` remains the durable source of truth.

## Codex

Codex should use `AGENTS.md` as the project instruction entry point.

Typical prompt:

```text
Read AGENTS.md.

Work on the first actionable item in TODO.md.
Inspect the repository before making assumptions.
Verify the implementation.
Update the project-memory files when the state genuinely changes.
```

Codex does not need a separate TODO database or a copy of Claude's TODO state.

Both agents operate on the same repository files.

## Other coding agents

If an agent does not automatically detect `AGENTS.md`, bootstrap it with:

```text
Before working on this repository, read AGENTS.md and follow it as the repository's development instructions.
```

After that, the same project-memory system can be used.

## Switching agents

Example:

1. Claude implements a feature.
2. Claude updates `TODO.md` and `CURRENT_STATE.md`.
3. Changes are committed.
4. Later, Codex opens the repository.
5. Codex reads `AGENTS.md`.
6. Codex reads the updated project state.
7. Codex continues with the next open task.

No conversation handoff is required.

## What belongs where

```text
AGENTS.md
→ How any coding agent should work in the repository.

CLAUDE.md
→ Claude-specific instructions and skills.

TODO.md
→ What remains unfinished.

CURRENT_STATE.md
→ What exists and works right now.

ARCHITECTURE.md
→ How the system is structured.

DECISIONS.md
→ Why important choices were made.

Git history / pull requests
→ What actually changed over time.
```

## Important rule

Do not let these files become huge.

Their value comes from allowing an agent to load a small amount of high-value context quickly.

If detailed documentation is needed, create dedicated documents and link to them from the appropriate project-memory file.
