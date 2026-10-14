# FINAL THAW — Level Structure and Spatial Design Contract

**Status:** design authority for the current two-mission opening; Phase 2 design is specified below, but the parking prototype remains implementation evidence only. Not art-final, not runtime-verified, and not locked full-game canon.  
**Branch reviewed:** `feat/godot-vertical-slice`  
**Primary references:** `docs/VISION.md`, `docs/DESIGN_PIVOT_PROTOTYPE_BRIEF.md`, `docs/CORE_LOOP.md`, `docs/design/MOTION_CHASE_PROTOTYPE.md`, `docs/design/fase1_fase2_mapa_progresion.md`.

## 1. Design intent

The opening is a continuous causal sequence, not two unrelated test rooms:

1. **The Ghost Protocol — investigate and infer.** Elena reconstructs the manipulated Aster circuit and finds evidence that Helix withheld the test result.
2. **Containment — hide, then run.** Opening G starts the recovery operation, but the escape is not one uninterrupted sprint. Elena first moves quietly through occupied or recently occupied work areas, avoiding staff sightlines, noise and security attention. The quiet route passes through the observation walkway, S2 and M. Elena then takes the existing lift to P0; the recovery unit follows through that same lift and reacquires her at R1, the exposed transition from the P0 service gallery into the east return corridor. The experience shifts into a full running chase from there. The unit must be physically present and have real line of sight. R1 is the Phase 1 design target at the P0 service-gallery/east-return threshold (X≈29, Z≈1); the exact footprint/collider and the visible approach must match the progression graph and P0 plan. No mandatory combat or takedown.
3. **Parking chase — improvise and survive.** Elena reaches the service-side parking area; the threat continues into an exposed, vehicle-filled environment. The player must read sightlines, sound, cover and traversable routes, not simply run down an obstacle corridor.

The north star is **tension with agency**. Elena is a scientist, not a combat protagonist. The level should reward observation, spatial reasoning and movement decisions. No firearms, mandatory combat, arbitrary instant-kill hazards, invisible blockers, forced trial-and-error or unexplained teleport transitions.

This document defines the intended level experience. It does not claim that the current code implements it.

## 2. Spatial contract: Mission 2 parking area

### 2.1 Site identity

The parking area is the service forecourt of the same clandestine hydrological/industrial research facility. It must read as a plausible operational space used by staff, maintenance and emergency logistics—not a generic arena populated with cars. The broad central area in the concept is a **service/maneuvering apron**, not a conventional narrow parking aisle; justify its width with turning, loading or maintenance activity and use the parked rows, columns and technical cage to create cover and route choices.

The architecture should communicate:
- the laboratory service facade and the exit Elena has just used;
- a clear distinction between pedestrian/service routes and vehicle circulation;
- a primary vehicle aisle, marked parking bays, structural columns and parked vehicles;
- a controlled perimeter (fence, retaining wall, gate, security lighting or equivalent) that explains why Elena cannot simply leave in any direction;
- a far-side egress target that is visible or inferable early, but not immediately safe;
- one or more service features (loading shutter, maintenance cage, drainage channel, barrier or security kiosk) that give the site a specific industrial identity.

**Continuity rule:** the selected Phase 1 exit and the parking entry must connect physically and visually, but their world coordinates are not a design authority and must not dictate the interior route. Phase 1 may leave through a different service route and a different exterior mouth if that produces a stronger stealth-to-chase sequence. Lock the selected exit, local coordinate frames, transform and elevation only after the complete room route is approved. Never teleport Elena into the parking lot.

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

### 2.2.1 Provisional dimension schedule

The SVG uses a nominal 14 px per local metre in plan. This schedule records the dimensions implied by the concept, not verified construction dimensions. Parking coordinates are local; there is deliberately no locked world transform until the Phase 1 escape route and exit mouth are selected.

| Element | Concept dimension | Design intent / check |
|---|---:|---|
| Site boundary | 48 × 30 m | Retain only if service operations and two routes justify the footprint |
| Marked bay | 3.0 m wide × 5.0 m deep | Wider than a minimum stall to permit readable cover routes; validate total bay count and circulation |
| Parked car envelope | approx. 1.9 × 4.5 m | Static cover; doors/bonnets do not create walkable space |
| Structural column | 1.0 × 1.0 m footprint | Must not intrude into the required clear route or hide a required landing |
| Technical cage | approx. 5.6 × 3.4 m at local centre (32.1, 13.1) | Fixed service enclosure; route B passes east/north of it with ≥1.5 m target clearance; no route through the cage |
| Main central apron | approx. 17.3 m between the two parking rows | Deliberately a service/maneuvering apron, not a standard aisle; use the technical cage, cover clusters and exposed crossing to break the open area |
| Pedestrian pinch | target ≥1.2 m | Only at one clearly telegraphed, non-jump pinch; prefer ≥1.5 m for a fast turn |
| Primary route | target ≥2.0 m clear | Measured between collision surfaces, not visual prop bounds |
| Canopy headroom | 2.8 m shown in section | Optional design element; remove if unsupported by the facility program, but retain route and threat readability |
| Perimeter | wall/fence shown schematically | Height, gate opening, climbability and boundary collision remain to be specified against the threat and exit behavior |

Before design lock, add dimension strings for the narrowest clear passage on each route, the service-cage bypass and the final gate. The current SVGs now dimension the overall envelope, a representative 3.0 × 5.0 m bay, the 17.3 m central apron, the 1.3 m O3 aperture and the 3.6 m far-side egress; they still do not prove every internal clearance or the Phase 1 exterior threshold.

### 2.3 Required plan and section views

A first spatial concept is recorded in [parking_plan_concept.svg](design/assets/phase2_parking/parking_plan_concept.svg), with companion section, threat and landmark/lighting overlays. All four drawings form **concept package v0.2**: the 48 × 30 m envelope, routes, sightline sectors, light zones and prop placements are design proposals, not approved production geometry and not a representation of the current Godot scene. The entry threshold is a provisional 3 m concept opening, not a requirement that Phase 1 use the currently drawn mouth or its coordinates. The plan's local origin and scale support spatial review; they do not lock its rotation or world transform. Their purpose is to expose route topology and reviewable spatial questions. The programming owner must not copy these coordinates into code until the chosen exit, physical connection, clearances and elevation are reconciled.

The parking layout is not accepted from a prose description alone. Its design package must contain:
1. **Dimensioned plan:** boundaries, building facade, entry, exit, bays, vehicles, columns, obstacles, cover, lighting and patrol/sightline overlays.
2. **Section B–B:** [section_parking_concept.svg](design/assets/phase2_parking/section_parking_concept.svg) is a dimensioned north–south section through representative parking rows, the 17.3 m service apron, optional canopy and 2.8 m headroom target. It does not cut the service mouth or north egress gate; those are defined in plan. The exterior datum relative to P−1 remains unresolved; do not infer a ramp or step from this drawing.
3. **Spatial graph:** nodes, traversable edges, directed drops/climbs, blocked edges and route alternatives.
4. **Threat overlay:** [threat_sightline_overlay.svg](design/assets/phase2_parking/threat_sightline_overlay.svg) records a candidate physically bounded pursuit line, sightline sectors and search pockets. It is not a simulation of the final AI; update it whenever cover geometry or the reachable threat route changes.
5. **Landmark/lighting overlay:** [lighting_landmark_overlay.svg](design/assets/phase2_parking/lighting_landmark_overlay.svg) records the intended landmark chain L1–L5 and exposure/orientation zones. The zones are not photometric values or final light placements.

The Phase 2 asset family now includes the plan, transverse section, threat/sightline overlay and lighting/landmark overlay. They use the same local coordinate convention but remain concept v0.1; the next revision must add/check internal dimension strings and reconcile the exact exterior datum. Do not present a screenshot of the prototype as an architectural plan.

### 2.4 Provisional spatial graph

The following coordinates are derived from the concept plan only. Origin is the northwest inside corner; X increases east, Z increases south. Values are approximate metres and must not be copied into the production builder before a coordinate transform and Phase 1 handoff review.

| Node | Approx. coordinate (X, Z) | Spatial role | Connected nodes / rule |
|---|---:|---|---|
| P2-01 Service threshold | (5.3, 21.8) local | Exterior mouth plane at the west edge of the entry vestibule | To P2-02 via the vestibule; world orientation/transform remain unlocked until Phase 1 exit is selected |
| P2-02 Route decision | (9.3, 21.8) | First readable split | Branches to P2-A1 or P2-B1 |
| P2-A1 Direct aisle | (14.3, 19.3) | Short exposed path; turns north around the first column | To P2-A2; keep ≥1.2 m clear west of the column |
| P2-A2 Exposed crossing | (22.9, 19.3) | High-risk central-apron crossing | To P2-A3; retain recovery cover nearby |
| P2-A3 Southern bypass | (38.2, 19.6) | Southern bypass around P2-O2; still exposed | To P2-A4; minimum clear width 2.0 m |
| P2-A4 South-east turn | (40.7, 19.6) | Exposed 90-degree turn south of O2 before convergence | To P2-JOIN; keep 2.0 m clear and visible from approach |
| P2-B1 Service lane | (11.1, 13.9) | Covered route behind vehicle row | To P2-B2; narrower clearances |
| P2-B2 North cover chain | (25.9, 9.6) | Longer route with broken sightlines | To P2-B3 |
| P2-B3 Technical-cage bypass | (37.1, 12.1) | Service-side traversal east of the technical cage; does not pass through the cage | To P2-JOIN; maintain ≥1.5 m target clearance from the cage envelope |
| P2-JOIN Convergence | (40.7, 16.8) | Both routes rejoin | To P2-05A |
| P2-05A Barrier approach | (44.3, 16.8) | Clear approach south of the barrier, with the 1.3 m aperture visible ahead | To P2-05; keep the approach collision-free |
| P2-05 Service bottleneck | (44.3, 14.8) | Partially lowered service barrier with a fixed, visible 1.3 m clear aperture | To P2-06 through the aperture; no timed slide or moving collision across a player already inside |
| P2-06 Egress approach | (44.3, 5.0) | Final approach, visible from mid-level | To P2-EXIT |
| P2-EXIT Boundary | (42.8, 1.8) | Physical escape threshold | Mission completion only after crossing actual boundary |

**Graph constraints:** all edges are bidirectionally traversable unless explicitly marked otherwise; no drop, climb, jump or squeeze is implied by a line alone. For every edge, the final graph must state clear width, elevation, traversal verb, threat accessibility, sightline condition, fail/recovery behavior and whether it is part of the intended fast route. The current concept has no approved one-way drop.

The concept section is available at [section_parking_concept.svg](design/assets/phase2_parking/section_parking_concept.svg). The transform `X+28.7 / Z−15.8` is withdrawn: it was derived from one provisional Phase 1 mouth before the stealth route, reacquisition trigger and escape pacing were closed. The Phase 2 drawings use local coordinates only. The current Phase 1 design requires a physically connected exit distinct from the west entrance, but its exact mouth is not locked; once the stealth route, chase trigger and exterior exit are selected, derive one transform from the real threshold width, orientation and elevation. The current prototype starts near `(X=34.5, Z=0)` and its builder has only a 14 m corridor half-width of 7 m; these are implementation facts to reconcile, not reasons to force the architecture to the old prototype.

### 2.5 Provisional edge and clearance contract

These are design targets for the concept graph, not measured clearances in the current prototype. Clear width means the narrowest continuous collision-free path, excluding cover that intentionally occupies the route.

| Edge | Traversal | Target clear width | Sightline / exposure | Recovery and threat rule |
|---|---|---:|---|---|
| P2-01 → P2-02 | Walk/run, no jump | ≥2.0 m | Entry is briefly sheltered by facade | Threat enters only through the actual connected Phase 1 exit; no spawn in front of Elena |
| P2-02 → P2-A1 → P2-A2 | Direct walk/run | ≥3.5 m at aisle; ≥1.5 m at turns | High exposure across the central aisle | Nearest cover cluster remains reachable; threat may pursue only along visible, traversable aisle |
| P2-02 → P2-B1 → P2-B2 | Walk/crouch where needed | ≥1.2 m at the single authored pinch; otherwise ≥1.5 m | Broken sightline behind parked vehicles | No required jump; player can retreat to P2-02 until the final commitment |
| P2-B2 → P2-B3 | Walk/run around technical cage | ≥1.5 m | Intermittent exposure through column gaps | Cage cannot become a dead end; enemy must take the same valid bypass or search the last-known position |
| P2-A2 → P2-A3 → P2-A4 → P2-JOIN / P2-B3 → P2-JOIN | Walk/run; direct route passes south of P2-O2 and turns north at P2-A4 | ≥2.0 m clear width at bypass and convergence | Direct route stays exposed; service route keeps more broken sightlines | Show the southern bypass from approach; keep the 1.3 m barrier aperture unobstructed; no hidden collision lip |
| P2-JOIN → P2-05A | Walk/run along the open apron | ≥2.0 m | The barrier opening is visible ahead | No obstruction or forced crouch on approach |
| P2-05A → P2-05 → P2-06 → P2-EXIT | Walk/run through service egress | ≥1.2 m at the fixed O3 aperture, ≥2.0 m otherwise | Final approach is exposed but readable from earlier landmark | No frame-perfect timing; the 1.3 m aperture stays open and collision-free; any future blocked state requires a drawn bypass |

No jump or climb is currently required by the parking concept. Do not import the prototype's 1.8 m/3.0 m gaps into this level simply because they exist in the mechanics test. If a jump, climb or squeeze is later added, it needs an approach/landing diagram and a measured capability test.

### 2.6 Landmark, lighting and sound schedule

All positions below use the local plan coordinates. These are design placements, not light-node coordinates for direct code copying.

| ID | Approx. local position (X, Z) | Visual/audio role | Required player reading |
|---|---:|---|---|
| L1 / S1 Service mouth | (6.8, 21.8) | Stable cool spill light; pump/ventilation sound recedes as exterior ambience emerges | The player can orient toward the apron and identify the facility facade behind them |
| L2 / S2 Central apron | (22.0, 15.0) | Hard, stable security-light pools; a short relay/actuator cue may signal a state change | The direct route is exposed; lighting does not imply that the illuminated route is safe |
| L3 / S3 Technical-cage bypass | (37.1, 12.1) | Restrained amber service indicator east of the cage; local electrical/mechanical hum | The covered route has a real operational purpose and is not a decorative dead end |
| L4 / S4 Bottleneck | (44.3, 14.8) | Barrier state has both a visible position and an audible actuator/denial cue | The player understands the available aperture and bypass before committing |
| L5 / S5 Egress landmark | (42.8, 1.8) | Clear silhouette/backlight with no overexposed bloom; gate/perimeter sound | The goal is inferable early, but crossing the boundary is still a physical action |

Lighting must preserve dark adaptation and camera readability. No strobing alarm, colour-only threat cue or pitch-black required route. Critical sounds (unit entering, barrier movement, alert state) need visual equivalents; critical visual state changes need an audio or text alternative where feasible. Use sound to reinforce distance and state, never to provide the only route instruction.

### 2.7 Checkpoint and retry contract

The concept plan marks three provisional anchors: **S** at the service entry, **CP1** at P2-JOIN after both routes converge, and **CP2** at the egress approach before the final bottleneck. These are design locations, not current code checkpoints.

| Anchor | Local coordinate (X, Z) | Purpose | Activation rule |
|---|---:|---|---|
| S / entry spawn pocket | (6.8, 21.8) local; target world (35.5, 6) | Safe spawn point 1.5 m inside the 3 m service threshold | Set by the integrated scene; do not spawn on the threshold collider or replay the standalone corridor |
| CP1 | (40.7, 16.8) | Avoid replaying both route branches after the player has completed the main traversal | Activate only after Elena physically enters the convergence pocket |
| CP2 | (44.3, 5.0) | Keep the final bottleneck/egress attempt short after the player reaches the last safe approach | Activate before the final committed crossing, not after an untelegraphed hazard |

On catch/fall/retry, restore Elena to the anchor with zero velocity, restore a fair threat state at a physically reachable position, clear transient alert/search timers and ensure the unit does not have an automatic fresh sightline to the respawn point. Preserve the current mission's in-memory puzzle/story knowledge; a retry must not silently erase the Aster discovery or add a new persistent save field. Reinitialize local obstacle states only if their state is consistent with the anchor; do not reset a barrier behind the player or place a collision over the respawn capsule.

Before acceptance, test each anchor with repeated catches, pause/restart and scene exit. Record the actual retry duration and verify that no checkpoint is inside a collider or enemy catch radius. The entry checkpoint must be translated with the approved world transform, not copied from the current prototype's old `(34.5, 0, 0)` value.

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
**Player action:** pass through the fixed, visibly open 1.3 m aperture in the service barrier. The current concept does not include a separate bypass; do not make the aperture close dynamically or require a timed slide.  
**Design purpose:** a final physical decision tied to the site's logistics.  
**Rules:** the obstacle must have a plausible architectural cause and a clear interaction affordance. Avoid a key hunt, a new unrelated puzzle or an unannounced dead end.

### Beat P2-06 — Escape and aftermath
**Player action:** cross the actual boundary and reach a safe transition point.  
**Design purpose:** deliver release without implying that the larger conflict is resolved.  
**Narrative result:** the immediate recovery unit is evaded; Helix's ability to identify and track Elena remains a threat. End with a short, authored beat that changes the player's understanding or stakes, not a generic “level complete” message.

The plan labels O1/O2/O3 correspond to provisional register entries P2-O1/P2-O2/P2-O3. Their IDs are stable design references, but their placements and dimensions are not production-locked until plan, section, graph and actual collision envelopes are reconciled. The design no longer assumes the player arrives from a specific Phase 1 coordinate; the final parking entry is to be transformed or redrawn around the selected exit, not vice versa. The final number and placement of physical obstacles remain subject to playtest. Each final obstacle must have a stable ID (P2-O1, P2-O2, …), measured footprint, approach, intended solution, alternate/recovery solution, collision envelope, camera risks, narrative function and acceptance test.

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

### 4.1 Provisional obstacle register

These entries turn the concept symbols into reviewable design proposals. Their positions and dimensions are **not locked** until the plan, collision envelope and actual player/camera are reconciled.

| ID | Approx. position (X, Z) | Proposed physical element | Intended decision | Fairness and recovery contract |
|---|---:|---|---|---|
| P2-O1 | (13.3, 13.4) | Abandoned maintenance cart/pallet, approx. 1.9 × 2.1 m footprint, intruding into the covered service lane | Read the remaining side clearance and choose to walk around rather than sprint blindly | Keep a visibly continuous passage of at least 1.2 m; no hidden collision protrusions; route remains recoverable if detected |
| P2-O2 | (36.9, 17.0) | Displaced service equipment rack, approx. 3.0 × 2.0 m footprint, between the routes near convergence | Use it as cover; Route A passes south of it while Route B approaches from the north-east | Must not intersect either route's minimum clear envelope; it changes sightline but does not block route connectivity |
| P2-O3 | (44.3, 14.8) | Partially lowered service barrier; plan shows a fixed 1.3 m clear aperture | Read the opening and pass through without a timed slide | Validate player/camera/threat clearance; aperture never closes on a character; any impassable variant needs a dimensioned bypass in plan and graph |

No obstacle is approved merely because it appears in the SVG. Before implementation, the design owner must review each item's measured footprint, approach view, collision shape, camera behavior, player and enemy traversability, audio/visual tell, alternative, checkpoint relationship and acceptance test. If an obstacle changes, update the plan, section/overlay, graph, register and traceability together.

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

The parking area should add a new fact, not repeat the same revelation. The current opening brief defines the causal trigger: the maintenance interaction queues `SERVICE_OVERRIDE` as separate mission state; opening the exterior leaf of G sends the queued audit and starts Containment. The specific recipient, chain of command and degree of human supervision remain open. The recommended story function for the parking area is to show that the response is operationally coordinated through door, light or access-state changes. This broader implication is a **design proposal**, not locked canon, and must not identify a named person as responsible.

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
`G → quiet evasion through F/E and potentially occupied work areas → mapped reacquisition threshold → running chase through service circulation → approved alternative exterior exit → parking entry → parking chase → far-side egress`.

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
- [ ] Threat path, candidate sightlines, search pockets, audio investigation points and enemy-accessible routes agree with the final cover geometry; the overlay is updated from measured geometry, not left as a schematic.
- [ ] Landmark chain L1–L5 is visible from the intended decision points under the actual camera; lighting supports orientation and risk without hiding collisions or relying on colour alone.
- [ ] Every beat has a player verb, spatial requirement, risk/reward, feedback and narrative purpose.
- [ ] The route reveals the goal early and communicates safe/unsafe options before commitment.
- [ ] Story facts are separated from proposals and legacy material; no unsupported canon is asserted.
- [ ] Required visual, audio, UI, accessibility and failure-state behavior is specified.
- [ ] Every criterion is mapped to an implementation owner and observable verification method.
- [ ] The design package has been reviewed against the current code and all mismatches are logged.

**Implementation-verified** is a separate gate: run the Godot scene and tests, manually play all routes, inspect camera/collisions/AI/audio, and record engine version, renderer, commit, exact commands/results, defects and evidence. Static documentation does not pass this gate.

## 10. Current implementation boundary

The existing `scenes/prototypes/phase2_parking_chase.tscn` wraps the motion/chase prototype with `parking_entry_mode=true` and `initial_checkpoint_index=2`. The builder uses a linear X-axis course, floor half-depth 7 m, a checkpoint near `(34.5, 0, 0)`, and an exit threshold at X=78 m. The parking concept is a separate 48 × 30 m local-coordinate proposal; no world coordinates are locked. After the Phase 1 room route and exit mouth are approved, reconcile the parking entrance, checkpoint, elevation and route against that actual threshold. Do not force the interior route to fit the old prototype. The gaps, tunnel, duct and climb belong to the mechanics prototype and are not automatically required in the parking level.

The current implementation and tests must be inspected and executed by the programming owner. Until evidence is supplied, do not claim that the route is playable, that alternate routes are balanced, that the AI is fair, or that the design is runtime-verified.
