# Claude Handoff — Binary Asset Production Tasks

## Purpose

This document lists work that requires local execution with Blender, Godot, image/3D generation tools or manual playtesting. Specifications are already in the repository; each task below should be completed as one focused commit with evidence.

## Required reading

1. `docs/art/ASSET_PRODUCTION_BIBLE.md`
2. `docs/art/MASTER_ASSET_LIST.md`
3. `docs/art/PRODUCTION_PIPELINE.md`
4. `docs/art/FLOODED_SHELTER_BATCH1_SPEC.md`
5. `docs/art/ELENA_3D_REFERENCE_PACK_SPEC.md`
6. `docs/art/FLOODED_SHELTER_PRESENTATION_SPEC.md`
7. `docs/art/CONCEPT_PROMPT_PACK.md`
8. Existing: `docs/art/LAB_STYLE_SPEC.md`, `docs/art/ELENA_BLOCKOUT_SPEC.md`, `docs/art/MARCUS_MPFB_SPEC.md`, `docs/art/PROVENANCE.md`

## Rules

- Do not mark any asset verified without Godot import and scene evidence.
- Record provenance for every asset.
- One focused commit per task.
- Update `MASTER_ASSET_LIST.md` status only after validation.
- Do not merge into `main` without human review.

## Task list

### Batch 1 — Flooded Shelter

| # | Task | Output | Depends on |
|---:|---|---|---|
| C-01 | Generate approved concept references for shelter environment | `assets/concept/environments/` | Prompt pack |
| C-02 | Generate approved references for generator, valve, rescue station, exit door and civilian | `assets/concept/props/`, `assets/concept/characters/` | Prompt pack |
| C-03 | Model shelter wall, floor, ceiling and doorway modules | `assets/models/environments/*.glb` | C-01 |
| C-04 | Model generator, valve wheel, pipe assembly, rescue station and exit door | `assets/models/props/*.glb` | C-02 |
| C-05 | Create shelter materials and textures | `assets/materials/`, `assets/textures/` | C-03, C-04 |
| C-06 | Create or refine civilian model and rescue animations | `assets/models/characters/` | C-02 |
| C-07 | Create dressing props: crate, bed, debris, light fixture, cables, warning sign | `assets/models/props/` | C-01 |
| C-08 | Integrate assets into Flooded Shelter scene | `scenes/levels/` | C-03 to C-07 |
| C-09 | Implement water shader and emergency lighting | Godot scene/shader files | C-08 |
| C-10 | Implement VFX FX-001 to FX-007 | Godot particle/shader scenes | C-08 |
| C-11 | Import and wire audio AUDIO-001 to AUDIO-014 | audio assets and scenes | External audio |
| C-12 | Run Godot tests and manual playtest | evidence in docs | C-08 to C-11 |

### Batch 2 — Elena

| # | Task | Output | Depends on |
|---:|---|---|---|
| C-13 | Generate Elena reference pack | `assets/concept/characters/elena/` | Prompt pack |
| C-14 | Generate or model Elena base mesh | `assets/models/characters/` | C-13 |
| C-15 | Retopologize, UV unwrap and bake Elena | Blender/Godot assets | C-14 |
| C-16 | Author Elena PBR materials | `assets/materials/`, `assets/textures/` | C-15 |
| C-17 | Rig Elena and create LOD set | `assets/models/characters/` | C-15 |
| C-18 | Create locomotion animation set | Godot-compatible animation files | C-17 |
| C-19 | Create interaction and reaction animations | Godot-compatible animation files | C-17 |
| C-20 | Model Aster device | `assets/models/props/` | C-13 |
| C-21 | Validate Elena in 2.5D and 3D test scenes | evidence in docs | C-16 to C-20 |

### Batch 3 — Marcus, enemies and combat art

| # | Task | Output | Depends on |
|---:|---|---|---|
| C-22 | Generate Marcus reference pack | `assets/concept/characters/marcus/` | Prompt pack |
| C-23 | Model, rig and texture Marcus | `assets/models/characters/` | C-22 |
| C-24 | Create Marcus combat animations | animation files | C-23 |
| C-25 | Create Scavenger, Enforcer, Marksman and Shield unit | `assets/models/characters/enemies/` | Enemy specs |
| C-26 | Create enemy animation sets | animation files | C-25 |
| C-27 | Create combat VFX | Godot VFX scenes | Combat design |
| C-28 | Create throwable environmental props | `assets/models/props/` | Arena design |

### Batch 4 — Narrative and later environments

| # | Task | Output | Depends on |
|---:|---|---|---|
| C-29 | Create Voss, Iris, Amara and civilian variants | character assets | Reference packs |
| C-30 | Create memory fragment prop and 24 variants | prop/FX assets | Narrative data |
| C-31 | Build Helix laboratory kit | environment assets | `LAB_STYLE_SPEC.md` |
| C-32 | Build highway, port and Final Thaw Station kits | environment assets | Level specs |
| C-33 | Produce ending cinematic assets | cinematic scenes | Final scripts |
| C-34 | Produce music, voice and SFX | audio assets | Audio specs |
| C-35 | Profile, optimize and export builds | performance reports/export presets | Complete content |

## Evidence template

For each completed task, add:

```markdown
## Evidence — <task id>

- Date:
- Godot version:
- Scene tested:
- Commands run:
- Screenshots/video:
- Pass/fail:
- Known issues:
- Provenance updated: yes/no
```

## Boundaries

These tasks require local tools or human-reviewed binary outputs. Perplexity-authored code and documentation may support them, but should not claim that binary assets, animations, audio, performance or playability have been verified without evidence.
