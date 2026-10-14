# FINAL THAW — Technical Debt Register

## Purpose

Track implementation debt that blocks the project from meeting its quality target. An item remains open until it is either fixed with evidence or explicitly descoped with a documented reason.

## Architecture decision

`scenes/levels/flooded_shelter_2_5d.tscn` is the canonical Flooded Shelter implementation. See `docs/ARCHITECTURE_DECISIONS.md`.

The dynamically built `flooded_shelter.tscn` remains a systems/accessibility laboratory, but new production features should target the canonical 2.5D scene.

## Critical debt

### TD-001 — Canonical Flooded Shelter needs parity with prototype improvements

- **Canonical scene:** `scenes/levels/flooded_shelter_2_5d.tscn`
- **Laboratory scene:** `scenes/levels/flooded_shelter.tscn`
- **Status:** In progress.
- **Completed:**
  - Controller references are wired in the scene.
  - Controller joins `flooded_shelter` group.
  - Controller restores persistence and emits initial state.
  - Elena detects `Interactable` areas and calls `try_interact()`.
  - Civilian has a rescue interaction.
  - Level geometry, player collision, interaction collision and win-zone collision exist.
  - Death flow is connected safely.
  - Demo HUD connects oxygen and initializes civilian state.
  - Missing HUD localization methods were added.
- **Remaining work:**
  - Localize `PowerConsole` and `ValveStation` interaction text.
  - Restore prop state from persistence.
  - Add visual/audio feedback for generator, valves, gate and rescue.
  - Port `AccessibilityManager` and `SoundCueHUD`.
  - Add narrative dismissal grace period.
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

### TD-011 — Canonical shelter interaction chain

- **Status:** Implemented; pending Godot verification.
- **Completed:**
  - Elena listens to `area_entered` / `area_exited`.
  - Elena stores and calls `Interactable.try_interact()`.
  - `Interactable.interact()` delegates to `try_interact()`.
  - `InteractionArea` has a collision shape.
  - Controller references are wired.
  - Controller joins the expected group.
  - Civilian is interactable.
  - Win zone can locate the controller.
- **Verification required:**
  - Godot loads the scene without errors.
  - Elena interacts with console, valves and civilian.
  - Generator, valves, gate, rescue and exit all work.
  - HUD oxygen and civilian state update.
- **Owner:** Perplexity + Claude/local Godot validation.
- **Priority:** P0.

### TD-012 — Oxygen design differs between implementations

- **Files:** `scripts/entities/elena.gd`, `scripts/vertical_slice/shelter_rules.gd`
- **Problem:** Implementation A drains oxygen only after valves open. Implementation B drains continuously from scene start.
- **Risk:** Inconsistent difficulty, tutorial pacing and player fairness.
- **Action required:** Choose one canonical survival rule and apply it across the game.
- **Owner:** Design decision.
- **Priority:** P1.

### TD-013 — Prop state is not restored from persistence

- **Files:** `scripts/levels/props/power_console.gd`, `scripts/levels/props/valve_station.gd`, `scripts/levels/props/flood_gate.gd`
- **Problem:** The controller restores its own state, but props do not restore `is_on`, `is_open` or visual state from `GameStateManager`.
- **Risk:** A restored save can show an active generator or open valves as inactive.
- **Action required:** Add restoration hooks or have the controller initialize prop state after restoring persistence.
- **Owner:** Perplexity.
- **Priority:** P1.

### TD-014 — Prop interaction text is hardcoded

- **Files:** `scripts/levels/props/power_console.gd`, `scripts/levels/props/valve_station.gd`
- **Problem:** Console and valve prompts use hardcoded Spanish strings.
- **Risk:** English players see Spanish UI; language changes do not update prompts.
- **Action required:** Use `NarrativeTextManager.get_interact_power_console()` and `get_interact_valve()`.
- **Owner:** Perplexity.
- **Priority:** P1.

## Resolution rule

A debt item is closed only when:

1. The code change is merged.
2. A test or documented manual check covers it.
3. Godot runs without new errors or warnings.
4. `PROJECT_STATUS.md` records the evidence.

## Current priority order

1. TD-011: run Godot and verify the repaired interaction chain.
2. TD-014: localize console and valve prompts.
3. TD-013: restore prop state from persistence.
4. TD-001: complete canonical parity.
5. TD-012: choose the canonical oxygen rule.
6. TD-005: define and consolidate the production player-controller contract.
7. TD-007: port accessibility to the canonical implementation.
8. TD-004: apply narrative grace period to the canonical implementation.
9. TD-006 and TD-008: harden condition systems and validation.
