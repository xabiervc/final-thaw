# FINAL THAW — Master Asset List

## Status legend

- `SPEC`: specification exists.
- `CONCEPT`: concept/reference exists.
- `BLOCKOUT`: rough geometry/layout exists.
- `FINAL`: production asset exists.
- `GODOT`: validated in Godot.
- `TODO`: not started.

## Priority 1 — Flooded Shelter presentation-ready

| ID | Asset | Type | Priority | Status | Owner | Acceptance criteria |
|---|---|---|---:|---|---|---|
| ENV-001 | Shelter wall module A | Environment | P0 | TODO | Claude/Blender | Modular, correct scale, collision, Godot import |
| ENV-002 | Shelter floor module A | Environment | P0 | TODO | Claude/Blender | Tiling-compatible, collision, Godot import |
| ENV-003 | Shelter ceiling module A | Environment | P0 | TODO | Claude/Blender | Modular, light-compatible, Godot import |
| ENV-004 | Shelter doorway module | Environment | P0 | TODO | Claude/Blender | Supports navigation and scene transitions |
| ENV-005 | Flooded water volume | Environment/VFX | P0 | TODO | Claude/Godot | Readable surface, transparent/refractive, performant |
| PROP-001 | Emergency generator | Prop | P0 | TODO | Claude/Blender | Interactive, POWER station visual, collision |
| PROP-002 | Valve wheel | Prop | P0 | TODO | Claude/Blender | Interactive, open/closed state, collision |
| PROP-003 | Pipe assembly A | Prop | P0 | TODO | Claude/Blender | Connects valve room visually, modular |
| PROP-004 | Rescue station | Prop | P0 | TODO | Claude/Blender | Clear CIVILIAN interaction affordance |
| PROP-005 | Exit door | Prop | P0 | TODO | Claude/Blender | Clear EXIT affordance, opens/closes |
| PROP-006 | Trapped civilian | Character/NPC | P0 | TODO | Claude/Blender | Rescue animation, readable silhouette |
| PROP-007 | Shelter crate A | Prop | P1 | TODO | Claude/Blender | Reusable clutter, collision |
| PROP-008 | Shelter bed A | Prop | P1 | TODO | Claude/Blender | Reusable clutter, collision |
| PROP-009 | Debris pile A | Prop | P1 | TODO | Claude/Blender | Reusable environmental damage |
| PROP-010 | Emergency light fixture | Prop | P1 | TODO | Claude/Blender | Emissive, supports flicker |
| UI-001 | Oxygen meter | UI | P0 | TODO | Perplexity/Godot | Diegetic Aster styling, readable at 75–200% UI scale |
| UI-002 | Objective tracker | UI | P0 | TODO | Perplexity/Godot | Shows POWER, VALVES, CIVILIAN, EXIT |
| UI-003 | Interaction prompt | UI | P0 | TODO | Perplexity/Godot | Clear E prompt and station highlight |
| UI-004 | Demo result screen | UI | P0 | TODO | Perplexity/Godot | Summarizes civilian aid decision |
| FX-001 | Water drip | VFX | P1 | TODO | Claude/Godot | Small reusable particle effect |
| FX-002 | Electrical spark | VFX | P1 | TODO | Claude/Godot | Generator activation feedback |
| FX-003 | Dust motes | VFX | P2 | TODO | Claude/Godot | Atmospheric depth |
| AUDIO-001 | Shelter ambience | Audio | P1 | TODO | External/Claude | Water, machinery, distant structure |
| AUDIO-002 | Generator activation | Audio | P1 | TODO | External/Claude | Mechanical startup and power hum |
| AUDIO-003 | Valve turn | Audio | P1 | TODO | External/Claude | Metal resistance and water release |
| AUDIO-004 | Oxygen warning | Audio | P0 | TODO | External/Claude | Clear escalating warning |

## Priority 2 — Elena 3D production

| ID | Asset | Type | Priority | Status | Owner | Acceptance criteria |
|---|---|---|---:|---|---|---|
| CHAR-001 | Elena Vast reference pack | Concept | P0 | TODO | Perplexity | Front, side, back, 3/4, expression and pose sheet |
| CHAR-002 | Elena Vast base mesh | Character | P0 | TODO | Claude/Blender | Animation-ready topology, correct proportions |
| CHAR-003 | Elena Vast PBR materials | Character | P0 | TODO | Claude/Blender | Base color, normal, roughness, AO; 2048–4096 px |
| CHAR-004 | Elena Vast rig | Character | P0 | TODO | Claude/Blender | Humanoid rig compatible with Godot |
| CHAR-005 | Elena locomotion set | Animation | P0 | TODO | Claude/Blender | Idle, walk, run, jump, land |
| CHAR-006 | Elena interaction set | Animation | P0 | TODO | Claude/Blender | Interact, scan, hack, carry/use object |
| CHAR-007 | Elena reaction set | Animation | P1 | TODO | Claude/Blender | Hit, stagger, death, rescue success |
| CHAR-008 | Elena LOD set | Character | P1 | TODO | Claude/Blender | LOD0, LOD1, LOD2 within budget |
| CHAR-009 | Aster device | Prop | P0 | TODO | Claude/Blender | Attachable, emissive, HUD source |

## Priority 3 — Marcus and combat

| ID | Asset | Type | Priority | Status | Owner | Acceptance criteria |
|---|---|---|---:|---|---|---|
| CHAR-010 | Marcus reference pack | Concept | P1 | TODO | Perplexity | Full turnaround, expressions, combat poses |
| CHAR-011 | Marcus base mesh | Character | P1 | TODO | Claude/Blender | Animation-ready topology |
| CHAR-012 | Marcus PBR materials | Character | P1 | TODO | Claude/Blender | Warm palette, worn fabric and practical gear |
| CHAR-013 | Marcus rig | Character | P1 | TODO | Claude/Blender | Combat-ready humanoid rig |
| CHAR-014 | Marcus combat set | Animation | P1 | TODO | Claude/Blender | Three-hit combo, heavy attack, dodge, hit reactions |
| ENEMY-001 | Scavenger | Character/Enemy | P1 | TODO | Claude/Blender | Patrol, attack, damage, death; ragged breathing audio |
| ENEMY-002 | Enforcer | Character/Enemy | P2 | TODO | Claude/Blender | Heavy enemy with mechanical servo identity |
| ENEMY-003 | Marksman | Character/Enemy | P2 | TODO | Claude/Blender | Ranged attack and targeting feedback |
| ENEMY-004 | Shield unit | Character/Enemy | P2 | TODO | Claude/Blender | Energy shield, block and shield-break states |
| PROP-020 | Throwable object | Prop | P1 | TODO | Claude/Blender | Physics-ready, reusable combat prop |
| FX-010 | Melee impact | VFX | P1 | TODO | Claude/Godot | Clear hit feedback without excessive gore |
| FX-011 | Dodge trail | VFX | P2 | TODO | Claude/Godot | Readable movement feedback |

## Priority 4 — Narrative, Helix and endings

| ID | Asset | Type | Priority | Status | Owner | Acceptance criteria |
|---|---|---|---:|---|---|---|
| CHAR-020 | Dr. Selene Voss | Character | P2 | TODO | Perplexity + Claude | Authoritative silhouette, Helix palette |
| CHAR-021 | Iris Vast | Character | P2 | TODO | Perplexity + Claude | Memory/cinematic use |
| CHAR-022 | Amara | Character | P3 | TODO | Perplexity + Claude | Flashback and narrative context |
| CHAR-023 | Civilian variant pack | Character/NPC | P2 | TODO | Claude/Blender | Modular clothing and color variants |
| PROP-030 | Memory fragment | Prop/Collectible | P1 | TODO | Claude/Blender | Floating hologram, 24 instances via variants |
| PROP-031 | Helix terminal | Prop | P2 | TODO | Claude/Blender | Interactive, emissive screen |
| PROP-032 | Shield generator | Prop | P2 | TODO | Claude/Blender | Hackable objective |
| PROP-033 | Iris grave | Prop | P3 | TODO | Claude/Blender | Public Thaw ending cinematic |
| PROP-034 | Marcus memorial | Prop | P3 | TODO | Claude/Blender | Public Thaw ending cinematic |
| ENV-010 | Helix laboratory kit | Environment | P2 | TODO | Claude/Blender | Modular walls, floors, terminals and containment units |
| ENV-011 | Highway environment kit | Environment | P3 | TODO | Claude/Blender | Wind, debris and damaged infrastructure |
| ENV-012 | Port environment kit | Environment | P3 | TODO | Claude/Blender | Evacuation and rescue context |
| ENV-013 | Final Thaw Station kit | Environment | P3 | TODO | Claude/Blender | Volumetric light, resistance presence, hope palette |

## Production order

1. Complete Priority 1 before expanding art scope.
2. Produce Elena 3D in parallel only after Flooded Shelter environment modules are stable.
3. Start Marcus/combat after Elena's animation pipeline is validated.
4. Produce narrative/endgame assets after core gameplay systems are verified.

## Definition of done

An asset is done only when it is present in the repository, imported into Godot, visually reviewed in its intended scene, technically validated, provenance-recorded and covered by a test or manual playtest evidence entry.
