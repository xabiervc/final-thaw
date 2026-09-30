# FINAL THAW — All Phases Award-Level Summary

## Quick Reference Table

| Phase | Prompt File | Status | Key Award Enhancements |
|-------|-------------|--------|------------------------|
| **0** | `phase_00_technical_foundation_award.md` | ✅ Updated | 60 FPS locked, <50ms input, save corruption protection, debug tools, comprehensive accessibility |
| **1** | `phase_01_elena_movement_award.md` | ✅ Updated | Smooth acceleration, normalized diagonals, deterministic interaction, scan with visual feedback |
| **2** | `phase_02_abandoned_laboratory_award.md` | ✅ Updated | Teach-test-twist-master puzzles, undo function, hint system, no softlocks, memory fragments |
| **3** | `phase_03_marcus_combat_award.md` | ✅ Updated | 3-hit combo, perfect dodge (150ms→2s slow-mo), parry (200ms→stagger+crit), style meter D→S |
| **4** | `phase_04_highway_riots_award.md` | ⚠️ Pending | Arena waves, enforcer counter-patterns, breakable barriers, environmental throws, score summary |
| **5** | `phase_05_broken_vehicle_award.md` | ⚠️ Pending | UI minigame, 5 controls with visual clues, fire timer (generous, no game-over), accessibility hints |
| **6** | `phase_06_flooded_shelter_award.md` | ⚠️ Pending | Water/pump/valve puzzles, civilian rescues (optional, +Civilian Aid), oxygen traversal, save persistence |
| **7** | `phase_07_militia_encirclement_award.md` | ⚠️ Pending | Marksman line-of-sight, cover system, boss riot commander (shield bash, block, tear gas, weak point rear) |
| **8** | `phase_08_first_contact_award.md` | ⚠️ Pending | Elena follower (waypoint-based, never stuck), arena protection, Elena Safety tracking, toxic rain exit |
| **9** | `phase_09_calibrate_aster_award.md` | ⚠️ Pending | 6 rotatable tiles, fixed circuit solution, hint mode, accessibility (click/keyboard/controller) |
| **10** | `phase_10_collapsing_dam_award.md` | ⚠️ Pending | Water cycles, moving platforms, power routing, valves/cranes, Aster calibration (3 charges), hazards |
| **11** | `phase_11_port_mutiny_award.md` | ⚠️ Pending | Shield enemies (frontal immunity, flank weak point), crane boss interaction, civilian rescues, arenas |
| **12** | `phase_12_free_switching_award.md` | ⚠️ Pending | <100ms character swap, inactive character invulnerable, synergy puzzles, lighting stealth, evidence choice |
| **13** | `phase_13_final_thaw_station_award.md` | ⚠️ Pending | 5-6 sections, weather stages (light snow→blizzard→storm), all mechanics recombined, evidence final choice |
| **14** | `phase_14_final_boss_award.md` | ⚠️ Pending | Helix Commander boss (energy blast, shield barrier, reinforcements, reactor sabotage), 3 calibration panels, vulnerability windows |
| **15** | `phase_15_epilogue_award.md` | ⚠️ Pending | 3 endings (Public/Guarded/Fragile Thaw), 90+ sec cinematics each, fully voiced, post-credits stinger |
| **16** | `phase_16_qa_release_award.md` | ⚠️ Pending | Full QA checklist, accessibility testing, performance profiling, export presets, release documentation |

---

## Detailed Phase Summaries

### Phase 0: Technical Foundation ✅
**File**: `phase_00_technical_foundation_award.md`

**Award Enhancements**:
- Godot 4.x config: 1280x720, 60 Hz physics, canvas_items stretch
- Input Map: 15+ actions (movement, combat, system, accessibility, debug)
- GameManager: elena_safety (0-3), prototype_integrity (0-3), civilian_aid (0-10), memory_fragments, playtime, difficulty
- Save system: JSON + CRC32 checksum, backup restoration, <100KB per save
- MainMenu: Start, Continue (disabled if no save), Options, Credits, Quit. Accessible (keyboard + controller + screen reader)
- HUD: 3 consequence counters with icons + color-coding, active character indicator, memory counter, objective marker
- Test room: Placeholder CharacterBody2D, smooth movement, 3 interactables, scan system
- Debug tools: God mode, infinite ammo, level unlock, ending force, FPS counter, teleport (password-protected in release)

**Performance Targets**:
- 60 FPS locked
- <2s load times
- <50ms input latency
- <100KB save files

---

### Phase 1: Elena Movement ✅
**File**: `phase_01_elena_movement_award.md`

**Award Enhancements**:
- Character: CharacterBody2D, capsule collision, ground shadow, Camera2D smooth follow
- Movement: Acceleration 30, deceleration 25, max speed 300, normalized diagonals, snap to grid at low velocity
- Facing direction: Track last movement vector, flip sprite accordingly
- Interactable component: display_name, prompt_text, enabled, interaction_range, interact() function
- Nearest-target selection: Distance-based, stable tie-breaker (node order), prompt shows "[E] {action} - {name}"
- Scan system: 200px radius, expanding ring pulse, highlighted interactables glow cyan, no state changes
- Test room: 3 interactables (terminal, lever, door), 5-10 scan targets, instruction panel

**Performance**:
- <0.1ms movement logic per frame
- <0.5ms interaction checks per frame
- 60 FPS locked

---

### Phase 2: Abandoned Laboratory ✅
**File**: `phase_02_abandoned_laboratory_award.md`

**Award Enhancements**:
- 4 rooms with teach-test-twist-master structure
- Reusable components: powered terminal, automated door, moving platform, hazard zone, prototype carrier
- Room 1 (Teach): Power restoration (repair 3 conduits in order)
- Room 2 (Test): Robotic arm redirect (observe cycle, press correct button)
- Room 3 (Twist): Moving platform (weight sensitivity, emergency stop)
- Room 4 (Master): Prototype calibration (navigate 3 hazard types, exit requires prototype)
- Memory fragments: 4 total (2 Elena, 1 Marcus, 1 optional)
- Narrative messages: Skippable, 8s auto-dismiss, entry + completion per room
- Save/checkpoint: Auto-save per room, manual save outside hazards, respawn at room start (not level)

**Accessibility**:
- Colorblind mode (hazards distinguishable without color)
- Extended time (+50% for timed sections)
- Puzzle hints (3 charges per level)
- Reduced motion (no platform wobble, no camera shake)

---

### Phase 3: Marcus Combat ✅
**File**: `phase_03_marcus_combat_award.md`

**Award Enhancements**:
- 3-hit combo: Light→Light→Heavy (launch), input buffer 0.5s, no random crits
- Perfect dodge: 150ms window → 2s slow-mo, guaranteed next hit
- Parry: 200ms block window → stagger enemy 1.5s, next attack = 2x damage crit
- Block: 60% frontal damage reduction, 5 stamina/sec, guard break after 3s
- Stamina: 100 max, 10/sec regen, dodge=20, block=5/sec, parry=0
- Hitbox/hurtbox: No double hits, active frames 0.1s, debug visualization (F4)
- Enemy AI (Scavenger): IDLE→APPROACH→WINDUP (0.5s telegraph)→STRIKE (0.2s)→RECOVERY (0.3s vulnerable)→IDLE
- Grab/throw: 3 tiers (light=10, heavy=25, explosive=40+AoE), parabolic trajectory visualization
- Arena: 800x600px, 5-7 throwables, 3-5 enemies in waves, doors lock/unlock, score summary (time, damage, env throws, clean clear)
- Hit feedback: Hit flash (0.1s white), camera shake (3px/0.2s), particles (sparks, blood, dust), damage numbers (optional)

**Performance**:
- 60 FPS locked with 5 enemies
- <1ms combat logic per frame
- Stamina bar, health bar, score UI all 60 FPS

---

### Phase 4: Highway Riots ⚠️
**Original**: `phase_04_highway_riots.md`
**Enhancements to Add**:
- 4 arenas connected by short traversal (cracked asphalt, guardrails, abandoned vehicles, orange haze)
- Enemy Enforcer: High health (100), slow movement (150 px/s), predictable block/counter timing (block 0.5s, counter 0.3s), flank weakness (100% damage from behind/environmental)
- ArenaController: Fixed spawn lists/waves, locked exits while active, checkpoint after clear, no random spawns
- Arena progression: Arena 1 (3 Scavengers), Arena 2 (2 Scav + 1 Enf), Arena 3 (2 Scav + 2 Enf + throwables), Arena 4 (3 Scav + 2 Enf + environmental hazards)
- Breakable barricades: Heavy attacks or throws break them (20 damage), at least one reveals optional shortcut (never blocks critical path)
- Environmental throws: Pipes (10 dmg), signs (15 dmg), car parts (25 dmg), fuel canisters (40 dmg + 50px radius explosion)
- Score summary: Time (<30s=S, <45s=A, <60s=B, <90s=C), damage taken (0=No Damage +500), env throws (+100 each), clean clear (+1000)
- Narrative: Skippable messages at start, between sections, ending. Evidence story flag in GameManager.

---

### Phase 5: Broken Vehicle ⚠️
**Original**: `phase_05_broken_vehicle.md`
**Enhancements to Add**:
- UI minigame scene: Legible systems diagram, fire/smoke background (parallax), status panel (progress bar, timer), accessible UI (high contrast, scalable text)
- 5 repair controls: Valves (2-4 states each), fuse links, fuel switches. Visual clues determine single valid configuration (e.g., color-matching, arrow alignment, pressure gauges in green zone)
- Click/controller navigation: Tab cycle through controls, Enter/Confirm to adjust state, visual highlight on selected control
- Fire timer: 120 seconds (generous), visual countdown bar, audio warning at 30s remaining (rising pitch). On expiry: auto-complete, set `vehicle_repaired_under_pressure` flag, show alternate text
- Success: Set `vehicle_repaired_cleanly` flag, show success text
- Accessibility hint mode: Toggleable, highlights one incorrect control without revealing full solution
- Pause handling: Explicit (pause minigame, not game), documented in code comments
- Narrative: Skippable context at start, transition to Phase 6 placeholder

---

### Phase 6: Flooded Shelter ⚠️
**Original**: `phase_06_flooded_shelter.md`
**Enhancements to Add**:
- WaterZone/WaterController: Fixed cycles (e.g., 10s rise, 10s fall) OR state-based (pump/valve controlled). Clear visual indicators (particle streams for current, pressure gauges). Serializable state (save/load safe)
- Pump component: Requires power (connect to power system), toggles water flow state. Visual: Spinning animation when active, red/green indicator light
- Valve component: Rotates 90° per interaction, redirects water flow. Visual: Handle position, arrow showing flow direction
- Powered door: Requires power + correct valve state. Wrong sequence resets local puzzle only (not entire room), shows useful feedback ("Valve 2 closed. Open to proceed.")
- Main route puzzle: Pump (restore power) → Valve (redirect water) → Door (open exit)
- Optional rescues (2+): Clearly marked (green arrow, "CIVILIAN TRAPPED" sign), attainable (no skill checks, just navigation), persistent after save/load, increment Civilian Aid once only
- Oxygen traversal: 30s timer (generous), visible UI bar, nearby reset checkpoints (air pockets), deterministic reset on timeout (respawn at last checkpoint, no counter reduction)
- Narrative: Entry/exit messages, rescue dialogue ("Thank you..." / "We owed you one"), transition noting Marcus approaching perimeter

---

### Phase 7: Militia Encirclement ⚠️
**Original**: `phase_07_militia_encirclement.md`
**Enhancements to Add**:
- Enemy Marksman: Deterministic state machine (POSITION→ACQUIRE LOS (1s)→WINDUP (0.5s telegraph, red laser sight)→PROJECTILE (fixed speed 600 px/s)→RECOVERY/REPOSITION (2s)). No random accuracy—always hits if LOS maintained through windup
- Line-of-sight system: Raycast from marksman to player. Solid cover (walls, sandbags, wrecks) blocks LOS. Partial cover (fences, debris) provides 50% damage reduction
- Cover logic: Player behind solid cover = 0 damage. Player behind partial cover = 50% damage. Player exposed = 100% damage. Visual: Cover outline glows blue when providing protection
- Arena progression: Arena 1 (3 Scav + 1 Marksman), Arena 2 (2 Scav + 2 Enf + 2 Marksmen), Arena 3 (4 Scav + 2 Enf + 3 Marksmen, requires movement between cover points)
- Boss: Riot Commander (health 200, armor 50). Attacks: Shield bash (charge 1s, lunge 0.3s, 30 damage), frontal shield block (80% reduction, 3s duration), tear gas (area denial, 5 damage/sec, 5s duration). Weak point: Rear (100% damage, visible when boss turns)
- Boss arena: Solid cover (concrete barriers, destructible after 50 damage), throwable objects (5+), checkpoint on death (not restart)
- Narrative: Messages from start through boss defeat. Set `perimeter_complete` and `termination_order_discovered` flags.

---

### Phase 8: First Contact ⚠️
**Original**: `phase_08_first_contact.md`
**Enhancements to Add**:
- ElenaFollower controller: Authored Path2D waypoints (not dynamic pathfinding). Elena moves waypoint-to-waypoint, waits at named safe points ("WAIT_POINT_1", "WAIT_POINT_2"). Never wanders, never runs through combat, never permanently stuck. If stuck >5s, teleports to Marcus (debug feature, not in release)
- Player controls Marcus only. Elena waits at safe points until mission event (e.g., "Marcus cleared arena → Elena moves to terminal → Terminal opens gate → Both progress to next waypoint")
- Enemy targeting: Enemies target Marcus by default (Marcus has threat priority). Design arenas so Elena's safe points are outside spawn zones. Exception: If enemy crosses protected boundary (defined Area2D around Elena), trigger "ELENA IN DANGER" warning (red screen border, audio alarm). If enemy reaches Elena (2s within boundary), decrement Elena Safety by 1 (prevent multiple decrements from same enemy with cooldown 5s)
- Terminal/gate events: Marcus clears arena (all enemies defeated) → Elena moves to protected terminal (2s interaction) → Gate opens → Both proceed to next section
- HUD: Elena Safety indicator (heart icon + number 0-3, color-coded 3=green, 2=yellow, 1=orange, 0=red). Contextual warning when Safety about to decrease ("PROTECT ELENA!" text, red flash)
- Dialogue: Skippable sequence for first contact ("I'm not here to hurt you." / "You're Helix." / "Not anymore.") and 3-4 short exchanges during mission. Do NOT pause combat automatically for dialogue (dialogue appears as subtitles during gameplay)
- Toxic rain exit: Stylised particles (cyan droplets, 100px/s downward), audio (hissing rain), fade to white over 2s, Act I completion flag, save checkpoint, transition to Phase 9 placeholder

---

## Phases 9-16: Pending Updates

**To be completed in next batch**:
- Phase 9: Calibrate Aster (circuit minigame, 6 tiles, fixed solution, hint mode)
- Phase 10: Collapsing Dam (water/platforms/power/valves/cranes, 3 Aster charges, hazards)
- Phase 11: Port Mutiny (shield enemies, crane boss, civilian rescues, 3 arenas)
- Phase 12: Free Switching (<100ms swap, synergy puzzles, lighting stealth, evidence choice)
- Phase 13: Final Thaw Station (5-6 sections, weather stages, all mechanics, final evidence choice)
- Phase 14: Final Boss (Commander boss, 3 calibration panels, vulnerability windows, environmental actions)
- Phase 15: Epilogue (3 cinematics 90+ sec each, fully voiced, post-credits stinger)
- Phase 16: QA Release (full checklist, accessibility testing, performance profiling, export presets)

---

## How to Use This Document

1. **For Phases 0-3 (Ready)**: Use the `*_award.md` files directly in Claude Code
2. **For Phases 4-8 (Manual Enhancement)**: Use original prompts + add enhancements listed above
3. **For Phases 9-16 (Coming Soon)**: Wait for updated `*_award.md` files or use this doc as reference

**Goal**: Every phase meets award-level standards by release.

---

## Performance & Quality Standards (All Phases)

| Metric | Target | Verification |
|--------|--------|--------------|
| FPS | 60 locked | Godot profiler, <16ms frame time |
| Input latency | <50ms | Input display overlay |
| Load time | <2s | Time from scene load to playable |
| Memory | <500MB peak | Godot debugger, OS task manager |
| Save file | <100KB | Check `user://savegame_*.json` |
| Accessibility | Full options | Test with disabled gamers |
| No softlocks | Always recoverable | QA playtesting 100+ hours |

---

**Next**: Update Phases 9-16 with award-level prompts.
