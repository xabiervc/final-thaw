# FINAL THAW — Systems Specification

## Purpose

This document specifies ALL survival and gameplay systems with **explicit inputs, outputs, limits, and priorities**. This is not a list—it is a functional specification that enables implementation without structural decisions on the fly.

---

## System 1: Temperature (Environmental Hazard)

### Purpose

Temperature represents environmental threat level. Extreme cold/heat damages Elena over time if not mitigated.

### Inputs

| Input | Source | Type | Range | Default |
|-------|--------|------|-------|--------|
| `ambient_temperature` | Level design (zone-based) | float | -40°C to +50°C | 20°C (safe) |
| `exposure_time` | Timer | float | 0-300 seconds | 0 |
| `protection_level` | Equipment (coat, shelter, vehicle) | int | 0-3 (none, light, medium, heavy) | 0 |
| `activity_level` | Player action (idle, walking, running) | enum | idle, low, medium, high | low |

### Outputs

| Output | Target | Type | Effect |
|--------|--------|------|--------|
| `body_temperature` | Health system | float | 35°C-39°C (safe), <35°C (hypothermia), >39°C (hyperthermia) |
| `cold_damage` | Health system | float | 0-5 damage per second (extreme cold, no protection) |
| `heat_damage` | Health system | float | 0-5 damage per second (extreme heat, no protection) |
| `visual_frost` | VFX system | bool | True when body_temp <36°C |
| `visual_sweat` | VFX system | bool | True when body_temp >38°C |

### Limits

| Limit | Value | Rationale |
|-------|-------|-----------|
| **Safe temperature range** | 10°C to 30°C | No damage, comfortable |
| **Cold danger threshold** | <10°C | Body temp starts dropping after 60s exposure |
| **Heat danger threshold** | >30°C | Body temp starts rising after 60s exposure |
| **Extreme cold** | <-20°C | Body temp drops immediately, 2 damage/s |
| **Extreme heat** | >40°C | Body temp rises immediately, 2 damage/s |
| **Max exposure time** | 300s (5 min) | After 5 min in extreme temp, protection degrades |

### Priorities

1. **Player survival** > environmental realism (gameplay first)
2. **Visual feedback** > numerical precision (player should SEE danger before numbers kill them)
3. **Protection matters** (coat, shelter, vehicle should noticeably reduce damage)

### Interaction Rules

| System | Interaction |
|--------|-------------|
| **Health** | Cold/heat damage reduces health. At 0 health → checkpoint restart. |
| **Shelter** | Entering shelter resets exposure_time to 0, body_temp returns to 37°C over 10s. |
| **Equipment** | Coat adds +1 protection_level (reduces damage by 33% per level). |
| **Vehicle** | Vehicle = heavy protection (protection_level 3, 100% damage reduction while inside). |

---

## System 2: Resources (Scarcity & Management)

### Purpose

Resources represent consumables player must manage. Scarcity creates tension and meaningful choices.

### Inputs

| Input | Source | Type | Range | Default |
|-------|--------|------|-------|--------|
| `health_packs` | Level pickups, civilian rescues | int | 0-10 | 0 |
| `aster_charges` | Phase 9+ (calibration minigame) | int | 0-3 per level | 3 |
| `food_rations` | Level pickups, rescues | int | 0-5 | 0 |
| `fuel` | Vehicle sections only | float | 0-100 liters | 100 |

### Outputs

| Output | Target | Type | Effect |
|--------|--------|------|--------|
| `heal_amount` | Health system | int | +25 health per health_pack |
| `calibration_bypass` | Hazard system | bool | 1 charge bypasses 1 hazard without integrity loss |
| `hunger_mitigation` | Health system | bool | 1 ration prevents hunger damage for 5 min |
| `vehicle_range` | Vehicle system | float | 1 liter = 2 km travel |

### Limits

| Limit | Value | Rationale |
|-------|-------|-----------|
| **Max health packs** | 10 | Prevents hoarding, encourages use |
| **Max food rations** | 5 | Scarcity creates meaningful choices |
| **Aster charges per level** | 3 | Limited resource, must allocate wisely |
| **Fuel tank capacity** | 100 liters | Vehicle sections are time-limited |

### Priorities

1. **Scarcity > abundance** (resources should feel valuable, not common)
2. **Player agency** (player chooses when to use, not auto-consumed)
3. **Visual clarity** (player always knows how many they have)

### Interaction Rules

| System | Interaction |
|--------|-------------|
| **Health** | Health pack: +25 health (capped at 100). Cannot use while in combat. |
| **Hazard** | Aster charge: bypasses 1 hazard without integrity loss. |
| **Hunger** | Food ration: prevents hunger damage for 5 min. Hunger = -1 health/min after 10 min without food. |
| **Vehicle** | Fuel: 1 liter per 2 km. At 0 liters, vehicle stops (fail state). |

---

## System 3: Shelter (Safe Zones & Recovery)

### Purpose

Shelter represents safe zones where player can recover, save, and plan. Creates rhythm between danger and safety.

### Inputs

| Input | Source | Type | Range | Default |
|-------|--------|------|-------|--------|
| `shelter_entered` | Player action (walk into shelter zone) | bool | True/False | False |
| `shelter_type` | Level design | enum | none, makeshift, safehouse, vehicle | none |
| `time_in_shelter` | Timer | float | 0-300 seconds | 0 |
| `enemies_nearby` | AI system | bool | True/False | False |

### Outputs

| Output | Target | Type | Effect |
|--------|--------|------|--------|
| `health_regen` | Health system | float | +1 health per second in shelter |
| `exposure_reset` | Temperature system | bool | exposure_time = 0 |
| `save_enabled` | Save system | bool | Manual save allowed |
| `enemy_aggro_reset` | AI system | bool | Enemies lose aggro if player stays 30s |

### Limits

| Limit | Value | Rationale |
|-------|-------|-----------|
| **Max health regen** | +30 health (30s in shelter) | Prevents full heal, encourages progression |
| **Min shelter time for save** | 10s | Prevents save-scumming mid-combat |
| **Max enemy aggro reset time** | 30s | Player must actively avoid enemies, not just hide |

### Priorities

1. **Safety > convenience** (shelter should feel meaningful, not just a checkpoint)
2. **Risk/reward** (some shelters have enemies nearby—player chooses to clear or avoid)
3. **Pacing** (shelters create rhythm: danger → safety → danger)

### Interaction Rules

| System | Interaction |
|--------|-------------|
| **Health** | +1 health/s in shelter (capped at +30 total). |
| **Temperature** | exposure_time = 0, body_temp returns to 37°C over 10s. |
| **Save** | Manual save enabled after 10s in shelter (prevents mid-combat save). |
| **AI** | Enemies lose aggro if player stays 30s without being seen. |

---

## System 4: Displacement (Movement & Navigation)

### Purpose

Displacement represents player movement through the world. Creates exploration, shortcuts, and pacing.

### Inputs

| Input | Source | Type | Range | Default |
|-------|--------|------|-------|--------|
| `movement_speed` | Player input (walk, run, crouch) | float | 0-320 pixels/s | 200 |
| `terrain_type` | Level design | enum | floor, stairs, ladder, water, hazard | floor |
| `stamina` | Stamina system | float | 0-100 | 100 |
| `encumbrance` | Inventory system | float | 0-1 (0 = light, 1 = overencumbered) | 0 |

### Outputs

| Output | Target | Type | Effect |
|--------|--------|------|--------|
| `position` | Camera, AI, triggers | Vector2 | Player world position |
| `stamina_drain` | Stamina system | float | -5 stamina/s while running |
| `noise_level` | AI detection | float | 0-10 (0 = silent, 10 = loud) |
| `shortcut_unlocked` | Level structure | bool | True when player reaches shortcut lever/door |

### Limits

| Limit | Value | Rationale |
|-------|-------|-----------|
| **Max run speed** | 320 pixels/s | Fast enough to feel agile, not so fast that puzzles break |
| **Max stamina** | 100 | Prevents infinite running |
| **Stamina regen** | +10/s when not running | Encourages pacing (run → walk → run) |
| **Encumbrance cap** | 1.0 (cannot move if overencumbered) | Prevents hoarding exploits |

### Priorities

1. **Player agency** (player chooses when to run, crouch, etc.)
2. **Feedback** (player should SEE stamina drain, HEAR noise level)
3. **Shortcuts matter** (unlocking shortcuts should feel rewarding)

### Interaction Rules

| System | Interaction |
|--------|-------------|
| **Stamina** | Running: -5 stamina/s. At 0 stamina, player forced to walk for 5s. |
| **AI** | Noise level: >5 noise attracts enemies within 500 pixels. |
| **Level** | Shortcut: Player pulls lever/opens door, creates faster route for future deaths. |

---

## System 5: Threats (Enemies & Hazards)

### Purpose

Threats represent challenges player must overcome. Creates tension, combat, and puzzle-solving.

### Inputs

| Input | Source | Type | Range | Default |
|-------|--------|------|-------|--------|
| `enemy_type` | Level design | enum | scavenger, enforcer, marksman, shield, boss | scavenger |
| `enemy_count` | Level design | int | 0-20 | 5 |
| `hazard_type` | Level design | enum | steam, electrical, toxic, falling_debris | steam |
| `hazard_active` | Hazard system | bool | True/False | False |
| `player_visible` | Stealth system | bool | True/False | False |

### Outputs

| Output | Target | Type | Effect |
|--------|--------|------|--------|
| `damage` | Health system | float | 10-50 damage per hit (based on enemy type) |
| `knockback` | Displacement system | float | 100-500 pixels (based on attack) |
| `hazard_damage` | Health system | float | 5-20 damage/s (based on hazard) |
| `integrity_loss` | Prototype system | int | -1 integrity if hazard hit without protection |

### Limits

| Limit | Value | Rationale |
|-------|-------|-----------|
| **Max enemies per arena** | 20 | Performance cap, prevents overwhelming player |
| **Max hazard damage** | 20 damage/s | Lethal in 5s if player stands in hazard (fair but punishing) |
| **Enemy spawn cap** | 5 waves per arena | Prevents infinite waves, gives player hope of clearing |

### Priorities

1. **Telegraphs > surprise** (player should see attacks coming, no cheap hits)
2. **Fairness > difficulty** (player should feel challenged, not cheated)
3. **Variety > repetition** (each enemy type requires different counterplay)

### Interaction Rules

| System | Interaction |
|--------|-------------|
| **Health** | Enemy hit: 10-50 damage (based on type). Hazard: 5-20 damage/s. |
| **Displacement** | Knockback: 100-500 pixels (based on attack). |
| **Prototype** | Hazard hit without protection: -1 integrity. |
| **Stealth** | Player visible = enemies aggro. Player hidden = enemies patrol. |

---

## System 6: Health (Survival State)

### Purpose

Health represents player's survival state. At 0 health, player restarts at checkpoint.

### Inputs

| Input | Source | Type | Range | Default |
|-------|--------|------|-------|--------|
| `damage` | Threats system | float | 0-50 per hit | 0 |
| `healing` | Resources system | int | +25 per health_pack | 0 |
| `regen` | Shelter system | float | +1/s in shelter | 0 |
| `hunger_damage` | Resources system | float | -1/min after 10 min without food | 0 |

### Outputs

| Output | Target | Type | Effect |
|--------|--------|------|--------|
| `current_health` | UI, checkpoint system | int | 0-100 |
| `death_trigger` | Checkpoint system | bool | True when health = 0 |
| `low_health_warning` | UI, audio | bool | True when health <20 |

### Limits

| Limit | Value | Rationale |
|-------|-------|-----------|
| **Max health** | 100 | Standard cap, easy to understand |
| **Min health for death** | 0 | Standard floor, clear fail state |
| **Max regen per shelter visit** | +30 | Prevents full heal, encourages progression |

### Priorities

1. **Clarity** (player always knows their health)
2. **Fairness** (death = checkpoint restart, not game over)
3. **Tension** (low health warning creates urgency)

### Interaction Rules

| System | Interaction |
|--------|-------------|
| **Checkpoint** | At 0 health: restart at last checkpoint (3-5 min back). |
| **Resources** | Health pack: +25 health (capped at 100). |
| **Shelter** | +1 health/s in shelter (capped at +30 total). |
| **Resources** | Hunger: -1 health/min after 10 min without food. |

---

## System 7: Inventory (Item Management)

### Purpose

Inventory represents items player carries. Creates resource management and encumbrance decisions.

### Inputs

| Input | Source | Type | Range | Default |
|-------|--------|------|-------|--------|
| `item_picked_up` | Player action | enum | health_pack, food, aster_charge, key_item | none |
| `item_dropped` | Player action | enum | health_pack, food, aster_charge | none |
| `item_used` | Player action | enum | health_pack, food, aster_charge | none |
| `max_capacity` | Game balance | int | 20 slots | 20 |

### Outputs

| Output | Target | Type | Effect |
|--------|--------|------|--------|
| `current_items` | UI, encumbrance system | int | 0-20 |
| `encumbrance` | Displacement system | float | 0-1 (0 = light, 1 = overencumbered) |
| `item_available` | Player action | bool | True if item in inventory |

### Limits

| Limit | Value | Rationale |
|-------|-------|-----------|
| **Max capacity** | 20 slots | Prevents hoarding, encourages choices |
| **Encumbrance threshold** | 15 slots | At 15+ items, player moves at 50% speed |
| **Overencumbered** | 20 slots | At 20 items, player cannot move |

### Priorities

1. **Player agency** (player chooses what to carry, what to drop)
2. **Clarity** (player always knows what they have)
3. **Consequences** (encumbrance affects movement, creates meaningful choices)

### Interaction Rules

| System | Interaction |
|--------|-------------|
| **Displacement** | Encumbrance: 0-15 items = normal speed, 15-19 items = 50% speed, 20 items = cannot move. |
| **Resources** | Item used: removed from inventory, effect applied. |

---

## System 8: Time (Pacing & Pressure)

### Purpose

Time represents pacing and pressure. Creates urgency without artificial timers.

### Inputs

| Input | Source | Type | Range | Default |
|-------|--------|------|-------|--------|
| `level_time` | Timer | float | 0-1800 seconds (30 min max per level) | 0 |
| `oxygen_timer` | Level design (specific sections) | float | 0-60 seconds | 60 |
| `fire_timer` | Level design (Phase 5) | float | 0-120 seconds | 120 |
| `checkpoint_reached` | Player action | bool | True/False | False |

### Outputs

| Output | Target | Type | Effect |
|--------|--------|------|--------|
| `time_remaining` | UI, checkpoint system | float | 0-1800 seconds |
| `oxygen_remaining` | UI, health system | float | 0-60 seconds |
| `fire_remaining` | UI, vehicle system | float | 0-120 seconds |
| `timer_expired` | Narrative, fail state | bool | True when timer = 0 |

### Limits

| Limit | Value | Rationale |
|-------|-------|-----------|
| **Max level time** | 1800s (30 min) | Prevents endless exploration, encourages progression |
| **Oxygen timer** | 60s | Generous (most players finish in 30-40s) |
| **Fire timer** | 120s | Generous (most players finish in 60-90s) |

### Priorities

1. **Urgency > punishment** (timers create tension, not instant death)
2. **Fairness** (timers are visible, telegraphed, skippable with skill)
3. **Pacing** (timers create rhythm: calm → urgent → calm)

### Interaction Rules

| System | Interaction |
|--------|-------------|
| **Narrative** | Timer expired: narrative adapts (e.g., "You fixed it, but barely"), no game over. |
| **Health** | Oxygen expired: -10 health (representing exhaustion), checkpoint restart if health = 0. |
| **Vehicle** | Fire expired: vehicle has reduced speed in next section (penalty, not fail state). |

---

## System 9: Consequences (Choice Impact)

### Purpose

Consequences represent how player choices affect the world, narrative, and endings.

### Inputs

| Input | Source | Type | Range | Default |
|-------|--------|------|-------|--------|
| `civilian_rescued` | Player action | bool | True/False per civilian | False |
| `evidence_preserved` | Player choice (Phase 12/13) | bool | True/False | False |
| `elena_protected` | Player action | bool | True/False per threat | False |
| `prototype_preserved` | Player action | bool | True/False per hazard | False |

### Outputs

| Output | Target | Type | Effect |
|--------|--------|------|--------|
| `civilian_aid` | Ending system | int | 0-10 (≥4 enables Public Thaw) |
| `evidence_choice` | Ending system | enum | preserve, erase |
| `elena_safety` | Ending system | int | 0-3 (≤1 forces Fragile Thaw) |
| `prototype_integrity` | Ending system | int | 0-3 (≤1 forces Fragile Thaw) |
| `npc_dialogue` | Narrative system | enum | grateful, neutral, bitter |
| `ending_available` | Ending system | enum | Public, Guarded, Fragile |

### Limits

| Limit | Value | Rationale |
|-------|-------|-----------|
| **Max civilian_aid** | 10 | Caps impact of rescues, prevents farming |
| **Evidence choice** | 1 per playthrough | Choice is permanent (can reload, but choice itself is binary) |
| **Ending eligibility** | 1 per playthrough | Player gets one ending per run (can replay for others) |

### Priorities

1. **Meaningful choices** (choices affect endings, not just dialogue)
2. **Clarity** (player understands consequences of choices)
3. **No "correct" answer** (Public/Guarded/Fragile all have valid reasoning)

### Interaction Rules

| System | Interaction |
|--------|-------------|
| **Ending** | Public Thaw: civilian_aid ≥4 AND evidence = preserve AND elena_safety ≥2 AND prototype_integrity ≥2. |
| **Ending** | Guarded Thaw: civilian_aid <4 OR evidence = erase (with elena_safety ≥2 AND prototype_integrity ≥2). |
| **Ending** | Fragile Thaw: elena_safety ≤1 OR prototype_integrity ≤1 (overrides all other conditions). |
| **Narrative** | NPC dialogue: grateful if rescued, bitter if not rescued. |

---

## System Interaction Matrix

| System A | System B | Interaction | Priority |
|----------|----------|-------------|----------|
| **Temperature** | Health | Cold/heat damage reduces health | High |
| **Temperature** | Shelter | Shelter resets exposure, returns body_temp to 37°C | High |
| **Resources** | Health | Health pack: +25 health, food: prevents hunger damage | High |
| **Resources** | Inventory | Items take inventory slots, encumbrance affects movement | Medium |
| **Shelter** | Save | Manual save enabled after 10s in shelter | High |
| **Shelter** | AI | Enemies lose aggro after 30s in shelter without being seen | Medium |
| **Displacement** | AI | Noise level >5 attracts enemies within 500 pixels | Medium |
| **Displacement** | Inventory | Encumbrance (15+ items) reduces movement speed to 50% | Medium |
| **Threats** | Health | Enemy hit: 10-50 damage, hazard: 5-20 damage/s | High |
| **Threats** | Prototype | Hazard hit without protection: -1 integrity | High |
| **Health** | Checkpoint | At 0 health: restart at checkpoint (3-5 min back) | High |
| **Inventory** | Displacement | Encumbrance: 0-15 items = normal, 15-19 = 50% speed, 20 = cannot move | Medium |
| **Time** | Narrative | Timer expired: narrative adapts (no game over) | Medium |
| **Time** | Health | Oxygen expired: -10 health, checkpoint if health = 0 | Medium |
| **Consequences** | Ending | civilian_aid, evidence, elena_safety, prototype_integrity determine ending | High |

---

## Summary: Complete Systems Specification

| System | Inputs | Outputs | Limits | Priorities | Interactions |
|--------|--------|---------|--------|------------|--------------|
| **Temperature** | 4 (ambient, exposure, protection, activity) | 4 (body_temp, cold/heat damage, visual effects) | 6 (safe range, danger thresholds, extremes, max exposure) | 3 (survival, feedback, protection) | 4 (health, shelter, equipment, vehicle) |
| **Resources** | 4 (health_packs, aster_charges, food, fuel) | 4 (heal, bypass, hunger_mitigation, range) | 4 (max packs, max food, charges per level, fuel capacity) | 3 (scarcity, agency, clarity) | 4 (health, hazard, hunger, vehicle) |
| **Shelter** | 4 (entered, type, time, enemies) | 4 (regen, exposure_reset, save_enabled, aggro_reset) | 3 (max regen, min save time, max aggro reset) | 3 (safety, risk/reward, pacing) | 4 (health, temperature, save, AI) |
| **Displacement** | 4 (speed, terrain, stamina, encumbrance) | 4 (position, stamina_drain, noise, shortcut) | 4 (max speed, max stamina, regen, encumbrance cap) | 3 (agency, feedback, shortcuts) | 4 (stamina, AI, level, inventory) |
| **Threats** | 5 (enemy_type, count, hazard_type, active, visible) | 4 (damage, knockback, hazard_damage, integrity_loss) | 3 (max enemies, max hazard damage, spawn cap) | 3 (telegraphs, fairness, variety) | 4 (health, displacement, prototype, stealth) |
| **Health** | 4 (damage, healing, regen, hunger) | 3 (current_health, death_trigger, low_warning) | 3 (max health, min health, max regen) | 3 (clarity, fairness, tension) | 4 (checkpoint, resources, shelter, hunger) |
| **Inventory** | 4 (picked_up, dropped, used, capacity) | 3 (current_items, encumbrance, item_available) | 3 (max capacity, encumbrance threshold, overencumbered) | 3 (agency, clarity, consequences) | 2 (displacement, resources) |
| **Time** | 4 (level_time, oxygen, fire, checkpoint) | 4 (time_remaining, oxygen, fire, expired) | 3 (max level time, oxygen timer, fire timer) | 3 (urgency, fairness, pacing) | 3 (narrative, health, vehicle) |
| **Consequences** | 4 (rescued, evidence, protected, preserved) | 6 (civilian_aid, evidence_choice, elena_safety, prototype_integrity, npc_dialogue, ending_available) | 3 (max aid, 1 choice per run, 1 ending per run) | 3 (meaningful, clear, no "correct") | 2 (ending, narrative) |

**Total**: 9 systems, 37 inputs, 38 outputs, 34 limits, 27 priorities, 38 interactions.

---

## Sign-Off

**Lead Designer**: [ ] All systems specified with inputs, outputs, limits, priorities
**Lead Programmer**: [ ] All interactions defined, no ambiguity
**Lead Writer**: [ ] All narrative consequences reflected in systems
**Accessibility Lead**: [ ] All systems accessible (visual/audio feedback, remappable controls)
**QA Lead**: [ ] All systems testable, acceptance criteria defined
**Producer**: [ ] Systems specification complete, no structural decisions left open

**Date**: September 30, 2026
**Status**: ✅ SYSTEMS SPECIFICATION COMPLETE. ALL 9 SYSTEMS DEFINED WITH INPUTS, OUTPUTS, LIMITS, PRIORITIES, INTERACTIONS.
