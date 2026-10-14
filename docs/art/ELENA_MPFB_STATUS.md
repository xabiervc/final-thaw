# Elena (MPFB base) — status and evidence

Status: **textured asset, imports in Godot, integrated in the playable Elena controller (`scripts/characters/elena_controller.gd`, flag `use_mpfb_model`).** Not final art. The scripted `ref_elena.glb` stays in `lab_reference_scene` until this model is reviewed. If the GLB cannot be loaded, the controller falls back to its primitive body.

## What exists

| Item | Value |
|---|---|
| Asset | `assets/models/lab_ref/ref_elena_mpfb.glb` (16 meshes, skinned, 53-bone `game_engine` rig, A-pose, 1.70 m, front = +Z) |
| Textures | `assets/textures/lab_ref/elena_mpfb_{albedo,normal,orm}.png`, one 2048² atlas (baked in Cycles from procedural materials, 8 samples) |
| Material | `assets/materials/lab_ref/elena_mpfb.tres` (albedo, normal, ORM: AO=R, rough=G, metal=B) |
| Backpack / Aster | keep the existing `ref_elena` and `ref_elena_aster` materials (resolved by name) |
| Triangles | 29,556 (approved budget 25–30k) |
| Pipeline | `tools/blender/elena_mpfb/`: `make_hair_card_texture.py` (system Python, once), `build_base` → `build_clothes` → `build_hair_cards` → `build_accessories` → `build_materials` → `build_finalize` (live Blender session with MPFB enabled), then `bake_elena.py` (headless) |

Bake command (Blender 5.2.2, ~2 min on CPU):

```text
blender --background --factory-startup --python tools/blender/elena_mpfb/bake_elena.py -- --repo <repo> --blend <elena_mpfb_outfit_v04.blend> --blend-dir <dir> --samples 8
```

The source `.blend` files live outside the repo (`D:/Projects/evidence/final-thaw/elena_mpfb/`).

## Integration

- `elena_controller.gd` instances `ref_elena_mpfb.glb` under its `visual` node and assigns each surface the `.tres` that matches its imported material name (same method as `lab_reference_scene.gd`), then adds a cyan Aster light at the hand. Collision capsule (0.32 m x 1.7 m), movement, facing and breathing scale are unchanged.
- `use_mpfb_model = false` restores the previous primitive body. The same fallback applies automatically if the GLB or its import is missing.
- `tests/test_elena_model.tscn` checks mesh count, skeleton, triangle budget, height, materials and the fallback. It has been written but not yet run; see the evidence below.

## Evidence (2026-10-14)

- Godot 4.7.2 stable, `godot --headless --path . --import`: GLB and PNGs import without errors.
- Script load check: 1 skeleton, 16 `MeshInstance3D`, all skinned except the Aster screen, ~29.5k triangles, head top at 1.71 m.
- Windowed render (OpenGL 3 via ANGLE, Intel HD 630) of front, side, back and head views with the `.tres` materials applied by name: textures, coat piping and eyes display; captured outside the repo.
- Not run: `lab_reference_scene.gd --check` against this asset (the reference scene still uses `ref_elena.glb`), `tests/test_elena_model.tscn`, animation, Godot performance profiling, grayscale readability review, a playthrough of the playable rooms with this model.

## Known limits

- Procedural cloth/skin only: no painted detail, no fold detail, no freckles or skin variation beyond noise.
- Face is a tuned MPFB head with simple eyes and brows; it does not reproduce the concept's painted likeness.
- Hair: since 2026-10-14 it is hair cards (about 1,900 triangles of alpha-scissor strips following the skull from the hairline and centre part to the nape, plus ponytail strips) over a heavily decimated shell. Strand texture and material are procedural (`make_hair_card_texture.py`, `elena_hair_cards.tres`). Second pass (crown strips, staggered strand roots) removed the dark crown patch and the hard fringe line. Remaining: alpha-scissor edges alias at distance, the silhouette is a smooth dome. It reads as hair with a parting and a ponytail, not yet as the concept's flowing style. Eyelash lines added for eye definition.
- Boot toes show the foot's toe shapes through the rubber.
- Coat hem is slightly wavy; piping edges are face-stepped.
- A-pose only. The Aster hangs at the right hand and needs a posed arm to look held.
- In the playable controller Elena keeps the A-pose while moving, jumping and falling (no walk, jump or idle animation yet), so she slides across the floor.
- The base mesh licence from MakeHuman/MPFB has not been verified against the official source and is **not** recorded in `PROVENANCE.md` yet.
