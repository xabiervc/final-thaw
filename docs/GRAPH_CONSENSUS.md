# Graph Consensus Protocol

## Purpose

This document explains how to use Final Thaw Graph Consensus v0. It coordinates Claude Code, GPT Go, Copilot in VS Code, Godot, and GitHub through explicit artifacts rather than long conversations.

The graph is deliberately dependency-free in v0. It does not call model APIs automatically. You run the LLM steps in the tool best suited to each role, save their structured outputs, and let deterministic consensus and validation scripts decide the next edge.

## Roles

- **Claude Code**: independent planner and architecture reviewer.
- **GPT Go**: independent planner and adversarial reviewer.
- **Copilot in VS Code**: implementation worker.
- **Godot**: deterministic runtime and acceptance-test verifier.
- **Python scripts**: consensus, validation, and evidence checks.
- **GitHub**: branch, commit, PR, and durable history.

## One complete run

### Step 1 — Create a task

```powershell
New-Item -ItemType Directory -Force .agent\runs\demo-first-level | Out-Null
Copy-Item agent\examples\tasks\first-level-foundation.yaml .agent\runs\demo-first-level\task.yaml
New-Item -ItemType Directory -Force .agent\runs\demo-first-level\proposals | Out-Null
New-Item -ItemType Directory -Force .agent\runs\demo-first-level\reviews | Out-Null
```

Edit `task.yaml` so that `scope.in` and `scope.out` match the actual task.

### Step 2 — Ask Claude for an independent proposal

```powershell
cd D:\Projects\github\final-thaw
claude --permission-mode plan
```

Prompt:

```text
Read .agent/runs/demo-first-level/task.yaml, AGENTS.md, CLAUDE.md, docs/DESIGN_AUTHORITY.md, docs/PROJECT_CONTRACT.md, and the relevant technical documents.

Do not edit files.
Return only JSON matching agent/schemas/proposal.schema.json.
Use agent_id="claude-planner" and role="planner".
```

Save the response as `.agent/runs/demo-first-level/proposals/claude.json`.

### Step 3 — Ask GPT Go for an independent proposal

Give GPT Go the task file and only the relevant authority excerpts:

```text
You are an independent planner for the Final Thaw graph.
Return only JSON matching agent/schemas/proposal.schema.json.
Use agent_id="gpt-planner" and role="planner".
Do not write code.

Task:
[PASTE task.yaml]

Relevant authority:
[PASTE relevant excerpts]
```

Save the response as `.agent/runs/demo-first-level/proposals/gpt.json`. Do not show Claude's proposal to GPT before it produces its own proposal.

### Step 4 — Cross-review

Ask Claude to review both proposals and save JSON as `reviews/claude.json`:

```text
Read the task, both proposal JSON files, and agent/schemas/review.schema.json.
Review scope, design authority, technical risks, tests, and missing evidence.
Do not edit files.
Return only valid JSON matching the review schema.
Use agent_id="claude-reviewer".
```

Ask GPT to perform the reciprocal review and save `reviews/gpt.json` with `agent_id="gpt-reviewer"`.

### Step 5 — Calculate consensus

```powershell
python agent\consensus.py `
  --proposals .agent\runs\demo-first-level\proposals\claude.json .agent\runs\demo-first-level\proposals\gpt.json `
  --reviews .agent\runs\demo-first-level\reviews\claude.json .agent\runs\demo-first-level\reviews\gpt.json `
  --output .agent\runs\demo-first-level\consensus.json
Get-Content .agent\runs\demo-first-level\consensus.json
```

Possible result:

```json
{
  "decision": "approve",
  "confidence": 0.84,
  "rationale": "Weighted approval ratio=0.840; weighted rejection ratio=0.000.",
  "blockers": [],
  "minority_report": [],
  "reopen_conditions": [],
  "round": 1
}
```

If the result is `revise`, update the task or proposals and repeat. If `reject`, stop. If `escalate`, the graph detected missing artifacts, blockers, or unresolved disagreement.

### Step 6 — Implement with Copilot

Only after `consensus.json` says `approve`, use Agent mode in VS Code:

```text
Read:
- .agent/runs/demo-first-level/task.yaml
- .agent/runs/demo-first-level/consensus.json
- AGENTS.md
- .github/copilot-instructions.md
- relevant design and technical documents

Implement only the approved scope.
Before editing, list exact files to change.
Do not modify files outside the approved scope.
After editing, report exact files changed, tests added, commands run, exit codes, and unverified behavior.
```

Save a short implementation report as `.agent/runs/demo-first-level/implementation.json`.

### Step 7 — Run Godot verification

```powershell
& "D:\Tools\Godot\Godot_v4.7.2-stable_win64.exe" `
  --headless `
  --path "D:\Projects\github\final-thaw" `
  "res://tests/test_phase_0.tscn"
$LASTEXITCODE
```

Run task-specific tests too. Save actual commands, version, exit codes, results, and warnings in `test-result.json`.

### Step 8 — Produce and validate evidence

Create `.agent/runs/demo-first-level/evidence.json`:

```json
{
  "run_id": "demo-first-level",
  "task_id": "first-level-foundation",
  "status": "complete",
  "artifacts": ["consensus.json", "implementation.json", "test-result.json"],
  "verification": {
    "godot_version": "4.7.2.stable.official.ed1daf0bf",
    "phase_0": {"passed": 11, "failed": 0, "exit_code": 0}
  },
  "limitations": ["Manual playtest must still be recorded."]
}
```

Validate:

```powershell
python agent\validate.py .agent\runs\demo-first-level\evidence.json
```

Expected:

```text
Evidence valid
```

### Step 9 — Commit and PR

Only after tests and evidence:

```powershell
git status
git diff --stat
git add <approved-files>
git commit -m "Implement first playable level slice"
git push -u origin feat/first-level-foundation
```

The graph branch is for improving the protocol. Game tasks use separate task branches.

## Decision rules

- missing proposals or reviews: `escalate`;
- invalid decision values: `escalate`;
- blocking findings: `revise`, then `escalate` after maximum rounds;
- missing required evidence: `revise`, then `escalate`;
- weighted approval >= 0.70 and every review approves: `approve`;
- weighted rejection >= 0.70: `reject`;
- unresolved disagreement before the round limit: `revise`;
- unresolved disagreement after the round limit: `escalate`.

Consensus cannot override a blocker or a failed deterministic test.

## What v0 does not do

- It does not call Claude, GPT, or Copilot APIs.
- It does not edit game files.
- It does not create commits automatically.
- It does not install plugins or MCP servers.
- It does not claim tests passed without recorded results.

These limits keep v0 inspectable and safe. API adapters and automatic routing can be added later.
