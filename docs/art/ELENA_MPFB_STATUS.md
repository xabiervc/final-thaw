# Elena (MPFB base) — status and evidence

Status: **textured asset, imports in Godot, not integrated in any scene.** Not final art: it does not yet resemble the concept closely enough (face, hairline, boot toes), so it is not marked final. Replaces nothing yet: the scripted `ref_elena.glb` stays in `lab_reference_scene` until this model is reviewed.

## What exists

| Item | Value |
|---|---|
| Asset | `assets/models/lab_ref/ref_elena_mpfb.glb` (16 meshes, skinned, 53-bone `game_engine` rig, A-pose, 1.70 m, front = +Z) |
| Textures | `assets/textures/lab_ref/elena_mpfb_{albedo,normal,orm}.png`, one 2048² atlas (baked in Cycles from procedural materials, 8 samples) |
| Material | `assets/materials/lab_ref/elena_mpfb.tres` (albedo, normal, ORM: AO=R, rough=G, metal=B) |
| Backpack / Aster | keep the existing `ref_elena` and `ref_elena_aster` materials (resolved by name) |
| Triangles | 29,812 (approved budget 25–30k) |
| Pipeline | `tools/blender/elena_mpfb/`: `build_base` → `build_clothes` → `build_accessories` → `build_materials` → `build_finalize` (live Blender session with MPFB enabled), then `bake_elena.py` (headless) |

Bake command (Blender 5.2.2, ~2 min on CPU):

```text
blender --background --factory-startup --python tools/blender/elena_mpfb/bake_elena.py -- --repo <repo> --blend <elena_mpfb_outfit_v04.blend> --blend-dir <dir> --samples 8
```

The source `.blend` files live outside the repo (`D:/Projects/evidence/final-thaw/elena_mpfb/`).

## Evidence (2026-10-14)

- Godot 4.7.2 stable, `godot --headless --path . --import`: GLB and PNGs import without errors.
- Script load check (first bake): 1 skeleton, 16 `MeshInstance3D`, all skinned except the Aster screen, ~29.5k triangles, head top at 1.71 m. Re-captured after the polish pass (flat hem, finer hairline); the load check was not repeated.
- Windowed render (OpenGL 3 via ANGLE, Intel HD 630) of front, side, back and head views with the `.tres` materials applied by name: textures, coat piping and eyes display; captured outside the repo.
- Not run: `lab_reference_scene.gd --check` against this asset (it is not wired into the scene), animation, Godot performance profiling, grayscale readability review.

## Known limits

- Procedural cloth/skin only: no painted detail, no fold detail, no freckles or skin variation beyond noise.
- Face is a tuned MPFB head with simple eyes and brows; it does not reproduce the concept's painted likeness.
- Hairline is blocky (hair is a shell cut at a plane/height function) and the ponytail is a tube.
- Boot toes show the foot's toe shapes through the rubber.
- Piping edges are face-stepped. Polish pass 2026-10-14: coat hem levelled, hair subdivided finer; smoothing the boot toes was tried and rejected (it stretched them into points).
- A-pose only. The Aster hangs at the right hand and needs a posed arm to look held.
- The base mesh licence from MakeHuman/MPFB has not been verified against the official source and is **not** recorded in `PROVENANCE.md` yet.
