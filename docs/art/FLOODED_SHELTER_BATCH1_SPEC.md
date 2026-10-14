# Flooded Shelter — Environment and Prop Production Specs

## Batch objective

Produce the first Godot-validated art set for the Flooded Shelter vertical slice. This batch replaces greybox representation with readable, modular, performance-conscious assets while preserving the existing gameplay route:

```text
POWER -> VALVES -> optional CIVILIAN -> EXIT
```

## Global constraints

- Godot 4.x.
- Scale: 1 unit = 1 meter.
- Up axis: +Y.
- Forward axis: -Z.
- Export format: GLB.
- Materials: PBR.
- Naming: lowercase snake case.
- All interactive props require collision.
- All environment modules must tile without visible seams.

## Environment modules

### ENV-001 — Shelter wall module A

- File: `assets/models/environments/env_shelter_wall_module_a.glb`
- Size: 4 m wide x 3 m high x 0.25 m deep.
- Pivot: bottom center.
- Materials: wet concrete, oxidized metal panels, minor water staining.
- Collision: static box collision.
- Acceptance: tiles horizontally, supports emergency light placement, no visible seam at repeat.

### ENV-002 — Shelter floor module A

- File: `assets/models/environments/env_shelter_floor_module_a.glb`
- Size: 4 m x 4 m x 0.1 m.
- Pivot: top center.
- Materials: worn concrete, drainage grates, damp patches.
- Collision: static box collision.
- Acceptance: tiles in X and Z, supports water volume placement, readable player movement surface.

### ENV-003 — Shelter ceiling module A

- File: `assets/models/environments/env_shelter_ceiling_module_a.glb`
- Size: 4 m x 4 m x 0.2 m.
- Pivot: bottom center.
- Materials: stained concrete, exposed conduits, damaged panels.
- Collision: optional; include only if required by level design.
- Acceptance: supports hanging pipes, lights and cables.

### ENV-004 — Shelter doorway module

- File: `assets/models/environments/env_shelter_doorway_module_a.glb`
- Size: 2 m wide x 2.4 m high x 0.3 m deep.
- Pivot: bottom center.
- Materials: reinforced frame, warning stripes, emergency signage.
- Collision: side jambs only; center remains navigable.
- Acceptance: compatible with exit door and room transitions.

## Interactive props

### PROP-001 — Emergency generator

- File: `assets/models/props/prop_shelter_generator_a.glb`
- Size: approximately 1.2 m x 0.9 m x 0.8 m.
- Pivot: bottom center.
- States: inactive, powering, active.
- Visual requirements: fuel cell or power core, cables, status lights, vents and physical interaction panel.
- Animation: fan spin or power-core pulse; status lights transition from red/amber to cyan.
- Collision: static box or convex collision.
- Acceptance: clearly reads as the POWER station; active state is visible from gameplay camera.

### PROP-002 — Valve wheel

- File: `assets/models/props/prop_shelter_valve_wheel_a.glb`
- Size: wheel diameter approximately 0.5 m.
- Pivot: wheel center.
- States: closed, turning, open.
- Animation: 180–270 degree rotation during activation.
- Materials: rusted metal, worn grip surfaces, water stains.
- Collision: interaction trigger only; no player-blocking collision unless design requires it.
- Acceptance: readable as VALVES interaction; rotation communicates water release.

### PROP-003 — Pipe assembly A

- File: `assets/models/props/prop_shelter_pipe_assembly_a.glb`
- Size: modular straight section, approximately 2 m long.
- Pivot: center.
- Materials: corroded metal, rubber seals, water residue.
- Variants: straight, elbow, junction.
- Acceptance: connects generator, valves and drainage area without floating geometry.

### PROP-004 — Rescue station

- File: `assets/models/props/prop_shelter_rescue_station_a.glb`
- Size: approximately 1.5 m x 2 m x 0.6 m.
- Pivot: bottom center.
- Visual requirements: emergency beacon, medical or survival supplies, clear civilian-access marker.
- Animation: beacon pulse when civilian rescue is available.
- Acceptance: unmistakably identifies the optional CIVILIAN interaction.

### PROP-005 — Exit door

- File: `assets/models/props/prop_shelter_exit_door_a.glb`
- Size: 1.2 m x 2.2 m x 0.1 m.
- Pivot: hinge edge.
- States: locked, unlocked, open.
- Animation: door swing or sliding motion.
- Materials: reinforced metal, EXIT signage, emergency lighting.
- Collision: dynamic collision; disabled or moved when open.
- Acceptance: clear EXIT affordance and reliable end-of-level interaction.

### PROP-006 — Trapped civilian

- File: `assets/models/characters/char_shelter_civilian_a.glb`
- Height: 1.65–1.80 m.
- Pivot: feet.
- States: trapped, rescued, following or safe.
- Visual requirements: civilian clothing, minor injuries or exhaustion conveyed through pose, readable silhouette.
- Animation: trapped struggle, rescue response, gratitude or relief.
- Acceptance: integrates with rescue station and increments `civilian_aid` exactly once.

## Environmental dressing

| ID | Asset | Purpose |
|---|---|---|
| PROP-007 | Crate A | Reusable storage clutter |
| PROP-008 | Bed A | Inhabited shelter context |
| PROP-009 | Debris pile A | Flood damage and blocked routes |
| PROP-010 | Emergency light fixture | Navigation and atmosphere |
| PROP-011 | Wall pipe A | Reusable pipe dressing |
| PROP-012 | Cable bundle A | Ceiling and wall detail |
| PROP-013 | Warning sign A | Hazard and route guidance |

## Water

### ENV-005 — Flooded water volume

- Implementation: Godot shader or particle-assisted plane.
- Requirements: semi-transparent surface, subtle wave motion, wet edge transition, reflection or fake reflection where performance allows.
- Gameplay: must not obscure interaction prompts or oxygen UI.
- Acceptance: readable at gameplay camera, performant at target resolution, visually distinct from floor.

## Lighting direction

- Base: cold, low-intensity ambient light.
- Emergency: amber flickering lights near POWER and EXIT.
- Interaction: cyan or pale blue highlight for interactive stations.
- Hazard: red-orange pulse when oxygen is low.
- Water: subtle specular highlights; avoid full-screen bloom.

## First-batch deliverables

1. ENV-001 to ENV-005.
2. PROP-001 to PROP-006.
3. At least PROP-007 to PROP-010 for dressing.
4. Godot scene integration and visual validation.
5. Provenance files for every exported asset.
