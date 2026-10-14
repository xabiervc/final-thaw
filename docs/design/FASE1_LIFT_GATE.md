# Phase 1 — Lift gate

Status: independent component and test bench, prepared; not executed in Godot and not validated by play. The lift is **not** part of the Phase 1 complex yet (see "Open design question"). It replaces nothing and the provisional ramp of the earlier greybox is not used here.

## Why a separate gate

A moving platform adds problems unrelated to the mission: carrying the character without sliding or falling, boarding without precise jumps, camera behaviour, losing power in the middle of a trip. The design review asked to validate them on their own, with the behaviour on power loss written down before any implementation. This document is that specification.

## Behaviour (as implemented in scripts/prototypes/service_lift.gd)

| Rule | Value |
|---|---|
| Landings | `lower` and `upper`, 3 m apart (configurable) |
| Speed | 1.2 m/s, so a 3 m trip takes about 2.5 s |
| Docking | The deck is exactly flush with the landing it is docked at |
| Gates | One at each end of the deck. The end facing a landing is open only while docked at that landing. Both are closed while moving |
| Calls | From either landing or the deck button. A call during a trip is queued and served after docking |
| Dwell | 3 s docked before any new departure, so a rider can always get off |
| Power loss while docked | Stays docked, keeps its open end open, refuses calls until power returns |
| Power loss while moving | Finishes the trip at 30% speed towards the **nearest** landing, then behaves as above. It is never left between floors; worst case 3 m / (1.2 x 0.3) s, about 8.3 s |
| Power source | `set_powered()`. In the mission it would be driven by maintenance, as the logic contract says |

The motion is a pure function of `step(delta)`, so the state machine is tested without physics.

## How it is checked

- `tests/test_service_lift.tscn` (state machine, stepped by hand): flush docking, gates at every stage, trip time, same-level calls, dwell, queued calls, power loss while docked, in the first half and in the second half of a trip, power return, invalid input.
- `tests/test_service_lift_transport.tscn` (real physics): a character boards by walking, rides up and down without sliding or leaving the deck, cannot step into the shaft from the closed end, and gets off by walking. It uses the same space as the manual scene (scripts/prototypes/lift_test_rig.gd).
- `scenes/prototypes/lift_gate_test.tscn` (by hand): WASD, Space, E to call or send, P to cut and restore power, R to return. It prints state changes as `[lift time] message`.

Not covered by any automatic test and needing a person: camera behaviour while riding, how the ride feels, whether the gates read clearly, and what a first-time player tries to do on the deck.

## Acceptance for the gate

1. Both automatic tests pass in Godot, with the version and command recorded.
2. By hand: ten round trips, boarding from both landings, power cut at the start, middle and end of a trip, cutting power while standing on the deck, jumping at the gate, and calling from the other landing while riding. No fall, no slide, no stuck state.
3. The camera stays readable during the ride (record where it does not).
4. Nothing in the mission depends on the lift until this gate is closed.

## Open design question

The layout marks a "lift slot" in the pump room (+1.5 m), but that room is 15 m from the catwalk, so a vertical lift there connects to nothing. Stairs already join every level, so the lift would be a convenience, not a necessity. Options for design to choose:

- **Keep the lift out of Phase 1** and use the gate only to validate the component for later phases. Cheapest and safest.
- **Add a lift shaft to the layout** between two existing levels where the saving matters (for example the hall at 0 m and the catwalk at +3 m), which needs a change to FASE1_ROOM_COMPLEX.md and its tests.
- **Move or remove the marked slot** in the pump room so the floor does not promise something that is not there.

Until that decision, the stairs remain the only vertical connections and the lift stays a test bench.
