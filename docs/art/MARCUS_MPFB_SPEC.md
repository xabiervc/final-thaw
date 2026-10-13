# Marcus Reyes — 3D specification (approved by the owner 2026-10-14)

Status: **approved** (the owner delegated approval: the spec follows the concept art and repo docs). Open decisions below default to: same 30k budget, skin hands with a texture glove. Geometry has not been generated yet (`CLAUDE.md`, 3D art pipeline). Source: `assets/concept/characters/marcus_reyes_concept.png`, `GDD.md` (palette: warm oranges, reds, earth tones; North American, 35–45). Method reuses the Elena pipeline in `tools/blender/elena_mpfb/` (see `ELENA_MPFB_STATUS.md`).

## Purpose
Second playable protagonist, readable at the isometric gameplay camera (~130 px tall at 720p): the silhouette and large colour blocks must read before any surface detail. Counterpart to Elena: bulkier, warm palette against her cool teal.

## Body and scale
- MPFB base, male, game_engine rig (53 bones), A-pose, feet on y = 0, front = +Z, 1.82 m (Elena 1.70 m).
- Macro: gender 1.0, age ≈ 0.6 (late 30s), muscle ≈ 0.55, weight ≈ 0.55, proportions neutral. Helper geometry removed after rigging, as for Elena.
- Face targets from the concept: square jaw, short dark hair, stubble, tired heavy brows. Stubble and skin detail are texture work, not geometry.

## Costume (from the concept)
| Part | Description | Colour (sRGB, from the swatches) |
|---|---|---|
| Jacket | Short padded work jacket, high stand collar, olive-green inner collar, shoulder yoke and elbow patches in a darker red | body `B5622B`, yoke/patches `8A3A32`, collar lining `3E4236` |
| Sweater | Dark knit crew neck | `202325` |
| Belt | Utility belt with buckle, two pouches (left), radio on the right hip, orange screen | belt `4A4B3F`, pouch `5A5A48`, radio `15181A` + amber `E8932A` |
| Trousers | Straight work trousers, dark green-grey | `32362F` |
| Gloves | Worn leather, brown | `5A4630` |
| Boots | Lace-up leather work boots, scuffed | `4A3B2B` |
| Hair | Short, dark, textured top | `15110F` |

Radio screen uses an amber emissive (no other emissive hue; Elena owns cyan).

## Budget and technical rules
- Whole character ≤ 30,000 triangles (body head+hands ≤ 15k, jacket ≤ 5k, belt+pouches+radio ≤ 2k, rest ≤ 8k).
- One 2048² atlas (albedo, normal, ORM), baked from procedural materials; garments derived from the body like Elena's; max 4 bone influences per vertex.
- Collision/gameplay capsule unchanged by the model; no gameplay scripts in the asset.
- Provenance: MPFB base and targets, same open licence question as Elena (to verify before recording in `PROVENANCE.md`).

## Acceptance
Imports in Godot 4.7.x without errors; height 1.82 m ± 0.02; ≤ 30k triangles; silhouette distinct from Elena in grayscale at gameplay distance; front/side/back captures reviewed against the concept by the project owner. Not "final" until that review.

## Open decisions for the owner
1. Approve the spec, or amend colours/proportions.
2. Same triangle budget as Elena (30k), or lower for later co-op/enemy counts.
3. Gloves modelled (hands become part of the glove mesh) or skin hands with a texture glove (cheaper, less readable).
