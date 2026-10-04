# FINAL THAW

**A climate thriller action-adventure about choices that matter.**

Alternate between scientist Elena Vast and former officer Marcus Reyes to survive the collapse and decide who the future serves.

## Current status

Phase 0: technical foundation. The game design documentation is extensive, but implementation and runtime verification are still in progress. Do not treat pre-production completion as proof that the game is playable or shippable.

## Engine and targets

- Engine: Godot 4.7.x
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
5. Run the Phase 0 acceptance test described in `docs/TECHNICAL_DESIGN.md`.

## Documentation authority

Start with [`docs/DESIGN_AUTHORITY.md`](docs/DESIGN_AUTHORITY.md). It defines normative documents, conflict resolution, change approval, and traceability rules.

- [Project identity](docs/PROJECT_IDENTITY.md)
- [Game vision](docs/VISION.md)
- [Core loop](docs/CORE_LOOP.md)
- [Systems specification](docs/SYSTEMS_SPEC.md)
- [Accessibility specification](docs/ACCESSIBILITY_SPEC.md)
- [Vertical slice plan](docs/VERTICAL_SLICE_PLAN.md)
- [Technical design](docs/TECHNICAL_DESIGN.md)
- [Project status](PROJECT_STATUS.md)
- [Development log](docs/DEVELOPMENT_LOG.md)
- [Quality gates](docs/QUALITY_GATES.md)

## Source of truth rule

The design authority is normative, but implementation evidence wins when reporting what currently works. A document saying that a feature is complete is not evidence that the feature runs. Runtime claims require a commit, engine version, command, and result.

## AI-assisted development

Read `AGENTS.md` and `CLAUDE.md` before editing. Use the smallest focused change, preserve existing Godot paths, update canonical documentation, add tests for behavior, and never claim verification without running it.
