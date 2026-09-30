You are continuing FINAL THAW in Godot 4.x. This game targets award-worthy quality at The Game Awards, D.I.C.E. Awards, BAFTA Games Awards, and Game Developers Choice Awards.

Read CLAUDE.md and inspect existing systems before editing. Phases 0–2 are complete with professional-grade foundation.

GOAL
Implement Marcus Reyes and a compact, deterministic isometric beat-'em-up combat foundation suitable for later levels. Combat must feel weighty, readable, tactical, and fair—worthy of comparison to Hades, Dead Cells, or Return of the Obra Dinn in terms of clarity and polish.

CONTEXT
Marcus is a former police officer. His gameplay is direct action, protection, crowd control, cover, grabs, and environmental use. Combat must feel readable and weighty, but stay technically modest.

QUALITY STANDARDS
- Every enemy attack must be telegraphed clearly before it hits
- Player must always have a counterplay option (no unavoidable damage)
- Combat must be deterministic: no RNG in damage, timing, or behavior
- Performance: 60 FPS stable even with multiple enemies and effects
- Accessibility: input remapping, reduced camera shake option, clear visual feedback

DELIVERABLES

1. Create scenes/characters/marcus_character.tscn with:
   - CharacterBody2D with collision
   - Placeholder sprite with clear, readable silhouette
   - Ground shadow for depth perception
   - State machine hooks (idle, move, attack, hitstun, etc.)
   - Health component (for future damage)
   - HUD integration (health bar when in combat)
   - Clean node organization and naming

2. Implement movement (scripts/characters/marcus_movement.gd):
   - Same control standard as Elena: smooth acceleration/deceleration, normalized diagonal
   - Add sprint (hold Shift or button), dodge (double-tap or button), and block (hold button)
   - Dodge has fixed invincibility frames (e.g., 0.3s); expose timings in constants/resources
   - Block reduces fixed percentage of frontal damage (e.g., 60%); document clearly
   - All inputs remappable and honored

3. Implement combat state machine (scripts/characters/marcus_combat.gd):
   - States: idle, move, light_attack, heavy_attack, combo, dodge, block, hitstun, grab, throw, defeated
   - Clear transitions with comments
   - Deterministic behavior: no randomness
   - Extensive documentation

4. Implement fixed three-hit combo:
   - Explicit attack data: startup frames, active frames, recovery frames, damage, knockback
   - Deterministic input buffering (e.g., 0.2s window to chain attacks)
   - No random critical hits or damage variance
   - Combo must feel satisfying and weighty
   - Visual feedback: hit flash, camera shake (with reduce toggle), particle or label feedback

5. Build reusable Hitbox/Hurtbox and Health components (scripts/components/):
   - Hitbox: damage, knockback, hitstun duration, attacker reference
   - Hurtbox: health reference, invincibility frames after hit
   - Avoid double hits from single attack (use attacked flag or I-frames)
   - Easy to debug: visible hitboxes in debug mode, clear console logs
   - Well-commented and modular

6. Create enemy_scavenger.tscn (scripts/enemies/enemy_scavenger.gd):
   - Deterministic AI state machine: idle, approach, windup, strike, recovery, hitstun, defeated
   - Attacks on predictable range and timing (e.g., 1.5s windup, 0.3s active, 0.5s recovery)
   - Visible health bar above enemy
   - Clear telegraph: windup animation, audio cue, or visual indicator
   - Dies cleanly with defeat animation or fade
   - Modular and reusable for future levels

7. Create grab/throwable-object system (scripts/components/grab_point.gd, throwable_object.gd):
   - Marcus can grab eligible objects (crates, barrels) with interact input
   - Carry while moving (slightly slower?); throw with attack input in facing direction
   - Thrown objects have deterministic collision/damage (fixed damage, fixed knockback)
   - Objects settle or break safely after throw (no physics explosions)
   - Clear visual indicator when object is grabbable
   - Works with remapped inputs

8. Create scenes/levels/marcus_combat_arena.tscn:
   - Walls and clear boundaries
   - 3–5 scavengers with clear spawn points
   - Multiple throwable objects placed strategically
   - Encounter start/end state (enemies spawn when player enters, arena locks until clear)
   - Simple score display (time, damage taken, enemies defeated, environmental throws)
   - Clear visual readability: no clutter, good lighting

9. Add hit feedback:
   - Hit flash on enemy (white flash for 0.1s)
   - Short camera shake (with reduce option in settings)
   - Particles or label feedback (damage numbers optional)
   - Audio placeholders for hits, dodges, blocks

10. Add accessibility:
    - Reduced camera shake toggle
    - Clear visual telegraphs for all attacks
    - No audio-only information (visual backup for all audio cues)
    - Input remapping fully honored

ACCEPTANCE CRITERIA
- Marcus can complete arena combat with light/heavy attacks, three-hit combo, dodge, block, grabs, and throws
- Enemy telegraphs are readable; AI is deterministic and learnable
- Hitbox system does not cause repeated unintended damage
- Performance is stable at 60 FPS with all effects active
- Reduced camera shake option works
- All inputs work with remapped bindings
- Code is modular, commented, and maintainable

DO NOT
- Add random damage, crits, or behavior
- Create enemies with unavoidable attacks
- Use complex physics that might cause softlocks
- Add final art (placeholder/stylised only)

Finish by reporting:
- Changed files with brief descriptions
- Test results (combat tested, accessibility verified, performance checked)
- Known limitations (be honest)
- Propose this commit message exactly:
Phase 3: Marcus combat fundamentals complete
