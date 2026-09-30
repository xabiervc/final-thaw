You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect existing reusable systems before editing. Phases 0-1 are complete with award-level technical foundation and Elena movement.

**AWARD-LEVEL TARGET**: Puzzles must match *Portal 2* design philosophy: teach, test, twist, master. Every puzzle is solvable through observation and logic. No frustration, no softlocks, no randomness.

GOAL
Create Elena's first complete puzzle chapter: abandoned laboratory with 4 compact, sequential puzzle rooms using placeholder/stylised art only.

## STORY CONTEXT
Elena escapes with the Aster Protocol prototype. In this laboratory, she discovers Helix withheld a viable stabilisation method because it could not control distribution. She retrieves a partial transmission for the future Final Thaw Station.

**Emotional beat**: This is where Elena's guilt manifests—she chose research over Iris, and now that research is being weaponized. First hint of her sister's story.

---

## REUSABLE SYSTEMS TO BUILD

### 1. Narrative Message Panel (`scenes/ui/narrative_panel.tscn`)
- **Position**: Top-center or bottom-center (choose one, be consistent)
- **Behavior**: Skippable (press any key to advance), does NOT pause gameplay by default
- **Duration**: Auto-dismiss after 8 seconds if not skipped
- **Visual**: Semi-transparent background, high-contrast text, fade in/out over 0.3s
- **Accessibility**: Text scalable (75%-200%), screen reader compatible
- **Audio**: Subtle typewriter sound per character (optional, toggleable)

### 2. Room Completion/Checkpoint System (`scripts/components/room_controller.gd`)
- **Functionality**: Tracks when player enters/exits room, triggers save on completion
- **Signals**: `room_entered(room_id: String)`, `room_completed(room_id: String)`
- **Integration**: Calls `GameManager.set_current_checkpoint_id(room_id)` and `GameManager.save_game()`
- **Visual feedback**: Subtle particle burst or sound when room completes

### 3. Powered Terminal Component (`scenes/components/terminal_powered.tscn`)
- **State**: Powered (blue glow #4A90E2) or unpowered (gray #808080)
- **Interaction**: "Access Terminal" prompt when powered, "No Power" when unpowered
- **Visual**: Screen glow, subtle hum audio (looping, pitch varies with state)
- **Puzzle role**: Often requires player to restore power first (see Room 1)

### 4. Door Component (`scenes/components/door Automated.tscn`)
- **States**: Closed, opening, open, closing, locked
- **Animation**: Slide or fade (choose one, 0.5 second duration)
- **Collision**: Enabled when closed/locked, disabled when open
- **Audio**: Door slide sound, lock click for locked state
- **Control**: Can be opened by terminal, lever, or direct interaction

### 5. Moving Platform Component (`scenes/components/moving_platform.tscn`)
- **Movement**: Fixed path (Path2D), constant speed or wait-at-endpoints
- **Rider behavior**: Character moves with platform, no sliding off
- **Safety**: Emergency stop button nearby (can halt mid-travel)
- **Visual**: Platform has clear edges, warning stripes, directional arrows
- **Audio**: Motor hum while moving, click when stopping

### 6. Hazard Zone Component (`scenes/components/hazard_zone.tscn`)
- **Types**: Electrical (floor sparks), toxic (green mist), thermal (heat distortion)
- **Damage**: Reduces Prototype Integrity by 1 per sustained exposure (not per frame)
- **Telegraph**: Visual warning before activation (0.5s glow), audio warning (rising pitch)
- **Safe zones**: Clearly marked areas between hazards
- **Checkpoint**: If player takes damage, respawn at last safe zone (not room start)

### 7. Prototype Carrier State (`scripts/components/prototype_carrier.gd`)
- **Attached to Elena**: Visual glow around character (particle system, cyan #00FFFF)
- **State**: `has_aster_prototype: bool` (saved in GameManager)
- **Visual**: Glow intensity pulses (1.0 to 1.2 scale, 1s loop)
- **Audio**: Subtle hum (pitch increases near hazards)
- **Mechanic**: Some puzzles only solvable when carrying prototype

---

## ROOM DESIGNS

### Room 1: Power Restoration (Teach)
**Objective**: Restore power to open exit door.

**Setup**:
- Terminal at entrance (unpowered, gray)
- 3 power conduits along path to terminal (visibly broken, sparks)
- Exit door at far end (locked, red indicator)

**Solution** (fixed, readable):
1. Player approaches first conduit, prompt appears: "[E] Repair Conduit"
2. Repair all 3 conduits in sequence (left to right, clearly indicated by numbering)
3. Return to terminal, now powered (blue glow)
4. Access terminal: "Restore Power?" → Yes
5. Door opens, room complete

**Teaching moment**: Conduits must be repaired in order (1→2→3). Wrong order does nothing (no punishment, just feedback: "Conduit 2 damaged. Repair Conduit 1 first.")

**Memory Fragment**: Elena Memory #1 near terminal (floating blue hologram): "Childhood: Elena and Iris building weather station together."

**Narrative message on entry**: "This facility... Helix used it from the start. They knew the protocol could work. They chose not to use it."

**Narrative message on completion**: "Power restored. Partial data recovered: 'Final Thaw Station coordinates locked.'"

---

### Room 2: Robotic Arm Redirect (Test)
**Objective**: Redirect robotic arm to clear path.

**Setup**:
- Terminal controls robotic arm (visible through window)
- Arm cycles through 4 fixed positions: A (left), B (center-left), C (center-right), D (right)
- Only position C clears path (blocks hazard vent)
- Terminal has 4 buttons labeled A-D

**Solution** (fixed, deducible):
1. Observe arm cycle: A→B→C→D→A (3 seconds per position)
2. Note that position C blocks vent (visual: arm physically in way)
3. Access terminal, press button C
4. Arm moves to C, locks in place
5. Path through vent is now safe, proceed to exit

**Test moment**: Player must observe cycle and deduce correct button. No timer, no punishment for wrong choice (arm just moves to wrong position, player can try again).

**Accessibility**: If player fails 3+ times, terminal shows hint: "Position C blocks vent. Press C to lock arm there."

**Memory Fragment**: Marcus Memory #1 in corner (floating orange hologram): "Badge Day: Young Marcus, police academy graduation, mother crying proud tears."

**Narrative message on entry**: "Automated systems. Efficient. Unfeeling. Just like Helix."

---

### Room 3: Moving Platform Traversal (Twist)
**Objective**: Cross gap using moving platform.

**Setup**:
- Gap too wide to jump (clearly marked with warning stripes)
- Moving platform on fixed path (left to right, 5 second cycle)
- Call button on left side (summons platform)
- Emergency stop button on right side (halts platform mid-travel)

**Solution** (fixed, readable):
1. Press call button, platform arrives (2 seconds)
2. Step onto platform
3. Platform moves right automatically
4. Optional: Press emergency stop if you need to pause mid-travel (teaches control)
5. Platform reaches right side, step off, proceed to exit

**Twist**: Platform has weight sensitivity. Moves slower with Elena on it (visible strain animation, motor pitch drops). If player tries to rush (jump off early), platform tips (visual wobble, audio alarm) but doesn't fail—just teaches patience.

**Safety features**:
- If player falls, instant respawn on platform (no damage, no checkpoint loss)
- Emergency stop always available
- No timer, no pressure

**Narrative message on entry**: "Infrastructure failing. Like everything else."

---

### Room 4: Prototype Calibration Chamber (Master)
**Objective**: Carry prototype through hazard zones to exit.

**Setup**:
- Elena picks up prototype at room start (glow activates, `has_aster_prototype = true`)
- 3 hazard zones in sequence: electrical (floor sparks), toxic (green mist), thermal (heat distortion)
- Each hazard has safe path (clearly marked with green floor arrows)
- Final exit requires prototype to be active (terminal only works if `has_aster_prototype = true`)

**Solution** (fixed, master-level):
1. Observe hazard patterns: electrical (2s on, 2s off), toxic (constant, must walk around), thermal (pulses outward from center)
2. Navigate through safe paths:
   - Electrical: Wait for off-cycle, run through (2s window)
   - Toxic: Walk around (no timing, just observation)
   - Thermal: Stay near edges (heat is radial from center)
3. Reach exit terminal, prototype glows brighter
4. Terminal: "Calibrate Protocol?" → Yes
5. Room complete, Phase 2 complete

**Master moment**: Combines all prior mechanics (power management from Room 1, observation from Room 2, platform timing from Room 3). Player must synthesize everything learned.

**Prototype Integrity mechanic**:
- Sustained hazard exposure (≥1 second in hazard zone) reduces `prototype_integrity` by 1
- Damage only once per hazard per checkpoint (can't farm damage)
- If `prototype_integrity` reaches 0, game over (restart from Room 1, but narrative acknowledges failure)
- Visual feedback: Prototype glow flickers, crack sound

**Memory Fragment**: Elena Memory #2 at exit (floating blue hologram): "The Choice: Elena in Helix office, evacuation form 'Select ONE dependant.' Her hand hovering."

**Narrative message on entry**: "The prototype... it's the only hope. But Helix won't let it go."

**Narrative message on completion**: "Calibration complete. Final Thaw Station location locked. Marcus Reyes approaching perimeter."

**Phase 2 completion**: Temporary return-to-menu or next-phase placeholder transition. Show statistics:
- Prototype Integrity remaining (0-3)
- Time taken (optional, not scored)
- Memory fragments collected (X/24)

---

## REQUIREMENTS (Award-Level Standards)

### Puzzle Design
- ✅ Every solution is fixed and readable (no randomness, no guessing)
- ✅ Wrong input resets only local mechanism quickly (no long penalties)
- ✅ All puzzles have undo function (last 3 actions reversible)
- ✅ Hint system available (3 charges per level, highlights correct next step)
- ✅ No softlocks (backup systems, emergency exits always available)

### Save/Checkpoint
- ✅ Auto-save after each room completion
- ✅ Manual save anytime outside hazard zones
- ✅ Checkpoint respawn at room start (not level start) on death
- ✅ All states persist: power, arm position, platform location, prototype integrity

### Narrative
- ✅ Short messages on room entry and completion (skippable, non-blocking)
- ✅ Memory fragments placed (4 total: 2 Elena, 1 Marcus, 1 optional)
- ✅ No exposition dumps—environment tells story (sparks, decay, abandoned equipment)

### Accessibility
- ✅ All puzzles solvable with colorblind mode (visual indicators beyond color)
- ✅ Extended time limit option (+50% for timed sections)
- ✅ Reduced motion option (no camera shake, no platform wobble)
- ✅ Puzzle hint system (3 levels: off, contextual, full solution)

### Performance
- ✅ 60 FPS locked in all rooms (profiler verification)
- ✅ Load time <1s between rooms
- ✅ No memory leaks (memory stable after 10+ room cycles)

---

## ACCEPTANCE CRITERIA (MUST PASS)

1. **Room 1 power puzzle**: Conduits must be repaired in order. Terminal only works when all 3 repaired. Door opens. PASS/FAIL with screenshot

2. **Room 2 arm puzzle**: Arm cycles visibly. Correct button (C) blocks vent. Wrong buttons do nothing harmful. PASS/FAIL

3. **Room 3 platform**: Platform moves on fixed path. Emergency stop works. Falling respawns on platform. PASS/FAIL

4. **Room 4 hazards**: All 3 hazards telegraphed. Safe paths visible. Prototype integrity reduces on sustained exposure. Exit requires prototype. PASS/FAIL

5. **Save/load**: After completing Room 2, save, quit, reload. Arm still in position C, door still open. PASS/FAIL

6. **Checkpoint system**: Die in Room 4, respawn at Room 4 start (not Room 1). PASS/FAIL

7. **Memory fragments**: All 4 collectible, counter updates (e.g., "Memories: 4/24"). PASS/FAIL

8. **Narrative messages**: All 8 messages (4 entry, 4 completion) display correctly, skippable, auto-dismiss after 8s. PASS/FAIL

9. **Accessibility**: Colorblind mode makes hazards distinguishable without color. Extended time option works. Hint system provides correct guidance. PASS/FAIL

10. **Performance**: 60 FPS locked in all rooms. Load time <1s between rooms. Memory stable. PASS/FAIL with profiler screenshots

---

## DO NOT

- Add combat or enemies (Phase 3+)
- Make puzzles time-pressured beyond player comfort
- Hide critical information (all clues must be visible)
- Require frame-perfect timing (generous windows always)
- Create softlocks (player can always reset or backtrack)
- Use randomness (all puzzles deterministic)

---

## FINISH BY REPORTING

1. **Changed files**: List all new/modified files with descriptions
2. **Test results**: For each acceptance criterion, state PASS/FAIL with evidence
3. **Known limitations**: Any unresolved issues, TODOs
4. **Performance metrics**: FPS per room, load times, memory usage
5. **Commit message**: Propose this exact message:

```
Phase 2: abandoned laboratory puzzles complete

Award-level puzzle design with:
- 4 rooms using teach-test-twist-master structure
- Reusable components (terminal, door, platform, hazard, prototype carrier)
- Memory fragments (4/24), skippable narrative messages
- Save/checkpoint system, accessibility options (hints, extended time, colorblind)
- 60 FPS locked, <1s room loads, no softlocks

All 10 acceptance criteria PASS. Ready for Phase 3.
```
