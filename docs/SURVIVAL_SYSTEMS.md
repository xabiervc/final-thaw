> **LEGACY DESIGN — UNDER REVIEW (2026-10-14).** This document describes the previous fixed 16-phase, dual-protagonist / combat-arena direction. Preserve it as historical source material, but do not treat its campaign structure, durations, character mechanics, thresholds or acceptance metrics as requirements for the current motion/chase prototype. For current direction and actual implementation boundaries, read [the working vision](VISION.md), [the design pivot brief](DESIGN_PIVOT_PROTOTYPE_BRIEF.md), [the motion/chase prototype](design/MOTION_CHASE_PROTOTYPE.md), and [project status](../PROJECT_STATUS.md). Reconcile this document after the combined investigation/escape prototype has been playtested and the owner approves the full-game direction.

---

# FINAL THAW — Survival Systems

## Full Specification

→ **See**: `docs/core_gameplay_loop.md` (Section: "Decision Types & Consequences") + `docs/narrative_complete.md` (Section: "Estados Narrativos")

## Summary

### Elena Safety System

**Variable**: `elena_safety` (integer, 0-3, default 3)

**Decrements When**:
1. Enemy reaches Elena (crosses protected boundary)
2. Scripted threat hits Elena (falling debris, explosion)

**Impact**:
- ≤1 → Forces Fragile Thaw ending
- = 3 → Best dialogue, NPCs: "She made it through. All of her."
- 0-1 → NPCs: "She survived. But..."

### Prototype Integrity System

**Variable**: `prototype_integrity` (integer, 0-3, default 3)

**Decrements When**:
1. Elena crosses hazard without protection (steam, electricity, toxic)
2. Sustained hazard exposure (defined event, not per-frame)

**Impact**:
- ≤1 → Forces Fragile Thaw ending
- = 3 → "Prototype stable. Perfect calibration."
- 0-2 → "Prototype damaged. Can still function."

### Civilian Aid System

**Variable**: `civilian_aid` (integer, 0-10, default 0)

**Increments When**:
1. Player rescues civilian (Phase 6: 3, Phase 11: 2, Phase 13: 3-4)
2. Each rescue = +1 (capped at 10, once per rescue)

**Impact**:
- ≥4 → Enables Public Thaw ending (if other conditions met)
- <4 → Locked out of Public Thaw

---

**Status**: ✅ COMPLETE (full spec in `docs/core_gameplay_loop.md` + `docs/narrative_complete.md`)
