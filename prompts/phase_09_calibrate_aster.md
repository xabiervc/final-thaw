You are continuing FINAL THAW in Godot 4.x. This game targets award-worthy quality at The Game Awards, D.I.C.E. Awards, BAFTA Games Awards, and Game Developers Choice Awards.

Read CLAUDE.md and inspect existing minigame/UI architecture. Phases 0–8 are complete with professional-grade foundation.

GOAL
Create the Calibrate Aster transition minigame: Elena reconnects a fixed circuit map while Marcus drives through a storm. Design with award-quality clarity, feedback, and accessibility.

STORY CONTEXT
The Aster Protocol identifies the Final Thaw Station, a mountain atmospheric relay. Helix is preparing a limited intervention that protects only privileged zones.

QUALITY STANDARDS
- Puzzle must be solvable from visual information alone
- No randomization of starting state or solution
- Clear feedback for powered/unpowered segments
- Accessibility: works with keyboard, controller, mouse; hint mode available; colorblind-safe

DELIVERABLES

1. Create scenes/minigames/minigame_aster.tscn with:
   - Legible UI circuit board (clear nodes, connections, rotation indicators)
   - Storm/vehicle background (stylised, not distracting)
   - Visual state feedback (powered segments glow, unpowered are dim)
   - Accessibility-friendly contrast (high contrast, large UI elements)
   - Clean, professional layout

2. Implement 6 rotatable circuit tiles/nodes (scripts/components/circuit_node.gd):
   - Each has fixed rotations (e.g., 4 directions: 0°, 90°, 180°, 270°)
   - One fixed solvable final circuit path from input to output
   - Do NOT randomize starting state or solution
   - Clear visual indicator of current rotation (arrow, line, or shape)
   - Smooth rotation animation (0.2s lerp)

3. Input support:
   - Click/tap to rotate
   - Keyboard navigation (Tab or arrows to select, Enter/Space to rotate)
   - Controller support (D-pad/arrows to select, A/Cross to rotate)
   - Clear focus indicators (highlight, border, or color change)
   - All inputs remappable and honored

4. Visual feedback:
   - Show powered segments immediately (glow, brightness, or particle effect)
   - Show unpowered/broken segments clearly (dim, gray, or different color)
   - When path is complete: enable Confirm Calibration button with clear feedback
   - Clear audio/visual feedback for rotation and power state changes

5. Add optional hint mode:
   - Settings toggle OR clearly labeled hint button
   - Highlights one incorrect tile without changing solution
   - Does NOT solve puzzle for player
   - Clear visual indicator (e.g., red outline or arrow)
   - Works with all input methods

6. On completion:
   - Set aster_calibrated and final_thaw_station_revealed flags in GameManager
   - Save game with visible confirmation
   - Deliver narrative reveal (2–4 sentences: Aster identifies Final Thaw Station, Helix preparing limited intervention)
   - Transition toward Phase 10 placeholder/level
   - Clear audio/visual success feedback

7. Do NOT use countdown timer:
   - Storm is atmosphere only (background animation, audio)
   - No time pressure; player can think at own pace
   - Pause functionality works

8. Add accessibility:
   - No color-only indicators (use brightness, shape, or labels)
   - Full keyboard/controller support
   - Text size adjustable (via future settings)
   - Hint mode available and clearly labeled
   - Clear audio/visual feedback for all states

ACCEPTANCE CRITERIA
- Puzzle is solvable from visual information alone
- Works with mouse, keyboard, and controller inputs
- State persists safely if saved/reloaded (or restarting is safe with no duplicate story reward)
- Narrative flags save correctly in GameManager
- Performance is stable; no stutter or lag
- Hint mode works without spoiling entire puzzle

DO NOT
- Randomize puzzle state or solution
- Add time pressure or countdown timer
- Use color-only indicators
- Make puzzle overly complex (6 nodes is max)

Finish by reporting:
- Changed files with brief descriptions
- Test results (puzzle tested with all inputs, save/load verified, accessibility checked)
- Known limitations (be honest)
- Propose this commit message exactly:
Phase 9: calibrate Aster minigame complete
