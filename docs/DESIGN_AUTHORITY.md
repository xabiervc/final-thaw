# FINAL THAW — Design Authority During Prototype-Led Redesign

## Purpose

This document separates current design direction, actual implementation evidence, protected technical contracts and legacy full-campaign specifications. The project is developing a two-mission opening; the former campaign package is not fully reconciled with this direction.

## Active design authority

| Area | Source | Status |
|---|---|---|
| Working vision | `docs/VISION.md` | Active working vision; full-game canon is not locked |
| Prototype scope and boundaries | `docs/DESIGN_PIVOT_PROTOTYPE_BRIEF.md` | Active brief for the opening prototype |
| Core gameplay and narrative loop | `docs/CORE_LOOP.md` | Active design contract for the opening; implementation state is separately tracked |
| Opening level structure and Phase 2 spatial design | `docs/LEVEL_STRUCTURE.md` plus `docs/design/assets/phase2_parking/` | Design authority for route, concept v0.3 plan/section, edge clearances, obstacle register and selected handoff transform; dimensions/colliders require runtime reconciliation |
| Mission 1 puzzle | `docs/design/MISSION1_GHOST_PROTOCOL.md` plus `docs/design/FASE1_LOGIC_CONTRACT.md` | Puzzle design and logic contract; implementation and integration must be evidenced |
| Phase 1 architecture/program | `docs/design/FASE1_ARCHITECTURAL_LAYOUT.md` v2.0 | Current spatial intent; plans, graph and scene must remain aligned |
| Phase 1 plans and section | `docs/design/assets/phase1_architecture/` | Current drawing authority for Phase 1; physical alignment remains pending verification |
| Phase 1 spatial graph | `docs/design/FASE1_SPATIAL_GRAPH.md` v1.0 | Current target topology; verify footprints and traversability in Godot |
| Phase 1 greybox dimensions/collisions | `docs/design/FASE1_GREYBOX_SPEC.md` v2.0 | Target measurements and collision contract, not proof of built geometry |
| Phase 1 functional experience | `docs/design/FASE1_FUNCTIONAL_SPEC.md` v2.0 | Target interactions, puzzle and escape flow; some escape requirements are not implemented |
| Phase 1/2 progression | `docs/design/fase1_fase2_mapa_progresion.md` v1.0 | Quiet evasion → perceptible reacquisition → running chase → selected exit and physical parking handoff; implementation pending |
| Movement/chase prototype mechanics | `docs/design/MOTION_CHASE_PROTOTYPE.md` plus current code | Prototype behavior and known limits; v2 test/playtest status must be recorded |
| Requirement-to-evidence mapping | `docs/TRACEABILITY_MATRIX.md` | Maps intended behavior to implementation, tests and verification gaps |
| Implementation status | `PROJECT_STATUS.md`, current scene/script/test state and recorded results | Source of truth for what exists and what was actually verified |
| Narrative legacy archive | `docs/narrative_complete.md` and explicitly marked legacy documents | Historical source material only where it conflicts with the active prototype direction |
| Technical/workflow contracts | `docs/PROJECT_CONTRACT.md`, `docs/QUALITY_GATES.md`, `AGENTS.md` | Protected engineering, testing and evidence requirements |
| Asset provenance | `docs/art/PROVENANCE.md` | Active source/licence record |

## Legacy specifications under review

Earlier documents describe a fixed 16-phase campaign, 13–15 hour duration, dual-protagonist switching, Marcus combat, combat arenas, survival counters and three fixed endings. Preserve this material as historical input; do not silently treat it as current prototype scope or erase its useful story ideas.

Relevant legacy sources include `docs/core_gameplay_loop.md`, detailed campaign tables in `docs/narrative_complete.md`, `docs/EXPLORATION_FLOW.md`, `docs/PROGRESSION_SPEC.md`, `docs/SURVIVAL_SYSTEMS.md`, `docs/NARRATIVE_STATE_MAP.md`, `docs/VERTICAL_SLICE_PLAN.md` and older phase prompts.

## Conflict resolution

1. For Phase 1 spatial intent, use `FASE1_ARCHITECTURAL_LAYOUT.md` v2.0, the current plan/section SVGs, `FASE1_SPATIAL_GRAPH.md` v1.0 and `FASE1_GREYBOX_SPEC.md` v2.0. Older references to v1.0/v0.6 are superseded.
2. For the opening's player-facing behavior and mission boundaries, use `DESIGN_PIVOT_PROTOTYPE_BRIEF.md`, `CORE_LOOP.md` and `LEVEL_STRUCTURE.md`.
3. For Phase 1 circuit behavior, `FASE1_LOGIC_CONTRACT.md` remains authoritative unless a specific change is explicitly approved.
4. For what exists, inspect current code, scenes and tests. Design documentation does not prove implementation.
5. For test status, require the exact command and observed result. A test file is not evidence that the test ran; a passing headless test is not a substitute for a manual playtest.
6. Preserve Phase 0 input actions/remaps, autoloads/public signals, resource paths, JSON/CRC32 save compatibility and Compatibility renderer assumptions unless impact analysis and explicit approval authorize a change.
7. When a legacy campaign document conflicts with the active prototype brief, the brief wins for prototype scope only. Record the conflict; do not silently declare the whole campaign redesigned.
8. Separate established story facts from proposals. The opening proposal now defines the causal beat (maintenance queues `SERVICE_OVERRIDE`; opening G's exterior leaf sends the audit and starts Containment) and recommends a facility-automated recovery protocol. The exact recipient/supervision, final recovery-unit identity, suppression motive, Marcus's role, chronology and endings remain open; do not promote proposals to full-game canon without owner approval.
9. Do not invent architectural connections to solve a gameplay beat. All routes must be present in plan, section, spatial graph and acceptance criteria before implementation.

## Required review gates

### Mission 1 — The Ghost Protocol
- Confirm the circuit follows `FASE1_LOGIC_CONTRACT.md` and scanner clues do not reveal the answer.
- Verify partial success, invalid order, safe recovery and restricted-record behavior.
- Verify the reveal triggers Containment exactly once and only under the agreed event contract.

### Mission 2 — Containment and parking
- Review the provisional plan, section, spatial graph, edge-clearance contract, obstacle register and conceptual threat/light overlays as a consistent package; the P−1 east mouth and local-to-world transform are selected design baselines; verify their actual footprint, elevation and clearances against the canonical scene before implementation acceptance.
- Run `godot --headless --path . res://tests/test_motion_chase_prototype.tscn` and `godot --headless --path . res://tests/test_phase_0.tscn`.
- Run the scene manually; review movement, camera occlusion, staff NPC routines/perception, noise and cover in the quiet section, the mapped transition to running chase, enemy sight/hearing/search, catches, checkpoints, selected exit and physical handoff.
- Verify the Phase 1 interior pursuit and distinct P−1 service exit before accepting the parking integration.
- Record engine version, renderer, commit, commands/output, warnings/errors, manual QA, evidence and remaining limitations.

### Narrative and integration
- Define clue relationships and intended inference before implementation.
- Make the scanner support reasoning without solving the puzzle.
- Ensure the system reveal causes a single visible and audible Containment response.
- Ensure Mission 2 adds a new narrative implication without claiming unsupported canon.
- Test mission continuity, state preservation, checkpoint behavior and the end-of-mission beat.

### Asset and production
- Review from the actual gameplay camera, not beauty renders alone.
- Verify scale, collision alignment, clearance, occlusion, performance and asset provenance.
- Do not call an asset production-ready without integration and owner review.

### Full-game reconciliation
After the combined opening is reviewed and playtested, explicitly decide whether the two-mission direction is accepted as campaign canon. Then reconcile Marcus's role, chronology, campaign structure, endings, duration, platform scope, accessibility and narrative-state documents. Until then, keep the prior campaign preserved as legacy material.

## Change policy

Keep design changes traceable and reversible. Update existing sources of truth instead of creating competing documents. Never claim a feature is specified, implemented, tested, playable or production-ready beyond the evidence actually available.
