# FINAL THAW — Progression Specification

## Full Specification

→ **See**: `docs/core_gameplay_loop.md` (Section: "Campaign Rhythm" + "What Changes Between Runs")

## Summary

### Campaign Progression (Linear)

**Phase Order** (Fixed):
```
0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 12 → 13 → 14 → 15 → 16
```

**Unlock**: Phase N unlocks when Phase N-1 completed.

### Duration by Playstyle

| Playstyle | Duration | Characteristics |
|-----------|----------|----------------|
| **Novice (first run)** | 13-15 hours | Exploration, all dialogue, all rescues |
| **Competent (second run)** | 8-10 hours | Optimal path, selective rescues |
| **Expert (speedrun)** | 5-6 hours | No exploration, 0 rescues, perfect timing |

### Skill Progression

| Phase | Elena Skills | Marcus Skills | Joint Skills |
|-------|--------------|---------------|--------------|
| **0-1** | Movement, scan, interaction | Movement, combat basics | N/A |
| **2-3** | Hazard navigation, puzzles | Combo, dodge, parry | N/A |
| **4-7** | Risk/reward, resource allocation | Target priority, stamina | N/A |
| **8-11** | Aster calibration (limited charges) | Shield enemies, boss patterns | Protect Elena, coordinate |
| **12-14** | N/A | N/A | Switching synergy, coordinated attacks |

### New Game+ Unlocks

| Unlock | Requirement | Impact |
|--------|-------------|--------|
| **Easy Mode** | Complete once | 50% less damage, +50% timers |
| **Hard Mode** | Complete on Normal | Faster AI, -50% timers, 2x hazard damage |
| **Chapter Select** | Complete once | Jump to any completed phase |
| **Developer Commentary** | Complete once | Press H for dev insights |

---

**Status**: ✅ COMPLETE (full spec in `docs/core_gameplay_loop.md`)
