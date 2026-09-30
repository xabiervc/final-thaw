You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect character, navigation, combat, narrative, HUD, and GameManager systems. Phases 0-7 are complete with award-level foundation, movement, puzzles, combat, and boss encounters.

**AWARD-LEVEL TARGET**: This joint mission must establish Elena-Marcus chemistry on par with *The Last of Us* (Joel/Ellie) or *Uncharted 4* (Sam/Drake). Their distrust→respect arc starts here. Dialogue must be skippable but meaningful, choices must matter, and escort mechanics must never frustrate.

GOAL
Build first Elena-Marcus mission using deliberately simple, reliable escort design. Player controls Marcus; Elena follows along safe authored routes and operates protected terminals.

## STORY CONTEXT

Marcus breaches shelter, finds Elena. She distrusts him ("You're Helix"). He warns Helix changed orders ("Terminate if capture fails"). They agree to temporary truce to escape.

**Character beats**:
- Elena sees Marcus as another Helix threat initially
- Marcus sees Elena as redemption opportunity (failed to save Amara, won't fail her)
- First hint of mutual respect: Elena's competence, Marcus's protection
- **First memory fragment**: Elena finds photo of Iris in shelter (Elena Memory #6)

## DELIVERABLES

### 1. Joint Mission Level (`scenes/levels/joint_mission_1.tscn`)

**Layout**:
- **Arena 1**: Small room (15x15m), 3 Scavengers, Elena waits at safe point
- **Terminal 1**: Elena operates while Marcus protects (30 second timer)
- **Gate 1**: Opens after terminal complete, leads to corridor
- **Arena 2**: Corridor (20x10m), 2 Scavengers + 1 Marksman, Elena follows Marcus
- **Terminal 2**: Elena operates while Marcus protects (45 second timer)
- **Gate 2**: Opens, leads to exterior exit
- **Toxic rain sequence**: Short cutscene, fade to Act II hub

**Safe points for Elena**:
- Named waypoints (e.g., "safe_point_1", "safe_point_2")
- Outside combat zones, behind cover
- Marked with invisible Area3D triggers
- Elena pathfinds only between safe points (never through combat)

### 2. Elena Follower Controller (`scripts/characters/elena_follower.gd`)

**Movement**:
- Uses authored Path2D waypoints (NOT dynamic NavigationAgent2D - too unreliable)
- Moves from safe_point to safe_point on mission event
- Speed: Matches Marcus walk speed (280px/s), no sprint
- Stays 100-200px behind Marcus when following

**Behavior states**:
```gdscript
STATE_WAIT = 0      # At safe point, immobile
STATE_MOVING = 1    # Pathing to next safe point
STATE_TERMINAL = 2  # Operating terminal, immobile
STATE_ESCAPE = 3    # Special sequence (toxic rain exit)
```

**Collision**:
- CharacterBody2D with solid collision (can't be pushed by enemies)
- Immune to damage during escort (invulnerable flag)
- Exception: Scripted threat events can decrement Elena Safety (see below)

**AI logic**:
```gdscript
# Simplified, deterministic
func _physics_process(delta):
    match state:
        STATE_WAIT:
            # Stay at current safe point
            velocity = Vector2.ZERO
        STATE_MOVING:
            # Move along Path2D to next safe point
            progress += speed * delta
            global_position = path.curve.sample_baked(progress)
        STATE_TERMINAL:
            # Snap to terminal position, play animation
            global_position = terminal_position
            # Terminal logic handled by interactable
```

**Never**:
- Wander off path
- Run through combat zones
- Get stuck on geometry (test all waypoints)
- Require player protection (design arenas so enemies can't reach her)

### 3. Arena Design for Escort

**Arena 1** (first combat):
- **Size**: 15x15m, enclosed
- **Enemies**: 3 Scavengers (spawn points: 2 near Marcus entry, 1 opposite)
- **Elena safe point**: Behind pillar, 5m from combat, out of enemy line of sight
- **Terminal**: 3m from Elena safe point, she walks to it after combat clear
- **Marcus role**: Clear enemies, then stand near terminal (protect radius)

**Arena 2** (corridor):
- **Size**: 20x10m, linear
- **Enemies**: 2 Scavengers (front), 1 Marksman (back, elevated)
- **Elena behavior**: Follows Marcus 100px behind, stops if Marcus stops
- **Cover**: Pillars every 5m, Marcus can hide, Elena stays behind pillars
- **Terminal**: At far end, Elena operates while Marcus guards door

**Enemy targeting**:
- All enemies target Marcus by default (aggression table: Marcus=100, Elena=0)
- Exception: Scripted event (see Elena Safety below)
- Marksman cannot target Elena through cover (line-of-sight check)

### 4. Elena Safety System

**GameManager tracking** (`game_manager.gd`):
```gdscript
@export var elena_safety: int = 3  # Range 0-3, start 3

func decrement_elena_safety(reason: String) -> void:
    if elena_safety > 0:
        elena_safety -= 1
        emit_signal("elena_safety_changed", elena_safety)
        # Show HUD warning: "Elena in danger!" (red flash)
        # Log reason for debugging
        print("Elena Safety decremented: ", reason)
```

**Defined decrement events** (only these, no others):
1. **Arena 1 proximity**: If enemy crosses protected boundary (5m from Elena safe point) and reaches Elena. Prevent multiple decrements from same enemy (track by enemy ID).
2. **Arena 2 scripted event**: One enemy breaks from wave, runs toward Elena. Must be intercepted by Marcus. If reaches Elena: -1 safety.
3. **Toxic rain sequence**: If Marcus doesn't reach shelter in time (30 seconds), Elena takes exposure: -1 safety.

**HUD indicator**:
- Heart icon + number (e.g., "❤️ 3/3")
- Color: 3=green, 2=yellow, 1=orange, 0=red
- Contextual warning: Flash red when enemy nears Elena (5m)
- Tooltip on first display: "Elena's safety. Protect her from threats."

**Narrative impact**:
- If Elena Safety = 3 at end: Elena dialogue "You kept me safe. Thank you."
- If Elena Safety = 0-1: Elena dialogue "That was... unnecessarily dangerous."
- Tracked for ending calculation (Phase 15)

### 5. Terminal/Gate Events

**Terminal interaction** (`scenes/components/escort_terminal.tscn`):
- **Interaction**: Elena operates (not Marcus)
- **Sequence**:
  1. Marcus clears arena (all enemies defeated)
  2. Signal to Elena: "Terminal clear, approach"
  3. Elena moves to terminal (STATE_MOVING → STATE_TERMINAL)
  4. Terminal progress bar (30-45 seconds)
  5. On complete: Gate opens, emit `terminal_complete` signal
- **Visual**: Progress bar above terminal (cyan fill), Elena typing animation
- **Interrupt**: If enemy enters arena during operation, pause progress, Elena returns to safe point

**Gate** (`scenes/components/escort_gate.tscn`):
- **States**: Closed, opening, open
- **Animation**: Slide up or fade out over 1 second (not instant)
- **Audio**: Mechanical unlock, door slide
- **Collision**: Disable on open

### 6. Dialogue System (Skippable, Non-Blocking)

**Dialogue panel** (`scenes/ui/escort_dialogue.tscn`):
- **Position**: Bottom-center (doesn't block gameplay view)
- **Background**: Semi-transparent black (#80000000), rounded corners
- **Text**: White (#FFFFFF), 20px, high contrast
- **Speakers**: Color-coded (Elena=cyan, Marcus=orange)
- **Behavior**: Appear on trigger, auto-advance after 5 seconds OR skip with any input
- **Audio**: Optional text-to-speech for accessibility

**Dialogue sequence** (first contact):
```
[Marcus]: "Target located. Approaching."
[Elena]: "You're Helix. Stay back."
[Marcus]: "Not anymore. They changed orders. We need to move."
[Elena]: "You expect me to trust you because Helix lied to you?"
[Marcus]: "I expect you to trust that I don't want to die in a flooded shelter."
[Elena]: "...That, at least, is clear."

[Exit sequence - toxic rain]:
[Marcus]: "Temporary truce. We escape together, then decide next steps."
[Elena]: "Agreed. But I choose when and where the protocol goes."
[Marcus]: "As long as it goes somewhere Helix can't reach immediately, we're fine."
```

**Dynamic references** (if player rescued civilians in Phase 6):
```
[Marcus]: "Those people back there... you helped them."
[Elena]: "Someone had to. Unlike your Helix."
[Marcus]: "Yeah. Unlike them."
```

**Memory fragment** (in shelter, near first terminal):
- Elena finds photo of Iris (same age as girl in shelter)
- Dialogue: "She was... never mind. Let's move."
- Collect: Elena Memory #6 ("Iris at this age...")

### 7. Toxic Rain Exit Sequence

**Trigger**: Gate 2 opens, Elena and Marcus reach exterior platform

**Sequence**:
1. **Camera**: Pan up to show toxic rain starting (particle system, green tint)
2. **Dialogue**: Marcus: "Acid rain. We need shelter. Now."
3. **Gameplay**: Short run to shelter (10m, 5 seconds) with rain particles
4. **Arrival**: Enter shelter, fade to black
5. **Act I complete**: Show "Act I Complete" title card, save checkpoint
6. **Transition**: Fade to Act II hub (vehicle minigame or direct to Phase 9)

**Visual**:
- Rain particles: Green (#40FF40), density 500 particles, lifetime 2 seconds
- Screen overlay: Green tint (#2000FF00), 20% opacity
- Audio: Hissing rain, sizzling on metal

**Accessibility**:
- Reduced motion option: Particles reduced by 75%, no screen tint
- Reduced weather intensity: Particle density 200 instead of 500

### 8. Save/Checkpoint System

**Autosave triggers**:
- Arena 1 clear
- Terminal 1 complete
- Arena 2 clear
- Terminal 2 complete
- Toxic rain sequence start

**Checkpoint**: After Terminal 2 complete, before toxic rain

**Save data**:
- Elena Safety value
- Civilians rescued count (from Phase 6)
- Memory fragments collected
- Current checkpoint ID ("joint_mission_1_arena_2", etc.)

**Load behavior**:
- Restore Elena to current safe point
- Restore Marcus to arena start (if died)
- Restore enemy states (defeated enemies stay defeated)
- Restore Elena Safety if decremented

---

## ACCEPTANCE CRITERIA (MUST PASS)

1. **Elena pathfinding**: Follows Path2D waypoints exactly, never deviates, never gets stuck. Test all safe points. PASS/FAIL

2. **Elena collision**: Solid (can't be pushed), invulnerable to enemies. Test with enemy attacks. PASS/FAIL

3. **Enemy targeting**: All enemies target Marcus (100% aggression), ignore Elena. Test with 5+ enemies. PASS/FAIL

4. **Elena Safety decrements**: Only on defined events (Arena 1 proximity, Arena 2 scripted, toxic rain timeout). No accidental decrements. Test all 3. PASS/FAIL

5. **HUD indicator**: Shows Elena Safety (heart + number), color-coded (3=green to 0=red), contextual warning flash. PASS/FAIL

6. **Terminal sequence**: Marcus clears → Elena approaches → operates (30-45s) → gate opens. Interrupt if enemy enters. Test full sequence. PASS/FAIL

7. **Dialogue**: Appears at correct triggers, skippable with any input, auto-advances after 5s. Dynamic references work (if civilians rescued). PASS/FAIL

8. **Memory fragment**: Elena Memory #6 placed, collectible, tracked in GameManager, persists on save/load. PASS/FAIL

9. **Toxic rain sequence**: Particles, tint, dialogue, run to shelter, fade, Act I complete card. All skippable with reduced motion option. PASS/FAIL

10. **Save/load**: Elena Safety, checkpoint, enemy states, memory fragments persist. Test mid-mission save, quit, reload. PASS/FAIL

11. **Performance**: 60 FPS locked with rain particles (500), 5 enemies, dialogue panel. Profiler: <5ms per frame. PASS/FAIL

12. **Accessibility**: Reduced motion (particles -75%, no tint), reduced weather (density 200), high contrast dialogue. Test all options. PASS/FAIL

---

## DO NOT

- Make Elena require constant protection (design arenas so she's naturally safe)
- Allow enemies to accidentally target Elena (aggression table = 0)
- Create long unskippable dialogue (max 5s per line, skip with any input)
- Reduce Elena Safety for normal combat (only scripted events)
- Use dynamic pathfinding for Elena (Path2D waypoints only, no NavAgent)
- Softlock progression (gate always opens if terminal complete, even if Marcus dies)

---

## FINISH BY REPORTING

1. **Changed files**: List all new/modified files with descriptions
2. **Test results**: For each acceptance criterion, state PASS/FAIL with evidence
3. **Known limitations**: Any unresolved issues, TODOs, technical debt
4. **Performance metrics**: FPS with rain particles, dialogue panel, 5 enemies
5. **Commit message**: Propose this exact message:

```
Phase 8: first joint mission complete

Award-level escort design with:
- Elena follows Path2D waypoints (never dynamic NavAgent, no stuck issues)
- Enemy targeting: Marcus 100%, Elena 0% (designed arenas, natural safety)
- Elena Safety system (3 defined decrement events, HUD indicator, narrative impact)
- Terminal/gate sequences (Marcus clears → Elena operates → gate opens)
- Skippable dialogue (5s auto, any input skip, dynamic references)
- Toxic rain exit (particles, tint, Act I complete card, accessibility options)
- Memory fragment #6 placed (Elena: "Iris at this age...")
- Full save/load persistence (Safety, checkpoint, enemies, memories)

All 12 acceptance criteria PASS. 60 FPS locked. Ready for Phase 9.
```
