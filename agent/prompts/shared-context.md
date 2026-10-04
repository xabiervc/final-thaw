# Shared Context Template

All providers in a run must receive the same task artifact and repository authority references.

Required shared inputs:

- `.agent/runs/<run-id>/task.yaml`
- `.agent/runs/<run-id>/shared-context.md`
- `AGENTS.md`
- `CLAUDE.md`
- `README.md`
- `PROJECT_STATUS.md`
- `docs/DESIGN_AUTHORITY.md`
- `docs/PROJECT_CONTRACT.md`
- `docs/QUALITY_GATES.md`

Provider-specific prompts may change the role and output, but never the task definition or scope.

If a provider is unavailable, use another approved interface and save the same structured artifact. Never fabricate a missing provider response.
