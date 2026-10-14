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

### Art pipeline and 3D art (2026-10-14, branch `feat/godot-vertical-slice`)

Status: **assets and visual wrappers exist and import in Godot; none is final, none has been reviewed by the owner in a playtest.**

- **Elena (MPFB base)** — `assets/models/lab_ref/ref_elena_mpfb.glb`: skinned (53-bone `game_engine` rig), 1.70 m, ~29.9k triangles, 2048² baked atlas, hair cards, painted face detail. The playable controller loads it with a primitive fallback. See `docs/art/ELENA_MPFB_STATUS.md`.
- **Marcus (MPFB base)** — `ref_marcus_mpfb.glb`: 1.817 m, ~28.8k triangles, jacket, belt kit, stubble, hair cards. Not wired into any scene (no Marcus gameplay exists). Spec: `docs/art/MARCUS_MPFB_SPEC.md`; status: `MARCUS_MPFB_STATUS.md`.
- **Level dressing (decision D1)** — visual-only wrappers `abandoned_lab_art.tscn` and `elena_test_room_art.tscn` instance the unmodified levels and add photographic CC0 textures (Poly Haven, 1K), kit walls/floors/dividers/set pieces, a lighting pass (glow, grading, fixture lights) and the Batch 2 art for 10 interactive component types, mirroring their glow/state. `NEXT_PATH` (`elena_test_room.gd`) and `LEVEL_PATH` (`main_menu.gd`) point at the wrappers; reverting those two constants restores the greybox. `abandoned_lab.tscn/.gd` are untouched. Details: `docs/art/LAB_KIT_PLAN.md`.
- **Provenance** — all external resources are recorded in `docs/art/PROVENANCE.md`. The MakeHuman/MPFB base-mesh licence is **not yet verified** against the official source.
- **Evidence** — Godot 4.7.2: all 12 scenes in `tests/*.tscn` exit 0 with no script errors (including `test_lab_art_components`, 12 checks, and `test_elena_model`, 14 checks). Windowed captures on an Intel HD 630 (OpenGL via ANGLE) were taken for characters and levels and kept outside the repo. Compile errors in `NarrativeTextManager`/`NarrativePanel` and missing `GameManager.get_flag/set_flag` were fixed; `test_vertical_slice`, `test_control_room_texts` and `test_phase_0` were repaired.
- **Not verified** — manual playtest of any dressed level, animation/posed characters, FPS or memory (no profiling), grayscale readability, the Marcus model in a scene. The renderer is still `gl_compatibility` (no SSAO, GI, volumetrics); a Forward+ move is an owner decision.
- **Known visual gaps vs. the concept art** — face likeness (generic tuned heads), strand-level hair, fabric folds, boot toes, collar detail; decor has no colliders; hazard zones, prototype carrier and tutorial barriers have no art.

### Elena test room transformation (2026-10-14, branch `feat/godot-vertical-slice`)

Scope: `scenes/levels/elena_test_room_art.tscn` (main-menu entry). Gameplay rules unchanged except the fixes below.
Evidence: Godot 4.7.2, Intel HD 630 (GL Compatibility via ANGLE), captures and benchmarks with
`tools/capture/scene_capture.tscn`; images kept outside the repo in `D:/Projects/evidence/final-thaw/transform_2026-10-14/`.

- **Art direction (VERIFIED in captures):** the room is dressed as Helix test bay B, a flood-control wing evacuated
  during the thaw (`scripts/levels/test_room_art/`, `assets/shaders/facility_*.gdshader`, `hazard_paint.gdshader`):
  meltwater tide line on every wall, flood barriers, frosted shutter, pump and gauge, warming station, generator
  landmark, airlock; emergency light rig and a generator circuit that comes online with the lever.
- **Fixes (VERIFIED by tests):** interaction targeting requires line of sight (the generator lever could be pulled
  through its wall); the alcove wall dithers away while Elena is behind it (she was fully hidden).
- **Investigation (VERIFIED by tests):** a scan in the generator bay reveals the feed cable to the hidden lever, with
  a one-time explanation; inspect points have specific names.
- **HUD (VERIFIED in captures at 1886x1061 and 1280x720):** objective card, amber key-cap prompt using the live
  `interact` binding, condition card, banners, input-map control legend, subtitle bar, world target marker.
- **Audio (IMPLEMENTED, not listened to):** deterministic synthesized soundscape (`scripts/audio/sfx_synth.gd`).
  Streams and player state are tested; mix and tone need a listening pass.
- **Elena pose (VERIFIED in captures/tests):** procedural rest pose, walk, air tuck and landing dip on the MPFB rig.
- **Performance (MEASURED, 3 interleaved rounds vs a worktree of 569f61e, 1280x720):** idle 11.2-11.6 ms vs
  13.0-14.2 ms; powered generator bay 11.1-13.8 vs 13.9-14.3; walking 13.1-14.0 vs 13.7-14.4. 1080p window:
  19.9-21.6 vs 26.8-27.0. Draw calls 184-213 vs 391-434. No Web export was profiled.
- **Tests:** `test_interaction_targeting` (15 checks) and `test_room_presentation` (27) added; all suites exit 0.
- **Not verified:** a manual hands-on playtest with keyboard, audio by ear, high-contrast/large-UI screenshots,
  Web export. The ES locale of the room's in-level dialogue is still hard-coded Spanish (no EN for that room).
- **Design direction changed on 2026-10-14** (two-mission redesign, 3D chase prototype first). This room's art
  pass does not pre-empt that decision; reusable parts are the LOS targeting, HUD, synthesized audio, pose layer,
  wall cutaway and capture harness.

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
- Final-quality art, VFX, audio, Marcus gameplay, dual-protagonist systems, combat, puzzles and ending content remain unimplemented or unverified.

## Next art tasks (need owner review or new hardware)

1. Review the dressed lab and phase 1 room in Godot and decide whether the look is acceptable.
2. Decide on the renderer (Forward+) and character-face tooling when the new PC arrives; verify the MPFB licence.
3. Commission or produce sculpted faces, hair and fabric detail; add collision to set pieces if desired.

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
