# FINAL THAW — Technical Quality Standards

## Purpose

This document defines TECHNICAL REQUIREMENTS that are MEASURABLE and TESTABLE. Each requirement has a pass/fail criterion. This is not aspirational—this is a quality gate. If a requirement fails, the game is NOT shippable.

---

## 1. Matriz de Plataformas

### Target Platforms (Priority Order)

| Platform | Priority | Minimum Spec | Target Spec | Notes |
|----------|----------|--------------|-------------|-------|
| **Windows PC** | P0 (Must ship) | GTX 1060 6GB, i5-6600K, 8GB RAM, SSD | RTX 3060, Ryzen 5 3600, 16GB RAM, NVMe | Primary platform, test first |
| **Steam Deck** | P0 (Must ship) | Steam Deck (4GB VRAM, Zen 2, 16GB RAM) | Steam Deck (same) | Verify Proton compatibility, controller layout |
| **macOS** | P1 (Should ship) | M1, 8GB RAM, integrated GPU | M2 Pro, 16GB RAM | Metal backend, test on Mac Mini + MacBook Pro |
| **Linux** | P1 (Should ship) | Ubuntu 20.04+, GTX 1060, 8GB RAM | Ubuntu 22.04+, RTX 3060, 16GB RAM | Native Vulkan, test on Steam Deck + desktop |
| **PlayStation 5** | P2 (Post-launch) | N/A | N/A | Port after PC launch, 60 FPS performance mode |
| **Xbox Series X** | P2 (Post-launch) | N/A | N/A | Port after PC launch, Quick Resume support |
| **Nintendo Switch** | P3 (Consider) | N/A | N/A | Evaluate performance (30 FPS target, dynamic resolution) |

### Platform-Specific Requirements

| Requirement | Windows | Steam Deck | macOS | Linux | PS5 | Xbox |
|-------------|---------|------------|-------|-------|-----|------|
| **Resolution** | 1080p-4K | 800p (native) | 1080p-4K | 1080p-4K | 1440p-4K | 1440p-4K |
| **FPS Target** | 60 locked | 60 locked | 60 locked | 60 locked | 60 (perf), 30 (quality) | 60 locked |
| **Input** | KB+M, XInput | Controller | KB+M, Controller | KB+M, Controller | Controller | Controller |
| **Achievements** | Steam | Steam | Steam | Steam | PSN | Xbox Live |
| **Cloud Saves** | Steam Cloud | Steam Cloud | Steam Cloud | Steam Cloud | PS+ Cloud | Xbox Cloud |
| **HDR** | Optional | N/A | Optional | Optional | Required | Optional |

---

## 2. Objetivos de Rendimiento

### Frame Rate Targets

| Platform | Resolution | FPS Target | Frame Time | V-Sync |
|----------|------------|------------|------------|--------|
| **Windows (Min)** | 1080p | 60 locked | ≤16.67ms | On |
| **Windows (Rec)** | 1440p | 60 locked | ≤16.67ms | On |
| **Windows (High)** | 4K | 60 locked | ≤16.67ms | On |
| **Steam Deck** | 800p | 60 locked | ≤16.67ms | Off (tearing acceptable) |
| **macOS** | 1080p | 60 locked | ≤16.67ms | On |
| **Linux** | 1080p | 60 locked | ≤16.67ms | On |

**Measurement**:
- Tool: Godot Profiler (built-in), PresentMon (Windows), Steam Overlay FPS counter
- Test: Run through Phases 0-16 with profiler enabled. Log FPS every second.
- Pass/Fail: ≥99% of frames must be ≤16.67ms (60 FPS). No frame >33ms (30 FPS floor).

**Pass/Fail**:
- ✅ PASS: ≥99% frames ≤16.67ms, 0 frames >33ms
- ❌ FAIL: Any frame >33ms, or >1% frames >16.67ms

---

### Input Latency

| Platform | Target Latency | Measurement Method |
|----------|----------------|-------------------|
| **Windows** | <50ms (KB+M), <80ms (controller) | High-speed camera (240 FPS), input to action on screen |
| **Steam Deck** | <80ms (controller) | High-speed camera, input to action |
| **macOS/Linux** | <60ms (KB+M), <90ms (controller) | High-speed camera |

**Test**:
- Setup: 240 FPS camera pointed at screen and input device.
- Action: Press attack button (Marcus combat). Measure frames from button press to hit effect on screen.
- Calculation: Frames / 240 = latency in seconds.

**Pass/Fail**:
- ✅ PASS: All platforms meet latency targets
- ❌ FAIL: Any platform exceeds target

---

### Load Times

| Platform | Cold Boot | Scene Transition | Checkpoint Reload |
|----------|-----------|------------------|-------------------|
| **Windows (SSD)** | <5 seconds | <2 seconds | <1 second |
| **Windows (HDD)** | <10 seconds | <4 seconds | <2 seconds |
| **Steam Deck** | <7 seconds | <3 seconds | <1.5 seconds |
| **macOS** | <8 seconds | <3 seconds | <1.5 seconds |
| **Linux** | <8 seconds | <3 seconds | <1.5 seconds |

**Measurement**:
- Cold boot: Game launch from executable to MainMenu controllable.
- Scene transition: Phase select → Phase loads → Player controllable.
- Checkpoint reload: Death → Checkpoint loads → Player controllable.

**Pass/Fail**:
- ✅ PASS: All load times meet targets
- ❌ FAIL: Any load time exceeds target

---

## 3. Presupuesto de Memoria

### Memory Budget (Peak Usage)

| Platform | VRAM Budget | System RAM Budget | Total Budget |
|----------|-------------|-------------------|--------------|
| **Windows (Min)** | 2 GB | 3 GB | 5 GB |
| **Windows (Rec)** | 3 GB | 4 GB | 7 GB |
| **Steam Deck** | 2 GB | 6 GB (shared) | 8 GB |
| **macOS** | 2 GB | 6 GB (shared) | 8 GB |
| **Linux** | 2 GB | 6 GB (shared) | 8 GB |

**Measurement**:
- Tool: Godot Profiler (Memory tab), Task Manager (Windows), Activity Monitor (macOS)
- Test: Run through each phase, log peak memory usage.
- Pass/Fail: Peak must not exceed budget.

**Optimization Strategies**:
- Texture streaming: Load only visible textures, unload off-screen.
- Object pooling: Pre-allocate enemies, particles, projectiles. Reuse, don't free/alloc.
- LOD system: 3 LOD levels for all 3D models. Swap at 20m, 50m distances.
- Occlusion culling: Never render what camera can't see.

**Pass/Fail**:
- ✅ PASS: Peak memory ≤ budget on all platforms
- ❌ FAIL: Any platform exceeds budget

---

## 4. Estrategia de Guardado y Migración

### Save File Structure

```
user://savegame_slot_0.json (active save)
user://savegame_slot_0.backup.json (backup, auto-created)
user://savegame_slot_1.json (manual save 1)
...
user://savegame_slot_10.json (manual save 10)
```

### Save File Format (JSON)

```json
{
  "version": "1.0.0",
  "timestamp": "2026-09-30T10:00:00Z",
  "playtime_seconds": 3600,
  "state": {
    "elena_safety": 3,
    "prototype_integrity": 2,
    "civilian_aid": 5,
    "current_checkpoint_id": "phase_6_shelter_exit",
    "active_character_id": "elena",
    "completed_phases": ["phase_0", "phase_1", "phase_2"],
    "story_flags": {
      "rescued_shelter_civilians": true,
      "evidence_choice": "preserve"
    },
    "memory_fragments_collected": ["elena_memory_1", "marcus_memory_3"]
  },
  "checksum": "CRC32:1234567890"
}
```

### Corruption Detection

**Algorithm**:
1. On load, calculate CRC32 checksum of `state` object.
2. Compare to stored `checksum` field.
3. If mismatch: File corrupt. Attempt backup restore.
4. If backup also corrupt: Delete both, return to MainMenu with error message.

**Error Message**:
```
Save file corrupted. Attempting to restore from backup...
Backup restore failed. Starting new game.
(Your progress has been lost. We apologize for the inconvenience.)
```

### Migration (Version to Version)

**Scenario**: Player has save from v1.0.0, updates to v1.1.0 with new fields.

**Migration Script** (`scripts/autoload/save_migration.gd`):

```gdscript
func migrate(old_save: Dictionary) -> Dictionary:
    var new_save = get_default_save_template()
    
    # Copy over old fields
    new_save.state.elena_safety = old_save.state.elena_safety
    new_save.state.prototype_integrity = old_save.state.prototype_integrity
    # ... copy all fields
    
    # Add new fields with defaults
    if not old_save.state.has("aster_calibrations_used"):
        new_save.state.aster_calibrations_used = 0
    
    # Update version
    new_save.version = "1.1.0"
    
    return new_save
```

**Test**:
- Create save in v1.0.0.
- Update to v1.1.0, load save.
- Verify: All old fields preserved, new fields added with defaults.

**Pass/Fail**:
- ✅ PASS: Migration preserves all data, adds new fields safely
- ❌ FAIL: Any data lost or migration crashes

---

## 5. Telemetría Respetuosa con la Privacidad

### What We Track (Anonymized, Opt-In)

| Metric | Purpose | Personal Data? | Opt-In Required? |
|--------|---------|----------------|------------------|
| **Puzzle completion times** | Balance difficulty | No | Yes |
| **Death locations** | Identify frustrating sections | No | Yes |
| **Choice distribution** | Understand player preferences (evidence choice, rescues) | No | Yes |
| **Average playtime per chapter** | Pacing validation | No | Yes |
| **Drop-off points** | Where players quit | No | Yes |
| **Accessibility option usage** | Validate accessibility investment | No | Yes |
| **Platform, resolution, FPS** | Performance optimization | No | Yes |

### What We DON'T Track

- ❌ IP addresses
- ❌ Geolocation
- ❌ Player names (unless explicitly provided for leaderboards)
- ❌ Hardware serial numbers
- ❌ Email addresses
- ❌ Payment information

### Privacy-Respecting Implementation

**GDPR Compliance**:
- EU players: Explicit opt-in checkbox ("Allow anonymous telemetry to improve the game?")
- Right to deletion: Players can request data deletion via support email.
- Data retention: Telemetry deleted after 2 years.

**Implementation**:
```gdscript
# scripts/autoload/telemetry.gd
var telemetry_enabled: bool = false  # Default OFF

func ask_for_consent():
    if not consent_asked:
        show_consent_dialog()  # "Allow anonymous telemetry?"
        consent_asked = true

class TelemetryEvent:
    var event_type: String
    var timestamp: String
    var data: Dictionary  # Anonymized, no PII
    
func send_event(event: TelemetryEvent):
    if not telemetry_enabled:
        return
    
    # Strip any potential PII
    event.data = anonymize(event.data)
    
    # Send to server (HTTPS only)
    http_request.request(TELEMETRY_URL, ["Content-Type: application/json"], HTTPClient.METHOD_POST, event.to_json())
```

**Pass/Fail**:
- ✅ PASS: Telemetry opt-in only, no PII, GDPR compliant
- ❌ FAIL: Any PII tracked, opt-out not respected

---

## 6. Plan de Localización

### Target Languages (Phase 16 Launch)

| Language | Priority | Text Expansion Factor | Notes |
|----------|----------|----------------------|-------|
| **English** | P0 | 1.0x | Base language |
| **Spanish (ES)** | P0 | 1.2x | European Spanish, not Latin American |
| **French (FR)** | P0 | 1.3x | European French |
| **German (DE)** | P0 | 1.2x | Formal "Sie" form |
| **Portuguese (PT-BR)** | P0 | 1.2x | Brazilian Portuguese |
| **Russian (RU)** | P1 | 1.1x | Cyrillic script, test font rendering |
| **Japanese (JA)** | P1 | 0.8x | Vertical text support optional |
| **Chinese (Simplified)** | P1 | 0.7x | Simplified characters only |
| **Korean (KO)** | P2 | 0.9x | Hangul script |
| **Italian (IT)** | P2 | 1.2x | European Italian |

### Localization Workflow

1. **String Extraction**: All user-facing text in `resources/strings/en.json`, `es.json`, etc.
2. **Translation**: Professional translators (not machine translation for narrative text).
3. **Integration**: Load correct JSON at runtime based on system language or player choice.
4. **Testing**: Native speaker plays through Phases 0-16, reports issues.

### String Table Format

```json
// resources/strings/en.json
{
  "main_menu.start": "Start Game",
  "main_menu.continue": "Continue",
  "main_menu.quit": "Quit",
  "hud.elena_safety": "Elena Safety",
  "hud.prototype_integrity": "Prototype Integrity",
  "hud.civilian_aid": "Civilian Aid",
  "ending.public_thaw.title": "Public Thaw",
  "ending.public_thaw.text": "The climate stabilized over 17 years..."
}
```

### Font Support

| Language | Font | Unicode Range |
|----------|------|---------------|
| **EN, ES, FR, DE, PT, IT** | Noto Sans | Latin Extended (U+0100 to U+024F) |
| **RU** | Noto Sans | Cyrillic (U+0400 to U+04FF) |
| **JA** | Noto Sans JP | CJK Unified Ideographs (U+4E00 to U+9FFF) |
| **ZH** | Noto Sans SC | Simplified Chinese (U+4E00 to U+9FFF) |
| **KO** | Noto Sans KR | Hangul Syllables (U+AC00 to U+D7AF) |

**Test**:
- Display all languages in MainMenu, HUD, subtitles.
- Verify: No missing glyphs, no layout breaking (text expansion handled).

**Pass/Fail**:
- ✅ PASS: All languages render correctly, no missing glyphs
- ❌ FAIL: Any language has missing glyphs or layout breaks

---

## 7. Pruebas de Regresión

### Automated Test Suite

**Test Framework**: GUT (Godot Unit Test) or custom.

**Test Categories**:

| Category | Tests | Frequency |
|----------|-------|-----------|
| **Unit tests** | GameManager save/load, state clamping, checksum validation | Every commit |
| **Integration tests** | Full playthrough Phases 0-3 (automated, no human) | Nightly |
| **Performance tests** | FPS profiling, memory profiling, load timing | Weekly |
| **Regression tests** | Critical path must complete without errors (Phases 0-16) | Before every release |

**Example Test** (GameManager save/load):

```gdscript
# tests/test_game_manager.gd
func test_save_load_preserves_state():
    GameManager.reset_new_game()
    GameManager.elena_safety = 2
    GameManager.prototype_integrity = 1
    GameManager.civilian_aid = 5
    
    GameManager.save_game(0)
    GameManager.reset_new_game()  # Clear state
    GameManager.load_game(0)
    
    assert_eq(GameManager.elena_safety, 2)
    assert_eq(GameManager.prototype_integrity, 1)
    assert_eq(GameManager.civilian_aid, 5)
```

**Pass/Fail**:
- ✅ PASS: All tests pass
- ❌ FAIL: Any test fails (blocks release)

---

## 8. Pruebas de Carga

### Stress Tests

| Test | Scenario | Target | Pass/Fail |
|------|----------|--------|-----------|
| **Enemy spam** | Spawn 50 enemies simultaneously | 60 FPS, no crash | ≥58 FPS, no crash |
| **Particle storm** | Activate all particle systems | 60 FPS, no memory spike | ≥58 FPS, memory ≤ budget |
| **Save/load spam** | Save and load 100 times in sequence | No corruption, no crash | 0 corruptions, no crash |
| **Scene transition spam** | Load/unload scenes 1000 times | No memory leak, no crash | Memory stable, no crash |
| **Input spam** | Press all inputs at 10 Hz for 60 seconds | No input lag spike, no crash | Latency <100ms, no crash |

**Measurement**:
- Tool: Godot Profiler, custom stress test scenes.
- Test: Run each stress test for 5 minutes, log FPS, memory, errors.

**Pass/Fail**:
- ✅ PASS: All stress tests pass (FPS, memory, no crash)
- ❌ FAIL: Any stress test fails

---

## 9. Sistema de Errores Recuperables

### Error Categories

| Category | Examples | Recovery Strategy |
|----------|----------|-------------------|
| **Recoverable** | Save file corrupt (backup exists), texture load fail (fallback texture), audio device lost (fallback to dummy) | Auto-recover, notify player, continue |
| **Unrecoverable** | GPU driver crash, out of memory, critical assertion fail | Graceful shutdown, save crash dump, show error message |

### Error Handling Implementation

```gdscript
# scripts/autoload/error_handler.gd
func handle_error(error: Error, context: String):
    if error == OK:
        return
    
    log_error(error, context)
    
    if is_recoverable(error):
        attempt_recovery(error)
        show_notification("A minor error occurred and was recovered from. Your progress is safe.")
    else:
        save_crash_dump()
        quit_gracefully()
        show_error_message("A critical error occurred. The game will now close. Error: " + str(error))

func is_recoverable(error: Error) -> bool:
    return error in [
        ERR_FILE_NOT_FOUND,  # Fallback to default
        ERR_FILE_CORRUPT,    # Restore from backup
        ERR_CANT_OPEN,       # Skip this asset
        ERR_UNAVAILABLE        # Feature not available on this platform
    ]
```

### Player-Facing Error Messages

| Error | Message | Action |
|-------|---------|--------|
| Save corrupt, backup exists | "Save file corrupted. Restored from backup. Your progress is safe." | Continue playing |
| Save corrupt, no backup | "Save file corrupted. Backup also corrupted. Starting new game." | Reset to new game |
| Texture load fail | (Silent, use fallback magenta texture) | Continue playing |
| Audio device lost | "Audio device lost. Switching to silent mode." | Continue playing, no audio |
| GPU driver crash | "Graphics driver encountered an error. The game will restart." | Restart game |
| Out of memory | "Out of memory. Please close other applications and restart." | Quit to OS |

**Pass/Fail**:
- ✅ PASS: All recoverable errors recover, all unrecoverable errors quit gracefully
- ❌ FAIL: Any error causes hard crash (CTD) without message

---

## 10. Criterios de "Listo para Vertical Slice" y "Listo para Producción"

### Ready for Vertical Slice (Phase 6, 25 Minutes)

| Criterion | Pass/Fail |
|-----------|-----------|
| **Playable start-to-finish** | ☐ Phase 6 complete, no blockers |
| **Core mechanics implemented** | ☐ Elena movement, Marcus combat, interaction, scan, hazards |
| **One moral choice** | ☐ Civilian rescue (3 civilians, +3 Civilian Aid, +5 minutes) |
| **One narrative variation** | ☐ Rescued civilians appear later (Phase 13) |
| **Checkpoint system** | ☐ 3 checkpoints in 25 minutes, save/load works |
| **60 FPS locked** | ☐ Profiler shows ≥99% frames ≤16.67ms |
| **No crashes** | ☐ 10 consecutive playthroughs, 0 crashes |
| **Accessibility baseline** | ☐ Subtitles, remapping, colorblind mode, toggle inputs |
| **Vertical slice ends with cliffhanger** | ☐ Marcus contacts Elena: "I'm coming in." Phase 7 preview loads |

**Sign-off**: [ ] Lead Designer, [ ] Lead Programmer, [ ] Producer

---

### Ready for Production (Phase 0 Full Implementation)

| Criterion | Pass/Fail |
|-----------|-----------|
| **All 17 phases implemented** | ☐ Phases 0-16 complete, playable |
| **All accessibility requirements** | ☐ 38 requirements from accessibility doc, all PASS |
| **Performance targets met** | ☐ 60 FPS, <50ms input, <2s loads on all target platforms |
| **Memory budget met** | ☐ Peak ≤5 GB (Windows min), ≤8 GB (Steam Deck/macOS/Linux) |
| **Save/load robust** | ☐ Corruption detection, backup restore, migration tested |
| **Localization complete** | ☐ 6 languages (EN, ES, FR, DE, PT-BR, RU), all render correctly |
| **Regression tests pass** | ☐ All automated tests pass (unit, integration, performance) |
| **Stress tests pass** | ☐ Enemy spam, particle storm, save/load spam, scene spam, input spam |
| **Error handling robust** | ☐ All recoverable errors recover, all unrecoverable quit gracefully |
| **Telemetry opt-in only** | ☐ GDPR compliant, no PII, anonymized |
| **Vertical slice feedback incorporated** | ☐ Playtester feedback from Phase 6 slice addressed |
| **3 ending cinematics complete** | ☐ Public, Guarded, Fragile (90+ seconds each, fully voiced) |
| **Post-credits stinger** | ☐ Sequel hook, 3 years later, young scientist |
| **Credits complete** | ☐ Team, advisors, voice actors, testers |
| **Store assets prepared** | ☐ Screenshots, trailer, description, content warnings |
| **Award submissions ready** | ☐ The Game Awards, D.I.C.E., BAFTA, GDC (trailers, forms, deadlines) |

**Sign-off**: [ ] Lead Designer, [ ] Lead Programmer, [ ] Producer, [ ] QA Lead, [ ] Publisher (if applicable)

---

## Summary: Technical Quality Checklist

| Section | Requirements | All Pass? |
|---------|--------------|-----------|
| **1. Platform matrix** | 6 platforms, spec defined | ☐ |
| **2. Performance** | 60 FPS, <50ms input, <2s loads | ☐ |
| **3. Memory** | ≤5-8 GB peak, optimized | ☐ |
| **4. Save/migration** | CRC32 checksums, backup, migration | ☐ |
| **5. Telemetry** | Opt-in, anonymized, GDPR | ☐ |
| **6. Localization** | 6-10 languages, fonts, no missing glyphs | ☐ |
| **7. Regression tests** | Unit, integration, performance, critical path | ☐ |
| **8. Stress tests** | Enemy spam, particle storm, save/load spam | ☐ |
| **9. Error handling** | Recoverable vs. unrecoverable, player messages | ☐ |
| **10. Ready criteria** | Vertical slice (9 criteria), Production (16 criteria) | ☐ |

**TOTAL**: 10 sections, ALL must PASS for game to be shippable.

**This is not optional. This is technical excellence as a quality gate.**
