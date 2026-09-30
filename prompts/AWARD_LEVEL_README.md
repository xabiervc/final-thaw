# FINAL THAW — Award-Level Development Guide

## ✅ Status: ALL Phases Have Award-Level Standards

This document tells you exactly which prompt files to use for each phase to achieve award-level quality (The Game Awards, D.I.C.E., BAFTA, GDC Choice).

---

## Fully Updated Prompts (Ready to Use)

| Phase | File to Use | Status | Key Enhancements |
|-------|-------------|--------|------------------|
| **Phase 0** | `phase_00_technical_foundation_award.md` | ✅ Complete | 60 FPS, accessibility, robust save/load, debug tools, comprehensive Input Map |
| **Phase 1** | `phase_01_elena_movement_award.md` | ✅ Complete | Smooth movement, normalized diagonals, deterministic interaction, scan system |
| **Phase 2** | `phase_02_abandoned_laboratory_award.md` | ✅ Complete | Portal 2-style puzzles (teach-test-twist-master), no softlocks, hint system |
| **Phase 3** | `phase_03_marcus_combat_award.md` | ✅ Complete | Hades+DMC combat, 3-hit combo, dodge/parry, style meter, enemy AI flanking |

## Enhancement Guide for Remaining Phases

| Phase | Original File | Enhancement Document |
|-------|---------------|---------------------|
| Phase 4 | `phase_04_highway_riots.md` | `phase_04_to_16_award_enhancements.md` (Highway section) |
| Phase 5 | `phase_05_broken_vehicle.md` | `phase_04_to_16_award_enhancements.md` (Vehicle section) |
| Phase 6 | `phase_06_flooded_shelter.md` | `phase_04_to_16_award_enhancements.md` (Shelter section) |
| Phase 7 | `phase_07_militia_encirclement.md` | `phase_04_to_16_award_enhancements.md` (Militia section) |
| Phase 8 | `phase_08_first_contact.md` | `phase_04_to_16_award_enhancements.md` (First Contact section) |
| Phase 9 | `phase_09_calibrate_aster.md` | `phase_04_to_16_award_enhancements.md` (Aster section) |
| Phase 10 | `phase_10_collapsing_dam.md` | `phase_04_to_16_award_enhancements.md` (Dam section) |
| Phase 11 | `phase_11_port_mutiny.md` | `phase_04_to_16_award_enhancements.md` (Port section) |
| Phase 12 | `phase_12_free_switching.md` | `phase_04_to_16_award_enhancements.md` (Switching section) |
| Phase 13 | `phase_13_final_thaw_station.md` | `phase_04_to_16_award_enhancements.md` (Station section) |
| Phase 14 | `phase_14_final_boss.md` | `phase_04_to_16_award_enhancements.md` (Boss section) |
| Phase 15 | `phase_15_epilogue.md` | `phase_04_to_16_award_enhancements.md` (Epilogue section) |
| Phase 16 | `phase_16_qa_release.md` | `phase_04_to_16_award_enhancements.md` (QA section) |

---

## How to Use This Guide

### For Phases 0-3 (Fully Updated, Ready)

1. Open Claude Code
2. Copy the award prompt (e.g., `phase_00_technical_foundation_award.md`)
3. Paste into Claude Code
4. Let Claude implement
5. Test thoroughly in Godot
6. Commit with exact message from prompt

### For Phases 4-16 (Enhancement Guide Method)

1. Open Claude Code
2. Copy the **original** prompt (e.g., `phase_04_highway_riots.md`)
3. Open `phase_04_to_16_award_enhancements.md` and find the section for your phase
4. Copy the enhancement section
5. Paste **both** into Claude Code (original prompt + enhancements)
6. Let Claude implement
7. Test, commit with enhanced message

**Example for Phase 4**:
```
[Copy contents of phase_04_highway_riots.md]

[Copy contents of phase_04_to_16_award_enhancements.md, Highway section]
```

---

## Quick Reference: Award Standards by Phase Type

### Combat Phases (3, 4, 7, 11, 14)
Must include:
- ✅ 3-hit combo with extensions (Phase 3)
- ✅ Perfect dodge (150ms window → 2s slow-mo) (Phase 3)
- ✅ Parry system (200ms block window → stagger + crit) (Phase 3)
- ✅ Style meter (D→S rating) (Phase 4)
- ✅ Environmental combat (3 tiers of throwables) (Phase 3)
- ✅ Enemy AI: flanking, telegraph hierarchy, adaptive aggression (Phase 3, 7)
- ✅ 60 FPS locked during combat (no drops) (All phases)
- ✅ Boss fixed state machine (no random moves) (Phase 7, 11, 14)
- ✅ Telegraphed attacks (1.0-1.5s windup) (Phase 7, 11, 14)
- ✅ Vulnerability windows (Phase 14)

### Puzzle Phases (2, 6, 9, 10)
Must include:
- ✅ Teach→Test→Twist→Master structure (Phase 2)
- ✅ Immediate feedback on wrong inputs (Phase 2)
- ✅ Undo function (last 3 actions) (Phase 2, 9)
- ✅ Hint system (3 charges per level) (Phase 2, 9)
- ✅ No softlocks (backup systems, emergency exits) (All phases)
- ✅ Visual indicators for all states (Phase 6, 10)
- ✅ Accessibility: alternate routes for timed sections (Phase 6, 10)
- ✅ State-based mechanics (not arbitrary timers) (Phase 6)

### Narrative Phases (8, 12, 13, 15)
Must include:
- ✅ Character-specific dialogue (Elena's guilt, Marcus's redemption) (Phase 8, 12)
- ✅ Dynamic references to player choices (civilians rescued, evidence choice) (Phase 8, 11, 15)
- ✅ Memory fragments placed throughout (2-3 per level) (Phase 6, 11, 13)
- ✅ Skippable but meaningful dialogue (All phases)
- ✅ No exposition dumps—show through action (All phases)
- ✅ Subtext carries weight (Phase 8, 12)
- ✅ 3 fully voiced cinematics (90+ seconds each) (Phase 15)
- ✅ Post-credits stinger (Phase 15)

### Character Switching (Phase 12)
Must include:
- ✅ <100ms swap time (Phase 12)
- ✅ Inactive character invulnerable, frozen, subtle idle (Phase 12)
- ✅ Contextual lockout (can't switch mid-air, in combat, during scripts) (Phase 12)
- ✅ Emotional progression (2s cooldown early → instant late-game) (Phase 12)
- ✅ Synergy moves requiring both characters (Phase 12)
- ✅ Clear UI feedback when switching is locked (Phase 12)

### Epilogue (Phase 15)
Must include:
- ✅ 3 distinct cinematics (90+ seconds each) (Phase 15)
- ✅ Fully voiced dialogue (Phase 15)
- ✅ Unique musical themes per ending (Phase 15)
- ✅ Public Thaw: Earth recovering, Elena at Iris's grave, Marcus at memorial (Phase 15)
- ✅ Guarded Thaw: Split screen thriving/struggling, resistance forms (Phase 15)
- ✅ Fragile Thaw: Incomplete stabilization, resilience montage (Phase 15)
- ✅ Post-credits stinger: Sequel hook, 3 years later, young scientist (Phase 15)
- ✅ Exact ending thresholds (code-proven logic) (Phase 15)

---

## Performance Targets (All Phases)

| Metric | Target | How to Verify |
|--------|--------|---------------|
| FPS | 60 locked | Godot profiler, no drops >5ms |
| Input latency | <50ms | Input display overlay, high-speed camera |
| Load time | <2s | Time from scene load to playable |
| Memory | <500MB peak | Godot debugger, OS task manager |
| Save file size | <100KB | Check `user://savegame_*.json` |

---

## Accessibility Requirements (All Phases)

Every phase must support:
- ✅ Full control remapping (Phase 0)
- ✅ Subtitle customization (size, color, background) (Phase 0)
- ✅ Colorblind mode (12 types) (Phase 0)
- ✅ Reduced motion (no camera shake, screen tilt) (Phase 0)
- ✅ Reduced weather intensity (particles, effects) (Phase 13)
- ✅ Puzzle hints (3 levels: off, contextual, full) (Phase 2, 9)
- ✅ Extended time limits (+50% on all timed puzzles) (Phase 5, 6)
- ✅ One-handed control scheme compatibility (Phase 0)
- ✅ Arena skip option after 3 deaths (Phase 4, 7, 11)

**Test with actual disabled gamers** before Phase 16 QA.

---

## Testing Checklist (Every Phase)

Before committing each phase:
- [ ] All acceptance criteria PASS (documented with screenshots/profiler data)
- [ ] 60 FPS maintained (profiler verification, <16ms frame time)
- [ ] No new warnings in Godot Output panel
- [ ] Save/load works with new state variables
- [ ] Accessibility features functional (keyboard nav, colorblind, subtitles)
- [ ] Debug tools work (for QA testing)
- [ ] Performance metrics logged (FPS, load time, memory)
- [ ] Known limitations documented
- [ ] Commit message matches exact format from prompt

---

## Award Submission Readiness

After Phase 16, verify:
- [ ] Full game playtested start-to-finish (all 3 endings)
- [ ] 24 memory fragments all collectible
- [ ] All accessibility options functional and tested with disabled gamers
- [ ] No crash reports in 48-hour intensive testing
- [ ] 95%+ playtesters complete the game
- [ ] Speedrun Any% <45 minutes achievable
- [ ] 100% completion <8 hours achievable
- [ ] All award submission requirements met (trailers, screenshots, descriptions)
- [ ] Metacritic technical score 9/10 or higher
- [ ] Steam Reviews 90%+ Positive

---

## File Organization

```
prompts/
├── AWARD_LEVEL_README.md          ← You are here (UPDATED)
├── phase_00_technical_foundation_award.md  ← USE THIS for Phase 0 ✅
├── phase_01_elena_movement_award.md        ← USE THIS for Phase 1 ✅
├── phase_02_abandoned_laboratory_award.md  ← USE THIS for Phase 2 ✅
├── phase_03_marcus_combat_award.md         ← USE THIS for Phase 3 ✅
├── phase_04_to_16_award_enhancements.md    ← USE THIS for Phases 4-16 ✅
├── phase_00_technical_foundation.md        ← Original (don't use)
├── phase_01_elena_movement.md              ← Original (don't use)
├── phase_02_abandoned_laboratory.md        ← Original (don't use)
├── phase_03_marcus_combat.md               ← Original (don't use)
├── phase_04_highway_riots.md               ← Original, use with enhancements
├── phase_05_broken_vehicle.md              ← Original, use with enhancements
├── ... (remaining phases 06-16)
```

---

## Next Steps

1. **Phase 0**: Use `phase_00_technical_foundation_award.md` ✅
2. **Phase 1**: Use `phase_01_elena_movement_award.md` ✅
3. **Phase 2**: Use `phase_02_abandoned_laboratory_award.md` ✅
4. **Phase 3**: Use `phase_03_marcus_combat_award.md` ✅
5. **Phase 4**: Use `phase_04_highway_riots.md` + `phase_04_to_16_award_enhancements.md` (Highway section) ✅
6. **Continue** through Phase 16, adding enhancements from guide

**Goal**: Every phase meets award-level standards by release.

---

## Questions?

If unsure about enhancing a specific phase, reference:
- `docs/award_vision.md` — Overall strategy, pillars of excellence
- `docs/narrative_enhancements.md` — Character depth, dialogue, cinematics
- `docs/gameplay_technical_enhancements.md` — Combat, puzzles, switching, accessibility
- `docs/quality_integration_summary.md` — Comprehensive integration overview
- `prompts/phase_04_to_16_award_enhancements.md` — Specific enhancements for phases 4-16

**Standard**: "Every frame, every line, every mechanic must earn its place. If it doesn't make the game better, cut it. If it makes the game good, ask if it could make it great."

---

## Summary of Updates

| Phase | Status | Files |
|-------|--------|-------|
| 0 | ✅ Fully updated | `phase_00_technical_foundation_award.md` |
| 1 | ✅ Fully updated | `phase_01_elena_movement_award.md` |
| 2 | ✅ Fully updated | `phase_02_abandoned_laboratory_award.md` |
| 3 | ✅ Fully updated | `phase_03_marcus_combat_award.md` |
| 4-16 | ✅ Enhancement guide | `phase_04_to_16_award_enhancements.md` |

**All 17 phases now have award-level standards documented and ready to implement.**
