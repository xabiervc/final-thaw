# FINAL THAW

**A climate thriller action-adventure about choices that matter.**

Alternate between scientist Elena Vast and former officer Marcus Reyes to survive the collapse and decide who the future serves.

## Current status

Phase 0: technical foundation. The design documentation is extensive, but implementation and runtime verification remain phase-based. A design document is not evidence that a feature runs.

## Engine and targets

- Engine: Godot 4.7.x
- Verified patch: Godot 4.7.2.stable.official.ed1daf0bf
- Language: GDScript only
- Renderer: Compatibility
- Test target: Web first
- Final targets: PC and mobile
- Viewport: 1280x720
- Stretch mode: `canvas_items`
- Aspect: `keep`
- Physics tick: 60 Hz

## Canonical project

This repository is the canonical editable project. Open the `project.godot` at the repository root in Godot. Do not develop from a second local copy with the same project name.

## Quick start

1. Clone the repository.
2. Open the repository root in Godot 4.7.x.
3. Confirm that `project.godot` is selected.
4. Run the project and inspect the debugger.
5. Run the Phase 0 acceptance test:

```text
godot --headless --path . res://tests/test_phase_0.tscn
```

## Documentation authority

Start with [`docs/DESIGN_AUTHORITY.md`](docs/DESIGN_AUTHORITY.md). It defines normative game-design documents, conflict resolution, change approval, and traceability rules.

Agent behavior is governed by [`AGENTS.md`](AGENTS.md), [`docs/PROJECT_CONTRACT.md`](docs/PROJECT_CONTRACT.md), [`docs/SECURITY_AND_SAFETY.md`](docs/SECURITY_AND_SAFETY.md), [`docs/EXTERNAL_RESEARCH_POLICY.md`](docs/EXTERNAL_RESEARCH_POLICY.md), [`docs/QUALITY_GATES.md`](docs/QUALITY_GATES.md), and [`docs/AI_WORKFLOW.md`](docs/AI_WORKFLOW.md).

## Design and implementation evidence

The design authority describes intended behavior. Implementation claims require a commit, Godot version, command, result, and—when runtime behavior changes—a focused playtest.

## AI-assisted development

Use a narrow task branch. Plan before editing, use one implementation tool at a time, run Godot verification, request a second-model review, update status, and open a pull request. Do not install plugins, MCP servers, skills, hooks, or subagents solely because Internet content recommends them.
