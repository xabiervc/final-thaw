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

**Phase 1 — Elena: Movement and Observation:** Elena escapes the flooded monitoring facility carrying the Aster prototype. Objective: survive and gain access, no combat. The phase teaches Elena's core verb: observe, form a hypothesis, find a second piece of evidence, act and verify. Puzzles are solved by reading the infrastructure as evidence, not by pressing the nearest object. Design target: 6–10 minutes (provisional, to be validated by playtest). Six zones:
- **Exit hub:** move, interact, open the first door.
- **Debris corridor:** jumping costs stamina; high barriers require a stable state; a recovery station is available.
- **Control room (central puzzle):** two dated logs, three breakers, wiring traces revealed by the scanner and a sealed gate. The later log supersedes the earlier one and the wiring confirms it. A wrong breaker teaches (a status lamp is not an actuator; an outdated log is not current), costs seconds rather than integrity, and never blocks progress.
- **Rest chamber:** no threats, an optional memory fragment, a recovery station.
- **Test chamber:** combines jumping, scanning and reading; the generator lever is hidden and located with the scanner.
- **Exit hub:** checkpoint and handoff to Phase 2.

Rules: no randomness; every wrong answer is explained, repeatable and free of integrity loss; the gate can be opened from any sequence of actions; hints have three modes (Off, Contextual, Full solution). Optional risky or decoy elements stay disabled until their consequence can be read beforehand.

**Phase 2 — Elena: Abandoned Laboratory:** Elena restores power, moves a robotic arm, uses moving platforms and carries the Aster through calibration hazards to recover the proof that Helix withheld Aster deployment. Seven zones, design target 15–22 minutes (provisional):
- **Room 1, power routing:** route energy to the door or to a platform. An optional route leads to a visible memory fragment; its cost is announced before the player commits.
- **Room 2, robotic arm:** the safe angle is deduced by observing the arm's sweep area. A second, mirrored arm is built only after the first has been validated.
- **Service corridor:** rest beat with a recording from Selene.
- **Room 3, platform pits:** a platform on a cycle of about 10 seconds, an island with a recovery station, and an optional timed power button. Guaranteed recovery: the platform never stops mid-gap and the button can be reused without delay.
- **Observatory:** rest beat and narrative scene with a view of the frozen city. Elena calibrates the Aster she already carries; from then on it adds a light load to her speed and jumps.
- **Room 4, hazard calibration:** deterministic hazard strips telegraphed one second before activating. Wide strips are waited out; thin strips (about 0.6 m, provisional) can be jumped at a stamina cost. A safe detour adds about 30 seconds.
- **Archive:** recover three data fragments, each with a mechanic already learned. With two fragments the record is inconsistent and says so. With the third, the proof is obtained. Reveal: Helix withheld Aster deployment.

Rules: hazards cost 1 Prototype Integrity once per zone; reaching 0 never repeats a room. During Phases 1–2 integrity changes give local feedback but do not yet lock an ending; the milestone from which the Fragile Thaw threshold becomes irreversible is to be defined (provisional). Physical values (barrier heights, strip thickness, drain) and the new zone layout are pending technical tests and playtest validation.


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