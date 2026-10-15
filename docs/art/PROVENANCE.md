# Art Provenance and Licenses

Policy: every external resource must be recorded here with source, author, license and where it is used. Review captures and temporary renders never go into the repository (they live under `D:/Projects/evidence/`); production textures do.

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

### Phases 1–2 demo: external assets added on 2026-10-15

Downloaded through the official Poly Haven API (`https://api.polyhaven.com/info/<id>`, `/files/<id>`) by `D:/Projects/external_assets/_tools/dl_ph_parking.py` (kept outside the repository). Author and licence metadata are saved in `D:/Projects/external_assets/polyhaven/models_1k/manifest.json`. Only the four models below were copied into the repository. Fetched but not used: `metal_trash_can`, `security_camera_01`, `plastic_crate_03`, `concrete_road_barrier_02`.

| Files | Source asset | Author | Licence | Change |
|---|---|---|---|---|
| `assets/models/parking/covered_car/` (glTF + 1K textures) | Poly Haven `covered_car` (https://polyhaven.com/a/covered_car) | MP | CC0 1.0 | none (instanced as a multimesh; collision is a separate box) |
| `assets/models/parking/security_light/` | Poly Haven `security_light` | Maximilian Schuster | CC0 1.0 | none |
| `assets/models/parking/utility_box_01/` | Poly Haven `utility_box_01` | James Ray Cock | CC0 1.0 | none |
| `assets/models/parking/rollershutter_door/` | Poly Haven `rollershutter_door` | MP | CC0 1.0 | none |
| `assets/textures/lab_photo/asphalt_033_{diff,nor,arm}.*` | ambientCG `Asphalt033` (https://ambientcg.com/view?id=Asphalt033) | ambientCG | CC0 1.0 | 2K -> 1K; AO and roughness packed into ARM by `tools/art/prepare_parking_textures.py` |

All 3D textures (`lab_photo`, `parking`, `props`) are imported VRAM-compressed with mipmaps (2026-10-15 performance fix).

### Elena v2 (2026-10-15): MakeHuman CC0 head assets and CMU motion capture

**MPFB / MakeHuman licence, verified 2026-10-15.** The MPFB FAQ (static.makehumancommunity.org/mpfb/faq/use_in_closed_source.html) states that "all core assets (the base mesh, targets, skins…) are shared under CC0", usable in closed-source games without attribution; the add-on code is GPL and does not cover its output. This closes the open item on Elena's MPFB base body.

| Files | Source | Licence | Change |
|---|---|---|---|
| `assets/textures/characters/elena/elena_skin_albedo.jpg`, `elena_skin_normal.png` | MakeHuman asset pack "skins01" (`skins01_cc0.zip`, files.makehumancommunity.org, sha256 `7495ab99…96dba9`), skin "onlytheghosts_middle_aged_eurasian_female" | CC0 (pack page: "Natural female skins, shared under CC0") | `tools/art/prepare_elena_textures.py`: slightly warmed; the normal map is derived from the albedo's high frequencies |
| `elena_eyes_albedo.png`, `elena_hair_albedo.png`, `elena_brows_albedo.png`, `elena_lashes_albedo.png` | MakeHuman "system assets" pack (`makehuman_system_assets_cc0.zip`, sha256 `b542127a…028a0107`): eyes "brown", hair "ponytail01", eyebrow001, eyelashes02 | CC0 (each `.mhmat` header: "explicitly released as CC0 in september 2020") | iris hue moved from red-brown to brown; hair, brows and lashes recoloured to the concept's dark brown |
| Eye, eyebrow, eyelash and ponytail meshes inside `assets/models/characters/elena/elena.glb` | same pack (`.mhclo`/`.obj`), fitted and rigged by MPFB 2.0.18 | CC0 | `tools/blender/elena_mpfb/build_elena_v2.py`; the ponytail is shortened to clear the backpack |
| Locomotion and reaction clips inside `elena.glb` (idle, walk, run, sprint, crouch_idle, crouch_walk, jump, fall, land, start, stop, turn_left, turn_right, alert) | CMU Graphics Lab Motion Capture Database, http://mocap.cs.cmu.edu, ASF/AMC trials 35_01, 35_22, 77_02, 77_09, 127_21, 143_01, 143_02, 143_03, 69_16, 69_18 (table: `assets/models/characters/elena/elena_clips.json`) | mocap.cs.cmu.edu/faqs.php: "The motion capture data may be copied, modified, or redistributed without permission." Requested acknowledgement (in the credits): "The data used in this project was obtained from mocap.cs.cmu.edu. The database was created with funding from NSF EIA-0196217." | retargeted by `tools/blender/elena_mpfb/mocap_cmu.py` (world-space delta transfer, A/T-pose alignment, leg-length height scaling, foot grounding and pinning, loop cutting); the crouched clips layer a crouch with leg IK on 35_01 and 77_02 |

The raw packs and the AMC files stay outside the repository (`D:/Projects/external_assets/makehuman`, `D:/Projects/external_assets/cmu_mocap`, with `SOURCE.txt`); only the processed textures and the exported GLB are shipped.

### Generated by scripts in this repository (no external source)

| Asset | Script | Notes |
|---|---|---|
| `assets/models/characters/recovery_unit.glb` | `tools/blender/build_recovery_unit.py` (Blender 5.2, headless) | Spec in the script header; flat PBR materials; no textures |
| `assets/models/lab_ref/ref_elena_mpfb.glb` animations | `tools/blender/elena_mpfb/animate_elena.py` | crouch_walk re-authored 2026-10-15 (longer stride) |
| `assets/audio/music/*.wav` | `tools/audio/render_music.gd` + `scripts/audio/game_synth.gd` | Deterministic synthesis; placeholders, not auditioned by ear |
| Runtime sound effects | `scripts/audio/sfx_synth.gd`, `scripts/audio/game_synth.gd` | Deterministic synthesis at load time |

## Adding an external resource

Before any external model, texture, add-on or font enters the project, add a row here with: name, URL, author, license (with link), date obtained, files affected and the change made. Anything without a compatible license is not used.
