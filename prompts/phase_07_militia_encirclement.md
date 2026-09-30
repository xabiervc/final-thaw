You are continuing FINAL THAW in Godot 4.x. This game targets award-worthy quality at The Game Awards, D.I.C.E. Awards, BAFTA Games Awards, and Game Developers Choice Awards.

Read CLAUDE.md and reuse existing combat and ArenaController systems. Phases 0–6 are complete with professional-grade foundation.

GOAL
Build Marcus's shelter-perimeter combat chapter: marksmen, readable cover/line-of-sight gameplay, and the first deterministic mini-boss. Design with award-quality enemy variety, arena design, and boss mechanics.

STORY CONTEXT
Helix has blockaded the shelter. Marcus fights through to reach Elena and learns orders now say to terminate her if capture fails.

QUALITY STANDARDS
- Marksman line-of-sight must be reliable and readable
- Cover must work consistently (solid cover blocks projectiles)
- Boss must be beatable through pattern learning, not luck
- No random unavoidable damage
- Accessibility: clear telegraphs, no audio-only information, input remapping

DELIVERABLES

1. Create scenes/levels/perimeter_level.tscn with:
   - 3 arenas plus boss arena connected clearly
   - Barriers, sandbags, wrecks, floodlights, emergency beacons
   - Visible shelter entrance as goal
   - Environmental storytelling: fortified positions, abandoned equipment, signs of struggle
   - Good lighting and readability

2. Create enemy_marksman.tscn (scripts/enemies/enemy_marksman.gd) with deterministic state machine:
   - States: position, acquire line of sight, visible aim/wind-up, fixed projectile, recovery/reposition
   - No random accuracy; every shot is intentional and telegraphed
   - Clear telegraph: laser sight, aim animation, audio cue (1s+ windup)
   - Fixed projectile speed and damage
   - Repositions after shooting (predictable pattern)
   - Visible health bar
   - Modular and reusable

3. Implement reusable line-of-sight and cover logic (scripts/components/cover_system.gd):
   - Solid cover (walls, sandbags, concrete barriers) reliably blocks projectiles
   - Partial cover (fences, debris) may not block fully; clearly indicated
   - Raycast-based detection; well-commented
   - Debug mode to visualize line-of-sight in editor
   - Performant (no excessive raycasts per frame)

4. Build encounters (designed deliberately):
   - Arena 1: Scavengers (3) + one marksman; teaches marksmen and cover importance
   - Arena 2: Enforcers (2) + two marksmen; teaches positioning and priority targeting
   - Arena 3: Mixed types (2 scavengers, 1 enforcer, 2 marksmen); requires movement between cover positions
   - All spawns fixed and learnable; no randomness

5. Build boss_riot_commander.tscn (scripts/bosses/boss_riot_commander.gd) with deterministic moves:
   - Shield bash/charge: telegraphed (1.5s windup), dodgeable, knockback
   - Frontal shield block: reduces damage from front, telegraphed activation
   - Tear-gas area denial: telegraphed AoE (1s warning), damage over time, avoidable
   - Rear is visible weak point (different color/brightness, takes extra damage)
   - Telegraph all attacks clearly with audio/visual cues
   - Provide safe avoidance windows
   - Add short fixed enraged behavior after health threshold (e.g., 50% health: faster attacks for 10s)
   - Deterministic AI; no randomness

6. Boss arena design:
   - Meaningful solid/destructible cover (sandbags, barriers, crates)
   - Throwable objects (canisters, pipes, debris)
   - Clear boss arena boundaries
   - Checkpoint/retry support (no long runback on death)
   - Good lighting and readability

7. Add narrative messaging:
   - Start: Marcus sees shelter, Helix blockade, determination to reach Elena
   - Mid: brief updates between arenas (2–3 sentences)
   - Boss defeat: Marcus learns termination orders, sets perimeter_complete and termination_order_discovered flags in GameManager
   - All messages skippable and non-blocking

8. Add accessibility:
   - Clear visual telegraphs for all attacks (especially boss)
   - No audio-only information
   - Input remapping fully honored
   - Reduced camera shake option
   - Colorblind-safe weak point indicator

ACCEPTANCE CRITERIA
- Marksman line-of-sight and projectiles are reliable; cover prevents damage when physically between
- Boss can be beaten consistently by learning patterns and flanking; no random unavoidable damage
- Arena progression and checkpointing work after save/load
- Performance is stable at 60 FPS
- All inputs work with remapped bindings

DO NOT
- Randomize marksman accuracy or boss behavior
- Create cover that inconsistently blocks projectiles
- Make boss unbeatable without using environmental mechanics (they should help, not required)
- Add unavoidable damage phases

Finish by reporting:
- Changed files with brief descriptions
- Test results (all arenas tested, boss tested, save/load verified, accessibility checked)
- Known limitations (be honest)
- Propose this commit message exactly:
Phase 7: militia encirclement combat complete
