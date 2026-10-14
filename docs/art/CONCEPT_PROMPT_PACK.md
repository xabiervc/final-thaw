# Concept Art and Image-to-3D Prompt Pack

## Purpose

Provide reusable, consistent prompts for generating 2D references that feed Blender modeling or image-to-3D tools such as Pixal3D, TRELLIS.2, Meshy, Tripo or Rodin. These prompts are starting points: every output requires human review against `ASSET_PRODUCTION_BIBLE.md`.

## Global style block

Append to every prompt:

```text
climate-thriller game art, painterly but readable, cold atmospheric lighting, restrained palette, clean silhouette, functional industrial design, high detail at focal points, no text, no watermark, no logo
```

## Global negative prompt

```text
low quality, blurry, extra limbs, deformed hands, distorted face, text, watermark, logo, oversaturated colors, fantasy armor, sexualized costume, cluttered background, extreme perspective, cropped body, duplicate objects
```

## Image-to-3D input rules

- Single subject, centered, fully visible.
- Neutral grey or white background.
- Even lighting with soft shadows.
- No extreme camera angle.
- Characters in A-pose with visible hands and feet.
- Props in three-quarter view with the main interaction side visible.
- Generate multiple views when the tool supports multi-view input.
- Keep source images at 1024 px minimum on the shortest side; prefer 2048 px.

## Elena Vast

### Front A-pose

```text
full-body character reference of Elena Vast, climate scientist, age 30, practical hooded technical jacket in cool blue and clinical white, dark grey field trousers, waterproof technical boots, small cyan holographic Aster device on left wrist, compact utility backpack, restrained determined expression, front view, A-pose, neutral grey background, even studio lighting, hands visible
```

### Side view

```text
full-body side view of Elena Vast, same costume and proportions, hooded technical jacket, compact backpack, Aster wrist device visible, A-pose, neutral grey background, even lighting, orthographic-style reference
```

### Back view

```text
full-body back view of Elena Vast, same costume and proportions, hood shape, backpack, jacket panels and boot details clearly visible, A-pose, neutral grey background, even lighting
```

### Three-quarter gameplay view

```text
full-body three-quarter view of Elena Vast, same costume, slightly forward-leaning observant posture, Aster device glowing cyan, readable silhouette for isometric game camera, neutral grey background, soft studio lighting
```

### Expression sheet

```text
expression sheet for Elena Vast, five head studies: neutral, determined, worried, focused, relieved, consistent face and hairstyle, restrained realistic expressions, neutral grey background
```

## Flooded Shelter environment

### Establishing concept

```text
flooded underground emergency shelter, wet concrete walls, oxidized metal panels, shallow stagnant water covering the floor, amber emergency lights, cyan interactive stations, exposed pipes, damaged ceiling, cinematic isometric game camera, readable route from generator room to valve room to rescue room to exit, moody but not dark, no characters
```

### Wall and floor module

```text
modular concrete shelter wall segment with oxidized metal panels and subtle water staining, front orthographic view, neutral lighting, game asset reference, no perspective distortion
```

```text
top-down modular shelter floor tile, worn concrete, drainage grate, damp patches, neutral lighting, seamless game texture reference
```

## Interactive props

### Emergency generator

```text
emergency power generator for flooded shelter, compact industrial machine, visible power core, cables, vents and status lights, red-amber inactive state with cyan active indicators, three-quarter view, neutral grey background, game prop reference
```

### Valve wheel and pipes

```text
large industrial valve wheel attached to corroded pipe assembly, rust and water stains, rubber seals, readable interaction handle, three-quarter view, neutral grey background, game prop reference
```

### Rescue station

```text
emergency civilian rescue station inside shelter, beacon light, supply locker, survival equipment, cyan access marker, damaged but functional, three-quarter view, neutral grey background, game prop reference
```

### Exit door

```text
reinforced shelter exit door with emergency signage, warning stripes, status light changing from locked amber to unlocked cyan, damp metal frame, three-quarter view, neutral grey background, game prop reference
```

### Trapped civilian

```text
full-body civilian survivor in worn practical clothing, exhausted but alive, seated or leaning posture, readable silhouette, muted blue and grey clothing with amber emergency accent, neutral grey background, character reference
```

## ComfyUI workflow recommendation

1. Generate 8–12 candidates per asset with FLUX or SDXL.
2. Select the best silhouette and proportions.
3. Use IPAdapter or style reference for consistency across the asset set.
4. Use ControlNet or pose guidance for character A-pose/front/side/back consistency.
5. Upscale the selected image.
6. Remove or clean the background.
7. Save approved references under `assets/concept/<category>/`.
8. Run image-to-3D only on approved references.

## Seed and prompt logging

For every approved reference, record:

```markdown
- Asset ID:
- Date:
- Tool/model:
- Prompt:
- Negative prompt:
- Seed:
- Sampler/steps:
- LoRA/style references:
- Output file:
- Approved by:
```

## Validation checklist

Before sending a reference to Blender or image-to-3D:

- [ ] Silhouette is readable at gameplay camera distance.
- [ ] Proportions match the asset specification.
- [ ] Palette matches `ASSET_PRODUCTION_BIBLE.md`.
- [ ] No text, watermark or logo.
- [ ] Hands, feet and functional parts are visible.
- [ ] Background is clean.
- [ ] Lighting is neutral enough for texture extraction.
- [ ] Asset ID and prompt metadata are recorded.
