You are continuing FINAL THAW in Godot 4.x. This game targets award-worthy quality at The Game Awards, D.I.C.E. Awards, BAFTA Games Awards, and Game Developers Choice Awards.

Read CLAUDE.md and inspect the existing project before editing. Phase 0 is complete: MainMenu, GameManager, HUD, Input Map, and test_room exist with professional-grade foundation.

GOAL
Implement Elena Vast's reusable movement, interaction, and scan foundation with award-quality polish, accessibility, and readability in an isometric 2D/2.5D room.

CONTEXT
Elena is an atmospheric systems scientist. Her gameplay focuses on navigation, observation, environmental systems, terminals, and non-lethal puzzle interaction. No combat in this phase. Movement and interaction must feel smooth, intentional, and readable.

QUALITY STANDARDS
- Movement must be smooth at 60 FPS with no stutter
- Interaction prompts must be clear, consistent, and accessible
- Scan must be useful, not decorative
- Code must be modular and reusable across future levels
- Accessibility: input remapping honored, visual indicators clear, no timing-critical actions

DELIVERABLES
1. Create scenes/characters/elena_character.tscn using CharacterBody2D with:
   - Collision shape (capsule or circle for smooth movement)
   - Visible placeholder sprite/shape with clear silhouette
   - Ground-contact shadow (slightly darker circle/oval beneath) for depth perception
   - Required child nodes for interaction detection (Area2D or raycast)
   - Clean node naming and organization

2. Create modular scripts (scripts/characters/elena_movement.gd, elena_interaction.gd):
   - Smooth acceleration/deceleration (not instant start/stop)
   - Normalized diagonal input (no faster diagonal movement)
   - Deterministic physics movement using velocity and move_and_slide()
   - Facing direction tracked for interaction and future animations
   - Room boundary collision that feels fair, not frustrating
   - Extensive comments explaining logic

3. Use top-down/isometric presentation:
   - Controls must feel intuitive relative to displayed world
   - Document chosen approach in comments and README
   - Camera follows Elena smoothly with slight lerp for polish

4. Create reusable Interactable component (scripts/components/interactable.gd):
   - Exports: display_name (string), prompt_text (string), enabled (bool, default true)
   - Method: interact(actor) to be overridden or connected via signals
   - Add to "interactables" group for easy detection
   - Visual feedback when enabled/disabled (color, brightness, or icon)
   - Clear comments and examples

5. Add nearest-target interaction selection:
   - When Elena is in range (configurable, e.g., 64 pixels), show clear interaction prompt
   - If multiple targets in range, select deterministically: nearest distance first, then stable node/path order as tie-breaker
   - Prompt must show interactable name and input button (e.g., "Terminal [E]")
   - Prompt must be readable, high contrast, not obscured

6. Add scan input (bound to Q by default, remappable):
   - Scan highlights interactables within specified radius (e.g., 200 pixels)
   - Use simple, accessible visual treatment: glow, outline, or brightness increase
   - No cooldown; spammable without penalty
   - Must NOT modify puzzle state or trigger interactions
   - Visual feedback must be clear for colorblind players (not just color change)
   - Optional audio cue (placeholder) for accessibility

7. Create scenes/levels/elena_test_room.tscn:
   - Clear walls and floor with readability markers
   - At least three interactables: terminal (opens door), lever (activates platform), locked door (requires terminal)
   - Scan targets clearly placed and visible
   - Small instruction panel explaining controls and objectives
   - Lighting or visual cues that guide player naturally
   - No dead ends or confusing layouts

8. Update GameManager with active_character_id support:
   - Add field and setter/getter
   - Prepare for future switching but do not implement free switching yet
   - Comment thoroughly

9. Add accessibility features:
   - Input remapping fully honored
   - Interaction prompt size adjustable via future settings
   - Scan visual works for colorblind players (brightness/outline, not just color)
   - No timing-critical inputs

ACCEPTANCE CRITERIA
- Elena moves smoothly at 60 FPS and cannot leave room bounds
- Ground shadow makes location and depth clear
- Interaction prompt consistently selects deterministic nearest target
- Scan visibly highlights nearby interactables and does not change state
- All scripts run without errors or warnings
- Interaction works with remapped inputs
- Code is commented, modular, and maintainable
- Test room is completable without confusion

DO NOT
- Implement combat, enemies, or hazards
- Randomize any behavior
- Create complex puzzles (save for Phase 2)
- Hardcode values that should be configurable

Finish by reporting:
- Changed files with brief descriptions
- Test results (what you tested: movement, interaction, scan, save/load, accessibility)
- Known limitations (be honest)
- Propose this commit message exactly:
Phase 1: Elena movement and observation complete
