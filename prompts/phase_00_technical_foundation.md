You are the implementation agent for FINAL THAW, a single-player isometric action-adventure made with Godot 4.x and GDScript. This game targets award-worthy quality at The Game Awards, D.I.C.E. Awards, BAFTA Games Awards, and Game Developers Choice Awards.

This is Phase 0. Create the complete project foundation with professional-grade architecture, accessibility, and polish.

QUALITY STANDARDS
- Code must be clean, modular, and maintainable
- No technical debt that will block future phases
- Accessibility built-in from day one
- Performance optimized for 60 FPS on modest hardware
- Zero tolerance for crashes or softlocks

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
1. Configure a Godot 4.x project for 1280x720 minimum resolution, 60 Hz physics, and sensible CanvasItem stretch settings. Document settings in comments.
2. Configure Input Map actions with defaults AND full remapping support: move_up, move_down, move_left, move_right, interact, scan, switch_character, attack_light, attack_heavy, dodge, block, pause. Bind keyboard defaults (WASD/arrows, E, Q, F, J, K, Space, LShift, Enter) and document in README and settings UI.
3. Create CLAUDE.md containing: project overview, deterministic rules (no RNG in gameplay), naming conventions (snake_case for files/functions, PascalCase for classes), folder structure, test expectations, Git workflow, and quality standards reference.
4. Create a Godot-compatible .gitignore. Do NOT ignore source scenes, scripts, or project.godot. Ignore only temporary files, exports, and user-specific configs.
5. Create GameManager as an autoload at scripts/autoload/game_manager.gd with:
   - Visible, clamped integer state: elena_safety (0–3, start 3), prototype_integrity (0–3, start 3), civilian_aid (0–10, start 0)
   - current_checkpoint_id (string), active_character_id (string), completed_phases (array), story_flags (dictionary)
   - Methods: reset_new_game(), save_game(), load_game(), safe getters/setters with validation
   - Save as JSON in user://savegame.json with error handling for missing/corrupt files
   - Signal emissions for state changes (for UI updates)
   - Comprehensive comments explaining each field and method
6. Create MainMenu scene with:
   - Title: FINAL THAW (stylised, readable font)
   - Start Game button (loads scenes/levels/test_room.tscn)
   - Continue button (disabled when no valid save, with tooltip explaining why)
   - Quit button
   - Settings button (placeholder for future accessibility options)
   - Clean, professional UI layout with proper focus navigation
7. Create basic HUD scene (scenes/ui/hud.tscn) with:
   - Three consequence counters visibly displayed at all times
   - Clear icons or labels for each counter
   - High contrast, readable at 1280x720
   - Safe margins for overscan
   - Accessibility-friendly font size (with future scaling support)
8. Create scenes/levels/test_room.tscn:
   - Coloured floor with clear boundaries
   - Collision walls that keep player inside
   - Controllable placeholder CharacterBody2D with smooth movement
   - Camera that follows player with slight lerp for polish
   - Movement normalized diagonally (no faster diagonal movement)
   - Input actions from Input Map, not hardcoded keys
   - Instruction label explaining controls
9. Create README.md with:
   - Project overview and vision (award-quality climate narrative game)
   - Opening/running instructions for Godot 4.x
   - Complete controls table with default bindings
   - Architecture summary (GameManager, autoloads, scene structure)
   - Quality standards reference (link to docs/quality_vision.md)
   - Phases 0–16 list with brief descriptions
   - Accessibility commitments
   - License placeholder (TODO)

ACCEPTANCE CRITERIA
- Opening project.godot in Godot 4.x has zero parser errors
- Running the project opens MainMenu with clean UI
- Start Game opens test_room and placeholder character moves smoothly with all configured inputs
- GameManager is accessible as autoload from any scene; HUD displays all three values correctly
- Saving and loading works flawlessly; missing/corrupt save files are handled gracefully without crash
- Input remapping UI works (even if minimal)
- Code is commented and maintainable
- No console errors or warnings during normal play

DO NOT
- Create final art, combat, puzzles, levels, online features, or external dependencies
- Use hardcoded values that should be configurable
- Ignore accessibility or performance
- Write messy or undocumented code

Finish by reporting:
- Changed files with brief descriptions
- Test results (what you tested and outcomes)
- Known limitations (be honest)
- Propose this commit message exactly:
Phase 0: project foundation complete
