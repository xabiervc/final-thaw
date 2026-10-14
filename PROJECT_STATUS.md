# Project Status — FINAL THAW

## Current phase

**Phase 1 implementation — design decisions closed; first canonical scene and integration checks are present, not yet executed.** The active branch retains the motion/chase prototype v2 and earlier comparison prototypes. Phase 1 now has one functional spec, reconciled geometry references, a canonical greybox scene and an integration test.

## Phase 1 sources of truth

- Functional behaviour and narrative handoff: `docs/design/FASE1_FUNCTIONAL_SPEC.md` (v1.0).
- Spatial graph: `docs/design/FASE1_SPATIAL_GRAPH.md` (v0.4).
- Greybox geometry: `docs/design/FASE1_GREYBOX_SPEC.md` (v1.1).
- Progression map: `docs/design/fase1_fase2_mapa_progresion.md` (v0.6).
- Electrical logic: `docs/design/FASE1_LOGIC_CONTRACT.md`.

No design alternative remains open inside the Phase 1 slice. Scene, collision, camera, timing and playtest results remain unverified.

## Phase 1 current implementation

- Canonical scene: `scenes/prototypes/phase1_canonical_greybox.tscn`.
- Builder/interactions: `scripts/prototypes/phase1_canonical_greybox.gd`.
- Integration test: `tests/test_phase1_canonical_greybox.tscn` / `tests/test_phase1_canonical_greybox.gd`.
- Reused circuit model: `scripts/prototypes/phase1_circuit_model.gd`.
- Reused service elevator: `scripts/prototypes/service_lift.gd`.

The scene connects the new single-bay geometry to the circuit model, maintenance-controlled lift, archive consultation, status fixtures, and G→H transition. This is code presence, not verified behavior.

## Phase 1 next steps

1. Run canonical scene integration test and service-lift state-machine/physics tests; fix all parse/runtime failures.
2. Run circuit model tests and Phase 0 regression.
3. Play the canonical scene manually: check floor continuity, missing stair barrier, pit exit, shaft gates, rider transport, camera, reachability and indicator readability.
4. Fix defects in the existing canonical scene before adding final art or expanding scope.
5. Run the existing motion/chase v2 test and play that prototype manually; then confirm the G→H handoff before considering the combined slice accepted.

## Existing motion/chase prototype v2

Files:
- Scene: `scenes/prototypes/motion_chase_prototype.tscn`
- Code: `scripts/prototypes/motion_chase_prototype.gd`
- Test: `tests/test_motion_chase_prototype.tscn` and `tests/test_motion_chase_prototype.gd`

Code inspection shows third-person camera orbit/fading, walk/run/crouch/jump, a defined climb, scanner reveal, checkpoints, and a recovery-unit state machine. These are implementation facts, not proof of validated gameplay quality. The prototype specification states v2 and its automated test have not yet been run.

Commands to run before integrating H:

```sh
godot --headless --path . res://tests/test_motion_chase_prototype.tscn
godot --headless --path . res://tests/test_phase_0.tscn
```

Then run the scene manually and log movement, camera, detection fairness, failures and retries. The historical Phase 0 result (11 passed, 0 failed) does not verify later changes.

## Technical and regression boundaries

Preserve Phase 0 input/autoload/resource-path contracts, save JSON/CRC32 behaviour, and Compatibility renderer assumptions unless an explicit impact review authorizes a change. Keep legacy scenes until the new slice passes human review. The current assets remain a prototype library; verify the MPFB/MakeHuman base-mesh licence before shipping derivatives.

## Reporting rule

Distinguish design specified, code present, automated test coverage, test executed successfully, manual playtest, and production readiness. Never claim one based on another.
