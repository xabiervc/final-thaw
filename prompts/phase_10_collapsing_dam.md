You are continuing FINAL THAW in Godot 4.x. This game targets award-worthy quality at The Game Awards, D.I.C.E. Awards, BAFTA Games Awards, and Game Developers Choice Awards.

Read CLAUDE.md and reuse existing environmental puzzle systems. Phases 0–9 are complete with professional-grade foundation.

GOAL
Build Elena's collapsing-dam chapter: a multi-section puzzle level combining readable water behavior, platforms, power routing, valves, cranes, and limited Aster calibration. Design with award-quality environmental storytelling, readability, and accessibility.

STORY CONTEXT
Extreme rainfall is breaking the dam. Elena must cross service interiors, stabilize gates enough to access the mountain route, and preserve the Aster prototype.

QUALITY STANDARDS
- All sections completable through observation and learning
- No frame-perfect jumps or timing
- Water, platforms, power, crane, and calibration states survive save/load or reset to unambiguous checkpoint
- Hazards have clear telegraphs and do not produce unavoidable failure
- Accessibility: colorblind-safe indicators, generous timing, no audio-only information

DELIVERABLES

1. Create scenes/levels/dam_level.tscn with:
   - Service walkways, cracked concrete, turbulent water, control panels, pipes, rain
   - Several sections connected in clear sequence (no confusing layouts)
   - Environmental storytelling: structural damage, emergency repairs, abandoned equipment
   - Good lighting and visibility
   - Clear path forward with optional exploration

2. Reuse/enhance water system with fixed cycles or state-based behavior:
   - For timing sections: show understandable cycle indicator (e.g., bar, light, or sound)
   - Provide adequate windows (no frame-perfect jumps)
   - Water state is serializable and persists through save/load
   - Clear visual/audio telegraphs for water changes

3. Create reusable moving-platform component (scripts/components/moving_platform.gd):
   - Fixed paths/timing (no randomness)
   - Safe rider behavior (player stays on platform during movement)
   - Save/load-safe state (platform position persists or resets to checkpoint)
   - Clear visual indicators for start/end positions
   - Well-commented and modular

4. Create power-routing puzzle (scripts/components/power_router.gd):
   - Determines which platform/door/crane receives power
   - Make state clear in world and UI (e.g., power panel with switches, visual connections)
   - Multiple valid configurations possible, but only one powers all required systems
   - Clear feedback when power is connected/disconnected
   - No softlocks possible

5. Add valve and crane interactions:
   - Valves: redirect water or flow (clearly indicated direction)
   - Cranes: move defined object/bridge (not complex physics; fixed path or position)
   - Clear interaction prompts and state indicators
   - Works with remapped inputs

6. Implement Aster calibration ability (limited, explicit):
   - Three level-specific calibration charges OR three named calibration terminals
   - Use changes must be visible (UI indicator, particle effect, or sound)
   - Saved in GameManager (aster_calibrations_used count or flags)
   - Never randomly fail (deterministic success)
   - Clear feedback when calibration is applied

7. Add telegraphed hazards:
   - Falling debris: shadow or indicator before impact (1s warning)
   - Steam vents: visual/audio telegraph before activation (0.5–1s warning)
   - Electrical danger: visible arcs, buzzing sound, clear safe zones
   - Fixed patterns/cycles (no randomness)
   - Fair checkpoints (no long backtracking on death)

8. Add narrative sequence:
   - Entry: Elena sees dam damage, urgency to cross
   - Mid: brief updates at section transitions (2–3 sentences)
   - Exit: dam-complete checkpoint, Phase 10 completion state, transition to next phase
   - All messages skippable and non-blocking

9. Add accessibility:
   - No color-only indicators (use labels, shapes, brightness)
   - Clear visual/audio telegraphs for all hazards
   - Generous timing on all platforming and puzzles
   - Input remapping fully honored
   - Reduced motion option (if water/debris animation is intense)

ACCEPTANCE CRITERIA
- All sections can be completed in deterministic route after observing environment
- Water, platforms, power, crane, and calibration states survive save/load or reset to unambiguous checkpoint state
- Hazards have clear telegraphs and do not produce unavoidable failure
- Performance is stable at 60 FPS
- All inputs work with remapped bindings

DO NOT
- Randomize water behavior, platform timing, or hazard patterns
- Create puzzles requiring precise timing or pixel-perfect movement
- Make hazards unavoidable or unfair
- Block critical path with bugs or softlocks

Finish by reporting:
- Changed files with brief descriptions
- Test results (all sections tested, save/load verified, accessibility checked)
- Known limitations (be honest)
- Propose this commit message exactly:
Phase 10: collapsing dam puzzles complete
