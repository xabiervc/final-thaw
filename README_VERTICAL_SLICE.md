# Final Thaw - Flooded Shelter playable prototype

Status: experimental branch `feat/godot-vertical-slice`. This is a 2D greybox prototype, not the full 25-minute production vertical slice. It adds no new autoloads, does not change `project.godot`, and leaves Phase 0 intact.

## Run

Open the repository root (`project.godot`) in Godot 4.7.x. Open `scenes/levels/flooded_shelter.tscn` and press F6 (Run Current Scene). The normal F5 main menu still starts the Phase 0 test room. This isolation is intentional.

Move with WASD or arrows. Press E beside the marked stations; Tab or Q shows the goal. Route: POWER -> VALVES -> optional CIVILIAN -> EXIT. Oxygen starts draining when valves open; at zero, the room restarts. A successful rescue increments `GameManager.civilian_aid` once and saves slot 0; the exit screen summarizes the consequence. Press E after finishing to return to the main menu.

## Test

From the repository root: `godot --headless --path . res://tests/test_vertical_slice.tscn`. Existing Phase 0 checks: `godot --headless --path . res://tests/test_phase_0.tscn`. If the executable is not on PATH, use the full path to Godot. The vertical-slice test uses save slot 99 and removes it afterward.

## Limits and validation

No runtime validation was performed by the authoring assistant. Test in the editor before calling this playable. The scene is built dynamically; its TSCN shows only a root node in the editor. The prototype intentionally has no Marcus, combat, sound, final assets, mobile touch controls, complete accessibility suite, or web export. The existing player controller may also need an interaction-input routing check because it consumes `interact`; verify the station interaction by hand. Do not merge into main until F6 and both headless test scenes pass.
