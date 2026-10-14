# FINAL THAW — Core Gameplay Loop (Current Prototype)

**Status:** working loop for the motion/chase prototype and proposed opening. This replaces the legacy puzzle-room/combat-arena loop for prototype work only.  
**Implementation detail:** `docs/design/MOTION_CHASE_PROTOTYPE.md`.

## Core loop

`Observe → Infer → Choose → Move → Trigger a response → Adapt`

The player reads the space, uses the scanner when its information is worth the pause, chooses a route or interaction, executes a physical challenge, and responds to the resulting environmental or enemy state. Thought and movement should reinforce each other rather than sit in separate unrelated room types.

## Mission 1 — Investigation/system puzzle (proposed; not implemented)

**Goal:** reconstruct what happened to an Aster test and recover meaningful evidence.

1. Observe the room and its operating state.
2. Scan traces, inspect machine states and compare environmental clues.
3. Form a hypothesis about a system configuration.
4. Change one or more components.
5. Read immediate feedback and revise if needed.
6. Resolve the system, reveal evidence and trigger containment.

Quality requirements: clear goal; at least two clues that support inference; feedback distinguishing partial success from error; optional hints that do not give away the answer; a physical result that changes the world. No fixed switch count, room duration or decision count is approved yet.

## Mission 2 — Traversal, stealth and escape (prototype exists)

1. Read the space and identify a safe landing or cover point.
2. Choose walking, running, crouching, jumping or an authored climb.
3. Manage noise and visibility as the recovery unit patrols or investigates.
4. If detected, break line of sight, hide or reach a route the unit cannot follow.
5. Use the scanner when its limited reveal window is worth the time.
6. Reach a checkpoint/exit; if caught or falling, learn why and retry quickly.

### Implemented in `scripts/prototypes/motion_chase_prototype.gd`

- Third-person camera orbit and occluder fade.
- Walk/run/crouch, jump buffer, coyote time, gravity and landing.
- Three authored gaps, low tunnel/duct and defined climb to a catwalk.
- Noise radii for stillness, crouch, walking and running.
- Recovery-unit states: patrol, investigate, alert, chase, search and return.
- Vision/line-of-sight checks, last-known-position pursuit, scan reveal and checkpoint recovery.
- HUD indicators for scanner, noise, unit state, catches and elapsed time.

These are code capabilities, not proof of good feel. The prototype spec says v2's automated test has not yet been run. Run it and record the result before calling the build verified.

### Not implemented

The Aster investigation puzzle, evidence pickup, narrative transition, dedicated crouch/climb animations, general-purpose navigation mesh, campaign integration, localization of prototype strings, Web profiling and full controller validation.

## Design rules

- Scanner is a trade-off: charge-up, short reveal and cooldown; test whether this creates tension rather than busywork.
- Faster movement is louder; quiet movement is slower.
- Threat state uses symbols and audio, not colour alone.
- After losing sight, the unit searches the last known position instead of tracking Elena through walls.
- Alternative routes need genuinely different risk profiles.
- Failure is local and retryable.
- Solving the system causes containment; the chase is a consequence of discovery.

## Evidence to collect

Record time to first successful jump/crouch/climb; falls and catches; whether players can explain detection; whether they discover alternative routes; scanner use and perceived forced waiting; time to retry; camera/collision frustration; motion discomfort; and puzzle comprehension once added. Do not invent success percentages before testing.

## Legacy status

The former Elena puzzle-room / Marcus combat-arena loop in `docs/core_gameplay_loop.md` is historical reference while the redesign is evaluated. Its durations, decision-density targets and Marcus switching requirements are not acceptance criteria for this prototype.
