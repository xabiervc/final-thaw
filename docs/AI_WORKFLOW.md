# AI-Assisted Development Workflow

## Roles

- **Copilot in VS Code**: small scoped implementation, navigation, refactoring, and test edits.
- **Claude Code**: repository planning, architecture review, coordinated changes, and audit.
- **GPT**: design critique, alternative approaches, debugging hypotheses, and review.
- **Godot**: scene loading, runtime execution, visual inspection, playtesting, and performance observation.
- **GitHub**: branches, commits, pull requests, review, issue tracking, and durable history.

No model is the source of truth for runtime behavior. Godot execution and recorded evidence are.

## Standard task loop

1. Create or select one issue or task with a narrow outcome.
2. Read `AGENTS.md`, `CLAUDE.md`, `README.md`, `PROJECT_STATUS.md`, `docs/DESIGN_AUTHORITY.md`, and relevant technical/design documents.
3. Ask one tool to produce a plan without editing.
4. Review scope, risks, expected files, and acceptance criteria.
5. Use one implementation tool for the smallest change.
6. Run tests and a focused playtest.
7. Use a second model for review, not for unbounded parallel edits.
8. Update documentation and status with actual evidence.
9. Commit to a task branch and open a pull request.

## Prompt templates

### Planning

```text
Read the project contract and relevant design authority. Do not edit files. Produce a narrow plan, expected files, risks, acceptance criteria, and verification commands for: [TASK]
```

### Implementation

```text
Read the project contract first. Implement only: [TASK]. Before editing, list files. Preserve resource paths and existing design constraints. Add behavior tests. After editing, report exact changes and verification still required.
```

### Review

```text
Review the proposed diff against the design authority, technical design, project contract, and quality gates. Do not edit files. Identify regressions, broken references, scope expansion, missing tests, documentation drift, and unsupported claims.
```

### Evidence report

```text
Report only what was actually verified. Include command, engine version, commit, exit code, test summary, warnings, playtest result, and remaining risks.
```

## Boundaries

Do not ask multiple agents to edit the same files concurrently. Do not merge or publish automatically. Do not install a discovered plugin, MCP server, skill, hook, or subagent without explicit review and approval.
