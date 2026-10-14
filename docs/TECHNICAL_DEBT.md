# FINAL THAW — Technical Debt Register

## Purpose

Track implementation debt that blocks the project from meeting its quality target. An item remains open until it is either fixed with evidence or explicitly descoped with a documented reason.

## Critical debt

### TD-001 — Two parallel Flooded Shelter implementations

- **Status:** Corrected audit. The original assumption that `DemoHUD` and `DemoEnd` were unused legacy code was wrong.
- **Active implementation A:** `scenes/levels/flooded_shelter.tscn`
  - Script: `scripts/vertical_slice/flooded_shelter.gd`
  - Player: `scripts/entities/player.gd`
  - Rules: `scripts/vertical_slice/shelter_rules.gd`
  - Builds its scene and UI dynamically.
- **Active implementation B:** `scenes/levels/flooded_shelter_2_5d.tscn`
  - Controller: `scripts/levels/flooded_shelter_controller.gd`
  - Player: `scripts/entities/elena.gd`
  - Civilian: `scripts/entities/civilian.gd`
  - Props: `power_console.gd`, `valve_station.gd`, `flood_gate.gd`, `shelter_light.gd`
  - UI: `demo_hud.gd` and `demo_end.gd`
  - Uses real scene connections and a node-based layout.
- **Problem:** Both implement the same narrative beat with different controllers, player scripts, interaction models, UI contracts and state ownership.
- **Risk:** Duplicate maintenance, divergent accessibility, inconsistent save/consequence behavior and uncertain canonical scene.
- **Action required:** Audit implementation B, compare both loops, choose the production base, then migrate the missing improvements from A or B.
- **Owner:** Perplexity + local Godot validation.
- **Priority:** P0.

### TD-002 — Prompt HUD localization and scaling

- **Status:** Resolved in commit `ed68a5d`.

### TD-003 — Narrative panel scaling

- **Status:** Partially resolved in commit `e5f739a`.
- **Remaining work:** Add dedicated localization keys and tests for panel chrome/messages.

### TD-004 — `interact` conflict

- **Status:** Resolved in implementation A, commit `e5f739a`.
- **Remaining work:** Apply the same grace-period rule to implementation B.

### TD-005 — Two player controllers remain unintegrated

- **Files:** `scripts/entities/player.gd`, `scripts/entities/elena.gd`, `scripts/characters/elena_controller.gd`
- **Problem:** There are now three player-related movement/interaction paths: 2D prototype player, 2.5D Elena and 3D test-room Elena.
- **Risk:** Duplicated maintenance, inconsistent accessibility and divergent gameplay feel.
- **Action required:** Audit all three, define the production character controller contract, then consolidate.
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
- **Remaining work:** Apply accessibility preferences consistently to implementation B; add full input remapping, gamepad remapping, colorblind modes beyond shelter palette, subtitle rendering and directional audio indicators.
- **Priority:** P1.

### TD-008 — No automated visual or performance validation

- **Problem:** There are headless logic tests, but no automated checks for resolution, UI overlap, frame time, memory or scene-load duration.
- **Risk:** Performance and presentation regressions can reach a milestone unnoticed.
- **Action required:** Add Godot headless smoke tests and a manual profiling checklist for each playable slice.
- **Owner:** Claude/local validation.
- **Priority:** P1.

### TD-009 — Duplicate or divergent Flooded Shelter scenes

- **Status:** Merged into TD-001.

### TD-010 — Accessibility improvements are not present in implementation B

- **Files:** `scripts/ui/demo_hud.gd`, `scripts/ui/demo_end.gd`, `scripts/levels/flooded_shelter_controller.gd`
- **Problem:** Implementation B uses the older HUD/end UI and does not yet use `AccessibilityManager`, visual sound cues or the narrative grace period.
- **Risk:** Accessibility behavior will differ depending on which shelter scene the player enters.
- **Action required:** After choosing the canonical implementation, port accessibility, localization and input contracts to it.
- **Owner:** Perplexity + Claude/local validation.
- **Priority:** P0.

## Resolution rule

A debt item is closed only when:

1. The code change is merged.
2. A test or documented manual check covers it.
3. Godot runs without new errors or warnings.
4. `PROJECT_STATUS.md` records the evidence.

## Current priority order

1. TD-001/TD-010: audit implementation B and choose the canonical Flooded Shelter.
2. TD-005: define and consolidate the production player-controller contract.
3. TD-007: port accessibility to the canonical implementation.
4. TD-004: apply narrative grace period to the canonical implementation.
5. TD-006 and TD-008: harden condition systems and validation.
