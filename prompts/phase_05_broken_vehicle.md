You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect existing UI and GameManager. Phases 0–4 are complete.

GOAL
Create a short, deterministic UI-focused transition minigame in which Marcus repairs an emergency vehicle before a fire front reaches an underpass.

DESIGN
- Target length: 2–5 minutes for a new player.
- The correct solution is fixed and visually deducible.
- A generous fire-front timer creates urgency but does not create a hard game-over. If it expires, the story continues with a small recorded efficiency flag only.

DELIVERABLES
1. Create scenes/minigames/minigame_vehicle.tscn with a legible systems diagram, fire/smoke background, status panel, progress bar, and accessible UI.
2. Implement 5 repair controls, such as valves, fuse links, and fuel switches. Each has 2–4 states. Show visual clues that determine the single valid configuration.
3. Implement click/controller navigation and a Confirm Repair action. Correct configuration succeeds; incorrect confirmation clearly identifies that one or more systems remain incorrect without revealing the entire answer unless accessibility hint mode is enabled.
4. Implement fire timer with documented duration. On expiry, auto-complete the scene safely, set a GameManager flag such as vehicle_repaired_under_pressure, and show alternate text.
5. If solved before expiry, set vehicle_repaired_cleanly. Do not introduce a hidden counter.
6. Add skippable narrative context and transition to a Phase 6 placeholder scene if that scene does not yet exist.
7. Ensure pause handling is explicit and documented.

ACCEPTANCE CRITERIA
- The puzzle is playable using mouse and keyboard/controller navigation.
- Correct solution and timeout outcomes are deterministic and both transition cleanly.
- Save/load cannot corrupt minigame state or trap the player.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 5: broken vehicle minigame complete
