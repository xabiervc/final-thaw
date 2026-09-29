You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and reuse systems already built. Phases 0–12 are complete.

GOAL
Build the longest chapter: Final Thaw Station. It recombines established mechanics without introducing expensive unrelated systems.

STORY CONTEXT
The mountain relay station is half-buried by storm debris and occupied by Helix. Elena and Marcus must reach atmospheric control while deciding how to handle evidence that Helix engineered an earlier Aster test failure.

DELIVERABLES
1. Create scenes/levels/final_thaw_station.tscn with 5–6 connected sections, indoor/outdoor transitions, mountain research architecture, Helix barricades/surveillance, and atmospheric machinery.
2. Add weather stages: light snow, blizzard, extreme storm. Apply readable visual/audio changes and modest, fair mechanical effects. Never obscure critical interactables or hazards; expose accessibility option to reduce visual weather intensity.
3. Build sections that recombine existing mechanics:
   - Security surveillance disable + patrol combat.
   - Power reroute + defensive encounter.
   - Barricade clearing + atmospheric calibration.
   - Rapid but fair switching section: Elena stabilizes a system while Marcus prevents fixed sabotage waves.
   - Optional researcher rescue/equipment repair routes that increment Civilian Aid or open a shortcut.
4. Use all existing enemy types in deliberate placements. No new enemy classes.
5. Add evidence discovery scene and final explicit choice. The Phase 13 choice is final and overwrites Phase 12 preliminary intention.
6. Add messages, checkpoints after major sections, final_thaw_station_complete flag, and transition to boss arena.

ACCEPTANCE CRITERIA
- Level is a coherent 20–35 minute chapter using existing systems rather than feature creep.
- Weather remains readable and does not lower determinism.
- Optional aid never blocks main path and persists correctly.
- Evidence choice is unmistakable and saved.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 13: Final Thaw Station level complete
