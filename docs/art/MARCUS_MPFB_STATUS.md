# Marcus (MPFB base) — status and evidence

Status: **textured asset, imports in Godot, not integrated in any scene, not final.** Built from `MARCUS_MPFB_SPEC.md` (approved by the owner 2026-10-14).

| Item | Value |
|---|---|
| Asset | `assets/models/lab_ref/ref_marcus_mpfb.glb` (skinned, 53-bone `game_engine` rig, A-pose, 1.817 m, front = +Z) |
| Textures / material | `assets/textures/lab_ref/marcus_mpfb_{albedo,normal,orm}.png` (2048² atlas), `assets/materials/lab_ref/marcus_mpfb.tres`, amber `marcus_radio_screen.tres` |
| Triangles | 28,724 (budget 30k) |
| Pipeline | `tools/blender/elena_mpfb/`: `char_common.py`, `build_marcus.py` → `build_marcus_finalize.py` (live Blender with MPFB), then `bake_marcus.py` (headless, ~3 min) |

## Evidence (2026-10-14)
- Godot 4.7.2: `--headless --import` clean; windowed capture (OpenGL 3 via ANGLE, Intel HD 630) of front/side/back/head with the `.tres` applied by name.
- Not run: animation, profiling, grayscale readability, integration, owner review against the concept.

## Known limits (why it is not final)
- Face is a generic tuned MPFB male head; no likeness to the concept, no stubble, hairline is stepped.
- Jacket: no real stand collar (padded ring added instead), no pockets/zipper detail, yoke and elbow-patch edges are face-stepped, jacket is a smoothed shell without fold detail.
- Boots show toe lobes; gloves are texture only on the skin hands.
- A-pose only; MPFB licence not yet verified for `PROVENANCE.md`.
