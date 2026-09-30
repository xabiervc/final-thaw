You are continuing FINAL THAW in Godot 4.x. This game targets award-worthy quality at The Game Awards, D.I.C.E. Awards, BAFTA Games Awards, and Game Developers Choice Awards.

Read CLAUDE.md and inspect character, navigation, combat, narrative, HUD, and GameManager systems. Phases 0–7 are complete with professional-grade foundation.

GOAL
Build the first Elena–Marcus mission using a deliberately simple, reliable escort design. The player controls Marcus; Elena follows only along safe authored routes and operates protected terminals. Design with award-quality AI behavior, arena design, and narrative pacing.

STORY CONTEXT
Marcus breaches the shelter and finds Elena. She distrusts him. He warns that Helix has changed orders. They agree to escape temporarily.

QUALITY STANDARDS
- Elena must NEVER get stuck, wander into combat, or behave unpredictably
- Every arena must be completable without Elena dying or being attacked
- Elena Safety changes only through clearly communicated, defined events
- Accessibility: clear visual indicators, skippable dialogue, input remapping

DELIVERABLES

1. Create scenes/levels/joint_mission_1.tscn with:
   - 2–3 combat arenas connected by safe traversal sections
   - Protected terminal spaces (Elena operates safely while Marcus defends)
   - Safe waiting points (Elena waits clearly, not hidden or wandering)
   - Gates/doors that open after terminal interaction
   - Exterior toxic-rain exit sequence (stylised particles, audio, fade)
   - Environmental storytelling: shelter interior, damaged infrastructure, escape route
   - Good lighting and readability

2. Create reliable ElenaFollower controller (scripts/characters/elena_follower.gd):
   - Use authored Path2D/waypoints OR NavigationAgent2D ONLY if stable and tested
   - Elena must NEVER wander, run through combat, or get permanently stuck
   - Prefer deterministic waypoint progression over dynamic pathfinding
   - Clear state machine: follow, wait, operate_terminal, safe
   - Teleport to next waypoint if stuck (with clear conditions, e.g., 5s unreachable)
   - Well-commented and debuggable

3. Player controls Marcus only:
   - Elena waits at named safe points until explicit mission event allows next route segment
   - Clear UI indicator when Elena is waiting vs moving
   - No player input controls Elena directly in this phase

4. Enemy targeting and Elena Safety:
   - Enemies target Marcus by default (priority targeting)
   - Design arenas so Elena is NOT accidentally exposed (spawn points, barriers)
   - Implement EXCEPTIONAL proximity warning: Elena Safety decrement ONLY if enemy crosses defined protected boundary or scripted threat reaches her
   - Prevent multiple decrements from single event (use flag or cooldown)
   - Clear visual/audio warning before Safety decrement (e.g., "Elena in danger!" with 2s warning)
   - HUD indicator for Elena Safety with contextual warning; explain value at first display

5. Create terminal/gate events:
   - Marcus clears arena (all enemies defeated)
   - Elena moves to protected terminal (clear path, no enemies alive)
   - Terminal opens gate (visible progress, audio/visual feedback)
   - Both progress to next section
   - Keep actions visible and deterministic
   - No softlocks possible

6. Add skippable dialogue sequence:
   - First contact: Elena distrusts Marcus, he warns of Helix orders
   - Several short exchanges during mission (2–3 sentences each)
   - Do NOT pause combat automatically for dialogue
   - All dialogue skippable and non-blocking
   - Clear, readable UI with good contrast

7. Build toxic rain exit sequence:
   - Stylised particles (rain, haze, storm effects)
   - Audio placeholder (rain, wind, thunder)
   - Fade to black or transition
   - Act I completion flag in GameManager
   - Save checkpoint with visible confirmation
   - Transition to next phase (Phase 9 placeholder or actual level)

8. Add accessibility:
   - Clear visual indicators for Elena state (waiting, moving, safe, danger)
   - Skippable dialogue with text size options
   - Input remapping fully honored
   - Reduced motion option for toxic rain effects
   - Clear audio/visual feedback for all events

ACCEPTANCE CRITERIA
- Elena never gets stuck in normal gameplay and cannot be needlessly attacked by spawned enemies
- Every arena/gate state can be replayed after death or save/load
- Elena Safety changes only through clearly communicated defined events (no hidden triggers)
- Dialogue is skippable and non-blocking
- Toxic rain sequence transitions cleanly
- Performance is stable at 60 FPS
- All inputs work with remapped bindings

DO NOT
- Let Elena wander freely or enter combat
- Create arenas where Elena can be accidentally killed
- Change Elena Safety through hidden or random events
- Block progression with bugs or softlocks

Finish by reporting:
- Changed files with brief descriptions
- Test results (all arenas tested, Elena AI tested, save/load verified, accessibility checked)
- Known limitations (be honest)
- Propose this commit message exactly:
Phase 8: first joint mission complete
