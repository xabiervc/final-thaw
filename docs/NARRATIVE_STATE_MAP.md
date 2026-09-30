# FINAL THAW — Narrative State Map

## Full Specification

→ **See**: `docs/narrative_complete.md` (Section: "Estados Narrativos")

## Summary

### Global States (GameManager Variables)

| Variable | Type | Range | Default | Impact |
|----------|------|-------|---------|--------|
| `elena_safety` | int | 0-3 | 3 | ≤1 → Fragile Thaw |
| `prototype_integrity` | int | 0-3 | 3 | ≤1 → Fragile Thaw |
| `civilian_aid` | int | 0-10 | 0 | ≥4 → Public Thaw possible |
| `evidence_choice` | string | preserve/erase | null | preserve → Public, erase → Guarded |
| `story_flags` | dict | See below | {} | NPC dialogue, ending variations |

### Key Story Flags

| Flag | Set When | Impact |
|------|----------|--------|
| `rescued_shelter_civilians` | Phase 6: ≥1 rescued | Phase 13 NPCs grateful vs. bitter |
| `rescued_port_civilians` | Phase 11: ≥1 rescued | Epilogue: thriving vs. abandoned |
| `switching_unlocked` | Phase 12: Free switching | UI changes, cooldown removed |
| `boss_defeated` | Phase 14: Voss defeated | Unlocks Phase 15 (epilogue) |

### State Transitions

```
[Start] → elena_safety=3, prototype_integrity=3, civilian_aid=0
   ↓
[Phase 6] → civilian_aid += 1-3 (player choice)
   ↓
[Phase 10] → prototype_integrity -= 0-2 (player skill)
   ↓
[Phase 12] → evidence_choice = "preserve" or "erase"
   ↓
[Phase 13] → evidence_choice OVERWRITES Phase 12 (final)
   ↓
[Phase 15] → Ending:
   - IF elena_safety≤1 OR prototype_integrity≤1 → Fragile
   - ELSE IF civilian_aid≥4 AND evidence="preserve" → Public
   - ELSE → Guarded
```

---

**Status**: ✅ COMPLETE (full spec in `docs/narrative_complete.md`)
