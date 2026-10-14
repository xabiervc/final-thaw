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

## Findings

### Resolved

| Area | Finding | Resolution |
|---|---|---|
| Main menu | Options and Credits were missing; phase 0 expects five menu buttons | Added both buttons, wired their scenes and added all five buttons to `menu_button` |
| Main menu | Secondary buttons were not localized | Added localized getters and refresh on language change |
| HUD | Spanish strings were hardcoded | Routed civilian aid, prototype integrity, Elena safety and FPS through `NarrativeTextManager` |
| HUD | Font scale did not update after changing options | HUD now reapplies font scale when `stats_changed` fires |
| Options | Spanish-only UI and fixed font size | Localized and applied `GameManager.font_scale` |
| Credits | Spanish-only UI and fixed font size | Localized and applied `GameManager.font_scale` |
| Narrative manager | Missing methods used by menu and HUD | Added fallback-backed methods and regression tests |

### Open

| Area | Finding | Risk | Next action |
|---|---|---|---|
| `demo_hud.gd` | Depends on nonexistent `FloodedShelterController` | Runtime/type-resolution failure if instantiated | Audit scene references, then adapt or remove |
| `demo_end.gd` | Depends on nonexistent `FloodedShelterController` | Runtime/type-resolution failure if instantiated | Audit scene references, then adapt or remove |
| `prompt_hud.gd` | Spanish strings and fixed fonts | Localization and accessibility failure | Localize and apply font scale |
| `narrative_panel.gd` | Fixed font size; consumes `interact` | UI-scale and input-conflict risk | Apply font scale and define input priority |
| Shelter scene | Built entirely in code | Hard to review, edit and QA visually | Gradually migrate stable modules to `.tscn` |
| Accessibility | Colorblind, subtitles, reduced motion and input profiles are persisted but not implemented | Specification not met | Implement and validate each option |

## Input conflict

`narrative_panel.gd` dismisses itself with `interact`. `flooded_shelter.gd` uses `interact` for stations. This creates a potential conflict when a narrative message is visible near an interactable.

Required behavior:

1. While a narrative panel is visible, `interact` dismisses it.
2. The shelter ignores station interaction for 0.35 seconds after dismissal.
3. The interaction prompt remains visible but disabled during that grace period.
4. The behavior must be covered by a headless test.

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
