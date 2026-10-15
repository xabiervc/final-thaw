# Project Status — FINAL THAW

## Current phase

**Phase 1 implemented end to end (as-built v3.0) and verified by automated tests and a route bot; human playtest pending; performance below target.** The canonical Phase 1 (`scenes/prototypes/phase1_canonical_greybox.tscn`, opened by "Iniciar demo") is one continuous, walkable building. The investigation puzzle runs on the unchanged electrical contract and leads to a two-tempo escape: quiet evasion past STAFF-M1, then a running chase that ends at the P−1 east mouth and continues, without a cut or teleport, into the Phase 2 parking scene.

Accepted as evidence: automated suites and the route bot, which drives the real input actions. **Not yet evidence:** a human playtest, audio listening, a Web export, or performance on the minimum-spec target.

## Design direction and ownership

Design documents define intended behaviour. The as-built record and the resolution of every contradiction found are in [`docs/design/FASE1_PREMIUM_AUDIT.md`](docs/design/FASE1_PREMIUM_AUDIT.md) (v3.0). Where a v2.1 spec disagrees with it, the v3.0 record and the scene win; each affected v2.1 spec carries a note that points to it.

Narrative decisions still open:
- the suppression motive;
- the exact recipient of the audit and who supervises it;
- the final identity and visual design of the recovery unit;
- the Elena/Iris/Selene chronology at this moment;
- Marcus's role and the destination after the parking scene.

## Sources of truth

- **As-built Phase 1 v3.0 (datums, geometry, threats, movement, performance):** `docs/design/FASE1_PREMIUM_AUDIT.md`.
- Architecture and program: `docs/design/FASE1_ARCHITECTURAL_LAYOUT.md` v2.1 (datums superseded by v3.0).
- Spatial graph: `docs/design/FASE1_SPATIAL_GRAPH.md` v1.1 (heights superseded). The runtime graph is `scripts/phase1/phase1_route_graph.gd`.
- Greybox: `docs/design/FASE1_GREYBOX_SPEC.md` v2.1 (datums, S2, bridge, R1 and O3 superseded).
- Functional experience: `docs/design/FASE1_FUNCTIONAL_SPEC.md` v2.1.
- Circuit logic: `docs/design/FASE1_LOGIC_CONTRACT.md` (**unchanged**; only the E panel sits 3 m higher).
- Lift: `docs/design/FASE1_LIFT_GATE.md` (stops at P0 0 and M +3; occupancy hold).
- Progression: `docs/design/fase1_fase2_mapa_progresion.md` v1.1.
- Build and verification: `docs/design/FASE1_CANONICAL_BUILD.md`.
- Phase 2 parking: `docs/LEVEL_STRUCTURE.md` and `docs/design/assets/phase2_parking/`.

## Implemented and verified (automated)

- **Building:** P−1 −2, P0 0, M +3, P2 +6. Includes the west tunnel, the P−1 pit with schematic and A→T bridge, maintenance, the lift P0↔M, S1/S2 as solid stairs with rails, control E, the archive, the two-leaf G airlock, the evacuation gallery and the east mouth at X=34.
- **Static batching:** per material, per 12 m cell and per storey band. Each storey's lights reach only that storey.
- **Puzzle:** maintenance turns on lights and pumps, powers the lift and queues `SERVICE_OVERRIDE`. Then: isolate ENSAYO, select ARCHIVO, check, rearm. The archive opens only with ARCHIVO stable. The scanner reveals things; it never gives the solution.
- **Escape:**
  - Opening G (outer leaf) starts Containment: alarms, O1 topples, R1 closes, and the recovery unit enters.
  - STAFF-M1 can report Elena; it never fights.
  - The unit rides the real lift. Containment telemetry reports a location, never Elena's position.
  - A hand crank opens R1. A running chase follows through S1, P−1 and the gallery.
  - Checkpoints F/M/P0/P−1 restore fairly after a catch.
- **Movement:**
  - Walk; run (Shift); crouch (Ctrl/C) with a real capsule change.
  - Jump with coyote time and input buffer.
  - Ledge mantle from 0.45 to 1.85 m, never over or through rails. No free climbing.
  - A single stamina gauge; full animation set; over-the-shoulder camera.
- **Handoff to Phase 2:** handled by `phase1_handoff.gd` (consumed once). Momentum, facing and the arriving unit carry over into the parking scene.
- **UI:**
  - The control legend lists only the actions that really work.
  - Hint ladder on H.
  - Every new text exists in ES and EN.

## Known limits (not hidden)

- **Performance:** worst views on the HD 630 at 720p:
  - Pumps: 30.4 ms.
  - Control: 22–26 ms.
  - Nave: 23 ms.
  - Pit: about 24 ms.

  The 60 FPS target is not met. See audit §6. The renderer stays at Compatibility unless the owner approves a change.
- No human playtest. Fairness, camera comfort, readability and fun are unverified.
- Synthesized audio has not been listened to. The Web export has not been tested.
- The parking scene is still the motion-prototype corridor with a built service mouth, not final parking geometry.
- The MPFB licence for Elena's model is unverified (`docs/art/PROVENANCE.md`).
- Phase 1 has no quick save; mission state is session-only, by contract.
- The accessibility input actions (captions, font size, colour-blind mode) are defined but have no handler. Remapping works through the InputMap, but there is no remapping UI in Phase 1. Critical states (circuit panel, unit awareness, R1 status) carry text or icon shapes as well as colour. A full colour-blind audit has not been done.

## 7. Test evidence

- **Commit:** `427dca3` (code; later commits are docs only).
- **Engine:** Godot 4.7.2-stable win64 console.
- **Renderer:** GL Compatibility, Windows 10, Intel HD 630.
- **Command, per suite:** `Godot_v4.7.2-stable_win64_console.exe --headless --fixed-fps 60 --path . res://tests/<suite>.tscn`
- **Result:** 32/32 suites exit 0, with 853 PASS checks, 0 FAIL and 0 SCRIPT ERROR.

| Suite | Checks |
|---|---|
| test_phase_0 | 7 |
| test_phase1_playthrough (route bot, full route to handoff) | 45 |
| test_phase1_canonical_greybox | 32 |
| test_phase1_edges (fall and softlock probes) | 23 |
| test_phase1_containment | 22 |
| test_phase1_escape_live | 5 |
| test_phase1_navigation | 32 |
| test_phase1_layout | 30 |
| test_phase1_interactions | 25 |
| test_phase1_circuit_model | 54 |
| test_phase1_exploration | 13 |
| test_phase1_dressing | 7 |
| test_phase2_parking_entry | 16 |
| test_elena_movement | 14 |
| test_elena_animations | 75 |
| test_service_lift | 32 |
| test_service_lift_transport | 14 |
| test_motion_chase_prototype | 34 |
| Control-room suites, other prototype and legacy suites (first_room_rules and vertical_slice print PASS) | the rest |

Expected warnings:
- "ObjectDB instances leaked at exit" in 9 suites, from test teardown.
- "Unknown control room text key: not_a_key" and "Guardado corrupto (CRC32 no coincide)", both from deliberate negative tests.

Review captures are kept outside the repo (`D:/Projects/evidence/final-thaw/phase1_premium_2026-10-15/`).

## Next work

1. Human playtest of the full route; record times, deaths, stuck points and comprehension of the puzzle without text.
2. Profile on the new PC; then decide on renderer and material consolidation with the owner.
3. Build the final parking geometry for Phase 2 at the selected transform.
4. Close the open narrative decisions; verify the MPFB licence.

Preserve the existing autoloads, InputMap action names and remaps, resource paths, JSON/CRC32 save compatibility and the Compatibility renderer.
