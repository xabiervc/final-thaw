You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect existing minigame/UI architecture. Phases 0–8 are complete.

GOAL
Create the Calibrate Aster transition minigame: Elena reconnects a fixed circuit map while Marcus drives through a storm.

STORY CONTEXT
The Aster Protocol identifies the Final Thaw Station, a mountain atmospheric relay. Helix is preparing a limited intervention that protects only privileged zones.

DELIVERABLES
1. Create scenes/minigames/minigame_aster.tscn with a legible UI circuit board, storm/vehicle background, visual state feedback, and accessibility-friendly contrast.
2. Implement 6 rotatable circuit tiles/nodes. Each has fixed rotations and one fixed solvable final circuit path from input to output. Do not randomize starting state or solution.
3. Nodes must work with click, keyboard, and controller focus.
4. Show powered segments immediately and unpowered/broken segments clearly. When path is complete, enable Confirm Calibration.
5. Add optional hint mode in settings or a clearly labeled hint control that highlights one incorrect tile without changing the solution.
6. On completion: set aster_calibrated and final_thaw_station_revealed flags, save, deliver narrative reveal, and transition toward Phase 10 placeholder/level.
7. Do not use a countdown timer. The storm is atmosphere only.

ACCEPTANCE CRITERIA
- Puzzle is solvable from visual information alone and works with all supported inputs.
- State persists safely if saved/reloaded where reasonable; at minimum, restarting is safe and no duplicate story reward occurs.
- Narrative flags save correctly.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 9: calibrate Aster minigame complete
