> **Rediseño espacial acordado (2026-10-16):** la propuesta de Fase 1 pasa a una huella conceptual de 48 × 34 m, con nave central de laboratorio de 6–8 m de altura libre, mezzanine parcial en ala lateral y ala superior P+3 que preserva el vacío central. Las cotas P−2 = −4,00 m, P0 = ±0,00 m, M = +1,50 m y P+3 = +3,00 m son cotas de suelo, no alturas libres. Se conserva la investigación Aster y el cuaderno de campo. La puerta de transferencia al edificio clandestino queda en el muro oriental del taller muerto de P−2; se descubre mediante indicios, pero solo se cruza con TRANSFER_KEY, PowerRestored y el registro Aster consultado. La cadena de transferencia (nota → armario seco del almacén → llave) es independiente de la cadena eléctrica (llave de servicio + puente → subestación → energía). Véanse [FASE1_ARCHITECTURAL_LAYOUT.md](design/FASE1_ARCHITECTURAL_LAYOUT.md), [FASE1_SPATIAL_GRAPH.md](design/FASE1_SPATIAL_GRAPH.md) y [fase1_fase2_mapa_progresion.md](design/fase1_fase2_mapa_progresion.md). Todo lo anterior es objetivo de diseño, no evidencia de implementación; los contratos de runtime, guardado y sistemas existentes permanecen protegidos salvo revisión explícitamente aprobada.

# FINAL THAW — Level Structure and Spatial Design Contract

> **v4.0 note (2026-10-15, as-built):** The Phase 2 yard is built (section 10). STAFF-M1 was removed from the quiet section; the recovery unit's suspicion stage replaces it. See [FASE1_PREMIUM_AUDIT.md](design/FASE1_PREMIUM_AUDIT.md) (v4.0).

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

**Continuity rule — selected design baseline:** the Phase 1 P−1 gallery exits east at world X=34, Z=4.5..7.5, Y=−2.0 m, through a 3 m opening. The parking vestibule begins at the same threshold; the selected transform is world X=local X+28.7 m, world Z=local Z−15.8 m, Y=−2.0 m. This maps the threshold to local (5.3, 21.8), the recovery checkpoint to world (35.5, 6), and the far-side egress beyond the north gate to (71.5, −16.2). Initial handoff stays at the threshold; the checkpoint is for recovery only. These are design-baseline coordinates, not runtime evidence. Validate the actual gallery, opening, elevation, colliders and camera in Godot; if the scene differs, update all affected drawings together. Never teleport Elena into the parking lot.

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

The SVG uses a nominal 14 px per local metre in plan. This schedule records the dimensions implied by the concept, not verified construction dimensions. Parking coordinates are local with the selected design transform X_world=X_local+28.7 m and Z_world=Z_local−15.8 m; verify it against the actual Phase 1 exit before implementation.

| Element | Concept dimension | Design intent / check |
|---|---:|---|
| Combined facade/site envelope | 48 × 30 m | Includes the 5.3 m facade band; clear parking yard is 42.7 m east of the service threshold. The 30 m Z depth is clear between inner north/south wall faces |
| Marked bay | 3.0 m wide × 5.0 m deep | Wider than a minimum stall to permit readable cover routes; validate total bay count and circulation |
| Parked car envelope | approx. 1.9 × 4.5 m | Static cover; doors/bonnets do not create walkable space |
| Pipe-rack support column | 1.0 × 1.0 m footprint at each inner parking-row edge | Supports overhead service pipes; no continuous canopy. Maintain 2.8 m clear below rack and keep the central apron open |
| Technical cage | approx. 5.6 × 3.4 m at local centre (32.1, 13.1) | Fixed service enclosure; route B passes east/north of it with ≥1.5 m target clearance; no route through the cage |
| Main central apron | approx. 17.3 m between the two parking rows | Deliberately a service/maneuvering apron, not a standard aisle; use the technical cage, cover clusters and exposed crossing to break the open area |
| Pedestrian pinch | target ≥1.2 m | Only at one clearly telegraphed, non-jump pinch; prefer ≥1.5 m for a fast turn |
| Primary route | target ≥2.0 m clear | Measured between collision surfaces, not visual prop bounds |
| Overhead service pipe racks | At the inner edges of the two parking rows; 2.8 m clear below | Two linear pipe racks supported by the column rows; the central apron remains open-air, with no continuous canopy |
| Perimeter walls | 0.3–0.5 m thick; 2.4 m high above pavement | Non-climbable in the baseline; the 3.6 m north egress is the only far-side opening. Verify collision and gate continuity in Godot |

The drawings now dimension the overall envelope, a representative 3.0 × 5.0 m bay, the 17.3 m central apron, O1/O2 footprints, the 1.3 × 2.2 m O3 aperture and the 3.6 m far-side egress. The plan records target clearances of O1 ≥1.2 m, O2 route ≥1.5 m and a 2.6 m nominal service-cage bypass; these are geometric targets, not verified collision envelopes, and must be checked against the actual player capsule and camera before production lock.

### 2.3 Required plan and section views

The selected spatial baseline is recorded in [parking_plan_concept.svg](design/assets/phase2_parking/parking_plan_concept.svg), with companion section, threat and landmark/lighting overlays. All four drawings form **concept package v0.3**: the 48 × 30 m envelope, routes, sightline sectors, light zones and prop placements are design proposals, not approved production geometry and not a representation of the current Godot scene. The entry threshold is a 3 m opening matched to the selected P−1 service mouth. The plan's local origin and scale are mapped to the selected world transform stated above; runtime verification is still required. Their purpose is to expose route topology and reviewable spatial questions. The programming owner must not treat these coordinates as runtime-verified until the selected exit, physical connection, clearances and elevation have been checked against the canonical scene.

The parking layout is not accepted from a prose description alone. Its design package must contain:
1. **Dimensioned plan:** boundaries, building facade, entry, exit, bays, vehicles, columns, obstacles, cover, lighting and pursuit/sightline overlays.
2. **Section B–B:** [section_parking_concept.svg](design/assets/phase2_parking/section_parking_concept.svg) is a dimensioned north–south section at local X≈36 m through representative vehicles, both overhead pipe-rack supports, O2 and the 17.3 m open service apron; 2.8 m clearance is measured below the racks. No continuous canopy is part of the baseline. It does not cut the service mouth or north egress gate; those are defined in plan. The selected datum is Y=−2.0 m, continuous with P−1; no ramp or step is intended at the service mouth. Verify the elevation in Godot.
3. **Spatial graph:** nodes, traversable edges, directed drops/climbs, blocked edges and route alternatives.
4. **Obstacle detail sheet:** [obstacle_detail_sheet.svg](design/assets/phase2_parking/obstacle_detail_sheet.svg) defines the plan/elevation envelopes for O1, O2 and O3, including the 1.3 × 2.2 m O3 aperture.
5. **Threat overlay:** [threat_sightline_overlay.svg](design/assets/phase2_parking/threat_sightline_overlay.svg) records a candidate physically bounded pursuit line, sightline sectors and search pockets. It is not a simulation of the final AI; update it whenever cover geometry or the reachable threat route changes.
6. **Landmark/lighting overlay:** [lighting_landmark_overlay.svg](design/assets/phase2_parking/lighting_landmark_overlay.svg) records the intended landmark chain L1–L5 and exposure/orientation zones. The zones are not photometric values or final light placements.

The Phase 2 asset family now includes the plan, north–south section, O1/O2/O3 detail sheet, threat/sightline overlay and lighting/landmark overlay. The four core spatial drawings are concept v0.3; the companion obstacle detail sheet records the measured apertures and footprints. They share local coordinates and the selected world transform; the next revision must validate all clearances, the final gate and Y=−2.0 m continuity in Godot. Do not present a screenshot of the prototype as an architectural plan.

### 2.4 Provisional spatial graph

The parking graph uses local metres with origin at the northwest corner of the combined facade/site plan; X increases east and Z increases south. The 48 × 30 m envelope is measured to the inside faces of the north/south/east perimeter walls; the 5.3 m facade band is included in X. The selected design-baseline transform is X_world=X_local+28.7 m, Z_world=Z_local−15.8 m, Y=−2.0 m. Values remain approximate and must not be copied into the production builder until the physical handoff is verified against the canonical scene.

| Node | Approx. coordinate (X, Z) | Spatial role | Connected nodes / rule |
|---|---:|---|---|
| P2-01 Service threshold | local (5.3, 21.8); world (34, 6, −2) | Exterior mouth plane at the west edge of the entry vestibule | Continuous handoff from P−1; preserve player position/orientation here, no scene-spawn teleport |
| P2-CP Recovery checkpoint | local (6.8, 21.8); world (35.5, 6, −2) | Safe pocket inside vestibule, 1.5 m beyond the mouth | Recovery-only checkpoint after fair failure; not the initial integration spawn |
| P2-02 Route decision | local (9.3, 21.8); world (38, 6, −2) | First readable split | Branches to P2-A1 or P2-B1 |
| P2-A1 Direct aisle | (14.3, 19.3) | Short exposed path; turns north around the first column | To P2-A2; keep ≥1.2 m clear west of the column |
| P2-A2 Exposed crossing | (22.9, 19.3) | High-risk central-apron crossing | To P2-A3; retain recovery cover nearby |
| P2-A3 Southern bypass | (38.2, 19.6) | Southern bypass around P2-O2; still exposed | To P2-A4; minimum clear width 2.0 m |
| P2-A4 South-east turn | (40.7, 19.6) | Exposed 90-degree turn south of O2 before convergence | To P2-JOIN; keep 2.0 m clear and visible from approach |
| P2-B1 Service lane | (11.1, 13.9) | Service-side route with intermittent cover from vehicles, columns and equipment; no continuous roof | To P2-B2; narrower clearances |
| P2-B2 North cover chain | (25.9, 9.6) | Longer route with broken sightlines | To P2-B3 |
| P2-B3 Technical-cage bypass | (37.1, 12.1) | Service-side traversal north/east of the closed technical cage; does not pass through it | To P2-JOIN; 2.6 m nominal gap at the cover/column row, with O2 the tighter ≥1.5 m passage; verify actual capsule clearance |
| P2-JOIN Convergence | (40.7, 16.8) | Both routes rejoin | To P2-05A |
| P2-05A Barrier approach | (44.3, 16.8) | Clear approach south of the barrier, with the 1.3 m aperture visible ahead | To P2-05; keep the approach collision-free |
| P2-05 Service bottleneck | (44.3, 14.8) | Fixed service-shutter leaves with a 1.3 m wide × 2.2 m high clear aperture | To P2-06 through the aperture; no interaction, timed slide or moving collision across a player already inside |
| P2-06 Egress approach | (44.3, 5.0) | Final approach, visible from mid-level | To P2-EXIT |
| P2-EXIT Boundary | local (42.8, −0.4); world (71.5, −16.2, −2) | Far-side threshold beyond the north wall; 3.6 m clear opening | Mission completion only after crossing the gate and its wall thickness |

**Graph constraints:** all edges are bidirectionally traversable unless explicitly marked otherwise; no drop, climb, jump or squeeze is implied by a line alone. For every edge, the final graph must state clear width, elevation, traversal verb, threat accessibility, sightline condition, fail/recovery behavior and whether it is part of the intended fast route. The current concept has no approved one-way drop.

The concept section is available at [section_parking_concept.svg](design/assets/phase2_parking/section_parking_concept.svg). The selected transform `X_world=X_local+28.7 / Z_world=Z_local−15.8`, at `Y=−2.0 m`, aligns the P−1 east mouth at world (34, 4.5..7.5, −2) with the parking threshold local (5.3, 21.8); the recovery checkpoint is world (35.5, 6) and the far-side egress beyond the north wall is (71.5, −16.2). The current prototype starts near `(X=34.5, Z=0)` and its builder has only a 14 m corridor half-width of 7 m; these are implementation facts to reconcile, not reasons to force the architecture to the old prototype. The selected transform remains a design baseline until scene geometry, elevation, collision and camera continuity are verified.

### 2.5 Provisional edge and clearance contract

These are design targets for the concept graph, not measured clearances in the current prototype. Clear width means the narrowest continuous collision-free path, excluding cover that intentionally occupies the route.

| Edge | Traversal | Target clear width | Sightline / exposure | Recovery and threat rule |
|---|---|---:|---|---|
| P2-01 → P2-CP | Walk/run through vestibule, no jump | 3.0 m clear opening; 1.5 m to checkpoint | Entry is briefly sheltered by facade | Preserve player transform at the threshold; CP is recovery-only, not the initial spawn |
| P2-CP → P2-02 | Walk/run through vestibule, no jump | 3.0 m clear opening; 2.5 m to decision | Read the direct/service split before committing | Checkpoint must not reset story state or place Elena in threat LOS |
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
| L3 / S3 Technical-cage bypass | (37.1, 12.1) | Restrained amber service indicator east of the cage; local electrical/mechanical hum | The service-side route has a real operational purpose and is not a decorative dead end |
| L4 / S4 Bottleneck | (44.3, 14.8) | Fixed open service-shutter leaves, safety marking and a clear 1.3 m aperture | The player sees the aperture before committing; no timed mechanism |
| L5 / S5 Egress landmark | (42.8, 1.8) | Clear silhouette/backlight with no overexposed bloom; gate/perimeter sound | The goal is inferable early, but crossing the boundary is still a physical action |

Lighting must preserve dark adaptation and camera readability. No strobing alarm, colour-only threat cue or pitch-black required route. Critical sounds (unit entering, barrier movement, alert state) need visual equivalents; critical visual state changes need an audio or text alternative where feasible. Use sound to reinforce distance and state, never to provide the only route instruction.

### 2.7 Checkpoint and retry contract

The concept plan marks three provisional anchors: **S** at the service entry, **CP1** at P2-JOIN after both routes converge, and **CP2** at the egress approach before the final bottleneck. These are design locations, not current code checkpoints.

| Anchor | Local coordinate (X, Z) | Purpose | Activation rule |
|---|---:|---|---|
| P2-CP / recovery checkpoint | local (6.8, 21.8); world (35.5, 6, −2) | Recovery-only anchor 1.5 m inside the 3 m service threshold | Not the initial spawn. Preserve the entry transform at P2-01; use CP only after fair failure |
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
**Fairness:** silhouettes, column rhythm, headlight/security-light contrast and the enemy's facing direction must communicate risk. The direct route must remain possible for a confident player; the partially covered service route must be useful, not mandatory busywork.

### Beat P2-03 — Vehicle-row traversal
**Player action:** thread through vehicle bays, columns and one clearly signposted service obstruction.  
**Design purpose:** convert the parking architecture into a movement puzzle. The player reads clearances and chooses when to crouch, walk or run.  
**Rules:** no random car alarms unless authored and telegraphed; no collision-only gaps that appear passable; no required jumps over car bodies unless the landing and animation are designed and tested. Vehicles are static cover, not physics hazards that move unpredictably.

### Beat P2-04 — Exposed crossing
**Player action:** cross a sightline between cover clusters, using timing, a distraction from an environmental source or a short sprint.  
**Design purpose:** create a legible high-risk/high-speed decision.  
**Rules:** the threat's detection cone, alert buildup and audio tell must be understandable. Do not require frame-perfect timing. At least one recovery option must exist if the player is detected early.

### Beat P2-05 — Service bottleneck
**Player action:** pass through the fixed, visibly open 1.3 m aperture in the service barrier. The selected baseline does not include a separate bypass; do not make the aperture close dynamically or require a timed slide.  
**Design purpose:** a final physical decision tied to the site's logistics.  
**Rules:** the obstacle must have a plausible architectural cause and a clear interaction affordance. Avoid a key hunt, a new unrelated puzzle or an unannounced dead end.

### Beat P2-06 — Escape and aftermath
**Player action:** cross the actual boundary and reach a safe transition point.  
**Design purpose:** deliver release without implying that the larger conflict is resolved.  
**Narrative result:** the immediate recovery unit is evaded; Helix's ability to identify and track Elena remains a threat. After crossing the north gate, a service reader displays “PROTOCOLO DE CONTENCIÓN: ACTIVO / SECTOR EXTERIOR” while perimeter lights/access states change in sequence. Elena's proposed line is “Fuera del perímetro. Eso no significa que haya terminado.” Deliver it as one short, skippable subtitle after the gate crossing, without pausing control. This suggests a coordinated response without naming an operator or resolving the wider conspiracy.

The plan labels O1/O2/O3 correspond to register entries P2-O1/P2-O2/P2-O3. Their footprints and baseline dimensions are defined in plan and the obstacle detail sheet; final collision envelopes, camera behavior and traversal clearances still require reconciliation against the actual player capsule. The selected handoff transform is X_world=X_local+28.7 m, Z_world=Z_local−15.8 m, Y=−2.0 m. If the canonical scene differs, update the affected plans/section/graph and record the deviation; do not introduce a teleport or silently force the old prototype checkpoint. Final collision behavior remains subject to playtest. The dimensioned [obstacle detail sheet](design/assets/phase2_parking/obstacle_detail_sheet.svg) records plan/elevation envelopes for O1/O2/O3. Each final obstacle must have a stable ID, measured footprint, approach, intended solution, recovery behavior, collision envelope, camera risks, narrative function and acceptance test.

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
| P2-O1 | (13.3, 13.4) | Static maintenance cart/pallet, 1.9 × 2.1 m footprint, 1.1 m high | Read the remaining side clearance and choose to walk around rather than sprint blindly | Low cover only when crouched and only if actual geometry blocks LOS; not climbable or movable; passage ≥1.2 m |
| P2-O2 | (36.9, 17.0) | Displaced service rack, 3.0 × 2.0 m footprint and 1.4 m high, between the routes near convergence | Low cover only while crouched; a standing Elena remains partly visible. Route A passes south, Route B passes east/north | Must not intersect either route's minimum clear envelope; no climbing or physics movement; see obstacle detail sheet |
| P2-O3 | (44.3, 14.8) | Fixed service-shutter leaves with a 1.3 m wide × 2.2 m high clear aperture | Read the opening and pass through; no interaction or timed slide | Leaves remain fixed open during gameplay; keep the aperture clear for player and threat. No bypass exists in this baseline; see obstacle detail sheet |

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

This is the intended narrative/spatial sequence. The existing parking prototype's standalone start and checkpoints are test infrastructure, not proof of this integrated route. The integrated scene must preserve Elena's world transform/orientation at P2-01 through the physical handoff; P2-CP is recovery-only, not the initial spawn. Do not replay the earlier corridor or reset mission evidence without an explicit persistence decision.

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

## 10. Current implementation boundary (as built, 2026-10-15)

The yard is built by `scripts/phase2/phase2_parking.gd` in the same scene as the facility (`scenes/prototypes/phase1_canonical_greybox.tscn`). The prototype corridor scene `phase2_parking_chase.tscn` no longer exists. The route bot walks the whole yard to the street (`tests/test_phase1_playthrough`), and a live run against the unit reaches the exit without a catch (`tests/test_phase1_escape_live`).

**Deviations from the v0.3 concept, and why:**
- **Envelope:** world x 34..76 and z −15.5..14 at Y −2, instead of x 28.7..76.7 and z −15.8..14.2. The concept's 5.3 m "facade band" is the real plant block between the building's east wall (x 30.3) and the yard.
- **Facility response:** the concept describes a "visible change in security state". It is implemented as floodlights switching on in sequence, the vehicle boom coming down and readers changing to "SECTOR EXTERIOR". A service camera over the mouth reports Elena's exit, so the unit follows her into the yard.
- **Egress:** the north gate splits into a vehicle lane, closed by the boom (Elena can still duck under it), and a fail-safe pedestrian emergency lane. The exit is obvious from the enclosure fence, the green emergency sign and light, and the painted pedestrian walkway, not from a game marker.
- **Distraction:** added the cage compressor (2 s delayed start) and the dock 2 roller shutter (controlled from beside the mouth, heard at the far end) for misdirection, as Beat P2-04 anticipated.
- **Darkness:** light pools define exposure. The unit sees at ×0.6 range in the dark (×1 in the pools), and the HUD shows the stealth level with a symbol and text.
- **Climbable cover:** cars, the crate stack and O2 can be climbed onto (0.45–1.85 m). The unit cannot follow, but it can reach 1.8 m up, so standing on a car beside it is not a safe exploit.

The remaining concept rules hold: two routes with different exposure, O1/O2 cover, a fixed 1.3 m O3 aperture, the recovery checkpoints (YARD at the mouth, JOIN, EGRESS), no required jump and no invisible walls.

**Not verified:** fairness and tension with human players, and camera comfort in the yard. See `PROJECT_STATUS.md`.

## 7. Owner-approved spatial and escape direction — 2026-10-15

This section records the next design target. The geometry and sequence below are not yet certified as built or runtime-verified. Existing parking dimensions and drawings remain useful references where compatible, but must be reconciled with the new human-stealth and hybrid first-person design before implementation is considered accepted.

### 7.1 Phase 1 building composition
Keep the large central pumping/laboratory hall as the principal spatial landmark. The current expanded target uses a conceptual 48 × 34 m footprint (1,632 m² gross). The nave should have 6–8 m clear height, with machinery, catwalks, pipes, visible vertical circulation and long sightlines. P−2 is at floor elevation −4.00 m, P0 at ±0.00 m, M at +1.50 m and P+3 at +3.00 m; these are floor datums, not room clear heights. The mezzanine occupies only a side wing, and P+3 is also a partial upper wing, so neither slab crosses the central nave void. Ordinary room clear heights and slab/structure thickness remain provisional until the section is measured against the Godot controller and collision scale.

P0 has two distinct access points: the old architectural corridor entrance and Elena's damaged service breach. The breach collapses physically after entry and blocks return through real geometry/collision. P−2 contains the energy/substation loop and the hidden transfer doorway in the east wall of the dead workshop. A clean strip of floor, fresh drag marks and faint airflow reveal the panel; a maintenance note sends the player to a raised dry cabinet in the spares store, where TRANSFER_KEY is found. This is separate from the drawer's SERVICE_KEY + INSULATED_BRIDGE energy chain. The door can be discovered early but opens to the active clandestine building only when TRANSFER_KEY and PowerRestored are both available. Do not route this transition through P+3 or an emergency exit.

The player should understand room relationships through visible landmarks, lighting, signage and glimpses of other elevations. Provide optional discoveries and shortcuts without maze-like routing or repetitive backtracking. Each major room must contribute a puzzle clue, environmental interaction, traversal challenge, narrative discovery, route choice or optional reward. See the coordinated Phase 1 plan, section, graph and progression document; all are design targets until validated in Godot.

### 7.2 Phase 2 transition and operational zone
After completing the required investigation and opening the appropriate gate, Elena enters a previously unseen operational area. She should initially move cautiously and observe a small number of human personnel working on a meaningful Helix/Aster activity. The scene must reveal information and build tension before detection; avoid NPCs that serve no gameplay or narrative purpose.

The principal redesigned pursuer is human. Detection, suspicion, search, communication and chase behavior must be readable and fair. The current robotic recovery unit is existing prototype behavior, not the approved final direction for this sequence.

### 7.3 Hybrid first-person chase
Use first-person perspective for the principal escape. Preserve free movement and route choices, punctuated by brief contextual actions (vault, duck/slide, push an object, operate a mechanism or select a route). Short, motivated looks back can show consequences such as a pursuer stumbling over an object. Avoid a QTE-only sequence, arbitrary failure and long interruptions of control.

### 7.4 Parking and public exit
The parking garage is a separately designed chase space, not required to be adjacent to the central hall. Connect it through a credible service route or a deliberate scene transition that preserves motion, sound, orientation and narrative continuity. Design vehicle rows, columns, ramps/barriers and readable route alternatives for the intended chase. Elena exits to a public street and loses the pursuers among pedestrians. The crowd may be staged efficiently; a full pedestrian simulation is not a requirement.

### 7.5 Future Marcus combat phases
Do not fold the full beat-'em-up into this level-design scope. Future Marcus-led phases should include Elena as a companion whose defensive capability progresses from dependence on Marcus to limited self-defense learned from him. The level and encounter design should later reflect this progression; the current Phase 1/2 priority remains investigation, human discovery and escape.

### 7.6 Art and verification gate
Use the owner's Marcus concept and illustrated laboratory reference to guide the art language: illustrated 3D, painterly materials, controlled edge definition, strong silhouettes and readable cinematic lighting. Before expanding production, validate one playable section in Godot from the gameplay camera. Reconcile layout drawings, collision, navigation, camera, scene transitions and the actual implementation; concept art or static renders do not prove a playable route.


## Owner-approved escape labyrinth: dry conduit to forest (2026-10-16; target only)

This replaces the immediate escape destination of the older parking-garage design for this sequence. The laboratory remains largely unchanged until functional correctness is established. After Elena observes the human-operated facility and is discovered, a fork leads right to the personnel/story area and left into the escape.

The escape route is a long, multi-corridor labyrinth inside a huge drained industrial water/service conduit. It must alternate direction through several long passages and include authored jumps/vaults, a gradual uphill section, a physical maintenance hatch or culvert mouth, a secondary road and a forest hiding place. The forest hideout is the end of the phase. No mandatory fight follows.

**Lighting is the principal diegetic wayfinding language:** the intended egress line uses stronger, more continuous light and repeated light pools visible from junction approaches; wrong branches are darker or have broken light continuity. Use redundant maintenance markings, conduit/cable direction, airflow, slope and outside ambience to avoid a colour-only or audio-only puzzle. The correct route must be inferable before commitment; wrong routes can cost time but should be recoverable and clearly communicate that they terminate.

The route is first-person with continuous player control, contextual traversal prompts and brief motivated glances back. Stamina is held at 100% (or an equivalent tested unlimited-sprint contract) during the adrenaline escape. Human pursuers are the principal threat; Door G, the legacy robot and the parking route are not dependencies. Keep legacy yard documentation/assets as explicitly historical/deferred rather than deleting them prematurely.

The existing plan, section, spatial graph and greybox spec must be updated together with dimensions, IDs, widths/headroom, turns, elevations, jump/vault envelopes, light cues, dead-end branches, threat accessibility, recovery behavior and the forest completion trigger. Design acceptance requires automated reachability/softlock/stamina/collision checks and a manually played end-to-end escape. The target is not evidence of implementation.
