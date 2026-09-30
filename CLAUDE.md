# FINAL THAW — Development Guidelines
## Award-Winning Quality Standard

**Target**: The Game Awards, D.I.C.E. Awards, BAFTA Games Awards, Game Developers Choice Awards

**Reference Titles**: The Last of Us Part II (narrative), Portal 2 (puzzle design), Hades (combat), Gris + Blade Runner 2049 (art direction), Celeste (polish)

---

## Project Overview

**FINAL THAW** is a single-player isometric action-adventure with dual protagonists: scientist Elena Vast (puzzles, navigation, interaction) and former officer Marcus Reyes (combat, protection, action). The game features alternating single-character and joint missions, culminating in coordinated boss battles requiring both characters.

**Themes**: Climate collapse, moral complexity, redemption, cooperation vs. control, what survival means when survival itself is weaponized.

**Target**: 12-15 hour experience, 3 endings, New Game+, full accessibility, 60 FPS locked.

---

## Quality Standards (Non-Negotiable)

### Performance
- **60 FPS locked** on minimum spec (GTX 1060 / RX 580)
- **<100ms input latency** end-to-end
- **<2 second scene transitions** (with animated loading screens)
- **0 crashes, 0 softlocks, 0 corrupted saves**

### Polish
- All movement has acceleration/deceleration (no instant starts/stops)
- All UI elements have hover/press states and animated transitions
- All audio has variation (no same sound >3 times without variation)
- All puzzles are deterministic (no randomization affecting fairness)

### Accessibility
- Full control remapping (keyboard, mouse, controller)
- UI scale 75-200%
- Colorblind modes (12 types)
- Subtitle customization (size, color, background, speaker labels)
- Puzzle hint system (off, contextual, full solution)
- Slow-motion mode (0.5x, 0.75x, 1.0x)
- See `docs/accessibility_implementation.md` for complete list

### Code Quality
- All scripts have docstrings
- All magic numbers are named constants
- All user-facing text externalized for localization
- Static typing where possible in GDScript
- No `_process()` for logic that can be `_physics_process()` or timer-based

---

## Folder Structure

```
final-thaw/
├── CLAUDE.md                    # This file
├── GDD.md                       # Game Design Document (award-winning standard)
├── README.md                    # Setup, controls, architecture
├── project.godot                # Godot 4.x project configuration
├── .gitignore                   # Godot-compatible, preserves scenes/scripts
├── scenes/
│   ├── ui/                      # MainMenu, HUD, Settings, Dialogue, Epilogue
│   ├── levels/                  # test_room, elena_test_room, highway, shelter, etc.
│   ├── characters/              # elena_character.tscn, marcus_character.tscn, enemies
│   ├── components/              # reusable: Interactable, Health, Hitbox, etc.
│   └── minigames/               # vehicle repair, Aster calibration
├── scripts/
│   ├── autoload/                # GameManager.gd, EventBus.gd
│   ├── characters/              # Elena, Marcus, enemy AI scripts
│   ├── components/              # Component scripts (Interactable, Health, etc.)
│   └── utils/                   # Helper functions, constants
├── assets/
│   ├── sprites/                 # Characters, environments, UI
│   ├── audio/                   # Music, SFX, voice acting
│   └── fonts/                   # All fonts
├── resources/
│   ├── accessibility_settings.tres
│   ├── combat_data/             # Attack definitions, enemy stats
│   └── narrative/               # Dialogue trees, ending conditions
├── docs/
│   ├── award_vision.md          # Award competition strategy
│   ├── accessibility_implementation.md  # Complete accessibility guide
│   ├── narrative_enhancements.md  # Character arcs, memory fragments, endings
│   ├── technical_excellence.md  # Performance, optimization, QA
│   ├── story_bible.md           # World lore, factions, timeline
│   ├── character_bible.md       # Character profiles, relationships
│   ├── act_outline.md           # Act-by-act story beats
│   └── sample_dialogue.md       # Dialogue examples, tone reference
├── config/
│   ├── narrative_config.json    # Story flags, consequence rules
│   ├── consequence_rules.json   # How choices affect endings
│   └── chapter_config.json      # Level ordering, checkpoints
├── data/
│   ├── factions.json            # Helix, resistance, communities
│   ├── locations.json           # All level metadata
│   └── story_objects.json       # Prototype, terminals, vehicles
├── schemas/
│   ├── story_state_schema.json  # JSON schema for save validation
│   └── ending_calculation_schema.json  # How endings are determined
├── tests/
│   └── continuity_checklist.md  # Narrative consistency tests
├── prompts/                     # Phase prompts for Claude Code
│   ├── README.md
│   ├── phase_00_technical_foundation.md
│   ├── phase_01_elena_movement.md
│   └── ... (all 17 phases)
└── exports/                     # Release builds
```

---

## Naming Conventions

### Files & Folders
- **snake_case**: `elena_character.tscn`, `game_manager.gd`
- **Lowercase**: All folders lowercase (`scenes/`, `scripts/`)
- **Descriptive**: `enemy_scavenger.tscn` not `enemy1.tscn`

### GDScript
- **snake_case**: variables, functions (`var health: int`, `func take_damage()`)
- **PascalCase**: classes, resources (`class_name GameManager`, `enum GameState`)
- **UPPER_SNAKE_CASE**: constants (`const MAX_HEALTH = 100`)
- **Typed**: Always use static typing where possible

### Nodes & Scenes
- **Descriptive**: `$HealthBar` not `$ProgressBar2`
- **Group by function**: `$Combat/HealthBar`, `$Combat/DamageNumber`
- **Instance naming**: `EnemyScavenger01`, `EnemyScavenger02` (not `Scavenger`, `Scavenger2`)

---

## Deterministic Design Rules

### No Randomization in Critical Paths
- **Puzzle solutions**: Fixed, readable, never randomized
- **Enemy spawns**: Fixed lists/waves, never random
- **Damage values**: Fixed per attack type, no random crits
- **AI behavior**: Deterministic state machines, no random decision-making

### Why Determinism Matters
- Players can learn patterns and improve
- Speedrunners can optimize routes
- Accessibility: players with anxiety don't face unpredictable challenges
- QA: bugs are reproducible, not "sometimes happens"

### When Randomization IS Acceptable
- Cosmetic variation (sprite variants, color tints)
- Ambient audio (bird calls, wind gusts) - but still weighted, not pure random
- Particle emission angles (natural variation)
- New Game+ "Hard Mode" modifiers (opt-in challenge)

---

## Input Map Actions

### Required Actions (Document Defaults in README)
```
Movement:
- move_up (W / Up Arrow)
- move_down (S / Down Arrow)
- move_left (A / Left Arrow)
- move_right (D / Right Arrow)
- sprint (Shift) - Marcus only

Interaction:
- interact (E) - terminals, levers, doors
- scan (Q) - Elena only, highlights interactables
- switch_character (Tab) - joint missions only

Combat (Marcus):
- attack_light (J / Mouse Left)
- attack_heavy (K / Mouse Right)
- dodge (Space)
- block (Shift)
- grab (E near throwable)

System:
- pause (Escape)
- menu_nav (Arrow keys / D-pad)
- confirm (Enter / A button)
- cancel (Backspace / B button)
```

**All inputs must be fully remappable at runtime.** Store in `resources/input_config.tres`.

---

## GameManager State Structure

```json
{
  "version": "1.0.0",
  "timestamp": "2026-09-30T20:00:00Z",
  "playtime_seconds": 3600,
  "state": {
    "elena_safety": 3,
    "prototype_integrity": 3,
    "civilian_aid": 5,
    "current_checkpoint_id": "phase_08_checkpoint_2",
    "active_character_id": "elena",
    "completed_phases": [0, 1, 2, 3, 4, 5, 6, 7],
    "story_flags": {
      "has_aster_prototype": true,
      "perimeter_complete": true,
      "termination_order_discovered": true,
      "aster_calibrated": false,
      "final_thaw_station_revealed": false,
      "evidence_choice": null
    },
    "memory_fragments": {
      "elena_fragments": 7,
      "marcus_fragments": 4,
      "collected_ids": [1, 3, 5, 7, 8, 11, 15, 2, 6, 9]
    },
    "combat_stats": {
      "nonlethal_ratio": 0.73,
      "total_kills": 45,
      "total_nonlethal_takedowns": 120
    },
    "rescues": {
      "shelter_civilians_saved": 3,
      "port_civilians_saved": 2,
      "researcher_rescues": 1
    }
  }
}
```

**Save Location**: `user://savegame.json` with backup at `user://savegame.json.bak`

**Autosave**: Every 30 seconds (toggleable in settings)

**Manual Save**: Anytime except during cinematics/combat

---

## Testing Expectations

### Per-Phase Testing

Every phase must pass before committing:

**Functional**:
- [ ] All new features work as specified in prompt
- [ ] No console errors or warnings
- [ ] Save/load works correctly
- [ ] All inputs respond correctly

**Performance**:
- [ ] 60 FPS stable in new areas
- [ ] No memory leaks (profile after 30 min play)
- [ ] Scene transitions <2 seconds

**Accessibility**:
- [ ] UI scales correctly (75%, 100%, 150%, 200%)
- [ ] Colorblind mode changes are visible
- [ ] All new features work with accessibility options

**Edge Cases**:
- [ ] Rapid input sequences don't break systems
- [ ] Save/load during edge states (mid-combat, mid-puzzle) works
- [ ] Death/retry multiple times doesn't accumulate bugs
- [ ] All difficulty settings work

### Release Testing (Phase 16)

- [ ] Full game playthrough (all three endings)
- [ ] Speedrun test (verify no sequence breaks)
- [ ] 100% completion test (all memory fragments, all rescues)
- [ ] Accessibility audit (all options functional)
- [ ] Performance audit (all quality presets)
- [ ] Compatibility test (Windows 10/11, macOS, Linux)

---

## Git Workflow

### Branch Strategy
- `main`: Always deployable, always passes all tests
- `feature/*`: Feature branches (e.g., `feature/elena-movement`, `feature/combat-system`)
- `fix/*`: Bug fix branches (e.g., `fix/save-corruption`, `fix/input-lag`)

### Commit Messages
- Use conventional commits: `type: description`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Phase commits use exact messages from prompts:
  - `Phase 0: project foundation complete - award-winning quality standard`
  - `Phase 1: Elena movement and observation complete`
  - etc.

### Example Workflow
```bash
# Start feature branch
git checkout -b feature/elena-movement main

# Make changes, test thoroughly
git add scenes/characters/elena_character.tscn
git add scripts/characters/elena_movement.gd
git commit -m "feat: implement Elena movement with acceleration/deceleration"

# More changes
git add scenes/levels/elena_test_room.tscn
git commit -m "feat: create Elena test room with interactables"

# Test, verify all checklist items pass
git push origin feature/elena-movement

# Create PR, get review, merge to main
git checkout main
git pull origin main
git merge feature/elena-movement

# Tag phase completion
git tag -a "phase-1-complete" -m "Phase 1: Elena movement and observation complete"
git push origin phase-1-complete
```

---

## Award-Winning Development Mantra

> "Every frame, every line, every mechanic must earn its place. If it doesn't make the game better, cut it. If it makes the game good, ask if it could make it great."

**FINAL THAW will not be "good for an indie game." It will be one of the best games of the year, period.**

---

## Key Reference Documents

- `GDD.md`: Complete game design with award-winning standards
- `docs/award_vision.md`: Award competition strategy, success metrics
- `docs/accessibility_implementation.md`: Complete accessibility guide (The Last of Us Part II standard)
- `docs/narrative_enhancements.md`: Character arcs, memory fragments, dynamic dialogue, ending cinematics
- `docs/technical_excellence.md`: Performance targets, optimization, QA, polish standards
- `docs/story_bible.md`: World lore, factions, timeline
- `docs/character_bible.md`: Character profiles, relationships, arcs
- `docs/act_outline.md`: Act-by-act story beats
- `prompts/README.md`: How to use phase prompts

---

## Getting Started

1. Read this document completely
2. Read `GDD.md` completely
3. Open `prompts/phase_00_technical_foundation.md`
4. Start Phase 0 in fresh Claude Code session
5. Test thoroughly in Godot 4.x
6. Commit with exact message from prompt
7. Proceed to Phase 1

**Do not skip phases. Do not cut corners. Award-winning quality requires award-winning discipline.**
