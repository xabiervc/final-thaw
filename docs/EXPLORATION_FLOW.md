# FINAL THAW — Exploration Flow

## Full Specification

→ **See**: `docs/core_gameplay_loop.md` (Section: "Zone Structure, Encounters, Resources, Threats, Rewards" + "Exploration → Survival → Narrative → Progression Integration")

## Summary

### Phase Structure (All Phases)

| Phase | Duration | Components |
|-------|----------|------------|
| **Entry** | 10-20s | Camera pan, narrative message (skippable) |
| **Exploration** | 30-60s | Scan interactables, find memory fragments |
| **Engagement** | 2-4 min | Puzzle/combat, hazards/enemies, optional rescues |
| **Exit** | 10-20s | Exit unlocks, checkpoint save, transition |

### Exploration Metrics

| Phase Type | Exploration | Engagement | Exit | Total |
|------------|-------------|------------|------|-------|
| **Puzzle (Elena)** | 30-60s | 2-4 min | 10-20s | 3-5 min |
| **Combat (Marcus)** | 15-30s | 2-3 min | 10-20s | 2.5-4 min |
| **Joint (Both)** | 30-60s | 3-5 min | 10-20s | 4-6 min |

### Exploration Rewards

| Reward | Frequency | Impact |
|--------|-----------|--------|
| **Memory Fragments** | 2-3 per level, 24 total | Narrative depth, 24/24 unlocks special epilogue |
| **Civilian Rescues** | 8-10 total, optional | +Civilian Aid, enables Public Thaw ending |
| **Shortcuts** | 1-2 per level | Faster route on death/retry |

---

**Status**: ✅ COMPLETE (full spec in `docs/core_gameplay_loop.md`)
