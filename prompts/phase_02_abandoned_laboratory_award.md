You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect existing reusable systems before editing. Phases 0–1 are complete.

**AWARD-LEVEL TARGET**: This implementation must meet The Game Awards / D.I.C.E. / BAFTA standards. Puzzle design must match *Portal 2* quality: every puzzle teaches, tests, then twists. 60 FPS locked is non-negotiable. All accessibility features must be implemented from day one.

GOAL
Create Elena's first complete puzzle chapter: an abandoned laboratory consisting of four compact, sequential puzzle rooms with award-winning design and polish.

## STORY CONTEXT

Elena escapes with the Aster Protocol prototype. In this laboratory, she discovers Helix withheld a viable stabilisation method because it could not control distribution. She retrieves a partial transmission for the future Final Thaw Station.

## DELIVERABLES

### 1. Reusable Systems

#### Narrative Message Panel (Skippable, Non-Blocking)
```gdscript
# scripts/components/narrative_panel.gd
class_name NarrativePanel
extends Control

@export var auto_hide_delay: float = 5.0  # seconds
@export var skip_input: String = "interact"  # allows skipping

func show_message(text: String) -> void:
    $Label.text = text
    visible = true
    # Auto-hide after delay
    yield(get_tree().create_timer(auto_hide_delay), "timeout")
    visible = false

func _input(event: InputEvent) -> void:
    if event.is_action_pressed(skip_input) and visible:
        visible = false  # Allow skipping
```

**Requirements**:
- Does NOT pause gameplay by default
- Skippable with interact input
- Auto-hides after 5 seconds
- Accessible: Scalable text (75%-200%), high contrast mode compatible

#### Room Checkpoint System
```gdscript
# scripts/autoload/room_checkpoint.gd
class_name RoomCheckpoint
extends Node

var completed_rooms: Array = []  # Room IDs

func mark_room_complete(room_id: String) -> void:
    if room_id not in completed_rooms:
        completed_rooms.append(room_id)
        GameManager.set_story_flag("lab_room_" + room_id, true)
        GameManager.save_game()

func is_room_complete(room_id: String) -> bool:
    return room_id in completed_rooms
```

**Requirements**:
- Saves after each room completion
- Allows restart from last completed room on death/failure
- Persists through save/load

#### Reusable Components
- **PoweredTerminal**: Requires power connection, interactable, shows status (on/off)
- **Door**: Opens/closes with animation, can be locked/unlocked
- **MovingPlatform**: Fixed cycle path, callable from button, safe rider behavior
- **HazardZone**: Damages prototype integrity if touched without protection
- **PrototypeCarrier**: Elena has_aster_prototype state, visible glow effect

### 2. Room 1: Power Restoration

**Layout**:
- 3 terminal nodes (A, B, C) in a row
- Power source on left, target device on right
- Instruction panel: "Connect power from source to device"

**Puzzle Flow** (Teach → Test → Twist → Master):
- **Teach**: Show correct connection path (A→B→C) with visual guide (faded arrows)
- **Test**: Player replicates sequence by rotating/connecting nodes
- **Twist**: Node B is broken (sparks, won't conduct), must reroute through backup node D
- **Master**: Complete sequence under optional time pressure (60 seconds, +50% accessibility)

**Visual Feedback**:
- Correct connection: Glows blue, smooth hum audio
- Incorrect connection: Sparks/fizzles immediately, red flash
- Complete circuit: Power flows visibly (particle stream), device activates

**Accessibility**:
- **Hints**: 3 charges, highlights next correct node
- **Undo**: Can reverse last 3 connections before committing
- **Time**: Optional (+50% time setting)
- **No softlock**: Wrong input resets local node only, not entire puzzle

### 3. Room 2: Robotic Arm

**Layout**:
- Robotic arm cycles through 3 fixed positions (left, center, right)
- Passage blocked when arm in center position
- Control terminal cycles arm position
- Instruction: "Redirect the arm to clear the path"

**Puzzle Flow**:
- **Teach**: Arm cycles automatically (5 seconds per position), center blocks path
- **Test**: Player uses terminal to cycle arm to left or right, moves through
- **Twist**: Arm malfunctions, cycles faster (2 seconds) or stops randomly
- **Master**: Must call arm to specific position using button, time movement through

**Visual Feedback**:
- Arm position indicator (LED: left=red, center=yellow, right=green)
- Arm movement telegraphed (servo whine audio, 0.5s before move)
- Safe passage highlighted when arm moves away

**Accessibility**:
- **Audio cues**: Different pitch for each position (low=left, mid=center, high=right)
- **Visual cues**: Color + shape indicators (triangle=closed, circle=open)
- **Time**: No time limit on base puzzle

### 4. Room 3: Moving Platform

**Layout**:
- Gap too wide to jump (200 pixels)
- Platform moves on fixed cycle between two platforms
- Button calls platform to current side
- Instruction: "Use the platform to cross"

**Puzzle Flow**:
- **Teach**: Platform cycles automatically (3 seconds each side), ride it across
- **Test**: Platform stops mid-way, must call from other side using button
- **Twist**: Platform has weight limit (moves slower with Elena on it)
- **Master**: Must move quickly but not panic (platform strain audio when overloaded)

**Visual Feedback**:
- Platform position: Visible track with markers for each stop
- Call button: Lights up when platform is callable
- Weight indicator: Platform sinks slightly with Elena on it, strain particles if overloaded

**Accessibility**:
- **No frame-perfect timing**: Platform waits 3 seconds before moving
- **Backup route**: Ladder on side (slower but safe) if platform fails
- **Visual**: High contrast platform edges, outline shader

### 5. Room 4: Prototype Calibration Chamber

**Layout**:
- Long corridor with 3 hazard zones (electrical, steam, toxic)
- Elena carries prototype (visible glow)
- Exit at far end
- Instruction: "Carry the prototype through without damaging it"

**Hazard Mechanics**:
- **Electrical**: Arcs between floor plates, 1-second telegraph before strike
- **Steam**: Vents spray in pattern (left, right, center), 2-second cycle
- **Toxic**: Pools on floor, avoidable with careful movement

**Prototype Integrity**:
- Starts at 3 (full)
- Sustained hazard exposure (2+ seconds) lowers integrity by 1
- Only once per hazard event/checkpoint (no repeated damage from same hazard)
- Reaching exit without damage preserves integrity (bonus Civilian Aid +1)

**Visual Feedback**:
- Prototype glow: Bright blue (3 integrity), yellow (2), orange (1), red (0)
- Hazard telegraphs: Electrical = crackle audio + spark particles, Steam = whistle + white particles, Toxic = green mist
- Damage indicator: Screen flash orange, Elena flinches

**Accessibility**:
- **Reduced hazards**: Option to disable one hazard type (easiest mode)
- **Visual + audio**: All hazards have both cues (no audio-only or visual-only)
- **Checkpoints**: After each hazard zone, can restart from there on death

### 6. Narrative Messages

**Room Entry Messages** (skippable):
- Room 1: "Power systems offline. Manual restoration required."
- Room 2: "Robotic arm malfunctioning. Proceed with caution."
- Room 3: "Platform unstable. Weight distribution critical."
- Room 4: "Prototype calibration chamber. Hazard zones active."

**Room Completion Messages**:
- Room 1: "Power restored. Access granted to next section."
- Room 2: "Arm redirected. Path clear."
- Room 3: "Platform crossing successful. Structural integrity holding."
- Room 4: "Prototype calibrated. Partial transmission received: Final Thaw Station coordinates locked."

**Final Exit Message**:
"Transmission complete. Helix knew all along. They could have saved everyone, but they chose control. Not anymore."

### 7. GameManager Integration

**New State Variables**:
- `has_aster_prototype`: bool, default false (set true in Room 4)
- `lab_rooms_completed`: int, range 0-4, tracks progress
- `prototype_damage_events`: int, counts how many times integrity lowered

**Functions**:
- `set_has_prototype(value: bool)`: Sets flag, triggers glow effect
- `get_prototype_integrity_display() -> String`: Returns "■■■■" (3), "■■■□" (2), "■■□□" (1), "■□□□" (0)

### 8. Testing Checklist

- [ ] All 4 rooms completable without developer console actions
- [ ] All puzzle solutions fixed, readable, deterministic (no randomness)
- [ ] Doors, terminals, arm positions, platform motion, hazards all functional after save/load
- [ ] No puzzle is soft-lockable (wrong input always recoverable)
- [ ] Hint system functional (3 charges per room, regenerates on reload)
- [ ] Undo function works (last 3 actions reversible)
- [ ] 60 FPS maintained during all puzzles (profiler verification)
- [ ] Accessibility options functional (hints, time extension, reduced hazards)
- [ ] Narrative messages skippable, non-blocking
- [ ] Checkpoint system saves correctly, reloads to last completed room

---

## ACCEPTANCE CRITERIA (MUST ALL PASS)

1. **Room 1 Completable**: Power restoration puzzle solvable, reroute mechanic works, time pressure optional. **PASS/FAIL**: [Test evidence]

2. **Room 2 Completable**: Arm redirection works, malfunction twist clear, button call functional. **PASS/FAIL**: [Test evidence]

3. **Room 3 Completable**: Platform crossing safe, weight mechanic readable, backup route accessible. **PASS/FAIL**: [Test evidence]

4. **Room 4 Completable**: Prototype carried through all 3 hazards, integrity decreases correctly, no unavoidable damage. **PASS/FAIL**: [Test evidence]

5. **Puzzle Determinism**: All solutions fixed, readable, no randomness. Same input = same result every time. **PASS/FAIL**: [Test evidence]

6. **No Softlocks**: Wrong input resets local mechanism only, never entire room. Player always able to retry. **PASS/FAIL**: [Test evidence]

7. **Save/Load**: Save in middle of puzzle, close project, reopen, load. Puzzle state preserved correctly. **PASS/FAIL**: [Test evidence]

8. **Hint System**: 3 charges per room, highlights correct next step, regenerates on reload. **PASS/FAIL**: [Test evidence]

9. **Accessibility**: Time extension (+50%) functional, reduced hazards option works, visual+audio cues on all hazards. **PASS/FAIL**: [Test evidence]

10. **Performance**: 60 FPS locked in all rooms, <16ms frame time, no stuttering during hazard effects. **PASS/FAIL**: [Profiler screenshot]

11. **Narrative Flow**: Messages skippable, non-blocking, context provided without exposition dumps. **PASS/FAIL**: [Test evidence]

12. **Checkpoint System**: Completing room saves progress, death reloads to last completed room, not room start. **PASS/FAIL**: [Test evidence]

---

## DO NOT

- Add randomness to puzzle solutions or enemy spawns
- Create time limits without +50% accessibility option
- Make hazards unavoidable or instant-kill
- Allow softlocks (player must always be able to retry)
- Block main path with optional rescues or collectibles
- Use color-only telegraphs (always audio + visual)

---

## FINISH BY REPORTING

1. **Changed files**: List all new/modified files with brief descriptions
2. **Test results**: For each of 12 acceptance criteria, state PASS/FAIL with evidence
3. **Known limitations**: Any unresolved issues, TODOs, or technical debt
4. **Performance metrics**: FPS in each room, frame time, memory usage
5. **Commit message**: Propose this exact message:

```
Phase 2: abandoned laboratory puzzles complete

Award-level implementation with:
- Portal 2-standard puzzle design (teach-test-twist-master)
- 4 sequential rooms with deterministic solutions
- Accessibility hints (3 charges/room), undo function, +50% time option
- Prototype integrity system with visual/audio hazard telegraphs
- Checkpoint system saves after each room
- 60 FPS locked, no softlocks possible

All 12 acceptance criteria PASS. Ready for Phase 3.
```
