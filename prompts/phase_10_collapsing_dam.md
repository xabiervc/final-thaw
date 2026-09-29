You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and reuse existing environmental puzzle systems. Phases 0–9 are complete.

GOAL
Build Elena's collapsing-dam chapter: a multi-section puzzle level combining readable water behavior, platforms, power routing, valves, cranes, and limited Aster calibration.

STORY CONTEXT
Extreme rainfall is breaking the dam. Elena must cross service interiors, stabilize gates enough to access the mountain route, and preserve the Aster prototype.

DELIVERABLES
1. Create scenes/levels/dam_level.tscn with service walkways, cracked concrete, turbulent water, control panels, pipes, rain, and several sections connected in a clear sequence.
2. Reuse/enhance water system with fixed cycles or state-based behavior. For timing sections, show an understandable cycle indicator and provide adequate windows—no frame-perfect jumps.
3. Create reusable moving-platform component with fixed paths/timing, safe rider behavior, and save/load-safe state.
4. Create a power-routing puzzle that determines which platform/door/crane receives power. Make state clear in world and UI.
5. Add valve and crane interactions. Cranes should move a defined object/bridge rather than use complex physics.
6. Implement Aster calibration ability in a limited, explicit way: three level-specific calibration charges or three named calibration terminals. Use changes must be visible, saved, and never randomly fail.
7. Add telegraphed hazards: falling debris, steam vents, electrical danger. Use fixed patterns/cycles and fair checkpoints.
8. Add narrative sequence, dam-complete checkpoint, and Phase 10 completion state.

ACCEPTANCE CRITERIA
- All sections can be completed in a deterministic route after observing the environment.
- Water, platforms, power, crane, and calibration states survive save/load or reset to an unambiguous checkpoint state.
- Hazards have clear telegraphs and do not produce unavoidable failure.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 10: collapsing dam puzzles complete
