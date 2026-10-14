# Final Thaw - Flooded Shelter playable prototype

Status: experimental branch `feat/godot-vertical-slice`. This is a 2D greybox prototype, not the full 25-minute production vertical slice. It adds no new autoloads, does not change `project.godot`, and leaves Phase 0 intact.

## Run

Open the repository root (`project.godot`) in Godot 4.7.x. Open `scenes/levels/flooded_shelter.tscn` and press F6 (Run Current Scene). The normal F5 main menu still starts the Phase 0 test room. This isolation is intentional.

Move with WASD or arrows. Press E beside the marked stations; Tab or Q shows the goal. Route: POWER -> VALVES -> optional CIVILIAN -> EXIT. Oxygen starts draining when valves open; at zero, the room restarts. A successful rescue increments `GameManager.civilian_aid` once and saves slot 0; the exit screen summarizes the consequence. Press E after finishing to return to the main menu.

## Test

From the repository root: `godot --headless --path . res://tests/test_vertical_slice.tscn`. Existing Phase 0 checks: `godot --headless --path . res://tests/test_phase_0.tscn`. If the executable is not on PATH, use the full path to Godot. The vertical-slice test uses save slot 99 and removes it afterward.

## Limits and validation

No runtime validation was performed by the authoring assistant. Test in the editor before calling this playable. The scene is built dynamically; its TSCN shows only a root node in the editor. The prototype intentionally has no Marcus, combat, sound, final assets, mobile touch controls, complete accessibility suite, or web export. The existing player controller may also need an interaction-input routing check because it consumes `interact`; verify the station interaction by hand. Do not merge into main until F6 and both headless test scenes pass.


## Canonical 3D investigation slice

The four-elevation Phase 1 greybox is a separate scene, not the main menu target:

- Run it in the editor with **F6 (Run Current Scene)**: `scenes/prototypes/phase1_canonical_greybox.tscn`.
- Run its integration test: `godot --headless --path . res://tests/test_phase1_canonical_greybox.tscn`.
- Verify the G→H parking-entry variant: `godot --headless --path . res://tests/test_phase2_parking_entry.tscn`.
- Architectural authority: `docs/design/FASE1_ARCHITECTURAL_LAYOUT.md`, the floor-plan SVGs under `docs/design/assets/phase1_architecture/`, and the spatial/greybox/functional specifications.
- The canonical scene builder places the lift between P0 (Y=0) and M (Y=+1.5), then uses fixed stairs S2 to reach P2 (Y=+3). The canonical spawn is in a physically enclosed 3 m entrance tunnel outside A. P0's nave ends north of the D1/D2 void; the A→B corridor borders the open pit instead of crossing it. The Aster landmark is supported by the nave floor and its scanner trace is aligned with it. G is a horizontal exit vestibule; it has no return stair.

The integration assertions now cover floor openings, S1/S2 handrails, both lift-shaft landings, exposed M/P2 edges, grounded fixtures, Aster/scan alignment, the 1.5 m mission lift and power loss while moving. A separate headless smoke test checks that G→H starts the chase at the parking checkpoint and does not spawn the patrol within immediate proximity. Godot execution and manual traversal are still required; runtime validity, clearances, camera readability, collision behavior and the complete G→H handoff remain **unverified**.

The existing Phase 2 motion/chase prototype now gives its latter section a service-parking-garage read, with marked bays, parked vehicles, pillars and a central escape lane. The canonical scene hands off to `scenes/prototypes/phase2_parking_chase.tscn`, which reuses the same script but starts at checkpoint X=34.5 instead of replaying the standalone corridor from its beginning. This handoff and the chase balance remain unverified. Do not create another architecture/progression document; the current sources of truth are the existing files under `docs/design/`.
