# FINAL THAW — Master Asset List

## Phases 1–2 demo — asset register (2026-10-15)

This register covers every asset the playable demo uses (`scenes/prototypes/phase1_canonical_greybox.tscn`: intro, Phase 1, Phase 2, ending). Status:
- **final**: production quality, no replacement planned.
- **temporary**: works and is coherent, but must be replaced before release.
- **generated**: produced procedurally by a script in this repository (reproducible), quality noted.
- **missing**: needed and not present; the gap is described.

Licences are stated only where they were actually checked. Poly Haven and ambientCG assets are CC0 1.0 per their sites and API metadata, recorded at download in `D:/Projects/external_assets/polyhaven/models_1k/manifest.json`. **The MPFB base-asset licence for Elena is not yet verified.**

| Asset | File / resource | Use | Status | Licence / provenance | Replacement work |
|---|---|---|---|---|---|
| Elena (body, outfit, hair) | `assets/models/lab_ref/ref_elena_mpfb.glb`, `assets/textures/lab_ref/elena_*` | Player character | temporary | MPFB 2 base (code GPL-3.0; base-asset licence **unverified**), outfit and hair from scripts in `tools/blender/elena_mpfb/` | Final sculpted character from `assets/concept/characters/elena_vast_concept.png`; verify or replace the MPFB base |
| Elena animations (13 clips) | same `.glb` (idle, walk, run, crouch_idle, crouch_walk, jump, fall, land, climb, scan, interact, alert, caught) | Locomotion, gestures | generated | Procedural keys, `tools/blender/elena_mpfb/animate_elena.py` | Mocap or hand-keyed set (see "missing" below); procedural poses are readable but stiff |
| Missing Elena animations | — | — | missing | — | Turn-in-place, start/stop, dedicated sprint, crawl, hit-react, look-at |
| Recovery unit | `assets/models/characters/recovery_unit.glb` | Phase 2 pursuer | generated | `tools/blender/build_recovery_unit.py` (spec in the script header) | Concept art, then a final model with track animation and articulated manipulators |
| Facility architecture | built in code (`scripts/phase1/phase1_building.gd`, `scripts/phase2/phase2_parking.gd`) | Building and yard | generated (greybox+) | Original | Modular art kit to the `LAB_STYLE_SPEC.md` direction |
| Wall, floor, metal and concrete textures | `assets/textures/lab_photo/{painted_plaster_wall,concrete_panels,concrete_floor_worn_001,metal_plate_02}_*` | Facility surfaces | temporary (good quality) | Poly Haven, CC0 1.0 | Keep or swap for a unified trim-sheet kit |
| Asphalt | `assets/textures/lab_photo/asphalt_033_*` | Yard, street | temporary (good quality) | ambientCG Asphalt033, CC0 1.0 (`tools/art/prepare_parking_textures.py`) | — |
| Covered car | `assets/models/parking/covered_car/` | Fleet in the yard (one multimesh) | temporary (good quality) | Poly Haven "covered_car", author MP, CC0 1.0 | A few uncovered vehicles for variety |
| Security light | `assets/models/parking/security_light/` | Yard floodlight fixtures | temporary | Poly Haven, Maximilian Schuster, CC0 1.0 | — |
| Utility box | `assets/models/parking/utility_box_01/` | Egress enclosure | temporary | Poly Haven, James Ray Cock, CC0 1.0 | — |
| Roller shutter | `assets/models/parking/rollershutter_door/` | Dock 2 noise device | temporary | Poly Haven, author MP, CC0 1.0 | — |
| Chain-link fence | procedural texture (`facility_materials.gd`) | Cage and egress enclosure | generated | Original | Modelled fence kit with posts and gates |
| City backdrop | boxes and window grids (`phase2_parking.gd`) | Exterior skyline | generated (placeholder) | Original | Matte-painted skyline card or low-poly city kit |
| Music: investigation, tension, chase, release | `assets/audio/music/*.wav` | Adaptive score | generated (placeholder) | `tools/audio/render_music.gd` + `scripts/audio/game_synth.gd`; **not auditioned by ear** | Composed score; see prompts below |
| Sound effects | runtime synthesis (`sfx_synth.gd`, `game_synth.gd`) | UI, interactions, unit, PA chime, compressor, shutter, wind | generated (placeholder) | Original; **not auditioned by ear** | Recorded or designed SFX; see prompts below |
| Public address voice | — | PA lines (currently subtitles and a chime) | missing | — | VO recording, ES/EN |
| Elena voice | — | Lines N1-01, N1-02, N2-01, N2-06 (currently subtitles) | missing | — | VO recording, ES/EN |
| Intro and ending cinematics | in-engine shots (`phase1_canonical_greybox.gd`, `cinematic_director.gd`) | Story framing | temporary | Original | Illustrated panels or a staged in-engine edit with final assets; see prompts below |
| UI theme | `scripts/ui/ui_kit.gd`, `prompt_hud.gd` | HUD, menus | temporary (coherent) | Original | Typography and iconography pass |
| Concept art | `assets/concept/characters/*.png` | Reference only | final (reference) | Owner-supplied | — |

### Production prompts for missing or temporary assets

- **Intro panels (6, 16:9, illustrated, restrained realism).** "Night, a clandestine hydrological research facility on the edge of a flooded city; cold blue light and one sodium lamp over a service tunnel; a woman scientist in a long teal coat with a backpack instrument case, seen from behind, entering; muted palette (slate blue, teal, sodium amber); painterly but grounded, no fantasy elements." Character design follows `elena_vast_concept.png`.
- **Ending panels (4).** "The same woman on an empty street above a sunken service yard at night; behind a gate, a tracked security robot with a red visor stands at the perimeter; floodlights switch on in sequence along the wall; she does not look back." The final card is typographic ("FINAL THAW STATION").
- **Recovery unit concept.** "Autonomous facility recovery robot, 1.9 m, tracked base, narrow upright chassis, mast with a wide horizontal sensor visor; industrial grey with amber hazard bands; clearly a machine, no face; folded manipulator arms; worn, maintained, municipal-utility feel."
- **Music.** Four stems, same key (D minor), loop-ready:
  - Investigation: 24 s; low drone, sparse glassy tones, unease without threat.
  - Tension: 72 bpm; heartbeat pulse, minor-second rub.
  - Chase: 128 bpm; driving bass ostinato and percussion, no melody.
  - Release: 10 s; open chord that settles.
- **SFX.**
  - Unit servo loop (electric drive whine with load).
  - Track thumps.
  - Alert stab: two rising tones, distinctive and short.
  - PA chime, three tones.
  - Compressor start-up and run loop.
  - Roller shutter.
  - Heavy gate clank.
  - Exterior night wind with distant traffic.
  - Footsteps by surface: concrete, grating, asphalt.
- **VO.** Elena: calm, precise, low voice; four lines (ES/EN) from `data/game_text.json`. PA: neutral synthetic female voice; five lines.

## Legacy — Flooded Shelter planning (2026-10 and earlier)

The tables below belong to the earlier Flooded Shelter slice and are kept for reference.

### Status legend (legacy)

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
