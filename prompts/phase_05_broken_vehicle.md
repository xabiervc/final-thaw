You are continuing FINAL THAW in Godot 4.x. This game targets award-worthy quality at The Game Awards, D.I.C.E. Awards, BAFTA Games Awards, and Game Developers Choice Awards.

Read CLAUDE.md and inspect existing UI and GameManager. Phases 0–4 are complete with professional-grade foundation.

GOAL
Create a short, deterministic UI-focused transition minigame in which Marcus repairs an emergency vehicle before a fire front reaches an underpass. Design with award-quality clarity, pacing, and accessibility.

DESIGN PRINCIPLES
- Target length: 2–5 minutes for a new player
- Correct solution is fixed and visually deducible
- Generous fire-front timer creates urgency without hard game-over
- Accessibility: no color-only indicators, full keyboard/controller support, clear feedback

DELIVERABLES

1. Create scenes/minigames/minigame_vehicle.tscn with:
   - Legible systems diagram (valves, fuses, fuel lines clearly labeled)
   - Fire/smoke background (stylised, not photorealistic)
   - Status panel showing progress and system states
   - Progress bar visible at all times
   - Accessible UI: high contrast, large text, clear focus indicators
   - Clean, professional layout

2. Implement 5 repair controls:
   - Valves (2–4 positions each), fuse links (on/off), fuel switches (open/closed)
   - Each has 2–4 states; not overly complex
   - Visual clues determine single valid configuration (e.g., color-matched pipes, labeled diagrams, flow arrows)
   - All controls work with mouse, keyboard, and controller
   - Clear focus navigation (Tab or D-pad)

3. Implement click/controller navigation and Confirm Repair action:
   - Correct configuration: success message, transition to next phase
   - Incorrect confirmation: clearly identifies that one or more systems remain incorrect (e.g., "Fuel line 2 not aligned" or "Fuse 3 still disconnected")
   - Does NOT reveal entire answer unless accessibility hint mode is enabled
   - Clear audio/visual feedback for success/failure

4. Implement fire timer with documented duration (e.g., 120 seconds):
   - Visible countdown bar or timer
   - On expiry: auto-complete scene safely, set GameManager flag (vehicle_repaired_under_pressure), show alternate text
   - No hard game-over; story continues with small efficiency flag only
   - If solved before expiry: set vehicle_repaired_cleanly flag
   - No hidden counters or gotchas

5. Add skippable narrative context:
   - Intro: Marcus finds vehicle, fire approaching, must repair quickly
   - Success/failure: brief outcome text (2–3 sentences)
   - Transition to Phase 6 placeholder scene (or next actual level if exists)
   - All text skippable and non-blocking

6. Ensure pause handling is explicit and documented:
   - Pausing minigame is allowed
   - Timer continues or pauses? Document clearly in comments
   - Recommended: timer pauses to avoid frustration

7. Add accessibility:
   - No color-only indicators (use labels, shapes, brightness)
   - Full keyboard/controller support
   - Text size adjustable (via future settings)
   - Hint mode available (clearly labeled button)
   - Clear audio/visual feedback for all states

ACCEPTANCE CRITERIA
- Puzzle is playable using mouse, keyboard, and controller navigation
- Correct solution and timeout outcomes are deterministic and both transition cleanly
- Save/load cannot corrupt minigame state or trap player (if save applicable)
- Visual clues are sufficient to deduce solution without guessing
- Hint mode works without spoiling entire puzzle
- Performance is stable; no stutter or lag

DO NOT
- Randomize puzzle state or solution
- Create time pressure that feels unfair or frustrating
- Use color-only indicators
- Make puzzle overly complex (5 controls is max)

Finish by reporting:
- Changed files with brief descriptions
- Test results (puzzle tested, timeout tested, accessibility verified)
- Known limitations (be honest)
- Propose this commit message exactly:
Phase 5: broken vehicle minigame complete
