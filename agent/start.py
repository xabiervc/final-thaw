from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path
import re
import textwrap
import uuid

ROOT = Path(__file__).parents[1]
RUNS = ROOT / ".agent" / "runs"


def slug(value: str) -> str:
    value = re.sub(r"[^a-zA-Z0-9]+", "-", value.strip().lower()).strip("-")
    return value or "task"


def ask(label: str) -> str:
    return input(f"{label}: ").strip()


def yaml_list(values: str) -> str:
    items = [item.strip() for item in values.split(",") if item.strip()]
    return "\n".join(f"    - {item}" for item in items) or "    - to be defined"


def write_prompt(path: Path, content: str) -> None:
    path.write_text(textwrap.dedent(content).strip() + "\n", encoding="utf-8")


def main() -> None:
    title = ask("Task title")
    description = ask("Task description")
    phase = ask("Phase (for example phase_0 or phase_1)")
    scope_in = ask("Scope in (comma-separated)")
    scope_out = ask("Scope out (comma-separated)")
    authority = ask("Authority files (comma-separated)")

    run_id = f"{datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')}-{slug(title)}-{uuid.uuid4().hex[:6]}"
    run = RUNS / run_id
    (run / "proposals").mkdir(parents=True, exist_ok=False)
    (run / "reviews").mkdir(parents=True, exist_ok=False)

    task = f"""id: {slug(title)}
title: {title}
description: {description}
phase: {phase}
scope:
  in:
{yaml_list(scope_in)}
  out:
{yaml_list(scope_out)}
authority:
{yaml_list(authority)}
verification:
  automated:
    - to be defined
  manual:
    - to be defined
"""
    (run / "task.yaml").write_text(task, encoding="utf-8")

    shared = f"""# Shared Context\n\nRun: {run_id}\nTask: {title}\n\nRead these repository files before acting:\n- AGENTS.md\n- CLAUDE.md\n- README.md\n- PROJECT_STATUS.md\n- docs/DESIGN_AUTHORITY.md\n- docs/PROJECT_CONTRACT.md\n- docs/QUALITY_GATES.md\n\nThe task artifact is authoritative for this run:\n- {run / 'task.yaml'}\n\nDo not invent repository state. Do not edit files unless the prompt explicitly allows it.\n"""
    (run / "shared-context.md").write_text(shared, encoding="utf-8")

    prompts = run / "prompts"
    prompts.mkdir()
    write_prompt(prompts / "claude-planner.md", f"""Read {run / 'shared-context.md'} and {run / 'task.yaml'}.\nDo not edit files.\nReturn only JSON matching agent/schemas/proposal.schema.json.\nUse agent_id=claude-planner and role=planner.\nSave the response as {run / 'proposals/claude.json'}.""")
    write_prompt(prompts / "gpt-planner.md", f"""You are the independent planning node for run {run_id}.\nRead {run / 'shared-context.md'} and {run / 'task.yaml'}.\nDo not write code.\nReturn only JSON matching agent/schemas/proposal.schema.json.\nUse agent_id=gpt-planner and role=planner.\nSave the response as {run / 'proposals/gpt.json'}.""")
    write_prompt(prompts / "claude-reviewer.md", f"""Read {run / 'task.yaml'}, both proposal files, and agent/schemas/review.schema.json.\nReview scope, authority, risks, tests, and missing evidence.\nDo not edit files.\nReturn only valid JSON with agent_id=claude-reviewer.\nSave as {run / 'reviews/claude.json'}.""")
    write_prompt(prompts / "gpt-reviewer.md", f"""Read {run / 'task.yaml'}, both proposal files, and agent/schemas/review.schema.json.\nReview independently. Do not edit files.\nReturn only valid JSON with agent_id=gpt-reviewer.\nSave as {run / 'reviews/gpt.json'}.""")
    write_prompt(prompts / "implementer-copilot.md", f"""Read {run / 'task.yaml'}, {run / 'consensus.json'}, AGENTS.md, and .github/copilot-instructions.md.\nImplement only if consensus.json decision is approve.\nBefore editing, list exact files.\nAfter editing, report files, tests, commands, exit codes, and unverified behavior.""")
    write_prompt(prompts / "implementer-claude.md", f"""Read {run / 'task.yaml'}, {run / 'consensus.json'}, AGENTS.md, CLAUDE.md, and the relevant design and technical documents.\nImplement only if consensus.json decision is approve.\nUse Claude Code for complex multi-file or architectural work.\nBefore editing, list exact files and risks.\nAfter editing, report files, tests, commands, exit codes, and unverified behavior.""")

    run_md = f"""# Run {run_id}\n\n## Task\n\n{title}\n\n## Next steps\n\n1. Run the Claude planner prompt: `{run / 'prompts/claude-planner.md'}`.\n2. Run the GPT Go planner prompt: `{run / 'prompts/gpt-planner.md'}`.\n3. Save JSON responses in `proposals/`.\n4. Run both reviewer prompts.\n5. Run `Graph: Calculate consensus`.\n6. Implement with Copilot for normal changes, or Claude Code for complex approved changes.\n7. Run Godot verification.\n8. Create and validate evidence.\n\n## Artifacts\n\n- Task: `{run / 'task.yaml'}`\n- Shared context: `{run / 'shared-context.md'}`\n- Prompts: `{prompts}`\n- Consensus: `{run / 'consensus.json'}`\n"""
    (run / "RUN.md").write_text(run_md, encoding="utf-8")
    print(run)


if __name__ == "__main__":
    main()
