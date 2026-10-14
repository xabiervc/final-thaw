# FINAL THAW — Localization Consistency Audit

## Audit date

2026-10-14

## Scope

- `scripts/managers/narrative_text_manager.gd`
- `scripts/data/narrative_text.gd`
- `data/narrative_text.tres`
- `data/narrative_text_es.tres`
- `data/narrative_text_en.tres`
- UI and shelter scripts that consume localized text

## Critical findings

### LC-001 — Spanish resource was missing

- **Status:** Resolved in commit `5238108`.
- **Problem:** `NarrativeTextManager.set_locale("es")` attempted to load `res://data/narrative_text_es.tres`, but the file did not exist.
- **Consequence:** Spanish fell back to the empty `narrative_text.tres`, causing English fallback strings to appear in the Spanish UI.
- **Resolution:** Added a complete Spanish resource for the current vertical slice.

### LC-002 — Demo status keys were missing from the resource schema

- **Status:** Resolved in commit `b614a4b`.
- **Problem:** `hud_demo_completed` and `hud_demo_failed` were written into the ES/EN resources but were not declared as exported properties in `NarrativeText`.
- **Risk:** Godot could emit resource-loading errors or silently fail to persist/read the values.
- **Resolution:** Added both properties to `scripts/data/narrative_text.gd`.

### LC-003 — Base Spanish resource remains empty

- **Status:** Accepted with condition.
- **Problem:** `data/narrative_text.tres` contains only the script reference and no text properties.
- **Current behavior:** It is used as a fallback when a locale resource is missing.
- **Risk:** Any missing locale resource will produce English fallbacks rather than Spanish content.
- **Required rule:** `narrative_text.tres` must either contain the complete Spanish baseline or be removed as a fallback once ES/EN resources are guaranteed to exist.
- **Owner:** Localization owner.
- **Priority:** P2.

## Key parity

| Key family | Manager usage | Schema | ES resource | EN resource |
|---|---|---|---|---|
| `menu_title` | Yes | Yes | Yes | Yes |
| `menu_context` | Yes | Yes | Yes | Yes |
| `menu_start_button` | Yes | Yes | Yes | Yes |
| `hud_oxygen_label` | Yes | Yes | Yes | Yes |
| `hud_civilian_*` | Yes | Yes | Yes | Yes |
| `hud_objective_*` | Yes | Yes | Yes | Yes |
| `hud_demo_completed` | Yes | Yes | Yes | Yes |
| `hud_demo_failed` | Yes | Yes | Yes | Yes |
| `interact_power_console_*` | Yes | Yes | Yes | Yes |
| `interact_valve_*` | Yes | Yes | Yes | Yes |
| `interact_civilian_*` | Yes | Yes | Yes | Yes |
| `civilian_rescue_lines` | Yes | Yes | Yes | Yes |
| `end_title_*` | Yes | Yes | Yes | Yes |
| `end_elena_*` | Yes | Yes | Yes | Yes |
| `end_civilian_*` | Yes | Yes | Yes | Yes |
| `end_power_restored` | Yes | Yes | Yes | Yes |
| `end_valves_opened` | Yes | Yes | Yes | Yes |
| `end_button_*` | Yes | Yes | Yes | Yes |
| `options_*` | Yes | No | No | No |
| `credits_title` | Yes | No | No | No |
| `prompt_*` | Yes | No | No | No |
| `shelter_*` | Yes | No | No | No |
| `sound_cue_*` | Yes | No | No | No |
| `cr_*` | Yes | Yes | No | Yes |

## Important distinction

A key can be absent from a `.tres` resource without causing a load error when `NarrativeText` does not declare it as an exported property. In that case, `NarrativeTextManager._text()` returns its fallback.

However, a key written into a `.tres` resource must exist as an exported property in `NarrativeText`. Otherwise, Godot may report an invalid property during resource loading.

## Remaining risks

1. `options_*`, `credits_title`, `prompt_*`, `shelter_*` and `sound_cue_*` are used by the manager but are not declared in `NarrativeText`.
2. Those keys are also absent from both ES and EN resources, so they currently rely entirely on code fallbacks.
3. The Spanish resource does not include control-room keys; the English resource does.
4. The fallback resource is empty.

## Required follow-up

1. Add all manager-used keys to `NarrativeText` as exported properties.
2. Add those keys to both ES and EN resources.
3. Add control-room keys to the Spanish resource.
4. Decide whether `narrative_text.tres` should be a full Spanish baseline or removed from the fallback path.
5. Add a headless test that loads both locale resources and asserts that every manager-used key is non-empty.

## Verification status

No localization work is considered verified until Godot loads both resources without errors and the ES/EN switch is manually tested in the canonical shelter scene.
