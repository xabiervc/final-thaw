# Lab Art — Batch 1 Specification (environment kit)

**Role: technical blockout, not the artistic standard** (owner decision; see `LAB_REFERENCE_SCENE_SPEC.md`). **Status:** approved by the owner on commit `ccf4905`; **generated and checked automatically, pending the owner's validation in Godot.** Not final, optimized or integrated; nothing is used by `abandoned_lab.tscn`. Values are as built unless a column says "target".

Conventions (same as `LAB_STYLE_SPEC.md`): GLB, 1 unit = 1 m, +Y up, front/interior = +Z, flat `lab_mat_*` materials, no lights, no cameras, no collision in the files. Sources: `tools/blender/build_lab_environment_kit_batch1.py` and `tools/blender/build_elena_blockout_a.py` (shared helpers in `tools/blender/lab_blender_common.py`). `.blend` files live outside the repository.

## Assets

| Asset | Size as built (m, x·y·z) | Pivot | Triangles (budget) | Materials | Purpose |
|---|---|---|---|---|---|
| `lab_wall_low_2m_a` | 2.00 · 0.90 · 0.53 | base center, interior face | 60 (120) | wall_panel, trim_metal | camera-side wall (greybox 0.9 m, 0.5 thick) |
| `lab_wall_2m_b` | 2.00 · 3.20 · 0.56 | base center, interior face | 196 (250) | wall_panel, trim_metal, rubber | vent grille + cable conduit variant |
| `lab_floor_2x2_b` | 2.00 · 0.103 · 2.00 | center, tile top | 92 (120) | floor_epoxy, floor_joint | wear variant (geometric scuffs, 3 mm high) |
| `lab_floor_edge_2m_a` | 2.00 · 0.07 · 0.15 | center, resting on y = 0 | 36 (40) | trim_metal | lip for pit edges and ledges |
| `lab_divider_wall_2m_a` | 2.00 · 3.20 · 0.66 | center, floor level | 108 (160) | wall_panel, trim_metal | divider arms; 0.6 m body + 0.03 m trim each face |
| `lab_door_frame_a` | 4.00 · 3.20 · 0.66 | center, floor level | 204 (250) | wall_panel, trim_metal | opening 2.80 × 3.00 m |
| `elena_blockout_a` | 0.69 · 1.70 · 0.80 | feet center, front +Z | 1,544 (3,500) | 9 `elena_blk_*` + `lab_mat_painted_metal` | see `ELENA_BLOCKOUT_SPEC.md` |

Reused unchanged from the first batch: `lab_floor_2x2_a`, `lab_wall_2m_a`, `lab_wall_corner_a`, `lab_wall_light_a`.

Changes from the approved proposal:
- **No texture.** The proposal listed `lab_detail_wear_a.png`; the owner's constraint is that no PNG goes into the repository, so the `_b` variants use geometric wear (the fallback the proposal named). No texture import settings were touched.
- Real sizes include the 3 cm trims (divider and frame 0.66 m deep, wall_b 0.56 m).
- Door-frame reveal trims were first built inside the opening and coplanar with the jambs (visible z-fighting stripes in captures). They now sit only on the ±Z faces, so the opening is exactly 2.80 × 3.00 m and no faces overlap.

## Fit with the greybox

A divider arm is 4.6 m = 2.0 + 2.0 (modules) + 0.6 (jamb). `lab_door_frame_a` plus two modules per side covers z ±6 (checked: z = −6.000 … 6.000). The door slab (0.4 × 3.0 × 2.8) fits the opening; the 0.2 m header closes the gap to the 3.2 m wall. The existing door strip (`door.gd`) is the same thickness as the frame (0.6 m), so its faces are coplanar with the frame header if both are drawn together: this matters for decision D1 (greybox is hidden when the art is attached).

## Test scene

`scenes/levels/art_tests/lab_kit_art_test_batch1.tscn` + `scripts/levels/art_tests/lab_kit_art_test_batch1.gd`. It does not use `abandoned_lab.tscn` or any gameplay script, and uses `follow_camera.gd` unmodified.

- Layout from `abandoned_lab.gd`: floor 12 m deep, back wall z = −6 (3.2 m), low wall z = +6 (0.9 m), divider at x = 16 with the door frame, pit from x = 22. Floor and back wall alternate `_a`/`_b` for side-by-side comparison.
- A walkable Elena blockout (physics against simple colliders, same convention as `elena_controller.gd`) next to a transparent capsule (r 0.32, h 1.7) and a 1.70 m pole.
- Colliders: `StaticBody3D`, layer 1, mask 0, boxes (floor, back wall, low wall, divider arms, door slab). Elena walker: layer 2, mask 1.
- Camera z limit is widened to 4.6 in this scene only (the game limits it to 1.5) so the 0.9 m wall can be framed. This is a test-scene parameter, not a change to the camera script.
- Lighting presets: `game` (values from `abandoned_lab.gd`) and `palette` (values from the palette test).

Keys: WASD/arrows move · 1–5 framings · O door open/closed · L lighting · G grayscale · P manual capture.

## Automatic check (`-- --check`, headless)

40 checks, 0 failures at the time of writing: sizes and pivots of the 7 assets; 15 material colors (and Aster emissive radiance); frame + modules span 12 m; opening 2.8 m wide and 3.0 m high is free, jambs and header are solid (ray tests against the visible meshes); Elena height 1.70 m with feet at y = 0, 1,544 triangles, 9 meshes, all 9 parts present, no skeleton or animation, backpack behind (−Z) and Aster in front (+Z); collider ray tests; the closed door blocks the capsule and the open door lets it through.

The check cannot judge appearance. It would not have caught the z-fighting above; that was found by looking at captures.

## What the owner validates

See the list in the delivery message and `LAB_KIT_PLAN.md` §5. Until then none of these assets is final, optimized or integrated.
