# FINAL THAW — Design Authority During Prototype-Led Redesign

## Purpose

This document separates the current working direction, actual implementation evidence, protected technical contracts and legacy full-campaign specifications. The project is in a prototype-led redesign; the previous design package is not fully reconciled with the new opening.

## Active design authority

| Area | Source | Status |
|---|---|---|
| Working vision | `docs/VISION.md` | Active working vision; validate before locking full-game canon |
| Next prototype scope and acceptance | `docs/DESIGN_PIVOT_PROTOTYPE_BRIEF.md` | Active brief for the opening prototype only |
| Current movement/chase mechanics | `docs/design/MOTION_CHASE_PROTOTYPE.md` plus code | Active prototype specification; v2 test not yet recorded as run |
| Core loop | `docs/CORE_LOOP.md` | Active loop for the motion/chase prototype and proposed investigation mission |
| Level structure | `docs/LEVEL_STRUCTURE.md` | Active prototype map and proposed two-mission opening |
| Implementation status | `PROJECT_STATUS.md` plus current code and test evidence | Source for what exists and what has actually been verified |
| Prototype traceability | `docs/TRACEABILITY_MATRIX.md` | Active mapping of code/test coverage and unimplemented requirements |
| Narrative source | `docs/narrative_complete.md` | Existing story details preserved; full campaign structure under review |
| Technical/agent workflow | `docs/PROJECT_CONTRACT.md`, `docs/QUALITY_GATES.md`, `AGENTS.md` | Active technical and workflow contracts |
| Asset provenance | `docs/art/PROVENANCE.md` | Active source/licence record |

## Legacy specifications under review

The following still contain earlier assumptions such as fixed 16 phases, 13–15 hour playtime, dual-protagonist switching, Marcus combat, combat arenas, survival counters and three fixed endings:
- `docs/core_gameplay_loop.md`
- detailed campaign tables in `docs/narrative_complete.md`
- `docs/EXPLORATION_FLOW.md`, `docs/PROGRESSION_SPEC.md`, `docs/SURVIVAL_SYSTEMS.md`, `docs/NARRATIVE_STATE_MAP.md`
- `docs/VERTICAL_SLICE_PLAN.md`
- remaining legacy sections of `docs/TRACEABILITY_MATRIX.md` if encountered in other copies or summaries.

Do not implement those assumptions as requirements for the current prototype. Do not delete them yet: they contain story and design material that should be reconciled deliberately after a playtest.

## Conflict resolution

1. For **the next prototype's intended behavior**, use the working brief and prototype specification.
2. For **what exists**, inspect the code and scene files. Documentation is not proof of implementation.
3. For **test status**, require an exact command and observed result. Automated checks do not replace a manual playtest.
4. For **Phase 0 technical contracts**, preserve input actions, autoloads, resource paths, save JSON/CRC32 and project assumptions unless an impact review and explicit approval authorize a change.
5. When a legacy campaign document conflicts with the current prototype brief, the brief wins for prototype scope only. Record the conflict; do not silently declare the full campaign redesigned.
6. Promote the new direction to full-game canon only after owner review of the combined puzzle/escape prototype and explicit reconciliation of narrative, progression, accessibility, platforms and endings.

## Required review gates

### Motion/chase v2
- Run `godot --headless --path . res://tests/test_motion_chase_prototype.tscn`.
- Run `godot --headless --path . res://tests/test_phase_0.tscn`.
- Run the scene manually; review movement, jump range, crouch clearance, climb, camera occlusion, enemy sight/hearing, search, catches, checkpoints and exit.
- Record Godot version, results, defects and evidence.

### Investigation puzzle and narrative bridge
- Define clue relationships and intended inference before implementation.
- Ensure the scanner supports reasoning but does not reveal the answer.
- Test feedback, hints, accessibility and alternative recovery.
- Verify puzzle completion causes a single, visible lockdown transition and that the chase follows causally.

### Assets and production
- Review from gameplay camera, not beauty renders alone.
- Verify scale, collider alignment, clearance, occlusion, performance and provenance/licensing.
- Do not call an asset production-ready without Godot integration and owner review.

### Full-game reconciliation
After the combined opening passes:
- Decide Marcus's role and whether the dual-protagonist premise survives.
- Reconcile campaign structure, endings, total duration and platform scope.
- Update narrative-state documents, progression, accessibility and traceability.
- Mark superseded specifications explicitly; preserve useful history.

## Change policy

Keep prototype changes small and reversible. Do not make wholesale renderer migrations, save migrations, scene deletions, autoload/input contract changes or full-campaign rewrites as incidental parts of the prototype task.
