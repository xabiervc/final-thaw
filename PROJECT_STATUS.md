# Project Status — FINAL THAW

## Current phase

**Phase 1 implementation — design decisions closed; scene and tests not yet validated.** The active branch contains the isolated third-person motion/chase prototype v2 plus the earlier shelter and Elena-room experiments. Fase 1 now has a single implementable functional spec and reconciled spatial/greybox references.

## Phase 1 sources of truth

- Functional behaviour and narrative handoff: `docs/design/FASE1_FUNCTIONAL_SPEC.md` (v1.0).
- Spatial graph: `docs/design/FASE1_SPATIAL_GRAPH.md` (v0.4).
- Greybox geometry: `docs/design/FASE1_GREYBOX_SPEC.md` (v1.1).
- Progression map: `docs/design/fase1_fase2_mapa_progresion.md` (v0.6).
- Electrical logic: `docs/design/FASE1_LOGIC_CONTRACT.md`.

No design alternative remains open inside the Phase 1 slice. Scene, collision, camera, timing and playtest results remain unverified.

## Phase 1 implementation sequence

1. Build the fixed geometry: entry, broken approach, south route, pit and always-usable fixed stairs.
2. Build the single platform elevator at X=24.5..27.5, Z=-4.5..-1.5; remove the provisional ramp and the second platform reservation X=30..34.
3. Port the circuit logic into isolated GDScript tests before wiring interaction UI.
4. Build selector, isolator, state panel, rearm, terminal, archive indicator and consultation.
5. Build the west vestibule and outer exit hatch; add the queued service-audit event and handoff to H.
6. Run Phase 1 tests and the Phase 0 regression; record exact Godot version/commands/results.
7. Only then integrate H with the existing motion/chase prototype. Run its v2 automated test and perform a separate hands-on playtest before claiming the chase works.

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
