You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and reuse existing combat and ArenaController systems. Phases 0–6 are complete.

GOAL
Build Marcus's shelter-perimeter combat chapter: marksmen, readable cover/line-of-sight gameplay, and the first deterministic mini-boss.

STORY CONTEXT
Helix has blockaded the shelter. Marcus fights through to reach Elena and learns orders now say to terminate her if capture fails.

DELIVERABLES
1. Create scenes/levels/perimeter_level.tscn with 3 arenas plus a boss arena. Use barriers, sandbags, wrecks, floodlights, emergency beacons, and a visible shelter entrance.
2. Create enemy_marksman.tscn using a deterministic state machine: position, acquire line of sight, visible aim/wind-up, fixed projectile, recovery/reposition. No random accuracy.
3. Implement reusable line-of-sight and cover logic. Solid cover must reliably block projectiles.
4. Build encounters: Arena 1 has scavengers plus one marksman; Arena 2 has enforcers plus two marksmen; Arena 3 mixes types requiring movement between cover.
5. Build boss_riot_commander.tscn. Required deterministic moves: shield bash/charge, frontal shield block, tear-gas area denial. His rear is a visible weak point. Telegraph all attacks, provide safe avoidance, and add short fixed enraged behavior after a health threshold.
6. Boss arena must include meaningful solid/destructible cover and throwable objects. It must have checkpoint/retry support.
7. Add narrative messaging from start through boss defeat. Set perimeter_complete and termination_order_discovered flags in GameManager.

ACCEPTANCE CRITERIA
- Marksman line-of-sight and projectiles are reliable; cover prevents damage when physically between them.
- Boss can be beaten consistently by learning patterns and flanking; no random unavoidable damage.
- Arena progression and checkpointing work after save/load.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 7: militia encirclement combat complete
