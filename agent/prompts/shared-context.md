# Shared Context Template

All agents in a run must receive the same task artifact and repository authority references. Role-specific prompts may change the requested output, but not the task definition.

## Required context

- task.yaml
- AGENTS.md
- CLAUDE.md
- README.md
- PROJECT_STATUS.md
- docs/DESIGN_AUTHORITY.md
- docs/PROJECT_CONTRACT.md
- docs/QUALITY_GATES.md

## Rule

The graph state and artifacts are the source of truth for the run. Chat history is not.
