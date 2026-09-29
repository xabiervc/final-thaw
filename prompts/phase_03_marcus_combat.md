You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect existing systems before editing. Phases 0–2 are complete.

GOAL
Implement Marcus Reyes and a compact, deterministic isometric beat-'em-up combat foundation suitable for later levels.

CONTEXT
Marcus is a former police officer. His gameplay is direct action, protection, crowd control, cover, grabs, and environmental use. Combat must feel readable and weighty, but stay technically modest.

DELIVERABLES
1. Create scenes/characters/marcus_character.tscn with CharacterBody2D, placeholder sprite, ground shadow, collision, state machine hooks, health, and HUD integration.
2. Implement movement with the same control standard as Elena plus sprint, dodge, and block. Dodge has fixed invincibility frames; expose timings in constants/resources. Block reduces a fixed percentage of frontal damage.
3. Implement combat state machine: idle, move, light_attack, heavy_attack, combo, dodge, block, hitstun, grab, throw, defeated.
4. Implement a fixed three-hit combo. Use explicit attack data (startup, active, recovery, damage, knockback) and deterministic input buffering; no random critical hits.
5. Build reusable Hitbox/Hurtbox and Health components. They must avoid double hits from a single attack and be easy to debug.
6. Create enemy_scavenger.tscn: deterministic AI state machine (idle, approach, windup, strike, recovery, hitstun, defeated). It attacks on predictable range/timing and has a visible health bar and telegraph.
7. Create a grab/throwable-object system for crates/barrels. Marcus can grab eligible object, carry it, and throw it in facing direction. Thrown objects have deterministic collision/damage and then settle or break safely.
8. Create scenes/levels/marcus_combat_arena.tscn with walls, 3–5 scavengers, throwable objects, encounter start/end state, and simple score display.
9. Add basic placeholder hit feedback: hit flash, short camera shake, particles or label feedback. Include an option/flag to reduce camera shake.

ACCEPTANCE CRITERIA
- Marcus can complete arena combat with light/heavy attacks, combo, dodge, block, grabs, and throws.
- Enemy telegraphs are readable and AI is deterministic.
- Hitbox system does not cause repeated unintended damage.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 3: Marcus combat fundamentals complete
