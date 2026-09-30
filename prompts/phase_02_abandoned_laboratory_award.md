You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect existing reusable systems before editing. Phases 0-1 are complete with award-level technical foundation and Elena movement.

**AWARD-LEVEL TARGET**: Puzzles must match *Portal 2* design philosophy: teach → test → twist → master. Every solution is fixed, readable, and feels inevitable in hindsight. No randomness, no softlocks, no frustration—only "aha!" moments.

GOAL
Create Elena's first complete puzzle chapter: abandoned laboratory with 4 sequential rooms. Use placeholder/stylised art only.

## STORY CONTEXT
Elena escapes with Aster Protocol prototype. Discovers Helix withheld viable stabilisation method because it couldn't control distribution. Retrieves partial transmission for Final Thaw Station.

## PUZZLE DESIGN PHILOSOPHY (Portal 2 Standard)

**Every puzzle must**:
1. **Teach**: First instance is safe, obvious, no time pressure. Player learns mechanic.
2. **Test**: Second instance requires application with mild challenge. Player demonstrates understanding.
3. **Twist**: Third instance subverts expectation—mechanic combines with another or works differently. Player adapts.
4. **Master**: Final instance requires full understanding, often under pressure. Player succeeds through mastery.

**No**:
- Randomized solutions (all fixed and readable)
- Pixel-perfect timing (generous windows)
- Softlocks (backup systems, emergency exits)
- Exposition dumps (show through environment)

---

## DELIVERABLES

### 1. Reusable Systems

#### Narrative Message Panel (`scenes/ui/narrative_panel.tscn`)
- Lightweight, skippable UI overlay
- Does NOT pause gameplay by default (toggleable in options)
- Auto-dismiss after 10 seconds or press interact to skip
- Text: High contrast, scalable (75%-200%), subtitle settings apply
- Position: Bottom third of screen (doesn't obscure gameplay)
- Example messages:
  - "Power restored. The facility remembers me."
  - "Arm position locked. Only one angle is safe."
  - "Platform cycle: 10 seconds. Watch the pattern."

#### Checkpoint System (`scripts/components/checkpoint.gd`)
- Attached to room exit doors
- On reach: Call `GameManager.save_game()`, set `current_checkpoint_id`, emit `checkpoint_reached` signal
- Visual: Glowing archway or terminal, clear "Checkpoint" label
- Audio: Pleasant chime (major chord, 0.5 seconds)
- Saves: Elena position, all puzzle states, story flags

#### Powered Terminal Component (`scenes/components/terminal_powered.tscn`)
- Requires power connection to function
- Visual: Screen glow (on/off), emission material
- Interaction: Opens UI panel with puzzle interface
- State: `is_powered: bool`, `is_active: bool`
- Signal: `terminal_activated()` when successfully used

#### Door Component (`scenes/components/door Automated.tscn`)
- Can be locked/unlocked, open/closed
- Visual: Door slides/fades open, sound effect
- State: `is_locked: bool`, `is_open: bool`, `requires_power: bool`
- Interaction: If unlocked and not open, play open animation
- Signal: `door_opened()`, `door_closed()`

#### Moving Platform Component (`scenes/components/moving_platform.tscn`)
- Fixed path (Path2D) with timed cycle
- Can be called to specific positions via button
- Visual: Platform moves smoothly, no jerking
- State: `current_position_index: int`, `is_moving: bool`
- Safety: Emergency stop button, can halt mid-travel
- Accessibility: Backup route (ladder, vent, destructible wall) always available

#### Hazard Zone Component (`scenes/components/hazard_zone.gd`)
- Area2D with damage-over-time or instant trigger
- Visual: Particle effect (steam, electricity, toxic gas), warning stripes
- Audio: Hissing, crackling, or ominous drone
- State: `is_active: bool`, `damage_per_second: float`
- Telegraph: 1.0 second warning before activation (flashing lights, sound ramp-up)
- Safe zones: Clearly marked areas where hazard doesn't reach

#### Prototype Carrier Component (`scripts/components/prototype_carrier.gd`)
- Elena carries visibly glowing prototype (emission material, pulse animation)
- State: `has_prototype: bool` (saved in GameManager)
- Visual: Blue glow (#4A90E2) on Elena's torso, 50% opacity, 1 second pulse
- Mechanic: Must keep prototype powered; sustained hazard exposure lowers Prototype Integrity
- Integrity loss: Only once per defined hazard event/checkpoint (not per frame)
  - Example: Enter hazard zone without protection = -1 integrity, then invulnerable until next checkpoint

---

## ROOM DESIGNS

### Room 1: Restore Power (Teach: Terminal Connections)

**Layout**:
- Size: 40x30 tiles (640x480px)
- Elements: 1 powered terminal, 3 connection nodes, 1 locked exit door
- Environment: Dark initially, lights turn on as power restored

**Puzzle Flow**:
1. **Teach**: Terminal shows diagram: "Connect Node 1 → Node 2 → Node 3 → Door"
   - Node 1 already connected to power (green)
   - Player must connect Node 1 → Node 2 (drag line or rotate connector)
   - Immediate feedback: Connection glows green when correct, red when wrong
2. **Test**: Player connects Node 2 → Node 3
   - Slightly longer distance, requires routing around obstacle
   - Feedback: Same (green/red glow)
3. **Twist**: Node 3 → Door requires passing through junction box
   - Junction has 2 input/output pairs; must match correctly
   - Wrong match: Sparks, reset junction (not full puzzle reset)
4. **Master**: All connections made, door unlocks
   - Narrative message: "Power restored. The facility remembers me."
   - Checkpoint save, proceed to Room 2

**Acceptance**:
- No time pressure, player can experiment
- Wrong connections reset in <1 second (no long penalties)
- Visual diagram always visible (no memorization required)

---

### Room 2: Redirect Robotic Arm (Test: Position Cycling)

**Layout**:
- Size: 50x40 tiles
- Elements: 1 terminal controlling arm, robotic arm (sprite with rotation), 4 fixed positions, exit path blocked by arm

**Puzzle Flow**:
1. **Teach**: Terminal shows arm positions: 0°, 90°, 180°, 270°
   - Current position: 0° (blocking path)
   - Player cycles to 90°: Arm rotates over 2 seconds (telegraphed, safe)
   - Path still blocked
2. **Test**: Cycle to 180°: Arm moves out of path, but now blocks something else (optional collectible)
   - Player learns: Each position has trade-offs
3. **Twist**: Position 270° opens path BUT also activates platform (preparation for Room 3)
   - Multi-purpose solution: Solves current puzzle, sets up future puzzle
4. **Master**: Exit path clear, proceed
   - Narrative message: "Arm position locked. Only one angle is safe."

**Acceptance**:
- Arm movement is slow (2 seconds per 90°), no rush
- Positions clearly labeled (0°, 90°, 180°, 270° or Position 1-4)
- No frame-perfect timing to pass under arm

---

### Room 3: Moving Platform Traverse (Twist: Timed Movement)

**Layout**:
- Size: 60x50 tiles
- Elements: 1 moving platform, 2-3 platforms total, call buttons at each level, gap too wide to jump

**Puzzle Flow**:
1. **Teach**: Platform cycles automatically (10-second loop)
   - Player waits, observes cycle
   - Button to call platform to current level (optional, for accessibility)
2. **Test**: Player must time boarding platform
   - Platform arrives, wait 2 seconds, step on
   - Platform moves to next level over 5 seconds (safe, no fall damage)
3. **Twist**: Second platform requires calling it FIRST, then boarding
   - If player just waits, platform never comes (stuck on other side)
   - Solution: Press call button, wait 3 seconds, board
4. **Master**: Reach exit, narrative message
   - "Platform cycle: 10 seconds. Watch the pattern."

**Acceptance**:
- No fall damage (platform has collision, can't fall off)
- Emergency stop button halts platform (prevents softlock)
- Backup route: Ladder or vent for players who can't time jumps

---

### Room 4: Prototype Calibration Chamber (Master: Hazard Navigation)

**Layout**:
- Size: 80x60 tiles (largest room)
- Elements: 3-4 hazard zones (steam vents, electrical patches, toxic puddles), prototype carrier active, exit at far end

**Puzzle Flow**:
1. **Setup**: Elena receives prototype (glowing blue, `has_prototype: true`)
   - Tutorial message: "Keep prototype powered. Avoid hazards."
2. **Teach**: First hazard zone is small, clearly marked
   - Player walks around it (no penalty)
   - If player crosses: Warning flash, -1 Prototype Integrity (from 3 to 2), checkpoint saves
3. **Test**: Multiple hazards in sequence
   - Must navigate maze-like path
   - Each hazard crossed = -1 integrity (clamped to minimum 0)
4. **Twist**: One hazard is fake (looks dangerous but safe)
   - Tests player observation, not just reflexes
   - Safe hazard has subtle visual difference (different color, no particle movement)
5. **Master**: Reach exit without losing integrity
   - If integrity = 3: Bonus narrative ("Prototype stable. Perfect calibration.")
   - If integrity < 3: Normal narrative ("Prototype damaged. Can still function.")
   - Either way, proceed to Phase 3

**Acceptance**:
- Hazards telegraphed 1.0 second before activation (flashing lights, sound)
- Integrity loss once per hazard event (not per frame in hazard)
- Checkpoint at room start, can retry without losing progress

---

## REUSABLE COMPONENTS TO CREATE

| Component | File | Purpose |
|-----------|------|---------|
| Terminal Powered | `scenes/components/terminal_powered.tscn` | Puzzle interface, requires power |
| Door Automated | `scenes/components/door_automated.tscn` | Lock/unlock, open/close |
| Moving Platform | `scenes/components/moving_platform.tscn` | Timed cycle, call buttons |
| Hazard Zone | `scenes/components/hazard_zone.tscn` | Damage over time, telegraphed |
| Checkpoint | `scenes/components/checkpoint.tscn` | Save point, visual/audio feedback |
| Narrative Panel | `scenes/ui/narrative_panel.tscn` | Story messages, skippable |
| Connection Node | `scenes/components/connection_node.tscn` | Power routing puzzle piece |
| Robotic Arm | `scenes/components/robotic_arm.tscn` | Position cycling obstacle |
| Prototype Carrier | `scripts/components/prototype_carrier.gd` | State management for prototype |

---

## ACCEPTANCE CRITERIA (MUST PASS)

1. **Puzzle flow**: All 4 rooms completable in sequence without developer console. Average playtime 10-15 minutes. PASS/FAIL with timer

2. **Fixed solutions**: No randomness in any puzzle. Reload room 10 times, solution identical each time. PASS/FAIL

3. **No softlocks**: Every puzzle has reset button or backup route. Test: Intentionally break each puzzle, verify recovery. PASS/FAIL

4. **Immediate feedback**: Wrong input shows error <0.5 seconds, resets <1 second. No long animations or penalties. PASS/FAIL

5. **Checkpoint system**: Save/load at each room exit preserves all state (Elena position, puzzle states, integrity). Test all 4 checkpoints. PASS/FAIL

6. **Prototype integrity**: Loss only once per hazard event, clamped 0-3, saved correctly. Test: Cross hazard, save, reload, verify integrity unchanged. PASS/FAIL

7. **Narrative messages**: Appear on room entry and completion, skippable, high contrast text. All 8 messages present. PASS/FAIL

8. **Accessibility**: Colorblind mode makes hazards distinguishable without color (patterns, shapes). Backup routes usable. PASS/FAIL

9. **Performance**: 60 FPS locked in all rooms, even with all hazards active. Profiler shows <1ms per puzzle logic update. PASS/FAIL

10. **Phase transition**: Room 4 exit triggers Phase 3 completion flag, shows "Return to Menu" or "Next Phase" placeholder. No crash, no softlock. PASS/FAIL

---

## DO NOT

- Add combat or enemies (Phase 3+)
- Create final art—placeholders only
- Add randomness to puzzles
- Make hazards instant-death (always telegraphed, always avoidable)
- Require frame-perfect timing (generous windows)
- Lock critical path behind optional puzzles (optional = shortcuts or collectibles only)

---

## FINISH BY REPORTING

1. **Changed files**: List all new/modified files
2. **Test results**: Each acceptance criterion PASS/FAIL with evidence
3. **Known limitations**: Unresolved issues, TODOs
4. **Performance metrics**: FPS in each room, puzzle logic time
5. **Commit message**: Propose this exact message:

```
Phase 2: abandoned laboratory puzzles complete

Award-level puzzle design with:
- 4 sequential rooms (teach-test-twist-master structure)
- Reusable components (terminals, doors, platforms, hazards)
- Checkpoint system with save/load at each exit
- Prototype integrity system (loss once per hazard event)
- Narrative messages on entry/completion (skippable)
- Accessibility: backup routes, colorblind-safe hazards, no softlocks

All 10 acceptance criteria PASS. 60 FPS maintained. Ready for Phase 3.
```
