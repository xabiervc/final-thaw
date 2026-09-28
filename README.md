# FINAL THAW

**Isometric action-adventure game built with Godot 4.x**

A scientist and a former police officer must cooperate to save humanity from climate collapse. Alternate between puzzle-solving as Elena Vast and beat-'em-up combat as Marcus Reyes, then combine both skill sets in joint missions.

---

## Story

The year is 2089. Decades of ignored warnings and corporate control have broken the planet. Dr. Elena Vast carries the **Aster Protocol**, a last-resort method to stabilize the atmosphere. Marcus Reyes, a burned-out former officer, must keep her alive long enough to reach the **Final Thaw Station**.

Their separate paths reveal incompatible truths about who caused the collapse—and whether humanity deserves the solution.

---

## Features

- **Two complementary protagonists**: Elena (puzzles, environment) and Marcus (combat, protection)
- **Isometric 2D/2.5D presentation** with readable spaces and deterministic gameplay
- **17 development phases** from foundation to release build
- **Three deterministic endings** based on visible consequence counters
- **No RNG**: enemy behavior, puzzles, hazards, and endings are all predictable

---

## Quick Start

### Prerequisites

- **Godot 4.x** (latest stable recommended)
- Git (optional, for version control)

### Setup

1. Clone or download this repository
2. Open `project.godot` in Godot 4.x
3. Run the project (F5 or Play button)

### Controls (default)

| Action | Keyboard |
|--------|----------|
| Move | WASD / Arrow keys |
| Interact | E / Enter |
| Scan (Elena) | Q |
| Light Attack (Marcus) | J / K |
| Heavy Attack (Marcus) | L |
| Dodge | Space |
| Block | Shift |
| Switch Character | Tab |
| Pause | Escape |

Controls can be reconfigured in Project Settings → Input Map.

---

## Consequence System

Three visible counters determine the ending:

| Counter | Range | Description |
|---------|-------|-------------|
| **Elena Safety** | 0–3 | Reduced when Elena is directly harmed in joint missions |
| **Prototype Integrity** | 0–3 | Reduced by major scripted failures involving the Aster device |
| **Civilian Aid** | 0–10 | Increased by completing optional rescues or aid actions |

The game never silently changes the ending. All three values are visible in the pause menu.

---

## Development Phases

The project is structured in **17 sequential phases**. Use `docs/final-thaw-godot4-phase-prompts.md` as your guide. Each phase is designed for one Claude Code session.

| Phase | Title | Focus |
|-------|-------|-------|
| 0 | Technical Foundation | Project setup, GameManager, MainMenu, test room |
| 1 | Elena: Movement | Character controller, interaction, scan |
| 2 | Elena: Laboratory | 4 puzzle rooms, prototype mechanics |
| 3 | Marcus: Combat | Beat-'em-up fundamentals, enemies |
| 4 | Marcus: Highway | Combat arenas, enforcers, scoring |
| 5 | Minigame: Vehicle | UI repair puzzle, transition |
| 6 | Elena: Shelter | Water puzzles, pumps, optional rescues |
| 7 | Marcus: Perimeter | Marksmen, cover, first mini-boss |
| 8 | Joint: First Contact | Escort mission, Elena Safety intro |
| 9 | Minigame: Aster | Circuit puzzle, story reveal |
| 10 | Elena: Dam | Water cycles, platforms, calibration |
| 11 | Marcus: Port | Shield units, crane boss, civilian aid |
| 12 | Joint: Free Switching | Character switching, lighting stealth |
| 13 | Final Thaw Station | Longest level, all systems, evidence choice |
| 14 | Final Boss | Coordinated battle, 3 calibrations |
| 15 | Epilogue | 3 endings, credits, New Game |
| 16 | QA & Release | Testing, optimization, export builds |

**Recommended workflow:**
1. Read the phase prompt in `docs/final-thaw-godot4-phase-prompts.md`
2. Paste it into Claude Code
3. Let Claude implement the phase
4. Run the project, verify acceptance criteria
5. Commit with the exact message provided
6. Move to the next phase

---

## Project Structure

```
final-thaw/
├── assets/
│   ├── audio/          # SFX and music
│   └── sprites/        # Character and environment art
├── docs/
│   ├── final-thaw-game-design-document.md   # Full design document
│   └── final-thaw-godot4-phase-prompts.md   # Phase-by-phase prompts
├── resources/          # Configuration and data
├── scenes/
│   ├── characters/     # Elena, Marcus, enemies
│   ├── components/     # Reusable components (Interactable, Hitbox, etc.)
│   ├── levels/         # All game levels
│   ├── minigames/      # Vehicle repair, Aster calibration
│   └── ui/             # MainMenu, HUD, epilogue
├── scripts/
│   ├── autoload/       # GameManager singleton
│   ├── characters/     # Character controllers
│   └── components/     # Component scripts
├── exports/            # Release builds
├── project.godot
├── README.md
└── .gitignore
```

---

## Endings

The game has **3 deterministic endings** based on counters and the final evidence choice:

### Public Thaw
- **Requirements:** Civilian Aid ≥ 4, Prototype Integrity ≥ 2, Evidence = Preserved
- **Outcome:** Communities receive stabilisation data. Helix loses legitimacy. Recovery begins as a shared resource.

### Guarded Thaw
- **Requirements:** Prototype succeeds, but Civilian Aid < 4 OR Evidence = Erased
- **Outcome:** Climate stabilizes, but Helix controls access to recovery technology.

### Fragile Thaw
- **Requirements:** Elena Safety ≤ 1 OR Prototype Integrity ≤ 1
- **Outcome:** Imperfect activation. Survival remains possible, but compromises are harder.

---

## Scope Boundaries

This project deliberately avoids:
- Open world or procedural generation
- Loot systems or microtransactions
- Online multiplayer
- Branching dialogue trees
- Dozens of enemy types
- Photorealistic asset production

**Act I (Phases 0–8)** is a credible vertical slice and self-contained playable demonstration. **Acts II–III (Phases 9–16)** expand the foundation into a 2.5–3.5 hour finished experience.

---

## License

TODO: Choose and add a license (e.g., MIT, GPL-3.0, or proprietary).

---

## Credits

**FINAL THAW** is a collaborative project. Development guided by phase prompts from `docs/final-thaw-godot4-phase-prompts.md`.

---

## Getting Help

- Read `docs/final-thaw-game-design-document.md` for full design context
- Use `docs/final-thaw-godot4-phase-prompts.md` for step-by-step implementation
- Check Godot 4.x documentation for engine-specific questions
- Open an issue in this repository for bugs or feature requests
