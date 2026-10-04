# Technical Design

## Engine

- Engine: Godot
- Exact version: Record before the first verified run.
- Renderer: Record the selected renderer.
- Project file: `project.godot`

## Runtime structure

- `scenes/`: scenes and scene composition.
- `scripts/`: game logic and systems.
- `assets/`: runtime and source assets.
- `config/`: configuration and tooling.
- `data/`: content and data files.

## Conventions

- Preserve existing resource paths unless a task explicitly changes them.
- Do not edit `.godot/` generated data.
- Keep scripts focused and document public signals and dependencies.
- Check scene and resource references before moving files.

## Main systems

Record each system with its entry point, dependencies, inputs, outputs, and verification method.

| System | Location | Dependencies | Verification |
|---|---|---|---|
| Main scene | To be defined | To be defined | Run project |
| Player | To be defined | To be defined | Manual playtest |
| Core interaction | To be defined | To be defined | Acceptance test |

## Save data

Record whether the game has save data, its location, schema, compatibility rules, and migration strategy.

## Build and run

Record the exact steps for a clean checkout to run the project. Include engine version and target platform.

## Known technical risks

- Missing or inconsistent engine version.
- Broken resource paths after file moves.
- Generated files accidentally committed.
- Features implemented without runtime verification.
