You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and reuse puzzle, interaction, HUD, narrative, and save systems. Phases 0–5 are complete.

GOAL
Build Elena's flooded underground shelter chapter, with deterministic water/pump/valve puzzles and optional civilian rescue objectives.

STORY CONTEXT
Survivors are trapped beneath a flooded shelter. Elena can prioritize the main route or spend time solving optional rescue puzzles, increasing visible Civilian Aid.

DELIVERABLES
1. Create scenes/levels/shelter_level.tscn containing several compact rooms/corridors with stylised wet concrete, pipes, water, emergency lighting, and clearly readable paths.
2. Build reusable WaterZone/WaterController systems. Water state changes must be fixed and serializable. Use either periodic, clearly signaled fixed cycles, or state-based water changes controlled by pumps/valves. Do not combine them confusingly.
3. Build reusable pump and valve components. Pumps require power/repair where appropriate. Valves visibly redirect water; every effect should be explained in the environment or UI.
4. Build powered-door and linked-sequence puzzle support. Incorrect sequences reset only the local puzzle and show useful feedback.
5. Include at least one main-route puzzle using pump + valve + powered door and at least two optional civilian rescue puzzles. Each rescue must be clearly marked, optional, attainable, persistent after save/load, and increment Civilian Aid once only.
6. Add one limited-oxygen traversal section. Use generous duration, visible timer, nearby reset checkpoints, and a deterministic reset on timeout. Do not reduce consequence counters merely for normal retry.
7. Add entry/exit and rescue narrative messages. End with a checkpoint and narrative transition noting Marcus is approaching the perimeter.

ACCEPTANCE CRITERIA
- Main route is always completable without optional rescues.
- Water, pump, valve, power, doors, oxygen, saves, and Civilian Aid counter behave predictably.
- No water state makes a critical path permanently impossible.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 6: flooded shelter puzzles complete
