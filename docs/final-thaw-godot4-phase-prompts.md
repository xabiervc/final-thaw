# FINAL THAW — Prompts por fases para Godot 4

Usa **un prompt por sesión de Claude Code**. No intentes construir varias fases juntas. Antes de pasar a la siguiente fase, ejecuta el proyecto, corrige errores, revisa los cambios y realiza el commit indicado.

## Reglas comunes

- Motor: **Godot 4.x**, GDScript, presentación 2D/2.5D isométrica estilizada.
- No usar plugins externos sin una necesidad justificada.
- Usar arte y sonido provisionales hasta la fase de pulido.
- Determinismo: física a 60 Hz; sin aleatoriedad oculta en IA, puzles, peligros, minijuegos ni finales.
- Sistemas modulares y reutilizables.
- No añadir mundo abierto, generación procedural, loot, monetización ni multijugador.

---

# Fase 0 — Base técnica

```text
You are the implementation agent for FINAL THAW, a single-player isometric action-adventure made with Godot 4.x and GDScript.

GOAL: Create a clean, runnable Godot 4.x foundation.

DELIVERABLES:
1. Project structure: scenes/, scripts/, assets/sprites/, assets/audio/, resources/, docs/, exports/
2. Input Map: move_up, move_down, move_left, move_right, interact, scan, switch_character, attack_light, attack_heavy, dodge, block, pause
3. CLAUDE.md with project overview, determinism rules, naming conventions, folder structure
4. .gitignore for Godot 4.x
5. GameManager autoload (scripts/autoload/game_manager.gd) with elena_safety (0-3), prototype_integrity (0-3), civilian_aid (0-10), checkpoint_id, character_id, phases, flags. Methods: reset_new_game(), save_game(), load_game()
6. MainMenu scene: FINAL THAW title, Start Game, Continue (disabled if no save), Quit
7. HUD showing three consequence counters
8. test_room.tscn with floor, boundaries, placeholder CharacterBody2D, camera
9. README.md with instructions, controls, phases 0-16 list

ACCEPTANCE: Project opens without errors, MainMenu works, test_room playable, GameManager accessible, save/load works.

Commit: Phase 0: project foundation complete
```

---

# Fase 1 — Elena: movimiento y observación

```text
Continuing FINAL THAW. Phase 0 complete.

GOAL: Implement Elena's movement, interaction, and scan.

DELIVERABLES:
1. elena_character.tscn (CharacterBody2D, sprite, collision, shadow, interaction nodes)
2. elena_movement.gd: smooth movement, diagonal normalization, boundaries
3. Interactable component: display_name, prompt_text, enabled, interact(actor)
4. Nearest-target selection (deterministic)
5. Scan ability: highlights interactables in range, no cooldown
6. elena_test_room.tscn with 3+ interactables
7. GameManager active_character_id support

ACCEPTANCE: Elena moves smoothly, interaction works deterministically, scan highlights without changing state.

Commit: Phase 1: Elena movement and observation complete
```

---

# Fase 2 — Elena: laboratorio abandonado

```text
Continuing FINAL THAW. Phases 0-1 complete.

GOAL: Create 4-room puzzle chapter.

ROOMS:
1. Power restoration: terminal connection sequence
2. Robotic arm: cycle positions via terminal
3. Moving platform: fixed timing, callable
4. Prototype chamber: hazard navigation, preserve Prototype Integrity

REQUIREMENTS: Fixed solutions, quick reset on failure, sequential rooms with save, narrative messages, chapter complete transition.

ACCEPTANCE: All 4 rooms playable, save/load works, no softlocks.

Commit: Phase 2: abandoned laboratory puzzles complete
```

---

# Fase 3 — Marcus: combate básico

```text
Continuing FINAL THAW. Phases 0-2 complete.

GOAL: Implement Marcus combat foundation.

DELIVERABLES:
1. marcus_character.tscn (CharacterBody2D, sprite, shadow, collision, health)
2. Movement: same as Elena + sprint, dodge (invincibility frames), block (damage reduction)
3. Combat: light/heavy attacks, fixed 3-hit combo, state machine
4. Hitbox/Hurtbox/Health components
5. enemy_scavenger.tscn: deterministic AI, health bar, telegraph
6. Grab/throw system for objects
7. marcus_combat_arena.tscn with 3-5 enemies, throwable objects, score display
8. Hit feedback: flash, camera shake (with reduce option)

ACCEPTANCE: Marcus can complete arena with all combat mechanics, enemy telegraphs readable.

Commit: Phase 3: Marcus combat fundamentals complete
```

---

# Fase 4 — Marcus: disturbios en la autopista

```text
Continuing FINAL THAW. Phases 0-3 complete.

GOAL: Build highway combat chapter.

DELIVERABLES:
1. highway_level.tscn: 4 arenas, stylised art
2. enemy_enforcer.tscn: high health, block/counter, flank weakness
3. ArenaController: fixed waves, locked exits, checkpoint on clear
4. Breakable barriers (destructible component)
5. Expanded throwable environment (pipes, signs, fuel canister)
6. Route-clearing score (time, damage, environmental throws, clean bonus)
7. Narrative messages, evidence flag, Phase 4 checkpoint

ACCEPTANCE: All arenas clearable, enforcer patterns consistent, no softlocks.

Commit: Phase 4: highway riots combat complete
```

---

# Fase 5 — Minijuego: vehículo averiado

```text
Continuing FINAL THAW. Phases 0-4 complete.

GOAL: Create UI-focused repair minigame.

DELIVERABLES:
1. minigame_vehicle.tscn: systems diagram, fire background, progress bar
2. 5 repair controls (valves, fuses, switches) with 2-4 states each
3. Click/controller navigation, Confirm Repair action
4. Fire timer (generous), auto-complete on expiry with flag
5. vehicle_repaired_cleanly / vehicle_repaired_under_pressure flags
6. Narrative context, transition to Phase 6 placeholder
7. Documented pause handling

ACCEPTANCE: Puzzle solvable from visual clues, deterministic outcomes, save/load safe.

Commit: Phase 5: broken vehicle minigame complete
```

---

# Fase 6 — Elena: refugio inundado

```text
Continuing FINAL THAW. Phases 0-5 complete.

GOAL: Build flooded shelter puzzle level.

DELIVERABLES:
1. shelter_level.tscn: rooms, water, emergency lighting
2. WaterZone/WaterController: fixed cycles or state-based (documented)
3. Pump/valve components with power requirements
4. Powered doors, linked-sequence puzzles
5. Main route puzzle + 2+ optional civilian rescues (increment Civilian Aid once)
6. Oxygen timer section (generous, checkpoints, deterministic reset)
7. Narrative messages, checkpoint, transition to Marcus approaching

ACCEPTANCE: Main route completable, water/pump/valve/oxygen predictable, no permanent blocks.

Commit: Phase 6: flooded shelter puzzles complete
```

---

# Fase 7 — Marcus: cerco de la milicia

```text
Continuing FINAL THAW. Phases 0-6 complete.

GOAL: Build perimeter combat with marksmen and mini-boss.

DELIVERABLES:
1. perimeter_level.tscn: 3 arenas + boss arena, barriers, floodlights
2. enemy_marksman.tscn: line-of-sight, aim telegraph, fixed projectile
3. Cover logic: solid cover blocks projectiles
4. Arena progression: scavengers+marksman, enforcers+2 marksmen, mixed
5. boss_riot_commander.tscn: shield bash, frontal block, tear gas, rear weak point, enraged state
6. Boss arena with cover, throwables, checkpoint
7. Narrative, perimeter_complete, termination_order_discovered flags

ACCEPTANCE: Marksman LOS reliable, boss beatable via patterns/flanking, checkpoint works.

Commit: Phase 7: militia encirclement combat complete
```

---

# Fase 8 — Misión conjunta: primer contacto

```text
Continuing FINAL THAW. Phases 0-7 complete.

GOAL: First Elena-Marcus escort mission.

DELIVERABLES:
1. joint_mission_1.tscn: 2-3 arenas, protected terminals, safe points, gates, toxic-rain exit
2. ElenaFollower: Path2D/waypoints, never stuck/wandering
3. Player controls Marcus only, Elena waits at safe points
4. Enemies target Marcus; Elena Safety warning/decrement only on defined boundary breach (single decrement per event)
5. Terminal/gate events: Marcus clears, Elena activates, gate opens
6. HUD Elena Safety indicator with explanation
7. Skippable dialogue (first contact, exchanges)
8. Toxic rain exit: particles, fade, Act I flag, checkpoint, transition

ACCEPTANCE: Elena never stuck/attacked unintentionally, arenas replayable, Elena Safety changes only via defined events.

Commit: Phase 8: first joint mission complete
```

---

# Fase 9 — Minijuego: calibrar Aster

```text
Continuing FINAL THAW. Phases 0-8 complete.

GOAL: Create Calibrate Aster circuit puzzle.

DELIVERABLES:
1. minigame_aster.tscn: circuit board UI, storm background, feedback
2. 6 rotatable nodes, fixed rotations, one solvable path
3. Click/keyboard/controller support
4. Powered/unpowered segment feedback, Confirm Calibration when complete
5. Optional hint mode (highlights one incorrect tile)
6. On completion: aster_calibrated, final_thaw_station_revealed flags, narrative, transition to Phase 10
7. No timer

ACCEPTANCE: Puzzle solvable from visuals, all inputs work, flags save correctly.

Commit: Phase 9: calibrate Aster minigame complete
```

---

# Fase 10 — Elena: presa colapsada

```text
Continuing FINAL THAW. Phases 0-9 complete.

GOAL: Build collapsing dam puzzle level.

DELIVERABLES:
1. dam_level.tscn: walkways, water, panels, rain, sections
2. Water system: fixed cycles/indicator, adequate windows
3. Moving-platform component: fixed paths/timing, safe rider, save-safe
4. Power-routing puzzle: clear world/UI state
5. Valve/crane interactions (defined object/bridge movement)
6. Aster calibration: 3 charges or 3 terminals, visible, saved, never random
7. Telegraphed hazards (debris, steam, electrical) with fixed patterns/checkpoints
8. Narrative, dam-complete checkpoint, Phase 10 state

ACCEPTANCE: All sections completable deterministically, states survive save/load, hazards telegraphed.

Commit: Phase 10: collapsing dam puzzles complete
```

---

# Fase 11 — Marcus: motín en el puerto

```text
Continuing FINAL THAW. Phases 0-10 complete.

GOAL: Build port combat with shield units and crane boss.

DELIVERABLES:
1. port_level.tscn: docks, containers, cranes, arenas, rescue locations
2. enemy_shield.tscn: frontal immunity, slow, shield-bash telegraph, flank/grab/stun counterplay
3. 3 combat arenas combining all 4 enemy types
4. 2+ optional civilian rescues (safe, visible, increment Civilian Aid once, persist)
5. boss_transport_captain.tscn: ground slam (shockwave), cargo throw, reinforcement call, fixed state machine
6. Crane interaction: optional, major damage + stun, no softlock
7. Chapter messages, checkpoint, port_complete flag

ACCEPTANCE: Shield mechanics understandable, boss beatable without crane (crane helps), rescue not farmable, combat stable.

Commit: Phase 11: port mutiny combat complete
```

---

# Fase 12 — Misión conjunta: cambio libre

```text
Continuing FINAL THAW. Phases 0-11 complete.

GOAL: Implement free Elena-Marcus switching in transit hub.

DELIVERABLES:
1. CharacterSwitchController, HUD active-character indicator
2. transit_hub.tscn: 3 rooms:
   - Room 1: Elena disables security (timed) while Marcus defends
   - Room 2: Marcus moves heavy object, Elena powers lift
   - Room 3: Elena controls lighting, Marcus stealth takedown (some enemies immune)
3. Elena timed security interaction: visible progress, defined interrupt/reset
4. Marcus heavy-object movement: controlled, collision-safe
5. Lighting system: visual difference, accessibility indicators, deterministic enemy changes
6. Dialogue (growing respect, core disagreement), skippable
7. Binary saved choice: preserve or erase evidence (evidence_choice)

ACCEPTANCE: Switching never breaks characters, each room requires both, all mechanics/checkpoint/save work.

Commit: Phase 12: transit hub joint mission complete
```

---

# Fase 13 — Estación Final Thaw

```text
Continuing FINAL THAW. Phases 0-12 complete.

GOAL: Build longest chapter (Final Thaw Station).

DELIVERABLES:
1. final_thaw_station.tscn: 5-6 sections, indoor/outdoor, architecture, barricades, machinery
2. Weather stages: snow → blizzard → storm, readable effects, accessibility reduce option
3. Sections recombining mechanics:
   - Surveillance disable + patrol combat
   - Power reroute + defensive encounter
   - Barricade clearing + atmospheric calibration
   - Rapid switching: Elena stabilizes, Marcus prevents sabotage
   - Optional rescues/repairs (Civilian Aid or shortcut)
4. All enemy types, deliberate placements, no new classes
5. Evidence discovery scene, final explicit choice (overwrites Phase 12)
6. Messages, checkpoints, final_thaw_station_complete flag, boss transition

ACCEPTANCE: Coherent 20-35 min chapter, weather readable, optional aid non-blocking, evidence choice saved.

Commit: Phase 13: Final Thaw Station level complete
```

---

# Fase 14 — Jefe final

```text
Continuing FINAL THAW. Phases 0-13 complete.

GOAL: Build final boss requiring Elena-Marcus coordination.

DELIVERABLES:
1. boss_arena.tscn: reactor/prototype, 3 calibration panels, vents, boss zone, spawn areas, safe lanes
2. boss_helix_commander.tscn: deterministic state machine, no random moves
3. 3 Elena calibrations: visible progress, defined interrupt/reset, Marcus protection task, creates vulnerability window
4. Marcus deals damage during vulnerability, boss damage reduction/invulnerability visible outside
5. Boss moves: telegraphed energy blast, shield barrier, reinforcement call (existing enemies), reactor sabotage (warning + counterplay)
6. Final phase: Elena maintains reactor balance, Marcus stops boss pressure
7. Optional environmental actions (steam vent, overload stun): visible, fixed effect, cooldown/charge, never mandatory
8. Checkpoint policy: documented fair retry point
9. Dialogue, epilogue transition

ACCEPTANCE: Boss beatable via patterns, all attacks telegraphed/avoidable, calibration/switching clear, retry/save/victory stable.

Commit: Phase 14: final boss battle complete
```

---

# Fase 15 — Epílogo

```text
Continuing FINAL THAW. Phases 0-14 complete.

GOAL: Create epilogue, deterministic endings, credits, New Game.

ENDING RULES:
- Fragile Thaw priority if elena_safety <= 1 OR prototype_integrity <= 1
- Else Public Thaw if civilian_aid >= 4 AND prototype_integrity >= 2 AND evidence_choice == "preserve"
- Else Guarded Thaw

DELIVERABLES:
1. epilogue.tscn: story cards/scenes, clearing weather, placeholder art
2. EndingResolver function: applies rules, returns ending key, testable
3. Concise narrative for each ending
4. Final statistics: civilians aided, Elena Safety, Prototype Integrity, evidence decision, ending title
5. Scrolling credits (skippable after delay)
6. New Game option: reset_new_game(), safe save clear/replacement
7. ending_viewed flag, coherent replay/new game
8. Test hooks/documentation for verifying all 3 endings

ACCEPTANCE: Same inputs = same ending, Fragile priority works, credits/New Game safe, all text/buttons functional.

Commit: Phase 15: epilogue and endings complete
```

---

# Fase 16 — QA y build

```text
Continuing FINAL THAW. Phases 0-15 complete.

GOAL: Release-focused QA, fixes, accessibility, export, documentation.

DELIVERABLES:
1. docs/qa_checklist.md: all menus, levels, puzzles, enemies, boss, minigames, switching, save/load, counters, endings, controls, exports
2. docs/qa_results.md: actual issues with severity, reproduction, resolution, verification (no invented results)
3. Fix blockers: crashes, parser errors, softlocks, progression breaks, corrupt saves, wrong ending logic, input failures, then visual/audio defects
4. Profile performance, optimize verified bottlenecks (nodes, particles, processing, effects), preserve gameplay
5. Accessibility: input remapping/bindings, text size (normal/large), reduced camera shake, reduced weather/effects, non-colour-only puzzle indicators
6. Export presets for Windows (macOS/Linux only if templates + testing available)
7. docs/release_checklist.md: v1.0.0, tested platforms, known issues, store assets checklist, screenshots/trailer placeholders, description placeholder, content warnings, sign-off
8. README.md update: install/run instructions, controls, accessibility, credits placeholder, license TODO
9. If Git available: clean tree, final version commit, annotated tag v1.0.0 after checks pass (no tag if blockers remain)

ACCEPTANCE: QA docs reflect real verification, all endings reachable via documented steps, Windows export tested, no known release-blocking issues.

Commit: Phase 16: QA, optimization, and release build complete
```
