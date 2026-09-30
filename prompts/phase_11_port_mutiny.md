You are continuing FINAL THAW in Godot 4.x. This game targets award-worthy quality at The Game Awards, D.I.C.E. Awards, BAFTA Games Awards, and Game Developers Choice Awards.

Read CLAUDE.md and reuse combat, arena, civilian aid, and save systems. Phases 0–10 are complete with professional-grade foundation.

GOAL
Build Marcus's port combat chapter, introduce shield units, provide optional civilian assistance, and create a deterministic second mini-boss with a crane interaction. Design with award-quality enemy variety, arena design, boss mechanics, and accessibility.

STORY CONTEXT
Evacuees, smugglers, and Helix forces struggle over ships that are not allowed to leave. Marcus clears a route to the mountain transit hub.

QUALITY STANDARDS
- Shield mechanics understandable on first introduction
- Boss beatable through basic combat even if crane is unused (crane materially helps but not required)
- Rescue counter cannot be farmed or duplicated through reloads
- All combat remains deterministic and stable on retry
- Accessibility: clear telegraphs, no audio-only information, input remapping

DELIVERABLES

1. Create scenes/levels/port_level.tscn with:
   - Docks, containers, cranes, storm sea, fuel canisters
   - Connected arenas with clear traversal paths
   - Optional rescue locations (clearly marked, visible)
   - Environmental storytelling: abandoned cargo, makeshift barricades, storm damage
   - Good lighting and readability

2. Create enemy_shield.tscn (scripts/enemies/enemy_shield.gd):
   - Clear frontal damage immunity/reduction (e.g., 80% reduction from front, 0% from back/flank)
   - Slow movement (slower than scavenger/enforcer)
   - Shield-bash telegraph (1.5s windup, clear animation/audio)
   - Readable counterplay: flank to attack unprotected side, grab/bypass, or environment stun
   - Deterministic AI: no randomness
   - Visible health bar
   - Modular and reusable

3. Create three fixed combat arenas (designed deliberately):
   - Arena 1: Scavengers (3) + one shield; teaches shield mechanics and flank weakness
   - Arena 2: Enforcers (2) + one shield + two scavengers; teaches positioning and priority targeting
   - Arena 3: Mixed types (2 scavengers, 1 enforcer, 2 shields, 1 marksman); requires all learned skills
   - All spawns fixed and learnable; no randomness
   - Clear cover and environmental objects

4. Add at least two optional civilian rescue tasks:
   - May require breakable barriers or clearing small threat
   - Must be safe, visible, optional, and attainable
   - Increment Civilian Aid once only (no farming through reloads)
   - Persistent after save/load (use flags in GameManager)
   - Clear visual indicator when rescue is complete

5. Create boss_transport_captain.tscn (scripts/bosses/boss_transport_captain.gd) with fixed boss state machine:
   - Ground slam: telegraphed (1.5s windup), avoidable shockwave (clear visual indicator), fixed damage
   - Cargo throw: telegraphed (1s windup), fixed trajectory, dodgeable
   - Reinforcement call: deterministic (calls 1–2 scavengers at fixed intervals), not random
   - Deterministic AI: no randomness in move selection
   - Visible health bar and clear phase transitions

6. Add crane interaction in boss arena:
   - Marcus can operate crane during clearly available window (e.g., boss stunned, or after phase transition)
   - Drops cargo on boss: deals major fixed damage (e.g., 30–40% of boss health) and stuns for 3–5s
   - Optional: boss is beatable without using crane, but crane materially helps
   - Never soft-locks fight (crane always available when needed)
   - Clear visual/audio feedback for crane operation and impact

7. Add chapter messages:
   - Start: Marcus sees port conflict, evacuees trapped, must reach mountain
   - Mid: brief updates between arenas (2–3 sentences)
   - Boss defeat: Marcus clears route, sets port_complete flag in GameManager
   - Checkpointing after each arena and boss
   - All messages skippable and non-blocking

8. Add accessibility:
   - Clear visual telegraphs for all attacks (especially shield bash and boss moves)
   - No audio-only information
   - Input remapping fully honored
   - Reduced camera shake option
   - Colorblind-safe shield immunity indicator (use brightness/shape, not just color)

ACCEPTANCE CRITERIA
- Shield mechanics are understandable on first introduction (flank weakness is clear)
- Boss is beatable through basic combat even if crane is unused; crane materially helps but not required
- Rescue counter cannot be farmed or duplicated through reloads (persistent flags)
- All combat remains deterministic and stable on retry
- Performance is stable at 60 FPS
- All inputs work with remapped bindings

DO NOT
- Randomize shield behavior, boss moves, or reinforcement calls
- Make crane required to beat boss (must be optional but helpful)
- Allow farming of Civilian Aid through reloads
- Create unavoidable damage phases

Finish by reporting:
- Changed files with brief descriptions
- Test results (all arenas tested, boss tested, rescues tested, save/load verified, accessibility checked)
- Known limitations (be honest)
- Propose this commit message exactly:
Phase 11: port mutiny combat complete
