# FINAL THAW — Asset Production Bible

## Purpose

This document is the single visual and technical contract for all FINAL THAW assets. It defines the look, materials, naming, scale, performance budgets and acceptance criteria required before an asset can be considered production-ready.

It complements, and does not replace:

- `GDD.md`
- `docs/art/LAB_STYLE_SPEC.md`
- `docs/art/ELENA_BLOCKOUT_SPEC.md`
- `docs/art/MARCUS_MPFB_SPEC.md`
- `docs/TECHNICAL_DESIGN.md`
- `docs/QUALITY_GATES.md`

## Visual direction

FINAL THAW combines a restrained climate-thriller atmosphere with expressive, readable game art.

- Inspiration: *Gris*, *Ori*, *Blade Runner 2049*.
- Mood: cold survival, institutional control, fragile hope.
- Shapes: clean silhouettes, functional industrial geometry, restrained ornamentation.
- Lighting: strong directional key light, controlled rim light, atmospheric fog and emissive technology.
- Detail: detail is concentrated at interaction points and narrative focal points.

## Color language

| Subject | Palette | Meaning |
|---|---|---|
| Elena Vast | Cool blues, cyans, clinical whites | Science, isolation, hope through knowledge |
| Marcus Reyes | Warm oranges, reds, earth tones | Action, humanity, protection through strength |
| Helix / Voss | Purple, gold, sterile white | Authority, control, corrupted idealism |
| Civilian spaces | Desaturated greys, muted blues, emergency amber | Survival and vulnerability |
| Hazard / failure | Red-orange, alarm amber | Danger, oxygen loss, system failure |
| Hope / resolution | Cyan, pale gold, clean white | Recovery, cooperation, clarity |

## Material rules

- Use physically based materials: albedo/base color, roughness, metallic where appropriate, normal and ambient occlusion.
- Avoid pure black and pure white albedo values.
- Metal surfaces should show believable wear, fingerprints, scratches or oxidation only where narratively justified.
- Fabric should use high roughness and subtle normal variation.
- Glass, screens and holograms use emissive maps rather than baked lighting.
- Water uses a dedicated shader with transparency, refraction or screen-space reflection where performance allows.

## Character standards

### Elena Vast

- Primary palette: cool blue, cyan and clinical white.
- Silhouette: practical scientist/explorer; recognizable through hood, jacket shape and Aster device.
- Materials: technical fabric, reinforced panels, matte plastic, limited metal accents.
- Expression: restrained, observant, determined.

### Marcus Reyes

- Primary palette: warm orange, red and earth tones.
- Silhouette: broader protective shape; recognizable through jacket volume and practical gear.
- Materials: worn fabric, leather-like accents, matte metal and rubber.
- Expression: guarded, protective, physically grounded.

### Dr. Selene Voss

- Primary palette: purple, gold and sterile white.
- Silhouette: controlled, architectural, authoritative.
- Materials: clean technical fabric, polished accents, Helix insignia.
- Expression: composed, convinced, tragic rather than cartoonishly villainous.

### Civilians and NPCs

- Use modular clothing and color variants.
- Maintain readable silhouettes at gameplay camera distance.
- Avoid unique high-cost assets for background characters.

## Environment standards

### Flooded Shelter

- Mood: claustrophobic, wet, damaged but still inhabited.
- Palette: cold concrete, oxidized metal, stagnant water, emergency amber.
- Key props: generator, valve wheels, pipes, rescue station, exit door, beds, crates and debris.
- Water must read clearly against floors and walls.
- Emergency lighting must guide the player through POWER, VALVES, CIVILIAN and EXIT.

### Helix laboratory

- Mood: sterile, controlled, oppressive.
- Palette: white panels, purple emissive technology, gold accents.
- Geometry: modular walls, floors, ceilings, terminals, containment units and technical props.
- Avoid organic decay except where the narrative requires contrast.

## Phases 1–2 demo: Helix Station B art direction (v2, 2026-10-15)

This section governs every asset of the playable demo (`scenes/prototypes/phase1_canonical_greybox.tscn`). It replaces the older "Helix laboratory" notes above for this location. Reference for people: `assets/concept/characters/elena_vast_concept.png`.

### The place

**Estación de Bombeo B** is a municipal storm-water pumping station from the 1920s: load-bearing brick, riveted steel, cast-iron pipework, an overhead travelling crane over the pump hall, a drainage pit and culverts. Helix leased it in the 2040s and inserted the **Aster** trial into the old pump hall: a clean, cable-fed, white-and-copper apparatus in a dirty historic shell. The two languages never blur:

| Layer | Materials | Where |
|---|---|---|
| **Historic station** (most of the space) | aged red-brown brick (`brick_wall_02`), white glazed tile dado to 1.4 m (`long_white_tiles`), green-painted riveted steel and machinery (`green_metal_rust`), cast-iron pipes painted by function, worn painted concrete floors (`painted_concrete`, `concrete_floor_damaged_01`), rusty tread plate (`metal_grate_rusty`), corrugated roof (`corrugated_iron_02`) | nave, pit, pump gallery, culverts, exterior |
| **Helix insert** (only where Helix built) | off-white composite panels, anodised aluminium extrusions, black rubber gaskets, cable trays with grey cable, copper bus bars, small glass instrument windows | Aster column and its gantry, control room E, archive F, airlock G, lift |
| **Neglect** (narrative, not decoration) | tide marks from the March flood (`NIVEL MÁX. 14/03`), mineral bloom on low brick, rust runs under fixings, standing water in the pit | below 1 m in P−1 and P0; never on the Helix insert, which is recent and maintained |

Believable before spectacular: every prop has a job (pumping, power, measurement, maintenance, storage).

### Palette

- **Base:** brick `#6E3B2C`→`#8C4E3A`, tile off-white `#C9C4B5` (never pure white), station green `#3F5A4A`, concrete `#7A7670`, steel graphite `#33373A`, Helix panel `#C8CBC6`.
- **Pipe colours by function** (readable, real-world convention): water `#3E5E4A` green, drainage `#2F3133` black-grey, fire main `#7A2018` red, compressed air `#6F8FA3` pale blue, power conduit `#9A8A5A` ochre.
- **Accents, reserved:** amber `#F2B340` = something Elena can use; cyan `#7FF0E6` = Elena's scanner and inference only; red `#E04A3A` = danger, alarms, the recovery unit's alert; green `#58C77A` = safe egress signs only; **Aster** = copper `#B87333` conductors plus a pale violet-white calibration light `#C9C2FF` and the eight-point star mark (`✳`) stencilled on its hardware. No other emissive hues.

### Materials and roughness

| Material | Roughness | Notes |
|---|---|---|
| Brick | 0.85–0.95 | mortar darker and rougher; damp band darker and 0.6 rough |
| Glazed tile | 0.25–0.4 | crazed, grimy joints; chips show 0.9 biscuit |
| Painted steel | 0.5–0.7 | edge wear to bare metal (metallic 0.8, 0.35 rough) |
| Bare/galvanised steel | 0.3–0.45 metallic | rails, Helix fixings |
| Concrete floor | 0.7–0.9 | wet patches 0.15 |
| Helix panel | 0.4–0.5 | clean, low variation |
| Rubber, cable | 0.75–0.9 | |
| Glass, screens | 0.05–0.15 | screens emissive, low energy |

Uniform roughness across a surface is a defect. World-space shading (tide line, damp band, grime toward floors, streaks under fixings) is done in the facility shaders so splits and reuse never show seams.

### Lighting

Night, emergency and maintenance power only: **low ambient, pools of motivated light, strong shapes.** Each room has one dominant source and one accent:

| Room | Key | Accent |
|---|---|---|
| Culvert and breach | cold moonlight through the breach | a dying amber bulkhead lamp inside |
| Access A | caged bulkhead lamp, warm | moonlight from the nave |
| Nave B (pump hall) | high clerestory moonlight shafts, cold | Aster column's violet-white rings; amber work lamp on the crane |
| Pit P−1 | sodium work lamps, orange | water reflections; red tide-mark |
| Pump gallery M | caged fluorescent battens, some dead | green pump status lamps |
| Control E | monitor glow, cool | one warm desk lamp |
| Archive F | red standby lamps | the console screen |
| Yard | sodium floodlights | city glow on the low cloud |

Light colours: moon `#9DB4D9`, fluorescent `#D8E6F0`, sodium `#FFB766`, bulkhead `#FFD7A0`, emergency red `#FF4A3A`. Fixtures are always modelled (no light without a visible source in hero views). Fog: depth fog only, interior `#141A20` thin, exterior `#1B2430` denser with height falloff for atmospheric perspective.

### Decals, signage and wear

- Signage is diegetic Spanish (the station is in a Spanish city): stencilled room codes (`B · NAVE DE BOMBEO`), pipe flow arrows, enamel safety plates, Helix labels in a clean sans on the insert only. Every sign has a reason to exist.
- Wear follows causes: grime gathers low and in corners, rust runs down from fixings, scuffs at hand height near doors and controls, clean paths on floors where people walked.
- No random graffiti inside (a guarded site); the outside yard wall may carry some.

### Scale and density

1 unit = 1 m. Doors 2.1 m (historic doors 2.6 m arched), corridors ≥ 1.8 m, stair rise 0.18 m, rail 1.1 m. Prop density: hero rooms dense along walls and around the landmark, with clear walking lanes ≥ 1.5 m; transit spaces sparse. Every room keeps a readable floor plan from the gameplay camera.

### Budgets (Intel HD 630 at 720p, "Performance" preset 16.7 ms)

- Visible triangles ≤ 350k; draw calls ≤ 350 per view (static geometry is batched per material per 12 m cell per storey; flat-colour materials share one vertex-colour palette batch per cell).
- Real lights: ≤ 6 affecting any one batch; no dynamic shadows except the moon and the yard floodlight key.
- Textures: every 3D texture is VRAM-compressed (S3TC/BPTC) with mipmaps. Normal maps use RGTC (two channels; shaders rebuild Z). Uncompressed textures are a defect. Sizes: tiling materials 1K, hero props 1K, small props 512, Elena 2K atlas and 2K skin.
- CC0 props are decimated to the standard-prop budget (≤ 2k tris) unless they are hero props (≤ 10k).
- The budget is measured on the driver the player gets. On the reference GPU, Godot forces ANGLE (Direct3D 11), which costs about 3× native OpenGL for this scene. See `PROJECT_STATUS.md`, "Performance".

### Illustrated style (v3, 2026-10-15)

The owner locked the look on 2026-10-15: an **illustrated 3D adventure**. Painted surfaces, controlled ink lines, a disciplined palette and cinematic light pools; never photographic. It refines the Helix Station B direction above (same place, palette and lighting plan) and governs every new asset.

**References.** There are two:
- the approved Marcus concept, for rendering: painted planes, strong silhouettes, ink only where form turns;
- an illustrated laboratory interior the owner showed in conversation, for mood: warm practical pools, cool shadow, readable clutter along walls.

The owner's lab illustration is a **mood reference only**. It is not in the repository; never copy it, trace it or reproduce its composition.

| Pillar | Rule | Implementation |
|---|---|---|
| **Painted albedo** | Surfaces read as brushwork: flat patches of colour, no photographic noise, value kept in the mid range. Photo-sourced CC0 textures are allowed only after the painted treatment. | `tools/art/stylize_textures.py` writes `<name>_paint.<ext>` next to each source: an oil-paint filter, plus tinted ink taken from OpenCV stylization. Materials pick the `_paint` file when it exists (`FacilityMaterials._painted`). |
| **Half-tone light** | Two soft steps (core shadow, lit plane) instead of a smooth Lambert falloff. Shadows keep the cool ambient colour; lights keep their warm colour. | `assets/shaders/illustrated_light.gdshaderinc` (station, wall and floor shaders); `FacilityMaterials.illustrate()` (toon diffuse) for standard materials. |
| **Diffuse-only environment** | Highlights are painted, not computed. Specular stays only on characters (skin, eyes, hair, Elena's wrist unit) and glass. Standing water reads as a cool sheen that grows at grazing angles. | `render_mode specular_disabled` in the include; `SPECULAR_DISABLED` in `illustrate()`; `puddle_sheen` in `facility_floor.gdshader`. Saves 2–3 ms at 720p on the reference GPU. |
| **Ink line** | One full-screen line from depth discontinuities: dark warm ink, never pure black. Lines fade between 32 and 70 m, so distance stays soft. | `assets/shaders/ink_outline.gdshader` (strength 0.8, 1 px). The scene's `InkOutline` quad is hidden on the "Performance" preset. |
| **Disciplined palette** | Mid-tone, slightly saturated base. The reserved accents are unchanged (amber, cyan, red, green, Aster copper/violet). Large areas stay in the brick, green and concrete families. | Environment adjustments (contrast 1.06, saturation 1.12); safety paint is red oxide, not signal red. |
| **Cinematic light** | Generous warm pools on cool ambient. Every pool has a visible fixture. The moon is the key outdoors and through clerestories. | `Phase1Builder.LIGHT_GAIN` (1.6) scales authored energies; Moon directional light energy 0.85 with shadows (off on "Performance"). |

**Characters.** They use the same painted treatment: Elena's skin and outfit `_paint` albedos, plus her MakeHuman-based model (`docs/art/PROVENANCE.md`). Her silhouette must read at the gameplay camera's 5 m arm. Her Aster scanner is a **wrist unit on the left forearm**, never a hand-held object; its screen faces her when she raises the forearm to scan.

**Not allowed:**
- unpainted photo textures on new environment assets;
- specular highlights on environment materials;
- black outlines baked into geometry;
- emissive colours outside the reserved accents;
- copying, tracing or committing the reference images.

**Review:** every illustrated asset is judged in Godot from the gameplay camera and one cinematic angle, under the "Balanced" and "Performance" presets. Review captures live outside the repository (`D:/Projects/evidence/`).

### Camera and composition

The gameplay camera (5 m arm, pitch ≈ −30°) must read the floor plan: tall stuff goes to walls and corners; the centre of rooms stays clear. Landmarks (the Aster column, the crane, the pit's pumps, the yard gate) are visible from several rooms. Cinematic shots use 35–55 mm equivalents, low angles in the hall, and always show a light source in frame.

### UI relationship

The HUD stays minimal and graphic (thin rules, small caps); world text carries information first. UI accents reuse the reserved hues: amber for interaction prompts, cyan for inference banners, red for danger.

## Technical standards

### Units and orientation

- Engine: Godot 4.x.
- Scale: 1 unit = 1 meter.
- Characters: approximately 1.70–1.85 meters tall unless the design specifies otherwise.
- Forward axis: -Z.
- Up axis: +Y.
- Pivots: characters at feet; props at logical interaction or placement point.

### Mesh rules

- No non-manifold geometry, flipped normals, interior faces or unused vertices.
- Hard-surface props should use clean edge flow and support loops where needed.
- Character meshes must be animation-ready before final approval.
- Every exported asset must include collision where gameplay requires it.

### Texture budgets

| Asset class | Maximum texture resolution |
|---|---|
| Main character | 2048–4096 px |
| Important NPC | 1024–2048 px |
| Hero prop | 1024–2048 px |
| Standard prop | 512–1024 px |
| Tiling material | 512–1024 px |
| Background environment module | 1024–2048 px per atlas |

### Polygon budgets

| Asset class | Target polygon budget |
|---|---|
| Main character LOD0 | 30,000–70,000 triangles |
| Main character LOD1 | 10,000–25,000 triangles |
| Main character LOD2 | 3,000–8,000 triangles |
| Hero prop | 2,000–10,000 triangles |
| Standard prop | 300–2,000 triangles |
| Environment module | Determined per level performance budget |

## Naming convention

Use lowercase snake case.

```text
assettype_subject_variant_purpose
```

Examples:

```text
char_elena_vast_base_lod0.glb
char_marcus_reyes_base_lod0.glb
prop_shelter_generator_a.glb
prop_shelter_valve_wheel_a.glb
env_shelter_wall_module_a.glb
fx_water_drip_small.tscn
ui_hud_oxygen_meter.png
mat_shelter_concrete_wet.tres
```

## Folder structure

```text
assets/
  concept/
    characters/
    environments/
    props/
  models/
    characters/
    environments/
    props/
  textures/
    characters/
    environments/
    props/
  materials/
    characters/
    environments/
    props/
```

## Production workflow

1. Define the asset in `MASTER_ASSET_LIST.md`.
2. Create or approve concept/reference imagery.
3. Create a blockout or AI-generated base where appropriate.
4. Produce final geometry, UVs and materials.
5. Validate scale, pivot, collision, naming and performance.
6. Import into Godot.
7. Validate in the target scene.
8. Record evidence before marking the asset complete.

## Acceptance criteria

An asset is production-ready only when all of the following are true:

- It matches the approved visual direction.
- It uses the correct scale, orientation and pivot.
- It passes mesh and texture validation.
- It has the required LODs and collision.
- It imports correctly into Godot.
- It performs within the relevant budget.
- It has been reviewed in the actual gameplay scene.
- Its provenance and license are recorded.

## Provenance

Every generated or externally sourced asset must record:

- Source tool or artist.
- Generation date.
- Prompt or reference files where applicable.
- License and commercial-use status.
- Human edits performed.
- Final Godot validation result.
