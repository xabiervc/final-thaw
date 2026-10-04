# Copilot Instructions — FINAL THAW (Godot 4.7, GDScript)

## Source of truth

- The repository root and its `project.godot` are the canonical editable project.
- Read `AGENTS.md`, `CLAUDE.md`, `README.md`, `PROJECT_STATUS.md`, `docs/DESIGN_AUTHORITY.md`, and the relevant normative design document before planning changes.
- If a design document conflicts with these instructions, stop and ask instead of guessing.
- Write code, comments, and documentation in English.

## Project

- 2D climate thriller action-adventure with two playable characters: Elena (puzzles/navigation, no attacks) and Marcus (combat, no hacking).
- Engine: Godot 4.7.x, GDScript only. Renderer: Compatibility. Web test first; final targets are PC and mobile.
- Viewport: 1280x720. Stretch mode: `canvas_items`. Aspect: `keep`. Physics: 60 Hz.
- Current stage: Phase 0 (technical foundation). Do not implement later-phase features unless asked.

## Project layout

- `scripts/managers/`: `InputSetup`, `GameManager`, `DebugManager` autoloads.
- `scripts/entities/`: player and interactables.
- `scripts/ui/`: menus and HUD.
- `scripts/levels/`: level scripts.
- `scenes/ui/`, `scenes/levels/`, `scenes/entities/`: `.tscn` files.
- `assets/`: fonts, textures, audio, and other game assets.
- `docs/`: design and development documentation.
- `tests/`: acceptance tests.

## Coding rules

- Use static typing wherever practical.
- Follow the official GDScript style guide: tabs; `snake_case` functions and variables; `PascalCase` classes and nodes; `UPPER_SNAKE_CASE` constants; leading underscore for private members.
- Never use `class_name` on an autoload script. Prefer `preload("res://...")` where appropriate.
- Access configured autoloads by global name: `GameManager`, `DebugManager`, `InputSetup`.
- Do not create extra singletons without an approved design decision.
- Use signals for communication between nodes. Avoid long `get_node()` paths; prefer `@onready` and `%UniqueName` nodes.
- Prefer composition and small single-purpose scripts.
- Keep physics in `_physics_process` and gameplay input in `_unhandled_input`.
- Do not use emojis or special glyphs in UI text.
- Comments explain why, not what.

## Input and accessibility

- Every input goes through an action defined in `InputSetup`.
- New actions require keyboard and gamepad bindings and remain remappable.
- Do not rely on color alone.
- Text size respects `GameManager.font_scale`.
- Follow the 38 testable accessibility requirements in `docs/ACCESSIBILITY_SPEC.md`.

## Save system

- Saves use `user://save_<slot>.json`.
- Format: `{"payload": <JSON string>, "crc32": <int>}`.
- CRC32 is computed over the exact payload string, never a re-serialized dictionary.
- Corrupt or missing files return `false` and leave current state untouched.
- Tests use slot 99 and never slot 0.

## Design constraints

- Consequence variables: `civilian_aid` (0-10), `prototype_integrity` (0-3), `elena_safety` (0-3), `evidence_choice` (`"preserve"` or `"erase"`).
- Public Thaw requires `civilian_aid >= 4`, preserved evidence, `elena_safety >= 2`, and `prototype_integrity >= 2`.
- Fragile Thaw is forced when `elena_safety <= 1` or `prototype_integrity <= 1`.
- Otherwise the ending is Guarded Thaw.
- Hazards are deterministic with visible and audible telegraphs and no random damage.
- Failure teaches: short setbacks and collectibles persist through death.
- Put tunable numeric values in exported variables or constants.

## Testing and workflow

After every change, run:

```text
godot --headless --path . res://tests/test_phase_0.tscn
```

The runner must exit 0 for success and 1 for failure. When adding behavior, add or update a test that checks real game rules, not only node existence. Do not edit `project.godot` by hand unless asked; explain the change first. Never commit `.godot/`. Keep changes small and focused. Before a large refactor, summarize the plan and wait for confirmation.

## Reporting

Before editing, list expected files. After editing, report exact files changed, tests actually run, test output or exit code, and any verification still required. Never claim runtime, build, playtest, accessibility, performance, or backup verification without evidence.
