You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect the existing project before editing. Phase 0 is complete: MainMenu, GameManager, HUD, Input Map, and test_room exist.

**AWARD-LEVEL TARGET**: This implementation must meet The Game Awards / D.I.C.E. / BAFTA standards. Movement must feel as smooth and responsive as *Hades* or *Celeste*. Every interaction must be deterministic and accessible. 60 FPS locked is non-negotiable.

GOAL
Implement Elena Vast's reusable movement, interaction, and scan foundation in a readable isometric 2D/2.5D room with award-winning polish.

CONTEXT
Elena is an atmospheric systems scientist. Her gameplay focuses on navigation, observation, environmental systems, terminals, and non-lethal puzzle interaction. No combat in this phase.

## DELIVERABLES

### 1. Elena Character Scene (`scenes/characters/elena_character.tscn`)

**Structure**:
```
Elena (CharacterBody2D)
├─ CollisionShape2D (capsule or circle, 48x48 pixels)
├─ Sprite (placeholder: blue rectangle or circle, 64x64)
├─ Shadow (ellipse, slightly offset, semi-transparent black)
├─ Camera2D (smooth follow enabled, drag margin 0.1)
├─ InteractionRay (RayCast2D, 200 pixels, collision_mask: interactables)
└─ ScanArea (Area2D, 200 pixels radius, collision_layer: scan_targets)
```

**Requirements**:
- Collision: CharacterBody2D with proper collision layer/mask (layer 1, mask 3 for walls/interactables)
- Sprite: Blue color (#4A90E2) for Elena, visible from distance
- Ground shadow: Makes location clear in isometric view, always grounded
- Camera: Smooth follow (drag enabled), keeps Elena centered but allows edge panning
- InteractionRay: Points in movement direction or last input direction
- ScanArea: Detects all interactables within 200 pixels

### 2. Elena Movement Script (`scripts/characters/elena.gd`)

**Movement Constants** (tweakable in inspector):
```gdscript
const ACCELERATION = 800.0  # pixels/second²
const DECELERATION = 1000.0  # pixels/second²
const MAX_SPEED = 300.0  # pixels/second
const STOP_THRESHOLD = 5.0  # pixels/second (snap to zero)
```

**Movement Logic**:
- Read Input Map actions (`move_up`, `move_down`, `move_left`, `move_right`)
- Create input vector, normalize if length > 1.0 (no faster diagonals)
- Apply acceleration/deceleration (not instant start/stop)
- Use `move_and_slide()` for collision detection
- Snap to zero when speed < STOP_THRESHOLD (prevents micro-movement jitter)
- Track facing direction for interaction ray

**Code Structure**:
```gdscript
extends CharacterBody2D

@export var acceleration: float = 800.0
@export var deceleration: float = 1000.0
@export var max_speed: float = 300.0

var input_vector: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.DOWN  # default facing down

func _physics_process(delta: float) -> void:
    # Get input
    input_vector = Vector2.ZERO
    input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
    
    # Normalize diagonal movement
    if input_vector.length() > 1.0:
        input_vector = input_vector.normalized()
    
    # Update facing direction
    if input_vector != Vector2.ZERO:
        facing_direction = input_vector.normalized()
    
    # Apply acceleration/deceleration
    if input_vector != Vector2.ZERO:
        velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
    else:
        velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
    
    # Snap to zero
    if velocity.length() < 5.0:
        velocity = Vector2.ZERO
    
    # Move
    move_and_slide()
```

**Accessibility Requirements**:
- Movement works with keyboard (WASD/arrows), controller (L-stick), and remapped inputs
- No timing-based movement (no stamina, no dash requirements for basic navigation)
- Speed is consistent across all input methods

### 3. Interactable Component (`scripts/components/interactable.gd`)

**Base Script**:
```gdscript
class_name Interactable
extends Node2D

@export var display_name: String = "Interactive Object"
@export var prompt_text: String = "Interact"
@export var enabled: bool = true
@export var interaction_range: float = 64.0  # pixels

signal interacted(actor)

var is_being_interacted_with: bool = false

func interact(actor: Node2D) -> void:
    if not enabled:
        return
    is_being_interacted_with = true
    emit_signal("interacted", actor)
    # Override this method in derived classes
    print("Interacted with %s" % display_name)
    is_being_interacted_with = false

func get_interaction_prompt() -> String:
    return prompt_text
```

**Derived Classes** (create as separate scripts):
- `TerminalInteractable`: For computer terminals, shows text interface
- `LeverInteractable`: For switches, toggles state on interact
- `DoorInteractable`: For doors, opens/closes with animation
- `PickupInteractable`: For collectibles (memory fragments, items)

**Group System**:
- All interactables must be in "interactables" group (for scan detection)
- Add to group in scene or via script: `add_to_group("interactables")`

### 4. Nearest-Target Selection System (`scripts/components/interaction_system.gd`)

**Autoload or Component**:
```gdscript
class_name InteractionSystem
extends Node

const MAX_INTERACTION_RANGE: float = 64.0  # pixels

var nearest_interactable: Interactable = null

func _physics_process(delta: float) -> void:
    # Find all interactables in range
    var interactables_in_range: Array = []
    for interactable in get_tree().get_nodes_in_group("interactables"):
        if not interactable is Interactable:
            continue
        if not interactable.enabled:
            continue
        
        # Calculate distance to player (Elena)
        var player = get_node_or_null("../Elena")  # Adjust path as needed
        if player == null:
            continue
        
        var distance = player.global_position.distance_to(interactable.global_position)
        if distance <= MAX_INTERACTION_RANGE:
            interactables_in_range.append({
                "node": interactable,
                "distance": distance
            })
    
    # Select nearest (tie-break by stable node order)
    if interactables_in_range.size() > 0:
        interactables_in_range.sort_custom(func(a, b): return a.distance < b.distance)
        nearest_interactable = interactables_in_range[0].node
    else:
        nearest_interactable = null
    
    # Update UI prompt
    update_interaction_prompt()

func update_interaction_prompt() -> void:
    if nearest_interactable != null:
        # Show prompt via HUD or UI
        var prompt = nearest_interactable.get_interaction_prompt()
        var name = nearest_interactable.display_name
        HUD.show_interaction_prompt(prompt, name)
    else:
        HUD.hide_interaction_prompt()

func perform_interaction() -> void:
    if nearest_interactable != null:
        var player = get_node_or_null("../Elena")
        nearest_interactable.interact(player)
```

**Deterministic Selection**:
- Primary sort: Distance (nearest first)
- Tie-breaker: Node tree order (first added to scene wins)
- No randomness, no flickering between targets

**Visual Feedback**:
- Highlight nearest interactable (shader, color tint, or outline)
- Show interaction prompt: "[E] {prompt_text} - {display_name}"
- Prompt appears only when in range, disappears when out of range

### 5. Scan System (`scripts/components/scan_system.gd`)

**Scan Input**: Bound to `scan` action (Q or Controller LB)

**Scan Logic**:
```gdscript
var scan_pressed: bool = false

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("scan"):
        scan_pressed = true
        perform_scan()
    elif event.is_action_released("scan"):
        scan_pressed = false
        clear_scan_highlight()

func perform_scan() -> void:
    # Find all interactables within 200 pixels
    var player = get_node_or_null("../Elena")
    if player == null:
        return
    
    var scan_radius: float = 200.0
    for interactable in get_tree().get_nodes_in_group("interactables"):
        if not interactable is Interactable:
            continue
        
        var distance = player.global_position.distance_to(interactable.global_position)
        if distance <= scan_radius:
            # Highlight interactable
            interactable.set_scan_highlight(true)

func clear_scan_highlight() -> void:
    for interactable in get_tree().get_nodes_in_group("interactables"):
        if interactable.has_method("set_scan_highlight"):
            interactable.set_scan_highlight(false)
```

**Visual Treatment**:
- Scan highlight: Bright outline, glow effect, or color pulse
- Accessible: High contrast, works with colorblind modes (use outline + pattern, not color alone)
- No cooldown: Hold to maintain scan, release to clear
- Does NOT modify puzzle state (purely informational)

**Audio Feedback**:
- Subtle hum or chime when scanning (optional, toggleable in accessibility)
- Different pitch for different interactable types (terminal = high, lever = mid, door = low)

### 6. Elena Test Room (`scenes/levels/elena_test_room.tscn`)

**Environment**:
- Floor: Neutral gray (#808080) with subtle grid pattern for readability
- Walls: Collision boundaries, clearly marked (invisible or dark outline)
- Lighting: Even, no dark corners (test visibility)
- Size: Approximately 800x600 pixels (enough for movement + 3 interactables)

**Interactables** (at least 3 types):
1. **Terminal**: `TerminalInteractable`, displays text when interacted
   - Position: Near center of room
   - Prompt: "Access Terminal"
   - On interact: Show message "Terminal accessed. Data downloaded."

2. **Lever**: `LeverInteractable`, toggles state
   - Position: Against one wall
   - Prompt: "Pull Lever"
   - On interact: Toggle lever animation, change state (on/off)

3. **Locked Door**: `DoorInteractable`, opens with animation
   - Position: Exit of room
   - Prompt: "Open Door"
   - On interact: Play open animation, allow passage

**Instruction Panel**:
- StaticText or Label node
- Content:
  ```
  Controls:
  - WASD / Arrows / L-Stick: Move
  - E / F / X: Interact
  - Q / LB: Scan
  
  Interact with all objects to test the system.
  ```

**Testing Checklist** (as comments in scene file):
- [ ] Elena moves smoothly, no floaty or stiff feeling
- [ ] Diagonal movement same speed as cardinal directions
- [ ] Cannot leave room bounds (collision works)
- [ ] Interaction prompt appears at 64 pixels, consistent for all objects
- [ ] Nearest target selected deterministically (no flickering)
- [ ] Scan highlights all interactables within 200 pixels
- [ ] Scan does not modify puzzle state
- [ ] 60 FPS maintained (verify with profiler)
- [ ] All inputs work with keyboard and controller
- [ ] Save/load preserves Elena position and interactable states

### 7. GameManager Integration

**Update `game_manager.gd`**:
- Add `active_character_id` variable: String, default "elena"
- Add `set_active_character(character_id: String)` function
- Add `get_active_character() -> String` function
- Emit `character_switched(character_id: String)` signal when changed

**Purpose**: Prepares for later character switching (Phase 8+), but do NOT implement free switching yet. Just track which character is active.

### 8. HUD Integration

**Update `hud.tscn`**:
- Add interaction prompt label (bottom-center or near player)
- Format: "[E] {prompt} - {name}" or controller equivalent
- Auto-hide when no interactable in range
- Accessibility: Scalable text (75%-200%), high contrast option

- Add scan indicator (optional): Shows "Scanning..." or icon when scan active

---

## ACCEPTANCE CRITERIA (MUST ALL PASS)

1. **Movement Smoothness**: Elena accelerates/decelerates smoothly, not instant start/stop. Feels responsive, not floaty or stiff. **PASS/FAIL**: [Test evidence]

2. **Diagonal Normalization**: Moving diagonally (e.g., W+D) is same speed as cardinal (W only). **PASS/FAIL**: [Profiler measurement]

3. **Room Bounds**: Elena cannot leave room. Collision prevents escape. **PASS/FAIL**: [Test evidence]

4. **Ground Shadow**: Shadow visible, makes Elena's position clear in isometric view. **PASS/FAIL**: [Screenshot]

5. **Interaction Prompt**: Appears consistently at 64 pixels from interactable. Shows correct prompt text and display name. **PASS/FAIL**: [Test evidence]

6. **Nearest-Target Selection**: When multiple interactables in range, nearest is selected. No flickering. Tie-breaker is deterministic. **PASS/FAIL**: [Test evidence]

7. **Scan System**: Highlights all interactables within 200 pixels. Does not modify puzzle state. Visual treatment is accessible (outline + pattern, not color alone). **PASS/FAIL**: [Test evidence]

8. **Input Compatibility**: All inputs work with keyboard (WASD/arrows), controller (L-stick, buttons), and remapped bindings. **PASS/FAIL**: [Test evidence]

9. **Performance**: 60 FPS locked in test_room with profiler showing <16ms frame time. No stuttering. **PASS/FAIL**: [Profiler screenshot]

10. **Save/Load**: Save game with Elena near interactable, close project, reopen, load. Elena position and interactable states preserved. **PASS/FAIL**: [Test evidence]

11. **Accessibility**: Interaction prompt visible with high contrast mode. Text scalable 75%-200%. Scan works with colorblind mode (outline, not just color). **PASS/FAIL**: [Test evidence]

12. **No Errors**: No parser errors, no runtime errors, no warnings in Godot Output panel. **PASS/FAIL**: [Output panel screenshot]

---

## DO NOT

- Implement combat (this is Elena-only puzzle phase)
- Add randomness to movement, interaction, or scan
- Hardcode key bindings (use Input Map only)
- Implement character switching yet (just track active_character_id)
- Create final art (use placeholder sprites)
- Add time pressure or fail states (this is a test/exploration phase)

---

## FINISH BY REPORTING

1. **Changed files**: List all new/modified files with brief descriptions
2. **Test results**: For each of 12 acceptance criteria, state PASS/FAIL with evidence (screenshots, profiler data, test notes)
3. **Known limitations**: Any unresolved issues, TODOs, or technical debt
4. **Performance metrics**: FPS in test_room, frame time, memory usage
5. **Commit message**: Propose this exact message:

```
Phase 1: Elena movement and observation complete

Award-level implementation with:
- Smooth, normalized movement (Hades/Celeste feel)
- Deterministic nearest-target interaction system
- Accessible scan system (outline + pattern, no cooldown)
- Comprehensive test room with 3 interactable types
- Full keyboard + controller support
- 60 FPS locked, <16ms frame time

All 12 acceptance criteria PASS. Ready for Phase 2.
```
