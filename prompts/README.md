# FINAL THAW — Phase Prompts

Use **one prompt per Claude Code session**. Do not combine multiple phases in a single session.

## How to use

1. Start a fresh Claude Code session for each phase
2. Copy the complete content of the phase file (e.g., `phase_00_technical_foundation.md`)
3. Paste into Claude Code
4. Let Claude implement the phase
5. Run the project in Godot, verify acceptance criteria
6. Commit with the exact message specified at the end of each prompt
7. Move to the next phase

## Phase order

| Phase | File | Focus |
|-------|------|-------|
| 0 | `phase_00_technical_foundation.md` | Project setup, GameManager, MainMenu |
| 1 | `phase_01_elena_movement.md` | Elena character controller, interaction, scan |
| 2 | `phase_02_abandoned_laboratory.md` | 4 puzzle rooms |
| 3 | `phase_03_marcus_combat.md` | Combat fundamentals, enemies |
| 4 | `phase_04_highway_riots.md` | Combat arenas, enforcers |
| 5 | `phase_05_broken_vehicle.md` | Vehicle repair minigame |
| 6 | `phase_06_flooded_shelter.md` | Water puzzles, optional rescues |
| 7 | `phase_07_militia_encirclement.md` | Marksmen, cover, first boss |
| 8 | `phase_08_first_contact.md` | First joint mission, escort |
| 9 | `phase_09_calibrate_aster.md` | Circuit minigame |
| 10 | `phase_10_collapsing_dam.md` | Dam puzzles, platforms |
| 11 | `phase_11_port_mutiny.md` | Shield units, crane boss |
| 12 | `phase_12_free_switching.md` | Character switching, stealth |
| 13 | `phase_13_final_thaw_station.md` | Longest level, all systems |
| 14 | `phase_14_final_boss.md` | Coordinated boss battle |
| 15 | `phase_15_epilogue.md` | 3 endings, credits |
| 16 | `phase_16_qa_release.md` | QA, optimization, export |

## Rules

- Never skip phases
- Test thoroughly before committing
- Use exact commit messages from prompts
- If a phase reveals bugs in previous phases, fix them before proceeding
