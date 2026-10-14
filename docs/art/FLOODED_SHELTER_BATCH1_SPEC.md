# Flooded Shelter — Production Batch 1 Specification

## Objective

Produce the first production-ready art batch for the Flooded Shelter vertical slice. This batch replaces greybox placeholders while preserving the existing gameplay route:

```text
POWER -> VALVES -> optional CIVILIAN -> EXIT
```

## Scene context

- Location: flooded underground civil shelter.
- Mood: claustrophobic, wet, damaged, still inhabited.
- Camera: 2.5D side-view gameplay with limited depth.
- Player: Elena Vast.
- Core systems: movement, oxygen depletion, interaction, generator activation, valve drainage, civilian rescue and exit progression.

## Global technical rules

- Engine: Godot 4.x.
- Scale: 1 unit = 1 meter.
- Up axis: +Y.
- Forward axis: -Z.
- Format: GLB for static meshes; FBX only if animation requires it.
- Textures: PNG, power-of-two dimensions.
- Materials: PBR; use Godot-compatible base color, normal, roughness, metallic and AO maps.
- Collision: include simple convex or trimesh collision only where needed.
- Naming: lowercase snake case, following `ASSET_PRODUCTION_BIBLE.md`.

## Environment modules

### ENV-001 — Shelter wall module A

- Purpose: reusable wall for the main shelter corridor.
- Dimensions: 4 m wide, 3 m high, 0.3 m thick.
- Materials: damaged concrete, exposed rebar in limited areas, water staining, painted directional markings.
- Details: cable conduits, wall panels, a damaged poster area and one recessed emergency-light socket.
- Collision: box collision matching visible geometry.
- Acceptance: tiles cleanly with ENV-002 and ENV-003; no visible seams at module boundaries.

### ENV-002 — Shelter floor module A

- Purpose: reusable floor for corridor and rooms.
- Dimensions: 4 m wide, 4 m deep, 0.2 m thick.
- Materials: wet concrete, drainage grating, painted safety lines, scattered dirt.
- Details: optional drain variant, cracked tile variant and debris socket.
- Collision: flat walkable surface.
- Acceptance: Elena movement feels stable; no z-fighting with water plane.

### ENV-003 — Shelter ceiling module A

- Purpose: reusable ceiling for corridor and rooms.
- Dimensions: 4 m wide, 4 m deep, 0.2 m thick.
- Materials: stained concrete, metal ducting, broken light housing.
- Details: pipe attachment points, ventilation grille and hanging cable variants.
- Collision: not required unless gameplay uses it.
- Acceptance: supports hanging lights and pipe assemblies without clipping.

### ENV-004 — Shelter doorway module

- Purpose: transition between POWER, VALVES, CIVILIAN and EXIT rooms.
- Dimensions: 2 m wide, 2.4 m high, 0.4 m thick.
- Materials: reinforced metal frame, damaged concrete surround, warning stripes.
- Details: door track, emergency signage and optional sliding-door variant.
- Collision: frame collision; doorway opening must remain clear.
- Acceptance: player can pass through without collision issues; door can be opened/closed by gameplay.

## Interactive props

### PROP-001 — Emergency generator

- Purpose: POWER station.
- Dimensions: approximately 1.2 m wide, 1.0 m deep, 1.4 m high.
- State A: inactive; dark screen, no emissive elements.
- State B: active; emissive status lights, spinning cooling fan, subtle electrical hum.
- Interaction: Elena activates it at the POWER station.
- Materials: matte metal casing, rubber cables, worn yellow hazard markings.
- Collision: box collision.
- Acceptance: activation state is readable from gameplay camera; interaction point is obvious.

### PROP-002 — Valve wheel

- Purpose: VALVES station.
- Dimensions: wheel diameter 0.5 m; mounted on a pipe assembly.
- State A: closed.
- State B: open; wheel rotated approximately 180 degrees.
- Interaction: Elena turns the wheel to drain water.
- Materials: oxidized red metal, steel pipe, rubber seals.
- Collision: not needed on wheel itself; pipe assembly requires collision.
- Acceptance: rotation is visible and communicates water drainage.

### PROP-003 — Pipe assembly A

- Purpose: connect valve room visually and structurally.
- Dimensions: modular straight, elbow and junction pieces.
- Materials: rusted steel, condensation, warning labels.
- Details: bolts, brackets, valves and drip points.
- Collision: only where it blocks movement.
- Acceptance: modular pieces connect without visible gaps.

### PROP-004 — Rescue station

- Purpose: CIVILIAN interaction point.
- Dimensions: approximately 1.5 m wide, 2.0 m high, 0.8 m deep.
- State A: civilian trapped behind collapsed debris or a jammed hatch.
- State B: civilian freed and following rescue flow.
- Interaction: Elena uses the station to free the civilian.
- Materials: metal hatch, emergency lighting, medical or civilian supplies.
- Collision: blocks passage until rescue is complete if required by level design.
- Acceptance: player understands that a person can be saved; rescue feedback is clear.

### PROP-005 — Exit door

- Purpose: EXIT station.
- Dimensions: 1.2 m wide, 2.2 m high.
- State A: locked or sealed.
- State B: open after required objectives are complete.
- Interaction: Elena opens it after completing the route.
- Materials: reinforced metal, green exit signage, emergency strip lighting.
- Collision: blocks passage until opened.
- Acceptance: exit state is unmistakable; door opens without obstructing the player.

## Supporting props

| ID | Asset | Purpose | Notes |
|---|---|---|---|
| PROP-006 | Trapped civilian | Rescue target | Simple readable NPC; rescue animation required |
| PROP-007 | Shelter crate A | Clutter | Stackable, 0.8 m cube maximum |
| PROP-008 | Shelter bed A | Clutter | Damaged mattress and metal frame |
| PROP-009 | Debris pile A | Environmental damage | Reusable rubble cluster |
| PROP-010 | Emergency light fixture | Lighting | Emissive amber; supports flicker |
| PROP-011 | Warning sign A | Environmental storytelling | Evacuation, electrical hazard or flood warning |
| PROP-012 | Cable bundle A | Set dressing | Hangs from ceiling or runs along walls |

## Water and lighting

### ENV-005 — Flooded water volume

- Purpose: visual and gameplay representation of flooding.
- Implementation: Godot plane or volumetric shader, not baked geometry.
- Requirements:
  - Semi-transparent surface.
  - Subtle animated normal or ripple effect.
  - Reflection or fake reflection if performance allows.
  - Clear depth transition near walls and props.
- Acceptance: water level can rise or fall when valves are activated.

### Lighting kit

- Emergency amber point lights for main route.
- Cold cyan fill light for Elena-readable areas.
- Red alarm light near oxygen warning or failed systems.
- Flicker animation for damaged fixtures.
- No dynamic shadows on low-end targets unless profiling proves acceptable.

## VFX

| ID | Effect | Purpose | Notes |
|---|---|---|---|
| FX-001 | Water drip | Ceiling and pipe leaks | Small, reusable particle system |
| FX-002 | Electrical spark | Generator activation | Short burst, non-repetitive timing |
| FX-003 | Dust motes | Atmosphere | Low-density ambient particles |
| FX-004 | Valve release | Water drainage feedback | Brief burst near valve and pipe |
| FX-005 | Rescue burst | Civilian freed | Soft light and debris displacement |

## Audio requirements

| ID | Sound | Trigger | Notes |
|---|---|---|---|
| AUDIO-001 | Shelter ambience | Always | Water, distant machinery, structural creaks |
| AUDIO-002 | Generator activation | POWER station | Mechanical startup, then electrical hum |
| AUDIO-003 | Valve turn | VALVES station | Metal resistance, water release |
| AUDIO-004 | Oxygen warning | Low oxygen | Escalating alarm; must remain readable |
| AUDIO-005 | Rescue success | Civilian freed | Human relief, debris movement, positive UI feedback |
| AUDIO-006 | Exit open | EXIT station | Heavy door mechanism and route-complete cue |

## Production order

1. ENV-001, ENV-002, ENV-003, ENV-004.
2. PROP-001, PROP-002, PROP-003, PROP-004, PROP-005.
3. ENV-005 water volume and lighting kit.
4. Supporting props and VFX.
5. Audio implementation.
6. Full scene integration and playtest.

## Batch acceptance

Batch 1 is complete when:

- All P0 environment modules and props exist in `assets/models`.
- All P0 assets import into Godot without missing materials or textures.
- The POWER, VALVES, CIVILIAN and EXIT route is visually readable.
- Water, lighting and interaction feedback support the existing gameplay loop.
- A recorded playtest demonstrates movement, oxygen, generator activation, valve drainage, civilian rescue and exit progression.
