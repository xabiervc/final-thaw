# Project Status — FINAL THAW

## Current phase

Phase 1 — First playable vertical slice and early 3D prototype.

## Design status

The design authority and supporting specifications are present. Design completeness does not imply implementation completeness.

## Implementation status

Phase 0 acceptance testing remains verified from the canonical checkout.

The `feat/godot-vertical-slice` branch contains the functional skeleton of the **Flooded Shelter 2.5D** vertical slice, plus an early 3D test-room prototype.

### Flooded Shelter 2.5D slice

- Elena has lateral movement, jumping, oxygen depletion and object interaction.
- The slice includes a power room, valve room and rescue room.
- The player can activate a generator, drain water through valves, rescue a trapped civilian and reach the exit.
- A demo-end screen summarizes player decisions.
- `GameStateManager` persists decisions and language preference.
- `NarrativeTextManager` centralizes narrative text and supports ES/EN localization.
- The main menu includes narrative context and an ES/EN language selector.

### Canonical shelter repairs

The canonical 2.5D shelter has received a substantial repair pass:

- `FloodedShelterController` has explicit scene references to Elena, civilian, console, both valves, flood gate and shelter light.
- The controller joins the `flooded_shelter` group; `WinZone` and `DemoEnd` locate it safely.
- The controller restores persisted power, valve, civilian and light state during `_ready()`.
- Elena detects `Interactable` areas through `area_entered` / `area_exited` and calls `Interactable.try_interact()`.
- `Interactable.interact()` delegates to `try_interact()`, so prop behavior and signals execute correctly.
- The civilian is interactable and can be rescued.
- The scene includes floor, walls, player collision, interaction collision and win-zone collision.
- The death flow connects through the controller and completes the level as a failure.
- Generator and valve prompts use localized text and refresh on language change.
- The shelter light responds to generator activation and persisted power state.
- `DemoHUD` has wired oxygen, objective and civilian labels; it updates oxygen continuously and initializes civilian state.
- `DemoEnd` has wired title, summary and buttons; it locates the controller and refreshes on language change.
- `NarrativeTextManager` emits `language_changed`, enabling prompts, HUD and end-screen text to update dynamically.

### Verification boundary

These repairs are implemented but **not yet verified by a recorded Godot playtest**. The following must be checked before TD-011 can close:

- The project compiles without script errors.
- The canonical scene loads without missing-node or missing-resource errors.
- Elena's `InteractionArea` detects `Interactable` areas.
- Generator activation, valve opening, flood-gate opening, civilian rescue and win-zone completion all work.
- Oxygen HUD updates continuously.
- `DemoHUD` labels display localized text.
- `DemoEnd` displays title, summary and functional buttons.
- ES/EN localization updates prompts, HUD and end screen.
- Persistence restores controller and prop state.

### Early 3D prototype

- A separate test room implements Elena movement, interaction and scanning in 3D.
- This is an early technical prototype for Phase 1; it does not replace or complete the Flooded Shelter 2.5D slice.
- Further work is required to validate 3D movement, camera framing, interaction affordances, collision, performance and visual direction.

## Verified evidence

- Engine: Godot 4.7.2.stable.official.ed1daf0bf.
- Phase 0 command: `--headless --path D:\Projects\github\final-thaw res://tests/test_phase_0.tscn`.
- Phase 0 result: 11 passed, 0 failed; exit code 0.
- Expected warning: the CRC32 corruption-detection test emits a corruption warning by design.
- The Flooded Shelter slice and 3D test room require recorded manual playtest evidence before being considered verified milestones.

## Current milestone

Stabilize and playtest the `feat/godot-vertical-slice` branch, then merge it after human review and recorded evidence.

## In progress

- Validating the repaired canonical Flooded Shelter interaction loop in Godot.
- Keeping design traceability aligned with implementation.
- Validating the Flooded Shelter gameplay loop, narrative flow, localization and decision summary.
- Evaluating the early 3D test room for movement, interaction, scanning and visual direction.
- Preparing a narrow art-production workflow for assets, potentially using Claude with a Blender MCP under explicit asset specifications.

## Known limitations

- The full game, complete vertical slice, accessibility suite, performance targets and platform exports are not yet verified.
- Phase 0 evidence verifies the technical foundation only.
- The Flooded Shelter slice is functionally complete at a prototype level, but is not art-complete, audio-complete, polished or release-ready.
- The canonical shelter repairs have not yet been validated by recorded Godot playtesting.
- The 3D test room is an early prototype, not a content-complete or production-quality vertical slice.
- Art, lighting, VFX, audio, Marcus gameplay, dual-protagonist systems, combat, puzzles and ending content remain unimplemented or unverified.

## Next three tasks

1. Run Godot and execute `docs/PLAYTEST_CHECKLIST.md` against `scenes/levels/flooded_shelter_2_5d.tscn`.
2. Record PASS/FAIL evidence for scene load, movement, interaction, generator, valves, gate, rescue, win zone, oxygen, persistence and ES/EN localization.
3. Playtest the 3D test room and record evidence for movement, interaction, scanning, collision, camera readability and performance.

## Next slices

### Marcus — Beat ’em up 2D

- Arena with X/Y movement.
- Basic combo, heavy attack and dodge.
- Basic enemies with hitboxes and hurtboxes.
- Throwable environmental object.
- Consequences affecting `civilian_aid`.

### Integration

- Transitions between slices with dialogue and consequences.
- Global save system and decision tree.

## How to test the current slice

1. Switch to the `feat/godot-vertical-slice` branch.
2. Open the project in Godot 4.4 or later.
3. Follow `docs/SETUP_FLOODED_SHELTER.md` to configure nodes and run the slice.
4. Use the ES/EN selector in the main menu to change language.
5. Separately test the 3D test room for Elena movement, interaction and scanning.

## Summary

The Flooded Shelter 2.5D slice is functionally complete at prototype level. Recent commits repaired the interaction chain, scene references, collision geometry, civilian rescue, death flow, prop persistence, shelter light, HUD wiring, end-screen wiring and dynamic localization. The next required step is recorded Godot validation of the repaired loop.

## Reporting rule

Do not mark a feature as verified, playable, accessible, performant or release-ready without evidence.
