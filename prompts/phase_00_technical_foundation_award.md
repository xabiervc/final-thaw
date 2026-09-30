You are the implementation agent for FINAL THAW, a single-player isometric action-adventure made with Godot 4.x and GDScript. The game alternates puzzle-focused scientist Elena Vast, combat-focused former officer Marcus Reyes, and later joint missions. It has a stylised 2D/2.5D isometric look, not photorealism.

**AWARD-LEVEL TARGET**: This game must compete for The Game Awards, D.I.C.E., BAFTA, and GDC Choice Awards. Every technical decision must support 60 FPS locked, <50ms input latency, <2 second load times, and comprehensive accessibility from day one.

This is Phase 0. Create the complete project foundation with award-winning technical standards.

## REQUIRED PROJECT STRUCTURE
```
scenes/
scenes/ui/
scenes/levels/
scenes/characters/
scenes/components/
scripts/
scripts/autoload/
scripts/characters/
scripts/components/
assets/sprites/
assets/audio/
assets/audio/music/
assets/audio/sfx/
resources/
docs/
exports/
tests/
```

## DELIVERABLES

### 1. Godot 4.x Project Configuration
- **Resolution**: 1280x720 windowed, scalable to 1920x1080 and 4K
- **Physics**: 60 Hz fixed timestep (not variable)
- **Stretch mode**: `canvas_items` with `viewport` stretch for pixel-perfect scaling
- **V-Sync**: Enabled by default, with option to disable
- **Window**: Borderless fullscreen option, always-on-top option for debugging

### 2. Input Map (Comprehensive, Remappable)
Configure and document these actions with default bindings:

**Movement**:
- `move_up`: W, Up Arrow, Controller L-Stick Up
- `move_down`: S, Down Arrow, Controller L-Stick Down
- `move_left`: A, Left Arrow, Controller L-Stick Left
- `move_right`: D, Right Arrow, Controller L-Stick Right
- `sprint`: Shift, Controller L3 (press)
- `interact`: E, F, Controller X
- `scan`: Q, Controller LB
- `switch_character`: Tab, Backspace, Controller Select/Back

**Combat** (Marcus):
- `attack_light`: Mouse Left, Controller RT
- `attack_heavy`: Mouse Right, Controller RB
- `dodge`: Space, Controller B
- `block`: Mouse Middle, Controller LT
- `grab`: G, Controller Y

**System**:
- `pause`: Escape, Controller Start
- `pause`: P
- `hint`: H (for accessibility hint system)

**Accessibility**:
- `slow_motion_toggle`: F1 (developer/QA only, not in release)
- `god_mode_toggle`: F2 (developer/QA only, not in release)

Document ALL bindings in README with alternative layouts for one-handed players.

### 3. CLAUDE.md (Project Constitution)
Create comprehensive CLAUDE.md containing:
- Project overview and award-level vision
- Deterministic design rules (no randomness in critical systems)
- Naming conventions: snake_case for files/functions, PascalCase for classes, camelCase for variables
- Folder structure with explanations
- Performance targets: 60 FPS locked, <2s loads, <50ms input
- Accessibility requirements: All UI scalable, colorblind-safe, screen-reader compatible
- Git workflow: Feature branches, PR reviews, no direct main commits
- Testing expectations: Every feature must be testable, debug tools built-in
- Citation requirement: All external code/assets must have source attribution

### 4. Godot-Compatible .gitignore
Create `.gitignore` that:
- Ignores `.godot/` editor cache, `.import/` folder
- Ignores `exports/` build artifacts (add to .gitignore, don't commit builds)
- Ignores `*.pyc`, `__pycache__/`, `.env`
- **Does NOT ignore**: `project.godot`, `*.tscn`, `*.gd`, `*.tres`, `*.png`, `*.wav`, `*.ogg`
- Includes comment explaining what should and shouldn't be committed

### 5. GameManager Autoload (Robust, Accessible, Award-Level)
Create `scripts/autoload/game_manager.gd` with:

**State Variables** (all visible in debugger, clamped to ranges):
- `elena_safety`: int, range 0-3, start 3
- `prototype_integrity`: int, range 0-3, start 3
- `civilian_aid`: int, range 0-10, start 0
- `current_checkpoint_id`: String, empty string at start
- `active_character_id`: String, "elena" or "marcus"
- `completed_phases`: Array of strings (e.g., ["phase_0", "phase_1"])
- `story_flags`: Dictionary (e.g., {"evidence_choice": "preserve", "rescued_shelter": true})
- `memory_fragments_collected`: Array of strings (unique IDs, e.g., ["elena_memory_1", "marcus_memory_3"])
- `playtime_seconds`: float, accumulates during gameplay
- `difficulty_setting`: String, "normal" or "hard" (for New Game+)

**Functions**:
- `reset_new_game()`: Resets all state to defaults, clears save file
- `save_game(slot: int = 0) -> bool`: Saves to `user://savegame_slot_{slot}.json` with CRC32 checksum. Returns true on success.
- `load_game(slot: int = 0) -> bool`: Loads from slot, verifies checksum. If corrupt, auto-restores from backup `user://savegame_slot_{slot}.backup.json`. Returns true on success.
- `get_elena_safety() -> int`: Safe getter (clamps to 0-3)
- `set_elena_safety(value: int)`: Safe setter (clamps to 0-3, emits signal if changed)
- `get_prototype_integrity() -> int`: Safe getter
- `set_prototype_integrity(value: int)`: Safe setter
- `get_civilian_aid() -> int`: Safe getter
- `set_civilian_aid(value: int)`: Safe setter (clamps to 0-10)
- `add_memory_fragment(fragment_id: String)`: Adds to collection if not already present, returns true if newly collected
- `get_memory_count() -> int`: Returns count of collected memories
- `get_total_playtime_formatted() -> String`: Returns "HH:MM:SS" format

**Signals**:
- `elena_safety_changed(new_value: int)`
- `prototype_integrity_changed(new_value: int)`
- `civilian_aid_changed(new_value: int)`
- `memory_collected(fragment_id: String)`
- `game_saved(slot: int)`
- `game_loaded(slot: int)`

**Error Handling**:
- If save fails (disk full, permission error), log error and return false. Do NOT crash.
- If load fails (file missing, corrupt), attempt backup restore. If that fails, return false and let caller decide (usually load MainMenu with no Continue option).
- All file I/O wrapped in try/catch equivalent (Godot's `push_error()` and return checks)

### 6. MainMenu Scene (Polished, Accessible)
Create `scenes/ui/main_menu.tscn` with:

**Visual Elements**:
- Title: "FINAL THAW" in stylized font (provide placeholder font)
- Subtitle: "A climate thriller about choices that matter"
- Background: Animated weather (light rain, fog) with parallax layers
- Menu buttons: Start Game, Continue, Options, Credits, Quit

**Functionality**:
- **Start Game**: Calls `GameManager.reset_new_game()`, loads `scenes/levels/test_room.tscn`
- **Continue**: Checks for valid save file. If exists, loads it. If not, button is disabled with tooltip "No save found"
- **Options**: Placeholder scene (to be implemented in Phase 1 with accessibility settings)
- **Credits**: Placeholder scrolling text (to be filled in Phase 15)
- **Quit**: Calls `get_tree().quit()` (works in export, does nothing in editor)

**Accessibility**:
- All buttons navigable with keyboard (Tab/Enter) and controller (D-pad/A)
- Focus indicators: Visible border/highlight on selected button
- Screen reader compatible: All text has semantic labels
- Color contrast: Minimum 4.5:1 for all text

**Audio**:
- Background music: Ambient, loopable track (placeholder)
- Button hover sound: Subtle click
- Button press sound: Slightly louder click

### 7. HUD System (Reusable, Accessible, Informative)
Create `scenes/ui/hud.tscn` as reusable scene with:

**Consequence Counters** (visible during gameplay):
- Elena Safety: Heart icon + number (0-3), color-coded (3=green, 2=yellow, 1=orange, 0=red)
- Prototype Integrity: Chip/circuit icon + number (0-3), same color coding
- Civilian Aid: Person icon + number (0-10), color-coded (0-3=red, 4-7=yellow, 8-10=green)

**Additional HUD Elements**:
- Active character indicator: "Playing as: Elena" or "Playing as: Marcus" with character portrait
- Memory fragments counter: "Memories: X/24" (clickable to view collection in pause menu)
- Objective marker: Arrow or minimap showing current goal (toggleable in options)
- Pause button: Top-right corner, accessible with `pause` input

**Accessibility Features**:
- All text scalable (75%-200% via options)
- High contrast mode: Black background, white/yellow text
- Icon + text for all indicators (never icon-only)
- Colorblind-safe: Icons distinguishable without color, patterns used in addition to color

**Auto-Hide Option**:
- HUD can fade out after 10 seconds of no changes (toggleable)
- Fades back in on input or when values change

### 8. Test Room (Functional, Demonstrative)
Create `scenes/levels/test_room.tscn` with:

**Environment**:
- Colored floor (neutral gray, non-distracting)
- Collision walls (invisible or clearly marked)
- Ceiling (optional, for atmosphere)
- Lighting: Even, no dark corners (for testing visibility)

**Player Character**:
- Placeholder CharacterBody2D with:
  - Rectangle collision (64x64 pixels)
  - Sprite (colored square, Elena=blue, Marcus=orange)
  - Ground shadow (ellipse, slightly offset)
  - Camera2D as child, smooth follow enabled

**Movement Script**:
- Uses Input Map actions (not hardcoded keys)
- Normalized diagonal movement (no faster diagonals)
- Acceleration/deceleration (not instant start/stop)
- Maximum speed: 300 pixels/second
- Collision detection: Cannot leave room bounds

**Interactive Elements** (for testing):
- 3 interactable objects (terminals, levers, doors)
- Each shows interaction prompt when in range
- Scan highlights all interactables within 200 pixels
- All objects save/load state correctly

**Testing Checklist** (as comments in scene file):
- [ ] Movement feels smooth, not floaty or stiff
- [ ] Diagonal movement same speed as cardinal
- [ ] Collision prevents leaving room
- [ ] Interaction prompt appears at consistent distance
- [ ] Scan highlights correct targets
- [ ] Save/load preserves all state
- [ ] 60 FPS maintained (use Godot profiler)

### 9. README.md (Comprehensive, Professional)
Create README.md with:

**Project Title & Tagline**:
```
# FINAL THAW
A climate thriller action-adventure about choices that matter.
Alternate between scientist Elena Vast and former officer Marcus Reyes to survive the collapse and decide who the future serves.
```

**Features**:
- Dual-protagonist narrative with meaningful choices
- Isometric 2D/2.5D stylized art
- Puzzle-solving and combat with award-level polish
- Comprehensive accessibility options
- 3 distinct endings based on your decisions
- Target playtime: 12-15 hours

**System Requirements** (Minimum):
- OS: Windows 10, macOS 11+, or Linux (Ubuntu 20.04+)
- Processor: Intel i5-6600K or AMD Ryzen 5 1600
- Memory: 8 GB RAM
- Graphics: NVIDIA GTX 1060 6GB or AMD RX 580
- Storage: 4 GB available space

**Opening & Running**:
1. Clone or download repository
2. Open Godot 4.x (version 4.2 or later)
3. Import project.godot
4. Press F5 to run
5. MainMenu opens. Press Enter or A to select Start Game.

**Controls** (Default):
- Movement: WASD or Arrow Keys or Controller L-Stick
- Interact: E or F or Controller X
- Scan: Q or Controller LB
- Switch Character: Tab or Backspace or Controller Select
- Attack (Marcus): Mouse Left/Right or Controller RT/RB
- Dodge (Marcus): Space or Controller B
- Pause: Escape or P or Controller Start

**Architecture Summary**:
- GameManager autoload handles all persistent state
- HUD displays consequence counters (Elena Safety, Prototype Integrity, Civilian Aid)
- Input Map centralizes all controls, fully remappable
- Save system uses JSON with CRC32 checksums for corruption detection
- All scenes use reusable components (Interactable, Health, etc.)

**Development Phases** (0-16):
- Phase 0: Project foundation (this phase)
- Phase 1: Elena movement and observation
- Phase 2: Abandoned laboratory puzzles
- Phase 3: Marcus combat fundamentals
- Phase 4: Highway riots combat
- Phase 5: Broken vehicle minigame
- Phase 6: Flooded shelter puzzles
- Phase 7: Militia encirclement combat
- Phase 8: First joint mission
- Phase 9: Calibrate Aster minigame
- Phase 10: Collapsing dam puzzles
- Phase 11: Port mutiny combat
- Phase 12: Transit hub joint mission (character switching)
- Phase 13: Final Thaw Station level
- Phase 14: Final boss battle
- Phase 15: Epilogue and endings
- Phase 16: QA, optimization, and release

**Accessibility**:
- Full control remapping
- Subtitle customization (size, color, background)
- Colorblind modes (12 types)
- Reduced motion and weather intensity
- Puzzle hint system (3 levels)
- Slow-motion mode (0.5x, 0.75x, 1.0x)

**License**: [TODO: Decide license - recommend MIT or CC BY-NC-SA]

**Credits**: [Placeholder for team, advisors, voice actors, etc.]

**Contact**: [Placeholder for website, social media, press kit]

### 10. Performance & Debug Tools (Developer-Only, Not in Release)
Create `scripts/autoload/debug_tools.gd` with:

**Functions** (password-protected or editor-only):
- `toggle_god_mode()`: Makes player invincible, infinite stamina
- `toggle_infinite_ammo()`: For combat testing
- `unlock_all_levels()`: Enables chapter select for testing
- `add_all_memories()`: For cinematic testing
- `force_ending(ending_type: String)`: Forces specific ending for QA
- `show_fps_counter()`: Displays real-time FPS, frame time, memory usage
- `teleport_to_checkpoint(checkpoint_id: String)`: For rapid iteration

**UI Overlay** (toggleable with F3):
- FPS counter (top-left)
- Memory usage (MB)
- Current scene name
- Active flags (e.g., "evidence_preserved", "shelter_rescued")
- Input display (shows which keys/buttons are pressed)

**Important**: All debug tools must be disabled in export builds unless explicitly enabled via export feature flag. Never ship with god mode accessible to players.

---

## ACCEPTANCE CRITERIA (MUST PASS)

1. **Opening project.godot in Godot 4.x**: No parser errors, no warnings in Output panel
2. **Running the project**: MainMenu opens within 2 seconds
3. **Start Game**: Loads test_room, placeholder character spawns and is controllable
4. **Movement**: Smooth, normalized, cannot leave room. 60 FPS maintained (verify with profiler)
5. **Interaction**: Prompt appears at correct distance, interactable responds
6. **Scan**: Highlights nearby targets, no performance hit
7. **GameManager**: Accessible as autoload, all three counters visible in HUD (3, 3, 0)
8. **Save/Load**: Save game, close project, reopen, load game. All state preserved. No corruption.
9. **Corrupt save handling**: Manually corrupt save file (edit JSON). Game detects corruption, restores backup or returns to MainMenu without crash
10. **Accessibility**: All buttons navigable with keyboard and controller. Focus visible. Screen reader can read all text
11. **Performance**: 60 FPS locked in test_room with profiler showing <16ms frame time

---

## DO NOT

- Create final art, combat, puzzles, levels, online features, or external dependencies
- Use randomness in any core system (movement, saves, input)
- Hardcode values that should be configurable (speeds, ranges, colors)
- Ignore error handling (all I/O must have try/catch equivalent)
- Ship with debug tools enabled in release builds

---

## FINISH BY REPORTING

1. **Changed files**: List all new/modified files with brief descriptions
2. **Test results**: For each acceptance criterion, state PASS/FAIL with evidence
3. **Known limitations**: Any unresolved issues, technical debt, or TODOs
4. **Performance metrics**: FPS in test_room, load time from MainMenu to test_room, input latency measurement if possible
5. **Commit message**: Propose this exact message:

```
Phase 0: project foundation complete

Award-level technical foundation with:
- 60 FPS locked, <2s loads, <50ms input latency
- Comprehensive Input Map (movement, combat, accessibility)
- GameManager autoload with robust save/load and corruption protection
- Accessible MainMenu and HUD with consequence counters
- Debug tools for QA (disabled in release)
- Full documentation (CLAUDE.md, README, .gitignore)

All acceptance criteria PASS. Ready for Phase 1.
```
