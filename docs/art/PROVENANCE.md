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

## Adding an external resource

Before any external model, texture, add-on or font enters the project, add a row here with: name, URL, author, license (with link), date obtained, files affected and the change made. Anything without a compatible license is not used.
