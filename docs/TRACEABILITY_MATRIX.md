# FINAL THAW — Prototype Traceability Matrix

**Status:** scoped to the current two-mission opening. This matrix replaces any claim that the former full campaign's traceability is complete.  
**Implementation reference:** `scripts/prototypes/motion_chase_prototype.gd`, `scenes/prototypes/phase2_parking_chase.tscn`  
**Design references:** `docs/CORE_LOOP.md`, `docs/LEVEL_STRUCTURE.md`, `docs/design/MISSION1_GHOST_PROTOCOL.md`, `docs/design/MOTION_CHASE_PROTOTYPE.md`.

## 1. Current code-level traceability: motion/chase prototype

| Design intent | Implementation reference | Test coverage / evidence | Remaining validation |
|---|---|---|---|
| Third-person movement/jump | `_move_player`, acceleration, gravity, jump buffer/coyote time | Inspect current assertions in v2 test | Hands-on feel, landing and camera response |
| Crouch under low geometry | `_set_crouch`, `_can_stand` | Tunnel dimensions/clearance constants | Runtime collision and model pose |
| Authored climb | `try_climb`, climb trigger callbacks | Trigger entry and climb completion checks | Player feel, animation transition, controller support |
| Camera readability | `_update_camera`, `_update_occluders` | Occluder fade check | Manual review in tunnel, pillars and catwalk |
| Threat detection | `can_enemy_see_player`, `enemy_cone_contains`, `_line_clear`, awareness | Detection checks | Telegraph timing and fairness |
| Noise investigation | `player_noise_radius`, `_enemy_hears_player` | Inspect exact assertions in current test | Runtime movement/noise cases |
| Bounded pursuit knowledge | `last_known`, chase/search transitions | Awareness/memory check | Hands-on confirmation of no wall tracking/unfair catches |
| Scanner supports route choice | `trigger_scan_reveal`, `_update_scan` | Markers show/hide and cooldown checks | Is the charge/cooldown an interesting trade-off? |
| Local failure recovery | `_respawn`, checkpoints and catch handling | Partial coverage | Checkpoint state, retry time, no stuck states |
| Exit completion | Exit threshold and `_finish` | Structural coverage | Full playthrough, restart and menu behavior |

**Verification warning:** structure/helper checks are not proof of a good playable experience. The v2 prototype test and current runtime status must be confirmed from actual results before any row is marked passing.

## 2. Mission 1 — investigation and story evidence (designed; integration pending)

| Design intent | Planned mechanic | Player-facing evidence | Acceptance |
|---|---|---|---|
| Infer Aster system fault | Multi-step circuit configuration under `FASE1_LOGIC_CONTRACT.md` | Diagram, physical A→T diversion, protection response | Player can explain why the safe configuration is correct |
| Scanner supports inference | Reveal traces/state, not the answer | Physical continuity and machine-state evidence | Puzzle remains solvable without literal HUD answer |
| Actions have consequences | Configuration changes system state | Lights, machines, door and terminal response | Correct/incorrect order produces distinct recoverable feedback |
| Puzzle supports story | Recover suppressed Aster test result | Restricted record plus physical evidence | Player understands that the result was withheld/manipulated |
| Hints support access | Escalating optional hint | Goal → clue relationship → stronger guidance | Helps without automatically skipping the puzzle |
| Trigger is causal and singular | Agreed Containment event contract | Visible/audio system response | Transition fires once and not from optional record reading alone unless contract changes |

| Mission-level maintenance side effect is separate from circuit logic | `MISSION1_GHOST_PROTOCOL.md`, `FASE1_FUNCTIONAL_SPEC.md`, `FASE1_LOGIC_CONTRACT.md` | Maintenance OFF→ON queues `SERVICE_OVERRIDE`; circuit outputs/history remain unchanged | State-transition test plus circuit reference regression |
| Archive consultation adds knowledge but does not trigger Containment | `MISSION1_GHOST_PROTOCOL.md`, `CORE_LOOP.md` | `RESTRICTED_RECORD_READ` changes only on successful consultation with stable ARCHIVO | Test stable/unpowered archive and verify no chase trigger |
| Opening exterior G sends queued audit once | `FASE1_FUNCTIONAL_SPEC.md`, `DESIGN_PIVOT_PROTOTYPE_BRIEF.md` | Door/audio/light response and one Containment activation | Test queued/missing queue, repeated open callback, mission restart |
| Opening G without queued audit is recoverably denied | `MISSION1_GHOST_PROTOCOL.md`, `FASE1_FUNCTIONAL_SPEC.md` | Diegetic denial; no enemy spawn or state corruption | Test no queue, then activate maintenance and retry |

## 3. Phase 1 escape continuity (specified; not fully implemented/verified)

| Requirement | Design authority | Required evidence |
|---|---|---|
| G triggers an interior pursuit, not a scene teleport | `FASE1_ARCHITECTURAL_LAYOUT.md`, `fase1_fase2_mapa_progresion.md` | Runtime walkthrough and trigger-state test |
| Elena retreats via F/E, S2, M, existing lift, P0, S1 and P−1 | `FASE1_SPATIAL_GRAPH.md`, `FASE1_GREYBOX_SPEC.md` | Connected plan/section, collision traversal, route test |
| O1/O2/O3 obstacles are visible, measured and recoverable | `FASE1_GREYBOX_SPEC.md` | Coordinate match across SVG, builder and obstacle test |
| P−1 evacuation gallery reaches the selected east exterior mouth at X=34, Z=4.5..7.5, Y=−2 | `FASE1_ARCHITECTURAL_LAYOUT.md`, `plan_p_minus2.svg` | Plan/section and physical scene walkthrough |
| Parking entry is continuous and starts at the integration checkpoint | `LEVEL_STRUCTURE.md` | Handoff test with no duplicate player or replayed corridor |

| Quiet evasion uses real cover and STAFF-M1 perception | `FASE1_FUNCTIONAL_SPEC.md`, `FASE1_SPATIAL_GRAPH.md`, M plan SVG | STAFF-M1 patrol, C1 pump-bank cover and O2 rack footprint are marked; sightlines respect solid geometry | Manual LOS/noise playtest, staff-state test, route-clearance check |
| Staff alert reports last-known position only | `FASE1_FUNCTIONAL_SPEC.md` | NPC callout/withdrawal and bounded report | Test LOS loss, alert, search and no wall tracking |
| R1 starts running chase in P0 after the existing lift | `FASE1_SPATIAL_GRAPH.md`, `FASE1_FUNCTIONAL_SPEC.md`, P0 plan and vertical section SVG | Unit follows through the same lift and reacquires Elena at the P0 service-gallery/east-return threshold (X≈29, Z≈1) | Test physical route, actual LOS, no teleport/spawn ahead, early reacquisition only on real LOS |
| Chase continues through existing S1/P−1 circulation | `FASE1_SPATIAL_GRAPH.md`, `FASE1_GREYBOX_SPEC.md`, progression map | R1 → P0 east return → S1 → P−1 → alternative service gallery | Walk full route, test collisions, camera, recovery, and physical exit-to-parking handoff |

## 4. Phase 2 parking design traceability (specified as design requirements; not verified in code)

| Requirement ID | Design intent | Design evidence required | Implementation/test evidence required |
|---|---|---|---|
| P2-ARCH-01 | Parking reads as a service forecourt belonging to the lab | Dimensioned plan, facade and site-boundary callouts | Scene inspection from entry camera |
| P2-ARCH-02 | Entry, exit and vehicle circulation form a traversable network | Plan, section, spatial graph and clearance table | Walk every edge with actual capsule/camera |
| P2-ROUTE-01 | At least two routes have distinct exposure/traversal risk | Route overlay and risk comparison | Playtest both routes; record outcomes |
| P2-ROUTE-02 | All major obstacles have ID, dimensions, solution and recovery | `LEVEL_STRUCTURE.md` obstacle register and `obstacle_detail_sheet.svg` plan/elevation details | Collision/behavior test and manual traversal; verify 1.3 × 2.2 m O3 aperture for player and threat |
| P2-AI-01 | Threat sees only within range/cone/line of sight | Sightline overlay and threat-state table | Occlusion, range, noise and last-known-position tests |
| P2-AI-02 | Threat cannot use undocumented shortcuts or cross solid obstacles | Threat navigation overlay | Walkthrough of all enemy/player routes |
| P2-FEEDBACK-01 | Alert/detection is legible and fair | Audio/visual feedback spec | Verify HUD, audio and state transitions in play |
| P2-SCAN-01 | Scanner supports tactical inference without revealing the route | Scanner timing and information table | Playtest charge/reveal/cooldown usefulness |
| P2-NARR-01 | Each beat reveals or reinforces one specific story fact; the final beat shows containment active in the exterior sector without naming an operator | Beat-to-information table in `LEVEL_STRUCTURE.md` and N2-01…N2-06 script table in `narrative_complete.md` | Comprehension check after playtest; verify final subtitle is skippable and never interrupts control |
| P2-NARR-02 | Proposed Helix coordination remains explicitly provisional | Narrative decision log / wording in docs | Review all VO, signage and props for canon overreach |
| P2-ACCESS-01 | Critical information is not colour-only or audio-only | Accessibility checklist | Keyboard/controller, visual audio alternatives and subtitles review |
| P2-RECOVERY-01 | Failure retries from a fair checkpoint and preserves agreed state | Checkpoint/state contract | Repeated catch/fall/restart integration tests |
| P2-HANDOFF-01 | Phase 1 exterior mouth connects to parking entry without teleport/replay | Combined plan and continuity graph | End-to-end scene traversal and checkpoint test |
| P2-VERIFY-01 | Implementation and runtime claims are evidence-based | Acceptance record template | Godot version, renderer, commit, commands, exit codes, warnings/errors and manual QA |

These rows define requirements and evidence, not passing results. No Phase 2 requirement is marked runtime-verified by this document.

## 5. Design-package traceability and ownership

| Requirement ID | Design requirement | Source of truth | Evidence required before design acceptance | Owner |
|---|---|---|---|---|
| P2-DOC-01 | Parking plan and section agree on overall dimensions, parking-row depth, apron width, orientation and vertical clearance | `LEVEL_STRUCTURE.md`, `parking_plan_concept.svg`, `section_parking_concept.svg` | Reconcile the 48 × 30 m plan with the 30 m north–south section, 5 m bay depths, 17.3 m apron, 2.8 m clear below the overhead pipe racks; no continuous canopy and vehicle envelopes | Design owner + programming owner |
| P2-DOC-02 | Parking local-to-world transform aligns with the selected Phase 1 alternative exit | `FASE1_SPATIAL_GRAPH.md`, `LEVEL_STRUCTURE.md`, parking plan and overlays | Selected baseline: world X=local X+28.7 m, Z=local Z−15.8 m, Y=−2.0 m; threshold local (5.3,21.8) maps to world (34,6); recovery checkpoint (6.8,21.8) maps to (35.5,6), not the initial spawn; far egress beyond the north wall local (42.8,−0.4) maps to (71.5,−16.2). Verify footprint, orientation, elevation and continuous colliders in Godot | Design owner defines; programmer verifies in scene |
| P2-DOC-03 | Two routes are meaningfully different in exposure and traversal cost | `LEVEL_STRUCTURE.md` route graph and edge contract | Plan overlay plus route-by-route playtest observations | Design owner + programmer |
| P2-DOC-04 | Every obstacle has stable ID, dimensions, approach, bypass and recovery | `LEVEL_STRUCTURE.md` obstacle register | Reviewed collision envelopes and manual traversal evidence | Design owner defines; programmer implements |
| P2-DOC-05 | Threat line-of-sight, patrol, hearing, search and route access are bounded and spatially possible | `LEVEL_STRUCTURE.md`, `threat_sightline_overlay.svg` | Reconcile sightline sectors with measured cover; test occlusion, hearing, last-known position and enemy route reachability | Shared |
| P2-DOC-06 | The opening reveal, trigger and chase dialogue are causal and non-blocking | `narrative_complete.md`, `CORE_LOOP.md`, `DESIGN_PIVOT_PROTOTYPE_BRIEF.md` | Trigger table and first-time-player comprehension answers | Design owner + programmer |
| P2-DOC-07 | Environmental clues, lighting and sound communicate critical facts accessibly | `LEVEL_STRUCTURE.md`, `lighting_landmark_overlay.svg`, `narrative_complete.md` | Check L1–L5 visibility from each decision point in actual camera; review contrast, audio alternatives and subtitles | Design owner |
| P2-DOC-08 | Every claim distinguishes proposal, specification, implementation and validation | `DESIGN_AUTHORITY.md`, `PROJECT_STATUS.md` | Status/evidence record tied to a commit and actual results | Both owners |
| P2-DOC-09 | Entry, route convergence and final approach use fair local retry anchors | `LEVEL_STRUCTURE.md` checkpoint contract and concept plan | Repeated catch/retry tests, no spawn collision or immediate detection, state preservation | Shared |

These requirements are design/verification gates, not passing results. The concept SVGs contain proposed sightline and light zones only; they do not represent a computed enemy perception model, actual navigation, measured illumination or Godot runtime behavior. The plan and section now target a 3 m clear entry, but the handoff remains provisional until the phase-1 scene confirms its actual bounds and elevation.

## 6. Protected regression boundary

Preserve Phase 0 InputMap action names/remaps, autoload names/public signals, resource paths, JSON/CRC32 save behavior and Compatibility renderer assumptions. Run:

```sh
godot --headless --path . res://tests/test_phase_0.tscn
```

Record the exact command, Godot version, commit, exit code, pass/fail summary, warnings and remaining verification. This matrix does not claim that the command has run for the current commit.

## 7. Deferred legacy traceability

Requirements for Marcus combat, character switching, civilian-aid thresholds, three endings, a fixed 16-phase campaign and legacy survival counters remain historical until the owner explicitly reconciles the full campaign after reviewing the combined opening. Their presence in older files is not proof that they belong to current scope.

## 8. Evidence vocabulary

Use these labels consistently:
- **Specified:** written in an active design authority.
- **Implemented:** corresponding behavior exists in current code/scene.
- **Test-covered:** an automated test asserts relevant behavior.
- **Test-executed:** the exact test was run and its result recorded.
- **Hands-on validated:** a human played the relevant route and reviewed feel/readability.
- **Accepted:** the design owner reviewed the evidence and accepted the result.

Never collapse these states into a generic “done”.
