# start_project

A reusable starter repository for projects that may be worked on by Claude Code, Codex, ChatGPT, or other coding agents.

The core idea is simple: **the repository keeps the project memory, not the chat session**.

Agents may change, conversations may be reset, and context windows may be lost. The important project state remains in a small set of Markdown files committed to Git.

## Using this repository

This repository is a **GitHub Template repository**. To start a new project, use the green **"Use this template"** button on GitHub (or *Repository contents → Use this template*) rather than cloning or forking. That creates a fresh repository seeded with this structure and no shared history.

After creating your project from the template, follow [Starting a new project](#starting-a-new-project) below.

## Repository structure

```text
start_project/
├── README.md
├── AGENTS.md
├── CLAUDE.md
├── TODO.md
├── docs/
│   ├── CURRENT_STATE.md
│   ├── ARCHITECTURE.md
│   ├── DECISIONS.md
│   └── AGENT_WORKFLOW.md
└── .claude/
    └── skills/
        ├── todo_next/
        ├── todo_list/
        └── todo_update/
```

## What each file is for

### `AGENTS.md`

The shared instruction file for coding agents.

It tells any agent:

- which project files to read before working;
- how the TODO system works;
- when to update project state;
- which files are authoritative;
- how to behave after completing meaningful work.

This should be the main cross-agent instruction file.

### `CLAUDE.md`

Claude Code-specific entry point.

It tells Claude to read `AGENTS.md` and can contain Claude-specific information such as available skills.

Do not duplicate all project rules here. Shared rules belong in `AGENTS.md`.

### `TODO.md`

The live list of unfinished work.

It answers:

> What still needs to be done?

Rules:

- only unfinished work;
- highest-priority / next-actionable item first;
- short Markdown checklist items;
- completed items are deleted;
- no changelog;
- no archive of completed tasks;
- Git history and pull requests are the historical record.

### `docs/CURRENT_STATE.md`

A concise technical checkpoint.

It answers:

> Where is the project right now?

Use it for things such as:

- what already exists;
- what currently works;
- important files or components;
- current limitations;
- known problems;
- deployment or environment state.

Do not turn it into a detailed development diary.

### `docs/ARCHITECTURE.md`

The structural overview of the project.

It answers:

> How does this project work?

Typical contents:

- main components;
- directories;
- data flow;
- external services;
- important dependencies;
- high-level relationships between parts of the system.

### `docs/DECISIONS.md`

A lightweight record of important technical decisions.

It answers:

> Why did we choose this approach?

Only record decisions that future agents or developers may otherwise reconsider without context.

Examples:

- why a framework was chosen;
- why one API replaced another;
- why authentication works in a specific way;
- why a particular deployment architecture exists.

### `docs/AGENT_WORKFLOW.md`

A short onboarding guide for using the repository with Claude Code, Codex, or another agent.

It is human-facing background, not part of the files an agent must load before every task.

### `.claude/skills/`

Claude-specific skills that wrap the shared `TODO.md`:

- `todo_next` — read-only; the next actionable item.
- `todo_list` — read-only; the full open list, compressed.
- `todo_update` — the single Claude write path; updates `TODO.md` after real state changes.

`TODO.md` remains the source of truth; the skills are only a convenient interface.

## The operating model

```text
                    Git repository
                         │
              ┌──────────┼──────────┐
              │          │          │
          Claude       Codex     other agent
              │          │          │
              └──────────┼──────────┘
                         │
                    AGENTS.md
                         │
              ┌──────────┼──────────┐
              │          │          │
            TODO     CURRENT     ARCHITECTURE
                       STATE
                         │
                     DECISIONS
                         │
                        Git
```

Agents are temporary. Repository state is durable.

## Recommended workflow

At the beginning of a new agent session:

1. Read `AGENTS.md`.
2. Read the files it references.
3. Inspect the actual repository before making assumptions.
4. Continue from the first actionable item in `TODO.md`.

After meaningful work:

1. verify the work is actually complete;
2. update the code;
3. test or otherwise validate the result;
4. remove completed TODO items;
5. add newly discovered work;
6. reorder `TODO.md`;
7. update `CURRENT_STATE.md` when the technical state changed;
8. update `DECISIONS.md` when an important decision was made;
9. commit the project-state updates together with the relevant work when appropriate.

## Starting a new project

Copy this repository or use it as a Git template.

Then:

1. replace this README's generic project description;
2. fill in `docs/ARCHITECTURE.md`;
3. fill in `docs/CURRENT_STATE.md`;
4. seed `TODO.md` with the first real tasks;
5. add project-specific rules to `AGENTS.md`;
6. add agent-specific instructions only where needed.

The goal is that a completely fresh agent session can enter the repository, read a few small files, inspect the code, and continue productively without needing the previous conversation.
