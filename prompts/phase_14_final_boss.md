You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and reuse the combat, switching, hazard, checkpoint, and narrative systems. Phases 0–13 are complete.

GOAL
Build the final boss in the atmospheric control chamber. It must require Elena and Marcus coordination, be fully deterministic, readable, and fair.

BOSS DESIGN
The Helix Retrieval Commander claims the Aster Protocol belongs to Helix. The boss has fixed phases and telegraphed moves: ranged energy blast, temporary shield barrier, reinforcement call, and reactor sabotage attempt.

DELIVERABLES
1. Create scenes/levels/boss_arena.tscn with a clear chamber layout: reactor/prototype, three calibration panels, vents/overload panels, boss center zone, fixed reinforcement spawn areas, and safe movement lanes.
2. Create boss_helix_commander.tscn using a documented deterministic state machine. No random move selection. Use a repeating or health-threshold-based attack order.
3. Create three Elena Aster calibration interactions. Each has visible progress, defined interruption/reset behavior, and a nearby/meaningful protection task for Marcus. Completing each creates a fixed boss vulnerability window.
4. During vulnerability, Marcus can deal standard damage. Outside it, boss damage reduction/invulnerability must be visibly communicated.
5. Implement boss moves: telegraphed dodgeable energy blast; temporary shield barrier; fixed reinforcement call using existing enemies; reactor sabotage attempt with clear warning and counterplay.
6. Final phase: Elena maintains reactor balance through simple repeated interaction/monitoring while Marcus stops boss pressure. Keep inputs manageable.
7. Add optional environmental actions such as venting steam or overload stun. Each must have visible availability, fixed effect, cooldown/limited charge, and never be mandatory.
8. Add boss checkpoint policy: retries resume at a documented fair checkpoint.
9. Add dialogue and transition to epilogue after victory.

ACCEPTANCE CRITERIA
- Boss can be consistently defeated through learned patterns without random luck.
- All attacks are telegraphed and avoidable.
- Calibration/switching design requires both characters without creating input confusion.
- Retry, save/load, and victory transition are stable.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 14: final boss battle complete
