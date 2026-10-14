# Art Provenance and Licenses

Policy: every external resource must be recorded here with source, author, license and where it is used. **No external resource is used so far.** Review captures and temporary renders never go into the repository (they live under `D:/Projects/evidence/`); production textures do.

## Tools

| Tool | Version | Role | License of the tool |
|---|---|---|---|
| Blender | 5.2.2 LTS (headless, Python scripts) | modelling, UV, Cycles baking | GPL; output files (meshes, textures) are not covered by the tool's license |
| Godot | 4.7.2.stable.official.ed1daf0bf | import, materials, validation | MIT |
| Claude (model `claude-sonnet-5-5`, via Claude Code) | — | wrote the scripts that generate every asset below | — |

Blender MCP was not available in the environment where these assets were produced; all Blender work is done by the reproducible scripts in `tools/blender/` (`tools/blender/reference/` for the reference scene). `.blend` files are kept outside the repository.

## Authoring tools installed for the studio (none of their files are part of a game build)

| Tool | Version | Source | License | Role |
|---|---|---|---|---|
| Blender MCP add-on (`mcp`) | 1.0.3 | `projects.blender.org/lab/blender_mcp` (Blender Lab), SHA-256 `a7a9da81…43040707`, local TCP server on `localhost:9876`, auto-start off | GPL-3.0-or-later | lets Claude drive an open Blender session |
| MPFB (add-on) | 2.0.18 | extensions.blender.org (hash verified by Blender) | GPL-3.0-or-later for the code; base-human assets are advertised as CC0 (verify per pack before shipping anything derived from them) | human base meshes for characters |
| Material Maker | 1.7 | winget (`RodZill4.MaterialMaker`, upstream GitHub) | MIT | procedural PBR texture editor |
| Krita | 5.3.4.1 | winget (`KDE.Krita`, download.kde.org) | GPL-3.0 | painting and texture touch-up |
| Audacity | 4.0.1 | winget (`Audacity.Audacity`, upstream GitHub release) | GPL-3.0-or-later | audio editing |
| Pillow | 12.3.0 | PyPI | HPND | image inspection in scripts |

## Assets created from scratch (no external source)

| Asset(s) | Origin | External resources | Notes |
|---|---|---|---|
| `assets/models/lab/lab_*_a.glb`, `lab_*_b.glb` (batches 1–2) and `assets/models/characters/elena_blockout_a.glb` | scripts in `tools/blender/` | none | **Blockouts and technical references.** Flat colors, no textures. Not the artistic standard (owner decision). |
| `assets/models/lab_ref/ref_*.glb` | scripts in `tools/blender/reference/` | none | Reference-scene geometry. Modelled procedurally; Elena follows the proportions and costume language of `assets/concept/characters/elena_vast_concept.png` (design reference, not reproduced). |
| `assets/textures/lab_ref/ref_*_albedo.png`, `_normal.png`, `_orm.png` | baked in Cycles from procedural node materials (noise, bevel/edge wear, ambient occlusion, directional scratches) | none | ORM = AO (R), roughness (G), metallic (B). Normal maps are tangent space, OpenGL (+Y). |
| `assets/textures/lab_ref/ref_terminal_screen_emission.png`, `ref_elena_aster_emission.png` | drawn with numpy in the scripts (rectangles, lines, a sine wave) | none | Synthetic interface graphics; no readable text, so nothing to localize. |
| `assets/materials/lab_ref/*.tres` | written by the scripts | none | Godot `StandardMaterial3D` resources that reference the textures above. |

## Concept art

`assets/concept/characters/elena_vast_concept.png` and `marcus_reyes_concept.png` are project design references supplied by the project owner. They are used as visual guidance only; no pixel of them is reused in any texture or model.

## External asset library (downloaded 2026-10-14, NOT yet in the repository)

Stored outside the repo in `D:/Projects/external_assets/` (download scripts in `_tools/`, listing in `polyhaven/manifest.json`). Only files that are actually used get copied into the repo, each with its own row here. The ambientCG zips also contained `.blend`/`.usdc` files that were extracted but never opened.

| Source | URL | Author / license | Obtained | Content |
|---|---|---|---|---|
| Poly Haven textures | https://polyhaven.com (API https://api.polyhaven.com) | Poly Haven contributors, CC0 1.0 | 2026-10-14 | 20 materials at 2K (diffuse JPG, GL normal PNG, ARM JPG): concrete, metal plate, corrugated/rusty iron, plaster, tiles, rubber, leather. ~419 MB |
| Poly Haven models | https://polyhaven.com | CC0 1.0 | 2026-10-14 | 14 glTF 2K props (barrels, cart, hand truck, lamps, cabinet, shelf, desk, chair, A/C unit, hydrant, circuit board). ~120 MB with the HDRIs |
| Poly Haven HDRIs | https://polyhaven.com | CC0 1.0 | 2026-10-14 | `abandoned_workshop`, `abandoned_factory_canteen_01` (2K .hdr) for look-dev reflections |
| ambientCG materials | https://ambientcg.com (API v2) | ambientCG, CC0 1.0 | 2026-10-14 | Concrete034, Metal063, Tiles141, Rubber004, Leather037, Fabric085, Asphalt033 (2K-JPG). ~158 MB |
| Kenney Space Kit, Furniture Kit | https://kenney.nl/assets/space-kit, https://kenney.nl/assets/furniture-kit | Kenney, CC0 (stated on each asset page) | 2026-10-14 | Low-poly kits, ~12 MB zipped; stylised, probably only useful as proxies |

### Textures from the external library now used in the repository

| Files | Source asset | License | Change |
|---|---|---|---|
| `assets/textures/lab_photo/concrete_floor_worn_001_{diff,nor,arm}.*` | Poly Haven `concrete_floor_worn_001` | CC0 1.0 | resized 2K -> 1K by `tools/art/prepare_photo_textures.py` (JPG q88 / PNG) |
| `assets/textures/lab_photo/painted_plaster_wall_{diff,nor,arm}.*` | Poly Haven `painted_plaster_wall` | CC0 1.0 | same |
| `assets/textures/lab_photo/concrete_panels_{diff,nor,arm}.*` | Poly Haven `concrete_panels` | CC0 1.0 | same |
| `assets/textures/lab_photo/metal_plate_02_{diff,nor,arm}.*` | Poly Haven `metal_plate_02` | CC0 1.0 | same |

Used by `scripts/levels/lab_art_dressing.gd` (world-space triplanar, tinted cool). ARM = AO (R), roughness (G), metallic (B).

| `assets/models/props/barrel_03/` (glTF + 2K textures, unmodified) | Poly Haven model `barrel_03` | CC0 1.0 | used for the barrel inspect point by `scripts/levels/lab_art_components.gd` (scaled to the greybox footprint) |

Quaternius packs were not downloaded (hosted behind Google Drive/itch, no stable official direct link).

## Adding an external resource

Before any external model, texture, add-on or font enters the project, add a row here with: name, URL, author, license (with link), date obtained, files affected and the change made. Anything without a compatible license is not used.
