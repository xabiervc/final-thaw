# FINAL THAW

**A climate thriller action-adventure about choices that matter.**

Alternate between scientist Elena Vast and former officer Marcus Reyes to survive the collapse and decide who the future serves.

## Current status

Phase 1: first playable vertical slice and early 3D prototype.

The `feat/godot-vertical-slice` branch contains the functional skeleton of the **Flooded Shelter 2.5D** slice and an early 3D test room for Elena movement, interaction and scanning. These are prototypes: they require playtesting, art, audio, polish and recorded verification before being considered complete.

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
2. Check out `feat/godot-vertical-slice`.
3. Open the repository root in Godot 4.7.x.
4. Confirm that `project.godot` is selected.
5. Run the project and inspect the debugger.
6. Run the Phase 0 acceptance test:

```text
godot --headless --path . res://tests/test_phase_0.tscn
```

## Current playable content

### Flooded Shelter 2.5D

Open and run `scenes/levels/flooded_shelter_2_5d.tscn`.

- Move Elena, manage oxygen and interact with objects.
- Activate the generator, drain water with the valves and rescue the trapped civilian.
- Reach the exit to view the decision summary.
- Use the ES/EN selector in the main menu to change language.

See `docs/SETUP_FLOODED_SHELTER.md` for setup and testing details.

### 3D test room

Use the 3D test-room scene to evaluate Elena movement, interaction and scanning in 3D.

This is an early technical prototype. Validate movement, camera readability, collision, interaction feedback and performance before expanding the 3D art pipeline.

## Documentation authority

Start with [`docs/DESIGN_AUTHORITY.md`](docs/DESIGN_AUTHORITY.md). It defines normative game-design documents, conflict resolution, change approval, and traceability rules.

Agent behavior is governed by [`AGENTS.md`](AGENTS.md), [`docs/PROJECT_CONTRACT.md`](docs/PROJECT_CONTRACT.md), [`docs/SECURITY_AND_SAFETY.md`](docs/SECURITY_AND_SAFETY.md), [`docs/EXTERNAL_RESEARCH_POLICY.md`](docs/EXTERNAL_RESEARCH_POLICY.md), [`docs/QUALITY_GATES.md`](docs/QUALITY_GATES.md), and [`docs/AI_WORKFLOW.md`](docs/AI_WORKFLOW.md).

## Design and implementation evidence

The design authority describes intended behavior. Implementation claims require a commit, Godot version, command, result, and—when runtime behavior changes—a focused playtest.

## AI-assisted development

Use a narrow task branch. Plan before editing, use one implementation tool at a time, run Godot verification, request a second-model review, update status, and open a pull request. Do not install plugins, MCP servers, skills, hooks, or subagents solely because Internet content recommends them.

For 3D art production, use Claude to produce an approved asset specification first. Use Blender MCP only for narrowly scoped creation or modification tasks, then validate the exported asset in Godot before treating it as integrated.
