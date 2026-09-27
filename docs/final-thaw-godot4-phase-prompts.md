# FINAL THAW — Prompts por fases para Godot 4

Usa **un prompt por sesión de Claude Code**. No intentes construir varias fases juntas. Antes de pasar a la siguiente fase, ejecuta el proyecto, corrige errores, revisa los cambios y realiza el commit indicado.

## Reglas comunes

- Motor: **Godot 4.x**, GDScript, presentación 2D/2.5D isométrica estilizada.
- No usar plugins externos sin una necesidad justificada.
- Usar arte y sonido provisionales hasta la fase de pulido.
- Determinismo: física a 60 Hz; sin aleatoriedad oculta en IA, puzles, peligros, minijuegos ni finales. Si se emplea aleatoriedad en el futuro, debe tener semilla explícita y guardada.
- Sistemas modulares y reutilizables; no duplicar scripts cuando un componente configurable sea suficiente.
- No añadir mundo abierto, generación procedural, loot, monetización ni multijugador.
- Al terminar cada fase: ejecutar la escena relevante, corregir errores y mostrar archivos modificados, resultados de prueba, limitaciones conocidas y el commit propuesto.

---

# Fase 0 — Base técnica

```text
You are the implementation agent for FINAL THAW, a single-player isometric action-adventure made with Godot 4.x and GDScript. The game alternates puzzle-focused scientist Elena Vast, combat-focused former officer Marcus Reyes, and later joint missions. It has a stylised 2D/2.5D isometric look, not photorealism.

Read CLAUDE.md if it exists. This is Phase 0, so create it as part of the work.

GOAL
Create a clean, runnable Godot 4.x foundation for the full project.

REQUIRED PROJECT STRUCTURE
- scenes/
- scenes/ui/
- scenes/levels/
- scenes/characters/
- scenes/components/
- scripts/
- scripts/autoload/
- scripts/characters/
- scripts/components/
- assets/sprites/
- assets/audio/
- resources/
- docs/
- exports/

DELIVERABLES
1. Configure a Godot 4.x project for 1280x720, 60 Hz physics, and sensible CanvasItem stretch settings.
2. Configure Input Map actions: move_up, move_down, move_left, move_right, interact, scan, switch_character, attack_light, attack_heavy, dodge, block, pause. Bind keyboard defaults and document them in README.
3. Create CLAUDE.md containing project overview, deterministic rules, naming conventions, folder structure, test expectations, and Git workflow.
4. Create a Godot-compatible .gitignore. Do not ignore source scenes, scripts, or project.godot.
5. Create GameManager as an autoload at scripts/autoload/game_manager.gd. It must have visible, clamped integer state for elena_safety (start 3, range 0–3), prototype_integrity (start 3, range 0–3), civilian_aid (start 0, range 0–10), current_checkpoint_id, active_character_id, completed_phases, and story_flags. Provide reset_new_game(), save_game(), load_game(), and safe getter/setter methods. Save as JSON in user://savegame.json. Handle missing/corrupt save files safely.
6. Create a MainMenu scene with title FINAL THAW, Start Game, Continue (disabled when no valid save), and Quit. Start Game should load scenes/levels/test_room.tscn.
7. Create a basic HUD scene or reusable UI component that visibly shows the three consequence counters.
8. Create scenes/levels/test_room.tscn: a coloured floor, collision boundaries, a controllable placeholder CharacterBody2D, and a simple camera. Movement must use Input Map actions, be normalized diagonally, and remain inside the room.
9. Create README.md with opening/running instructions, controls, architecture summary, and a concise list of phases 0–16.

ACCEPTANCE CRITERIA
- Opening project.godot in Godot 4.x has no parser errors.
- Running the project opens MainMenu.
- Start Game opens test_room and the placeholder character moves with configured inputs.
- GameManager is accessible as an autoload and HUD displays all three values.
- Saving and loading valid state works; missing/corrupt state does not crash.

DO NOT
- Create final art, combat, puzzles, levels, online features, or external dependencies.

Finish by reporting changed files, test results, known limitations, and propose this commit message exactly:
Phase 0: project foundation complete
```

---

# Fase 1 — Elena: movimiento y observación

```text
You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect the existing project before editing. Phase 0 is complete: MainMenu, GameManager, HUD, Input Map, and test_room exist.

GOAL
Implement Elena Vast's reusable movement, interaction, and scan foundation in a readable isometric 2D/2.5D room.

CONTEXT
Elena is an atmospheric systems scientist. Her gameplay focuses on navigation, observation, environmental systems, terminals, and non-lethal puzzle interaction. No combat in this phase.

DELIVERABLES
1. Create scenes/characters/elena_character.tscn using CharacterBody2D, collision, visible placeholder sprite/shape, a ground-contact shadow, and required child nodes for interaction detection.
2. Create modular scripts for Elena movement and interaction. Use smooth acceleration/deceleration, normalized diagonal input, deterministic physics movement, facing direction, and room boundary collision.
3. Use a top-down/isometric presentation: controls must feel intuitive relative to the displayed world. Document the chosen approach in comments/README.
4. Create a reusable Interactable component or base script. It must expose display_name, prompt_text, enabled state, and interact(actor). Put interactables in an interactable group.
5. Add nearest-target selection. When Elena is in range, show a clear interaction prompt. If multiple targets are in range, select deterministically: nearest distance, then stable node/path order as tie-breaker.
6. Add scan input. Scan highlights interactables within a specified radius using a simple, accessible visual treatment. It should have no cooldown and must not modify puzzle state.
7. Create scenes/levels/elena_test_room.tscn with walls, floor/readability markers, at least three interactables (terminal, lever, locked door), scan targets, and a small instruction panel.
8. Update GameManager with active_character_id support suitable for later switching, but do not implement free switching yet.

ACCEPTANCE CRITERIA
- Elena moves smoothly and cannot leave room bounds.
- Ground shadow makes location clear.
- Interaction prompt consistently selects the deterministic target.
- Scan visibly highlights nearby interactables and does not change state.
- All scripts run without errors.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 1: Elena movement and observation complete
```

---

# Fase 2 — Elena: laboratorio abandonado

```text
You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect existing reusable systems before editing. Phases 0–1 are complete.

GOAL
Create Elena's first complete puzzle chapter: an abandoned laboratory consisting of four compact, sequential puzzle rooms. Use placeholder/stylised art only.

STORY CONTEXT
Elena escapes with the Aster Protocol prototype. In this laboratory, she discovers Helix withheld a viable stabilisation method because it could not control distribution. She retrieves a partial transmission for the future Final Thaw Station.

REUSABLE SYSTEMS TO BUILD
- A lightweight skippable narrative/message panel that does not pause gameplay by default.
- Room completion/checkpoint system using GameManager.
- Reusable powered terminal, door, moving platform, hazard zone, and prototype-carrier components where practical.
- Elena must have has_aster_prototype state. It should be saved.

ROOMS
1. Lab Room 1: restore power. A fixed, clearly indicated terminal connection sequence opens the exit.
2. Lab Room 2: redirect a robotic arm. A terminal cycles the arm through fixed positions; only one permits passage.
3. Lab Room 3: traverse using a moving platform. Its cycle is fixed, readable, and optionally callable from a button. Never require frame-perfect timing.
4. Lab Room 4: prototype calibration chamber. Elena carries a visibly glowing prototype through telegraphed hazard zones. Sustained hazard exposure lowers Prototype Integrity only once per defined hazard event/checkpoint; reaching exit without damage preserves it.

REQUIREMENTS
- Every puzzle solution is fixed and readable.
- Wrong input resets only the local mechanism quickly; no long penalties.
- Connect rooms in order and save after each room.
- Show short narrative messages on room entry and puzzle completion.
- The final exit marks Phase 2 complete and presents a temporary return-to-menu or next-phase placeholder transition.

ACCEPTANCE CRITERIA
- A player can play all four rooms from start to finish without developer console actions.
- All doors, terminals, arm positions, platform motion, hazards, checkpointing, and prototype integrity work after a save/load.
- No puzzle is randomized or soft-lockable.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 2: abandoned laboratory puzzles complete
```

---

# Fase 3 — Marcus: combate básico

```text
You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect existing systems before editing. Phases 0–2 are complete.

GOAL
Implement Marcus Reyes and a compact, deterministic isometric beat-'em-up combat foundation suitable for later levels.

CONTEXT
Marcus is a former police officer. His gameplay is direct action, protection, crowd control, cover, grabs, and environmental use. Combat must feel readable and weighty, but stay technically modest.

DELIVERABLES
1. Create scenes/characters/marcus_character.tscn with CharacterBody2D, placeholder sprite, ground shadow, collision, state machine hooks, health, and HUD integration.
2. Implement movement with the same control standard as Elena plus sprint, dodge, and block. Dodge has fixed invincibility frames; expose timings in constants/resources. Block reduces a fixed percentage of frontal damage.
3. Implement combat state machine: idle, move, light_attack, heavy_attack, combo, dodge, block, hitstun, grab, throw, defeated.
4. Implement a fixed three-hit combo. Use explicit attack data (startup, active, recovery, damage, knockback) and deterministic input buffering; no random critical hits.
5. Build reusable Hitbox/Hurtbox and Health components. They must avoid double hits from a single attack and be easy to debug.
6. Create enemy_scavenger.tscn: deterministic AI state machine (idle, approach, windup, strike, recovery, hitstun, defeated). It attacks on predictable range/timing and has a visible health bar and telegraph.
7. Create a grab/throwable-object system for crates/barrels. Marcus can grab eligible object, carry it, and throw it in facing direction. Thrown objects have deterministic collision/damage and then settle or break safely.
8. Create scenes/levels/marcus_combat_arena.tscn with walls, 3–5 scavengers, throwable objects, encounter start/end state, and simple score display.
9. Add basic placeholder hit feedback: hit flash, short camera shake, particles or label feedback. Include an option/flag to reduce camera shake.

ACCEPTANCE CRITERIA
- Marcus can complete arena combat with light/heavy attacks, combo, dodge, block, grabs, and throws.
- Enemy telegraphs are readable and AI is deterministic.
- Hitbox system does not cause repeated unintended damage.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 3: Marcus combat fundamentals complete
```

---

# Fase 4 — Marcus: disturbios en la autopista

```text
You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect/reuse existing combat components. Phases 0–3 are complete.

GOAL
Build Marcus's Act I highway combat chapter: a readable linear route through a collapsed elevated highway under wildfire haze.

STORY CONTEXT
Helix patrols and displaced groups fight over supply convoys. Marcus clears a route and finds proof that his former unit has been reassigned to capture Elena.

DELIVERABLES
1. Create scenes/levels/highway_level.tscn with 4 compact arenas connected by short traversal sections. Use stylised placeholder art: cracked asphalt, guardrails, abandoned vehicles, debris, orange haze.
2. Create enemy_enforcer.tscn by reusing combat components. Enforcers have high health, slower movement, predictable block/counter timing, and clear flank/environmental weakness.
3. Create reusable ArenaController: fixed enemy spawn lists/waves, locked exits while active, clear completion condition, checkpoint after successful clear, and no random spawns.
4. Arena progression: Arena 1 introduces scavengers; Arena 2 introduces one enforcer; Arena 3 mixes scavengers/enforcers and throwable objects; Arena 4 combines prior mechanics.
5. Create breakable barricades/barriers using reusable destructible component. Heavy attacks or throws break them. At least one reveals a clear optional shortcut; no critical path may become permanently blocked.
6. Expand throwable environment with pipes, signs, car parts, and one clearly telegraphed fuel canister area effect. Keep outcomes deterministic.
7. Add route-clearing score summary: time, damage, environmental throws, clean-clear bonus. It is feedback only, not a story gate.
8. Add skippable narrative messages at chapter start, between sections, and ending. End with an evidence story flag in GameManager and a Phase 4 completion checkpoint.

ACCEPTANCE CRITERIA
- Every arena can be cleared in a fresh run and after loading a checkpoint.
- Enforcer counter/block pattern is clear and consistent.
- Waves, doors, barriers, optional path, scoring, and story flag work with no softlocks.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 4: highway riots combat complete
```

---

# Fase 5 — Minijuego: vehículo averiado

```text
You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect existing UI and GameManager. Phases 0–4 are complete.

GOAL
Create a short, deterministic UI-focused transition minigame in which Marcus repairs an emergency vehicle before a fire front reaches an underpass.

DESIGN
- Target length: 2–5 minutes for a new player.
- The correct solution is fixed and visually deducible.
- A generous fire-front timer creates urgency but does not create a hard game-over. If it expires, the story continues with a small recorded efficiency flag only.

DELIVERABLES
1. Create scenes/minigames/minigame_vehicle.tscn with a legible systems diagram, fire/smoke background, status panel, progress bar, and accessible UI.
2. Implement 5 repair controls, such as valves, fuse links, and fuel switches. Each has 2–4 states. Show visual clues that determine the single valid configuration.
3. Implement click/controller navigation and a Confirm Repair action. Correct configuration succeeds; incorrect confirmation clearly identifies that one or more systems remain incorrect without revealing the entire answer unless accessibility hint mode is enabled.
4. Implement fire timer with documented duration. On expiry, auto-complete the scene safely, set a GameManager flag such as vehicle_repaired_under_pressure, and show alternate text.
5. If solved before expiry, set vehicle_repaired_cleanly. Do not introduce a hidden counter.
6. Add skippable narrative context and transition to a Phase 6 placeholder scene if that scene does not yet exist.
7. Ensure pause handling is explicit and documented.

ACCEPTANCE CRITERIA
- The puzzle is playable using mouse and keyboard/controller navigation.
- Correct solution and timeout outcomes are deterministic and both transition cleanly.
- Save/load cannot corrupt minigame state or trap the player.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 5: broken vehicle minigame complete
```

---

# Fase 6 — Elena: refugio inundado

```text
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
```

---

# Fase 7 — Marcus: cerco de la milicia

```text
You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and reuse existing combat and ArenaController systems. Phases 0–6 are complete.

GOAL
Build Marcus's shelter-perimeter combat chapter: marksmen, readable cover/line-of-sight gameplay, and the first deterministic mini-boss.

STORY CONTEXT
Helix has blockaded the shelter. Marcus fights through to reach Elena and learns orders now say to terminate her if capture fails.

DELIVERABLES
1. Create scenes/levels/perimeter_level.tscn with 3 arenas plus a boss arena. Use barriers, sandbags, wrecks, floodlights, emergency beacons, and a visible shelter entrance.
2. Create enemy_marksman.tscn using a deterministic state machine: position, acquire line of sight, visible aim/wind-up, fixed projectile, recovery/reposition. No random accuracy.
3. Implement reusable line-of-sight and cover logic. Solid cover must reliably block projectiles.
4. Build encounters: Arena 1 has scavengers plus one marksman; Arena 2 has enforcers plus two marksmen; Arena 3 mixes types requiring movement between cover.
5. Build boss_riot_commander.tscn. Required deterministic moves: shield bash/charge, frontal shield block, tear-gas area denial. His rear is a visible weak point. Telegraph all attacks, provide safe avoidance, and add short fixed enraged behavior after a health threshold.
6. Boss arena must include meaningful solid/destructible cover and throwable objects. It must have checkpoint/retry support.
7. Add narrative messaging from start through boss defeat. Set perimeter_complete and termination_order_discovered flags in GameManager.

ACCEPTANCE CRITERIA
- Marksman line-of-sight and projectiles are reliable; cover prevents damage when physically between them.
- Boss can be beaten consistently by learning patterns and flanking; no random unavoidable damage.
- Arena progression and checkpointing work after save/load.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 7: militia encirclement combat complete
```

---

# Fase 8 — Misión conjunta: primer contacto

```text
You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect character, navigation, combat, narrative, HUD, and GameManager systems. Phases 0–7 are complete.

GOAL
Build the first Elena–Marcus mission using a deliberately simple, reliable escort design. The player controls Marcus; Elena follows only along safe authored routes and operates protected terminals.

STORY CONTEXT
Marcus breaches the shelter and finds Elena. She distrusts him. He warns that Helix has changed orders. They agree to escape temporarily.

DELIVERABLES
1. Create scenes/levels/joint_mission_1.tscn with 2–3 combat arenas, protected terminal spaces, safe waiting points, gates, and an exterior toxic-rain exit.
2. Create a reliable ElenaFollower controller. Use authored Path2D/waypoints or NavigationAgent2D only if it is stable. Elena must never wander, run through combat, or get permanently stuck. Prefer deterministic waypoint progression over dynamic pathfinding.
3. Player controls Marcus only. Elena waits at named safe points until an explicit mission event allows the next route segment.
4. Enemies target Marcus by default. Design arenas so Elena is not accidentally exposed. Implement an exceptional proximity warning and Elena Safety decrement only if an enemy crosses a defined protected boundary or scripted threat reaches her; prevent multiple decrements from a single event.
5. Create terminal/gate events: Marcus clears arena; Elena moves to protected terminal; terminal opens gate; both progress. Keep actions visible and deterministic.
6. Add HUD indicator for Elena Safety and contextual warning. Explain the value at first display.
7. Add skippable dialogue sequence for first contact and several short exchanges. Do not pause combat automatically for dialogue.
8. Build toxic rain exit sequence with stylised particles, audio placeholder, fade, Act I completion flag, save checkpoint, and transition.

ACCEPTANCE CRITERIA
- Elena never gets stuck in normal gameplay and cannot be needlessly attacked by spawned enemies.
- Every arena/gate state can be replayed after death or save/load.
- Elena Safety changes only through clearly communicated defined events.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 8: first joint mission complete
```

---

# Fase 9 — Minijuego: calibrar Aster

```text
You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect existing minigame/UI architecture. Phases 0–8 are complete.

GOAL
Create the Calibrate Aster transition minigame: Elena reconnects a fixed circuit map while Marcus drives through a storm.

STORY CONTEXT
The Aster Protocol identifies the Final Thaw Station, a mountain atmospheric relay. Helix is preparing a limited intervention that protects only privileged zones.

DELIVERABLES
1. Create scenes/minigames/minigame_aster.tscn with a legible UI circuit board, storm/vehicle background, visual state feedback, and accessibility-friendly contrast.
2. Implement 6 rotatable circuit tiles/nodes. Each has fixed rotations and one fixed solvable final circuit path from input to output. Do not randomize starting state or solution.
3. Nodes must work with click, keyboard, and controller focus.
4. Show powered segments immediately and unpowered/broken segments clearly. When path is complete, enable Confirm Calibration.
5. Add optional hint mode in settings or a clearly labeled hint control that highlights one incorrect tile without changing the solution.
6. On completion: set aster_calibrated and final_thaw_station_revealed flags, save, deliver narrative reveal, and transition toward Phase 10 placeholder/level.
7. Do not use a countdown timer. The storm is atmosphere only.

ACCEPTANCE CRITERIA
- Puzzle is solvable from visual information alone and works with all supported inputs.
- State persists safely if saved/reloaded where reasonable; at minimum, restarting is safe and no duplicate story reward occurs.
- Narrative flags save correctly.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 9: calibrate Aster minigame complete
```

---

# Fase 10 — Elena: presa colapsada

```text
You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and reuse existing environmental puzzle systems. Phases 0–9 are complete.

GOAL
Build Elena's collapsing-dam chapter: a multi-section puzzle level combining readable water behavior, platforms, power routing, valves, cranes, and limited Aster calibration.

STORY CONTEXT
Extreme rainfall is breaking the dam. Elena must cross service interiors, stabilize gates enough to access the mountain route, and preserve the Aster prototype.

DELIVERABLES
1. Create scenes/levels/dam_level.tscn with service walkways, cracked concrete, turbulent water, control panels, pipes, rain, and several sections connected in a clear sequence.
2. Reuse/enhance water system with fixed cycles or state-based behavior. For timing sections, show an understandable cycle indicator and provide adequate windows—no frame-perfect jumps.
3. Create reusable moving-platform component with fixed paths/timing, safe rider behavior, and save/load-safe state.
4. Create a power-routing puzzle that determines which platform/door/crane receives power. Make state clear in world and UI.
5. Add valve and crane interactions. Cranes should move a defined object/bridge rather than use complex physics.
6. Implement Aster calibration ability in a limited, explicit way: three level-specific calibration charges or three named calibration terminals. Use changes must be visible, saved, and never randomly fail.
7. Add telegraphed hazards: falling debris, steam vents, electrical danger. Use fixed patterns/cycles and fair checkpoints.
8. Add narrative sequence, dam-complete checkpoint, and Phase 10 completion state.

ACCEPTANCE CRITERIA
- All sections can be completed in a deterministic route after observing the environment.
- Water, platforms, power, crane, and calibration states survive save/load or reset to an unambiguous checkpoint state.
- Hazards have clear telegraphs and do not produce unavoidable failure.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 10: collapsing dam puzzles complete
```

---

# Fase 11 — Marcus: motín en el puerto

```text
You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and reuse combat, arena, civilian aid, and save systems. Phases 0–10 are complete.

GOAL
Build Marcus's port combat chapter, introduce shield units, provide optional civilian assistance, and create a deterministic second mini-boss with a crane interaction.

STORY CONTEXT
Evacuees, smugglers, and Helix forces struggle over ships that are not allowed to leave. Marcus clears a route to the mountain transit hub.

DELIVERABLES
1. Create scenes/levels/port_level.tscn with docks, containers, cranes, storm sea, fuel canisters, connected arenas, and optional rescue locations.
2. Create enemy_shield.tscn. It has clear frontal damage immunity/reduction, slow movement, shield-bash telegraph, and readable counterplay: flank, grab/bypass, or environment stun.
3. Create three fixed combat arenas that combine all four existing enemy types in deliberate, learnable placements.
4. Add at least two optional civilian rescue tasks. They may require breakable barriers or clearing a small threat. They must be safe, visible, optional, increment Civilian Aid once, and persist.
5. Create boss_transport_captain.tscn. Required moves: ground slam with avoidable shockwave, telegraphed cargo throw, deterministic reinforcement call. Use a fixed boss state machine.
6. Add a crane interaction in the boss arena. Marcus can operate it during a clearly available window to drop cargo, deal major fixed damage, and stun the boss. It must be optional and never soft-lock the fight.
7. Add chapter messages, checkpointing, and port_complete flag.

ACCEPTANCE CRITERIA
- Shield mechanics are understandable on first introduction.
- Boss is beatable through basic combat even if crane is unused, while crane materially helps.
- Rescue counter cannot be farmed or duplicated through reloads.
- All combat remains deterministic and stable on retry.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 11: port mutiny combat complete
```

---

# Fase 12 — Misión conjunta: cambio libre

```text
You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect both character systems and all reusable components. Phases 0–11 are complete.

GOAL
Implement controlled, reliable free switching between Elena and Marcus in the mountain transit hub, then use it in three combined puzzle-combat rooms.

STORY CONTEXT
Elena and Marcus now cooperate, though they disagree over whether saving the climate matters if Helix controls the solution.

CORE RULES
- Player switches via switch_character input.
- The inactive character is safe and predictable. Prefer standing at position with invulnerability only when outside active encounter design; do not allow abuse that trivializes combat. Clearly document exact behavior.
- Camera follows active character. Do not allow switching if a scripted sequence, transition, or invalid state would break it; show clear feedback.

DELIVERABLES
1. Create a reusable CharacterSwitchController and clear HUD active-character indicator.
2. Build scenes/levels/transit_hub.tscn with three sequential rooms:
   - Room 1: Elena disables security via a timed terminal interaction while Marcus protects her from fixed waves.
   - Room 2: Marcus moves a heavy object to create access, then Elena powers a lift.
   - Room 3: Elena controls lighting; darkness enables Marcus's single-target stealth takedown on eligible unaware enemies. Some enemies with lights are immune.
3. Add Elena timed security interaction. It must visibly progress, interrupt under defined conditions, and reset fairly.
4. Add Marcus heavy-object movement using a controlled, collision-safe approach. Avoid emergent physics that risks softlocks.
5. Add lighting state system with clear visual difference, accessibility-safe alternative indicators, and deterministic enemy behavior changes.
6. Create dialogue showing growing respect and the core disagreement. Dialogue is skippable and non-blocking during normal gameplay.
7. At the end, present a clear binary, saved choice: preserve evidence of Helix's earlier Aster failure, or erase it to prioritize immediate activation. Store evidence_choice as preserve or erase.

ACCEPTANCE CRITERIA
- Switching never leaves either character unusable, stuck, duplicated, or without a camera target.
- Each room requires both protagonists in a meaningful way.
- Security, heavy object, lighting, stealth, narrative choice, checkpointing, and save/load work.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 12: transit hub joint mission complete
```

---

# Fase 13 — Estación Final Thaw

```text
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
```

---

# Fase 14 — Jefe final: comandante de recuperación Helix

```text
You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and reuse the combat, switching, hazard, checkpoint, and narrative systems. Phases 0–13 are complete.

GOAL
Build the final boss in the atmospheric control chamber. It must require Elena and Marcus coordination, be fully deterministic, readable, and fair.

BOSS DESIGN
The Helix Retrieval Commander claims the Aster Protocol belongs to Helix. The boss has fixed phases and telegraphed moves: ranged energy blast, temporary shield barrier, reinforcement call, and reactor sabotage attempt.

DELIVERABLES
1. Create scenes/levels/boss_arena.tscn with a clear chamber layout: reactor/prototype, three calibration panels, vents/overload panels, boss center zone, fixed reinforcement spawn areas, and safe movement lanes.
2. Create boss_helix_commander.tscn using a documented deterministic state machine. No random move selection. Use a repeating or health-threshold-based attack order.
3. Create three Elena Aster calibration interactions. Each has visible progress, defined interruption/reset behavior, and a nearby/meaningful protection task for Marcus. Completing each creates a fixed boss vulnerability window.
4. During vulnerability, Marcus can deal standard damage. Outside it, boss damage reduction/invulnerability must be visibly communicated.
5. Implement boss moves: telegraphed dodgeable energy blast; temporary shield barrier; fixed reinforcement call using existing enemies; reactor sabotage attempt with clear warning and counterplay.
6. Final phase: Elena maintains reactor balance through simple repeated interaction/monitoring while Marcus stops boss pressure. Keep inputs manageable.
7. Add optional environmental actions such as venting steam or overload stun. Each must have visible availability, fixed effect, cooldown/limited charge, and never be mandatory.
8. Add boss checkpoint policy: retries resume at a documented fair checkpoint.
9. Add dialogue and transition to epilogue after victory.

ACCEPTANCE CRITERIA
- Boss can be consistently defeated through learned patterns without random luck.
- All attacks are telegraphed and avoidable.
- Calibration/switching design requires both characters without creating input confusion.
- Retry, save/load, and victory transition are stable.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 14: final boss battle complete
```

---

# Fase 15 — Epílogo: elección de primavera

```text
You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect GameManager consequence state and story choices. Phases 0–14 are complete.

GOAL
Create the epilogue, deterministic ending selection, credits, and a safe New Game loop.

ENDING RULES
Use the saved counters and final evidence choice. Document exact thresholds in code and UI/debug documentation.
- Fragile Thaw has priority if elena_safety <= 1 OR prototype_integrity <= 1.
- Otherwise Public Thaw if civilian_aid >= 4 AND prototype_integrity >= 2 AND evidence_choice == "preserve".
- Otherwise Guarded Thaw.

DELIVERABLES
1. Create scenes/ui/epilogue.tscn with readable story cards or scenes, clearing-weather presentation, and placeholder character/environment art.
2. Implement one EndingResolver function/resource that applies the rules above. It must be testable and return a named ending key.
3. Implement concise narrative content for Public Thaw, Guarded Thaw, and Fragile Thaw.
4. Show clear final statistics: civilians aided, Elena Safety, Prototype Integrity, final evidence decision, and ending title.
5. Create scrolling credits with placeholders for developer names and a thank-you. Make it skippable after a short delay.
6. Add New Game option that calls GameManager.reset_new_game(), clears/replaces save safely, and returns to a new start flow.
7. Add an ending-viewed flag and ensure replay/new game behavior is coherent.
8. Add lightweight test hooks or documented developer steps to verify all three endings without replaying full game.

ACCEPTANCE CRITERIA
- Same saved inputs always result in the same ending.
- Priority rule for Fragile Thaw works.
- Credits and New Game do not trap the player or leave old consequence state.
- All epilogue text and buttons function without errors.

Finish with changed files, test results, known limitations, and propose this commit message exactly:
Phase 15: epilogue and endings complete
```

---

# Fase 16 — QA, optimización y build de lanzamiento

```text
You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect the full project. Phases 0–15 are complete.

GOAL
Perform release-focused QA, correct verified defects, add essential accessibility settings if missing, prepare export configuration, and create release documentation. Do not add new gameplay features.

DELIVERABLES
1. Create docs/qa_checklist.md covering every menu, level, puzzle, enemy type, boss move, minigame, character switch scenario, save/load/checkpoint behavior, all consequence counters, all three endings, controls, and exported builds.
2. Run a systematic full-game verification. Record actual issues found in docs/qa_results.md with severity, reproduction steps, resolution, and verification status. Do not invent test results.
3. Fix confirmed blockers first: crashes, parser errors, softlocks, broken progression, corrupted save handling, incorrect ending logic, and input failures. Then address clear visual/audio defects.
4. Profile performance using Godot tooling where available. Optimize only verified bottlenecks: excessive nodes/particles, unnecessary processing, expensive effects. Preserve gameplay behavior.
5. Ensure essential accessibility: input remapping or documented configurable bindings; text size setting (normal/large); reduced camera shake; reduced weather/effect intensity; visual non-colour-only puzzle indicators.
6. Configure export presets for Windows. Configure macOS/Linux only if export templates and practical testing are available; do not falsely claim untested builds work.
7. Create docs/release_checklist.md with version 1.0.0, tested platforms, known issues, store asset checklist, screenshots/trailer placeholders, description placeholder, content warning review, and release sign-off fields.
8. Update README.md with installation/run instructions for the release build, controls, accessibility, credits placeholder, and license decision placeholder. Do not choose a license without asking; mark it clearly as TODO if undecided.
9. If Git is available, ensure clean working tree, make final version commit, and create annotated tag v1.0.0 only after checks pass. If any release blocker remains, do not tag; report it instead.

ACCEPTANCE CRITERIA
- QA documentation reflects real verification, not assumptions.
- Full game can reach each ending using documented test steps.
- Windows export is created and run-tested if export tooling is available.
- No knowingly unresolved release-blocking softlock, crash, or corrupt-save issue remains.

Finish with changed files, actual QA results, remaining known issues, build test results, and propose this commit message exactly:
Phase 16: QA, optimization, and release build complete
```
