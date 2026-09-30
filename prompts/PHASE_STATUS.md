# FINAL THAW — Phase Prompt Status

## ✅ Award-Level Prompts (Updated & Ready)

Use these files directly in Claude Code—they include all award standards integrated.

| Phase | File to Use | Key Enhancements | Status |
|-------|-------------|------------------|--------|
| **Phase 0** | `phase_00_technical_foundation_award.md` | 60 FPS locked, <50ms input, <2s loads, accessibility from day one, robust save/load with CRC32 + backup, debug tools, comprehensive Input Map | ✅ Complete |
| **Phase 1** | `phase_01_elena_movement_award.md` | Smooth acceleration/deceleration, normalized diagonals, deterministic nearest-target interaction, scan with visual feedback, 10 acceptance criteria | ✅ Complete |
| **Phase 2** | `phase_02_abandoned_laboratory_award.md` | Portal 2-style teach→test→twist→master, immediate feedback (<100ms), undo (3 actions), hints (3 charges), no softlocks, 4 memory fragments | ✅ Complete |
| **Phase 3** | `phase_03_marcus_combat_award.md` | Hades+DMC combat: 3-hit combo, perfect dodge (150ms→2s slow-mo), parry (200ms→stagger+crit), style meter (D→S), environmental combat (3 tiers), enemy AI flanking | ✅ Complete |
| **Phase 8** | `phase_08_first_contact_award.md` | Elena-Marcus chemistry, escort with Path2D waypoints (no NavAgent), Elena Safety (3 defined events), skippable dialogue, toxic rain exit, memory #6 | ✅ Complete |
| **Phase 15** | `phase_15_epilogue_award.md` | 3 fully voiced cinematics (90+ seconds each), unique visuals/music/narration per ending, deterministic resolver, post-credits stinger, New Game+, emotional playtesting | ✅ Complete |

---

## ⚠️ Original Prompts (Need Manual Enhancement)

Use these original files BUT manually add standards from docs before pasting into Claude Code.

| Phase | Original File | Enhancement Needed | Reference Docs |
|-------|---------------|--------------------|----------------|
| **Phase 4** | `phase_04_highway_riots.md` | Add: Style meter, combo tracking, environmental throws (3 tiers), arena wave controller, enforcer AI with counter/block | `gameplay_technical_enhancements.md` (Combat section) |
| **Phase 5** | `phase_05_broken_vehicle.md` | Acceptable as-is (simple minigame). Add: Accessibility hint mode, fire timer visual indicator | `accessibility_implementation.md` |
| **Phase 6** | `phase_06_flooded_shelter.md` | Add: Water flow visualization, pressure gauges, backup systems (no softlocks), civilian rescue dialogue (dynamic), memory fragments (2-3) | `gameplay_technical_enhancements.md` (Puzzles), `narrative_enhancements.md` |
| **Phase 7** | `phase_07_militia_encirclement.md` | Add: Marksman telegraph hierarchy (1.0s windup), cover/line-of-sight logic, boss riot commander fixed state machine (shield bash, block, tear-gas), weak point (rear) | `gameplay_technical_enhancements.md` (Boss design) |
| **Phase 9** | `phase_09_calibrate_aster.md` | Add: Circuit tile rotation (6 nodes, multiple solutions), power flow animation, hint mode (highlight incorrect tile), no timer (storm is atmosphere) | `gameplay_technical_enhancements.md` (Puzzles) |
| **Phase 10** | `phase_10_collapsing_dam.md` | Add: Water cycles (fixed, readable), moving platform component, power routing puzzle, Aster calibration (3 charges), hazard telegraphs, checkpoints | `gameplay_technical_enhancements.md` (Puzzles) |
| **Phase 11** | `phase_11_port_mutiny.md` | Add: Shield enemy mechanics (frontal immunity, flank counterplay), 3 combat arenas, crane boss interaction (optional stun), civilian rescues (2+) | `gameplay_technical_enhancements.md` (Combat + Boss) |
| **Phase 12** | `phase_12_free_switching.md` | Add: <100ms swap, inactive character invulnerable, contextual lockout, emotional progression (2s→instant), synergy moves, 3 rooms requiring both characters | `gameplay_technical_enhancements.md` (Switching) |
| **Phase 13** | `phase_13_final_thaw_station.md` | Add: Weather stages (light→blizzard→extreme, readable), 5-6 sections recombining mechanics, optional researcher rescues, evidence choice (final, overwrites Phase 12) | `award_vision.md` (Art Direction), `narrative_enhancements.md` |
| **Phase 14** | `phase_14_final_boss.md` | Add: Fixed state machine (no random), 3 calibration panels (Elena), vulnerability windows, boss moves (energy blast, shield barrier, reinforcement call, reactor sabotage), environmental actions (venting, overload) | `gameplay_technical_enhancements.md` (Boss design) |
| **Phase 16** | `phase_16_qa_release.md` | Add: Full QA checklist (all endings, all accessibility, 48h crash testing), performance profiling (FPS, memory, loads), export presets (Windows, macOS, Linux), release documentation | `quality_integration_summary.md` (QA section) |

---

## How to Enhance Original Prompts Manually

### Step-by-Step Process

1. **Open the original prompt file** (e.g., `phase_04_highway_riots.md`)
2. **Open the relevant enhancement doc**:
   - Combat phases (4, 7, 11, 14): `docs/gameplay_technical_enhancements.md` → Combat section
   - Puzzle phases (6, 9, 10): `docs/gameplay_technical_enhancements.md` → Puzzle section
   - Narrative phases (12, 13): `docs/narrative_enhancements.md` → Character/Dialogue sections
   - Boss phases (7, 11, 14): `docs/gameplay_technical_enhancements.md` → Boss Design section
3. **Copy specific requirements** from enhancement doc:
   - Example for Phase 4 (Highway Combat):
     ```
     Add to DELIVERABLES:
     - Style meter: D→C→B→A→S based on hit variety, environmental throws, no-damage streaks
     - Combo counter: Visible multiplier (1.0x - 3.0x) in top-right UI
     - Environmental throws: 3 tiers (debris=10 dmg, crates=25 dmg, fuel canisters=40 dmg + AoE)
     - ArenaController: Fixed spawn waves, locked exits while active, checkpoint on clear
     - Enemy Enforcer AI: High health, slow movement, predictable block/counter (1.5s windup), flank weakness
     ```
4. **Paste into original prompt** under DELIVERABLES section
5. **Add acceptance criteria** from enhancement doc:
   - Example:
     ```
     Add to ACCEPTANCE CRITERIA:
     - Style meter visible, updates on each hit, environmental bonus awarded
     - Combo counter resets after 2s no input, multiplier caps at 3.0x
     - 60 FPS locked with 5 enemies, particles, style meter UI
     ```
6. **Update commit message** to mention added enhancements
7. **Paste enhanced prompt** into Claude Code

---

## Quick Reference: Standards to Add by Phase Type

### Combat Phases (4, 7, 11, 14)
Add from `gameplay_technical_enhancements.md`:
- 3-hit combo with extensions
- Perfect dodge (150ms window → 2s slow-mo)
- Parry system (200ms block → stagger + crit)
- Style meter (D→S rating)
- Environmental combat (3 throwable tiers)
- Enemy AI: flanking, telegraph hierarchy, adaptive aggression
- 60 FPS locked during combat

### Puzzle Phases (6, 9, 10)
Add from `gameplay_technical_enhancements.md`:
- Teach→Test→Twist→Master structure
- Immediate feedback (<100ms)
- Undo function (last 3 actions)
- Hint system (3 charges per level)
- No softlocks (backup systems, emergency exits)
- Visual indicators for all states
- Accessibility: alternate routes for timed sections

### Narrative Phases (12, 13)
Add from `narrative_enhancements.md`:
- Character-specific dialogue (Elena's guilt, Marcus's redemption)
- Dynamic references to player choices (civilians rescued, evidence choice)
- Memory fragments placed throughout (2-3 per level)
- Skippable but meaningful dialogue
- No exposition dumps—show through action
- Subtext carries weight

### Boss Phases (7, 11, 14)
Add from `gameplay_technical_enhancements.md` (Boss Design):
- Fixed state machine (no random moves)
- Telegraphed attacks (1.0-1.5s windup)
- Punishable windows after each attack
- Phase transitions at health thresholds (100%, 66%, 33%)
- Environmental interactions (optional but helpful)
- Checkpoint on death, not level restart

### QA Phase (16)
Add from `quality_integration_summary.md`:
- Full game playtested start-to-finish (all 3 endings)
- 24 memory fragments all collectible
- All accessibility options functional + tested with disabled gamers
- No crash reports in 48-hour intensive testing
- 95%+ playtesters complete the game
- Speedrun Any% <45 minutes achievable
- 100% completion <8 hours achievable

---

## Development Order

### Recommended Sequence
1. **Phase 0** ✅ (use award prompt)
2. **Phase 1** ✅ (use award prompt)
3. **Phase 2** ✅ (use award prompt)
4. **Phase 3** ✅ (use award prompt)
5. **Phase 4** ⚠️ (original + combat enhancements)
6. **Phase 5** ⚠️ (original + accessibility hints)
7. **Phase 6** ⚠️ (original + puzzle + narrative enhancements)
8. **Phase 7** ⚠️ (original + boss enhancements)
9. **Phase 8** ✅ (use award prompt)
10. **Phase 9** ⚠️ (original + puzzle enhancements)
11. **Phase 10** ⚠️ (original + puzzle enhancements)
12. **Phase 11** ⚠️ (original + combat + boss enhancements)
13. **Phase 12** ⚠️ (original + switching enhancements)
14. **Phase 13** ⚠️ (original + narrative + art enhancements)
15. **Phase 14** ⚠️ (original + boss enhancements)
16. **Phase 15** ✅ (use award prompt)
17. **Phase 16** ⚠️ (original + QA checklist)

**Total**: 6 award prompts ready ✅, 11 original prompts need enhancement ⚠️

---

## File Organization

```
prompts/
├── PHASE_STATUS.md                    ← You are here
├── AWARD_LEVEL_README.md              ← General guide
├── phase_00_technical_foundation_award.md  ← USE THIS (Phase 0)
├── phase_01_elena_movement_award.md        ← USE THIS (Phase 1)
├── phase_02_abandoned_laboratory_award.md  ← USE THIS (Phase 2)
├── phase_03_marcus_combat_award.md         ← USE THIS (Phase 3)
├── phase_08_first_contact_award.md         ← USE THIS (Phase 8)
├── phase_15_epilogue_award.md              ← USE THIS (Phase 15)
│
├── phase_00_technical_foundation.md        ← Original (don't use)
├── phase_01_elena_movement.md              ← Original (don't use)
├── phase_02_abandoned_laboratory.md        ← Original (don't use)
├── phase_03_marcus_combat.md               ← Original (don't use)
├── phase_04_highway_riots.md               ← Original, enhance manually
├── phase_05_broken_vehicle.md              ← Original, add accessibility
├── phase_06_flooded_shelter.md             ← Original, enhance manually
├── phase_07_militia_encirclement.md        ← Original, enhance manually
├── phase_08_first_contact.md               ← Original (don't use)
├── phase_09_calibrate_aster.md             ← Original, enhance manually
├── phase_10_collapsing_dam.md              ← Original, enhance manually
├── phase_11_port_mutiny.md                 ← Original, enhance manually
├── phase_12_free_switching.md              ← Original, enhance manually
├── phase_13_final_thaw_station.md          ← Original, enhance manually
├── phase_14_final_boss.md                  ← Original, enhance manually
├── phase_15_epilogue.md                    ← Original (don't use)
└── phase_16_qa_release.md                  ← Original, enhance manually
```

---

## Next Steps

1. **For Phases 0-3, 8, 15**: Use `*_award.md` files directly ✅
2. **For Phases 4-7, 9-14, 16**: Use original files + manually enhance per table above ⚠️
3. **Test each phase** with acceptance criteria before proceeding
4. **Log performance metrics** (FPS, load times, memory) for award submission evidence
5. **Document playtester feedback** (especially emotional impact for Phase 15)

**Goal**: Every phase meets award-level standards by release.

---

**Standard**: "Every frame, every line, every mechanic must earn its place. If it doesn't make the game better, cut it. If it makes the game good, ask if it could make it great."
