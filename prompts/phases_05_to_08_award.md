# Phases 5-8 Award-Level Prompts

## Phase 5: Broken Vehicle Minigame

**File**: `phase_05_broken_vehicle_award.md`

**Concept**: UI-focused transition minigame (2-5 min). Marcus repairs emergency vehicle before fire front reaches underpass. Generous timer, no hard game-over.

**Key Features**:
- **Scene**: `scenes/minigames/minigame_vehicle.tscn`—legible systems diagram, fire/smoke background (parallax layers), status panel (progress bar, 120s timer), accessible UI (high contrast, 75%-200% text scale)
- **5 repair controls**: Valves (2-4 states), fuse links, fuel switches. Visual clues: color-matching (red→red port), arrow alignment (arrow points to correct position), pressure gauges (green zone = correct)
- **Navigation**: Tab cycle through controls, Enter/Confirm to adjust, visual highlight on selected (cyan border #00FFFF, 3px)
- **Fire timer**: 120s (generous), visual countdown bar (red #E24A4A, depletes left-to-right), audio warning at 30s (rising pitch, 440Hz→880Hz). On expiry: auto-complete, set `vehicle_repaired_under_pressure = true`, show alternate text ("Made it, but vehicle damaged. Performance reduced.")
- **Success**: All 5 controls in correct state, press Confirm Repair. Set `vehicle_repaired_cleanly = true`, show success text ("Vehicle operational. Full performance.")
- **Accessibility hint mode**: Toggleable (H key), highlights one incorrect control (red pulse) without revealing full solution
- **Pause**: Explicit (pauses minigame timer, not game), documented in code
- **Narrative**: Skippable context at start ("Fire front approaching. Need to get this running. NOW."), transition to Phase 6 placeholder

**Acceptance**: Playable with mouse/keyboard/controller. Correct solution and timeout both transition cleanly. Save/load doesn't corrupt state. 60 FPS. Commit: `Phase 5: broken vehicle minigame complete`

---

## Phase 6: Flooded Shelter Puzzles

**File**: `phase_06_flooded_shelter_award.md`

**Concept**: Elena's flooded underground shelter. Deterministic water/pump/valve puzzles. Optional civilian rescues increment Civilian Aid.

**Key Features**:
- **Scene**: `scenes/levels/shelter_level.tscn`—compact rooms/corridors, wet concrete texture (#606060), pipes (cylinders #808080), water (animated blue #4A90E2, particle streams for current), emergency lighting (point lights, yellow #FFD700, flicker 5% intensity)
- **WaterZone**: Fixed 10s rise / 10s fall cycle OR state-based (pump/valve controlled). Visual: particle streams show current direction, pressure gauges (green=low, yellow=medium, red=high). Serializable state (save/load safe)
- **Pump**: Requires power (connect to power system from Phase 2). Toggles water flow. Visual: spinning animation when active, red (#E24A4A) / green (#4A90E2) indicator light. Audio: motor hum (pitch varies with state)
- **Valve**: Rotates 90° per interaction, redirects water flow. Visual: handle position, arrow showing flow direction. Audio: metallic click
- **Powered door**: Requires power + correct valve state. Wrong sequence resets local puzzle only (not entire room), feedback ("Valve 2 closed. Open to proceed.")
- **Main route puzzle**: Pump (restore power) → Valve (redirect water away from path) → Door (open exit)
- **Optional rescues (2+)**: Clearly marked (green arrow #4A90E2, "CIVILIAN TRAPPED" sign), attainable (navigation only, no skill checks), persistent after save/load, increment `civilian_aid` once only (max 10). Dialogue: "Thank you..." / "We owed you one."
- **Oxygen traversal**: 30s timer (generous), visible UI bar (blue depleting), nearby reset checkpoints (air pockets—bubbles rising), deterministic reset on timeout (respawn at last checkpoint, no counter reduction)
- **Narrative**: Entry ("Survivors trapped below. I can help. Or I can hurry..."), exit ("Marcus approaching perimeter. Need to move."), rescue dialogue

**Acceptance**: Main route completable without rescues. Water/pump/valve/door/oxygen behave predictably. Civilian Aid increments correctly. 60 FPS. Commit: `Phase 6: flooded shelter puzzles complete`

---

## Phase 7: Militia Encirclement Combat

**File**: `phase_07_militia_encirclement_award.md`

**Concept**: Marcus's shelter-perimeter combat. Marksmen, readable cover/LOS gameplay, first deterministic mini-boss (Riot Commander).

**Key Features**:
- **Scene**: `scenes/levels/perimeter_level.tscn`—3 arenas + boss arena. Barriers (concrete #808080), sandbags (brown #8B4513), wrecks (abandoned vehicles), floodlights (spotlights, white #FFFFFF, sweep 2s cycle), emergency beacons (red rotating #E24A4A), visible shelter entrance
- **Enemy Marksman**: Deterministic AI: POSITION (find cover) → ACQUIRE LOS (1s, red laser sight visible) → WINDUP (0.5s, rising pitch audio 440Hz→880Hz) → PROJECTILE (fixed speed 600 px/s, hits if LOS maintained) → RECOVERY/REPOSITION (2s, moves to new cover). No random accuracy—always hits if LOS through windup
- **Line-of-sight system**: Raycast from marksman to player. Solid cover (walls, sandbags, wrecks) blocks LOS completely. Partial cover (fences, debris) provides 50% damage reduction. Visual: cover outline glows blue (#4A90E2) when providing protection
- **Arena progression**: Arena 1 (3 Scav + 1 Marksman), Arena 2 (2 Scav + 2 Enf + 2 Marksmen), Arena 3 (4 Scav + 2 Enf + 3 Marksmen—requires movement between cover points)
- **Boss: Riot Commander** (`scenes/bosses/boss_riot_commander.tscn`):
  - **Stats**: Health 200, armor 50 (reduces all damage by 50, destroyable with 50 damage)
  - **Attacks**:
    - Shield bash: Charge 1s (red glow), lunge 0.3s, 30 damage, knockback 400px
    - Frontal shield block: 80% reduction, 3s duration, stamina cost 10/sec (boss stamina 100)
    - Tear gas: Area denial (50px radius cloud), 5 damage/sec, 5s duration, visual green mist (#80FF80, 50% opacity)
  - **Weak point**: Rear (180° arc, 100% damage). Visible when boss turns for attacks
  - **Phases**: 100%→66% (normal), 66%→33% (enraged: attack speed +20%), 33%→0% (desperate: tear gas frequency +50%)
- **Boss arena**: Solid cover (concrete barriers, destructible after 50 damage), throwable objects (5+ including 2 fuel canisters), checkpoint on death (not restart)
- **Narrative**: Messages from start through boss defeat. Set `perimeter_complete = true`, `termination_order_discovered = true`. Final message: "'Terminate if capture fails.' They're not taking her alive."

**Acceptance**: Marksman LOS/projectiles reliable. Cover prevents damage when physically between. Boss beatable by learning patterns + flanking. No random unavoidable damage. Arena progression/checkpointing work after save/load. 60 FPS. Commit: `Phase 7: militia encirclement combat complete`

---

## Phase 8: First Joint Mission

**File**: `phase_08_first_contact_award.md`

**Concept**: First Elena–Marcus mission. Escort design: player controls Marcus, Elena follows via waypoints, operates protected terminals.

**Key Features**:
- **Scene**: `scenes/levels/joint_mission_1.tscn`—2-3 combat arenas (400x400px each), protected terminal spaces ( alcoves with collision barriers), safe waiting points (marked "SAFE_POINT" in debug), gates (automated doors), exterior toxic-rain exit (cyan particle rain, 100px/s)
- **ElenaFollower controller** (`scripts/characters/elena_follower.gd`):
  ```gdscript
  @export var waypoints: Array[Vector2]  # Set in inspector
  var current_waypoint: int = 0
  var is_waiting: bool = false
  
  func _physics_process(delta):
      if is_waiting:
          return  # Wait at safe point
      
      var target = waypoints[current_waypoint]
      var direction = (target - global_position).normalized()
      velocity = direction * 250  # Slower than Marcus
      move_and_slide()
      
      if global_position.distance_to(target) < 10:
          current_waypoint += 1
          if current_waypoint >= waypoints.size():
              is_waiting = true  # Reached final point
  ```
  - **Waypoint-based**: Not dynamic pathfinding. Elena moves point-to-point, never wanders
  - **Safe points**: Named ("WAIT_POINT_1", "WAIT_POINT_2") outside combat spawn zones
  - **Stuck detection**: If stuck >5s (velocity ~0 but not at waypoint), teleport to Marcus (debug feature, not in release)
- **Player controls Marcus only**. Elena waits at safe points until mission event:
  1. Marcus clears arena (all enemies defeated)
  2. Elena moves to protected terminal (2s interaction)
  3. Terminal opens gate
  4. Both proceed to next waypoint
- **Enemy targeting**: Enemies target Marcus by default (Marcus has `threat_priority = 1`, Elena `threat_priority = 0`). Design arenas so Elena's safe points are outside spawn zones (400px radius)
- **Elena Safety tracking**:
  - **Protected boundary**: Area2D around Elena (100px radius). If enemy enters, trigger "ELENA IN DANGER" warning (red screen border, audio alarm 880Hz, 0.5s)
  - **Damage**: If enemy remains in boundary for 2s, decrement `elena_safety` by 1 (clamp 0-3). Cooldown 5s (prevent multiple decrements from same enemy)
  - **HUD**: Heart icon + number (0-3), color-coded (3=green #4A90E2, 2=yellow #FFD700, 1=orange #FFA500, 0=red #E24A4A). Contextual warning when about to decrease ("PROTECT ELENA!" text, 2s)
- **Terminal/gate events**: Marcus clears → Elena moves (3s travel) → Terminal (2s interact) → Gate opens (1s animation) → Both proceed (2s travel) → Next arena
- **Dialogue**: Skippable sequence:
  - Marcus: "I'm not here to hurt you."
  - Elena: "You're Helix. That's exactly what you're here for."
  - Marcus (quiet): "Yeah. That's what I was trained to be. Not anymore."
  - Elena: "Then prove it. Get me out of here."
  - (During mission, 3-4 short exchanges: "Clear." / "Moving." / "Gate's locked." / "I can hack it. Cover me.")
  - Do NOT pause combat for dialogue (subtitles during gameplay)
- **Toxic rain exit**: Stylised particles (cyan droplets, 100px/s, cyan #00FFFF glow), audio (hissing rain, 2000-4000Hz band), fade to white over 2s, Act I completion flag (`GameManager.completed_phases.append("act_i")`), save checkpoint, transition to Phase 9 placeholder

**Acceptance**: Elena never stuck in normal gameplay. Never needlessly attacked by spawned enemies. Every arena/gate state replayable after death or save/load. Elena Safety changes only through defined events (enemy proximity, not environmental). 60 FPS. Commit: `Phase 8: first joint mission complete`

---

## Usage

1. Copy each phase section above
2. Expand into full prompt format (like Phases 0-4 award prompts)
3. Use in Claude Code
4. Test, commit with exact message

**Next**: Phases 9-16 award-level prompts.
