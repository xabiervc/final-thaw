# FINAL THAW — Systems Specification

## Purpose

This document specifies ALL survival systems with explicit inputs, outputs, limits, and priorities. This is NOT a high-level overview—this is a technical specification for implementation.

---

## System 1: Temperature

### Purpose

Temperature affects player movement speed, hazard resistance, and narrative state (extreme cold = climate collapse progression).

### Inputs

| Input | Type | Source | Default |
|-------|------|--------|---------|
| `ambient_temperature` | float | Level data (varies by zone) | -10°C to 40°C |
| `player_clothing_insulation` | float | Equipment (Elena: lab coat = 0.3, Marcus: jacket = 0.6) | 0.3 |
| `player_activity_level` | float | Player action (idle = 0.5, walking = 1.0, sprinting = 1.5) | 1.0 |
| `shelter_bonus` | float | Indoor zone (1.2x) or outdoor (1.0x) | 1.0 |

### Outputs

| Output | Type | Effect |
|--------|------|--------|
| `effective_temperature` | float | `ambient_temperature × shelter_bonus × (1.0 - player_clothing_insulation) / player_activity_level` |
| `cold_debuff` | bool | `effective_temperature < 0°C` → Movement speed -10% |
| `heat_debuff` | bool | `effective_temperature > 35°C` → Stamina regen -20% |
| `narrative_state` | string | `effective_temperature < -20°C` → "Extreme Cold" (climate collapse visible) |

### Limits

| Limit | Value | Enforcement |
|-------|-------|-------------|
| **Minimum effective temperature** | -50°C | Clamped (never colder than -50°C) |
| **Maximum effective temperature** | 50°C | Clamped (never hotter than 50°C) |
| **Cold debuff threshold** | 0°C | Below = debuff active |
| **Heat debuff threshold** | 35°C | Above = debuff active |

### Priority

**Priority**: Medium (affects movement/stamina, not life-or-death)

**Overrides**: None (temperature never kills player directly)

**Overridden by**: `health` system (health = 0 → death, regardless of temperature)

---

## System 2: Resources

### Purpose

Resources (food, water, materials) are NOT primary survival mechanics in Final Thaw. The game focuses on **time pressure and hazard navigation**, not resource gathering. Resources are narrative props, not core systems.

### Inputs

| Input | Type | Source | Default |
|-------|------|--------|---------|
| `resource_nodes` | array | Level data (scattered crates, terminals, vending machines) | 3-5 per level |
| `player_inventory_space` | int | Character (Elena = 5 slots, Marcus = 8 slots) | 5 |
| `resource_type` | string | Resource node (health_pack, battery, calibration_module) | Varies |

### Outputs

| Output | Type | Effect |
|--------|------|--------|
| `inventory` | array | Player's collected resources (max = `player_inventory_space`) |
| `resource_used` | bool | Player used resource (health_pack → +25 health, battery → powers terminal) |
| `narrative_flavor` | string | Resource descriptions (e.g., "Ration pack, expired 2047") |

### Limits

| Limit | Value | Enforcement |
|-------|-------|-------------|
| **Max inventory slots** | 8 (Marcus), 5 (Elena) | Cannot pick up more than capacity |
| **Resource stack size** | 1 per slot | No stacking (simplifies UI) |
| **Health pack heal** | +25 health | Clamped to `max_health` (100) |
| **Battery duration** | 60 seconds | Powers terminal for 60s, then depleted |

### Priority

**Priority**: Low (resources are convenience, not survival-critical)

**Overrides**: None

**Overridden by**: `health` system (health = 0 → death, even with resources in inventory)

---

## System 3: Shelter

### Purpose

Shelter (indoor zones, safe rooms, checkpoints) provides safety from hazards and narrative breathing room.

### Inputs

| Input | Type | Source | Default |
|-------|------|--------|---------|
| `zone_type` | string | Level data (indoor = 1.2x safety, outdoor = 1.0x) | "outdoor" |
| `hazard_active` | bool | Hazard system (steam vent, electrical arc, etc.) | false |
| `checkpoint_reached` | bool | Checkpoint trigger (true when player touches checkpoint) | false |

### Outputs

| Output | Type | Effect |
|--------|------|--------|
| `safety_multiplier` | float | `indoor = 1.2x`, `outdoor = 1.0x` (affects hazard damage) |
| `hazard_immunity` | bool | `checkpoint_reached = true` → Immune to hazards for 5 seconds (checkpoint grace period) |
| `narrative_state` | string | `zone_type = indoor` → "Shelter" (NPCs appear, dialogue triggers) |

### Limits

| Limit | Value | Enforcement |
|-------|-------|-------------|
| **Checkpoint grace period** | 5 seconds | Immune to hazards for 5s after reaching checkpoint |
| **Indoor safety cap** | 1.2x | Never more than 20% damage reduction indoors |
| **Shelter duration** | Until player exits zone | Shelter bonus ends when player leaves indoor zone |

### Priority

**Priority**: High (shelter = safety, checkpoints = progression)

**Overrides**: `hazards` system (shelter reduces hazard damage by 20%)

**Overridden by**: None (shelter is always beneficial)

---

## System 4: Displacement (Movement)

### Purpose

Displacement (player movement) is the CORE mechanic. All other systems support or constrain movement.

### Inputs

| Input | Type | Source | Default |
|-------|------|--------|---------|
| `input_vector` | Vector2 | Player input (WASD, controller stick) | (0, 0) |
| `movement_speed` | float | Character (Elena = 300 px/s, Marcus = 320 px/s) | 300 |
| `sprint_multiplier` | float | Sprint input (1.0x = walking, 1.4x = sprinting) | 1.0 |
| `cold_debuff` | bool | Temperature system (`effective_temperature < 0°C`) | false |
| `terrain_type` | string | Level data (floor = 1.0x, ice = 0.8x, rubble = 0.7x) | "floor" |

### Outputs

| Output | Type | Effect |
|--------|------|--------|
| `velocity` | Vector2 | `input_vector.normalized() × movement_speed × sprint_multiplier × terrain_multiplier × (0.9 if cold_debuff else 1.0)` |
| `distance_traveled` | float | Accumulated distance (used for speedrun metrics) |
| `time_in_zone` | float | Time spent in current zone (used for pacing metrics) |

### Limits

| Limit | Value | Enforcement |
|-------|-------|-------------|
| **Max sprint speed** | 1.4x walking speed | Clamped (never faster than 1.4x) |
| **Min terrain speed** | 0.7x (rubble/ice) | Never slower than 0.7x |
| **Diagonal normalization** | Yes | Diagonal movement = same speed as cardinal (no faster diagonals) |

### Priority

**Priority**: CRITICAL (movement is the CORE mechanic)

**Overrides**: None (movement is always allowed unless scripted event blocks it)

**Overridden by**: `hazards` system (hazards can block movement paths, but not movement itself)

---

## System 5: Threats (Hazards + Enemies)

### Purpose

Threats (environmental hazards + enemies) provide challenge and time pressure.

### Inputs

| Input | Type | Source | Default |
|-------|------|--------|---------|
| `hazard_type` | string | Level data (steam_vent, electrical_arc, toxic_water, falling_debris) | Varies |
| `hazard_active` | bool | Hazard cycle (telegraph = 1.0s, active = 2.0s, cooldown = 7.0s) | false |
| `enemy_type` | string | Level data (scavenger, enforcer, marksman, boss) | Varies |
| `enemy_health` | int | Enemy stats (scavenger = 50, enforcer = 100, marksman = 75, boss = 300) | Varies |
| `player_in_line_of_sight` | bool | Enemy AI (marksman only, true if LOS to player) | false |

### Outputs

| Output | Type | Effect |
|--------|------|--------|
| `hazard_damage` | int | `steam_vent = 10`, `electrical_arc = 15`, `toxic_water = 5/s`, `falling_debris = 20` |
| `enemy_damage` | int | `scavenger = 10`, `enforcer = 20`, `marksman = 15` (if LOS), `boss = 30` |
| `threat_telegraph` | bool | `true` for 1.0s before hazard/enemy attack (visible shadow, sound ramp-up, red flash) |
| `threat_active` | bool | `true` for 2.0s during hazard/enemy attack (damage window) |

### Limits

| Limit | Value | Enforcement |
|-------|-------|-------------|
| **Hazard telegraph duration** | 1.0s | Always 1.0s warning before damage |
| **Hazard active duration** | 2.0s | Always 2.0s damage window |
| **Hazard cooldown** | 7.0s | Always 7.0s between cycles |
| **Enemy attack windup** | 0.5-1.5s | Varies by enemy (scavenger = 0.5s, enforcer = 1.0s, marksman = 0.8s, boss = 1.5s) |
| **Max simultaneous threats** | 5 | Never more than 5 active threats at once (performance + readability) |

### Priority

**Priority**: HIGH (threats are primary challenge)

**Overrides**: `shelter` system (shelter reduces threat damage by 20%)

**Overridden by**: `health` system (health = 0 → death, regardless of threats remaining)

---

## System 6: Health

### Purpose

Health (Elena and Marcus HP) is the PRIMARY failure condition.

### Inputs

| Input | Type | Source | Default |
|-------|------|--------|---------|
| `damage_source` | string | Threat system (hazard or enemy) | Varies |
| `damage_amount` | int | Threat system (see Threats table above) | Varies |
| `shelter_bonus` | float | Shelter system (indoor = 0.8x damage, outdoor = 1.0x) | 1.0 |
| `health_pack_used` | bool | Resource system (player used health pack) | false |

### Outputs

| Output | Type | Effect |
|--------|------|--------|
| `current_health` | int | `current_health -= damage_amount × shelter_bonus` (clamped to 0-100) |
| `health_pack_heal` | int | `current_health += 25` (clamped to 100) |
| `death_state` | bool | `current_health <= 0` → Death, restart at checkpoint |
| `low_health_warning` | bool | `current_health <= 25` → UI warning (red flash, heartbeat sound) |

### Limits

| Limit | Value | Enforcement |
|-------|-------|-------------|
| **Max health** | 100 | Clamped (never above 100) |
| **Min health** | 0 | `current_health = 0` → Death |
| **Health pack heal** | +25 | Fixed heal amount (no scaling) |
| **Health pack uses** | 3 per level | Limited (cannot farm health packs) |

### Priority

**Priority**: CRITICAL (health = 0 → death, game over)

**Overrides**: All systems (death overrides everything)

**Overridden by**: None (death is final, only checkpoint restart recovers)

---

## System 7: Inventory

### Purpose

Inventory (limited slots for resources) provides strategic choices (what to carry, what to leave).

### Inputs

| Input | Type | Source | Default |
|-------|------|--------|---------|
| `inventory_space` | int | Character (Elena = 5, Marcus = 8) | 5 |
| `resource_pickup` | string | Player action (picks up resource) | null |
| `resource_drop` | string | Player action (drops resource) | null |
| `resource_use` | string | Player action (uses resource) | null |

### Outputs

| Output | Type | Effect |
|--------|------|--------|
| `inventory_slots` | array | Array of resource IDs (max length = `inventory_space`) |
| `inventory_full` | bool | `inventory_slots.length >= inventory_space` → Cannot pick up more |
| `resource_available` | bool | `resource_id in inventory_slots` → Can use resource |

### Limits

| Limit | Value | Enforcement |
|-------|-------|-------------|
| **Max inventory slots** | 8 (Marcus), 5 (Elena) | Cannot exceed character limit |
| **Resource stack size** | 1 per slot | No stacking (simplifies UI) |
| **Resource use cooldown** | 1.0s | Cannot spam health packs (1s between uses) |

### Priority

**Priority**: Low (inventory is convenience, not survival-critical)

**Overrides**: None

**Overridden by**: `health` system (health = 0 → death, even with full inventory)

---

## System 8: Time

### Purpose

Time (level timers, oxygen timers, fire timers) provides urgency and pacing.

### Inputs

| Input | Type | Source | Default |
|-------|------|--------|---------|
| `timer_type` | string | Level data (oxygen = 60s, fire = 120s, platform_cycle = 10s) | Varies |
| `timer_active` | bool | Level trigger (timer starts when player enters zone) | false |
| `timer_elapsed` | float | Delta time (accumulates while `timer_active = true`) | 0.0 |

### Outputs

| Output | Type | Effect |
|--------|------|--------|
| `timer_remaining` | float | `timer_type.duration - timer_elapsed` |
| `timer_expired` | bool | `timer_remaining <= 0` → Timer expired |
| `timer_warning` | bool | `timer_remaining <= 10s` → UI warning (red flash, beeping sound) |
| `narrative_adaptation` | string | `timer_expired = true` → Narrative adapts (e.g., "You escaped, but the fire nearly took you") |

### Limits

| Limit | Value | Enforcement |
|-------|-------|-------------|
| **Oxygen timer** | 60s | Fixed duration (generous, most players finish in 30-40s) |
| **Fire timer** | 120s | Fixed duration (generous, most players finish in 60-90s) |
| **Platform cycle** | 10s | Fixed cycle (learnable, optimizable) |
| **Timer warning threshold** | 10s | Warning starts at 10s remaining |

### Priority

**Priority**: Medium (timers provide urgency, but failure adapts narrative, doesn't kill)

**Overrides**: None (timer expiry never kills player directly)

**Overridden by**: `health` system (health = 0 → death, even if timer still running)

---

## System 9: Consequences (Survival Systems Integration)

### Purpose

Consequences (Elena Safety, Prototype Integrity, Civilian Aid) are the PRIMARY progression systems. They track player choices and determine ending eligibility.

### Inputs

| Input | Type | Source | Default |
|-------|------|--------|---------|
| `elena_safety_event` | string | Enemy reaches Elena, scripted threat hits her | null |
| `prototype_integrity_event` | string | Elena crosses hazard without protection | null |
| `civilian_aid_event` | string | Player rescues civilian | null |

### Outputs

| Output | Type | Effect |
|--------|------|--------|
| `elena_safety` | int | `elena_safety -= 1` per event (clamped to 0-3) |
| `prototype_integrity` | int | `prototype_integrity -= 1` per event (clamped to 0-3) |
| `civilian_aid` | int | `civilian_aid += 1` per rescue (clamped to 0-10) |
| `ending_eligibility` | string | `elena_safety <= 1 OR prototype_integrity <= 1` → Fragile Thaw; `civilian_aid >= 4 AND evidence_choice = "preserve"` → Public Thaw; else → Guarded Thaw |

### Limits

| Limit | Value | Enforcement |
|-------|-------|-------------|
| **Elena Safety range** | 0-3 | Clamped (never below 0 or above 3) |
| **Prototype Integrity range** | 0-3 | Clamped (never below 0 or above 3) |
| **Civilian Aid range** | 0-10 | Clamped (never below 0 or above 10) |
| **Event frequency** | Once per event | Cannot farm consequences (each event triggers once) |

### Priority

**Priority**: CRITICAL (consequences determine ending eligibility)

**Overrides**: All systems (ending eligibility overrides everything)

**Overridden by**: None (consequences are permanent, only reload can change them)

---

## System Interaction Rules

### Priority Hierarchy (Highest to Lowest)

1. **Health** (health = 0 → death, overrides everything)
2. **Consequences** (ending eligibility, permanent)
3. **Threats** (damage sources, time pressure)
4. **Displacement** (core mechanic, constrained by threats)
5. **Shelter** (reduces threat damage by 20%)
6. **Time** (urgency, narrative adaptation on expiry)
7. **Temperature** (movement/stamina debuffs)
8. **Inventory** (convenience, not survival-critical)
9. **Resources** (convenience, not survival-critical)

### Interaction Matrix

| System A | System B | Interaction |
|----------|----------|-------------|
| **Health** | Threats | Threats deal damage to health |
| **Health** | Shelter | Shelter reduces threat damage by 20% |
| **Health** | Resources | Health pack heals +25 health |
| **Threats** | Shelter | Shelter reduces threat damage by 20% |
| **Threats** | Time | Timer expiry may trigger threats (e.g., fire spreads) |
| **Displacement** | Threats | Threats can block movement paths (but not movement itself) |
| **Displacement** | Temperature | Cold debuff reduces movement speed by 10% |
| **Shelter** | Time | Shelter zones often have timers (oxygen, fire) |
| **Inventory** | Resources | Inventory holds resources |
| **Consequences** | All | Consequences track player choices across all systems |

---

## Sign-Off

**Lead Designer**: [ ] All systems specified with inputs, outputs, limits, priorities
**Lead Programmer**: [ ] All systems implementable, no ambiguity
**Lead Writer**: [ ] All narrative adaptations specified (timer expiry, shelter states)
**Accessibility Lead**: [ ] All systems accessible (remappable, scalable, colorblind-safe)
**QA Lead**: [ ] All systems testable, acceptance criteria clear
**Producer**: [ ] All systems within scope, no feature creep

**Date**: September 30, 2026

**Status**: ✅ SYSTEMS SPEC COMPLETE. ALL 9 SYSTEMS SPECIFIED WITH INPUTS, OUTPUTS, LIMITS, PRIORITIES, INTERACTIONS.
