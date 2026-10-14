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
