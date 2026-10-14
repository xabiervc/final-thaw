# Elena Vast — 3D Reference Pack Specification

## Objective

Define the visual reference package required to produce Elena Vast as an animation-ready 3D character for FINAL THAW. This pack is the input for Blender modeling, AI-assisted 3D generation, texturing, rigging and Godot validation.

## Character intent

Elena is a climate scientist and survivor driven by guilt, curiosity and responsibility. Her visual language must communicate intelligence, restraint and hope through knowledge.

- Age appearance: 28–35.
- Build: practical, athletic but not exaggerated.
- Height: approximately 1.72 m.
- Primary palette: cool blue, cyan, clinical white.
- Secondary accents: dark technical grey and muted teal.
- Forbidden: sexualized design, impractical footwear, excessive armor, bright fantasy materials.

## Silhouette goals

Elena must be recognizable from a distance through:

- A practical hooded technical jacket.
- A compact backpack or utility harness.
- The Aster device attached to the wrist, belt or chest.
- A clean vertical posture with a slightly forward-leaning observational idle.
- A distinctive hood or collar shape without obscuring the face.

## Required reference views

Produce the following images before final modeling:

| View | Purpose |
|---|---|
| Front T-pose or A-pose | Proportions, face, chest, arms and leg layout |
| Side view | Posture, jacket depth, backpack volume, profile silhouette |
| Back view | Hood, backpack, jacket rear, heel and hair shape |
| Three-quarter front | Primary gameplay readability |
| Three-quarter back | Gear and silhouette readability |
| Facial close-up | Age, expression, eye shape, hairline and skin material |
| Expression sheet | Neutral, determined, worried, focused, relieved |
| Pose sheet | Idle, walk, run, interact, scan/hack, hit, death |

## Costume specification

### Jacket

- Technical hooded jacket.
- Matte water-resistant fabric.
- Reinforced shoulder and elbow panels.
- Cyan piping or emissive trim used sparingly.
- Zipper, pockets and strap details must remain readable but not noisy.

### Trousers

- Durable field trousers.
- Slightly tapered fit.
- Reinforced knees.
- Dark grey or desaturated blue.

### Footwear

- Waterproof technical boots.
- Rubber sole.
- Low-contrast details.
- Must support running, climbing and flooded-environment traversal.

### Aster device

- Small wrist, chest or belt-mounted device.
- Emissive cyan display.
- Source of the diegetic HUD.
- Must remain visible in three-quarter gameplay view.

## Material specification

| Material | Roughness | Metallic | Notes |
|---|---:|---:|---|
| Technical fabric | 0.65–0.85 | 0.0 | Subtle weave normal variation |
| Reinforced panels | 0.45–0.65 | 0.0–0.2 | Slightly harder surface response |
| Metal accents | 0.30–0.55 | 0.6–0.9 | Limited scratches and wear |
| Skin | 0.45–0.65 | 0.0 | Natural subsurface approximation |
| Hair | 0.35–0.60 | 0.0 | Avoid overly glossy stylization |
| Aster device | 0.25–0.50 | 0.4–0.8 | Emissive cyan display |

## Texture requirements

- Base color: 2048 px minimum, 4096 px for hero close-ups.
- Normal map: same resolution as base color.
- Roughness: same resolution or packed channel.
- Ambient occlusion: baked where useful.
- Emissive: Aster device, jacket trim and optional suit indicators.
- Avoid unnecessary unique textures for repeated clothing panels.

## Polygon and LOD budget

| LOD | Triangle budget | Use |
|---|---:|---|
| LOD0 | 30,000–70,000 triangles | Close gameplay and cinematics |
| LOD1 | 10,000–25,000 triangles | Standard gameplay |
| LOD2 | 3,000–8,000 triangles | Distant gameplay or crowd use |

## Animation requirements

### Locomotion

- Idle.
- Idle fidget.
- Walk forward, backward and strafe.
- Run forward.
- Jump.
- Fall.
- Land.

### Interaction

- Generic interact.
- Generator activation.
- Valve turn.
- Civilian rescue.
- Scan.
- Hack or calibrate.

### Reaction

- Light hit.
- Heavy hit.
- Stagger.
- Death.
- Rescue success.
- Oxygen warning.

## Rig requirements

- Humanoid skeleton compatible with Godot.
- Root motion optional; in-place animations preferred for gameplay.
- Finger bones required for interaction credibility.
- Facial bones or blend shapes required for cinematics.
- Clean deformations at shoulders, elbows, wrists, hips, knees and neck.

## AI generation guidance

When using image-to-3D tools:

- Start from a clean, evenly lit, full-body A-pose reference.
- Use a neutral background.
- Avoid extreme perspective.
- Keep hands visible and uncrossed.
- Generate a base mesh only; final topology, rig and animation require Blender work.
- Validate proportions against the 1.72 m height target before texturing.

## Acceptance criteria

The reference pack is complete when it includes all required views, uses the approved palette, maintains a readable silhouette, specifies Aster placement and provides enough information for modeling, texturing, rigging and animation without further design ambiguity.
