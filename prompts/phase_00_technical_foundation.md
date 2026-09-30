You are the implementation agent for FINAL THAW, a single-player isometric action-adventure made with Godot 4.x and GDScript. The game alternates puzzle-focused scientist Elena Vast, combat-focused former officer Marcus Reyes, and later joint missions. It has a stylised 2D/2.5D isometric look, not photorealism.

**AWARD-WINNING QUALITY STANDARD**: This project targets The Game Awards, D.I.C.E. Awards, BAFTA Games Awards, and Game Developers Choice Awards competition level. Every system must be polished, accessible, and technically excellent. Reference standards: narrative depth of The Last of Us Part II, puzzle design of Portal 2, combat flow of Hades, art direction of Gris + Blade Runner 2049.

This is Phase 0. Create the complete project foundation with award-winning quality.

REQUIRED PROJECT STRUCTURE
- scenes/
- scenes/ui/
- scenes/levels/
- scenes/characters/
- scenes/components/
- scripts/
- scripts/autoload/
- scripts/characters/
- scripts/components/
- assets/sprites/
- assets/audio/
- resources/
- docs/
- exports/

DELIVERABLES
1. Configure a Godot 4.x project for 1280x720, 60 Hz physics, and sensible CanvasItem stretch settings. Target 60 FPS locked on minimum spec (GTX 1060 / RX 580). Document performance targets in CLAUDE.md.
2. Configure Input Map actions: move_up, move_down, move_left, move_right, interact, scan, switch_character, attack_light, attack_heavy, dodge, block, pause. Bind keyboard defaults (WASD/arrows, E, Q, Tab, J/K, Space, Shift, F) and document them in README. Make all inputs fully remappable at runtime.
3. Create CLAUDE.md containing project overview, deterministic rules, naming conventions, folder structure, test expectations, Git workflow, and award-winning quality standards (60 FPS, <100ms input latency, <2s scene transitions, no bugs in release).
4. Create a Godot-compatible .gitignore. Do not ignore source scenes, scripts, or project.godot.
5. Create GameManager as an autoload at scripts/autoload/game_manager.gd. It must have:
   - Visible, clamped integer state: elena_safety (start 3, range 0-3), prototype_integrity (start 3, range 0-3), civilian_aid (start 0, range 0-10)
   - current_checkpoint_id, active_character_id, completed_phases, story_flags (dictionary)
   - Memory fragment collection tracking (24 total, elena_fragments: 0-12, marcus_fragments: 0-12)
   - Combat style tracking: nonlethal_ratio (0.0-1.0), total_kills, total_nonlethal_takedowns
   - Methods: reset_new_game(), save_game(), load_game(), safe getters/setters with validation
   - Save as JSON in user://savegame.json with backup (user://savegame.json.bak)
   - Handle missing/corrupt save files safely (graceful fallback to new game, log error)
   - Autosave every 30 seconds (use timer, flag to disable in settings)
6. Create a MainMenu scene with:
   - Title: FINAL THAW (stylized, readable font)
   - Buttons: Start Game, Continue (disabled when no valid save), Settings, Quit
   - Subtle animated background (particle system, parallax clouds, or gradient shift)
   - Start Game loads scenes/levels/test_room.tscn
   - Continue loads most recent save
   - Settings opens options menu (audio, video, accessibility placeholders)
7. Create a basic HUD scene or reusable UI component that visibly shows:
   - Three consequence counters (Elena Safety: hearts/shields, Prototype Integrity: battery bars, Civilian Aid: people icons)
   - Active character indicator (Elena = blue accent, Marcus = orange accent)
   - Memory fragment counter (optional, toggleable)
   - All UI elements must be scalable (75-200%), colorblind-safe, and high-contrast compatible
8. Create scenes/levels/test_room.tscn:
   - Colored floor with readable boundaries
   - Collision walls (no escape)
   - Controllable placeholder CharacterBody2D with smooth movement
   - Simple camera with smooth follow, boundary clamping
   - Movement uses Input Map actions, normalized diagonally, acceleration/deceleration (not instant)
   - Ground shadow for depth perception
   - At least one interactable object with clear prompt
   - Performance: stable 60 FPS, no stuttering
9. Create README.md with:
   - Opening/running instructions (Godot 4.x required)
   - Controls (keyboard defaults, note full remapping available)
   - Architecture summary (GameManager, scenes, scripts structure)
   - Award-winning quality commitment statement
   - Concise list of phases 0-16 with descriptions
   - Accessibility features overview
   - Performance targets
10. Create initial accessibility settings structure in resources/accessibility_settings.tres or similar:
    - UI scale (default 100%, range 75-200%)
    - High contrast mode (bool)
    - Reduced motion (bool)
    - Subtitle size (enum: small, medium, large, extra_large)
    - Colorblind mode (enum: none, deuteranopia, protanopia, tritanopia)
    - Store in GameManager, apply globally

ACCEPTANCE CRITERIA (Award-Winning Standard)
- Opening project.godot in Godot 4.x has no parser errors or warnings
- Running the project opens MainMenu with smooth 60 FPS
- Start Game opens test_room and placeholder character moves with configured inputs (acceleration, deceleration, no sliding)
- GameManager is accessible as an autoload, all state variables work correctly
- HUD displays all three consequence counters with clear icons, updates in real-time
- Saving and loading works perfectly; missing/corrupt state does not crash, falls back gracefully
- UI is scalable, readable, colorblind-safe
- Input system is fully remappable (document how in CLAUDE.md)
- Performance: 60 FPS locked in test_room, <100ms input latency, <2s scene transitions
- No console errors or warnings during normal gameplay
- Code is clean, documented, follows naming conventions in CLAUDE.md

DO NOT
- Create final art, combat, puzzles, levels, online features, or external dependencies
- Hardcode values that should be settings (UI scale, keybindings, etc.)
- Use random number generators for anything affecting gameplay fairness
- Create technical debt that will block future phases
- Ignore accessibility or performance requirements

QUALITY CHECKLIST BEFORE SUBMITTING
- [ ] All scripts have docstrings explaining purpose
- [ ] All magic numbers are named constants
- [ ] All user-facing text is in one place for localization readiness
- [ ] All scenes load in <2 seconds
- [ ] All inputs are remappable
- [ ] UI scales correctly at 75%, 100%, 150%, 200%
- [ ] Colorblind mode changes are visible and meaningful
- [ ] Save/load tested with: normal save, corrupted save, missing save, multiple saves
- [ ] Performance profiled: 60 FPS stable, no memory leaks
- [ ] No console errors or warnings

Finish by reporting:
1. Changed files (complete list)
2. Test results (manual test checklist with pass/fail)
3. Known limitations (be honest, nothing blocks next phase)
4. Performance metrics (FPS, scene load times, input latency if measurable)
5. Propose this commit message exactly:
Phase 0: project foundation complete - award-winning quality standard
