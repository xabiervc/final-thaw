# Lab Reference Scene — Visual Target and Specification

**Status:** built as an isolated scene and checked automatically; **awaiting the owner's visual review in Godot**. Not final, optimized or integrated. It does not touch gameplay, functional colliders, autoloads, input actions, `project.godot` or the renderer (`gl_compatibility`).

Why it exists: batches 1–2 (`lab_*_a/b`, `elena_blockout_a`) are technical blockouts. This scene is the attempt at **product-level quality** for one representative corner, in the spirit of the concept art (not extreme photorealism, not generic low-poly).

## Visual target (what the scene tries to communicate)

A climate-research lab abandoned recently: cold, desaturated teal-gray architecture with real depth (recessed panels, steel pillars, bolted kick-plate, pipe run with flanges and a valve, cable tray, vertical conduit), a worn epoxy floor with saw-cut joints, bolted plates, a drain grate and painted safety lines, and an industrial science terminal (bolted cabinet, access door, louvers, 65-key keyboard, recessed bezel, amber interface). Light comes from a caged wall lamp over the terminal; amber from the terminal and cyan from Elena's Aster are the only accent hues. Elena stands at the terminal in her long dark-teal coat with gray-cyan piping, backpack with tools, knee-high rubber boots and the Aster in her right hand.

Palette rules kept from `LAB_STYLE_SPEC.md`: amber for interactables, cyan for Elena/scanning, backpack beacon unlit (D2), front of Elena = +Z (D4).

## Composition and camera

- Layout: floor 6 × 4 m (3 × 2 modules), back wall of three 2 m sections (inner face z = −2), left wall of two sections (inner face x = −3), corner column, terminal at (0, 0, −1.6), wall lamp at (0, 2.4, −1.875). No ceiling (camera looks in from above).
- Camera: the existing `scripts/components/follow_camera.gd` (FOV 40, offset (0, 8.5, 6.5)), unmodified. Shots 1–4 use it as is. Shots 5–6 (`detail_*`) only change the camera's `offset` and `fov` properties to inspect surfaces up close; they are inspection views, not gameplay framing.
- **Presentation mode (default):** technical references (scale pole, gameplay capsule) are hidden; `T` shows them. Captures are always taken in presentation mode.

## Assets (`assets/models/lab_ref/`, textures `assets/textures/lab_ref/`, materials `assets/materials/lab_ref/`)

All geometry is modelled by script (`tools/blender/reference/`), UV-unwrapped, and its textures are baked in Cycles from procedural materials. Per asset: `<asset>_albedo.png`, `<asset>_normal.png` (tangent, OpenGL +Y), `<asset>_orm.png` (AO = R, roughness = G, metallic = B); the matching `.tres` is a `StandardMaterial3D` using them. Meshes carry geometry and UV only; the scene applies the `.tres` by material name.

| Asset | What it is | Texture atlas |
|---|---|---|
| `ref_floor`, `ref_floor_plain` | 2 × 2 m module: four beveled epoxy tiles, rubber-filled cross joint, bolted steel plate, painted line; `ref_floor` adds a drain grate (real boolean cut) | 1024² |
| `ref_wall` | 2 m wall section, base on the floor, interior face z = 0, body toward −Z | 2048² |
| `ref_wall_corner` | interior corner column with guard angle and bolted kick-plate returns | 1024² |
| `ref_wall_light` (+ `emit_tube`) | caged wall lamp; the tube is a separate emissive mesh | 512² |
| `ref_terminal` (+ `emit_screen`, `emit_leds`) | industrial terminal; the screen is a separate emissive mesh with its own interface texture | 1024² + 512×288 emission |
| `ref_elena` (+ `emit_aster`) | Elena, rigid parts with pivots at the joints, no skeleton | 2048² atlas + Aster emission |

Measured with `-- --check` (Godot 4.7.2); "proposed" is the budget I first suggested, "limit" the threshold the check enforces:

| Asset | Size (m, x·y·z) | Triangles | Proposed | Limit |
|---|---|---|---|---|
| `ref_floor` / `ref_floor_plain` | 2.00 · 0.15 / 0.12 · 2.00 | 2,700 / 1,482 | 4,000 | 4,000 |
| `ref_wall` | 2.00 · 3.20 · 0.59 | 9,310 | 6,000 | 10,000 |
| `ref_wall_corner` | 0.61 · 3.20 · 0.61 | 1,012 | — | 2,500 |
| `ref_wall_light` | 0.92 · 0.24 · 0.22 | 768 | — | 2,000 |
| `ref_terminal` | 1.76 (incl. floor cable) · 1.48 · 0.93 | 5,878 | 8,000 | 8,000 |
| `ref_elena` | 0.60 · 1.71 · 0.86 | 14,854 | 12,000 | 15,000 |
| Whole scene (6 floor modules, 5 wall sections, corner, lamp, terminal, Elena) | — | 83,858 | 60,000 | 90,000 |

The wall, Elena and scene total exceed my first proposals; the limits were raised to the measured values rather than hiding it. No performance has been measured, so none is claimed.

## What is real and what is not

- **Real geometry** carries the construction detail (bevels, bolts, louvers, cutouts, pipes, keys, straps, pockets). Textures add wear, grime, edge chipping, scratches and surface relief; they are procedural, not hand-painted.
- **Elena** is a scripted model: a tailored two-layer open coat with folds, knit turtleneck, sleeves with piping cuffs, cargo trousers, rubber boots with soles, head with simple features (no detailed face), hair with ponytail, backpack with straps, tools and an unlit beacon. It follows the concept art's silhouette, proportions, palette and costume, but it **does not reproduce the painted concept**: no sculpted anatomy, no fabric-fold detail, no realistic hair, no facial likeness. Reaching that level needs a character artist or an external base mesh with a recorded license (see `PROVENANCE.md`).
- At gameplay distance Elena is ≈130 px tall at 720p, so silhouette and color blocks dominate; surface detail shows in the `detail_*` inspection views.
- The compatibility renderer has no SSAO, SSR, SDFGI or volumetric fog. Contact darkening is baked (AO in albedo/ORM), the light shaft is a faked additive cone, and glow is the environment's own.

## Rebuilding

```bash
python tools/blender/reference/build_all.py --samples 12
```

Runs floor (both variants), wall (+ corner + lamp), terminal and Elena through Blender 5.2 headless and rewrites GLB, PNG and `.tres`. `.blend` files go to `D:/Projects/evidence/final-thaw/lab-ref-source/` (outside the repo).

## Checks and capture

```bash
godot --headless --path . res://scenes/levels/art_tests/lab_reference_scene.tscn -- --check
godot --path . res://scenes/levels/art_tests/lab_reference_scene.tscn -- --capture --capture-dir=D:/Projects/evidence/final-thaw/lab-reference
```

`--check` verifies: every GLB material has a `.tres` with its textures loaded, per-asset triangle budgets and sizes, the scene total, Elena's height (1.70 m, feet on y = 0), the renderer is unchanged, the camera is `follow_camera.gd`, presentation mode hides the technical references, no level colliders and no gameplay scripts. It cannot judge appearance.

## Acceptance (owner, in Godot)

The criterion is visual: the scene must stop reading as a blockout and communicate a believable climate lab with Elena recognizable and coherent with her concept art. Review the six shots in color and grayscale from the real camera, the `detail_*` inspection views, and walk Elena around (`WASD`).

## Known limitations

- Scripted modelling is not sculpting: forms are clean and somewhat geometric, and procedural wear is plausible but regular compared with hand-painted work.
- Elena's face, hands and cloth are simplified; triangle count exceeds the original 12k proposal (the check uses a 15k budget).
- Texture weight is significant (the 2048² atlases are several MB each); no optimization or compression tuning has been done and no performance claim is made.
- Floor modules repeat (rotated variants and a plain variant mitigate it); only one wall design exists.
