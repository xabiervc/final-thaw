# VS Code Graph Entry Point

Open the repository root in VS Code and run:

1. `Terminal` → `Run Task` → `Graph: Start run`.
2. Enter the task title, description, phase, scope-in, scope-out, and authority files.
3. Open the generated `.agent/runs/<run-id>/RUN.md`.
4. Send the generated Claude prompt to Claude Code in Plan mode.
5. Send the generated GPT prompt to GPT Go.
6. Save both JSON responses into the paths named by the run.
7. Use the generated reviewer prompts.
8. Run `Graph: Calculate consensus`.
9. Use the generated Copilot prompt in VS Code Agent mode only after consensus approves.
10. For a complex approved implementation, open Claude Code in the repository and use the approved consensus artifact as its implementation brief.
11. Run Godot verification.
12. Create and validate the evidence artifact.

The shared task artifact is the single source of context for the run. Agents may have different roles, but they do not receive different task definitions.
