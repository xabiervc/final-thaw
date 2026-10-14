# FINAL THAW — Critical Documentation Index

**Current status:** prototype-led redesign. Some older documents still describe a previous dual-protagonist, combat-arena and fixed 16-phase campaign. Those are historical/under review for current prototype work.

## Read these first

1. [Working vision](VISION.md) — player fantasy, pillars, anti-pillars and scope.
2. [Design pivot brief](DESIGN_PIVOT_PROTOTYPE_BRIEF.md) — proposed two-mission opening, acceptance gate and boundaries.
3. [Motion/chase prototype](design/MOTION_CHASE_PROTOTYPE.md) — actual v2 mechanics, geometry, controls, AI, limits and how to run.
4. [Core loop](CORE_LOOP.md) — current/proposed loop and implementation boundary.
5. [Level structure](LEVEL_STRUCTURE.md) — current sandbox and proposed opening.
6. [Project status](../PROJECT_STATUS.md) — implementation evidence and next milestone.
7. [Traceability matrix](TRACEABILITY_MATRIX.md) — code/test mapping and unimplemented requirements.
8. [Narrative](narrative_complete.md) — legacy full campaign retained with opening hypothesis at the top.

## Technical governance

- [Design authority](DESIGN_AUTHORITY.md)
- [Project contract](PROJECT_CONTRACT.md)
- [Quality gates](QUALITY_GATES.md)
- [Agent instructions](../AGENTS.md)
- [Asset provenance](art/PROVENANCE.md)

## Current prototype paths

- Scene: `scenes/prototypes/motion_chase_prototype.tscn`
- Script: `scripts/prototypes/motion_chase_prototype.gd`
- Test scene: `tests/test_motion_chase_prototype.tscn`
- Test script: `tests/test_motion_chase_prototype.gd`

Commands from repository root:

```sh
godot --path . res://scenes/prototypes/motion_chase_prototype.tscn
godot --headless --path . res://tests/test_motion_chase_prototype.tscn
godot --headless --path . res://tests/test_phase_0.tscn
```

The v2 prototype document says its automated test has not yet been run. A successful headless test is necessary but insufficient: movement feel, camera readability, enemy fairness, audio and enjoyment require a hands-on playtest.

## Legacy specifications under review

`core_gameplay_loop.md`, `SURVIVAL_SYSTEMS.md`, `EXPLORATION_FLOW.md`, `NARRATIVE_STATE_MAP.md`, `PROGRESSION_SPEC.md`, `VERTICAL_SLICE_PLAN.md`, detailed campaign sections in `narrative_complete.md`, and old ending/Marcus-combat traceability are historical material. Their existence does not make them binding requirements for the new prototype.

## Status rule

Separate **implemented in code**, **covered by automated test**, **run successfully**, and **validated in hands-on playtest**. These are not equivalent.
