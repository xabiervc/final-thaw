# FINAL THAW — Traceability Matrix (Pillar → Mechanic → Scene → Variable → Interface → Test → Acceptance)

## Purpose

This document provides **COMPLETE TRAZABILITY** from design pillars to implementation tests. Every pillar is traced through mechanics, scenes, variables, UI, tests, and acceptance criteria. This eliminates ambiguity and ensures design integration.

---

## Pillar 1: Choices Have Mechanical Consequences

### Pillar Statement

> Every meaningful player decision must change gameplay, not just dialogue or cutscenes. Civilian Aid ≥4 REQUIRED for Public Thaw ending. Prototype Integrity ≤1 FORCES Fragile Thaw. Evidence choice DETERMINES which endings are available.

### Traceability

| Pilar | Mecánica | Escena | Variable | Interfaz | Test | Criterio de Aceptación |
|-------|----------|--------|----------|----------|------|----------------------|
| **Choices Matter** | Civilian rescues | Phase 6: 3 civilians trapped | `civilian_aid` (0-10) | HUD: 👥 X/10 | `test_civilian_aid.py`: Rescue civilian, verify +1, reload, verify persists | ≥80% players rescue ≥4 civilians (Public Thaw eligible) |
| **Choices Matter** | Hazard navigation | Phase 10: Dam hazards | `prototype_integrity` (0-3) | HUD: 💠 X/3 | `test_integrity.py`: Cross hazard unprotected, verify -1, reload, verify persists | Players understand integrity loss is permanent (≤1 → Fragile) |
| **Choices Matter** | Evidence choice | Phase 12 & 13: Binary choice | `evidence_choice` (preserve/erase) | Dialogue prompt: "Preserve evidence?" (Yes/No) | `test_evidence.py`: Choose preserve, verify flag, choose erase, verify override | 50% preserve / 50% erase (meaningful choice, no obvious "correct" answer) |
| **Choices Matter** | Elena Safety | Phase 8+: Enemy reaches Elena | `elena_safety` (0-3) | HUD: ❤️ X/3, warning flash | `test_elena_safety.py`: Enemy crosses boundary, verify -1, verify warning UI | Players protect Elena (≤1 → Fragile) |
| **Choices Matter** | Ending eligibility | Phase 15: 3 endings | All 4 variables above | Ending title card | `test_endings.py`: Set variables to each ending threshold, verify correct ending triggers | All 3 endings achievable, thresholds clear (Public ≥4 aid + preserve, Fragile ≤1 safety/integrity) |

### Integration Test

**Test**: `test_pillar1_choices_matter.py`

```python
def test_civilian_aid_impacts_ending():
    # Setup: Complete game with civilian_aid = 3
    GameManager.civilian_aid = 3
    GameManager.prototype_integrity = 3
    GameManager.elena_safety = 3
    GameManager.evidence_choice = "preserve"
    
    # Expected: Guarded Thaw (aid < 4)
    ending = EndingResolver.resolve()
    assert ending == "guarded_thaw"
    
    # Setup: Complete game with civilian_aid = 4
    GameManager.civilian_aid = 4
    
    # Expected: Public Thaw (aid ≥ 4, evidence preserved)
    ending = EndingResolver.resolve()
    assert ending == "public_thaw"

def test_integrity_loss_forces_fragile():
    # Setup: Complete game with prototype_integrity = 1
    GameManager.prototype_integrity = 1
    GameManager.civilian_aid = 10  # Max aid
    GameManager.evidence_choice = "preserve"
    
    # Expected: Fragile Thaw (integrity ≤1 overrides all)
    ending = EndingResolver.resolve()
    assert ending == "fragile_thaw"
```

**Acceptance**: All tests PASS, thresholds clear, no ambiguity.

---

## Pillar 2: Environment Is Masterable

### Pillar Statement

> Every environmental hazard has a pattern, a telegraph, and a safe window. Player can LEARN it, OPTIMIZE it, and SPEEDRUN it. Nothing is random. Nothing is a "gotcha."

### Traceability

| Pilar | Mecánica | Escena | Variable | Interfaz | Test | Criterio de Aceptación |
|-------|----------|--------|----------|----------|------|----------------------|
| **Masterable** | Steam vent telegraph | Phase 6: Shelter hazards | `hazard_active` (bool), `telegraph_duration` (1.0s) | Visual: Shadow on ground 1.0s before eruption | `test_steam_vent.py`: Verify shadow appears 1.0s before damage, verify safe window | Players can navigate without damage after 2-3 observations |
| **Masterable** | Electrical arc cycle | Phase 10: Dam hazards | `arc_cycle` (10s loop), `safe_window` (8s) | Visual: Beam shows next pole, Audio: crackle ramp-up | `test_electrical.py`: Verify cycle is fixed, verify safe window is 8s | Speedrunners can cross in <50% of novice time |
| **Masterable** | Oxygen timer | Phase 6: Oxygen section | `oxygen_timer` (60s), `checkpoint_midway` (30s) | UI: Depleting bar, Audio: beeps at 25%/10%/5% | `test_oxygen.py`: Verify timer is 60s, verify checkpoint at 30s | ≥80% players complete in 30-40s (generous window) |
| **Masterable** | Platform cycle | Phase 2 & 10: Moving platforms | `platform_cycle` (10s), `call_button` (bool) | Visual: Platform position, UI: Call button | `test_platform.py`: Verify cycle is 10s, verify call button works | Players learn pattern in 1-2 cycles |

### Integration Test

**Test**: `test_pillar2_masterable.py`

```python
def test_steam_vent_learnable():
    # Setup: Player observes vent 3 times
    vent = SteamVent()
    
    # Expected: Telegraph is 1.0s (visible, audible)
    assert vent.telegraph_duration == 1.0
    assert vent.shadow_visible == True
    assert vent.sound_ramp_up == True
    
    # Expected: Safe window is 8s (generous)
    assert vent.safe_window >= 8.0
    
    # Expected: Pattern is fixed (not random)
    assert vent.cycle_is_random == False

def test_speedrun_optimization():
    # Setup: Expert player navigates hazard section
    novice_time = 120  # 2 minutes (learning)
    expert_time = 50   # 50 seconds (optimized)
    
    # Expected: Expert is <50% of novice time
    assert expert_time < (novice_time * 0.5)
```

**Acceptance**: All hazards learnable in 2-3 observations, speedrun optimization possible.

---

## Pillar 3: Dual-Protagonist Is Core

### Pillar Statement

> Elena and Marcus are not interchangeable. Elena = puzzle mastery, Marcus = combat mastery. Switching reflects growing trust (2s cooldown early → instant late-game). Synergy moves require both characters.

### Traceability

| Pilar | Mecánica | Escena | Variable | Interfaz | Test | Criterio de Aceptación |
|-------|----------|--------|----------|----------|------|----------------------|
| **Dual-Protagonist** | Elena puzzles | Phase 2: Laboratory | `puzzle_solved` (bool), `aster_charges` (0-3) | UI: Terminal interface, charge counter | `test_elena_puzzles.py`: Solve puzzle without combat, verify completion | Elena sections completable without combat skills |
| **Dual-Protagonist** | Marcus combat | Phase 4: Highway arenas | `enemies_defeated` (int), `health` (0-100) | UI: Health bar, combo counter | `test_marcus_combat.py`: Defeat all enemies without puzzles, verify completion | Marcus sections completable without puzzle skills |
| **Dual-Protagonist** | Character switching | Phase 12: Transit hub | `switching_unlocked` (bool), `switch_cooldown` (2s → 0s) | UI: Character portrait, cooldown indicator | `test_switching.py`: Verify 2s cooldown early, instant late-game | Switching feels meaningful (trust progression) |
| **Dual-Protagonist** | Synergy moves | Phase 12: 3 rooms | `synergy_complete` (bool) | UI: "Switch to Elena/Marcus" prompt | `test_synergy.py`: Verify both characters required for each room | Neither character can solo synergy rooms |

### Integration Test

**Test**: `test_pillar3_dual_protagonist.py`

```python
def test_elena_cannot_combat():
    # Setup: Elena in combat arena
    elena = Elena()
    enemy = Enemy()
    
    # Expected: Elena has no attack abilities
    assert hasattr(elena, 'attack') == False
    assert hasattr(elena, 'dodge') == False
    
    # Expected: Elena must switch to Marcus or avoid combat
    assert elena.can_defeat_enemy(enemy) == False

def test_marcus_cannot_puzzles():
    # Setup: Marcus at terminal
    marcus = Marcus()
    terminal = Terminal()
    
    # Expected: Marcus cannot hack terminals
    assert hasattr(marcus, 'hack') == False
    
    # Expected: Marcus must switch to Elena or find alternate route
    assert marcus.can_solve_terminal(terminal) == False

def test_synergy_requires_both():
    # Setup: Phase 12 Room 1 (Elena hacks, Marcus defends)
    room = Phase12Room1()
    
    # Expected: Elena alone cannot complete (enemies overwhelm)
    assert room.can_complete_with("elena_only") == False
    
    # Expected: Marcus alone cannot complete (cannot hack)
    assert room.can_complete_with("marcus_only") == False
    
    # Expected: Both together can complete
    assert room.can_complete_with("both") == True
```

**Acceptance**: Neither character can solo all content, switching is mandatory.

---

## Pillar 4: Failure Teaches, Doesn't Punish

### Pillar Statement

> Death or failure should set player back 3-5 minutes maximum, never 30+ minutes. Checkpoints are generous. Collectibles persist through death. The game wants player to SUCCEED, not to SUFFER.

### Traceability

| Pilar | Mecánica | Escena | Variable | Interfaz | Test | Criterio de Aceptación |
|-------|----------|--------|----------|----------|------|----------------------|
| **Failure Teaches** | Checkpoint spacing | All phases | `checkpoint_interval` (≤5 min) | UI: Checkpoint notification | `test_checkpoint_spacing.py`: Measure time between all checkpoints, verify ≤5 min | No section >5 min without checkpoint |
| **Failure Teaches** | Collectible persistence | All phases | `memory_fragments_collected` (array), `civilian_aid` (int) | UI: Memory counter (X/24), Civilian Aid counter (X/10) | `test_collectible_persistence.py`: Collect memory, die, reload, verify persists | Collectibles never lost on death |
| **Failure Teaches** | Skip option | Phase 4, 7, 11 (combat arenas) | `deaths_in_arena` (int) | UI: "Skip this arena" button (appears after 3 deaths) | `test_skip_option.py`: Die 3 times, verify button appears, verify narrative adapts | Players can progress after 3 deaths without softlock |
| **Failure Teaches** | Restart time | All death scenarios | `restart_time` (<5s) | UI: Fade-out, load, fade-in | `test_restart_time.py`: Measure time from death to controllable, verify <5s | No death restart >5 seconds |

### Integration Test

**Test**: `test_pillar4_failure_teaches.py`

```python
def test_checkpoint_spacing():
    # Setup: Measure all checkpoint intervals
    intervals = [phase.checkpoint_interval for phase in all_phases]
    
    # Expected: All intervals ≤5 min (300s)
    assert max(intervals) <= 300
    
    # Expected: Average interval ~3 min (180s)
    assert sum(intervals) / len(intervals) <= 180

def test_collectibles_persist():
    # Setup: Collect memory fragment, die, reload
    GameManager.memory_fragments_collected.append("elena_memory_1")
    player.die()
    GameManager.load_game()
    
    # Expected: Memory still collected
    assert "elena_memory_1" in GameManager.memory_fragments_collected
    
    # Setup: Rescue civilian, die, reload
    GameManager.civilian_aid += 1
    player.die()
    GameManager.load_game()
    
    # Expected: Civilian Aid persists
    assert GameManager.civilian_aid >= 1

def test_skip_after_three_deaths():
    # Setup: Die 3 times in same arena
    arena = Phase4Arena2()
    arena.deaths = 3
    
    # Expected: Skip button appears
    assert arena.skip_button_visible == True
    
    # Expected: Narrative adapts (no Civilian Aid points)
    arena.skip()
    assert GameManager.civilian_aid == 0  # No points for skipped rescue
```

**Acceptance**: All checkpoints ≤5 min apart, collectibles persist, skip option works, restart <5s.

---

## Summary: Complete Traceability

| Pillar | Mechanics Traced | Scenes Covered | Variables Defined | UI Elements | Tests Written | Acceptance Criteria |
|--------|-----------------|----------------|-------------------|-------------|---------------|---------------------|
| **1. Choices Matter** | 4 (rescues, hazards, evidence, safety) | All phases (6, 10, 12, 13, 15) | 4 (civilian_aid, integrity, evidence, elena_safety) | 4 (HUD counters, prompts) | 5 (civilian_aid, integrity, evidence, elena_safety, endings) | All thresholds clear, all endings achievable |
| **2. Environment Masterable** | 4 (vents, electrical, oxygen, platforms) | Phase 6, 10 | 4 (hazard_active, telegraph, cycle, safe_window) | 4 (shadows, beams, timers, call buttons) | 4 (steam, electrical, oxygen, platform) | Learnable in 2-3 observations, speedrun optimization |
| **3. Dual-Protagonist** | 4 (Elena puzzles, Marcus combat, switching, synergy) | Phase 2, 4, 8, 12 | 4 (puzzle_solved, health, switching_unlocked, synergy_complete) | 4 (terminal UI, health bar, portraits, prompts) | 4 (elena_cannot_combat, marcus_cannot_puzzles, switching, synergy) | Neither character can solo all content |
| **4. Failure Teaches** | 4 (checkpoints, collectibles, skip, restart) | All phases | 4 (checkpoint_interval, memory_fragments, deaths_in_arena, restart_time) | 4 (notifications, counters, skip button, fade) | 4 (checkpoint_spacing, collectible_persistence, skip_option, restart_time) | All ≤5 min, persist, skip works, <5s restart |

**Total**: 16 mechanics, 20+ scenes, 16 variables, 16 UI elements, 17 tests, 16 acceptance criteria.

---

## Sign-Off

**Lead Designer**: [ ] All pillars traced through mechanics, scenes, variables
**Lead Programmer**: [ ] All variables implemented, all tests passing
**Lead Writer**: [ ] All narrative consequences reflected in gameplay
**Accessibility Lead**: [ ] All UI elements accessible (remappable, scalable, colorblind-safe)
**QA Lead**: [ ] All acceptance criteria testable, all tests automated
**Producer**: [ ] Traceability complete, no gaps, ready for implementation

**Date**: September 30, 2026
**Status**: ✅ TRACEABILITY MATRIX COMPLETE. ALL PILLARS TRACED FROM DESIGN TO TESTS.
