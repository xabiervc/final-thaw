# FINAL THAW — Prototype Traceability Matrix

**Status:** scoped to the current motion/chase prototype and proposed opening. This replaces the claim that the previous full campaign's traceability is complete.  
**Implementation:** `scripts/prototypes/motion_chase_prototype.gd`  
**Behavior checks:** `tests/test_motion_chase_prototype.gd`

## Current code-level traceability

| Design intent | Implementation | Test coverage / evidence | Remaining validation |
|---|---|---|---|
| Third-person movement/jump | `_move_player`, acceleration, gravity, jump buffer/coyote time | Geometry and structure checks in v2 test | Hands-on feel, landing and camera response |
| Crouch under low geometry | `_set_crouch`, `_can_stand` | Tunnel dimensions/clearance constants | Runtime collision and model pose |
| Authored climb | `try_climb`, climb trigger callbacks | Trigger entry and climb completion checks | Player feel, animation transition, controller support |
| Camera readability | `_update_camera`, `_update_occluders` | Occluder fade check | Manual review in tunnel, pillars and catwalk |
| Threat detection | `can_enemy_see_player`, `enemy_cone_contains`, `_line_clear`, awareness | Detection checks | Telegraph timing and fairness |
| Noise investigation | `player_noise_radius`, `_enemy_hears_player` | Inspect exact assertions in current test | Runtime movement/noise cases |
| Bounded pursuit knowledge | `last_known`, chase/search transitions | Awareness/memory check | Hands-on confirmation of no wall tracking/unfair catches |
| Scanner supports route choice | `trigger_scan_reveal`, `_update_scan` | Markers show/hide and cooldown checks | Is the charge/cooldown an interesting trade-off? |
| Local failure recovery | `_respawn`, checkpoints and catch handling | Partial coverage | Checkpoint state, retry time, no stuck states |
| Exit completion | Exit threshold and `_finish` | Structural coverage | Full playthrough, restart and menu behavior |

**Verification warning:** a test that checks node existence or calls helpers is not proof of a good playable experience. The v2 prototype spec says its automated test has not yet been run. Do not mark these rows passing until the exact command and result are recorded.

## Proposed Mission 1 traceability (not implemented)

| Design intent | Planned mechanic | Planned evidence | Acceptance |
|---|---|---|---|
| Infer an Aster system fault | Multi-step energy/system configuration | At least two complementary environmental clues | Player can explain why the configuration is correct |
| Scanner supports inference | Reveal traces/anomalies, not the answer | Trace or machine-state evidence | Player can solve without a literal HUD answer |
| Actions have physical consequence | Configuration changes system state | Power, machinery, lockdown response | Player sees/hears a causal result |
| Puzzle supports story | Evidence about Helix/Aster | Record, signal, machine state or memory | Player understands one new story fact |
| Hints support access | Escalating optional hint | Goal → clue relation → stronger guidance | Hint helps without automatically skipping puzzle |

## Proposed Mission 1 → Mission 2 transition

| Trigger | System response | Player-facing evidence | Required test |
|---|---|---|---|
| Puzzle solved | Facility containment activates | Lights, alarms, doors/audio change coherently | Transition fires once |
| Containment begins | Recovery unit enters appropriate state | Audible/visual warning and readable route pressure | AI starts in a fair state |
| Player escapes | Mission completes and evidence is retained | Short aftermath beat and objective closure | Completion and persistence policy |

## Protected regression boundary

Preserve Phase 0 input action contracts, autoload names/public signals, resource paths, save JSON/CRC32 behavior and Compatibility renderer assumptions. Run `godot --headless --path . res://tests/test_phase_0.tscn` after relevant changes and record the result. This matrix does not claim that command has been run for the current commit.

## Deferred legacy traceability

Rows for Marcus combat, character switching, civilian-aid thresholds, three endings, 16 campaign phases and survival counters refer to the prior design. Preserve them as historical material until the full-game direction is approved; do not use them as acceptance requirements for the motion/chase prototype.
