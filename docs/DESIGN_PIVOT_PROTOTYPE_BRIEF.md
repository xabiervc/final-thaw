# FINAL THAW — Design Pivot and Prototype Brief

**Status:** active working brief for the opening prototype; not the locked full-game specification.  
**Last reviewed:** 2026-10-14  
**Branch:** `feat/godot-vertical-slice`

## Purpose

Build and validate a small playable opening from the existing repository instead of extending the former 16-phase/two-protagonist campaign package. This brief governs the prototype only. It does not automatically rewrite the full campaign, final endings, Marcus's role, save schema or established story chronology.

## Current opening

The opening has two causally linked slices:

1. **The Ghost Protocol — investigation/system puzzle.** Elena reconstructs an Aster test by comparing the intended circuit diagram, a physically manipulated A→T bridge, protection behaviour and a restricted record.
2. **Containment — traversal/stealth/escape.** Leaving through G synchronizes a queued service audit; Helix activates a recovery unit that searches for Elena using bounded vision/noise rules.

The functional decisions for Phase 1 are closed in `docs/design/FASE1_FUNCTIONAL_SPEC.md`. Its construction geometry, spatial graph and progression map are reconciled and versioned. The first canonical scene is `scenes/prototypes/phase1_canonical_greybox.tscn`, with an integration test at `tests/test_phase1_canonical_greybox.tscn`. This is code presence, not Godot validation.

## Mission 1 — The Ghost Protocol

**Primary verb: understand.**

- One traversal order: entry → pit and maintenance switch → platform elevator → controls → archive → G → exterior.
- Maintenance starts off. The single platform elevator is in the existing shaft footprint and requires maintenance. The fixed pit stairs never require power.
- The extra platform reservation X=30..34 and provisional ramp have been removed from the final slice; there is no alternate B route.
- The circuit follows `FASE1_LOGIC_CONTRACT.md`: safe order is isolate trial, select ARCHIVO, verify. An unsafe order trips protection but remains recoverable.
- The archive contains one session-persistent record contradicting the official summary. Reading it is not extraction and does not change the save format.
- The maintenance interaction queues `SERVICE_OVERRIDE` as a mission-level flag separate from the circuit model. Opening the exterior leaf of G while the flag is queued sends the audit and starts Containment exactly once. Reading the record adds `RESTRICTED_RECORD_READ` but is not the trigger by itself. Without the queued flag, G does not start the chase.

## Mission 2 — Containment

**Primary verb: escape.**

The design authority for parking architecture, route topology, encounter beats, environmental storytelling and acceptance is `docs/LEVEL_STRUCTURE.md`; the core behavior and narrative continuity contract is `docs/CORE_LOOP.md`. The opening script proposal and unresolved story decisions are recorded at the top of `docs/narrative_complete.md`. These sources define intent; none certifies runtime implementation.

The existing motion/chase prototype is the foundation, not yet validated or campaign-integrated. It includes a third-person camera, movement, jumps, crouch, a defined climb, scanner, checkpoints and a patrol/investigate/alert/chase/search/return recovery unit. It has no navigation mesh, crouch/climb animations are provisional, and detection/noise values need playtesting.

The current canonical scene contains a provisional G→H handoff into the existing motion/chase scene so the boundary can be tested end to end. This is a temporary prototype integration boundary, not the final Phase 1 → Phase 2 handoff. The final design preserves Elena's world transform at P2-01 (the P−1 service threshold); P2-CP is a recovery-only checkpoint, not the initial spawn. Do not accept the combined slice or tune campaign pacing until the Phase 1 scene/tests are stable, the v2 motion/chase test has run, and a hands-on chase playtest is recorded.

## Implementation order

1. Construct Phase 1 geometry and single platform elevator from the reconciled greybox.
2. Implement/test circuit state machine independently, then connect physical interactions.
3. Implement diagnostic display, status fixtures, archive consultation and session knowledge.
4. Implement G exit, queued audit and transition trigger.
5. Execute Phase 1 automated tests and Phase 0 regression; fix defects and record evidence.
6. Run the motion/chase v2 automated test, then play it manually; only then connect H.
7. Conduct combined hands-on playtest before expanding content or revising full-campaign canon.

## Technical boundaries and evidence

Preserve Phase 0 input/autoload/resource/save/CRC32 contracts, Compatibility renderer and existing resource paths. Keep legacy scenes. No weapons, combat, full inventory, campaign rewrite, save-schema migration or final art expansion in this slice.

For every acceptance claim, distinguish static review, code present, automated test coverage, test executed, hands-on validation and production readiness. Run and report Godot version, exact commands/output, defects, camera/collision observations, player comprehension and performance notes.

The MPFB/MakeHuman asset licence remains a shipping blocker until verified from authoritative terms.
