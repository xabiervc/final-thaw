# Elena Vast — 3D Reference Pack Specification

## Objective

Define the reference material required to produce a consistent, animation-ready 3D version of Elena Vast for FINAL THAW.

This specification extends `docs/art/ELENA_BLOCKOUT_SPEC.md` and `docs/art/ELENA_MPFB_STATUS.md`. It is the source brief for concept generation, AI 3D generation, Blender refinement, rigging and Godot validation.

## Character summary

- Name: Elena Vast.
- Role: co-protagonist, scientist and survivor.
- Age range: 28–35.
- Build: athletic but not exaggerated; practical, mobile, capable.
- Height: 1.72 m.
- Personality: restrained, observant, determined, carrying guilt and hope.
- Visual identity: cool blues, cyans and clinical whites; scientific, isolated, hopeful through knowledge.

## Silhouette goals

Elena must be recognizable from a distance through:

- A practical hooded technical jacket.
- A compact backpack or utility harness.
- The Aster device on her wrist or belt.
- A clear head-and-shoulder silhouette.
- A slightly forward-leaning, alert posture.

Avoid overly heroic proportions, excessive armor detail or impractical clothing.

## Costume design

### Base layer

- Dark blue technical base layer.
- High collar for cold environments.
- Reinforced elbow and knee panels.
- Matte fabric with subtle wear.

### Outer layer

- Cyan-and-white technical jacket.
- Hood that can be down for gameplay and up for weather/cinematic variants.
- Zippered pockets and utility straps.
- Reflective or emissive cyan piping, used sparingly.

### Gear

- Compact utility belt.
- Aster device: small holographic scientific tool, cyan emissive screen.
- Practical boots with reinforced soles.
- Optional small backpack for exploration scenes.

### Forbidden elements

- No military-grade armor.
- No sexualized design.
- No overly clean “hero costume” appearance.
- No bright saturated colors outside the established palette.

## Required reference views

Produce the following views with consistent proportions, costume and lighting:

| View | Purpose |
|---|---|
| Front, T-pose or A-pose | Base mesh proportions and costume layout |
| Back, A-pose | Backpack, hood, jacket back and heel details |
| Left side, A-pose | Body depth, jacket volume, belt and boot profile |
| Right side, A-pose | Mirror check and asymmetric gear details |
| Three-quarter front | Primary gameplay readability |
| Three-quarter back | Silhouette and backpack readability |
| Facial neutral | Base expression |
| Facial determined | Primary gameplay expression |
| Facial grief | Narrative and memory scenes |
| Facial alert | Combat, hazard and exploration |

## Required pose sheet

| Pose | Purpose |
|---|---|
| Idle | Neutral character presence |
| Walk | Standard locomotion reference |
| Run | Urgent movement |
| Jump | Platforming and traversal |
| Interact | Object use, terminals and stations |
| Scan | Aster device scanning animation |
| Hack | Terminal or shield-generator interaction |
| Carry/assist | Civilian rescue and cooperative moments |
| Hit reaction | Combat and environmental damage |
| Death | Failure state |

## Facial design

- Face should be believable and expressive, not hyperrealistic.
- Eyes must remain readable at gameplay camera distance.
- Brows and mouth carry most emotion; avoid relying only on micro-expressions.
- Hair must be practical, tied back or contained, with controlled simulation or baked motion.
- Skin material should avoid plastic-looking subsurface scattering.

## Color specification

| Area | Color direction |
|---|---|
| Jacket base | Desaturated cyan-blue |
| Jacket accents | Pale cyan and white |
| Base layer | Deep blue-grey |
| Pants | Dark technical grey-blue |
| Boots | Dark grey with cyan detail |
| Aster device | White casing with cyan emissive screen |
| Hair | Dark brown or dark auburn, low saturation |
| Skin | Neutral, realistic tone; avoid stylized saturation |

## 3D technical requirements

- Height: 1.72 m.
- Pivot: between feet, at ground level.
- Orientation: +Y up, -Z forward.
- LOD0: 30,000–70,000 triangles.
- LOD1: 10,000–25,000 triangles.
- LOD2: 3,000–8,000 triangles.
- Texture: 2048 px minimum; 4096 px only if justified by close-up cinematics.
- Maps: base color, normal, roughness, AO; metallic only where needed.
- Rig: humanoid, compatible with Godot AnimationPlayer or AnimationTree.
- Mesh: no non-manifold geometry, flipped normals or duplicate vertices.

## AI generation guidance

Use the reference pack to generate a base, then refine in Blender. Do not treat an AI-generated mesh as final.

Recommended prompt structure:

```text
Full-body game character reference sheet of Elena Vast,
adult woman, 28-35, athletic practical build, 1.72 m,
short practical dark hair, restrained determined expression,
cyans and clinical whites, technical hooded jacket,
utility belt, compact backpack, small holographic scientific device,
climate-survival scientist outfit,
front, side, back and three-quarter views,
neutral A-pose, clean neutral background,
stylized realistic game art, readable silhouette,
inspired by Gris, Ori and Blade Runner 2049
```

Negative prompt:

```text
armor, sexualized, exaggerated proportions, extra limbs,
deformed hands, blurry face, inconsistent costume,
oversaturated colors, photorealistic celebrity likeness,
cluttered background, text, watermark
```

## Acceptance criteria

The reference pack is complete when:

- All required views and poses exist.
- Costume, proportions and palette are consistent across views.
- The silhouette is readable at expected gameplay distance.
- The Aster device and key costume elements are clearly defined.
- A 3D artist or Blender MCP agent can create a base mesh without asking additional design questions.
- The pack has been reviewed against `ASSET_PRODUCTION_BIBLE.md`.
