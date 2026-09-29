You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect character, navigation, combat, narrative, HUD, and GameManager systems. Phases 0–7 are complete.

GOAL
Build the first Elena–Marcus mission using a deliberately simple, reliable escort design. The player controls Marcus; Elena follows only along safe authored routes and operates protected terminals.

STORY CONTEXT
Marcus breaches the shelter and finds Elena. She distrusts him. He warns that Helix has changed orders. They agree to escape temporarily.

DELIVERABLES
1. Create scenes/levels/joint_mission_1.tscn with 2–3 combat arenas, protected terminal spaces, safe waiting points, gates, and an exterior toxic-rain exit.
2. Create a reliable ElenaFollower controller. Use authored Path2D/waypoints or NavigationAgent2D only if it is stable. Elena must never wander, run through combat, or get permanently stuck. Prefer deterministic waypoint progression over dynamic pathfinding.
3. Player controls Marcus only. Elena waits at named safe points until an explicit mission event allows the next route segment.
4. Enemies target Marcus by default. Design arenas so Elena is not accidentally exposed. Implement an exceptional proximity warning and Elena Safety decrement only if an enemy crosses a defined protected boundary or scripted threat reaches her; prevent multiple decrements from a single event.
5. Create terminal/gate events: Marcus clears arena; Elena moves to protected terminal; terminal opens gate; both progress. Keep actions visible and deterministic.
6. Add HUD indicator for Elena Safety and contextual warning. Explain the value at first display.
7. Add skippable dialogue sequence for first contact and several short exchanges. Do not pause combat automatically for dialogue.
8. Build toxic rain exit sequence with stylised particles, audio placeholder, fade, Act I completion flag, save checkpoint, and transition.

ACCEPTANCE CRITERIA
- Elena never gets stuck in normal gameplay and cannot be needlessly attacked by spawned enemies.
- Every arena/gate state can be replayed after death or save/load.
- Elena Safety changes only through clearly communicated defined events.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 8: first joint mission complete
