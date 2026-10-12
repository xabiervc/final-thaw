# Lab Style Spec — Abandoned Laboratory (3D)

**Status:** transcribed from the values validated in `scripts/levels/art_tests/lab_palette_test.gd` (Godot 4.7.2). Sections marked **[proposed]** are new and need owner approval. Nothing here is marked final, optimized or integrated.

**Scope:** Phase 2, rooms 1 and 2 of the abandoned laboratory. Concept references: `assets/concept/characters/` (Elena). This document is the contract for `tools/blender/build_lab_corner_assets.py` and the scene `scenes/levels/art_tests/lab_corner_art_test_assets.tscn`.

## 1. Visual direction

- Cold, desaturated, institutional lab, abandoned recently (not ruined). Light is the main storytelling tool.
- Amber (`#F2B340`) is reserved for interactables and terminal screens. Cyan (`#7FF0E6`) is reserved for Elena and scanning. No other emissive hues.
- Readability from the gameplay camera and in grayscale comes before surface detail. Values must separate floor, wall, props and Elena.

## 2. Palette and materials

All materials are flat PBR (no textures), metallic 0. Names are stable and shared by Godot and Blender.

| Material | sRGB | Roughness | Emission | Use |
|---|---|---|---|---|
| `lab_mat_floor_epoxy` | `#6B7377` | 0.65 | — | floor tile |
| `lab_mat_floor_joint` | `#4A5155` | 0.90 | — | floor joint |
| `lab_mat_wall_panel` | `#9AA2A5` | 0.80 | — | wall panels, corner post |
| `lab_mat_trim_metal` | `#3B4347` | 0.50 | — | baseboard, rail, seams, trim |
| `lab_mat_painted_metal` | `#56656C` | 0.70 | — | terminal and container bodies |
| `lab_mat_rubber` | `#1E2124` | 0.90 | — | handles, terminal plinth |
| `lab_mat_screen_emissive` | `#F2B340` | 0.40 | 2.0 | terminal screen |
| `lab_mat_light_emissive` | `#DDE8F0` | 0.40 | 2.5 | wall light tube |

Test-only values, **not** part of the asset set: `lab_mat_wall_stain` `#858D90` (wear readability test).

Blender writes base colors in linear space; the glTF exporter normalizes emissive color and compensates with strength, so Godot shows e.g. energy 1.78 instead of 2.0 for the screen. Effective radiance is identical (checked by `--check`).

## 3. Lighting and environment (from the palette test)

- Environment: solid background `(0.02, 0.03, 0.05)`, ambient color `(0.35, 0.42, 0.50)` energy 0.5, Filmic tonemap, fog `(0.10, 0.14, 0.18)` density 0.01.
- Key light: `OmniLight3D` at `(0, 2.2, -1.55)`, color `#DDE8F0`, energy 1.6, range 6, only shadow caster.
- Terminal accent: amber `(0.95, 0.70, 0.25)`, energy 0.6, range 3, at terminal + `(0, 1.3, 0.8)`.
- Lights live in the scene, never inside GLB files.

## 4. Camera and scale

- Existing `scripts/components/follow_camera.gd` (FOV 40, offset `(0, 8.5, 6.5)`). It is not modified.
- 1 unit = 1 m, +Y up, front of props = +Z. Elena reference ≈ 1.7 m.
- Room corner: floor 6 × 4 m, walls 3.2 m high and 0.5 m thick, floor top at y = 0.
- Module grid: floor 2 × 2 m (1.96 m tile + 2 cm joint, joint 2 cm below the tile top), walls 2 m wide. Baseboard 0.3 m, rail at y = 1.0 m, vertical seams every 2 m.

## 5. Asset conventions

- Format: GLB, one file per asset in `assets/models/lab/`, named `lab_<thing>_<size?>_<variant>`; first variant is `_a`.
- Pivots: floor = module center at the tile top; wall = base center on the interior face (interior normal +Z, body toward −Z); corner = interior corner vertex at floor level (body toward −X, −Z); terminal and container = base center; wall light = housing center (back face on the wall).
- Materials embedded in the GLB with the names above. No textures: texture import/compression settings are untouched.
- Collision is not exported; it is added in Godot as `StaticBody3D`, layer 1, mask 0, `BoxShape3D` (same pattern as `build_util.gd` and `abandoned_lab.gd`).
- Blender sources (`.blend`) are not versioned. The reproducible source is `tools/blender/build_lab_corner_assets.py`.

## 6. Batch 1 catalogue

| Asset | Size (m, x·y·z) | Pivot | Triangles | Materials |
|---|---|---|---|---|
| `lab_floor_2x2_a` | 2.00 · 0.10 · 2.00 | center, tile top | 56 | floor_epoxy, floor_joint |
| `lab_wall_2m_a` | 2.00 · 3.20 · 0.53 | base, interior face | 60 | wall_panel, trim_metal |
| `lab_wall_corner_a` | 0.56 · 3.20 · 0.56 | interior corner | 36 | wall_panel, trim_metal |
| `lab_terminal_a` | 1.04 · 1.46 · 0.74 | base center | 148 | painted_metal, rubber, trim_metal, screen_emissive |
| `lab_container_a` | 1.24 · 1.00 · 0.88 | base center | 152 | painted_metal, trim_metal, rubber |
| `lab_wall_light_a` | 0.80 · 0.20 · 0.26 | housing center | 56 | trim_metal, light_emissive |

Colliders in the test scene: floor 6 × 0.5 × 4 (top at y = 0), back wall 6.5 × 3.2 × 0.5, left wall 0.5 × 3.2 × 4, terminal 1.0 × 1.5 × 0.7, container 1.24 × 1.0 × 0.84. The wall light has none (mounted at 2.4 m).

## 7. Budgets and limits [proposed]

- Props ≤ 500 triangles, modules ≤ 200, single draw call per material per asset. Batch 1 stays well inside this; whole test scene ≈ 1,030 triangles.
- No asset carries baked lights, cameras or animations in this batch.

## 8. Open items

- The amber backpack pilot light of Elena is omitted in the reference on purpose (amber is reserved); this stays a pending review decision.
- Wear levels (the palette test refers to level 2/5 for a stain) are not formally defined yet; see `docs/art/LAB_NEXT_BATCH.md`.

## 9. Validation status

- Palette and light test: captured with Godot 4.7.2.stable.official.ed1daf0bf (`--capture`, 8 PNG, 1280 × 720); visual validation reported by the project owner.
- Batch 1: generated, imported and checked automatically (`--check`: dimensions, pivots, materials, collisions). **Pending:** visual review in Godot by the project owner, camera-framing review and performance profiling. Not marked final, optimized or integrated.
