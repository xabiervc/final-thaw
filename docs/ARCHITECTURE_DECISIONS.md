# FINAL THAW — Architecture Decisions

## Status

**Decision recorded:** 2026-10-14  
**Decision:** Adopt `scenes/levels/flooded_shelter_2_5d.tscn` as the canonical Flooded Shelter implementation.

## Context

The repository currently contains two playable implementations of the Flooded Shelter beat.

| Area | `flooded_shelter.tscn` | `flooded_shelter_2_5d.tscn` |
|---|---|---|
| Scene construction | Entirely dynamic in code | Node-based scene with explicit hierarchy |
| Controller | `vertical_slice/flooded_shelter.gd` | `levels/flooded_shelter_controller.gd` |
| Player | `entities/player.gd` | `entities/elena.gd` |
| Civilian | Dynamic interactable metadata | Dedicated `Civilian` entity |
| Rules | `vertical_slice/shelter_rules.gd` | Controller-owned signals and state |
| UI | Dynamic labels | `DemoHUD` and `DemoEnd` |
| Accessibility | AccessibilityManager, sound cues, remapping | Not yet integrated |
| Narrative grace period | Implemented | Not yet implemented |
| Puzzle model | One valve station | Two valve stations and partial progress |

## Decision

Use `flooded_shelter_2_5d.tscn` as the production base for the Flooded Shelter vertical slice.

The dynamically built `flooded_shelter.tscn` remains a useful accessibility and systems laboratory, but it should not receive new production features until the canonical implementation reaches parity.

## Rationale

1. The 2.5D scene is node-based, making it easier to review, edit, QA and extend in the Godot editor.
2. It already has a dedicated controller, `FloodedShelterController`, with clear signals.
3. It separates Elena, civilian, props, win zone and UI into distinct scene nodes and scripts.
4. Its two-valve design creates meaningful partial progress and a clearer puzzle arc.
5. Its `DemoHUD` and `DemoEnd` are already connected through signals.
6. Its persistence keys already match `GameStateManager`: `shelter_power_restored`, `shelter_valves_opened` and `shelter_civilian_rescued`.

## Required migration work

Before the canonical scene is presentation-ready, it must receive the improvements already developed in the dynamic prototype:

1. Call `restore_from_persistence()` during controller setup.
2. Emit initial civilian and oxygen state after scene readiness.
3. Route all civilian, HUD and end-screen strings through `NarrativeTextManager`.
4. Integrate `AccessibilityManager` into `DemoHUD`, `DemoEnd` and Elena.
5. Add the narrative dismissal grace period to prevent `interact` conflicts.
6. Integrate `SoundCueHUD` for generator, valves, rescue and oxygen events.
7. Define a shared interaction contract across `player.gd`, `elena.gd` and `elena_controller.gd`.
8. Audit whether Elena's interaction signals are connected in the scene.
9. Decide the canonical oxygen model: continuous drain versus drain after valves open.
10. Migrate or adapt relevant tests from `test_vertical_slice.gd`.

## Non-goals

- Do not delete `flooded_shelter.tscn` yet.
- Do not delete `DemoHUD` or `DemoEnd`.
- Do not mark the canonical scene verified until Godot playtesting and automated tests provide evidence.

## Consequences

- New Flooded Shelter features should target `flooded_shelter_2_5d.tscn`.
- Accessibility work must be ported from the dynamic prototype to the canonical scene.
- The dynamic prototype remains available for isolated systems testing.
- The final game should have one shelter controller contract, one player interaction contract and one UI accessibility contract.
