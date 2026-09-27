# Decisions

This file records important technical and architectural decisions that future agents may otherwise reconsider without knowing the original reasoning.

Keep entries concise.

Do not record routine implementation details.

## Entry format

Use this structure:

```md
## YYYY-MM-DD — Short decision title

**Decision:** What was chosen.

**Reason:** Why it was chosen.

**Alternatives considered:** Optional. Mention meaningful alternatives only.

**Consequences:** Important trade-offs or constraints created by the decision.
```

## Initial decision — Repository-managed agent memory

**Decision:** Project state is stored in repository Markdown files rather than depending on agent conversation history.

**Reason:** Coding agents may work in separate sessions, tools, or context windows. Repository files survive context resets and can be shared by Claude Code, Codex, ChatGPT, and other agents.

**Consequences:** Agents must keep `TODO.md` and the relevant project-state documentation current after meaningful changes.
