# FINAL THAW

**A climate-thriller sci-fi adventure about investigation, physical risk, and consequential discoveries.**

The current working direction is an Elena-led opening: investigate a Helix/Aster system, uncover evidence, then escape a containment response through traversal and stealth. This is a prototype hypothesis, not yet the locked full-game scope.

## Current playable: Phases 1 and 2

"Iniciar demo" in the main menu opens the demo (`scenes/prototypes/phase1_canonical_greybox.tscn`), one continuous scene:
- an intro cinematic (skippable: hold E / X);
- Phase 1, **The Ghost Protocol**: investigate the Aster anomaly inside the Helix facility. Compare the official report, the wiring schematic and a tampered A–T jumper, form a hypothesis (field notes), test it on the circuit, read the restricted record;
- Phase 2, **Containment**: leaving through airlock G sends a service audit. Slip away from the recovery unit, take the lift, get reacquired at R1, escape through the drainage gallery into the service yard, and reach the emergency exit;
- an ending cinematic and a results screen.

The as-built record, design decisions, measured performance and known limits are in [the as-built record](docs/design/FASE1_PREMIUM_AUDIT.md). It is verified by automated tests and a route bot; **there has been no human playtest yet**. 60 FPS on an Intel HD 630 needs the "Performance" graphics preset.

### Controls

Every control below can be remapped in Options → Controls (keyboard and gamepad; conflicts swap; restore defaults).

| Action | Keyboard | Gamepad | Input action |
|---|---|---|---|
| Move | WASD / arrows | Left stick | `move_up` `move_down` `move_left` `move_right` |
| Look | Mouse (click to capture) | Right stick | `look_*` |
| Run (uses stamina) | Shift | LB / L1 or RT | `run` |
| Crouch (quieter, harder to see; stays down under low ceilings) | Ctrl / C | B / ○ | `crouch` |
| Jump; jump while moving at a ledge to climb onto it (0.45–1.85 m) | Space | A / ✕ | `jump` |
| Interact | E / F | X / □ | `interact` |
| Scan (hold) | Tab / Q | Y / △ | `scan` |
| Hint (graded, never the full solution) | H | View / Share | `hint` |
| Pause menu (field notes, options, retry, quit) | Esc / P | Menu / Options | `pause` |

The 16 Phase 0 action names stay defined for older scenes. The combat and legacy hotkey actions (`attack_*`, `dodge`, `quick_save`, `quick_load`, `toggle_captions`, `increase_font`, `decrease_font`, `toggle_colorblind_mode`) are not used by the demo. Captions, text size and the colour-blind palette are set in Options.

### Options

Every option changes the game:
- Accessibility: text size, high contrast, reduced motion, subtitles and subtitle background, colour-blind palette, game speed.
- Gameplay: difficulty (Explorer / Standard / Demanding), camera sensitivity, invert vertical look, graphics quality.
- Audio: master, music and effects volume.
- Controls: remapping.

Options are saved with the game settings and survive restarts.

## Other prototypes

The branch also keeps the **motion/chase prototype v2** (`scenes/prototypes/motion_chase_prototype.tscn`, [spec](docs/design/MOTION_CHASE_PROTOTYPE.md)), a mechanics test bed that is no longer connected to the demo. It also keeps the earlier Flooded Shelter 2.5D and Elena test-room experiments, available for comparison and reusable components.

## Current design documents

1. [Working vision](docs/VISION.md)
2. [Design pivot and prototype brief](docs/DESIGN_PIVOT_PROTOTYPE_BRIEF.md)
3. [Motion/chase prototype specification](docs/design/MOTION_CHASE_PROTOTYPE.md)
4. [Core gameplay loop](docs/CORE_LOOP.md)
5. [Level structure](docs/LEVEL_STRUCTURE.md)
6. [Project status and evidence boundary](PROJECT_STATUS.md)
7. [Traceability matrix](docs/TRACEABILITY_MATRIX.md)
8. [Design authority](docs/DESIGN_AUTHORITY.md)
9. [Asset provenance and licences](docs/art/PROVENANCE.md)
10. [Asset register (status, replacement work, production prompts)](docs/art/MASTER_ASSET_LIST.md)
11. [As-built record, Phases 1–2](docs/design/FASE1_PREMIUM_AUDIT.md)

The older 16-phase, dual-protagonist campaign documents are retained as historical design material while the prototype is evaluated. They are not automatically binding requirements for the new prototype.

## Engine and technical constraints

- Engine: Godot 4.7.x (see project status for the recorded patch).
- Language: GDScript.
- Renderer: Compatibility (measured on an Intel HD 630; graphics presets in Options).
- Preserve Phase 0 input, autoload, resource, save and CRC32 contracts.
- Profile the actual target before making renderer or platform changes.
- Do not claim performance, accessibility, playability or production readiness without recorded evidence.

## Verification commands

Run from the repository root:

```sh
godot --headless --fixed-fps 60 --path . res://tests/test_phase1_playthrough.tscn
godot --headless --fixed-fps 60 --path . res://tests/test_phase1_containment.tscn
godot --headless --fixed-fps 60 --path . res://tests/test_game_systems.tscn
godot --headless --fixed-fps 60 --path . res://tests/test_phase_0.tscn
```

Every suite is a scene in `tests/` and runs the same way (32 suites; the last recorded results are in `PROJECT_STATUS.md`). To benchmark a location: `godot --path . --resolution 1280x720 res://tools/capture/scene_capture.tscn -- --scene=res://scenes/prototypes/phase1_canonical_greybox.tscn --props=play_intro:false --pos=18.5,3,-5.4 --wait=120 --bench=400 --out=D:/Projects/evidence/shot.png` (screenshots stay outside the repository).

Then run the prototype manually. Automated tests do not verify camera comfort, movement feel, enemy fairness, audio quality or whether the chase is fun.

## Asset and development workflow

Treat existing character models, lab kit, shaders, visual wrappers, scanner effects, HUD and synthesized audio as prototype assets. Review them from the intended third-person camera and verify collision, scale, traversal clearance, occlusion, provenance and licensing before production use.

Keep changes narrow and reversible. Do not remove earlier scenes, change the save schema, or rewrite the full campaign until the combined puzzle/escape prototype has passed owner review.

## Owner-approved next direction (2026-10-15)

The current playable route described above is the **as-built prototype**, not the final approved direction for the next production pass. The owner has approved a target of illustrated 3D adventure art (informed by the Marcus character concept and illustrated industrial laboratory reference), a larger but legible interconnected Phase 1 building, a physically collapsed service-breach entrance, and a redesigned Phase 2 that begins with human operational discovery and continues into a hybrid first-person escape through a distinct parking garage to a public street.

The escape target combines free movement and route choice with short contextual actions and brief looks back that show consequences. The robot-led route remains the current implementation until a replacement is integrated and verified. The future Marcus-led beat-'em-up progression is a documented design direction only: Elena begins dependent on Marcus and gradually learns limited defensive skills from him. Full combat implementation is not part of the current Phase 1/2 task.

See [Design Authority](docs/DESIGN_AUTHORITY.md), [Working Vision](docs/VISION.md), [Core Loop](docs/CORE_LOOP.md), [Level Structure](docs/LEVEL_STRUCTURE.md), and [Project Status](PROJECT_STATUS.md). These approved targets do not imply implementation or verification; use the status and traceability documents for evidence.
