# Copilot Instructions — FINAL THAW (Godot 4.7, GDScript)

## Project
- 2D climate thriller action-adventure with two playable characters: Elena (puzzles/navigation, no attacks) and Marcus (combat, no hacking).
- Engine: Godot 4.7.x, GDScript only (no C#). Renderer: Compatibility (web test first; final targets are PC and mobile).
- Viewport 1280x720, stretch mode `canvas_items`, aspect `keep`, physics 60 Hz.
- Current stage: Phase 0 (technical foundation). Do not implement later-phase features unless asked.

## Project layout
- `scripts/managers/` autoloads: `InputSetup`, `GameManager`, `DebugManager`.
- `scripts/entities/` player and interactables. `scripts/ui/` menus and HUD. `scripts/levels/` level scripts.
- `scenes/ui/`, `scenes/levels/`, `scenes/entities/` hold `.tscn` files. `assets/` holds fonts, textures, audio.
- `tests/` holds the acceptance tests. `docs/` (if present) holds the design documents.

## Coding rules
- Use static typing wherever possible (`var speed: float = 320.0`, typed function signatures and return types).
- Follow the official GDScript style guide: tabs for indentation, `snake_case` for functions and variables, `PascalCase` for classes and nodes, `UPPER_SNAKE_CASE` for constants, leading underscore for private members.
- Never use `class_name` on an autoload script (it conflicts with the autoload name). Prefer `preload("res://...")` over `class_name` for scripts instantiated from code.
- Access autoloads by their global name (`GameManager`, `DebugManager`, `InputSetup`). Do not create extra singletons without asking.
- Use signals for communication between nodes ("call down, signal up"). Avoid long `get_node()` paths; use `@onready` and `%UniqueName` nodes.
- Prefer composition and small scripts over deep inheritance. Keep functions short and single-purpose.
- Keep physics code in `_physics_process`, input handling in `_unhandled_input`, and never poll input in `_process` for gameplay.
- Do not use emojis or special glyphs in UI text (the default font and the web export do not render them).
- Comments explain *why*, not *what*. Write code and comments in English.

## Input and accessibility
- Every input must go through an action defined in `InputSetup` (16 actions). Never hard-code key codes in gameplay scripts.
- Every action must stay remappable. Any new action must also get keyboard and gamepad bindings.
- Do not rely on color alone to convey information; pair it with text, shape, or sound.
- Text size must respect `GameManager.font_scale`. Timed actions should have a toggle or assist alternative.
- Design target: 38 testable accessibility requirements (see `docs/ACCESSIBILITY_SPEC.md` if present).

## Save system
- Saves live in `user://save_<slot>.json`. The file stores `{"payload": <JSON string>, "crc32": <int>}`.
- The CRC32 is computed over the exact payload string, never over a re-serialized dictionary.
- On a corrupt or missing file, `load_game()` must return `false` and leave the current state untouched.
- Tests use slot 99 and must never touch slot 0.

## Game-design constraints (do not violate)
- Consequence variables: `civilian_aid` (0-10), `prototype_integrity` (0-3), `elena_safety` (0-3), `evidence_choice` (`"preserve"` or `"erase"`).
- Endings: Public Thaw needs `civilian_aid >= 4`, evidence preserved, and `elena_safety >= 2` and `prototype_integrity >= 2`. Fragile Thaw is forced when `elena_safety <= 1` or `prototype_integrity <= 1`. Otherwise Guarded Thaw.
- Hazards are deterministic: fixed cycles, visible and audible telegraphs, no random damage.
- Failure teaches, it does not punish: short setbacks, collectibles persist through death.
- Numeric values in design docs (damage, timers, speeds) are hypotheses to be tuned by playtesting. Put them in exported variables or constants so they are easy to change.

## Testing and workflow
- After every change, run the acceptance tests:
  `godot --headless --path . res://tests/test_phase_0.tscn`
  The runner exits with code 0 if all tests pass and 1 otherwise.
- When adding behavior, add or update a test in `tests/` that checks real game rules, not just that nodes exist.
- Do not edit `project.godot` by hand unless asked; explain the change first. Never commit the `.godot/` folder.
- Keep changes small and focused. Before large refactors, summarize the plan and wait for confirmation.
- If a design document conflicts with these instructions, stop and ask instead of guessing.
