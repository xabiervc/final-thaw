# FINAL THAW — Level Structure Specification

## Purpose

This document specifies the EXACT structure of all levels: zones, shortcuts, decision points, encounters, resources, checkpoints, and rhythm. This is NOT a high-level overview—this is a technical specification for level designers.

---

## Level Template (All Levels Follow This Structure)

### Zone Types

| Zone Type | Purpose | Characteristics |
|-----------|---------|-----------------|
| **Hub** | Central area connecting multiple paths | Wide open space, multiple exits, safe (no hazards/enemies), checkpoint at entrance |
| **Corridor** | Linear traversal between hubs | Narrow path, may have hazards, no enemies (Elena levels) or light enemies (Marcus levels) |
| **Arena** | Combat or puzzle challenge | Enclosed space, hazards/enemies spawn, exit locked until cleared, checkpoint after clear |
| **Safe Room** | Breathing room, narrative | Indoor zone, no hazards/enemies, NPCs may appear, checkpoint, narrative triggers |
| **Boss Arena** | Boss battle | Large enclosed space, boss + adds, exit locked until boss defeated, checkpoint before and after |

---

## Phase-by-Phase Level Structure

### Phase 0-1: Tutorial (Test Rooms)

**Zones**: 2 (Elena test room, Marcus test room)

| Zone | Type | Size | Hazards/Enemies | Checkpoints | Decision Points |
|------|------|------|-----------------|-------------|-----------------|
| **Elena Test Room** | Hub | 40x40 tiles | None | 1 (center) | 0 (pure tutorial) |
| **Marcus Test Room** | Arena | 60x60 tiles | 5 Scavengers (tutorial spawn) | 1 (entrance) | 0 (pure tutorial) |

**Shortcuts**: None (tutorial, linear)

**Resources**: 3 interactables (Elena: terminal, lever, door; Marcus: 5 Scavengers, 3 throwable crates)

**Rhythm**: 5 minutes total (2.5 min Elena, 2.5 min Marcus)

---

### Phase 2: Abandoned Laboratory (4 Puzzle Rooms)

**Zones**: 4 (sequential puzzle rooms)

| Zone | Type | Size | Hazards/Enemies | Checkpoints | Decision Points |
|------|------|------|-----------------|-------------|-----------------|
| **Room 1 (Power)** | Arena | 40x30 tiles | Power routing puzzle (3 nodes) | 1 (exit) | Route power to A (door) or B (platform) — both useful, only one correct for optimal path |
| **Room 2 (Arm)** | Arena | 50x40 tiles | Robotic arm (4 positions) | 1 (exit) | Rotate arm to 0°, 90°, 180°, or 270° — only one angle clears path |
| **Room 3 (Platform)** | Arena | 60x50 tiles | Moving platform (10s cycle) | 1 (exit) | Call platform first or wait for cycle? — calling saves time |
| **Room 4 (Prototype)** | Arena | 80x60 tiles | 3-4 hazard zones (steam, electrical, toxic) | 1 (exit) | Cross hazards (fast, -1 integrity if mistimed) or go around (safe, +30s)? |

**Shortcuts**: None (linear progression, each room unlocks next)

**Resources**: 3 terminals, 1 lever, 1 platform button, 3-4 hazards

**Checkpoints**: 4 (one per room exit)

**Rhythm**: 15-20 minutes total (4-5 min per room)

---

### Phase 4: Highway Riots (4 Combat Arenas)

**Zones**: 4 (sequential combat arenas connected by short corridors)

| Zone | Type | Size | Hazards/Enemies | Checkpoints | Decision Points |
|------|------|------|-----------------|-------------|-----------------|
| **Arena 1** | Arena | 60x60 tiles | 3 Scavengers | 1 (after clear) | Focus fire one enemy or AoE? — focus fire is faster |
| **Arena 2** | Arena | 70x70 tiles | 1 Enforcer + 2 Scavengers | 1 (after clear) | Flank Enforcer (2x damage from back) or frontal assault (slower)? |
| **Arena 3** | Arena | 80x80 tiles | 2 Enforcers + 4 Scavengers + 5 throwable crates | 1 (after clear) | Use environmental throws (crates stun 2s) or pure combat? |
| **Arena 4** | Arena | 90x90 tiles | 3 Enforcers + 6 Scavengers + 2 fuel canisters | 1 (after clear) | Lure enemies to fuel canister (AoE explosion, 40 damage) or fight normally? |

**Shortcuts**: 1 (Arena 3 has breakable barricade — breaking it reveals shortcut to Arena 4 exit, saves 30s)

**Resources**: 5-10 throwable objects per arena (crates, pipes, signs, fuel canisters)

**Checkpoints**: 4 (one per arena, after clear)

**Rhythm**: 12-15 minutes total (3-4 min per arena)

---

### Phase 6: Flooded Shelter (5 Puzzle Rooms + 3 Rescues)

**Zones**: 8 (5 main path rooms, 3 optional rescue rooms)

| Zone | Type | Size | Hazards/Enemies | Checkpoints | Decision Points |
|------|------|------|-----------------|-------------|-----------------|
| **Room 1 (Power)** | Arena | 40x30 tiles | Power routing puzzle (pump + valve + door) | 1 (exit) | Pump first (floods room, opens path) or valve first (drains, reveals shortcut)? |
| **Room 2 (Oxygen)** | Corridor | 60x20 tiles | Oxygen timer (60s) | 1 (midway, 30s) | Rush through (fast, may fail timer) or explore for collectibles (slower, may succeed)? |
| **Room 3 (Valves)** | Arena | 50x40 tiles | 3 valves (redirect water) | 1 (exit) | Redirect water to flood path (opens shortcut) or drain path (safer, longer)? |
| **Rescue 1 (Optional)** | Safe Room | 30x30 tiles | None (civilian trapped) | None | Rescue civilian (+1 Civilian Aid, +2-3 min) or skip (faster, no aid)? |
| **Rescue 2 (Optional)** | Safe Room | 30x30 tiles | None (civilian trapped) | None | Rescue civilian (+1 Civilian Aid, +2-3 min) or skip? |
| **Rescue 3 (Optional)** | Safe Room | 30x30 tiles | None (civilian trapped) | None | Rescue civilian (+1 Civilian Aid, +2-3 min) or skip? |
| **Room 4 (Platforms)** | Arena | 60x50 tiles | 2 moving platforms (10s cycle) | 1 (exit) | Time platform jumps (fast, may fall) or wait for safe window (slower, safer)? |
| **Room 5 (Exit)** | Hub | 80x60 tiles | None (exit trigger) | 1 (exit, Phase 6 complete) | None (linear exit) |

**Shortcuts**: 2 (Room 1 valve shortcut, Room 3 water flood shortcut — both save 30-60s)

**Resources**: 3 civilians (optional rescues), 2 memory fragments (hidden in Rescue 2 and Room 4)

**Checkpoints**: 6 (Rooms 1-5 exits + midway through Room 2 oxygen)

**Rhythm**: 18-22 minutes total (3-4 min per room, +2-3 min per rescue)

---

### Phase 10: Collapsing Dam (5 Puzzle Rooms)

**Zones**: 5 (sequential puzzle rooms)

| Zone | Type | Size | Hazards/Enemies | Checkpoints | Decision Points |
|------|------|------|-----------------|-------------|-----------------|
| **Room 1 (Power)** | Arena | 50x40 tiles | Power routing (4 circuits, overload risk) | 1 (exit) | Route power to A (door) + B (platform) + C (crane) — all useful, but overloading causes 2s blackout |
| **Room 2 (Platforms)** | Arena | 60x50 tiles | 3 moving platforms (10s cycle each) | 1 (exit) | Time all 3 platforms (fast, complex) or go around (slower, simpler)? |
| **Room 3 (Valves)** | Arena | 50x40 tiles | 4 valves (redirect water, flood/ drain paths) | 1 (exit) | Flood path (opens shortcut, risky) or drain path (safer, longer)? |
| **Room 4 (Crane)** | Arena | 70x60 tiles | Crane control (move bridge) | 1 (exit) | Use crane to move bridge (fast, requires power from Room 1) or swim through toxic water (-1 integrity)? |
| **Room 5 (Calibration)** | Arena | 80x60 tiles | 3 Aster calibration terminals, 3 hazards | 1 (exit) | Use calibration charges (3 total, bypass hazards) or navigate hazards normally (save charges for later)? |

**Shortcuts**: 2 (Room 1 overload shortcut, Room 3 flood shortcut — both save 30-60s)

**Resources**: 3 Aster calibration charges (limited, shared across level)

**Checkpoints**: 5 (one per room exit)

**Rhythm**: 15-20 minutes total (3-4 min per room)

---

### Phase 12: Transit Hub (3 Joint Rooms)

**Zones**: 3 (sequential joint puzzle-combat rooms)

| Zone | Type | Size | Hazards/Enemies | Checkpoints | Decision Points |
|------|------|------|-----------------|-------------|-----------------|
| **Room 1 (Security)** | Arena | 70x60 tiles | Elena: terminal hack (10s). Marcus: 3 waves of 2 Scavengers each | 1 (after clear) | Elena hacks terminal (10s) while Marcus defends — coordinate timing or rush? |
| **Room 2 (Heavy Object)** | Arena | 60x50 tiles | Marcus: push heavy crate (5s). Elena: power lift (terminal, 5s) | 1 (after clear) | Both must act within 3s of each other — communicate timing or fail? |
| **Room 3 (Lighting Stealth)** | Arena | 80x70 tiles | Elena: 3 light switches (off/dim/bright). Marcus: 4 enemies (2 with flashlights, 2 without) | 1 (after clear) | Elena turns lights off (Marcus can stealth takedown unaware enemies) or bright (Marcus must fight all 4)? |

**Shortcuts**: None (linear progression, each room unlocks next)

**Resources**: None (pure puzzle-combat coordination)

**Checkpoints**: 3 (one per room exit)

**Rhythm**: 20-25 minutes total (7-8 min per room)

---

### Phase 13: Final Thaw Station (6 Sections)

**Zones**: 6 (sequential sections, increasing difficulty)

| Zone | Type | Size | Hazards/Enemies | Checkpoints | Decision Points |
|------|------|------|-----------------|-------------|-----------------|
| **Section 1 (Surveillance)** | Corridor | 80x20 tiles | 2 cameras (alert enemies if player seen), 2 patrols | 1 (exit) | Disable cameras (Elena hack, 5s each) or avoid line of sight (slower, stealth)? |
| **Section 2 (Power)** | Arena | 60x50 tiles | Power routing (5 circuits, 3 hazards) + 2 waves of enemies | 1 (after clear) | Route power while defending (hard, fast) or clear enemies first (safer, slower)? |
| **Section 3 (Barricades)** | Corridor | 70x20 tiles | 3 barricades (breakable, 10s each) + 3 marksmen | 1 (exit) | Break barricades (loud, alerts marksmen) or flank marksmen first (quiet, slower)? |
| **Section 4 (Calibration)** | Arena | 80x60 tiles | 3 Aster calibration terminals, 4 hazards, 2 waves of enemies | 1 (after clear) | Calibrate while defending (hard, fast) or clear enemies first (safer, slower)? |
| **Section 5 (Switching)** | Arena | 90x70 tiles | Elena: stabilize system (10s). Marcus: prevent 3 waves of sabotage | 1 (after clear) | Coordinate switching (Elena stabilizes, Marcus protects) or solo (harder)? |
| **Section 6 (Exit)** | Hub | 100x80 tiles | None (exit trigger to Phase 14 boss) | 1 (exit, Phase 13 complete) | None (linear exit) |

**Shortcuts**: 1 (Section 3 barricade skip — if player flanks marksmen first, can skip breaking barricades, saves 30s)

**Resources**: 3-4 researcher rescues (optional, +Civilian Aid), 2-3 equipment repairs (optional, opens shortcuts)

**Checkpoints**: 6 (one per section exit)

**Rhythm**: 25-35 minutes total (4-6 min per section)

---

## Summary: Level Structure Metrics

| Phase | Zones | Checkpoints | Shortcuts | Decision Points | Resources | Avg Rhythm |
|-------|-------|-------------|-----------|-----------------|-----------|------------|
| **0-1 (Tutorial)** | 2 | 2 | 0 | 0 | 6 interactables | 5 min |
| **2 (Laboratory)** | 4 | 4 | 0 | 4 | 8 interactables | 15-20 min |
| **4 (Highway)** | 4 | 4 | 1 | 4 | 20-40 throwables | 12-15 min |
| **6 (Shelter)** | 8 | 6 | 2 | 8 | 3 civilians, 2 memories | 18-22 min |
| **10 (Dam)** | 5 | 5 | 2 | 5 | 3 calibration charges | 15-20 min |
| **12 (Transit Hub)** | 3 | 3 | 0 | 3 | None (pure coordination) | 20-25 min |
| **13 (Final Station)** | 6 | 6 | 1 | 6 | 3-4 rescues, 2-3 repairs | 25-35 min |

**Total Campaign**: 32 zones, 30 checkpoints, 6 shortcuts, 30 decision points, 50+ resources, 120-177 minutes (2-3 hours) of core gameplay (excluding dialogue, cutscenes, exploration).

---

## Sign-Off

**Lead Designer**: [ ] All zones specified with size, hazards, checkpoints, decision points
**Level Designer**: [ ] All shortcuts, resources, rhythm defined
**Lead Programmer**: [ ] All zones implementable, no ambiguity
**QA Lead**: [ ] All zones testable, acceptance criteria clear
**Producer**: [ ] All zones within scope, no feature creep

**Date**: September 30, 2026

**Status**: ✅ LEVEL STRUCTURE COMPLETE. ALL 7 MAJOR PHASES SPECIFIED WITH ZONES, SHORTCUTS, DECISION POINTS, ENCOUNTERS, RESOURCES, CHECKPOINTS, RHYTHM.
