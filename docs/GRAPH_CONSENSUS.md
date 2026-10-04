# Graph Consensus Protocol

## Common workspace

VS Code is the common interface, while `.agent/runs/<run-id>/` is the shared state. The graph is not tied to one model provider.

```text
VS Code task
  ↓
task.yaml + shared-context.md
  ├── Claude in VS Code or Claude Code terminal
  ├── GPT in VS Code or GPT Go externally
  └── Copilot in VS Code
        ↓
  consensus.py
        ↓
  Copilot or Claude Code
        ↓
  Godot
        ↓
  evidence.json
```

## Provider setup

Make Claude, GPT, and Copilot available through the VS Code model picker, approved provider integrations, or BYOK where supported by the installed VS Code version and account plans. Provider availability, quotas, and features can change. Do not put keys or tokens in the repository.

If a provider is unavailable in VS Code, use its native application or CLI and write the structured result to the same run artifact path. This preserves the graph contract without forcing all providers into one UI.

## Start from one point

```text
VS Code → Terminal → Run Task → Graph: Start run
```

Answer the questions once. The task creates:

```text
.agent/runs/<run-id>/
├── task.yaml
├── shared-context.md
├── RUN.md
├── prompts/
├── proposals/
└── reviews/
```

## Select the implementer

Use the consensus result to choose the implementer:

- localized task, few files, no architectural or persistence change: Copilot Agent;
- complex multi-file, architectural, debugging, or migration task: Claude Code after consensus;
- no approval: neither implementation agent edits.

The handoff prompt must include the exact run paths and the approved `consensus.json`. The implementer may not expand the scope.

## Minimal run

```text
1. Start one run in VS Code.
2. Produce Claude and GPT proposals from the same task artifact.
3. Produce cross-reviews.
4. Run deterministic consensus.
5. Implement with Copilot or Claude Code according to the approved result.
6. Run Godot.
7. Validate evidence.
8. Commit and create a PR.
```

## Provider failure

A missing provider is not a new task. Keep the run and substitute the provider while preserving the same schema and artifact path. A provider failure must be recorded in the run; do not silently convert missing output into approval.
