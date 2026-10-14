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

The functional decisions for Phase 1 are closed in `docs/design/FASE1_FUNCTIONAL_SPEC.md`. Its construction geometry, spatial graph and progression map are reconciled and versioned. This closure is design authority, not Godot validation.

## Mission 1 — The Ghost Protocol

**Primary verb: understand.**

- One traversal order: entry → pit and maintenance switch → platform elevator → controls → archive → G → exterior.
- Maintenance starts off. The single platform elevator is in the existing shaft footprint and requires maintenance. The fixed pit stairs never require power.
- The extra platform reservation X=30..34 and provisional ramp have been removed from the final slice; there is no alternate B route.
- The circuit follows `FASE1_LOGIC_CONTRACT.md`: safe order is isolate trial, select ARCHIVO, verify. An unsafe order trips protection but remains recoverable.
- The archive contains one session-persistent record contradicting the official summary. Reading it is not extraction and does not change the save format.
- The maintenance switch queues SERVICE_OVERRIDE locally. Crossing the outer G hatch sends the queued audit and starts Containment. Reading the record adds RESTRICTED_RECORD_READ but is not the trigger by itself.

## Mission 2 — Containment

**Primary verb: escape.**

The existing motion/chase prototype is the foundation, not yet validated or campaign-integrated. It includes a third-person camera, movement, jumps, crouch, a defined climb, scanner, checkpoints and a patrol/investigate/alert/chase/search/return recovery unit. It has no navigation mesh, crouch/climb animations are provisional, and detection/noise values need playtesting.

Do not connect H until Phase 1's scene and tests are stable and the v2 motion/chase test has been run.

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
