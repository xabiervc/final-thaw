You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and reuse combat, arena, civilian aid, and save systems. Phases 0–10 are complete.

GOAL
Build Marcus's port combat chapter, introduce shield units, provide optional civilian assistance, and create a deterministic second mini-boss with a crane interaction.

STORY CONTEXT
Evacuees, smugglers, and Helix forces struggle over ships that are not allowed to leave. Marcus clears a route to the mountain transit hub.

DELIVERABLES
1. Create scenes/levels/port_level.tscn with docks, containers, cranes, storm sea, fuel canisters, connected arenas, and optional rescue locations.
2. Create enemy_shield.tscn. It has clear frontal damage immunity/reduction, slow movement, shield-bash telegraph, and readable counterplay: flank, grab/bypass, or environment stun.
3. Create three fixed combat arenas that combine all four existing enemy types in deliberate, learnable placements.
4. Add at least two optional civilian rescue tasks. They may require breakable barriers or clearing a small threat. They must be safe, visible, optional, increment Civilian Aid once, and persist.
5. Create boss_transport_captain.tscn. Required moves: ground slam with avoidable shockwave, telegraphed cargo throw, deterministic reinforcement call. Use a fixed boss state machine.
6. Add a crane interaction in the boss arena. Marcus can operate it during a clearly available window to drop cargo, deal major fixed damage, and stun the boss. It must be optional and never soft-lock the fight.
7. Add chapter messages, checkpointing, and port_complete flag.

ACCEPTANCE CRITERIA
- Shield mechanics are understandable on first introduction.
- Boss is beatable through basic combat even if crane is unused, while crane materially helps.
- Rescue counter cannot be farmed or duplicated through reloads.
- All combat remains deterministic and stable on retry.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 11: port mutiny combat complete
