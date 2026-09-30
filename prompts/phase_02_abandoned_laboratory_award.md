You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect existing reusable systems before editing. Phases 0-1 are complete with award-level technical foundation and Elena movement.

**AWARD-LEVEL TARGET**: Puzzles must match *Portal 2* design philosophy: teach→test→twist→master structure, immediate feedback, no softlocks, visual clarity, and emotional payoff. Every puzzle teaches something new or twists an existing mechanic.

GOAL
Create Elena's first complete puzzle chapter: abandoned laboratory with 4 sequential rooms. Use placeholder/stylised art only.

## STORY CONTEXT

Elena escapes with Aster Protocol prototype. In this laboratory, she discovers Helix withheld viable stabilisation method because it couldn't control distribution. She retrieves partial transmission for Final Thaw Station.

**Character moment**: This is where Elena's guilt surfaces—she recognizes the science could have saved Iris. First memory fragment location.

## DELIVERABLES

### 1. Narrative/Message Panel (Reusable, Skippable)

Create `scenes/ui/narrative_panel.tscn` with:
- **Position**: Top-center or bottom-center (consistent throughout game)
- **Background**: Semi-transparent black (#80000000), rounded corners
- **Text**: White (#FFFFFF), minimum 18px, high contrast
- **Behavior**: Appears on room entry, auto-fades after 5 seconds OR skip with any input
- **Audio**: Subtle fade-in sound, optional text-to-speech for accessibility
- **Signal**: `narrative_complete` emitted when player dismisses or timer expires

**Example messages**:
- Room 1 entry: "Helix Lab Sector 7. Power offline. I need to restore it to access the archives."
- Room 1 complete: "Power restored. Terminal unlocked. What are you hiding, Helix?"
- Room 4 complete: "Partial transmission received. Final Thaw Station... there's still hope."

### 2. Room Completion/Checkpoint System

**GameManager updates** (`game_manager.gd`):
- Add `completed_rooms: Array` (stores room IDs like ["lab_1", "lab_2"])
- Add `current_checkpoint_id: String` (last checkpoint reached)
- Function `mark_room_complete(room_id: String)`: Adds to array, saves game
- Function `is_room_complete(room_id: String) -> bool`: Returns true if already completed
- Function `set_checkpoint(checkpoint_id: String)`: Sets current checkpoint, saves

**Checkpoint Scene** (`scenes/components/checkpoint.tscn`):
- Area2D with visible marker (glowing pedestal or hologram)
- On player enter: Play chime, set checkpoint, save game, show toast "Checkpoint Reached"
- Visual: Green glow when active, gray when already triggered

### 3. Reusable Puzzle Components

#### Powered Terminal (`scenes/components/powered_terminal.tscn`)
- **State**: `powered: bool` (default false), `solved: bool` (default false)
- **Interaction**: Opens puzzle UI when interacted
- **Visual**: Screen glow when powered, sparks when unpowered
- **Puzzle**: Connection sequence (nodes A→B→C→D, must link in order)
- **Feedback**: Green flash on correct connection, red on wrong (immediate, <100ms)
- **Undo**: Back button removes last connection (max 3 undos)
- **Hint**: Hold H for 2 seconds to highlight next correct node (3 charges per level)
- **On solve**: Set `powered=true`, emit `terminal_solved` signal, unlock connected door

#### Door (`scenes/components/powered_door.tscn`)
- **State**: `locked: bool`, `powered: bool`, `open: bool`
- **Interaction**: Opens if `powered=true` and `locked=false`, shows "Locked" or "No Power" otherwise
- **Animation**: Slide up or fade out over 0.5 seconds (not instant)
- **Audio**: Mechanical unlock sound, door slide sound
- **Visual**: Red light when locked/unpowered, green when open

#### Moving Platform (`scenes/components/moving_platform.tscn`)
- **Movement**: Fixed path (Path2D), constant speed or timed cycle
- **Controls**: Optional button to call platform to current floor
- **Safety**: Emergency stop if player still on platform after 10 seconds (returns to start)
- **Visual**: Metallic platform with hazard stripes, directional arrows showing path
- **Audio**: Motor hum while moving, clunk when docking

#### Hazard Zone (`scenes/components/hazard_zone.tscn`)
- **Types**: Electrical (floor), toxic (puddles), steam (vents)
- **Damage**: Reduces `prototype_integrity` by 1 only once per defined hazard event (not per frame)
- **Telegraph**: Visual warning before activation (flashing lights, 1 second delay)
- **Safe windows**: Clear patterns (e.g., electrical pulses every 3 seconds, safe for 1.5 seconds)
- **Checkpoint reset**: On death, respawn at last checkpoint with no penalty beyond time loss

#### Prototype Carrier (Elena state)
- **GameManager flag**: `has_aster_prototype: bool` (default true for this level)
- **Visual**: Glowing case attached to Elena sprite (cyan pulse)
- **Mechanic**: Hazard exposure reduces `prototype_integrity` only at defined checkpoints (not continuously)
- **Example**: 3 hazard zones, each reduces integrity by 1 if crossed without timing. Max loss = 3, min = 0

### 4. Four Puzzle Rooms

#### Lab Room 1: Restore Power (Teach)
**Layout**: 10x10 meters, terminal at far end, door locked
**Mechanic**: Connection sequence (A→B→C→D)
**Teaching**: 
- First connection highlighted (subtle arrow)
- Immediate feedback (green/red)
- Undo available (back button)
**Solution**: Fixed sequence (e.g., top-left→top-right→bottom-right→bottom-left)
**On complete**: Door unlocks, checkpoint activated, narrative panel: "Power restored. Terminal unlocked."
**Memory fragment**: Hidden behind terminal (Elena Memory #1: "First Aster test success")

#### Lab Room 2: Redirect Robotic Arm (Test)
**Layout**: 12x10 meters, robotic arm blocks path, terminal controls it
**Mechanic**: Terminal cycles arm through 4 fixed positions (0°, 90°, 180°, 270°)
**Teaching**: Same terminal UI as Room 1, but different puzzle type
**Test**: Player must observe arm positions, identify which one clears path
**Solution**: Only 1 position works (e.g., 180°), others block or are dangerous
**Feedback**: Arm moves visibly, collision updates immediately
**On complete**: Arm retracts fully, path clears, narrative: "Arm retracted. Moving forward."
**Memory fragment**: Under desk near terminal (Marcus Memory #1: "Badge day")

#### Lab Room 3: Moving Platform Traverse (Twist)
**Layout**: 15x10 meters, gap in floor, platform cycles between 3 positions
**Mechanic**: Platform moves on fixed 10-second cycle (Position A→B→C→A)
**Twist**: Player can call platform to current position with button, but this resets cycle
**Teaching**: Observe cycle, learn timing, plan route
**Test**: Must reach far side without falling (falling = respawn at start, no integrity loss)
**Accessibility**: Alternate route via ladder on right wall (longer but no timing required)
**On complete**: Platform docks at exit, narrative: "Platform stable. Continuing."
**Memory fragment**: On platform itself (Elena Memory #2: "Iris at weather station")

#### Lab Room 4: Prototype Calibration Chamber (Master)
**Layout**: 20x15 meters, 3 hazard zones in sequence, exit at far end
**Mechanic**: Combine all prior skills:
- Power routing ( Room 1) to disable hazards temporarily
- Timing (Room 3) to cross when safe
- Observation (Room 2) to identify safe windows
**Master sequence**:
1. Activate terminal to disable Hazard 1 for 5 seconds
2. Cross Hazard 1 within window
3. Wait for Hazard 2 safe cycle (3 seconds every 5 seconds)
4. Cross Hazard 2
5. Time Hazard 3 pulse (1 second every 3 seconds)
6. Cross to exit
**Integrity stakes**: Each hazard crossed unsafely = -1 prototype_integrity (max -3, min 0)
**On complete**: 
- If integrity preserved (3/3): Narrative: "Prototype intact. Full power. Transmission received."
- If integrity damaged (1-2): Narrative: "Prototype damaged but functional. Transmission received."
- If integrity destroyed (0/3): Narrative: "Prototype critical. Transmission received, but data corrupted."
**Memory fragment**: In corner behind exit door (Voss Memory #1: "Mumbai heat dome")

### 5. Save System Integration

**Autosave triggers**:
- On room entry (before puzzles)
- On room completion (after checkpoint)
- On integrity change (if damaged)

**Manual save**: Available anytime outside combat (not applicable in this phase, but prepare for later)

**Save data**:
- Current room ID
- Completed rooms array
- Prototype integrity value
- Checkpoint ID
- Memory fragments collected

**Load behavior**:
- Restore Elena position to start of current room
- Restore all puzzle states (terminal connections, platform positions, hazard timers)
- Restore integrity value

### 6. Visual Readability

**Floor markings**:
- Grid lines every 1 meter (subtle, 10% opacity)
- Hazard zones outlined in red (dashed, 50% opacity)
- Safe paths highlighted in green (subtle glow)

**Lighting**:
- Even illumination, no dark corners
- Hazard zones have localized red lighting
- Terminals glow cyan when active

**UI overlays**:
- Integrity display in HUD: "Prototype: ★★★" (fills/empties dynamically)
- Room progress: "Lab 1/4" in corner
- Objective marker: Arrow pointing to next goal (toggleable in options)

### 7. Accessibility Features

**Puzzle hints**:
- Level 0 (Off): No hints
- Level 1 (Contextual): Subtle highlight on correct interactable after 30 seconds inactive
- Level 2 (Full): Arrow points to next objective, text hint appears

**Extended time**:
- All timed puzzles have +50% duration option (toggle in pause menu)
- No penalty, no achievement lockout

**Alternate routes**:
- Room 3 has ladder route (longer but no timing)
- Marked on minimap for players who enable "Objective marker always-on"

**Colorblind mode**:
- Hazard zones use patterns (stripes, dots) in addition to color
- Terminal connections use shapes (circle, square, triangle) not just colors

---

## ACCEPTANCE CRITERIA (MUST PASS)

1. **Puzzle structure**: All 4 rooms follow teach→test→twist→master. Document which mechanic is taught/tested/twisted/mastered. PASS/FAIL

2. **Immediate feedback**: Wrong terminal connection shows red flash <100ms. Correct shows green. Test with all 4 rooms. PASS/FAIL

3. **Undo function**: Can reverse last 3 terminal actions. Test in Rooms 1 and 4. PASS/FAIL

4. **Hint system**: Hold H for 2 seconds highlights next correct node. 3 charges per level, recharge on room entry. Test in all rooms. PASS/FAIL

5. **No softlocks**: Falling into gap respawns at room start. Wrong platform timing = retry, no death. Test all failure states. PASS/FAIL

6. **Checkpoint system**: Save/load preserves room state, integrity, position. Test mid-room save, quit, reload. PASS/FAIL

7. **Integrity tracking**: HUD shows prototype integrity (3 stars), decreases on hazard damage, persists on save/load. PASS/FAIL

8. **Narrative panels**: Appear on room entry/completion, skippable with any input, auto-fade after 5 seconds. Test all 8 panels. PASS/FAIL

9. **Memory fragments**: 4 placed (1 per room), collectible, tracked in GameManager, persist on save/load. PASS/FAIL

10. **Accessibility**: Colorblind mode makes hazards distinguishable without color. Extended time option works. Alternate route in Room 3 functional. PASS/FAIL

11. **Performance**: 60 FPS locked in all rooms. No drops when hazards active, platforms moving, terminals open. PASS/FAIL

12. **Visual clarity**: Player can always see path, hazards, interactables. No dark corners, no ambiguous collision. Test with new player (no spoilers). PASS/FAIL

---

## DO NOT

- Add combat or enemies (Phase 3+)
- Randomize puzzle solutions (all fixed and readable)
- Create long penalties (wrong input resets local mechanism only, <5 seconds)
- Make puzzles time-critical without alternate routes
- Reduce consequence counters for normal retry/death
- Softlock player (always provide reset or escape)

---

## FINISH BY REPORTING

1. **Changed files**: List all new/modified files with descriptions
2. **Test results**: For each acceptance criterion, state PASS/FAIL with evidence
3. **Known limitations**: Any unresolved issues, TODOs, technical debt
4. **Performance metrics**: FPS in each room, load time between rooms, memory usage
5. **Commit message**: Propose this exact message:

```
Phase 2: abandoned laboratory puzzles complete

Award-level puzzle design with:
- 4 rooms following teach→test→twist→master structure
- Immediate feedback (<100ms), undo function (3 actions), hint system (3 charges)
- No softlocks (respawn on failure, alternate routes)
- Checkpoint system with full state persistence
- Prototype integrity tracking (hazard damage, saved)
- 4 memory fragments placed (Elena x2, Marcus x1, Voss x1)
- Full accessibility (colorblind, extended time, alternate routes)

All 12 acceptance criteria PASS. 60 FPS maintained. Ready for Phase 3.
```
