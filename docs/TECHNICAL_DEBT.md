# FINAL THAW — Technical Debt Register

## Purpose

Track implementation debt that blocks the project from meeting its quality target. An item remains open until it is either fixed with evidence or explicitly descoped with a documented reason.

## Architecture decision

`scenes/levels/flooded_shelter_2_5d.tscn` is now the canonical Flooded Shelter implementation. See `docs/ARCHITECTURE_DECISIONS.md`.

The dynamically built `flooded_shelter.tscn` remains a systems/accessibility laboratory, but new production features should target the canonical 2.5D scene.

## Critical debt

### TD-001 — Canonical Flooded Shelter needs parity with prototype improvements

- **Canonical scene:** `scenes/levels/flooded_shelter_2_5d.tscn`
- **Laboratory scene:** `scenes/levels/flooded_shelter.tscn`
- **Problem:** The canonical scene has a stronger node/controller architecture, but lacks accessibility, localization, sound cues and the narrative interaction grace period developed in the laboratory scene.
- **Required work:**
  - Call `restore_from_persistence()` on controller readiness.
  - Emit initial civilian and oxygen state.
  - Localize civilian, HUD and end-screen text.
  - Integrate `AccessibilityManager` into `DemoHUD`, `DemoEnd` and Elena.
  - Add the narrative dismissal grace period.
  - Integrate `SoundCueHUD`.
  - Define a shared interaction contract.
- **Owner:** Perplexity + Claude/local Godot validation.
- **Priority:** P0.

### TD-002 — Prompt HUD localization and scaling

- **Status:** Resolved in commit `ed68a5d`.

### TD-003 — Narrative panel scaling

- **Status:** Partially resolved in commit `e5f739a`.
- **Remaining work:** Add dedicated localization keys and tests for panel chrome/messages.

### TD-004 — `interact` conflict

- **Status:** Resolved in the laboratory implementation, commit `e5f739a`.
- **Remaining work:** Port the grace-period rule to the canonical 2.5D implementation.

### TD-005 — Three player paths remain unintegrated

- **Files:** `scripts/entities/player.gd`, `scripts/entities/elena.gd`, `scripts/characters/elena_controller.gd`
- **Problem:** The project has a 2D prototype player, a 2.5D canonical Elena and a 3D test-room Elena. Their movement, condition and interaction models differ.
- **Risk:** Duplicated maintenance, inconsistent accessibility and divergent gameplay feel.
- **Action required:** Define the production character-controller contract, then consolidate movement, condition and interaction behavior.
- **Owner:** Design/technical decision.
- **Priority:** P0.

### TD-006 — Character condition lacks resource validation

- **File:** `scripts/components/character_condition.gd`
- **Problem:** `spend()` reduces stamina without a `can_spend()` check. There are no signals for state changes.
- **Risk:** UI, audio and gameplay systems cannot react cleanly; the player controller may spend resources without sufficient validation.
- **Action required:** Add `can_spend()`, state-change signals and tests for stamina thresholds.
- **Owner:** Perplexity.
- **Priority:** P2.

### TD-007 — Accessibility options are incomplete

- **Status:** Major progress.
- **Implemented:** Text scale, high contrast, reduced motion for prompt/cues, subtitle background in narrative panel, colorblind-safe shelter palettes, core action remapping and visual sound cues.
- **Remaining work:** Apply accessibility preferences consistently to the canonical 2.5D implementation; add full input remapping, gamepad remapping, broader colorblind support, subtitle rendering and directional audio indicators.
- **Priority:** P1.

### TD-008 — No automated visual or performance validation

- **Problem:** There are headless logic tests, but no automated checks for resolution, UI overlap, frame time, memory or scene-load duration.
- **Risk:** Performance and presentation regressions can reach a milestone unnoticed.
- **Action required:** Add Godot headless smoke tests and a manual profiling checklist for each playable slice.
- **Owner:** Claude/local validation.
- **Priority:** P1.

### TD-011 — Elena 2.5D interaction connections are unverified

- **Files:** `scripts/entities/elena.gd`, `scenes/levels/flooded_shelter_2_5d.tscn`
- **Problem:** `elena.gd` defines `_on_interaction_area_body_entered()` and `_on_interaction_area_body_exited()`, but the audited scene file does not show connections for those signals.
- **Risk:** `interactable_nearby` may remain null, making `try_interact()` always fail.
- **Action required:** Inspect the full scene/import state and add explicit signal connections or connect them in `_ready()`.
- **Owner:** Perplexity + local Godot validation.
- **Priority:** P0.

### TD-012 — Oxygen design differs between implementations

- **Files:** `scripts/entities/elena.gd`, `scripts/vertical_slice/shelter_rules.gd`
- **Problem:** Implementation A drains oxygen only after valves open. Implementation B drains continuously from scene start.
- **Risk:** Inconsistent difficulty, tutorial pacing and player fairness.
- **Action required:** Choose one canonical survival rule and apply it across the game.
- **Owner:** Design decision.
- **Priority:** P1.

## Resolution rule

A debt item is closed only when:

1. The code change is merged.
2. A test or documented manual check covers it.
3. Godot runs without new errors or warnings.
4. `PROJECT_STATUS.md` records the evidence.

## Current priority order

1. TD-011: verify and repair Elena interaction connections.
2. TD-001: bring the canonical 2.5D scene to parity.
3. TD-012: choose the canonical oxygen rule.
4. TD-005: define and consolidate the production player-controller contract.
5. TD-007: port accessibility to the canonical implementation.
6. TD-004: apply narrative grace period to the canonical implementation.
7. TD-006 and TD-008: harden condition systems and validation.
