# FINAL THAW — Design Authority

## Purpose

This document identifies design documents that currently govern implementation, distinguishes legacy specifications from approved direction, and defines conflict resolution while the game is undergoing a prototype-led redesign.

**Important status:** the legacy design package and new prototype brief are not fully reconciled. Until playtest results are reviewed, do not treat the legacy full-campaign requirements as requirements for the new prototype.

## Active working authority

| Area | Document | Status | Scope |
|---|---|---|---|
| Prototype direction | `docs/DESIGN_PIVOT_PROTOTYPE_BRIEF.md` | **ACTIVE WORKING BRIEF — VALIDATE, NOT FINAL CAMPAIGN CANON** | Next proof of concept only: Elena-led 3D traversal, investigation puzzle, pursuit/escape |
| Current implementation evidence | `PROJECT_STATUS.md` | Status record | What currently exists, test evidence, known gaps and next milestone |
| Asset provenance | `docs/art/PROVENANCE.md` | Active technical record | Source/licence tracking; required before shipping external or derived assets |
| Technical/agent workflow | `docs/PROJECT_CONTRACT.md`, `docs/QUALITY_GATES.md`, `AGENTS.md` | Active | Safety, implementation and verification procedure |
| Phase 0 contracts | Existing test suite and technical contract docs | Protected baseline | Input/autoload/resource/save compatibility until reviewed change is explicitly approved |

## Legacy design specifications — under review

The following files contain detailed prior-direction assumptions. They remain useful as historical source material but must not be taken as binding scope for the new prototype without explicit reconciliation:

- `docs/VISION.md` — dual-protagonist player fantasy, four fixed pillars and 13–15-hour campaign.
- `docs/CORE_LOOP.md` and `docs/core_gameplay_loop.md` — timed puzzle rooms, Marcus combat arenas, and fixed decision metrics.
- `docs/LEVEL_STRUCTURE.md`, `docs/EXPLORATION_FLOW.md`, `docs/PROGRESSION_SPEC.md`, `docs/VERTICAL_SLICE_PLAN.md` — fixed phase/room counts and campaign flow.
- `docs/SYSTEMS_SPEC.md`, `docs/SURVIVAL_SYSTEMS.md`, `docs/NARRATIVE_STATE_MAP.md` — resource/ending thresholds and systems that may not survive the pivot.
- `docs/TRACEABILITY_MATRIX.md` — traces prior pillars and mechanics, not yet the new prototype.
- `docs/narrative_complete.md` — detailed full-campaign narrative that must be selectively reconciled with the two-mission opening.
- `GDD.md` — high-level aspirational document with scope and award claims, not the acceptance authority for current implementation.

Do not delete these documents. Do not implement them as new-prototype requirements merely because they were previously labelled normative. Update them only after the owner reviews prototype evidence and the new scope is deliberately adopted.

## Conflict resolution during redesign

1. For the **next prototype's scope and acceptance criteria**, use `docs/DESIGN_PIVOT_PROTOTYPE_BRIEF.md`.
2. For **what the code currently does**, use the actual branch plus `PROJECT_STATUS.md` and reproducible test/playtest evidence; a design brief is not proof of implementation.
3. For **Phase 0 technical contracts**, preserve the current tests and technical contract docs unless a dedicated impact analysis and approval authorize a change.
4. When another legacy design document conflicts with the prototype brief, treat it as legacy guidance for this prototype and record the conflict rather than silently merging both directions.
5. This temporary precedence does not approve a full-game redesign or a new save format. After the prototype gate, the owner must decide whether to promote the new direction to full-campaign canon.
6. Do not declare completion, performance, accessibility, compatibility or a successful playtest without evidence.

## Required review gates

### Before implementing movement/traversal
- Confirm target Godot version, current renderer and required target platforms.
- Inspect existing controller, camera, input actions and collision layers.
- Define observable acceptance tests for movement, jump/landing, crawl and climb.
- Keep the change isolated from save, autoload and Phase 0 behavior.

### Before adding pursuit AI
- Specify state machine and visible tells.
- Define line-of-sight break, search, recovery, checkpoint/death behavior and deterministic tests.
- Confirm the encounter introduces a route/timing/concealment decision and is not just a timer.

### Before approving assets
- Review from the intended gameplay camera, not only beauty renders.
- Verify scale, collider alignment, traversal clearance, camera occlusion, state/scan visibility, performance and licensing.
- Record owner review and a build identifier.

### After the five-minute proof of concept
- Run regression tests and manual playtest.
- Record failures and player observations.
- Decide explicitly which legacy mechanics, characters, ending rules, platforms and campaign assumptions survive.
- Only then reconcile normative design documents and traceability.

## Change policy

- Typos and clarifications may be edited directly.
- Changes to mechanics, narrative, accessibility, scope or normative hierarchy require an explicit design decision and impact analysis.
- Do not make irreversible scene deletion, wholesale art replacement, renderer migration, save migration or autoload/input contract changes as part of the proof-of-concept task.
