You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect character, navigation, combat, narrative, HUD, and GameManager systems. Phases 0–7 are complete.

**AWARD-LEVEL QUALITY STANDARD**: This joint mission establishes the emotional core of Elena and Marcus's relationship. Dialogue must feel authentic, Elena must never be a liability, and the escort design must respect player intelligence.

GOAL
Build the first Elena–Marcus mission using a deliberately simple, reliable escort design. The player controls Marcus; Elena follows only along safe authored routes and operates protected terminals.

STORY CONTEXT
Marcus breaches the shelter and finds Elena. She distrusts him. He warns that Helix has changed orders. They agree to escape temporarily.

CHARACTER DEPTH REQUIREMENTS
- **Elena**: Restrained but deep. Pain in what she doesn't say. Fidgets with prototype when anxious. Voice: Eastern European accent, 28-35.
- **Marcus**: Gravelly, tired, but warm when he drops guard. Protective without being patronizing. Scans perimeter constantly. Voice: North American, 35-45.
- **Dialogue subtext**: Elena's guilt over Iris vs. Marcus's failure with Amara. Both lost people. Both chose differently.

DELIVERABLES
1. Create scenes/levels/joint_mission_1.tscn with 2–3 combat arenas, protected terminal spaces, safe waiting points, gates, and an exterior toxic-rain exit. Design for 8-12 minute playthrough.
2. Create a reliable ElenaFollower controller. Use authored Path2D/waypoints or NavigationAgent2D only if it is stable. Elena must never wander, run through combat, or get permanently stuck. Prefer deterministic waypoint progression over dynamic pathfinding. Include idle animations (fidgets with prototype, looks around nervously).
3. Player controls Marcus only. Elena waits at named safe points until an explicit mission event allows the next route segment.
4. Enemies target Marcus by default. Design arenas so Elena is not accidentally exposed. Implement an exceptional proximity warning and Elena Safety decrement only if an enemy crosses a defined protected boundary or scripted threat reaches her; prevent multiple decrements from a single event.
5. Create terminal/gate events: Marcus clears arena; Elena moves to protected terminal; terminal opens gate; both progress. Keep actions visible and deterministic.
6. Add HUD indicator for Elena Safety and contextual warning. Explain the value at first display.
7. Add skippable dialogue sequence for first contact and several short exchanges. Do not pause combat automatically for dialogue. Include:
   - **First meeting**: Marcus: "I'm not here to hurt you." Elena: "You're Helix. That's exactly what you're here for." Marcus (quiet): "Yeah. That's what I was trained to be."
   - **Mid-mission**: Elena: "Why protect me?" Marcus: "Because someone has to. And I'm done following orders that get people killed."
   - **Exit sequence**: Elena: "Temporary truce. We escape together, then decide next steps." Marcus: "As long as it goes somewhere Helix cannot reach immediately, we are fine."
8. Build toxic rain exit sequence with stylised particles, audio placeholder, fade, Act I completion flag, save checkpoint, and transition.
9. Add 2-3 memory fragments of Elena (childhood with Iris, university, the choice) hidden in safe areas. Collecting triggers short flashback (3-5s still image with voiceover).
10. Implement dynamic dialogue reactivity: If player rescued civilians in Phase 6 (shelter), Elena references them: "Those people in the shelter... they reminded me of Iris." If not: "I couldn't save them. Just like I couldn't save her."

ACCEPTANCE CRITERIA
- Elena never gets stuck in normal gameplay and cannot be needlessly attacked by spawned enemies.
- Every arena/gate state can be replayed after death or save/load.
- Elena Safety changes only through clearly communicated defined events.
- Dialogue feels authentic, not expository.
- Memory fragments are optional but rewarding.
- Dynamic dialogue references prior choices accurately.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 8: first joint mission complete with character depth and dynamic dialogue
