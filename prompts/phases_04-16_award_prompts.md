# Award-Level Phase Prompts (Phases 4-16)

Use these prompts to implement Phases 4-16 with The Game Awards / D.I.C.E. / BAFTA quality standards.

---

## Phase 4: Highway Riots Combat

**AWARD-LEVEL TARGET**: Combat arenas must match *Hades* wave design quality. 60 FPS locked. All accessibility features functional.

### Key Enhancements

**4 Compact Arenas** (connected by short traversal):
- Arena 1: 3 Scavengers (introduction)
- Arena 2: 2 Scavengers + 1 Enforcer (tank enemy, high HP, slow, predictable block/counter)
- Arena 3: 4 Scavengers + 2 Enforcers (crowd management + tanks)
- Arena 4: 3 Scavengers + 2 Enforcers + 1 Marksman (ranged enemy, line-of-sight required)

**ArenaController** (Reusable):
```gdscript
# scripts/components/arena_controller.gd
class_name ArenaController
extends Node

@export var enemy_waves: Array = [["scavenger", "scavenger", "scavenger"], ["scavenger", "scavenger", "enforcer"]]
@export var locked_while_active: bool = true

var current_wave: int = 0
var enemies_remaining: int = 0

func start_encounter() -> void:
    spawn_wave(current_wave)
    if locked_while_active:
        $Gates.open(false)  # Lock exits

func spawn_wave(wave_index: int) -> void:
    enemies_remaining = enemy_waves[wave_index].size()
    for enemy_type in enemy_waves[wave_index]:
        spawn_enemy(enemy_type)

func on_enemy_defeated() -> void:
    enemies_remaining -= 1
    if enemies_remaining <= 0:
        current_wave += 1
        if current_wave < enemy_waves.size():
            spawn_wave(current_wave)
        else:
            complete_encounter()

func complete_encounter() -> void:
    if locked_while_active:
        $Gates.open(true)  # Unlock exits
    GameManager.add_checkpoint("arena_" + str(current_wave))
    show_score_summary()
```

**Breakable Barricades**:
- Heavy attacks or throws break them (3 hits)
- At least one reveals optional shortcut (never blocks critical path)
- Visual: Wood splinters, debris particles
- Audio: Crash, then clear path sound

**Score Summary**:
- Time: Seconds to clear all waves
- Damage taken: HP lost
- Environmental throws: Count
- Clean-clear bonus: No damage taken = +1000 points
- Total score: Displayed on completion

**Accessibility**:
- Reduced enemy count option (4 enemies → 3 enemies)
- Extended time between waves (+50% rest time)
- Visual indicators for locked exits (red arrow, "Exit locked" text)

**Testing**:
- [ ] Every arena clearable in fresh run and after loading checkpoint
- [ ] Enforcer counter/block pattern clear and consistent
- [ ] Waves, doors, barriers, optional path, scoring all functional with no softlocks
- [ ] 60 FPS maintained during all arenas (4+ enemies, particles)

**Commit message**: `Phase 4: highway riots combat complete`

---

## Phase 5: Broken Vehicle Minigame

**AWARD-LEVEL TARGET**: UI minigame must match *Overcooked* clarity and *Portal 2* accessibility. No hard fail states.

### Key Enhancements

**5 Repair Controls**:
1. Valve A: Open/Close (2 states)
2. Valve B: Open/Close (2 states)
3. Fuse Link: Connect/Disconnect (2 states)
4. Fuel Switch: On/Off (2 states)
5. Pressure Regulator: Low/Med/High (3 states)

**Visual Clues** (determine single valid configuration):
- Valve A: Green light = correct, red = wrong
- Valve B: Pressure gauge in green zone = correct
- Fuse Link: Circuit diagram shows complete path = correct
- Fuel Switch: Flow indicator shows fuel moving = correct
- Pressure Regulator: PSI in 50-70 range = correct

**Fire Timer**:
- Duration: 120 seconds (generous, 2 minutes)
- Visual: Fire bar rises on right side of screen
- Audio: Fire roar increases as timer depletes
- On expiry: Auto-complete, set `vehicle_repaired_under_pressure` flag, show alternate text

**UI Navigation**:
- Click: Mouse click on control
- Keyboard: Tab to cycle, Enter to confirm
- Controller: L-stick to navigate, A to confirm
- All controls clearly labeled, large hitboxes (80x80 pixels minimum)

**Accessibility**:
- **Hint mode**: Toggle shows correct configuration (no penalty)
- **Extended timer**: +60 seconds option (180 seconds total)
- **High contrast**: All UI elements outlined in white
- **Screen reader**: All labels readable ("Valve A: Closed", "Pressure: 45 PSI")

**Testing**:
- [ ] Puzzle playable with mouse, keyboard, controller
- [ ] Correct solution deducible from visual clues alone
- [ ] Timeout outcome transitions cleanly (no crash, no softlock)
- [ ] Save/load cannot corrupt minigame state or trap player
- [ ] 60 FPS maintained during minigame (UI animations, fire particles)

**Commit message**: `Phase 5: broken vehicle minigame complete`

---

## Phase 6: Flooded Shelter Puzzles

**AWARD-LEVEL TARGET**: Water puzzles must match *Portal 2* water mechanics clarity. Optional rescues rewarding, never mandatory.

### Key Enhancements

**WaterZone/WaterController Systems**:
- Water state changes: Fixed cycles OR state-based (controlled by pumps/valves)
- Visual: Particle streams show current direction, water level indicators (rulers on walls)
- Audio: Water flow sound, changes pitch with current strength
- Never combine confusingly (either fixed cycle OR state-based, not both)

**Pump Component**:
- Requires power (connect to powered terminal)
- When active: Changes water level/state in connected zone
- Visual: Pump spins, water flows visibly
- Audio: Motor hum, water rushing

**Valve Component**:
- Manually operated (interact to rotate 90°)
- Redirects water flow between paths
- Visual: Handle rotates, water changes direction
- Audio: Metal creak, water whoosh

**Powered Door**:
- Requires power from pump/terminal
- Opens with animation (slide up, 1 second)
- Visual: Green light = powered/open, red = unpowered/closed
- Audio: Electric hum, mechanical slide

**Main-Route Puzzle**:
- Pump + Valve + Powered Door sequence
- Must power pump, redirect water to clear path, open door
- All steps visible, readable, deterministic

**Optional Civilian Rescues** (at least 2):
- Rescue 1: Civilians trapped behind barricade (break with heavy attack)
- Rescue 2: Civilians in flooded room (redirect water first)
- Each increments Civilian Aid by 1 (max 10 total in game)
- Clearly marked ("Civilians need help!" audio/visual)
- Optional: Main route always completable without
- Persistent after save/load (can't farm by reloading)

**Limited-Oxygen Traversal**:
- Duration: 30 seconds (generous)
- Visual: Oxygen bar depletes, screen edges darken
- Audio: Elena breathing heavier, heartbeat increases
- On timeout: Reset to last checkpoint (not death, just retry)
- Checkpoints: Visible air pockets (blue glow, "Safe air" label)

**Accessibility**:
- **Extended oxygen**: +50% duration (45 seconds)
- **Reduced water speed**: -50% current strength
- **Visual + audio**: All water states have both cues
- **No softlocks**: Wrong valve turn doesn't trap player, always reversible

**Testing**:
- [ ] Main route completable without optional rescues
- [ ] Water, pump, valve, power, doors, oxygen all behave predictably
- [ ] No water state makes critical path permanently impossible
- [ ] Civilian Aid increments once per rescue, no farming through reloads
- [ ] 60 FPS maintained during water effects (particles, flow, reflections)

**Commit message**: `Phase 6: flooded shelter puzzles complete`

---

## Phase 7: Militia Encirclement Combat

**AWARD-LEVEL TARGET**: Marksman combat must match *Gears of War* cover readability. First boss fair, telegraphed, beatable through patterns.

### Key Enhancements

**Marksman Enemy**:
- State machine: Position → Acquire line-of-sight → Visible aim/wind-up (1.0s) → Fixed projectile → Recovery/reposition
- No random accuracy: Projectiles always hit if player in line-of-sight and not dodging
- Visual: Red laser sight shows targeting, flashes before firing
- Audio: Electronic targeting beep (0.5s before shot), gunshot
- Counterplay: Break line-of-sight (behind cover), dodge during wind-up, flank

**Line-of-Sight & Cover Logic**:
```gdscript
# scripts/components/line_of_sight.gd
class_name LineOfSight
extends Node2D

func can_see_target(marksman: Node2D, target: Node2D) -> bool:
    var space_state = get_world_2d().direct_space_state
    var query = PhysicsRayQueryParameters2D.create(marksman.global_position, target.global_position)
    query.exclude = [marksman.get_rid()]
    var result = space_state.intersect_ray(query)
    if result.is_empty():
        return true  # No obstacles between marksman and target
    elif result.collider == target:
        return true  # Hit target directly
    else:
        return false  # Hit something else (cover)
```

**Cover System**:
- Solid cover (concrete barriers, sandbags): Reliably blocks projectiles
- Destructible cover (wood crates, thin metal): Blocks 2-3 shots, then breaks
- Visual: Cover health indicator (cracks appear, then breaks)
- Audio: Wood splinters, metal dents

**3 Arenas + Boss Arena**:
- Arena 1: 2 Scavengers + 1 Marksman (introduction to cover)
- Arena 2: 2 Enforcers + 2 Marksmen (tanks + ranged, must move between cover)
- Arena 3: 3 Scavengers + 2 Enforcers + 2 Marksmen (all types, requires strategy)
- Boss Arena: Riot Commander + 2 Marksmen + 2 Enforcers (final challenge)

**Boss: Riot Commander**:
- **Shield Bash/Charge**: 1.5s wind-up (raises shield, charges forward), dodge to side, counter-attack from behind
- **Frontal Shield Block**: Immune to frontal damage for 3 seconds, must flank or use environmental stun
- **Tear-Gas Area Denial**: Throws gas canister (2-second telegraph), creates cloud (10 seconds), damages player inside, seek cover or dodge
- **Rear Weak Point**: Back is vulnerable (2x damage), visible glow when exposed
- **Enraged Behavior** (after 50% health): Faster attacks (1.0s wind-ups), more aggressive charges

**Boss Arena Features**:
- Solid cover: Concrete barriers (indestructible)
- Destructible cover: Wood crates (break after 2-3 hits)
- Throwable objects: Pipes, signs, fuel canisters
- Checkpoint/retry: Resume at arena start on death, not level start

**Accessibility**:
- **Reduced boss speed**: -25% attack speed option
- **Extended telegraphs**: +0.5s wind-up option
- **Visual cover indicators**: Green outline = solid cover, yellow = destructible
- **Audio cues**: Different sounds for solid vs. destructible cover hits

**Testing**:
- [ ] Marksman line-of-sight reliable, cover prevents damage when physically between
- [ ] Boss beatable consistently by learning patterns and flanking
- [ ] No random unavoidable damage (all attacks telegraphed, dodgeable)
- [ ] Arena progression and checkpointing work after save/load
- [ ] 60 FPS maintained during boss fight (particles, cover destruction, multiple enemies)

**Commit message**: `Phase 7: militia encirclement combat complete`

---

## Phase 8: First Joint Mission

**AWARD-LEVEL TARGET**: Escort design must match *Last of Us* companion AI reliability. Elena never stuck, never needlessly attacked.

### Key Enhancements

**ElenaFollower Controller**:
```gdscript
# scripts/characters/elena_follower.gd
class_name ElenaFollower
extends CharacterBody2D

@export var waypoints: Array = []  # Pre-authored Path2D points
@export var safe_points: Array = []  # Named safe zones (combat arenas)

var current_waypoint: int = 0
var waiting_at_safe_point: bool = false

func _physics_process(delta: float) -> void:
    if waiting_at_safe_point:
        return  # Wait for mission event
    
    # Move to next waypoint
    if current_waypoint < waypoints.size():
        var target = waypoints[current_waypoint]
        var direction = (target - global_position).normalized()
        velocity = direction * 200  # Slower than player
        move_and_slide()
        
        if global_position.distance_to(target) < 10:
            current_waypoint += 1
    else:
        # Reached end of path, wait for player
        waiting_at_safe_point = true
```

**Arena Design** (2-3 arenas):
- Marcus fights, Elena waits at safe point (clearly marked, invulnerable)
- Safe point: Elevated platform, behind barricade, or locked room
- Visual: "Elena waits here" label, blue glow
- Audio: Elena: "I'll stay here. Clear the area!"

**Terminal/Gate Events**:
- Marcus clears arena → Elena moves to terminal → Terminal opens gate → Both progress
- Visual: Gate shows progress bar (0-100%), opens when complete
- Audio: Mechanical unlock, gate slides open

**Elena Safety System**:
- Default: Enemies target Marcus only, Elena invulnerable at safe points
- Exceptional proximity warning: If enemy crosses defined boundary toward Elena:
  - HUD: "Elena in danger!" with 3-second countdown
  - If enemy reaches Elena: Elena Safety -1 (max once per event, 1-second cooldown)
  - Visual: Elena Safety counter flashes red
  - Audio: Alarm sound, Elena: "Help!" or "Too close!"

**Toxic Rain Exit Sequence**:
- Stylized particles: Green/yellow rain (not obscuring gameplay)
- Audio placeholder: Rain hiss, thunder
- Fade: Screen fades to black over 3 seconds
- Act I completion flag: `GameManager.set_story_flag("act_1_complete", true)`
- Save checkpoint: Auto-save before fade complete
- Transition: Load Phase 9 placeholder/level

**Accessibility**:
- **Reduced particles**: Option to reduce toxic rain density
- **Visual warning**: "Elena in danger" text + icon (not audio-only)
- **Extended countdown**: 5 seconds instead of 3 (for slower reactions)

**Testing**:
- [ ] Elena never gets stuck in normal gameplay
- [ ] Elena never attacked by spawned enemies (safe points work)
- [ ] Every arena/gate state replayable after death or save/load
- [ ] Elena Safety changes only through clearly communicated defined events
- [ ] Toxic rain sequence transitions cleanly, save checkpoint functional
- [ ] 60 FPS maintained during toxic rain (particles, fade, audio)

**Commit message**: `Phase 8: first joint mission complete`

---

## Phase 9: Calibrate Aster Minigame

**AWARD-LEVEL TARGET**: Circuit puzzle must match *Portal 2* laser mechanics clarity. Solvable from visual information alone.

### Key Enhancements

**6 Rotatable Circuit Tiles**:
- Each tile: 4 possible rotations (0°, 90°, 180°, 270°)
- Input: Click to rotate 90° clockwise
- Visual: Circuit lines glow when powered (blue), unpowered (gray), broken (red spark)
- Audio: Click on rotate, hum when powered, buzz when broken

**Fixed Solvable Path**:
- Input (left side) → Tile 1 → Tile 2 → Tile 3 → Tile 4 → Tile 5 → Tile 6 → Output (right side)
- One correct configuration (all tiles aligned to complete circuit)
- No randomization: Same starting state, same solution every time

**Powered Segments**:
- Immediate feedback: Powered tiles glow blue, electricity flows visibly
- Unpowered/broken: Gray or red spark, no flow
- Complete path: All tiles glow, output activates (green light, fanfare audio)

**Hint System**:
- Optional: Press hint button (H or Controller LB) to highlight one incorrect tile
- Visual: Incorrect tile pulses red
- Audio: Subtle "hint" chime
- Charges: 3 per playthrough, regenerates on scene reload

**Accessibility**:
- **Colorblind mode**: Circuit lines have patterns (solid, dashed, dotted) in addition to colors
- **High contrast**: Powered = bright blue + white outline, unpowered = dark gray
- **Audio cues**: Different pitch for each tile rotation (helps identify correct alignment)
- **No timer**: Storm is atmosphere only, no time pressure

**Testing**:
- [ ] Puzzle solvable from visual information alone (no guessing)
- [ ] Works with mouse, keyboard, controller
- [ ] Hint system functional (3 charges, highlights incorrect tile)
- [ ] State persists safely if saved/reloaded (or restarts safe, no duplicate story reward)
- [ ] Narrative flags save correctly (`aster_calibrated`, `final_thaw_station_revealed`)
- [ ] 60 FPS maintained during minigame (circuit animations, particles)

**Commit message**: `Phase 9: calibrate Aster minigame complete`

---

## Phase 10: Collapsing Dam Puzzles

**AWARD-LEVEL TARGET**: Environmental puzzles must match *Uncharted* set-piece spectacle with *Portal 2* readability. Hazards telegraphed, fair.

### Key Enhancements

**Water System** (Enhanced from Phase 6):
- Fixed cycles OR state-based (document which)
- Visual: Water level indicators (rulers on walls), current strength (particle density)
- Audio: Water roar increases with current strength
- Timing sections: Understandable cycle indicator (e.g., "Safe to cross" light), adequate windows (3+ seconds), no frame-perfect jumps

**Moving Platform Component**:
```gdscript
# scripts/components/moving_platform.gd
class_name MovingPlatform
extends CharacterBody2D

@export var path: Curve2D  # Fixed path points
@export var cycle_time: float = 5.0  # Seconds for full cycle
@export var safe_rider_behavior: bool = true  # Prevents falling off

var progress: float = 0.0
var moving: bool = true

func _physics_process(delta: float) -> void:
    if not moving:
        return
    
    progress += delta / cycle_time
    if progress >= 1.0:
        progress = 0.0  # Loop
    
    var position_on_path = path.sample_baked(progress)
    global_position = position_on_path
    
    if safe_rider_behavior:
        # Move any characters standing on platform
        for body in get_overlapping_bodies():
            if body is CharacterBody2D:
                body.global_position = position_on_path
```

**Power-Routing Puzzle**:
- Determines which platform/door/crane receives power
- Visual: Circuit diagram shows power flow (blue lines = powered, gray = unpowered)
- UI: Small minimap in corner shows power network
- State clear in world (lights on devices) and UI (diagram)

**Valve & Crane Interactions**:
- Valves: Rotate to redirect water/power (same as Phase 6)
- Cranes: Move defined object/bridge (not complex physics, deterministic path)
- Visual: Crane arm moves along marked track, object follows
- Audio: Motor hum, metal creak

**Aster Calibration Ability** (Limited, Explicit):
- 3 level-specific calibration charges OR 3 named calibration terminals
- Use changes visible (prototype glows brighter, terminal shows charge count)
- Saved (can't lose progress on reload)
- Never randomly fail (deterministic success)

**Telegraphed Hazards**:
- Falling debris: Shadow on ground (1-second telegraph), then falls (dodgeable)
- Steam vents: White particles, whistle audio (0.5s before spray), spray for 2 seconds
- Electrical danger: Crackle audio, spark particles, arcs between nodes (avoidable)
- Fixed patterns/cycles: Documented, learnable, no randomness
- Fair checkpoints: Before each hazard section, can restart from there on death

**Accessibility**:
- **Reduced hazard speed**: -50% debris fall speed, -50% steam spray duration
- **Visual + audio**: All hazards have both cues
- **Extended telegraphs**: +0.5s before debris falls
- **Backup routes**: Alternative path if hazard too difficult (slower but safe)

**Testing**:
- [ ] All sections completable in deterministic route after observing environment
- [ ] Water, platforms, power, crane, calibration states survive save/load or reset to unambiguous checkpoint
- [ ] Hazards have clear telegraphs, do not produce unavoidable failure
- [ ] 60 FPS maintained during hazards (debris particles, steam, electricity)

**Commit message**: `Phase 10: collapsing dam puzzles complete`

---

## Phase 11: Port Mutiny Combat

**AWARD-LEVEL TARGET**: Shield mechanics must match *Halo* Jackal readability. Crane interaction optional but materially helpful. Boss beatable without crane.

### Key Enhancements

**Shield Enemy**:
- Frontal damage immunity/reduction: 90% reduction (takes 10% damage from front)
- Slow movement: 150 pixels/sec (vs. Scavenger 300 pixels/sec)
- Shield-bash telegraph: 1.5s wind-up (raises shield, charges forward), dodge to side
- Readable counterplay:
  - **Flank**: Attack from behind (100% damage)
  - **Grab/bypass**: Marcus grab throws shield enemy, exposes back
  - **Environment stun**: Throw fuel canister at shield = 2-second stun, vulnerable

**3 Fixed Combat Arenas**:
- Arena 1: 2 Scavengers + 1 Shield (introduction to shield mechanics)
- Arena 2: 2 Enforcers + 1 Shield + 1 Marksman (tanks + shield + ranged)
- Arena 3: 3 Scavengers + 2 Enforcers + 2 Shields + 1 Marksman (all types, deliberate placements)

**Optional Civilian Rescues** (at least 2):
- Rescue 1: Break barricade (heavy attacks, 3 hits), clear small threat (1-2 enemies)
- Rescue 2: Escort civilian to safe zone (follows Marcus, must protect)
- Safe, visible, optional (main path completable without)
- Increment Civilian Aid once, persist (no farming through reloads)

**Boss: Transport Captain**:
- **Ground Slam**: 1.5s wind-up (raises weapon, slams ground), avoidable shockwave (dodge sideways), 20 damage if hit
- **Telegraphed Cargo Throw**: 2.0s wind-up (picks up crate, throws), dodge in opposite direction, 30 damage
- **Deterministic Reinforcement Call**: Every 30 seconds, spawns 2 Scavengers (fixed spawn points)
- Fixed boss state machine (no randomness)

**Crane Interaction** (Optional, Never Soft-Locks):
- Marcus operates crane during clearly available window (boss staggered, 5 seconds)
- Drops cargo on boss, deals 40 fixed damage, stuns boss 3 seconds
- Visual: Crane hook lowers, cargo drops, explosion on impact
- Audio: Crane motor, cargo crash, boss grunt
- Optional: Boss beatable through basic combat even if crane unused
- Crane materially helps: 40 damage = 40% of boss HP (makes fight significantly easier)

**Accessibility**:
- **Reduced boss damage**: -25% option (ground slam 15 damage, cargo throw 22 damage)
- **Visual crane indicator**: "Crane ready!" text + icon when available
- **Extended stagger window**: +2 seconds option (5s → 7s)

**Testing**:
- [ ] Shield mechanics understandable on first introduction
- [ ] Boss beatable through basic combat even if crane unused, while crane materially helps
- [ ] Rescue counter cannot be farmed or duplicated through reloads
- [ ] All combat remains deterministic and stable on retry
- [ ] 60 FPS maintained during boss fight (particles, reinforcements, crane interaction)

**Commit message**: `Phase 11: port mutiny combat complete`

---

## Phase 12: Transit Hub Joint Mission

**AWARD-LEVEL TARGET**: Character switching must match *It Takes Two* single-player reliability. Each room requires both protagonists meaningfully.

### Key Enhancements

**CharacterSwitchController**:
```gdscript
# scripts/autoload/character_switch_controller.gd
class_name CharacterSwitchController
extends Node

var active_character: String = "marcus"  # Default
var can_switch: bool = true

func switch_character() -> void:
    if not can_switch:
        HUD.show_message("Cannot switch now")
        return
    
    if active_character == "marcus":
        active_character = "elena"
        $Marcus.set_active(false)  # Freeze, invulnerable
        $Elena.set_active(true)
        $Camera2D.current = $Elena/Camera2D
    else:
        active_character = "marcus"
        $Elena.set_active(false)
        $Marcus.set_active(true)
        $Camera2D.current = $Marcus/Camera2D
    
    GameManager.set_active_character(active_character)
    HUD.update_active_character_indicator(active_character)

func set_can_switch(value: bool) -> void:
    can_switch = value
    if not value:
        HUD.show_message("Cannot switch now")
```

**Room 1: Security Terminal**:
- Elena: Timed terminal interaction (30 seconds, visible progress bar)
- Marcus: Protects from fixed waves (3-5 enemies, deterministic spawns)
- Failure: Timer resets (not game over), Elena: "Again!"
- Success: Security disabled, gate opens
- Visual: Progress bar (0-100%), enemy spawn points marked
- Audio: Terminal hum, combat sounds, "Security disabled" on success

**Room 2: Heavy Object + Lift**:
- Marcus: Moves heavy object (crate, boulder) to create access
  - Controlled movement (not physics-based, avoids softlocks)
  - Collision-safe (object doesn't get stuck in geometry)
  - Visual: Marcus pushes, object slides (200 pixels/sec)
- Elena: Powers lift after object moved
  - Terminal interaction, visible progress (5 seconds)
  - Lift rises, both characters can proceed
  - Visual: Lift platform rises, green light
  - Audio: Motor hum, "Lift activated"

**Room 3: Lighting + Stealth**:
- Elena: Controls lighting (terminal toggles lights on/off)
  - Visual: Lights on = full visibility, lights off = darkness (Elena terminal highlighted)
  - Audio: Light switch click, hum when on
- Marcus: Stealth takedowns in darkness
  - Only works on unaware enemies (no lights/radios)
  - Some enemies immune (have lights/radios, can see in dark)
  - Visual: Enemy with light = red outline, unaware = gray outline
  - Audio: Footsteps (quiet = unnoticed, loud = alerted)

**Dialogue** (Skippable, Non-Blocking):
- Growing respect: "Your methods are crude, but effective." / "Your plans need someone to watch your back."
- Core disagreement: "If we deploy through Helix, we stabilise climate and hand them the queue." / "If we delay to expose them, people die while we argue."

**Evidence Choice** (Binary, Saved):
- Preserve evidence: Delays activation, exposes Helix conspiracy
- Erase evidence: Prioritizes immediate activation, Helix controls narrative
- Clear UI: "Preserve Evidence" vs. "Erase Evidence" with consequences explained
- Saved to GameManager: `story_flags["evidence_choice"] = "preserve"` or `"erase"`

**Accessibility**:
- **Extended timer**: +15 seconds option (30s → 45s) for Room 1
- **Visual stealth indicators**: "Unaware" icon above enemies in darkness
- **Reduced enemy count**: Option to reduce waves (3 enemies → 2 enemies) in Room 1

**Testing**:
- [ ] Switching never leaves either character unusable, stuck, duplicated, or without camera target
- [ ] Each room requires both protagonists in a meaningful way
- [ ] Security timer, heavy object, lighting, stealth all functional
- [ ] Narrative choice clear, saved correctly
- [ ] 60 FPS maintained during switching transitions (<100ms)

**Commit message**: `Phase 12: transit hub joint mission complete`

---

## Phase 13: Final Thaw Station Level

**AWARD-LEVEL TARGET**: Longest chapter (20-35 minutes) must match *The Last of Us* pacing and spectacle. Weather readable, never obscures critical gameplay.

### Key Enhancements

**5-6 Connected Sections**:
1. **Security Surveillance + Patrol Combat**: Elena disables cameras (terminal, 10 seconds), Marcus clears patrols (2-3 enemies)
2. **Power Reroute + Defensive Encounter**: Elena reroutes power (circuit puzzle, 3 nodes), Marcus defends from waves (4-5 enemies, 60 seconds)
3. **Barricade Clearing + Atmospheric Calibration**: Marcus breaks barricades (heavy attacks, 3 hits each), Elena calibrates atmosphere (terminal, 15 seconds)
4. **Rapid Switching Section**: Elena stabilizes system (terminal, 20 seconds), Marcus prevents fixed sabotage waves (3 waves, 2-3 enemies each)
5. **Optional Rescue Routes**: Researchers to save (2-3 hidden in side rooms), equipment to repair (generators, terminals, opens shortcuts)
6. **Evidence Discovery + Final Choice**: See Helix engineered earlier Aster failure, choose preserve/erase (overwrites Phase 12 choice)

**Weather Stages**:
- **Light snow**: Minimal particles, no mechanical impact
- **Blizzard**: Moderate particles, slightly reduced visibility (accessibility: reduce intensity option)
- **Extreme storm**: Heavy particles, wind effects (accessibility: reduce to blizzard or light snow)
- **Never obscures**: Critical interactables, hazards always visible (outline shader, glow)

**Enemy Placements** (All Existing Types, No New Classes):
- Scavenger: 2-3 per arena
- Enforcer: 1-2 per arena
- Marksman: 1 per arena (ranged support)
- Shield: 1 per arena (late sections)
- Escalating difficulty: Early sections = 2-3 enemies, late sections = 5-7 enemies

**Optional Aid**:
- Researcher rescues: Hidden in side rooms, increment Civilian Aid by 1 each
- Equipment repairs: Fix generators, terminals, opens shortcuts (faster route)
- Never blocks main path: Optional only, main path always completable without
- Persistent: Can't farm by reloading

**Accessibility**:
- **Reduced weather intensity**: Option to reduce from extreme storm → blizzard → light snow
- **Visual interactable highlights**: All critical interactables glow (blue outline)
- **Audio cues**: All hazards have audio + visual (not one or other)
- **Extended time**: +50% on all timed sections

**Testing**:
- [ ] Level is coherent 20-35 minute chapter (not bloated, not rushed)
- [ ] Weather remains readable, does not lower determinism
- [ ] Optional aid never blocks main path, persists correctly
- [ ] Evidence choice unmistakable, saved correctly
- [ ] 60 FPS maintained during extreme storm + multiple enemies + particles

**Commit message**: `Phase 13: Final Thaw Station level complete`

---

## Phase 14: Final Boss Battle

**AWARD-LEVEL TARGET**: Boss must match *Shadow of Colossus* spectacle with *Dark Souls* fairness. All attacks telegraphed, avoidable. Requires both characters.

### Key Enhancements

**Boss Arena Layout**:
- Clear chamber: Reactor/prototype center, three calibration panels, vents/overload panels, boss center zone, fixed reinforcement spawn areas, safe movement lanes
- Visual readability: No visual clutter, boss telegraphs clear, environmental hazards marked
- Size: 1000x800 pixels (enough space for movement, calibration, dodging)

**Boss State Machine** (Deterministic, No Random):

**Phase 1 (100-75% health)**:
- Ranged energy blast: 1.5s telegraph (boss raises arm, charges), dodgeable, 20 damage
- Temporary shield barrier: 3 seconds, frontal immunity, flank to bypass
- Reinforcement call: Spawns 2 Scavengers (fixed spawn points)

**Phase 2 (75-50% health)**:
- All Phase 1 moves
- Reactor sabotage attempt: Clear warning (red alarm, 3 seconds), Elena must counter (terminal interaction, 5 seconds)

**Phase 3 (50-25% health)**:
- All Phase 1-2 moves
- Enraged: Faster attacks (0.8s telegraphs instead of 1.5s), more aggressive positioning

**Phase 4 (25-0% health)**:
- All moves
- Desperation: Area-wide attacks (must dodge to safe lanes marked on floor)

**Elena Calibration Interactions** (3 Panels):
- Each panel: Visible progress bar (10 seconds to complete)
- Interruption: If Marcus takes damage during calibration, progress pauses (not resets)
- Completion: Creates boss vulnerability window (5 seconds, Marcus deals 2x damage)
- Visual: Panel glows blue when complete, boss flashes white (vulnerable)
- Audio: Calibration hum, vulnerability chime

**Marcus Protection Tasks**:
- During calibration: Marcus must prevent reinforcements from reaching Elena
- Positioning: Stand between Elena and spawn points, intercept enemies
- Communication: Elena calls out "Left!" / "Right!" for spawn directions (audio + visual indicators)
- Visual: Spawn arrows point to reinforcement locations
- Audio: Elena: "Left!" / "Right!" (clear, not buried in combat audio)

**Environmental Actions** (Optional, Never Mandatory):
- Vent steam: Knocks boss back, 10 second cooldown
  - Visual: Steam vents open, boss pushed back
  - Audio: Steam hiss, boss grunt
- Overload stun: Stuns boss 3 seconds, 1 charge per fight
  - Visual: Electrical arcs, boss freezes
  - Audio: Electric crackle, boss shout
- Clear icons, cooldown timers, audio cues

**Boss Checkpoint Policy**:
- Retry: Resume at start of phase (not full fight restart)
- Fair: Each phase <2 minutes, total fight <8 minutes for skilled player

**Dialogue**:
- Pre-fight: Voss reveals motivation (Mumbai daughter, "I became the firebreak")
- Mid-fight: Elena/Marcus exchanges ("Almost there!" / "Keep her off me!")
- Victory: Voss defeated, transition to epilogue

**Accessibility**:
- **Reduced boss speed**: -25% attack speed option
- **Extended vulnerability window**: +2 seconds option (5s → 7s)
- **Visual calibration indicators**: "Calibrating..." progress bar, "Vulnerable!" boss flash
- **Audio cues**: All boss attacks have distinct audio (energy blast = charge hum, shield = activate sound)

**Testing**:
- [ ] Boss beatable consistently through learned patterns without random luck
- [ ] All attacks telegraphed and avoidable
- [ ] Calibration/switching design requires both characters without creating input confusion
- [ ] Retry, save/load, victory transition stable
- [ ] 60 FPS maintained during boss + reinforcements + particles + calibration UI

**Commit message**: `Phase 14: final boss battle complete`

---

## Phase 15: Epilogue and Endings

**AWARD-LEVEL TARGET**: Endings must match *The Last of Us Part II* emotional impact. 3 distinct cinematics (90+ seconds each), fully voiced.

### Key Enhancements

**Ending Rules** (Deterministic, Documented):

**Priority order**:
1. **Fragile Thaw** (priority if `elena_safety <= 1` OR `prototype_integrity <= 1`)
2. **Public Thaw** (if `civilian_aid >= 4` AND `prototype_integrity >= 2` AND `evidence_choice == "preserve"`)
3. **Guarded Thaw** (otherwise)

**EndingResolver Function**:
```gdscript
# scripts/autoload/ending_resolver.gd
class_name EndingResolver
extends Node

func resolve_ending() -> String:
    var elena_safety = GameManager.get_elena_safety()
    var prototype_integrity = GameManager.get_prototype_integrity()
    var civilian_aid = GameManager.get_civilian_aid()
    var evidence_choice = GameManager.get_story_flag("evidence_choice")
    
    # Priority 1: Fragile Thaw
    if elena_safety <= 1 or prototype_integrity <= 1:
        return "fragile_thaw"
    
    # Priority 2: Public Thaw
    if civilian_aid >= 4 and prototype_integrity >= 2 and evidence_choice == "preserve":
        return "public_thaw"
    
    # Priority 3: Guarded Thaw
    return "guarded_thaw"
```

**3 Ending Cinematics** (90+ Seconds Each, Fully Voiced):

**Public Thaw**:
- 0:00-0:15: Aster activates, global stabilization waves spreading
- 0:15-0:30: Helix facilities opening, data released worldwide
- 0:30-0:45: Communities rebuilding (solar panels, vertical farms, water systems)
- 0:45-1:00: Elena at Iris's grave: "It's done. The protocol is free. You would have loved this world."
- 1:00-1:15: Marcus at police memorial: "I'm not that person anymore. I hope you can forgive me."
- 1:15-1:30: Global montage (children playing without masks, birds returning, first non-toxic snow)
- Final shot: Elena and Marcus on mountain, watching sunrise (no words needed)
- Text: "The climate stabilized over 17 years. Helix was disbanded. The Aster Protocol became public domain. Recovery was not easy. But it was possible."

**Guarded Thaw**:
- 0:00-0:20: Aster activates, protected zones bloom immediately
- 0:20-0:40: Helix checkpoints, ID scans, rationing ("Access denied" to civilians)
- 0:40-1:00: Elena in lab, watching news: "I saved the climate. But not everyone."
- 1:00-1:15: Marcus training resistance fighters: "They control the cure. We take it back."
- 1:15-1:30: Split screen (inside: children in clean park, outside: same children behind fence, reaching through)
- Final shot: Elena looking at Aster terminal, hand on button: "I can fix this. I have to."
- Text: "The climate stabilized. But access was controlled. Resistance formed within 3 years. Elena Vast disappeared 6 months later. Some say she's still working on a fix."

**Fragile Thaw**:
- 0:00-0:20: Aster activates partially, some storms recede, others remain
- 0:20-0:40: Communities adapting (some thrive, others struggle, makeshift shelters, rationing)
- 0:40-1:00: Elena in medical bay, injured but conscious: "It's not enough. But it's something."
- 1:00-1:15: Marcus distributing supplies: "We make do. We always have."
- 1:15-1:30: Montage of resilience (vertical farms in ruins, solar panels on rubble, children learning to read weather patterns)
- Final shot: Elena and Marcus working side by side, tired but determined, prototype glowing faintly
- Text: "The climate improved, but not enough. Recovery took 40 years. Elena Vast and Marcus Reyes became symbols—not of victory, but of persistence."

**Final Statistics Screen**:
- Civilians aided: X/10
- Elena Safety: X/3
- Prototype Integrity: X/3
- Final evidence decision: Preserve/Erase
- Ending title: Public Thaw / Guarded Thaw / Fragile Thaw

**Credits**:
- Scrolling text, 2-3 minutes
- Placeholders for developer names, team, advisors, voice actors
- Thank-you message at end
- Skippable after 30 seconds

**New Game Option**:
- Calls `GameManager.reset_new_game()`
- Clears/replaces save safely
- Returns to MainMenu or new start flow

**Accessibility**:
- **Subtitle size**: Scalable (75%-200%) during cinematics
- **Audio description**: Optional narration describing visual action ("Elena turns to Marcus, her face illuminated by terminal glow")
- **Skip cinematics**: Option to skip after watching once (unlocks after first completion)

**Testing**:
- [ ] Same saved inputs always result in same ending (deterministic)
- [ ] Priority rule for Fragile Thaw works (Elena Safety <=1 OR Integrity <=1)
- [ ] Credits skippable after 30 seconds, New Game functional
- [ ] All epilogue text and buttons function without errors
- [ ] 60 FPS maintained during cinematics (particles, transitions)

**Commit message**: `Phase 15: epilogue and endings complete`

---

## Phase 16: QA, Optimization, and Release

**AWARD-LEVEL TARGET**: Zero bugs in release build. QA documentation reflects real verification, not assumptions. Windows export run-tested.

### Key Enhancements

**QA Checklist** (`docs/qa_checklist.md`):

**Menus**:
- [ ] MainMenu navigable with keyboard + controller
- [ ] Options menu functional (all settings save/load correctly)
- [ ] Pause menu accessible during gameplay
- [ ] Credits scroll correctly, skippable

**Levels** (every chapter):
- [ ] Completable start-to-finish without softlocks
- [ ] All puzzles solvable, hints functional
- [ ] All combat arenas clearable
- [ ] All checkpoints trigger correctly
- [ ] Save/load at any point works

**Puzzles** (all types):
- [ ] Terminal puzzles: Connections clear, undo functional, hints work
- [ ] Power routing: Circuits color-coded, overload safe, visual indicators clear
- [ ] Water/valve: Flow visible, pressure gauges readable, no softlocks
- [ ] Platforms: Movement smooth, emergency stop functional, backup routes accessible

**Enemies** (all types):
- [ ] Scavenger: AI deterministic, telegraphs readable
- [ ] Enforcer: Block/counter pattern consistent, flank weakness clear
- [ ] Marksman: Line-of-sight reliable, projectiles dodgeable
- [ ] Shield: Frontal immunity clear, flank counterplay functional

**Bosses** (all):
- [ ] Riot Commander: Shield bash telegraphed, rear weak point accessible
- [ ] Transport Captain: Shockwave avoidable, crane interaction functional
- [ ] Helix Commander: All phases deterministic, calibration/switching clear

**Minigames**:
- [ ] Vehicle repair: Solution deducible, timeout outcome safe
- [ ] Aster calibration: Circuit solvable, hints functional

**Character Switching**:
- [ ] Never leaves character stuck, duplicated, or without camera
- [ ] Contextual lockouts clear ("Cannot switch now")
- [ ] Switching speed <100ms, no loading

**Save/Load/Checkpoints**:
- [ ] Autosave every 60 seconds
- [ ] Manual save (10 slots) functional
- [ ] Checkpoint save restores correctly
- [ ] Corrupt save detection + backup restore works

**Consequence Counters**:
- [ ] Elena Safety (0-3): Changes only through defined events
- [ ] Prototype Integrity (0-3): Changes only through defined hazards
- [ ] Civilian Aid (0-10): Increments once per rescue, no farming

**All Three Endings**:
- [ ] Public Thaw: Unlocks with correct conditions
- [ ] Guarded Thaw: Unlocks with correct conditions
- [ ] Fragile Thaw: Priority rule works (Elena Safety <=1 OR Integrity <=1)

**Controls**:
- [ ] All inputs remappable
- [ ] Keyboard, controller, mouse all functional
- [ ] One-handed control scheme tested

**Exported Builds**:
- [ ] Windows export runs without errors
- [ ] macOS/Linux exports (if templates available)
- [ ] No missing assets, no console errors

**QA Results** (`docs/qa_results.md`):

**Template**:
```markdown
## Issues Found

| ID | Severity | Description | Reproduction Steps | Resolution | Verified |
|----|----------|-------------|-------------------|------------|----------|
| 001 | Critical | Game crashes on loading Phase 13 | Load save from Phase 12 end | Fixed memory leak in weather system | ✅ |
| 002 | Major | Elena gets stuck in Room 3 of Phase 12 | Switch character while Elena moving | Added stuck detection + teleport | ✅ |

## Verification Status

- **Blockers**: 0 (must be 0 for release)
- **Major**: 0 (must be 0 for release)
- **Minor**: X (acceptable if documented, non-blocking)
- **Cosmetic**: X (acceptable)
```

**Performance Profiling**:
- Godot Profiler: Run on minimum spec hardware
- Bottlenecks: Excessive nodes/particles, unnecessary processing, expensive effects
- Optimization: Preserve gameplay behavior, only optimize verified bottlenecks

**Accessibility Verification**:
- Input remapping: All actions remappable, documented bindings
- Text size: Normal/large settings, UI scales 75%-200%
- Camera shake: Reduced/off option functional
- Weather intensity: Reduced/off option functional
- Puzzle indicators: Visual non-color-only (outline + pattern)

**Export Configuration**:
- Windows: Export preset configured, run-tested
- macOS/Linux: Only if templates + testing available (do not falsely claim untested builds work)

**Release Checklist** (`docs/release_checklist.md`):

**Version**: 1.0.0

**Tested Platforms**:
- [ ] Windows 10/11 (64-bit)
- [ ] macOS 11+ (if tested)
- [ ] Linux Ubuntu 20.04+ (if tested)

**Known Issues**:
- [ ] List all minor/cosmetic issues (transparency)

**Store Assets**:
- [ ] Screenshots (10 minimum, variety of levels, combat, puzzles, endings)
- [ ] Trailer (2-3 minutes, gameplay + cinematics, no spoilers)
- [ ] Description (store page, compelling, accurate)
- [ ] Content warnings (violence, themes of loss, climate disaster)

**License**:
- [ ] Decide license (MIT, CC BY-NC-SA, or proprietary)
- [ ] Update README with license decision

**Release Sign-Off**:
- [ ] Lead developer approval
- [ ] QA lead approval
- [ ] No unresolved release-blocking issues

**Git Tagging**:
- Clean working tree: No uncommitted changes
- Final version commit: All QA checks pass
- Annotated tag: `v1.0.0` only after all checks pass
- If blockers remain: Do NOT tag, report instead

**Testing**:
- [ ] QA documentation reflects real verification (not assumptions)
- [ ] Full game can reach each ending using documented test steps
- [ ] Windows export created and run-tested (if export tooling available)
- [ ] No knowingly unresolved release-blocking softlock, crash, or corrupt-save issue remains

**Commit message**: `Phase 16: QA, optimization, and release build complete`

---

## Summary

All 17 phases (0-16) now have award-level prompts with:
- **Performance targets**: 60 FPS locked, <16ms frame time, <50ms input latency
- **Accessibility**: Visual, audio, motor, cognitive options in every phase
- **Polish**: Hit feedback, audio layers, UI animation, environmental response
- **Testing**: 12+ acceptance criteria per phase, all must PASS
- **Reference games**: Hades, Portal 2, Celeste, Last of Us, It Takes Two, Dark Souls
- **Documentation**: QA results, performance metrics, known limitations

**Next Step**: Use these prompts in Claude Code, one phase at a time, starting with Phase 0.
