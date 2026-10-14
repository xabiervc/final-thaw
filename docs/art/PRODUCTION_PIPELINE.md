# FINAL THAW — Asset Production Pipeline

## Objective

Define the repeatable path from design requirement to Godot-validated production asset. This pipeline applies to characters, props, environment modules, VFX, UI and audio-supported assets.

## Roles

| Role | Responsibility |
|---|---|
| Perplexity | Design specs, asset lists, concept prompts, Godot code, tests, documentation and integration plans |
| Claude / Blender MCP | Blender modeling, retopology, UVs, baking, rigging, animation, export and local asset processing |
| External tools | AI 3D generation, texturing, music, voice and specialized VFX where appropriate |
| Human reviewer | Final visual approval, playtesting, performance validation and merge approval |

## Asset lifecycle

```text
Requirement
  -> Asset ID created in MASTER_ASSET_LIST.md
  -> Concept/reference
  -> Blockout or AI-generated base
  -> Final mesh and materials
  -> Technical validation
  -> Godot import
  -> Scene validation
  -> Provenance record
  -> Done
```

## Stage 1 — Requirement

Every asset must have:

- A unique ID.
- A priority.
- A gameplay or narrative purpose.
- A target scene.
- Technical constraints.
- Acceptance criteria.

No asset should enter production without an entry in `MASTER_ASSET_LIST.md`.

## Stage 2 — Concept and reference

For each asset, produce:

- At least one clear concept image.
- A silhouette check.
- A palette check against `ASSET_PRODUCTION_BIBLE.md`.
- For characters: front, side, back and three-quarter references.
- For props: at least one primary view plus detail references where needed.
- For environments: a top-down layout and one or more camera-reference renders.

## Stage 3 — Blockout

Create a low-detail version to validate:

- Scale in meters.
- Player readability.
- Collision shape.
- Placement in the Godot scene.
- Camera framing.
- Interaction affordance.

Blockouts must be tested in Godot before final art production begins.

## Stage 4 — Final asset

### Characters

1. Build or refine base mesh.
2. Create animation-ready topology.
3. Unwrap UVs.
4. Bake and author PBR textures.
5. Create rig.
6. Assign skin weights.
7. Create required animation set.
8. Export GLB or FBX according to the Godot import requirement.
9. Validate in Godot.

### Props

1. Create final high- or medium-poly mesh.
2. Create game-resolution mesh.
3. Unwrap UVs.
4. Bake normal and ambient occlusion where useful.
5. Author PBR materials.
6. Add collision.
7. Export GLB.
8. Validate interaction, scale and readability in Godot.

### Environment modules

1. Create modular grid-compatible geometry.
2. Ensure consistent floor height and wall thickness.
3. Create tiling materials or atlas textures.
4. Add collision.
5. Validate seams, lighting and navigation.
6. Export and assemble in Godot.

## Stage 5 — Godot validation

Every asset must be checked for:

- Correct scale: 1 unit = 1 meter.
- Correct orientation: +Y up, -Z forward.
- Correct pivot.
- Correct collision.
- Correct material import.
- Correct animation import, if applicable.
- No missing textures.
- No unexpected transform values.
- Performance within budget.
- Visual readability in the actual scene.

## Stage 6 — Provenance

Create or update `assets/<asset_type>/<asset_id>/PROVENANCE.md` with:

```markdown
# Asset provenance — <ASSET_ID>

- Asset: <name>
- Source: <tool, artist or workflow>
- Date: <YYYY-MM-DD>
- Reference files: <paths>
- Prompt: <prompt or link>
- License: <license/commercial status>
- Human edits: <list>
- Godot validation: <pass/fail and notes>
```

## Commit discipline

Use one focused commit per coherent production unit:

```text
docs(art): add asset production bible
docs(art): add prioritized master asset list
docs(art): add flooded shelter environment module specs
art(env): add flooded shelter blockout modules
art(prop): add shelter generator and valve props
art(char): add Elena reference pack
art(char): add Elena base mesh and materials
feat(godot): integrate shelter environment modules
```

## Quality gates

An asset cannot be marked `FINAL` or `GODOT` without:

- A visual review.
- A technical review.
- A Godot scene review.
- A performance check where relevant.
- A provenance record.

## First production batch

The first batch is intentionally narrow:

1. Shelter wall, floor, ceiling and doorway modules.
2. Generator, valve wheel, pipe assembly, rescue station and exit door.
3. Water volume and basic emergency lighting.
4. Elena reference pack.

This batch validates the complete pipeline before scaling production to the full game.
