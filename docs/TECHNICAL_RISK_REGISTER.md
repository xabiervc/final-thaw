# FINAL THAW — Technical Risk Register

## Full Specification

→ **See**: `docs/technical_quality.md` (Sections: Performance, Memory, Save, Localization)

## Summary

### Risk Matrix

| Risk | Probability | Impact | Mitigation | Owner |
|------|-------------|--------|------------|-------|
| **Performance <60 FPS** | Medium | High | LOD, occlusion culling, texture streaming, pooling | Lead Programmer |
| **Save corruption** | Low | High | CRC32 checksums, backup restore, migration scripts | Lead Programmer |
| **Accessibility breaks gameplay** | Medium | Medium | Automated tests (38 requirements), disabled gamer playtests | Accessibility Lead |
| **Localization text overflow** | High | Low | Text expansion factors (1.0-1.3x), UI scaling, font fallback | Lead Writer |
| **Memory >5-8 GB** | Medium | High | Texture streaming, pooling, LOD, aggressive unloading | Lead Programmer |
| **Input latency >50ms** | Low | Medium | DirectInput/XInput priority, buffering, 1000Hz polling | Lead Programmer |
| **Checkpoints >5 min apart** | Low | Medium | Level design review, playtest timing, mid-level checkpoints | Lead Designer |
| **Vertical slice delayed** | Medium | High | Scope reduction (fewer rooms/rescues), parallel implementation | Producer |

### Risk Review Cadence

- **Weekly**: Lead Programmer reviews performance, memory, save risks
- **Bi-weekly**: Full team risk review (all categories)
- **Pre-milestone**: Review before Vertical Slice (Week 10) and Production (Week 30)

### Risk Triggers

| Risk | Trigger | Action |
|------|---------|--------|
| Performance <60 FPS | >1% frames >16.67ms | Optimization sprint (1 week) |
| Memory >5 GB | Peak >5 GB (Windows min) | Texture compression, reduce LOD |
| Input latency >50ms | High-speed camera >50ms | Input pipeline audit |
| Vertical slice delayed | Week 8: <50% complete | Scope reduction, cut 1-2 rooms |

---

**Status**: ✅ COMPLETE (full spec in `docs/technical_quality.md`)
