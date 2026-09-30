# FINAL THAW — Award-Level Development Guide

## ⚠️ IMPORTANT: Which Prompts to Use

This document tells you exactly which prompt files to use for each phase to achieve award-level quality.

---

## Updated Prompts (Use These)

| Phase | File to Use | Status |
|-------|-------------|--------|
| **Phase 0** | `phase_00_technical_foundation_award.md` | ✅ Updated with 60 FPS, accessibility, robust save/load, debug tools |
| **Phase 1** | `phase_01_elena_movement_award.md` | ✅ Updated with smooth movement, deterministic interaction, scan system |

## Original Prompts (Need Updating)

| Phase | Original File | Status | Action Needed |
|-------|---------------|--------|---------------|
| Phase 2 | `phase_02_abandoned_laboratory.md` | ⚠️ Original | Use with award_vision.md as reference |
| Phase 3 | `phase_03_marcus_combat.md` | ⚠️ Original | Use with gameplay_technical_enhancements.md combat section |
| Phase 4 | `phase_04_highway_riots.md` | ⚠️ Original | Use with award_vision.md gameplay section |
| Phase 5 | `phase_05_broken_vehicle.md` | ⚠️ Original | Acceptable as-is (minigame is simple) |
| Phase 6 | `phase_06_flooded_shelter.md` | ⚠️ Original | Use with narrative_enhancements.md for rescue dialogue |
| Phase 7 | `phase_07_militia_encirclement.md` | ⚠️ Original | Use with gameplay_technical_enhancements.md boss design |
| Phase 8 | `phase_08_first_contact.md` | ⚠️ Original | Use with narrative_enhancements.md for Elena-Marcus dialogue |
| Phase 9 | `phase_09_calibrate_aster.md` | ⚠️ Original | Acceptable as-is (puzzle design is solid) |
| Phase 10 | `phase_10_collapsing_dam.md` | ⚠️ Original | Use with gameplay_technical_enhancements.md puzzle section |
| Phase 11 | `phase_11_port_mutiny.md` | ⚠️ Original | Use with gameplay_technical_enhancements.md boss + shield design |
| Phase 12 | `phase_12_free_switching.md` | ⚠️ Original | Use with gameplay_technical_enhancements.md switching section |
| Phase 13 | `phase_13_final_thaw_station.md` | ⚠️ Original | Use with award_vision.md for weather, pacing, scope |
| Phase 14 | `phase_14_final_boss.md` | ⚠️ Original | Use with gameplay_technical_enhancements.md boss design |
| Phase 15 | `phase_15_epilogue.md` | ⚠️ Original | Use with narrative_enhancements.md for 3 cinematics |
| Phase 16 | `phase_16_qa_release.md` | ⚠️ Original | Use with quality_integration_summary.md QA checklist |

---

## How to Use This Guide

### For Phases 0-1 (Ready)
1. Open Claude Code
2. Copy `phase_00_technical_foundation_award.md` (for Phase 0) or `phase_01_elena_movement_award.md` (for Phase 1)
3. Paste into Claude Code
4. Let Claude implement
5. Test thoroughly in Godot
6. Commit with exact message from prompt

### For Phases 2-16 (Need Enhancement)
1. Open Claude Code
2. Copy the original prompt (e.g., `phase_03_marcus_combat.md`)
3. **Before pasting**, read the relevant enhancement document:
   - Combat phases (3, 4, 7, 11, 14): Read `docs/gameplay_technical_enhancements.md` combat section
   - Puzzle phases (2, 6, 10): Read `docs/gameplay_technical_enhancements.md` puzzle section
   - Narrative phases (8, 12, 13, 15): Read `docs/narrative_enhancements.md`
   - Switching phase (12): Read `docs/gameplay_technical_enhancements.md` switching section
   - QA phase (16): Read `docs/quality_integration_summary.md` QA checklist
4. **Manually enhance the prompt** by adding specific requirements from enhancement docs:
   - Example for Phase 3 (Marcus Combat): Add combo system, dodge/parry, style meter, enemy AI flanking
   - Example for Phase 15 (Epilogue): Add 3 fully voiced cinematics, post-credits stinger, specific dialogue
5. Paste enhanced prompt into Claude Code
6. Test, commit, proceed

---

## Quick Reference: Award Standards by Phase Type

### Combat Phases (3, 4, 7, 11, 14)
Must include:
- 3-hit combo with extensions
- Perfect dodge (150ms window → 2s slow-mo)
- Parry system (200ms block window → stagger + crit)
- Style meter (D→S rating)
- Environmental combat (3 tiers of throwables)
- Enemy AI: flanking, telegraph hierarchy, adaptive aggression
- 60 FPS locked during combat (no drops)

### Puzzle Phases (2, 6, 10)
Must include:
- Teach→Test→Twist→Master structure
- Immediate feedback on wrong inputs
- Undo function (last 3 actions)
- Hint system (3 charges per level)
- No softlocks (backup systems, emergency exits)
- Visual indicators for all states
- Accessibility: alternate routes for timed sections

### Narrative Phases (8, 12, 13, 15)
Must include:
- Character-specific dialogue (Elena's guilt, Marcus's redemption)
- Dynamic references to player choices (civilians rescued, evidence choice)
- Memory fragments placed throughout (2-3 per level)
- Skippable but meaningful dialogue
- No exposition dumps—show through action
- Subtext carries weight (characters rarely say exactly what they feel)

### Character Switching (Phase 12)
Must include:
- <100ms swap time
- Inactive character invulnerable, frozen, subtle idle
- Contextual lockout (can't switch mid-air, in combat, during scripts)
- Emotional progression (2s cooldown early → instant late-game)
- Synergy moves requiring both characters
- Clear UI feedback when switching is locked

### Boss Phases (7, 11, 14)
Must include:
- Fixed state machine (no random moves)
- Telegraphed attacks (1.0-1.5s windup)
- Punishable windows after each attack
- Phase transitions at health thresholds (100%, 66%, 33%)
- Environmental interactions (optional but helpful)
- Checkpoint on death, not level restart
- 60 FPS locked during boss fight

### Epilogue (Phase 15)
Must include:
- 3 distinct cinematics (90+ seconds each)
- Fully voiced dialogue
- Unique musical themes per ending
- Public Thaw: Earth recovering, Elena at Iris's grave, Marcus at memorial
- Guarded Thaw: Split screen thriving/struggling, resistance forms
- Fragile Thaw: Incomplete stabilization, resilience montage
- Post-credits stinger: Sequel hook, 3 years later, young scientist

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
- Full control remapping
- Subtitle customization (size, color, background)
- Colorblind mode (12 types)
- Reduced motion (no camera shake, screen tilt)
- Reduced weather intensity (particles, effects)
- Puzzle hints (3 levels: off, contextual, full)
- Extended time limits (+50% on all timed puzzles)
- One-handed control scheme compatibility

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

---

## File Organization

```
prompts/
├── AWARD_LEVEL_README.md          ← You are here
├── phase_00_technical_foundation_award.md  ← USE THIS for Phase 0
├── phase_01_elena_movement_award.md        ← USE THIS for Phase 1
├── phase_00_technical_foundation.md        ← Original (don't use)
├── phase_01_elena_movement.md              ← Original (don't use)
├── phase_02_abandoned_laboratory.md        ← Original, enhance manually
├── phase_03_marcus_combat.md               ← Original, enhance with combat section
├── ... (remaining phases 04-16)
```

---

## Next Steps

1. **Phase 0**: Use `phase_00_technical_foundation_award.md` ✅
2. **Phase 1**: Use `phase_01_elena_movement_award.md` ✅
3. **Phase 2**: Use original + manually add puzzle enhancements from `gameplay_technical_enhancements.md`
4. **Phase 3**: Use original + manually add combat enhancements (combo, dodge, parry, style meter)
5. **Continue** through Phase 16, enhancing each with relevant standards

**Goal**: Every phase meets award-level standards by release.

---

## Questions?

If unsure about enhancing a specific phase, reference:
- `docs/award_vision.md` — Overall strategy, pillars of excellence
- `docs/narrative_enhancements.md` — Character depth, dialogue, cinematics
- `docs/gameplay_technical_enhancements.md` — Combat, puzzles, switching, accessibility
- `docs/quality_integration_summary.md` — Comprehensive integration overview

**Standard**: "Every frame, every line, every mechanic must earn its place. If it doesn't make the game better, cut it. If it makes the game good, ask if it could make it great."
