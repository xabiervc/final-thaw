# FINAL THAW — Vertical Slice Plan

## Full Specification

→ **See**: `docs/core_gameplay_loop.md` (Section: "Vertical Slice Specification")

## Summary

### Scope: Phase 6 (Flooded Shelter) — First 25 Minutes

### Objetivo

Navigate flooded shelter, rescue civilians (optional), reach exit before oxygen runs out.

### Contenido Exacto

**Scenes**:
- 5 puzzle rooms (power, valves, platforms, oxygen, exit)
- 3 civilian rescues (optional, +Civilian Aid)
- 2 memory fragments (hidden)
- 3 checkpoints (room exits)

**Duration**:
- Target: 20-30 minutes (first playthrough)
- Speedrun: 12-15 minutes (optimal path, no rescues)

**Assets**:
- Environment: Wet concrete, pipes, water particles, emergency lighting
- Characters: Elena, 3 civilians (idle, rescued)
- UI: Oxygen timer, prompts, checkpoint notification
- Audio: Water ambience, pump/valve sounds, oxygen alarm, chime
- VFX: Water flow, oxygen depletion, rescue sparkles

### Objetivos (Measurable)

| Objective | Metric | Pass Condition |
|-----------|--------|----------------|
| **Completable** | Playtesters finish | ≥80% complete in 20-30 min |
| **Engaging** | "Wanted to continue" | ≥70% positive feedback |
| **Accessible** | Disabled gamers complete | 2 motor, 2 hearing testers complete |
| **Performant** | 60 FPS, <2s loads | ≥99% frames ≤16.67ms |
| **Stable** | No crashes, no softlocks | 10 playthroughs, 0 crashes |

### Estados (Save/Load)

**Checkpoints**:
- Checkpoint 1: Room 1 exit (power restored)
- Checkpoint 2: Room 3 exit (platform traversed)
- Checkpoint 3: Room 5 exit (level complete)

**Persistent**:
- `civilian_aid` persists through death/reload
- `memory_fragments_collected` persist through death/reload

### Criterios de Éxito (Sign-Off)

- [ ] Lead Designer: Engaging, represents full game
- [ ] Lead Programmer: 60 FPS, no crashes, save/load works
- [ ] Accessibility Lead: All options functional, disabled testers complete
- [ ] Producer: Ready for external playtest (5-10 testers)
- [ ] QA Lead: 10 playthroughs, 0 crashes, 0 softlocks

---

**Status**: ✅ COMPLETE (full spec in `docs/core_gameplay_loop.md`)
