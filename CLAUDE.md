# FINAL THAW — Development Guidelines

## Current phase

**Phase 1 — First playable vertical slice and early 3D prototype.**

The `feat/godot-vertical-slice` branch contains the Flooded Shelter 2.5D gameplay skeleton and an early 3D test room for Elena movement, interaction and scanning. Phase 0 acceptance testing remains verified; the current slice and 3D prototype require recorded playtest evidence before being considered complete.

## Project overview

**FINAL THAW** is a single-player isometric action-adventure with dual protagonists: scientist Elena Vast and former officer Marcus Reyes. The game explores climate collapse, moral complexity, redemption, cooperation versus control, and survival under pressure.

The long-term targets remain a 12–15 hour experience, three endings, New Game+, full accessibility and strong performance. Current implementation is intentionally narrower: stabilize and validate one playable slice before expanding scope.

## Quality standards

### Performance

- Target 60 FPS on minimum specification.
- Keep input latency low and scene transitions fast.
- Avoid crashes, softlocks and save corruption.
- Profile before claiming performance targets are met.

### Polish

- Movement should feel responsive and readable.
- UI should have clear states and transitions.
- Audio should vary rather than repeat identically.
- Puzzles and critical gameplay outcomes must remain deterministic.

### Accessibility

- Support remappable controls.
- Keep UI legible and scalable.
- Avoid relying on color alone to convey critical information.
- Provide subtitles, clear feedback and adjustable difficulty or assistance where practical.

Accessibility is part of the design, not a late patch.

### Code quality

- Use GDScript static typing where practical.
- Prefer named constants over magic numbers.
- Externalize user-facing text for localization.
- Use `_physics_process()` or timers for physics-dependent logic where appropriate.
- Keep scripts focused and documented.

## Current implementation

### Flooded Shelter 2.5D slice

The Flooded Shelter slice includes:

- Elena lateral movement, jumping, oxygen depletion and interaction.
- A power room, valve room and rescue room.
- Generator activation, water drainage and civilian rescue.
- An exit and decision-summary end screen.
- `GameStateManager` persistence for decisions and language preference.
- `NarrativeTextManager` with ES/EN localization.
- A main menu with narrative context and language selection.

### Early 3D prototype

A separate 3D test room evaluates Elena movement, interaction and scanning.

Treat this as a technical prototype. Before expanding 3D production, validate movement feel, camera framing, interaction affordances, collision, visual readability and performance in Godot.

## Folder structure

```text
final-thaw/
├── .github/
├── assets/
│   └── concept/
│       └── characters/
│           ├── elena_vast_concept.png
│           └── marcus_reyes_concept.png
├── config/
├── data/
├── docs/
├── prompts/
├── scenes/
│   ├── ui/
│   ├── levels/
│   └── props/
├── schemas/
├── scripts/
├── tests/
├── AGENTS.md
├── CLAUDE.md
├── GDD.md
├── PROJECT_STATUS.md
├── README.md
├── README_VERTICAL_SLICE.md
├── icon.svg
├── project.godot
└── setup_phase0.py
```

Use the repository as the source of truth for the exact current layout. When adding a major new directory or system, update this map and `PROJECT_STATUS.md`.

## Concept art

The approved character concept references are:

- `assets/concept/characters/elena_vast_concept.png`
- `assets/concept/characters/marcus_reyes_concept.png`

Use these images to guide character proportions, silhouette, costume language, palette, materials and visual personality. They are design references, not final in-game assets.

Before producing a 3D character or prop, derive a written specification from the relevant concept art. The specification must define scale, silhouette, materials, palette, level of detail, animation requirements, collision requirements and Godot integration requirements.

## Naming conventions

### Files and folders

- Use `snake_case` for files and folders.
- Use descriptive names: `flooded_shelter_2_5d.tscn`, not `level1.tscn`.
- Keep asset names stable and meaningful.

### GDScript

- Use `snake_case` for variables and functions.
- Use `PascalCase` for classes and resources.
- Use `UPPER_SNAKE_CASE` for constants.
- Use static typing where practical.

### Nodes and scenes

- Use descriptive node names.
- Group nodes by function.
- Avoid generic names such as `Node2D`, `Area2D` or `Control` in exported or reusable scenes.

## Deterministic design

Critical gameplay paths should be predictable and reproducible:

- Puzzle solutions must be fixed and readable.
- Enemy spawns and combat outcomes must not depend on hidden randomness.
- Damage values must be explicit.
- AI behavior should use clear states and rules.

Cosmetic variation, ambient audio variation and controlled particle variation are acceptable.

## Input conventions

Document all input actions in `README.md` and keep them remappable.

Current slice conventions include:

- `move_left` / `move_right` for Elena movement.
- `interact` for terminals, valves, consoles and doors.
- `scan` for Elena’s scanning ability.
- `jump` where supported by the current slice.

Do not rename or remove existing input actions without checking every scene and script that depends on them.

## 3D art pipeline

Use a specification-first workflow for 3D assets.

1. Select the relevant concept art and extract its visual rules.
2. Define the asset’s purpose, dimensions, silhouette, materials, palette, animation needs, collision requirements and Godot integration requirements.
3. Approve the specification before generating geometry.
4. Use Blender MCP only for narrowly scoped creation or modification.
5. Review renders from the intended in-game camera against the concept art and art direction.
6. Export using agreed naming, scale, pivot, UV, material and format conventions.
7. Import and validate the asset in Godot.
8. Record integration evidence before marking the asset complete.

Do not generate broad scene changes, character redesigns or material overhauls without an approved specification. Concept art guides the work; it does not replace Godot validation.

## Testing expectations

Before merging a change:

- Run the relevant automated tests.
- Playtest affected runtime behavior in Godot.
- Record the Godot version, command or scene, result and any expected warnings.
- Verify new UI text in both supported languages where applicable.
- Check that interactions, save/state behavior and navigation still work.

Do not mark a feature verified, playable, accessible, performant or release-ready without evidence.

## Git workflow

- Use focused feature branches.
- Use conventional commit messages: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`.
- Keep commits small and reviewable.
- Update `PROJECT_STATUS.md` when status, scope or verified evidence changes.
- Open a pull request for human review before merging significant work.

## Key documents

- `GDD.md`: complete game-design vision and pillars.
- `PROJECT_STATUS.md`: current phase, implementation state and evidence.
- `README.md`: setup, current playable content and project targets.
- `README_VERTICAL_SLICE.md`: Flooded Shelter vertical-slice overview.
- `AGENTS.md`: agent safety, roles, workflow and reporting rules.
- `docs/DESIGN_AUTHORITY.md`: normative design authority.
- `docs/SETUP_FLOODED_SHELTER.md`: Flooded Shelter slice setup and testing.
- `assets/concept/characters/`: approved character concept references.

## Getting started

1. Read `README.md`, `PROJECT_STATUS.md`, `AGENTS.md` and `GDD.md`.
2. Review `README_VERTICAL_SLICE.md` and the character concept references.
3. Check out `feat/godot-vertical-slice`.
4. Open the repository root in Godot 4.7.x.
5. Run the Phase 0 acceptance test.
6. Playtest the Flooded Shelter slice and the 3D test room.
7. Choose one narrow task with explicit acceptance criteria.
8. Implement, test, document and open a pull request.

Do not skip verification. Do not expand scope before the current slice is stable.
