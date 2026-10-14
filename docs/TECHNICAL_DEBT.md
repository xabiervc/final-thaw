# FINAL THAW — Technical Debt Register

## Purpose

Track implementation debt that blocks the project from meeting its quality target. An item remains open until it is either fixed with evidence or explicitly descoped with a documented reason.

## Critical debt

### TD-001 — Legacy shelter UI depends on a missing class

- **Files:** `scripts/ui/demo_hud.gd`, `scripts/ui/demo_end.gd`
- **Problem:** Both scripts declare `var shelter: FloodedShelterController`, but no `FloodedShelterController` class exists in the repository.
- **Current controller:** `scripts/vertical_slice/flooded_shelter.gd` is a `Node2D` without `class_name` and exposes different signals.
- **Risk:** If any scene instantiates these scripts, Godot may fail to resolve the type or the HUD will not receive events.
- **Evidence status:** GitHub code search returned no references, but results were marked incomplete. This is not sufficient evidence for deletion.
- **Action required:** Audit every `.tscn` and `.gd` file for `DemoHUD`, `DemoEnd` and `FloodedShelterController`. Then either adapt both scripts to `shelter_rules.gd` / `flooded_shelter.gd`, or remove them in a separate commit.
- **Owner:** Claude/local audit + human review.
- **Priority:** P0.

### TD-002 — Prompt HUD is not localized or scalable

- **File:** `scripts/ui/prompt_hud.gd`
- **Problem:** Instructions and condition text are hardcoded in Spanish. Font sizes are fixed and do not respond to `GameManager.font_scale`.
- **Risk:** Breaks ES/EN localization and the 75–200% UI-scale accessibility requirement.
- **Action required:** Route all user-facing strings through `NarrativeTextManager`; apply font scaling on creation and when `GameManager.stats_changed` fires.
- **Owner:** Perplexity.
- **Priority:** P1.

### TD-003 — Narrative panel is not localized or scalable

- **File:** `scripts/ui/narrative_panel.gd`
- **Problem:** Font size is fixed at 22; no integration with `GameManager.font_scale`.
- **Risk:** Narrative text may become unreadable at minimum or maximum UI scale.
- **Action required:** Apply font scaling when showing the panel and when font scale changes.
- **Owner:** Perplexity.
- **Priority:** P1.

### TD-004 — `interact` is consumed by multiple systems

- **Files:** `scripts/ui/narrative_panel.gd`, `scripts/vertical_slice/flooded_shelter.gd`
- **Problem:** Both use `_unhandled_input` for `interact`. The narrative panel can dismiss itself with the same action used to interact with stations.
- **Risk:** A player may accidentally skip narrative text or trigger an unintended interaction.
- **Action required:** Define input priority: narrative panel should consume `interact` only while visible, and the shelter should ignore interaction for a short grace period after narrative dismissal.
- **Owner:** Perplexity.
- **Priority:** P1.

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

## Resolution rule

A debt item is closed only when:

1. The code change is merged.
2. A test or documented manual check covers it.
3. Godot runs without new errors or warnings.
4. `PROJECT_STATUS.md` records the evidence.

## Current priority order

1. TD-001: audit and resolve legacy shelter UI.
2. TD-004: prevent `interact` conflicts.
3. TD-002 and TD-003: localize and scale remaining UI.
4. TD-007: implement the accessibility options already persisted.
5. TD-005: decide the player-controller architecture.
6. TD-006 and TD-008: harden condition systems and validation.
