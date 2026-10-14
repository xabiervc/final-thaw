# FINAL THAW — Critical Documentation Index

**Current status:** prototype-led redesign of the opening. Older documents still describe a former dual-protagonist, combat-arena and fixed 16-phase campaign; treat those as historical material until deliberately reconciled.

## Read these first

1. [Working vision](VISION.md) — player fantasy, pillars, anti-pillars and scope.
2. [Design authority](DESIGN_AUTHORITY.md) — precedence, conflict resolution and current sources of truth.
3. [Prototype brief](DESIGN_PIVOT_PROTOTYPE_BRIEF.md) — two-mission opening, boundaries and implementation order.
4. [Core loop and mission contracts](CORE_LOOP.md) — player verbs, threat rules, narrative progression and continuity.
5. [Level structure and Phase 2 spatial design](LEVEL_STRUCTURE.md) — parking architecture, candidate transform, route graph, clearances, obstacle register, narrative beats and acceptance gates.
   - [Parking concept plan](design/assets/phase2_parking/parking_plan_concept.svg) — provisional 48 × 30 m layout, two routes, cover, obstacles, sightline and light overlays.
   - [Parking concept section](design/assets/phase2_parking/section_parking_concept.svg) — provisional vertical relationships; exterior datum still unresolved.
6. [Mission 1 puzzle](design/MISSION1_GHOST_PROTOCOL.md) — investigation, clue relationships and puzzle feedback.
7. [Phase 1 architecture](design/FASE1_ARCHITECTURAL_LAYOUT.md) — building program, routes and escape intent.
8. [Phase 1 progression](design/fase1_fase2_mapa_progresion.md) — route, state transitions, chase sequence and parking handoff.
9. [Motion/chase mechanics prototype](design/MOTION_CHASE_PROTOTYPE.md) — current movement, scanner, recovery-unit behavior, controls, limits and run commands.
10. [Traceability matrix](TRACEABILITY_MATRIX.md) — maps requirements to design evidence, implementation and verification gaps.
11. [Project status](../PROJECT_STATUS.md) — current implementation evidence and next milestone.
12. [Narrative archive](narrative_complete.md) — legacy story material; not automatically current canon.

## Technical governance and production constraints

- [Project contract](PROJECT_CONTRACT.md)
- [Quality gates](QUALITY_GATES.md)
- [Agent instructions](../AGENTS.md)
- [Asset provenance](art/PROVENANCE.md)

## Current prototype paths

- Standalone mechanics scene: `scenes/prototypes/motion_chase_prototype.tscn`
- Phase 2 parking entry scene: `scenes/prototypes/phase2_parking_chase.tscn`
- Builder: `scripts/prototypes/motion_chase_prototype.gd`
- Behavior test scene: `tests/test_motion_chase_prototype.tscn`
- Behavior test script: `tests/test_motion_chase_prototype.gd`

Commands from repository root:

```sh
godot --path . res://scenes/prototypes/motion_chase_prototype.tscn
godot --headless --path . res://tests/test_motion_chase_prototype.tscn
godot --headless --path . res://tests/test_phase_0.tscn
```

The v2 prototype documentation has not recorded a successful run of its automated test. A passing headless test is necessary but insufficient: movement feel, camera readability, threat fairness, audio, route choice and narrative comprehension require a hands-on playtest.

## Legacy specifications under review

`core_gameplay_loop.md`, `SURVIVAL_SYSTEMS.md`, `EXPLORATION_FLOW.md`, `NARRATIVE_STATE_MAP.md`, `PROGRESSION_SPEC.md`, `VERTICAL_SLICE_PLAN.md`, detailed campaign sections in `narrative_complete.md`, and old ending/Marcus-combat traceability are historical material. Their presence does not make them binding requirements for the current prototype.

## Status rule

Separate **specified**, **implemented in code**, **covered by an automated test**, **test executed successfully**, **hands-on validated**, and **accepted by the design owner**. These are different claims and require different evidence.
