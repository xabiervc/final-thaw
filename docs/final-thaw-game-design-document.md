# FINAL THAW
## Game Design Document

**Genre:** Isometric action-adventure, puzzle-platformer, beat 'em up

**Target experience:** 2.5–3.5 hours, 3 acts, 17 phases (0–16)

**Core promise:** In a planet-wide climate emergency, scientist Elena Vast must reach the Final Thaw Station with the Aster Protocol prototype. Former police officer Marcus Reyes must keep her alive.

---

# Protagonists

## Dr. Elena Vast (scientist, puzzle-focused)
- Move, jump, climb, push/pull light objects
- Scan environmental devices and reveal interactable systems
- Carry Aster prototype to unlock/calibrate climate-control equipment
- Repair circuits, redirect power, operate pumps, valves, cranes, lifts
- Temporarily disable lighting, cameras, alarms, automated defenses

## Marcus Reyes (officer, combat-focused)
- Move, sprint, dodge, block, grab, interact with environmental objects
- Light attack, heavy attack, deterministic 3-hit combo, grab/throw
- Use cover against ranged enemies
- Throw enemies into breakable scenery or hazards
- Protect Elena during joint sequences

---

# Consequence Model (deterministic, visible)

- **Elena Safety:** 0–3, reduced when directly harmed in joint sequences
- **Prototype Integrity:** 0–3, reduced by major scripted failures
- **Civilian Aid:** 0–10, increased by optional rescues/aid actions

Player can inspect these in pause menu. Game never silently changes ending.

---

# Act I — Separation (Phases 0–8)

**Phase 0 — Technical Foundation:** Godot project, deterministic rules, input mapping, isometric camera, save structure, visual palette.

**Phase 1 — Elena: Movement and Observation:** Escape monitoring facility, learn movement, scanning, carrying prototype, no combat.

**Phase 2 — Elena: Abandoned Laboratory:** 4 puzzle rooms (power restoration, robotic arm, moving platform, prototype calibration chamber). Reveal: Helix withheld Aster deployment.

**Phase 3 — Marcus: Combat Fundamentals:** Light/heavy attacks, 3-hit combo, dodge, block, grab, environmental throws. Enemy: scavenger.

**Phase 4 — Marcus: Highway Riots:** 4-5 arenas, enforcer enemies, breakable barriers, route-clearing score. Evidence: former unit reassigned to capture Elena.

**Phase 5 — Minigame: Broken Vehicle:** Repair emergency vehicle before fire front arrives. Deterministic sequence puzzle.

**Phase 6 — Elena: Flooded Shelter:** Water cycles, pumps, valves, powered doors, optional civilian rescues, oxygen timer.

**Phase 7 — Marcus: Militia Encirclement:** Marksman enemies, cover system, mini-boss (riot commander). Orders changed: terminate Elena if capture impossible.

**Phase 8 — Joint Mission: First Contact:** Guided escort model. Marcus controls combat, Elena activates gates from safety. Escape into toxic rainstorm. Act I complete.

---

# Act II — Cooperation (Phases 9–12)

**Phase 9 — Minigame: Calibrate Aster:** Circuit-alignment puzzle. Destination revealed: Final Thaw Station. Helix preparing limited intervention.

**Phase 10 — Elena: Collapsing Dam:** Water cycles, moving platforms, power routing, valves, cranes, limited Aster calibration, environmental hazards.

**Phase 11 — Marcus: Port Mutiny:** All enemy types plus shield units. Mini-boss (transport captain) with crane interaction. Optional civilian assistance.

**Phase 12 — Joint Mission: Free Switching:** Transit hub. Elena disables security, powers lifts, controls lighting. Marcus clears combat, moves heavy objects. Central disagreement: deploy Aster even if Helix takes it? Evidence choice: preserve or erase.

---

# Act III — The Final Thaw (Phases 13–16)

**Phase 13 — Final Thaw Station:** Longest level. 5-6 sections combining all systems. Weather escalation (snow → blizzard → storm). Optional researcher rescues. Evidence discovery: Helix engineered earlier Aster failure. Final evidence choice.

**Phase 14 — Final Boss: Helix Retrieval Commander:** Coordinated battle. Elena completes 3 Aster calibrations, creating vulnerability windows. Marcus prevents reinforcements, attacks during windows. Final phase: Elena maintains reactor balance, Marcus stops boss. Deterministic, telegraphed attacks.

**Phase 15 — Epilogue: Choice of Spring:** Aster activates. 3 endings based on counters + evidence choice:
- **Public Thaw:** High Civilian Aid (≥4), high Prototype Integrity (≥2), evidence preserved. Communities receive data, Helix loses legitimacy.
- **Guarded Thaw:** Prototype succeeds but evidence destroyed or Civilian Aid low. Helix controls recovery.
- **Fragile Thaw:** Low Elena Safety (≤1) or low Prototype Integrity (≤1). Imperfect activation, harder compromises ahead.

**Phase 16 — QA and Release Build:** Validate all rooms, puzzles, combat, switching, save/load, counters, accessibility. Fix bugs, optimize, export builds, prepare store assets.

---

# Scope Boundaries

No open world, procedural generation, loot systems, online multiplayer, branching dialogue trees, dozens of enemy types, or photorealistic assets. Act I complete = credible vertical slice. Acts II-III expand to 2.5–3.5 hour experience.