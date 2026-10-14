> **LEGACY DESIGN — UNDER REVIEW (2026-10-14).** This document describes the previous fixed 16-phase, dual-protagonist / combat-arena direction. Preserve it as historical source material, but do not treat its campaign structure, durations, character mechanics, thresholds or acceptance metrics as requirements for the current motion/chase prototype. For current direction and actual implementation boundaries, read [the working vision](VISION.md), [the design pivot brief](DESIGN_PIVOT_PROTOTYPE_BRIEF.md), [the motion/chase prototype](design/MOTION_CHASE_PROTOTYPE.md), and [project status](../PROJECT_STATUS.md). Reconcile this document after the combined investigation/escape prototype has been playtested and the owner approves the full-game direction.

---

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
