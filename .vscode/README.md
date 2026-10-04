# VS Code Graph Entry Point

VS Code is the common workspace for the graph, but the graph state—not a chat window—is the source of truth.

## One-time setup

Open the repository root:

```text
D:\Projects\github\final-thaw
```

Make the required model providers available in VS Code using the model picker, supported provider integrations, or approved BYOK configuration. Availability depends on the installed VS Code version, extensions, account plan, quotas, and provider configuration.

Do not commit API keys, tokens, cookies, provider configuration containing secrets, or private prompts.

## Run the graph

1. Open the repository root in VS Code.
2. Run `Terminal` → `Run Task` → `Graph: Start run`.
3. Enter the task information once.
4. Open the generated `.agent/runs/<run-id>/RUN.md`.
5. Run the generated Claude planner prompt using Claude in VS Code or Claude Code in the integrated terminal.
6. Run the generated GPT planner prompt using GPT in VS Code or GPT Go outside VS Code if that provider is not available in the model picker.
7. Save both structured JSON responses in the paths shown by the run.
8. Run the reviewer prompts.
9. Run `Graph: Calculate consensus`.
10. Use the generated Copilot prompt for normal work, or the generated Claude Code prompt for complex approved work.
11. Run Godot verification and validate the evidence artifact.

All providers receive the same `task.yaml` and `shared-context.md`. The provider is replaceable; the artifact contract is not.

## Provider roles

- Claude: architecture-aware planning, repository-wide reasoning, complex debugging, and complex approved implementation.
- GPT: independent planning, adversarial review, and alternative analysis.
- Copilot: localized implementation and VS Code Agent work.
- Godot: deterministic tests and runtime/playtest evidence.
- Python graph scripts: routing, consensus, validation, and evidence checks.

## Complex Claude Code handoff

For a complex approved task, run Claude Code from the integrated terminal:

```powershell
cd D:\Projects\github\final-thaw
claude --permission-mode plan
```

After confirming the plan and consensus artifact, use the generated `implementer-claude.md` prompt and switch to the appropriate execution permission only when ready to edit.

## Troubleshooting

If a model is not available inside VS Code:

- keep the same run;
- use Claude Code or GPT Go externally;
- save the response in the same artifact path;
- continue with the graph.

The graph does not require every provider to be embedded in the same chat window.
