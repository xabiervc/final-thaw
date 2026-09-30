You are continuing FINAL THAW in Godot 4.x. This game targets award-worthy quality at The Game Awards, D.I.C.E. Awards, BAFTA Games Awards, and Game Developers Choice Awards.

Read CLAUDE.md and reuse systems already built. Phases 0–12 are complete with professional-grade foundation.

GOAL
Build the longest chapter: Final Thaw Station. It recombines established mechanics without introducing expensive unrelated systems. Design with award-quality level design, pacing, environmental storytelling, and accessibility.

STORY CONTEXT
The mountain relay station is half-buried by storm debris and occupied by Helix. Elena and Marcus must reach atmospheric control while deciding how to handle evidence that Helix engineered an earlier Aster test failure.

QUALITY STANDARDS
- Level is coherent 20–35 minute chapter using existing systems rather than feature creep
- Weather remains readable and does not lower determinism
- Optional aid never blocks main path and persists correctly
- Evidence choice is unmistakable and saved
- Accessibility: clear visual indicators, skippable dialogue, input remapping, reduced weather intensity option

DELIVERABLES

1. Create scenes/levels/final_thaw_station.tscn with:
   - 5–6 connected sections (indoor/outdoor transitions, mountain research architecture)
   - Helix barricades/surveillance (barriers, cameras, patrol routes)
   - Atmospheric machinery (pipes, vents, control panels, relays)
   - Clear path forward with optional exploration
   - Environmental storytelling: research facility, storm damage, Helix occupation
   - Good lighting and readability

2. Add weather stages (scripts/components/weather_controller.gd):
   - Light snow (section 1–2): minimal visual effect, slight slowdown
   - Blizzard (section 3–4): moderate visual effect, moderate slowdown, reduced visibility
   - Extreme storm (section 5–6): heavy visual effect, significant slowdown, low visibility
   - Apply readable visual/audio changes and modest, fair mechanical effects
   - NEVER obscure critical interactables or hazards
   - Expose accessibility option to reduce visual weather intensity (settings toggle)
   - Performance optimized (particle limits, LOD if needed)

3. Build sections that recombine existing mechanics:

   Section 1: Security Surveillance + Patrol Combat
   - Elena disables surveillance cameras via terminal (timed interaction)
   - Marcus defends from patrol waves (2–3 enemies)
   - Clear visual feedback when cameras are disabled
   - Environmental storytelling: security room, monitors, Helix presence

   Section 2: Power Reroute + Defensive Encounter
   - Elena reroutes power to open path (puzzle: power_router component)
   - Marcus defends position from waves (3–4 enemies)
   - Clear feedback when power is connected
   - Environmental storytelling: power room, generators, cables

   Section 3: Barricade Clearing + Atmospheric Calibration
   - Marcus clears barricade (heavy attacks or environmental interaction)
   - Elena calibrates atmospheric system (timed terminal interaction)
   - Both actions required; neither works alone
   - Environmental storytelling: damaged corridor, atmospheric equipment

   Section 4: Rapid Switching Section
   - Elena stabilizes system (timed interaction, e.g., 15–20s)
   - Marcus prevents fixed sabotage waves (3–4 enemies, fixed spawns)
   - Switching may be required to handle both tasks
   - Clear feedback for system stability and enemy waves
   - Environmental storytelling: control room, sabotage attempts

   Section 5: Optional Researcher Rescue/Equipment Repair
   - Optional route off main path (clearly marked)
   - Rescue researchers or repair equipment (puzzle or combat)
   - Increments Civilian Aid once (persistent flag)
   - May open shortcut back to main path
   - Environmental storytelling: research lab, trapped survivors, damaged equipment

   Section 6: Final Approach to Atmospheric Control
   - Clear path to boss arena
   - Narrative buildup (Helix presence, storm intensity, final decision weight)
   - Checkpoint before boss arena
   - Environmental storytelling: atmospheric control chamber entrance, Helix fortification

4. Use all existing enemy types in deliberate placements:
   - Scavengers, Enforcers, Marksmen, Shields
   - No new enemy classes (reuse existing components)
   - Fixed spawns and waves (no randomness)
   - Clear cover and environmental objects

5. Add evidence discovery scene and final explicit choice:
   - Evidence room or terminal with Helix's earlier Aster test failure data
   - Clear narrative (2–4 sentences: Helix engineered failure to justify control)
   - Final choice: preserve evidence or erase it (overwrites Phase 12 preliminary intention)
   - Store evidence_choice as "preserve" or "erase" in GameManager
   - Clear UI prompt explaining consequences (brief, not spoiling endings)
   - Choice is saved immediately with visible confirmation
   - Visual/audio feedback on selection

6. Add messages, checkpoints, and transitions:
   - Entry: Elena/Marcus arrive at station, storm intensity, Helix presence
   - Mid: brief updates at section transitions (2–3 sentences)
   - Evidence discovery: clear narrative reveal
   - Exit: final_thaw_station_complete flag, transition to boss arena
   - Checkpoints after major sections (at least after sections 2, 4, 6)
   - All messages skippable and non-blocking

7. Add accessibility:
   - Clear visual indicators for weather intensity, enemy spawns, and interactables
   - Reduced weather intensity option (settings toggle)
   - Skippable dialogue with text size options
   - Input remapping fully honored
   - Clear audio/visual feedback for all events

ACCEPTANCE CRITERIA
- Level is coherent 20–35 minute chapter using existing systems rather than feature creep
- Weather remains readable and does not lower determinism (critical interactables always visible)
- Optional aid never blocks main path and persists correctly (Civilian Aid flag saved)
- Evidence choice is unmistakable and saved (no ambiguity)
- Performance is stable at 60 FPS (weather effects optimized)
- All inputs work with remapped bindings

DO NOT
- Introduce new enemy types or mechanics (reuse existing systems)
- Make weather obscure critical interactables or hazards
- Block main path with optional content
- Allow evidence choice to be ambiguous or lost through save/load

Finish by reporting:
- Changed files with brief descriptions
- Test results (all sections tested, weather tested, save/load verified, accessibility checked)
- Known limitations (be honest)
- Propose this commit message exactly:
Phase 13: Final Thaw Station level complete
