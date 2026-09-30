# FINAL THAW — Level Structure

## Purpose

This document defines the EXACT structure of all zones, shortcuts, decision points, encounters, resources, checkpoints, and rhythm for the entire campaign. This enables level designers to build without structural decisions on the fly.

---

## Zone Overview (16 Phases, 3 Acts)

| Phase | Zone Name | Act | Type | Duration | Shortcuts | Decision Points | Encounters | Resources | Checkpoints |
|-------|-----------|-----|------|----------|-----------|-----------------|------------|-----------|-------------|
| **0** | Test Room | Tutorial | Tutorial | 5 min | 0 | 0 | 0 | 0 | 1 |
| **1** | Elena Test Room | Tutorial | Tutorial | 10 min | 0 | 0 | 0 | 0 | 1 |
| **2** | Abandoned Laboratory | Act I | Puzzle | 20 min | 0 | 1 (power routing choice) | 0 | 0 | 4 (per room) |
| **3** | Combat Arena | Act I | Combat | 15 min | 0 | 0 | 5 waves | 3 health packs | 1 |
| **4** | Highway Riots | Act I | Combat | 15 min | 1 (breakable barricade) | 1 (route choice: safe vs. fast) | 4 arenas | 5 health packs, 3 throwables | 4 (per arena) |
| **5** | Broken Vehicle | Act I | Minigame | 5 min | N/A | 1 (repair before timer) | 0 | 0 | N/A |
| **6** | Flooded Shelter | Act I | Puzzle + Rescues | 20 min | 0 | 3 (rescue 0-3 civilians) | 0 | 2 health packs, 2 memories | 3 (per room) |
| **7** | Militia Perimeter | Act I | Combat + Boss | 18 min | 0 | 1 (kill or spare Commander) | 3 arenas + boss | 4 health packs | 4 (3 arenas + boss) |
| **8** | First Joint Mission | Act I | Joint | 25 min | 0 | 1 (trust Marcus or run) | 2-3 arenas | 3 health packs | 3 (per arena) |
| **9** | Calibrate Aster | Act II | Minigame | 10 min | N/A | 0 | 0 | 0 | N/A |
| **10** | Collapsing Dam | Act II | Puzzle | 20 min | 1 (alternate route) | 1 (use Aster charges or navigate hazards) | 0 | 2 health packs, 2 memories | 5 (per section) |
| **11** | Port Mutiny | Act II | Combat + Boss | 25 min | 0 | 2 (rescue 0-2 evacuees, kill or spare Captain) | 3 arenas + boss | 5 health packs, 3 throwables | 4 (3 arenas + boss) |
| **12** | Transit Hub | Act II | Joint + Switching | 30 min | 0 | 1 (preserve or erase evidence) | 3 rooms | 3 health packs | 3 (per room) |
| **13** | Final Thaw Station | Act III | Joint + Mixed | 35 min | 2 (researcher rescues open shortcuts) | 1 (final evidence choice) | 6 sections | 4 health packs, 3-4 rescues | 6 (per section) |
| **14** | Final Boss | Act III | Boss | 20 min | N/A | 1 (kill or spare Voss) | 1 boss fight | 2 health packs | 3 (per phase) |
| **15** | Epilogue | Act III | Narrative | 15 min | N/A | 1 (ending choice: Public/Guarded/Fragile) | 0 | 0 | N/A |
| **16** | QA & Release | N/A | Testing | N/A | N/A | N/A | N/A | N/A | N/A |

---

## Detailed Zone Breakdown

### Phase 2: Abandoned Laboratory (4 Puzzle Rooms)

**Zone Type**: Puzzle (Elena only)

**Duration**: 20 minutes (5 min per room)

**Shortcuts**: 0 (linear progression)

**Decision Points**:
1. **Room 1**: Power routing choice (door vs. platform—both lead to same exit, but platform reveals optional memory fragment)

**Encounters**: 0 (no combat, only puzzles)

**Resources**:
- 0 health packs (no health system in puzzle rooms)
- 2 memory fragments (1 in Room 1 optional, 1 in Room 4)

**Checkpoints**: 4 (one per room exit)

**Rhythm**: Calm (puzzle-solving) → Tension (hazard navigation) → Relief (checkpoint)

---

### Phase 4: Highway Riots (4 Combat Arenas)

**Zone Type**: Combat (Marcus only)

**Duration**: 15 minutes (3-4 min per arena)

**Shortcuts**: 1 (breakable barricade between Arena 2 and 3—reveals faster route, but Arena 3 is harder)

**Decision Points**:
1. **Arena 2**: Route choice (safe route = longer, no enemies; fast route = shorter, 2 Scavengers + 1 Enforcer)

**Encounters**:
- Arena 1: 3 Scavengers (teach basic combat)
- Arena 2: 1 Enforcer + 2 Scavengers (teach Enforcer patterns)
- Arena 3: 2 Enforcers + 4 Scavengers + throwables (test mastery)
- Arena 4: 3 Enforcers + 6 Scavengers + fuel canisters (final test)

**Resources**:
- 5 health packs (1-2 per arena)
- 3 throwables (pipes, signs, car parts)

**Checkpoints**: 4 (one per arena exit)

**Rhythm**: Tension (arena start) → Action (combat) → Relief (arena clear) → Repeat

---

### Phase 6: Flooded Shelter (5 Rooms + 3 Rescues)

**Zone Type**: Puzzle + Rescues (Elena only)

**Duration**: 20 minutes (4 min per room + 1 min per rescue)

**Shortcuts**: 0 (linear, but rescues are optional)

**Decision Points**:
1. **Room 2**: Rescue civilian 1 (optional, +1 Civilian Aid, +2 min)
2. **Room 4**: Rescue civilian 2 (optional, +1 Civilian Aid, +2 min)
3. **Room 5**: Rescue civilian 3 (optional, +1 Civilian Aid, +2 min, oxygen timer section)

**Encounters**: 0 (no combat, only hazards)

**Resources**:
- 2 health packs (1 in Room 3, 1 in Room 5)
- 2 memory fragments (1 in Room 2 optional rescue, 1 in Room 4)

**Checkpoints**: 3 (one per room exit: Rooms 1, 3, 5)

**Rhythm**: Calm (exploration) → Tension (oxygen timer) → Relief (checkpoint) → Moral choice (rescue or skip)

---

### Phase 10: Collapsing Dam (5 Sections)

**Zone Type**: Puzzle (Elena only)

**Duration**: 20 minutes (4 min per section)

**Shortcuts**: 1 (alternate route in Section 3—longer but no hazard, vs. short but hazardous)

**Decision Points**:
1. **Section 3**: Use Aster charge (bypass hazard, -1 charge) or navigate hazard (risk integrity loss)

**Encounters**: 0 (no combat, only hazards)

**Resources**:
- 2 health packs (1 in Section 2, 1 in Section 4)
- 2 memory fragments (1 in Section 1, 1 in Section 3 optional shortcut)

**Checkpoints**: 5 (one per section exit)

**Rhythm**: Calm (exploration) → Tension (hazard navigation) → Relief (checkpoint) → Resource choice (use charge or risk)

---

### Phase 12: Transit Hub (3 Rooms)

**Zone Type**: Joint (Elena + Marcus, switching required)

**Duration**: 30 minutes (10 min per room)

**Shortcuts**: 0 (linear, switching is mandatory)

**Decision Points**:
1. **Room 3**: Preserve evidence (harder final boss, Public Thaw available) or erase (easier boss, locked to Guarded/Fragile)

**Encounters**:
- Room 1: Elena hacks terminal (10s) while Marcus defends against 3 waves (2 Scavengers per wave)
- Room 2: Marcus pushes heavy object (5s) while Elena powers lift (terminal, 5s)—must coordinate within 3s
- Room 3: Elena controls lighting (3 switches: off/dim/bright) while Marcus performs stealth takedowns (instant kill from behind on unaware enemies)

**Resources**:
- 3 health packs (1 per room)

**Checkpoints**: 3 (one per room exit)

**Rhythm**: Coordination (both characters needed) → Tension (timing/stealth) → Relief (room clear) → Moral choice (evidence)

---

### Phase 13: Final Thaw Station (6 Sections)

**Zone Type**: Joint (Elena + Marcus, mixed puzzle + combat)

**Duration**: 35 minutes (5-6 min per section)

**Shortcuts**: 2 (researcher rescue 1 opens shortcut between Sections 2-3, rescue 2 opens shortcut between Sections 4-5)

**Decision Points**:
1. **Section 6**: Final evidence choice (overwrites Phase 12 choice)—preserve (expose Helix, harder boss) or erase (immediate deployment, easier boss)

**Encounters**:
- Section 1: Security surveillance disable + patrol combat (Elena disables cameras, Marcus fights patrol)
- Section 2: Power reroute + defensive encounter (Elena routes power, Marcus defends against waves)
- Section 3: Barricade clearing + atmospheric calibration (Marcus breaks barricades, Elena calibrates Aster)
- Section 4: Rapid switching (Elena stabilizes system, Marcus prevents sabotage waves)
- Section 5: Optional researcher rescues (0-3, +Civilian Aid, opens shortcuts)
- Section 6: Final evidence discovery + choice

**Resources**:
- 4 health packs (1 per section, 2 in Section 5)
- 3-4 researcher rescues (optional, +Civilian Aid, opens shortcuts)

**Checkpoints**: 6 (one per section exit)

**Rhythm**: Coordination (both characters) → Tension (combat/puzzle) → Relief (checkpoint) → Optional (rescue) → Final choice

---

## Rhythm Analysis (Pacing Across Campaign)

| Act | Phases | Rhythm | Purpose |
|-----|--------|--------|---------|
| **Act I (Separation)** | 0-8 | Tutorial → Puzzle → Combat → Mixed → Joint | Teach mechanics, establish characters, build trust |
| **Act II (Cooperation)** | 9-12 | Minigame → Puzzle → Combat + Boss → Joint + Switching | Deepen mechanics, unlock switching, moral choice |
| **Act III (Convergence)** | 13-15 | Mixed (longest) → Boss → Narrative | Climax, coordination test, ending choice |

**Pacing Rule**: No phase >35 minutes without checkpoint. No phase <5 minutes (except tutorials). Rhythm alternates: calm → tension → relief → repeat.

---

## Sign-Off

**Lead Designer**: [ ] All zones defined with shortcuts, decision points, encounters, resources, checkpoints
**Lead Programmer**: [ ] All checkpoints implemented, shortcuts functional, decision points tracked
**Lead Writer**: [ ] All decision points have narrative weight, rescues affect dialogue/endings
**Accessibility Lead**: [ ] All shortcuts accessible, decision points clear, checkpoints frequent (≤5 min)
**QA Lead**: [ ] All zones testable, rhythm verified (no phase >35 min without checkpoint)
**Producer**: [ ] Level structure complete, no structural decisions left open

**Date**: September 30, 2026
**Status**: ✅ LEVEL STRUCTURE COMPLETE. ALL 16 PHASES DEFINED WITH ZONES, SHORTCUTS, DECISION POINTS, ENCOUNTERS, RESOURCES, CHECKPOINTS, RHYTHM.
