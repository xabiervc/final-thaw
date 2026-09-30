You are continuing FINAL THAW in Godot 4.x. This game targets award-worthy quality at The Game Awards, D.I.C.E. Awards, BAFTA Games Awards, and Game Developers Choice Awards.

Read CLAUDE.md and reuse puzzle, interaction, HUD, narrative, and save systems. Phases 0–5 are complete with professional-grade foundation.

GOAL
Build Elena's flooded underground shelter chapter with deterministic water/pump/valve puzzles and optional civilian rescue objectives. Design with award-quality environmental storytelling, readability, and accessibility.

STORY CONTEXT
Survivors are trapped beneath a flooded shelter. Elena can prioritize the main route or spend time solving optional rescue puzzles, increasing visible Civilian Aid.

QUALITY STANDARDS
- Main route always completable without optional rescues
- Water behavior is predictable and readable
- No puzzle requires frame-perfect timing or pixel-perfect movement
- Environmental storytelling shows desperation, improvisation, hope
- Accessibility: colorblind-safe indicators, generous timing, no audio-only information

DELIVERABLES

1. Create scenes/levels/shelter_level.tscn containing:
   - Several compact rooms/corridors connected clearly
   - Stylised wet concrete, pipes, water, emergency lighting
   - Clearly readable paths; no confusing layouts
   - Environmental storytelling: abandoned belongings, makeshift shelters, water damage
   - Good lighting and visibility

2. Build reusable WaterZone/WaterController systems (scripts/components/):
   - Water state changes are fixed and serializable
   - Use either: (a) periodic, clearly signaled fixed cycles, OR (b) state-based water changes controlled by pumps/valves
   - Do NOT combine both approaches confusingly
   - Clear visual/audio indicators for water state changes
   - Works with save/load (state persists correctly)

3. Build reusable pump and valve components (scripts/components/pump.gd, valve.gd):
   - Pumps require power/repair where appropriate (clear indicator if unpowered)
   - Valves visibly redirect water; every effect explained in environment or UI
   - Clear interaction prompts and state indicators
   - Works with remapped inputs

4. Build powered-door and linked-sequence puzzle support (scripts/components/powered_door.gd, puzzle_sequence.gd):
   - Incorrect sequences reset only local puzzle quickly (under 3 seconds)
   - Show useful feedback (e.g., "Valve 2 must be opened first" or "Power not connected")
   - Clear visual/audio feedback for success/failure
   - No softlocks possible

5. Include puzzles:
   - At least one main-route puzzle using pump + valve + powered door
   - At least two optional civilian rescue puzzles (clearly marked, optional, attainable)
   - Each rescue must be persistent after save/load
   - Each rescue increments Civilian Aid once only (no farming)
   - Clear visual indicators for optional vs required

6. Add one limited-oxygen traversal section:
   - Generous duration (e.g., 60+ seconds)
   - Visible timer (diegetic or UI)
   - Nearby reset checkpoints (no long backtracking on failure)
   - Deterministic reset on timeout (no random failure)
   - Do NOT reduce consequence counters merely for normal retry
   - Clear visual/audio warning when oxygen low

7. Add narrative messages:
   - Entry: Elena hears survivors, must reach them
   - Rescue completions: brief thank-you or relief (2–3 sentences)
   - Exit: checkpoint and transition noting Marcus is approaching perimeter
   - All messages skippable and non-blocking

8. Add accessibility:
   - No color-only indicators (use labels, shapes, brightness)
   - Clear visual/audio telegraphs for water changes
   - Generous timing on all puzzles
   - Input remapping fully honored
   - Reduced motion option (if water animation is intense)

ACCEPTANCE CRITERIA
- Main route is always completable without optional rescues
- Water, pump, valve, power, doors, oxygen, saves, and Civilian Aid counter behave predictably
- No water state makes critical path permanently impossible
- Optional rescues are clear, optional, attainable, and persistent
- Performance is stable at 60 FPS
- All inputs work with remapped bindings

DO NOT
- Randomize water behavior or puzzle states
- Create puzzles requiring precise timing or movement
- Block critical path with water or puzzles
- Allow farming of Civilian Aid through reloads

Finish by reporting:
- Changed files with brief descriptions
- Test results (main route tested, rescues tested, save/load verified, accessibility checked)
- Known limitations (be honest)
- Propose this commit message exactly:
Phase 6: flooded shelter puzzles complete
