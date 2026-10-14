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
- `scenes/ui/*.tscn`
- `scenes/levels/*.tscn`
- `scenes/props/*.tscn`

## Findings

### Resolved

| Area | Finding | Resolution |
|---|---|---|
| Main menu | Options and Credits were missing; phase 0 expects five menu buttons | Added both buttons, wired their scenes and added all five buttons to `menu_button` |
| Main menu | Secondary buttons were not localized | Added localized getters and refresh on language change |
| HUD | Spanish strings were hardcoded | Routed civilian aid, prototype integrity, Elena safety and FPS through `NarrativeTextManager` |
| HUD | Font scale did not update after changing options | HUD now reapplies font scale when `stats_changed` fires |
| Prompt HUD | Spanish strings and fixed fonts | Localized instructions and condition text; applied font scaling |
| Narrative panel | Fixed font size; `interact` conflict | Applied font scaling and added dismissal signal/grace period |
| Options | Spanish-only UI and fixed font size | Localized and applied `GameManager.font_scale` |
| Credits | Spanish-only UI and fixed font size | Localized and applied `GameManager.font_scale` |
| Narrative manager | Missing methods used by menu and HUD | Added fallback-backed methods and regression tests |

### Open

| Area | Finding | Risk | Next action |
|---|---|---|---|
| `demo_hud.gd` | Depends on nonexistent `FloodedShelterController` | Runtime/type-resolution failure if instantiated | Complete local scene audit, then adapt or remove |
| `demo_end.gd` | Depends on nonexistent `FloodedShelterController` | Runtime/type-resolution failure if instantiated | Complete local scene audit, then adapt or remove |
| Shelter scenes | `flooded_shelter.tscn` and `flooded_shelter_2_5d.tscn` coexist | Wrong scene may be edited or tested | Identify canonical scene and mark/remove the other |
| Shelter scene | Built entirely in code | Hard to review, edit and QA visually | Gradually migrate stable modules to `.tscn` |
| Accessibility | Colorblind, subtitles, reduced motion and input profiles are persisted but not implemented | Specification not met | Implement and validate each option |

## Input conflict resolution

The previous conflict between `narrative_panel.gd` and `flooded_shelter.gd` is resolved:

1. While a narrative panel is visible, `interact` dismisses it.
2. `narrative_dismissed` starts a 0.35-second grace period.
3. During that period, `flooded_shelter.gd` ignores station interaction.
4. After the grace period, station interaction resumes normally.

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
- `cr_*`

Every new key must have:

- A non-empty fallback.
- An ES entry.
- An EN entry.
- A test or manual localization check.

## Accessibility contract

Before the Flooded Shelter can be called presentation-ready:

- UI scale must work from 0.75 to 2.0.
- High-contrast mode must be implemented.
- Colorblind-safe palettes must be available.
- Reduced motion must reduce or disable tweens, particles and camera shake.
- Subtitle size and background must be configurable.
- Critical audio cues need visual equivalents.
- All interactions must be remappable.

## Verification status

No UI change in this audit is marked verified until Godot is run, the relevant scenes are manually checked, and test evidence is recorded in `PROJECT_STATUS.md`.
