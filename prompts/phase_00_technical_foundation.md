You are the implementation agent for FINAL THAW, a single-player isometric action-adventure made with Godot 4.x and GDScript. The game alternates puzzle-focused scientist Elena Vast, combat-focused former officer Marcus Reyes, and later joint missions. It has a stylised 2D/2.5D isometric look, not photorealism.

**QUALITY STANDARD**: This game is being built to compete for The Game Awards, D.I.C.E. Awards, BAFTA Games Awards, and Game Developers Choice Awards. Every system must meet award-winning standards: accessible, performant, polished, and emotionally resonant.

This is Phase 0. Create the complete project foundation.

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
1. Configure a Godot 4.x project for 1280x720, 60 Hz physics, and sensible CanvasItem stretch settings. Target: 60 FPS locked on minimum spec, <100ms input latency.
2. Configure Input Map actions: move_up, move_down, move_left, move_right, interact, scan, switch_character, attack_light, attack_heavy, dodge, block, pause. Bind keyboard defaults (WASD, arrows, E, Q, F, J, K, L, U, I, ESC) and document them in README. Include full control remapping support from start.
3. Create CLAUDE.md containing project overview, deterministic rules, naming conventions, folder structure, test expectations, Git workflow, and award-quality standards reference.
4. Create a Godot-compatible .gitignore. Do not ignore source scenes, scripts, or project.godot.
5. Create GameManager as an autoload at scripts/autoload/game_manager.gd. It must have visible, clamped integer state for elena_safety (start 3, range 0–3), prototype_integrity (start 3, range 0–3), civilian_aid (start 0, range 0–10), current_checkpoint_id, active_character_id, completed_phases, and story_flags. Provide reset_new_game(), save_game(), load_game(), and safe getter/setter methods. Save as JSON in user://savegame.json. Handle missing/corrupt save files safely with backup/restore. Implement triple-save system: write to temp, backup existing, atomic rename, verify integrity.
6. Create a MainMenu scene with title FINAL THAW, Start Game, Continue (disabled when no valid save), and Quit. Start Game should load scenes/levels/test_room.tscn. Add Options button placeholder for future accessibility settings.
7. Create a basic HUD scene or reusable UI component that visibly shows the three consequence counters. Design as diegetic holographic projection (Elena = blue, Marcus = orange). Support UI scaling 75%-200% from start.
8. Create scenes/levels/test_room.tscn: a coloured floor, collision boundaries, a controllable placeholder CharacterBody2D, and a simple camera. Movement must use Input Map actions, be normalized diagonally, and remain inside the room. Include ground shadow for spatial clarity.
9. Create README.md with opening/running instructions, controls, architecture summary, accessibility features (control remapping, UI scale, subtitle options), and a concise list of phases 0–16 with award-quality commitment statement.

ACCEPTANCE CRITERIA
- Opening project.godot in Godot 4.x has no parser errors.
- Running the project opens MainMenu.
- Start Game opens test_room and the placeholder character moves with configured inputs.
- GameManager is accessible as an autoload and HUD displays all three values with diegetic holographic style.
- Saving and loading valid state works; missing/corrupt state does not crash (backup restored).
- Input remapping functional (test: change move_up binding, verify it works).
- UI scaling works (test: set to 150%, verify HUD scales correctly).

DO NOT
- Create final art, combat, puzzles, levels, online features, or external dependencies.
- Hardcode any values that should be accessibility options.
- Ignore performance (target 60 FPS even in test_room).

Finish by reporting changed files, test results (FPS, input latency if measurable, save/load test), known limitations, and propose this commit message exactly:
Phase 0: project foundation complete
