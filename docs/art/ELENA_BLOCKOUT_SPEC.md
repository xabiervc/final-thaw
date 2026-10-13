# Elena Blockout — Specification

**Status:** built as `assets/models/characters/elena_blockout_a.glb` (1,544 triangles, 9 rigid meshes, no rig); checked automatically, **pending the owner's validation in Godot**. Reference: `assets/concept/characters/elena_vast_concept.png` (front, side, three-quarter, face). The concept is a design reference, not an in-game asset. This blockout is not the final character.

## Scope

- In: static, stylized, readable mesh for lighting, scale and silhouette review.
- Out: final character, animation, skinning, facial detail, hair simulation, cloth physics.

## Concept-art rules extracted

| Element | Concept art |
|---|---|
| Coat | long (to mid-thigh), dark teal, high stand collar, open front, two large flap pockets, gray-cyan piping down the front and shoulder yoke panels |
| Under | dark charcoal turtleneck with short zip |
| Legs | charcoal cargo trousers with side pockets |
| Boots | dark teal-green rubber boots, knee-high, plain |
| Backpack | teal-green, tool loops (wrench, pliers) on the side, small amber beacon on top |
| Hands | holds a handheld device with cyan screen (the Aster) in the right hand |
| Hair | dark brown, parted, low ponytail |
| Face | tired, serious; **not modelled** in the blockout |
| Palette strip | skin, gray, dark teal, light cyan, dark brown |

## Proportions and scale [proposed]

- Height 1.70 m, matching the gameplay capsule (r 0.32, h 1.7). About 7.2 heads; head enlarged ≈ 8% for readability at 8.5 m camera height (head height ≈ 0.25 m including hair).
- Shoulder width ≈ 0.46 m; coat width at hem ≈ 0.58 m. As built the bounding box is 0.69 × 1.70 × 0.80 m (the forward right arm with the Aster and the backpack add depth).
- Coat hem at y ≈ 0.80 m, boot shaft top at y ≈ 0.45 m, boot sole 0.04 m.
- Silhouette priorities, in order: long coat with flared hem, stand collar, backpack bulk behind, knee boots, ponytail.

## Orientation and structure

- Origin at feet center on the floor. **Front = +Z** (as in `elena_controller.gd`, where `visual.rotation.y = atan2(x, z)`); backpack at −Z.
- Pose: neutral A-stance, right forearm slightly forward holding the Aster.
- No armature and no skin weights. Rigid parts as nodes with pivots at joints so Godot can pose or rotate them later: `Root` → `Hips` → (`Torso` → `Head`, `ArmL`, `ArmR` → `Aster`, `Backpack`), `LegL`, `LegR`. 9 meshes, no animation clips. `R` is Elena's anatomical right, which is −X when she faces +Z.
- Collision: none in the GLB. The existing capsule in `elena_controller.gd` stays the collider.

## Materials

Flat PBR, metallic 0. Colors match the palette-test reference so lighting reviews stay comparable.

| Material | sRGB | Roughness | Emission |
|---|---|---|---|
| `elena_blk_coat` | `#2C474C` | 0.85 | — |
| `elena_blk_piping` | `#8DB0B0` | 0.60 | — |
| `elena_blk_turtleneck` | `#26292C` | 0.90 | — |
| `elena_blk_trousers` | `#33373A` | 0.90 | — |
| `elena_blk_boots` | `#1F3436` | 0.70 | — |
| `elena_blk_backpack` | `#26403F` | 0.85 | — |
| `elena_blk_skin` | `#D9B49A` | 0.80 | — |
| `elena_blk_hair` | `#2A211E` | 0.90 | — |
| `elena_blk_aster` | `#7FF0E6` | 0.40 | 2.0 (cyan reserved for Elena and scanning) |

The amber beacon on the backpack is **not emissive** in the blockout (amber is reserved for interactables). It is a small nub using `lab_mat_painted_metal` (the tenth material in the file) until decision D2 in `LAB_KIT_PLAN.md`.

## Budget and export [proposed]

- ≤ 3,500 triangles; ≤ 10 mesh nodes; 9 `elena_blk_*` materials + the beacon nub; no textures.
- File: `assets/models/characters/elena_blockout_a.glb`; script `tools/blender/build_elena_blockout_a.py`; `.blend` outside the repo.
- Facial detail: none (smooth head, hair mass with ponytail, no eyes, mouth or brows).

## Acceptance in Godot (owner validates)

1. At the gameplay camera, the silhouette reads as Elena from the concept: long coat, stand collar, backpack, knee boots.
2. Height matches the capsule and a 1.70 m reference pole; feet sit at y = 0.
3. Front is +Z; rotating the node with `atan2(x, z)` faces the movement direction.
4. Grayscale: coat, trousers, boots and floor separate by value; Aster cyan is the only emissive element.
5. Replacing the current primitive `visual` meshes with this model is **not** part of this task; no gameplay file is touched.
