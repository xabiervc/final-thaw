# FINAL THAW — Technical Debt Register

## Purpose

Track implementation debt that blocks the project from meeting its quality target. An item remains open until it is either fixed with evidence or explicitly descoped with a documented reason.

## Critical debt

### TD-001 — Legacy shelter UI depends on a missing class

- **Files:** `scripts/ui/demo_hud.gd`, `scripts/ui/demo_end.gd`
- **Problem:** Both scripts declare `var shelter: FloodedShelterController`, but no `FloodedShelterController` class exists in the repository.
- **Current controller:** `scripts/vertical_slice/flooded_shelter.gd` is a `Node2D` without `class_name` and exposes different signals.
- **Risk:** If any scene instantiates these scripts, Godot may fail to resolve the type or the HUD will not receive events.
- **Audit status:** No references were found in `scenes/levels`, `scenes/props` or global GitHub code search. Search results were marked incomplete, so deletion is not yet justified.
- **Additional audit needed:** Inspect `flooded_shelter_2_5d.tscn`, `abandoned_lab*.tscn`, `test_room.tscn`, `art_tests/` and `proto/` locally for indirect references.
- **Action required:** Either adapt both scripts to `shelter_rules.gd` / `flooded_shelter.gd`, or remove them in a separate commit after local verification.
- **Owner:** Claude/local audit + human review.
- **Priority:** P0.

### TD-002 — Prompt HUD localization and scaling

- **Status:** Resolved in commit `ed68a5d`.
- **Resolution:** Instructions and condition text now use `NarrativeTextManager`; fonts respond to `GameManager.font_scale` and `stats_changed`.

### TD-003 — Narrative panel scaling

- **Status:** Partially resolved in commit `e5f739a`.
- **Resolution:** Font scale now responds to `GameManager.font_scale` and `stats_changed`.
- **Remaining work:** Add dedicated localization keys and tests for panel chrome/messages.

### TD-004 — `interact` conflict

- **Status:** Resolved in commit `e5f739a`.
- **Resolution:** `narrative_panel.gd` emits `narrative_dismissed`; `flooded_shelter.gd` applies a 0.35-second interaction grace period.

### TD-005 — Two player controllers remain unintegrated

- **Files:** `scripts/entities/player.gd`, `scripts/characters/elena_controller.gd`
- **Problem:** The 2D vertical slice uses `entities/player.gd`; the 3D test room uses `characters/elena_controller.gd`. They have different movement, condition and interaction models.
- **Risk:** Duplicated maintenance, inconsistent accessibility and divergent gameplay feel.
- **Action required:** Decide whether to unify around a shared movement/condition component or explicitly maintain two prototype controllers until the 3D pipeline is validated.
- **Owner:** Design/technical decision.
- **Priority:** P1.

### TD-006 — Character condition lacks resource validation

- **File:** `scripts/components/character_condition.gd`
- **Problem:** `spend()` reduces stamina without a `can_spend()` check. There are no signals for state changes.
- **Risk:** UI, audio and gameplay systems cannot react cleanly; the player controller may spend resources without sufficient validation.
- **Action required:** Add `can_spend()`, state-change signals and tests for stamina thresholds.
- **Owner:** Perplexity.
- **Priority:** P2.

### TD-007 — Accessibility options are incomplete

- **Files:** `scripts/ui/options_menu.gd`, `scripts/managers/game_manager.gd`
- **Problem:** Only text scale is implemented. `colorblind_mode`, `subtitle_size` and `input_profile` are persisted but not visibly wired to UI or gameplay.
- **Risk:** The accessibility specification is not met.
- **Action required:** Implement high contrast, colorblind-safe palettes, subtitle size/background options, reduced motion and input remapping.
- **Owner:** Perplexity + Claude/Godot validation.
- **Priority:** P1.

### TD-008 — No automated visual or performance validation

- **Problem:** There are headless logic tests, but no automated checks for resolution, UI overlap, frame time, memory or scene-load duration.
- **Risk:** Performance and presentation regressions can reach a milestone unnoticed.
- **Action required:** Add Godot headless smoke tests and a manual profiling checklist for each playable slice.
- **Owner:** Claude/local validation.
- **Priority:** P1.

### TD-009 — Duplicate or divergent Flooded Shelter scenes

- **Files:** `scenes/levels/flooded_shelter.tscn`, `scenes/levels/flooded_shelter_2_5d.tscn`
- **Problem:** Two similarly named shelter scenes exist. Their relationship, intended use and differences are not documented.
- **Risk:** Developers may edit the wrong scene; tests may validate one while the playable route uses another.
- **Action required:** Audit both scenes and scripts, document the canonical scene, and remove or clearly mark the obsolete variant.
- **Owner:** Perplexity + local Godot validation.
- **Priority:** P1.

## Resolution rule

A debt item is closed only when:

1. The code change is merged.
2. A test or documented manual check covers it.
3. Godot runs without new errors or warnings.
4. `PROJECT_STATUS.md` records the evidence.

## Current priority order

1. TD-001: complete local audit and resolve legacy shelter UI.
2. TD-009: identify the canonical Flooded Shelter scene.
3. TD-007: implement the accessibility options already persisted.
4. TD-005: decide the player-controller architecture.
5. TD-006 and TD-008: harden condition systems and validation.
