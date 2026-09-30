You are continuing FINAL THAW in Godot 4.x. This game targets award-worthy quality at The Game Awards, D.I.C.E. Awards, BAFTA Games Awards, and Game Developers Choice Awards.

Read CLAUDE.md and inspect/reuse existing combat components. Phases 0–3 are complete with professional-grade foundation.

GOAL
Build Marcus's Act I highway combat chapter: a readable linear route through a collapsed elevated highway under wildfire haze. Design with award-quality pacing, enemy variety, environmental storytelling, and accessibility.

STORY CONTEXT
Helix patrols and displaced groups fight over supply convoys. Marcus clears a route and finds proof that his former unit has been reassigned to capture Elena.

QUALITY STANDARDS
- Every arena must be completable without frustration
- Enemy patterns must be learnable within 2–3 attempts
- Environmental storytelling shows collapse, conflict, desperation
- Performance: 60 FPS stable even with multiple enemies and effects
- Accessibility: clear visual telegraphs, no audio-only information, input remapping

DELIVERABLES

1. Create scenes/levels/highway_level.tscn with:
   - 4 compact arenas connected by short traversal sections (30–60 seconds each)
   - Stylised placeholder art: cracked asphalt, guardrails, abandoned vehicles, debris, orange haze
   - Clear path forward; no confusing layouts
   - Environmental storytelling: burnt cars, abandoned supplies, makeshift barricades
   - Good lighting and readability

2. Create enemy_enforcer.tscn (scripts/enemies/enemy_enforcer.gd) by reusing combat components:
   - High health (2–3x scavenger), slower movement, predictable block/counter timing
   - Clear flank/environmental weakness (e.g., stunned by thrown objects, vulnerable from behind)
   - Telegraphed attacks: shield bash (1.5s windup), overhead strike (1s windup)
   - Deterministic AI: no randomness
   - Visible health bar
   - Modular and reusable

3. Create reusable ArenaController (scripts/components/arena_controller.gd):
   - Fixed enemy spawn lists/waves (no randomness)
   - Locked exits while active (clear visual indicator: gate, barrier, or UI message)
   - Clear completion condition (all enemies defeated)
   - Checkpoint after successful clear with visible confirmation
   - No random spawns; all waves are authored and learnable
   - Well-commented and configurable

4. Arena progression (design each arena deliberately):
   - Arena 1: Introduces scavengers (3–4 enemies); teaches basic combat
   - Arena 2: Introduces one enforcer + 2 scavengers; teaches flank/environmental weakness
   - Arena 3: Mixes scavengers/enforcers (2 enforcers + 3 scavengers) with throwable objects; teaches environmental combat
   - Arena 4: Combines all prior mechanics (2 enforcers + 4 scavengers + objects); final test before narrative

5. Create breakable barricades/barriers (scripts/components/destructible.gd):
   - Heavy attacks or throws break them (fixed health, fixed damage values)
   - At least one reveals clear optional shortcut (not required for main path)
   - No critical path may become permanently blocked
   - Clear visual feedback when damaged and destroyed
   - Works with remapped inputs

6. Expand throwable environment:
   - Pipes, signs, car parts, and one clearly telegraphed fuel canister with area effect
   - Fuel canister: telegraphed explosion (1s warning), fixed damage radius, visual/audio feedback
   - Keep outcomes deterministic: no physics explosions or random damage
   - Clear visual indicators for all throwables

7. Add route-clearing score summary (post-chapter UI):
   - Time taken
   - Damage taken
   - Environmental throws landed
   - Clean-clear bonus (no damage taken in an arena)
   - Feedback only, not a story gate or achievement
   - Clear, readable UI

8. Add skippable narrative messages:
   - Chapter start: context about highway, Helix patrols, Marcus's mission
   - Between sections: brief updates (2–3 sentences max)
   - Ending: evidence story flag (Marcus discovers reassignment orders)
   - Phase 4 completion checkpoint with visible confirmation
   - All messages skippable and non-blocking

9. Add accessibility:
   - Clear visual telegraphs for all enemy attacks
   - No audio-only information
   - Input remapping fully honored
   - Reduced camera shake option
   - Colorblind-safe indicators

ACCEPTANCE CRITERIA
- Every arena can be cleared in a fresh run and after loading a checkpoint
- Enforcer counter/block pattern is clear, consistent, and learnable
- Waves, doors, barriers, optional path, scoring, and story flag work with no softlocks
- Performance is stable at 60 FPS
- All inputs work with remapped bindings
- Environmental storytelling is clear without exposition

DO NOT
- Add random enemy spawns or behavior
- Create arenas that require pixel-perfect movement or timing
- Block critical path with breakable objects
- Write lengthy narrative text

Finish by reporting:
- Changed files with brief descriptions
- Test results (all arenas tested, save/load verified, accessibility checked)
- Known limitations (be honest)
- Propose this commit message exactly:
Phase 4: highway riots combat complete
