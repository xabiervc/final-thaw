# FINAL THAW — Level Structure and Spatial Design Contract

**Status:** design authority for the current two-mission opening; Phase 2 design is specified below, but the parking prototype remains implementation evidence only. Not art-final, not runtime-verified, and not locked full-game canon.  
**Branch reviewed:** `feat/godot-vertical-slice`  
**Primary references:** `docs/VISION.md`, `docs/DESIGN_PIVOT_PROTOTYPE_BRIEF.md`, `docs/CORE_LOOP.md`, `docs/design/MOTION_CHASE_PROTOTYPE.md`, `docs/design/fase1_fase2_mapa_progresion.md`.

## 1. Design intent

The opening is a continuous causal sequence, not two unrelated test rooms:

1. **The Ghost Protocol — investigate and infer.** Elena reconstructs the manipulated Aster circuit and finds evidence that Helix withheld the test result.
2. **Containment — escape under pressure.** Opening the exterior leaf of G exposes Elena to a recovery operation. She retreats through the laboratory, descends through the existing service circulation and leaves through the distinct P−1 evacuation outlet.
3. **Parking chase — improvise and survive.** Elena reaches the service-side parking area; the threat continues into an exposed, vehicle-filled environment. The player must read sightlines, sound, cover and traversable routes, not simply run down an obstacle corridor.

The north star is **tension with agency**. Elena is a scientist, not a combat protagonist. The level should reward observation, spatial reasoning and movement decisions. No firearms, mandatory combat, arbitrary instant-kill hazards, invisible blockers, forced trial-and-error or unexplained teleport transitions.

This document defines the intended level experience. It does not claim that the current code implements it.

## 2. Spatial contract: Mission 2 parking area

### 2.1 Site identity

The parking area is the service forecourt of the same clandestine hydrological/industrial research facility. It must read as a plausible operational space used by staff, maintenance and emergency logistics—not a generic arena populated with cars.

The architecture should communicate:
- the laboratory service facade and the exit Elena has just used;
- a clear distinction between pedestrian/service routes and vehicle circulation;
- a primary vehicle aisle, marked parking bays, structural columns and parked vehicles;
- a controlled perimeter (fence, retaining wall, gate, security lighting or equivalent) that explains why Elena cannot simply leave in any direction;
- a far-side egress target that is visible or inferable early, but not immediately safe;
- one or more service features (loading shutter, maintenance cage, drainage channel, barrier or security kiosk) that give the site a specific industrial identity.

**Continuity rule:** the P−1 evacuation mouth and the parking entry must meet physically and visually. The player must be able to understand which side of the building they have emerged from. The exterior transition must not place Elena in the middle of the parking lot without a traversable connection.

### 2.2 Greybox scale and coordinate contract

The existing motion/chase builder uses an approximately 82 m long linear corridor and places its last segment in a parking-like setting. This is a prototype measurement, not an approved architectural footprint. Do not silently treat its current dimensions as canonical parking architecture.

For the parking level, author a measured plan before expanding the builder. The plan must include:
- overall boundary and dimensions;
- entry point from Phase 1 and exit/goal point;
- vehicle aisle widths and bay depth/width;
- column footprints and clear distances;
- vehicle envelopes with doors/bonnets treated as non-traversable unless explicitly designed otherwise;
- pedestrian clearance around vehicles and at every route pinch point;
- sightline and cover sectors for the recovery unit;
- obstacle envelopes, jump/climb envelopes, landing zones and recovery/checkpoint locations;
- wall, fence and gate heights; any overhangs or low ceilings;
- lighting fixtures, shadows and high-contrast navigation landmarks.

**Provisional greybox targets, to be checked against the real player capsule and third-person camera before lock:**
- principal walk/run aisle: target 3.5–4.5 m clear;
- pedestrian bypass around a parked vehicle: target at least 1.2 m clear, preferably 1.5 m where the chase demands a fast turn;
- ordinary door/gate clear opening: target at least 1.2 m;
- route headroom: target at least 2.2 m, with no camera trap at low geometry;
- major route decision: enough space to read the options before committing.

These are design targets, not verified measurements. Any deviation must be recorded with its gameplay reason and tested in the actual scene. The level designer must not compress circulation to preserve the old corridor length.

### 2.3 Required plan and section views

The parking layout is not accepted from a prose description alone. Its design package must contain:
1. **Dimensioned plan:** boundaries, building facade, entry, exit, bays, vehicles, columns, obstacles, cover, lighting and patrol/sightline overlays.
2. **Longitudinal section:** elevation changes, ramps, barriers, low clearances, roof/awning edges and camera-relevant occlusion.
3. **Spatial graph:** nodes, traversable edges, directed drops/climbs, blocked edges and route alternatives.
4. **Threat overlay:** patrol path, investigation points, alert sightlines, chase shortcuts, search pockets and no-go zones.
5. **Landmark/lighting overlay:** what the player can see from entry and each critical decision point, by day/night or emergency-light state as appropriate.

The existing project has Phase 1 plan/section SVGs. Extend the same disciplined visual conventions for Phase 2 in the existing architecture asset family once the parking dimensions are resolved; do not present a screenshot of the prototype as an architectural plan.

## 3. Parking route topology and encounter sequence

The parking area must be a compact, legible route network with meaningful risk differences. It should not be a single 80 m straight sprint with decorative cars.

### Beat P2-01 — Emergence and orientation
**Entry:** service exit from Phase 1.  
**Player learns:** the escape route has brought Elena outside, but not to safety.  
**Spatial requirement:** establish the service facade, the parking aisle and the distant egress target in one readable composition. Give the player a brief orientation window before the threat reaches the same space.  
**Threat:** audio or light response signals pursuit; do not spawn an enemy in an unexplained position or let it acquire Elena through the building.

### Beat P2-02 — First cover decision
**Player action:** choose between a more direct exposed aisle and a slower route through parked vehicles/columns.  
**Design purpose:** teach that cover blocks line of sight but not necessarily sound.  
**Fairness:** silhouettes, column rhythm, headlight/security-light contrast and the enemy's facing direction must communicate risk. The direct route must remain possible for a confident player; the covered route must be useful, not mandatory busywork.

### Beat P2-03 — Vehicle-row traversal
**Player action:** thread through vehicle bays, columns and one clearly signposted service obstruction.  
**Design purpose:** convert the parking architecture into a movement puzzle. The player reads clearances and chooses when to crouch, walk or run.  
**Rules:** no random car alarms unless authored and telegraphed; no collision-only gaps that appear passable; no required jumps over car bodies unless the landing and animation are designed and tested. Vehicles are static cover, not physics hazards that move unpredictably.

### Beat P2-04 — Exposed crossing
**Player action:** cross a sightline between cover clusters, using timing, a distraction from an environmental source or a short sprint.  
**Design purpose:** create a legible high-risk/high-speed decision.  
**Rules:** the threat's detection cone, alert buildup and audio tell must be understandable. Do not require frame-perfect timing. At least one recovery option must exist if the player is detected early.

### Beat P2-05 — Service bottleneck
**Player action:** pass a narrow but readable egress mechanism (for example a half-open service shutter or vehicle barrier) with an authored route around or through it.  
**Design purpose:** a final physical decision tied to the site's logistics.  
**Rules:** the obstacle must have a plausible architectural cause and a clear interaction affordance. Avoid a key hunt, a new unrelated puzzle or an unannounced dead end.

### Beat P2-06 — Escape and aftermath
**Player action:** cross the actual boundary and reach a safe transition point.  
**Design purpose:** deliver release without implying that the larger conflict is resolved.  
**Narrative result:** the immediate recovery unit is evaded; Helix's ability to identify and track Elena remains a threat. End with a short, authored beat that changes the player's understanding or stakes, not a generic “level complete” message.

The number and placement of physical obstacles remain subject to plan and playtest. Each final obstacle must have a stable ID (P2-O1, P2-O2, …), measured footprint, approach, intended solution, alternate/recovery solution, collision envelope, camera risks, narrative function and acceptance test.

## 4. Route alternatives and threat fairness

The level must support at least two meaningfully different routes between the first cover decision and the service bottleneck:
- **Direct/exposed route:** shorter and easier to read, but with more time in line of sight and fewer hiding pockets.
- **Covered/service route:** longer or more physically constrained, but offers broken sightlines and lower exposure; it must not be universally superior.

The route graph must state the risk trade-off for every branch. A route is not an alternative if it rejoins before changing exposure, traversal demand or timing.

The recovery unit must obey bounded knowledge:
- vision requires a valid cone, range and clear line of sight;
- sound produces investigation of a location, not perfect tracking;
- after losing sight, the unit pursues the last known position and searches plausible nearby cover;
- it does not know Elena's live coordinates through walls or closed shutters;
- the unit respects physical barriers, columns, vehicles, ledges and traversable gaps;
- any shortcut it uses must be visible in the plan and physically reachable;
- alert state has a legible visual and audio tell before full chase;
- contact/failure returns Elena to a defined checkpoint without corrupting mission state or causing a long replay.

The scanner remains a tactical trade-off: charge time, brief reveal and cooldown should make the player choose when to stop and gather information. It must not outline the correct route continuously or trivialize the threat.

## 5. Architectural language, props and visual storytelling

### 5.1 Material and form hierarchy

The facility exterior and parking area should use a controlled industrial vocabulary: reinforced concrete, painted steel, galvanized service elements, drainage channels, safety markings, utility cabinets, worn bay numbers and weathered but maintained infrastructure. Abandonment is selective: some areas are neglected, while security equipment and containment systems remain active.

Use three levels of visual information:
- **Primary navigation:** facade openings, aisle direction, lighting pools, large numbered bays and the exit silhouette.
- **Secondary gameplay:** columns, vehicles, shutters, barriers, service equipment and cover boundaries.
- **Tertiary narrative:** incident labels, staff traces, maintenance tags, a hastily abandoned cart, a damaged access reader, or evidence of a hurried response.

Props must tell a consistent story. Avoid random debris piles, repeated asset dressing, meaningless warning signs and clutter that obscures collision or cover rules.

### 5.2 Lighting and colour

Lighting is functional, not merely decorative:
- service exit: cooler, stable spill light to preserve route recognition;
- active security zone: harder pools and clear sightline silhouettes;
- cover pockets: enough contrast to communicate concealment without making the player invisible to themselves;
- egress: a distinct but not over-bright landmark visible from the middle encounter;
- alarm/emergency state: a restrained state change tied to containment, not continuous red flashing that harms readability.

Do not use colour alone for threat state or route safety. Pair it with shape, symbol, animation, audio and environmental context. Check the level under the actual renderer and camera, including low-quality graphics settings.

### 5.3 Soundscape

Build a sound hierarchy:
1. immediate threat cues (unit movement, alert, search, footsteps);
2. player feedback (footsteps by surface/speed, landing, scan, interaction denial);
3. environmental bed (ventilation, distant pumps, electrical hum, rain/wind only if the setting supports it);
4. narrative cues (containment signal, distant gate, vehicle/door mechanism).

Audio must communicate distance/state without making silent play impossible. Provide visual equivalents for important audio-only information and subtitle/transcription treatment for any narrative voice or intelligible announcement.

## 6. Narrative and story contract

### 6.1 What is established

- Elena Vast is a scientist/investigator, not a soldier.
- Aster is a consequential research project whose test result was manipulated or withheld.
- Helix is capable of initiating a recovery/containment response.
- Mission 1 reveals evidence and triggers a causal transition into escape.
- Mission 2 continues the escape into a service parking area.
- The prototype-led redesign has not yet locked the complete campaign, Marcus's role, chronology, endings or the full explanation of Helix.

### 6.2 Mission 2 narrative question

**Can Elena get beyond the facility's immediate recovery perimeter after discovering that the Aster record was deliberately suppressed?**

The parking area should add a new fact, not repeat the same revelation. The current opening brief defines the causal trigger: maintenance queues `SERVICE_OVERRIDE`; crossing the exterior leaf of G sends the queued audit and starts Containment. The specific recipient, chain of command and degree of human supervision remain open. The recommended story function for the parking area is to show that the response is operationally coordinated through door, light or access-state changes. This broader implication is a **design proposal**, not locked canon, and must not identify a named person as responsible.

### 6.3 Beat-to-information contract

| Beat | Story information | Delivery | What must remain unresolved |
|---|---|---|---|
| Emergence | The facility's service perimeter is controlled | Architecture, signage, lighting, sound | Who authorized this specific response |
| First cover decision | The recovery unit is searching, not randomly attacking | Enemy behaviour and bounded perception | Full Helix chain of command |
| Vehicle-row traversal | The site was in operational use shortly before the incident | Staff traces, fleet/service labels, interrupted routine | Exact timeline of evacuation |
| Exposed crossing | Containment adapts to Elena's presence | A visible change in security state, not omniscient AI | Whether the response is automated or directly supervised |
| Service bottleneck | The intended egress is restricted for a plausible operational reason | Barrier/shutter state and maintenance markings | How far the suppression operation reaches |
| Escape | Elena is outside the immediate perimeter but still at risk | Short aftermath beat, sound/visual continuation | Campaign-level resolution and Marcus's role |

No narrative beat may depend on reading an optional document during a chase. Core information is communicated through action, visual state, mandatory short dialogue/VO if any, or a recap accessible after the encounter.

### 6.4 Elena's agency and characterization

Elena's competence comes from noticing patterns and making constrained decisions. Do not make her deliver exposition while sprinting, perform implausible combat, or solve the situation through unexplained hacking powers. Her emotional state should be conveyed with short, context-specific reactions and physical hesitation only when control remains fair.

Any voice line must have a trigger, exact text or approved intent, delivery timing, subtitle, skip/replay policy and a gameplay-safe window. Avoid continuous chatter that explains what the player can already see.

### 6.5 Continuity from Phase 1

The canonical handoff is:
`G → interior pursuit → F/E retreat → S2 → M → existing lift → P0 → S1 → P−1 → evacuation gallery → exterior service mouth → parking entry → parking chase → far-side egress`.

This is the intended narrative/spatial sequence. The existing parking prototype's standalone start and checkpoints are test infrastructure, not proof of this integrated route. The integrated scene must spawn Elena at the parking entry checkpoint and must not replay the earlier corridor or reset mission evidence without an explicit persistence decision.

## 7. Functional contract and failure recovery

- Movement options must be readable from geometry and contextual cues.
- Every jump, climb, crouch or squeeze has a visible approach and safe/understandable landing or recovery.
- A player caught by the unit returns to the most recent fair checkpoint; elapsed-time/catch counters may reset only if the HUD communicates that policy.
- Checkpoints must not place Elena in direct detection range without a fair alert window.
- The scanner's charge/reveal/cooldown behavior must match the UI and audio.
- Pausing, restarting and returning to menu must behave consistently with the current scene contract.
- No new save fields or save-schema changes are implied by this design. Any persistent story flag requires an explicit decision and compatibility review.
- No gameplay-critical clue may rely on colour alone, a particular audio channel, or a single optional scan.
- A detected player must retain a plausible route to recover unless the level explicitly and fairly enters a failure state.

## 8. Required design deliverables and ownership boundary

The programming owner implements code. The design owner defines and reviews:
- dimensioned Phase 2 plan and relevant section;
- spatial graph and threat/sightline overlay;
- obstacle register with measurements and alternatives;
- mission beats, narrative information and continuity;
- prop/material/lighting/audio direction;
- HUD, feedback and accessibility expectations;
- traceability from every design requirement to scene behavior and test;
- manual playtest script and acceptance criteria.

Do not create parallel documents when an existing authority can be updated. Keep `LEVEL_STRUCTURE.md` as the opening level-structure authority, `CORE_LOOP.md` for gameplay behavior, `DESIGN_AUTHORITY.md` for precedence, and `TRACEABILITY_MATRIX.md` for requirement-to-evidence mapping.

## 9. Acceptance gate for Phase 2 design

**Design-complete** means all of the following are documented and mutually consistent:
- [ ] Dimensioned plan, section, coordinate convention and spatial graph agree.
- [ ] Phase 1 exit and parking entry form a continuous, traversable boundary.
- [ ] All route branches, checkpoints, obstacles, collision envelopes and recoveries are defined.
- [ ] Enemy patrol, hearing, vision, last-known-position behavior and accessible routes are overlaid on the plan.
- [ ] Every beat has a player verb, spatial requirement, risk/reward, feedback and narrative purpose.
- [ ] The route reveals the goal early and communicates safe/unsafe options before commitment.
- [ ] Story facts are separated from proposals and legacy material; no unsupported canon is asserted.
- [ ] Required visual, audio, UI, accessibility and failure-state behavior is specified.
- [ ] Every criterion is mapped to an implementation owner and observable verification method.
- [ ] The design package has been reviewed against the current code and all mismatches are logged.

**Implementation-verified** is a separate gate: run the Godot scene and tests, manually play all routes, inspect camera/collisions/AI/audio, and record engine version, renderer, commit, exact commands/results, defects and evidence. Static documentation does not pass this gate.

## 10. Current implementation boundary

The existing `scenes/prototypes/phase2_parking_chase.tscn` wraps the motion/chase prototype with `parking_entry_mode=true` and `initial_checkpoint_index=2`. The builder uses linear floor segments, a small number of gaps, a low tunnel, a duct, a climb and a final exit threshold; parking dressing consists of bays, vehicles and columns. This is a useful mechanics prototype, not the completed architectural level specified here.

The current implementation and tests must be inspected and executed by the programming owner. Until evidence is supplied, do not claim that the route is playable, that alternate routes are balanced, that the AI is fair, or that the design is runtime-verified.
