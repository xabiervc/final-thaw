# Phase 1 — Canonical build and verification

**Status:** first canonical scene and integration test are present in code. Neither has been run in Godot in this change, and neither has been manually playtested. This document distinguishes implementation from verified behavior.

## Canonical scene

Open `scenes/prototypes/phase1_canonical_greybox.tscn` and press F6. Its builder is `scripts/prototypes/phase1_canonical_greybox.gd`.

This is the only scene that implements the current Phase 1 design authority:
- `FASE1_FUNCTIONAL_SPEC.md` v1.0
- `FASE1_SPATIAL_GRAPH.md` v0.4
- `FASE1_GREYBOX_SPEC.md` v1.1
- `fase1_fase2_mapa_progresion.md` v0.6
- `FASE1_LOGIC_CONTRACT.md`

The earlier `phase1_spatial_greybox.tscn` is preserved as a six-room comparison prototype. It uses another coordinate plan and must not be judged as an implementation of the current graph. The expanded exploration build is also non-canonical. Nothing in this migration deletes or overwrites those prototypes.

## Implemented in the canonical scene (not yet verified)

- Ground slab split around the lift shaft, service pit and fixed pit stair opening.
- Pit schematic, tampered A→T bridge, maintenance switch and service lights.
- Original-shaft service lift, unpowered initially and wired to the maintenance state.
- The upper-landing protective rail stops at X=26, leaving the X=24..26 overlap clear for lift-to-walkway transfer.
- Upper walkway and archive cabin, selector, trial isolator, diagnostic panel and independent rearm interaction.
- Local F archive-status display and a separate consultation control.
- Hold-to-scan continuity reveal (0.9 s charge, 3 s visible, 4 s cooldown) at schematic A, physical A→T bridge and node T; it does not point at an interaction.
- F→G inner door unlocked once from the cabin side; G→H outer hatch; queued audit and a delayed transition to the existing motion/chase prototype after crossing outside.
- Reuses `phase1_circuit_model.gd`, `service_lift.gd`, `phase1_spatial_player.gd`, `prompt_hud.gd` and the shared FacilityMaterials palette. No save-format, autoload, input-action or renderer changes.

These bullets describe the code's intended behavior, not successful Godot execution.

## Automated checks

Run under Godot 4.7.x with the Compatibility renderer:

```sh
godot --headless --path . res://tests/test_phase1_canonical_greybox.tscn
godot --headless --path . res://tests/test_service_lift.tscn
godot --headless --path . res://tests/test_service_lift_transport.tscn
godot --headless --path . res://tests/test_phase1_circuit_model.tscn
```

Phase 0 regression command:

```sh
godot --headless --path . res://tests/test_phase_0.tscn
```

Record Godot version, commit, exact command, output, and exit code. Any script parse error, failed assertion or timeout is a blocker.

## Manual gate

Open the canonical scene with F6 and test in sequence: enter; inspect the broken access and central rig; descend and leave the pit with maintenance off; operate maintenance; return through the fixed stairs; summon, board, ride and leave the lift from both ends; cut power while docked and at early, midpoint and late positions; solve and deliberately trip the circuit; inspect diagnostics before and after rearm; consult archive only with stable supply; unlock F→G; open and cross G→H.

Capture camera and collision issues, whether the status panel and F indicator are readable without approaching the wrong control, whether the lift gates read clearly, whether the player can pass every opening without jumping, and whether the circuit is inferred instead of brute-forced. A human playtest with a new player remains mandatory.

## Known verification boundary

No Godot executable was available in the editing environment, so none of the commands above are claimed as run. Scene geometry, collision, camera, visual readability, lift physics, transition behavior and player comprehension remain pending evidence.
