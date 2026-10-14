# UI Audit — Flooded Shelter and Menus

## Audit date

2026-10-14

## Scope

- `scripts/ui/hud.gd`
- `scripts/ui/demo_hud.gd`
- `scripts/ui/demo_end.gd`
- `scripts/ui/prompt_hud.gd`
- `scripts/ui/narrative_panel.gd`
- `scripts/ui/main_menu.gd`
- `scripts/ui/options_menu.gd`
- `scripts/ui/credits.gd`
- `scripts/ui/sound_cue_hud.gd`
- `scenes/ui/*.tscn`
- `scenes/levels/*.tscn`
- `scenes/props/*.tscn`
- `scripts/levels/flooded_shelter_controller.gd`
- `scripts/entities/elena.gd`
- `scripts/entities/civilian.gd`

## Important correction

An earlier audit incorrectly classified `demo_hud.gd` and `demo_end.gd` as unused legacy code.

They are active in `scenes/levels/flooded_shelter_2_5d.tscn`, which uses `FloodedShelterController`, Elena, Civilian, props and a win zone.

Therefore, `DemoHUD` and `DemoEnd` must not be deleted without first completing the canonical-scene migration.

## Canonical decision

`flooded_shelter_2_5d.tscn` is now the canonical Flooded Shelter implementation.

`flooded_shelter.tscn` remains a systems and accessibility laboratory.

## Implementation comparison

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

## Resolved

| Area | Finding | Resolution |
|---|---|---|
| Main menu | Options and Credits were missing | Added both buttons, wired their scenes and restored the five-button contract |
| Main menu | Secondary buttons were not localized | Added localized getters and refresh on language change |
| HUD | Spanish strings were hardcoded | Routed HUD text through `NarrativeTextManager` |
| HUD | Font scale did not update | HUD reapplies font scale on `stats_changed` |
| Prompt HUD | Spanish strings and fixed fonts | Localized and scaled |
| Narrative panel | Fixed font size; `interact` conflict | Added scaling, dismissal signal and grace period |
| Options | Limited accessibility | Added high contrast, reduced motion, subtitles, colorblind modes and core remapping |
| Credits | Spanish-only UI and fixed font size | Localized and scaled |
| Sound cues | No visual equivalent for audio events | Added `SoundCueHUD` and integrated shelter cues |

## Open

| Area | Finding | Risk | Next action |
|---|---|---|---|
| `flooded_shelter_2_5d.tscn` | Canonical scene lacks accessibility parity | Inconsistent player experience | Port AccessibilityManager, sound cues and narrative grace period |
| `DemoHUD` | Active, but not connected to AccessibilityManager | Inconsistent accessibility | Localize and scale; integrate accessibility |
| `DemoEnd` | Active, but not connected to AccessibilityManager | Inconsistent accessibility | Localize and scale; integrate accessibility |
| `civilian.gd` | Rescue dialogue is hardcoded in Spanish | Localization failure | Route through `NarrativeTextManager` |
| `elena.gd` | Interaction signal connections are unverified | Interaction may never work | Verify or add `area_entered` / `area_exited` connections |
| Oxygen | Continuous drain in canonical scene; valves-gated drain in laboratory | Inconsistent difficulty | Choose one canonical survival rule |
| Accessibility | Full remapping, gamepad, subtitle rendering and directional cues remain incomplete | Specification not met | Extend after canonical parity |

## Input conflict resolution

The laboratory implementation resolves the conflict as follows:

1. While a narrative panel is visible, `interact` dismisses it.
2. `narrative_dismissed` starts a 0.35-second grace period.
3. During that period, station interaction is ignored.
4. After the grace period, station interaction resumes.

This behavior must be ported to the canonical 2.5D implementation.

## Localization contract

All player-facing strings must come from `NarrativeTextManager`.

Required key families:

- `menu_*`
- `options_*`
- `credits_*`
- `hud_*`
- `interact_*`
- `shelter_*`
- `end_*`
- `prompt_*`
- `condition_state_*`
- `sound_cue_*`
- `civilian_*`
- `cr_*`

Every new key must have:

- A non-empty fallback.
- An ES entry.
- An EN entry.
- A test or manual localization check.

## Accessibility contract

Before the canonical Flooded Shelter can be called presentation-ready:

- UI scale must work from 0.75 to 2.0.
- High-contrast mode must be implemented.
- Colorblind-safe palettes must be available.
- Reduced motion must reduce or disable tweens, particles and camera shake.
- Subtitle size and background must be configurable.
- Critical audio cues need visual equivalents.
- All interactions must be remappable.

## Verification status

No UI change in this audit is marked verified until Godot is run, the relevant scenes are manually checked, and test evidence is recorded in `PROJECT_STATUS.md`.
