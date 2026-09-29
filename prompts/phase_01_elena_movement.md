You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect the existing project before editing. Phase 0 is complete: MainMenu, GameManager, HUD, Input Map, and test_room exist.

GOAL
Implement Elena Vast's reusable movement, interaction, and scan foundation in a readable isometric 2D/2.5D room.

CONTEXT
Elena is an atmospheric systems scientist. Her gameplay focuses on navigation, observation, environmental systems, terminals, and non-lethal puzzle interaction. No combat in this phase.

DELIVERABLES
1. Create scenes/characters/elena_character.tscn using CharacterBody2D, collision, visible placeholder sprite/shape, a ground-contact shadow, and required child nodes for interaction detection.
2. Create modular scripts for Elena movement and interaction. Use smooth acceleration/deceleration, normalized diagonal input, deterministic physics movement, facing direction, and room boundary collision.
3. Use a top-down/isometric presentation: controls must feel intuitive relative to the displayed world. Document the chosen approach in comments/README.
4. Create a reusable Interactable component or base script. It must expose display_name, prompt_text, enabled state, and interact(actor). Put interactables in an interactable group.
5. Add nearest-target selection. When Elena is in range, show a clear interaction prompt. If multiple targets are in range, select deterministically: nearest distance, then stable node/path order as tie-breaker.
6. Add scan input. Scan highlights interactables within a specified radius using a simple, accessible visual treatment. It should have no cooldown and must not modify puzzle state.
7. Create scenes/levels/elena_test_room.tscn with walls, floor/readability markers, at least three interactables (terminal, lever, locked door), scan targets, and a small instruction panel.
8. Update GameManager with active_character_id support suitable for later switching, but do not implement free switching yet.

ACCEPTANCE CRITERIA
- Elena moves smoothly and cannot leave room bounds.
- Ground shadow makes location clear.
- Interaction prompt consistently selects the deterministic target.
- Scan visibly highlights nearby interactables and does not change state.
- All scripts run without errors.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 1: Elena movement and observation complete
