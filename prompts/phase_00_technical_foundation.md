You are the implementation agent for FINAL THAW, a single-player isometric action-adventure made with Godot 4.x and GDScript. The game alternates puzzle-focused scientist Elena Vast, combat-focused former officer Marcus Reyes, and later joint missions. It has a stylised 2D/2.5D isometric look, not photorealism.

**AWARD-LEVEL QUALITY STANDARD**: This game targets competition for The Game Awards, D.I.C.E., BAFTA, and GDC Choice Awards. Every system must be built with accessibility, polish, and technical excellence from day one.

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
1. Configure a Godot 4.x project for 1280x720, 60 Hz physics, and sensible CanvasItem stretch settings. Target 60 FPS locked on minimum spec, <100ms input latency.
2. Configure Input Map actions: move_up, move_down, move_left, move_right, interact, scan, switch_character, attack_light, attack_heavy, dodge, block, pause. Bind keyboard defaults (WASD, arrows, E, Q, F, J, K, L, Shift, Space, P) and document them in README. Make all inputs fully remappable at runtime.
3. Create CLAUDE.md containing project overview, deterministic rules, naming conventions, folder structure, test expectations, Git workflow, and award-level quality commitment.
4. Create a Godot-compatible .gitignore. Do not ignore source scenes, scripts, or project.godot.
5. Create GameManager as an autoload at scripts/autoload/game_manager.gd. It must have visible, clamped integer state for elena_safety (start 3, range 0–3), prototype_integrity (start 3, range 0–3), civilian_aid (start 0, range 0–10), current_checkpoint_id, active_character_id, completed_phases, story_flags, memory_fragments_collected (0/30), nonlethal_ratio (0.0–1.0), and evidence_choice. Provide reset_new_game(), save_game(), load_game(), and safe getter/setter methods. Save as JSON in user://savegame.json. Handle missing/corrupt save files safely with backup recovery.
6. Create a MainMenu scene with title FINAL THAW, Start Game, Continue (disabled when no valid save), Options (placeholder), and Quit. Start Game should load scenes/levels/test_room.tscn. Add subtle animated background (particles or gradient).
7. Create a basic HUD scene or reusable UI component that visibly shows the three consequence counters with diegetic styling (holographic projection aesthetic). Include option to toggle diegetic/classic UI.
8. Create scenes/levels/test_room.tscn: a coloured floor, collision boundaries, a controllable placeholder CharacterBody2D, and a simple camera. Movement must use Input Map actions, be normalized diagonally, and remain inside the room. Include ground shadow for spatial clarity.
9. Create README.md with opening/running instructions, controls, architecture summary, accessibility features (remapping, UI scale, colorblind modes), and a concise list of phases 0–16.
10. Create initial accessibility settings resource at resources/accessibility_settings.tres with: ui_scale (1.0), colorblind_mode ("none"), reduced_motion (false), reduced_weather (false), subtitle_size (1.0), subtitle_background (true), puzzle_hints ("contextual"), aim_assist (0.5), slow_motion (1.0).

ACCEPTANCE CRITERIA
- Opening project.godot in Godot 4.x has no parser errors.
- Running the project opens MainMenu with smooth animation.
- Start Game opens test_room and the placeholder character moves with configured inputs at 60 FPS.
- GameManager is accessible as an autoload and HUD displays all three values with diegetic styling.
- Saving and loading valid state works; missing/corrupt state does not crash and recovers from backup.
- All inputs are remappable via code (UI not required yet).
- Accessibility settings resource loads and can be modified at runtime.

DO NOT
- Create final art, combat, puzzles, levels, online features, or external dependencies.
- Hardcode values that should be settings.
- Ignore accessibility or performance targets.

Finish by reporting changed files, test results (FPS, load time, input latency if measurable), known limitations, and propose this commit message exactly:
Phase 0: project foundation complete with accessibility and performance baseline
