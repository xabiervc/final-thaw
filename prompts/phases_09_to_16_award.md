# Phases 9-16 Award-Level Prompts

## Phase 9: Calibrate Aster Minigame

**File**: `phase_09_calibrate_aster_award.md`

**Concept**: UI circuit puzzle. Elena reconnects fixed circuit map while Marcus drives through storm. 2-5 min, visually deducible solution.

**Key Features**:
- **Scene**: `scenes/minigames/minigame_aster.tscn`—legible UI circuit board (grid 6x4 tiles), storm/vehicle background (parallax: rain streaks 50px/s, lightning flashes 2s interval), visual state feedback (powered segments glow cyan #00FFFF, unpowered gray #808080), accessible UI (high contrast, 75%-200% text scale)
- **6 rotatable tiles**: Each tile has 4 rotations (0°, 90°, 180°, 270°). Fixed starting state, fixed solution. Circuit path: input (left) → tiles → output (right). Visual: circuit lines glow when powered
- **Controls**: Click to rotate (90° CW), keyboard (Q/E rotate CCW/CW, arrow keys navigate), controller (D-pad navigate, A rotate). Focus highlight (cyan border 3px)
- **Power flow animation**: Electricity visibly travels through correct path (cyan particles, 200px/s), stops at breaks (red spark effect)
- **Confirm Calibration**: Button enabled only when path complete (input connected to output). On press: success animation (full circuit glows, 2s), narrative reveal
- **Hint mode**: Optional (H key or settings toggle). Highlights one incorrect tile (red pulse 1s) without changing solution. 3 charges, regenerate on scene reload
- **No timer**: Storm is atmosphere only (audio: rain, thunder, vehicle engine 800Hz hum)
- **Narrative**: On completion: "Aster calibrated. Final Thaw Station identified: mountain atmospheric relay, coordinates locked. Helix preparing competing intervention—protected zones only." Set `aster_calibrated = true`, `final_thaw_station_revealed = true`. Save. Transition to Phase 10 placeholder

**Acceptance**: Solvable from visual information alone. Works with mouse/keyboard/controller. State persists safely (restart safe, no duplicate story reward). Narrative flags save correctly. 60 FPS. Commit: `Phase 9: calibrate Aster minigame complete`

---

## Phase 10: Collapsing Dam Puzzles

**File**: `phase_10_collapsing_dam_award.md`

**Concept**: Elena's multi-section puzzle level. Water behavior, moving platforms, power routing, valves, cranes, limited Aster calibration.

**Key Features**:
- **Scene**: `scenes/levels/dam_level.tscn`—5-6 sections connected sequentially. Service walkways (metal grating #606060), cracked concrete (texture with fissures), turbulent water (animated blue-green #40A0A0, particle spray), control panels (interactive terminals), pipes (cylinders #808080), rain (exterior sections, cyan particles 100px/s)
- **Water system**: Fixed cycles (10s rise / 10s fall) OR state-based (pump/valve controlled). Visual: particle streams show current, pressure gauges (green/yellow/red). Timing sections: understandable cycle indicator (arrow showing rise/fall direction, 3s advance warning), generous windows (no frame-perfect jumps—minimum 2s safe window)
- **Moving platform**: Fixed Path2D, constant speed (100px/s) or wait-at-endpoints (2s wait). Rider behavior: character moves with platform (no sliding), emergency stop button (halts mid-travel). Save/load-safe state (platform position serialized)
- **Power routing puzzle**: 3 circuits (red=emergency, blue=life support, yellow=machinery). Player connects power source to devices. Too many devices = overload (wires glow orange #FFA500, spark, 2s blackout, reset required). Visual: wires glow when powered, pulse when overloaded
- **Valve/crane interactions**: Valves redirect water (90° rotation). Cranes move defined objects/bridges (not complex physics—predefined animation: lift 2s, move 3s, lower 2s)
- **Aster calibration (limited)**: 3 level-specific calibration charges OR 3 named calibration terminals. Each use: consume 1 charge, solve minor puzzle (align frequency dial, hold connection 3s). Visual: prototype glows brighter, cyan aura intensifies. Uses must be visible, saved, never randomly fail
- **Hazards**: Falling debris (telegraph: shadow appears 1s before impact, dodgeable), steam vents (telegraph: pressure gauge rises 2s before burst, avoid cone 60° arc), electrical danger (telegraph: wires spark 0.5s before electrification, don't touch). Fixed patterns/cycles, fair checkpoints (respawn before hazard, not in it)
- **Narrative**: Entry ("Dam failing. If it breaks, everything downstream..."), mid ("Aster calibration critical. But the structural integrity..."), exit ("Dam stable. For now. Marcus at the port. Helix mobilizing."). Checkpoint, Phase 10 complete flag

**Acceptance**: All sections completable in deterministic route. Water/platforms/power/crane/calibration states survive save/load or reset to unambiguous checkpoint. Hazards have clear telegraphs, no unavoidable failure. 60 FPS. Commit: `Phase 10: collapsing dam puzzles complete`

---

## Phase 11: Port Mutiny Combat

**File**: `phase_11_port_mutiny_award.md`

**Concept**: Marcus's port combat. Shield enemies, optional civilian assistance, deterministic second mini-boss (Transport Captain) with crane interaction.

**Key Features**:
- **Scene**: `scenes/levels/port_level.tscn`—docks (wooden planks #8B4513), containers (stacked boxes #404040), cranes (tall structures, animated boom), storm sea (animated dark blue #204060, wave particles), fuel canisters (red #E24A4A, explosive), 3 arenas connected, optional rescue locations (marked with distress flares #FFD700)
- **Enemy Shield** (`scenes/enemies/enemy_shield.tscn`):
  - **Stats**: Health 75, frontal immunity (100% damage reduction from front 180° arc), slow movement (120 px/s)
  - **Attacks**: Shield bash (telegraph 1s, lunge 0.3s, 25 damage, knockback 300px), no ranged attacks
  - **Counterplay**:
    - Flank: Rear 180° arc = 100% damage (no reduction). Telegraph: shield turns slowly (2s for 180°), player must reposition
    - Grab/bypass: Marcus can grab shield (if stamina ≥40), throw over shoulder (50 damage, ignores shield). Animation: 1s grab, 0.5s throw
    - Environment stun: Throw fuel canister at shield (40 damage + explosion = shield stunned 3s, immunity disabled)
- **3 fixed combat arenas**:
  - Arena 1: 3 Scavengers + 1 Shield. Teaches shield frontal immunity, flank requirement.
  - Arena 2: 2 Scavengers + 2 Enforcers + 2 Shields. Teaches prioritization (Shields first or last?).
  - Arena 3: 4 Scavengers + 2 Enforcers + 3 Shields + fuel canisters. Final test combining all.
- **Optional civilian rescues (2+)**: Marked with distress flares (yellow glow, audio beep 440Hz every 2s). Require: breakable barrier (50 HP) OR clearing 1-2 enemies. Safe (no time limit), visible, optional, increment `civilian_aid` once (max 10), persist after save/load. Dialogue: "Ships never came. You... you came. Thank you."
- **Boss: Transport Captain** (`scenes/bosses/boss_transport_captain.tscn`):
  - **Stats**: Health 150, armor 25 (destroyable with 25 damage)
  - **Attacks**:
    - Ground slam: Telegraph 1.5s (raises weapon overhead, red glow), shockwave (200px radius, 40 damage, dodgeable by jumping or backstep)
    - Cargo throw: Telegraph 2s (picks up crate, aims), projectile (300px/s, 30 damage, avoidable by sidestepping)
    - Reinforcement call: Every 30s, spawns 2 Scavengers at fixed positions (corners). Telegraph: Captain blows whistle (audio 880Hz, 1s), Scavengers drop from cranes (2s animation)
  - **Phases**: 100%→50% (normal), 50%→0% (enraged: attack speed +25%, reinforcement call every 20s)
- **Crane interaction**: In boss arena, crane control terminal (green button #4A90E2). During boss fight, crane hook hangs above arena. Player can:
  1. Lure boss under hook (Captain follows player)
  2. Press terminal (1s interact)
  3. Crane drops cargo (500 damage, instant armor break, stuns boss 5s)
  - **Availability**: Clear window (boss not attacking, player at terminal, boss under hook). Telegraph: crane hook glows cyan when aligned
  - **Optional**: Boss beatable without crane (basic combat). Crane materially helps (500 damage = 33% of boss health, armor break, free DPS window)
  - **Never soft-locks**: If crane used, boss still fightable (stunned, not skipped)
- **Narrative**: Entry ("Port's a warzone. Evacuees, smugglers, Helix. Everyone wants the ships."), mid ("Captain's coordinating. Take him out, the rest scatter."), exit ("Port clear. Mountain transit hub next. Elena's waiting."). Checkpoint, `port_complete = true`

**Acceptance**: Shield mechanics understandable on first introduction (flank = damage, front = immune). Boss beatable through basic combat even if crane unused, while crane materially helps. Rescue counter cannot be farmed/duplicated through reloads. All combat deterministic, stable on retry. 60 FPS. Commit: `Phase 11: port mutiny combat complete`

---

## Phase 12: Transit Hub Joint Mission (Free Switching)

**File**: `phase_12_free_switching_award.md`

**Concept**: Controlled, reliable free switching between Elena and Marcus. 3 combined puzzle-combat rooms.

**Key Features**:
- **CharacterSwitchController** (`scripts/autoload/character_switch_controller.gd`):
  ```gdscript
  var active_character: String = "marcus"  # Start as Marcus
  var elena_node: Node2D
  var marcus_node: Node2D
  var can_switch: bool = true
  var switch_cooldown: float = 0.0
  
  func _physics_process(delta):
      if Input.is_action_just_pressed("switch_character") and can_switch and switch_cooldown <= 0.0:
          switch_character()
      switch_cooldown -= delta
  
  func switch_character():
      var old_active = active_character
      active_character = "elena" if active_character == "marcus" else "marcus"
      
      # Swap control
      get_node(old_active).set_process_input(false)
      get_node(old_active).collision_layer = 2  # Inactive layer (invulnerable)
      get_node(active_character).set_process_input(true)
      get_node(active_character).collision_layer = 1  # Active layer
      
      # Camera follow
      var camera = get_node("../Camera2D")
      camera.position = get_node(active_character).position
      
      # Feedback
      emit_signal("character_switched", active_character)
      switch_cooldown = 0.5  # Prevent accidental double-switch
  ```
  - **Instant swap**: <100ms transition (no loading, just node activation swap)
  - **Inactive character**: Frozen in place (`set_process_input(false)`), invulnerable (`collision_layer = 2`), subtle idle animation (breathing, scanning—1.02 scale pulse, 2s loop)
  - **Contextual lockout**: `can_switch = false` during scripted sequences, mid-air (check `is_on_floor()`), or in combat arenas (ArenaController sets flag). Clear UI feedback: "Cannot switch now" (red text, 1s)
  - **Camera**: Follows active character smoothly (drag margin 0.2). Character-specific: Elena = slightly higher (zoom 0.9), wider FOV for puzzle readability. Marcus = lower (zoom 1.0), tighter FOV for combat intensity
- **HUD active-character indicator**: Top-left corner. Portrait (Elena blue #4A90E2, Marcus orange #E26A4A), name text ("Playing as: Elena" / "Playing as: Marcus"), 75%-200% scalable
- **Scene**: `scenes/levels/transit_hub.tscn`—3 sequential rooms (600x400px each), connected by corridors (200px)
- **Room 1: Elena disables security, Marcus protects**:
  - Setup: Elena at terminal (protected alcove, collision barriers), Marcus in arena (400x400px combat zone)
  - Mechanic: Elena interacts with terminal (3s hold, progress bar). Marcus defends from 3 waves of enemies (2 Scavengers per wave, 10s between waves)
  - Interrupt: If Marcus takes >50 damage or enemies enter Elena's alcove, terminal interaction resets (progress bar empties, 2s cooldown)
  - Success: Terminal hacked, security disabled, door opens, both proceed
- **Room 2: Marcus moves heavy object, Elena powers lift**:
  - Setup: Heavy crate (500kg, Marcus can push at 50px/s), lift platform (requires power)
  - Mechanic: Marcus pushes crate onto lift (10s travel). Elena activates power terminal (2s interact). Lift rises with crate (5s animation). Marcus steps on other side, proceeds
  - Collision-safe: Crate has fixed path (no physics—predefined animation), can't be knocked off
- **Room 3: Elena controls lighting, Marcus stealth takedown**:
  - Setup: Dark room (ambient light 20% intensity), 3 enemies (2 Scavengers + 1 Marksman), light switches (3 terminals around room)
  - Mechanic: Elena moves between terminals (2s travel each), toggles lights (on/off, 1s animation). Lights off = room dark (5% ambient). Lights on = room lit (100% ambient)
  - Stealth: Darkness enables Marcus single-target stealth takedown (approach from behind, 1s interact, instant kill on unaware enemies). Lights on = enemies alert (can't stealth)
  - Immune enemies: Marksman has flashlight (cone 60°, 200px range). Even in darkness, flashlight reveals Marcus if in cone (red alert, enemies attack)
  - Solution: Elena dims lights → Marcus stealths first Scavenger → Elena toggles different lights to distract → Marcus stealths second → Elena keeps lights on for Marksman (flashlight useless when main lights on) → Marcus approaches from flank, combat kill
- **Dialogue**: Growing respect + core disagreement. Skippable, non-blocking:
  - Elena: "Your methods are crude. But effective."
  - Marcus: "Your plans need someone to watch your back."
  - (After evidence room, Phase 12 choice—see below)
- **Evidence choice (binary, saved)**:
  - Context: Terminal shows evidence—Helix engineered earlier Aster test failure to justify emergency authority
  - Option A (Preserve): "We expose them. Delay deployment, but world knows the truth." Set `evidence_choice = "preserve"`, `evidence_preserved = true`
  - Option B (Erase): "We activate now. Climate can't wait for politics." Set `evidence_choice = "erase"`, `evidence_erased = true`
  - UI: Two buttons (green "Preserve Evidence", red "Erase Evidence"), 2s confirmation (prevent misclick), skippable (defaults to "Preserve" if skipped)
  - Saved in GameManager: `story_flags["evidence_choice"] = "preserve"` or `"erase"`

**Acceptance**: Switching never leaves either character unusable, stuck, duplicated, or without camera target. Each room requires both protagonists meaningfully (can't solo). Security/heavy object/lighting/stealth/narrative choice/checkpointing/save-load work. 60 FPS. Commit: `Phase 12: transit hub joint mission complete`

---

## Phase 13: Final Thaw Station Level

**File**: `phase_13_final_thaw_station_award.md`

**Concept**: Longest chapter (20-35 min). 5-6 sections recombining all mechanics. Weather stages. Evidence final choice.

**Key Features**:
- **Scene**: `scenes/levels/final_thaw_station.tscn`—5-6 connected sections (indoor/outdoor transitions). Mountain research architecture (concrete #808080, steel beams #606060), Helix barricades (red #E24A4A, surveillance cameras rotating 2s cycle), atmospheric machinery (large cylinders, pipes, control panels)
- **Weather stages** (progressive intensity):
  - Stage 1 (Sections 1-2): Light snow (white particles 20px/s, 30% density). Visual: gentle accumulation on surfaces. Mechanical: none (atmosphere only)
  - Stage 2 (Sections 3-4): Blizzard (white particles 50px/s, 70% density, wind sway 10px oscillation). Visual: reduced visibility (fog 50% opacity). Mechanical: player movement speed -10% (wind resistance)
  - Stage 3 (Sections 5-6): Extreme storm (white particles 80px/s, 100% density, wind sway 20px, lightning flashes 3s interval). Visual: near-zero visibility (fog 80% opacity), screen shake 1px continuous. Mechanical: player movement speed -20%, Elena scan range -25% (weather interference)
  - **Accessibility option**: Reduce weather intensity (toggle in options). Stage 1 = no particles, Stage 2 = 30% density, Stage 3 = 50% density. Never obscures critical interactables/hazards
- **Sections** (5-6, sequential):
  1. **Security surveillance disable + patrol combat**: Elena disables cameras (terminal, 3s interact), Marcus clears patrol (2 Scavengers + 1 Marksman). Stealth approach possible if Elena disables first.
  2. **Power reroute + defensive encounter**: Elena reroutes power (3 circuits: red/blue/yellow, match colors), Marcus defends terminal from 2 waves (3 enemies per wave). Elena must complete before Marcus overwhelmed (soft timer: enemies spawn faster after 60s).
  3. **Barricade clearing + atmospheric calibration**: Marcus breaks barricade (100 HP, 10s heavy attacks), Elena calibrates atmospheric vent (frequency dial mini-game: align 3 dials to green zones, 5s hold). Parallel tasks.
  4. **Rapid switching section**: Elena stabilizes reactor (hold interaction 10s, progress bar), Marcus prevents sabotage waves (3 waves, 2 enemies per wave, 15s between). Player must switch rapidly (Elena hold → Marcus defend → switch back before Elena interrupted).
  5. **Optional researcher rescue/equipment repair**: Side area (marked "RESEARCHER TRAPPED"). Rescue requires: navigate hazard corridor (electrical, thermal, toxic—apply all 3), open locked door (power + valve puzzle). Reward: +2 Civilian Aid, shortcut to Section 6 (skip long corridor).
  6. **Final approach**: Long corridor (100px wide, 400px long), Helix guards (2 Enforcers + 1 Shield), evidence discovery terminal at end.
- **All existing enemy types**: Scavenger, Enforcer, Marksman, Shield. No new classes. Deliberate placements (not random—designed encounters).
- **Evidence discovery scene**: Terminal at end of Section 6. Interactive (2s hold). Cinematic (non-skippable first time, skippable on replay):
  - Text: "Helix Internal Memo. Subject: Aster Protocol Test 7-C. Status: DELIBERATELY MISREPORTED. Actual result: 94% stabilization efficiency. Public report: 12% efficiency, 'unstable'. Conclusion: Withhold viable method. Justify emergency authority. Control deployment."
  - Choice (final, overwrites Phase 12 preliminary):
    - Preserve: "Release this. World deserves to know." Set `evidence_choice = "preserve"`, `evidence_preserved = true`, `helix_exposed = true`
    - Erase: "Delete it. Activate Aster now. Politics later." Set `evidence_choice = "erase"`, `evidence_erased = true`, `helix_hidden = true`
  - UI: Same as Phase 12 (two buttons, 2s confirmation, skippable defaults to Preserve)
- **Narrative**: Entry ("Final Thaw Station. Where Aster goes live. Or dies."), mid ("Helix won't let us through. They know what we're carrying."), exit ("Commander waiting. Atmospheric control. This ends now."). Checkpoints after major sections (Sections 2, 4, 6). `final_thaw_station_complete = true`. Transition to boss arena (Phase 14).

**Acceptance**: Level is coherent 20-35 min chapter using existing systems (no feature creep). Weather remains readable (critical interactables always visible). Optional aid never blocks main path, persists correctly. Evidence choice unmistakable (clear text, distinct buttons), saved. 60 FPS. Commit: `Phase 13: Final Thaw Station level complete`

---

## Phase 14: Final Boss Battle

**File**: `phase_14_final_boss_award.md`

**Concept**: Helix Commander boss. Requires Elena + Marcus coordination. Fully deterministic, readable, fair.

**Key Features**:
- **Scene**: `scenes/levels/boss_arena.tscn`—clear chamber layout (800x600px). Reactor/prototype (center, glowing cylinder #00FFFF, 100px height), 3 calibration panels (around reactor, 120° apart, interactive terminals), vents/overload panels (4 corners, interactive), boss center zone (marked circle 200px radius), fixed reinforcement spawn areas (corners, 4 positions), safe movement lanes (clear paths between cover)
- **Boss: Helix Commander** (`scenes/bosses/boss_helix_commander.tscn`):
  - **Stats**: Health 300, armor 75 (destroyable with 75 damage), speed 180 px/s
  - **Deterministic state machine** (no random move selection—fixed order or health-threshold-based):
    - Phase 1 (100%→66%): Energy blast (3s cycle) → Shield barrier (6s duration) → Reinforcements (2 Scavengers) → repeat
    - Phase 2 (66%→33%): Energy blast (2s cycle) → Shield barrier (4s) → Reinforcements (2 Scav + 1 Enf) → Reactor sabotage attempt → repeat
    - Phase 3 (33%→0%): Energy blast (1.5s cycle) → Shield barrier (3s) → Reinforcements (4 Scav + 2 Enf) → Reactor sabotage (2s) → Enraged (attack speed +30%) → repeat
  - **Attacks**:
    - Ranged energy blast: Telegraph 1s (arm raises, cyan glow #00FFFF), projectile (400px/s, 50px radius, 40 damage), dodgeable (150ms window)
    - Temporary shield barrier: Frontal 180° arc, 80% damage reduction, 3-6s duration (varies by phase). Telegraph: shield generator deploys (1s, mechanical sound)
    - Reinforcement call: Fixed spawn (corners), 2-6 enemies depending on phase. Telegraph: Commander presses comms device (1s, audio 880Hz), enemies drop from ceiling (2s animation)
    - Reactor sabotage (Phase 2+): Commander moves to reactor (5s travel), interacts (3s), reactor overheats (red glow #E24A4A, 10 damage/sec to all characters in arena). Counterplay: Elena or Marcus can interrupt (attack Commander during interaction, 3 hits = interrupt)
- **3 Elena Aster calibration interactions** (panels around reactor):
  - **Panel mechanics**: Elena interacts (hold 5s, progress bar). Panel glows cyan when active. Completing panel = boss vulnerability window (10s, shield disabled, 100% damage from all sources)
  - **Interruption/reset**: If Elena takes damage during calibration, progress resets (not lost entirely—resume from 0%). If Marcus dies, calibration pauses (can't complete until Marcus revived)
  - **Protection task for Marcus**: While Elena calibrates, Marcus must defend (keep enemies away from Elena, keep Commander occupied). Commander prioritizes Elena during calibration (threat priority shift)
  - **Vulnerability window**: After panel complete, boss shield disabled (10s). Marcus can deal standard damage (no reduction). Visual: boss glows red #E24A4A (vulnerable), audio: shield hum stops
- **Boss damage outside vulnerability**: 80% reduction (shield active). Visual: boss glows blue #4A90E2 (shielded), projectiles deflect (particle effect)
- **Final phase (Phase 3, 33% health)**: Elena maintains reactor balance (repeated interaction: press button every 3s to vent pressure, 5 times total). Marcus stops boss pressure (keep Commander busy, defeat reinforcements). Inputs manageable (Elena: 5 button presses over 15s. Marcus: standard combat)
- **Optional environmental actions**:
  - Vent steam: Terminal (green button #4A90E2). Press = steam vent activates (200px radius cloud, 5s duration, 10 damage/sec to boss + enemies in cloud). Cooldown: 20s. Limited charge: 3 uses per fight
  - Overload stun: Terminal (red button #E24A4A). Press = arena-wide overload (all enemies stunned 3s, boss stunned 5s). Cooldown: 60s. Limited charge: 1 use per fight
  - **Visibility**: Both terminals clearly marked (glowing buttons, 100px height). Availability shown (green = ready, gray = cooldown). Effect telegraphed (steam appears, screen flashes for overload). Never mandatory (boss beatable with basic combat)
- **Boss checkpoint policy**: Retries resume at fair checkpoint (start of current phase, not phase transition). Example: Die at 20% health (Phase 3), restart at 33% (Phase 3 start), not 66% (Phase 2).
- **Dialogue**:
  - Start: Commander: "You think you can override decades of planning with a prototype and a conscience?"
  - Marcus: "No. Just your monopoly on who gets to live."
  - Phase 2: Commander: "You don't understand what you're destroying."
  - Elena: "A system that serves only some is not recovery. It's a filter."
  - Phase 3: Commander: "Perhaps you're right. But the world won't thank you for this."
  - Marcus: "It doesn't need to. It needs to exist."
  - On defeat: Commander collapses (2s animation), reactor stabilizes (cyan glow, hum pitch drops). Transition to epilogue (Phase 15).

**Acceptance**: Boss consistently defeatable through learned patterns (no random luck). All attacks telegraphed (≥1s warning), avoidable (dodgeable or blockable). Calibration/switching design requires both characters (Elena calibrates, Marcus protects) without creating input confusion (clear prompts, no overlapping interactions). Retry/save-load/victory transition stable. 60 FPS. Commit: `Phase 14: final boss battle complete`

---

## Phase 15: Epilogue and Endings

**File**: `phase_15_epilogue_award.md`

**Concept**: Epilogue, deterministic ending selection, 3 fully-voiced cinematics (90+ sec each), credits, safe New Game loop.

**Key Features**:
- **Scene**: `scenes/ui/epilogue.tscn`—readable story cards or scenes (full-screen backgrounds), clearing-weather presentation (storm recedes, blue sky emerges), placeholder character/environment art (silhouettes, stylized)
- **EndingResolver** (`scripts/autoload/ending_resolver.gd`):
  ```gdscript
  func resolve_ending() -> String:
      var elena_safety = GameManager.get_elena_safety()
      var prototype_integrity = GameManager.get_prototype_integrity()
      var civilian_aid = GameManager.get_civilian_aid()
      var evidence_choice = GameManager.story_flags.get("evidence_choice", "preserve")
      
      # Priority rule: Fragile Thaw if critical stats too low
      if elena_safety <= 1 or prototype_integrity <= 1:
          return "fragile_thaw"
      
      # Public Thaw: high aid + good integrity + evidence preserved
      if civilian_aid >= 4 and prototype_integrity >= 2 and evidence_choice == "preserve":
          return "public_thaw"
      
      # Default: Guarded Thaw
      return "guarded_thaw"
  ```
  - **Testable**: Function returns named ending key ("public_thaw", "guarded_thaw", "fragile_thaw"). Unit test in `tests/test_ending_resolver.gd`
  - **Deterministic**: Same saved inputs always result in same ending (no randomness)
- **3 endings** (90+ sec cinematics, fully voiced—placeholder voice acting until final recording):
  - **Public Thaw**:
    - **Visual**: Time-lapse Earth recovering. Storms receding (satellite view, hurricane clouds dissipate over 10s). Green returning (vegetation spread, brown→green transition). People emerging (silhouettes exiting shelters, looking at sky)
    - **Audio**: Full orchestra (strings, brass, choir), ascending progression (C minor → C major), hopeful tempo (80 BPM)
    - **Sequence**:
      1. 0:00-0:15: Aster activates. Global map shows stabilization waves spreading (cyan rings from Final Thaw Station)
      2. 0:15-0:30: Helix facilities opening, data released. Scientists worldwide accessing Aster (montage: labs, universities, community centers)
      3. 0:30-0:45: Communities rebuilding. Solar panels (rooftops), vertical farms (skyscrapers), water systems (pipes, pumps)
      4. 0:45-1:00: Elena at Iris's grave (simple marker, flowers). Voice: "It's done. The protocol is free. You would have loved this world."
      5. 1:00-1:15: Marcus at police memorial (wall with names). Placing badge. Voice: "I'm not that person anymore. I hope you can forgive me."
      6. 1:15-1:30: Global montage—children playing outside without masks, birds returning (flock flying), first snow that isn't toxic (white flakes, clean)
    - **Final shot**: Elena and Marcus on mountain (same as Final Thaw Station), watching sunrise (orange/pink sky, 5s hold). No words.
    - **Text**: "The climate stabilized over 17 years. Helix was disbanded. The Aster Protocol became public domain. Recovery was not easy. But it was possible."
  - **Guarded Thaw**:
    - **Visual**: Split screen—protected zones thriving (left: green parks, clean buildings, happy people), outside struggling (right: brown wasteland, ruined structures, desperate people)
    - **Audio**: Somber strings (cello, bass), unresolved harmony (C minor, no resolution to major), slow tempo (60 BPM)
    - **Sequence**:
      1. 0:00-0:20: Aster activates. Protected zones bloom immediately (satellite: green circles appear, expand slowly)
      2. 0:20-0:40: Helix checkpoints, ID scans, rationing. "ACCESS DENIED" stamps on civilians (montage: families turned away, guards with rifles)
      3. 0:40-1:00: Elena in lab (same as Phase 0 facility), watching news monitors. Voice: "I saved the climate. But not everyone."
      4. 1:00-1:15: Marcus training resistance fighters (underground bunker, weapons table). Voice: "They control the cure. We take it back."
      5. 1:15-1:30: Split screen—inside: children in clean park (playing, laughing). Outside: same children behind fence (reaching through, crying)
    - **Final shot**: Elena looking at Aster terminal (hand on button, conflicted expression). Voice: "I can fix this. I have to."
    - **Text**: "The climate stabilized. But access was controlled. Resistance formed within 3 years. Elena Vast disappeared 6 months later. Some say she's still working on a fix."
  - **Fragile Thaw**:
    - **Visual**: Damaged prototype (cracked, flickering), incomplete stabilization. Storm still raging but weaker (clouds thinner, rain lighter)
    - **Audio**: Piano solo (minor key, fragile, uncertain), sparse notes (1 every 2s), slow tempo (50 BPM)
    - **Sequence**:
      1. 0:00-0:20: Aster activates partially. Some storms recede (left side of screen), others remain (right side). Uneven recovery
      2. 0:20-0:40: Communities adapting—some thrive (solar panels, greenhouses), others struggle (makeshift shelters, ration lines)
      3. 0:40-1:00: Elena in medical bay (hospital bed, bandages, IV drip). Injured but conscious. Voice: "It's not enough. But it's something."
      4. 1:00-1:15: Marcus distributing supplies (warehouse, boxes, people lining up). Voice: "We make do. We always have."
      5. 1:15-1:30: Montage of resilience—vertical farms in ruins (plants growing through concrete), solar panels on rubble (improvised mounts), children learning to read weather patterns (charts, instruments)
    - **Final shot**: Elena and Marcus working side by side (lab bench, prototype between them), tired but determined (eye contact, slight nod). Prototype glowing faintly (pulsing 1Hz)
    - **Text**: "The climate improved, but not enough. Recovery took 40 years. Elena Vast and Marcus Reyes became symbols—not of victory, but of persistence."
- **Final statistics display** (after cinematic, before credits):
  - Civilians aided: X/10
  - Elena Safety: X/3
  - Prototype Integrity: X/3
  - Final evidence decision: "Preserved" or "Erased"
  - Ending title: "Public Thaw" / "Guarded Thaw" / "Fragile Thaw"
  - Playtime: "Total time: HH:MM:SS"
- **Scrolling credits**:
  - Content: Developer names (placeholder: "Development Team", "Narrative Design", "Art Direction", "Music Composition", "Voice Acting", "Special Thanks"), thank-you ("Thank you for playing FINAL THAW. Dedicated to climate activists worldwide.")
  - Duration: 60s scroll (slow, readable)
  - Skippable: Press any key after 10s delay ("Press any key to skip" prompt)
- **New Game option**:
  - Button: "New Game" (appears after credits or on skip)
  - Function: Calls `GameManager.reset_new_game()`, clears/replaces save safely (backup old save to `user://savegame_backup.json`), returns to MainMenu (not direct load—let player choose)
  - Ending-viewed flag: `GameManager.ending_viewed = true`. Ensures replay/new game behavior coherent (can watch credits again or skip)
- **Test hooks** (developer steps to verify all 3 endings without replaying full game):
  - Debug menu (F3): "Force ending: Public/Guarded/Fragile" buttons
  - Console command: `set_ending <type>` (e.g., `set_ending public_thaw`)
  - Test save files: Pre-configured saves with specific stats (e.g., `save_public_thaw.json`: civilian_aid=10, elena_safety=3, prototype_integrity=3, evidence=preserve)

**Acceptance**: Same saved inputs always result in same ending (deterministic). Priority rule for Fragile Thaw works (elena_safety ≤1 OR prototype_integrity ≤1 → Fragile, regardless of other stats). Credits and New Game don't trap player or leave old consequence state. All epilogue text/buttons function without errors. 60 FPS during cinematics. Commit: `Phase 15: epilogue and endings complete`

---

## Phase 16: QA, Optimization, and Release Build

**File**: `phase_16_qa_release_award.md`

**Concept**: Release-focused QA. Correct verified defects. Add essential accessibility. Prepare export configuration. Create release documentation. No new gameplay features.

**Key Features**:
- **QA Checklist** (`docs/qa_checklist.md`):
  - **Menus**: MainMenu (Start/Continue/Options/Credits/Quit all functional), Pause menu (Resume/Options/Quit working), Options (all settings apply correctly, persist after restart)
  - **Levels**: Every level loads without errors, all puzzles solvable, all combat arenas beatable, all bosses defeatable, no softlocks (player can always progress or die to respawn)
  - **Puzzles**: All puzzles tested (Phase 2, 6, 9, 10, 12), no randomness, hints work, undo function works, no softlocks
  - **Enemy types**: Scavenger, Enforcer, Marksman, Shield—all AI behaviors correct, telegraphs readable, damage values accurate
  - **Boss moves**: Riot Commander (shield bash, block, tear gas), Transport Captain (slam, throw, reinforcements), Helix Commander (energy blast, shield barrier, reinforcements, reactor sabotage)—all telegraphed, dodgeable, fair
  - **Minigames**: Vehicle repair (Phase 5), Aster calibration (Phase 9)—both playable with mouse/keyboard/controller, hints work, timer/timeout handled
  - **Character switch scenarios**: Phase 12 (3 rooms), Phase 14 (boss)—switching never leaves characters stuck/invulnerable/duplicated, camera always follows active character
  - **Save/load/checkpoint**: Manual save (10 slots), autosave (60s), checkpoint (every 3-5 min)—all persist correctly, corruption detection/restoration works
  - **Consequence counters**: Elena Safety (0-3), Prototype Integrity (0-3), Civilian Aid (0-10)—all increment/decrement correctly, persist after save/load, affect ending correctly
  - **All 3 endings**: Public/Guarded/Fragile Thaw—each triggerable via test hooks, cinematics play fully, credits scroll, New Game option works
  - **Controls**: All Input Map actions functional (movement, combat, interaction, scan, switch, pause), remapping works, controller support full parity
  - **Exported builds**: Windows (.exe), macOS (.app if templates available), Linux (.x86_64 if templates available)—all run without errors, 60 FPS maintained
- **QA Results** (`docs/qa_results.md`):
  - **Format**: Table with columns: Issue ID, Severity (Critical/Major/Minor), Description, Reproduction Steps, Resolution, Verification Status
  - **Example**:
    | ID | Severity | Description | Reproduction | Resolution | Status |
    |----|----------|-------------|--------------|------------|--------|
    | QA-001 | Critical | Save corruption on Phase 10 load | Save at dam checkpoint, quit, reload → error | Added CRC32 checksum + backup restore | ✅ Verified |
    | QA-002 | Major | Elena stuck in Phase 12 Room 2 | Switch to Elena, push crate into corner → can't move | Added stuck detection + teleport to Marcus after 5s | ✅ Verified |
    | QA-003 | Minor | Subtitle overlap in Phase 14 boss dialogue | Play boss fight on repeat → subtitles stack | Added subtitle queue (max 3 lines, auto-dismiss) | ✅ Verified |
  - **Do NOT invent test results**: Only log actual issues found during real playtesting
- **Defect Fixes** (priority order):
  1. **Blockers** (fix immediately): Crashes (engine crash, hard freeze), parser errors (Godot Output warnings), softlocks (player can't progress without restart), broken progression (can't complete level/boss), corrupted save handling (save won't load, no backup), incorrect ending logic (wrong ending triggers), input failures (controls unresponsive)
  2. **Major** (fix after blockers): Visual defects (missing textures, broken animations), audio defects (missing SFX, music cuts out), UI defects (overlapping text, buttons not clickable), performance issues (FPS drops below 50, load times >5s)
  3. **Minor** (fix if time permits): Typos in dialogue, color inconsistencies, minor animation glitches, edge-case bugs (rare, low impact)
- **Performance Profiling** (Godot Profiler tool):
  - **Verified bottlenecks**: Excessive nodes (>1000 in scene), particles (>500 active), expensive effects (volumetric fog, real-time shadows), unnecessary processing (loops in `_process` instead of `_physics_process`)
  - **Optimizations**: LOD for 3D models (3 levels, seamless transitions), occlusion culling (never render what camera can't see), batch rendering (combine static geometry into single draw calls), object pooling (particles, enemies, projectiles—no runtime allocation)
  - **Preserve gameplay behavior**: No changes to damage values, timings, AI behavior—only rendering/processing optimizations
- **Accessibility** (essential settings if missing):
  - **Input**: Full remapping (keyboard, mouse, controller), documented configurable bindings (README, options menu)
  - **Text size**: Setting (Normal 100%, Large 150%, Extra Large 200%)—applies to all UI, subtitles, dialogue
  - **Reduced camera shake**: Toggle (On/Off)—disables all screen shake, motion blur
  - **Reduced weather/effect intensity**: Slider (0%-100%)—reduces particle density, fog opacity, lightning frequency
  - **Visual non-colour-only puzzle indicators**: All puzzles solvable without color discrimination (shapes, patterns, text labels in addition to colors)
  - **Test with disabled gamers**: During development (not post-launch). Recruit via accessibility forums, Discord servers. Compensate fairly ($50-100/hour). Implement feedback before Phase 16.
- **Export Configuration**:
  - **Windows**: Preset `windows_desktop_64.exe`. Features: Direct3D 12, 64-bit, embedded PCK. Test on: Windows 10/11, GTX 1060, Ryzen 5 1600, 8GB RAM
  - **macOS** (if export templates available): Preset `macos_universal.app`. Features: Metal, Universal binary (Intel + Apple Silicon). Test on: macOS 11+, M1 Mac, 8GB RAM
  - **Linux** (if export templates available): Preset `linux_x86_64.x86_64`. Features: Vulkan, 64-bit. Test on: Ubuntu 20.04+, GTX 1060, 8GB RAM
  - **Do NOT falsely claim untested builds work**: If macOS/Linux templates not available or not tested, document as "Coming soon" in release notes
- **Release Checklist** (`docs/release_checklist.md`):
  - **Version**: 1.0.0 (semantic versioning: MAJOR.MINOR.PATCH)
  - **Tested platforms**: List all platforms tested (e.g., "Windows 10/11, GTX 1060, Ryzen 5 1600")
  - **Known issues**: Document any unresolved issues (e.g., "Minor stutter on integrated graphics (Intel UHD 620). Workaround: Reduce resolution to 720p.")
  - **Store asset checklist**: Trailer (30-60s, gameplay + cinematics), screenshots (10+, variety: combat, puzzles, cinematics, environments), description (200-500 words, hook + features + awards), icon (512x512px, PNG), capsule art (616x353px, PNG)
  - **Content warning review**: Violence (combat, blood optional), strong language (mild profanity), themes (climate collapse, death, guilt). Rate accordingly (ESRB T, PEGI 12)
  - **Release sign-off fields**: Developer sign-off (name, date), QA sign-off (name, date), publisher sign-off (if applicable, name, date)
- **README Update**:
  - **Installation/run instructions**: "Download release .exe. Run. No installation required. Minimum specs: [list]. Recommended specs: [list]."
  - **Controls**: Default keyboard/mouse/controller bindings (table format)
  - **Accessibility**: List all accessibility options (text size, colorblind modes, reduced motion, remapping, hints)
  - **Credits placeholder**: "Development: [Team names]. Music: [Composer]. Voice acting: [Cast]. Special thanks: [Advisors, testers, family]."
  - **License decision placeholder**: "© 2026 [Studio name]. All rights reserved." OR "Released under MIT License. See LICENSE file." (TODO if undecided—mark clearly)
- **Git Tagging** (if Git available):
  - **Clean working tree**: `git status` shows no uncommitted changes
  - **Final version commit**: `git commit -am "Version 1.0.0: Release ready"`
  - **Annotated tag**: `git tag -a v1.0.0 -m "FINAL THAW v1.0.0 - Initial release"`
  - **Only after checks pass**: If any release blocker remains (crash, softlock, corrupt save), do NOT tag. Report it instead (`docs/release_blockers.md` with description, severity, fix plan)

**Acceptance**: QA documentation reflects real verification (not assumptions). Full game can reach each ending using documented test steps (debug menu, test saves). Windows export created and run-tested (if export tooling available). No knowingly unresolved release-blocking softlock, crash, or corrupt-save issue remains. Commit: `Phase 16: QA, optimization, and release build complete`

---

## Usage

1. Copy each phase section above
2. Expand into full prompt format (like Phases 0-4 award prompts)
3. Use in Claude Code
4. Test, commit with exact message

**All 17 phases now have award-level specifications.** 🎯
