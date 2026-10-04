# Graph Consensus Protocol

## Single entry point

The graph is started from VS Code. You do not manually reconstruct the task context for every agent.

1. Open the repository root in VS Code.
2. Run `Terminal` → `Run Task` → `Graph: Start run`.
3. Answer the task questions once.
4. Open the generated `.agent/runs/<run-id>/RUN.md`.
5. Use the generated Claude and GPT prompts from that run.
6. Save their structured JSON responses in the generated proposal paths.
7. Use the generated reviewer prompts.
8. Run `Graph: Calculate consensus`.
9. Use the generated Copilot prompt for normal implementation, or the generated Claude Code prompt for complex approved implementation.
10. Run Godot and validate evidence.

All agents receive the same `task.yaml` and shared context. Only their roles and output schemas differ.

## Start a run

```text
VS Code → Terminal → Run Task → Graph: Start run
```

The task creates a run such as:

```text
.agent/runs/20261005T000000Z-first-level-abc123/
├── task.yaml
├── shared-context.md
├── RUN.md
├── prompts/
├── proposals/
└── reviews/
```

## Consensus path

```text
one task entry
  ↓
shared task artifact
  ├── Claude planner
  └── GPT planner
        ↓
  cross-review
        ↓
  deterministic consensus
        ├── approve → Copilot or Claude Code
        ├── revise → new round
        ├── reject → stop
        └── escalate → exception path
```

The shared artifact is the common point. Claude and GPT do not invent separate tasks, and the implementation agent consumes the approved consensus rather than an unrelated chat.

## Choosing the implementer

Use Copilot in VS Code when the approved task is:

- localized;
- limited to a few files;
- consistent with existing architecture;
- not a save-format, project-configuration, or architectural change.

Use Claude Code after consensus when the approved task is:

- multi-file and tightly coupled;
- architectural;
- difficult to implement safely with local edits;
- dependent on repository-wide reasoning;
- a complex debugging or migration task.

The implementation agent never changes the task scope. The consensus artifact is the handoff contract.

## Why this is not fully automatic yet

This v0 deliberately does not call model APIs. It makes the common task, prompts, artifact paths, and transitions automatic while keeping model credentials and provider integrations outside the repository. Later adapters can replace manual copy/paste without changing the graph state or schemas.
